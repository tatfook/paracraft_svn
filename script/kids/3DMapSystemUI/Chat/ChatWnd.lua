--[[
Title: chat window
Author(s): WangTian
Date: 2007/10/14
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

-- constructor
function Map3DSystem.UI.Chat.ChatWnd:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.Chat.ChatWnd:show(bShow)
	if(not self.wndName) then
		log("error: window frame object not inited.\n");
	end
	
	local _appName = self.appName;
	local _wndName = self.wndName;
	
	local _document = Map3DSystem.UI.Windows.GetWindowFrameDocument(_appName, _wndName);
	
	if(bShow == nil) then
		bShow = not _document.visible;
	end
	
	if(bShow == true) then
		Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	else
		Map3DSystem.UI.Windows.ShowWindow(false, _appName, _wndName);
	end
end

-- init the ChatWnd UI
function Map3DSystem.UI.Chat.ChatWnd:InitUI(parent)
	
	if(parent:GetChild(self.wndName.."_cont"):IsValid() == true) then
		-- TODO: tricky problem: this function is called twice
		-- inited
		return;
	end
	
	if(parent:IsValid() == true) then
		
		--parent.background = "";
		
		_this = ParaUI.CreateUIObject("container", self.wndName.."_cont", "_fi", 0, 0, 0, 0);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_this.background = "";
		parent:AddChild(_this);
		
		local _parent = _this;
		
		_this = ParaUI.CreateUIObject("container", "btnTopIcon_BG", "_lt", 16, -42, 36, 36);
		_this.background = "Texture/3DMapSystem/IM/ChatWndIconFrame.png: 4 4 4 4";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnTopIcon", "_lt", 18, -40, 32, 32)
		--_this.text = "icon";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 70, -40, 315, 14)
		_this.text = self.wndName;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 70, -22, 315, 12)
		_this.text = string.format("<%s>", self.wndName);
		_this:GetFont("text").color = "128 128 128";
		_parent:AddChild(_this);

		--_this = ParaUI.CreateUIObject("button", "btnReceiverIcon", "_rt", -73, 44, 64, 64)
		--_this.text = "";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "btnMyIcon", "_rb", -73, -111, 64, 64)
		--_this.text = "button1";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "btnReceiverMenu", "_rt", -33, 110, 24, 24)
		--_this.text = ">";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "button1", "_rb", -33, -45, 24, 24)
		--_this.text = ">";
		--_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnActionList", "_lb", 4, -111, 32, 32)
		_this.tooltip = "Actions";
		_this.background = "Texture/3DMapSystem/IM/Action.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnShakeScreen", "_lb", 42, -111, 32, 32)
		_this.tooltip = "Shake";
		_this.background = "Texture/3DMapSystem/IM/Shake.png";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnSendMyLocation", "_lb", 80, -111, 32, 32)
		_this.tooltip = "Invite";
		_this.background = "Texture/3DMapSystem/IM/Invite.png";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnJoin", "_lb", 118, -111, 32, 32)
		_this.tooltip = "join";
		_this.background = "Texture/3DMapSystem/IM/Join.png";
		_this.onclick = string.format(";Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_JOIN_JGSL, jid=%q})", self.wndName);
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "TreeViewChatDisplay_BG", "_fi", 4, 2, 4, 117);
		_this.enable = false;
		_this.background = "Texture/3DMapSystem/IM/ChatDisplay_BG.png: 10 10 10 10";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = self.wndName.."_treeViewChatDisplay",
			alignment = "_fi",
			left = 4,
			top = 10,
			width = 10,
			height = 123,
			parent = _parent,
			container_bg = "",
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
			DrawNodeHandler = Map3DSystem.UI.Chat.ChatWnd.DrawContactNodeHandler,
		};
		local node = ctl.RootNode;
		ctl:Show();
		
		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = self.wndName.."_textBoxChatSendText",
			alignment = "_mb",
			left = 4,
			top = 0,
			width = 56,
			height = 72,
			parent = _parent,
			container_bg = "Texture/3DMapSystem/IM/SendBox_BG.png: 7 7 18 20",
			--main_bg = "",
			
			--editbox_bg = "Texture/3DMapSystem/IM/white80opacity.png",
			--line_count = 3,
			--line_height = 24,
			--line_spacing = 0,
		};
		ctl:Show(true);
		
		local cont = ParaUI.GetUIObject(self.wndName.."_textBoxChatSendText");
		cont:BringToFront();
		
		-- send button
		_this = ParaUI.CreateUIObject("button", "btnSend", "_rb", -56, -70, 48, 32)
		_this.text = "send";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
		_this.onclick=string.format([[;Map3DSystem.UI.Chat.ChatWnd.OnSendMessage_static("%s");]],self.wndName);
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "btnUserIcon_BG", "_rb", -50, -30, 34, 34);
		_this.background = "Texture/3DMapSystem/IM/ChatWndIconFrame.png: 4 4 4 4";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("container", "btnUserIcon", "_rb", -48, -28, 32, 32);
		_this.background = "Texture/3DMapSystem/IM/online.png";
		_parent:AddChild(_this);
	else
		log("error: parent container not inited in ChatWnd:InitUI() call.\n");
	end
end

-- chat window chatting history treeview owner draw function
function Map3DSystem.UI.Chat.ChatWnd.DrawContactNodeHandler(_parent, treeNode)
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
		_this = ParaUI.CreateUIObject("text", "header", "_mt", 10, -5, 0, height);
		_this.text = treeNode.Text;
		_this:GetFont("text").color = treeNode.color;
		_this.font = "myriad pro;18;bold;true";
		_parent:AddChild(_this);
	elseif(treeNode.type == "message") then
		-- render contact message TreeNode: a text and a time tag
		width = 24 -- check box width
		--_this = ParaUI.CreateUIObject("container", "message_BG", "_fi", 0, 0, 0, 0);
		--_this.background = "Texture/3DMapSystem/IM/white80opacity.png";
		--_this.enable = false;
		--_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", "message", "_mt", 20, 0, 40, height);
		_this.text = treeNode.Text;
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", "message_time", "_rt", -40, 0, 40, height);
		_this.text = ParaGlobal.GetTimeFormat("H:m");
		_this:GetFont("text").color = "128 128 128";
		_parent:AddChild(_this);
	end
end

-- chat window message procedure
function Map3DSystem.UI.Chat.ChatWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		if(DEBUG_CHAT) then
			_guihelper.MessageBox("ChatWnd recv MSG WM_CLOSE.\n");
		end
		-- TODO: real close that window object
		Map3DSystem.UI.Chat.MainWnd.RemoveChattingTab(window.name);
		Map3DSystem.UI.Chat.ChatWnd.OnCloseWindow(msg.fromWndName);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		local ctl = CommonCtrl.GetControl(window.name.."_treeViewChatDisplay");
		ctl:Update(true);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		if(DEBUG_CHAT) then
			_guihelper.MessageBox("ChatWnd recv MSG WM_MINIMIZE.\n");
			Map3DSystem.UI.Windows.ShowWindow(false, "Chat", msg.fromWndName);
		end
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		if(DEBUG_CHAT) then
			_guihelper.MessageBox("ChatWnd recv MSG WM_HIDE.\n");
		end
		--Map3DSystem.UI.Chat.HideAll();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		if(DEBUG_CHAT) then
			_guihelper.MessageBox("ChatWnd recv MSG WM_SHOW.\n");
		end
		--Map3DSystem.UI.Chat.ShowAll();
		--Map3DSystem.UI.Chat.IsShow = true;
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_TOGGLE) then
		if(DEBUG_CHAT) then
			_guihelper.MessageBox("ChatWnd recv MSG WM_TOGGLE.\n");
		end
		Map3DSystem.UI.Windows.ShowWindow(nil, "Chat", msg.fromWndName);
	end
end

-- get the window frame according to the user JID
-- @ sJID: user JID
function Map3DSystem.UI.Chat.ChatWnd.GetWindowFrame(sJID)
	
	local _mainWnd = Map3DSystem.UI.Chat.MainWndObj;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_mainWnd.app.name, sJID);
	if(_frame) then
		-- window frame already exists
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_"..sJID.."_window_document");
	else
		-- window frame not exists, create new one
		NPL.load("(gl)script/ide/os.lua");
		local _app = CommonCtrl.os.CreateGetApp("Chat");
		local _wnd = _app:RegisterWindow(sJID, nil, Map3DSystem.UI.Chat.ChatWnd.MSGProc);
		
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			mainBarIconSetID = 13, -- or nil
			icon = "",
			iconSize = 48,
			text = "",
			style = Map3DSystem.UI.Windows.Style[4],
			maximumSizeX = 700,
			maximumSizeY = 500,
			minimumSizeX = 300,
			minimumSizeY = 300,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = true,
			isShowMinimizeBox = true,
			isShowAutoHideBox = true,
			allowDrag = true,
			allowResize = true,
			initialPosX = 200,
			initialPosY = 200,
			initialWidth = 400,
			initialHeight = 400,
			
			ShowUICallback = Map3DSystem.UI.Chat.ChatWnd.ShowUI,
		};
		
		local nCount = Map3DSystem.UI.Chat.ChatWnd.CreationCount;
		
		if(nCount >= 0 and nCount <= 3) then
			param.initialPosX = 100 + nCount * 50;
			param.initialPosY = 200 + nCount * 50;
			Map3DSystem.UI.Chat.ChatWnd.CreationCount = nCount + 1;
		elseif(nCount >= 4 and nCount <= 7) then
			param.initialPosX = 200 + (nCount - 4) * 50;
			param.initialPosY = 200 + (nCount - 4) * 50;
			Map3DSystem.UI.Chat.ChatWnd.CreationCount = nCount + 1;
		elseif(nCount >= 8 and nCount <= 11) then
			param.initialPosX = 200 + (nCount - 8) * 50;
			param.initialPosY = 100 + (nCount - 8) * 50;
			if(nCount == 11) then
				Map3DSystem.UI.Chat.ChatWnd.CreationCount = 0;
			else
				Map3DSystem.UI.Chat.ChatWnd.CreationCount = nCount + 1;
			end
		end
		
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		-- TODO: should register window frame be default hiden?
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
		
		Map3DSystem.UI.Chat.MainWnd.AddChattingTab(sJID);
		
		--_frame.ChatWnd = {};
		--_frame.ChatWnd.wndName = _frame.wnd.name; -- TODO: dirty get window object
		--_frame.ChatWnd.appName = _frame.wnd.app.name; -- TODO: dirty get application object
		--Map3DSystem.UI.Chat.ChatWnd:new(_frame.ChatWnd);
		--_frame.ChatWnd:InitUI(_document);
	end
	
	return _frame.ChatWnd;
end

-- show ui function of the chat window
-- @param bShow: true or false
-- @param parentUI: parent UI contain object
-- @param parentWindow: parent os window object
function Map3DSystem.UI.Chat.ChatWnd.ShowUI(bShow, parentUI, parentWindow)
	
	local _wndName = parentWindow.name; -- TODO: dirty get window object
	local _appName = parentWindow.app.name; -- TODO: dirty get application object
	local _frame = Map3DSystem.UI.Windows.GetWindowFrame(_appName, _wndName)
	_frame.ChatWnd = {};
	_frame.ChatWnd.wndName = parentWindow.name; -- TODO: dirty get window object
	_frame.ChatWnd.appName = parentWindow.app.name; -- TODO: dirty get application object
	Map3DSystem.UI.Chat.ChatWnd:new(_frame.ChatWnd);
	_frame.ChatWnd:InitUI(parentUI);
end

-- close callback function of the chat window
function Map3DSystem.UI.Chat.ChatWnd.OnCloseWindow(sJID)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _mainWnd = Map3DSystem.UI.Chat.MainWndObj;
	local _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_mainWnd.app.name, sJID);
	_frame.ChatWnd:OnClose();
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp(_mainWnd.name);
	local _wnd = _app:UnRegisterWindow(_frame.wnd.name);
	Map3DSystem.UI.Windows.UnRegisterWindowFrame(_mainWnd.app.name, sJID);
	_frame = nil;
end

-- close the chat windows
function Map3DSystem.UI.Chat.ChatWnd:OnClose()
	local _wndName = self.wndName;
	local _appName = self.appName;
	
	log("ChatWnd:OnCloseWindow(), ".._wndName.." ".._appName.." \n");
end

-- add a line of text to the chat history
-- @param from: the name of the user
-- @param subject: nil
-- @param body: the message body
function Map3DSystem.UI.Chat.ChatWnd:AddTextToChatHistory(from, subject, body)
	local ctl = CommonCtrl.GetControl(self.wndName.."_treeViewChatDisplay");
	if(ctl==nil)then
		log("error: getting ChatWnd instance: "..self.wndName.."_treeViewChatDisplay".."\r\n");
		return;
	end
	if(Map3DSystem.UI.Chat.ChatWnd.LastMessageSpeaker[self.wndName] ~= tostring(from)) then
		Map3DSystem.UI.Chat.ChatWnd.LastMessageSpeaker[self.wndName] = tostring(from);
		local headerColor;
		if(tostring(from) == "我") then
			headerColor = "234 202 53";
		else
			headerColor = "150 212 68";
		end
		local _text;
		local _atTag = string.find(tostring(from), "@");
		if(_atTag) then
			_text = string.sub(tostring(from), 0, _atTag - 1);
		else
			_text = tostring(from);
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = _text, type = "header", color = headerColor}));
	end
	ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = tostring(body), type = "message"}));
	ctl:Update(true); -- true to scroll to last element.
	
	if(tostring(from) == "我") then
		headon_speech.Speek("<player>", tostring(body), 3);
	else
		headon_speech.Speek(tostring(from), tostring(body), 3);
	end
end

-- called when received a message from server
-- @param from: the name of the user
-- @param subject: nil
-- @param body: the message body
function Map3DSystem.UI.Chat.ChatWnd:OnReceiveMessage(from, subject, body)
	-- TODO: fix more function here
	-- TODO: get chat window
	-- TODO: show according to Chat isShow
	self:AddTextToChatHistory(from, subject, body);
end

-- called to send a message 
-- @param to: JID
-- @param body: the message body
function Map3DSystem.UI.Chat.ChatWnd:SendChatMessage(to, body)
	local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	if(jc~=nil) then
		self:AddTextToChatHistory("我", nil, body)
		jc:Message(to, body);
		
		-- TODO: debug purpose
		Map3DSystem.UI.Chat.LastSendContact = to;
		--jc:activate(to..":script/kids/3DMapSystemUI/Chat/ChatWnd.lua", {body="jabber NPL message", sendername="tester"});
	end
end

-- update the contact status of the given user
-- @param sJID: given user JID
-- @param status: online status
-- @param personalMSG: personal message
function Map3DSystem.UI.Chat.ChatWnd.UpdateContactStatus(sJID, status, personalMSG)
	local _document = Map3DSystem.UI.Chat.ChatWnd.GetWindowFrameDocument(sJID);
	if(_document:IsValid()) then
		local _cont = _document:GetChild(sJID.."_cont");
		local _icon = _cont:GetChild("btnTopIcon");
		local _label1 = _cont:GetChild("label1");
		local _label2 = _cont:GetChild("label2");
		local _name = Map3DSystem.UI.Chat.MainWnd.GetNameFromJID(sJID);
		_label1.text = _name.." - "..personalMSG;
		_label2.text = "<"..sJID..">";
		
		if(status == "online") then
			_icon.background = "Texture/3DMapSystem/IM/online.png";
		elseif(status == "dnd") then
			_icon.background = "Texture/3DMapSystem/IM/busy.png";
		elseif(status == "xa") then
			_icon.background = "Texture/3DMapSystem/IM/away.png";
		elseif(status == "chat") then
			_icon.background = "Texture/3DMapSystem/IM/chatty.png";
		elseif(status == "offline") then
			_icon.background = "Texture/3DMapSystem/IM/offline.png";
		end
	end
end

-- get the document window UI object of the given user
-- @param sJID: given user JID
function Map3DSystem.UI.Chat.ChatWnd.GetWindowFrameDocument(sJID)
	local _mainWnd = Map3DSystem.UI.Chat.MainWndObj;
	return Map3DSystem.UI.Windows.GetWindowFrameDocument(_mainWnd.app.name, sJID);
end

-- static function
-- send message in the textBox of the chat window
function Map3DSystem.UI.Chat.ChatWnd.OnSendMessage_static(sJID)

	local self = Map3DSystem.UI.Chat.ChatWnd.GetWindowFrame(sJID);
	if(self == nil)then
		log("error getting ChatWnd instance: "..sJID.."\r\n");
		return;
	end
	
	-- get text
	local ctl = CommonCtrl.GetControl(self.wndName.."_textBoxChatSendText");
	if(ctl == nil)then
		log("error getting ChatWnd instance: "..self.name.."_textBoxChatSendText".."\r\n");
		return;
	end
	
	local text = ctl:GetText();
	ctl:SetText("");
	if(text ~= "") then
		-- send text if not empty string
		self:SendChatMessage(tostring(sJID), text);
	end
end


-- TODO: what the hell is this?
-- main activation function
local function activate()
	if(msg.body~=nil) then
		-- testing NPL jabber activation using the same syntax as NPL.activate();
		_guihelper.MessageBox((msg.sendername or "未知").." activation via jabber: "..tostring(msg.body).."\n");
	end
end

NPL.this(activate);