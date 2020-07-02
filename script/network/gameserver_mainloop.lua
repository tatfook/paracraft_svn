-- game interface: main game script loop for the game server mode
-- author: Li,Xizhi 
-- date: 2007-7-30
-- description: this script is activated every 0.5 sec by AI simulator.
--	it uses a finite state machine.State nil is the inital game state. state 0 is idle.
--  it uses passive user interface, which means that the 2D user interface is only updated upon a user click 

NPL.load("(gl)script/lang/lang.lua"); -- localization init

-- this ensures that all Kids Movie functions are loaded
NPL.load("(gl)script/kids/kids_init.lua");
NPL.load("(gl)script/network/gameserver_hostworld.lua");
NPL.load("(gl)script/network/gameserver_mainUI.lua");

if(not GameServer) then GameServer={}; end

local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		--------------------------------------------
		-- get settings specific to this instance of game server, such as user name, password, ip, etc.
		--------------------------------------------
		log("game server is started");
		kids_db.User.Name = ParaEngine.GetAppCommandLineByParam("username", kids_db.User.Name);
		kids_db.User.Password = ParaEngine.GetAppCommandLineByParam("password", kids_db.User.Password);
		kids_db.User.IP = ParaEngine.GetAppCommandLineByParam("IP", "0");
		kids_db.User.Port = tonumber(ParaEngine.GetAppCommandLineByParam("port", "60001"));
		GameServer.DefaultHostWorld = ParaEngine.GetAppCommandLineByParam("defaultworld", nil);

		-- set IP address of game server
		ParaNetwork.SetNerveCenterAddress(string.format("%s:%d", kids_db.User.IP, kids_db.User.Port));
		ParaNetwork.SetNerveReceptorAddress(string.format("%s:%d", kids_db.User.IP, kids_db.User.Port-1));
		
		-- enable network layer, if the user name and password has changed.
		ParaNetwork.EnableNetwork(true, kids_db.User.Name, kids_db.User.Password);
		-- update application title
		ParaEngine.SetWindowText(string.format("%s (game server mode)", ParaNetwork.GetInternalID()));
		
		-- event handler
		GameServer.ReBindEventHandlers();
		
		-- show UI
		GameServer.ShowMainUI();
		
		ParaEngine.EnablePassiveRendering(true);

		-- start hosting
		local res = GameServer.HostWorld();
		if(res~=nil) then
			log(tostring(res));
			ParaGlobal.ExitApp();
		end
	
		main_state=0;
	else
		
	end	
end

-- this function is automatically called in GameServer.LoadWorld_imp() upon scene restart or loading. 
function GameServer.ReBindEventHandlers()
	-- register network event handler
	ParaScene.RegisterEvent("_n_kidsmovie_network", ";KidsUI_OnNetworkEvent();");
end

NPL.this(activate);
