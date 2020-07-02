--[[
Title: Desktop Dock Area for Aries App
Author(s): WangTian
Company: ParaEnging Co.
Date: 2008/12/2
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Area: 
Kids Version:
	---------------------------------------------------------
	| Notification									  Quest	|
	|														|
	| Target								   QuestTracker	|
	| (Team)											 	|
	| 													 	|
	| 													 	|
	| 													 s	|
	| 													 p	|
	| 													 e	|
	| 													 c	|
	|													 i	|
	|													 a	|
	|													 l	|
	| HpMyPlayer  										 	|
	|											  MagicStar |
	| Map		  | -------- Dock -------- | AntiIndulgence	|
	-------------------------Exp-----------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
MyCompany.Aries.Desktop.Dock.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/os.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatWnd.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSet.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local ChatWnd = commonlib.gettable("MyCompany.Aries.ChatWnd");

NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
-- create class
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockHelper.lua");
local DockHelper = commonlib.gettable("MyCompany.Aries.Desktop.DockHelper");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");

NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local Player = commonlib.gettable("MyCompany.Aries.Player");

-- dock height reserved for dock itself
-- mainly for other user interface components shown in the middle area of the dock leaving the bottom for dock
Dock.ReservedHeight = 40;
function Dock.SetTop(top)
	top = top or -20;
	local _dock = ParaUI.GetUIObject("Aries_Dock");
	if(_dock and _dock:IsValid())then
		_dock.y = top;
	end
end

local exidListWithForbiddenShowNotification = {
	-- CombatPills_DamageBoost   exid
	[832] = true,
	[1648] = true,
	-- CombatPills_ResistBoost   exid
	[834] = true,
	[1649] = true,
	-- CombatPills_HPBoost   exid
	[835] = true,
	[1650] = true,
	-- CritPill   exid
	[901] = true,
	[1651] = true,
	-- ResiliencePill  exid
	[902] = true,
	[1652] = true,
}

-- invoked at Desktop.InitDesktop(), it assert this function is invoked only once
function Dock.Init()
	-- load desktop implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/Dock.kids.lua");
		if(System.options.theme == "v2") then
			Dock.CreateV2();
		else
			Dock.Create();
		end
	else
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/Dock.teen.lua");
		Dock.Create();
	end
end

local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");
-- virtual function: Desktop window handler
function Dock.MSGProc(msg)
	if(msg.type == MSGTYPE.ON_LEVELUP) then
		local level = msg.level;
		MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI(true);
		NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
		local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
		local provider = QuestClientLogics.provider;
		if(provider)then
			provider:NotifyChanged();
		end
		QuestTrackerPane.NeedReload();
		QuestClientLogics.UpdateUI(true);

		NPL.load("(gl)script/apps/Aries/Login/WorldAssetPreloader.lua");
		local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")
		WorldAssetPreloader.OnPlayerReachedLevel(level);

		if(Dock.RefreshPage)then
			Dock.RefreshPage();
		end
	end
end

-- virtual: show or hide all windows related to the dock. such as the character, map, pet, etc. 
function Dock.ShowHideAllWindow(bShow)
end

-- virtual:
function Dock.RefreshPage()
end

local hooks = {
	["OnPurchaseItemAfterGetItemsInBag"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnPurchaseItemAfterGetItemsInBag") then
					if(msg.tiptypeonerror ~= "none") then
						if(msg.ForceShowOrHideNotificationOnObtain ~= false) then
							Dock.OnPurchaseNotification(msg.gsid, msg.count);
						end
					end
					if(msg.ForceShowOrHideNotificationOnObtain == true) then
						Dock.OnPurchaseNotification(msg.gsid, msg.count, true);
					end
				end
			end, 
			hookName = "Aries_PurchaseItemNotification", appName = "Aries", wndName = "main"},
	["OnExtendedCost"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnExtendedCost") then
					if(msg.output_msg) then
						if(msg.tiptypeonerror ~= "none") then
							--exidListWithForbiddenShowNotification
							if(System.options.version=="kids") then
								local exid = tonumber(msg.input_msg.exid);
								if(not exidListWithForbiddenShowNotification[exid]) then
									Dock.OnExtendedCostNotification(msg.output_msg);
								end
								if(exid == 1930) then
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag12"});
								end
							else
								Dock.OnExtendedCostNotification(msg.output_msg);
							end
							
							
						end
					end
				end
			end, 
			hookName = "Aries_ExtendedCostNotification", appName = "Aries", wndName = "main"},
	["OnSellItem"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnSellItem") then
					if(msg.deltaemoney) then
						if(msg.tiptypeonerror ~= "none") then
							Dock.OnJoybeanNotification(msg.deltaemoney);
						end
					end
				end
			end, 
			hookName = "Aries_SellItemNotification", appName = "Aries", wndName = "main"},
	["OnNortifyItems"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnNortifyItems") then
					if(msg.items) then
						Dock.OnExtendedCostNotification(msg.items);
					end
				end
			end, 
			hookName = "Aries_AddItemsNotification", appName = "Aries", wndName = "items"},
	["OnUnEquipItem"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnUnEquipItem") then
					-- check if user bag overweighted
					MyCompany.Aries.Player.CheckAndUpdateAvatarSpeed();
				end
			end, 
			hookName = "Aries_OnUnEquipItem", appName = "Aries", wndName = "main"},
	["OnObtainItem"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnObtainItem") then
					-- force update avatar speed
					-- NOTE: prevent multiple UpdateAvatarSpeed call in series of OnObtainItem msg at the same time
					Dock.bForceUpdateAvatarSpeed = true;
					UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
						if(elapsedTime == 500) then
							Dock.bForceUpdateAvatarSpeed = false;
							MyCompany.Aries.Player.CheckAndUpdateAvatarSpeed();
						end
					end);

					if(msg.gsid and msg.count) then
						local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(msg.gsid);
						if(gsItem) then
							local assetfile = gsItem.assetfile;
							local _ = string.match(string.lower(assetfile), "^(.+)_acquire$")
							if(_) then
								-- send log information
								paraworld.PostLog({action = "dragonwish_acquire", gsid = msg.gsid, assetkey = assetfile}, 
									"dragonwish_acquire_log", function(msg)
								end);
							end
							local _ = string.match(string.lower(assetfile), "^(.+)_complete$")
							if(_) then
								-- send log information
								paraworld.PostLog({action = "dragonwish_complete", gsid = msg.gsid, assetkey = assetfile}, 
									"dragonwish_complete_log", function(msg)
								end);
							end
							-- on this login, first get rune and popup AutoTips
							local gsid = tonumber(msg.gsid);
							if( gsid > 23000 and gsid <= 23999 ) then
								-- 获得符文自动装备
								local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
								MyCardsManager.AutoEquipRune(msg.gsid);
								NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
								local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
								AutoTips.CheckShowGetRune();
							end
							-- making skills
							if( gsid >= 21105 and gsid <= 21110 and System.options.version=="teen") then
								local bOwn, guid, bag, copies = ItemManager.IfOwnGSItem(msg.gsid);
								if(not copies or (msg.count - copies) == 0) then
									-- only calls when it is the first point learnt
									if(gsid == 21109 or gsid == 21110)then
										CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { action_type = "gatherer_skill_learned", wndName = "main",});
									end
									MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79014);
								end
							end

							-- 获得战斗背包自动装备
							--commonlib.echo(gsItem)
							if(gsItem.template.class == 19 and gsItem.template.subclass == 1) then
								local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
								local ItemManager = System.Item.ItemManager;
								local hasGSItem = ItemManager.IfOwnGSItem;
								local bHas, guid = hasGSItem(msg.gsid);	
								commonlib.echo("=========get newbag:0")	
								--commonlib.echo(guid)					
								local item = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
								--commonlib.echo(item)	
								if(item and item.guid > 0) then
									local deck = ItemManager.GetItemByBagAndPosition(0, 24); -- 战斗背包种类
									local _preGsid = deck.gsid;
									local _curGsid = msg.gsid;
									commonlib.echo("=========get newbag:1")
									MyCardsManager.AutoCopyCardsFrmPreDeck(_preGsid,_curGsid,false);
									commonlib.echo("=========get newbag:2")
									UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
										if(elapsedTime == 500) then
											commonlib.echo("=========get newbag:3")
											local item = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
											if(item and item.guid > 0) then
												commonlib.echo("=========get newbag:4")
												item:OnClick("left");
											end
										end
									end);
								end		
																				
							end

							-- 10101 ~ 10999  follow pet  
							if(gsid >= 10101 and gsid <= 10999) then
								System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateFollowPetRelated"});
							end
							if(gsItem.template.stats and gsItem.template.stats[48] == 1) then
								if(gsid == 12001 or gsid == 12002) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(gsid == 12003 or gsid == 12004 or (System.options.version == "teen" and gsid == 12046)) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(gsid == 12005 or gsid == 12006) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(gsid == 12007) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(gsid == 12008 or gsid == 12009) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(gsid == 12010) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(gsid == 17297 and System.options.version == "kids") then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag12"});
								end
								if(gsid == 15584 and System.options.version == "teen") then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag0"});
								end
								if((gsid == 12055 or gsid == 12056) and System.options.version == "teen") then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
								if(System.options.version == "teen" and gsid == 12059) then
									-- require game server update
									System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateBag14"});
								end
							end
						end
					end
				end
			end, 
			hookName = "Aries_Log_OnObtainItem", appName = "Aries", wndName = "items"},
	["OnUpdatePetGet"] = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnUpdatePetGet") then
					Dock.UpdateLevelExpAndHP()
				end
			end, 
			hookName = "Aries_Dock_OnUpdatePetGetInfo", appName = "Aries", wndName = "main"},
};

CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Aries_PurchaseItemNotification", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Aries_ExtendedCostNotification", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		--CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Aries_Log_OnObtainItem", 
			--hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Aries_Dock_OnUpdatePetGetInfo", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Aries_AutoTips", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});

unhooks = {
	["Aries_PurchaseItemNotification"] = {hookName = "Aries_PurchaseItemNotification", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET},
	["Aries_ExtendedCostNotification"] = {hookName = "Aries_ExtendedCostNotification", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET},
	["Aries_Dock_OnUpdatePetGetInfo"] = {hookName = "Aries_Dock_OnUpdatePetGetInfo", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET},
	["Aries_AutoTips"] = {hookName = "Aries_AutoTips", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET},

};
-- show or hide the dock, toggle the visibility if bShow is nil
function Dock.Show(bShow)
	local _dock = ParaUI.GetUIObject("Aries_Dock");
	if(_dock:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _dock.visible;
		end
		_dock.visible = bShow;
	end
	Dock.is_visible = bShow;
	Dock.ShowHideAllWindow(bShow);

	-- hook and unhook item purchase for purchase notification
	if(bShow == true) then
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnPurchaseItemAfterGetItemsInBag"]);
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnExtendedCost"]);
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnSellItem"]);
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnNortifyItems"]);
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnUnEquipItem"]);
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnObtainItem"]);
		-- update the dragon level exp and hp
		Dock.UpdateLevelExpAndHP();
		-- hook into pet get
		CommonCtrl.os.hook.SetWindowsHook(hooks["OnUpdatePetGet"]);
	elseif(bShow == false) then
		--CommonCtrl.os.hook.UnhookWindowsHook(unhooks["Aries_PurchaseItemNotification"]);
		CommonCtrl.os.hook.UnhookWindowsHook(unhooks["Aries_ExtendedCostNotification"]);
		CommonCtrl.os.hook.UnhookWindowsHook(unhooks["Aries_Dock_OnUpdatePetGetInfo"]);
		CommonCtrl.os.hook.UnhookWindowsHook(unhooks["Aries_AutoTips"]);
	end	
end

function Dock.UpdateLevelExpAndHP()
	local combatlel = 0;
	local combatexp = 0;
	local nextlevelexp = 20;
	-- get pet level
	combatlel = Combat.GetMyCombatLevel();
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatexp = bean.combatexp or 1;
		nextlevelexp = bean.nextlevelexp or 15;
	end
	local MsgHandler = commonlib.getfield("MyCompany.Aries.Combat.MsgHandler");
	if(MsgHandler) then
		-- update max hp according to level
		local old_max_hp = MsgHandler.GetMaxHP();
		MsgHandler.UpdateMaxHP(combatlel);
		local max_hp = MsgHandler.GetMaxHP();
		if(old_max_hp < max_hp and old_max_hp ~= 500) then
			-- level up refill max hp
			MsgHandler.SetCurrentHP(max_hp);
		end
		local current_hp, max_hp = MsgHandler.GetCurrentHP(), MsgHandler.GetMaxHP();
		NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
		MyCompany.Aries.Desktop.HPMyPlayerArea.SetValue(current_hp,max_hp);
	end
	NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	MyCompany.Aries.Desktop.EXPArea.SetValue(combatlel,combatexp, nextlevelexp);
end

function Dock.ShowBBSChatWnd()
end

function Dock.HideBBSChatWnd()
end

-- public: this function is called. whenever the user pressed the enter key and wants to enter some chat message. 
function Dock.OnEnterChat()
	
end

function Dock.SetButtonEnabled(name, bEnable)
end

Dock.isIdleMode = false;

function Dock.IsIdleMode()
	return Dock.isIdleMode;
end

-- enter idle mode, disabling dragon icon, action and my homeland
-- idle mode will also prohibit the user to teleport to other homeland or invited to other places
function Dock.EnterIdleMode()
	Dock.isIdleMode = true;
	-- close the local map if opened
	NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
	MyCompany.Aries.Desktop.LocalMap.Hide()
	-- first close all open windows
	Dock.HideAllWindows();
	-- disable the map button
	MyCompany.Aries.Desktop.MapArea.DisableButton()
	-- disable times magazine button
	MyCompany.Aries.Desktop.NotificationArea.SetButtonEnabled("magazine", false);
	-- disable mail button
	MyCompany.Aries.Desktop.NotificationArea.SetButtonEnabled("mail", false);
	-- disable some dock buttons
	Dock.SetButtonEnabled("myhome", false);
	Dock.SetButtonEnabled("action", false);
	Dock.SetButtonEnabled("family", false);
	Dock.SetButtonEnabled("dragonicon", false);
end

-- leave idle mode, disabling dragon icon, action and my homeland
function Dock.LeaveIdleMode()
	Dock.isIdleMode = false;
	-- enable the map button
	MyCompany.Aries.Desktop.MapArea.EnableButton()
	-- enable times magazine button
	MyCompany.Aries.Desktop.NotificationArea.SetButtonEnabled("magazine", true);
	-- enable mail button
	MyCompany.Aries.Desktop.NotificationArea.SetButtonEnabled("mail", true);
	-- enable some dock buttons
	Dock.SetButtonEnabled("myhome", true);
	Dock.SetButtonEnabled("action", true);
	Dock.SetButtonEnabled("family", true);
	Dock.SetButtonEnabled("dragonicon", true);
end

-- @param (optional)bForceNotification: force the notification of item obtain, mainly for quest related items which gsid exceeds 50000
function Dock.OnCostNotification(gsid, count, bForceNotification)
	if(gsid and gsid > 50000 and bForceNotification ~= true) then
		-- don't show quest item
		return;
	end
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	local bHidden;
	local isEnergyStone=false;
	if(gsItem) then
		-- 12 Force_Notification_OnObtain(C) 强制显示在获得提示中（1显示0隐藏） 
		bHidden = gsItem.template.stats[12];
	end
	if(bHidden ~= 0) then
		Dock.ShowItemDropSound({gsid});
		Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/CostSingleItem.html?gsid="..gsid.."&count="..count);
	end
end

-- @param (optional)bForceNotification: force the notification of item obtain, mainly for quest related items which gsid exceeds 50000
function Dock.OnPurchaseNotification(gsid, count, bForceNotification)
	if(gsid and gsid > 50000 and bForceNotification ~= true) then
		-- don't show quest item
		return;
	end
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	local bHidden;
	local isEnergyStone=false;
	if(gsItem) then
		-- 12 Force_Notification_OnObtain(C) 强制显示在获得提示中（1显示0隐藏） 
		bHidden = gsItem.template.stats[12];
	end
	if(bHidden ~= 0) then
		Dock.ShowItemDropSound({gsid});
		if(System.options.version == "kids") then
			Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/SingleItem.html?gsid="..gsid.."&count="..count);
			Dock.ShowNotificationInChannel(gsid, count);
		else
			Dock.ShowNotificationInChannel(gsid, count);
		end
	end
end

-- on last pills notification
function Dock.OnLastPillsNotification(gsids)
	local marker_gsid;
	for marker_gsid in string.gmatch(gsids, "([^,]+)") do
		marker_gsid = tonumber(marker_gsid);
		if(marker_gsid) then
			-- 56 Related_CombatPill_GSID(CG) 战斗药丸标记对应的战斗药丸gsid 
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(marker_gsid);
			if(gsItem) then
				local pill_gsid = gsItem.template.stats[56];
				if(pill_gsid) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(pill_gsid);
					if(gsItem) then
						BroadcastHelper.PushLabel({
							id = "pill_effect_disappear"..tostring(pill_gsid), label = gsItem.template.name.."效果消失", 
							max_duration = 4000, color = "255 0 0", 
							scaling = 1.1, bold = true, shadow = true,
						});
					end
				end
			end
		end
	end
end

function Dock.DockTip(output_msg)
	if(not output_msg)then return end
	local bean = MyCompany.Aries.Pet.GetBean();
	local mySchool= MyCompany.Aries.Combat.GetSchoolGSID();
	local action_type = output_msg.action_type;
	local gsid_map = {};
	local k,v;
	if(output_msg.adds)then
		for k,v in ipairs(output_msg.adds) do
			local gsid = v.gsid;
			if(gsid)then
				gsid_map[gsid] = gsid;
			end
		end
	end
	if(output_msg.obtains)then
		for k,v in pairs(output_msg.obtains) do
			if(v > 0)then
				gsid_map[k] = k;
			end
		end
	end
	local gsid,v;
	for gsid,v in pairs(gsid_map) do
		--如果是开卡包不提示动画
		if(action_type and action_type == "DirectlyOpenCardPack_callback_from_powerapi")then
			return
		end
		DockTip.GetInstance():PushGsid(gsid);
	end
end
-- output_msg of the extendedcost API
function Dock.OnExtendedCostNotification(output_msg)
	if(not output_msg) then
		return;
	end
	-- NOTE: we assume that the adds part and the updates part can not collide on the same gsid
	local items = {};
	local isEnergyStone=false;
	local bean = MyCompany.Aries.Pet.GetBean();
	local mySchool= MyCompany.Aries.Combat.GetSchoolGSID();
	--新手提示
	Dock.DockTip(output_msg)

	if(output_msg.adds) then
		local _, add;
		for _, add in ipairs(output_msg.adds) do
			if(add.gsid and add.gsid > 0) then
				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(add.gsid);
				local bHidden;
				if(gsItem) then
					bHidden = gsItem.template.stats[12];
					if (bean) then
						if (bean.combatlel<=10) then
							
							if (gsItem.template.class==1) then -- judge item is equip or not

								local needLvl=gsItem.template.stats[138] or 0;  -- 掉落装备级别
								local needSchool=gsItem.template.stats[137];  -- 掉落装备可用系别
								if (needSchool) then 
									if (CommonClientService.IsRightSchool(add.gsid)) then
										local ItemInventoryType = gsItem.template.inventorytype; -- 掉落装备类别
										local curItem = ItemManager.GetItemByBagAndPosition(0, ItemInventoryType); -- 当前身上穿着的该类装备级别
										if(curItem) then
											curItem = ItemManager.GetGlobalStoreItemInMemory(curItem.gsid)
										end
										if (curItem and curItem.template) then
											local curlvl=curItem.template.stats[138] or 0;
											if (needLvl>curlvl) then
												NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
												local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
												--AutoTips.ShowPage("LootEquip",add.gsid,true);
											end
										else -- 如果获得是新装备
											NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
											local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
											--AutoTips.ShowPage("LootEquip",add.gsid,true);
										end
									end
								else  -- 通用系别
										local ItemInventoryType = gsItem.template.inventorytype; -- 掉落装备类别
										local curItem = ItemManager.GetItemByBagAndPosition(0, ItemInventoryType); -- 当前身上穿着的该类装备级别
										if(curItem) then
											curItem = ItemManager.GetGlobalStoreItemInMemory(curItem.gsid)
										end
										if (curItem and curItem.template) then
											local curlvl=curItem.template.stats[138] or 0;
											if (needLvl>curlvl) then
												NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
												local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
												--AutoTips.ShowPage("LootEquip",add.gsid,true);
											end
										else -- 如果获得是新装备
											NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
											local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
											--AutoTips.ShowPage("LootEquip",add.gsid,true);
										end
								end

							elseif (gsItem.template.class==11) then -- follow pet							

								NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
								local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
								--AutoTips.ShowPage("PetEquip",add.gsid,true);
							end
						end --if (bean.combatlel<=10) 
					end
				end --if(gsItem)
				if (add.gsid==998) then
					isEnergyStone=true;
				end
				-- don't show quest item and force hiden item
				if((bHidden == nil and add.gsid < 50000) or bHidden == 1) then
					if(not gsItem.template.stats[528]) then
						table.insert(items, {gsid = add.gsid, count = add.cnt});
					end
					--table.insert(items, {gsid = add.gsid, count = add.cnt});
				end
			end
		end
	end
	if(output_msg.updates) then
		local _, update;
		for _, update in ipairs(output_msg.updates) do
			if(update.gsid_fromlocalserver and update.gsid_fromlocalserver > 0) then
				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(update.gsid_fromlocalserver);
				local bHidden;
				if(gsItem) then
					bHidden = gsItem.template.stats[12];
				end
				-- don't show quest item and force hiden item
				if((bHidden == nil and update.gsid_fromlocalserver < 50000 and update.cnt and update.cnt > 0) or bHidden == 1) then
					if(not gsItem.template.stats[528]) then
						table.insert(items, {gsid = update.gsid_fromlocalserver, count = update.cnt});
					end
					--table.insert(items, {gsid = update.gsid_fromlocalserver, count = update.cnt});
				end
			end
		end
	end
	if(output_msg.stats) then
		local _, stat;
		for _, stat in ipairs(output_msg.stats) do
			if(System.options.version == "kids") then
				if(stat.gsid and (stat.gsid == 0)) then
					-- select the joybean obtains
					table.insert(items, {gsid = stat.gsid, count = stat.cnt});
				end
			else
				if(stat.gsid and (stat.gsid == 0 or stat.gsid == -13 or stat.gsid == -113)) then
					-- select the joybean obtains or exp or 宠物经验
					table.insert(items, {gsid = stat.gsid, count = stat.cnt});
				end
			end
		end
	end
	if(#(items) >= 1) then
		if(#(items) == 0) then
			return;
		elseif(#(items) == 1) then
			Dock.ShowItemDropSound({items[1].gsid});
			if(System.options.version == "kids") then
				Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/SingleItem.html?gsid="..items[1].gsid.."&count="..items[1].count);
				Dock.ShowNotificationInChannel(items[1].gsid, items[1].count);
			else
				Dock.ShowNotificationInChannel(items[1].gsid, items[1].count);
			end
		else
			local itemlist = "";
			local drops = {};
			local _, item;
			for _, item in ipairs(items) do
				itemlist = itemlist.."("..item.gsid..","..item.count..")";
				table.insert(drops, item.gsid);
			end
			Dock.ShowItemDropSound(drops);
			if(System.options.version == "kids") then
				Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/MultipleItems.html?itemlist="..itemlist);
				local _, item;
				for _, item in ipairs(items) do
					Dock.ShowNotificationInChannel(item.gsid, item.count);
				end
			else
				local _, item;
				for _, item in ipairs(items) do
					Dock.ShowNotificationInChannel(item.gsid, item.count);
				end
			end
		end
	end
	if (isEnergyStone) then
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经购买了能量石，快给魔法星补充能量吧！</div>");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				if(System.options.version=="kids") then
					MyCompany.Aries.Desktop.Dock.ShowCharPage(5, true);
				else
					NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.lua");
					local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");
					MagicStarPage.ShowPage(2);
				end
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OpenBag_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end

function Dock.OnJoybeanNotification(count)
	if(type(count) ~= "number") then
		-- isn't valid count
		return;
	end
	Dock.ShowItemDropSound({0});
	if(count and  count ~= 0) then
		if(System.options.version == "kids") then
			Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/Joybean.html?count="..count);
			Dock.ShowNotificationInChannel(0, count);
		else
			Dock.ShowNotificationInChannel(0, count);
		end
	end
end

function Dock.OnExpNotification(count)
	if(type(count) ~= "number") then
		-- isn't valid count
		return;
	end
	if(System.options.version == "kids") then
		--Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/Exp.html?count="..count);
	else
		-- NOTE: -13: combat exp
		Dock.ShowNotificationInChannel(-13, count);
	end
end

function Dock.OnFollowPetExpNotification(count)
	if(type(count) ~= "number") then
		-- isn't valid count
		return;
	end
	if(System.options.version == "kids") then
		-- NOTE: -113: follow pet combat exp
		--Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/Exp.html?count="..count);
		Dock.ShowNotificationInChannel(-113, count);
	else
		-- NOTE: -114: follow pet unified combat exp teen version
		-- 去掉  你获得了： 3宠物训练点
		--Dock.ShowNotificationInChannel(-114, count);
	end
end

-- hide all windows, usually this is called before enter or leave homeland to give a clear look
function Dock.HideAllWindows()
	-- hide BBS chat window
	Dock.HideBBSChatWnd();
	
	-- hide target MCML page
	NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
	MyCompany.Aries.Desktop.TargetArea.ShowTarget("");
	-- hide local map
	-- TODO: dirty code, hide directly by name
	local _localmap = ParaUI.GetUIObject("Aries_GUID_LocalMap_window");
	if(_localmap:IsValid() == true) then
		_localmap.visible = false;
	end
	-- close full profile
	System.App.Commands.Call("File.MCMLWindowFrame", {
		name = "Aries.ViewFullProfile", app_key = MyCompany.Aries.app.app_key, bShow = false});
	-- close family window
	System.App.Commands.Call("File.MCMLWindowFrame", {
		name = "HaqiGroupManage.ShowPage", app_key = MyCompany.Aries.app.app_key, bShow = false});
	-- hide inventory window
	NPL.load("(gl)script/apps/Aries/Inventory/MainWnd.lua");
	MyCompany.Aries.Inventory.HideMainWnd();
	-- hide friend window
	NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
	MyCompany.Aries.Friends.ShowMainWnd(false);

	-- close autotips
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
	local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
	AutoTips.system_looptip.visible = false;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		name = "Aries.AutoTip", app_key = MyCompany.Aries.app.app_key, bShow = false});
end

-- virtual: click on chat bar smiley, show the smiley selector menu
function Dock.OnClickSmiley(bShow, frommouseup)
end

-- virtual: show the smiley
function Dock.DoSmiley(node)
end

-- virtual: click on dragon icon
function Dock.OnClickDragon()
	-- call hook for OnDragonIconClick
	local msg = { aries_type = "OnDragonIconClick", wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);

	local msg = { aries_type = "onDragonIconClick_MPD", wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	
	System.App.Commands.Call("Profile.Aries.ShowMountPetProfile");
end

-- show item drop sound according to item material
-- @param drops: drop gsid
function Dock.ShowItemDropSound(drops)
	if(type(drops) ~= "table") then
		return;
	end
	local _, gsid;
	for _, gsid in pairs(drops) do
		--0 consumable items 
		--1 Metal  
		--2 Wood  
		--3 Liquid  
		--4 Jewelry  
		--5 Chain  
		--6 Plate  
		--7 Cloth  
		--8 Leather
		local audio_file;
		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local material = gsItem.template.material;
			if(material == 0) then
				audio_file = "Audio/Haqi/Material/0_PutDownFoodGeneric.ogg";
			elseif(material == 1) then
				audio_file = "Audio/Haqi/Material/1_PutDownLArgeMEtal.ogg";
			elseif(material == 2) then
				audio_file = "Audio/Haqi/Material/2_PickUpWoodLarge.ogg";
			elseif(material == 3) then
				audio_file = "Audio/Haqi/Material/3_PutDownWater_Liquid01.ogg";
			elseif(material == 4) then
				audio_file = "Audio/Haqi/Material/4_PutDownRing.ogg";
			elseif(material == 5) then
				audio_file = "Audio/Haqi/Material/5_PutDownGems.ogg";
			elseif(material == 6) then
				audio_file = "Audio/Haqi/Material/6_PickUpLargeChain.ogg";
			elseif(material == 7) then
				audio_file = "Audio/Haqi/Material/7_PutDownCloth_Leather01.ogg";
			elseif(material == 8) then
				audio_file = "Audio/Haqi/Material/8_PutDownWand.ogg";
			elseif(material == 9) then
				audio_file = "Audio/Haqi/Material/9_PickUpBag.ogg";
			elseif(material == 10) then
				audio_file = "Audio/Haqi/Material/10_PickUpParchment_Paper.ogg";
			elseif(material == 11) then
				audio_file = "Audio/Haqi/Material/11_PutDownRocks_Ore01.ogg";
			end
		elseif(gsid == 0) then
			audio_file = "Audio/Haqi/Material/11_PutDownRocks_Ore01.ogg";
		end
		if(audio_file) then
			local audio_src = AudioEngine.CreateGet(audio_file)
			audio_src.file = audio_file;
			audio_src:play(); -- then play with default. 
		end
	end
end

-- notification count downs, if the count reach 0, the notification will play a hide animation
-- each time the notification is shown, the countdown is refresh to 3 seconds
-- the NotificationCountDown is initially negative indicating the notification is active until the count is up
-- this is specially useful when user don't want to show some presense or feed information on start up
Dock.NotificationCountDown = -2;

-- show the notification bubble over the UtilBar2
-- @param msg: the msg to display, currently only text is applied
-- @param CommandOrDostring: app command or dostring, nil indicating the notification is not clickable
function Dock.ShowNotification(msgOrOwnerDraw, CommandOrDostringOrFunction, nNotificationCountDown)
	if(type(Dock.NotificationCountDown) == "number" and Dock.NotificationCountDown < 0) then
		-- the NotificationCountDown is initially negative indicating the notification is active until the count is up
		-- this is specially useful when user don't want to show some presense or feed information on start up
		return;
	end
	local _notification = ParaUI.GetUIObject("AriesNotification");
	if(_notification:IsValid() == false ) then
		_notification = ParaUI.CreateUIObject("container", "AriesNotification", "_ctb", 190, -72, 220, 150);
		_notification.background = "";
		_notification.zorder = 13;
		_notification:AttachToRoot();
	end
	
	_notification.visible = true;
	
	local _text = _notification:GetChild("text");
	if(_text:IsValid() == true) then
		_text.text = "";
	end
	local _ownerDrawCanvas = _notification:GetChild("OwnerDrawCanvas");
	if(_ownerDrawCanvas:IsValid() == true) then
		_ownerDrawCanvas:RemoveAll();
	end
	if(type(msgOrOwnerDraw) == "string") then
		local _ownerDrawCanvas = _notification:GetChild("OwnerDrawCanvas");
		if(_ownerDrawCanvas:IsValid() == false) then
			_ownerDrawCanvas = ParaUI.CreateUIObject("container", "OwnerDrawCanvas", "_fi", 0, 0, -100, 0);
			_ownerDrawCanvas.background = "";
			_notification:AddChild(_ownerDrawCanvas);
		end
		_ownerDrawCanvas:RemoveAll();
		
		local NotificationPage = System.mcml.PageCtrl:new({url = msgOrOwnerDraw});
		NotificationPage:Create("AriesNotificationPage", _ownerDrawCanvas, "_fi", 0, 0, 0, 0);
		
		local _close = _notification:GetChild("Close");
		if(_close:IsValid() == false) then
			_close = ParaUI.CreateUIObject("button", "Close", "_lt", 33, 70, 153, 49);
			_close.background = "Texture/Aries/Common/PickUp_32bits.png; 0 0 153 49";
			_close.zorder = 2;
			_close.onclick = ";MyCompany.Aries.Desktop.Dock.NotificationCountDown = 0;";
			_notification:AddChild(_close);
		end

		if(string.find(msgOrOwnerDraw, "SingleItem.html") or 
			string.find(msgOrOwnerDraw, "MultipleItems.html") or 
			string.find(msgOrOwnerDraw, "Joybean.html")) then
			_close.visible = true;
		else
			_close.visible = false;
		end


	elseif(type(msgOrOwnerDraw) == "function") then
		local _ownerDrawCanvas = _notification:GetChild("OwnerDrawCanvas");
		if(_ownerDrawCanvas:IsValid() == false) then
			_ownerDrawCanvas = ParaUI.CreateUIObject("container", "OwnerDrawCanvas", "_fi", 0, 0, -100, 0);
			_ownerDrawCanvas.background = "";
			_notification:AddChild(_ownerDrawCanvas);
		end
		_ownerDrawCanvas:RemoveAll();
		
		msgOrOwnerDraw(_ownerDrawCanvas);
	end
	
	Dock.NotificationCallback = CommandOrDostringOrFunction;
	
	if(Dock.NotificationCountDown == nil) then
		-- skip animation if the notification box is already shown on screen
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_notification);
		block:SetTime(200);
		block:SetAlphaRange(0, 1);
		block:SetTranslationYRange(128, 0);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
	end
	
	Dock.NotificationCountDown = nNotificationCountDown or 10;
end

-- show the item notification in channel message
function Dock.ShowNotificationInChannel(gsid, count)
	if(count == 0 or not count) then
		return;
	end
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem and gsItem.template.stats and gsItem.template.stats[528]) then
		local words = "";
		if(gsItem.template.stats[528] == 1) then
			words = "时来运转，人品好就是多财多福啊！恭喜你抽中一张吉利卡！"
			words = string.format("<font color='#E066FF'>%s</font>",words);
		elseif(gsItem.template.stats[528] == 2) then
			words = "就在一瞬间，人品好像发生了变化！恭喜你抽中一张转运卡！";
			--words = string.format("<font color='#FF4500'>%s</font>",words);
		elseif(gsItem.template.stats[528] == 3) then
			words = "时运不济怎么办，难道这就是命？很抱歉你抽中一张倒霉卡！"
			words = string.format("<font color='#76EE00'>%s</font>",words);
		end
		ChatChannel.AppendChat({
			ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
			fromname = "", 
			fromschool = Combat.GetSchool(), 
			fromisvip = false, 
			words = words,
			is_direct_mcml = true,
			bHideSubject = true,
			bHideTooltip = true,
			bHideColon = true,
		});
		return;
	end
	if(gsid == 50401) then
		ChatChannel.AppendChat({
			ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
			fromname = "", 
			fromschool = Combat.GetSchool(), 
			fromisvip = false, 
			words = "很可惜，鱼儿跑掉了...",
			is_direct_mcml = true,
			bHideSubject = true,
			bHideTooltip = true,
			bHideColon = true,
		});
		return;
	end
	NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
	local item_name = CommonCtrl.GenericTooltip.GetItemMCMLText(gsid, math.abs(tonumber(count)), true, "class='bordertext'")

	if(item_name) then
		if(count > 0) then
			ChatChannel.AppendChat({
				ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
				fromname = "", 
				fromschool = Combat.GetSchool(), 
				fromisvip = false, 
				words = "你获得了: "..item_name,
				is_direct_mcml = true,
				bHideSubject = true,
				bHideTooltip = true,
				bHideColon = true,
			});
		else
			local words = string.format("<font color='#76EE00'>%s</font>%s","你失去了: ",item_name);
			ChatChannel.AppendChat({
				ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
				fromname = "", 
				fromschool = Combat.GetSchool(), 
				fromisvip = false, 
				--words = "你失去了: "..item_name,
				words = words,
				is_direct_mcml = true,
				bHideSubject = true,
				bHideTooltip = true,
				bHideColon = true,
			});
		end
		
	end
end

function Dock.DoClickNotification()
	local callback = Dock.NotificationCallback;
	if(type(callback) == "string") then
		-- this is a onclick string, DoString
		NPL.DoString(callback);
	elseif(type(callback) == "function") then
		-- this is a function, call directly
		callback();
	elseif(type(callback) == "table") then
		-- this is a command, call directly
		callback:Call();
	end
	
	if(Dock.NotificationCountDown ~= nil) then
		Dock.NotificationCountDown = 0.2;
	end
end

function Dock.RegisterDoNotificationTimer()
	Dock.timer = Dock.timer or commonlib.Timer:new({callbackFunc = Dock.DoNotificationTimer});
	Dock.timer:Change(200,200);
end

-- bubble count downs, if the count reach 0, the bubble will play a hide animation
function Dock.DoNotificationTimer()
	if(Dock.NotificationCountDown ~= nil) then
		if(Dock.NotificationCountDown < 0) then
			-- the NotificationCountDown is initially negative indicating the notification is active until the count is up
			-- this is specially useful when user don't want to show some presense or feed information on start up
			Dock.NotificationCountDown = Dock.NotificationCountDown + 0.2;
			return;
		end
		Dock.NotificationCountDown = Dock.NotificationCountDown - 0.2;
		if(Dock.NotificationCountDown <= 0) then
			Dock.NotificationCountDown = nil;
			Dock.NotificationCallback = nil;
			local _notification = ParaUI.GetUIObject("AriesNotification");
			if(_notification:IsValid() == true) then
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_notification);
				block:SetTime(150);
				block:SetAlphaRange(1, 0);
				block:SetTranslationYRange(0, 128);
				block:SetApplyAnim(true); 
				block:SetCallback(function ()
					_notification.visible = false;
				end); 
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		end
	end
end


function Dock.DoRid()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
	local IsInHomeland = Map3DSystem.App.HomeLand.HomeLandGateway.IsInHomeland();
	if(IsInHomeland)then
        _guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">在家园中不能驾驭！</div>]])
		return;
	end
	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
	local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
	GathererBarPage.Start({duration = 1000,}, nil, function()
		-- play mount pet mount spell
		NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
		local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
		local spell_file;
		if(System.options.version == "teen")then
			spell_file = "config/Aries/Spells/Action_OnMount_teen.xml";
		else
			spell_file = "config/Aries/Spells/Action_OnMount.xml";
		end
		local current_playing_id = ParaGlobal.GenerateUniqueID();
		SpellCast.EntitySpellCast(0, ParaScene.GetPlayer(), 1, ParaScene.GetPlayer(), 1, spell_file, nil, nil, nil, nil, nil, function()
		end, nil, true, current_playing_id, true);
		item:MountMe();
	end);
end
function Dock.DoFollow()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
	if(MyCompany.Aries.Player.IsFlying() or MyCompany.Aries.Player.IsInAir()) then
        _guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你的抱抱龙正飞在天空中呢，如果要变成“跟随”状态，请先按F键降落。</div>]])
	else
        item:FollowMe();
	end
end
function Dock.DoHome()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
	if(MyCompany.Aries.Player.IsFlying() or MyCompany.Aries.Player.IsInAir()) then
        _guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你的抱抱龙正飞在天空中呢，如果要送它回家，请先按F键降落。</div>]])
    else
        item:GoHome();
    end
end
function Dock.DoChangeBody()
	NPL.load("(gl)script/apps/Aries/Inventory/TabMountExPage.lua");
	MyCompany.Aries.Inventory.TabMountExPage.ShowItemView1("1","1");

	NPL.load("(gl)script/apps/Aries/Inventory/MainWnd.lua");
	MyCompany.Aries.Inventory.ShowMainWnd(true, 2);
end

-- call this to switch from server
function Dock.OnSwitchServer()
	local bean = MyCompany.Aries.Pet.GetBean();
	local level,rookie;
	if(bean) then
		level = bean.combatlel or 1;
	end
	if (level <10) then
		rookie="1";
	else
		rookie="0";
	end

	local world_info = MyCompany.Aries.WorldManager:GetCurrentWorld();
	if( not (world_info.can_save_location and world_info.can_teleport) )  then
		_guihelper.MessageBox("您所在的世界不允许切换服务器. 只有公共世界或岛屿中才能切换.")
		return;
	end

	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.lua");
		local FamilyServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSelect");
		FamilyServerSelect.SwitchSvr = 0;

		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/FamilyServer/FamilyServerSelect.html?from=setting&rookie="..rookie, 
			name = "ServerSelectPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			ToggleShowHide = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -960/2,
				y = -560/2,
				width = 960,
				height = 560,
		});
	else
		NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.teen.lua");
		local FamilyServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSelect");
		FamilyServerSelect.SwitchSvr = 0;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/FamilyServer/FamilyServerSelect.teen.html?from=setting&rookie="..rookie, 
			name = "ServerSelectPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			ToggleShowHide = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -660/2,
				y = -470/2,
				width = 660,
				height = 470,
		});
	end
end

function Dock.OnSwitchUser()
	-- call hook for OnTryToLeaveTown
	local hook_msg = { aries_type = "OnTryToLeaveTown", deltaemoney = msg and msg.deltaemoney, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local product_name = MyCompany.Aries.ExternalUserModule:GetConfig().product_name or "魔法哈奇"

	local diag_text = format("你要切换用户, 并重新登录%s吗？", product_name);
	
	_guihelper.MessageBox(string.format([[<div style="margin-left:24px;margin-top:32px;">%s</div>]], diag_text), function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			paraworld.PostLog({action="user_restart", reason="switch_user"}, "logout_log", function(msg)
			end);
			Dock.PostLogoutTime(function()
				-- fixed: prevent auto login on restart 
				System.User.keepworktoken = nil;
				Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
			end);
			
		end	
	end, _guihelper.MessageBoxButtons.YesNo);
end

-- auto tips
function Dock.DoAutoTips()
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
	local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
	local remained_sec = MyCompany.Aries.Desktop.AntiIndulgenceArea.GetRemainedSec();
	local tiptype;
	if(remained_sec <= 60)then				
		math.randomseed(ParaGlobal.GetGameTime());
		local r = math.random(9);
		local c = r%2;
		if (c==1) then
			tiptype="GetTime1";
		else
			tiptype="GetTime2";
		end
		AutoTips.ShowPage(tiptype);
	else
		AutoTips.ShowPage();
	end	
end

function Dock.ShowHelpPage()
	Dock.FireCmd("HelpMainList.ShowPage");
end


-- show a message box, where the user must select reconnect or exit application. 
function Dock.ShowReconnectPage(bShow)
	if(bShow~=false) then
		_guihelper.MessageBox([[<div style="margin-top:32px;">本次连接已经断开，请尝试重新登录！</div>]], function(res)
			
			if(res and res == _guihelper.DialogResult.Yes) then
				paraworld.PostLog({action="user_restart", reason="disconnect"}, "logout_log", function(msg)
				end);
				Dock.PostLogoutTime(function()
					Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
				end);
			elseif(res and res == _guihelper.DialogResult.No) then
				Dock.LeaveTown();
			end
		end, _guihelper.MessageBoxButtons.YesNoCancel, nil, "script/apps/Aries/Desktop/GUIHelper/LeaveWorldMessageBox.html", nil, 50000); -- 50000 for zorder
	else
		_guihelper.CloseMessageBox();
	end	
end

function Dock.OnDisconnected(nid, reason)
	local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");
	
	-- LiXizhi: 2011.1.10 we will disable auto reconnect, because it will trigger bugs that users may take advantage of. 
	-- LiXizhi:2013.2.13 reconnection is reenabled. 
	if(GameServer.rest.client.cur_game_server_nid ~= nid) then
		LOG.std(nil, "system", "Dock.OnDisconnected", "unknown connection %s is disconnected, ignore it", nid);
		return;
	end
	if(reason == "connection_overwrite") then
		Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft", startup_msg=[[温馨提示：您的帐号在异地登录！如果非您本人，请及时修改密码.]]});
	end
	local auto_connect_mehod = "gsl_reconnect";
	if (auto_connect_mehod == "restart") then
		local last_world_session = MyCompany.Aries.WorldManager:SaveSessionCheckPoint();
		if(last_world_session) then
			Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft", startup_msg={
					autorecover=true, last_user_nid=last_world_session.last_user_nid, 
					gs_nid = last_world_session.gs_nid, ws_id = last_world_session.ws_id,
					ws_seqid = last_world_session.ws_seqid, ws_text=last_world_session.ws_text,
				}});
		else
			Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft", startup_msg=[[温馨提示：刚刚网络状态不太好， 请重新登录]]});
		end
	elseif (auto_connect_mehod == "gsl_reconnect") then
		-- do a full reconnection by establishing rest and then reconnect last gsl server. Possibly save in many conditions. 
		Map3DSystem.App.Commands.Call("File.Reconnect");

	elseif (auto_connect_mehod == "simple_reconnect") then
		-- whether we have shown the reconnect dialog to the user
		local is_reconnect_page_shown = false;

		Dock.autorecover_timer = Dock.autorecover_timer or commonlib.Timer:new({callbackFunc = function(timer)
			MainLogin:RecoverConnection(function(msg)
				if (msg.connected) then
					is_reconnect_page_shown = false;
					Dock.ShowReconnectPage(false);
				
					Dock.last_reconnect_time = ParaGlobal.timeGetTime();
				
					if(type(commonlib.getfield("MyCompany.Aries.Desktop.NotificationArea.AppendFeed")) == "function") then
						MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
							ShowCallbackFunc = function(node)
								_guihelper.MessageBox([[<div style="margin-top:32px;">温馨提示：刚刚网络状态不太好，如果你在游戏过程中出现异常，可以尝试重新登录。</div>]], function(res)
										if(res and res == _guihelper.DialogResult.Retry) then
											Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
										end
									end, _guihelper.MessageBoxButtons.RetryCancel, nil, "script/apps/Aries/Desktop/GUIHelper/LeaveWorldMessageBox.html");
								
							end;
						});
					end	
				else
					if(not is_reconnect_page_shown) then
						Dock.ShowReconnectPage(true);
					end	
					-- reconnect again every 20 seconds. 
					Dock.autorecover_timer:Change(20000, nil);
				end
			end);
		end})
	
		if(not Dock.autorecover_timer:IsEnabled()) then
			-- reconnect immediately the first time we lost connection. 
			if(Dock.last_reconnect_time and (ParaGlobal.timeGetTime()-Dock.last_reconnect_time)<20000) then
				Dock.autorecover_timer:Change(20000, nil)
			else
				Dock.autorecover_timer:Change(0,nil)
			end	
		end	
	end
end

-- set can exit
function Dock.SetCanExit(bCanExit)
	Dock.bCanExit = bCanExit;
end

function Dock.OnExit()
	--如果正在玩flash游戏 隐藏它
	Map3DSystem.App.MiniGames.InvokeFlashGameWindow(false);
	
	if(Dock.bCanExit== false) then
		return;
	end
	
	-- call hook for OnTryToLeaveTown
	local hook_msg = { aries_type = "OnTryToLeaveTown", deltaemoney = msg and msg.deltaemoney, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	
	-- tricky: if the user click the close window button twice we will allow window to close. 
	local oldvalue_ = ParaEngine.GetAttributeObject():GetField("IsWindowClosingAllowed", true);
	local para_oldv;
	if(oldvalue_ == false) then
		ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
		para_oldv = "0";
	else
		para_oldv = "1";
	end

	Dock.SaveLocalPlayerInfo();

	--local ItemManager = System.Item.ItemManager;
	--local item = ItemManager.GetItemByBagAndPosition(0, 23);
	local gsid = MyCompany.Aries.Combat.GetSchoolGSID();
	local bPickedSchool = false;
	if(gsid and gsid > 0) then
		bPickedSchool = true;
	end
	local bInTutorial = false;
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local worldinfo = WorldManager:GetCurrentWorld();
	if(worldinfo) then
		local worldname = worldinfo.name;
		if(worldname == "Tutorial") then
			bInTutorial = true;
		end
	end
	if(bPickedSchool and not bInTutorial) then
		--local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
		--local params = {
			--url = "script/apps/Aries/Desktop/CombatNote.html?leavehaqi=1&paraoldv="..para_oldv, 
			--app_key = MyCompany.Aries.app.app_key, 
			--name = "CombatNote.ShowPage", 
			--isShowTitleBar = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = style,
			--zorder = 2,
			--allowDrag = false,
			--isTopLevel = true,
			--enable_esc_key = true,
			--directPosition = true,
				--align = "_ct",
				--x = -600/2,
				--y = -420/2,
				--width = 600,
				--height =450,
		--};
		--System.App.Commands.Call("File.MCMLWindowFrame",  params);

		local leavehaqi=1;
		if(System.options.version=="kids") then
			NPL.load("(gl)script/apps/Aries/Desktop/Calendar.kids.lua");
		else
			NPL.load("(gl)script/apps/Aries/Desktop/Calendar.teen.lua");
		end
		local Calendar = commonlib.gettable("MyCompany.Aries.Desktop.Calendar");
		Calendar.ShowPage(leavehaqi,para_oldv);

	else

		local product_name = MyCompany.Aries.ExternalUserModule:GetConfig().product_name or "魔法哈奇";

		_guihelper.MessageBox(string.format([[你要离开%s吗？]], product_name), function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				Dock.LeaveTown();
			else
				if(not oldvalue_) then
					ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", oldvalue_);
				end
				--如果正在玩flash游戏，恢复显示
				Map3DSystem.App.MiniGames.InvokeFlashGameWindow(true);
			end
		end, _guihelper.MessageBoxButtons.YesNo, nil, nil, nil, 50000); -- 50000 for zorder
	end
end

function Dock.SaveLocalPlayerInfo(bForceFlush)
	MyCompany.Aries.Player.RecordLastPosition(bForceFlush);

	-- save the latest ccs info and nickname
	local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");
	if(UserLoginProcess.TrySaveUserInfo) then
		UserLoginProcess.TrySaveUserInfo();
	end
end

-- @param callbackFunc: if provided, it will not exit the app. if nil, it will exit the app. 
-- Always provide your own callback if one wants to restart the game without closing the window. 
function Dock.LeaveTown(callbackFunc)
	if(Dock.IsLeaving) then
		return;
	end
	Dock.IsLeaving = true;
	BroadcastHelper.PushLabel({id="exit", label = "正在退出游戏, 请稍候...", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});

	-- stop background music
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	MyCompany.Aries.Scene.StopRegionBGMusic();
	
	
	-- unfreeze the player
	MyCompany.Aries.Player.SetFreezed(false);
	
	-- save data
	Dock.SaveLocalPlayerInfo();
	
	-- send log information
	local is_logout_send = false;
	local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
	local used_sec = AntiIndulgenceArea.GetUsedTime();
	paraworld.PostLog({action="user_logout",onlinetime=used_sec}, "logout_log", function(msg)
		is_logout_send = true;
	end);
	
	LOG.std("", "system", "Dock", "leaving game from within world. world checking point written.")

	local function Exit()
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime >= 500) then
				if(not is_logout_send) then
					LOG.std(nil, "warn", "aries", "logout postlog is not sent, but we will terminate the app anyway")
				end
				Dock.DoExit();
			end
		end);
	end
	
	Dock.PostLogoutTime(callbackFunc or Exit);
end

-- force exit
-- @param bRedirectToLauncher: true to redirect to a proper page so that user can get more accurate information. 
function Dock.DoExit(bRedirectToLauncher)
	ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
	if(System.options.IsWebBrowser) then
		commonlib.app_ipc.ActivateHostApp("exit_game");
	else
		if(bRedirectToLauncher) then
			if(System.options.version == "kids") then
				ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0).."HaqiLauncherKids.exe", "", "", 1); 
			else
				ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0).."HaqiLauncherTeen.exe", "", "", 1); 
			end
		end
	end	
	-- Method1: ParaGlobal.ExitApp();
	-- Method2: Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
	-- Method3: Exit using paraworld

	NPL.load("(gl)script/apps/Aries/Creator/Game/Login/ParaWorldLoginDocker.lua");
	local ParaWorldLoginDocker = commonlib.gettable("MyCompany.Aries.Game.MainLogin.ParaWorldLoginDocker")
	ParaWorldLoginDocker.Restart()
end

-- post logout message with time and call callback funciton if valid
function Dock.PostLogoutTime(callbackFunc)
	if(not MyCompany.Aries.Scene) then
		return
	end
	local msg = {
		logintime = MyCompany.Aries.Scene.GetLastAuthServerTimeSince0000(),
		logouttime = MyCompany.Aries.Scene.GetElapsedSecondsSince0000(),
	};
	if(msg.logintime) then 
		paraworld.auth.Logout(msg, "auth.logout", function(msg)
			if(callbackFunc and type(callbackFunc) == "function") then
				callbackFunc();
			end
		end, nil, 2000, function(msg)
			if(callbackFunc and type(callbackFunc) == "function") then
				callbackFunc();
			end
		end);
	end
end

function Dock.OnSystemSetting()
	System.App.Commands.Call("File.Aries.Settings");
end

function Dock.DoSharePhotos()
	NPL.load("(gl)script/apps/Aries/Creator/SharePhotosPage.lua");
	MyCompany.Aries.Creator.SharePhotosPage.TakeSnapshotEx(); -- always take a snap shot when opened.

	if(System.options.locale == "zhCN") then
		MyCompany.Aries.Creator.SharePhotosPage.ShowPage();
	end
end

function Dock.OnGraphicsSetting()
	if(Player.IsInCombat()) then
		return;
	end
	System.App.Commands.Call("File.Settings");
end

function Dock.OnSoundSetting()
	System.App.Commands.Call("File.Settings");
end
function Dock.OnGotoHomeLand()
	if(Player.IsInCombat()) then
		return;
	end
	System.App.Commands.Call("Profile.Aries.MyHomeLand");
end
function Dock.OnGotoGroup()	
	if(Player.IsInCombat()) then
		return;
	end
	System.App.Commands.Call("Profile.Aries.MyFamilyWnd");
end

function Dock.OnOpenLottery()	
	NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemLuckyPage.lua");
    local ItemLuckyPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemLuckyPage");
    ItemLuckyPage.ShowPage();
end

function Dock.OnGotoCreatorWorld()
	NPL.load("(gl)script/apps/Aries/Creator/CreateOpenWorld.lua");
	MyCompany.Aries.Creator.CreateOpenWorld.ShowPage();
end

function Dock.OnGotoCreatorWorldNew()
	NPL.load("(gl)script/apps/Aries/Creator/Game/GameMarket/EnterGamePage.lua");
	local EnterGamePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.EnterGamePage");
	EnterGamePage.ShowPage(true);
end

function Dock.DoShowPetManager()
	if(Player.IsInCombat()) then
		return;
	end
	NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPage.lua");
	local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
	CombatPetPage.ShowPage(nil);
	-- click button sound
	AudioEngine.PlayUISound("Btn7");
end

-- toggle show/hide. 
-- @param num: [1,5] 5 character pages. 
-- @param bForceShow: force show instead of toggle show
function Dock.ShowCharPage(num, bForceShow, zorder)
	--if(Player.IsInCombat()) then
		--return;
	--end
	-- click button sound
	AudioEngine.PlayUISound("Btn7");
	-- show main window
	MyCompany.Aries.Desktop.CombatCharacterFrame.ShowMainWnd(tonumber(num), nil, bForceShow, zorder)
end

function Dock.ShowAutoTips()
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
	MyCompany.Aries.Desktop.AutoTips.ShowPage()
end
function Dock.UpdateDealButtonState()
end