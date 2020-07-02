--[[
Title: GSL MultiUserChat(muc) client
Author(s): LiXizhi
Company: ParaEnging Co. & Taomee Inc.
Date: 2010/1/12
Desc: muc_handler is a handler class for GSL_client. One can create one or more, ususally there is only one. 
GSL_muc_client is a singleton instance of muc_handler.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/GSL_muc_client.lua");

-- join an MUC room, currently any one can join 
MyCompany.Aries.Chat.GSL_muc_client:JoinRoom(room_id);

-- send a message to the MUC room. 
MyCompany.Aries.Chat.GSL_muc_client:SendMucMessage("this is some text")

-- note: messages will be received via the BBS chat interface. 
-- note: OnAgentJoin and OnAgentLeave will be called for user presence. 

-- this will grab all users in the group. 
commonlib.echo(MyCompany.Aries.Chat.GSL_muc_client:GetAllUsers())
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL.lua");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
-- create class
local GSL_muc_client = commonlib.gettable("MyCompany.Aries.Chat.GSL_muc_client");

-- muc handler
local muc_handler = commonlib.inherit(nil, 
{
	-- function(curTime, isNormalUpdate)  end, a timer that periodically send messages to server
	OnTimer = nil, 
	-- function(msg, curTime) end, handle server message. 
	-- If return true, the message will not be passed down to other handlers. 
	HandleMessage = nil,
	-- function(msg)  end, process real time messages added to the GSL client. 
	-- If return true, the message will not be passed down to other handlers. 
	AddRealtimeMessage = nil,
	-- function(sid, msg) end,send realtime message to a server object. 
	-- If return true, the message will not be passed down to other handlers. 
	SendRealtimeMessage = nil,
	-- function(client)  end, callback to be called when client registered this handler. 
	OnRegisterHandler = nil,
	-- function(client)  end, callback to be called when client registered this handler. 
	Reset = nil,
	
	-- private: the GSL_client that owns this handler.
	client = nil,
	-- handler name
	name = "muc_client",
	-- cid is unique identifier to be shared between grid node and client, so that the client can identify its reply
	cid = 1,
	-- if an agent is not active for this time, it will be removed from the scene
	AgentTimeOut = 10000,
});

function muc_handler:ctor()
	self.agents = {};
	self.timeid = 0;
	self.agentcount = 0;
end

-- output log message 
function muc_handler:log(...)
	commonlib.log("muc log(%s): %s\n", self.name, tostring(self.room_id));
	commonlib.log(...)
	log("\n")
end

-----------------------------
-- public functions
-----------------------------

-- automatically register this handler with the current GSL client, if never registered before. 
-- safe to call this function as many times as one like.  
function muc_handler:AutoRegister()
	if(not self.IsRegistered) then
		self:log("register handler")
		Map3DSystem.GSL_client:RegisterHandler("muc_client",  self);
	end	
end

-- join a given room and leave previous one. 
-- @param room_id: number of family id. 
function muc_handler:JoinRoom(room_id)
	-- register handler if not
	self:AutoRegister();
	
	if(not room_id or not self.client) then
		commonlib.applog("Join room ignored.")
		return 
	end
	if(self.room_id == room_id and self.proxy) then
		return
	end
	
	if( self.proxy ) then
		self:log(" logging out muc room: (%s, %s)", tostring(proxy.nid), tostring(proxy:GetKey()))
		self.proxy:Logout();
		self.proxy = nil;
	end
	
	self.room_id = room_id;
	
	self.nid = self.nid or self.client.nid;
	self.worldpath = string.format("worlds/muc/default/?nid=%s", tostring(self.room_id));
	
	-- ask the gateway 
	if(self.client.gatewayProxy) then
		self.client.gatewayProxy:Send({
			type = GSL_msg.CS_Login,
			worldpath = self.worldpath,
			handler = self.name, -- handler name, so that we can intercept the returned message
			x = 0,y = 0,z = 0,
			-- identify this client
			cid = self.cid, 
		})
	else
		self:log("warning: GSL gateway can not be found.")
	end	
end	

-- send muc message to the room. 
-- @param text: the string to send, it will be received via the BBS chat interface. 
function muc_handler:SendMucMessage(text)
	if(self.client and text) then
		self.client:AddRealtimeMessage({
			type = "muc_chat";
			name = "chat",
			value = text,
		});
	end
end

-- get all users. 
function muc_handler:GetAllUsers()
	return self.agents;
end

NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");

-- a new agent has joined the room. 
function muc_handler:OnAgentJoin(agent)
	commonlib.echo("agent join "..agent.nid)
	MyCompany.Aries.Chat.FamilyChatWnd.MemberJoinChatRoom(tonumber(agent.nid));
end

-- a new agent has joined the room. 
function muc_handler:OnAgentLeave(agent)
	commonlib.echo("agent leave "..agent.nid)
	MyCompany.Aries.Chat.FamilyChatWnd.MemberLeaveChatRoom(tonumber(agent.nid));
end

-- received muc message
function muc_handler:OnRevMucMessage(nid, text)
	commonlib.log("muc chat: %s says %s\n", tostring(nid), tostring(text));
	
	MyCompany.Aries.Chat.FamilyChatWnd.RecvMSG(nid, text);
end
	
-------------------------------	
-- following are GSL handler interface functions
-------------------------------

-- keep a reference to the client object. 
function muc_handler:OnRegisterHandler(client)
	self.IsRegistered = true;
	self.client = client;
	-- create an agent for current player.
	self.playeragent = GSL.agent:new({nid = client.nid,});
end

-- get the agent representing the current player. 
function muc_handler:GetPlayerAgent()
	return self.playeragent;
end
-- it will create the agent structure if it does not exist
-- it will revive and reuse the self.timeoutagents if it exist. 
function muc_handler:GetAgent(nid)
	if(not nid) then return end
	local agent = self.agents[nid];
	if(not agent) then
		-- create a new one. 
		agent = GSL.agent:new{nid = nid};
		self.agents[nid] = agent;
		
		self.agentcount = self.agentcount + 1;
		self:OnAgentJoin(agent);
	end	
	return agent;
end

-- a timer that periodically send messages to server
-- @param curTime: current time
-- @param isNormalUpdate: if true, it is normal update. otherwise it is real time update. 
function muc_handler:OnTimer(curTime, isNormalUpdate)
	if(not self.proxy) then
		return;
	end
	local proxy = self.proxy;
	
	if(isNormalUpdate) then
		-- send a ping message to the server. 
		
		-- increase client time id. 
		self.timeid = self.timeid + 1;
	
		proxy:Send({
			type = GSL_msg.CS_NormalUpdate,
			-- client agent stream
			agent = nil,
			-- forward server time
			st = proxy.st,
			-- so that we are not interested in agents states, only ping is returned then. 
			dummy = true,
		});
		
		--
		-- check for any agent time out
		--
		local _, agent;
		local count = 0;
		local TimedOutAgents;
		for _, agent in pairs(self.agents) do
			if(agent:CheckTimeOut(curTime, self.AgentTimeOut)) then
				-- if the agent is timed out, remove character and make inactive 
				-- Mark the agent nid to be deleted after the iteration
				TimedOutAgents = TimedOutAgents or {};
				TimedOutAgents[agent.nid] = agent;
			else	
				count = count +1;
			end
		end
		if(TimedOutAgents~=nil) then
			local key, agent;
			for key, agent in pairs(TimedOutAgents) do
				self.agentcount = self.agentcount - 1;
				self.agents[key] = nil;
				self:OnAgentLeave(agent);
			end
		end
	else
		-- send queued real time messages to the server. 
		local agent = self:GetPlayerAgent();
		
		local agentStream = {}
		if(not agent or not agent:GenerateRealtimeStream(agentStream)) then
			return
		end
	
		-- real time udpate
		proxy:Send({
				type = GSL_msg.CS_RealtimeUpdate,
				-- client agent stream
				agent = agentStream,
				-- forward server time
				st = proxy.st,
				-- send client time
				ct = self.timeid,
			}, nil, true);
	end
end

-- handle server message. 
-- @return true, the message will not be passed down to other handlers. 
function muc_handler:HandleMessage(msg, curTime)
	if(msg.cid ~= self.cid) then
		return
	end
	-- log("muc_handler ----------------------->:"); commonlib.echo(msg)
	
	if(msg.type == GSL_msg.SC_Login_Reply) then	
		self.client.gatewayProxy:OnRespond();
		
		if(msg.refused) then
			-- server rejected this client
			self:log("grid node server %s refused us", msg.from);
		else
			-- new grid node server accepted this client
			
			local proxy = Map3DSystem.GSL.ServerProxy:new({DefaultFile="script/apps/GameServer/GSL_grid.lua",
				id = msg.gid,
				UserRole = msg.Role,
				x = msg.gx, y=msg.gy, size=msg.gsize,
				proxy = msg.proxy,
			});
			proxy:Init(self.client.gatewayProxy.nid, self.client.gatewayProxy.ws_id, msg.worldpath);
			proxy:MakeReady();
			
			self.proxy = proxy;
			self:log(" new muc gridnode found: %s(%s) at %s\n", tostring(proxy.npl_addr_prefix), tostring(proxy:GetKey()), tostring(proxy.worldpath));
		end
	elseif(self.proxy) then
		-- we have received a message from muc proxy
		local proxy = self.proxy;
			
		if(msg.type==GSL_msg.SC_RealtimeUpdate) then
			-- handle real time messages
			proxy:OnRespond();
			
			if (msg.agents) then
				-- update all agents
				local nid, stream;
				for nid, stream in pairs(msg.agents) do
					local local_agent = self:GetAgent(nid);
					if(local_agent~=nil) then
						-- just provide the heart beat to local agent, so that they are not timed out. 
						local_agent:tick(curTime);
						local_agent:OnNetReceive(stream, function(nid, opcode, value)
							self:OnRevMucMessage(nid, value);
						end);
					end	
				end
			end
			
		elseif(msg.type==GSL_msg.SC_NormalUpdate) then
			-- handle slow real time ping messages
			--log("11111111111111111111111\n")
			--commonlib.echo(msg.ping)
			proxy:OnRespond();
			if(msg.ping) then
				-- read ping CSV string to prevent agent time out on client. 
				for nid in string.gmatch(msg.ping, "[^,]+") do
					local local_agent = self:GetAgent(nid);
					if(local_agent) then
						-- just provide the heart beat to local agent, so that they are not timed out. 
						local_agent:tick(curTime);
					end	
				end
			end
		end
	end
	return true;
end

-- add a real time message to server on behalf of the current avatar.
-- @return true, the message will not be passed down to other handlers. 
function muc_handler:AddRealtimeMessage(msg)
	if(msg.type == "muc_chat") then
		local agent = self:GetPlayerAgent();
		if(agent) then
			agent:AddToRealtimeQueue(msg);
		end	
		return true;
	end
end

-- send realtime message to a server object
-- @param sid: server object id. 
-- @param msg: the message to send. 
-- @return true, the message will not be passed down to other handlers. 
function muc_handler:SendRealtimeMessage(sid, msg)
end

-- this function is called when client is reset or this handler is removed 
function muc_handler:Reset()
	if( self.proxy ) then
		self:log(" logging out muc room: (%s, %s)", tostring(self.proxy.nid), tostring(self.proxy:GetKey()))
		self.proxy:Logout();
		self.proxy = nil;
	end
end

-- the instance of GSL default client.
GSL_muc_client = muc_handler:new(GSL_muc_client)