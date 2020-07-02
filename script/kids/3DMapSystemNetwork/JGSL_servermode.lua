--[[
Title: server mode of JGSL grid server
Author(s): LiXizhi
Date: 2008.8.6
Desc: 
call the stay alive function periodically to make sure this instance (system service) is alive.
Map3DSystem.JGSL.servermode.StayAlive()
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_servermode.lua");
Map3DSystem.JGSL.servermode.StayAlive()
Map3DSystem.JGSL.servermode.EnterServerMode()
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");

if(not Map3DSystem.JGSL) then Map3DSystem.JGSL = {};end;

local servermode = {
	jid = Map3DSystem.User.jid,
	ConnectTimer = -100000,
	-- only reconnect every 20 seconds
	ConnectPeriod = 20000, -- 20000 milliseconds
	-- private: the jabber client instance
	jc = nil,
	AliveTimer = 0,
	-- check keep connected every 10 minutes
	AlivePeriod = 600000, -- 600000 milliseconds
	-- once ondisconnected, we will try to Auto reconnect by 2 times before waiting until the next ConnectPeriod
	AutoConnectCount = 2,
	ReconnectCount_ = 0, 
};
Map3DSystem.JGSL.servermode = servermode;

-----------------------------
-- public function
-----------------------------

-- get the currently connected client. return nil, if connection is not valid or not authenticated
function servermode.GetJC()
	local jc = servermode.GetClient();
	if(jc:GetIsAuthenticated()) then
		return jc;
	end
end

-- get the JID of this jabber client.
function servermode.GetJID()
	return servermode.jid;
end

-- Get default jabber client, create if not exist. It will return nil, if jid is not known
-- It does not open a connection immediately.
function servermode.GetClient()
	if(not servermode.jc and servermode.jid) then
		local jc = JabberClientManager.CreateJabberClient(servermode.jid);
		servermode.jc = jc;
		jc:ResetAllEventListeners();
		jc:AddEventListener("JE_OnConnect", "Map3DSystem.JGSL.servermode.JE_OnConnect()");
		jc:AddEventListener("JE_OnAuthenticate", "Map3DSystem.JGSL.servermode.JE_OnAuthenticate()");
		jc:AddEventListener("JE_OnDisconnect", "Map3DSystem.JGSL.servermode.JE_OnDisconnect()");
		jc:AddEventListener("JE_OnAuthError", "Map3DSystem.JGSL.servermode.JE_OnAuthError()");
		jc:AddEventListener("JE_OnError", "Map3DSystem.JGSL.servermode.JE_OnError()");
		jc:AddEventListener("JE_OnMessage", "Map3DSystem.JGSL.servermode.JE_OnMessage()");
		
		commonlib.log("JSM: client created for %s\n", servermode.jid);
	end
	return servermode.jc
end

-- this function should be called periodically to connect to the JGSL
-- internally it just checks with the remote server every 10 mins if disconnected
function servermode.StayAlive()
	-- 600000 milliseconds
	if(servermode.CheckLastTime("AliveTimer", servermode.AlivePeriod, true)) then 
		local jc = servermode.GetClient();
		if(jc and not jc:GetIsAuthenticated()) then
			servermode.EnterServerMode();
		end
	end
end

-- enter to server mode, without graphics, but as a system service. 
function servermode.EnterServerMode()
	-- TODO: ParaEngine.EnablePassiveRendering(true);
	-- TODO: minimize the window here
	
	-- overwrite the JGSL jabber client functions. 
	Map3DSystem.JGSL.GetJC = servermode.GetJC
	Map3DSystem.JGSL.GetJID = servermode.GetJID
	
	local function InitJabberServerMode(msg)
		if(Map3DSystem.User.jid) then
			servermode.jid = Map3DSystem.User.jid;
			commonlib.log("JSM: started on node %s\n", servermode.jid);
		end
		if(servermode.jid) then
			-- init the jabber client instant messanger
			servermode.InitJabber(Map3DSystem.User.Password);
			
			NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_gateway.lua");
			Map3DSystem.JGSL.gateway:Restart();
			NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_grid.lua");
			Map3DSystem.JGSL_grid.Restart();
		end	
	end
	if(not servermode.jid) then
		log("JSM: connecting with REST server\n")
		-- if jid is still unknown, we will ask the rest server. 
		paraworld.auth.AuthUser({username = Map3DSystem.User.Name, password = Map3DSystem.User.Password,}, "jgsl", InitJabberServerMode)
	else
		InitJabberServerMode();
	end
end

-- this function will return true if nMilliSecondsPassed is passed since last timer of timerName is set
-- @param timerName: such as "ConnectTimer"
-- @param nMilliSecondsPassed: such as 20000 milliseconds
-- @param bUpdateIfTrue: whether it will update last connection time if true.
function servermode.CheckLastTime(timerName, nMilliSecondsPassed, bUpdateIfTrue)
	local nTime = ParaGlobal.GetGameTime();
	if((nTime - servermode[timerName]) > nMilliSecondsPassed) then -- 20000 milliseconds
		if(bUpdateIfTrue) then
			servermode[timerName] = nTime;
		end	
		return true;
	end
end

-- initialize the instant messager client
-- @param password: password
function servermode.InitJabber(password)
	local jc = servermode.GetClient();
	if(jc:IsValid()) then
		if(not jc:GetIsAuthenticated()) then
			if(servermode.AllowRetry or  servermode.CheckLastTime("ConnectTimer", servermode.ConnectPeriod, true)) then -- 20000 milliseconds
				servermode.AllowRetry = nil;
				jc.Password = password;
				log("JSM: connecting JS...\n")
				-- open the connection
				if(not jc:Connect()) then
					commonlib.log("warning: cannot make connection for %s\n", servermode.jid)
				end
			else
				log("you can not connect when you have just making a connection attempt a while ago\n");
			end	
		else
			log("already connected to "..servermode.jid.."\n");
		end	
	else
		log("warning: Invalid JC client");	
	end
end

---------------------------------
-- server mode jabber event callback functions
---------------------------------

-- any kinds of error may goes here
function servermode.JE_OnError()
	-- TODO: find a better way to handle error.
	if(msg~=nil and msg.msg ~=nil) then
		commonlib.echo(msg);
	end
end

-- received a message packet
function servermode.JE_OnMessage()
	if(msg and msg.subtype) then
		if( msg.subtype == 8192) then
			-- the client msg.from is possibly offline, since we received an invalid message, here. 
			-- because server is epoll style, we do nothing about it. 
		end
	end
end

-- connection is established, user is still being authenticated.
-- The connection is connected, but no stream:stream has been sent, yet
function servermode.JE_OnConnect()
	log("JSM: connection established\n")
end

-- gracefully disconnected.
-- The connection is disconnected
function servermode.JE_OnDisconnect()
	log("JSM: connection lost\n")
	commonlib.echo(msg);
	ParaEngine.SetWindowText(string.format("%s(offline)", servermode.jid));
	
	
	if (servermode.ReconnectCount_ < servermode.AutoConnectCount) then
		servermode.ReconnectCount_ = servermode.ReconnectCount_ +1;
		commonlib.log("JSM: auto reconnecting on the %d times\n", servermode.ReconnectCount_)
		servermode.AllowRetry = true; -- this will bypass the connectperiod check and reconnect immediately. 
		servermode.EnterServerMode();
	else
		commonlib.log("JSM: we shall wait %d milliseconds before trying again.\n", servermode.ConnectPeriod)
	end
end

-- use Jabber_OnError() instead. this function is not called.
-- Authentication failed. The connection is not terminated if there is an auth error and there is at least one event handler for this event.
function servermode.JE_OnAuthError()
	log("JSM: Jabber_OnAuthError:\n")
	if(msg~=nil) then
		commonlib.echo(msg);
	end
end

-- user is authenticated
-- The connection is complete, and the user is authenticated
function servermode.JE_OnAuthenticate()
	log("JSM: Authenticated\n")
	servermode.ReconnectCount_ = 0;
	ParaEngine.SetWindowText(string.format("%s(online)", servermode.jid));
end