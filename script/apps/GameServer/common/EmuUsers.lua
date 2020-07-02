--[[
Title:  TODO: NOT PORTED TO GSL YET, user emulation module
Author(s): LiXizhi
Date: 2008/12/21
Desc: Only one virtual user is allowed to login and interacts with the GUI. However, we allow unlimited accounts to simulaneously login in as emulated users. 
An emu user is a full fledged active user in the viewpoint of the server. User emulation is primarily used for 
   * server stress test, so that we can simulate 100 characters with low client side cost.
   * clients service management, one human client service personel can simultaneously chat with clients on behalf of multiple characters in different locations in the virtual world. 
   * auto bot. a robot agent that can do an variety of things. it therefore allows a single instance to run multiple auto bots. this is similar to MSN bot. 

User Guide
-------------------
The main user should be testers and client service personels. A simple configuration file is used to setup all emu users. The file contains username and password for each user.
Additional features per user include displayname, initial world, hangout positions; auto-reply text; gossip text, etc.

To start the emu layer, specify your EmuUsersDB file and call Map3DSystem.EmuUsers.LoadUsers("config/EmuUsersDB.table"), and off you go. 

The implementation
-------------------
instead of calling the default login API. a special login API is provided and the user session is maintained by the user emulation layer. 
	
use the lib:
------------------------------------------------------------
paraworld.ChangeDomain({domain="test.pala5.cn", chatdomain="192.168.0.233"})
NPL.load("(gl)script/apps/GameServer/common/EmuUsers.lua");
Map3DSystem.EmuUsers.LoadUsers("config/EmuUsersDB.xml")
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL.lua");

if(not Map3DSystem.EmuUsers) then Map3DSystem.EmuUsers={}; end
local EmuUsers = Map3DSystem.EmuUsers;

-- create a special Emu REST API wrapper
paraworld.CreateRESTJsonWrapper("Map3DSystem.EmuUsers.AuthUser", "%MAIN%/Auth/AuthUser.ashx");

-- array of user being emulated. 
local Users = {};
-- mapping from user.nid to instance of EmuUsers.user
local mapNID = {};
-- mapping from user.JID to instance of EmuUsers.user
local mapJID = {};

---------------------------------
-- user template and functions
---------------------------------
local user = {
	-- whether REST API auth is passed. 
	IsAuthenticated, 
	username,
	password,
	domain,
	nid,
	sessionkey,
	jid, -- usually nid@chatdomain. 
	chatdomain,
	
	--------------------------
	-- emu parameters
	--------------------------
	-- number of milli-seconds since last frame move call. 
	TimeSinceLastFrameMove = 0,
	-- The last time that it receives a message from the GSL server.
	LastGSLReceiveTime = 0,
	-- jabber client instance
	jc, 
	
	--------------------------
	-- additional features: all of them are optional.
	--------------------------
	nickname, 
	-- the world to login to
	worldpath,
	-- the jid of the server to connect to. it can omit the domain, such as "1100", instead of "1100@pala5.com"
	server,
	-- initial agent appearance.
	agent = {
		-- current position. After compressing, it has 2 decimal
		x=nil,y=nil,z=nil,
		-- the nick name to be displayed on head of character 
		nickname=nil,
		-- id or string of the main asset file of the agent
		AssetFile=nil,
		-- customizable character string,
		ccs=nil,
		-- scaling.After compressing, it has 2 decimal
		scaling=nil,
		-- anim id or string
		anim=nil,
		-- character facing. After compressing, it is [0,6.28/256)
		facing=nil,
	},
	-- an array table containing hangout positions
	hangoutPos,
	-- an array of text or a CSV string of text to automatically reply to incoming calls. 
	autoreply,
	-- an array of text to speak every time interval, so the emu user appears to be alive. 
	gossiptext,
}
EmuUsers.user = user;

-- a mapping from key name to string(the string is in CSV format). 
EmuUsers.TextGroup = {};

function user:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- convert full jid to jid, removing the trailing resource string /paraengine
	if(o.jid~=nil) then
		o.jid = string.gsub(o.jid, "/.*$", "");
	end
	-- for data keeping. 
	o.group2 = {};
	return o
end

-- function to be called periodically. 
function user:log(...)
	commonlib.log("EmuUser:%s(%s)", self.username, tostring(self.nid));
	commonlib.log(...);
	log("\n")
end

-- function to be called periodically. 
function user:FrameMove(timeNow)
end

-- call this function to release the user and remove it from the emulation layer. 
function user:Release(timeNow)
	if(self.jc) then
		jc:Close();
		self.jc = nil;
	end
	if(self.jid) then
		mapJID[self.jid] = nil;
	end
	if(self.nid) then
		mapNID[self.nid] = nil;
	end
end


-- call this function to authenticate the user with the central API and then connect to GSL server. 
function user:Connect()
	Map3DSystem.EmuUsers.AuthUser({username = self.username, password = self.password}, self.username, function(msg)
		if(msg) then
			if(msg.issuccess) then
				self.IsAuthenticated = true;
				self.sessionkey= msg.sessionkey;
				self.nid= msg.nid;
				self.uid = msg.userid;
				self.jid = string.format("%s@%s", self.nid, self.chatdomain);
				mapNID[self.nid] = mapNID[self.nid] or self;
				mapJID[self.jid] = mapJID[self.jid] or self;
				
				commonlib.log("EmuUser: %s (%s) is authenticated.uid=%s,  sk=%s\n", self.username, self.nid, self.uid, self.sessionkey)
				
				self:JC_Connect();
			else
				commonlib.log("warning: can not auth emulated user %s\n", self.username);
			end
		end
	end)
end

-- connecting to jabber client
function user:JC_Connect()
	if(self.IsAuthenticated and self.jid) then
		if(not self.jc) then
			local jc = JabberClientManager.CreateJabberClient(self.jid);
			self.jc = jc;
			jc.Password = self.password;
			jc:ResetAllEventListeners();
			-- bind event
			jc:AddEventListener("JE_OnConnect", "Map3DSystem.EmuUsers.JE_OnConnect()");
			jc:AddEventListener("JE_OnAuthenticate", "Map3DSystem.EmuUsers.JE_OnAuthenticate()");
			jc:AddEventListener("JE_OnDisconnect", "Map3DSystem.EmuUsers.JE_OnDisconnect()");
			jc:AddEventListener("JE_OnAuthError", "Map3DSystem.EmuUsers.JE_OnAuthError()");
			jc:AddEventListener("JE_OnError", "Map3DSystem.EmuUsers.JE_OnError()");
			
			-- TODO: map this to ChatApp handler. 
			jc:AddEventListener("JE_OnMessage", "Map3DSystem.EmuUsers.JE_OnMessage()");
		end
		if(not self.jc:GetIsAuthenticated()) then
			if(not self.jc:Connect()) then
				commonlib.log("warning: cannot make connection for %s\n", self.jid)
			end
		end
	end
end

-- login to GSL server
function user:LoginGSL()
	if(not (self.server and self.playeragent and self.playeragent.x and self.playeragent.AssetFile)) then
		commonlib.log("JCEmu: GSL is ignored, since there is no agent or server data for %s \n", self.jid);
		return;
	end
	if(not self.client) then
		self.client = Map3DSystem.GSL.client:new ({IsEmulated=true, jid = self.jid})
	end
	
	-- apply the agent info from emu user config file. 
	local agent = self.client:GetPlayerAgent()
	if (agent) then
		commonlib.partialcopy(agent, self.playeragent)
		self.client.timeid = self.client.timeid + 1;
		-- this ensures that AssetFile are transmitted. 
		agent.GTwo= true;
	end
	commonlib.log("JCEmu: %s connecting to GSL gateway %s\n", self.jid, self.server)
	self.client.EmuUser_worldpath = worldpath;
	self.client:LoginServer(self.server)
end

-- get a random text string from auto reply text if any. 
-- @return the text or nil.
function user:GetAutoReply()
	if(self.autoreply) then
		-- convert csv string to an array table.
		if(type(self.autoreply) == "string") then
			local sentences = {};
			local sentence
			for sentence in string.gmatch(self.autoreply, "[^,]+") do
				table.insert(sentences, sentence);
			end
			self.autoreply = sentences;
		end
		if(type(self.autoreply) == "table") then
			
			local nIndex = math.floor(ParaGlobal.random()*(#(self.autoreply)))+1;
			if(nIndex <= 0) then
				nIndex = 1;
			end
			if(nIndex > #(self.autoreply)) then
				nIndex = #(self.autoreply);
			end
			
			if(nIndex>=1) then
				return self.autoreply[nIndex]
			end
		end	
	end
end

-- send a chat message to a given jid
function user:SendChatMessage(jid, body)
	if(self.jc) then
		self.jc:Message(jid, body);
	end
end

---------------------------------
-- jabber event callback functions
---------------------------------
function EmuUsers.JE_OnConnect()
	local u = EmuUsers.GetUserByJID(msg.jckey);
	if(u) then
		u:log("Connection established");
	end
end
function EmuUsers.JE_OnAuthenticate()
	local u = EmuUsers.GetUserByJID(msg.jckey);
	if(u) then
		u:log("JC authenticated");
		--u:log("resource id is "..tostring(u.jc.Resource));
		u:LoginGSL();
	end
end
function EmuUsers.JE_OnDisconnect()
	local u = EmuUsers.GetUserByJID(msg.jckey);
	if(u) then
		u:log("Disconnected");
		-- TODO: shall we do auto reconnect, here? 
	end
end
function EmuUsers.JE_OnAuthError()
	local u = EmuUsers.GetUserByJID(msg.jckey);
	if(u) then
		u:log("Auth Error!");
	end
end
function EmuUsers.JE_OnError()
	local u = EmuUsers.GetUserByJID(msg.jckey);
	if(u) then
		u:log("Error!");
		commonlib.echo(msg)
	end
end
function EmuUsers.JE_OnMessage()
	if(msg and msg.subtype) then
		if( msg.subtype == 8192) then
			-- the client msg.from is possibly offline, since we received an invalid message, here. 
			-- because server is epoll style, we do nothing about it. 
			return
		end
	end
	
	local u = EmuUsers.GetUserByJID(msg.jckey);
	if(u) then
		u:log("received msg from %s: %s", msg.from, tostring(msg.body));
		
		-- TODO: forward the message to main user IM's JE_OnMessage. so that it get a chance to display on GUI. 
		
		local replytext = u:GetAutoReply();
		if(replytext) then
			-- TODO: push to a queue, and use a timer to reply with a time delay.  here I just reply immediately. 
			u:SendChatMessage(msg.from, replytext);
		end
	end
end

---------------------------------
-- pub functions
---------------------------------

-- do something for each user
-- e.g. EmuUsers.EachUser(function(user) user:Connect() end)
-- @param callbackFunc: a function (user) end, this function will be call for each user, with user table as input.
function EmuUsers.EachUser(callbackFunc)
	local _, u;
	for _, u in pairs(Users) do
		callbackFunc(u);
	end
end

-- this function should be called periodically (such as every second) to simulate all emu users.
-- internally it iterate all users and send update to server if needed. 
-- @param timeNow: the current system time in milliseconds. It is used to deduce the elapsed time since last call.  
function EmuUsers.FrameMove(timeNow)
	EmuUsers.EachUser(function(user) 
		user:FrameMove(timeNow) 
	end)
end

-- load users from a configuration file
-- @param filename filename. 
function EmuUsers.LoadUsers(filename)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		local node;
		
		-- read all TextGroups
		for node in commonlib.XPath.eachNode(xmlRoot, "/EmuDB/TextGroup/text") do
			if(node.attr and node.attr.key and type(node[1]) == "string") then
				EmuUsers.TextGroup[node.attr.key] = node[1];
			end
		end
		--commonlib.echo(EmuUsers.TextGroup)
		
		-- read all users
		for node in commonlib.XPath.eachNode(xmlRoot, "/EmuDB/EmuUsers/user") do
			-- skip the current user
			if(node.attr and node.attr.username~=Map3DSystem.User.Name) then
				local u = EmuUsers.CreateUser(node.attr);
				if(u) then
					-- read agent structure
					local agentNode
					for agentNode in commonlib.XPath.eachNode(node, "/playeragent") do
						u.playeragent = {
							jid = u.jid,
							x = tonumber(agentNode.attr.x),
							y = tonumber(agentNode.attr.y),
							z = tonumber(agentNode.attr.z),
							facing = tonumber(agentNode.attr.facing),
							nickname = agentNode.attr.nickname,
							AssetFile = agentNode.attr.AssetFile,
							-- whether this is a dummy
							dummy = tonumber(agentNode.attr.dummy),
						} 
						--commonlib.echo(u.playeragent);
					end
					-- read auto reply text
					local autoreplyNode
					for autoreplyNode in commonlib.XPath.eachNode(node, "/autoreply") do
						if(autoreplyNode.attr and autoreplyNode.attr.textkey) then
							u.autoreply = EmuUsers.TextGroup[autoreplyNode.attr.textkey];
						end
						if(type(autoreplyNode[1]) == "string") then
							u.autoreply = autoreplyNode[1];
						end
					end
				end	
			end
		end
	else
		commonlib.log("warning: failed loading emu user table %s\n", filename);
	end
end

-- Create a new user to the emulation layer. It will authenticate the user, connect to GSL, and then begins simulation
-- @param usertable: {username, password, chatdomain, worldpath, server}
--			username: input to the AuthUser Rest API. it should be the user's email address.
--			password: password to the AuthUser Rest API.
--			chatdomain: if nil, the default one %CHATDOMAIN% will be used. 
function EmuUsers.CreateUser(usertable)
	if(not usertable or not usertable.username or not usertable.password) then
		log("warning: incomplete usertable used in emu createuser\n")
		return;
	end
	local u = EmuUsers.FindUserByName(usertable.username);
	if(u) then
		commonlib.log("warning: failed EmuUsers.CreateUser(%s) because the user already exist. \n", usertable.username)
		return;
	else
		usertable.chatdomain = usertable.chatdomain or paraworld.TranslateURL("%CHATDOMAIN%");
		u = EmuUsers.user:new(usertable);
		u.worldpath = usertable.worldpath;
		-- force gateway if any for testing purposes. 
		u.server = Map3DSystem.options.ForceGateway or usertable.server;
		if(u.server) then
			if(not string.match(u.server, "@")) then
				u.server = u.server.."@"..usertable.chatdomain;
			end
		end
		table.insert(Users, u);
		if (u.nid) then
			mapNID[u.nid] = u;
		end
		if (u.jid) then	
			mapJID[u.jid] = u;
		end	
	end
	u:Connect();
	return u;
end

-- return a given EmuUsers.user
function EmuUsers.GetUserByNID(nid)
	return mapNID[nid]
end

-- return a given EmuUsers.user
function EmuUsers.GetUserByJID(jid)
	return mapJID[jid]
end

-- return a given EmuUsers.user if found
function EmuUsers.FindUserByName(username)
	local _, u;
	for _, u in pairs(Users) do
		if(u.username == username) then
			return u;
		end	
	end
end


local function activate()
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local JID = string.gsub(msg.from, "/.*$", "");
end
NPL.this(activate);
