--[[
Title: The jabber client will send the first message to the server, and wait for the server's reply until the next message is sent. If the client does not receive any reply, it will assume that the connection is lost. 
When a jabber client receives a server message, it will extract sub messages for each JGSL_server_agent. And for each agent, it will create such a character if it has not been done before. It will also carry out the action sequence immediately. 
Author(s): LiXizhi
Date: 2007/11/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
Map3DSystem.JGSL_client:Dump()
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_msg_def.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_serverproxy.lua");

if(not Map3DSystem.JGSL_client) then Map3DSystem.JGSL_client = {};end;

local JGSL_server = Map3DSystem.JGSL_server;
local JGSL_client = Map3DSystem.JGSL_client;
local JGSL = Map3DSystem.JGSL;
local JGSL_msg = Map3DSystem.JGSL_msg;

-- private: client state
local clientstate = {
	-- client has been reset
	none = nil,
	-- contacting gateway
	gateway = 1,
	-- sending normal update with grid server
	normalupdate = 2,
	-- disconnected from server, because of time out.
	-- disconnected = 3,
}

local client = {
	-- client session key, it is regenerated each time we are connecting to a user server. 
	sessionkey = ParaGlobal.GenerateUniqueID(),
	-- client version
	ClientVersion = 1,
	-- required server version
	ServerVersion = 1,
	-- player agent. 
	playeragent = nil,
	-- server agents on client, where agents[jid] = {agent}.
	agents = {},
	-- a pool of timed out agents
	timeoutagents = {},
	-- jc instance. if nil, JGSL.GetJC will be used. 
	jc = nil,
	-- the jid of this server.
	jid = nil,
	-- whether this client is emulated. 
	IsEmulated = nil,
	-- LoginServer will be forced to login to this world regardless the current world.
	EmuUser_worldpath = nil,
	-- private: keep a reference to the world path. this is sent automatically and should not be modified by users.
	worldpath = nil,
	-- timer ID
	TimerID = 16,
	-- emulation timer ID
	EmuTimerID = 21,
	-- if a client shall only send a message to the server every 3 seconds and after it receives the last server message. 
	-- if the client does not receive message from server within this time, it will continue to wait until ServerTimeOut
	NormalUpdateInterval = 3000,
	-- if the client does not receive any messages from the server for 10 seconds. It will send the normal update again. 
	-- it is usually twice of NormalUpdateInterval.
	MaxNormalUpdateInterval = 6000,
	-- if the server is not responding in 20 seconds, we will report to user about connecion lost or unsuccessful. 
	ServerTimeOut = 20000,
	-- if an agent is not active for this time, it will be removed from the scene
	AgentTimeOut = 20000,
	-- the gate way server proxy object 
	gatewayProxy = nil, 
	-- the grid node server proxies. mapping from grid node server key to proxy object
	gridnodeProxies = nil,
	-- we will need to connect to all grid node servers within 30 meters, as agent or observers.
	sense_radius = 30,
	state = clientstate.none,
	-- increased by one eact time a normal update is sent
	timeid = 1,
}
JGSL.client = client;

--------------------------
-- public functions
--------------------------

-- create a new instance of this class. 
-- if there is only one instance, just use the default JGSL_client object without calling new() method.
-- @param o: if emulated, use new({IsEmulated=true, jid=jid})
function client:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- force emulation. 
	if(o.jid) then
		if(not o.jc) then
			o.jc = JabberClientManager.CreateJabberClient(o.jid);
		end
	end
	-- create gateway
	o.gatewayProxy = Map3DSystem.JGSL.ServerProxy:new({
			DefaultFile = "script/kids/3DMapSystemNetwork/JGSL_gateway.lua",
			jc = o.jc,
			MaxTimeOutRetry = 0,
		});
	-- create player agent		
	if(o.jid) then	
		o.playeragent = JGSL.agent:new({jid = o.jid});
	end	
	o.agents = {};
	-- this is not reset during self:Reset().
	o.timeoutagents = {}; 
	o.timeid = 1;
	return o;
end
	
-- regenerate session and become a unconnected client. This is usually called by JGSL.Reset() 
function client:Reset()
	self:log(" client is reset")
	-- regenerate session
	self.sessionkey = ParaGlobal.GenerateUniqueID();
	
	self.state = clientstate.none;
	self.agents = {};
	
	if(not self.IsEmulated) then
		-- close timer
		NPL.KillTimer(self.TimerID);
	end	

	-- break connections with gateway server proxy
	if(	self.gatewayProxy) then
		self.gatewayProxy:Reset();
	end
	
	-- break connections with grid server proxies if any. 
	if(self.gridnodeProxies) then
		local _, gridProxy
		for _, gridProxy in pairs(self.gridnodeProxies) do
			gridProxy:Reset();
		end
	end	
	self.gridnodeProxies = {};
	
	self.state = clientstate.none;
end

-- output a log message
function client:log(...)
	commonlib.applog("GSL_client: (%s): ", tostring(self.jid));
	commonlib.log(...)
	log("\n")
end

-- dump the current JGSL status. 
function client:Dump()
	commonlib.log("Dumping JGSL client of (%s): \n", tostring(self.jid));
	commonlib.log("   state: %s\n", tostring(self.state));
	commonlib.log("   sessionkey: %s\n", tostring(self.sessionkey));
	commonlib.log("   gateway: %s\n", tostring(self.gatewayProxy.jid));
	commonlib.log("   agents: \n");
	local agentCount=0;
	local _, agent
	for _, agent in pairs(self.agents) do
		agentCount = agentCount+1;
		log("    -->");agent:Dump();
	end
	commonlib.log("   #agents: %d\n", agentCount);
	
	commonlib.log("   timeoutagents: \n");
	agentCount=0;
	for _, agent in pairs(self.timeoutagents) do
		agentCount = agentCount+1;
		log("    --> ");agent:Dump();
	end
	commonlib.log("   #timeoutagents: %d\n", agentCount);
	
	commonlib.log("   gridnodeProxies: \n");
	local key, proxy
	for key, proxy in pairs(self.gridnodeProxies) do
		log("    --> ");proxy:Dump();
	end
end

-- it will create the agent structure if it does not exist
function client:GetAgent(jid)
	if(not jid) then return end
	local agent = self.agents[jid] or self.timeoutagents[jid];
	if(not agent) then
		agent = JGSL.agent:new{jid = jid};
		self.agents[jid] = agent;
	end
	return agent;
end

-- get the JC instance 
function client:GetJC()
	if(not self.jc) then
		self.jc = JGSL.GetJC();
	end
	return self.jc
end

-- get the jid instance 
function client:GetJID()
	if(self.jid) then
		return self.jid
	else
		self.jid = JGSL.GetJID();
		return self.jid
	end
end

-- jid of the gateway server
function client:GetGatewayServerJID()
	if(self.gatewayProxy) then
		return self.gatewayProxy.jid;
	end	
end

-- send a message to a given jid
-- @param msg: msg to send
-- @param neuronfile: if nil, self.DefaultFile is used. 
function client:Send(jid, msg, neuronfile)
	local jc = self:GetJC()
	if(jc and jid) then
		jc:activate(jid..":"..(neuronfile or "script/kids/3DMapSystemNetwork/JGSL_client.lua"), msg);
	end
end

-- login to a server with a known jid name
-- if we have a previous connection with the same gateway, all grid nodes sessions are reused. and the function returns immediately.
-- @param jid: should be a jid like "lixizhi@paraweb3d.com"
function client:LoginServer(jid)
	if(jid == self:GetJID()) then
		JGSL.Log("你不能加入自己的服务器");
		return nil;
	end
	local worldpath = self.EmuUser_worldpath or ParaWorld.GetWorldDirectory()
	-- keep the world path. 
	self.worldpath = worldpath;
	
	-- if a different gateway is found, logout the current gateway. 
	if(self.gatewayProxy.jid~=jid) then
		self:LogoutServer();
	elseif(self.state ~= clientstate.none) then	
		-- if we are already connected to the gateway server, return immediately. 
		if(self.gatewayProxy.worldpath~=worldpath) then
			self.gatewayProxy.worldpath = worldpath
			-- TODO: shall we also log out previous grid node server? 
		end	
		-- if we have a previous connection with the same gateway, all grid nodes sessions are reused. and the function returns immediately.
		return;
	end
	
	-- reset client since we are connecting again. 
	self:Reset();
	
	-- inform user we are connecting to server
	--JGSL.Log("正在连接 JGSL server "..jid);
	self:log("connecting to JGSL gateway %s\n", jid);
	
	-- set to the new server
	self.gatewayProxy.jid = jid;
	self.gatewayProxy.worldpath = worldpath;
	
	-- send a login message to server
	self:PingGateway()
	
	if(not self.IsEmulated) then
		-- set the timer to send client normal update to server
		NPL.SetTimer(self.TimerID, self.NormalUpdateInterval/1000, ";Map3DSystem.JGSL_client:OnTimer()");
	else
		NPL.SetTimer(self.EmuTimerID, self.NormalUpdateInterval/1000, ";Map3DSystem.JGSL.client:OnTimerEmu()");
	end	
end

-- logout the current connected gateway and grid servers
-- @param bSilent: if true, we shall inform the UI. 
function client:LogoutServer(bSilent)
	local jid;
	if(self.gatewayProxy) then
		jid = self.gatewayProxy.jid;
	end
	self:Reset();
	if(not bSilent) then
		-- send game event 
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JGSL_SIGNEDOUT, serverJID=jid})
	end	
end

-- sent ping to gateway server to establish connection with it
function client:PingGateway()
	-- send a login message to server
	self.gatewayProxy:Send({
		type = JGSL_msg.CS_PING,
		-- csk is client session key
		csk = self.sessionkey,
	})
	self.state = clientstate.gateway;
end

-- get gateway round trip time for debugging purposes. 
function client:QueryGateway()
	-- send a login message to server
	self.gatewayProxy:Send({
		type = JGSL_msg.CS_QUERY,
		-- csk is client session key
		csk = self.sessionkey,
		fields = {"systime"},
		forward = tostring(ParaGlobal.timeGetTime()),
	})
end

-- get a ready only copy of currently connected server info table. 
-- it will return nil if not connected yet. 
function client:GetServerInfo()
	if(self.gatewayProxy.SignedIn) then
		return self.gatewayProxy;
	end
end

--------------------------
-- private functions:
--------------------------

-- get the agent representing the current player. 
function client:GetPlayerAgent()
	if(not self.playeragent) then
		self.playeragent = JGSL.agent:new({jid = self:GetJID(),});
	end
	return self.playeragent;
end

-- a timer that periodically send messages for emulated users
function client:OnTimerEmu()
	if(not Map3DSystem.EmuUsers) then
		return
	end
	Map3DSystem.EmuUsers.EachUser(function(user)
		if (user.client) then
			user.client:OnTimer()
		end
	end)
end

-- a timer that periodically send messages 
function client:OnTimer()
	local curTime = ParaGlobal.GetGameTime();

	if(self.state == clientstate.normalupdate) then
		-- send normal update to server
		self:SendNormalUpdate();
		
	elseif(self.state == clientstate.gateway) then
		if(self.gatewayProxy:CheckState(curTime)) then
			-- resend a login message to server
			self:PingGateway();
			
		elseif(self.gatewayProxy:IsDead())then	
			self.state = clientstate.none;
			if(not self.IsEmulated) then
				_guihelper.MessageBox("服务器链接超时, 是否重新连接?", function(res)
					if(res==nil or res == _guihelper.DialogResult.Yes) then
						self:PingGateway();
					end	
				end, _guihelper.MessageBoxButtons.YesNo)
			else
				-- self:log("emu ping gateway")
				self:PingGateway();
			end
		end
	else
		return
	end
	
	--
	-- check for any agent time out
	--
	local _, agent;
	local count = 0;
	local TimedOutAgents;
	for _, agent in pairs(self.agents) do
		if(agent:CheckTimeOut(curTime, self.AgentTimeOut)) then
			-- if the agent is timed out, remove character and make inactive 
			-- commonlib.log(string.format("JC(%s) user %s left us\n", agent.jid, tostring(self.jid)));
			if(agent:cleanup()) then
				-- send game event 
				Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JGSL_USER_LEAVE, userJID=agent.jid})
				
				-- Mark the agent jid to be deleted after the iteration
				TimedOutAgents = TimedOutAgents or {};
				TimedOutAgents[agent.jid] = true;
			end	
		else	
			count = count +1;
		end
	end
	
	-- Note: currently, client agents are only moved from agents pool or loggedout agent pool,
	--  so they are never deleted from memory, even self:Reset() is called.
	if(TimedOutAgents~=nil) then
		local key, _;
		for key, _ in pairs(TimedOutAgents) do
			self.timeoutagents[key] = self.agents[key];
			self.agents[key] = nil;
		end
	end
end

-- when some remote user creations are received by this computer, it will be applied in this world, however, without writing into the history. 
function client:ApplyCreations(creations)
	if(creations==nil) then return end
	
	for i = 1, table.getn(creations) do
		-- create without writing to history
		local new_msg = {
			SkipHistory = true,
		}
		commonlib.partialcopy(new_msg, creations[i]);
		Map3DSystem.SendMessage_obj(new_msg);
	end
end

-- when some remote user env updates are received by this computer, it will be applied in this world, however, without writing into the history. 
function client:ApplyEnvs(env)
	if(env==nil) then return end
	
	for i = 1, table.getn(env) do
		-- create without writing to history
		local new_msg = {
			SkipHistory = true,
		}
		commonlib.partialcopy(new_msg, env[i]);
		Map3DSystem.SendMessage_env(new_msg);
	end
end

-- verify the session key in the message is the same as the gateway's session key
function client:Verifysessionkey(msg)
	-- check if session key is valid, except for the SC_PING_REPLY message. 
	if(msg.sk ~= self.gatewayProxy.sk and msg.type ~=JGSL_msg.SC_PING_REPLY) then
		self:log(" ignored a packet with invalid session key %s from %s\n", tostring(msg.sk), msg.from)
		return;
	end
	return true;
end

-- get available best server grid proxy for a given world path. 
-- a best grid proxy is a proxy that is smallest in size. 
-- @param worldpath: the world that the grid node is in. 
-- @param x, y, z: a position that the grid node contains. 
-- @param IsObserver: true if we are just getting for an observer node. 
function client:FindBestGridProxy(worldpath, x, y, z)
	local candidate = nil;
	local key, proxy
	for key, proxy in pairs(self.gridnodeProxies) do
		if(proxy:Contains(worldpath, x, y, z)) then
			if(not candidate or not candidate.size or (proxy.size and proxy.size<candidate.size)) then
				candidate = proxy
			end
		end	
	end
	return candidate;
end

-- remove grid proxy
function client:RemoveGridProxy(proxy)
	if(proxy.sk) then
		self.gridnodeProxies[proxy.sk] = nil;
	end	
end

-- Create a connected grid node server proxy, each grid node is responsible for simulating a specific region in the world.
-- @param msg: the reply NPL message from SC_Login_Reply. It should contain grid node session key and info {gk, gjid, gx,gy,gsize, worldpath}
-- @return: return the proxy object if succeeded
function client:CreateGridNodeProxy(msg)
	local proxy = Map3DSystem.JGSL.ServerProxy:new({DefaultFile="script/kids/3DMapSystemNetwork/JGSL_grid.lua",
		sk = msg.gk,
		id = msg.gid,
		jid = msg.gjid,
		jc = self:GetJC(),
		UserRole = msg.Role,
		worldpath = msg.worldpath,
		x = msg.gx, y=msg.gy, size=msg.gsize,
	});
	
	-- remove identical one
	if(self.gridnodeProxies) then
		local key, gridProxy
		for key, gridProxy in pairs(self.gridnodeProxies) do
			if(gridProxy:IsEqual(proxy)) then
				self.gridnodeProxies[key] = nil;
				break;
			end
		end
	end
	
	-- insert only if session key exists. 
	if(proxy.sk) then
		proxy:UpdateSessionKey(proxy.sk);
		-- send grid node id and session key in the cookie
		proxy.cookies = {sk = proxy.sk, id = proxy.id};
		self.gridnodeProxies[proxy.sk] = proxy;
		proxy:MakeReady();
		self:log(" new gridnode found: %s(%s) %s at %s(%s, %s)\n", tostring(proxy.jid), tostring(proxy.id), tostring(proxy.sk), tostring(proxy.worldpath), tostring(proxy.x), tostring(proxy.y));
		
		if(not self.IsEmulated) then
			self:Dump(); -- let us examine the state for this release. 
		end
		return proxy;
	end
end

-- send a normal update packet to the grid node containing the request location. 
-- if no grid node connection is available for the region, we will ask the gateway for it. 
function client:SendNormalUpdate()
	-- increase client time id. 
	self.timeid = self.timeid + 1;
	
	local agent = self:GetPlayerAgent();
	
	if(not self.IsEmulated or not (agent.x and agent.y and agent.z) ) then
		agent.x,agent.y,agent.z = ParaScene.GetPlayer():GetPosition();
	end
						
	-- check 5 points near the center of the player. Pos (7,9,5,1,3) on the numeric pad, where 5 is the player position. 
	local nIndex, rx, ry;
	local excludeList = {};
	
	local nToIndex = 4;
	if(self.IsEmulated) then
		nToIndex = 0;
	end
	local curTime = ParaGlobal.GetGameTime();
	for nIndex = 0,nToIndex do
		if(nIndex == 0) then
			rx, ry = 0,0;
		elseif(nIndex == 1) then
			rx, ry = self.sense_radius,self.sense_radius;
		elseif(nIndex == 2) then
			rx, ry = self.sense_radius,-self.sense_radius;
		elseif(nIndex == 3) then
			rx, ry = -self.sense_radius,-self.sense_radius;
		elseif(nIndex == 4) then
			rx, ry = -self.sense_radius,self.sense_radius;		
		end
		local x,y,z = agent.x+rx, agent.y, agent.z+ry
		
		local proxy = self:FindBestGridProxy(self.gatewayProxy.worldpath, x, y, z)
		if(proxy) then
			if(not excludeList[proxy.sk]) then
				excludeList[proxy.sk] = true;
				-- send agent or observer normal update to this grid node proxy server
				if(proxy:CheckState(curTime)) then
					
					if(nIndex == 0) then
						-- request agent normal update
						
						-- this will let us send relative position. 
						agent.gx, agent.gz= proxy.from_x, proxy.from_y;
						
						-- NOTE: only update from real character when we are not emulating the client
						if(not self.IsEmulated) then
							agent:UpdateFromPlayer(ParaScene.GetPlayer(), self.timeid);
						else
							if(not (agent.x and agent.y and agent.z and agent.AssetFile) ) then
								agent:UpdateFromPlayer(ParaScene.GetPlayer(), self.timeid);
							else	
								agent:UpdateFromSelf(self.timeid);
							end	
						end	
						
						-- TODO: we need to find a way to send relative position. 
						local agentStream = {data = agent:GenerateUpdateStream(proxy.ct) }
						--commonlib.log("%s(%s): sending normal update:----------->\n", self.jid, proxy:GetJC().User);
						-- print(agentStream.data)
						
						--if(self.IsEmulated) then
							--commonlib.log("emu sent %s last time %s\n", tostring(curTime), tostring(proxy.LastSendTime))
						--end
						
						-- if proxy:CanEdit() then send creations related stuffs to server
						if (proxy:CanEdit() and (not self.IsEmulated) ) then
							agent:GenerateCreationStream(agentStream);
						end
						
						proxy:Send({
							type = JGSL_msg.CS_NormalUpdate,
							-- client agent stream
							agent = agentStream,
							-- forward server time
							st = proxy.st,
							-- send client time
							ct = self.timeid,
							-- recover list if any
							recover = proxy.recoverlist,
							-- whether this is a dummy agent that will not receive other agents' updates. 
							dummy = agent.dummy,
						});
						proxy.recoverlist = nil;
					else
						-- request observer agent update
						proxy:Send({
							type = JGSL_msg.CS_ObserverUpdate,
							-- observing agent position, NOTE: they are not sent in this release
							-- x=x, y=y,z=z,
							-- forward server time
							st = proxy.st,
							-- send client time
							-- ct = self.timeid,
							-- recover list if any
							recover = proxy.recoverlist,
						});
						proxy.recoverlist = nil;
					end	
				elseif(proxy:IsDead()) then
					self:log("Dead--state %s, last sent time %s, curtime %s", tostring(proxy.state), tostring(proxy.LastSendTime), tostring(curTime));	
					proxy:Reset();
					self:RemoveGridProxy(proxy);
				end		
			end	
			--self:log("state %s, last sent time %s, curtime %s", tostring(proxy.state), tostring(proxy.LastSendTime), tostring(curTime));	
		else
			-- we do not have a proxy connection in the region, ask the gateway about it. 
			if(self.gatewayProxy:CheckState(curTime)) then
				self.gatewayProxy:Send({
					type = JGSL_msg.CS_Login,
					worldpath = self.gatewayProxy.worldpath,
					x = x,
					y = y,
					z = z,
				})
			elseif(self.gatewayProxy:IsDead()) then
				self.gatewayProxy:Reset();
				self:Reset();
				if(not self.IsEmulated) then
					self:log("warning: connection to gateway server (%s) is down. \n", tostring(self.gatewayProxy.jid))
					_guihelper.MessageBox("与服务器的链接断开了, 是否重新连接?", function(res)
						if(res==nil or res == _guihelper.DialogResult.Yes) then
							if(self.gatewayProxy.jid) then
								self:LoginServer(self.gatewayProxy.jid)
							end
						end	
					end, _guihelper.MessageBoxButtons.YesNo)
				else
					--self:log("emu reconnect")
					if(self.gatewayProxy.jid) then
						self:LoginServer(self.gatewayProxy.jid)
					end
				end	
			end	
		end
	end
	-- send CS_Logout packets to not touched proxies in the last frame. 
	if(self.activeProxies) then
		local key, _;
		for key, _ in pairs(self.activeProxies) do
			if(not excludeList[key]) then
				local proxy = self.gridnodeProxies[key];
				if(proxy) then
					self:log(" logging out grid node: (%s, %s)", tostring(proxy.jid), tostring(proxy.id))
					-- logout proxy, but do not delete it since we may reuse it again. 
					proxy:Logout();
				end	
			end
		end
	end
	self.activeProxies = excludeList;
end

-- handle server messages
function client:HandleMessage(msg)
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local jid = string.gsub(msg.from, "/.*$", "");
	
	if(msg.type==JGSL_msg.SC_NormalUpdate) then
		--------------------------------
		-- grid node server send us agent update info 
		--------------------------------
		--commonlib.log("JC(%s)-----------client received SC_NormalUpdate\n", msg.jckey)
		--commonlib.echo(msg);
		local proxy;
		if (msg.sk) then
			proxy = self.gridnodeProxies[msg.sk];
		end	
		if(proxy) then
			proxy:OnRespond();
			proxy.ct = msg.ct;
			proxy.st = msg.st;
		else
			return
		end
		-- only update when client is not emulated. 
		if(not self.IsEmulated) then
			-- update all agents
			local opcode_jid = Map3DSystem.JGSL.opcode.opcode_jid;
			local jid, agent;
			for jid, agent in pairs(msg.agents) do
				local local_agent = self:GetAgent(opcode_jid:read(jid));
				if(local_agent~=nil) then
					-- set relative position origin before updating. 
					local_agent.gx, local_agent.gz = proxy.from_x, proxy.from_y;
					local_agent:UpdateFromStream(agent, msg.st);
					--commonlib.echo({"-------------\n", local_agent.x, local_agent.z})
					
					-- Note: only update if this proxy represent a region in the current world
					if(self.worldpath == proxy.worldpath) then
						local_agent:update();
					end	
					
					-- just provide the heart beat to local agent, so that they are not timed out. 
					local_agent:tick(nil, true);
					
					if(not local_agent:IsIntact()) then
						if(proxy:AddToRecoverList(local_agent)) then
							commonlib.log("warning: recovering intact agent %s\n", tostring(local_agent.jid))
						end
					end
				end	
			end
			if(msg.ping) then
				-- read ping CSV string to prevent agent time out on client. 
				for jid in string.gmatch(msg.ping, "[^,]+") do
					local local_agent = self:GetAgent(opcode_jid:read(jid));
					if(local_agent~=nil) then
						-- just provide the heart beat to local agent, so that they are not timed out. 
						local bNeedUpdate = local_agent:tick(nil, true);
						if(self.worldpath == proxy.worldpath) then
							if(not local_agent:IsIntact()) then
								if(proxy:AddToRecoverList(local_agent)) then
									commonlib.log("warning: recovering intact agent %s\n", tostring(local_agent.jid))
								end
							elseif(bNeedUpdate) then
								commonlib.log("ping revived %s\n", local_agent.jid)
								local_agent:update();
							end
						end	
					end	
				end
			end
			-- update all server creations in the message
			self:ApplyCreations(msg.creations);
			-- update all environment update  in the messages
			self:ApplyEnvs(msg.env);
		end	
		
	elseif(msg.type == JGSL_msg.SC_PING_REPLY) then
		--------------------------------
		-- gateway server replying from pinging 
		--------------------------------
		self.gatewayProxy:OnRespond();
		if(msg.sk == nil) then
			commonlib.log("warning: gateway %s does not return session key in SC_PING_REPLY\n", msg.from);
			return
		end
		self.gatewayProxy:UpdateSessionKey(msg.sk, true);
		
		commonlib.log("JC(%s): gateway connection established: (%s, %s)\n", msg.jckey, msg.from, tostring(msg.sk));

		if(msg.csk ~= self.sessionkey) then
			-- if server does not forward the client session key that we sent during pinging, report invalid session key
			-- JGSL.Log(string.format("忽略了从JGSL服务器:%s 收到的不兼容链接\n", msg.from))
			self:log("ignored invalid session key %s from grid node %s, the right key is %s\n", tostring(msg.csk), msg.from, tostring(self.sessionkey))
		else
			self.state = clientstate.normalupdate;
			-- we have connected with gateway, so send the first agent normal update packet to server
			self:SendNormalUpdate();
		end	
	elseif(msg.type == JGSL_msg.SC_Login_Reply) then	
		--------------------------------------
		-- gateway server replied with a best grid server
		--------------------------------------
		self.gatewayProxy:OnRespond();
		
		if(not msg.gk or msg.refused) then
			-- server rejected this client
			JGSL.Log(string.format("%s 的JGSL服务器拒绝了您的登陆请求", msg.from));
			self:log("grid node server %s reused us", msg.from);
			
			-- log out to prevent requesting server again like crazy.
			self:LogoutServer();
		else
			-- new grid node server accepted this client
			-- JGSL.Log(string.format("您成功登陆了 %s 的Grid Node服务器", msg.from));
			
			-- check client and server version. 
			if(not msg.ClientVersion or not msg.ServerVersion or msg.ClientVersion >self.ClientVersion or msg.ServerVersion <self.ServerVersion) then
				-- client and server version does not match.
				JGSL.Log("对不起，您的客户端的版本同游戏服务器的版本不兼容，请更新您的客户端");
				self:log("JC version with server not compatible. \nserver:(s:%s; c:%s);client:(s:%s; c:%s)\n", 
					tostring(msg.ClientVersion), tostring(msg.ServerVersion), tostring(self.ClientVersion), tostring(self.ServerVersion));
				-- log out to prevent requesting server again like crazy.
				self:LogoutServer();
				return;
			end
			self:CreateGridNodeProxy(msg)
		end
	elseif(msg.type==JGSL_msg.SC_QUERY_REPLY) then	
		-- just send result to log for debugging purposes. 
		self:log("SC_QUERY_REPLY at time %d", ParaGlobal.timeGetTime());
		commonlib.echo(msg);
	end	
end

-- it just displays whatever messages it receive. 
local function activate()
	if(JGSL.dump_client_msg) then
		commonlib.applog("GSL_client received");
		commonlib.echo(msg);
	end
	
	if(msg.jckey == JGSL_client:GetJID()) then
		JGSL_client:HandleMessage(msg)
	else
		-- for emulated users. 
		if(Map3DSystem.EmuUsers) then
			local user = Map3DSystem.EmuUsers.GetUserByJID(msg.jckey);
			if(user and user.client) then
				user.client:HandleMessage(msg)
			end
		end	
	end	
end
NPL.this(activate);
-- the singleton instance of JGSL default client.
JGSL_client = client:new(JGSL_client);