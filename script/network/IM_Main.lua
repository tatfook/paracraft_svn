--[[
Title: Instant messenging main window
Author(s): LiXizhi
Date: 2007/9/17
------------------------------------------------------------
NPL.load("(gl)script/network/IM_Main.lua");
IM_Main.Init("LiXizhi", "password", "paraweb3d.com")
IM_Main.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/event_mapping.lua");
NPL.load("(gl)script/network/IM_ChatWnd.lua");
NPL.load("(gl)script/network/IM_TreeView.lua");
NPL.load("(gl)script/ide/ContextMenu.lua");

if(not IM_Main) then IM_Main={}; end

IM_Main.jc_name = "default";
IM_Main.UserJID = "";
IM_Main.UserStatus = {
	"离线", "在线", "忙碌",
}
IM_Main.LastConnectionTime = 0;
function IM_Main.GetClient()
	-- create if not exist
	return JabberClientManager.CreateJabberClient(IM_Main.jc_name);
end

-- get the currently connected client. return nil, if connection is not valid
function IM_Main.GetConnectedClient()
	local jc = IM_Main.GetClient();
	if(jc:IsValid() and jc:GetIsAuthenticated()) then
		return jc;
	end
end

-- such as IM_Main.Init("LiXizhi", "password", "paraweb3d.com")
function IM_Main.Init(username, password, servername, parentWindow)
	-- NOTE by Andy: add a parameter "parentWindow" will record the parent window object for sending messages
	if(parentWindow) then
		IM_Main.parentWindow = parentWindow;
	end
	
	local jc = IM_Main.GetClient();
	if(jc:IsValid()) then
		if(not jc:GetIsAuthenticated()) then
			if((ParaGlobal.timeGetTime() - IM_Main.LastConnectionTime)> 20000) then
				IM_Main.LastConnectionTime = ParaGlobal.timeGetTime();
				jc.User = username;
				jc.Password = password;
				jc.Server = servername;
				IM_Main.UserJID = username.."@"..servername;
				jc:ResetAllEventListeners();
				if(parentWindow) then
					-- bind event to 3D Map system
					--jc:AddEventListener(Jabber_Event.Jabber_OnPresence, "IM_Main.Map3DChat_OnPresence()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnError, "IM_Main.Map3DChat_OnError()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnRegistered, "IM_Main.Map3DChat_OnRegistered()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnMessage, "IM_Main.Map3DChat_OnMessage()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnConnect, "IM_Main.Map3DChat_OnConnect()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnAuthenticate, "IM_Main.Map3DChat_OnAuthenticate()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnDisconnect, "IM_Main.Map3DChat_OnDisconnect()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnRosterBegin, "IM_Main.Map3DChat_OnRosterBegin()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnRosterItem, "IM_Main.Map3DChat_OnRosterItem()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnRosterEnd, "IM_Main.Map3DChat_OnRosterEnd()");
					--jc:AddEventListener(Jabber_Event.Jabber_OnAuthError, "IM_Main.Map3DChat_OnAuthError()");
					
					jc:AddEventListener(Jabber_Event.Jabber_OnPresence, "IM_Main.Jabber_OnPresence()");
					jc:AddEventListener(Jabber_Event.Jabber_OnError, "IM_Main.Jabber_OnError()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRegistered, "IM_Main.Jabber_OnRegistered()");
					jc:AddEventListener(Jabber_Event.Jabber_OnMessage, "IM_Main.Jabber_OnMessage()");
					jc:AddEventListener(Jabber_Event.Jabber_OnConnect, "IM_Main.Jabber_OnConnect()");
					jc:AddEventListener(Jabber_Event.Jabber_OnAuthenticate, "IM_Main.Jabber_OnAuthenticate()");
					jc:AddEventListener(Jabber_Event.Jabber_OnDisconnect, "IM_Main.Jabber_OnDisconnect()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRosterBegin, "IM_Main.Jabber_OnRosterBegin()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRosterItem, "IM_Main.Jabber_OnRosterItem()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRosterEnd, "IM_Main.Jabber_OnRosterEnd()");
					jc:AddEventListener(Jabber_Event.Jabber_OnAuthError, "IM_Main.Jabber_OnAuthError()");
				else
					-- bind event to IM_Main
					jc:AddEventListener(Jabber_Event.Jabber_OnPresence, "IM_Main.Jabber_OnPresence()");
					jc:AddEventListener(Jabber_Event.Jabber_OnError, "IM_Main.Jabber_OnError()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRegistered, "IM_Main.Jabber_OnRegistered()");
					jc:AddEventListener(Jabber_Event.Jabber_OnMessage, "IM_Main.Jabber_OnMessage()");
					jc:AddEventListener(Jabber_Event.Jabber_OnConnect, "IM_Main.Jabber_OnConnect()");
					jc:AddEventListener(Jabber_Event.Jabber_OnAuthenticate, "IM_Main.Jabber_OnAuthenticate()");
					jc:AddEventListener(Jabber_Event.Jabber_OnDisconnect, "IM_Main.Jabber_OnDisconnect()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRosterBegin, "IM_Main.Jabber_OnRosterBegin()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRosterItem, "IM_Main.Jabber_OnRosterItem()");
					jc:AddEventListener(Jabber_Event.Jabber_OnRosterEnd, "IM_Main.Jabber_OnRosterEnd()");
					jc:AddEventListener(Jabber_Event.Jabber_OnAuthError, "IM_Main.Jabber_OnAuthError()");
				end
				jc:Connect();
			else
				_guihelper.MessageBox("正在连接...请稍候再试");
			end	
		else
			_guihelper.MessageBox("已经连接了 "..jc.User..jc.Server);
		end	
	end
end

function IM_Main.Jabber_OnPresence()
	_guihelper.MessageBox(msg.from..":"..msg.presenceType.." Jabber_OnPresence\n");
	IM_Main.UpdateRosterUI();
end

function IM_Main.Map3DChat_OnPresence()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnPresence", msg.from, msg.presenceType);
	-- TODO: temporarily the Map 3D system uses the IM_Main user interface
	IM_Main.UpdateRosterUI();
end

-- any kinds of error may goes here
function IM_Main.Jabber_OnError()
	-- TODO: find a better way to handle error.
	_guihelper.MessageBox("Jabber_OnError\n");
	if(msg~=nil and msg.msg ~=nil) then
		_guihelper.MessageBox(tostring(msg.msg));
	end
end

function IM_Main.Map3DChat_OnError()
	if(msg~=nil and msg.msg ~=nil) then
		IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
			"OnError", tostring(msg.msg));
	end
end

-- succesfully registered a user
function IM_Main.Jabber_OnRegistered()
	_guihelper.MessageBox("Jabber_OnRegistered\n");
end

function IM_Main.Map3DChat_OnRegistered()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRegistered");
end

-- received a message
function IM_Main.Jabber_OnMessage()
	--_guihelper.MessageBox("Jabber_OnMessage\n");
	if(msg~=nil) then
		-- here we just show the message
		-- msg.from may be of format "name@server/resource", so we need to remove resource
		local sJID = string.gsub(msg.from, "/.*$", "");
		local chatWnd = IM_Main.GetChatWnd(sJID);
		if(chatWnd~=nil) then
			chatWnd:Show(true);
			chatWnd:OnReceiveMessage(sJID, tostring(msg.subject), tostring(msg.body));
		end
	end
end

function IM_Main.Map3DChat_OnMessage()
	if(msg~=nil) then
		local sJID = string.gsub(msg.from, "/.*$", "");
		IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
			"OnMessage", sJID, tostring(msg.subject), tostring(msg.body));
	end
end

-- connection is established, user is still being authenticated.
function IM_Main.Jabber_OnConnect()
	_guihelper.MessageBox("Jabber_OnConnect\n");
end

function IM_Main.Map3DChat_OnConnect()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnConnect");
end

-- use Jabber_OnError() instead. this function is not called.
function IM_Main.Jabber_OnAuthError()
	_guihelper.MessageBox("Jabber_OnAuthError\n");
end

function IM_Main.Map3DChat_OnAuthError()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnAuthError");
end

-- user is authenticated
function IM_Main.Jabber_OnAuthenticate()
	_guihelper.MessageBox("Jabber_OnAuthenticate\n");
	local _this = ParaUI.GetUIObject("IM_Main_cont");
	if(_this:IsValid() == true) then
		local ctrl = CommonCtrl.GetControl("comboBoxIMUserStatus");
		if(ctrl~=nil)then
			-- TODO SetPresence() with the status and show text on this local machine.
			-- here we will just display online, here.
			ctrl:SetText(IM_Main.UserStatus[2]); 
		end
	end
end

function IM_Main.Map3DChat_OnAuthenticate()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnAuthenticate");
end

-- we are beginning to retrieve contact list from the server. This usually happens automatically when user is authenticated.
function IM_Main.Jabber_OnRosterBegin()
	--_guihelper.MessageBox("Jabber_OnRosterBegin\n");
	IM_Main.RosterBegin = true;
end

function IM_Main.Map3DChat_OnRosterBegin()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRosterBegin");
end

--[[
msg = {
	Subscription = number, -- 0(to), 1(from), 2(both), 3(none), 4(remove)
	JID = string, -- jabber ID
}
]]
function IM_Main.Jabber_OnRosterItem()
	--_guihelper.MessageBox(msg.JID..":"..msg.Subscription.." Jabber_OnRosterItem\n");
	IM_Main.UpdateRosterUI();
end

function IM_Main.Map3DChat_OnRosterItem()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRosterItem");
end

-- we have received all contact lists from the server. Usually we need to update the UI.
function IM_Main.Jabber_OnRosterEnd()
	--_guihelper.MessageBox("Jabber_OnRosterEnd\n");
	IM_Main.RosterBegin = nil;
	IM_Main.UpdateRosterUI();
end

function IM_Main.Map3DChat_OnRosterEnd()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnRosterEnd");
end

-- gracefully disconnected.
function IM_Main.Jabber_OnDisconnect()
	_guihelper.MessageBox("Jabber_OnDisconnect\n");
	
	local _this = ParaUI.GetUIObject("IM_Main_cont");
	if(_this:IsValid() == true) then
		local ctrl = CommonCtrl.GetControl("comboBoxIMUserStatus");
		if(ctrl~=nil)then
			ctrl:SetText( IM_Main.UserStatus[1] ); 
		end
	end
end

function IM_Main.Map3DChat_OnDisconnect()
	IM_Main.parentWindow:SendMessage(IM_Main.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CHAT, 
		"OnDisconnect");
end

-- @param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- 
-- NOTE by Andy: change to show(bool, UIparent, windowobject) interface
function IM_Main.Show(bShow, _parent, parentWindow)
	local _this;
	
	if(parentWindow) then
		IM_Main.parentWindow = parentWindow;
	end
	
	_this=ParaUI.GetUIObject("IM_Main_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		-- IM_Main_cont
		local width, height = 285, 432;
		
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "IM_Main_cont", "_lt", 0, 0, width, height)
			_this.candrag = true;
			_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
			_this:AttachToRoot();

			_this = ParaUI.CreateUIObject("button", "buttonClose", "_rt", -27, 3, 24, 24)
			_this.text = "X";
			_this.onclick = ";IM_Main.Show();"
			_parent:AddChild(_this);
			
		else
			_this = ParaUI.CreateUIObject("container", "IM_Main_cont", "_fi", 0, 0, 0, 0);
			_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
			_parent:AddChild(_this);
			
			-- NOTE: there is no close button is window object specified
		end
		
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 91, 9, 190, 14)
		_this.text = "ParaWorld Messenger";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnIMIcon", "_lt", 7, 29, 48, 48)
		_this.text = "IM Icon";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "textBoxPersonalMsg", "_mt", 61, 54, 3, 23)
		_this.text = "<输入个人消息>";
		_parent:AddChild(_this);
		
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxIMUserStatus",
			alignment = "_mt",
			left = 61,
			top = 29,
			width = 3,
			height = 23,
			dropdownheight = 106,
 			parent = _parent,
			text = IM_Main.UserStatus[1],
			items = IM_Main.UserStatus,
			FuncTextFormat = IM_Main.FormatUserStatus,
			AllowUserEdit = false,
		};
		ctl:Show();

		-- tabs_cont
		_this = ParaUI.CreateUIObject("container", "tabs_cont", "_ml", 3, 84, 40, 89)
		_this.background = ""
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "tabChat", "_lt", 4, 0, 36, 36)
		_this.text = "chat";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "tabActivities", "_lt", 4, 42, 36, 36)
		_this.text = "act";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "tabSocial", "_lt", 4, 84, 36, 36)
		_this.text = "Social";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "tabLove", "_lt", 4, 126, 36, 36)
		_this.text = "Love";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "tabShop", "_lt", 4, 168, 36, 36)
		_this.text = "Shop";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("container", "panelAds", "_lt", 3, 349, 279, 80)
		_this.background = ""
		_parent = ParaUI.GetUIObject("IM_Main_cont");
		_parent:AddChild(_this);

		-- IM_Chat_Cont
		_this = ParaUI.CreateUIObject("container", "IM_Chat_Cont", "_fi", 43, 83, 6, 89)
		_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "btnAddContact", "_rt", -42, 4, 39, 23)
		_this.text = "add";
		_this.onclick = ";IM_Main.AddContact();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "textBoxAddContact", "_mt", 6, 4, 48, 23)
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local param = {
				name = "treeViewContacts",
				alignment = "_fi",
				left = 6,
				top = 33,
				width = 3,
				height = 3,
				container_bg = "Texture/tooltip_text.PNG",
				parent = _parent,
				DefaultIndentation = 10,
				DefaultNodeHeight = 26,
				DrawNodeHandler = IM_TreeView.DrawContactNodeHandler,
			};
		if(parentWindow) then
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Chat.lua");
			param.onclick = Map3DSystem.UI.Chat.OnClickUser;
		else
			param.onclick = IM_Main.OnClickUser;
		end
		local ctl = CommonCtrl.TreeView:new(param);
		local node = ctl.RootNode;
		ctl:Show();


	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end	
end

-- used to format user status
function IM_Main.FormatUserStatus(status)
	local jc = IM_Main.GetConnectedClient();
	if(jc~=nil) then
		return string.format("%s (%s)", jc.User, status);
	else
		return string.format("%s (%s)", "尚未登陆", status);
	end
end


-- destory the control
function IM_Main.OnDestory()
	ParaUI.Destroy("IM_Main_cont");
end

-- display a dialog showing detail information about a given user according to its jid. 
-- @param sJID: string of jabber ID. 
function IM_Main.ShowUserOnMap(sJID)
	_guihelper.MessageBox("TODO: Show user "..sJID..". on 3d map \n");
end

-- return the IM_ChatWnd instance for a given sJID, it will  create the window if it has never been created before. 
function IM_Main.GetChatWnd(sJID)
	if(not sJID) then return end
	local WndName = sJID.."ChatWnd";
	if(not ParaUI.GetUIObject(WndName):IsValid()) then	
		-- create the object if it does not exist
		local ctl = CommonCtrl.IM_ChatWnd:new{
			name = WndName,
			alignment = "_lt",
			left=500, top=60,
			width = 512,
			height = 290,
			parent = nil,
			to_JID = sJID,
		};
		ctl:Show(true);
	end
	return CommonCtrl.GetControl(WndName);
end

-- called when clicking a user
function IM_Main.OnClickUser(treeNode)
	if(treeNode == nil) then 
		return 
	end
	if(treeNode.type == "group") then
		-- group node
		if(mouse_button == "left") then
			
		elseif(mouse_button == "right") then
			local ctl = CommonCtrl.GetControl("IM_Group_contextmenu");
			if(ctl==nil)then
				ctl = CommonCtrl.ContextMenu:new{
					name = "IM_Group_contextmenu",
					width = 150,
					height = 100,
					container_bg = "Texture/tooltip_text.PNG",
					onclick = IM_Main.OnClickGroupContextMenuItem,
				};
				local node = ctl.RootNode;
				node:AddChild(CommonCtrl.TreeNode:new({Text = "向此组发送即时消息", Name = "ChatWithGroup"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "重名命名组", Name = "RenameGroup"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "删除组", Name = "DeleteGroup"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "新建组", Name = "CreateGroup"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "粘贴用户", Name = "PasteUser"}));
			end	

			ctl:Show(mouse_x, mouse_y, treeNode);
		end	
	elseif(treeNode.type == "user") then
		-- user node
		if(mouse_button == "left") then
			IM_Main.ShowChatWithUser(treeNode.Name)
		elseif(mouse_button == "right") then
			
			local ctl = CommonCtrl.GetControl("IM_User_contextmenu");
			if(ctl==nil)then
				ctl = CommonCtrl.ContextMenu:new{
					name = "IM_User_contextmenu",
					width = 150,
					height = 100,
					container_bg = "Texture/tooltip_text.PNG",
					onclick = IM_Main.OnClickUserContextMenuItem,
				};
				local node = ctl.RootNode;
				node:AddChild(CommonCtrl.TreeNode:new({Text = "发送即时消息", Name = "ChatWithUser"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "查看地图", Name = "ViewOnMap"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "删除用户", Name = "DeleteUser"}));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "复制用户", Name = "CopyUser"}));
			end	

			ctl:Show(mouse_x, mouse_y, treeNode);
		end
	end	
end

-- context menu event handler
function IM_Main.OnClickGroupContextMenuItem(menuItem, UserNode)
	if(menuItem.Name == "ChatWithGroup") then
	elseif(menuItem.Name == "RenameGroup") then
	elseif(menuItem.Name == "DeleteGroup") then
	elseif(menuItem.Name == "CreateGroup") then
	elseif(menuItem.Name == "PasteUser") then
	end
end

-- context menu event handler
function IM_Main.OnClickUserContextMenuItem(menuItem, UserNode)
	if(menuItem.Name == "ChatWithUser") then
		IM_Main.ShowChatWithUser(UserNode.Name);
		
	elseif(menuItem.Name == "ViewOnMap") then
		IM_Main.ShowUserOnMap(UserNode.Name)
		
	elseif(menuItem.Name == "DeleteUser") then
		_guihelper.MessageBox("您真的要删除下面联系人么?\n"..UserNode.Name, function (sJID) 
			-- remove user from contact list
			if(sJID~=nil) then
				local jc = IM_Main.GetConnectedClient();
				if(jc~=nil) then
					jc:RemoveRosterItem(sJID);
				end
			end
		end, UserNode.Name)
		
	elseif(menuItem.Name == "CopyUser") then
	end
end

-- display a chat dialog to begin chatting
-- @param sJID: string of jabber ID. 
function IM_Main.ShowChatWithUser(sJID)
	local chatWnd = IM_Main.GetChatWnd(sJID);
	if(chatWnd~=nil) then
		chatWnd:Show(true);
	end
end

-- add a contact according to the user input  in editbox
function IM_Main.AddContact()
	local tmp=ParaUI.GetUIObject("IM_Main_cont");
	if(tmp:IsValid()) then	
		local tmp=tmp:GetChild("IM_Chat_Cont");
		if(tmp:IsValid()) then		
			local tmp=tmp:GetChild("textBoxAddContact");
			if(tmp:IsValid()) then
				local UserToAdd = tmp.text;
				if(UserToAdd ~= nil and UserToAdd ~="") then
					local jc = IM_Main.GetConnectedClient();
					if(jc~=nil) then
						jc:Subscribe(UserToAdd, UserToAdd, "general");
					end	
				else
					_guihelper.MessageBox("输入名字, 例如 name@paraweb3d.com");
				end
			end
		end
	end
end

-- just update the entire UI. 
function IM_Main.UpdateRosterUI()
	if(IM_Main.RosterBegin) then 
		return 
	end
	
	local jc = IM_Main.GetConnectedClient();
	local _this = ParaUI.GetUIObject("IM_Main_cont");
	if(jc~=nil and _this:IsValid() == true) then
		_this=_this:GetChild("IM_Chat_Cont");
		if(_this:IsValid() == true) then
			-- update contact list UI for this user. Here I used a simple listbox.
			local treeView = CommonCtrl.GetControl("treeViewContacts");
			if(treeView~=nil)then
				treeView.RootNode:ClearAllChildren();
				local node = treeView.RootNode;
				
				-- add groups
				local groups= jc:GetRosterGroups();
				if(groups~=nil) then
					local groupname;
					for groupname in string.gfind(groups, "([^;]+)") do
						node:AddChild( CommonCtrl.TreeNode:new({Text = groupname, Name = groupname, type = "group"}) );
					end
				end
				-- get all users inside contact group
				local names = jc:GetRosterItems();
				if(names~=nil) then
					local userJID;
					for userJID in string.gfind(names, "([^;]+)") do
						--log("roster item begins\n");log(jc:GetRosterItemDetail(userJID));
						local userDetail = commonlib.LoadTableFromString(jc:GetRosterItemDetail(userJID));
						if(userDetail~=nil) then
							local _, detail;
							for _, detail in ipairs(userDetail) do
								local groupNode = treeView.RootNode:GetChildByName(detail.groupname);
								if(not groupNode)then
									log("warning: a user does not belong to any IM roster group\n");
									groupNode = treeView.RootNode;
								end
								groupNode:AddChild( CommonCtrl.TreeNode:new({Text = userJID, Name = userJID, type = "user", Tag = detail,}) );
							end
						end
					end
				end
				treeView:Update();
			end
		end
	end
end