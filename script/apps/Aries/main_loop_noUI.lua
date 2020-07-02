--[[
Title: Main game loop for UnitTest
Company: ParaEnging Co. & Taomee Inc.
Date: 2010/5/18
Desc: Entry point and game loop
command line params
| *name*| *desc* |
| gateway | force the gateway to use, usually for debugging purposes. such as "1100" |
e.g. 
<verbatim>
	paraworld.exe username="1100@paraengine.com" password="1100@paraengine.com" servermode="true" d3d="false" chatdomain="192.168.0.233" domain="test.pala5.cn"
	paraworld.exe username="LiXizhi1" password="" gateway="1100"
</verbatim>
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/Aries/main_loop_noUI.lua");
set the bootstrapper to point to this file, see config/bootstrapper.xml
Or run application with command line: bootstrapper = "script/apps/Aries/bootstrapper.xml"
------------------------------------------------------------
]]
-- mainstate is just a dummy to set some ReleaseBuild=true


NPL.load("(gl)script/mainstate.lua"); 
NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes
-- let us see replace im server if command line contains imserver="game"
local imserver = ParaEngine.GetAppCommandLineByParam("imserver", "game");
if(imserver == "game") then
	NPL.load("(gl)script/apps/IMServer/IMserver_client.lua");
	-- this will replace the default(real) jabber client with the one implemented by our own game server based IM server. Make sure this is done before you use it in the app code.
	JabberClientManager = commonlib.gettable("IMServer.JabberClientManager");
end

if(not ReleaseBuild) then
	System.options.IsEditorMode = true;
else
	-- release build: bring window to front. 
	ParaEngine.GetAttributeObject():CallField("BringWindowToTop");
end

-- load from config file
local function Aries_load_config(filename)
	filename = filename or "config/GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading game server config file %s\n", filename);
		return;
	end	
	
	local node;
	local bg_loader_list;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/asset_server_addresses")[1];
	if(node and node.attr) then
		-- if asset is not found locally, we will look in this place
		 bg_loader_list = node.attr.bg_loader_list;
	end
	
	local node;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/asset_server_addresses/address")[1];
	if(node and node.attr) then
		-- if asset is not found locally, we will look in this place
		ParaAsset.SetAssetServerUrl(node.attr.host);
		commonlib.log("Asset server: %s\n", node.attr.host)
	end
	
	local chat_domain
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/chat_server_addresses")[1];
	if(node and node.attr) then
		chat_domain = node.attr.domain;
		System.User.ChatDomain = chat_domain;
		commonlib.log("Chat server domain: %s\n", System.User.ChatDomain);
	end
	
	System.User.ChatServers = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameClient/chat_server_addresses/address") do
		if(node.attr and node.attr.host and node.attr.port) then
			System.User.ChatServers[#(System.User.ChatServers) + 1] = node.attr;
			if(not chat_domain) then
				System.User.ChatDomain = node.attr.host;
				System.User.ChatPort = tonumber(node.attr.port);
			end
		end	
	end
	
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/web_domain")[1];
	if(node and node.attr) then
		System.User.Domain = node.attr.domain;
		commonlib.log("Web domain: %s\n", System.User.Domain)
		local web_node = node;
		node = commonlib.XPath.selectNodes(web_node, "/log_server")[1];
		if(node and node.attr) then
			commonlib.log("Log server: %s\n", node.attr.host);
			paraworld.ChangeDomain({logserver = node.attr.host})
		end
		node = commonlib.XPath.selectNodes(web_node, "/file_server")[1];
		if(node and node.attr) then
			commonlib.log("File server: %s\n", node.attr.host);
			paraworld.ChangeDomain({fileserver = node.attr.host})
		end
		
	end
	paraworld.ChangeDomain({domain=System.User.Domain, chatdomain=System.User.ChatDomain, asset_stats = bg_loader_list})
end
-- load from config file
Aries_load_config();
	
-- some init stuffs that are only called once at engine start up, but after System.init()
local bAries_Init;
local function Aries_Init()
	if(bAries_Init) then return end
	bAries_Init = true;
	
	System.SystemInfo.SetField("name", "Aries")
	
	-- install the Aries app, if it is not installed yet.
	System.App.Registration.CheckInstallApps({
		{app={app_key="WebBrowser_GUID"}, IP_file="script/kids/3DMapSystemApp/WebBrowser/IP.xml"},
		{app={app_key="ScreenShot_GUID"}, IP_file="script/kids/3DMapSystemUI/ScreenShot/IP.xml"},
		{app={app_key="CCS_GUID"}, IP_file="script/kids/3DMapSystemUI/CCS/IP.xml"},
		{app={app_key="Chat_GUID"}, IP_file="script/kids/3DMapSystemUI/Chat/IP.xml"},
		{app={app_key="profiles_GUID"}, IP_file="script/kids/3DMapSystemApp/profiles/IP.xml"},
		{app={app_key="worlds_GUID"}, IP_file="script/kids/3DMapSystemApp/worlds/IP.xml"},
		{app={app_key="Creator_GUID"}, IP_file="script/kids/3DMapSystemUI/Creator/IP.xml"},
		{app={app_key="Inventory_GUID"}, IP_file="script/kids/3DMapSystemApp/Inventory/IP.xml"},
		{app={app_key="Inventor_GUID"}, IP_file="script/kids/3DMapSystemUI/Inventor/IP.xml"},
		{app={app_key="HomeZone_GUID"}, IP_file="script/kids/3DMapSystemUI/HomeZone/IP.xml"},
		{app={app_key="HomeLand_GUID"}, IP_file="script/kids/3DMapSystemUI/HomeLand/IP.xml"},
		{app={app_key="FireMaster_GUID"}, IP_file="script/kids/3DMapSystemUI/FireMaster/IP.xml"},
		{app={app_key="FreeGrab_GUID"}, IP_file="script/kids/3DMapSystemUI/FreeGrab/IP.xml"},
		{app={app_key="Developers_GUID"}, IP_file="script/kids/3DMapSystemApp/Developers/IP.xml"},
		{app={app_key="Debug_GUID"}, IP_file="script/kids/3DMapSystemApp/DebugApp/IP.xml"},
		{app={app_key="MiniGames_GUID"}, IP_file="script/kids/3DMapSystemUI/MiniGames/IP.xml"},
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

	System.options.ViewProfileCommand = "Profile.Aries.ShowFullProfile";	
end


-- this script is activated every 0.5 sec. it uses a finite state machine (main_state). 
-- State nil is the inital game state. state 0 is idle.

function ABCactivate()
	commonlib.log("enter activate...\n");
	if(main_state==0) then
		-- this is the main game loop  
	elseif(main_state==nil) then
		-- initialization 
		commonlib.log("main_state system init...\n");

		main_state = System.init();
		commonlib.log("main_state=0\n");
		
		if(main_state~=nil) then
			commonlib.log("main_state initing ...\n");
			Aries_Init();	
			NPL.load("(gl)script/apps/Aries/Login/MainLogin_noUI.lua");			
			commonlib.log("main login start ...\n");
			MyCompany.Aries.MainLogin:start();
		end
	elseif(main_state=="exit") then	
		ParaGlobal.Exit(0);		
	end	
end

commonlib.log("activate main_loop ...\n");
main_state=nil;
NPL.this(activate);
