--[[
Title: Desktop Dock Area for Aries App
Author(s): WangTian
Company: ParaEnging Co
Date: 2008/12/2
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
	7. middle bottom area: always on top first level function list, it further divides into:
		7.1 Chatbar, chat box for user text input and functional button for advanced chatting, such as smiley, quick words, actions
		7.2 series of icons for each first level functions
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/Dock.kids.lua");
MyCompany.Aries.Desktop.Dock.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.dealdefend.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatWnd.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSet.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatWindow.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatEdit.lua");
NPL.load("(gl)script/apps/Aries/SlashCommand/SlashCommand.lua");
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local ChatWnd = commonlib.gettable("MyCompany.Aries.ChatWnd");
local ChatEdit = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatEdit");
local ChatWindow = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatWindow");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
-- create class
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

local page;

-- virtual function: create UI
function Dock.CreateV2()
	local _parent = ParaUI.CreateUIObject("container", "Aries_Dock", "_ctb", 0, -16, 776, 111);
	_parent.background = "";
	_parent.zorder = -3;
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();

	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/Dock/Dock.kids.html",click_through = true,});

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
	-- Dock.RegistCmd();

	NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
	local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
	FamilyManager.CreateOrGetManager();


	--NPL.load("(gl)script/apps/Aries/Desktop/Dock/ManualDock.lua");
	--local ManualDock = commonlib.gettable("MyCompany.Aries.Desktop.ManualDock");
	--ManualDock.InternalOnInit();

	--NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
	--local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
	--LoopTips.DoStartDefault()

	NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
	DockTip.GetInstance();

	--NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClientLogics.lua");
	--local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");
	--GathererClientLogics.OnInit();
	--DealDefend.LoadState(function()
		--Dock.UpdateDealButtonState();
	--end)
	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	QuestHelp.AddEventListener();
end

function Dock.Create()
	local margin_left, margin_top = 32, 32;
	local _dock = ParaUI.CreateUIObject("container", "Aries_Dock", "_ctb", 36 - 40-margin_left/2, -20, 740+margin_left, 70+margin_top);
	_dock.background = "";
	_dock.zorder = -1;
	_dock:GetAttributeObject():SetField("ClickThrough", true);
	_dock:AttachToRoot();
	
	local _bg = ParaUI.CreateUIObject("container", "Dock_BG", "_lt", 0+margin_left, 0+margin_top, 740, 70);
	_bg.background = ""
	_bg.color = "255 255 255 200";
	_bg.enabled = false;
	_dock:AddChild(_bg);
	
		
		local _bg_base = ParaUI.CreateUIObject("container", "Base", "_lt", 32, 34, 715, 48);
		_bg_base.background = "Texture/Aries/Dock/Web/bg_area2_32bits.png; 0 0 64 40: 16 16 16 16";
		_bg_base:GetAttributeObject():SetField("ClickThrough", true);
		_bg:AddChild(_bg_base);
		
		local _bgbox = ParaUI.CreateUIObject("container", "bgbox", "_lt", 27, 26, 400, 64);
		_bgbox.background = "Texture/Aries/Dock/Web/bg_area1_32bits.png; 0 0 64 64: 22 51 43 14";
		_bgbox:GetAttributeObject():SetField("ClickThrough", true);
		_bg:AddChild(_bgbox);
	
	local _charBar = ParaUI.CreateUIObject("container", "CharBar", "_lt", 0+margin_left, 0+margin_top, 434, 80);
	_charBar.background = "";
	_charBar:GetAttributeObject():SetField("ClickThrough", true);
	_dock:AddChild(_charBar);
		local _chatEdit = ParaUI.CreateUIObject("container", "ChatEdit", "_lt", 74, 34, 214, 32);
		_chatEdit.background = "Texture/Aries/Dock/Web/channel_textbox_32bits.png:15 15 16 16";
		_chatEdit:GetAttributeObject():SetField("ClickThrough", true);
		_charBar:AddChild(_chatEdit);
		local _edit = ParaUI.CreateUIObject("imeeditbox", "AriesBBSChatEdit", "_lt", 85, 38, 174, 25);
		_edit.background = "";
		_edit.onkeyup = ";MyCompany.Aries.Desktop.Dock.OnInputKeyUp();";
		_charBar:AddChild(_edit);
		local _say = ParaUI.CreateUIObject("button", "Say", "_lt", 257, 35, 32, 32);
		_say.background = "Texture/Aries/Dock/Web/channel_say_32bits.png; 0 0 32 32";
		_say.onclick = ";MyCompany.Aries.Desktop.Dock.SendInputText();";
		_charBar:AddChild(_say);
		local _smiley = ParaUI.CreateUIObject("button", "Aries_Dock_Smiley", "_rt", -141, 33, 32, 32);
		_smiley.background = "Texture/Aries/Dock/Web/Smiley_32bits.png; 0 0 32 32";
		_smiley.onclick = ";MyCompany.Aries.Desktop.Dock.OnClickSmiley();";
		_smiley.tooltip = "表情";
		_charBar:AddChild(_smiley); 
		local _quickword = ParaUI.CreateUIObject("button", "Aries_Dock_Quickword", "_rt", -103, 33, 32, 32);
		_quickword.background = "Texture/Aries/Dock/Web/Quickword_32bits.png; 0 0 32 32";
		_quickword.onclick = ";MyCompany.Aries.Desktop.Dock.OnClickQuickword();";
		_quickword.tooltip = "快捷语言";
		_charBar:AddChild(_quickword);
		local _action = ParaUI.CreateUIObject("button", "Aries_Dock_Action", "_rt", -67, 33, 32, 32);
		_action.background = "Texture/Aries/Dock/Web/Action_32bits.png; 0 0 32 32";
		_action.onclick = ";MyCompany.Aries.Desktop.Dock.OnClickAction();";
		_action.tooltip = "动作";
		_charBar:AddChild(_action);
	
	local _dragon = ParaUI.CreateUIObject("button", "Aries_Dock_DragonIcon", "_lt", 0+margin_left, 0+margin_top, 72, 72);
	_dragon.background = "Texture/Aries/Dock/Web/DragonIconTemp_32bits.png; 0 0 72 72";
	_dragon.tooltip = "人物";
	_dragon.onclick = ";MyCompany.Aries.Desktop.CombatCharacterFrame.ShowMainWnd();";
	_dock:AddChild(_dragon);
	
	_guihelper.SetVistaStyleButton3(_dragon, 
		"Texture/Aries/Dock/Web/dragon_bg_blue_32bits.png; 0 0 72 72", 
		"Texture/Aries/Dock/Web/dragon_bg_blue_light_32bits.png; 0 0 72 72", 
		"Texture/Aries/Dock/Web/dragon_bg_blue_disabled_32bits.png; 0 0 72 72", 
		"Texture/Aries/Dock/Web/dragon_bg_blue_dark_32bits.png; 0 0 72 72");
	

	local _toggle = ParaUI.CreateUIObject("button", "Toggle", "_lt", 146+margin_left, 14+margin_top, 64, 23);
	_toggle.background = "Texture/Aries/Dock/Web/channel_arrow_up_32bits.png;0 0 64 23";
	_toggle.onclick = ";MyCompany.Aries.Desktop.Dock.ToggleChatWindow();";
	_toggle.zorder=10;
	_dock:AddChild(_toggle);
	
	local _functions = ParaUI.CreateUIObject("container", "Functions", "_lt", 413+margin_left, -3+margin_top, 560, 80);
	_functions.background = "";
	_functions:GetAttributeObject():SetField("ClickThrough", true);
	_dock:AddChild(_functions);
	
		local _HL = ParaUI.CreateUIObject("button", "_hl", "_lt", 5 - 4, 27 - 4, 52, 52);
		_HL.background = "Texture/Aries/Dock/button_highlight.png";
		_functions:AddChild(_HL);
		_HL:GetAttributeObject():SetField("AlwaysMouseOver", true);
		_guihelper.SetVistaStyleButton3(_HL, 
			"", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png");
		local _throwable = ParaUI.CreateUIObject("button", "Aries_Dock_Throwable", "_lt", 5, 27, 44, 44);
		_throwable.background = "Texture/Aries/Dock/Web/Throwable_32bits.png; 0 0 44 44";
		_throwable.onclick = ";System.App.Commands.Call(\"Profile.Aries.ThrowableWnd\");";
		_throwable.tooltip = "投掷道具";
		_functions:AddChild(_throwable);
		
		local _HL = ParaUI.CreateUIObject("button", "_hl", "_lt", 5 + 52 - 4, 27 - 4, 52, 52);
		_HL.background = "Texture/Aries/Dock/button_highlight.png";
		_functions:AddChild(_HL);
		_HL:GetAttributeObject():SetField("AlwaysMouseOver", true);
		_guihelper.SetVistaStyleButton3(_HL, 
			"", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png");
		local _bag = ParaUI.CreateUIObject("button", "Aries_Dock_Bag", "_lt", 5 + 52, 27, 44, 44);
		_bag.background = "Texture/Aries/Dock/Web/Dragon_32bits.png; 0 0 46 46";
		_bag.onclick = ";MyCompany.Aries.Desktop.Dock.OnClickDragon_Menu();";
		_bag.tooltip = "抱抱龙";
		_functions:AddChild(_bag);
		
		local _HL = ParaUI.CreateUIObject("button", "_hl", "_lt", 5 + 52*2 - 4, 27 - 4, 52, 52);
		_HL.background = "Texture/Aries/Dock/button_highlight.png";
		_functions:AddChild(_HL);
		_HL:GetAttributeObject():SetField("AlwaysMouseOver", true);
		_guihelper.SetVistaStyleButton3(_HL, 
			"", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png");
		local _friends = ParaUI.CreateUIObject("button", "Aries_Dock_Friends", "_lt", 5 + 52*2, 27, 44, 44);
		_friends.background = "Texture/Aries/Dock/Web/Friends_32bits.png; 0 0 44 44";
		_friends.onclick = ";System.App.Commands.Call(\"Profile.Aries.FriendsWnd\");";
		_friends.tooltip = "好友";
		_functions:AddChild(_friends);
		
		local _HL = ParaUI.CreateUIObject("button", "_hl", "_lt", 5 + 52*3 - 4, 27 - 4, 52, 52);
		_HL.background = "Texture/Aries/Dock/button_highlight.png";
		_functions:AddChild(_HL);
		_HL:GetAttributeObject():SetField("AlwaysMouseOver", true);
		_guihelper.SetVistaStyleButton3(_HL, 
			"", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png");
		local _friends = ParaUI.CreateUIObject("button", "Aries_Dock_Family", "_lt", 5 + 52*3, 27, 44, 44);
		_friends.background = "Texture/Aries/Dock/Web/Family_32bits.png; 0 0 44 44";
		_friends.onclick = ";System.App.Commands.Call(\"Profile.Aries.MyFamilyWnd\");";
		_friends.tooltip = "家族";
		_functions:AddChild(_friends);
		
		local _HL = ParaUI.CreateUIObject("button", "_hl", "_lt", 5 + 52*4 - 4, 27 - 4, 52, 52);
		_HL.background = "Texture/Aries/Dock/button_highlight.png";
		_functions:AddChild(_HL);
		_HL:GetAttributeObject():SetField("AlwaysMouseOver", true);
		_guihelper.SetVistaStyleButton3(_HL, 
			"", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png");
		local _home = ParaUI.CreateUIObject("button", "Aries_Dock_MyHome", "_lt", 5 + 52*4, 27, 44, 44);
		_home.background = "Texture/Aries/Dock/Web/Home_32bits.png; 0 0 44 44";
		_home.onclick = ";MyCompany.Aries.Desktop.Dock.OnClickHomeland();";
		_home.tooltip = "家园";
		_functions:AddChild(_home);
		
		local _HL = ParaUI.CreateUIObject("button", "_hl", "_lt", 5 + 52*5 - 4, 27 - 4, 52, 52);
		_HL.background = "Texture/Aries/Dock/button_highlight.png";
		_functions:AddChild(_HL);
		_HL:GetAttributeObject():SetField("AlwaysMouseOver", true);
		_guihelper.SetVistaStyleButton3(_HL, 
			"", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png", 
			"Texture/Aries/Dock/Web/button_highlight.png");
		local _help = ParaUI.CreateUIObject("button", "btnAriesHelp", "_lt", 5 + 52*5, 27, 44, 44);
		_help.background = "Texture/Aries/Dock/Web/Help_32bits.png; 0 0 44 44";
		_help.onclick = ";MyCompany.Aries.Desktop.Dock.OnClickSettings();";
		_help.tooltip = "帮助/设置";
		_functions:AddChild(_help);
	
	----------------------------------
	-- 5 buttons around the char image
	----------------------------------
	local CharAreaButtons = {};
	CharAreaButtons.name = "CharAreaButtons";
	local left, top = 390, 87;
	CharAreaButtons.all_pos = {
		["btn1"] = {
			x = -390+left,
			y = -21+top,
			width = 37,
			height = 37,
			zorder = 1,
			background = "Texture/Aries/Dock/Web/user_cards_bg_32bits.png; 0 0 37 37",
			tooltip = "卡片 (C)",
			onclick = ";MyCompany.Aries.Desktop.Dock.ShowCharPage(2);",
		},
		["btn2"] = {
			x = -386+left,
			y = -58+top,
			width = 37,
			height = 37,
			zorder = 1,
			background = "Texture/Aries/Dock/Web/user_equipment_bg_32bits.png; 0 0 37 37",
			tooltip = "装备 (B)",
			onclick = ";MyCompany.Aries.Desktop.Dock.ShowCharPage(3);",
		},
		["btn3"] = {
			x = -360+left,
			y = -85+top,
			width = 37,
			height = 37,
			zorder = 1,
			background = "Texture/Aries/Dock/Web/user_magicstar_bg_32bits.png; 0 0 37 37",
			tooltip = "魔法星",
			onclick = ";MyCompany.Aries.Desktop.Dock.ShowCharPage(5);",
		},
		["btn4"] = {
			x = -323+left,
			y = -87+top,
			width = 37,
			height = 37,
			zorder = 1,
			background = "Texture/Aries/Dock/Web/user_combat_pet_32bits.png; 0 0 37 37",
			tooltip = "宠物",
			onclick = ";MyCompany.Aries.Desktop.Dock.DoShowPetManager();",
		},
		["btn5"] = {
			x = -293+left,
			y = -66+top,
			width = 37,
			height = 37,
			zorder = 1,
			background = "Texture/Aries/Dock/Web/quick_dock_32bits.png; 0 0 37 37",
			tooltip = "药丸快捷栏",
			onclick = ";MyCompany.Aries.Desktop.Dock.OnClickQuickDockButton();",
		},
		["btn_deal"] = {
			x = -300+left,
			y = -10+top,
			width = 16,
			height = 19,
			zorder = 1,
			background = "Texture/Aries/Common/lock_32bits.png; 0 0 16 19",
			tooltip = "交易锁定",
			onclick = ";MyCompany.Aries.Desktop.Dock.OnClickDealPage();",
		},
	}
	local name,node;
	for name,node in pairs(CharAreaButtons.all_pos) do
		local btn = ParaUI.GetUIObject(CharAreaButtons.name..name);
		if(not btn or not btn:IsValid())then
			btn = ParaUI.CreateUIObject("button", CharAreaButtons.name..name, "_lt", node.x, node.y, node.width, node.height);
			btn.background = node.background;
			btn.tooltip = node.tooltip;
			btn.zorder = node.zorder;
			btn.onclick = node.onclick;
			_dock:AddChild(btn);
		elseif(btn and btn:IsValid())then
			local x = node.x;
			if(x)then
				btn.x = x;
			end
			local y = node.y;
			if(y)then
				btn.y = y;
			end
			local zorder = node.zorder;
			if(zorder)then
				btn.zorder = zorder;
			end
		end	
	end

	-- this is tricky to keep the friend list alive
	NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
	-- tricky: inform that UI is available, any offline messages can now be pushed to ui. 
	MyCompany.Aries.Friends.SetUIAvailable(true);
	-- tricky: update subscriptions. so that the presence are sent and received. 
	MyCompany.Aries.Friends.UpdateJabberSubscription();

	Dock.Show(true);
	
	if(System.options.theme ~= "v2") then
		ChatEdit.RedirectUITarget("AriesBBSChatEdit");
	end
end

local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");

local function_available_map = 
{
	["mountpet"] = true, -- enable this in case some 0 level user accidentally disabled pet. 
	["family"] = true,
	["myhome"] = true,
}

-- virtual function: Desktop window handler
function Dock.MSGProc(msg)
	if(msg.type == MSGTYPE.ON_LEVELUP or msg.type == MSGTYPE.ON_ACTIVATE_DESKTOP) then
		local level = msg.level;
		local bNeedRefresh;
		if(level>6) then
			if(level>=15) then
				if(page) then
					page:Refresh();
				end
			end
			-- do nothing
			local name, bAvailable
			for name, bAvailable in pairs(function_available_map) do
				if(not bAvailable) then
					function_available_map[name] = true;
					bNeedRefresh = true;
				end
			end
		else
			function_available_map["myhome"] = (level>=5);
			function_available_map["family"] = (level>=4);

			function_available_map["mountpet"] = (level>=2);
			if(level<=2) then
				-- tricky: this ensures some 0 level user accidentally disabled pet. 
				MyCompany.Aries.Pet.ForceCombatStatus();
			end

			bNeedRefresh = true;
		end
		if(bNeedRefresh) then
			Dock.RefreshAvailableFunctions();
		end
		if(msg.type == MSGTYPE.ON_LEVELUP)then
			NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
			local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
			local provider = QuestClientLogics.provider;
			if(provider)then
				provider:NotifyChanged();
			end
			QuestTrackerPane.NeedReload();
			QuestClientLogics.UpdateUI(true)

			NPL.load("(gl)script/apps/Aries/Login/WorldAssetPreloader.lua");
			local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")
			WorldAssetPreloader.OnPlayerReachedLevel(level);
		end
	end
end

Dock.FireCmd = Dock.FireCmd or function()
	-- placeholder
	return false;
end


function Dock.RefreshAvailableFunctions()
	local name, bAvailable
	for name, bAvailable in pairs(function_available_map) do
		Dock.SetButtonEnabled(name, bAvailable);
	end
end

function Dock.SetButtonEnabled(name, bEnable)
	local uiobj_name;
	if(name == "dragonicon") then
		uiobj_name = "Aries_Dock_DragonIcon";
	elseif(name == "smiley") then
		uiobj_name = "Aries_Dock_Smiley";
	elseif(name == "quickword") then
		uiobj_name = "Aries_Dock_Quickword";
	elseif(name == "action") then
		uiobj_name = "Aries_Dock_Action";
	elseif(name == "throwable") then
		uiobj_name = "Aries_Dock_Throwable";
	elseif(name == "bag" or name == "mountpet") then
		uiobj_name = "Aries_Dock_Bag";
	elseif(name == "friends") then
		uiobj_name = "Aries_Dock_Friends";
	elseif(name == "family") then
		uiobj_name = "Aries_Dock_Family";
	elseif(name == "myhome") then
		uiobj_name = "Aries_Dock_MyHome";
	elseif(name == "help") then
		uiobj_name = "btnAriesHelp";
	end
	if(uiobj_name) then
		local _btn = ParaUI.GetUIObject(uiobj_name);
		if(_btn:IsValid() == true) then
			_btn.enabled = bEnable;
		end
	end
end

NPL.load("(gl)script/apps/Aries/BBSChat/SentenceHistory.lua");
local sentence_history = commonlib.gettable("MyCompany.Aries.BBSChat.sentence_history");

-- input key up
function Dock.OnInputKeyUp()
	ChatEdit.OnKeyUp();
end

-- we will keep a text history using sentence_history class, so that the user can toggle to previous text easily.  
function Dock.SendInputText()
	ChatEdit.OnClickSend();
end


function Dock.ShowBBSChatWnd()
end

function Dock.HideBBSChatWnd()
end

-- click on chat bar smiley, show the smiley selector menu
-- TODO: store the smileys in an xml document
function Dock.OnClickSmiley(bShow)
	NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/SmileyPage.lua");
	local SmileyPage = commonlib.gettable("MyCompany.Aries.ChatSystem.SmileyPage");
	SmileyPage.ShowPage_Kids(bShow);
end

-- show the smiley
function Dock.DoSmiley(node)
	
end

-- click on chat bar quickword, show the quick word selector menu
-- TODO: store the quick words in an xml document
function Dock.OnClickQuickword()
	--NPL.load("(gl)script/ide/ContextMenu2.lua");
	local ctl = CommonCtrl.GetControl("Aries_Quickword");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_Quickword",
			width = 170,
			subMenuWidth = 300,
			height = 285, -- add 30(menuitemHeight) for each new line. 
			style = CommonCtrl.ContextMenu.DefaultStyleThick,
		};
		Dock.RefreshQuickword();
	end
	
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	-- Note: 2009.9.29. Xizhi: if u ever added new menu items, please modify the height of the menu item, because animation only support "_lt" alignment. 
	ctl:Show(x-15, y-ctl.height+20);
end

-- say the quickword
function Dock.DoQuickword(node)
	ChatEdit.SendTextSilent(node.Text)
end

function Dock.ToggleChatWindow()
	if(ChatWindow.ToggleShow()) then
		local _dock = ParaUI.GetUIObject("Aries_Dock");
		if(_dock:IsValid() == true) then
			local _toggle = _dock:GetChild("Toggle");
			_toggle.background = "Texture/Aries/Dock/channel_arrow_down_32bits.png;0 0 82 31";
		end
	else
		local _dock = ParaUI.GetUIObject("Aries_Dock");
		if(_dock:IsValid() == true) then
			local _toggle = _dock:GetChild("Toggle");
			_toggle.background = "Texture/Aries/Dock/Web/channel_arrow_up_32bits.png;0 0 64 23";
		end
	end
	--[[
	if(ChatWnd.IsShow()) then
		local _dock = ParaUI.GetUIObject("Aries_Dock");
		if(_dock:IsValid() == true) then
			local _toggle = _dock:GetChild("Toggle");
			_toggle.background = "Texture/Aries/Dock/Web/channel_arrow_up_32bits.png;0 0 64 23";
		end
		ChatWnd.HidePage();
	else
		local _dock = ParaUI.GetUIObject("Aries_Dock");
		if(_dock:IsValid() == true) then
			local _toggle = _dock:GetChild("Toggle");
			_toggle.background = "Texture/Aries/Dock/channel_arrow_down_32bits.png;0 0 82 31";
		end
		ChatWnd.ShowPage();
	end]]
end

-- refresh quickword
-- call this function whenever their is any quickword update:
-- MyCompany.Aries.Desktop.Dock.RefreshQuickword()
function Dock.RefreshQuickword()
	local filename = "config/Aries/Desktop.Dock.Quickword.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("error: failed loading quickword config file %s, using default\n", filename);
		-- use default config file xml root
		xmlRoot = 
		{
		  {
			{
			  { attr={ sentence="我的西瓜仔给我找到了新种子。" }, name="node" },
			  attr={ name="问好" },
			  n=1,
			  name="category" 
			},
			n=1,
			name="quickwords" 
		  },
		  n=1 
		};
	end	
	
	local ctl = CommonCtrl.GetControl("Aries_Quickword");
	if(ctl) then
		local node = ctl.RootNode;
		-- clear all children first
		node:ClearAllChildren();
		
		local subNode;
		-- name node: for displaying name of the selected object. Click to display property
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "快捷语言", Name = "name", Type="Title", NodeHeight = 26 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "----------------------", Name = "titleseparator", Type="separator", NodeHeight = 4 });
		-- by categories
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Quickwords", Name = "actions", Type = "Group", NodeHeight = 0 });
		
		-- read attributes of npl worker states
		local node_category;
		for node_category in commonlib.XPath.eachNode(xmlRoot, "/quickwords/category") do
			if(node_category.attr and node_category.attr.name) then
				subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = node_category.attr.name, Name = "looped", Type = "Menuitem"});
				local node_sentence;
				for node_sentence in commonlib.XPath.eachNode(node_category, "/node") do
					subNode:AddChild(CommonCtrl.TreeNode:new({Text = node_sentence.attr.sentence, Name = "xx", Type = "Menuitem", onclick = Dock.DoQuickword, }));
				end
			end	
		end
		local node_sentence;
		for node_sentence in commonlib.XPath.eachNode(xmlRoot, "/quickwords/node") do
			node:AddChild(CommonCtrl.TreeNode:new({Text = node_sentence.attr.sentence, Name = "xx", Type = "Menuitem", onclick = Dock.DoQuickword, }));
		end
	end
end

-- click on chat bar smiley, show the quick word selector menu
-- TODO: store the quick words in an xml document
function Dock.OnClickAction(bShow)
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	if(not x) then
		x, y, width, height = 0,0,0,0;
	end
	x = x+width/2-55;
	if(x<0) then
		x = 0;
	end
	local _mainWnd = ParaUI.GetUIObject("AriesAnimationSelector");
	
	local width, height = 275, 177+43*2;
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
		
		Dock.contentPage_AnimationSelector = System.mcml.PageCtrl:new({url = "script/apps/Aries/Desktop/AnimationSelector.html"});
		Dock.contentPage_AnimationSelector:Create("AnimationSelector", _content, "_fi", 0, 0, 0, 0);
	else
		-- toggle visibility if bShow is nil
		if(bShow == nil) then
			bShow = not _mainWnd.visible;
		end
		if(Dock.contentPage_AnimationSelector) then
			Dock.contentPage_AnimationSelector:Init("script/apps/Aries/Desktop/AnimationSelector.html");
		end
		_mainWnd.visible = bShow;
		if(bShow) then
			_mainWnd:GetChild("content"):Reposition("_lt", x, y-height, width, height);
		end
	end
end

function Dock.OnClickDragon_Menu()
	local ctl = CommonCtrl.GetControl("Aries_OnClickDragon");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_OnClickDragon",
			width = 160,
			height = 160, -- add menuitemHeight(30) with each new item
			style = {
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 18,
				borderRight = 22,
				
				fillLeft = 0,
				fillTop = -15,
				fillWidth = 0,
				fillHeight = -24,
				
				titlecolor = "#283546",
				level1itemcolor = "#283546",
				level2itemcolor = "#3e7320",
				
				iconsize_x = 18,
				iconsize_y = 18,
				
				menu_bg = "Texture/Aries/Dock/menu_bg_32bits.png:24 30 39 30",
				menu_lvl2_bg = "Texture/Aries/Dock/menu_lvl2_bg_32bits.png:39 30 24 30",
				shadow_bg = nil,
				separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
				item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
				expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
				expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
				menuitemHeight = 30,
				separatorHeight = 2,
				titleHeight = 26,
				
				titleFont = "System;14;bold";
			},
		};
		local node = ctl.RootNode;
		local subNode;
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "name", Type="Title", NodeHeight = 0 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "titleseparator", Type="separator", NodeHeight = 0 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Quickwords", Name = "actions", Type = "Group", NodeHeight = 0 });
			-- node:AddChild(CommonCtrl.TreeNode:new({Text = "   抱抱龙资料", Name = "SystemSettings", Type = "Menuitem", onclick = Dock.OnClickDragon, Icon = "Texture/Aries/Dock/dragon_info_icon_32bits.png;0 0 18 18"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "   抱抱龙资料", Name = "ExitGame", Type = "Menuitem", onclick = Dock.DoChangeBody, Icon = "Texture/Aries/Dock/changebody_icon_32bits.png;0 0 19 20"}));
			if(System.options.theme == "v2") then
				node:AddChild(CommonCtrl.TreeNode:new({Text = "   抱抱龙心愿", Name = "SystemSettings", Type = "Menuitem", onclick = function() 
					MyCompany.Aries.Desktop.QuestArea.OnClickQuestDragonStatus();
				end, Icon = "Texture/Aries/Dock/dragon_info_icon_32bits.png;0 0 18 18"}));
				ctl.height = ctl.height + 30;
			end
			node:AddChild(CommonCtrl.TreeNode:new({Text = "   驾驭", Name = "ExitGame", Type = "Menuitem", onclick = Dock.DoRid, Icon = "Texture/Aries/Dock/ride_icon_32bits.png;0 0 18 18"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "   跟随", Name = "ExitGame", Type = "Menuitem", onclick = Dock.DoFollow, Icon = "Texture/Aries/Dock/follow_icon_32bits.png;0 0 18 18"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "   回家", Name = "ExitGame", Type = "Menuitem", onclick = Dock.DoHome, Icon = "Texture/Aries/Dock/gohome_icon_32bits.png;0 0 18 18"}));
	end
	
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	ctl:Show(x-105, y-ctl.height);
end

function Dock.OnClickHomeland()
	local ctl = CommonCtrl.GetControl("Aries_Homeland");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_Homeland",
			width = 175,
			height = 100, -- add menuitemHeight(30) with each new item
			style = {
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 18,
				borderRight = 22,
				
				fillLeft = 0,
				fillTop = -15,
				fillWidth = 0,
				fillHeight = -24,
				
				titlecolor = "#283546",
				level1itemcolor = "#283546",
				level2itemcolor = "#3e7320",
				
				iconsize_x = 24,
				iconsize_y = 21,
				
				menu_bg = "Texture/Aries/Dock/menu_bg_32bits.png:24 30 39 30",
				menu_lvl2_bg = "Texture/Aries/Dock/menu_lvl2_bg_32bits.png:39 30 24 30",
				shadow_bg = nil,
				separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
				item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
				expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
				expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
				menuitemHeight = 30,
				separatorHeight = 2,
				titleHeight = 26,
				
				titleFont = "System;14;bold";
			},
		};
		local node = ctl.RootNode;
		local subNode;
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "name", Type="Title", NodeHeight = 0 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "titleseparator", Type="separator", NodeHeight = 0 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Quickwords", Name = "actions", Type = "Group", NodeHeight = 0 });
			node:AddChild(CommonCtrl.TreeNode:new({Text = "   我的家园", Name = "SystemSettings", Type = "Menuitem", onclick = Dock.OnGotoHomeLand, Icon = "Texture/Aries/Dock/Web/homeland_icon_32bits.png;"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "   创意空间", Name = "CreatorGame", Type = "Menuitem", onclick = Dock.OnGotoCreatorWorld, Icon = "Texture/Aries/Dock/Web/creator_icon_32bits.png;"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "   创意空间", Name = "CreatorGameNew", Type = "Menuitem", onclick = Dock.OnGotoCreatorWorldNew, Icon = "Texture/Aries/Dock/Web/creator_icon_32bits.png;"}));
	end
	
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	ctl:Show(x-105, y-ctl.height);
end

function Dock.OnClickSettings()
	local ctl = CommonCtrl.GetControl("Aries_Setings");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_Setings",
			width = 175,
			height = 220, -- add menuitemHeight(30) with each new item
			style = {
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 18,
				borderRight = 22,
				
				fillLeft = 0,
				fillTop = -15,
				fillWidth = 0,
				fillHeight = -24,
				
				titlecolor = "#283546",
				level1itemcolor = "#283546",
				level2itemcolor = "#3e7320",
				
				iconsize_x = 24,
				iconsize_y = 21,
				
				menu_bg = "Texture/Aries/Dock/menu_bg_32bits.png:24 30 39 30",
				menu_lvl2_bg = "Texture/Aries/Dock/menu_lvl2_bg_32bits.png:39 30 24 30",
				shadow_bg = nil,
				separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
				item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
				expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
				expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
				menuitemHeight = 30,
				separatorHeight = 2,
				titleHeight = 26,
				
				titleFont = "System;14;bold";
			},
		};
		local node = ctl.RootNode;
		local subNode;
		
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "name", Type="Title", NodeHeight = 0 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "titleseparator", Type="separator", NodeHeight = 0 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Quickwords", Name = "actions", Type = "Group", NodeHeight = 0 });
		
		subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "   疑难解答", Name = "looped", Type = "Menuitem", Icon = "Texture/Aries/Inventory/SmallHelp_32bits.png"});	
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "战斗帮助", Name = "cards", Type = "Menuitem", onclick = Dock.DoFAQ, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "抱抱龙帮助", Name = "dragon", Type = "Menuitem", onclick = Dock.DoFAQ, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "角色帮助", Name = "character", Type = "Menuitem", onclick = Dock.DoFAQ, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "家族帮助", Name = "family", Type = "Menuitem", onclick = Dock.DoFAQ, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "魔法星帮助", Name = "magicstar", Type = "Menuitem", onclick = Dock.DoFAQ, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "卡牌百科", Name = "cardwiki", Type = "Menuitem", onclick = Dock.DoFAQ}));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "向导精灵", Name = "GuideElf", Type = "Menuitem", onclick = Dock.DoAutoTips,}));	
		subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "   装备强化", Name = "UpgradeItems", Type = "Menuitem", Icon = "Texture/Aries/Common/ThemeKid/magic_star/attribs_32bits.png;0 0 25 24"});	
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "达尔默德(宝石镶嵌)", Name = "merge_gem", Type = "Menuitem", onclick = Dock.DoEquipUpgrade, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "小胖(装备强化)", Name = "item_addon", Type = "Menuitem", onclick = Dock.DoEquipUpgrade, }));
			subNode:AddChild(CommonCtrl.TreeNode:new({Text = "苏苏(宝石平移)", Name = "translate_gem", Type = "Menuitem", onclick = Dock.DoEquipUpgrade, }));

		--node:AddChild(CommonCtrl.TreeNode:new({Text = "   拍照", Name = "SharePhotosPage", Type = "Menuitem", onclick = Dock.DoSharePhotos, Icon = "Texture/Aries/Dock/Web/camera_32bits.png; 0 0 24 21"}));	
		node:AddChild(CommonCtrl.TreeNode:new({Text = "   系统设置", Name = "SystemSettings", Type = "Menuitem", onclick = Dock.OnSystemSetting, Icon = "Texture/Aries/Dock/SystemSettings_32bits.png;0 0 24 21"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "   切换服务器", Name = "SwitchServer", Type = "Menuitem", onclick = Dock.OnSwitchServer, Icon = "Texture/Aries/Dock/SwitchingServers_32bits.png;0 0 24 21"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "   切换用户", Name = "SwitchUser", Type = "Menuitem", onclick = Dock.OnSwitchUser, Icon = "Texture/Aries/Dock/SwitchUser_32bits.png;0 0 24 21"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "   离开小镇", Name = "ExitGame", Type = "Menuitem", onclick = Dock.OnExit, Icon = "Texture/Aries/Dock/Quit_32bits.png;0 0 24 21"}));
	end
	
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	ctl:Show(x-105, y-ctl.height);

end

function Dock.DoEquipUpgrade(node)
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
    local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

	local name = node.Name;
	if(name == "merge_gem") then
		WorldManager:GotoNPC(30414);
	elseif(name == "item_addon") then
		WorldManager:GotoNPC(30422);
	elseif(name == "translate_gem") then
		WorldManager:GotoNPC(30042);
	end
end

function Dock.DoFAQ(node)
	if(node.Name == "cards") then
		NPL.load("(gl)script/apps/Aries/Help/CombatHelp/CombatHelpPage.lua");
		MyCompany.Aries.Help.CombatHelpPage.ShowPage();
	elseif(node.Name == "dragon") then
		NPL.load("(gl)script/apps/Aries/Help/PetHelp/PetHelpPage.lua");
		MyCompany.Aries.Help.PetHelpPage.ShowPage();
	elseif(node.Name == "character") then
		NPL.load("(gl)script/apps/Aries/Help/RoleHelp/RoleHelpPage.lua");
		MyCompany.Aries.Help.RoleHelpPage.ShowPage();
	elseif(node.Name == "family") then
		NPL.load("(gl)script/apps/Aries/Help/FamilyHelp/FamilyHelpPage.lua");
		MyCompany.Aries.Help.FamilyHelpPage.ShowPage();
	elseif(node.Name == "magicstar") then
		NPL.load("(gl)script/apps/Aries/Help/MagicStarHelp2/MagicStarHelp2.lua");
		MyCompany.Aries.Help.MagicStarHelp2.ShowPage();
	elseif(node.Name == "cardwiki") then
		NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
		MyCompany.Aries.Quest.NPCs.CombatSkillLearn.ShowSkillEncyclopedia_kids(2);
	end
end

-- public: this function is called. whenever the user pressed the enter key and wants to enter some chat message. 
function Dock.OnEnterChat()
	if(System.options.theme == "v2") then
		MyCompany.Aries.ChatSystem.ChatWindow.ShowAllPage(true);
	else
		if(Player.IsInCombat) then
			if(Player.IsInCombat()) then
				MyCompany.Aries.ChatSystem.ChatWindow.ShowAllPage(true);
			else
				ChatEdit.ShowPage();
				ChatEdit.SetFocus();
			end
		end
	end
end

-- virtual: show or hide all windows related to the dock. such as the character, map, pet, etc. 
function Dock.ShowHideAllWindow(bShow)
	if(Dock.is_quick_dock_page_opened and not bShow) then
		Dock.ShowHideQuickDockPage(false);
	elseif(Dock.is_quick_dock_page_opened and bShow) then
		Dock.ShowHideQuickDockPage(true);
	end
end

-- only for show/hide window during combat. 
function Dock.ShowHideQuickDockPage(bShow)
	local _quickDockArea = ParaUI.GetUIObject("QuickDockArea");
	if(_quickDockArea:IsValid()) then
		if(bShow == nil) then
			bShow = not _quickDockArea.visible;
		end
		_quickDockArea.visible = bShow;
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
		Dock.OnCreate_QuickDockPage();
	end
end
function Dock.UpdateDealButtonState()
	if(page) then
		local btn = page:FindControl("DealButton");
		if(btn) then
			if(not DealDefend.HasLockPassword())then
				btn.tooltip ="设置交易密码";
				btn.background = "Texture/Aries/Common/unlock_32bits.png; 0 0 16 19";
				return
			end

			local is_locked = DealDefend.IsLocked()
			page:SetValue("DealButton", is_locked);

			if(is_locked)then
				btn.tooltip ="你的物品正受到交易密码的保护。可点击解锁";
				btn.background = "Texture/Aries/Common/lock_32bits.png; 0 0 16 19";
			else
				btn.tooltip ="交易密码管理";
				btn.background = "Texture/Aries/Common/unlock_32bits.png; 0 0 16 19";
			end
		end
	else
		local btn = ParaUI.GetUIObject("CharAreaButtons".."btn_deal");
		if(btn and btn:IsValid())then
			if(not DealDefend.HasLockPassword())then
				btn.tooltip ="设置交易密码";
				btn.background = "Texture/Aries/Common/unlock_32bits.png; 0 0 16 19";
				return
			end
			--解锁
			if(DealDefend.IsLocked())then
				btn.tooltip ="你的物品正受到交易密码的保护。可点击解锁";
				btn.background = "Texture/Aries/Common/lock_32bits.png; 0 0 16 19";
			else
				btn.tooltip ="交易密码管理";
				btn.background = "Texture/Aries/Common/unlock_32bits.png; 0 0 16 19";
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
-- calling this function multiple time will cause the page to refresh. 
function Dock.OnCreate_QuickDockPage()
	if(ParaUI.GetUIObject("QuickDockArea"):IsValid()) then
		if(Dock.quick_dock_page) then
			Dock.quick_dock_page:Refresh();
		end
		return
	end
	local _parent = ParaUI.CreateUIObject("container", "QuickDockArea", "_ctb", -60, -110, 400, 100);
	_parent.background = "";
	_parent.zorder = -1;
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();
	
	Dock.quick_dock_page = Dock.quick_dock_page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/Dock/QuickDockPage.html",click_through = true,});
	-- one can create a UI instance like this. 
	Dock.quick_dock_page:Create("QuickDockArea", _parent, "_fi", 0, 0, 0, 0);
end

function Dock.OnClickSkill()
	NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.lua");
	MyCompany.Aries.Desktop.MinorSkillPage.ShowPage();
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