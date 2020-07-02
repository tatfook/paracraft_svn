--[[
Title: Chat contact window user interface
Author(s): WangTian
Date: 2008/5/27
NOTE: updated to the new user interface
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd2.lua");
local chatwnd = Map3DSystem.App.Chat.ChatWnd:CreateGetWnd({"andy2@pala5.cn"});
chatwnd:ShowMainWnd(true);
------------------------------------------------------------
]]

local ChatWnd = commonlib.gettable("Map3DSystem.App.Chat.ChatWnd");

if(not ChatWnd.wnds) then
	ChatWnd.wnds = {};
end

-- get the ChatWnd by its JID list. if the ChatWnd of the given JIDs list is not created. it will create a new one and return. 
-- @param JIDs: e.x. {"andy2@pala5.cn", "leio@pala5.cn", "lixizhi@pala5.cn", "Clayman@pala5.cn", ...}
-- create ChatWnd object
function Map3DSystem.App.Chat.ChatWnd:CreateGetWnd(JIDs)
	
	if(type(JIDs) ~= "table") then
		log("error: create Chat.ChatWnd with no JID info\n");
		return;
	end
	
	table.sort(JIDs);
	
	local ID = Map3DSystem.App.Chat.ChatWnd.GenerateID(JIDs);
	if(Map3DSystem.App.Chat.ChatWnd.wnds[ID] ~= nil) then
		return Map3DSystem.App.Chat.ChatWnd.wnds[ID];
	else
		local o = {JIDs = JIDs};
		setmetatable(o, self)
		self.__index = self;
		
		o.ID = ID;
		o.nid = Map3DSystem.App.Chat.GetNameFromJID(JIDs[1])
		Map3DSystem.App.Chat.ChatWnd.wnds[o.ID] = o;
		
		return o;
	end
end

function Map3DSystem.App.Chat.ChatWnd:Destroy()
	local _app = Map3DSystem.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID);
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		frame:Destroy();
	end
	
	Map3DSystem.App.Chat.ChatWnd.wnds[self.ID] = nil;
end

-- Show the Chat window
-- @param bShow:
-- @param bSilentInit: if true, the window is init but not show
function Map3DSystem.App.Chat.ChatWnd:ShowMainWnd(bShow, bSilentInit)
	local _app = Map3DSystem.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID) or _app:RegisterWindow(self.ID, nil, Map3DSystem.App.Chat.ChatWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		if(bShow == nil) then
			local commandName = "Profile.Chat.ToggleChatTab."..self.ID;
			local _contact = ParaUI.GetUIObject("contact:"..commandName);
			if(_contact:IsValid() == true) then
				local _icon = _contact:GetChild("iconarea"):GetChild("icon");
				local x, y, width, height = _icon:GetAbsPosition();
				frame.MinimizedPointX = x + width/2;
				frame.MinimizedPointY = y + height/2;
			end
			frame:Show2(bShow);
		else
			frame.MinimizedPointX = nil;
			frame.MinimizedPointY = nil;
			frame:Show2(bShow);
		end
		
		local _this = ParaUI.GetUIObject("ChatWnd_"..self.ID);
		-- focus the input editbox
		if(_this:IsValid() == true) then
			local _input = _this:GetChild("InputBox"):GetChild("Input");
			_input:Focus();
		end
		return;
	end
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 350, -- initial width of the window client area
		initialHeight = 400, -- initial height of the window client area
		
		initialPosX = 201,
		initialPosY = 101,
		
		isShowMinimizeBox = true,
		
		isPinned = true,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = {
			name = "ChatWndStyle",
			
			--window_bg = "Texture/Aquarius/Common/frame2_32bits.png:8 25 8 8",
			window_bg = "Texture/Aquarius/Common/Frame4_32bits.png:32 46 20 17",
			fillBGLeft = 0,
			fillBGTop = 0,
			fillBGWidth = 0,
			fillBGHeight = 0,
			
			shadow_bg = "Texture/Aquarius/Common/Frame3_shadow_32bits.png: 16 16 32 32",
			fillShadowLeft = -5,
			fillShadowTop = -4,
			fillShadowWidth = -9,
			fillShadowHeight = -10,
			
			titleBarHeight = 36,
			toolboxBarHeight = 48,
			statusBarHeight = 32,
			borderLeft = 1,
			borderRight = 1,
			borderBottom = 1,
			
			textfont = Map3DSystem.DefaultBoldFontString;
			textcolor = "35 35 35",
			
			iconSize = 16,
			iconTextDistance = 16, -- distance between icon and text on the title bar
			
			IconBox = {alignment = "_lt",
						x = 13, y = 12, size = 16,},
			TextBox = {alignment = "_lt",
						x = 32, y = 12, height = 16,},
						
			CloseBox = {alignment = "_rt",
						x = -24, y = 11, sizex = 17, sizey = 16, 
						icon = "Texture/Aquarius/Common/Frame_Close_32bits.png; 0 0 17 16",
						icon_over = "Texture/Aquarius/Common/Frame_Close_over_32bits.png; 0 0 17 16",
						icon_pressed = "Texture/Aquarius/Common/Frame_Close_pressed_32bits.png; 0 0 17 16",
						},
			MinBox = {alignment = "_rt",
						x = -60, y = 11, sizex = 17, sizey = 16, 
						icon = "Texture/Aquarius/Common/Frame_Min_32bits.png; 0 0 17 16",
						icon_over = "Texture/Aquarius/Common/Frame_Min_over_32bits.png; 0 0 17 16",
						icon_pressed = "Texture/Aquarius/Common/Frame_Min_pressed_32bits.png; 0 0 17 16",
						},
			MaxBox = {alignment = "_rt",
						x = -42, y = 11, sizex = 17, sizey = 16, 
						icon = "Texture/Aquarius/Common/Frame_Max_32bits.png; 0 0 17 16",
						icon_over = "Texture/Aquarius/Common/Frame_Max_over_32bits.png; 0 0 17 16",
						icon_pressed = "Texture/Aquarius/Common/Frame_Max_pressed_32bits.png; 0 0 17 16",
						},
			PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
						x = 2, y = 2, size = 20,
						icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
						icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
			
			resizerSize = 24,
			resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
		},
		
		allowResize = true,
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = Map3DSystem.App.Chat.ChatWnd.Show,
	};
	
	local text, icon, shortText = self:GetTextAndIcon();
	sampleWindowsParam.text = text;
	--sampleWindowsParam.icon = icon;
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow, nil, bSilentInit);
	
	local _this = ParaUI.GetUIObject("ChatWnd_"..self.ID);
	-- focus the input editbox
	if(_this:IsValid() == true) then
		local _input = _this:GetChild("InputBox"):GetChild("Input");
		_input:Focus();
	end
	-- create tab
	-- currently create a tab
	
	local commandName = "Profile.Chat.ToggleChatTab."..self.ID;
	local command = Map3DSystem.App.Commands.GetCommand(commandName);
	if(command == nil) then
		command = Map3DSystem.App.Commands.AddNamedCommand({
			name = commandName, 
			app_key = Map3DSystem.App.Chat.app.app_key, 
			tooltip = text, 
			icon = icon, 
			ButtonText = shortText,
			--ownerDrawHandler = function (_parent)
				--local _icon = ParaUI.CreateUIObject("button", "defaultIcon", "_fi", 0, 0, 0, 0);
				--_icon.background = icon;
				--_icon.onclick = string.format(";Map3DSystem.App.Chat.ChatWnd.OnToggleChatTab(%q);", self.ID);
				--_icon.tooltip = text;
				--_parent:AddChild(_icon);
				--
				--local _icon = ParaUI.CreateUIObject("button", "defaultIcon", "_fi", 0, 0, 0, 10);
				--_icon.background = "";
				--_icon.text = Map3DSystem.App.Chat.GetNameFromJID(self.JIDs[1]);
				--_icon.enabled = false;
				--_parent:AddChild(_icon);
			--end,
			--onclick = function (command)
					--log("chat tab onclick\n")
					----string.format(";Map3DSystem.App.Chat.ChatWnd.OnToggleChatTab(%q);", self.ID)
					--Map3DSystem.App.Chat.ChatWnd.OnToggleChatTab(self.ID);
				--end,
		});
		
			
	end
	
	local presence = Map3DSystem.App.Chat.JID_Presence_mapping[self.JIDs[1]];
	
	local presenceicon = Map3DSystem.App.Chat.UserStatusIcon[presence];
	if(presenceicon == nil) then
		presenceicon = Map3DSystem.App.Chat.UserStatusIcon[6]; -- offline
	end
	MyCompany.Aquarius.Desktop.ChatTabs.AddContact({name = command.name, icon = icon, nid = self.nid, 
		presenceicon = presenceicon, tooltip = text, commandName = command.name});
	
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(contact.nid, "RefreshContact", function (msg)
		local nickname = "匿名";
		if(msg and msg.users and msg.users[1]) then
			nickname = msg.users[1].nickname;
			if(nickname == nil or nickname == "") then
				nickname = "匿名";
			end
		end	
		frame:SetText("与 "..nickname.." 的对话");
	end, "access plus 1 year");
end


-- return the window frame visibility
-- nil if the window frame is not inited
function Map3DSystem.App.Chat.ChatWnd:GetVisible()
	local _app = Map3DSystem.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID) or _app:RegisterWindow(self.ID, nil, Map3DSystem.App.Chat.ChatWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		return frame:GetVisible();
	else
		return nil;
	end
end

-- return if the window frame top frame
function Map3DSystem.App.Chat.ChatWnd:IsTopFrame()
	local _app = Map3DSystem.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID) or _app:RegisterWindow(self.ID, nil, Map3DSystem.App.Chat.ChatWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		return frame:IsTopFrame();
	else
		return false;
	end
end

-- get the text and icon according to ChatWnd JID list
-- @return text, icon, shortText: string
function Map3DSystem.App.Chat.ChatWnd:GetTextAndIcon()
	local text, icon, shortText;
	if(table.getn(self.JIDs) > 2) then
		text = "Chat with "..Map3DSystem.App.Chat.GetNameFromJID(self.JIDs[1]).." and other "..(table.getn(self.JIDs)-1).." guys";
		icon = "Texture/3DMapSystem/Chat/MultipleChat.png";
		shortText = Map3DSystem.App.Chat.GetNameFromJID(self.JIDs[1]).."...";
	elseif(table.getn(self.JIDs) == 2) then
		text = "Chat with "..Map3DSystem.App.Chat.GetNameFromJID(self.JIDs[1]).." and "..Map3DSystem.App.Chat.GetNameFromJID(self.JIDs[2]);
		icon = "Texture/3DMapSystem/Chat/TwoChat.png";
		shortText = Map3DSystem.App.Chat.GetNameFromJID(self.JIDs[1]).."...";
	else
		--text = "Chat with "..Map3DSystem.App.Chat.GetNameFromJID(self.ID);
		--text = "Chat with "..Map3DSystem.App.Chat.GetNameFromJID(self.ID);
		text = "与 "..Map3DSystem.App.Chat.GetNameFromJID(self.ID).." 的对话"
		if(self.ID == "114") then
			-- hard code the service hotline
			text = "与 Pala5客服 对话";
		end
		icon = "Texture/3DMapSystem/Chat/OneChat.png";
		shortText = Map3DSystem.App.Chat.GetNameFromJID(self.ID);
	end
	return text or "", icon or "", shortText or "";
end

-- update the UI
function Map3DSystem.App.Chat.ChatWnd:Update()
	-- TODO: update the contact information field
	
	-- update the conversation treeview
	local ctl = CommonCtrl.GetControl(self.ID.."_Conversation_TreeView");
	if(ctl ~= nil) then
		ctl:Update(true);
	end
	
	-- update the title text and icon
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(Map3DSystem.App.Chat.app._app.name, self.ID);
	if(frame ~= nil) then
		local text, icon = self:GetTextAndIcon();
		frame:SetText(text);
		frame:SetIcon(icon);
	end
end

-- recv message
-- @param JID
-- @param subject
-- @param body
function Map3DSystem.App.Chat.ChatWnd:RecvMSG(JID, subject, body)
	self:AppendMSG(JID, body);
	
	local isVisible = self:GetVisible();
	if(isVisible == false) then
		
	elseif(isVisible == true) then
		local isTopFrame = self:IsTopFrame();
		if(isTopFrame == true) then
			return; -- return if the current user interact window is chat window itself
		end
	end
	
	-- otherwise show the message in the bubble on chat tabs
	MyCompany.Aquarius.Desktop.ChatTabs.ShowBubbleMSG({name = "Profile.Chat.ToggleChatTab."..self.ID}, body);
	
	---- update to the status bar task message
	--Map3DSystem.App.ActionFeed.StatusBar.PostMSGToTask(self.ID, body);
end

-- send message
function Map3DSystem.App.Chat.ChatWnd:SendMSG()
	local _this = ParaUI.GetUIObject("ChatWnd_"..self.ID);
	local sendText;
	
	if(_this:IsValid() == true) then
		local _input = _this:GetChild("InputBox"):GetChild("Input");
		if(_input.text == "") then
			return; -- empty text input field
		end
		sendText = _input.text;
		_input.text = "";
		
		local jc = Map3DSystem.App.Chat.GetConnectedClient();
		if(jc ~= nil) then
			local k, v;
			for k, v in pairs(self.JIDs) do
				jc:Message(v, sendText);
			end
		end
		
		self:AppendMSG(Map3DSystem.App.Chat.UserJID, sendText);
	end
end

-- append the message to conversation treeview and update
function Map3DSystem.App.Chat.ChatWnd:AppendMSG(JID, body)
	
	local time = ParaGlobal.GetTimeFormat("HH:mm");
	if(self.LatestMSGTime ~= time) then
		self.LatestMSGTime = time;
	else
		time = nil;
	end
	
	
	local ctl = CommonCtrl.GetControl(self.ID.."_Conversation_TreeView");
	
	if(ctl == nil) then
		log("error: getting ChatWnd conversation treeview: "..self.ID.."_Conversation_TreeView".."\r\n");
		return;
	end
	--if(self.LastMessageSpeaker ~= JID) then
		--self.LastMessageSpeaker = JID;
		--
		--local text;
		--if(Map3DSystem.App.Chat.UserJID == JID) then
			--text = "我";
		--else
			--text = Map3DSystem.App.Chat.GetNameFromJID(JID);
		--end
		--
		--local headerColor;
		--if(text == "我") then
			--headerColor = "234 202 53";
		--else
			--headerColor = "150 212 68";
		--end
		--
		--ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = text, type = "header", NodeHeight = 25, color = headerColor, time = time}));
	--end
	
	if(time ~= nil) then
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({type = "time", time = time}));
	end
	
	local nid = Map3DSystem.App.Chat.GetNameFromJID(JID);
	
	if(Map3DSystem.App.Chat.UserJID == JID) then
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = tostring(body), type = "message", nid = nid, ifmyself = true,}));
	else
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = tostring(body), type = "message", nid = nid, ifmyself = false,}));
	end
	ctl:Update(true); -- true to scroll to last element.
	ctl:Update(true); -- true to scroll to last element.
	-- NOTE: a little trick here:
	--		if a text is very long, the node height is updated in the ownerdraw handler
	--		but the treeview still scroll down as the original height
	-- TODO: improvement: insert the node with height, pay attention if the scroll bar is available
	
	-- append message to channel window as well
	--Map3DSystem.App.Chat.ChannelManager.AppendJabberChatMessage(JID, subject, body);
end

-- click on the chat tab
function Map3DSystem.App.Chat.ChatWnd.OnToggleChatTab(ID)
	local chatWnd = Map3DSystem.App.Chat.ChatWnd.GetChatWndByID(ID);
	chatWnd:ShowMainWnd();
end

-- generate a unique ID of this chat window using the JIDs
function Map3DSystem.App.Chat.ChatWnd.GenerateID(JIDs)
	local ID = "";
	local k, v;
	for k, v in ipairs(JIDs) do
		ID = ID..Map3DSystem.App.Chat.GetNameFromJID(v); --.."#";
	end
	--if(ID ~= "") then
		--ID = string.gsub(ID, 1, -2);
	--end
	return ID;
end

-- get the chat window using ID
function Map3DSystem.App.Chat.ChatWnd.GetChatWndByID(ID)
	return Map3DSystem.App.Chat.ChatWnd.wnds[ID];
end

-- Message Processor of Chat chat window control
function Map3DSystem.App.Chat.ChatWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		local chatWnd = Map3DSystem.App.Chat.ChatWnd.GetChatWndByID(window.name);
		chatWnd:Update();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		Map3DSystem.App.Chat.ChatWnd.OnToggleChatTab(window.name)
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		local chatWnd = Map3DSystem.App.Chat.ChatWnd.GetChatWndByID(window.name);
		
		--Map3DSystem.UI.MainBar.RemoveBarItem("Chat.ToggleChatTab."..chatWnd.ID, "stacks");
		
		--Map3DSystem.App.ActionFeed.StatusBar.RemoveTask(chatWnd.ID);
		
		local commandName = "Profile.Chat.ToggleChatTab."..chatWnd.ID;
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command ~= nil) then
			MyCompany.Aquarius.Desktop.ChatTabs.RemoveContact({name = command.name});
		end
		
		chatWnd:Destroy();
	end
end

-- show Chat ChatWnd in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
function Map3DSystem.App.Chat.ChatWnd.Show(bShow, _parent, parentWindow)
	local _chatWnd = Map3DSystem.App.Chat.ChatWnd.GetChatWndByID(parentWindow.name);
	
	if(_chatWnd == nil) then
		log("error: show chat window with no chatwindow created.\n");
		log("\t\t os.window name: "..(parentWindow.name or "").."\n");
		return;
	end
	
	_chatWnd.parentWindow = parentWindow;
	
	local _this;
	_this = ParaUI.GetUIObject("ChatWnd_".._chatWnd.ID);
	
	if(_this:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "ChatWnd_".._chatWnd.ID, "_lt", 0, 50, 300, 500);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "ChatWnd_".._chatWnd.ID, "_fi", 0, 0, 0, 0);
			_this.background = "";
			_parent:AddChild(_this);
		end
		
		local _main = _this;
		
		-- HIDE the toolbox
		--_toolBox = ParaUI.CreateUIObject("container", "ToolBox", "_mt", 0, 0, 0, 64);
		----_toolBox.background = "";
		--_main:AddChild(_toolBox);
		
		--_chatBox = ParaUI.CreateUIObject("container", "ChatBox", "_fi", 0, 64, 0, 32);
		_chatBox = ParaUI.CreateUIObject("container", "ChatBox", "_fi", 1, 1, 1, 32);
		_chatBox.background = "Texture/3DMapSystem/Chat/ChatBoxBG.png";
		_main:AddChild(_chatBox);
		
		_inputBox = ParaUI.CreateUIObject("container", "InputBox", "_mb", 0, 0, 0, 32);
		--_inputBox.background = "";
		_main:AddChild(_inputBox);
		
		
		------------------------ toolbox ------------------------
		
		--_this = ParaUI.CreateUIObject("button", "Link", "_lt", 16, 8, 48, 48);
		--_this.background = "Texture/3DMapSystem/common/IconSet/Map_8.png";
		--_this.tooltip = "JGSL";
		--_this.onclick = string.format(";Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JOIN_JGSL, jid=%q})", _chatWnd.JIDs[1]);
		--
		--_toolBox:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "AddToConversation", "_lt", 80, 8, 48, 48);
		--_this.background = "Texture/3DMapSystem/Chat/AddToConversation.png";
		--_this.tooltip = "TODO: Add a Friend to this Conversation";
		--_toolBox:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "Action", "_lt", 144, 8, 48, 48);
		--_this.background = "Texture/3DMapSystem/Chat/Action.png";
		--_this.tooltip = "TODO: Actions";
		--_toolBox:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "Block", "_lt", 208, 8, 48, 48);
		--_this.background = "Texture/3DMapSystem/Chat/Block.png";
		--_this.tooltip = "TODO: Block this Contact";
		--_toolBox:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "ToggleInfo", "_rt", -64, 8, 48, 48);
		--_this.tooltip = "TODO: Toggle Information Field";
		--_this.background = "Texture/3DMapSystem/Chat/ToggleInfo.png";
		--_toolBox:AddChild(_this);
		
		
		------------------------ chatbox ------------------------
		
		_this = ParaUI.CreateUIObject("container", "Conversation", "_fi", 0, 0, 0, 0);
		_this.background = "";
		_chatBox:AddChild(_this);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = _chatWnd.ID.."_Conversation_TreeView",
			alignment = "_fi",
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			parent = _this,
			container_bg = "",
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
			VerticalScrollBarStep = 22,
			DrawNodeHandler = Map3DSystem.App.Chat.ChatWnd.DrawConversationNodeHandler,
		};
		local node = ctl.RootNode;
		ctl:Show();
		
		
		------------------------ inputbox ------------------------
		
		_this = ParaUI.CreateUIObject("container", "BG", "_fi", 0, 0, 0, 0);
		_this.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png: 4 4 4 4";
		_inputBox:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("imeeditbox", "Input", "_fi", 16, 4, 32, 4);
		_this.onchange = string.format(";Map3DSystem.App.Chat.ChatWnd.OnInputTextChange(%q);", _chatWnd.ID);
		_inputBox:AddChild(_this);
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- monitor the keychange, enter to send message
function Map3DSystem.App.Chat.ChatWnd.OnInputTextChange(ChatWndID)
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		local chatWnd = Map3DSystem.App.Chat.ChatWnd.GetChatWndByID(ChatWndID);
		if(chatWnd ~= nil) then
			chatWnd:SendMSG();
		end
	end
end

function Map3DSystem.App.Chat.ChatWnd.DrawConversationNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1); -- indentation of this node. 
	local top = 2;
	local width;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.type == "header") then
		-- render contact header TreeNode: a colored name and an underline
		width = 24 -- check box width
		_this = ParaUI.CreateUIObject("container", "header_BG", "_fi", 5, 0, 5, 5);
		_this.background = "Texture/3DMapSystem/IM/underline.png: 4 4 4 4";
		_this.enable = false;
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", "header", "_mt", 10, 3, 0, height - 3);
		_this.text = treeNode.Text;
		_this:GetFont("text").color = treeNode.color;
		_this.font = Map3DSystem.DefaultFontFamily..";"..Map3DSystem.DefaultFontSize..";".."bold";
		_parent:AddChild(_this);
	elseif(treeNode.type == "time") then
		treeNode.NodeHeight = 10;
		_this = ParaUI.CreateUIObject("button", "time", "_mt", 0, 0, 0, 22);
		_this.background = "";
		_this.text = treeNode.time;
		_this.enabled = false;
		_guihelper.SetFontColor(_this, "138 138 138");
		_parent:AddChild(_this);
	elseif(treeNode.type == "message") then
		-- render contact message TreeNode: an icon and a text bubble
		local function GetLineCount(text, fitwidth, font)
			local line;
			local count = 0;
			for line in string.gfind(text, "([^\n]+)") do
				local textWidth = _guihelper.GetTextWidth(line, font);
				count = count + math.ceil (textWidth / fitwidth);
			end
			return count;
		end
		
		local textWidth = _guihelper.GetTextWidth(treeNode.Text, System.DefaultFontString);
		
		local lines = GetLineCount(treeNode.Text, (nodeWidth - 6 - 32 - 32 - 6 - 40), System.DefaultFontString); -- icon*2 + border*2 + bubbleborder*2
		
		
		local _icon, _bubble;
		if(treeNode.ifmyself == true) then
			_icon = ParaUI.CreateUIObject("container", "icon", "_rb", -38, -32, 32, 32);
			-- get the icon in memory
			System.App.profiles.ProfileManager.GetUserInfo(treeNode.nid, "UpdateChatWndIcon", function(msg)
				if(msg and msg.users and msg.users[1]) then
					_icon.background = msg.users[1].photo;
				else
					_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
				end
			end, "access plus 10 year");
			--_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
			_parent:AddChild(_icon);
			
			MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, treeNode.nid);
			
			_bubble = ParaUI.CreateUIObject("container", "bubble", "_rt", -(textWidth + 40 + 38), 10, textWidth + 40, 22);
			if(lines > 1) then
				_bubble.x = -(nodeWidth - 6 - 32 - 32 - 6 + 38);
				_bubble.width = nodeWidth - 6 - 32 - 32 - 6;
				_bubble.height = 15 * lines + 8;
			end
			_bubble.background = "Texture/Aquarius/Andy/ChatBubbleRight_32bits.png; 0 0 53 22: 20 8 20 9";
			_parent:AddChild(_bubble);
		else
			_icon = ParaUI.CreateUIObject("container", "icon", "_lb", 6, -32, 32, 32);
			-- get the icon in memory
			System.App.profiles.ProfileManager.GetUserInfo(treeNode.nid, "UpdateChatWndIcon", function(msg)
				if(msg and msg.users and msg.users[1]) then
					_icon.background = msg.users[1].photo;
				else
					_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
				end
			end, "access plus 10 year");
			--_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
			_parent:AddChild(_icon);
			
			MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, treeNode.nid);
			
			_bubble = ParaUI.CreateUIObject("container", "bubble", "_lt", 38, 10, textWidth + 40, 22);
			if(lines > 1) then
				_bubble.width = nodeWidth - 6 - 32 - 32 - 6;
				_bubble.height = 15 * lines + 8;
			end
			_bubble.background = "Texture/Aquarius/Andy/ChatBubbleLeft_32bits.png; 0 0 53 22: 20 8 20 9";
			_parent:AddChild(_bubble);
		end
		treeNode.NodeHeight = 32;
		
		
		if(lines == 1) then
			-- default height is 22 
			_this = ParaUI.CreateUIObject("text", "message", "_lt", 20, 2, _bubble.width - 40, 22);
			_this.text = treeNode.Text;
			_bubble:AddChild(_this);
		else
			_this = ParaUI.CreateUIObject("text", "message", "_lt", 20, 3, _bubble.width - 40, 15 * lines + 6); -- default font is 12 weight
			_this.text = treeNode.Text;
			_bubble:AddChild(_this);
			treeNode.NodeHeight = 15 * lines + 8 + 10;
		end
	end
end
