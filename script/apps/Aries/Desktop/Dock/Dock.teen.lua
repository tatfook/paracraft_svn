--[[
Title: Desktop Dock Area for Aries App
Author(s): LiXizhi, WangTian
Company: ParaEnging Co.
Date: 2011/4/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/Dock.teen.lua");
MyCompany.Aries.Desktop.Dock.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.lua");
local MinorSkillPage = commonlib.gettable("MyCompany.Aries.Desktop.MinorSkillPage");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemBuildPage.lua");
local ItemBuildPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemBuildPage");
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
NPL.load("(gl)script/apps/Aquarius/Desktop/LocalMap.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatWindow.lua");
local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
-- create class
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
Dock.static_view_page_index = 1;
Dock.static_view_len = 9;
local page;
-- virtual function: create UI
function Dock.Create()
	local _parent = ParaUI.CreateUIObject("container", "Aries_Dock", "_ctb", 0, 0, 940, 111);
	_parent.background = "";
	_parent.zorder = -3;
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();

	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/Dock/Dock2.teen.html",click_through = true,});

	if(System.options.IsMobilePlatform) then
		page.SelfPaint = true;
	end

	-- one can create a UI instance like this. 
	page:Create("Aries_Dock_mcml", _parent, "_fi", 0, 0, 0, 0);

	-- this is tricky to keep the friend list alive
	NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
	-- tricky: inform that UI is available, any offline messages can now be pushed to ui. 
	MyCompany.Aries.Friends.SetUIAvailable(true);
	-- tricky: update subscriptions. so that the presence are sent and received. 
	MyCompany.Aries.Friends.UpdateJabberSubscription();
	Dock.RegistCmd();

	NPL.load("(gl)script/apps/Aries/Desktop/Dock/ManualDock.lua");
	local ManualDock = commonlib.gettable("MyCompany.Aries.Desktop.ManualDock");
	ManualDock.InternalOnInit();

	--NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
	--local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
	--LoopTips.DoStartDefault()

	NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
	local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
	DockTip.GetInstance();


	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClientLogics.lua");
	local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");
	GathererClientLogics.OnInit();
	DealDefend.LoadState(function()
		Dock.UpdateDealButtonState();
	end)
	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	QuestHelp.AddEventListener();

	NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
	local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
	local manager = FamilyManager.CreateOrGetManager();
	manager:TryAutoSignIn();
end

function Dock.SetButtonEnabled(name, bEnable)
	-- TODO: 
end

-- public: this function is called. whenever the user pressed the enter key and wants to enter some chat message. 
function Dock.OnEnterChat()
	MyCompany.Aries.ChatSystem.ChatWindow.ShowAllPage(true);
end
--在key_settings_default.csv配置
--local key_to_cmd_map = {
	--["c"] = "ProfilePane.ShowPage",--人物
	---- ["z"] = "PetPage.ShowPage",--坐骑
	--["p"] = "CombatPetPane.ShowPage",--宠物
	--["b"] = "CharacterBagPage.ShowPage",--背包
	--["v"] = "CombatCardTeen",--技能
	--["l"] = "QuestPane.ShowPage",--任务
	--["t"] = "LobbyClientServicePage.ShowPage",--组队
	--["f"] = "FriendsPage.ShowPage",--好友
	--["j"] = "FamilyMembersPage.ShowPage",--家族
	--["h"] = "AutoTip",--帮助
	--["m"] = "Aries.LocalMapMCML",--地图
	--["toggleplayers"] = "ToggleRenderOtherPlayer",
--}
--
--function Dock.FireKey(key)
	--if(not key)then return end
	--if(type(key)== "number" and key >=1 and key <= 9)then
		--local index = Dock.static_view_len * (Dock.static_view_page_index - 1) + key
--
		---- click item shortcut with index
		--ItemManager.OnClickItemShortcut(index);
	--else
		--if(key_to_cmd_map[key]) then
			--Dock.FireCmd(key_to_cmd_map[key]);
		--end
	--end
--end

-- settings related. 
function Dock.OnClickSettings()
	local x, y, width, height = _guihelper.GetLastUIObjectPos();
	if(y) then
		y = y - 10;
	else
		LOG.std(nil, "warn", "Dock", "no last ui pos");
		return;
	end

	System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Desktop/Functions/SystemMenuPopup.teen.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "SystemMenuPopup.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = false,
		isTopLevel = true,
		is_click_to_close = true,
        directPosition = true,
            align = "_lt",
            x = x,
            y = y - 195,
            width = 140,
            height = 195,
    });
end

function Dock.PayGuide()
	NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.teen.lua");
	local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
	PurchaseMagicBean.Show()	
end

function Dock.PENoteDoPost()
    NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage();	
end

function Dock.UpdateDealButtonState()
	if(page) then
		local btn = page:FindControl("DealButton");
		if(btn) then
			if(not DealDefend.HasLockPassword())then
				btn.tooltip ="设置交易密码";
				btn.background = "Texture/Aries/Dock/teen/unlock2_32bits.png; 0 0 16 19";
				return
			end

			local is_locked = DealDefend.IsLocked()
			page:SetValue("DealButton", is_locked);

			if(is_locked)then
				btn.tooltip ="你的物品正受到交易密码的保护。可点击解锁";
				btn.background = "Texture/Aries/Dock/teen/lock2_32bits.png; 0 0 16 19";
			else
				btn.tooltip ="交易密码管理";
				btn.background = "Texture/Aries/Dock/teen/unlock2_32bits.png; 0 0 16 19";
			end
		end
	else
		local btn = ParaUI.GetUIObject("CharAreaButtons".."btn_deal");
		if(btn and btn:IsValid())then
			if(not DealDefend.HasLockPassword())then
				btn.tooltip ="设置交易密码";
				btn.background = "Texture/Aries/Dock/teen/unlock2_32bits.png; 0 0 16 19";
				return
			end
			--解锁
			if(DealDefend.IsLocked())then
				btn.tooltip ="你的物品正受到交易密码的保护。可点击解锁";
				btn.background = "Texture/Aries/Dock/teen/lock2_32bits.png; 0 0 16 19";
			else
				btn.tooltip ="交易密码管理";
				btn.background = "Texture/Aries/Dock/teen/unlock2_32bits.png; 0 0 16 19";
			end
		end
	end
end
function Dock.OnClickDealPage()
	if(not DealDefend.HasChecked())then
		return;
	end
	--设置交易密码
	if(not DealDefend.HasLockPassword())then
		NPL.load("(gl)script/apps/Aries/DealDefend/DealLockPage.lua");
		local DealLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealLockPage");
		DealLockPage.ShowPage();
		return
	end
	--如果重置申请生效 重新加载
	if(DealDefend.ResetPassword_Successful_InMemory())then
		local date1,date2 = DealDefend.GetTime();
		paraworld.PostLog({action = "reset_deal_password_failed", nid = Map3DSystem.User.nid,reset_time = date1,post_time = date2,}, 
			"reset_deal_password_failed_log", function(msg)
		end);
		_guihelper.MessageBox("重置密码申请已经生效，请重新登录！");
		return;
	end
	--解锁
	if(DealDefend.IsLocked())then
		NPL.load("(gl)script/apps/Aries/DealDefend/DealUnLockPage.lua");
		local DealUnLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealUnLockPage");
		DealUnLockPage.ShowPage();
	else
		NPL.load("(gl)script/apps/Aries/DealDefend/DealUnLockPage.lua");
		local DealUnLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealUnLockPage");
		DealUnLockPage.ShowPage("do_manage");
	end
end

function Dock.OnClickSkill()
	local x, y, width, height = _guihelper.GetLastUIObjectPos();
	if(y) then
		y = y - 10;
	else
		LOG.std(nil, "warn", "Dock", "no last ui pos");
		return;
	end

	System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Desktop/Functions/SkillMenuPopup.teen.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "SkillMenuPopup.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = false,
		isTopLevel = true,
		is_click_to_close = true,
        directPosition = true,
            align = "_lt",
            x = x,
            y = y - 64,
            width = 140,
            height = 64,
    });
end
-- virtual: show or hide all windows related to the dock. such as the character, map, pet, etc. 
function Dock.ShowHideAllWindow(bShow)
	if(not Dock.last_cmd)then
		return
	end
	if(not bShow) then
		local node = Dock.cmds[Dock.last_cmd];
		local wndName = node.wndName or "";
		local _wnd = Dock.FindWindow(wndName);
		if(_wnd and _wnd:IsVisible())then
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = wndName, app_key=MyCompany.Aries.app.app_key, bShow = false,bDestroy = true,});
		end
	end
	if(Dock.is_quick_dock_page_opened and not bShow) then
		Dock.ShowHideQuickDockPage(false);
	elseif(Dock.is_quick_dock_page_opened and bShow) then
		Dock.ShowHideQuickDockPage(true);
	end
end

function Dock.OnClickMountPetButton()
	local x, y, width, height = _guihelper.GetLastUIObjectPos();
	if(y) then
		y = y - 10;
	else
		LOG.std(nil, "warn", "Dock", "no last ui pos");
		return;
	end

	local show_mount_page_direct = true;
	if(not show_mount_page_direct) then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Desktop/Functions/MountPetMenuPopup.teen.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "MountPetMenuPopup.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			isTopLevel = true,
			is_click_to_close = true,
			directPosition = true,
				align = "_lt",
				x = x,
				y = y - 128,
				width = 140,
				height = 128,
		});
	else
		NPL.load("(gl)script/apps/Aries/Inventory/PetPage.lua");
		local PetPage = commonlib.gettable("MyCompany.Aries.Inventory.PetPage");
		PetPage.ShowPage();
	end
end

function Dock.FireCmd(cmd,...)
	if(not cmd)then return end
	if(Dock.last_cmd and Dock.last_cmd ~= cmd)then
		local node = Dock.cmds[Dock.last_cmd];
		local wndName = node.wndName or "";
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = wndName, app_key=MyCompany.Aries.app.app_key, bShow = false,bDestroy = node.bDestroyOnClose,});
	end
	Dock.__FireCmd(cmd,...);
	Dock.last_cmd = cmd;
end
function Dock.__FireCmd(cmd,...)
	if(not cmd)then return end
	local node = Dock.cmds[cmd];
	local wndName = node.wndName or "";
	local _wnd = Dock.FindWindow(wndName);
	if(_wnd)then
		if(_wnd:IsVisible())then
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = wndName, app_key=MyCompany.Aries.app.app_key, bShow = false,bDestroy = node.bDestroyOnClose,});
		else
			if(cmd == "Aries.LocalMapMCML")then
				LocalMap.Show();
				return;
			end
			if(node and node.show_func)then
				if(node.show_params) then
					node.show_func(unpack(node.show_params));
				else
					node.show_func(...);
				end
			end
		end
	else
		if(cmd == "Aries.LocalMapMCML")then
			LocalMap.Show();
			return;
		end
		if(node and node.show_func)then
			if(node.show_params) then
				node.show_func(unpack(node.show_params));
			else
				node.show_func(...);
			end
		end
	end
end
function Dock.RegistCmd()
	NPL.load("(gl)script/apps/Aries/NewProfile/ProfilePane.lua");
	local ProfilePane = commonlib.gettable("MyCompany.Aries.ProfilePane");
	NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
	local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
	NPL.load("(gl)script/apps/Aries/Inventory/PetPage.lua");
	local PetPage = commonlib.gettable("MyCompany.Aries.Inventory.PetPage");
	NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
	local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
	NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
	local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
	 NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
    local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
	NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
	local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
	local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
	NPL.load("(gl)script/apps/Aries/Family/FamilyMembersPage.lua");
	local FamilyMembersPage = commonlib.gettable("Map3DSystem.App.Family.FamilyMembersPage");
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
	local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
	 NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.lua");
    local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");
	NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
	local HaqiShop = commonlib.gettable("MyCompany.Aries.HaqiShop");
	NPL.load("(gl)script/apps/Aquarius/Desktop/LocalMap.lua");
	local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
	NPL.load("(gl)script/apps/Aries/Desktop/HelpMainList.teen.lua");
	local HelpMainList = commonlib.gettable("MyCompany.Aries.Desktop.HelpMainList");
	NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
	local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");

	NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.lua");
	local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");

	NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/CastMachine.teen.lua");
	local CastMachine = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine");

	NPL.load("(gl)script/apps/Aries/HaqiShop/AuctionHouse.lua");
	local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
	if(not Dock.cmds)then
		Dock.cmds = {
			["ProfilePane.ShowPage"] = { wndName = "ProfilePane.ShowPage", show_func = ProfilePane.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["MountPet.ShowMenu"] = { wndName = "MountPet.ShowMenu", show_func = Dock.OnClickMountPetButton,enable_hide_docktip = true, bDestroyOnClose=true,},
			["PetPage.ShowPage"] = { wndName = "PetPage.ShowPage", show_func = PetPage.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			--["CombatPetPane.ShowPage"] = { wndName = "CombatPetPane.ShowPage", show_func = CombatPetPane.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["CombatFollowPetPane.ShowPage"] = { wndName = "CombatFollowPetPane.ShowPage", show_func = CombatFollowPetPane.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["CharacterBagPage.ShowPage"] = { wndName = "CharacterBagPage.ShowPage", show_func = CharacterBagPage.ShowPage_click_from_dock, enable_hide_docktip = true, bDestroyOnClose=true,},
			["CombatCardTeen"] = { wndName = "CombatCardTeen", show_func = MyCardsManager.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["QuestPane.ShowPage"] = { wndName = "QuestPane.ShowPage", show_func = QuestPane.ShowPage, show_params={"can_accept_quest"}, enable_hide_docktip = true, bDestroyOnClose=true,},
			["LobbyClientServicePage.ShowPage"] = { wndName = "LobbyClientServicePage.ShowPage", show_func = LobbyClientServicePage.ShowDefaultRooms, enable_hide_docktip = true, bDestroyOnClose=true,},
			["LobbyClientServicePage.ShowMenu"] = { wndName = "LobbyClientServicePage.ShowPage", show_func = LobbyClientServicePage.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["LobbyClientServicePage.ShowMenuPvP"] = { wndName = "LobbyClientServicePage.ShowPage", show_func = LobbyClientServicePage.ShowPagePvP, enable_hide_docktip = true, bDestroyOnClose=true,},
			["FriendsPage.ShowPage"] = { wndName = "FriendsPage.ShowPage", show_func = FriendsPage.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["FamilyMembersPage.ShowPage"] = { wndName = "FamilyMembersPage.ShowPage", show_func = FamilyMembersPage.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["AutoTip"] = { wndName = "AutoTip", show_func = AutoTips.ShowPage,bDestroyOnClose=true,},
			["MagicStarPage.ShowPage"] = { wndName = "MagicStarPage.ShowPage", show_func = MagicStarPage.ShowPage, bDestroyOnClose=true,},
			["HaqiShop.ShowMainWnd"] = { wndName = "HaqiShop.ShowMainWnd", show_func = MyCompany.Aries.HaqiShop.ShowMainWnd, bDestroyOnClose=true,},
			["AuctionHouse.ShowPage"] = { wndName = "AuctionHouse.ShowMainWnd", show_func = MyCompany.Aries.AuctionHouse.ShowPage, bDestroyOnClose=true,},
			["Aries.LocalMapMCML"] = { wndName = "Aries.LocalMapMCML", show_func = LocalMap.Show, enable_hide_docktip = true, bDestroyOnClose=false,},
			["HelpMainList.ShowPage"] = { wndName = "HelpMainList.ShowPage", show_func = HelpMainList.ShowPage, enable_hide_docktip = true, bDestroyOnClose=true,},
			["ToggleRenderOtherPlayer"] = { wndName = "ToggleRenderOtherPlayer", show_func = MapArea.ToggleRenderPlayers, bDestroyOnClose=true,},
			["MagicStarPage.ShowPage"]={ wndName = "MagicStarPage.ShowPage", show_func = MagicStarPage.ShowPage, bDestroyOnClose=true,},
			["ItemBuildPage.ShowPage"]={ wndName = "ItemBuildPage.ShowPage", show_func = ItemBuildPage.ShowPage, bDestroyOnClose=true,},
			["MinorSkillPage.ShowPage"]={ wndName = "MinorSkillPage.ShowPage", show_func = MinorSkillPage.ShowPage, bDestroyOnClose=true,},
		}
	end
end
function Dock.WindowIsShow()
	if(Dock.cmds)then
		local k,v;
		for k,v in pairs(Dock.cmds) do
			local wndName = v.wndName;
			local _wnd = Dock.FindWindow(wndName);
			if(_wnd)then
				if(_wnd:IsVisible())then
					return true;
				end
			end
		end
	end
end
function Dock.FindWindow(wndName)
	if(not wndName)then return end
	local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
	if(_app and _app._app) then
		_app = _app._app;
		local _wnd = _app:FindWindow(wndName);
		return _wnd;
	end
end
function Dock.OnClose(name)
end
-- click on chat bar smiley, show the quick word selector menu
-- TODO: store the quick words in an xml document
function Dock.OnClickAction(bShow)
	if(type(bShow) == "string") then
		bShow = true;
	end
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	if(not x) then
		x, y, width, height = 0,0,0,0;
	end
	x = x+width/2-155;
	if(x<0) then
		x = 0;
	end
	y = y - 10;
	local _mainWnd = ParaUI.GetUIObject("AriesAnimationSelector");
	
	local width, height = 275, 177+43;
	if(_mainWnd:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		_mainWnd = ParaUI.CreateUIObject("container", "AriesAnimationSelector", "_fi", 0,0,0,0);
		_mainWnd.background = "";
		_mainWnd.zorder = 1;
		_mainWnd:AttachToRoot();
		
		_mainWnd.onmouseup = ";MyCompany.Aries.Desktop.Dock.OnClickAction(false);";
		
		local _content = ParaUI.CreateUIObject("container", "content", "_lt", x, y-height, width, height);
		_content.background = "";
		_mainWnd:AddChild(_content);
		
		Dock.contentPage_AnimationSelector = System.mcml.PageCtrl:new({url = "script/apps/Aries/Desktop/AnimationSelector.teen.html"});
		Dock.contentPage_AnimationSelector:Create("AnimationSelector", _content, "_fi", 0, 0, 0, 0);
	else
		-- toggle visibility if bShow is nil
		if(bShow == nil) then
			bShow = not _mainWnd.visible;
		end
		if(Dock.contentPage_AnimationSelector) then
			Dock.contentPage_AnimationSelector:Init("script/apps/Aries/Desktop/AnimationSelector.teen.html");
		end
		_mainWnd.visible = bShow;
		if(bShow) then
			_mainWnd:GetChild("content"):Reposition("_lt", x, y-height, width, height);
		end
	end
end
-- only for show/hide window during combat. 
function Dock.ShowHideQuickDockPage(bShow)
	--local _quickDockArea = ParaUI.GetUIObject("QuickDockArea");
	--if(_quickDockArea:IsValid()) then
		--if(bShow == nil) then
			--bShow = not _quickDockArea.visible;
		--end
		--_quickDockArea.visible = bShow;
	--end
	if (bShow) then
		System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Desktop/Dock/QuickDockPage.teen.html", 
		name = "Aries.quick_dock_page", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 1,
		allowDrag = true,
		isTopLevel = false,
		directPosition = true,
			align = "_ctb",
			x = 0,
			y = -80,
			width = 400,
			height = 200,
		})
	else
		local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
		if(_app and _app._app) then
			_app = _app._app;
			local _wnd = _app:FindWindow("Aries.quick_dock_page") 
			if (_wnd) then
				local _wndFrame = _wnd:GetWindowFrame();
				if (_wndFrame) then
					_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
				end
			end
		end
	end
end

--whether or not show quick dock page on desktop
function Dock.OnClickQuickDockButton()
	if(Dock.is_quick_dock_page_opened)then
		Dock.is_quick_dock_page_opened = false;
		Dock.ShowHideQuickDockPage(false);
	else
		Dock.is_quick_dock_page_opened = true;
		Dock.ShowHideQuickDockPage(true);
--		Dock.OnCreate_QuickDockPage();
	end
end
-- calling this function multiple time will cause the page to refresh. 
function Dock.OnCreate_QuickDockPage()
	if(ParaUI.GetUIObject("QuickDockArea"):IsValid()) then
		if(Dock.quick_dock_page) then
			Dock.quick_dock_page:Refresh();
		end
		return
	end
	local _parent = ParaUI.CreateUIObject("container", "QuickDockArea", "_ctb", 0, -80, 400, 200);
	_parent.background = "";
	_parent.zorder = -1;
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:GetAttributeObject():SetField("allowDrag", true);
	_parent:AttachToRoot();
	
	Dock.quick_dock_page = Dock.quick_dock_page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/Dock/QuickDockPage.teen.html",allowDrag = true, click_through = true,});
	-- one can create a UI instance like this. 
	Dock.quick_dock_page:Create("QuickDockArea", _parent, "_fi", 0, 0, 0, 0);
end
function Dock.RefreshPage()
	page:Refresh(0);
end
function Dock.IsShowExtensionBar()
	if(Dock.extends_bar_state)then
		if(Dock.extends_bar_state == "closed")then
			return false
		else
			return true;
		end
	end
	return MyCompany.Aries.Player.GetLevel()>=3;
end

function Dock.LoadExtbarCfg()
	if (Dock.ExtbarDS) then
		return
	end

	local config_file="config/Aries/Others/DockBarNpcPos.teen.xml";	
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading DockBarNpcPos config file: %s\n", config_file);
		return;
	end
		
	local xmlnode="/npc/item";
	Dock.ExtbarDS={};
	-- leveltip	
	local each_item,i = nil,1;	
	for each_item in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		Dock.ExtbarDS[i] = {};
		Dock.ExtbarDS[i].world = each_item.attr.world;
		if (each_item.attr.pos) then
			Dock.ExtbarDS[i].pos = commonlib.LoadTableFromString(each_item.attr.pos);
		else
			Dock.ExtbarDS[i].pos = nil;
		end
		if (each_item.attr.camera) then
			Dock.ExtbarDS[i].camera = commonlib.LoadTableFromString(each_item.attr.camera);
		else
			Dock.ExtbarDS[i].camera = nil;
		end
		if (each_item.attr.facing) then
			Dock.ExtbarDS[i].facing = tonumber(each_item.attr.facing);
		else
			Dock.ExtbarDS[i].facing = 0;
		end
		Dock.ExtbarDS[i].icon = each_item.attr.icon;
		Dock.ExtbarDS[i].name = each_item.attr.button;
		Dock.ExtbarDS[i].tooltip = each_item.attr.tooltip;
		Dock.ExtbarDS[i].goalpointer = each_item.attr.goalpointer;
		i=i+1;
	end
end
