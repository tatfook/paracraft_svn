--[[
Title: TODO: move this file to HaqiQuestHook. by Xizhi
Author(s): Leio
Date: 2011/11/17
Desc: This file is identical to the function of HaqiQuestHook.lua, except that it is more flexible. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestHook.lua");
local QuestHook = commonlib.gettable("MyCompany.Aries.Quest.QuestHook");
QuestHook.Invoke("quest_npc_dialog", 31035);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Dialog_NPC.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local QuestHook = commonlib.gettable("MyCompany.Aries.Quest.QuestHook");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");

local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
function QuestHook.SetHook()
	if(CommonClientService.IsTeenVersion())then
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = QuestHook.HookHandler_teen, 
			hookName = "Hook_Quest", appName = "Aries", wndName = "quest_main"});
	else
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = QuestHook.HookHandler_kids, 
			hookName = "Hook_Quest", appName = "Aries", wndName = "quest_main"});
	end
end

--@param action_type:"quest_accept" or "quest_finish" or "quest_npc_dialog" or 
-- "showpage": when the npc dialog is shown. 
-- "oninit": only send once when quest is initialized. 
--@param id:quest id or npc id
function QuestHook.Invoke(action_type, id)
	if(not action_type or not id)then return end
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", 
	{ action_type = action_type, id = id, wndName = "quest_main",});
end

--------------------------------------
-- teen version
--------------------------------------
local first_quest_id = 61050;
-- this is a teen version only hook.
function QuestHook.HookHandler_teen(nCode, appName, msg, value)
	local self = QuestHook;
	local provider = QuestClientLogics.GetProvider();
	if(msg.action_type == "quest_accept")then
		local questid = msg.id;
		if(questid == first_quest_id and Player.GetLevel()<2)then
			-- the first task
			MyCompany.Aries.Dialog.ShowTransparentPage("script/apps/Aries/Dialog/QuestDialog/ClickQuestCharTutorial.teen.html?name=complete", "ClickQuestCharTutorial");
		elseif(questid == 61318)then
			--加入家族
			local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory();
			if(userinfo and userinfo.family and userinfo.family ~= "")then
				MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79015);
			end
		elseif(questid == 60502)then
			----生活技能
			--if(hasGSItem(21105) or hasGSItem(21106) or hasGSItem(21107) or hasGSItem(21108) or hasGSItem(21109) or hasGSItem(21110))then
				--MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79014);
			--end
			----辅修专业
			--NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/ForgetSkill.teen.lua");
			--local ForgetSkill = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.ForgetSkill");
			--ForgetSkill.ShowPage();
		elseif(questid == 61055)then
			--宠物
			NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
			local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
			local list,map = CombatPetPane.GetMyPetList_Memory();
			if(list and (#list > 0))then
				MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79013);
			end
		end
	elseif(msg.action_type == "quest_finish")then
		local questid = msg.id;
		if(questid == first_quest_id)then
			--  the first task
			MyCompany.Aries.Dialog.ShowTransparentPage(nil, "ClickQuestCharTutorial");
		elseif(questid == 60150)then
			--宝石镶嵌
			local has_upgrade_item,has_attach_gem_item = EquipHelper.GetEquipmentState();
			--如果有可以镶嵌宝石的装备
			if(has_attach_gem_item)then
				NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemAttachPage.lua");
				local GemAttachPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemAttachPage");
				GemAttachPage.ShowPage();
			end
		elseif(questid == 60151)then
			----装备强化
			--local has_upgrade_item,has_attach_gem_item = EquipHelper.GetEquipmentState();
			----如果有可以升级的装备
			--if(has_upgrade_item)then
				--NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
				--MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade.ShowPage();
			--end
		end
	elseif(msg.action_type == "quest_npc_dialog")then
		--NOTE:this is a npcid
		local npcid = msg.id;
		if(npcid == 31001)then
			--  the first task
			MyCompany.Aries.Dialog.ShowTransparentPage(nil, "ClickQuestCharTutorial");
		elseif(npcid == 31011 and provider:HasAccept(61166))then
			
		elseif(npcid == 31038 and provider:HasAccept(61168))then
			----符文商店
			--NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
			--local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
			--NPCShopPage.ShowPage(31038);
		elseif(npcid == 31082 and provider:HasAccept(60502))then
			
		end
	elseif(msg.action_type == "quest_showpage")then
		--NOTE:this is a npcid
		local npcid = msg.id;
		-- when page is shown.
		if(not provider:HasFinished(first_quest_id))then
			--  the first task
			MyCompany.Aries.Dialog.ShowTransparentPage(nil, "ClickQuestCharTutorial");
		end	
	elseif(msg.action_type == "quest_oninit")then
		if(not provider:HasFinished(first_quest_id) and Player.GetLevel()<2)then
			-- user has not finished first task when logging in the world, we will show some start up UI. 
			if(provider:HasAccept(first_quest_id))then
				MyCompany.Aries.Dialog.ShowTransparentPage("script/apps/Aries/Dialog/QuestDialog/ClickQuestCharTutorial.teen.html?name=complete", "ClickQuestCharTutorial");
			else
				MyCompany.Aries.Dialog.ShowTransparentPage("script/apps/Aries/Dialog/QuestDialog/ClickQuestCharTutorial.teen.html?name=accept", "ClickQuestCharTutorial");
			end
		end
		--加入家族任务
		if(provider:HasAccept(61318))then
			local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory();
			if(userinfo and userinfo.family and userinfo.family ~= "")then
				MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79015);
			end
		end
		----生活技能任务
		--if(provider:HasAccept(60502))then
			--if(hasGSItem(21105) or hasGSItem(21106) or hasGSItem(21107) or hasGSItem(21108) or hasGSItem(21109) or hasGSItem(21110))then
				--MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79014);
			--end
		--end
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
		local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
		local list,map = CombatPetPane.GetMyPetList_Memory();
		if(list and (#list > 0))then
			MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79013);
		end
	end
	return nCode;
end

--------------------------------------
-- kids version
--------------------------------------
local kids_first_task_set = {63000, 60001, 60002, 60003, 60004, 60005}
local kids_first_task_map = {[63000]=true,[60001]=true, [60002]=true, [60003]=true, [60004]=true, [60005]=true}

-- this is a teen version only hook.
function QuestHook.HookHandler_kids(nCode, appName, msg, value)
	local self = QuestHook;
	local provider = QuestClientLogics.GetProvider();
	if(msg.action_type == "quest_accept")then
		local questid = msg.id;
		if(kids_first_task_map[questid] and Player.GetLevel()<2)then
			-- the first task
			MyCompany.Aries.Dialog.ShowTransparentPage("script/apps/Aries/Dialog/QuestDialog/ClickQuestCharTutorial.kids.html?name=complete", "ClickQuestCharTutorial");
		end
		if(questid == 60309)then
			LobbyClientServicePage.AutoFindRoom("HaqiTown_GraduateExam_54_55", "PvE",nil,true);
		end
	elseif(msg.action_type == "quest_finish")then
		local questid = msg.id;
		if(kids_first_task_map[questid])then
			--  the first task
			MyCompany.Aries.Dialog.ShowTransparentPage(nil, "ClickQuestCharTutorial");
		end
	elseif(msg.action_type == "quest_npc_dialog")then
		--NOTE:this is a npcid
		local npcid = msg.id;
		
	elseif(msg.action_type == "quest_showpage")then
		--NOTE:this is a npcid
		local npcid = msg.id;
		-- when page is shown.
		if(not provider:HasFinishedAny(kids_first_task_set))then
			--  the first task
			MyCompany.Aries.Dialog.ShowTransparentPage(nil, "ClickQuestCharTutorial");
		end	
	elseif(msg.action_type == "quest_oninit")then
		if(not provider:HasFinishedAny(kids_first_task_set) and Player.GetLevel()<2)then
			-- user has not finished first task when logging in the world, we will show some start up UI. 
			if(provider:HasAcceptAny(kids_first_task_set))then
				MyCompany.Aries.Dialog.ShowTransparentPage("script/apps/Aries/Dialog/QuestDialog/ClickQuestCharTutorial.kids.html?name=complete", "ClickQuestCharTutorial");
			else
				MyCompany.Aries.Dialog.ShowTransparentPage("script/apps/Aries/Dialog/QuestDialog/ClickQuestCharTutorial.kids.html?name=accept", "ClickQuestCharTutorial");
			end
		else
			-- TODO: others
		end
	end
	return nCode;
end
