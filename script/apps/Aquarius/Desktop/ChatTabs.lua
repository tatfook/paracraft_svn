--[[
Title: Desktop ChatTabs Area for Aquarius App
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Aquarius/Desktop/AquariusDesktop.lua
Area: 
	---------------------------------------------------------
	| Profile										Mini Map|
	|														|
	| 													 C	|
	| 													 h	|
	| 													 a	|
	| 													 t	|
	| 													 T	|
	| 													 a	|
	| 													 b	|
	|													 s	|
	|														|
	|														|
	|														|
	|														|
	| Menu | QuickLaunch | CurrentApp | UtilBar1 | UtilBar2	|
	|┗━━━━━━━━━━━━━Dock━━━━━━━━━━━━━┛ |
	---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/ChatTabs.lua");
MyCompany.Aquarius.Desktop.ChatTabs.InitChatTabs();
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktopChatTabs";
local ChatTabs = {};
commonlib.setfield("MyCompany.Aquarius.Desktop.ChatTabs", ChatTabs);

-- data keeping
-- current tabs of chat window
ChatTabs.RootNode = CommonCtrl.TreeNode:new({Name = "ChatTabsRoot",});

-- invoked at Desktop.InitDesktop()
function ChatTabs.InitChatTabs()

	-- ChatTabs area
	local _chatTabsArea = ParaUI.CreateUIObject("container", "ChatTabsArea", "_rt", -48, 24+2 + 128+6 + 24+2 + 8, 48, 0);
	_chatTabsArea.background = "";
	_chatTabsArea.zorder = 2;
	_chatTabsArea:AttachToRoot();
end

function ChatTabs.GetContactIconY(index)
	return (48 * (index - 1));
end

-- add contact to the chattabs
-- @param contact: contact to be added
-- e.g. {name = command.name, icon = icon, nid = nid, tooltip = text, presenceicon = presenceicon, commandName = command.name}
function ChatTabs.AddContact(contact)
	local node = ChatTabs.RootNode:GetChildByName(contact.name);
	if(not node) then
		contact.Name = contact.name;
		node = ChatTabs.RootNode:AddChild(CommonCtrl.TreeNode:new(contact));
		ChatTabs.RefreshContact();
	end
end

-- remove contact from the chattabs
-- @param contact: contact to be removed
-- e.g. {name = command.name}
function ChatTabs.RemoveContact(contact)
	local node = ChatTabs.RootNode:GetChildByName(contact.name);
	ChatTabs.RootNode:RemoveChildByName(contact.name)
	ChatTabs.RefreshContact();
end

function ChatTabs.OnClickContact(index)
	local contact = ChatTabs.RootNode:GetChild(index);
	
	if(mouse_button == "left") then
		System.App.Commands.Call(contact.commandName);
	else
		local ctl = CommonCtrl.GetControl("ChatTabs_ContextMenu");
		if(ctl==nil)then
			NPL.load("(gl)script/ide/ContextMenu.lua");
			ctl = CommonCtrl.ContextMenu:new{
				name = "ChatTabs_ContextMenu",
				width = 120,
				height = 160,
				--container_bg = "Texture/3DMapSystem/ContextMenu/BG3.png:8 8 8 8",
				--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
			};
			local node = ctl.RootNode;
			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "pe:name", Name = "pe:name", Type = "Group", NodeHeight = 0 });
			
			node:AddChild(CommonCtrl.TreeNode:new({Text = "查看信息", Name = "viewprofile", Type = "Menuitem", onclick = function()
					Map3DSystem.App.Commands.Call(Map3DSystem.options.ViewProfileCommand, ctl.uid)
				end, Icon = "Texture/3DMapSystem/common/userInfo.png",}));
			
			node:AddChild(CommonCtrl.TreeNode:new({Text = "加为好友", Name = "addasfriend",Type = "Menuitem", onclick = function()
			
					Map3DSystem.App.Commands.Call("Profile.Aquarius.AddAsFriend", {uid = ctl.uid});
					
				end, Icon = "Texture/3DMapSystem/common/user_add.png",}));	
			
			node:AddChild(CommonCtrl.TreeNode:new({Text = "私聊", Name = "chat", Type = "Menuitem", onclick = function()
					Map3DSystem.App.Commands.Call("Profile.Chat.ChatWithContactImmediate", {uid = ctl.uid});
				end, Icon = "Texture/3DMapSystem/common/chat.png",}));
			
			node:AddChild(CommonCtrl.TreeNode:new({Text = "打个招呼", Name = "poke", Type = "Menuitem", onclick = function()
					Map3DSystem.App.profiles.ProfileManager.Poke(ctl.uid)
				end, Icon = "Texture/3DMapSystem/common/wand.png",}));
					
			node:AddChild(CommonCtrl.TreeNode:new({Text = "去他的房间", Name = "teleport", Type = "Menuitem", onclick = function()
					-- TODO: 
					--_guihelper.MessageBox("他没有入住房间")
					Map3DSystem.App.Commands.Call("Profile.Aquarius.NA");
				end, Icon = "Texture/3DMapSystem/common/house.png",}));
			
			node:AddChild(CommonCtrl.TreeNode:new({Text = "去他的星球", Name = "teleport", Type = "Menuitem", onclick = function()
					-- TODO: 
					--_guihelper.MessageBox("他没有拥有的星球")
					Map3DSystem.App.Commands.Call("Profile.Aquarius.NA");
				end, Icon = "Texture/3DMapSystem/common/page_world.png",}));	
				
			node:AddChild(CommonCtrl.TreeNode:new({Text = "去找他", Name = "teleport", Type = "Menuitem", onclick = function()
					Map3DSystem.App.profiles.ProfileManager.TeleportToUser(ctl.uid)
				end, Icon = "Texture/3DMapSystem/common/transmit.png",}));
				
			node:AddChild(CommonCtrl.TreeNode:new({Text = "屏蔽", Name = "blockuser", Type = "Menuitem", onclick = function()
					-- TODO: block the user in IM
					Map3DSystem.App.Commands.Call("Profile.Aquarius.NA");
				end, Icon = "Texture/3DMapSystem/common/cancel.png",}));	
				
				
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "访问家园", Name = "visitworld",onclick = function()
					--Map3DSystem.App.profiles.ProfileManager.GotoHomeWorld(ctl.uid)
				--end, Icon = "Texture/3DMapSystem/common/house.png",}));		
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "打个招呼", Name = "poke", Type = "Menuitem", onclick = function()
					--Map3DSystem.App.profiles.ProfileManager.Poke(ctl.uid)
				--end, Icon = "Texture/3DMapSystem/common/wand.png",}));
			
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "查看好友", Name = "viewfriend",Type = "Menuitem", onclick = function()
					--Map3DSystem.App.profiles.ProfileManager.FriendsPage(ctl.uid)
				--end, }));	
		end	
		System.App.profiles.ProfileManager.GetUserInfo(System.App.Chat.GetNameFromJID(contact.nid), nil, function(msg) 
			if(msg and msg.users and msg.users[1]) then
				ctl.uid = msg.users[1].userid;
			else
				ctl.uid = nil;
			end
			ctl:Show();
		end, "access plus 10 year");
	end
end

function ChatTabs.RefreshContact()
	local _chatTabsArea = ParaUI.GetUIObject("ChatTabsArea");
	if(_chatTabsArea:IsValid()) then
		_chatTabsArea:RemoveAll();
		local nCount = ChatTabs.RootNode:GetChildCount();
		_chatTabsArea.height = 48 * nCount;
		local i;
		for i = 1, nCount do
			contact = ChatTabs.RootNode:GetChild(i);
			local index = contact.index;
			local _contact = ParaUI.CreateUIObject("container", "contact:"..contact.name, "_lt", 0, ChatTabs.GetContactIconY(index), 48, 48);
			_contact.background = "";
			_chatTabsArea:AddChild(_contact);
			local _area = ParaUI.CreateUIObject("container", "iconarea", "_lt", 0, 0, 48, 48);
			_area.background = "";
			_contact:AddChild(_area);
			
				local _shadow = ParaUI.CreateUIObject("button", "shadow", "_lt", 0, 0, 41, 42);
				_shadow.background = "Texture/Aquarius/Andy/UserIconShadow_32bits.png; 0 0 41 42";
				--_shadow.animstyle = 12;
				_area:AddChild(_shadow);
				local _icon = ParaUI.CreateUIObject("button", "icon", "_lt", 7, 5, 28, 28);
				--_icon.background = contact.icon;
				--_icon.background = Map3DSystem.App.Chat.MainWnd.GetUserIconSampleFromNID(contact.nid);
				_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
				_icon.animstyle = 12;
				--_icon.onclick = ";System.App.Commands.Call(\""..contact.commandName.."\");";
				_icon.onclick = ";MyCompany.Aquarius.Desktop.ChatTabs.OnClickContact("..i..");";
				
				_icon.onmouseenter = ";MyCompany.Aquarius.Desktop.ChatTabs.OnEnterTab(\""..contact.name.."\");";
				_icon.onmouseleave = ";MyCompany.Aquarius.Desktop.ChatTabs.OnLeaveTab(\""..contact.name.."\");";
				_area:AddChild(_icon);
				
				MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, contact.nid);
			
			local _nameandstatus = ParaUI.CreateUIObject("container", "nameandstatus", "_lt", 7, 9, 64, 20);
			_nameandstatus.background = "Texture/Aquarius/Andy/TextBG_32bits.png; 0 0 24 20: 12 10 11 10";
			_nameandstatus.visible = false;
			_contact:AddChild(_nameandstatus);
			
				local _status = ParaUI.CreateUIObject("button", "status", "_lt", 2, 2, 16, 16);
				_status.background = contact.presenceicon;
				_nameandstatus:AddChild(_status);
				
				
				System.App.profiles.ProfileManager.GetUserInfo(contact.nid, "RefreshContact", function (msg)
						if(msg and msg.users and msg.users[1]) then
							-- in local server
							local profile;
							local photo = msg.users[1].smallphoto;
							local nickname = msg.users[1].nickname;
							if(nickname == nil or nickname == "") then
								nickname = "匿名";
							end
							-- NOTE: currently the fill name callback still don't know how to fill the text and affect other ui object apperance
							-- we assume the title text width is 4 chinese characters
							local width = _guihelper.GetTextWidth("四个汉字", System.DefaultBoldFontString);
							local width = _guihelper.GetTextWidth(nickname, System.DefaultBoldFontString);
							--local width = _guihelper.GetTextWidth(contact.nid, System.DefaultBoldFontString);
							local _name = ParaUI.CreateUIObject("text", "name", "_lt", 20, 3, width, 20);
							_name.background = nil;
							_name.text = nickname;
							_icon.tooltip = "与 "..nickname.." 的对话";
							_name.font = System.DefaultBoldFontString;
							_name.shadow = true;
							_guihelper.SetFontColor(_name, "255 255 255");
							_nameandstatus:AddChild(_name);
							_nameandstatus.width = width + 24 - 4;
							_nameandstatus.x = -(width + 24 - 4 + 8);
						else
							-- remote call
							-- NOTE: currently the fill name callback still don't know how to fill the text and affect other ui object apperance
							-- we assume the title text width is 4 chinese characters
							local width = _guihelper.GetTextWidth("四个汉字", System.DefaultBoldFontString);
							--local width = _guihelper.GetTextWidth(contact.nid, System.DefaultBoldFontString);
							local _name = ParaUI.CreateUIObject("text", "name", "_lt", 20, 3, width, 20);
							_name.background = nil;
							_name.text = contact.nid.."";
							_name.font = System.DefaultBoldFontString;
							_name.shadow = true;
							_guihelper.SetFontColor(_name, "255 255 255");
							_nameandstatus:AddChild(_name);
							_nameandstatus.width = width + 24 - 4;
							_nameandstatus.x = -(width + 24 - 4 + 8);
							
							MyCompany.Aquarius.Desktop.FillUIObjectWithNameFromNID(_name, contact.nid);
						end
				end, "access plus 10 year");
				
				
			local _bubble = ParaUI.CreateUIObject("container", "textbubble", "_lt", 7, 8, 40, 22);
			_bubble.background = "Texture/Aquarius/Andy/ChatBubbleRight_32bits.png; 0 0 53 22: 20 8 20 9";
			_bubble.visible = false;
			_bubble.enabled = false;
			_contact:AddChild(_bubble);
			
				local _text = ParaUI.CreateUIObject("text", "text", "_lt", 20, 2, 64, 22);
				_text.text = "";
				_bubble:AddChild(_text);
		end
	end
end

function ChatTabs.OnEnterTab(name)
	local _contact = ParaUI.GetUIObject("contact:"..name);
	if(_contact:IsValid() == true) then
		local _nameandstatus = _contact:GetChild("nameandstatus");
		_nameandstatus.visible = true;
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_nameandstatus);
		block:SetTime(150);
		block:SetAlphaRange(0, 1);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
	end
end

function ChatTabs.OnLeaveTab(name)
	local _contact = ParaUI.GetUIObject("contact:"..name);
	if(_contact:IsValid() == true) then
		local _nameandstatus = _contact:GetChild("nameandstatus");
		_nameandstatus.visible = true;
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_nameandstatus);
		block:SetTime(150);
		block:SetAlphaRange(1, 0);
		block:SetApplyAnim(true); 
		block:SetCallback(function ()
			_nameandstatus.visible = false;
		end); 
		UIAnimManager.PlayDirectUIAnimation(block);
	end
end

-- bubble count downs, if the count reach 0, the bubble will play a hide animation
-- each time the bubble is shown, the countdown is refresh to 2 seconds
-- e.g. ["contact:"..contact.name] = 3.8
ChatTabs.BubbleCountDowns = {};

-- show the message bubble on the chattab
-- @param contact: contact to be removed
-- @param msg: message text, if nil it will clear the 
-- e.g. {name = command.name}
function ChatTabs.ShowBubbleMSG(contact, msg)
	local _contact = ParaUI.GetUIObject("contact:"..contact.name);
	if(_contact:IsValid() == true) then
		local _bubble = _contact:GetChild("textbubble");
		local _text = _bubble:GetChild("text");
		local enter = string.find(msg, "\n");
		local str = string.sub(msg, 1, enter);
		local shortStr = string.sub(str, 1, 20);
		if(shortStr == msg) then
			_text.text = shortStr;
		else
			_text.text = shortStr.."...";
		end
		local width = _guihelper.GetTextWidth(_text.text, System.DefaultFontString);
		_bubble.width = width + 40;
		_bubble.x = -(width + 40) + 2;
		_text.width = width;
		
		_bubble.visible = true;
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_bubble);
		block:SetTime(150);
		block:SetAlphaRange(0, 0.8);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		
		local _area = _contact:GetChild("iconarea");
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_area);
		block:SetTime(70);
		block:SetYRange(0, -5);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_area);
		block:SetTime(70);
		block:SetYRange(-5, -8);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_area);
		block:SetTime(70);
		block:SetYRange(-8, -9);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_area);
		block:SetTime(70);
		block:SetYRange(-9, -8);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_area);
		block:SetTime(70);
		block:SetYRange(-8, -5);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_area);
		block:SetTime(70);
		block:SetYRange(-5, 0);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		
		
		--local fileName = "script/UIAnimation/CommonIcon.lua.table";
		--local _icon = _contact:GetChild("icon");
		--if(_icon:IsValid() == true) then
			--UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Bounce", false);
		--end
		--local _shadow = _contact:GetChild("shadow");
		--if(_shadow:IsValid() == true) then
			--UIAnimManager.PlayUIAnimationSequence(_shadow, fileName, "Bounce", false);
		--end
		
		-- each time the bubble is shown, the countdown is refresh to 4 seconds
		ChatTabs.BubbleCountDowns["contact:"..contact.name] = 4;
	end
end

function ChatTabs.RegisterDoBubbleTimer()
	-- set OnRoster message timer
	NPL.SetTimer(24593, 0.2, ";MyCompany.Aquarius.Desktop.ChatTabs.DoBubbleTimer();");
end

-- bubble count downs, if the count reach 0, the bubble will play a hide animation
function ChatTabs.DoBubbleTimer()
	local contact, countdown;
	for contact, countdown in pairs(ChatTabs.BubbleCountDowns) do
		ChatTabs.BubbleCountDowns[contact] = countdown - 0.2;
		if(countdown <= 0) then
			ChatTabs.BubbleCountDowns[contact] = nil;
			local _contact = ParaUI.GetUIObject(contact);
			if(_contact:IsValid() == true) then
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_contact:GetChild("textbubble"));
				block:SetTime(150);
				block:SetAlphaRange(0.8, 0);
				block:SetApplyAnim(true); 
				block:SetCallback(function ()
					_contact:GetChild("textbubble").visible = false;
				end); 
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		end
	end
end