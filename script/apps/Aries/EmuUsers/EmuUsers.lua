--[[
Title: Emulating a user for stress test
Author(s):  LiXizhi
Date: 2009/11/3
Desc: Create an instance of an EmuUser, specify its behavior and call start to begin emulating it. 
Internally a state machine is used. No user interface is supported for EmuUsers, it just emulate 
all packets sent of a standard user following normal login procedure. 

-- TODO: enable data compression for all internet NPL packets, and disable for Intranet packets:
	http://www.jenkinssoftware.com/raknet/manual/datacompression.html : Frequency table for average game. 
	http://cs.fit.edu/~mmahoney/compression/
	
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/EmuUsers/EmuUsers.lua");

local user = MyCompany.Aries.EmuUser:new({nid="some nid", password=""})
user:Start();
-- polling for user:IsLoggedIn()

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/jabber_client.lua");

-- define a base class with constructor
local EmuUser = commonlib.inherit(nil, {
	-- connection timeouts
	conn_timeout = 20,
	-- function () end to be called when user is signed in to the world 
	OnSignedIn = nil,
})
commonlib.setfield("MyCompany.Aries.EmuUser", EmuUser);

function EmuUser:ctor()
	self.nid = self.nid or "valid_nid";
	self.password = self.password or "1234567";
	self.worldpath = self.worldpath or ParaWorld.GetWorldDirectory();
	self.logger_name = "_emu_user_log_"..self.nid;
	-- we shall assume that the game server's nid is "gs_emu_self..[nid]", so that NPL will establish multiple connection even for the same host:port
	self.gs_nid = "gs_emu_"..self.nid;
	-- some internal states keeping
	self.states = {};
	-- REST based API client
	self.rest_client = GameServer.rest.client:new({});
	-- game client
	self.client = Map3DSystem.GSL.client:new({IsEmulated=true});
	-- jabber client
	self.jabber_client = GameServer.jabber.client:new({})
	self.jabber_client:AddEventListener("OnAuthenticate", EmuUser.JE_OnAuthenticate, self);
	self.jabber_client:AddEventListener("OnMessage", EmuUser.JE_OnMessage, self);
end

-- start the user
function EmuUser:Start()
	if(self.IsStarted) then return end
	
	self.IsStarted = true;
	self.state = "start";
	self:next_step("start");
end

-- set the initial player agent. This function should be called before we logged in to a given game world. 
-- @param playerAgent: a table containing {x,y,z,facing, ...}
function EmuUser:UpdatePlayerAgent(playerAgent)
	if(playerAgent) then
		local agent = self.client:GetPlayerAgent()
		if (agent) then
			commonlib.partialcopy(agent, playerAgent)
		end
	end
end

-- internally it is a state machine, call next to perform
-- @param state:
function EmuUser:next_step(state)
	if(not self.state) then return end
	self.state = state or self.state;
	state = self.state;
	
	if(state == "DoNormalUpdate") then
		return;
	end
	
	self:log("EmuUser(%s):  stage %s", self.nid, state);
	
	if(state == "start") then
		commonlib.applog("EmuUser(%s):  stage %s", self.nid, state);
		self:next_step("ConnectRestGateway");
	elseif(state == "ConnectRestGateway") then
		self:ConnectRestGateway();
	elseif(state == "AuthUser") then
		self:AuthUser()
	elseif(state == "SyncGlobalStore") then
		self:SyncGlobalStore()
	elseif(state == "ExtendedCostTemplate") then
		self:ExtendedCostTemplate()
	elseif(state == "CreateNewAvatar") then
		self:CreateNewAvatar()
	elseif(state == "VerifyNickName") then
		self:VerifyNickName()
	elseif(state == "DownloadProfile") then
		self:DownloadProfile()
	elseif(state == "VerifyInventory") then
		self:VerifyInventory()
	elseif(state == "VerifyPet") then
		self:VerifyPet()
	elseif(state == "VerifyFriends") then
		self:VerifyFriends()
	elseif(state == "InitJabber") then
		self:InitJabber()
	elseif(state == "SelectWorldServer") then
		self:SelectWorldServer()
	elseif(state == "LoadMainWorld") then
		self.SignedIn = true;
		self:LoadMainWorld()
	end
end

function EmuUser:log(...)
	--commonlib.servicelog(self.logger_name, ...);
	commonlib.applog(...)
end

function EmuUser:Fail(...)
	self:log("Error:");
	self:log(...);
	self.state = nil;
end

-- return true if the user has signed in to a game world. 
function EmuUser:IsLoggedIn()
	return self.SignedIn;
end

local bRestClientInited;
local rest_client;
function EmuUser:ConnectRestGateway()
	if(not bRestClientInited) then
		-- connect to game server using default local GameClient.config.xml
		bRestClientInited = true;
		GameServer.rest.client:load_config();
	end
	local best_world_server = self.rest_client.world_servers[1];

	-- add a unique game server nid to NPL runtime, as if each user is connecting to a different game server even all users are on the same machine. 	
	self.world_server = {
		host = best_world_server.host,
		port = best_world_server.port,
		nid = self.gs_nid,
		world_id = best_world_server.world_id,
	}
	-- commonlib.echo(self.world_server);
	
	self.rest_client:start(nil, 0, function(msg)
		if(msg and msg.connected) then
			self:next_step("AuthUser");
		else
			self:Fail("服务器的链接无法建立");
		end
	end, self.world_server);
end

function EmuUser:AuthUser()
	local url = paraworld.auth.AuthUser.GetUrl();
	
	self.rest_client:SendRequest(url, {
		username = self.nid,
		password = self.password,
	}, function (msg)
		if(msg ~= nil) then
			if(msg.issuccess) then
				self:log("%s authenticated", self.nid)
				
				-- NOTE by LiXizhi for temporary ejabberd authentication. 
				self.ejabberdsession = msg.ejabberdsession;
				self.ChatDomain = paraworld.TranslateURL("%CHATDOMAIN%");
				if(msg.nid) then
					self.jid = msg.nid.."@"..self.ChatDomain;
				end
				
				if(self.OnSignedIn) then
					self.OnSignedIn();
				end
				self:next_step("SyncGlobalStore");
			else
				self:Fail("%s can not be authenticated", self.nid)
			end
		end	
	end)
end

function EmuUser:SyncGlobalStore()
	local url = paraworld.globalstore.GetGSObtainCntInTimeSpan.GetUrl();
	
	-- gsid to fetch
	local gsids = {50004, 17012}
	
	self.states.gsid_index = (self.states.gsid_index or 0) + 1;
	local gsid = gsids[self.states.gsid_index];
	if(gsid) then
		self.rest_client:SendRequest(url, {
			gsid = gsid,
		}, function (msg)
			self:next_step();
		end)
	else	
		self:next_step("ExtendedCostTemplate")
	end	
end

function EmuUser:ExtendedCostTemplate()
	self:next_step("CreateNewAvatar")
end

function EmuUser:CreateNewAvatar()
	local url = paraworld.users.getInfo.GetUrl();
	
	self.rest_client:SendRequest(url, {
		nids = string.format("%s,", self.nid),
		fields = "birthday,emoney,nickname,nid,pmoney,userid",
	}, function (msg)
		self:next_step("VerifyNickName")
	end)
end

function EmuUser:VerifyNickName()
	self:next_step("DownloadProfile")
end
function EmuUser:DownloadProfile()
	local url = paraworld.profile.GetMCML.GetUrl(url);
	
	self.rest_client:SendRequest(url, {
	}, function (msg)
		self:next_step("VerifyInventory")
	end)
end

function EmuUser:VerifyInventory()
	local url = paraworld.inventory.GetItemsInBag.GetUrl();
	
	-- bags to fetch, both string and number are supported. 
	local bags = {"0", "1", "11", "12", "13", "21", "22", "23", "10062", "10063", "72", "81", "91", "10010"};
	
	self.states.inventory_index = (self.states.inventory_index or 0) + 1;
	local bag = tonumber(bags[self.states.inventory_index]);
	if(bag) then
		self.rest_client:SendRequest(url, {
			bag = bag,
		}, function (msg)
			self:next_step();
		end)
	else	
		self:next_step("VerifyPet")
	end	
end

function EmuUser:VerifyPet()
	self:next_step("InitJabber")
end


------------------------------------------------
-- jabber event callback
------------------------------------------------
function EmuUser:JE_OnAuthenticate(event)
	self:log(event)
	self:next_step("SelectWorldServer")
end

function EmuUser:JE_OnMessage(event)
	self:log(event)
end

function EmuUser:InitJabber()
	self.jabber_client:start(self.jid, self.ejabberdsession)
end

function EmuUser:SelectWorldServer()
	self:next_step("LoadMainWorld")
end

function EmuUser:LoadMainWorld()
	self:next_step("DoNormalUpdate")
	
	-- DUMMY: send an IM request message to himself
	self.jabber_client:SendRequest(self.jid, "ping", {}, function(jabber_client, jid_from, body) 
		commonlib.log("hi, I am online %s\n", jid_from)
		commonlib.echo(body)
	end)
	
	-- login to game server. 
	self.client:LoginServer(self.world_server.nid, self.world_server.world_id, self.worldpath)
	
	-- set the timer to send client normal update to server
	--self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		--self.client:AddRealtimeMessage({name="chat", value="I am a test user, hehe~"})
	--end})
	--self.timer:Change(300, 10000);
end

function EmuUser:DoNormalUpdate()
	-- TODO: use a timer to replay a rest dump log file from log/rest_*.log	
end

