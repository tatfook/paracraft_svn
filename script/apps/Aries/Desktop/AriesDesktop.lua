--[[
Title: Desktop UI for Aries App
Author(s): WangTian 
Date: 2009/4/7, 2011.4.8 revised for Tean Version LiXizhi
Desc: Desktop is cleanly devided by following areas, each area manages their own UI and functions: 
	1. Notification area: including magazine, journal, mail, message and telephone
	2. Quest area: rank, activity, bonous, quest(kids only), wish(kids only), camera toggle bar, ...
	3. Map area: Kids version: big map icon or leave icon for homezone application; Tean version: mini-map or leave icon for homezone
	5. Target area: Kids version:current interact target and available functions, also team member display; Tean version: only target object without team members
	6. Special area: e.g. the special functions available only in homezone application
	7. Dock area: always on top first level function list, it further divides into:
		7.1 Chatbar, chat box for user text input and functional button for advanced chatting, such as smiley, quick words, actions
		7.2 series of icons for each first level functions
    8. HpMyPlayer: Kids Version: hp display; Tean Version: HP, character head display, status, 4 team members display.
Note: Each area is further divided into separate files
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
Tean Version: 
    ---------------------------------------------------------
	| HpMyPlayer   Target							   Map	|
	| (Team)										 Quest	|
	|    									  Notification  |
	| 													 	|
	| 													 	|
	| 													 	|
	| 													 	|
	| 													 	|
	| 													 	|
	| 													 	|
	|													 	|
	|													 	|
	|													 	|
	| Chat         										 	|
	|														|
	|   		  | -------- Dock -------- |	MagicStar	|
	-------------------------Exp-----------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/AriesDesktop.lua");
MyCompany.Aries.Desktop.InitDesktop();
MyCompany.Aries.Desktop.SendMessage({type = MyCompany.Aries.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
MyCompany.Aries.Desktop.SendMessage({type = MyCompany.Aries.Desktop.MSGTYPE.ON_LEVELUP, level = 10});
local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");

local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
-- create class
local libName = "AriesDesktop";
local Desktop = commonlib.gettable("MyCompany.Aries.Desktop");

-- individual files of each UI area
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");

NPL.load("(gl)script/apps/Aries/Desktop/Profile.lua");
NPL.load("(gl)script/apps/Aries/Player/main.lua");

NPL.load("(gl)script/apps/Aries/Desktop/MagicStarArea.lua");
NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/ArrowPointer.lua");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");

NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Dialog_NPC.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbySharedLoot.lua");
local SharedLoot = commonlib.gettable("Map3DSystem.GSL.Lobby.SharedLoot");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");
local MagicStarArea = commonlib.gettable("MyCompany.Aries.Desktop.MagicStarArea");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
local BattleChatArea = commonlib.gettable("MyCompany.Aries.Combat.UI.BattleChatArea");
local Dialog = commonlib.gettable("MyCompany.Aries.Dialog");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");

NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");
local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");
-- messge types
local MSGTYPE = commonlib.createtable("MyCompany.Aries.Desktop.MSGTYPE", {
	-- show/hide the task bar, 
	-- msg = {bShow = true}
	SHOW_DESKTOP = 1001,

	-- invoked when player levels up. 
	-- {level = number:player level}
	ON_LEVELUP = 1002,

	-- invoked when desktop ui is shown. 
	-- {level = number:player level}
	ON_ACTIVATE_DESKTOP = 1003,
});

-- call this only once at the beginning of Aries. 
-- init desktop components
function Desktop.InitDesktop()
	if(Desktop.IsInit) then 
		return 
	end
	Desktop.IsInit = true;
	Desktop.name = libName;
	
	-- initialize each desktop area
	Desktop.NotificationArea.Init();
	Desktop.QuestArea.Init();
	Desktop.TargetArea.Init();
	Desktop.MapArea.Init();
	Desktop.Dock.Init();
	
	MagicStarArea.Init();

	--战斗任务已经 是否开启
	Desktop.EXPArea.Init();
	Desktop.HPMyPlayerArea.Init();
	Desktop.EXPArea.Show(true);
	Desktop.HPMyPlayerArea.Show(true);
	Desktop.AntiIndulgenceArea.Init();
	Desktop.GUIHelper.ArrowPointer.Init();
	Desktop.InitAutoTips();

	Desktop.Teen0LvlAutoEquip();

	NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
	Desktop.LocalMap.Init();
	
	-- register the notification timer
	Desktop.Dock.RegisterDoNotificationTimer()
	
	QuestTrackerPane.Show(false);
	
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
	end

	NPL.load("(gl)script/apps/Aries/Trade/TradeClient.lua");
	MyCompany.Aries.Trade.TradeClient:RegisterEventHandler();

	-- create windows for message handling
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp(Desktop.name);
	Desktop.App = _app;
	Desktop.MainWnd = _app:RegisterWindow("main", nil, Desktop.MSGProc);

	-- this will disable picking for physics group 2. 
	ParaScene.GetAttributeObject():SetField("PhysicsGroupMask", 11);

	-- whether to use 3d scaling.
	local att = ParaScene.GetAttributeObject();
	att:SetField("HeadOn3DScalingEnabled", MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableHeadonTextScaling",true));

	-- whether to enable friend to teleport to my position. 
	System.options.EnableFriendTeleport = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableFriendTeleport",true);
	
	-- whether to enable auto picking single target after card picking
	if(System.options.version == "teen") then
		System.options.EnableAutoPickSingleTarget = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableAutoPickSingleTarget", true);
	else
		System.options.EnableAutoPickSingleTarget = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableAutoPickSingleTarget", false);
	end
	
	-- whether to hide the player hat and back
	System.options.EnableForceHideHead = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableForceHideHead", false);
	System.options.EnableForceHideBack = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableForceHideBack", false);

	-- whether to enable add friend
	System.options.isAllowAddFriend = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxAllowAddFriend",true);

	-- enable background music
	if(System.options.IsMobilePlatform) then
		System.options.EnableBackgroundMusic = false;
	else
		System.options.EnableBackgroundMusic = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableBackgroundMusic",true, true );
	end

	-- hide family name 
	System.options.hide_family_name = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.hide_family_name",false);

	-- load gossip if any
	NPL.load("(gl)script/apps/Aries/Player/GossipAI.lua");
	local GossipAI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.GossipAI");
	GossipAI.OnInit();

	--家族用户背包里面所有的物品，记录物品总数量
	CharacterBagPage.SynchUserBag();
	-- called whenever the user has paid. 
	MyCompany.Aries.event:AddEventListener("pay", function(self, event) 
		LOG.std(nil, "system", "pay", event);

		Map3DSystem.Item.ItemManager.GetItemsInBag(0, nil, function()  
			Map3DSystem.Item.ItemManager.GetItemsInBag(1, nil, function()  
				-- update the user info 
				System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg) 
					-- update all page controls containing the pe:slot tag
					Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();

					MyCompany.Aries.event:DispatchEvent({type="pay_after", })

					NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
					local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
					local provider = QuestClientLogics.provider;
					if(provider)then
						provider:NotifyChanged();
						NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
						local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
						QuestTrackerPane.NeedReload();
						QuestTrackerPane.ReloadPage();
					end
					
				end, "access plus 0 day");
			
				Dock.OnExtendedCostNotification({adds={{gsid = 984, cnt = event.count or 0}}});
			
			end, "access plus 0 day");
		end, "access plus 0 day");

	end, nil, "aries_external_pay_money");

end

function Desktop.InitAutoTips()
	-- 启动主动提醒, always show on first start
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
	local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
	AutoTips.ShowPage();
end
-- whenever user switched world and desktop is activated. 
-- refresh all user interfaces here. 
function Desktop.OnActivateDesktop()
	MsgHandler.OnActivateDesktop();

	QuestTrackerPane.is_disabled = nil;
	QuestTrackerPane.last_goalid = nil;
	MyCompany.Aries.Player.SetHeadonTextColorFunction(nil);
	Desktop.HPMyPlayerArea.OnActivateDesktop();
	Desktop.MapArea.OnActivateDesktop();
	BattleChatArea.OnActivateDesktop();

	-- 0 will use unlit biped selection effect. 1 will use yellow border style. 
	local DefaultTheme = commonlib.gettable("MyCompany.Aries.Theme.Default");
	ParaScene.GetPlayer():SetField("SelectionEffect", DefaultTheme.BipedSelectionEffect or 1);
	if(System.options.version == "teen") then
		ParaCamera.GetAttributeObject():SetField("MinCameraObjectDistance", 5);
	end
	
	NPL.load("(gl)script/apps/Aries/Login/WorldAssetPreloader.lua");
	local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")
	WorldAssetPreloader.OnPlayerReachedLevel();

	-- this ensure that proper ui is displayed
	Desktop.SendMessage({type = MyCompany.Aries.Desktop.MSGTYPE.ON_ACTIVATE_DESKTOP, level = MyCompany.Aries.Player.GetLevel()});

	if(Map3DSystem.User.need_to_check_locked)then
		Map3DSystem.User.need_to_check_locked = false;
		DealDefend.Reset();
		DealDefend.LoadState(function()
			Dock.UpdateDealButtonState();
		end)
	end

	NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyGlobalEvent.lua");
	local GlobalEvent = commonlib.gettable("Map3DSystem.GSL.Lobby.GlobalEvent");
	GlobalEvent.Start(true);
end


-- only call this when all UI have been reset. 
function Desktop.CleanUp()
	Desktop.IsInit = false;
end

-- send a message to Desktop:main window handler
-- Desktop.SendMessage({type = Desktop.MSGTYPE.MENU_SHOW});
function Desktop.SendMessage(msg)
	msg.wndName = "main";
	Desktop.App:SendMessage(msg);
end


-- Desktop window handler
function Desktop.MSGProc(window, msg)
	if(msg.type == MSGTYPE.SHOW_DESKTOP) then
		-- show/hide the task bar, 
		-- msg = {bShow = true}
		Desktop.Show(msg.bShow);

	else -- if(msg.type == MSGTYPE.ON_LEVELUP) then
		
		Desktop.NotificationArea.MSGProc(msg);
		Desktop.QuestArea.MSGProc(msg);
		Desktop.Dock.MSGProc(msg);
	end
end

-------------------------
-- protected
-------------------------

-- show or hide task bar UI
function Desktop.Show(bShow)
	if(Desktop.IsInit == false) then return end
	if(bShow == true) then
		-- show desktop with animation
		-- Desktop.ShowDesktopWithAnimation();
		-- tracker is always shown on each world login. it maybe hidden afterwards by other modules such as in instance world or homeland,etc.
		-- QuestTrackerPane.Show(true);
		-- EXPBuffArea.Show_LobbyBtn(true);
	end
end

-- show all desktop areas
function Desktop.ShowAllAreas()
	Desktop.IsVisible = true;
	Desktop.NotificationArea.Show(true);
	Desktop.QuestArea.Show(true);
	Desktop.QuestArea.Show3DTracker(true);
	Desktop.TargetArea.Show(true);
	Desktop.MapArea.Show(true);
	Desktop.Dock.Show(true);
	AutoTips.ShowAutoTips(true);
	LoopTips.ShowPage(true);

	MagicStarArea.Show(true);
	Desktop.EXPArea.Show(true);
	Desktop.HPMyPlayerArea.Show(true);

	--刷新战斗UI 如果战斗任务没有开启 血条 经验条 不会显示
	Desktop.AntiIndulgenceArea.Show(true);
	--QuestTrackerPane.Show(true);
	
	--EXPBuffArea.Show_LobbyBtn(true);
	BattleChatArea.Show(true);

	Dialog.ShowHideAllTransparentPage(true);
	LinksAreaPage.Show(true);
end

-- hide all desktop areas
function Desktop.HideAllAreas()
	Desktop.IsVisible = false;
	Desktop.NotificationArea.Show(false);
	Desktop.QuestArea.Show(false);
	Desktop.QuestArea.Show3DTracker(false);
	Desktop.TargetArea.Show(false);
	Desktop.MapArea.Show(false);
	Desktop.Dock.Show(false);
	AutoTips.ShowAutoTips(false);
	LoopTips.ShowPage(false);

	Desktop.EXPArea.Show(false);
	Desktop.HPMyPlayerArea.Show(false);
	Desktop.AntiIndulgenceArea.Show(false);
	MagicStarArea.Show(false);
	--QuestTrackerPane.Show(false);
	--EXPBuffArea.Show_LobbyBtn(false);
	BattleChatArea.Show(false);
	Dialog.ShowHideAllTransparentPage(false);
	LinksAreaPage.Show(false);
end

-- return true if desktop is currently visible. 
function Desktop.IsVisible()
	return Desktop.IsVisible;
end

-- Change the UI mode. Each area may have different display layout in default mode. 
-- @param mode: "tutorial", "combat", "normal", "home", etc
function Desktop.SetMode(mode)
	-- call set mode of each area
	BattleChatArea.SetMode(mode);
	HPMyPlayerArea.SetMode(mode);
end

-- received GSL chat message
function Desktop.OnReceiveGSLChatMsg(nid, value)
	local sFirstLetter = string.sub(value,1,1)
	if(sFirstLetter=="{")then
		ChatChannel.AppendChat( value, true, nid);
	elseif(sFirstLetter=="/")then
		local cmd_name, cmd_body = value:match("^/(%S+)%s*(.*)$");
		LOG.std(nil, "debug", "gsl char command", value);

		if(System.options.mc) then
			-- mc does not handle these commands
			return;
		end

		if(cmd_name == "addon") then
			local nid,gsid, level,name = cmd_body:match("^(%d+) (%d+) (%d+)(.*)");
			if(nid and level and ExternalUserModule:CanViewUser(nid)) then
				nid = tonumber(nid);
				gsid = tonumber(gsid);
				level = tonumber(level);
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem and gsItem.template) then
					
					if(level>=7) then
						local text = format("恭喜%s将[%s]装备强化至【%d级】", name or tostring(nid), gsItem.template.name or "", level)
						BroadcastHelper.PushLabel({id="addon_bbs", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					end
					if(level>=0) then
						name = commonlib.Encoding.EncodeStr(name);
						NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
						local text_name = format([[<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
							tooltip="%s" onclick="MyCompany.Aries.ChatSystem.ChatWindow.OnClickName" param1='%s'><div style="float:left;margin-top:-2px;color:#f9f7d4">%s</div></a>]], "左键私聊, 右键查看", tostring(nid)..":"..(name or ""), name or tostring(nid));
						local mcml_text = format([[恭喜%s将%s装备强化至【%d级】]], text_name, CommonCtrl.GenericTooltip.GetItemMCMLText(gsid, nil, false, "class='bordertext'"), level)
						ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, is_direct_mcml=true, words=mcml_text});
					end
				end
			end
		elseif(cmd_name == "opencards") then
			local nid,gsids, bag_gsid, name = cmd_body:match("^(%d+) ([%d,]+) (%d+) (.*)");
			if(nid and bag_gsid and ExternalUserModule:CanViewUser(nid)) then
				
				local cards = {};
				local gsid;
				for gsid in gsids:gmatch("%d+") do
					gsid = tonumber(gsid);
					cards[#cards+1] = gsid;
				end
				
				nid = tonumber(nid);
				bag_gsid = tonumber(bag_gsid);
				
				local card_text = "";
				local card_mcml = "";
				local _;
				for _, gsid in ipairs(cards) do
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem and gsItem.template.class == 18) then
						local quality = gsItem.template.stats[221];
						if(quality) then
							if(quality>=3) then
								card_text = card_text..format("[%s]", gsItem.template.name or "");
							end
							if(quality>=2) then
								card_mcml = card_mcml..CommonCtrl.GenericTooltip.GetItemMCMLText(gsid, nil, false, "class='bordertext'");
							end	
						end
					end
				end
				local gsItem_bag = ItemManager.GetGlobalStoreItemInMemory(bag_gsid);
				if(gsItem_bag) then
					if(card_text~="") then
						local text = format("恭喜%s从[%s]中获得了%s", name or tostring(nid), gsItem_bag.template.name or "", card_text)
						BroadcastHelper.PushLabel({id="opencards", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					end
					if(card_mcml~="") then
						name = commonlib.Encoding.EncodeStr(name);
						NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
						local text_name = format([[<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
							tooltip="%s" onclick="MyCompany.Aries.ChatSystem.ChatWindow.OnClickName" param1='%s'><div style="float:left;margin-top:-2px;color:#f9f7d4">%s</div></a>]], "左键私聊, 右键查看", tostring(nid)..":"..(name or ""), name or tostring(nid));
						local mcml_text = format([[恭喜%s从%s中获得了%s]], text_name, CommonCtrl.GenericTooltip.GetItemMCMLText(bag_gsid, nil, false, "class='bordertext'"), card_mcml)
						ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, is_direct_mcml=true, words=mcml_text});
					end
				end
			end
		elseif(cmd_name == "opengifts") then
			local nid,gsids, bag_gsid, name = cmd_body:match("^(%d+) ([%d,]+) (%d+) (.*)");
			if(nid and bag_gsid and ExternalUserModule:CanViewUser(nid)) then
				
				local cards = {};
				local gsid;
				for gsid in gsids:gmatch("%d+") do
					gsid = tonumber(gsid);
					cards[#cards+1] = gsid;
				end
				
				nid = tonumber(nid);
				bag_gsid = tonumber(bag_gsid);
				
				local card_text = "";
				local card_mcml = "";
				local _;
				for _, gsid in ipairs(cards) do
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem and gsItem.template.class == 18) then
						local quality = gsItem.template.stats[221];
						if(quality) then
							if(quality>=3) then
								card_text = card_text..format("[%s]", gsItem.template.name or "");
							end
							if(quality>=2) then
								card_mcml = card_mcml..CommonCtrl.GenericTooltip.GetItemMCMLText(gsid, nil, false, "class='bordertext'");
							end	
						end
					end
				end
				local gsItem_bag = ItemManager.GetGlobalStoreItemInMemory(bag_gsid);
				if(gsItem_bag) then
					if(card_text~="") then
						local text = format("恭喜%s从[%s]中获得了%s", name or tostring(nid), gsItem_bag.template.name or "", card_text)
						BroadcastHelper.PushLabel({id="opengifts", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					end
					if(card_mcml~="") then
						name = commonlib.Encoding.EncodeStr(name);
						NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
						local text_name = format([[<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
							tooltip="%s" onclick="MyCompany.Aries.ChatSystem.ChatWindow.OnClickName" param1='%s'><div style="float:left;margin-top:-2px;color:#f9f7d4">%s</div></a>]], "左键私聊, 右键查看", tostring(nid)..":"..(name or ""), name or tostring(nid));
						local mcml_text = format([[恭喜%s从%s中获得了%s]], text_name, CommonCtrl.GenericTooltip.GetItemMCMLText(bag_gsid, nil, false, "class='bordertext'"), card_mcml)
						ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, is_direct_mcml=true, words=mcml_text});
					end
				end
			end


		elseif(cmd_name == "shared_loot") then
			local nid,loot_name, count,name = cmd_body:match("^(%d+) (%S+) (%d+) (.*)");
			if(nid and loot_name and ExternalUserModule:CanViewUser(nid)) then
				nid = tonumber(nid);
				count = tonumber(count);

				local loot = SharedLoot.GetLoot(loot_name);
				if(loot) then
					local text_format;
					local item_name = "";
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(loot.reward_gsid);
					if(gsItem) then
						item_name = gsItem.template.name;
					end

					local title = loot.attr.title or loot_name;
					local item_count_text;
					if(loot.reward_count and loot.reward_count>1) then
						item_count_text = "X"..loot.reward_count;
					end
					local text = format("恭喜%s在【%s】中时运爆发获得了[%s]%s", name or tostring(nid), title, item_name, item_count_text or "");
					BroadcastHelper.PushLabel({id="loot_bbs", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					
					name = commonlib.Encoding.EncodeStr(name);
					NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
					local text_name = format([[<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
						tooltip="%s" onclick="MyCompany.Aries.ChatSystem.ChatWindow.OnClickName" param1='%s'><div style="float:left;margin-top:-2px;color:#f9f7d4">%s</div></a>]], "左键私聊, 右键查看", tostring(nid)..":"..(name or ""), name or tostring(nid));
					local mcml_text;
					if(loot.reward_gsid == 2129 or loot.reward_gsid == 2131) then
						NPL.load("(gl)script/apps/Aries/Pet/LittleGame.lua");
						local button = "<input type='button' style='font-size:12px;height:18px;margin-top:-2px;' value='赶紧看看' onclick='MyCompany.Aries.Pet.LittleGame.ShowPage' class='linkbutton_yellow' />";
						mcml_text = format("[公告]恭喜%s在【%s】中时运爆发获得了%s%s%s", text_name, title, CommonCtrl.GenericTooltip.GetItemMCMLText(loot.reward_gsid, nil, false, "class='bordertext'"), item_count_text or "",button)	;
					else
						mcml_text = format("[公告]恭喜%s在【%s】中时运爆发获得了%s%s", text_name, title, CommonCtrl.GenericTooltip.GetItemMCMLText(loot.reward_gsid, nil, false, "class='bordertext'"), item_count_text or "")	;
					end
					
					ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, is_direct_mcml=true, words=mcml_text, bHideSubject = true});
				end
			end
		elseif(cmd_name == "lottery") then
			local nid,gsid, count,name = cmd_body:match("^(%d+) (%d+) (%d+)(.*)");
			if(nid and gsid and ExternalUserModule:CanViewUser(nid)) then
				nid = tonumber(nid);
				gsid = tonumber(gsid);
				count = tonumber(count);
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem and gsItem.template) then
					local text_format;
					local nID = math.random(1,3);
					if(nID<=1) then
						text_format = "%s玩家排除万难，在大乐透中抽中了%s，大家给点掌声！";
					elseif(nID<=2) then
						text_format = "%s玩家今天的时运爆发，在大乐透中抽中了%s！";
					else
						text_format = "%s玩家人品大爆发，在大乐透中抽中了%s，恭喜一下！";
					end

					local text = format(text_format, name or tostring(nid), gsItem.template.name or "")
					BroadcastHelper.PushLabel({id="lottery_bbs", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					
					name = commonlib.Encoding.EncodeStr(name);
					NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
					local text_name = format([[<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
						tooltip="%s" onclick="MyCompany.Aries.ChatSystem.ChatWindow.OnClickName" param1='%s'><div style="float:left;margin-top:-2px;color:#f9f7d4">%s</div></a>]], "左键私聊, 右键查看", tostring(nid)..":"..(name or ""), name or tostring(nid));
					local mcml_text = format(text_format..[[<input type="button" style="font-size:12px;height:18px;" value="试试手气" onclick="MyCompany.Aries.Desktop.Dock.OnOpenLottery" class="linkbutton_yellow" />]], text_name, CommonCtrl.GenericTooltip.GetItemMCMLText(gsid, nil, false, "class='bordertext'"))
					ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, is_direct_mcml=true, words=mcml_text});
				end
			end
		elseif(cmd_name == "lotteryFormItem") then
			local nid,from_gsid, loot_gsid ,loot_count,name = cmd_body:match("^(%d+) (%d+) (%d+) (%d+)(.*)");
			if(nid and from_gsid and loot_gsid and loot_count and ExternalUserModule:CanViewUser(nid)) then
				nid = tonumber(nid);
				from_gsid = tonumber(from_gsid);
				loot_gsid = tonumber(loot_gsid);
				loot_count = tonumber(loot_count);
				local from_gsItem = ItemManager.GetGlobalStoreItemInMemory(from_gsid);
				local loot_gsItem = ItemManager.GetGlobalStoreItemInMemory(loot_gsid);
				if(from_gsItem and from_gsItem.template and loot_gsItem and loot_gsItem.template) then
					local text_format;
					--local nID = math.random(1,3);
					--if(nID<=1) then
						--text_format = "%s玩家排除万难，在大乐透中抽中了%s，大家给点掌声！";
					--elseif(nID<=2) then
						--text_format = "%s玩家今天的时运爆发，在大乐透中抽中了%s！";
					--else
						--text_format = "%s玩家人品大爆发，在大乐透中抽中了%s，恭喜一下！";
					--end

					text_format = "玩家%s人品大爆发，打开%s后获得了%d个%s";

					local text = format(text_format, name or tostring(nid), from_gsItem.template.name or "", loot_count, loot_gsItem.template.name or "")
					BroadcastHelper.PushLabel({id="lottery_bbs", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					
					name = commonlib.Encoding.EncodeStr(name);
					NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
					local text_name = format([[<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
						tooltip="%s" onclick="MyCompany.Aries.ChatSystem.ChatWindow.OnClickName" param1='%s'><div style="float:left;margin-top:-2px;color:#f9f7d4">%s</div></a>]], "左键私聊, 右键查看", tostring(nid)..":"..(name or ""), name or tostring(nid));
					local mcml_text = format(text_format, text_name, CommonCtrl.GenericTooltip.GetItemMCMLText(from_gsid, nil, false, "class='bordertext'"), loot_count, CommonCtrl.GenericTooltip.GetItemMCMLText(loot_gsid, nil, false, "class='bordertext'"))
					ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, is_direct_mcml=true, words=mcml_text});
				end
			end
		end
	else
		--MyCompany.Aries.BBSChatWnd.AddDialog(nid, value);
		LOG.std(nil, "debug", "client_chat_rec", value);
	end
end

function Desktop.Teen0LvlAutoEquip()
	if (System.options.version == "teen") then
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		local deck=ItemManager.GetItemByBagAndPosition(0, 24); -- 战斗背包种类
		local combatbag_gsid = deck.gsid;
		
		local hasItem,guid = hasGSItem(combatbag_gsid);
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			commonlib.echo(item);
			if(item)then
				local clientdata = item.clientdata;
				commonlib.echo("==========before Teen0LvlAutoEquip()");
				commonlib.echo(clientdata);
				if(clientdata == "" or clientdata == "{}")then								
					NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
					local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
					MyCardsManager.Init();
					NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
					local CombatSkillLearn = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn");
					log("+++++++ Teen0LvlAutoEquip() Enter+++++++\n")
					CombatSkillLearn.TeenAutoStudy();
				end	
			end
		end
	end
end