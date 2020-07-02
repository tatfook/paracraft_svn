--[[
Title: Profile in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the Profile window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Profile.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Profile.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("ProfileWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("ProfileWnd recv MSG WM_HIDE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("ProfileWnd recv MSG WM_SHOW.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		-- Do your code
		--_guihelper.MessageBox("ProfileWnd recv MSG WM_MINIMIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MAXIMIZE) then
		-- Do your code
		--_guihelper.MessageBox("ProfileWnd recv MSG WM_MAXIMIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("ProfileWnd recv MSG WM_SIZE. size:"..msg.param1.."\n");
	end
end

-- init message system: call this function at main bar initialization to init the message system for profile window
function Map3DSystem.UI.Profile.InitMessageSystem()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("Profile");
	Map3DSystem.UI.Profile.App = _app;
	Map3DSystem.UI.Profile.MainWnd = _app:RegisterWindow("ProfileWnd", nil, Map3DSystem.UI.Profile.MSGProc);
end

-- send a message to Profile:ProfileWnd window handler
-- e.g. Map3DSystem.UI.Profile.SendMeMessage({type = Map3DSystem.msg.PROFILE_...})
function Map3DSystem.UI.Profile.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.Profile.MainWnd.name;
	Map3DSystem.UI.Profile.App:SendMessage(msg);
end

function Map3DSystem.UI.Profile.OnClick()
	Map3DSystem.UI.Profile.IsShow = not Map3DSystem.UI.Profile.IsShow;
	if(Map3DSystem.UI.Profile.IsShow) then
		Map3DSystem.UI.Profile.ShowWnd()
	else
		Map3DSystem.UI.Profile.CloseWnd()
	end
end

function Map3DSystem.UI.Profile.ShowWnd()

	local _wnd = ParaUI.GetUIObject("Profile_window");
	
	if(_wnd:IsValid() == false) then
		-- creation sub panel for the first run
		local _wnd = ParaUI.CreateUIObject("container", "Profile_window", "_lt", 0, 0, 350, 400);
		_wnd:AttachToRoot();
		
		-- my client window
		
		local _myClient = ParaUI.CreateUIObject("container", "MyClientWindow", "_lt", 0, 0, 175, 200);
		_wnd:AddChild(_myClient);
		
		local _icon = ParaUI.CreateUIObject("container", "MyClientIcon", "_lt", 5, 5, 32, 32);
		_icon.background = "Texture/3DMapSystem/Profile/Server.png";
		_myClient:AddChild(_icon);
		
		local _text = ParaUI.CreateUIObject("text", "MyClientText", "_lt", 45, 10, 120, 24);
		_text.text = "我的世界中的用户";
		_myClient:AddChild(_text);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local param = {
				name = "treeViewMyClient",
				alignment = "_fi",
				left = 10,
				top = 40,
				width = 10,
				height = 10,
				container_bg = "Texture/3DMapSystem/IM/white80opacity.png",
				parent = _myClient,
				DefaultIndentation = 24,
				DefaultNodeHeight = 24,
				DrawNodeHandler = Map3DSystem.UI.Profile.DrawMyClientNodeHandler,
				onclick = Map3DSystem.UI.Profile.OnClickMyClientUser,
			};
		local ctl = CommonCtrl.TreeView:new(param);
		local node = ctl.RootNode;
		ctl:Show();
		
		
		-- my server window
		local _myServer = ParaUI.CreateUIObject("container", "MyServerWindow", "_lt", 175, 0, 175, 200);
		_wnd:AddChild(_myServer);
		
		_icon = ParaUI.CreateUIObject("container", "MyServerIcon", "_lt", 5, 5, 32, 32);
		_icon.background = "Texture/3DMapSystem/Profile/Client.png";
		_myServer:AddChild(_icon);
		
		_text = ParaUI.CreateUIObject("text", "MyServerText", "_lt", 45, 10, 120, 24);
		_text.text = "我访问世界中的用户";
		_myServer:AddChild(_text);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local param = {
				name = "treeViewMyServer",
				alignment = "_fi",
				left = 10,
				top = 40,
				width = 10,
				height = 10,
				container_bg = "Texture/3DMapSystem/IM/white80opacity.png",
				parent = _myServer,
				DefaultIndentation = 24,
				DefaultNodeHeight = 24,
				DrawNodeHandler = Map3DSystem.UI.Profile.DrawMyServerNodeHandler,
				onclick = Map3DSystem.UI.Profile.OnClickMyServerUser,
			};
		local ctl = CommonCtrl.TreeView:new(param);
		local node = ctl.RootNode;
		ctl:Show();
		
		-- creation sub panel for the first run
		local _myLog = ParaUI.CreateUIObject("container", "MyLogWindow", "_lt", 0, 200, 350, 200);
		_wnd:AddChild(_myLog);
		
		_text = ParaUI.CreateUIObject("text", "MyLogText", "_lt", 40, 10, 100, 24);
		_text.text = "历史信息";
		_myLog:AddChild(_text);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local param = {
				name = "treeViewMyLog",
				alignment = "_fi",
				left = 10,
				top = 40,
				width = 10,
				height = 10,
				container_bg = "Texture/3DMapSystem/IM/white80opacity.png",
				parent = _myLog,
				DefaultIndentation = 24,
				DefaultNodeHeight = 24,
				DrawNodeHandler = nil, -- Map3DSystem.UI.Profile.DrawMyLogNodeHandler,
				onclick = nil,
			};
		local ctl = CommonCtrl.TreeView:new(param);
		local node = ctl.RootNode;
		ctl:Show();
		
		---- test button
		--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 50, 50, 128, 32);
		--_temp.text = "Profile";
		--_wnd:AddChild(_temp);
		
		---- creation sub panel for the first run
		--local _testWnd = ParaUI.CreateUIObject("container", "test", "_lt", 400, 500, 200, 200);
		--_testWnd:AttachToRoot();
		--_testWnd.candrag = true;
		--_testWnd.ondragbegin = ";Map3DSystem.UI.Profile.TestDragBegin();";
		--_testWnd.ondragmove = ";Map3DSystem.UI.Profile.TestDragMove();";
		--_testWnd.ondragend = ";Map3DSystem.UI.Profile.TestDragEnd();";
	else
		-- show Profile window
		_wnd.visible = true;
	end
end

function Map3DSystem.UI.Profile.DrawMyClientNodeHandler(_parent, treeNode)

	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1); -- indentation of this node. 
	local top = 2;
	local width;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	-- Test code: just for testing. remove this line
	--_parent.background = "Texture/whitedot.png"; _guihelper.SetUIColor(_parent, "0 0 100 60");
	
	if(treeNode.type == "user") then
		-- render user TreeNode: user status icon(according to presence, click to open dialog) + text button(NickName+Message) + tooltip (full information). 
		width = 24; -- status icon width
		-- status icon
		_this = ParaUI.CreateUIObject("button","b","_lt", left, 0, width , width );
		local _icon = _this;
		local _status;
		_parent:AddChild(_this);
		if(treeNode.Tag.presenceType == -1) then
			-- available status
			if(not treeNode.Tag.presenceShow or treeNode.Tag.presenceShow == "") then
				-- online
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/online.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "online";
			elseif(treeNode.Tag.presenceShow == "xa") then
				-- xa
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/away.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "xa";
			elseif(treeNode.Tag.presenceShow == "away") then
				-- away
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/away.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "xa";
			elseif(treeNode.Tag.presenceShow == "dnd") then
				-- dnd
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/busy.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "dnd";
			elseif(treeNode.Tag.presenceShow == "chat") then
				-- chat
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/chatty.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "chat";
			end
		else
			-- it is offline or some other unavailable status.
			_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/offline.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
			_status = "offline";
		end
		_this.onclick = string.format(";Map3DSystem.UI.Profile.ShowUserOnMap(%q)", treeNode.Name);
		left = left + width;
		
		-- text button	
		_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/3DMapSystem/IM/lightblue.png");
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q,%q)", treeNode.TreeView.name, treeNode:GetNodePath());
		
		-- set text: NickName -- presenece status text
		local displaytext;
		if(not treeNode.Tag.NickName or treeNode.Tag.NickName=="") then
			displaytext = treeNode.Text or treeNode.Name;
		else
			displaytext = treeNode.Tag.NickName;
		end
		
		local _name = Map3DSystem.UI.Chat.MainWnd.GetNameFromJID(treeNode.Name);
		
		if(treeNode.Tag.presenceStatus~=nil and treeNode.Tag.presenceStatus~="") then
			--displaytext = displaytext.." - "..treeNode.Tag.presenceStatus;
			displaytext = _name.." - "..treeNode.Tag.presenceStatus;
			-- TODO: add/update to contact table
			Map3DSystem.UI.Chat.JIDList[treeNode.Name] = treeNode.Tag.presenceStatus;
			
			Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(treeNode.Name, _status, treeNode.Tag.presenceStatus);
		else
			local _msgLocal = Map3DSystem.UI.Chat.JIDList[treeNode.Name];
			if(_msgLocal ~= nil) then
				displaytext = _name.." - ".._msgLocal;
				Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(treeNode.Name, _status, _msgLocal);
			else
				displaytext = _name;
				Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(treeNode.Name, _status, "");
			end
			-- TODO: we should store <userJID, status> records in a local table and check if there is an entry in the local database. 
			-- this is because presence is only sent when user is online. for offline users status, we load from local database table.
		end
		_this.text = displaytext;
		
		-- set tooltips: text + (TextStatus) \n<JID>\nSome help text
		local tooltips = displaytext;
		if(treeNode.Tag.presenceType ~= -1) then
			-- TODO: some other status text
			tooltips = tooltips.."(离线)";
		end	
		tooltips = tooltips.."\n<"..treeNode.Name..">".."\n";
		tooltips = tooltips .."左键点击查看地图位置";
		_icon.tooltip = tooltips;
	end
end

function Map3DSystem.UI.Profile.DrawMyServerNodeHandler(_parent, treeNode)

	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1); -- indentation of this node. 
	local top = 2;
	local width;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	-- Test code: just for testing. remove this line
	--_parent.background = "Texture/whitedot.png"; _guihelper.SetUIColor(_parent, "0 0 100 60");
	
	if(treeNode.type == "user") then
		-- render user TreeNode: user status icon(according to presence, click to open dialog) + text button(NickName+Message) + tooltip (full information). 
		width = 24; -- status icon width
		-- status icon
		_this = ParaUI.CreateUIObject("button","b","_lt", left, 0, width , width );
		local _icon = _this;
		local _status;
		_parent:AddChild(_this);
		if(treeNode.Tag.presenceType == -1) then
			-- available status
			if(not treeNode.Tag.presenceShow or treeNode.Tag.presenceShow == "") then
				-- online
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/online.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "online";
			elseif(treeNode.Tag.presenceShow == "xa") then
				-- xa
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/away.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "xa";
			elseif(treeNode.Tag.presenceShow == "away") then
				-- away
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/away.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "xa";
			elseif(treeNode.Tag.presenceShow == "dnd") then
				-- dnd
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/busy.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "dnd";
			elseif(treeNode.Tag.presenceShow == "chat") then
				-- chat
				_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/chatty.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
				_status = "chat";
			end
		else
			-- it is offline or some other unavailable status.
			_guihelper.SetVistaStyleButton(_this, "Texture/3DMapSystem/IM/offline.png", 
						"Texture/3DMapSystem/IM/contact-over.png");
			_status = "offline";
		end
		_this.onclick = string.format(";Map3DSystem.UI.Profile.ShowUserOnMap(%q)", treeNode.Name);
		left = left + width;
		
		-- text button	
		_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/3DMapSystem/IM/lightblue.png");
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q,%q)", treeNode.TreeView.name, treeNode:GetNodePath());
		
		-- set text: NickName -- presenece status text
		local displaytext;
		if(not treeNode.Tag.NickName or treeNode.Tag.NickName=="") then
			displaytext = treeNode.Text or treeNode.Name;
		else
			displaytext = treeNode.Tag.NickName;
		end
		
		local _name = Map3DSystem.UI.Chat.MainWnd.GetNameFromJID(treeNode.Name);
		
		if(treeNode.Tag.presenceStatus~=nil and treeNode.Tag.presenceStatus~="") then
			--displaytext = displaytext.." - "..treeNode.Tag.presenceStatus;
			displaytext = _name.." - "..treeNode.Tag.presenceStatus;
			-- TODO: add/update to contact table
			Map3DSystem.UI.Chat.JIDList[treeNode.Name] = treeNode.Tag.presenceStatus;
			
			Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(treeNode.Name, _status, treeNode.Tag.presenceStatus);
		else
			local _msgLocal = Map3DSystem.UI.Chat.JIDList[treeNode.Name];
			if(_msgLocal ~= nil) then
				displaytext = _name.." - ".._msgLocal;
				Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(treeNode.Name, _status, _msgLocal);
			else
				displaytext = _name;
				Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(treeNode.Name, _status, "");
			end
			-- TODO: we should store <userJID, status> records in a local table and check if there is an entry in the local database. 
			-- this is because presence is only sent when user is online. for offline users status, we load from local database table.
		end
		_this.text = displaytext;
		
		-- set tooltips: text + (TextStatus) \n<JID>\nSome help text
		local tooltips = displaytext;
		if(treeNode.Tag.presenceType ~= -1) then
			-- TODO: some other status text
			tooltips = tooltips.."(离线)";
		end	
		tooltips = tooltips.."\n<"..treeNode.Name..">".."\n";
		tooltips = tooltips .."左键点击查看地图位置";
		_icon.tooltip = tooltips;
	end
end

-- called when clicking a user
function Map3DSystem.UI.Profile.OnClickMyClientUser(treeNode)
	if(treeNode == nil) then 
		return 
	end
	if(treeNode.type == "user") then
		-- user node
		if(mouse_button == "left") then
			Map3DSystem.UI.Chat.MainWnd.ShowChatWithUser(treeNode.Name);
		elseif(mouse_button == "right") then
			
			local ctl = CommonCtrl.GetControl("IM_User_contextmenu");
			if(ctl==nil)then
				ctl = CommonCtrl.ContextMenu:new{
					name = "IM_User_contextmenu",
					width = 150,
					height = 100,
					container_bg = "Texture/tooltip_text.PNG",
					onclick = Map3DSystem.UI.Chat.MainWnd.OnClickUserContextMenuItem,
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

-- called when clicking a user
function Map3DSystem.UI.Profile.OnClickMyServerUser(treeNode)
	if(treeNode == nil) then 
		return 
	end
	if(treeNode.type == "user") then
		-- user node
		if(mouse_button == "left") then
			Map3DSystem.UI.Chat.MainWnd.ShowChatWithUser(treeNode.Name);
		elseif(mouse_button == "right") then
			
			local ctl = CommonCtrl.GetControl("IM_User_contextmenu");
			if(ctl==nil)then
				ctl = CommonCtrl.ContextMenu:new{
					name = "IM_User_contextmenu",
					width = 150,
					height = 100,
					container_bg = "Texture/tooltip_text.PNG",
					onclick = Map3DSystem.UI.Chat.MainWnd.OnClickUserContextMenuItem,
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

function Map3DSystem.UI.Profile.AddMyClient(userJID)

	local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	if(jc ~= nil) then
		local userDetail = Map3DSystem.UI.Chat.RosterHistory.UserDetails[userJID];
		local treeView = CommonCtrl.GetControl("treeViewMyClient");
		if(treeView ~= nil and userDetail ~= nil) then
			local _, detail;
			for _, detail in ipairs(userDetail) do
				
				local rootNode = treeView.RootNode;
				if( rootNode:GetChildByName(userJID) == nil) then
					-- if no userJID added before add to list
					rootNode:AddChild( CommonCtrl.TreeNode:new({
							Text = userJID, 
							Name = userJID, 
							type = "user", 
							Tag = detail,}));
					treeView:Update();
					return true;
				end
			end
		end
	end
end

function Map3DSystem.UI.Profile.RemoveMyClient(userJID)

	local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	if(jc ~= nil) then
		local userDetail = Map3DSystem.UI.Chat.RosterHistory.UserDetails[userJID];
		local treeView = CommonCtrl.GetControl("treeViewMyClient");
		if(treeView ~= nil and userDetail ~= nil) then
			local _, detail;
			for _, detail in ipairs(userDetail) do
				local rootNode = treeView.RootNode;
				rootNode:RemoveChildByName(userJID);
				treeView:Update();
				return true;
			end
		end
	end
end

function Map3DSystem.UI.Profile.AddMyServer(userJID)

	local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	if(jc ~= nil) then
		local userDetail = Map3DSystem.UI.Chat.RosterHistory.UserDetails[userJID];
		local treeView = CommonCtrl.GetControl("treeViewMyServer");
		if(treeView ~= nil and userDetail ~= nil) then
			local _, detail;
			for _, detail in ipairs(userDetail) do
				
				local rootNode = treeView.RootNode;
				if( rootNode:GetChildByName(userJID) == nil) then
					-- if no userJID added before add to list
					rootNode:AddChild( CommonCtrl.TreeNode:new({
							Text = userJID, 
							Name = userJID, 
							type = "user", 
							Tag = detail,}));
					treeView:Update();
					return true;
				end
			end
			
		end
	end
end

function Map3DSystem.UI.Profile.RemoveMyServer(userJID)

	local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	if(jc ~= nil) then
		local userDetail = Map3DSystem.UI.Chat.RosterHistory.UserDetails[userJID];
		local treeView = CommonCtrl.GetControl("treeViewMyServer");
		if(treeView ~= nil and userDetail ~= nil) then
			local _, detail;
			for _, detail in ipairs(userDetail) do
				local rootNode = treeView.RootNode;
				rootNode:RemoveChildByName(userJID);
				treeView:Update();
				return true;
			end
			
		end
	end
end

function Map3DSystem.UI.Profile.AppendMyLog(sLog)
	
	local treeView = CommonCtrl.GetControl("treeViewMyLog");
	local rootNode = treeView.RootNode;
	
	rootNode:AddChild( CommonCtrl.TreeNode:new({
			Text = sLog, 
			Name = "log", 
			}));
			
	treeView:Update();
end

function Map3DSystem.UI.Profile.CloseWnd()
	
	local _wnd = ParaUI.GetUIObject("Profile_window");
	
	if(_wnd:IsValid() == false) then
		log("Profile window container is not yet initialized.\r\n");
	else
		-- show creation sub panel
		_wnd.visible = false;
	end
end


function Map3DSystem.UI.Profile.OnMouseEnter()
end

function Map3DSystem.UI.Profile.OnMouseLeave()
end