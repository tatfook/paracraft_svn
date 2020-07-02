--[[
Title: chat in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the chat window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Chat.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

-- on main bar "Chat" icon click
-- main bar chat icon onclick
-- including:
--		1. init the chat system (one time init)
--		2. forward click will show and hide all the chat windows including the chat main window
function Map3DSystem.UI.Chat.OnClick()
	
	if(Map3DSystem.UI.Chat.IsInit == false) then
		-- TODO: currently we init the chat system on chat first click
		-- TODO: should be inited at startup
		if(Map3DSystem.UI.Chat.OneTimeInit()) then
			Map3DSystem.UI.Chat.IsInit = true;
		end
	end
	
	if(Map3DSystem.UI.Windows.WndSet["Chat"] == nil) then
		Map3DSystem.UI.Chat.InitMainWndObject();
	end
	
	-- toggle show/hide all chat windows
	Map3DSystem.UI.Chat.IsShow = not Map3DSystem.UI.Chat.IsShow;
	if(Map3DSystem.UI.Chat.IsShow) then
		Map3DSystem.UI.Chat.ShowAll()
	else
		Map3DSystem.UI.Chat.HideAll()
	end
end

-- one time initialize to chat system
-- including:
--		1. init the jabber instant messanger
--		2. init window object(main wnd)
--		3. use the register frame to show main window UI
function Map3DSystem.UI.Chat.OneTimeInit()
	-- init the jabber client
	--Map3DSystem.UI.Chat.InitIM("LiXizhi", "1234567", "paraweb3d.com");
	
	--chatdomain = "192.168.198.128"
	
	
	--Map3DSystem.UI.Chat.InitIM(Map3DSystem.User.Name, Map3DSystem.User.Password, Map3DSystem.User.ChatDomain);
	
	Map3DSystem.UI.Chat.InitIM(Map3DSystem.User.Name, Map3DSystem.User.Password, paraworld.TranslateURL("%CHATDOMAIN%"));
	
	
	-- init the main window object
	local _appName, _wndName, _document, _frame;
	_appName, _wndName, _document, _frame = Map3DSystem.UI.Chat.InitMainWndObject();
	
	---- init the main window UI
	--NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd.lua");
	--Map3DSystem.UI.Chat.MainWnd.ShowMainWndUI(true, _document, _frame.wnd);
	
	NPL.load("(gl)script/ide/commonlib.lua");
	Map3DSystem.UI.Chat.JIDList = commonlib.LoadTableFromFile("History/JIDList.ini") or Map3DSystem.UI.Chat.JIDList;
	Map3DSystem.UI.Chat.RosterHistory = commonlib.LoadTableFromFile("History/RosterHistory.ini") or Map3DSystem.UI.Chat.RosterHistory;
	
	---- init the history object
	--_appName, _wndName, _document, _frame = Map3DSystem.UI.Chat.InitHistoryWndObject();
	---- init the history window UI
	--NPL.load("(gl)script/kids/3DMapSystemUI/Chat/HistoryWnd.lua");
	--Map3DSystem.UI.Chat.HistoryWnd.ShowUI(true, _document, _frame.wnd);
	
	return true;
end

-- get default jabber client, create if not exist
function Map3DSystem.UI.Chat.GetClient()
	return JabberClientManager.CreateJabberClient(Map3DSystem.UI.Chat.JabberClientName);
end

-- get the currently connected client. return nil, if connection is not valid
function Map3DSystem.UI.Chat.GetConnectedClient()
	local jc = Map3DSystem.UI.Chat.GetClient();
	if(jc:IsValid() and jc:GetIsAuthenticated()) then
		return jc;
	end
end


--------------------------------------
-- TODO: improve the persistency, currently the chat functions are reset
--------------------------------------

function Map3DSystem.UI.Chat.EnterScene()
	Map3DSystem.UI.Windows.WndSet["Chat"] = nil;
	NPL.load("(gl)script/ide/os.lua");
	CommonCtrl.os.DestroyApp("Chat");
	Map3DSystem.UI.Chat.MainWndObj = nil;
	--local jc = Map3DSystem.UI.Chat.GetClient();
	--jc:Close();
	Map3DSystem.UI.Chat.LastConnectionTime = 0;
	Map3DSystem.UI.Chat.IsInit = false;
	Map3DSystem.UI.Chat.IsShow = false;
	Map3DSystem.UI.Map.IsShow = false;
end

-- init the main window object
-- including:
--		1. create application "Chat"
--		2. create main window "MainWindow" to app "Chat"
--		3. register window frame for "MainWindow"
function Map3DSystem.UI.Chat.InitMainWndObject()
	
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("Chat");
	local _wnd = _app:RegisterWindow("MainWindow", nil, Map3DSystem.UI.Chat.MSGProc);
	
	Map3DSystem.UI.Chat.MainWndObj = _wnd;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local param = {
		wnd = _wnd,
		--isUseUI = true,
		mainBarIconSetID = 13, -- or nil
		icon = Map3DSystem.UI.MainBar.IconSet[13].NormalIconPath,
		iconSize = 48,
		text = "", -- TODO: naming
		style = Map3DSystem.UI.Windows.Style[3],
		maximumSizeX = 260,
		maximumSizeY = 700,
		minimumSizeX = 260,
		minimumSizeY = 300,
		isShowIcon = true,
		--opacity = 100, -- [0, 100]
		isShowMaximizeBox = true,
		isShowMinimizeBox = true,
		isShowAutoHideBox = true,
		allowDrag = true,
		allowResize = true,
		initialPosX = 700,
		initialPosY = 100,
		initialWidth = 260,
		initialHeight = 500,
		
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd.lua");
		ShowUICallback = Map3DSystem.UI.Chat.MainWnd.ShowMainWndUI,
	};
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		
	return Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	
	--Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	--
	--NPL.load("(gl)script/network/IM_Main.lua");
	--IM_Main.Show(true, _document, _frame.wnd);
end

-- init the history window object
-- including:
--		1. create application "Chat"
--		2. create history window "HistoryWindow" to app "Chat"
--		3. register window frame for "HistoryWindow"
function Map3DSystem.UI.Chat.InitHistoryWndObject()

	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("Chat");
	local _wnd = _app:RegisterWindow("HistoryWindow", nil, nil);
	
	Map3DSystem.UI.Chat.HistoryWnd = _wnd;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local param = {
		wnd = _wnd,
		--isUseUI = true,
		mainBarIconSetID = 13, -- or nil
		icon = Map3DSystem.UI.MainBar.IconSet[13].NormalIconPath,
		iconSize = 48,
		text = "ParaWorld Chat History", -- TODO: naming
		style = Map3DSystem.UI.Windows.Style[1],
		maximumSizeX = 700,
		maximumSizeY = 700,
		minimumSizeX = 300,
		minimumSizeY = 300,
		isShowIcon = true,
		--opacity = 100, -- [0, 100]
		isShowMaximizeBox = true,
		isShowMinimizeBox = true,
		isShowAutoHideBox = true,
		allowDrag = true,
		allowResize = true,
		initialPosX = 50,
		initialPosY = 50,
		initialWidth = 600,
		initialHeight = 500,
		
		ShowUICallback = Map3DSystem.UI.Chat.MainWnd.ShowMainWndUI, -- NOTE: show UI callback function
	};
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	return Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	
	--Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	--
	--NPL.load("(gl)script/network/IM_Main.lua");
	--IM_Main.Show(true, _document, _frame.wnd);
end

-- initiate the instant messager client
-- such as Map3DSystem.UI.Chat.InitIM("LiXizhi", "1234567", "paraweb3d.com")
function Map3DSystem.UI.Chat.InitIM(username, password, servername)
	local jc = Map3DSystem.UI.Chat.GetClient();
	if(jc:IsValid()) then
		if(not jc:GetIsAuthenticated()) then
			if((ParaGlobal.timeGetTime() - Map3DSystem.UI.Chat.LastConnectionTime)> 20000) then
				Map3DSystem.UI.Chat.LastConnectionTime = ParaGlobal.timeGetTime();
				jc.User = username;
				jc.Password = password;
				jc.Server = servername;
				Map3DSystem.UI.Chat.UserJID = string.lower(username.."@"..servername);
				jc:ResetAllEventListeners();
				-- bind event to map 3d system chat
				jc:AddEventListener(Jabber_Event.Jabber_OnPresence, "Map3DSystem.UI.Chat.Jabber_OnPresence()");
				jc:AddEventListener(Jabber_Event.Jabber_OnError, "Map3DSystem.UI.Chat.Jabber_OnError()");
				jc:AddEventListener(Jabber_Event.Jabber_OnRegistered, "Map3DSystem.UI.Chat.Jabber_OnRegistered()");
				jc:AddEventListener(Jabber_Event.Jabber_OnMessage, "Map3DSystem.UI.Chat.Jabber_OnMessage()");
				jc:AddEventListener(Jabber_Event.Jabber_OnConnect, "Map3DSystem.UI.Chat.Jabber_OnConnect()");
				jc:AddEventListener(Jabber_Event.Jabber_OnAuthenticate, "Map3DSystem.UI.Chat.Jabber_OnAuthenticate()");
				jc:AddEventListener(Jabber_Event.Jabber_OnDisconnect, "Map3DSystem.UI.Chat.Jabber_OnDisconnect()");
				jc:AddEventListener(Jabber_Event.Jabber_OnRosterBegin, "Map3DSystem.UI.Chat.Jabber_OnRosterBegin()");
				jc:AddEventListener(Jabber_Event.Jabber_OnRosterItem, "Map3DSystem.UI.Chat.Jabber_OnRosterItem()");
				jc:AddEventListener(Jabber_Event.Jabber_OnRosterEnd, "Map3DSystem.UI.Chat.Jabber_OnRosterEnd()");
				jc:AddEventListener(Jabber_Event.Jabber_OnAuthError, "Map3DSystem.UI.Chat.Jabber_OnAuthError()");
				
				jc:AddEventListener(Jabber_Event.Jabber_OnSubscription, "Map3DSystem.UI.Chat.Jabber_OnSubscription()");
				jc:AddEventListener(Jabber_Event.Jabber_OnUnsubscription, "Map3DSystem.UI.Chat.Jabber_OnUnsubscription()");
				
				-- NOTE: added by Andy: 2008-4-12
				jc.PlaintextAuth = true;
				
				jc:Connect();
				
				-- TODO: Update to new main bar user draw implementation
				--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = 13, isLooping = true, isAnimate = true});
			else
				_guihelper.MessageBox("正在连接...请稍候再试");
			end	
		else
			_guihelper.MessageBox("已经连接了 "..jc.User..jc.Server);
		end	
	end
end

function Map3DSystem.UI.Chat.OnExit()
	NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	Map3DSystem.Misc.SaveTableToFile(Map3DSystem.UI.Chat.JIDList, "History/JIDList.ini");
	Map3DSystem.Misc.SaveTableToFile(Map3DSystem.UI.Chat.RosterHistory, "History/RosterHistory.ini");
end

function Map3DSystem.UI.Chat.ShowAll()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.ShowApplication(Map3DSystem.UI.Chat.MainWndObj.app.name);
end

function Map3DSystem.UI.Chat.HideAll()

	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.HideApplication(Map3DSystem.UI.Chat.MainWndObj.app.name);
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	--Map3DSystem.UI.Windows.HideAllInCategory(10);
end

DEBUG_CHAT = false;

-- send a message to Chat:ChatWndObject window handler
-- e.g. Map3DSystem.UI.Chat.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_Show})
function Map3DSystem.UI.Chat.SendMeMessage(msg)
	if(Map3DSystem.UI.Chat.MainWndObj == nil) then
		log("warning: Map3DSystem.UI.Chat.MainWndObj nil. please init the chat first\n");
		
		if(msg.type == Map3DSystem.msg.CHAT_EasyTalkPanel) then
			-- TODO: some easy talk panel
			Map3DSystem.UI.Chat.ShowEasyTalkPanel();
		end
	else
		msg.wndName = Map3DSystem.UI.Chat.MainWndObj.name;
		Map3DSystem.UI.Chat.MainWndObj.app:SendMessage(msg);
	end
end

function Map3DSystem.UI.Chat.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		if(DEBUG_CHAT) then
			log("ChatWnd recv MSG WM_CLOSE.\n");
		end
		Map3DSystem.UI.Chat.HideAll();
		Map3DSystem.UI.Chat.IsShow = false;
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		if(DEBUG_CHAT) then
			log("ChatWnd recv MSG WM_SIZE.\n");
		end
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		if(DEBUG_CHAT) then
			log("ChatWnd recv MSG WM_HIDE.\n");
		end
		Map3DSystem.UI.Chat.HideAll();
		Map3DSystem.UI.Chat.IsShow = false;
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		if(DEBUG_CHAT) then
			log("ChatWnd recv MSG WM_SHOW.\n");
		end
		Map3DSystem.UI.Chat.ShowAll();
		Map3DSystem.UI.Chat.IsShow = true;
		
	elseif(msg.type == Map3DSystem.msg.CHAT_EasyTalkPanel) then
		if(DEBUG_CHAT) then
			log("ChatWnd recv MSG CHAT_EasyTalkPanel.\n");
		end
		
		-- TODO: some easy talk panel
		Map3DSystem.UI.Chat.ShowEasyTalkPanel();
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CHAT) then
		-- Do your code
		
		-- TODO: MSGProc ONLY listen to OnPresence and OnMessage message type
		
		if(msg.param1 == "OnPresence") then
			if(DEBUG_CHAT) then
				log("OnPresence: from:"..msg.param2.." presenceType:"..msg.param3.."\n");
			end
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd.lua");
			Map3DSystem.UI.Chat.MainWnd.UpdateContactList();
			-- TODO: update contact list
		elseif(msg.param1 == "OnError") then
			if(DEBUG_CHAT) then
				log("OnError: msg:"..msg.param2.."\n");
				NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
				Map3DSystem.Misc.SaveTableToFile(msg, "TestTable/MSG.ini");
				local nStr = string.find(msg.param2,"Bad host");
				if(nStr ~= nil) then
					log("bad host"..nStr.."\n");
					Map3DSystem.UI.Chat.MainWnd.UpdateContactList();
				end
			end
		elseif(msg.param1 == "OnRegistered") then
			if(DEBUG_CHAT) then
				log("OnRegistered\n");
			end
		elseif(msg.param1 == "OnMessage") then
			if(DEBUG_CHAT) then
				log("OnMessage: JID:"..msg.param2.." subject:"..msg.param3.." body:"..msg.param4.."\n");
			end
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd.lua");
			local chatWnd = Map3DSystem.UI.Chat.ChatWnd.GetWindowFrame(msg.param2);
			if(chatWnd~=nil) then
				chatWnd:show(true);
				chatWnd:OnReceiveMessage(msg.param2, msg.param3, msg.param4);
			end
		elseif(msg.param1 == "OnConnect") then
			if(DEBUG_CHAT) then
				log("OnConnect\n");
			end
		elseif(msg.param1 == "OnAuthError") then
			if(DEBUG_CHAT) then
				log("OnAuthError\n");
			end
			
			-- TODO: Update to new main bar user draw implementation
			--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = 13, isLooping = true, isAnimate = false});
			
		elseif(msg.param1 == "OnAuthenticate") then
			if(DEBUG_CHAT) then
				log("OnAuthenticate\n");
			end
			-- TODO: update user status to "online"
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("online");
			-- TODO: send personal message
			Map3DSystem.UI.Chat.MainWnd.SetUserPersonalMSG("AndyTestingPersonalMSG", true);
			-- TODO: save the personal message on exit
			
			
			-- TODO: Update to new main bar user draw implementation
			--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = 13, isLooping = true, isAnimate = false});
			
		elseif(msg.param1 == "OnRosterBegin") then
			if(DEBUG_CHAT) then
				log("OnRosterBegin\n");
			end
			Map3DSystem.UI.Chat.RosterBegin = true;
		elseif(msg.param1 == "OnRosterItem") then
			if(DEBUG_CHAT) then
				log("OnRosterItem:\n");
				--log("    Subscription"..msg.Subscription.." JID:"..msg.JID.."\n");
			end
			
			--msg = {
			--	Subscription = number, -- 0(to), 1(from), 2(both), 3(none), 4(remove)
			--	JID = string, -- jabber ID
			--}
			Map3DSystem.UI.Chat.MainWnd.UpdateContactList();
		elseif(msg.param1 == "OnRosterEnd") then
			if(DEBUG_CHAT) then
				log("OnRosterEnd\n");
			end
			Map3DSystem.UI.Chat.RosterBegin = nil;
			Map3DSystem.UI.Chat.MainWnd.UpdateContactList();
			-- TODO: update contact list
		elseif(msg.param1 == "OnDisconnect") then
			if(DEBUG_CHAT) then
				log("OnDisconnect\n");
			end
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("offline");
			-- TODO: update user status to "offline"
			
			
			-- TODO: Update to new main bar user draw implementation
			--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = 13, isLooping = true, isAnimate = false});
			
		elseif(msg.param1 == "OnSubscription") then
			_guihelper.MessageBox("一个新用户"..tostring(msg.param2).."订阅了您。是否接受?\n");
			-- TODO: We should send a CHAT_SUBSCRIBE message to add. Here I just hard code everything here. 
			-- automatically accept.
			local jc = Map3DSystem.UI.Chat.GetConnectedClient();
			if(jc~=nil) then
				-- allow subscription
				jc:AllowSubscription(tostring(msg.param2), true);
				-- auto subscribe to it
				jc:Subscribe(tostring(msg.param2), tostring(msg.param2), "general");
			end	
			
		elseif(msg.param1 == "OnUnsubscription") then
			_guihelper.MessageBox("用户"..tostring(msg.param2).."将你移出了它的通讯列表\n");
			--jc:RemoveRosterItem(tostring(msg.param2));
		end
	end
end

function Map3DSystem.UI.Chat.ShowEasyTalkPanel(bShow)
	local _this;
	local _parent;
	
	_this = ParaUI.GetUIObject("EasyTalkPanel");
	if(_this:IsValid()) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		_this:GetChild("editBox"):Focus();
	else
		if(bShow == false) then return; end
		
		_this = ParaUI.CreateUIObject("container", "EasyTalkPanel", "_ctb", 0, -64, 450, 96);
		--_this.background = "";
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("container", "chaticon", "_lt", 10, -35, 48, 48);
		_this.background = "Texture/3DMapSystem/MainBarIcon/Chat.png; 0 0 48 48";
		_this.enable = false;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "ISay", "_lt", 20, 20, 50, 32);
		--_this.background = "";
		_this.text = "我对";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "talktodropdownlistbox",
			alignment = "_lt",
			left = 55,
			top = 17,
			width = 180,
			height = 24,
			dropdownheight = 72,
 			parent = _parent,
			text = "上一个联系人",
			items = {"最近的5个人", "当前选中的人", "上一个联系人", "一定范围内的人",},
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("button", "Invite", "_lt", 260, 17, 48, 24);
		--_this.background = "";
		_this.text = "邀请";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Map", "_lt", 315, 17, 48, 24);
		--_this.background = "";
		_this.text = "地图";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Trade", "_lt", 370, 17, 48, 24);
		--_this.background = "";
		_this.text = "交易";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Close", "_rt", -24, 8, 16, 16);
		--_this.background = "";
		_this.text = "×";
		_this.onclick = [[;ParaUI.GetUIObject("EasyTalkPanel").visible = false;]];
		_parent:AddChild(_this);
		
		
		_this = ParaUI.CreateUIObject("editbox", "editBox", "_lt", 20, 50, 300, 24);
		--_this.background = "";
		_this.text = "";
		_this.onchange = ";Map3DSystem.UI.Chat.OnChangeEasyTalkEditBox();";
		_this:Focus();
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "send", "_lt", 325, 50, 48, 24);
		--_this.background = "";
		_this.text = "发送";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "action", "_rt", -60, 50, 48, 24);
		--_this.background = "";
		_this.text = "动作";
		_parent:AddChild(_this);
		
		--_this = ParaUI.CreateUIObject("container", "EasyTalkPanel", "_ctb", 0, 64, 400, 96)
		--_this.background = "";
		--_parent:AddChild(_this);
	end
end

function Map3DSystem.UI.Chat.OnChangeEasyTalkEditBox()
	if(virtual_key == Event_Mapping.EM_KEY_RETURN) then
		
		local _quickLaunch = ParaUI.GetUIObject("EasyTalkPanel");
		local _edit = _quickLaunch:GetChild("editBox");
		
		local ctl = CommonCtrl.GetControl("talktodropdownlistbox");
		local _text = ctl:GetText();
		
		if(_edit.text == "") then
			-- TODO: UI error the editbox didn't get the return key when editbox is empty
			_quickLaunch.visible = false;
			return;
		end
		
		if(_text == "最近的5个人") then
		elseif(_text == "当前选中的人") then
		elseif(_text == "上一个联系人") then
			if(Map3DSystem.UI.Chat.LastSendContact ~= nil) then
				local sJID = Map3DSystem.UI.Chat.LastSendContact;
				Map3DSystem.UI.Windows.GetWindowFrame("Chat", sJID).ChatWnd:SendChatMessage(sJID, _edit.text);
			else
				log("Map3DSystem.UI.Chat.LastSendContact is nil\n");
			end
		elseif(_text == "一定范围内的人") then
		end
		
		-- send the message: _edit.text
		
		_edit.text = "";
	end
end

function Map3DSystem.UI.Chat.Jabber_OnPresence()
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnPresence", msg.from, msg.presenceType);
end

-- any kinds of error may goes here
function Map3DSystem.UI.Chat.Jabber_OnError()
	-- TODO: find a better way to handle error.
	if(msg~=nil and msg.msg ~=nil) then
		Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
			"OnError", tostring(msg.msg));
	end
end

-- succesfully registered a user
function Map3DSystem.UI.Chat.Jabber_OnRegistered()
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRegistered");
end

-- received a message
function Map3DSystem.UI.Chat.Jabber_OnMessage()
	if(msg~=nil) then
		-- here we just show the message
		-- msg.from may be of format "name@server/resource", so we need to remove resource
		local sJID = string.gsub(msg.from, "/.*$", "");
		Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
			"OnMessage", sJID, tostring(msg.subject), tostring(msg.body));
	end
end

-- connection is established, user is still being authenticated.
function Map3DSystem.UI.Chat.Jabber_OnConnect()
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnConnect");
end

-- use Jabber_OnError() instead. this function is not called.
function Map3DSystem.UI.Chat.Jabber_OnAuthError()
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnAuthError");
end

-- user is authenticated
function Map3DSystem.UI.Chat.Jabber_OnAuthenticate()
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnAuthenticate");
end

-- we are beginning to retrieve contact list from the server. This usually happens automatically when user is authenticated.
function Map3DSystem.UI.Chat.Jabber_OnRosterBegin()
	--_guihelper.MessageBox("Jabber_OnRosterBegin\n");
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRosterBegin");
end

-- a new user added this user
function Map3DSystem.UI.Chat.Jabber_OnSubscription()
	--_guihelper.MessageBox("Jabber_OnRosterBegin\n");
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnSubscription", msg.from);
end

-- a user unsubscribes from this user
function Map3DSystem.UI.Chat.Jabber_OnUnsubscription()
	--_guihelper.MessageBox("Jabber_OnRosterBegin\n");
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnUnsubscription", msg.from);
end


--[[
msg = {
	Subscription = number, -- 0(to), 1(from), 2(both), 3(none), 4(remove)
	JID = string, -- jabber ID
}
]]
function Map3DSystem.UI.Chat.Jabber_OnRosterItem()
	--_guihelper.MessageBox(msg.JID..":"..msg.Subscription.." Jabber_OnRosterItem\n");
	--Map3DSystem.UI.Chat.UpdateRosterUI();
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRosterItem");
end


-- we have received all contact lists from the server. Usually we need to update the UI.
function Map3DSystem.UI.Chat.Jabber_OnRosterEnd()
	--_guihelper.MessageBox("Jabber_OnRosterEnd\n");
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRosterEnd");
end

-- gracefully disconnected.
function Map3DSystem.UI.Chat.Jabber_OnDisconnect()
	Map3DSystem.UI.Chat.parentWindow:SendMessage(Map3DSystem.UI.Chat.MainWndObj.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnDisconnect");
end

function Map3DSystem.UI.Chat.OnMouseEnter()
end

function Map3DSystem.UI.Chat.OnMouseLeave()
end