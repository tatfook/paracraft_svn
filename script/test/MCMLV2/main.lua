--[[
Title: Main loop
Author(s): LiXizhi
Company: ParaEnging Co.
Date: 2014/3/21
Desc: Entry point and game loop
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/test/MCMLV2/main.lua"); 
NPL.activate("source/HelloWorld/main.lua");
Or run application with command line: bootstrapper="script/test/MCMLV2/main.lua"
------------------------------------------------------------
]]
-- 加载一些核心类库
NPL.load("(gl)script/kids/ParaWorldCore.lua"); 

--读配置文件
local function load_config()
	System.options.is_client = true;
	local filename = "config/GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "warning", "aries", "warning: failed loading game server config file %s", filename);
		return;
	end	
	local node;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/asset_server_addresses/address")[1];
	if(node and node.attr) then
		-- 设置资源服务器URL
		ParaAsset.SetAssetServerUrl(node.attr.host);
		LOG.std("", "system", "aries", "Asset server: %s", node.attr.host)
	end
end

-- 初始化程序
local function InitApp()
	--读配置文件
	load_config();

	--初始化系统
	main_state = System.init();

	-- 使用一个Creator风格的内置GUI皮肤
	NPL.load("(gl)script/apps/Aries/Creator/Game/DefaultTheme.mc.lua");
	MyCompany.Aries.Creator.Game.Theme.Default:Load();

	-- 注册一些常用的内部APP。 
	System.App.Registration.CheckInstallApps({
		{app={app_key="WebBrowser_GUID"}, IP_file="script/kids/3DMapSystemApp/WebBrowser/IP.xml"},
		{app={app_key="worlds_GUID"}, IP_file="script/kids/3DMapSystemApp/worlds/IP.xml"},
		{app={app_key="Debug_GUID"}, IP_file="script/kids/3DMapSystemApp/DebugApp/IP.xml"},
	})

--	System.App.Commands.Call("Help.Debug");
--	System.App.Commands.Call("File.MCMLBrowser");

	NPL.load("(gl)script/ide/System/test/test_Windows.lua");
	local test_Windows = commonlib.gettable("System.Core.Test.test_Windows");
	test_Windows:TestMCMLPage("script/test/mcmlv2/mcml_window.html");

--	local app = Map3DSystem.App.Registration.GetApp("Debug_GUID");
--
--	NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/DebugWnd.lua");
--	Map3DSystem.App.Debug.ShowDebugWnd(app._app);

	-- 显示一个HTML页面 (旧版) using mcml version 1
	-- 注册常用HTML渲染控件
	--[[
	NPL.load("(gl)script/apps/Aries/mcml/mcml_aries.lua");
	MyCompany.Aries.mcml_controls.register_all();

	NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
	local page = System.mcml.PageCtrl:new({url="source/HelloWorldMCML/HelloWorld.html"});
	page:Create("helloworldpage", nil, "_fi", 0, 0, 0, 0)
	]]
	
	-- here is another way to create window with new mcml version 2. 
--	NPL.load("(gl)script/ide/System/Windows/Window.lua");
--    local Window = commonlib.gettable("System.Windows.Window")
--    local window = Window:new();
--    window:Show({
--        url="script/test/MCMLV2/mcml_window.html", 
--        alignment="_lt", left = 300, top = 100, width = 300, height = 400,
--    });
end

-- 主循环， 每秒会调用2次. 
local function activate()
	if(main_state == nil) then
		main_state = 1;
		-- 保证只调用一次
		InitApp();
	else
		
	end
end

NPL.this(activate);