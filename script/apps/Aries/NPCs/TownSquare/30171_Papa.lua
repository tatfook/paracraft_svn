--[[
Title: Papa
Author(s): WangTian
Company: ParaEnging Co. & Taomee Inc.
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Test/30171_Papa.lua
------------------------------------------------------------
]]

-- create class
local libName = "Papa";
local Papa = commonlib.gettable("MyCompany.Aries.Quest.NPCs.Papa");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 50042_DoneMouseTutorial
-- 50043_NewbieQuest_Acquire
-- 50044_NewbieQuest_Complete
-- 50045_NewbieQuest_HasReadTimeMagazine
-- 50046_NewbieQuest_HasReadCitizenHandbook
-- 50047_NewbieQuest_HasUsedLocalMap

-- Papa.main
function Papa.main()
	Papa.RefreshQuestStatus()
end

local audio_state_mapping = {
	[1] = nil,
	[2] = "Audio/Haqi/CombatTutorial/MouseTutorial_state2.ogg",
	[3] = "Audio/Haqi/CombatTutorial/MouseTutorial_state3.ogg",
	[4] = "Audio/Haqi/CombatTutorial/MouseTutorial_state4.ogg",
	[5] = "Audio/Haqi/CombatTutorial/MouseTutorial_state5.ogg",
	[6] = "Audio/Haqi/CombatTutorial/MouseTutorial_state6.ogg",
};

function Papa.PlayMouseTutorialAudio(state)
	local asset_file = audio_state_mapping[state];
	if(asset_file) then
		local audio_src = AudioEngine.CreateGet(asset_file)
		audio_src.file = asset_file;
		audio_src:play(); -- then play with default. 
	end
end

function Papa.StopMouseTutorialAudio(state)
	local asset_file = audio_state_mapping[state];
	if(asset_file) then
		local audio_src = AudioEngine.CreateGet(asset_file)
		audio_src.file = asset_file;
		audio_src:stop(); -- then play with default. 
		audio_src:release();
	end
end

-- refresh quest status
function Papa.RefreshQuestStatus()
	local hasGSItem = hasGSItem;
	if(not hasGSItem(50042)) then
		-- haven't finished the mouse tutorial
		-- TODO: START the mouse tutorial
		Papa.StartMouseTutorialIfNot();
	elseif(hasGSItem(50042) and not hasGSItem(50043)) then
		-- finished the mouse tutorial, but haven't acquired the newbie quest
		-- fire a missile from player to papa
		local _papa = NPC.GetNpcCharacterFromIDAndInstance(30171);
		local _player = ParaScene.GetPlayer();
		if(_player and _player:IsValid() == true and _papa and _papa:IsValid() == true) then
			local fromX, fromY, fromZ = _player:GetPosition();
			fromY = fromY + 1;
			local toX, toY, toZ = _papa:GetViewCenter();
			local asset = ParaAsset.LoadParaX("", "character/common/pointer/pointer.x");
			ParaScene.FireMissile(asset, 10, fromX, fromY, fromZ, toX, toY, toZ);
		end
	elseif(hasGSItem(50043) and not hasGSItem(50044)) then
		-- acquired the newbie quest, but not finished
		-- refresh the newbiequest icon
		local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/TownSquare/30171_Papa_newbiequest_status.html", 
			"normal", "Texture/Aries/Quest/QuestNewbie_32bits.png;10 0 80 75", "入住登记", nil, 10, nil);

		Papa.isAcquireNewbieQuest = true;
		
		local function TalkToPapa(forcestate)
			-- show newbiequest help dialog
			local url = "script/apps/Aries/NPCs/TownSquare/30171_Papa_NewbieQuest_Help_dialog.html";
			if(forcestate) then
				url = url.."?forcestate="..forcestate;
			end
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = url, 
				app_key = MyCompany.Aries.app.app_key, 
				name = "NPC_Dialog", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				directPosition = true,
					align = "_lt",
						x = 41,
						y = 165,
						width = 204,
						height = 430,
			});
		end
		
		local dragonFetched = MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie();
		
		local function HideAllNewbieQuestArrows()
			-- cleat text tip
			ParaUI.Destroy("Papa_ShowTip");
			local Desktop = MyCompany.Aries.Desktop;
			Desktop.GUIHelper.ArrowPointer.HideArrow(5461);
			Desktop.GUIHelper.ArrowPointer.HideArrow(5462);
			Desktop.GUIHelper.ArrowPointer.HideArrow(5463);
			Desktop.GUIHelper.ArrowPointer.HideArrow(5464);
			Desktop.GUIHelper.ArrowPointer.HideArrow(5471);
			Desktop.GUIHelper.ArrowPointer.HideArrow(5472);
		end
		
		local Desktop = MyCompany.Aries.Desktop;
		
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnCloseTimeMagazine") then
					if(not hasGSItem(50045)) then
						ItemManager.PurchaseItem(50045, 1, function(msg) end, function(msg)
							if(msg) then
								CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseTimeMagazine_Papa_NewbieQuest_Help_dialog", 
									hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
								log("+++++++Purchase 50045_NewbieQuest_HasReadTimeMagazine return: +++++++\n")
								commonlib.echo(msg);
								--MyCompany.Aries.Quest.NPCs.Papa.RefreshQuestStatus();
								TalkToPapa(2);
							end
						end);
					end
				end
			end, 
			hookName = "CloseTimeMagazine_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnCloseReadingItem") then
					if(msg.gsid == 19002) then
						if(not hasGSItem(50046)) then
							ItemManager.PurchaseItem(50046, 1, function(msg) end, function(msg)
								if(msg) then
									CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseReadingItem_Papa_NewbieQuest_Help_dialog", 
										hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
									log("+++++++Purchase 50046_NewbieQuest_HasReadCitizenHandbook return: +++++++\n")
									commonlib.echo(msg);
									--MyCompany.Aries.Quest.NPCs.Papa.RefreshQuestStatus();
									TalkToPapa(3);
								end
							end);
						end
					end
				end
			end, 
			hookName = "CloseReadingItem_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnCloseLocalMap") then
					--Desktop.GUIHelper.ArrowPointer.HideArrow(5472);
					HideAllNewbieQuestArrows();
					if(not hasGSItem(50047)) then
						ItemManager.PurchaseItem(50047, 1, function(msg) end, function(msg)
							if(msg) then
								CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseLocalMap_Papa_NewbieQuest_Help_dialog", 
									hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
								log("+++++++Purchase 50047_NewbieQuest_HasUsedLocalMap return: +++++++\n")
								commonlib.echo(msg);
								--MyCompany.Aries.Quest.NPCs.Papa.RefreshQuestStatus();
								TalkToPapa(4);
							end
						end);
					end
				end
			end, 
			hookName = "CloseLocalMap_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
		if(not hasGSItem(50045)) then
			-- not 50045_NewbieQuest_HasReadTimeMagazine
			local function ContinueHook()
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OpenTimeMagazine_Papa_NewbieQuest_Help_dialog", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			end
			local Desktop = MyCompany.Aries.Desktop;
			Desktop.GUIHelper.ArrowPointer.ShowArrow(5461, 7, "_lt", 70, 80, 64, 64);
			Papa.ShowTip("阅读时报", "_lt", 150, 90, 100, 50);
			CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
				callback = function(nCode, appName, msg, value)
					if(msg.aries_type == "OnOpenTimeMagazine") then
						HideAllNewbieQuestArrows();
						ContinueHook();
					end
				end, 
				hookName = "OpenTimeMagazine_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
		elseif(not hasGSItem(50046)) then
			-- not 50046_NewbieQuest_HasReadCitizenHandbook
			local function ContinueHook3()
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OpenInventoryWnd_Papa_NewbieQuest_Help_dialog", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseInventoryWnd_Papa_NewbieQuest_Help_dialog", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ClickInventoryWndTab_Papa_NewbieQuest_Help_dialog", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ClickInventoryItem_Papa_NewbieQuest_Help_dialog", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			end
			local function ContinueHook2()
				CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
					callback = function(nCode, appName, msg, value)
						if(msg.aries_type == "OnClickInventoryItem") then
							if(msg.guid) then
								local item = System.Item.ItemManager.GetItemByGUID(msg.guid);
								if(item and item.guid > 0) then
									Desktop.GUIHelper.ArrowPointer.HideArrow(5464);
									HideAllNewbieQuestArrows();
									ContinueHook3();
								end
							end
						end
					end, 
					hookName = "ClickInventoryItem_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
			end
			local function ContinueHook()
				CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
					callback = function(nCode, appName, msg, value)
						if(msg.aries_type == "OnClickInventoryWndTab") then
							if(msg.class == "character" and msg.subclass == "reading") then
								--Desktop.GUIHelper.ArrowPointer.HideArrow(5463);
								--Desktop.GUIHelper.ArrowPointer.HideAllArrows();
								HideAllNewbieQuestArrows();
								Desktop.GUIHelper.ArrowPointer.ShowArrow(5464, 6, "_ct", -24 - 30, -186 + 10, 64, 64);
								ContinueHook2();
							else
								--Desktop.GUIHelper.ArrowPointer.HideAllArrows();
								HideAllNewbieQuestArrows();
								Desktop.GUIHelper.ArrowPointer.ShowArrow(5463, 6, "_ct", 260 - 90, 28 - 74 - 10, 64, 64);
							end
						end
					end, 
					hookName = "ClickInventoryWndTab_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
			end
			local Desktop = MyCompany.Aries.Desktop;
			Desktop.GUIHelper.ArrowPointer.ShowArrow(5462, 2, "_ctb", 158, -70, 64, 64);
			Papa.ShowTip("打开背包", "_ctb", 290, -80, 100, 50);
			CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
				callback = function(nCode, appName, msg, value)
					if(msg.aries_type == "OnOpenInventoryWnd") then
						HideAllNewbieQuestArrows();
						Desktop.GUIHelper.ArrowPointer.ShowArrow(5463, 6, "_ct", 260 - 90, 28 - 74 - 10, 64, 64);
						ContinueHook();
					end
				end, 
				hookName = "OpenInventoryWnd_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
			CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
				callback = function(nCode, appName, msg, value)
					if(msg.aries_type == "OnCloseInventoryWnd") then
						--Desktop.GUIHelper.ArrowPointer.HideAllArrows();
						HideAllNewbieQuestArrows();
						Desktop.GUIHelper.ArrowPointer.ShowArrow(5462, 2, "_ctb", 158, -70, 64, 64);
						Papa.ShowTip("打开背包", "_ctb", 290, -80, 100, 50);
						ContinueHook();
					end
				end, 
				hookName = "CloseInventoryWnd_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
		elseif(not hasGSItem(50047)) then
			-- 50047_NewbieQuest_HasUsedLocalMap
			local function ContinueHook()
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OpenLocalMap_Papa_NewbieQuest_Help_dialog", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			end
			local Desktop = MyCompany.Aries.Desktop;
			Desktop.GUIHelper.ArrowPointer.ShowArrow(5471, 1, "_lb", 80, -150, 64, 64);
			Papa.ShowTip("打开地图", "_lb", 160, -150, 100, 50);
			CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
				callback = function(nCode, appName, msg, value)
					if(msg.aries_type == "OnOpenLocalMap") then
						HideAllNewbieQuestArrows();
						--Desktop.GUIHelper.ArrowPointer.ShowArrow(5472, 2, "_ct", -180, -300, 64, 64);
						ContinueHook();
					end
				end, 
				hookName = "OpenLocalMap_Papa_NewbieQuest_Help_dialog", appName = "Aries", wndName = "main"});
		elseif(dragonFetched == false) then
			TalkToPapa(5);
		end
	elseif(hasGSItem(50044)) then
		-- finished the newbie quest
		-- hide the newbiequest icon
		local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/TownSquare/30171_Papa_newbiequest_status.html");
		Papa.isFinishNewbieQuest = true;
		
		-- unhook all hooks
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseTimeMagazine_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseReadingItem_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseLocalMap_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OpenTimeMagazine_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OpenInventoryWnd_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CloseInventoryWnd_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ClickInventoryWndTab_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "ClickInventoryItem_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OpenLocalMap_Papa_NewbieQuest_Help_dialog", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	end
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldClosing") then
				-- first unhook the world closing
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_Papa", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				-- clear text tip
				ParaUI.Destroy("Papa_ShowTip");
			end
		end, 
		hookName = "WorldClosing_Papa", appName = "Aries", wndName = "main"});
end

-- Papa timer
function Papa.On_Timer()
	if(Papa.isFinishNewbieQuest == true) then
		return;
	end
	if(Papa.isAcquireNewbieQuest ~= true) then
		Papa.RefreshQuestStatus();
	end
end

Papa.isMouseTutorialStarted = nil;

function Papa.StartMouseTutorialIfNot()
	if(Papa.isMouseTutorialStarted ~= true) then
		Papa.isMouseTutorialStarted = true;

		-- hide all desktop areas
		MyCompany.Aries.Desktop.HideAllAreas();

		-- destroy previous one
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30171_Papa_MouseTutorial_for_combattutorial.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "NPC_Dialog", 
			bDestroy=true});

		-- show tutorial
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30171_Papa_MouseTutorial_for_combattutorial.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "NPC_Dialog", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			zorder = 2,
			directPosition = true,
				align = "_lt",
					x = 41,
					y = 165,
					width = 204,
					height = 400,
		});
	end
end

function Papa.PreDialog()
	return true;
end

------------------------------------------------
----			Homeland Tutorial			----
------------------------------------------------

-- state 1: welcome home
-- state 2: let's learn to plant
-- state 3: click on parterre
-- state 4: select a seed
-- state 5: you can water and debug
-- state 6: finish plant
-- state 7: let's learn to deco
-- state 8: click on warehouse
-- state 9: click on item
-- state 10: double click to move it
-- state 11: move it to a proper place
-- state 12: click to rotate
-- state 13: click save to finish deco
-- state 14: congrates

-- 50116_NewbieQuest_Homeland_CompletePlant
-- 50117_NewbieQuest_Homeland_CompleteDeco
-- 50118_NewbieQuest_Homeland_CompleteAll

-- Papa.main2
function Papa.main2()
	-- TODO: consistency check if no item avaiable but quest requirement is not done yet
	local completed = false;
	--50118_NewbieQuest_Homeland_CompleteAll
	if(hasGSItem(50118)) then
		completed = true;
	end
	if(completed) then
		-- complete the homeland tutorial
		MyCompany.Aries.Quest.NPCAIMemory.ClearMemory(30172);
		return;
	end
	local inMyHomeland = System.App.HomeLand.HomeLandGateway.IsInMyHomeland();
	if(not inMyHomeland) then
		-- not in user's own homeland
		MyCompany.Aries.Quest.NPCAIMemory.ClearMemory(30172);
		return;
	else
		-- incomplete the homeland tutorial
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
		-- default from the start
		memory.state = 1;
		--50116_NewbieQuest_Homeland_CompletePlant
		if(true) then -- if(hasGSItem(50116)) then
			memory.state = 7;
		end
		Papa.RefreshQuestStatus2();
		-- reset visibles
		Papa.lastNPCDialogVisible = false;
		Papa.lastSeedWndVisible = false;
		Papa.lastPlantWndVisible = false;
		Papa.lastHomelandOutdoorWndVisible = false;
		
		-- hook into OnWorldClosing
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnWorldClosing") then
					Papa.ClearAllHints();
					MyCompany.Aries.Quest.NPCAIMemory.ClearMemory(30172);
					CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_PaPaTutorial", 
						hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
					CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OnMCMLWindowFrameInvisible_PaPaTutorial", 
						hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				end
			end, 
			hookName = "WorldClosing_PaPaTutorial", appName = "Aries", wndName = "main"});
			
		-- hook into OnWorldClosing
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnMCMLWindowFrameInvisible") then
commonlib.applog("====Papa.OnMCMLWindowFrameInvisible====")
commonlib.echo(msg);
					if(msg.name == "NPC_Dialog") then
						-- dialog is closed
						local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
commonlib.echo(memory);
						if(memory.state == 1) then
							---- check two requirements
							--if(plant) then
								--memory.state = 2;
							--elseif(deco) then
								--memory.state = 7;
							--end
							memory.state = 2;
							Papa.RefreshQuestStatus2();
						elseif(memory.state == 2) then
							memory.state = 3;
							Papa.RefreshQuestStatus2();
						elseif(memory.state == 5) then
							memory.state = 6;
							Papa.RefreshQuestStatus2();
						elseif(memory.state == 6) then
							memory.state = 7;
							Papa.RefreshQuestStatus2();
						elseif(memory.state == 7) then
							memory.state = 8;
							Papa.RefreshQuestStatus2();
						end
					elseif(msg.name == "PlantGridViewPage.ShowPage") then
						-- SeedWnd is closed
						local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
commonlib.echo(memory);
						if(memory.state == 4) then
							memory.state = 3;
							Papa.RefreshQuestStatus2();
						end
					--elseif(msg.name == "PlantViewPage.ShowPage") then
						---- NOTE andy 2009/11/10: little tricky bug
						----			targetarea click will close the npc_dialog if the selected object is not valid
						----			which will then be invoked right after Papa.RefreshQuestStatus2() is called
						----			Delay the refresh by a time slice
						--UIAnimManager.PlayCustomAnimation(200, function(elapsedTime)
							--if(elapsedTime == 200) then
								---- PlantWnd is closed
								--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
								--if(memory.state == 5) then
									--memory.state = 6;
									--Papa.RefreshQuestStatus2();
								--end
							--end
						--end);
					elseif(msg.name == "MyHomelandOutdoorPage.ShowPage") then
						-- HomelandOutdoorWnd is closed
						local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
commonlib.echo(memory);
						if(memory.state == 9) then
							memory.state = 8;
							Papa.RefreshQuestStatus2();
						end
					elseif(msg.name == "NormalViewPage.ShowPage") then
						-- NormalViewPage is closed
						local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
commonlib.echo(memory);
						if(memory.state == 12) then
							memory.state = 13;
							Papa.RefreshQuestStatus2();
						end
					end
				end
			end, 
			hookName = "OnMCMLWindowFrameInvisible_PaPaTutorial", appName = "Aries", wndName = "main"});
	end
end

-- Papa.RefreshQuestStatus2
function Papa.RefreshQuestStatus2()
	
commonlib.applog("====Papa.RefreshQuestStatus2====")
	Papa.ClearAllHints();
	local Desktop = MyCompany.Aries.Desktop;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
commonlib.echo(memory)
	if(memory.state == 1) then
		Papa.ShowHomelandTutorialDialog();
	elseif(memory.state == 2) then
		Papa.ShowHomelandTutorialDialog();
	elseif(memory.state == 3) then
		Papa.ShowHomelandParterres();
		Papa.ShowTip("点击小花圃", "_lt", 150, 90, 100, 50);
		Papa.HookPlant();
	elseif(memory.state == 4) then
		Papa.ShowTip("选择一颗种子", "_lt", 150, 90, 130, 50);
		Desktop.GUIHelper.ArrowPointer.ShowArrow(4562, 4, "_lt", 100, 140, 64, 64);
		Papa.HookPlant();
	elseif(memory.state == 5) then
		--Papa.ShowTip("通过浇水、除虫照顾植物，结果之后别忘了来收获", "_lt", 150, 90, 340, 50);
		Desktop.GUIHelper.ArrowPointer.ShowArrow(4563, 4, "_lt", 360, 115, 64, 64);
		Papa.ShowHomelandTutorialDialog();
	elseif(memory.state == 6) then
		Papa.ShowHomelandTutorialDialog();
	elseif(memory.state == 7) then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/PlantView_New.lua");
		MyCompany.Aries.Inventory.PlantViewPage_New.ClosePage()
		Papa.ShowHomelandTutorialDialog();
	elseif(memory.state == 8) then
		Papa.ShowTip("打开家园仓库", "_rt", -250, 260, 130, 50);
		Desktop.GUIHelper.ArrowPointer.ShowArrow(4564, 6, "_rt", -170, 320, 64, 64);
		Papa.HookOpenWareHouse();
	elseif(memory.state == 9) then
		Papa.ShowTip("单击物品，从仓库中拿出来", "_ctb", -225, -170, 200, 50);
		Desktop.GUIHelper.ArrowPointer.ShowArrow(4565, 2, "_ctb", -277, -100, 64, 64);
		Papa.HookItemMovedFromStoreToHomeland();
	elseif(memory.state == 10) then
		Papa.ShowTip("单击物品，可以移动它", "_ctt", 0, 90, 180, 50);
		-- show object pointer
		Papa.ShowNewlyCreatedItemPointer();
		-- hook object pick
		Papa.HookItemPicked();
	elseif(memory.state == 11) then
		Papa.ShowTip("移动到合适的位置，单击地面，将它放下", "_ctt", 0, 90, 300, 50);
		-- hook object down
		Papa.HookItemDropped();
	elseif(memory.state == 12) then
		Papa.ShowTip("使用按钮旋转物品", "_lt", 170, 220, 150, 50);
		Desktop.GUIHelper.ArrowPointer.ShowArrow(4566, 4, "_lt", 140, 270, 64, 64);
		-- hook object rotate left or right
		Papa.HookItemRotated();
	elseif(memory.state == 13) then
		Papa.ShowTip("装扮完成后，点击保存", "_rt", -290, 370, 170, 50);
		Desktop.GUIHelper.ArrowPointer.ShowArrow(4568, 6, "_rt", -170, 430, 64, 64);
		-- hook save
		Papa.HookSaveHomeland();
	elseif(memory.state == 14) then
		Papa.ShowHomelandTutorialDialog();
	end
end

function Papa.ClearAllHints()
	-- clost npc dialog
	System.App.Commands.Call("File.MCMLWindowFrame", {
		name="NPC_Dialog", app_key = MyCompany.Aries.app.app_key, bShow = false});
	-- clear all parterre position effects
	local i = 1;
	for i = 1, 100 do
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.DestroyEffect("ShowHomelandParterres"..i);
	end
	-- clear NewlyCreatedItemPointer
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.DestroyEffect("NewlyCreatedItemPointer");
	-- cleat text tip
	ParaUI.Destroy("Papa_ShowTip");
	-- unregister hook
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.ShowHomelandParterreSelected", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.SeedPlanted", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.OnOpenWareHouse", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.OnItemMovedFromStoreToHomeland", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.OnHomelandItemPicked", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.OnHomelandItemDropped", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.OnHomelandItemRotated", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Papa.OnHomelandSaved", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	-- clear arrows
	local Desktop = MyCompany.Aries.Desktop;
	Desktop.GUIHelper.ArrowPointer.HideArrow(4562);
	Desktop.GUIHelper.ArrowPointer.HideArrow(4563);
	Desktop.GUIHelper.ArrowPointer.HideArrow(4564);
	Desktop.GUIHelper.ArrowPointer.HideArrow(4565);
	Desktop.GUIHelper.ArrowPointer.HideArrow(4566);
	Desktop.GUIHelper.ArrowPointer.HideArrow(4568);
end

function Papa.ShowHomelandTutorialDialog()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/TownSquare/30171_Papa_HomelandTutorial.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "NPC_Dialog", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		allowDrag = false,
		directPosition = true,
			align = "_lt",
				x = 41,
				y = 165,
				width = 204,
				height = 320,
	});
end

function Papa.ShowHomelandParterres()
	----local seedgridlist = GetSeedGridInfo();
	
	---- hook into pet feed
	--CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		--callback = function(nCode, appName, msg, value)
			--if(msg.aries_type == "GetSeedGridInfo") then
				--commonlib.echo(msg.seedgrid_list);
			--end
		--end, 
		--hookName = "Papa.ShowHomelandParterres", appName = "Aries", wndName = "main"});
	local info = Map3DSystem.App.HomeLand.HomeLandGateway.GetUnLinkedSeedGridInfo()
	---- suppose we have the homeland parterre positions
	--local positions = {{19951.666015625, 30.149089813232, 20308.390625},
						--{19951.076171875, 30.143800735474, 20315.201171875},
						--{19967.076171875, 30.145341873169, 20307.244140625},
						--{19971.998046875, 30.145845413208, 20314.1640625},
						--{19966.013671875, 30.143644332886, 20317.912109375}};
	if(info) then
		local i = 1;
		for i = 1, #(info) do
			local params = {
				--asset_file = "character/v5/temp/Effect/Invisibility_Impact_Base.x",
				asset_file = "character/common/tutorial_pointer/tutorial_pointer.x",
				binding_obj_name = nil,
				scale = 2,
				start_position = {info[i].x, info[i].y + 0.5, info[i].z},
				duration_time = 9000000,
				force_name = "ShowHomelandParterres"..i,
				begin_callback = function() 
					end,
				end_callback = nil,
			};
			local EffectManager = MyCompany.Aries.EffectManager;
			EffectManager.CreateEffect(params);
			
			-- only show one homeland parterre
			break;
		end
		
		-- hook into SeedGridSelected
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "SeedGridSelected") then
					local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
					if(memory.state == 3) then
						memory.state = 4;
						Papa.RefreshQuestStatus2();
					end
				end
			end, 
			hookName = "Papa.ShowHomelandParterreSelected", appName = "Aries", wndName = "homeland"});
	end
end

function Papa.ShowTip(text, align, left, top, width, height)
	ParaUI.Destroy("Papa_ShowTip");
	local _tip_cont = ParaUI.CreateUIObject("container", "Papa_ShowTip", align, left, top, width, height);
	_tip_cont.background = "Texture/Aries/Quest/Dialog_BG_32bits.png: 31 31 31 31";
	_tip_cont.enabled = false;
	_tip_cont:AttachToRoot();
	local _text = ParaUI.CreateUIObject("button", "text", "_lt", 0, 0, width, height);
	_text.text = text;
	_text.background = "";
	_tip_cont:AddChild(_text);
	_guihelper.SetFontColor(_text, "#d58302");
end

function Papa.HookPlant()
	-- hook into SeedPlanted
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "SeedPlanted") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 3 or memory.state == 4) then
					memory.state = 5;
					Papa.RefreshQuestStatus2();
					
					-- 50116_NewbieQuest_Homeland_CompletePlant
					ItemManager.PurchaseItem(50116, 1, function(msg) end, function(msg) 
						log("+++++++Purchase item #50116_NewbieQuest_Homeland_CompletePlant return: +++++++\n")
						commonlib.echo(msg);
					end, nil, "none", true);
				end
			end
		end, 
		hookName = "Papa.SeedPlanted", appName = "Aries", wndName = "homeland"});
end

function Papa.HookOpenWareHouse()
	-- hook into SeedPlanted
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnOpenWareHouse") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 8) then
					memory.state = 9;
					Papa.RefreshQuestStatus2();
				end
			end
		end, 
		hookName = "Papa.OnOpenWareHouse", appName = "Aries", wndName = "homeland"});
end

local newlyCreatedObjPositionX;
local newlyCreatedObjPositionY;
local newlyCreatedObjPositionZ;
function Papa.HookItemMovedFromStoreToHomeland()
	-- hook into SeedPlanted
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnItemMovedFromStoreToHomeland") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 9) then
					memory.state = 10;
					newlyCreatedObjPositionX = msg.x;
					newlyCreatedObjPositionY = msg.y;
					newlyCreatedObjPositionZ = msg.z;
					Papa.RefreshQuestStatus2();
					-- 50117_NewbieQuest_Homeland_CompleteDeco
					ItemManager.PurchaseItem(50117, 1, function(msg) end, function(msg) 
						log("+++++++Purchase item #50117_NewbieQuest_Homeland_CompleteDeco return: +++++++\n")
						commonlib.echo(msg);
					end, nil, "none", true);
					-- 50118_NewbieQuest_Homeland_CompleteAll
					ItemManager.PurchaseItem(50118, 1, function(msg) end, function(msg) 
						log("+++++++Purchase item #50118_NewbieQuest_Homeland_CompleteAll return: +++++++\n")
						commonlib.echo(msg);
					end, nil, "none", true);
				end
			end
		end, 
		hookName = "Papa.OnItemMovedFromStoreToHomeland", appName = "Aries", wndName = "homeland"});
end

function Papa.ShowNewlyCreatedItemPointer()
	local position = {ParaScene.GetPlayer():GetPosition()};
	if(newlyCreatedObjPositionX and newlyCreatedObjPositionY and newlyCreatedObjPositionZ) then
		position = {newlyCreatedObjPositionX, newlyCreatedObjPositionY + 1, newlyCreatedObjPositionZ}
	end
	
	local params = {
		asset_file = "character/common/headarrow/headarrow.x",
		binding_obj_name = nil,
		start_position = position,
		duration_time = 9000000,
		force_name = "NewlyCreatedItemPointer",
		begin_callback = function() 
			end,
		end_callback = nil,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
end

function Papa.HookItemPicked()
	-- hook into HomelandItemPicked
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnHomelandItemPicked") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 10) then
					memory.state = 11;
					Papa.RefreshQuestStatus2();
				end
			end
		end, 
		hookName = "Papa.OnHomelandItemPicked", appName = "Aries", wndName = "homeland"});
end

function Papa.HookItemDropped()
	-- hook into HomelandItemDropped
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnHomelandItemDropped") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 11) then
					memory.state = 12;
					Papa.RefreshQuestStatus2();
				end
			end
		end, 
		hookName = "Papa.OnHomelandItemDropped", appName = "Aries", wndName = "homeland"});
end

function Papa.HookItemRotated()
	-- hook into HomelandItemRotated
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnHomelandItemRotated") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 12) then
					memory.state = 13;
					Papa.RefreshQuestStatus2();
				end
			end
		end, 
		hookName = "Papa.OnHomelandItemRotated", appName = "Aries", wndName = "homeland"});
end

function Papa.HookSaveHomeland()
	-- hook into HomelandSaved
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnHomelandSaved") then
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30172);
				if(memory.state == 13) then
					memory.state = 14;
					Papa.RefreshQuestStatus2();
				end
			end
		end, 
		hookName = "Papa.OnHomelandSaved", appName = "Aries", wndName = "homeland"});
end

-- Papa timer2
function Papa.On_Timer2()
end


--local hook_msg = { aries_type = "SeedPlanted", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--
--local hook_msg = { aries_type = "OnOpenWareHouse", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--
--local hook_msg = { aries_type = "OnItemMovedFromStoreToHomeland", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--local hook_msg = { aries_type = "OnHomelandItemPicked", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--local hook_msg = { aries_type = "OnHomelandItemDropped", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--local hook_msg = { aries_type = "OnHomelandItemRotated", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--
--local hook_msg = { aries_type = "OnHomelandSaved", wndName = "homeland"};
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);


-------------- schedule labazhou --------------

function Papa.GiveLaBaZhou()
	local i = Papa.GetDailyIndex();
	if(i == 1) then
		-- 208 LaBaZhou_PapaReward_30028_RockRoundBasin
		ItemManager.ExtendedCost(208, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 208: LaBaZhou_PapaReward_30028_RockRoundBasin return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 2) then
		-- 209 LaBaZhou_PapaReward_30053_PurpleLianaBarrier 
		ItemManager.ExtendedCost(209, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 209: LaBaZhou_PapaReward_30053_PurpleLianaBarrier return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 3) then
		-- 210 LaBaZhou_PapaReward_30052_BambooBarrier 
		ItemManager.ExtendedCost(210, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 210: LaBaZhou_PapaReward_30052_BambooBarrier return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function Papa.GiveLaBaZhouToday()
	-- 50254_PapaRecvLaBaZhouToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50254);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function Papa.NotGiveLaBaZhouTodayAndHaveLaBaZhou()
	-- 17050_LaBaZhou
	if(not Papa.GiveLaBaZhouToday() and (hasGSItem(17050, 12))) then
		return true;
	else
		return false;
	end
end

--function Papa.GetRandomRewardName()
	--local i = Papa.GetDailyIndex();
	--if(i == 1) then
		--return "泡泡池塘";
	--elseif(i == 2) then
		--return "紫藤萝栅栏";
	--elseif(i == 3) then
		--return "竹子栅栏";
	--end
--end
--
--function Papa.GetRandomRewardGSID()
	--local i = Papa.GetDailyIndex();
	--if(i == 1) then
		--return 30028;
	--elseif(i == 2) then
		--return 30053;
	--elseif(i == 3) then
		--return 30052;
	--end
--end
--
--function Papa.GetDailyIndex()
	--local nid = System.App.profiles.ProfileManager.GetNID();
	--local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	--serverdate = string.gsub(serverdate, "%D", "");
	--local days = tonumber(serverdate);
	--
	--local i = math.mod(math.mod((days * nid), 1987), 3) + 1; -- 1987: the 300th prime number
	--return i;
--end


-------------- schedule Carnation --------------

function Papa.GiveCarnation()
	local i = Papa.GetDailyIndex();
	if(i == 1) then
		-- 357 Carnation_PapaReward_30113_LionStone 
		ItemManager.ExtendedCost(357, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 357: Carnation_PapaReward_30113_LionStone return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 2) then
		-- 358 Carnation_PapaReward_30114_TraditionalWoodenBed 
		ItemManager.ExtendedCost(358, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 358: Carnation_PapaReward_30114_TraditionalWoodenBed return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function Papa.GiveCarnationToday()
	-- 50280_PapaRecvCarnationToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50280);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function Papa.NotGiveCarnationTodayAndHaveCarnation()
	-- 17085_CollectableCarnation
	if(not Papa.GiveCarnationToday() and (hasGSItem(17085, 12))) then
		return true;
	else
		return false;
	end
end

function Papa.GetRandomRewardName()
	local i = Papa.GetDailyIndex();
	if(i == 1) then
		return "石雕狮子";
	elseif(i == 2) then
		return "檀香木床";
	end
end

function Papa.GetRandomRewardGSID()
	local i = Papa.GetDailyIndex();
	if(i == 1) then
		return 30113;
	elseif(i == 2) then
		return 30114;
	end
end

function Papa.GetDailyIndex()
	local nid = System.App.profiles.ProfileManager.GetNID();
	local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	serverdate = string.gsub(serverdate, "%D", "");
	local days = tonumber(serverdate);
	
	local i = math.mod(math.mod((days * nid), 2129), 2) + 1; -- 2129: the 320th prime number
	return i;
end