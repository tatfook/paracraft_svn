--[[
Title: Instant messenging main window in Map 3D system
Author(s): WangTian
Date: 2007/10/12
NOTE: this is a revision of the original Map3DSystem.UI.Chat.lua interface
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

-- @param bShow: show or hide the panel
-- @param parentUI: parent container inside which the content is displayed. it can be nil.
-- @param parentWindow: parent window for sending messages
function Map3DSystem.UI.Chat.MainWnd.ShowMainWndUI(bShow, parentUI, parentWindow)
	
	local _this, _parent;
	
	-- NOTE: parentWindow should ONLY used on initialize, 
	--		further change parentwindow will cause unreferenced window frame object
	if(parentWindow) then
		Map3DSystem.UI.Chat.parentWindow = parentWindow;
	end
	
	_this = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		-- Map3DSystem_Chat_Main_cont
		local width, height = 284, 452;
		
		if(parentUI == nil) then
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_Chat_Main_cont", "_lt", 0, 0, width, height);
			_this.candrag = true;
			_this.background = "Texture/uncheckbox.png: 10 10 10 10";
			--_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
			_this:AttachToRoot();
			
			_parent = _this;
			
			_this = ParaUI.CreateUIObject("button", "buttonClose", "_rt", -27, 3, 24, 24);
			_this.text = "X";
			_this.onclick = ";Map3DSystem.UI.Chat.Show();" -- TODO: close button
			_parent:AddChild(_this);
			
		else
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_Chat_Main_cont", "_fi", 0, 0, 0, 0);
			--_this:SetNineElementBG("Texture/uncheckbox.png", 10, 10, 10, 10);
			_this.background = "";
			parentUI:AddChild(_this);
			
			-- NOTE: there is no close button is window object specified
		end
		
		_parent = _this;
		
		--_this = ParaUI.CreateUIObject("text", "label1", "_lt", 91, 9, 190, 14)
		--_this.text = "ParaWorld Messenger";
		--_parent:AddChild(_this);
		
		
		_this = ParaUI.CreateUIObject("text", "mainWindowTitleText", "_lt", 15, -25, 200, 24)
		_this.text = "ParaWorld Chat";
		_this.font = "helvetica;24;regular;true";
		--_this.font = "myriad pro;18;regular;true";
		_this.scalingx = 0.7;
		_this.scalingy = 0.7;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "btnIMIcon_BG", "_lt", 10, 0, 61, 61)
		--_this.text = "IM Icon";
		_this.background = "Texture/3DMapSystem/IM/UserIcon_Frame_BG.png: 8 8 10 10";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnIMIcon", "_lt", 15, 5, 48, 48)
		--_this.text = "IM Icon";
		_this.background = "Texture/3DMapSystem/IM/offline64.png";
		_this.onclick = ";Map3DSystem.UI.Chat.MainWnd.OnUserIconClick();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "textBoxPersonalMsg", "_mt", 75, 34, 20, 20)
		_this.text = "<输入个人消息>";
		_this.onchange = ";Map3DSystem.UI.Chat.MainWnd.OnChangePersonalMsg();";
		_this.onkeydown = ";Map3DSystem.UI.Chat.MainWnd.OnKeyDownPersonalMsg();";
		_parent:AddChild(_this);
		
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxChatUserStatus",
			alignment = "_mt",
			left = 75,
			top = 6,
			width = 20,
			height = 20,
			dropdownheight = 106,
 			parent = _parent,
 			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/dropdownlistbox_container_bg.png: 4 4 4 4", 
			dropdownbutton_bg = "Texture/3DMapSystem/common/ThemeLightBlue/dropdownlistbox_dropdownbutton_bg.png: 4 4 4 4",
			--listbox_bg = nil, -- list box background texture
			text = Map3DSystem.UI.Chat.UserStatus[5],
			items = Map3DSystem.UI.Chat.UserStatus,
			FuncTextFormat = Map3DSystem.UI.Chat.FormatUserStatus,
			AllowUserEdit = false,
			onselect = Map3DSystem.UI.Chat.MainWnd.OnSelectUserStatus,
		};
		ctl:Show();
		
		local contactPosX = Map3DSystem.UI.Chat.MainWndContactsPosX;
		local contactPosY = Map3DSystem.UI.Chat.MainWndContactsPosY;
		
		-- IM_Tab_Cont
		
		--_this = ParaUI.CreateUIObject("container", "IM_Tab_Cont_BG", "_ml", 0, contactPosY + 1, contactPosX + 4, Map3DSystem.UI.Chat.MainWndAdsHeight + 10);
		--_this.background = "Texture/3DMapSystem/IM/ContactTab_BG.png: 8 8 8 8";
		--_this.enable = false;
		--_parent:AddChild(_this);
		
		-- NOTE: the height 250 here will be adjusted according to the new window frame size
		_this = ParaUI.CreateUIObject("container", "IM_Tab_Cont", "_ml", 0, contactPosY + 1, contactPosX + 1, Map3DSystem.UI.Chat.MainWndAdsHeight + 10);
		--_this.background = "Texture/3DMapSystem/IM/tab-chatting-BG.png: 30 30 1 30";
		_this.background = "";
		_this.visible = false;
		_parent:AddChild(_this);
		_parent = _this;
		
		---------------------------------------------------
		-- TODO: fix this field into chat tabs
		
		--_this = ParaUI.CreateUIObject("button", "tabChat", "_lt", 4, 0, 36, 36)
		--_this.text = "chat";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "tabActivities", "_lt", 4, 42, 36, 36)
		--_this.text = "act";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "tabSocial", "_lt", 4, 84, 36, 36)
		--_this.text = "Social";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "tabLove", "_lt", 4, 126, 36, 36)
		--_this.text = "Love";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "tabShop", "_lt", 4, 168, 36, 36)
		--_this.text = "Shop";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("container", "panelAds", "_lt", 3, 349, 279, 80)
		--_this.background = ""
		--_parent = ParaUI.GetUIObject("IM_Main_cont");
		--_parent:AddChild(_this);
		
		---------------------------------------------------
		
		_parent = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");

		-- IM_Contact_Cont
		-- NOTE: the width 220 and height 300 here will be adjusted according to the new window frame size
		_this = ParaUI.CreateUIObject("container", "IM_Contact_Cont", "_fi", 
				contactPosX, contactPosY, 1, Map3DSystem.UI.Chat.MainWndAdsHeight); --239, 306
		--_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
		--_this.background = "Texture/3DMapSystem/IM/contactlist_bg.png: 6 6 6 6";
		_this.background = "";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "btnAddContact", "_rt", -45, 10, 39, 23)
		_this.text = "add";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 8 8 8 8";
		_this.onclick = ";Map3DSystem.UI.Chat.MainWnd.AddContact();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "textBoxAddContact", "_mt", 5, 10, 50, 23);
		_this.color = "255 255 255 160";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local param = {
				name = "treeViewContacts",
				alignment = "_fi",
				left = 4,
				top = 40,
				width = 4,
				height = 4,
				container_bg = "Texture/3DMapSystem/IM/white80opacity.png",
				parent = _parent,
				DefaultIndentation = 24,
				DefaultNodeHeight = 24,
				DrawNodeHandler = Map3DSystem.UI.Chat.MainWnd.DrawContactNodeHandler,
			};
		if(parentWindow) then
			param.onclick = Map3DSystem.UI.Chat.MainWnd.OnClickUser;
		else
			param.onclick = Map3DSystem.UI.Chat.MainWnd.OnClickUser;
		end
		local ctl = CommonCtrl.TreeView:new(param);
		local node = ctl.RootNode;
		ctl:Show();
		
		
		_parent = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
		
		---- IM_Ads_Cont
		--_this = ParaUI.CreateUIObject("container", "IM_Ads_Cont", "_mb", 
				--16, 0, 16, Map3DSystem.UI.Chat.MainWndAdsHeight - 7);
		----_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
		--_parent:AddChild(_this);
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- onclick function on the login user icon
function Map3DSystem.UI.Chat.MainWnd.OnUserIconClick()
	local _appName = Map3DSystem.UI.Chat.MainWndObj.app.name;
	local _wndName = Map3DSystem.UI.Chat.MainWndObj.name;
	local color = "160 160 255";
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.PaintWindow(_appName, _wndName, color);
end

-- owner draw function of the contact list treeview
function Map3DSystem.UI.Chat.MainWnd.DrawContactNodeHandler(_parent, treeNode)
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
	
	if(treeNode.type == "group") then
		-- render contact group TreeNode: a check box and a text button. click either to toggle the node.
		width = 24 -- check box width
		if(treeNode:GetChildCount() > 0) then
			-- group with children
			-- checkbox
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/IM/group-arrow-down.png";
			else
				_this.background = "Texture/3DMapSystem/IM/group-arrow-right.png";
			end
			
			-- text button
			_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			
			-- set text
			_this.text = treeNode.Text;
		else
			-- no users in this group	
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/IM/group-arrow-down.png";
			else
				_this.background = "Texture/3DMapSystem/IM/group-arrow-right.png";
			end
			
			_this=ParaUI.CreateUIObject("text","b","_lt", left, 0, nodeWidth - left-1, height);
			_parent:AddChild(_this);
			_this:GetFont("text").format=36; -- single line and vertical align
			
			-- set text
			_this.text = (treeNode.Text or "").." (空)";
		end
	elseif(treeNode.type == "user") then
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
		_this.onclick = string.format(";Map3DSystem.UI.Chat.MainWnd.ShowUserOnMap(%q)", treeNode.Name);
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

-- update the entire UI
function Map3DSystem.UI.Chat.MainWnd.UpdateContactList()
	if(Map3DSystem.UI.Chat.RosterBegin) then 
		return 
	end
	
	local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	local _this = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	if(_this:IsValid() == true) then
		_this=_this:GetChild("IM_Contact_Cont");
		if(_this:IsValid() == true) then
			-- update contact list UI for this user. Here I used a simple listbox.
			local treeView = CommonCtrl.GetControl("treeViewContacts");
			if(treeView~=nil) then
				treeView.RootNode:ClearAllChildren();
				local node = treeView.RootNode;
				-- add groups
				local groups;
				if(jc ~= nil) then
					-- online mode
					groups= jc:GetRosterGroups();
					Map3DSystem.UI.Chat.RosterHistory.Groups = groups;
				else
					-- offline mode, read history
					groups = Map3DSystem.UI.Chat.RosterHistory.Groups;
				end
				if(groups~=nil) then
					local groupname;
					for groupname in string.gfind(groups, "([^;]+)") do
						node:AddChild( CommonCtrl.TreeNode:new({Text = groupname, Name = groupname, type = "group"}) );
					end
					node:AddChild( CommonCtrl.TreeNode:new({Text = "离线联系人", Name = "Offline Contacts", type = "group"}) );
				end
				-- get all users inside contact group
				local names;
				if(jc ~= nil) then
					-- online mode
					names = jc:GetRosterItems();
					Map3DSystem.UI.Chat.RosterHistory.Names = names;
				else
					-- offline mode, read history
					names = Map3DSystem.UI.Chat.RosterHistory.Names;
				end
				if(names~=nil) then
					local userJID;
					for userJID in string.gfind(names, "([^;]+)") do
						--log("roster item begins\n");log(jc:GetRosterItemDetail(userJID));
						local userDetail;
						if(jc ~= nil) then
							-- online mode
							userDetail = commonlib.LoadTableFromString(jc:GetRosterItemDetail(userJID));
							Map3DSystem.UI.Chat.RosterHistory.UserDetails[userJID] = userDetail;
						else
							-- offline mode, read history
							userDetail = Map3DSystem.UI.Chat.RosterHistory.UserDetails[userJID];
						end
						
						if(userDetail~=nil) then
							local _, detail;
							for _, detail in ipairs(userDetail) do
								local groupNode = treeView.RootNode:GetChildByName(detail.groupname);
								if(detail.presenceType ~= -1) then
									-- add to offline contact group
									groupNode = treeView.RootNode:GetChildByName("Offline Contacts");
									groupNode:AddChild( CommonCtrl.TreeNode:new({Text = userJID, Name = userJID, type = "user", Tag = detail,}) );
									break;
								end
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

-- called when clicking a user
-- @param treeNode: treenode of the contact treeview
function Map3DSystem.UI.Chat.MainWnd.OnClickUser(treeNode)
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
					onclick = Map3DSystem.UI.Chat.MainWnd.OnClickGroupContextMenuItem,
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

-- group context menu event handler
-- @param menuItem: 
-- @param UserNode: 
function Map3DSystem.UI.Chat.MainWnd.OnClickGroupContextMenuItem(menuItem, UserNode)
	if(menuItem.Name == "ChatWithGroup") then
	elseif(menuItem.Name == "RenameGroup") then
	elseif(menuItem.Name == "DeleteGroup") then
	elseif(menuItem.Name == "CreateGroup") then
	elseif(menuItem.Name == "PasteUser") then
	end
end

-- user context menu event handler
-- @param menuItem: 
-- @param UserNode: 
function Map3DSystem.UI.Chat.MainWnd.OnClickUserContextMenuItem(menuItem, UserNode)
	if(menuItem.Name == "ChatWithUser") then
		Map3DSystem.UI.Chat.MainWnd.ShowChatWithUser(UserNode.Name);
		
	elseif(menuItem.Name == "ViewOnMap") then
		Map3DSystem.UI.Chat.MainWnd.ShowUserOnMap(UserNode.Name)
		
	elseif(menuItem.Name == "DeleteUser") then
		_guihelper.MessageBox("您真的要删除下面联系人么?\n"..UserNode.Name, function (sJID) 
			-- remove user from contact list
			if(sJID~=nil) then
				local jc = Map3DSystem.UI.Chat.GetConnectedClient();
				if(jc~=nil) then
					jc:RemoveRosterItem(sJID);
				end
			end
		end, UserNode.Name)
		
	elseif(menuItem.Name == "CopyUser") then
	end
end

-- add the contact shown in the textBoxAddContact text box
function Map3DSystem.UI.Chat.MainWnd.AddContact()
	local tmp=ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	if(tmp:IsValid()) then	
		local tmp=tmp:GetChild("IM_Contact_Cont");
		if(tmp:IsValid()) then		
			local tmp=tmp:GetChild("textBoxAddContact");
			if(tmp:IsValid()) then
				local UserToAdd = tmp.text;
				if(UserToAdd ~= nil and UserToAdd ~="") then
					local jc = Map3DSystem.UI.Chat.GetConnectedClient();
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

-- show the ChatWnd instance for a given sJID, it will create the window if it has never been created before.
-- @param sJID: the JID of the communicate user
function Map3DSystem.UI.Chat.MainWnd.ShowChatWithUser(sJID)
	if(not sJID) then return end
	
	if(not Map3DSystem.UI.Chat.MainWndObj) then
		log("error: Main chat window object is not yet inited in ShowChatWithUser() call.\n");
		return;
	end
	
	-- get the window frame object if not exists, create one.
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd.lua");
	local ctl = Map3DSystem.UI.Chat.ChatWnd.GetWindowFrame(sJID);
	ctl:show(true);
	
	-- TODO: dirty set the newly created window and tab bar icon status
	Map3DSystem.UI.Chat.MainWnd.UpdateContactList()
	
	--if(not ParaUI.GetUIObject(WndName):IsValid()) then	
		---- create the object if it does not exist
		--local ctl = CommonCtrl.IM_ChatWnd:new{
			--name = WndName,
			--alignment = "_lt",
			--left=500, top=60,
			--width = 512,
			--height = 290,
			--parent = nil,
			--to_JID = sJID,
		--};
		--ctl:Show(true);
	--end
	--return CommonCtrl.GetControl(WndName);
end

-- TODO: show the user on the map
-- TODO: write proper command for map application
function Map3DSystem.UI.Chat.MainWnd.ShowUserOnMap(sJID)
	_guihelper.MessageBox("TODO: Show user "..sJID..". on 3d map \n");
end

-- dirty change personal msg
-- TODO: more actions for editBox
function Map3DSystem.UI.Chat.MainWnd.OnChangePersonalMsg()
	local _main = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	local _editBox = _main:GetChild("textBoxPersonalMsg");
	if(_editBox.text == "<输入个人消息>") then
		_editBox.text = "";
	end
	if(virtual_key == Event_Mapping.EM_KEY_RETURN) then
		if(_editBox.text ~= "<输入个人消息>") then
			Map3DSystem.UI.Chat.MainWnd.SetUserPersonalMSG(_editBox.text);
		end
	end
end

-- set the user's personal information
-- @param personalMSG: the personal information message
-- @param bBroadcast: whether broadcast the user presence information, default true
function Map3DSystem.UI.Chat.MainWnd.SetUserPersonalMSG(personalMSG, bBroadcast)
	local _main = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	local _editBox = _main:GetChild("textBoxPersonalMsg");
	_editBox.text = personalMSG;
	
	if(bBroadcast == nil) then
		bBroadcast = true;
	end
	
	if(bBroadcast == true) then
		local jc = Map3DSystem.UI.Chat.GetConnectedClient();
		jc:SetPresence(-1, personalMSG, nil, 0);
	end
end

-- change the main window current user status according to the control selection, automaticly set the user's presence information
-- @param sCtrlName: dropdownlistbox name
function Map3DSystem.UI.Chat.MainWnd.OnSelectUserStatus(sCtrlName)

	local ctrl = CommonCtrl.GetControl(sCtrlName);
	if(ctrl~=nil)then
		local selection = ctrl:GetText();
		
		local jc = Map3DSystem.UI.Chat.GetConnectedClient();
	
		if(selection == "在线") then
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("online");
		elseif(selection == "接受聊天") then
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("chat");
			jc:SetPresence(-1, "andy", "chat", 0); -- TODO: add nick name
		elseif(selection == "忙碌") then
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("busy");
			jc:SetPresence(-1, "andy", "dnd", 0); -- TODO: add nick name
		elseif(selection == "离开") then
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("away");
			jc:SetPresence(-1, "andy", "xa", 0); -- TODO: add nick name
		elseif(selection == "离线") then
			Map3DSystem.UI.Chat.MainWnd.SetUserStatus("offline");
			jc:SetPresence(-1, "andy", "offline", 0); -- TODO: add nick name
		end
	end
end

-- set main window current user status, automaticly set the user's presence information
function Map3DSystem.UI.Chat.MainWnd.SetUserStatus(status)

	local _this = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	if(_this:IsValid() == true) then
		local ctrl = CommonCtrl.GetControl("comboBoxChatUserStatus");
		if(ctrl~=nil)then
			
			local _main = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
			local _icon = _main:GetChild("btnIMIcon");
			local jc = Map3DSystem.UI.Chat.GetConnectedClient();
			
			if(jc ~= nil) then
				if(status == "online") then
					ctrl:SetText(jc.User .." - ".. Map3DSystem.UI.Chat.UserStatus[1]);
					_icon.background = "Texture/3DMapSystem/IM/online64.png";
					jc:SetPresence(-1, nil, "online", 0);
				elseif(status == "chat") then
					ctrl:SetText(jc.User .." - ".. Map3DSystem.UI.Chat.UserStatus[2]);
					_icon.background = "Texture/3DMapSystem/IM/chatty64.png";
					jc:SetPresence(-1, nil, "chat", 0); 
				elseif(status == "busy") then
					ctrl:SetText(jc.User .." - ".. Map3DSystem.UI.Chat.UserStatus[3]);
					_icon.background = "Texture/3DMapSystem/IM/busy64.png";
					jc:SetPresence(-1, nil, "dnd", 0);
				elseif(status == "away") then
					ctrl:SetText(jc.User .." - ".. Map3DSystem.UI.Chat.UserStatus[4]);
					_icon.background = "Texture/3DMapSystem/IM/away64.png";
					jc:SetPresence(-1, nil, "xa", 0);
				elseif(status == "offline") then
					ctrl:SetText(jc.User .." - ".. Map3DSystem.UI.Chat.UserStatus[5]);
					_icon.background = "Texture/3DMapSystem/IM/offline64.png";
					jc:SetPresence(-1, nil, "offline", 0);
				end
			end
		end
	end
end

-- add a new chatting tab in tab contianer in main chat window
-- @param sJID: the communicating user JID
function Map3DSystem.UI.Chat.MainWnd.AddChattingTab(sJID)
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp(Map3DSystem.UI.Chat.MainWndObj.app.name);
	local _wnd = _app:FindWindow(sJID);
	if(_wnd == nil) then
		log("error: the window object not registered. in AddChattingTab(sJID) call \n");
		return;
	end
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(Map3DSystem.UI.Chat.MainWndObj.app.name, sJID);
	if(_frame == nil) then
		log("error: the window frame object not registered. in AddChattingTab(sJID) call \n");
		return;
	end
	
	local nCount = table.getn(Map3DSystem.UI.Chat.ChattingTab);
	if(nCount == 0) then
		Map3DSystem.UI.Chat.ChattingTab[nCount+1] = sJID;
	else
		local k, v;
		for k,v in pairs(Map3DSystem.UI.Chat.ChattingTab) do
			if(v == sJID) then
				log("warning: the chatting window is already added to chatting tab.\n");
				return;
			end
		end
		Map3DSystem.UI.Chat.ChattingTab[nCount+1] = sJID;
	end
	
	Map3DSystem.UI.Chat.MainWnd.RefreshChattingTab();
end

-- remove a chatting tab in tab contianer in main chat window
-- @param sJID: the communicating user JID
function Map3DSystem.UI.Chat.MainWnd.RemoveChattingTab(sJID)
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp(Map3DSystem.UI.Chat.MainWndObj.app.name);
	local _wnd = _app:FindWindow(sJID);
	if(_wnd == nil) then
		log("error: the window object not registered. in RemoveChattingTab(sJID) call \n");
		return;
	end
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(Map3DSystem.UI.Chat.MainWndObj.app.name, sJID);
	if(_frame == nil) then
		log("error: the window frame object not registered. in RemoveChattingTab(sJID) call \n");
		return;
	end
	
	local nCount = table.getn(Map3DSystem.UI.Chat.ChattingTab);
	local removePos = nCount + 2;
	if(nCount == 0) then
		log("warning: ChattingTab is empty. in RemoveChattingTab(sJID) call\n");
		return;
	else
		local k, v;
		for k,v in pairs(Map3DSystem.UI.Chat.ChattingTab) do
			if(v == sJID) then
				Map3DSystem.UI.Chat.ChattingTab[k] = nil;
				removePos = k;
			else
				if(k > removePos) then
					Map3DSystem.UI.Chat.ChattingTab[k-1] = v;
				end
			end
		end
		Map3DSystem.UI.Chat.ChattingTab[nCount] = nil;
		Map3DSystem.UI.Chat.MainWnd.RefreshChattingTab();
	end
	if(removePos == nCount + 2) then
		log("error: the chatting window is not found in chatting tab. in RemoveChattingTab(sJID) call\n");
		return;
	end
end

-- refresh the chatting tab in main chat window
function Map3DSystem.UI.Chat.MainWnd.RefreshChattingTab()
	local contactPosX = Map3DSystem.UI.Chat.MainWndContactsPosX;
	local contactPosY = Map3DSystem.UI.Chat.MainWndContactsPosY;
	local _parent;
	local _main = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	ParaUI.Destroy("IM_Tab_Cont");
	-- NOTE: the height 250 here will be adjusted according to the new window frame size
	local _tab = ParaUI.CreateUIObject("container", "IM_Tab_Cont", "_ml", 
			0, contactPosY + 1, contactPosX + 1, Map3DSystem.UI.Chat.MainWndAdsHeight + 10);
	--_tab.background = "Texture/3DMapSystem/IM/tab-chatting-BG.png: 30 30 1 30";
	_tab.background = "";
	_tab.visible = false;
	_main:AddChild(_tab);
	
	local nCount = table.getn(Map3DSystem.UI.Chat.ChattingTab);
	
	local _initPositionX = 8;
	local _initPositionY = 8;
	local _initIconWidth = 36;
	local _initIconHeight = 36;
	local _initGap = 2;
	local _this;
	local k, v;
	for k, v in pairs(Map3DSystem.UI.Chat.ChattingTab) do
		_this = ParaUI.CreateUIObject("container", "tabBG"..k, "_lt", 
			_initPositionX, _initPositionY + (k-1)*(_initIconHeight + _initGap), _initIconWidth, _initIconHeight);
		--_this.background = "Texture/3DMapSystem/IM/tab-chatting.png: 30 30 1 30";
		--_this.background = "Texture/3DMapSystem/IM/ContactTabBtn_BG.png: 8 8 8 8";
		_this.background = "";
		_tab:AddChild(_this);
		_parent = _this;
		
		local _name = Map3DSystem.UI.Chat.MainWnd.GetNameFromJID(v);
		
		_this = ParaUI.CreateUIObject("button", "tab"..k, "_lt", 
			2, 2, 32, 32);
		_this.tooltip = _name;
		_this.background = "Texture/3DMapSystem/IM/online.png"; -- TODO: online status
		_this.onclick = ";Map3DSystem.UI.Chat.MainWnd.OnClickChattingTab(\""..v.."\");";
		_parent:AddChild(_this);
	end
end

-- return the name of a Jabber ID, if not including any "@" sign the whole JID is returned
-- @param sJID: the given JID
-- @return: the name of the JID
-- e.g. for JID:"andy@paraweb3d.com" it returns "andy"
function Map3DSystem.UI.Chat.MainWnd.GetNameFromJID(sJID)
	local _at = string.find(sJID, "@", 1);
	local _name;
	if(_at == nil) then
		return sJID;
	else
		return string.sub(sJID, 1, _at-1);
	end
end

-- update the contact status, automaticly update the chat window contact status
-- @param sJID: contact's JID
-- @param status: status of the contact
-- @param personalMSG: personal information message
function Map3DSystem.UI.Chat.MainWnd.UpdateContactStatus(sJID, status, personalMSG)

	local _main = ParaUI.GetUIObject("Map3DSystem_Chat_Main_cont");
	local _tab = _main:GetChild("IM_Tab_Cont");
	local k, v;
	for k, v in pairs(Map3DSystem.UI.Chat.ChattingTab) do
		if(v == sJID) then
			local _BG = _tab:GetChild("tabBG"..k);
			local _icon = _BG:GetChild("tab"..k);
			local _name = Map3DSystem.UI.Chat.MainWnd.GetNameFromJID(sJID);
			_icon.tooltip = _name.." - "..personalMSG;
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
	
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd.lua");
	Map3DSystem.UI.Chat.ChatWnd.UpdateContactStatus(sJID, status, personalMSG);
end

-- onclick chatting tab info
-- @param sJID: communicating user's JID
function Map3DSystem.UI.Chat.MainWnd.OnClickChattingTab(sJID)
	NPL.load("(gl)script/ide/os.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _app = CommonCtrl.os.CreateGetApp(Map3DSystem.UI.Chat.MainWndObj.app.name);
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(Map3DSystem.UI.Chat.MainWndObj.app.name, sJID);
	
	_frame.wnd:SendMessage(_frame.wnd.name, CommonCtrl.os.MSGTYPE.WM_TOGGLE);
end