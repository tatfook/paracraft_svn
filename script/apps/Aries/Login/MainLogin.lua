--[[
Title: Aries Main login window
Author(s):  WangTian, LiXizhi
Company: ParaEnging Co. & Taomee Inc.
Date: 2009/4/6, refactored LXZ 2009.8.1
Desc: The login window that shows at startup not the login window in game
The login procedure is this:
	- A: Update Core Client
	- A.1: Start ClientUpdaterPage.html. Check Version and download necessary client files to patch folder
	- A.2: load the background 3D scene while updating client. 
	- A.3: if reboot is needed, exit current application and run the bootstrapper/updater application(which will apply downloaded patch and run the main exe again, go to A.1). 
	- A.4: start synchronizing assets in the background. 
	-----------	
	- B: local user account
	- B.1: get saved account from config/LocalUsers.table
	- B.2: if there are saved accounts, open LocalUserSelectPage.html, otherwise continue to next step. 
	- B.3: open UserLoginPage.html
	-----------	
	- C: online login [No User Interface]. if anything goes wrong, return to B.3. 
	- C.1: Login_procedure: connect to the default game server, and connect to jabber server
	- C.2: Get user items, fetching roster and presence information, etc.
	- C.3: fork: if user is new or does not contain avatar, proceed to D section, otherwise proceed to E section
	-----------	
	- D: Avatar Creation
	- D.1: TODO: 
	- D.2: TODO: 
	- D.3: TODO:  Once finished, proceed to E section. 
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
NPL.load("(gl)script/apps/Aries/Login/MainLogin.lua");
MyCompany.Aries.MainLogin:start();
------------------------------------------------------------
]]

-- NOTE: suggest the offline mode COMPLETELY DEPRECATED in Aries
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Partners/PartnerPlatforms.lua");
local Platforms = commonlib.gettable("MyCompany.Aries.Partners.Platforms");
			
-- create class
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");
local UserLoginProcess = nil;

-- the initial states in the state machine. 
-- Please see self:next_step() for more information on the meaning of these states. 
MainLogin.state = {
	IsVersionSelected = nil,
	IsUpdaterStarted = nil,
	Loaded3DSceneRequested = nil,
	IsInitFuncCalled = nil,
	IsCoreClientUpdated = nil,
	IsRebootRequired = nil,
	IsPackagesLoaded = nil,
	IsAssetSyncStarted = nil,
	IsLocalUserSelected = nil,
	IsRegistrationRequested = nil,
	IsUserSelected = nil,
	IsLoginStarted = nil,
	IsOfflineModeActivated =nil,
	IsRegRealnm = false,
	IsRestGatewayConnected = nil,
	IsProductVersionVerified = nil,
	IsUserNidSelected = nil,
	IsRegUserRequested = nil,
	IsRegUserConfirmRequested = nil,
	IsAuthenticated = nil,
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
	IsCleanCached = nil,
	IsTutorialFinished = nil,
	IsWorldServerSelected = nil,
	IsLoadMainWorldRequested = nil,
	IsLoadTutorialWorldRequested = nil, -- NOT used
	IsLoadHomeWorldRequested = nil, -- NOT used
	IsWorldConnected = nil,

	-- table of {user_nid = "1234567", user_name = "", password="",}, as a result of SelectLocalUser
	local_user = nil,	
	-- the background 3d world path during login. This is set during Updater progress. We can display some news and movies in it. 
	login_bg_worldpath = nil,
	-- a table of {username, password} as a result of UserLoginPage
	auth_user = nil,
	-- registration user
	reg_user = {},
	-- a table of {worldpath, role, bHideProgressUI, movie, gs_nid, ws_id }, to be passed to LoadWorld command. 
	-- where gs_nid is the game server nid, and ws_id is the world server id. 
	load_world_params = nil,
	-- the main login world
	login_bg_worldpath = nil,
	-- the preferred gateway game server during login process. nil or a table of {nid=game_server_nid_string}
	gateway_server = nil,
};

-- mapping from game server nid to last ping latency in milliseconds
MainLogin.network_latency = {};

-- start the login procedure. Only call this function once. 
-- @param init_callback: the one time init function to be called to load theme and config etc.
function MainLogin:start(init_callback)
	-- initial states
	MainLogin.state = {
		reg_user = {},
	};
	self.init_callback = init_callback;

	-- in case there are background asset.
	NPL.load("(gl)script/kids/3DMapSystemApp/Assets/AsyncLoaderProgressBar.lua");
	Map3DSystem.App.Assets.AsyncLoaderProgressBar.CreateDefaultAssetBar(true);

	NPL.load("(gl)script/apps/Aries/Login/UserLoginProcess.lua");
	UserLoginProcess = UserLoginProcess or commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");
	
	-- register external functions for each login step. Each handler's first parameter is MainLogin class instance. 
	-- TODO: add your custom handlers here. 
	self.handlers = self.handlers or {
		-- select which game version to use
		SelectGameVersion = self.SelectGameVersion,
		-- update the core ParaEngine and minimal art assets. The logo page is also displayed here. 
		UpdateCoreClient = self.UpdateCoreClient,
		-- load the background 3d scene
		LoadBackground3DScene = self.LoadBackground3DScene,
		RebootClient = self.RebootClient,
		StartAssetSync = self.StartAssetSync,
		-- select a user login platform like taomee, facebook, qq, etc.
		SelectPlatform = self.SelectPlatform,
		-- select a locally saved user account to login
		SelectLocalUser = self.SelectLocalUser,
		-- Load buildin packages and mod
		LoadPackages = self.LoadPackages,
		-- the login page
		ShowLoginPage = self.ShowLoginPage,
		-- the registration page
		ShowRegPage = self.ShowRegPage,
		-- establish the first rest connection with the initial gateway game server. 
		ConnectRestGateway = UserLoginProcess.Proc_ConnectRestGateway,
		-- verify product version
		VerifyProductVersion = self.Proc_VerifyProductVersion,
		-- select user nid
		SelectUserNid = self.SelectUserNid,
		-- Establish connection with the default gateway game server; and authenticate the user and establish jabber connection. 
		AuthUser = UserLoginProcess.Proc_Authentication,
		-- register the user
		RegUser = UserLoginProcess.Proc_Registration,
		-- show the confirm page
		RegUserConfirm = self.ShowRegConfirmPage,
		-- if AuthUser returns msg.isreg is false, we will needs to trigger this one before proceding to next step. 
		CreateNewAvatar = self.CreateNewAvatar,
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
		-- Clean Cache
		CleanCache = UserLoginProcess.Proc_CleanCache,
		-- GameTutorial 
		GameTutorial = self.Proc_GameTutorial,
		-- pick a world server
		SelectWorldServer = self.SelectWorldServer,
		-- connect main world
		LoadMainWorld = self.LoadMainWorld,
	}
	self:next_step();
	
end

-- invoke a handler 
function MainLogin:Invoke_handler(handler_name)
	if(self.handlers and self.handlers[handler_name]) then
		LOG.std("", "system","Login", "=====>Login Stage: %s", handler_name);
		self.handlers[handler_name](self);
	else
		LOG.std("", "error","Login", "error: unable to find login handler %s", handler_name);
	end
end

-- perform next step. 
-- @param state_update: This can be nil, it is a table to modify the current state. such as {IsLocalUserSelected=true}
function MainLogin:next_step(state_update)
	local state = self.state;
	if(state_update) then
		if(state_update.IsRestGatewayConnected == false) then	
			state.IsProductVersionVerified = nil
			state.IsUserNidSelected = nil
			state.IsRegUserRequested = nil
			state.IsRegUserConfirmRequested = nil
			state.auth_user = nil;
			state_update.IsAuthenticated = false;
		end
		if(state_update.IsAuthenticated == false) then	
			-- if not authenticated, then everything afterwards should be canceled. 
			state.IsUserNidSelected = nil;
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
			state.IsCleanCached = nil;
			state.IsWorldServerSelected = nil;
			state.IsTutorialFinished = nil;
			state.IsLoadMainWorldRequested = nil;
			state.IsLoadTutorialWorldRequested = nil; -- NOT used
			state.IsLoadHomeWorldRequested = nil; -- NOT used
			state.IsWorldConnected = nil;
			if(state.auth_user) then
				state.auth_user.nid2 = nil;
			end
		end
		commonlib.partialcopy(state, state_update);
	end
	if(state.IsRebootRequired) then	
		self:Invoke_handler("RebootClient");
	elseif(not state.IsUpdaterStarted) then	
		self:Invoke_handler("UpdateCoreClient");
	elseif(not state.IsCoreClientUpdated) then	
		return
	elseif(not state.IsPackagesLoaded) then
		self:Invoke_handler("LoadPackages");
	elseif(state.Loaded3DSceneRequested) then
		self:Invoke_handler("LoadBackground3DScene");
	elseif(not state.IsVersionSelected) then	
		self:Invoke_handler("SelectGameVersion");
	elseif(not state.IsInitFuncCalled) then
		if(self.init_callback) then
			self.init_callback();
		end
		self:next_step({IsInitFuncCalled = true});
	elseif(not state.IsAssetSyncStarted) then
		self:Invoke_handler("StartAssetSync");
	elseif(not state.IsPlatformSelected) then
		self:Invoke_handler("SelectPlatform");
	elseif(state.IsRegistrationRequested) then
		self:Invoke_handler("ShowRegPage");
	elseif(not state.IsLocalUserSelected) then
		self:Invoke_handler("SelectLocalUser");
	elseif(not state.IsLoginStarted) then
		state.IsUserNidSelected = false;
		if(state.auth_user) then
			state.auth_user.nid2 = nil;
		end
		self:Invoke_handler("ShowLoginPage");
	elseif(not state.IsRestGatewayConnected) then
		self:Invoke_handler("ConnectRestGateway");	
	elseif(not state.IsProductVersionVerified) then
		self:Invoke_handler("VerifyProductVersion");	
	elseif(not state.IsUserNidSelected) then
		self:Invoke_handler("SelectUserNid");	
	elseif(state.IsRegUserRequested) then		
		self:Invoke_handler("RegUser");	
	elseif(state.IsRegUserConfirmRequested) then		
		self:Invoke_handler("RegUserConfirm");	
			
	elseif(not state.IsAuthenticated) then	
		self:Invoke_handler("AuthUser");
	elseif(not state.IsFriendsVerified) then
		self:Invoke_handler("VerifyFriends");		
	elseif(not state.IsGlobalStoreSynced) then
		self:Invoke_handler("SyncGlobalStore"); -- move the sync global store process before create avatar
	elseif(not state.IsExtendedCostSynced) then
		self:Invoke_handler("ExtendedCostTemplate");
	elseif(state.IsAvatarCreationRequested) then		
		self:Invoke_handler("CreateNewAvatar");
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
	elseif(not state.IsCleanCached) then
		self:Invoke_handler("CleanCache");
	elseif(not state.IsJabberInited) then
		self:Invoke_handler("InitJabber");
	elseif(not state.IsTutorialFinished) then	
		self:Invoke_handler("GameTutorial");
	elseif(not state.IsWorldServerSelected) then
		self:Invoke_handler("SelectWorldServer");
	elseif(state.IsLoadMainWorldRequested and state.load_world_params) then		
		self:Invoke_handler("LoadMainWorld");
	end
end

function MainLogin.ShowAlmightyGovernment()
	local s = string.format([[<div style="margin:30px;">%s系统维护中，请稍后再试</div>]],MyCompany.Aries.ExternalUserModule:GetConfig().product_name or "魔法哈奇")
	_guihelper.MessageBox(s, function()
		ParaGlobal.ExitApp()
	end, _guihelper.MessageBoxButtons.OK);
end

-- call this before any UI is drawn
function MainLogin:AutoAdjustUIScalingForTouchDevice(callbackFunc)
	if(System.options.IsTouchDevice) then
		NPL.load("(gl)script/ide/System/Windows/Screen.lua");
		local Screen = commonlib.gettable("System.Windows.Screen");

		local function AutoAdjustUIScaling_()
			local touch_ui_height = 560;
			local frame_size = ParaEngine.GetAttributeObject():GetField("ScreenResolution", {960,560});
			local frame_height = frame_size[2];
			if(frame_height == 0) then
				frame_height = Screen:GetHeight();
				LOG.std(nil, "error", "TouchDevice", "ScreenResolution not implemented");
			end
			LOG.std(nil, "info", "TouchDevice", {frame_size, ui_height = Screen:GetHeight()});
			scaling = frame_height / touch_ui_height;
			if(scaling ~= 1) then	
				LOG.std(nil, "info", "TouchDevice", "set UIScale to %s for TouchDevice", scaling);
				ParaUI.GetUIObject("root"):SetField("UIScale", {scaling, scaling});
			end
		end

		NPL.load("(gl)script/ide/timer.lua");
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(Screen:GetWidth() > 0) then
				timer:Change();
				
				AutoAdjustUIScaling_();

				if(callbackFunc) then
					callbackFunc();
				end

				Screen:Connect("sizeChanged", function(width, height)
					AutoAdjustUIScaling_();
				end);
			end
		end})
		mytimer:Change(0,300);
	end
end

-- login handler
function MainLogin:LoadBackground3DScene()
	self:AutoAdjustUIScalingForTouchDevice(function()
		
	end);

	if(self.state.login_bg_worldpath) then
		local world
		Map3DSystem.UI.LoadWorld.LoadWorldImmediate(self.state.login_bg_worldpath, true, true, function(percent)
				if(percent == 100) then
					local worldpath = ParaWorld.GetWorldDirectory();

					-- leave previous block world.
					ParaTerrain.LeaveBlockWorld();

					if(commonlib.getfield("MyCompany.Aries.Game.is_started")) then
						-- if the MC block world is started before, exit it. 
						NPL.load("(gl)script/apps/Aries/Creator/Game/main.lua");
						local Game = commonlib.gettable("MyCompany.Aries.Game")
						Game.Exit();
					end

					-- we will load blocks if exist. 
					if(	ParaIO.DoesAssetFileExist(format("%sblockWorld.lastsave/blockTemplate.xml", worldpath), true) or
						ParaIO.DoesAssetFileExist(format("%sblockWorld/blockTemplate.xml", worldpath), true) ) then	

						NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
						local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
						GameLogic.StaticInit(1);
					end

					-- block user input
					ParaScene.GetAttributeObject():SetField("BlockInput", true);
					--ParaCamera.GetAttributeObject():SetField("BlockInput", true);

					-- MyCompany.Aries.WorldManager:PushWorldEffectStates({ bUseShadow = true, bFullScreenGlow=true})

					-- replace main character with dummy
					local player = ParaScene.GetPlayer();
					player:ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", "character/common/dummy/elf_size/elf_size.x"));
					player:SetDensity(0); -- make it flow in the air
					--ParaScene.GetAttributeObject():SetField("ShowMainPlayer", false);
				end
			end)
	end	
	self:next_step({Loaded3DSceneRequested = false});
end

-- login handler
function MainLogin:UpdateCoreClient()
	if(not System.options.isAB_SDK and System.options.isKid) then
		local attr = ParaEngine.GetAttributeObject();
		local procName = string.lower(attr:GetField("ProcessName", ""));
		
		if(attr:GetField("AppCount", 0)>3) then
			_guihelper.MessageBox("只允许同时运行3个客户端， 您超出了!", function()
				ParaGlobal.Exit(0);
			end)
			return;
		end
		if(procName ~="" and procName ~= "paraengineclient.exe") then
			_guihelper.MessageBox("进程名被修改了", function()
				ParaGlobal.Exit(0);
			end)
			return;
		end
	end

	if(not self.state.IsInitFuncCalled) then
		if(System.options.isKid ~= nil) then
			if(self.init_callback) then
				self.init_callback();
			end
			self:next_step({IsInitFuncCalled = true});
			return;
		end
	end

	self:next_step({IsUpdaterStarted = true});

	-- self:next_step({IsCoreClientUpdated = true});
	-- display the local LocalUserSelectPage.html
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Login/ClientUpdaterPage.html", 
		name = "ClientUpdaterPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		allowDrag = false,
		directPosition = true,
			align = "_ct",
			x = -960/2,
			y = -560/2,
			width = 960,
			height = 560,
		cancelShowAnimation = true,
	});

	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = ExternalUserModule:GetConfig().logo_bottom_banner_page.."?showcopyright=true&showtoplogo=true"..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "", "&showbg=false"), 
		name = "LogoBottomBannerPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = false,
		zorder = -1,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
		cancelShowAnimation = true,
	});
end

-- select which game version to use: kids or teen
function MainLogin:SelectGameVersion()
	-- local test_me = System.options.isAB_SDK;

	if(System.options.isKid == nil) then
		-- directly proceed to next step. 
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Login/VersionSelectPage.html", 
			name = "VersionSelectPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 0,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
					x = -480/2,
					y = -86,
					width = 480,
					height = 256,
		});
		-- change the background banner page. 
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = ExternalUserModule:GetConfig().logo_bottom_banner_page.."?showcopyright=true&showtoplogo=true"..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "","&showbg=false"), 
			name = "LogoBottomBannerPage", 
			click_through = true,
		});
	else
		self:next_step({IsVersionSelected = true});
	end
end

-- display the solve network issue dialog. if we are unable to connect. 
function MainLogin:OnSolveNetworkIssue()
	if(System.options.version == "kids") then
		local new_port = GameServer.rest.client:get_login_server_port2();
		if(new_port) then
			System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/Login/SolveNetworkIssue.html", 
					name = "SolveNetworkIssue", 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					style = CommonCtrl.WindowFrame.ContainerStyle,
					-- isTopLevel = true,
					zorder = 10,
					allowDrag = false,
					directPosition = true,
						align = "_ct",
							x = -600/2,
							y = -400/2,
							width = 600,
							height = 400,
				});
		else
			LOG.std("", "warn", "MainLogin", "no secondary port to connect to.");
		end
	end
end


-- TODO: login handler
function MainLogin:RebootClient()
	self.state.IsRebootRequired = nil;
	-- ParaEngine.exit();
end

-- get the default ip address. 
function MainLogin:StartAssetSync()
	-- play background music 
	if(System.options.version == "kids" or System.options.IsMobilePlatform) then
	else
		-- enable background music
		System.options.EnableBackgroundMusic = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableBackgroundMusic",true, true);
		NPL.load("(gl)script/apps/Aries/Scene/main.lua");
		local Scene = commonlib.gettable("MyCompany.Aries.Scene");
		--Scene.ReplaceBGMusic("Area_61HaqiTown_teen");
	end

	paraworld.whereipfrom({}, "whereipfrom", function(html_node)
		if(html_node) then
			NPL.load("(gl)script/ide/XPath.lua");
			local node = commonlib.XPath.selectNode(html_node, "/html/body");
			if(node and node[1]) then
				System.options.whereipfrom = node[1];
			end
		end
	end)
	self:next_step({IsAssetSyncStarted = true});
end

-- login handler
function MainLogin:ShowRegPage()
	-- send log information
	if (MainLogin.state.IsRegRealnm) then
		paraworld.PostLog({action = "regist_realnm_try"}, "regist_try_log", function(msg)
		end);
	else
		paraworld.PostLog({action = "regist_try"}, "regist_try_log", function(msg)
		end);
	end
	
	UserLoginProcess.ShowProgress();
	
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = ExternalUserModule:GetRegionID();
	-- 2012.8.5: disable in-game registration for taomee user, since we used new interface
	if (region_id~=0) then
		local cfg = ExternalUserModule:GetConfig();
		local url_reg= cfg.registration_url;
		ParaGlobal.ShellExecute("open", url_reg, "", "", 1);
		MainLogin:next_step({IsRegUserConfirmRequested=false, IsRegistrationRequested = false, IsRegUserRequested = false, IsLocalUserSelected=true, IsLoginStarted = false, IsAuthenticated = false});
		return;
	end
	-- change the background banner page. 
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = ExternalUserModule:GetConfig().logo_bottom_banner_page..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "", "&showbg=false"), 
		name = "LogoBottomBannerPage", 
	});

	NPL.load("(gl)script/apps/Aries/Login/UserLoginProcess.lua");
	UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");
	UserLoginProcess.ShowProgress("正在建立连接...", 0);
	realnm = realnm or 0;

	UserLoginProcess.LoadDefaultGatewayServer();
	local max_retry_count = 2;
	local cur_retry_count = 0;
	if(paraworld.use_game_server) then	
		local function StartConnect_()
			LOG.std("", "system", "Login", "RegInHaqi try connecting to game server the %d times", cur_retry_count+1);
			-- set redirecting to true to prevent disconnection message box to appear. 
			System.User.IsRedirecting = true;
			local res = GameServer.rest.client:start(System.options.clientconfig_file, 0, function(msg)
				if(msg and msg.connected) then
					UserLoginProcess.ShowProgress();
					local msg={};
					paraworld.users.GetRegVeriCode(msg,"GetRegVeriCode",function (msg)
						if(msg.session)then
							local base64_data = msg.valibmp;
					
							local bin_data = commonlib.Encoding.unbase64(base64_data);
							if(bin_data) then
								ParaIO.CreateDirectory("temp/");
								local file = ParaIO.open("temp/last_reg_validation_image.png", "w");
								file:write(bin_data, #bin_data);
								file:close();
								if(System.options.version=="kids") then 
									if (MainLogin.state.IsRegRealnm) then
										System.App.Commands.Call("File.MCMLWindowFrame", {
											url = "script/apps/Aries/Login/TaoMeeRegPage.html?realname_reg=true&session="..msg.session, 
											name = "Aries.TaoMeeRegPage", 
											isShowTitleBar = false,
											allowDrag = false,
											DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
											style = CommonCtrl.WindowFrame.ContainerStyle,
											zorder = 20,
											directPosition = true,
											enable_esc_key = true,
											align = "_ct",
											x = -900/2,
											y = -600/2,
											width = 800,
											height = 600,
										});
									else
										System.App.Commands.Call("File.MCMLWindowFrame", {
											url = "script/apps/Aries/Login/TaoMeeRegPage.html?session="..msg.session, 
											name = "Aries.TaoMeeRegPage", 
											isShowTitleBar = false,
											allowDrag = false,
											DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
											style = CommonCtrl.WindowFrame.ContainerStyle,
											zorder = 10,
											directPosition = true,
											enable_esc_key = true,
											align = "_ct",
											x = -900/2,
											y = -600/2,
											width = 800,
											height = 600,
										});
									end
								else
									if (MainLogin.state.IsRegRealnm) then
										System.App.Commands.Call("File.MCMLWindowFrame", {
											url = "script/apps/Aries/Login/TaoMeeRegPage.teen.html?realname_reg=true&session="..msg.session, 
											name = "Aries.TaoMeeRegPage", 
											isShowTitleBar = false,
											allowDrag = false,
											DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
											style = CommonCtrl.WindowFrame.ContainerStyle,
											zorder = 10,
											directPosition = true,
											enable_esc_key = true,
											align = "_ct",
											x = -900/2,
											y = -600/2,
											width = 800,
											height = 600,
										});
									else
										System.App.Commands.Call("File.MCMLWindowFrame", {
											url = "script/apps/Aries/Login/TaoMeeRegPage.teen.html?session="..msg.session, 
											name = "Aries.TaoMeeRegPage", 
											isShowTitleBar = false,
											allowDrag = false,
											DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
											style = CommonCtrl.WindowFrame.ContainerStyle,
											zorder = 10,
											directPosition = true,
											enable_esc_key = true,
											align = "_ct",
											x = -900/2,
											y = -600/2,
											width = 800,
											height = 600,
										});
									end

								end
								return;
							end
						end
					end);					
					
				else
					if(cur_retry_count<max_retry_count) then
						cur_retry_count = cur_retry_count + 1;						
						UserLoginProcess.ShowProgress(string.format("正在建立连接...(第%d次尝试)", cur_retry_count+1), 0);
						StartConnect_();
					else
						System.User.IsRedirecting = true;
						UserLoginProcess.Fail([[<div style="margin-left:24px;margin-top:32px;">服务器的链接无法建立, 请稍候再试</div>]], {IsRestGatewayConnected = false, IsLoginStarted=false, IsUserSelected= false, IsRegistrationRequested=false, IsLocalUserSelected=false}, function()
							MainLogin:OnSolveNetworkIssue();
						end);
					end	
				end
			end)
			if( res ~= 0) then
				UserLoginProcess.Fail("服务器的链接无法建立",{IsRestGatewayConnected = false, IsLoginStarted=false, IsUserSelected= false, IsRegistrationRequested=false, IsLocalUserSelected=false}, function()
					MainLogin:OnSolveNetworkIssue();
				end);
			end
		end
		StartConnect_();
	end
						
	--commonlib.echo("========reg try====");
	--commonlib.echo(MainLogin.state);
end

-- login handler
function MainLogin:ShowRegConfirmPage()
	UserLoginProcess.ShowProgress();

	-- display the local registration confirm page
	if(System.options.version=="kids") then 
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Login/TaoMeeRegConfirmPage.html", 
			name = "TaoMeeRegPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -960/2,
				y = -560/2,
				width = 960,
				height = 560,
			cancelShowAnimation = true,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Login/TaoMeeRegConfirmPage.teen.html", 
			name = "TaoMeeRegPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -900/2,
				y = -600/2,
				width = 800,
				height = 560,
			cancelShowAnimation = true,
		});
	end
end

-- let the user select a platform
function MainLogin:SelectPlatform()
	LOG.std("", "system", "MainLogin", "select user platform");
	
	-- if the application root directory contains "platform.txt"  file, we will show the selection page. 
	if(System.options.platform_id and System.options.platform_id>0) then
		-- show the login page. 
		self:next_step({IsPlatformSelected = true, IsLocalUserSelected = true});

	elseif( #(System.options.platforms) > 1 and not System.options.login_tokens) then
		-- change the background banner page. 
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = ExternalUserModule:GetConfig().logo_bottom_banner_page.."?showtoplogo=true&showcopyright=true"..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "", "&showbg=false"), 
			name = "LogoBottomBannerPage", 
		});

		NPL.load("(gl)script/apps/Aries/Partners/PartnerSelectionPage.lua");
		local PartnerSelectionPage = commonlib.gettable("MyCompany.Aries.Partners.PartnerSelectionPage");
		PartnerSelectionPage.ShowPage(nil, function(platform_id) 
			System.options.platform_id = platform_id;
			if(not platform_id) then
				self:next_step({IsPlatformSelected = true});
			else
				-- show the login page. 
				self:next_step({IsPlatformSelected = true, IsLocalUserSelected = true});
			end
		end);
	else
		self:next_step({IsPlatformSelected = true});
	end
end

-- call this before any UI is drawn
function MainLogin:AutoAdjustUIScalingForTouchDevice()
	if(System.options.IsTouchDevice) then
		NPL.load("(gl)script/ide/System/Windows/Screen.lua");
		local Screen = commonlib.gettable("System.Windows.Screen");

		NPL.load("(gl)script/ide/timer.lua");
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(Screen:GetWidth() > 0) then
				timer:Change();
				
				local touch_ui_height = 560;
				local frame_size = ParaEngine.GetAttributeObject():GetField("ScreenResolution", {960,560});
				local frame_height = frame_size[2];
				scaling = frame_height / touch_ui_height;
				if(scaling ~= 1) then	
					ParaUI.GetUIObject("root"):SetField("UIScale", {scaling, scaling});
				end
			end
		end})
		mytimer:Change(0,300);
	end
end


-- only used to scaling the UI for mobile version, so that UI is as large as possible.
function MainLogin:AdjustUIScaling()
	self:AutoAdjustUIScalingForTouchDevice();

	-- this is old code
--	if(System.options.IsMobilePlatform and not System.options.mc) then
--		-- 1 is the smallest, which is always the min_ui_height
--		local value = 1; 
--		if(value) then
--			local scaling;
--			local min_ui_height = 560;
--			if(value >= 1 and value <= 10) then
--				local ui_height = value*min_ui_height;
--				local frame_size = ParaEngine.GetAttributeObject():GetField("ScreenResolution", {960,560});
--				local frame_height = frame_size[2];
--				scaling = frame_height / ui_height;
--			else
--				scaling = 1;
--			end
--			ParaUI.GetUIObject("root"):SetField("UIScale", {scaling, scaling});
--		end
--	end
end

-- login handler
function MainLogin:SelectLocalUser()

	self:AdjustUIScaling();
	LOG.std("", "system", "MainLogin", "isKids version is %s", tostring(System.options.isKid));

	-- TODO: very dirty code
	-- overwrite the System.UI.CCS.ApplyCCSInfoString function
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	-- needs to read from config/LocalUsers.table
	NPL.load("(gl)script/apps/Aries/Login/LocalUserSelectPage.lua");
	local local_user_count = MyCompany.Aries.LocalUserSelectPage:LoadFromFile();

	-- 2010/5/5 instant login 
	-- if the following file exist the login process will use the username and password in the file to process instant login
	if(ParaIO.DoesFileExist("temp/instant_login/username", true) == true) then
		local_user_count = 0;
	end
	
	if(local_user_count and local_user_count>0 and not System.options.login_tokens) then
		-- display the local LocalUserSelectPage.html
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = if_else(System.options.version=="kids",  "script/apps/Aries/Login/LocalUserSelectPage.html", "script/apps/Aries/Login/LocalUserSelectPage.teen.html"), 
			name = "LocalUserSelectPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 0,
			click_through = true,
			allowDrag = false,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			cancelShowAnimation = true,
		});
		
		-- change the background banner page. 
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = ExternalUserModule:GetConfig().logo_bottom_banner_page.."?showtoplogo=true&showcopyright=true"..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "", "&showbg=false"), 
			name = "LogoBottomBannerPage", 
		});
		
		if(MyCompany.Aries.MainLogin.startup_msg) then
			local startup_msg = MyCompany.Aries.MainLogin.startup_msg;
			if(type(startup_msg) == "string" ) then
				_guihelper.MessageBox(startup_msg);
			elseif(type(startup_msg) == "table" and startup_msg.autorecover) then
				paraworld.PostLog({action = "user_disconnect_tip", msg="Proc_Disconnect"}, "user_disconnect_log", function(msg)
				end);
				_guihelper.MessageBox([[掉线了. 重新登录之前的服务器？]], function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						_guihelper.CloseMessageBox(true); -- fast close without animation
						-- pressed YES
						local user_info = MyCompany.Aries.LocalUserSelectPage.SearchUser(tostring(startup_msg.last_user_nid));
						if(user_info) then
							if(user_info.user_nid and user_info.password) then
								MyCompany.Aries.LocalUserSelectPage.CloseWindow();
								MainLogin:next_step({IsLocalUserSelected = true, local_user = user_info, IsLoginStarted=true, 
										auth_user = {username=user_info.user_nid, password=user_info.password, rememberpassword=true, rememberusername=true,},
										gateway_server={nid = tostring(startup_msg.gs_nid), },
										IsWorldServerSelected = true, 
										IsLoadMainWorldRequested=true, 
										load_world_params = {
											gs_nid = startup_msg.gs_nid, 
											ws_id = startup_msg.ws_id,
											ws_text = startup_msg.ws_text,
											ws_seqid = startup_msg.ws_seqid,
										},
									});
							else
								MyCompany.Aries.LocalUserSelectPage.OnSelectUser(startup_msg.last_user_nid);
							end
						end
					else
						MyCompany.Aries.MainLogin.startup_msg = nil;
					end
				end, _guihelper.MessageBoxButtons.YesNo);
			end
			MyCompany.Aries.MainLogin.startup_msg = nil;
		end
	else
		self:next_step({IsLocalUserSelected = true});	
	end	
	
	if(not ParaIO.DoesFileExist("perf.txt")) then
		-- send log information
		paraworld.PostLog({action = "startup_with_empty_perf"}, "startup_with_empty_perf_log", function(msg)
		end);
		-- create a new perf.txt file, if it doesn't exist
		-- in order to allow backward compatible with environments that has already run
		-- we use the perf.txt file existence to check if the user has run the engine at least once.
		-- NOTE 2010/1/25: this is little tricky: the engine will generate an empty perf.txt on close if doesn't exist
		--		we generate the empty perf.txt in script
		ParaIO.CreateNewFile("perf.txt");
	end
end

-- let the user select user nid. 
function MainLogin:SelectUserNid()
	local values = self.state.auth_user;
	if(System.options.login_tokens) then
		local tokens = System.options.login_tokens;

		values = values or {};
		values.oid = tokens.oid;
		values.token = tokens.token;
		values.time = tokens.time;
		values.oid = tokens.oid;
		values.website = tokens.website;
		values.sid = tokens.sid;
		values.game = tokens.game;
	end
	
	if(values and values.oid and values.token and not values.nid2) then
		UserLoginProcess.ShowProgress("获取角色列表...");
		
		-- TODO: load user
		NPL.load("(gl)script/apps/Aries/Pet/main.lua");
		-- needs to read from config/LocalUsers.table
		NPL.load("(gl)script/apps/Aries/Login/LocalUserSelectPage.lua");
		local local_user_count = MyCompany.Aries.LocalUserSelectPage:LoadFromFile();

		paraworld.users.GetNIDByOtherAccountID({plat = values.plat, oid = values.oid}, "GetNIDByOtherAccountID", function(msg)
			LOG.std(nil, "debug", "GetNIDByOtherAccountID.result", msg);
			if(msg and msg.nid) then
				local all_user_nids = {};
				local nid_;
				for nid_ in string.gmatch(tostring(msg.nid), "([^,]+)") do
					nid_ = tonumber(nid_);
					if(nid_ and nid_~=-1) then
						all_user_nids[#all_user_nids+1] = nid_;
					end
				end
				-- TODO: for testing. remove when api is fixed. 
				--if(values.oid == "83CDEA7F989E0CAF28B47EA07763D23A" and #all_user_nids == 0) then
					--all_user_nids[1] = 800008;
					--all_user_nids[2] = 800013;
					--all_user_nids[3] = 800012;
					--all_user_nids[4] = 800011;
					--all_user_nids[5] = 800010;
					--all_user_nids[6] = 800009;
				--end
				
				--if(#all_user_nids == 0) then
                --NOTE by leio:Must show AccountUserSelectPage
				if(false) then
					-- create the first user
					local params = {
						userName = values.username,
						password = values.password,
						plat = values.plat,
						token = values.token,
						key = values.key,
						time = values.time,
						oid = values.oid,
						website = values.website,
						sid = values.sid,
						game = values.game,
					};
					UserLoginProcess.ShowProgress("创建第一个角色...");
					paraworld.users.Registration(params, "Register", function(msg)
						if(msg and msg.nid) then
							-- send log information
							paraworld.PostLog({reg_nid = tostring(msg.nid), action = "regist_success"}, "regist_success_log", function(msg) end);
							values.nid2 = tonumber(msg.nid);
							self:next_step({IsUserNidSelected = true});
						else
							LOG.std("", "error","Login", "Registration failed");
							UserLoginProcess.Fail("无法创建角色");
						end
					end, nil, 20000, function(msg)
						-- timeout request
						LOG.std("", "error","Login.Registration.timeout", msg);
						UserLoginProcess.Fail("无法创建角色");
					end)

				else
					-- hide progress UI
					UserLoginProcess.HideProgressUI();
					NPL.load("(gl)script/apps/Aries/Login/AccountUserSelectPage.lua");
					MyCompany.Aries.AccountUserSelectPage.ShowPage(all_user_nids, values, function(user_nid)
						if(user_nid) then
							values.nid2 = tonumber(user_nid);
							self:next_step({IsUserNidSelected = true});
						else
							self:next_step({IsAuthenticated = false, IsLoginStarted = false});
						end
					end);
				end
			end
		end, nil, 20000, function(msg)
			-- timeout request
			LOG.std("", "error","Login.GetNIDByOtherAccountID.timeout", msg);
			UserLoginProcess.Fail("无法获取角色列表");					
		end)
	else
		-- no need to select user nid.
		self:next_step({IsUserNidSelected = true});
	end
end

-- load predefined mod packages if any
function MainLogin:LoadPackages()
	NPL.load("(gl)script/apps/Aries/Creator/Game/Login/BuildinMod.lua");
	local BuildinMod = commonlib.gettable("MyCompany.Aries.Game.MainLogin.BuildinMod");
	BuildinMod.AddBuildinMods();

	NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
    local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
    GameLogic.InitMod();

	NPL.load("(gl)script/apps/Aries/Creator/Game/mcml/pe_mc_mcml.lua");
	MyCompany.Aries.Game.mcml_controls.register_all();

	self:next_step({IsPackagesLoaded = true});
end

-- login handler
function MainLogin:ShowLoginPage()
	-- change the background banner page. 
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = ExternalUserModule:GetConfig().logo_bottom_banner_page.."?showcopyright=true&showtoplogo=true"..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "", "&showbg=false"), 
		name = "LogoBottomBannerPage", 
	});

	-- now implement the server-size pushed login news page. 
	local xmlRoot = System.SystemInfo.GetField("login_news_page_data");
	if(xmlRoot) then
		local config = commonlib.XPath.selectNodes(xmlRoot, "//haqi:config")[1];
		local attr = {};
		if(config and config.attr) then
			attr = config.attr;
		end
		local mcml_root = commonlib.XPath.selectNodes(xmlRoot, "//pe:mcml")[1];
		if(mcml_root) then
			NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
			local page = Map3DSystem.mcml.PageCtrl:new({url=""});
			
			local uiobject = page:Create("login_news_page", nil, "_fi", 0, 0, 0, 0);
			uiobject.zorder = tonumber(attr.zorder) or 10; -- make it stand out
			page:Goto(xmlRoot);
		end
		
		if(attr.can_login == "false") then
			if(attr.show_mcml ~= "true") then
				_guihelper.MessageBox(attr.reason or "服务器维护中", function()
					-- 服务器维护时，返回到登录界面
					Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
					--NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
					-- MyCompany.Aries.Desktop.Dock.DoExit(true);
				end, _guihelper.MessageBoxButtons.OK);
			end
			return;
		end
	end
	
	-- display the local UserLoginPage.html
	if(not System.options.platform_id) then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = if_else(System.options.version=="kids", "script/apps/Aries/Login/UserLoginPage.html", "script/apps/Aries/Login/UserLoginPage.teen.html"),
			name = "UserLoginPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 0,
			click_through = true,
			allowDrag = false,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			cancelShowAnimation = true,
		});
	else
		local function OnProcessResult(result)
			LOG.std(nil, "debug", "platform.login.result", result);
			if(result.errorcode) then
				_guihelper.MessageBox("认证失败了, 请重新尝试");
				self:next_step({IsPlatformSelected = false, IsLocalUserSelected = false});

			elseif(result.uid and result.token and tonumber(result.plat)) then
				local url_cmdParams = result;
				local _plat = tonumber(url_cmdParams.plat); -- 平台ID，1:Facebook；2:QQ
				-- _guihelper.MessageBox(url_cmdParams.nid);
				local all_user_nids = {};
				local nid_;
				for nid_ in string.gmatch(tostring(url_cmdParams.nid), "([^,]+)") do
					nid_ = tonumber(nid_);
					if(nid_ and nid_~=-1) then
						all_user_nids[#all_user_nids+1] = nid_;
					end
				end
				local _uid = url_cmdParams.uid; -- 平台的用户ID，如QQ的OpenID，Facebook的EMail.....
				local _token = url_cmdParams.token; -- 平台的认证凭证
				local _appid = url_cmdParams.app_id; -- 平台的AppID
				
				self:next_step({IsLoginStarted=true, auth_user = {
					username=_uid, password="placeholder", 
					plat = _plat,  appid = _appid,
					loginplat = 1,
					-- use the first user to login, 
					-- nid2 = all_user_nids[1],
					oid = _uid,
					token = _token,
					rememberpassword=false, rememberusername=true}});
			else
				self:next_step({IsPlatformSelected = false, IsLocalUserSelected = false});
			end
		end
		Platforms.SetPlat(System.options.platform_id);

		_guihelper.MessageBoxClass.CheckShow(function() 
			-- TODO: if it is inn full screen mode. To window mode first. 
			Platforms.show_login_window(OnProcessResult)
		end);
	end

	if(MyCompany.Aries.MainLogin.startup_msg) then
		if(type(MyCompany.Aries.MainLogin.startup_msg) == "string" ) then
			_guihelper.MessageBox(MyCompany.Aries.MainLogin.startup_msg);
		elseif(type(MyCompany.Aries.MainLogin.startup_msg) == "table" ) then
			-- this should not happen in most cases. 
		end
		MyCompany.Aries.MainLogin.startup_msg = nil;
	end
end

-- return true if server should be closed. 
function MainLogin:CheckServerOpenningTime()
	local teen_20120430_test = true;
	if(teen_20120430_test and System.options.version == "teen" and System.options.locale == "zhCN") then
		if(not System.options.isAB_SDK) then
			NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
			local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
			local isHoliday = AntiIndulgenceArea.IsInHoliday();
			---------------------------
			-- NOTE:  ALWAY isHoliday
			---------------------------
			--isHoliday = true;

			NPL.load("(gl)script/apps/Aries/Scene/main.lua");
			local Scene = commonlib.gettable("MyCompany.Aries.Scene");
			local time = Scene.GetElapsedSecondsSince0000();

			local bCanPass = true;

			if(isHoliday) then
				if(not time or (time < 6 * 60 * 60 and time > 2 * 60 * 60) ) then
					bCanPass = false;
				end
			else
				if(not time or (time < 6 * 60 * 60 and time > 2 * 60 * 60)) then
					bCanPass = false;
				end
			end

			if(ParaIO.DoesFileExist("character/Animation/script/pubchk.lua", false)) then
				bCanPass = true;
			end
			
			if(bCanPass == false) then
    		    _guihelper.MessageBox([[开服时间:<br/>每天上午6:00 -- 凌晨2:00]], function()
					ParaGlobal.ExitApp();
				end);
				return true;
			end
		end
	end
end

-- login handler: the user has not finished with avatar creation, so display the page. 
function MainLogin:CreateNewAvatar()
	if(self:CheckServerOpenningTime()) then
		return;
	end
	--paraworld.ShowMessage("正在获取人物化身信息");
	-- NOTE by andy 2009/8/18: check the inventory system bag for register information
	local ItemManager = System.Item.ItemManager;
	System.Item.ItemManager.GetItemsInBag(0, "Proc_CheckNewAvatar", function(msg)
		if(msg and msg.items) then
			local count = ItemManager.GetItemCountInBag(0);
			local isNewAvatarCreated = false;
			local i;
			for i = 1, count do
				local item = ItemManager.GetItemByBagAndOrder(0, i);
				if(item ~= nil and item.guid > 0) then
					if(item.gsid == 999) then
						isNewAvatarCreated = true;
						break;
					end
				end
			end
			local isDragonSelected = false;
			local hasGSItem = ItemManager.IfOwnGSItem;
			if(isNewAvatarCreated) then
				-- check if choose dragon color: 
				-- 11009_DragonBaseColor_Purple
				-- 11010_DragonBaseColor_Orange
				-- 11011_DragonBaseColor_Green
				isDragonSelected = (hasGSItem(11009) or hasGSItem(11010) or hasGSItem(11011) or hasGSItem(11012));
			end

			if(not isDragonSelected or not isNewAvatarCreated) then
				UserLoginProcess.TrySaveUserInfo();	
			end
			
			-----------------------------------------
			-- NOTE: this is a flag for debugging page
			-----------------------------------------
			 --isNewAvatarCreated = false;
			 --isDragonSelected = false;

			if(isDragonSelected) then
				-- continue if avatar and dragon are all selected. 
				MainLogin:next_step({IsAvatarCreationRequested = false});
			elseif(not isNewAvatarCreated) then
				-- clear progress UI
				UserLoginProcess.ShowProgress();
						
				System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {name = "Tutorial",
					on_finish = function()
						-- block user input
						ParaScene.GetAttributeObject():SetField("BlockInput", true);
						-- @Note: set this to false if one wants to rotate camera with mouse during avatar creation. 
						-- ParaCamera.GetAttributeObject():SetField("BlockInput", true); 
						
						MyCompany.Aries.WorldManager:PushWorldEffectStates({ bUseShadow = true, bFullScreenGlow=true})

						-- replace main character with dummy
						local player = ParaScene.GetPlayer();
						player:ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", "character/common/dummy/elf_size/elf_size.x"));
						player:SetFacing(2.7); -- change the default facing here!
						player:SetDensity(0); -- make it flow in the air
						if(System.options.version=="teen") then
							player:SetPhysicsHeight(0);
						end

						---- we only have the avatar info and dragon missing so we start from the license code page
						---- display the local NewAvatarLicensePage.html
						--System.App.Commands.Call("File.MCMLWindowFrame", {
							--url = "script/apps/Aries/Login/NewAvatarLicensePage.html", 
							--name = "NewAvatarPage", 
							--isShowTitleBar = false,
							--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
							--style = CommonCtrl.WindowFrame.ContainerStyle,
							--zorder = 2,
							--allowDrag = false,
							--directPosition = true,
								--align = "_ct",
								--x = -960/2,
								--y = -560/2,
								--width = 960,
								--height = 560,
							--cancelShowAnimation = true,
						--});
						
						-- directly proceed to next step. 
						System.App.Commands.Call("File.MCMLWindowFrame", {
							url = if_else(System.options.version=="kids", "script/apps/Aries/Login/NewAvatarDisplayPage.html", "script/apps/Aries/Login/NewAvatarDisplayPage.teen.html"),
							name = "NewAvatarDisplayPage", 
							isShowTitleBar = false,
							DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
							style = CommonCtrl.WindowFrame.ContainerStyle,
							zorder = 2,
							allowDrag = false,
							directPosition = true,
								align = "_fi",
									x = 0,
									y = 0,
									width = 0,
									height = 0,
							cancelShowAnimation = true,
						});
					end});
			elseif(not isDragonSelected) then
				-- clear progress UI
				UserLoginProcess.ShowProgress();
						
				System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {name = "Tutorial",
					on_finish = function()
						-- block user input
						ParaScene.GetAttributeObject():SetField("BlockInput", true);
						ParaCamera.GetAttributeObject():SetField("BlockInput", true);
						MyCompany.Aries.WorldManager:PushWorldEffectStates({ bUseShadow = true, bFullScreenGlow=true})

						-- replace main character with dummy
						local player = ParaScene.GetPlayer();
						player:ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", "character/common/dummy/elf_size/elf_size.x"));
						player:SetFacing(2.7); -- change the default facing here!

						-- we only have the avatar info and dragon missing so we start from the license code page
						-- display the local NewAvatarLicensePage.html
						System.App.Commands.Call("File.MCMLWindowFrame", {
							url = if_else(System.options.version=="kids", "script/apps/Aries/Login/NewAvatarFinishPage.html", "script/apps/Aries/Login/NewAvatarFinishPage.teen.html"),
							name = "NewAvatarPage", 
							isShowTitleBar = false,
							DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
							style = CommonCtrl.WindowFrame.ContainerStyle,
							zorder = 2,
							allowDrag = false,
							directPosition = true,
								align = "_fi",
								x = 0,
								y = 0,
								width = 0,
								height = 0,
							cancelShowAnimation = true,
						});
					end});
			end

		else
			UserLoginProcess.Fail("获取人物化身信息失败，请稍候再试");
			return;
		end
	end, "access plus 0 day");
end

-- login handler
function MainLogin:Proc_GameTutorial()
	-- launch the game tutorial if it is not completed. 
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	
	-- the following gsids stand for the 7 magic classes. If the user has not select one, we will trigger the tutorial. 
	local bIsGameTutorialCompleted = false;
	local classprop_gsid = MyCompany.Aries.Combat.GetSchoolGSID();
	if(classprop_gsid and classprop_gsid > 0) then
		if(classprop_gsid == 986) then
			bIsGameTutorialCompleted = true;
		elseif(classprop_gsid == 987) then
			bIsGameTutorialCompleted = true;
		elseif(classprop_gsid == 988) then
			bIsGameTutorialCompleted = true;
		elseif(classprop_gsid == 989) then
			bIsGameTutorialCompleted = true;
		elseif(classprop_gsid == 990) then
			bIsGameTutorialCompleted = true;
		elseif(classprop_gsid == 991) then
			bIsGameTutorialCompleted = true;
		elseif(classprop_gsid == 992) then
			bIsGameTutorialCompleted = true;
		end
	end

	-- Note: for debugging only, uncomment to force launch tutorial. 
	-- bIsGameTutorialCompleted = false;

	if(bIsGameTutorialCompleted) then
		MainLogin:next_step({IsTutorialFinished = true});
	else
		-- clear progress UI
		UserLoginProcess.ShowProgress();
		local world_info = MyCompany.Aries.WorldManager:GetCurrentWorld()

		NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatTutorialMain.lua");
		local function DoPickSchoolAndTutorial()
			-- start the tutorial
			MyCompany.Aries.Tutorial.CombatTutorialMain.Start(function(msg)  
				-- continue the next step.
				local world_info = MyCompany.Aries.WorldManager:GetWorldInfo("default");
				MainLogin:next_step({IsTutorialFinished = true, login_pos=world_info.login_pos});
			end);
		end
		if(System.options.version == "teen") then
			-- disable standalone tutorial
			MyCompany.Aries.Tutorial.CombatTutorialMain.skip_combat_tutorial = true;
		elseif(System.options.version == "kids") then
			-- disable standalone tutorial
			MyCompany.Aries.Tutorial.CombatTutorialMain.skip_combat_tutorial = true;
		end
		
		if(MyCompany.Aries.Tutorial.CombatTutorialMain.skip_combat_tutorial and world_info and world_info.name == "Tutorial") then
			DoPickSchoolAndTutorial();
		else
			System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
				name = if_else(MyCompany.Aries.Tutorial.CombatTutorialMain.skip_combat_tutorial, "Tutorial", "CombatTutorial"), on_finish = function()
				MyCompany.Aries.WorldManager:PushWorldEffectStates({ bUseShadow = true, bFullScreenGlow=true})
				DoPickSchoolAndTutorial();
			end, });
		end
	end
end

-- login handler
function MainLogin:SelectWorldServer()
	-- just in case, input is blocked due to tutorial.
	ParaScene.GetAttributeObject():SetField("BlockInput", false);
	ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	
	-- removed, now bg is in banner page: manally assign the background in window frame style
	--local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	--style.window_bg = "Texture/Aries/Login/UserSelect_BG2_32bits.png; 0 0 1020 680";

	local bean = MyCompany.Aries.Pet.GetBean();
	local level,rookie;
	if(bean) then
		level = bean.combatlel or 1;
	else
		level = 1;
	end
	if (level <10) then
		rookie="1";
	else
		rookie="0";
	end

	local function ShowSelectPage_(servers)
		if(System.options.version=="kids") then
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/FamilyServer/FamilyServerSelect.html?rookie="..rookie, 
				name = "ServerSelectPage", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				ToggleShowHide = true, 
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				enable_esc_key = false,
				directPosition = true,
					align = "_ct",
					x = -960/2,
					y = -560/2,
					width = 960,
					height = 560,
			});
		else
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/FamilyServer/FamilyServerSelect.teen.html?rookie="..rookie, 
				name = "ServerSelectPage", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				ToggleShowHide = true, 
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				enable_esc_key = false,
				directPosition = true,
					align = "_ct",
					x = -660/2,
					y = -470/2,
					width = 660,
					height = 470,
			});
		end
	end 
	if(System.options.auto_select_server) then
		if(System.options.version == "kids") then
			NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.lua");
		else
			NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.teen.lua");
		end
		local FamilyServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSelect");


		NPL.load("(gl)script/apps/Aries/FamilyServer/ServerSelect.lua");
		local ServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.ServerSelect");
		local level = MyCompany.Aries.Player.GetLevel();
		--if(System.options.mc) then
			---- simulate new user. 
			--level = 1;
		--end

		ServerSelect.AutoSelectServer(level, function(msg)
			if(msg and msg.best_server) then
				FamilyServerSelect.SwitchWorldServer(msg.best_server, nil, function(bSucceed)
					if(not bSucceed) then
						System.options.auto_select_server = false;
						MyCompany.Aries.MainLogin:next_step({IsAuthenticated == false, IsRestGatewayConnected=false, IsLoginStarted = false});
					end
				end);
			else
				ShowSelectPage_();
			end
		end)
	else
		ShowSelectPage_();
	end

	-- change logo page UI. 
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = ExternalUserModule:GetConfig().logo_bottom_banner_page.."?showcopyright=true"..if_else(not ExternalUserModule:GetConfig().login_bg_worldpath, "", "&showbg=false"), 
		name = "LogoBottomBannerPage", 
	});
end

-- login handler
function MainLogin:LoadMainWorld()

	self:next_step({IsLoadMainWorldRequested = false});	
	
	local params = self.state.load_world_params;
	
	-- clear the logo page UI. 
	System.App.Commands.Call("File.MCMLWindowFrame", {
		name = "LogoBottomBannerPage", 
		bDestroy = true,
	});
	
	if(ParaWorld.GetWorldDirectory() ~= params.worldpath) then
		
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
		Map3DSystem.App.HomeLand.HomeLandGateway.Away();

		NPL.load("(gl)script/apps/GameServer/GSL.lua");
		Map3DSystem.GSL_client:LogoutServer(true);

		local has_login_pos;
		local login_pos = self.state.login_pos;

		local user_login_level = 2;
		if( System.options.mc) then
			
			NPL.load("(gl)script/apps/Aries/Creator/Game/main.lua");
			local Game = commonlib.gettable("MyCompany.Aries.Game");
			-- login standalone. 
			Game.Start(MyCompany.Aries.ExternalUserModule:GetConfig().mc_default_world, true);

		elseif( System.options.version == "kids") then
			user_login_level = 10;
			if( (MyCompany.Aries.Player.GetLevel() or 1) <= user_login_level ) then
				if(not params.worldpath and not params.name) then
					-- defaults to "NewUserIsland"
					params.name = "NewUserIsland"
					local world_info = MyCompany.Aries.WorldManager:GetWorldInfo(params.name);
					login_pos = world_info.login_pos;
				end
			end
		else
			-- TODO:
		end

		if( System.options.version == "teen") then
		-- 青年版登录点固定，10级以前在新手村，10级以后在彩虹城
			params.name = "61HaqiTown_teen";
			user_login_level = 10;
			local world_info = MyCompany.Aries.WorldManager:GetWorldInfo(params.name);
			if ((MyCompany.Aries.Player.GetLevel() or 1) < user_login_level) then
				login_pos = world_info.login_pos
			else
				login_pos = world_info.born_pos
			end
		elseif( (MyCompany.Aries.Player.GetLevel() or 1) < user_login_level ) then
			local world_info = MyCompany.Aries.WorldManager:GetWorldInfo(params.name);
			if(not login_pos) then
				login_pos = world_info.login_pos;
				LOG.std(nil, "info", "MainLogin", "we will use login_pos since user level is less than 2");
			end
			if(world_info.new_born_cg) then
				params.cg_movie_file = world_info.new_born_cg;
				LOG.std(nil, "info", "MainLogin", "we will use new_born_cg %s since user level is less than 2", world_info.new_born_cg);
			end
		end

		if(login_pos) then
			has_login_pos = true;
			params.PosX = login_pos.x;
			params.PosY = login_pos.y;
			params.PosZ = login_pos.z;
			params.PosFacing = login_pos.facing;
			params.PosRadius = login_pos.radius;
			params.CameraRotY = login_pos.CameraRotY;
			params.CameraLiftupAngle = login_pos.CameraLiftupAngle;
			params.CameraObjectDistance = login_pos.CameraObjectDistance;
			self.state.login_pos = nil;
		end
		
		if(not MyCompany.Aries.WorldManager:RecoverWorldSession(params)) then
			if(not has_login_pos) then -- skip login pos
				local last_pos = MyCompany.Aries.Player.LoadLocalData("LastPosition", nil);
			
				if(last_pos and last_pos.pos) then
					local world_info = MyCompany.Aries.WorldManager:GetWorldInfo(params.name or last_pos.worldname);
				
					if(world_info.name == last_pos.worldname) then
						params.name = world_info.name;
						params.PosX = last_pos.pos.x or params.PosX;
						params.PosY = last_pos.pos.y or params.PosY;
						params.PosZ = last_pos.pos.z or params.PosZ;
						params.PosFacing = last_pos.pos.facing or params.PosFacing;
						params.PosRadius = nil;
					end
				end
			end

			params.on_finish = function()
				if(System.options.visit_url) then
					-- just in case a visit url is specified. 
					local params = System.options.visit_url;
					System.options.visit_url = nil;
					if(type(params) == "string") then
						local nid, slot_id = params:match("^(%d+)@?(.*)$");
						params = {nid = nid, slot_id=slot_id, exclusive_mode = true};
					end
					System.App.Commands.Call("Profile.Aries.GotoHomeLand", params);
				else
					-- daily checkin. 
					NPL.load("(gl)script/apps/Aries/Login/DailyCheckin.lua");
					local DailyCheckin = commonlib.gettable("MyCompany.Aries.DailyCheckin");
					DailyCheckin.ShowPageIfNotCheckedin();
				end

				NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.lua");
				local NPCTipsPage = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTipsPage");
				if( MyCompany.Aries.Player.GetLevel() == 0) then
					NPCTipsPage.OnLevelup(0);
				end
				
				-- send log information
				paraworld.PostLog({action = "user_enter_community", clientversion = ClientVersion, partner=System.options.partner}, "user_enter_community_log", function(msg) end);
			end;
			System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
		end
	end	
	-- System.App.Commands.Call("File.ConnectAriesWorld");
end

-- NOT used. verify the product version.
function MainLogin.Proc_VerifyProductVersion()
	NPL.load("(gl)script/apps/GameServer/GSL_version.lua");
	local GSL_version = commonlib.gettable("Map3DSystem.GSL.GSL_version");
	UserLoginProcess.ShowProgress("正在检查版本号");
	local from_time = ParaGlobal.timeGetTime();
	-- send log information
	paraworld.auth.Ping({ver=GSL_version.ver}, "checkversion", function(msg)
		LOG.std(nil, "system", "login", "check version %s", commonlib.serialize_compact(msg));
		if(msg) then
			if(msg.ver == GSL_version.ver) then
				local svrtime = msg.srvtime;
				local hh,mm,ss=0,0,0;
				if (svrtime) then
					hh,mm,ss=string.match(svrtime,"(%d+):(%d+):(%d+)");
				end
				if (not System.User.login_time) then
					System.User.login_time=hh*3600+mm*60+ss;			
				end
				MainLogin:next_step({IsProductVersionVerified = true});
				to_time = ParaGlobal.timeGetTime();
				MainLogin.last_ping_interval = to_time-from_time;
				local game_nid = GameServer.rest.client.cur_game_server_nid;
				if(game_nid) then
					NPL.load("(gl)script/apps/Aries/Player/main.lua");
					local Player = commonlib.gettable("MyCompany.Aries.Player");
					local network_latency = Player.LoadLocalData("network_latency", {}, true)
					network_latency[game_nid] = MainLogin.last_ping_interval;
					LOG.std(nil, "info", "network_latency", network_latency);
					Player.SaveLocalData("network_latency", network_latency, true, true);
					MainLogin.network_latency = network_latency;
				end
			else
				UserLoginProcess.Fail(format("你的游戏版本号是%d, 需要的版本号为%d. 请重新登录并更新游戏，如果仍然不行，请重新安装。", GSL_version.ver or 0, msg.ver or 0));
				paraworld.PostLog({action = "user_verify_version_failed", msg=format("user ver %d, server ver %d", GSL_version.ver or 0, msg.ver or 0)}, "user_login_process_stage_progress_log");
			end
		else
			UserLoginProcess.Fail("版本号验证失败");
		end
	end, "access plus 0 day", 10000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("版本号验证超时", {IsRestGatewayConnected = false, IsLoginStarted=false, IsUserSelected= false, IsRegistrationRequested=false, IsLocalUserSelected=false}, function()
			MainLogin:OnSolveNetworkIssue();
		end);
	end);
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
	local function RecoverFailed(reason)
		if(callbackFunc) then
			callbackFunc({connected=false, reason=reason})
		end	
	end
	if(not System.User.IsAuthenticated) then
		LOG.std("", "error","Login", "we can not recover an authenticated connection");
		RecoverFailed();
	end
	
	LOG.std("", "system","Login", "Now trying to recover connection with game server and re-authenticate ...");
	
	System.User.IsRedirecting = true;
	local res = GameServer.rest.client:recover_connection(function(msg)
		if(msg and msg.connected) then
			-- connection is established, we will now authenticate using old credentials. 
			paraworld.auth.AuthUser(Map3DSystem.User.last_login_msg or {
					username = System.User.username,
					password = System.User.Password,
				}, "login", function (msg)
					if(msg==nil) then
						RecoverFailed()
					elseif(msg.issuccess) then	
						-- successfully recovered from connection. 
						LOG.std("", "system","Login", "Successfully recovered connection with game server and re-authenticated");
						if(callbackFunc) then
							callbackFunc({connected=true})
						end	
					else
						RecoverFailed(msg.errorcode)
					end
				end, nil, 10000, function(msg)
					-- timeout request
					RecoverFailed("timeout");
				end)
		else
			RecoverFailed()
		end
	end)
	if( res ~= 0) then
		RecoverFailed()
	end
end