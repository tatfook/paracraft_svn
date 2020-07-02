--[[
Title: Chat contact window user interface
Author(s): WangTian
Company: ParaEnging Co. & Taomee Inc.
Date: 2009/4/9
NOTE: updated to the new user interface
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/ChatWnd.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
-- create class
local libName = "AriesChatWnd";
local ChatWnd = commonlib.gettable("MyCompany.Aries.Chat.ChatWnd");
local Chat = commonlib.gettable("MyCompany.Aries.Chat");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");

if(not ChatWnd.wnds) then
	ChatWnd.wnds = {};
end

-- get the ChatWnd by its JID list. if the ChatWnd of the given JIDs list is not created. it will create a new one and return. 
-- @param JIDs: e.x. {"andy2@pala5.cn", "leio@pala5.cn", "lixizhi@pala5.cn", "Clayman@pala5.cn", ...}
-- create ChatWnd object
function ChatWnd:CreateGetWnd(JIDs)
	
	if(type(JIDs) ~= "table") then
		log("error: create Chat.ChatWnd with no JID info\n");
		return;
	end
	
	table.sort(JIDs);
	
	local ID = ChatWnd.GenerateID(JIDs);
	if(ChatWnd.wnds[ID] ~= nil) then
		return ChatWnd.wnds[ID];
	else
		local o = {JIDs = JIDs};
		setmetatable(o, self)
		self.__index = self;
		
		o.ID = ID;
		o.nid = System.App.Chat.GetNameFromJID(JIDs[1])
		ChatWnd.wnds[o.ID] = o;
		
		return o;
	end
end

function ChatWnd:Destroy()
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID);
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		frame:Destroy();
	end
	
	ChatWnd.wnds[self.ID] = nil;
end

-- Show the Chat window
-- @param bShow:
-- @param bSilentInit: if true, the window is init but not show
function ChatWnd:ShowMainWnd(bShow, bSilentInit)
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID) or _app:RegisterWindow(self.ID, nil, ChatWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		if(bShow == nil) then
			local commandName = "Profile.Aries.ToggleChatTab."..self.ID;
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
		
		initialWidth = 484, -- initial width of the window client area
		initialHeight = 392, -- initial height of the window client area
		
		initialPosX = 201,
		initialPosY = 101,
		
		isShowMinimizeBox = false, -- turn off the minimize operation
		
		isPinned = true,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = {
			name = "ChatWndStyle",
			
			--window_bg = "Texture/Aries/Common/frame2_32bits.png:8 25 8 8",
			--window_bg = "Texture/Aries/Friends/ChatWnd_Frame.png:30 30 30 30",
			window_bg = "Texture/Aries/Friends/chatwnd_bg_32bits.png;0 0 484 392:30 30 30 30",
			fillBGLeft = 0,
			fillBGTop = 0,
			fillBGWidth = 0,
			fillBGHeight = 0,
			
			shadow_bg = "",
			fillShadowLeft = -5,
			fillShadowTop = -4,
			fillShadowWidth = -9,
			fillShadowHeight = -10,
			
			titleBarHeight = 36,
			toolboxBarHeight = 48,
			statusBarHeight = 32,
			borderLeft = 21,
			borderRight = 21,
			borderBottom = 21,
			
			textfont = System.DefaultBoldFontString;
			textcolor = "35 35 35",
			
			iconSize = 16,
			iconTextDistance = 16, -- distance between icon and text on the title bar
			
			IconBox = {alignment = "_lt",
						x = 13, y = 12, size = 16,},
			TextBox = {alignment = "_lt",
						x = 32, y = 22, height = 20,},
						
			CloseBox = {alignment = "_rt",
						x = -48, y = -6, sizex = 54, sizey = 54, 
						icon = "Texture/Aries/Common/Close_Big_54_32bits.png;0 0 54 54",
						},
			MinBox = {alignment = "_rt",
						x = -60, y = 11, sizex = 17, sizey = 16, 
						icon = "Texture/Aries/Common/Frame_Min_32bits.png; 0 0 17 16",
						icon_over = "Texture/Aries/Common/Frame_Min_over_32bits.png; 0 0 17 16",
						icon_pressed = "Texture/Aries/Common/Frame_Min_pressed_32bits.png; 0 0 17 16",
						},
			MaxBox = {alignment = "_rt",
						x = -42, y = 11, sizex = 17, sizey = 16, 
						icon = "Texture/Aries/Common/Frame_Max_32bits.png; 0 0 17 16",
						icon_over = "Texture/Aries/Common/Frame_Max_over_32bits.png; 0 0 17 16",
						icon_pressed = "Texture/Aries/Common/Frame_Max_pressed_32bits.png; 0 0 17 16",
						},
			PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
						x = 2, y = 2, size = 20,
						icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
						icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
			
			resizerSize = 24,
			resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
		},
		
		allowResize = false, -- 2009.5.16: turn off the resize operation for Aries
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = ChatWnd.Show,
	};
	
	--sampleWindowsParam.text = text;
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
	
	local commandName = "Profile.Aries.ToggleChatTab."..self.ID;
	local command = System.App.Commands.GetCommand(commandName);
	if(command == nil) then
		command = System.App.Commands.AddNamedCommand({
			name = commandName, 
			app_key = MyCompany.Aries.app.app_key, 
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
				--_icon.text = System.App.Chat.GetNameFromJID(self.JIDs[1]);
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
	
	
	-- refresh the window frame title
	self:SetTextAndIcon();
end


-- return the window frame visibility
-- nil if the window frame is not inited
function ChatWnd:GetVisible()
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID) or _app:RegisterWindow(self.ID, nil, ChatWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		return frame:GetVisible();
	else
		return nil;
	end
end

-- return if the window frame top frame
function ChatWnd:IsTopFrame()
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow(self.ID) or _app:RegisterWindow(self.ID, nil, ChatWnd.MSGProc);
	
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
function ChatWnd:SetTextAndIcon()
	local text, icon, shortText;
	if(table.getn(self.JIDs) > 2) then
		-- multiple chat is depracated in Aries
		text = "Chat with "..System.App.Chat.GetNameFromJID(self.JIDs[1]).." and other "..(table.getn(self.JIDs)-1).." guys";
		--icon = "Texture/3DMapSystem/Chat/MultipleChat.png";
		icon = "";
		shortText = System.App.Chat.GetNameFromJID(self.JIDs[1]).."...";
	elseif(table.getn(self.JIDs) == 2) then
		-- multiple chat is depracated in Aries
		text = "Chat with "..System.App.Chat.GetNameFromJID(self.JIDs[1]).." and "..System.App.Chat.GetNameFromJID(self.JIDs[2]);
		--icon = "Texture/3DMapSystem/Chat/TwoChat.png";
		icon = "";
		shortText = System.App.Chat.GetNameFromJID(self.JIDs[1]).."...";
	else
		--text = "Chat with "..System.App.Chat.GetNameFromJID(self.ID);
		--text = "Chat with "..System.App.Chat.GetNameFromJID(self.ID);
		local nickname;
		
		System.App.profiles.ProfileManager.GetUserInfo(System.App.Chat.GetNameFromJID(self.ID), "AriesChatSetTextAndIcon", function(msg)
			local frame = CommonCtrl.WindowFrame.GetWindowFrame2(System.App.Chat.app._app.name, self.ID);
			if(frame ~= nil) then
				if(msg and msg.users and msg.users[1]) then
					nickname = msg.users[1].nickname;
				else
					nickname = "";
				end
				local nid=System.App.Chat.GetNameFromJID(self.ID);
				local t_nid=tonumber(nid);
				if (t_nid) then
					nid=MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(t_nid);
				end
				frame:SetText("与"..nickname.." ("..nid..") 通话中");
				frame:SetIcon("");
				self.nickname = nickname;
			end
		end, "access plus 10 year");
	end
end

-- update the UI
function ChatWnd:Update()
	-- TODO: update the contact information field
	
	-- update the conversation treeview
	local ctl = CommonCtrl.GetControl(self.ID.."_Conversation_TreeView");
	if(ctl ~= nil) then
		ctl:Update(true);
	end
	
	-- update the title text and icon
	self:SetTextAndIcon();
end

-- recv message
-- @param JID
-- @param subject
-- @param body
function ChatWnd:RecvMSG(JID, subject, body)
	--commonlib.echo({JID, subject, body})
	self:AppendMSG(JID, body);
	
	local isVisible = self:GetVisible();
	if(isVisible == false) then
		self:SetTextAndIcon();
		local commandName = "Profile.Aries.ToggleChatTab."..self.ID;
		local presence = System.App.Chat.GetPresenceFromJID(self.JIDs[1]);
		local presenceicon = Chat.UserStatusIcon[presence];
		if(presenceicon == nil) then
			presenceicon = Chat.UserStatusIcon[6]; -- offline
		end
		MyCompany.Aries.Desktop.NotificationArea.AppendMSG({Name = commandName, icon = icon, nid = self.nid, 
			presenceicon = presenceicon, tooltip = text, commandName = commandName});
		
	elseif(isVisible == true) then
		local isTopFrame = self:IsTopFrame();
		if(isTopFrame == true) then
			return; -- return if the current user interact window is chat window itself
		end
	end

	local msgdata = { ChannelIndex=ChatChannel.EnumChannels.Private,from=self.nid,words=body, };
	ChatChannel.AppendChat( msgdata );
	
	---- otherwise show the message in the bubble on chat tabs
	--MyCompany.Aquarius.Desktop.ChatTabs.ShowBubbleMSG({name = "Profile.Aries.ToggleChatTab."..self.ID}, body);
end

-- send message
function ChatWnd:SendMSG()
	local _this = ParaUI.GetUIObject("ChatWnd_"..self.ID);
	local sendText;
	
	if(_this:IsValid() == true) then
		local _input = _this:GetChild("InputBox"):GetChild("Input");
		if(_input.text == "") then
			return; -- empty text input field
		end
		sendText = _input.text;
		
		if(string.len(sendText) > 120) then
			_guihelper.MessageBox("你输入的文字太多了，请缩短一点吧");
			return;
		end
		
		_input.text = "";
		sendText = MyCompany.Aries.Chat.BadWordFilter.FilterString(sendText);
		self:SendMSGToServer(sendText);
	end
end


-- send message
function ChatWnd:SendMSGToServer(words)
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();

	if(words)then
		local jc = Chat.GetConnectedClient();
		if(jc ~= nil) then
			local k, v;
			for k, v in pairs(self.JIDs) do
				local canSendMsg=ExternalUserModule:CanViewUser(myNid, v);
				if (canSendMsg) then
					jc:Message(v, words);
				end				
			end
			self:AppendMSG(System.App.Chat.UserJID, words);
		end
	end
end

-- append the message to conversation treeview and update
function ChatWnd:AppendMSG(JID, body)
	if(not JID) then
		return;
	end
	
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
	
	if(time ~= nil) then
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({type = "time", time = time}));
	end
	
	
	local nid = System.App.Chat.GetNameFromJID(JID);
	
	if(System.App.Chat.UserJID == JID) then
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = tostring(body), type = "message", nid = nid, icon = icon, ifmyself = true, nickname = "我",}));
		--System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "ChatWindowUserName", function(msg)
			--if(msg and msg.users[1]) then
				--local nickname = msg.users[1].nickname;
				--ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = tostring(body), type = "message", nid = nid, ifmyself = true, nickname = nickname,}));
			--end
		--end);
	else
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = tostring(body), type = "message", nid = nid, ifmyself = false, }));
	end
	ctl:Update(true); -- true to scroll to last element.
	--ctl:Update(true); -- true to scroll to last element.
	
	-- NOTE: a little trick here:
	--		if a text is very long, the node height is updated in the ownerdraw handler
	--		but the treeview still scroll down as the original height
	-- TODO: improvement: insert the node with height, pay attention if the scroll bar is available
	
	-- append message to channel window as well
	--Map3DSystem.App.Chat.ChannelManager.AppendJabberChatMessage(JID, subject, body);
end

-- click on the chat tab
function ChatWnd.OnToggleChatTab(ID)
	local chatWnd = ChatWnd.GetChatWndByID(ID);
	chatWnd:ShowMainWnd();
end

-- generate a unique ID of this chat window using the JIDs
function ChatWnd.GenerateID(JIDs)
	local ID = "";
	local k, v;
	for k, v in ipairs(JIDs) do
		ID = ID..System.App.Chat.GetNameFromJID(v); --.."#";
	end
	--if(ID ~= "") then
		--ID = string.gsub(ID, 1, -2);
	--end
	return ID;
end

-- get the chat window using ID
function ChatWnd.GetChatWndByID(ID)
	return ChatWnd.wnds[ID];
end

-- Message Processor of Chat chat window control
function ChatWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		local chatWnd = ChatWnd.GetChatWndByID(window.name);
		chatWnd:Update();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- TODO: temporary use the minimize bahavior for close click
		MyCompany.Aries.Chat.ChatWnd.OnToggleChatTab(window.name)
	--elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		--local chatWnd = ChatWnd.GetChatWndByID(window.name);
		--
		----local commandName = "Profile.Aries.ToggleChatTab."..chatWnd.ID;
		----local command = System.App.Commands.GetCommand(commandName);
		----if(command ~= nil) then
			----MyCompany.Aquarius.Desktop.ChatTabs.RemoveContact({name = command.name});
		----end
		--
		--chatWnd:Destroy();
	end
end

-- show Chat ChatWnd in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
function ChatWnd.Show(bShow, _parent, parentWindow)
	local _chatWnd = ChatWnd.GetChatWndByID(parentWindow.name);
	
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
		local _chatBox = ParaUI.CreateUIObject("container", "ChatBox", "_fi", 10, 10, 140, 100);
		_chatBox.background = "Texture/Aries/Friends/ChatWnd_Chatbox_32bits.png: 30 30 30 30";
		_main:AddChild(_chatBox);
		
		local _inputBox = ParaUI.CreateUIObject("container", "InputBox", "_mb", 10, 0, 140, 100);
		_inputBox.background = "";
		_main:AddChild(_inputBox);
		
		local _targetAvatar = ParaUI.CreateUIObject("container", "TargetAvatar", "_mr", 10, 10, 122, 146);
		_targetAvatar.background = "Texture/Aries/Friends/ChatWnd_Avatar_32bits.png; 0 0 122 122 : 40 30 40 60";
		_targetAvatar.fastrender = false;
		_main:AddChild(_targetAvatar);
		
		local _myself = ParaUI.CreateUIObject("container", "Myself", "_rb", -132, -136, 122, 122);
		_myself.background = "Texture/Aries/Friends/ChatWnd_Avatar_32bits.png; 0 0 122 122 : 40 30 40 60";
		_main:AddChild(_myself);
		
		------------------------ chatbox ------------------------
		
		_this = ParaUI.CreateUIObject("container", "WarningIcon", "_lt", 8, 6, 16, 16);
		_this.background = "Texture/Aries/Friends/ChatWnd_Exclaim.png";
		_chatBox:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", "WarningText", "_lt", 30, 6, 200, 24);
		_this.text = "请不要向任何人泄露你的密码哦";
		_this.font = System.DefaultFontFamily..";12;norm";
		_guihelper.SetFontColor(_this, "#ff009a");
		_chatBox:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "Conversation", "_fi", 6, 28, 6, 6);
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
			DrawNodeHandler = ChatWnd.DrawConversationNodeHandler2,
		};
		local node = ctl.RootNode;
		ctl:Show();
		
		------------------------ inputbox ------------------------
		
		--_this = ParaUI.CreateUIObject("button", "Smiley", "_lt", 12, 2, 24, 24);
		--_this.background = "Texture/Aries/Friends/ChatWnd_Smiley_32bits.png; 0 0 24 24";
		--_inputBox:AddChild(_this);
		--_this = ParaUI.CreateUIObject("button", "SnapShot", "_lt", 40, 2, 32, 24);
		--_this.background = "Texture/Aries/Friends/ChatWnd_ScnChop_32bits.png; 0 0 32 24";
		--_inputBox:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "BG", "_fi", 0, 10, 0, 52);
		_this.background = "Texture/Aries/Friends/chatwnd_input_32bits.png: 15 15 15 15";
		_inputBox:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("imeeditbox", "Input", "_fi", 10, 16, 8, 53);
		_this.background = "";
		_this.onchange = string.format(";MyCompany.Aries.Chat.ChatWnd.OnInputTextChange(%q);", _chatWnd.ID);
		_inputBox:AddChild(_this);
		
		--_this = ParaUI.CreateUIObject("button", "Send", "_rb", -173, -45, 107, 37);
		_this = ParaUI.CreateUIObject("button", "Send", "_rb", -93, -44, 107, 37);
		_this.background = "Texture/Aries/Friends/ChatWnd_Send_32bits.png; 0 0 107 37";
		_this.onclick = string.format(";MyCompany.Aries.Chat.ChatWnd.SendInputMSG(%q);", _chatWnd.ID);
		_inputBox:AddChild(_this);
		--_this = ParaUI.CreateUIObject("button", "InputOption", "_rb", -65, -45, 60, 37);
		--_this.background = "Texture/Aries/Friends/ChatWnd_SendOption_32bits.png; 0 0 60 37";
		--_inputBox:AddChild(_this);
		
		
		local _, __, width, height = _targetAvatar:GetAbsPosition();
		local _targetCanvas = ParaUI.CreateUIObject("container", "TargetCanvas", "_fi", -(height - width)/2, 0, -(height - width)/2, 0);
		_targetCanvas.background = "";
		_targetAvatar:AddChild(_targetCanvas);
		
		local _viewprofile = ParaUI.CreateUIObject("button", "ViewProfile", "_lt", 80, 4, 60, 31);
		_viewprofile.background = "Texture/Aries/Friends/QuickLookProfile_32bits.png;0 0 60 31";
		_viewprofile.onclick = string.format(";MyCompany.Aries.Chat.ChatWnd.ViewProfile(%q);", _chatWnd.ID);
		_viewprofile.zorder = 2;
		_targetCanvas:AddChild(_viewprofile);
		
		-- use pe:avatar to show friend
		local nid = tonumber(System.App.Chat.GetNameFromJID(_chatWnd.ID));
		if(nid) then
			--local textbuffer = "<div width=\"100%\" height=\"100%\"> <pe:avatar miniscenegraphname=\"chatWnd_".._chatWnd.ID.."\" nid=\""..nid.."\"/></div>";
			local textbuffer = [[<div width="100%" height="100%"> <pe:player nid=']]..nid..string.format([[' object="self" name='%s' miniscenegraphname='%s' background="" rendertargetsize="256" IsPortrait=true IsInteractive=false/></div>]], "chatWnd_".._chatWnd.ID, "chatWnd_".._chatWnd.ID);
			local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
			if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
				local xmlRoot = System.mcml.buildclass(xmlRoot);
				mcmlNode = xmlRoot[1];
				local _, __, width, height = _targetCanvas:GetAbsPosition();
				local myLayout = System.mcml_controls.layout:new();
				myLayout:reset(0, 0, width, height);
				System.mcml_controls.create("chatWnd_".._chatWnd.ID, mcmlNode, nil, _targetCanvas, 0, 0, width, height, nil, myLayout);
			end
		end
		
		-- use pe:avatar to show myself portfolio
		local textbuffer = "<div width=\"100%\" height=\"100%\"> <pe:player object=\"self\" miniscenegraphname=\"ChatWnd_Myself\" nid=\"loggedinuser\" IsPortrait=true IsInteractive=false/></div>";
		local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = System.mcml.buildclass(xmlRoot);
			mcmlNode = xmlRoot[1];
			local _, __, width, height = _myself:GetAbsPosition();
			local myLayout = System.mcml_controls.layout:new();
			myLayout:reset(0, 0, width, height);
			System.mcml_controls.create("myself".._chatWnd.ID, mcmlNode, nil, _myself, 0, 0, width, height, nil, myLayout);
		end
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- monitor the keychange, enter to send message
function ChatWnd.OnInputTextChange(ChatWndID)
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		local chatWnd = ChatWnd.GetChatWndByID(ChatWndID);
		if(chatWnd ~= nil) then
			chatWnd:SendMSG();
		end
	end
end

function ChatWnd.SendInputMSG(ChatWndID)
	local chatWnd = ChatWnd.GetChatWndByID(ChatWndID);
	if(chatWnd ~= nil) then
		chatWnd:SendMSG();
	end
end

function ChatWnd.ViewProfile(ChatWndID)
	local chatWnd = ChatWnd.GetChatWndByID(ChatWndID);
	if(chatWnd ~= nil) then
		local k, v;
		for k, v in pairs(chatWnd.JIDs) do
			local nid = string.match(v, "^(%d+)@");
			if(nid) then
				nid = tonumber(nid);
				System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
			end
		end
	end
end

function ChatWnd.DrawConversationNodeHandler(_parent, treeNode)
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
		_this.font = System.DefaultFontFamily..";"..System.DefaultFontSize..";".."bold";
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
			
			MyCompany.Aries.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, treeNode.nid);
			
			_bubble = ParaUI.CreateUIObject("container", "bubble", "_rt", -(textWidth + 40 + 38), 10, textWidth + 40, 22);
			if(lines > 1) then
				_bubble.x = -(nodeWidth - 6 - 32 - 32 - 6 + 38);
				_bubble.width = nodeWidth - 6 - 32 - 32 - 6;
				_bubble.height = 15 * lines + 8;
			end
			_bubble.background = "Texture/Aries/Andy/ChatBubbleRight_32bits.png; 0 0 53 22: 20 8 20 9";
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
			
			MyCompany.Aries.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, treeNode.nid);
			
			_bubble = ParaUI.CreateUIObject("container", "bubble", "_lt", 38, 10, textWidth + 40, 22);
			if(lines > 1) then
				_bubble.width = nodeWidth - 6 - 32 - 32 - 6;
				_bubble.height = 15 * lines + 8;
			end
			_bubble.background = "Texture/Aries/Andy/ChatBubbleLeft_32bits.png; 0 0 53 22: 20 8 20 9";
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


function ChatWnd.DrawConversationNodeHandler2(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return;
	end
	local _this;
	local height = 100; -- just big enough
	local nodeWidth = treeNode.TreeView.ClientWidth;
	local oldNodeHeight = treeNode:GetHeight();
	
	-- added by LXZ 2010.8.27: only pure text allowed.
	local mcmlStr = Encoding.EncodeStr(treeNode.Text);
	
	local mcmlNode;
	if(mcmlStr and treeNode.Text) then
		mcmlStr = mcmlStr:gsub("\n", "<br/>");
		local textbuffer;
		if(treeNode.ifmyself) then
			textbuffer = "<p><pe:name style='float:left;line-height:16px;font-size:14pt;color:#ff6801' />说:<div style=\"float:left;line-height:16px;font-size:14pt;color:#9a9a9a\">"..mcmlStr.."</div></p>";
		elseif(treeNode.nid) then
			textbuffer = "<p><pe:name style='float:left;line-height:16px;font-size:14pt;color:#ff6801' nid='"..Encoding.EncodeStr(tostring(treeNode.nid)).."'/> 说: <div style=\"float:left;line-height:16px;font-size:14pt;color:#1bacd9\">"..mcmlStr.."</div></p>";
		end
		--textbuffer = ParaMisc.EncodingConvert("", "HTML", textbuffer);
		local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
			mcmlNode = xmlRoot[1];
			--mcmlNode:SetAttribute("style", "color:#C8E3F1")
			
			local myLayout = Map3DSystem.mcml_controls.layout:new();
			myLayout:reset(0, 0, nodeWidth, height);
			Map3DSystem.mcml_controls.create("", mcmlNode, nil, _parent, 0, 0, nodeWidth, height, nil, myLayout);
			
			local _, usedHeight = myLayout:GetUsedSize();
			treeNode.NodeHeight = usedHeight - 2;
			
			if(oldNodeHeight ~= treeNode.NodeHeight) then
				return treeNode.NodeHeight;
			end
		end
	end
end