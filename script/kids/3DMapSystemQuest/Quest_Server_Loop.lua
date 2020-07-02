--[[
Title: main loop file for quest server mode
Author(s): WangTian
Date: 2009/6/25
Desc: in ParaWorldCore.lua, if the command line contains questservermode="true", then the main game loop is automatically set this file
and main_state is set to "Quest_servermode". The server mode will periodically keep the server connection alive. 
One can also set the main game loop to this file in bootstrapper
use the lib:
------------------------------------------------------------
ParaGlobal.SetGameLoop("(gl)script/kids/3DMapSystemQuest/Quest_Server_Loop.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes


local function activate()
	if(main_state == 0) then
		-- this is the main server loop
		-- TODO: keep alive
		--Map3DSystem.Quest.Server.StayAlive();
	elseif(main_state == "Quest_servermode") then
		
		--NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");
		--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_Server.lua");
		
		-- set the main cursor
		ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",3,4);
		
		ParaScene.PauseScene(true);
		
		-- make these files accessible by other machines
		NPL.AddPublicFile("script/kids/3DMapSystemQuest/Quest_Server.lua", 1);
		NPL.AddPublicFile("script/kids/3DMapSystemQuest/Quest_Client.lua", 2);

		NPL.StartNetServer("192.168.0.102", "60011");
		input = input or {};

		local rts_name = "worker1";
		local worker = NPL.CreateRuntimeState(rts_name, 0);
		worker:Start();
		
		log("=====simple server is now started=========\n\n")
		
		
		---- start the NPL server
		--NPL.StartNetServer("192.168.0.102", "65431");
		--local serverThread1 = NPL.CreateRuntimeState("worker1", 0);
		--serverThread1:Start();
		--
		---- startup all applications
		--NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
		--Map3DSystem.App.AppManager.Startup();

--NPL.load("(gl)script/test/network/TestSimpleClient.lua");
--test_start_simple_client();

		main_state = 0;

do return end

	NPL.StartNetServer("127.0.0.1", "60001");
	input = input or {};

	local i, nCount = nil, input.threadcount or 1
	for i=1,nCount do
		local rts_name = "worker"..i;
		local worker = NPL.CreateRuntimeState(rts_name, 0);
		worker:Start();
	end
	
	log("=====simple server is now started=========\n\n")
	
	do return end
	
	
	
		-- start the NPL server
		NPL.StartNetServer("192.168.0.102", "65431");
		local serverThread1 = NPL.CreateRuntimeState("QuestServer1", 0);
		serverThread1:Start();
		
		-- startup all applications
		NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
		Map3DSystem.App.AppManager.Startup();
		
		-- set the main cursor
		ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",3,4);
		
		---- start server mode now.
		--Map3DSystem.Quest.Server.EnterServerMode();
		
		main_state = 0;
	end
end
NPL.this(activate);


--local function activate()
	--if(main_state == 0) then
		---- this is the main server loop
		---- TODO: keep alive
		----Map3DSystem.Quest.Server.StayAlive();
	--elseif(main_state == nil or main_state == "Quest_servermode") then
		---- startup all applications
		--NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
		--Map3DSystem.App.AppManager.Startup();
		--
		---- start server mode now.
		--Map3DSystem.Quest.Server.EnterServerMode();
		--
		--main_state = 0;
	--end
--end
--NPL.this(activate);

