--[[
Title: Chat system contacts bar
Author(s): WangTian
Date: 2008/8/13
Desc: contacts bar is a container shown on the right bottom of the screen, right above the status bar.
		Each item in the contacts bar is an icon represents a user in the chat contact list. Each icon 
		is accociated with a chat window which is triggered by the user or receive a message. 
		Chat window can be minimized to the coresponding icon. Online status of the contact is shown on 
		the right bottom 1/4 corner over the icon. If new message received, and chat window is minimized(not visible), 
		new messages are shown with a bubble.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ContactsBar.lua");
------------------------------------------------------------
]]

--if(not Map3DSystem.App.Chat.ContactsBar) then Map3DSystem.App.Chat.ContactsBar = {}; end

local ContactsBar = commonlib.gettable("Map3DSystem.App.Chat.ContactsBar");

ContactsBar.ContactsBarNodes = CommonCtrl.TreeNode:new({Text = "contactsbar", Name = "contactsbar"});


-- add a status bar task.
-- @param task:
--	{
--		name = "Chat1",
--		icon = "optional icon, usually has it",
--		text = "this is optional",
--		tooltip = "some text",
--		commandName = "",
--	}
-- @param priority: number
--		Priority defines the position of the given command in the status bar. Higher priority shown on the right.
--		For those items with the same priority, the more recent added has lower priority which shows on the left.
-- Here are some default priorities for official applications:
--		ChatWindow: 3, OfficalAppStatus: 8, DefaultPriority: 5
function ContactsBar.AddContact(contact, priority)
	if(contact ~= nil and contact.name ~= nil) then
		-- default priority
		priority = priority or 5;
		
		if(ContactsBar.ContactsBarNodes:GetChildByName(contact.name)) then
			log("Command: "..contact.name.." already added into the contacts bar\n");
			return;
		end
		
		ContactsBar.Accumulator = ContactsBar.Accumulator or 1000;
		ContactsBar.Accumulator = ContactsBar.Accumulator - 1;
		
		ContactsBar.ContactsBarNodes:AddChild(CommonCtrl.TreeNode:new({
			Name = contact.name, 
			priority = priority,
			comparePriority = priority * 1000 + ContactsBar.Accumulator,
			contact = contact,
			}));
		ContactsBar.ContactsBarNodes:SortChildren(CommonCtrl.TreeNode.GenerateGreaterCFByField("comparePriority"));
		--Map3DSystem.UI.AppTaskBar.StatusBarNode:SortChildren(CommonCtrl.TreeNode.GenerateLessCFByField("comparePriority"));
		
		-- refresh the contacts bar
		ContactsBar.Refresh();
	end
end

-- remove contact icon from the contacts bar
-- @param contactName: the task to be removed from the contacts bar
function ContactsBar.RemoveContact(contactName)
	if(ContactsBar.ContactsBarNodes:GetChildByName(contactName)) then
		ContactsBar.ContactsBarNodes:RemoveChildByName(contactName);
		
		-- refresh the contacts bar
		ContactsBar.Refresh();
	end
end

-- remove all tasks in contacts bar
function ContactsBar.ClearContacts()
	log("warning: All contactsBar commands cleared\n")
	ContactsBar.ContactsBarNodes:ClearAllChildren();
	
	-- refresh the contacts bar
	ContactsBar.Refresh();
end

-- refresh the contacts bar with the UI parent container
function ContactsBar.Refresh(_parent)
	
	_parent = _parent or ContactsBar.parentUIObj;
	if(_parent == nil) then
		return;
	end
	
	if(_parent:IsValid() == false) then
		log("Invalid parent UI object in ContactsBar.Refresh()\n");
		ContactsBar.parentUIObj = nil;
		return;
	end
	
	-- record the _parent for refresh
	ContactsBar.parentUIObj = _parent;
	
	-- remove all children, since we will rebuild all. 
	_parent:RemoveAll();
	
	local iconSize = 24;
	local contactHeight = 24;
	local contactWidth = 24;
	local left = 6;
	local iconTop = (contactHeight - iconSize)/2;
	
	_bar = ParaUI.CreateUIObject("container", "ContactsBar_cont", "_fi", 0, 0, 0, 0);
	_bar.background = "";
	_parent:AddChild(_bar);
	
	
	--
	-- all other custom buttons added via application interface
	--
	local _,_, maxWidth = _parent:GetAbsPosition();
	maxWidth = maxWidth - 22;
	local bNoSpaceLeft;
	
	local count = 0; -- number of icon created. 
	local index, contact;
	for index, contact in ipairs(Map3DSystem.App.Chat.ContactsBar.ContactsBarNodes.Nodes) do
		--if(contact.AppCommand) then	
			local contact = contact.contact;
			-- LiXizhi 2008.6.22, added automatic taskWidth
			contactWidth = 0;
			if(contact.icon) then
				contactWidth = contactWidth+iconSize+iconTop;
			end
			if(contact.text) then
				contactWidth = contactWidth+_guihelper.GetTextWidth(contact.text);
			end
			if(contactWidth == 0) then
				contactWidth = 16;
			end
			
			if((left + contactWidth) < maxWidth) then
			
				local _contact = ParaUI.CreateUIObject("container", "Contact_"..contact.name, "_rt", -(left + contactWidth), 6, contactWidth, contactHeight);
				_contact.background = "";
				_bar:AddChild(_contact);
				
				local _left = 0
				if(contact.icon) then
					local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", _left, iconTop, iconSize, iconSize);
					_icon.background = contact.icon;
					_guihelper.SetUIColor(_icon, "255 255 255");
					_icon.animstyle = 13;
					_icon.onclick = string.format(";Map3DSystem.App.Commands.Call(%q);", contact.commandName);
					_contact:AddChild(_icon);
					if(contact.tooltip) then
						_icon.tooltip = contact.tooltip;
					end
					_left = _left+iconSize+iconTop
				end	
				
				if(contact.text) then
					local _text = ParaUI.CreateUIObject("button", "Text", "_lt", _left, 0, contactWidth-left, contactHeight);
					_text.background = "";
					_text.text = contact.text;
					_text.onclick = string.format(";Map3DSystem.App.Commands.Call(%q);", contact.commandName);
					if(contact.tooltip) then
						_text.tooltip = contact.tooltip;
					end
					_contact:AddChild(_text);
				end	
				
				left = left + contactWidth + 2;
			else
				bNoSpaceLeft = true;
			end	
			
			count = count + 1;
			-- 5 is maximum status bar icon number
			if(bNoSpaceLeft) then
				-- show extension button << using a popup menu control.
				StatusBar.ExtensionItemIndex = index;
				
				local _this = ParaUI.CreateUIObject("button", "extBtn", "_rt", -(left + 16), 5, 16, 16)
				_this.background = "Texture/3DMapSystem/Desktop/ext_left.png";
				_this.animstyle = 12;
				_this.onclick = ";Map3DSystem.App.Chat.ContactsBar.ShowContactsBarExtensionMenu();"
				_bar:AddChild(_this);
				break;
			end
		--end	
	end
	
	-- bring up a context menu for selecting extension items. 
	function Map3DSystem.App.Chat.ContactsBar.ShowContactsBarExtensionMenu()
		local ctl = CommonCtrl.GetControl("statusbar.ExtensionMenu");
		if(ctl == nil)then
			ctl = CommonCtrl.ContextMenu:new{
				name = "statusbar.ExtensionMenu",
				width = 130,
				height = 150,
				DefaultIconSize = 24,
				DefaultNodeHeight = 26,
				container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
				onclick = function (node, param1)
						if(node.commandName ~= nil) then
							Map3DSystem.App.Commands.Call(node.commandName);
						end
					end,
				AutoPositionMode = "_lb",
			};
		end
		local _this = Map3DSystem.App.ActionFeed.StatusBar.parentUIObj:GetChild("extBtn");
		if(_this:IsValid()) then
			local x, y, width, height = _this:GetAbsPosition();
			
			ctl.RootNode:ClearAllChildren();
			
			local index, node
			
			local nSize = Map3DSystem.App.Chat.ContactsBar.ContactsBarNodes:GetChildCount();
			
			for index = StatusBar.ExtensionItemIndex, nSize do
				ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(CommonCtrl.TreeNode:new({
					Text = Map3DSystem.App.Chat.ContactsBar.ContactsBarNodes.Nodes[index].text, 
					Name = Map3DSystem.App.Chat.ContactsBar.ContactsBarNodes.Nodes[index].name, 
					commandName = Map3DSystem.App.Chat.ContactsBar.ContactsBarNodes.Nodes[index].commandName, 
					Icon = Map3DSystem.App.Chat.ContactsBar.ContactsBarNodes.Nodes[index].icon})));
			end
			
			ctl:Show(x, y);
		end	
	end
end