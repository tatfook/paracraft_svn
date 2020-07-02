--[[
Title:  OBSOLETED use JGSL_grid instead: When a jabber server receives a message from the client, it will accept it or reject it. If accepted, it will reply so and create a JGSL_client_agent character on the server computer if it has never been created before. This JGSL_client_agent will be responsible to keep track of an active client on the server. 
Author(s): LiXizhi
Date: 2007/11/6, revised by LiXizhi 2008.6.26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_msg_def.lua");

if(not Map3DSystem.JGSL_server) then Map3DSystem.JGSL_server={}; end

local JGSL_server = Map3DSystem.JGSL_server;
local JGSL_client = Map3DSystem.JGSL_client;
local JGSL = Map3DSystem.JGSL;
local JGSL_msg = Map3DSystem.JGSL_msg;

-- server session key, it is regenerated each time we load a different world.
JGSL_server.sessionkey = ParaGlobal.GenerateUniqueID();

-- server version
JGSL_server.ServerVersion = 1;

-- required client version
JGSL_server.ClientVersion = 1;


-- the agent of the current player
JGSL_server.playeragent = nil;

-- timer ID
JGSL_server.TimerID = 17;

-- contains all client and server agent creation and environmental action history. 
JGSL_server.history = {
	creations = {},
	env = {},
}

-- max number of creations in a message
JGSL_server.max_creations_per_msg = 5;
-- max number of env updates in a message
JGSL_server.max_env_per_msg = 5;

-- a timer that is enabled when there are active client connected to this server.
-- should be smaller or equal to Map3DSystem.JGSL_client.NormalUpdateInterval to prevent duplicate group2 info to be sent for the same client.
JGSL_server.TimerInterval = 3000;

-- if a client is not responding in 20 seconds, we will make it inactive user and remove from active user list. 
JGSL_server.ClientTimeOut = 20000;

-- if true, the game server is a dedicated server usually without any user interface. Pure server will use a different restart function. 
JGSL_server.IsPureServer = nil;

-- a new character will be located at radius = miniSpawnRadius+math.sqrt(OnlineUserNum+1)*3;
JGSL_server.miniSpawnRadius = 5;

-- When the server has broadcasted this number of objects, the server will be automatically restarted; this is usually the setting for testing public server.
JGSL_server.RestartOnCreateNum = tonumber(ParaEngine.GetAppCommandLineByParam("RestartOnCreateNum", "0"));

-- client agents on server, where JGSL_server.agents[JID] = {agent}.
JGSL_server.agents = {};

------------------------------
-- public function
------------------------------
-- regenerate session and become a new server. This is usually called by Map3DSystem.JGSL.Reset()
-- call this to reset the server to inital disconnected state where there is a new session key, no history, no timer, no agents. 
function JGSL_server.Reset()
	-- regenerate session key 
	JGSL_server.sessionkey = ParaGlobal.GenerateUniqueID();
	-- clear agents
	JGSL_server.agents = {};
	
	-- clear history
	JGSL_server.history.clear();
	
	-- only send creation messages from this time. 
	JGSL_server.LastCreationHistoryTime = nil;
	-- only send env messages from this time. 
	JGSL_server.LastEnvHistoryTime = nil;
	
	NPL.KillTimer(JGSL_server.TimerID);
end


-- stop the timer and clear the server creation history. call this function when there are no users connected. 
-- JGSL will be active as long as there is a new client connection to it. 
function JGSL_server.MakeServerPassive()
	JGSL_server.Reset();
	JGSL.Log("JGSL 服务器最近无人访问变成了被动模式, Timer关闭了")
end

------------------------------
-- private functions
------------------------------
-- get the agent representing the current player. 
function JGSL_server.GetPlayerAgent()
	if(JGSL_server.playeragent == nil or JGSL_server.playeragent.JID~=JGSL.GetJID()) then
		JGSL_server.playeragent = JGSL.agent:new({JID = JGSL.GetJID(),})
	end
	return JGSL_server.playeragent;
end

-- it will create the agent structure if it does not exist
function JGSL_server.GetAgent(JID)
	if(not JID) then return end
	local agent = JGSL_server.agents[JID];
	if(not agent) then
		agent = JGSL_server.CreateAgent(JID)
	end
	return agent;
end

-- create an agent. it will overwrite existing one, if any, with a newly created one. 
function JGSL_server.CreateAgent(JID)
	local agent = JGSL.agent:new{JID = JID};
	JGSL_server.agents[JID] = agent;
	return agent;
end

-- some statistics
JGSL_server.statistics = {
	StartTime = ParaGlobal.GetDateFormat(nil)..ParaGlobal.GetTimeFormat(nil),
	OnlineUserNum = 0,
	VisitsSinceStart = 0,
	NumObjectCreated = 0,
}

-- clear all history. call this function when a server restart.
function JGSL_server.history.clear()
	JGSL_server.history.creations = {};
	JGSL_server.history.env = {};
end

-- when the server receives some client updates that contains creations, it will save all clients' creations
-- to an array. At normal update time, the server will broadcast previous creations to the clients.
-- @param creations: an array of creation history
-- @param fromJID: who added this creations. 
function JGSL_server.history.AddCreations(creations, fromJID)
	if(creations and #creations>0) then 
		local nOldSize = #(JGSL_server.history.creations)
		local i;
		for i = 1, #creations do
			if(fromJID~=nil) then
				-- secretly change the author anyway.
				creations[i].fromJID = fromJID
			end	
			JGSL_server.history.creations[nOldSize+i] = creations[i];
		end
	end
end

-- when the server receives some client updates that contains env updates, it will save all clients' creations
-- to an array. At normal update time, the server will broadcast previous envs to the clients.
-- @param env: an array of env history
-- @param fromJID: who added this env. 
function JGSL_server.history.AddEnvs(env, fromJID)
	if(env and #env>0) then 
		local nOldSize = #(JGSL_server.history.env)
		local i;
		for i = 1, #(env) do
			if(fromJID~=nil) then
				-- secretly change the author anyway.
				env[i].fromJID = fromJID
			end	
			JGSL_server.history.env[nOldSize+i] = env[i];
		end
	end	
end


-- get an array of creations from the server creation history.
-- @param agent:  the agent for whom creations will be retrieved. In fact, it will return all creations 
-- who time is larger than agent.LastCreationHistoryTime, and whose agent.fromJID is different from the one in creation history.
-- @param MaxCount: nil or max number of creations to return. This prevents sending too many in a single message. 
-- @return: return nil or an array of creations for sending back to the client agent
function JGSL_server.history.GetCreationsForClientAgent(agent, MaxCount)
	agent.LastCreationHistoryTime = agent.LastCreationHistoryTime or 0;
	local i;
	local Count = #(JGSL_server.history.creations) - agent.LastCreationHistoryTime;
	if(MaxCount~=nil and Count>MaxCount) then
		Count = MaxCount;
	end
	local creations;
	for i = 1, Count do
		local new_msg = JGSL_server.history.creations[i+agent.LastCreationHistoryTime];
		if(new_msg.fromJID ~= agent.JID) then
			if(creations == nil) then
				creations = {};
			end
			creations[#creations+1] = new_msg
		end	
	end
	agent.LastCreationHistoryTime = agent.LastCreationHistoryTime+Count;
	
	return creations;
end


-- get an array of creations from the server creation history.
-- @param agent:  the agent for whom creations will be retrieved. In fact, it will return all creations 
-- who time is larger than agent.LastEnvHistoryTime, and whose agent.fromJID is different from the one in creation history.
-- @param MaxCount: nil or max number of creations to return. This prevents sending too many in a single message. 
-- @return: return nil or an array of creations for sending back to the client agent
function JGSL_server.history.GetEnvsForClientAgent(agent, MaxCount)
	agent.LastEnvHistoryTime = agent.LastEnvHistoryTime or 0;
	local i;
	local Count = #(JGSL_server.history.env) - agent.LastEnvHistoryTime;
	if(MaxCount~=nil and Count>MaxCount) then
		Count = MaxCount;
	end
	local env;
	for i = 1, Count do
		local new_msg = JGSL_server.history.env[i+agent.LastEnvHistoryTime];
		if(new_msg.fromJID ~= agent.JID) then
			if(env == nil) then
				env = {};
			end
			env[#env+1] = new_msg
		end	
	end
	agent.LastEnvHistoryTime = agent.LastEnvHistoryTime+Count;
	
	return env;
end

-- when some remote user creations are received by this computer, it will be applied in this world, however, without writing into the history. 
function JGSL_server.ApplyCreations(creations)
	if(creations==nil) then return end

	for i = 1, #(creations) do
		-- create without writing to history
		local new_msg = {
			SkipHistory = true,
		}
		commonlib.partialcopy(new_msg, creations[i]);
		Map3DSystem.SendMessage_obj(new_msg);
	end
end

-- when some remote user creations are received by this computer, it will be applied in this world, however, without writing into the history. 
function JGSL_server.ApplyEnvs(env)
	if(env==nil) then return end
	
	for i = 1, #(env) do
		-- create without writing to history
		local new_msg = {
			SkipHistory = true,
		}
		commonlib.partialcopy(new_msg, env[i]);
		Map3DSystem.SendMessage_env(new_msg);
	end
end

-- a very slowly kicked timer that periodically check user status
function JGSL_server.OnTimer()

	local curTime = ParaGlobal.GetGameTime();
	local _, agent;
	local count = 0;
	local TimedOutAgents;
	-- check for any client agent that is not active
	for _, agent in pairs(JGSL_server.agents) do
		if(agent:CheckTimeOut(curTime, JGSL_server.ClientTimeOut)) then
			-- if the agent is timed out, remove character and make inactive 
			JGSL.Log(string.format("用户 %s 离开了JGSL服务器", agent.JID));
			agent:cleanup();
			-- Mark the agent JID to be deleted after the iteration
			TimedOutAgents = TimedOutAgents or {};
			TimedOutAgents[agent.JID] = true;
			-- send game event 
			Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JGSL_USER_LEAVE, userJID=agent.JID})
		else	
			count = count +1;
		end
	end
	-- delete timed out agents
	if(TimedOutAgents~=nil) then
		local key, _;
		for key, _ in pairs(TimedOutAgents) do
			JGSL_server.agents[key] = nil;
		end
	end
	
	-- just kill timer, if there are no more agents
	if(count==0)then
		JGSL_server.MakeServerPassive();
	end
	
	-- only update current player agent in timer. 
	local agent = JGSL_server.GetPlayerAgent();
	agent:UpdateFromPlayer(ParaScene.GetPlayer());
	
	---------------------------
	-- add object message: creation, modification, deletion
	---------------------------
	local history = Map3DSystem.obj.GetHistory();
	local time = history.creations:GetLastTime();
	if(time~=nil and (JGSL_server.LastCreationHistoryTime and time > JGSL_server.LastCreationHistoryTime)) then
		local t;
		local creations;
		for t=JGSL_server.LastCreationHistoryTime+1, time do
			local msg = history.creations:getValue(1, t);
			if(msg~=nil and msg.author == ParaScene.GetPlayer().name) then
				if(creations == nil) then
					creations = {};
				end
				-- secretly change the name of the operation to the client JID
				local new_msg = {author = agent.name}
				commonlib.partialcopy(new_msg, msg);
				creations[#creations+1] = new_msg;
			end
		end
		JGSL_server.LastCreationHistoryTime = time;
		
		-- add to creation history
		if(creations~=nil) then
			JGSL_server.history.AddCreations(creations, JGSL.GetJID())
		end
	end
	
	---------------------------
	-- env message: ocean, terrain paint, heightmap, etc. 
	---------------------------
	local history = Map3DSystem.Env.GetHistory();
	local time = history.env:GetLastTime();
	if(time~=nil and (JGSL_server.LastEnvHistoryTime and time>JGSL_server.LastEnvHistoryTime)) then
		local t;
		local env;
		for t=JGSL_server.LastEnvHistoryTime+1, time do
			local msg = history.env:getValue(1, t);
			if(msg~=nil and msg.author == ParaScene.GetPlayer().name) then
				if(env == nil) then
					env = {};
				end
				-- secretly change the name of the operation to the client JID
				local new_msg = {author = agent.name}
				commonlib.partialcopy(new_msg, msg);
				env[table.getn(env)+1] = new_msg;
			end
		end
		JGSL_server.LastEnvHistoryTime = time;
		
		-- add to env history
		if(env~=nil) then
			-- compress to reduce redundencies 
			JGSL.CompressEnvs(env);
			JGSL_server.history.AddEnvs(env, JGSL.GetJID())
		end
	end
end

local function activate()
	if(JGSL.IsGrid) then
		return Map3DSystem.JGSL_grid.activate();
	end
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local JID = string.gsub(msg.from, "/.*$", "");
	
	if(JGSL.dump_server_msg) then
		log(JGSL.GetJID().." received from client "..tostring(JID).."\n\n");
		log(commonlib.serialize(msg));
	end
	
	if(msg.error and type(msg.error)=="table") then
		commonlib.echo({JID=JID, msg.error})
		JGSL.Log(string.format("%s: %s", JID, tostring(msg.error.msg)));
		--if(msg.error.code == 500 and msg.error.condition == "resource-constraint") then
			-- msg.error.msg: Your contact offline message queue is full. The message has been discarded.
		--end
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JGSL_SERVER_ERROR})
		JGSL_client.LogoutServer(true);	
		return
	end
	
	-- check if session key is valid, except for the CS_PING message. 
	if(msg.sk ~= JGSL_server.sessionkey and msg.type ~=JGSL_msg.CS_PING) then
		commonlib.log("jgsl server ignored an invalid session key %s from JID %s\n", tostring(msg.sk), JID)
		return;
	end
	
	if(msg.type == JGSL_msg.CS_NormalUpdate) then
		------------------------------------
		-- a client sends us(server) a normal update
		------------------------------------
		-- update the client agent on server
		local agent_from = JGSL_server.GetAgent(JID);
		if(agent_from==nil or msg.agent==nil) then return end
		
		if(not agent_from.SignedIn ) then
			log("agent is not signed in, but we received a packet from it. possibly because it is an offline message due to immediate close down of server or client.\n");
			return;
		end
		
		local out_msg = {type = JGSL_msg.SC_NormalUpdate, agents = {}};
		
		-- get all creations since last update feedback
		out_msg.creations = JGSL_server.history.GetCreationsForClientAgent(agent_from, JGSL_server.max_creations_per_msg)
		-- get all env updates since last update feedback
		out_msg.env = JGSL_server.history.GetEnvsForClientAgent(agent_from, JGSL_server.max_env_per_msg)
		
		-- update any object creations contained in the client update. 
		JGSL_server.history.AddCreations(msg.agent.creations, JID);
		JGSL_server.ApplyCreations(msg.agent.creations);
		
		-- update any object env updates contained in the client update. 
		JGSL_server.history.AddEnvs(msg.agent.env, JID);
		JGSL_server.ApplyEnvs(msg.agent.env);
		
		agent_from:UpdateFromStream(msg.agent);
		agent_from:update();
		
		-- send all client agents updates to client
		local _, agent;
		local index = 1;
		for _, agent in pairs(JGSL_server.agents) do
			-- TODO: does jabber:XMPP has a group chat function, which performs better than this simple enumeration?
			-- skip the sender agent
			if(agent.JID~=JID) then
				if(msg.agent.GTwo) then
					agent.group2[JID] = true;
				end
				local GTwo; -- very tricky here, but it sures that if any client agent group2 changes, it will be broadcasted only once in all other client agent's normal update
				if(agent_from.group2[agent.JID]) then
					agent_from.group2[agent.JID] = nil;
					GTwo = true;
				else
					GTwo = JGSL.SearchRequestGroup(msg.agent.req_GTwo, agent.JID);
				end
				out_msg.agents[index] = agent:GenerateUpdateStream({GTwo=GTwo});
				index = index +1;
			end	
		end
		
		-- send the player itself as the last one in the agent table. 
		local agent = JGSL_server.GetPlayerAgent();
		local GTwo; -- very tricky here, but it sures that if any client agent group2 changes, it will be broadcasted only once in all other client agent's normal update
		if(agent_from.group2[agent.JID]) then
			agent_from.group2[agent.JID] = nil;
			GTwo = true;
		else
			GTwo = JGSL.SearchRequestGroup(msg.agent.req_GTwo, agent.JID);
		end
		out_msg.agents[index] = agent:GenerateUpdateStream({GTwo=GTwo});

		-- reply to client.
		JGSL.SendToClient(JID, out_msg);
	elseif(msg.type == JGSL_msg.CS_PING) then
		--------------------------------
		-- Client pings: forward client session key and send server session keys. 
		--------------------------------
		-- only be a server if it is not a connected client. comment this out if you want to allow both client and server on the same computer. 
		if(Map3DSystem.JGSL_client.GetServerInfo()==nil) then
			local msg_reply = {
				type = JGSL_msg.SC_PING_REPLY, 
				-- forward the client session key(csk)
				csk = msg.csk,
				-- following is also sent for client side consideration. 
				-- server world path
				worldpath = ParaWorld.GetWorldDirectory(),
				-- number of env object created. 
				envNum = #(JGSL_server.history.env),
				-- number of obj object created. 
				objNum = #(JGSL_server.history.creations),
				-- number of users online. 
				usrNum = #(JGSL_server.agents),
			};
			JGSL.SendToClient(JID, msg_reply);
		end
	elseif(msg.type == JGSL_msg.CS_Login) then
		------------------------------------
		-- a client just request connection
		------------------------------------
		JGSL.Log("用户登陆到本服务器："..tostring(JID))
		JGSL_server.statistics.VisitsSinceStart = JGSL_server.statistics.VisitsSinceStart+1;
		local clientUID = msg.clientUID;
			
		-- randomly generate the spawn position for the incoming user. The spawn position is within a certain radius of the current player. 
		local OnlineUserNum = #(JGSL_server.agents);
		JGSL_server.OnlineUserNum = OnlineUserNum;
		local radius = JGSL_server.miniSpawnRadius + math.sqrt(OnlineUserNum+1)*3;
		local player = ParaScene.GetPlayer();
		local px,py,pz = player:GetPosition();
		local x = (math.random()*2-1)*radius + px;
		local z = (math.random()*2-1)*radius + pz;
		if(x<0) then x=0 end
		if(z<0) then z=0 end
		local y = ParaTerrain.GetElevation(x,z);
		
		-- TODO: authenticate to decide "guest", "administrator", "friend"
		-- TODO: authenticate user, if failed we should inform the client. 
		-- make it friend for testing purposes
		local UserRole = "guest"; 
		
		local msg = {
			-- SC: InitGame: first and basic world information.
			type = JGSL_msg.SC_Login_Reply, 
			worldpath = ParaWorld.GetWorldDirectory(),
			worldname = ParaWorld.GetWorldName(),
			desc = "",
			x=x,
			y=y,
			z=z,
			
			Role = UserRole,
			hostuid = Map3DSystem.User.userid,
			OnlineUserNum = JGSL_server.OnlineUserNum,
			StartTime = JGSL_server.statistics.StartTime,
			VisitsSinceStart = JGSL_server.statistics.VisitsSinceStart,
			ServerVersion = JGSL_server.ServerVersion, 
			ClientVersion = JGSL_server.ClientVersion, 
		};

		JGSL.SendToClient(JID, msg);
		
		-- create a agent for the new user
		local agent = JGSL_server.CreateAgent(JID);
		if(agent~=nil) then 
			agent:update();
			agent.SignedIn = true;
			agent.uid = clientUID;
		end
		
		if(OnlineUserNum == 0)  then
			-- start broadcasting history to clients only when the first client connect to it. 
			JGSL_server.LastEnvHistoryTime = Map3DSystem.Env.GetHistory().env:GetLastTime() or 0
			JGSL_server.LastCreationHistoryTime = Map3DSystem.obj.GetHistory().creations:GetLastTime() or 0
		end	
			
		-- send game event 
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JGSL_USER_COME, userJID=JID, uid=clientUID})
		
		-- set the server timer for each login.
		NPL.SetTimer(JGSL_server.TimerID, JGSL_server.TimerInterval/1000, ";Map3DSystem.JGSL_server.OnTimer()");
	end
end
NPL.this(activate);
