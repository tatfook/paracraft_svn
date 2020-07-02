--[[
Title: Aries quest main entry
Author(s): WangTian
Date: 2009/6/20

Login to quest server and init the world scene status

---++ Aries Quest System
Aries quest system uses a complete item system implementation.

---++ Computing Analogy
Each NPC entity has various attributes, including:
	Apparaence: name, position, asset file, customizable info
	AI script: On_Perception, On_Framemove, .etc script and sentient radius
	Memory: items in each user's bag and a RAM memory on each item
	FSM: MCML dialog script containing all the dialog status
	
Apparaence information is broadcasted via "quest" server 

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/main.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");

-- create class
local libName = "Quest";
local Quest = commonlib.gettable("MyCompany.Aries.Quest");

NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPL.load("(gl)script/apps/Aries/Quest/GameObject.lua");

function Quest.RegisterBroadcastPlayerPositionTimer()
	NPL.load("(gl)script/ide/timer.lua");
	Quest.broadcast_timer = Quest.broadcast_timer or commonlib.Timer:new({callbackFunc = Quest.BroadcastPlayerPosition});
	Quest.broadcast_timer:Change(100, 1000);
end

function Quest.BroadcastPlayerPosition()
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	System.Quest.Client.BroadcastMyPosition(x, y, z);
end

-- appended notification quest list
Quest.AppendedNotificationQuestList = {};

-- NOTE: we assume that the quest can be triggered only once in one session
-- 
-- append the quest url if not appended before
-- @param url: quest url
-- @return: true if appended or false if has appended before other error
function Quest.AppendFeedIfNotAppended(url)
	if(url) then
		if(Quest.AppendedNotificationQuestList[url] ~= true) then
			Quest.AppendedNotificationQuestList[url] = true;
			local QuestArea = MyCompany.Aries.Desktop.QuestArea;
			QuestArea.AppendFeed({
				type = "AriesQuestMSG", 
				url = url,
			});
			-- send log information
			paraworld.PostLog({action = "dragonwish_trigger", url = url}, 
				"dragonwish_trigger_log", function(msg)
			end);
			return true;
		end
	end
	return false;
end

-- init the quest system
-- this function is called whenever the world is loaded
function Quest.AutoConnectQuestWorld()
	local worldDir = ParaWorld.GetWorldDirectory()
	
	local thisworld = string.match(string.lower(worldDir),"%/([0-9_a-z]*)%/$");
	NPL.load("(gl)script/apps/Aries/NPCs/NPCNoCombat_AI.lua");
	MyCompany.Aries.Quest.NPCAI.NPCnoCombat_AI.BuildNpcWordsXml(thisworld);		
	
	-- download the file first if the files don't exist
	LOG.std("", "system", "quest", "Loading NPC and Game objects for quest world %s", worldDir);

	if(worldDir == "worlds/MyWorlds/0806_homeland/") then
		Quest.GameObject.CreateGameObjectCharacter(90783, {
			name = "Andy的家",
			position = { 20039.505859375, 4.0995688438416, 19997.689453125 },
			facing = -0.73955643177032 + 3.14,
			scaling = 1,
			assetfile_char = "",
			assetfile_model = "model/06props/shared/pops/Instructions.x",
			replaceabletextures_model = {
				[1] = "Texture/Aries/Temp/AndysHome.png",
				[2] = "Texture/Aries/Temp/AndysHome.png",
			},
		});
	elseif(string.find(string.lower(worldDir), "homeland")) then
		LOG.std("", "system", "quest", "Loading NPC for homeland worlds");
		MyCompany.Aries.Scene.CreateHomelandAwayPortal();
	end
	
	
	if(worldDir == MyCompany.Aries.DefaultHomelandWorldDir.."/") then
		LOG.std("", "system", "quest", "Loading home land tutorial NPC");
		-- homeland tutorial NPC
		local params = { 
			name = "帕帕2",
			position = { 20070.865234375, -101, 19755.751953125 },
			facing = 1.0644947290421,
			--friend_npcs = "30011",
			scaling = 1.4,
			directscaling = true,
			timer_period = 200,
			assetfile_char = "character/v5/01human/PaPa/PaPa.x",
			assetfile_model = "model/common/aries_npc_boundingvolumn/aries_npc_boundingvolumn.x",
			main_script = "script/apps/Aries/NPCs/TownSquare/30171_Papa.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.Papa.main2();",
			--predialog_function = "MyCompany.Aries.Quest.NPCs.Papa.PreDialog2",
			on_timer = ";MyCompany.Aries.Quest.NPCs.Papa.On_Timer2();",
			--dialog_page = "script/apps/Aries/NPCs/TownSquare/30171_Papa_dialog.html",
			--selected_page = "script/apps/Aries/NPCs/TownSquare/30171_Papa_selected.html",
		}; -- 帕帕
		Quest.NPC.CreateNPCCharacter(30172, params);
	end
	
	NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;

	MyCompany.Aries.Quest.NPCList.LoadNPCInWorld(worldname);

	-- load for NPCs in world
	local npc_count = 0; 
	local npc_id, params;
	for npc_id, params in pairs(MyCompany.Aries.Quest.NPCList.NPCs) do
		npc_count = npc_count + 1;
		if(params.copies) then
			-- remove the copies that exceed the maxdailycount or maxweeklycount
			if(params.gsid_binding_maxcount_intimespan) then
				local gsid_binding = params.gsid_binding_maxcount_intimespan;
				local ItemManager = System.Item.ItemManager;
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid_binding);
				local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid_binding);
				if(gsItem and gsObtain) then
					local remainingDailyCount = 10000; --  just large enough for an NPC copies
					local remainingWeeklyCount = 10000; --  just large enough for an NPC copies
					if(gsItem.maxdailycount ~= 0) then
						remainingDailyCount = gsItem.maxdailycount - gsObtain.inday;
					end
					if(gsItem.maxweeklycount ~= 0) then
						remainingWeeklyCount = gsItem.maxweeklycount - gsObtain.inweek;
					end
					local canObtainCountToday = math.min(remainingDailyCount, remainingWeeklyCount);
					params.copies = math.min(canObtainCountToday, params.copies);
				end
			end
			
			-- create individual NPCs
			local i;
			for i = 1, params.copies do
				local position = params.positions[i];
				local facing = params.facings[i];
				local scaling = params.scaling;
				local rotation = params.rotation;
				if(params.scalings) then
					scaling = params.scalings[i];
				end
				if(params.rotations) then
					rotation = params.rotations[i];
				end
				local params = commonlib.deepcopy(params);
				params.copies = nil;
				params.positions = nil;
				params.facings = nil;
				params.scalings = nil;
				params.position = position;
				params.facing = facing;
				params.scaling = scaling;
				params.rotation = rotation;
				params.instance = i;
				Quest.NPC.CreateNPCCharacter(npc_id, params);
			end
		else
			Quest.NPC.CreateNPCCharacter(npc_id, params);
		end
	end
	
	-- load game object in world
	NPL.load("(gl)script/apps/Aries/Quest/GameObjectList.lua");
	if(System.options.version == "kids") then
		-- load game object ONLY in kids version
		-- teen version gameobjects will use gameserver normal update message as source
		MyCompany.Aries.Quest.GameObjectList.LoadGameObjectsInWorld(worldname);
	end
	
	local gameobject_count = 0;
	local gameobj_id, params;
	for gameobj_id, params in pairs(MyCompany.Aries.Quest.GameObjectList.GameObjects) do
		gameobject_count = gameobject_count + 1;
		if(params.copies) then
			-- create individual gameobjects
			local i;
			for i = 1, params.copies do
				local position = params.positions[i];
				local facing = params.facings[i];
				local scaling = params.scaling;
				if(params.scalings) then
					scaling = params.scalings[i];
				end
				local params = commonlib.deepcopy(params);
				params.copies = nil;
				params.positions = nil;
				params.facings = nil;
				params.scalings = nil;
				params.position = position;
				params.facing = facing;
				params.scaling = scaling;
				params.instance = i;
				Quest.GameObject.CreateGameObjectCharacter(gameobj_id, params);
			end
		else
			Quest.GameObject.CreateGameObjectCharacter(gameobj_id, params);
		end
	end
	LOG.std("", "system", "quest", "quest loaded %d NPCs and %d game objects in world %s", npc_count, gameobject_count, worldDir);

	--更新NPC显示任务的状态
	NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
	local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
	QuestClientLogics.UpdateNpcShowState();
end

-- init the quest system
-- this function is called in Aries application connect
function Quest.Init()
	
	-- init the respawn timer
	Quest.GameObject.InitRespawnTimer()
	
	-- npc ai memory
	NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
	
	--------------------------------------------------
	-- quest client login and update process
	-- 
	-- 1. login to the quest server
	-- 1.2 hear the reply and start the rest quest process
	-- 2. visualize, post player position at regular frequency
	-- 2.2 visualize, onreceive each {NPC, GameObj, GSItem} position, create or update the {NPC, GameObj, GSItem}
	-- 3. query quest list, 
	-- 3.2 query quest list, on receive quest list, update the quest area icons
	-- 4. interact with NPC, only talk with common NPC, query the NPC dialog MCML url
	-- 4.2 interact with NPC, receive the url and display the content, running like FSM
	-- 5. interact with GameObj, only pick common GameObj, send an immediate user player position
	-- 5.2 interact with GameObj, get issuccess, if true, update the bag if bNeedUpdate, if false, do nothing
	-- 6. interact with GSItem, only purchase common GSItem, directly purchase through local PurchaseItem
	--------------------------------------------------
	
	--------------------------------------------------
	-- quest server process
	-- 
	-- 1.1 receive the login from nid user, init the quest list, setup dialog MCML url for each NPC and return
	-- 2.1 visualize, on each posted position, calculate the nearby {NPC, GameObj, GSItem}, update by region
	-- 3.1 query quest list, return the available quest infos
	-- 4.1 interact with NPC, return the NPC dialog MCML url, NOTE: and return new MCML url as soon as the url is changed
	-- 5.1 interact with GameObj, purchase the GameObj for NO price, check if the distance to the obj is close enough
	--		return issuccess or not, and the contained bag & bNeedUpdate(some GameObj is hidden)
	--		check if the GameObj is global or user, if global broadcast the GameObj, if user, only update the user GameObj
	--------------------------------------------------
	
	--do return end
	--
	--NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");
	--System.Quest.Init();
	--
	---- send the test msg
	--System.Quest.SendToServer({TestCase = "TP", data="from client"});
	--
	--do return end
	--
	---- make these files accessible by other machines
	--NPL.AddPublicFile("script/kids/3DMapSystemQuest/Quest_Server.lua", 1);
	--NPL.AddPublicFile("script/kids/3DMapSystemQuest/Quest_Client.lua", 2);
	--
	--NPL.StartNetServer("192.168.0.102", "60022");
	--input = input or {};
	--
	---- add the server address
	--NPL.AddNPLRuntimeAddress({host = "192.168.0.102", port = "60011", nid = "questserver"})
	--
	--while( NPL.activate("(worker1)questserver:script/kids/3DMapSystemQuest/Quest_Server.lua", {TestCase = "TP", data="from client"}) ~=0 ) do end
	--
	--do return end
	
	do return end
	
	-- create each NPC character
	local char = ParaScene.GetCharacter("NPC:10106");
	if(char:IsValid() == false) then
		local obj_params = {};
		obj_params.name = "NPC:10106";
		obj_params.x = 20032.279296875;
		obj_params.y = 1.499951004982;
		obj_params.z = 19860.8671875;
		obj_params.AssetFile = "character/v5/02animals/PoliceDog/PoliceDog.x";
		obj_params.IsCharacter = true;
		-- skip saving to history for recording or undo.
		System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true,});
		char = ParaScene.GetCharacter("NPC:10106");
	end
	-- if character exists, update the position and rotation
	char:SetPosition(20032.279296875, 1.499951004982, 19860.8671875);
	char:SetFacing(1.2733715772629);
	--char:SetScaling();
	
	local char = ParaScene.GetCharacter("NPC:10106");
	System.ShowHeadOnDisplay(true, char, "NPC:汪汪狗");
	local playerChar = char:ToCharacter();
	playerChar:AssignAIController("face", "true");
	
	-- prevent head on text to be removed. 
	char:SetDynamicField("AlwaysShowHeadOnText", true);
	
	--------------------------------------------------------
	--player:SetField("SentientField", 3);--senses everybody including its own kind.
	char:SetField("Sentient Radius", System.options.CharClickDistSq); -- sense click distance characters
	--player:SetField("GroupID", 3);
	-- player:SetField("Sentient", true);
	--player:MakeGlobal(true);
	--------------------------------------------------------
	
	
	local char = ParaScene.GetCharacter("NPC:10001");
	System.ShowHeadOnDisplay(true, char, "NPC:抱抱龙");
	local playerChar = char:ToCharacter();
	playerChar:AssignAIController("face", "true");
	
	-- prevent head on text to be removed. 
	char:SetDynamicField("AlwaysShowHeadOnText", true);
	
	--------------------------------------------------------
	--player:SetField("SentientField", 3);--senses everybody including its own kind.
	char:SetField("Sentient Radius", System.options.CharClickDistSq); -- sense click distance characters
	--player:SetField("GroupID", 3);
	-- player:SetField("Sentient", true);
	--player:MakeGlobal(true);
	--------------------------------------------------------
	
	
	local char = ParaScene.GetCharacter("NPC:20000");
	if(char:IsValid() == false) then
		local obj_params = {};
		obj_params.name = "NPC:20000";
		obj_params.x = 19682.302734375;
		obj_params.y = 1.7123551368713;
		obj_params.z = 19942.7734375;
		obj_params.AssetFile = "character/v5/05test/MysteryAcinusTree1.x";
		obj_params.IsCharacter = true;
		-- skip saving to history for recording or undo.
		System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true,});
		char = ParaScene.GetCharacter("NPC:20000");
	end
	-- if character exists, update the position and rotation
	char:SetPosition(19682.302734375, 1.7123551368713, 19942.7734375);
	char:SetFacing(-0.57444131374359);
	--char:SetScaling();
	
	local char = ParaScene.GetCharacter("NPC:20000");
	System.ShowHeadOnDisplay(true, char, "NPC:神奇浆果树");
	local playerChar = char:ToCharacter();
	playerChar:AssignAIController("face", "true");
	
	-- prevent head on text to be removed. 
	char:SetDynamicField("AlwaysShowHeadOnText", true);
	
	--------------------------------------------------------
	--player:SetField("SentientField", 3);--senses everybody including its own kind.
	char:SetField("Sentient Radius", System.options.CharClickDistSq); -- sense click distance characters
	--player:SetField("GroupID", 3);
	-- player:SetField("Sentient", true);
	--player:MakeGlobal(true);
	--------------------------------------------------------
	
	---- create each NPC character
	--local char = ParaScene.GetCharacter("NPC:10106-1");
	--if(char:IsValid() == false) then
		--local obj_params = {};
		--obj_params.name = "NPC:10106-1";
		--obj_params.x = 241.53271484375;
		--obj_params.y = -0.0058922339230776;
		--obj_params.z = 252.46124267578;
		--obj_params.AssetFile = "character/v3/Pet/XHM/XHM.xml";
		--obj_params.IsCharacter = true;
		---- skip saving to history for recording or undo.
		--System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true,});
		--char = ParaScene.GetCharacter("NPC:10106-1");
	--end
	---- if character exists, update the position and rotation
	--char:SetPosition(241.53271484375, -0.0058922339230776, 252.46124267578);
	----char:SetFacing();
	----char:SetScaling();
	--
	--local char = ParaScene.GetCharacter("NPC:10106-1");
	--System.ShowHeadOnDisplay(true, char, "NPC:汪汪狗1");
	--local playerChar = char:ToCharacter();
	--playerChar:AssignAIController("face", "true");
	----------------------------------------------------------
	----player:SetField("SentientField", 3);--senses everybody including its own kind.
	--char:SetField("Sentient Radius", System.options.CharClickDistSq); -- sense click distance characters
	----player:SetField("GroupID", 3);
	---- player:SetField("Sentient", true);
	----player:MakeGlobal(true);
	----------------------------------------------------------
	
	
	
	
	
	---- start the quest server
	--NPL.StartNetServer("192.168.0.102", "64254");
	--local rts_name = "QuestServer";
	--local questserver_Runtime = NPL.CreateRuntimeState(rts_name, 0);
	--questserver_Runtime:Start();
	--NPL.activate(string.format("(%s)script/kids/3DMapSystemQuest/Quest_Server_Loop.lua", rts_name), {state = "Quest_servermode"});
	
	---- TODO: login server
	--local SID = "blablabla...";
	--System.Quest.Client.LoginServer(SID);
	--
	---- register the player move timer
	--Quest.RegisterBroadcastPlayerPositionTimer()
	
	
	
	
	
	
	
	
	--NPL.load("(gl)script/apps/Aquarius/Quest/Quest_ListWnd.lua");
	--MyCompany.Aquarius.Quest_ListWnd.Init();
	
	---- init window object
	--local _app = MyCompany.Aquarius.app._app;
	--local _wnd = _app:FindWindow("NPCQuestDialog") or _app:RegisterWindow("NPCQuestDialog", nil, Quest.MSGProc);
	--
	--NPL.load("(gl)script/ide/WindowFrame.lua");
	--
	--local sampleWindowsParam = {
		--wnd = _wnd, -- a CommonCtrl.os.window object
		--
		--
		--isShowTitleBar = true, -- default show title bar
		--isShowToolboxBar = false, -- default hide title bar
		--isShowStatusBar = false, -- default show status bar
		--
		--initialWidth = 300, -- initial width of the window client area
		--initialHeight = 400, -- initial height of the window client area
		--
		--initialPosX = 50,
		--initialPosY = 150,
		--
		--isPinned = true,
		--
		--maxWidth = 600,
		--maxHeight = 600,
		--minWidth = 300,
		--minHeight = 300,
		--
		--style = CommonCtrl.WindowFrame.DefaultStyle,
		--
		--alignment = "Free", -- Free|Left|Right|Bottom
		--
		--ShowUICallback = function () do return end end,
	--};
	
	--local text, icon, shortText = self:GetTextAndIcon();
	--sampleWindowsParam.text = text;
	----sampleWindowsParam.icon = icon;
	
	--local frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	--frame:Show2(true, nil, true);
	
	-- TODO: use BCS as creator object lock testing
	-- 201: BCS base
	--System.UI.Creator.SetGroupLock(true, 201);
	
	--local locks = MyCompany.Aquarius.app:ReadConfig("Locks", nil);
	--if(locks == nil) then
		--MyCompany.Aquarius.app:WriteConfig("Locks", {
			--[201001] = true,
			--[201002] = true,
			--[201003] = true,
			--[201004] = true,
			--[201005] = true,
			--[201006] = true,
			--[201007] = true,
			--[201008] = true,
			--[201009] = true,
			--[201010] = true,
		--});
	--end
	--locks = MyCompany.Aquarius.app:ReadConfig("Locks", nil);
	--local k, v;
	--for k, v in pairs(locks) do
		--if(v == true) then
			--Quest.LockItem(k);
		--elseif(v == false) then
			--Quest.UnlockItem(k);
		--end
	--end
end

-- get finished dragon quest count
function Quest.GetFinishedDragonQuestCount()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	
	-- 50011_WishLevel0_Complete
	-- 50014_WishLevel1_Complete
	-- 50017_WishLevel2_Complete
	-- 50020_WishLevel3_Complete
	-- 50023_WishLevel4_Complete
	-- 50026_WishLevel5_Complete
	-- 50029_WishLevel6_Complete
	-- 50032_WishLevel7_Complete
	-- 50035_WishLevel8_Complete
	-- 50051_WishLevel9_Complete
	-- 50038_WishRandom1_Complete
	-- 50216_WishLevel10_Complete
	-- 50219_WishLevel12_Complete
	
	-- count the completed quest count
	local completequestcount = 0;

	if(hasGSItem(50011)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50014)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50017)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50020)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50023)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50026)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50029)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50032)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50035)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50051)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50216)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50219)) then
		completequestcount = completequestcount + 1;
	end
	
	-- schedule
	-- 50189_WishElkFeed_Complete
	-- 50197_WishForSnowman_Complete
	-- 50200_TakeElkHome_Complete
	-- 50203_SpecialChristmasGift_Complete
	-- 50206_KnitChirstmasSock_Complete
	-- 50210_SnowShooting_Complete
	-- 50213_BuildIceHouse_Complete
	-- 50250_CookLaBaZhou_Complete
	if(hasGSItem(50189)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50197)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50200)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50203)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50206)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50210)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50213)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50250)) then
		completequestcount = completequestcount + 1;
	end
	if(hasGSItem(50309)) then
		completequestcount = completequestcount + 1;
	end
	
	--50120_WishRandom_CompleteCounter
	if(hasGSItem(50120)) then
		local _, __, ___, copies = hasGSItem(50120);
		completequestcount = completequestcount + copies;
	end
	
	return completequestcount;
end

-- get finished medal quest count
function Quest.GetFinishedMedalQuestCount()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	
	local completequestcount = 0;
	return completequestcount;
end

function Quest.GetItemBackground(id)
	if(id == nil) then
		return
	end
	local ID = math.floor(id/1000);
	local itemID = math.mod(id, 1000);
	
	return System.UI.Creator.GetItemBackground(ID, itemID);
end

function Quest.LockItem(id)
	if(id == nil) then
		return
	end
	local ID = math.floor(id/1000);
	local itemID = math.mod(id, 1000);
	System.UI.Creator.SetItemLock(true, ID, itemID);
end
function Quest.UnlockItem(id)
	if(id == nil) then
		return
	end
	local ID = math.floor(id/1000);
	local itemID = math.mod(id, 1000);
	System.UI.Creator.SetItemLock(false, ID, itemID);
	
	-- directly write back
	local locks = MyCompany.Aquarius.app:ReadConfig("Locks", {});
	locks[id] = false;
	MyCompany.Aquarius.app:WriteConfig("Locks", nil);
	MyCompany.Aquarius.app:WriteConfig("Locks", locks);
end

function Quest.OnQuestGiver_Bye(NPC_id)
	ParaUI.Destroy("Quest_DialogWnd");
	ParaUI.Destroy("Quest_DetailsWnd");
	ParaUI.Destroy("Quest_CompleteWnd");
	
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("NPCQuestDialog");
	if(_wnd ~= nil) then
		_wnd:ShowWindowFrame(false);
	end
end

-- quest dialog window message processor
function Quest.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		System.Quest.Client.QuestgiverBye();
	end
end


-- Quest ID and quest mapping
Quest.NPC_ID_Quest_Mapping = {};
-- Quest ID and queststatus mapping
Quest.NPC_QuestID_Status_Mapping = {};

-- NPC ID and name mapping
Quest.NPC_ID_Name_Mapping = {};
-- NPC name and ID mapping
Quest.NPC_Name_ID_Mapping = {};

function Quest.GetIDFromCharName(CharName)
	local Name = string.sub(CharName, 5);
	return Quest.NPC_Name_ID_Mapping[Name];
end

function Quest.GetCharNameFromID(NPC_id)
	return Quest.NPC_ID_Name_Mapping[NPC_id];
end


--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGHandler_Client.lua");
--local Quest_MSGHandler_Client = Map3DSystem.Quest.Client.MSGHandler;
--
---- SMSG_QUESTGIVER_BYE
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_BYE(Quest.OnQuestGiver_Bye);
--
--
--NPL.load("(gl)script/apps/Aquarius/Quest/Quest_NPCStatus.lua");
--
---- SMSG_QUESTGIVER_STATUS
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_STATUS(MyCompany.Aquarius.Quest_NPCStatus.OnQuestgiver_Status);
---- SMSG_NEARBY_NPCS
--Quest_MSGHandler_Client.RegisterHandler_SMSG_NEARBY_NPCS(MyCompany.Aquarius.Quest_NPCStatus.OnReceiveNearbyNPC);
--
--
--
--
--NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DialogWnd.lua");
--
---- SMSG_QUESTGIVER_QUEST_LIST
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_LIST(MyCompany.Aquarius.Quest_DialogWnd.OnRecvQuestList)
--
--
---- SMSG_QUESTGIVER_QUEST_COMPLETE
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_COMPLETE(MyCompany.Aquarius.Quest_DialogWnd.OnQuestComplete);
--
--
--
--
--NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DetailsWnd.lua");
--
---- SMSG_QUESTGIVER_QUEST_DETAILS
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_DETAILS(MyCompany.Aquarius.Quest_DetailsWnd.OnRecvDetails)
---- SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM(MyCompany.Aquarius.Quest_DetailsWnd.OnAcceptQuestResponse)
--
--
--
--
--NPL.load("(gl)script/apps/Aquarius/Quest/Quest_CompleteWnd.lua");
---- SMSG_QUESTGIVER_OFFER_REWARD
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_OFFER_REWARD(MyCompany.Aquarius.Quest_CompleteWnd.OnOfferReward)
--
--
--
--
--
--
---- SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER(function(id, count, CurrentDialog_NPC_id) 
		----_guihelper.MessageBox("SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER: goal_id: "..id.."\n");
		--log("SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER: goal_id: "..id.."\n");
		--
		----local name = Quest.GetCharNameFromID(CurrentDialog_NPC_id);
		----if(name) then
			----headon_speech.Speek("NPC:"..name, "恭喜你答对咯\n", 3);
		----end
	--end);
--
---- SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER
--Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER(function(id, CurrentDialog_NPC_id) 
		----_guihelper.MessageBox("SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER: goal_id: "..id.."\n");
		--log("SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER: goal_id: "..id.."\n");
		--
		----local name = Quest.GetCharNameFromID(CurrentDialog_NPC_id);
		----if(name) then
			----headon_speech.Speek("NPC:"..name, "这么简单都答错\n", 3);
		----end
	--end);