--[[
Title: instance entry for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Instance/main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Instance/Pages/InstanceMenuPage.lua");
local InstanceMenuPage = commonlib.gettable("MyCompany.Aries.Instance.InstanceMenuPage");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
-- create class
local Instance = commonlib.gettable("MyCompany.Aries.Instance");

local Combat = commonlib.gettable("MyCompany.Aries.Combat");

local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");

local ItemManager = commonlib.gettable("System.Item.ItemManager");
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local PvPTicket_NPC = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvPTicket_NPC");

NPL.load("(gl)script/apps/Aries/NPCs/Combat/39000_BasicArena.lua");
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");

local hasGSItem = ItemManager.IfOwnGSItem;

-- Instance.init()
function Instance.Init()
end

function Instance.YYsDream_main()
end

function Instance.FreePvPTicketAmbassador_main()
end

function Instance.FreeArenaPvPTicketAmbassador_main()
end

function Instance.InsuranceAmbassador_main()
end

local last_distancetoplayersq_t = {};

-- record the start time for animation
local instance_entrance_lock_countdown_starttime = nil;

-- on world load
function Instance.OnWorldLoad()
	
    local worldpath = ParaWorld.GetWorldDirectory();

	if(worldpath ~= "worlds/MyWorlds/AriesTutorial/") then
		-- reset the combat pip tutorial if not in tutorial world
		local NPCs = commonlib.gettable("MyCompany.Aries.Quest.NPCs");
		NPCs.CombatTutorial = nil;
	end
    
	if(worldpath == "worlds/MyWorlds/61HaqiTown/") then
		
		local params = {
			name = "",
			position = { 20480.076171875, 20026.103515625, 20203.83984375 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -0.7996312379837 + 1.57,
			scaling = 2.0,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301121, params);
		
		local params = {
			name = "",
			position = { 19852.685546875, 5.0098361968994, 19505.505859375 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.09365 + 1.57,
			scaling = 1.0,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			dialog_page = "script/apps/Aries/NPCs/Instance/31001_LightTowerEntrance_dialog.html",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301125, params);
		
		-- temp npc for dialog portait
		local params = {
			name = "",
			position = { 19852.685546875, -10005.0098361968994, 19505.505859375 },
			assetfile_char = "character/v5/10mobs/HaqiTown/WhiteSmashBull/WhiteSmashBull.x",
			facing = 2.09365 + 1.57,
			scaling = 1.0,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(319763, params);
		
		--  moved to tools
		--local params = {
			--name = "",
			--position = { 20095.20703125,-1.2449071407318,19650.435546875 },
			--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
			--assetfile_model = "model/01building/v5/01house/DeliverDoor/ArenicDoor_Blue.x",
			--facing = 1.89,
			--scaling = 1.4,
			--scale_char = 3,
			--talk_dist = 6,
			--main_script = "script/apps/Aries/Instance/main.lua",
			--main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			--predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",	
			--timer_period = 1000,
		--};
		--local NPC = MyCompany.Aries.Quest.NPC;
		--NPC.CreateNPCCharacter(301133, params);
		--local params = {
			--name = "",
			--position = { 20116.67578125,-1.1926848888397,19645.47265625 },
			--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
			--assetfile_model = "model/01building/v5/01house/DeliverDoor/ArenicDoor_Green.x",
			--facing = 1.75,
			--scaling = 1.9,
			--scale_char = 3,
			--talk_dist = 6,
			--main_script = "script/apps/Aries/Instance/main.lua",
			--main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			--predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",	
			--timer_period = 1000,
		--};
		--local NPC = MyCompany.Aries.Quest.NPC;
		--NPC.CreateNPCCharacter(301134, params);
		--local params = {
			--name = "",
			--position = { 20141.412109375,-1.2199252843857,19643.50390625 },
			--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
			--assetfile_model = "model/01building/v5/01house/DeliverDoor/ArenicDoor_Red.x",
			--facing = 1.6,
			--scaling = 2.4,
			--scale_char = 3,
			--talk_dist = 6,
			--main_script = "script/apps/Aries/Instance/main.lua",
			--main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			--predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			--timer_period = 1000,
		--};
		--local NPC = MyCompany.Aries.Quest.NPC;
		--NPC.CreateNPCCharacter(301135, params);
		
		--local params = {
			--name = "赛场管理员",
			--position = { 20326.515625, -2.3626141548157, 19699.607421875 },
			--assetfile_char = "character/v5/02animals/FlyPig/FlyPig.x",
			--facing = 2.19872,
			--scaling = 1.8,
			----scale_char = 3,
			--talk_dist = 6,
			--main_script = "script/apps/Aries/Instance/main.lua",
			--main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			--predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			--timer_period = 1000,
		--};
		--local NPC = MyCompany.Aries.Quest.NPC;
		--NPC.CreateNPCCharacter(301138, params);


	elseif(worldpath == "worlds/MyWorlds/61HaqiTown_teen/") then
		
		local params = {
			name = "",
			position = { 19573.3, 33.7, 19604.7 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -0.51 + 1.57,
			scaling = 1.8,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301121, params);
		
		local params = {
			name = "",
			position = { 19916.71,33.58,19737.49 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -0.51 + 1.57,
			scaling = 1.8,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301152, params);

		local params = {
			name = "",
			position = { 19971.29,43.88,19496.09 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 0.24 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301156, params);
		
		local params = {
			name = "",
			position = { 20341.54,15.23,19621.72 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 0.62 + 1.57,
			scaling = 1.8,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301163, params);
		
	elseif(worldpath == "worlds/MyWorlds/FlamingPhoenixIsland/") then
		
		local params = {
			name = "",
			position = { 20155.255859375, 104.05625152588, 20211.958984375 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.832404255867 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		
		if(System.options.version == "teen") then
			params.position = {20157.41, 72.30, 20215.45};
		end

		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301122, params);
		
		local params = {
			name = "",
			position = { 19924.681640625, 37.672855377197, 19877.39453125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -0.17074 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301132, params);
		
		if(System.options.version == "teen") then
			local params = {
				name = "",
				position = { 19700.70,7.07,19759.62 },
				assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
				facing = -0.51 + 1.57,
				scaling = 1.8,
				talk_dist = 6,
				main_script = "script/apps/Aries/Instance/main.lua",
				main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
				predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
				selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
				timer_period = 1000,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			NPC.CreateNPCCharacter(301153, params);
		end
		
	elseif(worldpath == "worlds/MyWorlds/FlamingPhoenixIsland_teen/") then
		
		local params = {
			name = "",
			position = { 20154.6,73.91,20239.18 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.3 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301122, params);
		
		local params = {
			name = "",
			position = { 19924.681640625, 37.672855377197, 19877.39453125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -0.17074 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301132, params);
		
		if(System.options.version == "teen") then
			local params = {
				name = "",
				position = { 19630.18,8.24,19674.37 },
				assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
				facing = -1.8 + 1.57,
				scaling = 1.8,
				talk_dist = 6,
				main_script = "script/apps/Aries/Instance/main.lua",
				main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
				predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
				selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
				timer_period = 1000,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			NPC.CreateNPCCharacter(301153, params);
		end
		
	elseif(worldpath == "worlds/MyWorlds/FrostRoarIsland/") then
		
		local params = {
			name = "",
			position = { 19855.779297, 3.192261, 20442.494141 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.96014 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301141, params);
		
		local params = {
			name = "",
			position = { 19945.45117,235.50811,20223.53907 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.06214 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301144, params);
		
		local params = {
			name = "",
			position = { 19956.8515625, 53.986122131348, 20004.025390625 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.54142 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301147, params);
		
	elseif(worldpath == "worlds/MyWorlds/FrostRoarIsland_teen/") then

		local params = {
			name = "",
			position = { 19945.45117,235.50811,20223.53907 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.06214 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301144, params);
		
		local params = {
			name = "",
			position = { 19879.29,6.18,19942.30 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.06214 + 1.57,
			scaling = 2, 
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301154, params);
		
		local params = {
			name = "",
			position = { 19873.46, 10.59, 20091.07 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 0.2 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301147, params);
		
		local params = {
			name = "",
			position = { 19530.46,18.47,19985.90 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -2.05 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301157, params);
		
	elseif(worldpath == "worlds/MyWorlds/AncientEgyptIsland/") then
		
		local params = {
			name = "",
			position = { 20060.359375, 56.111408233643, 20364.328125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.57712 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301143, params);
		
		local params = {
			name = "",
			position = { 19903.318359375, 11.678829193115, 19369.216796875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.90135 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301150, params);
		
	elseif(worldpath == "worlds/MyWorlds/AncientEgyptIsland_teen/") then
		
		local params = {
			name = "",
			position = { 20060.359375, 56.111408233643, 20364.328125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.57712 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301143, params);

		local params = {
			name = "",
			position = { 19949.16,6.79,20249.91 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.06214 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301155, params);
		
		local params = {
			name = "",
			position = { 19903.318359375, 11.678829193115, 19369.216796875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.90135 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301150, params);
		
	elseif(worldpath == "worlds/MyWorlds/DarkForestIsland_teen/") then
	
		local params = {
			name = "",
			position = { 19441.79, 3.01, 19915.87 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.77 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301158, params);

		local params = {
			name = "",
			position = { 19907.33, 12.13, 19673.66 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 1.52 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301159, params);

		local params = {
			name = "",
			position = { 19574.4, 31.0, 19453.9 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.7 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301161, params);
		
		local params = {
			name = "",
			position = { 19829.49, 5.8, 19480.07 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.7 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301162, params);
		
		local params = {
			name = "",
			position = { 19309.08, 71.9, 20133.31 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.13 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301164, params);
		
	elseif(worldpath == "worlds/MyWorlds/CloudFortressIsland_teen/") then
	
		local params = {
			name = "",
			position = { 20183.50,431.0,20412.5 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -2.4 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301165, params);
		
		local params = {
			name = "",
			position = { 19760.94,208.40,20485.07 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -2.1 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301166, params);

		local params = {
			name = "",
			position = { 20718.86,239.22,20649.29 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -1.89 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301167, params);
		
		local params = {
			name = "",
			position = { 21254.52,449.92,20107.14 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = -2.47 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301168, params);
		
		local params = {
			name = "",
			position = { 19713.10,335.70,19415.62 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 2.76 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301170, params);
		
		
		

	elseif(worldpath == "worlds/Instances/HaqiTown_FireCavern/") then
		
		local params = {
			name = "",
			position = { 20551.576171875, 20017.39453125, 19909.44140625 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 1.39074 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301123, params);
		
	elseif(worldpath == "worlds/Instances/HaqiTown_FireCavern2/") then
		
		local params = {
			name = "",
			position = { 20145.455078125, 20012.9375, 19992.662109375 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -0.3656 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301123, params);

	elseif(worldpath == "worlds/Instances/FlamingPhoenixIsland_TheGreatTree/") then
		
		local params = {
			name = "",
			position = { 19999.966796875, 20000.19921875, 19951.37109375 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301124, params);
		
	elseif(worldpath == "worlds/Instances/HaqiTown_LightHouse/") then
		local params = {
			name = "",
			position = { 11092.650390625, 20005.36640625, 20000.185546875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			assetfile_model = "model/01building/v5/04instance/LightTower/LightTower8/LightTower8_door.x",
			facing = 1.57,
			scaling = 1.5,
			scale_char = 1.7,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301126, params);
		local params = {
			name = "",
			position = { 13791.931640625, 20005.36640625, 20000.185546875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			assetfile_model = "model/01building/v5/04instance/LightTower/LightTower26/LightTower26_door.x",
			facing = 1.57,
			scaling = 1.5,
			scale_char = 1.7,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301127, params);
		local params = {
			name = "",
			position = { 19042.91796875, 20005.36640625, 20000.185546875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			assetfile_model = "model/01building/v5/04instance/LightTower/LightTower61/LightTower61_door.x",
			facing = 1.57,
			scaling = 1.5,
			scale_char = 1.7,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301128, params);

	elseif(worldpath == "worlds/Instances/HaqiTown_YYsDream_S1/") then
		
		local params = {
			name = "",
			position = { 19904.740234375, 63.940895080566, 20067.73828125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301129, params);
		
		local params = {
			name = "",
			position = { 20051.955078125, 24.91866569519, 20094.048828125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -0.92957 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301130, params);
		
	elseif(worldpath == "worlds/Instances/HaqiTown_YYsDream_S3/") then
		
		local params = {
			name = "",
			position = { 20051.955078125, 24.91866569519, 20094.048828125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -0.92957 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301130, params);
		
		local params = {
			name = "",
			position = { 19905.3, 62.5, 20072.0 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Entrance.x",
			facing = 0,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301169, params);

	elseif(worldpath == "worlds/Instances/HaqiTown_YYsDream_S2/") then
		
		local params = {
			name = "",
			position = { 20257.560546875, 78.983120727539, 19943.12890625 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0.36192 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301131, params);

	elseif(worldpath == "worlds/Instances/FlamingPhoenixIsland_GoldenOgreTreasureHouse/") then
		
		local params = {
			name = "",
			position = { 19942.666015625, 20028.33984375, 20045.57421875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -2.143 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301136, params);
		
	elseif(worldpath == "worlds/Instances/FrostRoarIsland_IceKingCave/") then
		
		local params = {
			name = "",
			position = { 20115, 20157.453125, 20064.080078125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -0.21864 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301145, params);
		
		local params = {
			name = "",
			position = { 19974.39,20031.99,20049.66 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 1.63 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301146, params);
		
	elseif(worldpath == "worlds/Instances/FrostRoarIsland_StormEye/") then
		
		local params = {
			name = "",
			position = { 19981.861328125, -10.111120223999, 19947.376953125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 1.05566 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301148, params);
		
	elseif(worldpath == "worlds/Instances/AncientEgyptIsland_LostTemple/") then
		
		local params = {
			name = "",
			position = { 19953.681640625, 99.990699768066, 20039.76171875 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -1.57712 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301142, params);
		
	elseif(worldpath == "worlds/Instances/AncientEgyptIsland_PharaohFortress/") then
		
		local params = {
			name = "",
			position = { 20306.615234375, 30.389307022095, 19985.890625 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 2.36761 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301149, params);
		
	elseif(worldpath == "worlds/Instances/HaqiTown_GraduateExam_54_55/") then
		
		local params = {
			name = "",
			position = { 19925.4, 61.7, 20005.2 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301151, params);
		
	elseif(worldpath == "worlds/Instances/HaqiTown_TrialOfChampions_Amateur/" or 
			worldpath == "worlds/Instances/HaqiTown_TrialOfChampions_Intermediate/" or 
			worldpath == "worlds/Instances/HaqiTown_TrialOfChampions_Master/") then
		
		local params = {
			name = "",
			position = { 10183.63671875, 20005.099609375, 20000.203125 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0.00036 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301137, params);
		
	elseif(worldpath == "worlds/Instances/DarkForestIsland_PirateSeamaster/") then
		
		local params = {
			name = "",
			position = { 19954.7, 2.1, 19998.9 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 3.1 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301160, params);
		
	elseif(worldpath == "worlds/Instances/CrazyTower_Fire_1/" or 
			worldpath == "worlds/Instances/CrazyTower_Ice_1/" or 
			worldpath == "worlds/Instances/CrazyTower_Storm_1/" or 
			worldpath == "worlds/Instances/CrazyTower_Life_1/" or 
			worldpath == "worlds/Instances/CrazyTower_Death_1/") then
		
		local params = {
			name = "",
			position = { 20043.0, 34.5, 20019.2 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0.2 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301160, params);
		
	elseif(worldpath == "worlds/Instances/CrazyTower_Fire_2/" or 
			worldpath == "worlds/Instances/CrazyTower_Ice_2/" or 
			worldpath == "worlds/Instances/CrazyTower_Storm_2/" or 
			worldpath == "worlds/Instances/CrazyTower_Life_2/" or 
			worldpath == "worlds/Instances/CrazyTower_Death_2/") then
		
		local params = {
			name = "",
			position = { 19961.4, 68.4, 20197.9 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = -0.5 + 1.57,
			scaling = 1.5,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301160, params);
		
	elseif(worldpath == "worlds/Instances/HaqiTown_RedMushroomArena/") then
		
		-- 隐藏哈2红蘑菇的看台观众
		if(System.options.version == "kids") then
			local params = {
				copies = 10,
				positions = {
							{ 20033.107421875, 70.661598205566, 20033.21484375 },
							{ 20025.80078125, 68.402702331543, 20032.509765625 },
							{ 20029.759765625, 66.450271606445, 20025.841796875 },
							{ 20036.57421875, 68.402702331543, 20024.880859375 },
							{ 20036.0078125, 66.450271606445, 20018.748046875 },
							{ 20030.529296875, 66.402351379395, 19974.12109375 },
							{ 20026.279296875, 66.402351379395, 19970.1171875 },
							{ 20024.017578125, 68.354782104492, 19964.45703125 },
							{ 20032.18359375, 68.354782104492, 19970.7421875 },
							{ 20041.291015625, 70.613677978516, 19976.4296875 },
							},
				facings = {2.25945, 
							2.25945, 
							2.25945, 
							2.25945, 
							2.25945,  
							-2.40993, 
							-2.40993, 
							-2.40993, 
							-2.40993, 
							-2.40993, 
							},
				name = "",
				position = { 19664.3515625, 6.9998273849487, 20104.884765625 },
				facing = 2.8132255077362,
				scaling = 1.6,
				isalwaysshowheadontext = false,
				--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
				assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
				main_script = "script/apps/Aries/Instance/main.lua",
				main_function = "MyCompany.Aries.Instance.DummyAudience_Main();",
				selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
				autofacing = true,
				on_timer = ";MyCompany.Aries.Instance.OnDummyAudience_Timer();",
				timer_period = 5000,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			local i = 1;
			for i = 1, 10 do
				params.instance = i;
				params.position = params.positions[i];
				params.facing = params.facings[i];
				if(i == 1 or i == 6) then
					params.assetfile_char = "character/v5/01human/Dongdong/Dongdong_now.x";
					params.scaling = 1.6;
				elseif(i == 2 or i == 7) then
					params.assetfile_char = "character/v5/01human/Dancer/Dancer.x";
					params.scaling = 3;
				elseif(i == 3 or i == 8) then
					params.assetfile_char = "character/v5/01human/DE_QingQing/DE_QingQing.x";
					params.scaling = 1.6;
				elseif(i == 9) then
					params.assetfile_char = "character/v5/01human/GruntNuncle/GruntNuncle.x";
					params.scaling = 3;
				elseif(i == 4) then
					params.assetfile_char = "character/v5/01human/Dancer/Dancer.x";
					params.scaling = 3;
				elseif(i == 5) then
					params.assetfile_char = "character/v5/01human/HaqiAmbassador/HaqiAmbassador.x";
					params.scaling = 2.2;
				elseif(i == 10) then
					params.assetfile_char = "character/v3/Elf/Female/ElfFemale.xml";
					params.scaling = 3.2;
				end
				local npcChar = NPC.CreateNPCCharacter(379854, params);
				if(npcChar and npcChar:IsValid() == true) then
					if(i == 10) then
						local CCS = commonlib.gettable("System.UI.CCS");
						CCS.DB.ApplyCartoonfaceInfoString(npcChar, "0#F#0#0#0#0#0#F#0#0#0#0#10#F#0#0#0#0#10#F#0#0#0#0#11#F#0#0#0#0#9#F#0#0#0#0#0#F#0#0#0#0#");
						CCS.Predefined.ApplyFacialInfoString(npcChar, "0#1#0#2#1#");
						npcChar:ToCharacter():SetCharacterSlot(16, 1178);
					end
				end
			end
		end
		
		local params = {
			copies = 10,
			positions = {
						{ 19992.8, 63.619201660156, 20036.7 },
						{ 19995.5, 63.619201660156, 20033.6 },
						{ 20000.3, 63.619201660156, 20031.5 },
						{ 20005.0, 63.619201660156, 20033.0 },
						{ 20008.0, 63.619201660156, 20036.0 },
						{ 20007.5, 63.619201660156, 19959.5 },
						{ 20005.5, 63.619201660156, 19964.4 },
						{ 20000.8, 63.619201660156, 19966.1 },
						{ 19996.3, 63.619201660156, 19965.7 },
						{ 19993.2, 63.619201660156, 19961.1 },
						},
			facings = {-2.13537, 
						-2.13537, 
						-2.13537, 
						-2.13537, 
						-2.13537, 
						1.99487, 
						1.99487, 
						1.99487, 
						1.99487, 
						1.99487, 
						},
			name = "",
			position = { 19664.3515625, 6.9998273849487, 20104.884765625 },
			facing = 2.8132255077362,
			isalwaysshowheadontext = false,
			assetfile_char = "character/common/dummy/elf_size/elf_size.x",
			assetfile_model = "model/02furniture/v5/Redmushroom/DoorAndFence/Fence04.x",
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntranceLock_Main();",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			autofacing = true,
			on_timer = ";MyCompany.Aries.Instance.OnInstanceEntranceLock_Timer();",
			timer_period = 10,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		local i = 1;
		for i = 1, 10 do
			params.instance = i;
			params.position = params.positions[i];
			params.facing = params.facings[i];
			local _, npcModel = NPC.CreateNPCCharacter(379855, params);
			if(npcModel and npcModel:IsValid()) then
				npcModel:EnablePhysics(false);
			end
		end
		
		--local params = {
			--copies = 2,
			--positions = {
						--{ 19999.814453125, 62.821643829346, 19954.189453125 },
						--{ 20000.5546875, 62.912590026855, 20045.0234375 },
						--},
			--facings = {1.55974, 
						---1.62465, 
						--},
			--name = "",
			--position = { 19664.3515625, 6.9998273849487, 20104.884765625 },
			--facing = 2.8132255077362,
			--isalwaysshowheadontext = false,
			--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
			--assetfile_model = "model/06props/v5/05other/RedMushroomPhysics/RedMushroomPhysics.x",
			--scaling = 1,
			--scale_char = 0.00001,
			--main_script = "script/apps/Aries/Instance/main.lua",
			--main_function = "MyCompany.Aries.Instance.InstanceEntranceLock_Main();",
			--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			--autofacing = true,
			--on_timer = ";MyCompany.Aries.Instance.OnInstanceEntranceLock_Timer();",
			--timer_period = 50,
		--};
		--local NPC = MyCompany.Aries.Quest.NPC;
		--local i = 1;
		--for i = 1, 2 do
			--params.instance = i;
			--params.position = params.positions[i];
			--params.facing = params.facings[i];
			--NPC.CreateNPCCharacter(379856, params);
		--end
		
		local params = {
			name = "红蘑菇使者",
			position = { 19970.947265625, 63.409507751465, 19999.56640625 },
			assetfile_char = "character/v5/01human/Messenger/Messenger.x",
			facing = -0.03892,
			scaling = 1.6,
			--scale_char = 3,
			talk_dist = 1,
			isalwaysshowheadontext = false,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301139, params);

		local params = {
			name = "",
			position = { 20032.935546875, 63.251533508301, 19998.99609375 },
			assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
			facing = 0.03777 + 1.57,
			scaling = 2,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.ExitInstance_PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			on_timer = ";MyCompany.Aries.Instance.On_Timer();",
			timer_period = 1000,
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.CreateNPCCharacter(301140, params);
	elseif(worldpath == "worlds/Instances/HaqiTown_LafeierCastle_PVP/") then
		if(System.options.version == "kids") then
			local params = {
				copies = 10,
				positions = {
					{20093.53,63.18,20018.76 },
					{20100.62,66.04,20027.40 },
					{20090.89,64.52,20022.97 },
					{20133.18,63.18,20018.51 },
					{20139.37,66.04,20026.56 },
					{20135.67,63.18,19944.01 },
					{20144.06,64.52,19940.37 },
					{20101.24,63.18,19944.60 },
					{20092.80,64.52,19940.20 },
					{20097.64,66.04,19935.43 },
				},
				facings = {
							1.5,
							1.4,
							1.6,
							1.7,
							1.8,
							4.2,
							4.1,
							4.5,
							5,
							5.1,
							5,			 
							},
				name = "",
				position = { 19664.3515625, 6.9998273849487, 20104.884765625 },
				facing = 2.8132255077362,
				scaling = 1.6,
				isalwaysshowheadontext = false,
				--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
				assetfile_char = "character/v5/09effect/InstanceDoor/InstanceDoor_Exit.x",
				main_script = "script/apps/Aries/Instance/main.lua",
				main_function = "MyCompany.Aries.Instance.DummyAudience_Main();",
				selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
				autofacing = true,
				on_timer = ";MyCompany.Aries.Instance.OnDummyAudience_Timer();",
				timer_period = 5000,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			local i = 1;
			for i = 1, 10 do
				params.instance = i;
				params.position = params.positions[i];
				params.facing = params.facings[i];
				if(i == 1 or i == 6) then
					params.assetfile_char = "character/v5/01human/Dongdong/Dongdong_now.x";
					params.scaling = 1.6;
				elseif(i == 2 or i == 7) then
					params.assetfile_char = "character/v5/01human/Sosue/Sosue.x";
					params.scaling = 3;
				elseif(i == 3 or i == 8) then
					params.assetfile_char = "character/v5/01human/DE_QingQing/DE_QingQing.x";
					params.scaling = 1.6;
				elseif(i == 9) then
					params.assetfile_char = "character/v5/01human/GruntNuncle/GruntNuncle.x";
					params.scaling = 3;
				elseif(i == 4) then
					params.assetfile_char = "character/v5/01human/Dancer/Dancer.x";
					params.scaling = 3;
				elseif(i == 5) then
					params.assetfile_char = "character/v5/01human/HaqiAmbassador/HaqiAmbassador.x";
					params.scaling = 2.2;
				elseif(i == 10) then
					params.assetfile_char = "character/v5/01human/HaqiAmbassador/HaqiAmbassador.x";
					params.scaling = 2.2;
				end
				local npcChar = NPC.CreateNPCCharacter(379854, params);
				if(npcChar and npcChar:IsValid() == true) then
					if(i == 10) then
						local CCS = commonlib.gettable("System.UI.CCS");
						CCS.DB.ApplyCartoonfaceInfoString(npcChar, "0#F#0#0#0#0#0#F#0#0#0#0#10#F#0#0#0#0#10#F#0#0#0#0#11#F#0#0#0#0#9#F#0#0#0#0#0#F#0#0#0#0#");
						CCS.Predefined.ApplyFacialInfoString(npcChar, "0#1#0#2#1#");
						npcChar:ToCharacter():SetCharacterSlot(16, 1178);
					end
				end
			end
		end
		
		--local params = {
			--copies = 10,
			--positions = {
						--{ 19992.8, 63.619201660156, 20036.7 },
						--{ 19995.5, 63.619201660156, 20033.6 },
						--{ 20000.3, 63.619201660156, 20031.5 },
						--{ 20005.0, 63.619201660156, 20033.0 },
						--{ 20008.0, 63.619201660156, 20036.0 },
						--{ 20007.5, 63.619201660156, 19959.5 },
						--{ 20005.5, 63.619201660156, 19964.4 },
						--{ 20000.8, 63.619201660156, 19966.1 },
						--{ 19996.3, 63.619201660156, 19965.7 },
						--{ 19993.2, 63.619201660156, 19961.1 },
						--},
			--facings = {-2.13537, 
						---2.13537, 
						---2.13537, 
						---2.13537, 
						---2.13537, 
						--1.99487, 
						--1.99487, 
						--1.99487, 
						--1.99487, 
						--1.99487, 
						--},
			--name = "",
			--position = { 19664.3515625, 6.9998273849487, 20104.884765625 },
			--facing = 2.8132255077362,
			--isalwaysshowheadontext = false,
			--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
			--assetfile_model = "model/02furniture/v5/Redmushroom/DoorAndFence/Fence04.x",
			--main_script = "script/apps/Aries/Instance/main.lua",
			--main_function = "MyCompany.Aries.Instance.InstanceEntranceLock_Main();",
			--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			--autofacing = true,
			--on_timer = ";MyCompany.Aries.Instance.OnInstanceEntranceLock_Timer();",
			--timer_period = 10,
		--};
		--local NPC = MyCompany.Aries.Quest.NPC;
		--local i = 1;
		--for i = 1, 10 do
			--params.instance = i;
			--params.position = params.positions[i];
			--params.facing = params.facings[i];
			--local _, npcModel = NPC.CreateNPCCharacter(379855, params);
			--if(npcModel and npcModel:IsValid()) then
				--npcModel:EnablePhysics(false);
			--end
		--end
	end
	
	local current_worlddir = ParaWorld.GetWorldDirectory();
	if(current_worlddir == "worlds/Instances/HaqiTown_RedMushroomArena/" or 
		string.find(current_worlddir, "worlds/Instances/HaqiTown_TrialOfChampions")) then
		-- reset entrance lock countdown start time for animation
		instance_entrance_lock_countdown_starttime = ParaGlobal.timeGetTime();
		
		-- set team position according to the team id
		NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
		local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
	
		local matchinfo = LobbyClient:GetMatchInfo();
		local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
		if(not matchinfo) then
			matchinfo = {teams = {{},{}}}
		end
		
		local team_index = 1;
		local game1 = game_info:new(matchinfo.teams[1]);
		local game2 = game_info:new(matchinfo.teams[2]);
		if(game1:has_player(tostring(System.App.profiles.ProfileManager.GetNID()))) then
			team_index = 1;
		end
		if(game2:has_player(tostring(System.App.profiles.ProfileManager.GetNID()))) then
			team_index = 2;
		end

		UIAnimManager.PlayCustomAnimation(10, function(elapsedTime)
			if(elapsedTime == 10) then
				if(team_index == 1) then
					-- red team
					local myself_objname = tostring(System.App.profiles.ProfileManager.GetNID());
					local player = ParaScene.GetObject(myself_objname);
					if(player and player:IsValid()) then
						--player:SetPosition(20000.017578125, 62.922424316406, 20040.3984375);
						if(current_worlddir == "worlds/Instances/HaqiTown_RedMushroomArena/") then
							player:SetPosition(20000.083984375, 63.791568756104, 20015.98046875);
						elseif(string.find(current_worlddir, "worlds/Instances/HaqiTown_TrialOfChampions")) then
							player:SetPosition(10150.0, 20006.1, 20008.9);
						end
						player:SetFacing(1.59435);
						local att = ParaCamera.GetAttributeObject();
						att:SetField("CameraObjectDistance", 20);
						att:SetField("CameraLiftupAngle", 0.41537);
						att:SetField("CameraRotY", -1.56633 + 3.14);
					end
				elseif(team_index == 2) then
					-- blue team
					local myself_objname = tostring(System.App.profiles.ProfileManager.GetNID());
					local player = ParaScene.GetObject(myself_objname);
					if(player and player:IsValid()) then
						--player:SetPosition(20000.6953125, 62.804271697998, 19957.802734375);
						if(current_worlddir == "worlds/Instances/HaqiTown_RedMushroomArena/") then
							player:SetPosition(20000.08203125, 63.868598937988, 19988.294921875);
						elseif(string.find(current_worlddir, "worlds/Instances/HaqiTown_TrialOfChampions")) then
							player:SetPosition(10150.0, 20006.1, 19990.2);
						end
						player:SetFacing(-1.55624);
						local att = ParaCamera.GetAttributeObject();
						att:SetField("CameraObjectDistance", 20);
						att:SetField("CameraLiftupAngle", 0.37448);
						att:SetField("CameraRotY", -1.56633);
					end
				end
				-- mount on dragon
				local ItemManager = System.Item.ItemManager;
				local item = ItemManager.GetMyMountPetItem();
				if(item and item.guid > 0) then
					if(item.clientdata ~= "mount") then
						item:MountMe();
					end
				end
				-- block all input
				-- commented by LiXizhi 2011.9.22 (Enter Key should be received in object manager)
				-- ParaScene.GetAttributeObject():SetField("BlockInput", true); 
				System.KeyBoard.SetKeyPassFilter(System.KeyBoard.enter_key_filter);
				System.Mouse.SetMousePassFilter(System.Mouse.disable_filter);
				ParaCamera.GetAttributeObject():SetField("BlockInput", true);
				-- hide all desktop areas
				MyCompany.Aries.Desktop.HideAllAreas();
			end
		end);
	end

	if(current_worlddir == "worlds/Instances/HaqiTown_LafeierCastle_PVP/") then
		-- reset entrance lock countdown start time for animation
		instance_entrance_lock_countdown_starttime = ParaGlobal.timeGetTime();
		
		-- set team position according to the team id
		NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
		local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
	
		local matchinfo = LobbyClient:GetMatchInfo();
		local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
		if(not matchinfo) then
			matchinfo = {teams = {{},{}}}
		end
		
		local team_index = 1;
		local game1 = game_info:new(matchinfo.teams[1]);
		local game2 = game_info:new(matchinfo.teams[2]);
		if(game1:has_player(tostring(System.App.profiles.ProfileManager.GetNID()))) then
			team_index = 1;
		end
		if(game2:has_player(tostring(System.App.profiles.ProfileManager.GetNID()))) then
			team_index = 2;
		end

		UIAnimManager.PlayCustomAnimation(10, function(elapsedTime)
			if(elapsedTime == 10) then
				if(team_index == 1) then
					-- red team
					local myself_objname = tostring(System.App.profiles.ProfileManager.GetNID());
					local player = ParaScene.GetObject(myself_objname);
					if(player and player:IsValid()) then
						--player:SetPosition(20000.017578125, 62.922424316406, 20040.3984375);
						if(current_worlddir == "worlds/Instances/HaqiTown_LafeierCastle_PVP/") then
							player:SetPosition(20117.54,62.14,19995.64);
						end
						player:SetFacing(1.59435);
						local att = ParaCamera.GetAttributeObject();
						att:SetField("CameraObjectDistance", 20);
						att:SetField("CameraLiftupAngle", 0.41537);
						att:SetField("CameraRotY", -1.56633 + 3.14);
					end
				elseif(team_index == 2) then
					-- blue team
					local myself_objname = tostring(System.App.profiles.ProfileManager.GetNID());
					local player = ParaScene.GetObject(myself_objname);
					if(player and player:IsValid()) then
						--player:SetPosition(20000.6953125, 62.804271697998, 19957.802734375);
						if(current_worlddir == "worlds/Instances/HaqiTown_LafeierCastle_PVP/") then
							player:SetPosition(20117.35,62.14,19965.91);
						end
						player:SetFacing(-1.55624);
						local att = ParaCamera.GetAttributeObject();
						att:SetField("CameraObjectDistance", 20);
						att:SetField("CameraLiftupAngle", 0.37448);
						att:SetField("CameraRotY", -1.56633);
					end
				end
				-- mount on dragon
				local ItemManager = System.Item.ItemManager;
				local item = ItemManager.GetMyMountPetItem();
				if(item and item.guid > 0) then
					if(item.clientdata ~= "mount") then
						item:MountMe();
					end
				end
				-- block all input
				-- commented by LiXizhi 2011.9.22 (Enter Key should be received in object manager)
				-- ParaScene.GetAttributeObject():SetField("BlockInput", true); 
				System.KeyBoard.SetKeyPassFilter(System.KeyBoard.enter_key_filter);
				System.Mouse.SetMousePassFilter(System.Mouse.disable_filter);
				ParaCamera.GetAttributeObject():SetField("BlockInput", true);
				-- hide all desktop areas
				MyCompany.Aries.Desktop.HideAllAreas();
			end
		end);
	end

	last_distancetoplayersq_t = {};
end

function Instance.DummyAudience_Main()
end

local random_words = {
	"加油！",
	"好厉害啊！",
	"能给我签个名吗？",
	"我是你的Fans！",
	"偶像……我们合个影吧？？",
	"真是大有潜力的哈奇啊！",
	"你是我们的英雄！",
};

function Instance.OnDummyAudience_Timer()
	-- play random dummy audience animation
	local tobe_cheer_id = {};
	local i = math.random(1, 10);
	table.insert(tobe_cheer_id, i);
	local i = math.random(1, 10);
	table.insert(tobe_cheer_id, i);
	local _, instance;
	for _, instance in pairs(tobe_cheer_id) do
		local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(379854, instance);
		if(npcChar and npcChar:IsValid() == true) then
			local animfile = "character/Animation/v5/hongmogu/ElfFemale_jump.x";
			System.Animation.PlayAnimationFile(animfile, npcChar);
			-- speak random word
			local word = random_words[math.random(1, #random_words)];
			headon_speech.Speek(npcChar.name, headon_speech.GetBoldTextMCML(word), 2);
		end
	end
	local tobe_cheer_id = {};
	local i = math.random(1, 10);
	table.insert(tobe_cheer_id, i);
	local i = math.random(1, 10);
	table.insert(tobe_cheer_id, i);
	local _, instance;
	for _, instance in pairs(tobe_cheer_id) do
		local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(379854, instance);
		if(npcChar and npcChar:IsValid() == true) then
			local animfile = "character/Animation/v5/hongmogu/ElfFemale_huanhu.x";
			System.Animation.PlayAnimationFile(animfile, npcChar);
			-- speak random word
			local word = random_words[math.random(1, #random_words)];
			headon_speech.Speek(npcChar.name, headon_speech.GetBoldTextMCML(word), 2);
		end
	end
end

function Instance.InstanceEntranceLock_Main()
end

function Instance.OnInstanceEntranceLock_Timer()
	-- play count down animation
	if(instance_entrance_lock_countdown_starttime) then
		local nil_starttime = false;
		local i;
		for i = 1, 10 do
			local npcModel = NPC.GetNpcModelFromIDAndInstance(379855, i);
			if(npcModel and npcModel:IsValid() == true) then
				local x, y, z = npcModel:GetPosition();
				local delta_time = ParaGlobal.timeGetTime() - instance_entrance_lock_countdown_starttime;
				y = 62.984199523926 - delta_time * 0.0002;
				npcModel:SetPosition(x, y, z);
				if(delta_time > 16000) then
					nil_starttime = true;
					npcModel:EnablePhysics(false);
				end
			end
		end
		if(nil_starttime == true) then
			instance_entrance_lock_countdown_starttime = nil;
		end
	end
end

function Instance.On_Timer()
	
	
    local worldpath = ParaWorld.GetWorldDirectory();
    
	if(worldpath == "worlds/Instances/HaqiTown_YYsDream_S1/") then
		local NPC = MyCompany.Aries.Quest.NPC;
		local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(301129);
		if(npcChar and npcChar:IsValid() == true) then
			local isAllArenaDefeated = false;
			local arena_data_map = MsgHandler.Get_arena_data_map();
			local arena_id, data;
			for arena_id, data in pairs(arena_data_map) do
				if(data.bIncludedAnyAliveMob) then
					isAllArenaDefeated = false;
					break;
				else
					isAllArenaDefeated = true;
				end
			end
			if(isAllArenaDefeated) then
				local x, y, z = npcChar:GetPosition();
				if(y < -5000) then
					npcChar:SetPosition(x, 63.940895080566, z);
				end
			else
				local x, y, z = npcChar:GetPosition();
				if(y >= -5000) then
					npcChar:SetPosition(x, -10000, z);
				end
			end
		end
	elseif(worldpath == "worlds/Instances/HaqiTown_YYsDream_S3/") then
		local NPC = MyCompany.Aries.Quest.NPC;
		local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(301169);
		if(npcChar and npcChar:IsValid() == true) then
			local isAllArenaDefeated = false;
			local arena_data_map = MsgHandler.Get_arena_data_map();
			local arena_id, data;
			for arena_id, data in pairs(arena_data_map) do
				if(data.bIncludedAnyAliveMob) then
					isAllArenaDefeated = false;
					break;
				else
					isAllArenaDefeated = true;
				end
			end
			if(isAllArenaDefeated) then
				local x, y, z = npcChar:GetPosition();
				if(y < -5000) then
					npcChar:SetPosition(x, 62.5, z);
				end
			else
				local x, y, z = npcChar:GetPosition();
				if(y >= -5000) then
					npcChar:SetPosition(x, -10000, z);
				end
			end
		end
	end

	local i = 1;
	for i = 1, 39 do
		local NPC = MyCompany.Aries.Quest.NPC;
		local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(301120 + i);
		if(npcChar and npcChar:IsValid() == true) then
			local dist_sq = npcChar:DistanceToPlayerSq();
			local player = ParaScene.GetPlayer();
			if(player and player:IsValid() and player.name ~= "invisible camera") then
				if(last_distancetoplayersq_t[i] and last_distancetoplayersq_t[i] >= 80 and dist_sq < 80) then
					if(i == 1 or i == 2 or i == 5 or i == 12 or i == 13 or i == 14 or i == 15 or i == 21 or i == 23 or i == 24 or i == 27 or 
						i == 30 or i == 32 or i == 33 or i == 34 or i == 35 or i == 36 or i == 37 or i == 38 or i == 39) then
						Instance.EnterInstance_PreDialog(301120 + i);
					elseif(i == 3 or i == 4 or i == 10 or i == 11 or i == 16 or i == 17 or i == 20 or i == 22 or i == 25 or i == 26 or 
						i == 28 or i == 29 or i == 31) then
						Instance.ExitInstance_PreDialog(301120 + i);
					end
				end
			end
			
			if(dist_sq < 10000) then
				last_distancetoplayersq_t[i] = dist_sq;
			end
		end
	end
end

function Instance.InstanceEntrance_Main()
end

function Instance.Entrance_HaqiTown_Christmas_Colorful_World()
	local game_setting = {game_type="PvE",guard_map={},leader_text="",min_level=50,keyname="HaqiTown_Christmas_Colorful_World",mode=3,requirement_tag="storm|fire|life|death|ice",max_level=55,max_players=1,name="——————",};
	LobbyClientServicePage.DoCreateGame(game_setting);
end

function Instance.EnterTreasureHouse_click(instance)
	local world_info = WorldManager:GetCurrentWorld();
	if(world_info and instance) then
		Map3DSystem.GSL_client:SendRealtimeMessage("sAriesInstanceEntry", {body="[Aries][ServerObject_Instance_Entry]IsEntryValid:"..world_info.name.."+"..instance});
	end
end

function Instance.EnterTreasureHouse_from_serverobject(instance_key, world_name, instance)
	Instance.EnterInstancePortal(instance_key, function ()
		Map3DSystem.GSL_client:SendRealtimeMessage("sAriesInstanceEntry", {body="[Aries][ServerObject_Instance_Entry]OnSuccessfulEnterEntry:"..world_name.."+"..instance});
	end, 1000) -- 1000 for delay m sec
end

function Instance.Buy3v3ticket()
	_guihelper.CloseMessageBox();
	WorldManager:GotoNPC(30559,function()
		NPCShopPage.ShowPage(30559,"menu1");
	end)
end

function Instance.PVP3v3Check(worldname)
	local canGet3v3Score = LobbyClientServicePage.PVP3v3GetScoreCheck();
	if(not canGet3v3Score) then
		_guihelper.MessageBox("你的3v3门票已经用完，不能参加3v3比赛,是否现在前去购买？",function (dialogResult)
			if(dialogResult == _guihelper.DialogResult.Yes) then
				WorldManager:GotoNPC(30559,function()
					NPCShopPage.ShowPage(30559,"menu1");
				end)
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	else
		local text = "";
		local bHas52108, _, __, copies52108 = System.Item.ItemManager.IfOwnGSItem(52108);
		text = text..string.format("本月战斗额外奖励场次：%d<br/>",copies52108 or 0);	

		local bHas50420, _, __, copies50420 = System.Item.ItemManager.IfOwnGSItem(50420);
		text = text..string.format("免费入场卷:%d<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/><br/>", copies50420 or 0, 50420);	

		local bHas52109, _, __, copies52109 = System.Item.ItemManager.IfOwnGSItem(52109);
		text = text..string.format("剩余入场卷:%d<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/><br/>", copies52109 or 0, 52109);	

		text = text.."<a onclick='MyCompany.Aries.Instance.Buy3v3ticket'>补充入场券<a/>";
		_guihelper.MessageBox(text,function (dialogResult)
			if(dialogResult == _guihelper.DialogResult.OK) then
				LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP");
			end
		end, _guihelper.MessageBoxButtons.OK);
		--LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP");
	end

	--[[
	local tag_gsid = LobbyClientServicePage.award_tag_gsid_for_3v3_kids;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(tag_gsid);
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(tag_gsid);
	local bHas, _, __, copies = hasGSItem(tag_gsid);
	if(not copies) then
		copies = 0
	end
	local maxweeklycount = gsItem.maxweeklycount;
	if(gsObtain.inweek >= maxweeklycount) then
		local text = "你本周获得3v3积分奖励的次数已用尽，但是战斗胜利仍然可以获得<pe:item gsid='17213' style='width:24px;height:24px;' isclickable='false'/>和<pe:item gsid='17577' style='width:24px;height:24px;' isclickable='false'/>。是否进行参加战斗？";
		_guihelper.MessageBox(text,function (dialogResult)
			if(dialogResult == _guihelper.DialogResult.Yes) then
				LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	else
		local remain_award_times = maxweeklycount - (gsObtain.inweek or 0);
		local reward_times = LobbyClientServicePage.Get3v3ScoreTimesPerDay();
		local text = string.format("你还剩余<font style='font-weight:bolder;color:#FF0000;font-size:13px;'>%d</font>张3v3门票，本周还可以获得<font style='font-weight:bolder;color:#FF0000;font-size:13px;'>%d</font>次3v3积分奖励。是否进行参加战斗？",copies,remain_award_times);
		_guihelper.MessageBox(text,function (dialogResult)
			if(dialogResult == _guihelper.DialogResult.Yes) then
				LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end
	--]]
end

function Instance.Join3V3OnePlayerTeam()
	if(TeamClientLogics:IsInTeam()) then
		_guihelper.MessageBox("你当前在队伍中，不能进行3v3单人排队！");
		return;
	end
	Instance.PVP3v3Check("HaqiTown_LafeierCastle_PVP_OneTeam");
end

function Instance.Join3V3TwoPlayerTeam()
	if(not TeamClientLogics:IsInTeam()) then
		_guihelper.MessageBox("你当前不在队伍中，3v3双人排队需要两人组队才能开启！");
		return;
	end
	Instance.PVP3v3Check("HaqiTown_LafeierCastle_PVP_TwoTeam");
end

function Instance.Join3V3ThreePlayerTeam()
	if(not TeamClientLogics:IsInTeam()) then
		_guihelper.MessageBox("你当前不在队伍中，3v3三人排队需要三人组队才能开启！");
		return;
	end
	local id = MyCompany.Aries.Friends.GetMyFamilyID();
	if(not id) then
		_guihelper.MessageBox("3v3三人排队模式需要加入家族才能参加！");
		return;
	end
	Instance.PVP3v3Check("HaqiTown_LafeierCastle_PVP_ThreeTeam");
end


-- directly enter instance world
-- same as Instance.EnterInstancePortal, except that without caring about whether we are in a team
function Instance.EnterInstancePortalDirect(world_name, enter_callback, delay_msec, is_local_instance)
	System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
			name = world_name,
			-- instance = world_name,
			-- if one wants to use local instance
			is_local_instance = is_local_instance, 
			-- nid = ProfileManager.GetNID()..tostring(math.random(10000, 99999)), 
			on_finish = function()
				if(enter_callback) then
					enter_callback();
				end
				local world = WorldManager:GetWorldInfo(world_name);
				if(world and world.motion_file)then
					CombatSceneMotionHelper.PlayCombatMotion_LoginWorld(world.motion_file);
				end
			end,
		});
end

-- enter a given instance world immediately. 
-- @param world_name: see AriesGameWorlds.onfig.xml, such as "HaqiTown_FireCavern"
-- @param is_local_instance: if true we will force local instance 
function Instance.EnterInstancePortal(world_name, enter_callback, delay_msec, is_local_instance)
	if(TeamMembersPage.IsTeamValid())then
		TeamWorldInstancePortal.Preload(world_name, enter_callback, delay_msec);
		--NOTE:move to TeamWorldInstancePortal.GoTo()
	else
		Instance.EnterInstancePortalDirect(world_name, enter_callback, delay_msec, is_local_instance);
	end
end

-- call this function when the user is inside an instance world. 
function Instance.LeaveInstancePortal()
	WorldManager:TeleportBack();
end

-- invoke the practice arena selection ui. 
-- @param has_battle_field: true to invlude the battle field button in the popup dialog page. 
function Instance.ShowPracticeArenaDialog(has_battle_field)
	-- @note: true to allow fair play since level 10
	local enable_fair_play = true;
	-- @note: true to enable practice ticket logic
	local need_tickets = false;
	-- 12003_FreePvPTicket
	-- 12004_ForSalePvPTicket
	if(need_tickets and (not hasGSItem(12003) and not hasGSItem(12004))) then
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(12003);
		if(gsObtain and gsObtain.inday == 0) then
			-- show the tip for free ticket 
			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			_guihelper.Custom_MessageBox("快到试练场管理员那领取免费PK入场券吧！",function(result)
				if(result == _guihelper.DialogResult.Yes)then
					local item;
					if(CommonClientService.IsKidsVersion())then
						item = {CameraPosition={10,0.51,-0.85,},Name="PK管理员",Position={20074.52,1.48,19651.13,},Desc="bla",}
						NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
						MyCompany.Aries.Help.MapHelp.GotoPlaceByItem(item);
					else
						local worldname,position,camera = WorldManager:GetWorldPositionByNPC(31042);
						WorldManager:GotoWorldPosition(worldname,position,camera);
					end
						
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
		else
			-- show the tip for shopping ticket 
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			_guihelper.Custom_MessageBox("没有PK入场券不能进入PK试炼场。",function(result)
				if(result == _guihelper.DialogResult.Yes)then
				else
					NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
					MyCompany.Aries.HaqiShop.ShowMainWnd("tabTool","5001");
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/GoShop_32bits.png; 0 0 153 49"});
		end
		-- show the tip for store purchase
		BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "没有PK入场券不能进入PK试炼场。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
		return;
	end
		
	NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
	local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
	local isHoliday = AntiIndulgenceArea.IsInHoliday()
		
	local time = Scene.GetElapsedSecondsSince0000()

	if(not LobbyClientServicePage.IsOpen_PvP_Practice()) then
		return;
	end

	local level = Combat.GetMyCombatLevel();
	if(enable_fair_play and level<10) then
		BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "你的等级太低了，PK试炼场需要10级才能进入。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
		return;
	elseif(not enable_fair_play  and level < 20 ) then
		BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "你的等级太低了，PK试炼场需要20级才能进入。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
		return;
	else
			
		local function SelectAndEnterArena(name)
			-- show page with advanced parameters
			local url = if_else(System.options.version == "kids", "script/apps/Aries/CombatRoom/PvPModeSelectPage.html", "script/apps/Aries/CombatRoom/Teen/PvPModeSelectPage.teen.html");
			if(has_battle_field) then
				url = format("%s?battlefield=true", url);
			end
			local params = {
				url = url, 
				name = "PvPModeSelectPage", 
				isShowTitleBar = false,
				DestroyOnClose = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				enable_esc_key = true,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -240/2,
					y = -200/2,
					width = 240,
					height = 200,
			}
			System.App.Commands.Call("File.MCMLWindowFrame", params);
			local pvp_mode_name = {
				["1v1"] = "1v1",
			}
			params._page.OnClose = function()
				local pvp_mode = params._page._pvp_mode;
				if(pvp_mode) then
					-- tricky: for 1v1, we will do more accurate match by moving level [48,50] to lengendary group
					if(pvp_mode == "battlefield")  then
						Instance.EnterInstance_BattlefieldClient();
					else
						if(enable_fair_play) then
							-- Instance.EnterInstancePortal(name);
							if(need_tickets) then
								Instance.EnterInstancePortal(name..(pvp_mode_name[pvp_mode] or ""));
							else
								if(pvp_mode_name[pvp_mode] == "1v1") then
									if(not TeamClientLogics:IsInTeam())then
										LobbyClientServicePage.DoAutoJoinRoom(name..(pvp_mode_name[pvp_mode] or ""), "PvP")
									else
										_guihelper.MessageBox("你在组队中, 请先离开现在的队伍");
									end
								else
									if(not TeamClientLogics:IsInTeam())then
										_guihelper.MessageBox("你还没有组队. <br/>确定需要系统帮你安排队友吗？", function(res)
											if(res and res == _guihelper.DialogResult.Yes) then
												LobbyClientServicePage.DoAutoJoinRoom(name..(pvp_mode_name[pvp_mode] or ""), "PvP")
											end
										end, _guihelper.MessageBoxButtons.YesNo)
									else
										LobbyClientServicePage.DoAutoJoinRoom(name..(pvp_mode_name[pvp_mode] or ""), "PvP", true)
									end
								end
							end
						else
							if(level>=50 and pvp_mode == "1v1")  then
								Instance.EnterInstancePortal("HaqiTown_TrialOfChampions_Legendary1v1");
							else
								Instance.EnterInstancePortal(name..(pvp_mode_name[pvp_mode] or ""));
							end
						end
					end
				end
			end;
		end
			
		LobbyClientServicePage.LoadRoomState(function(msg)
			if(msg and msg.status == "match_making")then
				_guihelper.MessageBox("你在竞技赛场排队当中，暂时不能进去！");
			else
				if(enable_fair_play) then
					if(level>=40) then
						SelectAndEnterArena("HaqiTown_TrialOfChampions_Intermediate");
						BroadcastHelper.PushLabel({id="arena_enter_text", label = "你参加的是(40级以上)竞技场", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
						--_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">你参加的是(30级以上)竞技场<br/>你现在是否进入？</div>]], function(res)
							--if(res and res == _guihelper.DialogResult.Yes) then
								--SelectAndEnterArena("HaqiTown_TrialOfChampions_Intermediate");
							--end
						--end, _guihelper.MessageBoxButtons.YesNo);
					else
						SelectAndEnterArena("HaqiTown_TrialOfChampions_Amateur");
						BroadcastHelper.PushLabel({id="arena_enter_text", label = "你参加的是(10-39级)竞技场", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
						--_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">你参加的是(10-30级)竞技场<br/>你现在是否进入？</div>]], function(res)
							--if(res and res == _guihelper.DialogResult.Yes) then
								--SelectAndEnterArena("HaqiTown_TrialOfChampions_Amateur");
							--end
						--end, _guihelper.MessageBoxButtons.YesNo);
					end
				else
					if(level>=50) then
						_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是高级PK试炼场(50-55级)，你现在就想去挑战吗？</div>]], function(res)
							if(res and res == _guihelper.DialogResult.Yes) then
								SelectAndEnterArena("HaqiTown_TrialOfChampions_Master");
							end
						end, _guihelper.MessageBoxButtons.YesNo);
					elseif(level>=40) then
						_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是中级PK试炼场(40-49级)，你现在就想去挑战吗？</div>]], function(res)
							if(res and res == _guihelper.DialogResult.Yes) then
								SelectAndEnterArena("HaqiTown_TrialOfChampions_Intermediate");
							end
						end, _guihelper.MessageBoxButtons.YesNo);
					elseif(level>=20) then
						_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是初级PK试炼场(20-39级)，你现在就想去挑战吗？</div>]], function(res)
							if(res and res == _guihelper.DialogResult.Yes) then
								SelectAndEnterArena("HaqiTown_TrialOfChampions_Amateur");
							end
						end, _guihelper.MessageBoxButtons.YesNo);
					end
				end
			end
		end)
	end
end

function Instance.GetTodayArenaPvPTicket(worldname)
	local Player = commonlib.getfield("MyCompany.Aries.Player");
	worldname = worldname or "";
    if(Player.LoadLocalData) then
		local nid = Map3DSystem.User.nid;
		local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
		local key = string.format("ArenaPvPTicket_Used_%s_%s_%s",tostring(nid),tostring(today),worldname);
        local used = Player.LoadLocalData(key, 0);
		return used;
    end
	return 0;
end
function Instance.GetTodayAvailableArenaPvPTicket(worldname)
	local Player = commonlib.getfield("MyCompany.Aries.Player");
	worldname = worldname or "";
    if(Player.LoadLocalData) then
		local nid = Map3DSystem.User.nid;
		local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
		local key = string.format("ArenaPvPTicket_Used_%s_%s_%s",tostring(nid),tostring(today),worldname);
        local used = Player.LoadLocalData(key, 0);
		return 20 - used;
    end
	return 0;
end


function Instance.IncTodayAvailableArenaPvPTicket(worldname)
	local Player = commonlib.getfield("MyCompany.Aries.Player");
	worldname = worldname or "";
    if(Player.LoadLocalData and Player.SaveLocalData) then
		local nid = Map3DSystem.User.nid;
		local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
		local key = string.format("ArenaPvPTicket_Used_%s_%s_%s",tostring(nid),tostring(today),worldname);
		local used = Player.LoadLocalData(key, 0);
		Player.SaveLocalData(key, used + 1);
	end
end

function Instance.EnterInstance_BattlefieldClient()
	
	if(System.options.version == "kids") then
		NPL.load("(gl)script/apps/Aries/CombatRoom/BattleFieldTeam.lua");
		local BattleFieldTeam = commonlib.gettable("MyCompany.Aries.CombatRoom.BattleFieldTeam");
		BattleFieldTeam.ShowPage();
		return;	
	end

	local time = Scene.GetElapsedSecondsSince0000()
	if(not System.options.isAB_SDK) then
		NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
		local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
		local isHoliday = AntiIndulgenceArea.IsInHoliday()
		
		if(isHoliday) then
			-- open every holiday
		else
			if(System.options.version == "kids") then
				if(not time or time < 9 * 60 * 60 or time > (22 * 60 * 60)) then
					_guihelper.MessageBox("英雄谷只在9:00~22:00开启。")
					return;
				end
			else
				if(not time or time < 19 * 60 * 60 or time > (23 * 60 * 60)) then
					_guihelper.MessageBox("英雄谷只在19:00~23:00开启。")
					return;
				end
			end
		end
		local bf_userdata = MyCompany.Aries.Player.LoadLocalData("BattlefieldClient");
		if(bf_userdata and not bf_userdata.is_finished) then
			local bf_cooldown_mins = 10;
			-- this fixed a bug that user logs out yesterday and login today.  
			if(bf_userdata.start_time and (time - bf_userdata.start_time) < bf_cooldown_mins*60 
				and time>bf_userdata.start_time) then
				_guihelper.MessageBox( format("对不起，由于你中途退出了英雄谷, 再过%d分钟才能再次进入。", 
					math.floor((bf_cooldown_mins*60 - (time - bf_userdata.start_time))/60)+1 ));
				return;
			end
		end
	end
	local text;
	if(System.options.version == "kids") then
		text = "参加英雄谷可以获得徽章兑换大量的<pe:item gsid = '17258' style = 'width:32px;height:32px;' isclickable = 'false' />和<pe:item gsid = '17213' style = 'width:32px;height:32px;' isclickable = 'false' />，每次战斗结束后会扣除10点精力值，你确定立即加入战斗吗？";
	else
		text = "英雄谷正在开发建设中, 你可以先睹为快！";
	end
	_guihelper.MessageBox(text, function()
		local name = "BattleField_ChampionsValley"
		local level = Combat.GetMyCombatLevel();
		if(level >= 50 and System.options.version ~= "teen") then
			name = "BattleField_ChampionsValley_Master"
		end
		if(System.options.version == "kids") then
			local beHas = hasGSItem(50416);
			if(beHas) then
				ItemManager.ExtendedCost(3601,nil,nil,function(msg) end,function(msg) end);
			end
		end
		
		MyCompany.Aries.Player.SaveLocalData("BattlefieldClient", {start_time=time})
		Instance.EnterInstancePortal(name);
	end);
end
function Instance.EnterInstance_PreDialog(npc_id, instance)
	npc_id = tonumber(npc_id);
	instance = tonumber(instance);
	local isAntiSystemIsEnabled = false;
	local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
	if(AntiIndulgenceArea) then
		isAntiSystemIsEnabled = AntiIndulgenceArea.IsAntiSystemIsEnabled();
	end

	if(BasicArena.IsImmortal()) then
		return;
	end
	
	--if(isAntiSystemIsEnabled) then
		--if(not (npc_id == 301133 or npc_id == 301134 or npc_id == 301135 or npc_id == 301138)) then
			---- skip AntiIndulgence test for pvp instance
			--BroadcastHelper.PushLabel({id="antiindulgence_tip", label = "你今天的战斗时间已经用完了，不能再进去战斗了，明天再来吧！", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			---- _guihelper.MessageBox([[<div style="margin-left:20px;margin-top:24px;">你今天的战斗时间已经用完了，不能再进去战斗了，明天再来吧！</div>]]);
			--return false;
		--end
	--end

	-- enter a room using lobby service. if not exist, we will enter using default logic. 
	local function AutoEnterPvERoom(worldname)
		if(TeamClientLogics:IsInTeam() and LobbyClientServicePage.GetRoomID()) then
			-- local worldname = LobbyClientServicePage.GetWorldNameByGameID(LobbyClientServicePage.GetRoomID());
			_guihelper.MessageBox("你已经在副本排队中, 如果想重新排队， 请先退出当前的队伍");
			return;
		end
		local search_func;
		if(CommonClientService.IsKidsVersion())then
			search_func = LobbyClientServicePage.AutoFindRoom;
		else
			search_func = LobbyClientServicePage.SearchModeWorld;
		end
		if(not search_func)then
			return
		end
		search_func(worldname, "PvE", function(user_level, games)
			if(games and #games>0) then
				local game_tmpl = games[1];
				local min_level = game_tmpl.min_level or user_level or 0;
				local max_level = game_tmpl.max_level or user_level or 100;
				if(user_level < min_level) then
					_guihelper.MessageBox(format([[这个副本适合%d级-%d级进入，你的等级太低了。快点提升你的等级吧！]], min_level, max_level));
				else
					Instance.EnterInstancePortal(worldname, nil, nil, true);
				end
			else
				LOG.std(nil,"info", "instance.main", "there is no room for %s. check config file", worldname)
				Instance.EnterInstancePortal(worldname);
			end
		end);
	end
	if(npc_id == 301121) then
		local s;
		if(CommonClientService.IsKidsVersion())then
			s = [[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是火鬃怪宝库，里面或许藏了许多宝贝，你现在就想去挑战吗？</div>]];
		else
			s = [[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是火焰山洞，里面或许藏了许多宝贝，你现在就想去挑战吗？</div>]];
		end
		_guihelper.MessageBox(s, function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				if(System.options.version == "teen") then
					AutoEnterPvERoom("HaqiTown_FireCavern");
				else
					Instance.EnterInstancePortalDirect("HaqiTown_FireCavern");
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301122) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">凤凰之影在神木空间的顶端，但神木空间里面危险重重，你确认要进去吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				if(System.options.version == "teen") then
					AutoEnterPvERoom("FlamingPhoenixIsland_TheGreatTree");
				else
					Instance.EnterInstancePortalDirect("FlamingPhoenixIsland_TheGreatTree");
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301141) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是冰封极地，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				if(System.options.version == "teen") then
					AutoEnterPvERoom("FrostRoarIsland_IceBearLair");
				else
					Instance.EnterInstancePortalDirect("FrostRoarIsland_IceBearLair");
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301143) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是落日神殿，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				if(System.options.version == "teen") then
					AutoEnterPvERoom("AncientEgyptIsland_LostTemple");
				else
					Instance.EnterInstancePortalDirect("AncientEgyptIsland_LostTemple");
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301144) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是大地冰熊的巢穴，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("FrostRoarIsland_IceKingCave");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301147) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是风暴之眼，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("FrostRoarIsland_StormEye");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301150) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是地狱之海，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("AncientEgyptIsland_PharaohFortress");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301152) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是彩虹岛暴熊宝库，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("Global_HaqiTown_TreasureHouse");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301153) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是火鸟岛暴熊宝库，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("Global_FlamingPhoenixIsland_TreasureHouse");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301154) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是寒冰岛暴熊宝库，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("Global_FrostRoarIsland_TreasureHouse");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301155) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是沙漠岛暴熊宝库，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("Global_AncientEgyptIsland_TreasureHouse");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301156) then
		InstanceMenuPage.ShowPage({
			title = "试炼之塔",
			{label = "试炼之塔-初阶", worldname = "HaqiTown_LightHouse_S1",},
			{label = "试炼之塔-中阶", worldname = "HaqiTown_LightHouse_S2",},
			{label = "试炼之塔-高阶", worldname = "HaqiTown_LightHouse_S3",},
		},function(selected_node)
			if(selected_node and selected_node.worldname)then
				AutoEnterPvERoom(selected_node.worldname);
			end
		end);
	elseif(npc_id == 301157) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是林海小径，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("HaqiTown_YYsDream_S2");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301158) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是前线地牢，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("DarkForestIsland_DeathDungeon");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301159) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是黑暗军团粮仓，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("DarkForestIsland_LegionGrainDepot");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301161) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是暴熊海贼团总部，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("DarkForestIsland_PirateNest");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301162) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是海贼团霸王号，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("DarkForestIsland_PirateSeamaster");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301163) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是遗忘沙漠，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("HaqiTown_HarshDesert");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301164) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是封印之地，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("DarkForestIsland_DeathHeadQuarter");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301165) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是熔岩炼狱，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("CloudFortressIsland_MoltenCore");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301166) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是前线营寨，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("CloudFortressIsland_BearChieftain");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301167) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是亚龙王巢穴，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("CloudFortressIsland_DragonLair");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301168) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是黑女王飞空艇，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("CloudFortressIsland_QueensBattleship");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	elseif(npc_id == 301170) then
		NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
		local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
		local provider = QuestClientLogics.GetProvider();
		-- 4、摄魂魔镜 副本传送门 增加之前秩序神殿进入条件的提示和逻辑“未完成前置任务：达纳斯的教导”（任务：达纳斯的教导   ID ：62253）
		local quest_id = 62253;
		if(not provider:HasFinished(quest_id)) then
			local templates = provider:GetTemplateQuests();
			local template = templates[quest_id];
			local title = "达纳斯的教导";
			if(template and template.Title) then
				title = template.Title;
			end
			-- tip
			NPL.load("(gl)script/ide/TooltipHelper.lua");
			local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
			BroadcastHelper.PushLabel({id="CannotEnterPalace_tip", label = "前置任务："..tostring(title).."，尚未完成！", 
					max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			return false;
		end
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道神秘的能量门就是摄魂魔境，你准备好了吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				AutoEnterPvERoom("CloudFortressIsland_FrighteningSoul");
			end
		end, _guihelper.MessageBoxButtons.YesNo);

		

		
	elseif(npc_id == 301169) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道门就来到梦魇禁地，你确认要进去吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				if(System.options.version == "teen") then
					--AutoEnterPvERoom("HaqiTown_YYsDream_S4");
				else
					--Instance.EnterInstancePortalDirect("HaqiTown_YYsDream_S4");
					local game_setting = {game_type="PvE",guard_map={},leader_text="",min_level=50,keyname="YYsNightmare_S4",mode=3,requirement_tag="storm|fire|life|death|ice",max_level=55,max_players=2,name="——————",};
					LobbyClientServicePage.DoCreateGame(game_setting);
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);

		
		
		
		
	elseif(npc_id == 9931318) then
		AutoEnterPvERoom("HaqiTown_CampfireChallenge");
		
		
	elseif(npc_id == 301125) then
		return true;
	elseif(npc_id == 301129) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">穿过这道门就来到梦幻寒冰岛，你确认要进去吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				if(System.options.version == "teen") then
					AutoEnterPvERoom("HaqiTown_YYsDream_S2");
				else
					Instance.EnterInstancePortalDirect("HaqiTown_YYsDream_S2");
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		
	elseif(npc_id == 301792) then
		return true;
	elseif(npc_id == 301132) then
		
		if(System.options.version == "teen") then
			_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是熔岩洞窟，里面或许藏了许多宝贝，你现在就想去挑战吗？</div>]], function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					AutoEnterPvERoom("FlamingPhoenixIsland_GoldenOgreTreasureHouse");
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		else
			_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是金鬃怪的宝库，里面或许藏了许多宝贝，你现在就想去挑战吗？</div>]], function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--AutoEnterPvERoom("FlamingPhoenixIsland_GoldenOgreTreasureHouse");
					Instance.EnterInstancePortalDirect("FlamingPhoenixIsland_GoldenOgreTreasureHouse");
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end
		
	elseif(npc_id >= 301133 and npc_id <= 301135) then
		Instance.ShowPracticeArenaDialog();

	elseif(npc_id == 301138) then
		
		local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
		if(ExternalUserModule:GetConfig().disable_pvp) then
			if(System.options.version == "teen") then
				_guihelper.MessageBox("本月红蘑菇赛场不开放, 下个赛季来参加吧");
			else
				_guihelper.MessageBox("本月红蘑菇赛场不开放, 下个赛季来参加吧");
			end
			return;
		end

		-- 12005_ArenaFreeTicket
		-- 12006_ForSaleArenaPvPTicket
		if(not hasGSItem(12005) and not hasGSItem(12006)) then
			local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(12005);
			if(gsObtain and gsObtain.inday == 0) then
				-- show the tip for free ticket 
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				_guihelper.Custom_MessageBox("快到赛场管理员那领取免费赛场门票吧！",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						local item;
						if(CommonClientService.IsKidsVersion())then
							item = {CameraPosition={15, 0.26, -0.82,},Name="赛场管理员",Position={20316.82, -2.36, 19688.65,},Desc="bla",}
							NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
							MyCompany.Aries.Help.MapHelp.GotoPlaceByItem(item);
						else
							local worldname,position,camera = WorldManager:GetWorldPositionByNPC(31119);
							WorldManager:GotoWorldPosition(worldname,position,camera, nil, nil, true);
						end
						
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
			else
				-- show the tip for shopping ticket 
				 NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				_guihelper.Custom_MessageBox("没有赛场门票不能进入红蘑菇赛场。",function(result)
					if(result == _guihelper.DialogResult.Yes)then
					else
						NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
						MyCompany.Aries.HaqiShop.ShowMainWnd("tabTool","5001");
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/GoShop_32bits.png; 0 0 153 49"});
			end
			if(CommonClientService.IsKidsVersion())then
				BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "去阳光海岸领取免费门票，或者去商城购买吧。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			end
			return;
		end
		
		local time = Scene.GetElapsedSecondsSince0000();
		local week, day = Scene.GetDayOfWeek();
		local n = 1;
		local level = Combat.GetMyCombatLevel();

		if(System.options.version == "teen") then
			--if(day == "Tue" or day == "Thu" or day == "Sat") then
				--BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "红蘑菇赛场周二、周四、周六不开放。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				--return;
			--end
			if(level >= 40) then
				if(not time or (time > (1 * 60 * 60) and time < (12 * 60 * 60)) or (time > (14 * 60 * 60) and time < (17 * 60 * 60))) then
					BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "红蘑菇赛场开放时间为12:00~14:00和17:00~次日1:00。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
					return;
				end
			end
		else
			--if(not time or time < (10 * 60 * 60) or time > (22 * 60 * 60)) then
				--BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "红蘑菇赛场开放时间为10:00~~22:00。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				--return;
			--end
			if(not time or time < (11 * 60 * 60) or time > (19 * 60 * 60)) then
				BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "红蘑菇赛场开放时间为11:00~19:00。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				return;
			end
		end

		if(System.options.version == "teen") then
			if(level < 10) then
				BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "你的等级太低了，红蘑菇赛场需要10级才能进入。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				return;
			end
		else
			if(level < 20) then
				BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "你的等级太低了，红蘑菇赛场需要20级才能进入。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				return;
			end
		end
		if(System.options.version == "teen") then
			InstanceMenuPage.ShowPage({
				title = "红蘑菇积分赛",
				{label = "红蘑菇1v1积分赛", worldname = "HaqiTown_RedMushroomArena_1v1",},
				{label = "红蘑菇2v2积分赛", worldname = "HaqiTown_RedMushroomArena_2v2",},
			},function(selected_node)
				if(selected_node and selected_node.worldname)then
					if(selected_node.worldname == "HaqiTown_RedMushroomArena_1v1")then
						PvPTicket_NPC.Join1v1();
					elseif(selected_node.worldname == "HaqiTown_RedMushroomArena_2v2")then
						PvPTicket_NPC.Join2v2();
					end
				end
			end);
		else
			-- show lobby page with filtered result
			LobbyClientServicePage.DirectShowPage("PvP",{ 
				HaqiTown_RedMushroomArena_1v1= true, 
				HaqiTown_RedMushroomArena_2v2 = true, 
				HaqiTown_RedMushroomArena_3v3 = true, 
				HaqiTown_RedMushroomArena_4v4 = true, 
			},true);
		end
		--_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:300px;">这里是红蘑菇赛场，你现在就想去挑战吗？</div>]], function(res)
			--if(res and res == _guihelper.DialogResult.Yes) then
				--Instance.EnterInstancePortal("HaqiTown_RedMushroomArena");
			--end
		--end, _guihelper.MessageBoxButtons.YesNo);

	end

	return false;
end

function Instance.ExitInstance_PreDialog(npc_id, instance)
	
	if(npc_id == 301126) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:280px;">你突破了重重考验，终于能进入8层了，现在就要进去吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				Instance.EnterInstancePortal("HaqiTown_LightHouse_S2");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		return false;
	elseif(npc_id == 301127) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:280px;">你突破了重重考验，终于能进入26层了，现在就要进去吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				Instance.EnterInstancePortal("HaqiTown_LightHouse_S3");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		return false;
	elseif(npc_id == 301128) then
		_guihelper.MessageBox([[<div style="margin-top:10px;margin-left:10px;width:280px;">你突破了重重考验，终于能进入61层了，现在就要进去吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				Instance.EnterInstancePortal("HaqiTown_LightHouse_S4");
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		return false;
	end

	local world_info = WorldManager:GetCurrentWorld();
	if(world_info and world_info.world_title) then
		_guihelper.MessageBox(string.format([[<div style="margin-top:10px;margin-left:10px;width:300px;">你确定离开【%s】吗？</div>]], world_info.world_title), function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				Instance.LeaveInstancePortal();
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end
	
	return false;
end


