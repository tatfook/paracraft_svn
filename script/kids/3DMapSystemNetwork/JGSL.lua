--[[
Title: Jabber GSL server and client.
Author(s): LiXizhi
Date: 2007/11/6, doc replenished 2008.6.22 by LiXizhi
use the lib:
JGSL is a special server type in ParaWorld. A PC can be both a client and a server at the same time. 
However, usually it is just either of them. The implementation of client and server are in jgsl_client and jgsl_server file.
This is a entry file that contains public functions to the JGSL module. 

---+++ Reset server sessions. 
when client and server connect, they ping each other and exchange their session keys. By regenerating session keys, we 
will reject any previous established JGSL game connections. Usually we need to regenerate session when we load a different world.
In other word, if either client or server receives a packet from someone with an unknown session key, it will simply ignore it. 
In most cases, this could be an offline message. 
<verbatim>
	-- note: we will logout currently connected server if any. 
	Map3DSystem.JGSL.Reset()
</verbatim>

---+++ Login/Logout to a JGSL server
Login/Logout is done by just two simple calls. 
<verbatim>
	-- It will logged out from previous server and then logged in to the new one. 
	Map3DSystem.JGSL_client.LoginServer(JID, callbackFunc)
	-- log out either by sending the logout message to server or not. 
	Map3DSystem.JGSL_client.LogoutServer(bSilent)
</verbatim>

---+++ Getting Server Status
a client can get server status table by calling 
<verbatim>
	-- serverInfo is nil if not connected to any server now. 
	-- more information, see Map3DSystem.JGSL_client.server
	local serverInfo = Map3DSystem.JGSL_client.GetServerInfo();
	
	-- get the jabber id of this computer. 
	local sJID = Map3DSystem.JGSL.GetJID()
</verbatim>

---+++ JGSL Events
one can hook to following messages to get informed about server or client status, such as whether the last login is successful, etc. 
<verbatim>
	-- called whenever this computer successfully signed in to a remote server. Input contains server JID
	-- msg = {serverJID=JID}
	GAME_JGSL_SIGNEDIN = AutoEnum(),
	-- called whenever this computer signed out of a remote server or just can not connect to the server due to time out. . Input contains server JID.
	-- msg = {serverJID=JID}
	GAME_JGSL_SIGNEDOUT = AutoEnum(),
	-- called whenever connection to a remote server computer timed out. 
	-- it may due to server unavailable or server just shut down. If the server is connected previously, GAME_JGSL_SIGNEDOUT will entails. 
	GAME_JGSL_CONNECTION_TIMEOUT = AutoEnum(),
	-- called whenever some user come in to this world.
	-- msg = {userJID=JID}
	GAME_JGSL_USER_COME = AutoEnum(),
	-- called whenever some user leaves this world. 
	-- msg = {userJID=JID}
	GAME_JGSL_USER_LEAVE = AutoEnum(),
	-- a game client or server status message. 
	-- msg = {text=string}
	GAME_LOG = AutoEnum(),
</verbatim>	
	
---+++ client logic
The jabber client will send the first message to the server, and wait for the server's reply until 
the next message is sent. If the client does not receive any reply, it will assume that the connection is lost. 
When a jabber client receives a server message, it will extract sub messages for each JGSL_server_agent. 
And for each agent, it will create such a character if it has not been done before. It will also carry out the action sequence immediately. 

Both client and server utilizes the creation and env message history. And they will try to broadcast every history from the moment the server or client is started. 
however, we can change this behavior to broadcast history from the time the world is loaded. see variable below. 
<verbatim>
	Map3DSystem.JGSL_client.LastCreationHistoryTime
	Map3DSystem.JGSL_client.LastEnvHistoryTime
</verbatim>

---+++ server logic
When a jabber server receives a message from the client, it will accept it or reject it. 
If accepted, it will reply so and create a JGSL_client_agent character on the server computer if it has never 
been created before. This JGSL_client_agent will be responsible to keep track of an active client on the server. 

enable Map3DSystem.JGSL.dump_[server|client]_msg for debugging. 
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
------------------------------------------------------------
]]
if(not Map3DSystem.JGSL) then Map3DSystem.JGSL = {};end;
if(not Map3DSystem.JGSL_server) then Map3DSystem.JGSL_server={}; end
if(not Map3DSystem.JGSL_client) then Map3DSystem.JGSL_client={}; end
if(not Map3DSystem.JGSL.query) then Map3DSystem.JGSL.query={}; end
if(not Map3DSystem.JGSL_msg) then Map3DSystem.JGSL_msg={}; end
if(not Map3DSystem.JGSL.gateway) then Map3DSystem.JGSL.gateway = {};end;

NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_config.lua");
Map3DSystem.JGSL.config:load();

NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_agent.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_gateway.lua");
--NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_server.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_client.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_query.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MsgProc_game.lua");


	
local gateway = Map3DSystem.JGSL.gateway;
--local JGSL_server = Map3DSystem.JGSL_server;
local JGSL_client = Map3DSystem.JGSL_client;
local JGSL = Map3DSystem.JGSL;

-- boolean: whether this server is a grid server or not.
JGSL.IsGrid = nil;

-- dump all msg to log. should always be nil, except u are debugging
--JGSL.dump_server_msg = true;
--JGSL.dump_client_msg = true;

-- default neuron files for client and server. 
--JGSL.DefaultServerFile = "script/kids/3DMapSystemNetwork/JGSL_server.lua";
JGSL.DefaultClientFile = "script/kids/3DMapSystemNetwork/JGSL_client.lua";

-- TODO: the avatar to be displayed when the appearance is not synchronized in JGSL. Use something simple, such as a stick or a nude avatar. 
JGSL.DefaultAvatarFile = "character/v3/dummy/dummy.x";
-- JGSL.DefaultAvatarFile will be used as key to find the ccsstring. 
JGSL.DefaultAvatarCCSStrings = {
	["character/v3/Human/Female/HumanFemale.xml"] = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#10#12#0#0#0#0#0#0#0#",
	["character/v3/Human/Male/HumanMale.xml"] = "0#0#4#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#11#13#0#0#0#0#0#0#0#",
	["character/v3/Human/Female/HumanFemale.x"] = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#10#12#0#0#0#0#0#0#0#",
	["character/v3/Human/Male/HumanMale.x"] = "0#0#4#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#11#13#0#0#0#0#0#0#0#",
};

-- add any string map as you like once and for all. and make sure that the server has the same mapping.  It is better to fetch this via local or remote XML file.
function JGSL.InitStringMap()
	if(JabberClientManager) then
		JabberClientManager.ClearStringMap();
		JabberClientManager.AddStringMap(1, "script/kids/3DMapSystemNetwork/JGSL_gateway.lua");
		JabberClientManager.AddStringMap(2, "script/kids/3DMapSystemNetwork/JGSL_grid.lua");
		JabberClientManager.AddStringMap(3, "script/kids/3DMapSystemNetwork/JGSL_server.lua");
		JabberClientManager.AddStringMap(4, "script/kids/3DMapSystemNetwork/JGSL_client.lua");
		JabberClientManager.AddStringMap(5, "script/kids/3DMapSystemNetwork/JGSL_client_emu.lua");
		JabberClientManager.AddStringMap(6, "script/kids/3DMapSystemNetwork/EmuUsers.lua");
	end
end
JGSL.InitStringMap();

-----------------------------
-- public function
-----------------------------
-- get a connected jabber client. it may return nil if jabber client is invalid.
function JGSL.GetJC()
	if(JabberClientManager) then
		local jc = JabberClientManager.CreateJabberClient(Map3DSystem.User.jid);
		if(jc:IsValid() and jc:GetIsAuthenticated()) then
			return jc;
		end
	end
end

-- get the JID of this jabber client.
function JGSL.GetJID()
	return Map3DSystem.User.jid;
end

-- when client and server connect, they must exchange their session keys. By regenerating session keys, we 
-- will reject any previous established JGSL game connections. Usually we need to regenerate session when we load a different world.
-- @note: we will logout currently connected server if any. 
function JGSL.Reset()
	JGSL_client:LogoutServer();
	gateway:Reset();
	-- JGSL_server:Reset();
end

-- reset if not. 
function JGSL.ResetIfNot()
	if(not JGSL.IsResetBefore) then
		JGSL.IsResetBefore = true;
		JGSL.Reset();
	end
end

-- display text to in-game log panel. 
-- @param text: string
-- @param level: the level of importance of the message. it can be nil. 
function JGSL.Log(text, level)
	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_LOG, text=text})
end

-- return the index of a value from table Req_group, which equals value.  Return nil if not found
-- e.g SearchRequestGroup({[1] = "lxz@pe"}, "lxz@pe") returns 1
function JGSL.SearchRequestGroup(Req_group, value)
	if(Req_group~=nil) then
		local index, data;
		for index, data in ipairs(Req_group) do
			if(data == value) then
				return index;
			end
		end
	end
end

-- compress environment updates, removing redundent ones. 
-- It will ensure that the following messages will only have one latest copy in env array.
--  OCEAN_SET_WATER,  SKY_SET_Sky
-- @param env: array of env messages. 
function JGSL.CompressEnvs(env)
	if(env==nil) then return end
	
	local lastSetWaterIndex = nil;
	local lastSetSkyIndex = nil;
	
	local i=1;
	while true do
		-- create without writing to history
		local msg = env[i];
		if(msg==nil) then
			break;
		else
			if(msg.type == Map3DSystem.msg.OCEAN_SET_WATER) then
				if(lastSetWaterIndex ~= nil) then
					-- merge with previous ones
					commonlib.mincopy(msg, env[lastSetWaterIndex]);
					commonlib.removeArrayItem(env, lastSetWaterIndex);
					i = i-1;
				end
				lastSetWaterIndex = i;
			elseif(msg.type == Map3DSystem.msg.SKY_SET_Sky) then
				if(lastSetSkyIndex ~= nil) then
					-- merge with previous ones
					commonlib.mincopy(msg, env[lastSetSkyIndex]);
					commonlib.removeArrayItem(env, lastSetSkyIndex);
					i = i-1;
				end	
				lastSetSkyIndex = i;
			end
		end
		i=i+1;
	end
end
