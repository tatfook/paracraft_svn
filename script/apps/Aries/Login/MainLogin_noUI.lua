--[[
Title: Aries Main login NOUI for API test
Date: 2010/5/18
The login procedure is this:
	-----------	
	- B: local user account
	- B.1: get saved account from config/LocalUsers.table
	- B.2: if there are saved accounts, open LocalUserSelectPage.html, otherwise continue to next step. 
	- B.3: open UserLoginPage.html
	-----------	
	- C: online login [No User Interface]. if anything goes wrong, return to B.3. 
	- C.1: Login_procedure: connect to the default game server
	- C.2: Get user items, fetching roster and presence information, etc.
	- C.3: fork: if user is new or does not contain avatar, proceed to D section, otherwise proceed to E section
	-----------	
	- E: World Server Selection
	- E.1: sort world server list. 
	- E.2: display the ServerSelectPage1.html, let the user pick a game world to connect to. 
	- E.3: switch to the game server containing the user selected world server. 
	-----------
Internally, we use a state machine to handle above functions. 
	- Call MainLogin:next_step() to proceed to next step according to current state. if MainLogin.next_step() returns true, we can start loading the initial world. 
	- Please see the MainLogin:start() function and comments of self.handlers

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/MainLogin_noUI.lua");
MyCompany.Aries.MainLogin:start();
------------------------------------------------------------
]]

-- NOTE: suggest the offline mode COMPLETELY DEPRECATED in Aries

-- create class
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");
local UserLoginProcess = nil;

-- the initial states in the state machine. 
-- Please see self:next_step() for more information on the meaning of these states. 
MainLogin.state = {
	IsUpdaterStarted = nil,
	Loaded3DSceneRequested = nil,
	IsCoreClientUpdated = nil,
	IsRebootRequired = nil,
	IsAssetSyncStarted = nil,
	IsLocalUserSelected = nil,
	IsRegistrationRequested = nil,
	IsUserSelected = nil,
	IsLoginStarted = nil,
	IsOfflineModeActivated =nil,
	IsRestGatewayConnected = nil,
	IsRegUserRequested = nil,
	IsRegUserConfirmRequested = nil,
	IsAuthenticated = false,
	IsNickNameVerified = nil,
	IsAvatarCreationRequested = nil,
	IsFamilyInfoVerified = nil,
	IsGlobalStoreSynced = nil,
	IsExtendedCostSynced = nil,
	IsInventoryVerified = nil,
	IsEssentialItemsVerified = nil,
	IsPetVerified = nil,
	IsVIPItemsVerified = nil,
	IsFriendsVerified = nil,
	IsJabberInited = nil,
	IsWorldServerSelected = nil,
	IsLoadMainWorldRequested = nil,
	IsLoadTutorialWorldRequested = nil, -- NOT used
	IsLoadHomeWorldRequested = nil, -- NOT used
	IsWorldConnected = nil,
	IsAPItested = nil,

	-- table of {user_nid = "1234567", user_name = "", password="",}, as a result of SelectLocalUser
	local_user = nil,	
	-- the background 3d world path during login. This is set during Updater progress. We can display some news and movies in it. 
	login_bg_worldpath = nil,
	-- a table of {username, password} as a result of UserLoginPage
	auth_user = {username="50333182", password="pe1234567",},
	-- registration user
	reg_user = {},
	-- a table of {worldpath, role, bHideProgressUI, movie, gs_nid, ws_id }, to be passed to LoadWorld command. 
	-- where gs_nid is the game server nid, and ws_id is the world server id. 
	load_world_params = nil,
};

-- start the login procedure. Only call this function once. 
function MainLogin:start()
	-- initial states
	MainLogin.state = {
		reg_user = {},
	};
	
	NPL.load("(gl)script/apps/Aries/Login/UserLoginProcess_noUI.lua");
	UserLoginProcess = UserLoginProcess or commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");
	
	-- register external functions for each login step. Each handler's first parameter is MainLogin class instance. 
	-- TODO: add your custom handlers here. 
	self.handlers = self.handlers or {
		-- update the core ParaEngine and minimal art assets. The logo page is also displayed here. 
		-- UpdateCoreClient = self.UpdateCoreClient,
		-- load the background scene
		-- LoadBackground3DScene = self.LoadBackground3DScene,
		RebootClient = self.RebootClient,
		StartAssetSync = self.StartAssetSync,
		-- select a locally saved user account to login
		SelectLocalUser = self.SelectLocalUser,
		-- the login page
		ShowLoginPage = self.ShowLoginPage,
		-- the registration page
		-- ShowRegPage = self.ShowRegPage,
		-- establish the first rest connection with the initial gateway game server. 
		ConnectRestGateway = UserLoginProcess.Proc_ConnectRestGateway,
		-- Establish connection with the default gateway game server; and authenticate the user and establish jabber connection. 
		AuthUser = UserLoginProcess.Proc_Authentication,
		-- register the user
		-- RegUser = UserLoginProcess.Proc_Registration,
		-- show the confirm page
		-- RegUserConfirm = self.ShowRegConfirmPage,
		-- if AuthUser returns msg.isreg is false, we will needs to trigger this one before proceding to next step. 
		-- CreateNewAvatar = self.CreateNewAvatar,
		-- note:if no nick name is found, this user should be treated as a newly registered user, 
		-- and we should direct it to CreateNewAvatar page
		VerifyNickName = UserLoginProcess.Proc_VerifyNickName,
		-- download the family profile 
		VerifyFamilyInfo = UserLoginProcess.Proc_VerifyFamilyInfo,
		-- verify all server objects
		VerifyServerObjects = UserLoginProcess.Proc_VerifyServerObjects,
		-- sync global store
		SyncGlobalStore = UserLoginProcess.Proc_SyncGlobalStore,
		-- sync extended cost template
		ExtendedCostTemplate = UserLoginProcess.Proc_SyncExtendedCost,
		-- verify the inventory 
		VerifyInventory = UserLoginProcess.Proc_VerifyInventory,
		-- verify pet
		VerifyPet = UserLoginProcess.Proc_VerifyPet,
		-- verify essential items
		VerifyEssentialItems = UserLoginProcess.Proc_VerifyEssentialItems,
		-- verify vip items
		VerifyVIPItems = UserLoginProcess.Proc_VerifyVIPItems,
		-- verify friends
		VerifyFriends = UserLoginProcess.Proc_VerifyFriends,
		-- init jabber
		InitJabber = UserLoginProcess.Proc_InitJabber,
		-- pick a world server
		SelectWorldServer = self.SelectWorldServer,
		-- connect main world
		LoadMainWorld = self.LoadMainWorld,
		-- API test, Added by YanDongdong
		API_test = self.API_unit_test,
	}
	self:next_step();
	
	-- in case there are background asset.
	-- NPL.load("(gl)script/kids/3DMapSystemApp/Assets/AsyncLoaderProgressBar.lua");
	-- Map3DSystem.App.Assets.AsyncLoaderProgressBar.CreateDefaultAssetBar(true, "_lb", 20, -360, 32, 160);
end

-- invoke a handler 
function MainLogin:Invoke_handler(handler_name)
	if(self.handlers and self.handlers[handler_name]) then
		commonlib.log("=====>Login Stage: %s\n", handler_name);
		self.handlers[handler_name](self);
	--	commonlib.log("%s finished!.....\n", handler_name);
	else
		commonlib.log("error: unable to find login handler %s \n", handler_name);
	end
end

-- perform next step. 
-- @param state_update: This can be nil, it is a table to modify the current state. such as {IsLocalUserSelected=true}
function MainLogin:next_step(state_update)
	local state = self.state;
	if(state_update) then
		if(state_update.IsAuthenticated == false) then	
			-- if not authenticated, then everything afterwards should be canceled. 
			state.IsNickNameVerified = nil;
			state.IsAvatarCreationRequested = nil;
			state.IsFamilyInfoVerified = nil;
			state.IsGlobalStoreSynced = nil;
			state.IsExtendedCostSynced = nil;
			state.IsInventoryVerified = nil;
			state.IsEssentialItemsVerified = nil;
			state.IsPetVerified = nil;
			state.IsVIPItemsVerified = nil;
			state.IsFriendsVerified = nil;
			state.IsJabberInited = nil;
			state.IsWorldServerSelected = nil;
			state.IsLoadMainWorldRequested = nil;
			state.IsLoadTutorialWorldRequested = nil; -- NOT used
			state.IsLoadHomeWorldRequested = nil; -- NOT used
			state.IsWorldConnected = nil;
		end
		commonlib.partialcopy(state, state_update);
	end
	
	commonlib.log(main_state.."|===========\n");
	commonlib.log({state});
	
	if(state.IsRebootRequired) then	
		self:Invoke_handler("RebootClient");
--	elseif(not state.IsUpdaterStarted) then	
--		self:Invoke_handler("UpdateCoreClient");
--	elseif(state.Loaded3DSceneRequested) then
--		self:Invoke_handler("LoadBackground3DScene");
--	elseif(not state.IsCoreClientUpdated) then	
--		return
	elseif(not state.IsAssetSyncStarted) then
		self:Invoke_handler("StartAssetSync");
--	elseif(state.IsRegistrationRequested) then
--		self:Invoke_handler("ShowRegPage");		
	elseif(not state.IsLocalUserSelected) then
		self:Invoke_handler("SelectLocalUser");
	elseif(not state.IsLoginStarted) then
		self:Invoke_handler("ShowLoginPage");
	elseif(not state.IsRestGatewayConnected) then
		self:Invoke_handler("ConnectRestGateway");		
--	elseif(state.IsRegUserRequested) then		
--		self:Invoke_handler("RegUser");	
--	elseif(state.IsRegUserConfirmRequested) then		
--		self:Invoke_handler("RegUserConfirm");				
	elseif(not state.IsAuthenticated) then	
		self:Invoke_handler("AuthUser");
	elseif(not state.IsFriendsVerified) then
		self:Invoke_handler("VerifyFriends");		
	elseif(not state.IsGlobalStoreSynced) then
		self:Invoke_handler("SyncGlobalStore"); -- move the sync global store process before create avatar
	elseif(not state.IsExtendedCostSynced) then
		self:Invoke_handler("ExtendedCostTemplate");
--	elseif(state.IsAvatarCreationRequested) then		
--		self:Invoke_handler("CreateNewAvatar");
	elseif(not state.IsNickNameVerified) then
		self:Invoke_handler("VerifyNickName");
	elseif(not state.IsFamilyInfoVerified) then	
		self:Invoke_handler("VerifyFamilyInfo");
	elseif(not state.IsServerObjectsVerified) then	
		self:Invoke_handler("VerifyServerObjects");
	elseif(not state.IsInventoryVerified) then
		self:Invoke_handler("VerifyInventory");	
	elseif(not state.IsEssentialItemsVerified) then
		self:Invoke_handler("VerifyEssentialItems");
	elseif(not state.IsPetVerified) then
		self:Invoke_handler("VerifyPet");
	elseif(not state.IsVIPItemsVerified) then
		self:Invoke_handler("VerifyVIPItems");
	elseif(not state.IsJabberInited) then
		self:Invoke_handler("InitJabber");
	elseif(not state.IsWorldServerSelected) then	
		self:Invoke_handler("SelectWorldServer");
--	elseif(state.IsLoadMainWorldRequested and state.load_world_params) then		
--		self:Invoke_handler("LoadMainWorld");
	elseif(not state.IsAPItested) then	
		self:Invoke_handler("API_test");
	end
end

-- TODO: login handler
function MainLogin:RebootClient()
	self.state.IsRebootRequired = nil;
	-- ParaEngine.exit();
end

-- TODO: login handler
function MainLogin:StartAssetSync()
	self:next_step({IsAssetSyncStarted = true});
end

-- login handler
function MainLogin:ShowLoginPage()
	MainLogin:next_step({IsLoginStarted=true, auth_user = {username="50333182", password="pe1234567",}});
end

-- login handler
function MainLogin:SelectLocalUser()
	-- TODO: very dirty code
	-- overwrite the System.UI.CCS.ApplyCCSInfoString function
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	-- needs to read from config/LocalUsers.table
	NPL.load("(gl)script/apps/Aries/Login/LocalUserSelectPage.lua");
	local local_user_count = MyCompany.Aries.LocalUserSelectPage:LoadFromFile();
	
	-- 2010/5/5 instant login 
	-- if the following file exist the login process will use the username and password in the file to process instant login
	local_user_count = 0;
	self:next_step({IsLocalUserSelected = true});	
end

-- login handler
function MainLogin:SelectWorldServer()
	-- removed, now bg is in banner page: manally assign the background in window frame style
	--local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	--style.window_bg = "Texture/Aries/Login/UserSelect_BG2_32bits.png; 0 0 1020 680";
	
	--[[
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Login/ServerSelectPage1.html", 
		name = "ServerSelectPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		-- style = style,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		allowDrag = false,
		directPosition = true,
			align = "_ct",
			x = -1020/2,
			y = -680/2,
			width = 1020,
			height = 680,
		-- cancelShowAnimation = true,
	});
	]]

	world= { gs_nid="1002", id="015.", people=1, percentage=0, seqno=15, text="七色丛林", type="", ws_id="2" }

	commonlib.echo("begin to switch world server!");	
	commonlib.applog("user selected"..commonlib.serialize(world));
	
	local is_switching_from_game;	
	
	-- go to next step after we have an authenticated connection.
	local function GotoNextStep()
		NPL.load("(gl)script/apps/GameServer/GSL.lua");
		Map3DSystem.GSL_client:Reset();
		
		-- go to next step
		MainLogin:next_step({
			IsWorldServerSelected = true, 
			IsLoadMainWorldRequested=true, 
			load_world_params = {
				worldpath = world.worldpath,
				gs_nid = world.gs_nid, 
				ws_id = world.ws_id,
				ws_text = world.text,
				ws_seqid = world.id,
			},
		});
	end
	
	local function ConnectFail(reasonText)
		commonlib.applog(string.format("failed to connect to %s", world.gs_nid));
		
		if(not is_switching_from_game) then
			commonlib.log("无法连接这台服务器, 请试试其他服务器");
			MyCompany.Aries.MainLogin:next_step(state or {IsLoginStarted = false});
		else
			commonlib.log("无法连接这台服务器, 请重新登录并试试其他服务器");
			Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
		end	
	end
	
	----------------------------
	-- switch game server and authenticate using old account
	----------------------------
	local rest_client = GameServer.rest.client;
	if(rest_client:get_current_server_nid() == world.gs_nid) then
		-- if user selects the same server as we logged in, use it. 
		GotoNextStep();
	else
		commonlib.log("正在切换服务器...");			
		-- if user selects a different game server, diconnect old and connect to the new one and sign in using the same account. 
		GameServer.rest.client:connect({nid=world.gs_nid, world_id=world.ws_id,}, timeout, function(msg) 
			if(msg.connected) then
				commonlib.applog(string.format("connection with world server %s is established", world.gs_nid))
				commonlib.log("连接成功, 正在验证用户身份...");
				if(msg.is_switch_connection) then
					-- authenticate again with the new game server using existing account. 
					paraworld.auth.AuthUser({username = tostring(System.User.nid), password = System.User.Password,}, "login", function (msg)
						if(msg==nil) then
							ConnectFail("这台服务器无法认证, 请试试其他服务器");
						elseif(msg.issuccess) then	
							GotoNextStep();
						else
							ConnectFail("服务器认证失败了, 请重新登录");
						end
					end, nil, 20000, function(msg)
						-- timeout request
						commonlib.applog("Proc_Authentication timed out")
						ConnectFail("用户验证超时了, 可能服务器太忙了, 或者您的网络质量不好.");
					end);
				end
			else
				ConnectFail("无法连接这台服务器, 请试试其他服务器");
			end
		end)
	end
	
end


-- login handler
function MainLogin:LoadMainWorld()
	self:next_step({IsLoadMainWorldRequested = false});	
	
	local params = self.state.load_world_params;
	
	-- clear the logo page UI. 
	-- System.App.Commands.Call("File.MCMLWindowFrame", {
	--	name = "LogoBottomBannerPage", 
	--	bDestroy = true,
	-- });
	
	if(ParaWorld.GetWorldDirectory() ~= params.worldpath) then
		
		-- NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
		-- Map3DSystem.App.HomeLand.HomeLandGateway.Away();

		NPL.load("(gl)script/apps/GameServer/GSL.lua");
		Map3DSystem.GSL_client:LogoutServer(true);

		System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
		
		-- also log client version in post log
		--local ClientVersion = "";
		--if(ParaIO.DoesFileExist("version.txt")) then
		--	local file = ParaIO.open("version.txt", "r");
		--	if(file:IsValid()) then
		--		local text = file:GetText();
		--		ClientVersion = string.match(text, "^ver=([%.%d]+)") or "";
		--		file:close();
		--	end
		--end
		
		-- send log information
		--paraworld.PostLog({action = "user_enter_community", clientversion = ClientVersion}, "user_enter_community_log", function(msg)
		--end);
	end	
end

-- In case we have lost connection with the game server due to network instability. 
-- we can recover the previous connection and do a quick authentication using old credentials. 
-- Please note that, we will not reconnect to GSL servers or continue any timed out API requests. 
-- The user is at risk that GSL server or API requests may not work properly after reconnection. 
-- So we still recomment user to do a full software restart of the system, instead of using the recovered connection 
-- unless the user is at some critical task such as creating game world that he or she does not wish to terminate immediately. 
-- @note: Usually if recover failed, we may wait a few seconds and try again. In most cases, we will always do automatic connection recovery
-- @param callbackFunc: a function(msg) end, where msg = {connected=boolean}.
function MainLogin:RecoverConnection(callbackFunc)
	if(main_state=="exit") then	
		ParaGlobal.Exit(0);		
	end	
	local function RecoverFailed()
		if(callbackFunc) then
			callbackFunc({connected=false})
		end	
	end
	if(not System.User.IsAuthenticated) then
		log("we can not recover an authenticated connection\n")
		RecoverFailed();
	end
	
	commonlib.applog("Now trying to recover connection with game server and re-authenticate ...")
	
	System.User.IsRedirecting = true;
	local res = GameServer.rest.client:recover_connection(function(msg)
		if(msg and msg.connected) then
			-- connection is established, we will now authenticate using old credentials. 
			paraworld.auth.AuthUser({
					username = System.User.username,
					password = System.User.Password,
				}, "login", function (msg)
					if(msg==nil) then
						RecoverFailed()
					elseif(msg.issuccess) then	
						-- successfully recovered from connection. 
						commonlib.log("Successfully recovered connection with game server and re-authenticated\n")
						if(callbackFunc) then
							callbackFunc({connected=true})
						end	
					else
						RecoverFailed()
					end
				end, nil, 20000, function(msg)
					-- timeout request
					RecoverFailed();
				end)
		else
			RecoverFailed()
		end
	end)
	if( res ~= 0) then
		RecoverFailed()
	end
end

function MainLogin:API_unit_test()
		NPL.load("(gl)script/ide/UnitTest/unit_test.lua");	
		ParaIO.DeleteFile("temp/*.test");
		local test = commonlib.UnitTest:new();
		-- test:ClearResult();
		if(test:ParseFile("script/kids/3DMapSystemApp/API/test/paraworld.worlds.test.lua")) then
			test:Run();
		end	
		main_state="exit";
		-- go to next step
		MainLogin:next_step({IsAPItested = true });		
end