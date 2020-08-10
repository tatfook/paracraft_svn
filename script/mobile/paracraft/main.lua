--[[
Title: paracraft mobile game
Author(s): LiXizhi
Date: 2014/9/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/main.lua");
local App = commonlib.gettable("ParaCraft.Mobile.App")
App.Start();
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/ParaWorldCore.lua"); 
NPL.load("(gl)script/apps/IMServer/IMserver_client.lua");
JabberClientManager = commonlib.gettable("IMServer.JabberClientManager");

System.options.open_resolution = ParaEngine.GetAppCommandLineByParam("resolution",nil);
System.options.IsMobilePlatform = true;
local App = commonlib.gettable("ParaCraft.Mobile.App")

function App:Start()
	_guihelper.MessageBox("")
end

function App:ConfigLuaJit()
	-- turn off luajit since it crashes on some android hardware
	if(jit and jit.version) then
		log("luajit is off since it crashes on some android hardware\n");
		jit.off();
		log(string.format("ParaEngine JIT version:%s status:%s \r\n", tostring(jit.version), tostring(jit.status())));
	end
	--NPL.load("(gl)script/test/TestGUI.lua");
	--TestGUI:test_GUI_SelfPaint();
	--TestGUI:test_gui_OwnerDraw();
	--TestGUI:test_RenderTarget_paint();
end

function App:LoadConfig()
	self:ConfigLuaJit();
	System.options.is_client = true;
	-- this is a MicroCosmos app. 
	System.options.mc = true; 
	
	NPL.load("(gl)script/mobile/API/LocalBridgePBAPI.lua");

	-- language translations
	NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Translation.lua");
	local Translation = commonlib.gettable("MyCompany.Aries.Game.Common.Translation")
	Translation.Init();

	local filename = "config/GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "warning", "aries", "warning: failed loading game server config file %s", filename);
		return;
	end	
	local node;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/asset_server_addresses/address")[1];
	if(node and node.attr) then
		ParaAsset.SetAssetServerUrl(node.attr.host);
		LOG.std("", "system", "aries", "Asset server: %s", node.attr.host)
	end

	-- turn async loading off for initial user interface, it will be turned back on during game play. 
	ParaEngine.GetAttributeObject():GetChild("AssetManager"):SetField("AsyncLoading", false);
	-- give local file priority in asset manifest
	LOG.std(nil, "info", "AssetManifest", "use local file first");
	ParaEngine.GetAttributeObject():GetChild("AssetManager"):SetField("UseLocalFileFirst", true);

	-- load compressed resource file, such as those block templates, etc. 
	ParaAsset.OpenArchive("main_mobile_res.pkg");
end

function App:Init()
	self:LoadConfig();

	main_state = System.init();

	---- get the client version
	NPL.load("(gl)script/apps/Aries/Creator/Game/game_options.lua");
	local options = commonlib.gettable("MyCompany.Aries.Game.GameLogic.options")
	System.options.ClientVersion = options.GetClientVersion();

	NPL.load("(gl)script/mobile/paracraft/DefaultTheme.mobile.lua");
	ParaCraft.Mobile.Theme.Default:Load();

	System.App.Registration.CheckInstallApps({
		{app={app_key="WebBrowser_GUID"}, IP_file="script/kids/3DMapSystemApp/WebBrowser/IP.xml"},
		{app={app_key="worlds_GUID"}, IP_file="script/kids/3DMapSystemApp/worlds/IP.xml"},
		{app={app_key="Debug_GUID"}, IP_file="script/kids/3DMapSystemApp/DebugApp/IP.xml"},
		{app={app_key="Creator_GUID"}, IP_file="script/kids/3DMapSystemUI/Creator/IP.xml"},
		{app={app_key="Aries_GUID"}, IP_file="script/apps/Aries/IP.xml", bSkipInsertDB = true},
	})
	-- change the login machanism to use our own login module
	System.App.Commands.SetDefaultCommand("Login", "Profile.Aries.Login");
	-- change the load world command to use our own module
	System.App.Commands.SetDefaultCommand("LoadWorld", "File.EnterAriesWorld");
	-- change the handler of system command line. 
	System.App.Commands.SetDefaultCommand("SysCommandLine", "Profile.Aries.SysCommandLine");
	-- change the handler of enter to chat. 
	System.App.Commands.SetDefaultCommand("EnterChat", "Profile.Aries.EnterChat");
	-- change the handler of drop files 
	System.App.Commands.SetDefaultCommand("SYS_WM_DROPFILES", "Profile.Aries.SYS_WM_DROPFILES");
	-- change the handler of slate mode settings change
	System.App.Commands.SetDefaultCommand("SYS_WM_SETTINGCHANGE", "Profile.Aries.SYS_WM_SETTINGCHANGE");

	-- some code driven audio files for backward compatible
	AudioEngine.Init();
	-- set max concurrent sounds
	AudioEngine.SetGarbageCollectThreshold(10)
	-- load wave description resources
	AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");
	CommonCtrl.Locale.EnableLocale(false);
	
	NPL.load("(gl)script/apps/Aries/mcml/mcml_aries.lua");
	MyCompany.Aries.mcml_controls.register_all();
	-- mcml v2
	NPL.load("(gl)script/apps/Aries/Creator/Game/mcml2/mcml.lua");
	MyCompany.Aries.Game.mcml2.mcml_controls.register_all();

	if(not System.options.mc) then
		-- load all worlds configuration file
		NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
		MyCompany.Aries.WorldManager:Init();
	end
	ParaUI.SetMinimumScreenSize(960,640,true);
	if(System.options.IsMobilePlatform) then
		-- set touch finger size, better be even multiple of 15
		ParaUI.GetUIObject("root"):SetField("FingerSizePixels", 60);
	end

	-- reset all replace files
	ParaIO.LoadReplaceFile("", true);
end

function App:LoadSampleWorld()
	NPL.load("(gl)script/apps/Aries/Creator/Game/main.lua");
	local Game = commonlib.gettable("MyCompany.Aries.Game")

	local worldname = "SampleWorld";
	local worldfolder = "worlds/DesignHouse/";
	local worldpath = worldfolder..worldname;
	if(not ParaIO.DoesFileExist(worldpath)) then
		--  世界不存在就创建一个
		NPL.load("(gl)script/apps/Aries/Creator/Game/Login/CreateNewWorld.lua");
		local CreateNewWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.CreateNewWorld")
		if(CreateNewWorld.CreateWorld({
				worldname = worldname, 
				creationfolder=worldfolder, 
				parentworld = "worlds/Templates/Empty/flatsandland", --从哪个世界派生新世界
				world_generator = "flat", -- 超级平坦
				seed = world_name, -- 创建世界的随机种子
			})) then
			-- created new world succeed!
		end
	end
	Game.Start(worldpath);
end

local function activate()
	if(main_state == nil) then
		main_state = 1;
		App:Init();
		if(ParaEngine.GetAppCommandLineByParam("test", nil) == "true") then
			_guihelper.MessageBox("我们本周还在测试阶段.努力中", function()
				App:LoadSampleWorld();
			end)
		else
			NPL.load("(gl)script/mobile/paracraft/Login/MainLogin.lua");
			ParaCraft.Mobile.MainLogin:start();

			--NPL.activate("AutoUpdater.cpp", {type="auto_update",action = "check",app_type = "paracraft"})
			--NPL.activate("AutoUpdater.cpp", {type="auto_update",action = "check",app_type = "haqi2"})
		end
	else
		-- loop
	end
end
NPL.this(activate);