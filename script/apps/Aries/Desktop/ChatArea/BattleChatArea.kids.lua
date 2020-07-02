--[[
Title: Chat area
Author(s): LiXizhi
Date: 2010/7/20
Desc: chat log and chat input
use the lib:
------------------------------------------------------------
MyCompany.Aries.Combat.UI.BattleChatArea.Show()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatWindow.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/BattleQuickWord.lua");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
local BattleChatArea = commonlib.gettable("MyCompany.Aries.Combat.UI.BattleChatArea");
local ChatWindow = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatWindow");
local ChatEdit = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatEdit");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

local DefaultPos = {
	RestoreBtn = {alignment = "_lb", left = 0, top = -223+90, width = 16, height = 17, background = "Texture/Aries/ChatSystem/kids/max_32bits.png;0 0 16 17"},
	LogWnd = {alignment = "_fi", left = 0, top = 0, width = 0, height = 25},
	EditWnd = {alignment = "_lb", left = 0, top = -27, width = 320, height = 30},
	ParentWnd = {alignment = "_lb", left = 0, top = -400+90-25, width = 320, height = 200+25+25},
	dragger_top = 49, -- margin top of dragger to the outer parent window
}

-- call this once
function BattleChatArea.DoInit()
	if(BattleChatArea.is_inited) then
		return;
	end
	BattleChatArea.is_inited = true;
	ChatWindow.DefaultPos = DefaultPos;

	-- init chat system
	ChatWindow.InitSystem();
end

-- virtual function: this function is called when UI needs to be recreated. 
function BattleChatArea.Create(bDelayCreateUI)
	-- the default show positions.
	BattleChatArea.DoInit();
	if(bDelayCreateUI) then
		return;
	end
	
	if(ParaUI.GetUIObject("BattleChatArea"):IsValid()) then
		return;
	end
	if(System.options.mc) then
		return
	end

	local self = BattleChatArea;
	local _ctBottomArea = ParaUI.CreateUIObject("container", "BattleChatArea", "_lb", 0, -142, 185, 44);
	_ctBottomArea.background = "";
	_ctBottomArea.zorder = -2
	_ctBottomArea.visible=false;
	_ctBottomArea:AttachToRoot();

	local _btnBattleChat = ParaUI.CreateUIObject("button", "BattleChatBtn", "_lt", 0, 0, 40, 44);
	_btnBattleChat.background = "Texture/Aries/Combat/CombatState/ChatBtn_32bits.png; 0 0 40 44";
	_btnBattleChat.animstyle = 23;
	_btnBattleChat.onclick = ";MyCompany.Aries.ChatSystem.BattleQuickWord.OnQuickword();";
	_btnBattleChat.tooltip = "聊天";
	_btnBattleChat.visible=true;
	_ctBottomArea:AddChild(_btnBattleChat);

	
	local _btnShop = ParaUI.CreateUIObject("button", "BattleShopBtn", "_lt", 45, 5, 40, 26);
	-- _btnShop.background = "Texture/Aries/Dock/kids/shop_btn_32bits.png;0 0 45 45";
	_btnShop.background = "Texture/Aries/Common/ThemeKid/btn_thick_s_32bits.png:7 7 7 7";
	_btnShop:SetScript("onclick", function()
		MyCompany.Aries.HaqiShop.ShowMainWnd(nil, nil, 10);
	end);
	_btnShop.text = "商城";
	_btnShop.tooltip = "自动战斗时, 可以看看商城哦!";
	_btnShop.visible=true;
	_guihelper.SetButtonFontColor(_btnShop, "#095700");
	_ctBottomArea:AddChild(_btnShop);

	local level = MyCompany.Aries.Player.GetLevel();
	if(level > 30) then
		local _btnShop = ParaUI.CreateUIObject("button", "BattleCardBtn", "_lt", 90, 5, 40, 26);
		-- _btnShop.background = "Texture/Aries/Dock/kids/shop_btn_32bits.png;0 0 45 45";
		_btnShop.background = "Texture/Aries/Common/ThemeKid/btn_thick_s_32bits.png:7 7 7 7";
		_btnShop:SetScript("onclick", function()
			MyCompany.Aries.Desktop.Dock.ShowCharPage(2, nil, 10);
		end);
		_btnShop.text = "配卡";
		_btnShop.tooltip = "战斗中配卡只能影响下场战斗!";
		_btnShop.visible=true;
		_guihelper.SetButtonFontColor(_btnShop, "#095700");
		_ctBottomArea:AddChild(_btnShop);

		--[[ can not do extended cost in game
		local _btnShop = ParaUI.CreateUIObject("button", "BattleShopBtn", "_lt", 135, 5, 40, 26);
		-- _btnShop.background = "Texture/Aries/Dock/kids/shop_btn_32bits.png;0 0 45 45";
		_btnShop.background = "Texture/Aries/Common/ThemeKid/btn_thick_s_32bits.png:7 7 7 7";
		_btnShop:SetScript("onclick", function()
			NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
			local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
			NPCShopPage.ShowPage(30429, nil, nil, 10);
		end);
		_btnShop.text = "药丸";
		_btnShop.tooltip = "战斗中使用道具只能影响下场战斗!";
		_btnShop.visible=true;
		_guihelper.SetButtonFontColor(_btnShop, "#095700");
		_ctBottomArea:AddChild(_btnShop);
		]]
	end


	
	-- show the chat window
	local is_start_minimized = false;
	if(is_start_minimized) then
		ChatWindow.OnClickWndMinimize(); 
	else
		ChatWindow.Show(true);
	end
end

-- virtual function: show/hide the battle area
function BattleChatArea.Show(bShow)
	if(bShow or bShow==nil) then
		ChatWindow.Show();
	else
		ChatWindow.HideAll();
	end
end

-- virtual funciton: Set the UI mode of the battle area, so that it has different display for different mode.
-- @param mode: "tutorial", "combat", "normal", "home"
function BattleChatArea.SetMode(mode)
	local mode_changed;
	if(BattleChatArea.mode ~= mode) then
		BattleChatArea.mode = mode;
		mode_changed = true;
	end

	if(mode == "combat") then
		if(mode_changed) then
			local _parentwnd = ChatWindow.CreateGetParentWnd();
			if(_parentwnd.x == 0) then
				local params = ChatWindow.DefaultPos.ParentWnd;
				_parentwnd:Reposition(params.alignment, params.left, params.top-60, params.width, params.height);
			end
			if(TeamClientLogics:IsInTeam()) then
				if(TeamMembersPage.IsExpanded()) then
					TeamMembersPage.ChangeShowState();
				end
			end
			ParaUI.GetUIObject("BattleChatArea").visible = true;
		end
		MsgHandler.ShowAutoAIModeBtn(true);
	else
		if(mode_changed) then
			local _parentwnd = ChatWindow.CreateGetParentWnd();
			if(_parentwnd.x == 0) then
				local params = ChatWindow.DefaultPos.ParentWnd;
				_parentwnd:Reposition(params.alignment, params.left, params.top, params.width, params.height);
			end
			if(TeamClientLogics:IsInTeam()) then
				if(not TeamMembersPage.IsExpanded()) then
					TeamMembersPage:ChangeShowState();
				end
			end
			ParaUI.GetUIObject("BattleChatArea").visible = false;
		end
		MsgHandler.ShowAutoAIModeBtn(false);
	end
end

function BattleChatArea.TryEnterChat()
	if( BattleChatArea.mytimer and BattleChatArea.mytimer.enabled and BattleChatArea.IsActive) then
		-- always set the focus to the chat window, when the enter key is presed. 
		MyCompany.Aries.ChatSystem.ChatWindow.ShowAllPage(true);
	end
end

-- use timer to check for enter key since user input is blocked during battle mode. 
function BattleChatArea.OnTimer()
	if(not BattleChatArea.IsActive) then
		ChatWindow.HideAll();
		BattleChatArea.mytimer:Change();
	end
end