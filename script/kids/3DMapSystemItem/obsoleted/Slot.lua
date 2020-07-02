--[[
Title: item slot
Author(s): WangTian
Date: 2009/2/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemItem/Slot.lua");
------------------------------------------------------------
]]

local Slot = {
	type = nil, -- "Bag" or "Link" or "Equip"
		-- choose the following property according to the slot type
		itemids = nil, -- item instance ids
		linkid = nil, -- directly link to the global store id
		equipid = nil, -- item instance id that equipted on the character slot
	-- if the slot is contains a bag item
	bag = nil, -- bag instance id
	position = nil, -- slot in bag container or position in quicklaunch bar or slot in character
	-- slot type position 0 is a special position reserved for the link object that picked from external item object
	-- e.g. items in menu list, items in store or other none bag/link/equip items
};
commonlib.setfield("Map3DSystem.Item.Slot", Slot)


---------------------------------
-- functions
---------------------------------
function Slot:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- get slot type
function Slot:GetType()
	return self.type;
end

-- get slot position
function Slot:GetPosition()
	return self.position;
end

-- get slot item global store id
-- NOTE: no matter what type of item belongs to the slot bag, link or equipment, 
--		there is only one item that the slot reference in the global store.
--		e.x: only bag items with the same global store id can be stacked in on bag slot
function Slot:GetGlobalStoreID()
	if(self.type == "Bag") then
		return nil;
	elseif(self.type == "Link") then
		return self.linkid;
	elseif(self.type == "Equip") then
		return nil;
	end
end

-- Get the Icon of this object
-- @param callbackFunc: function (filename) end. if nil, it will return the icon texture path. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Slot:GetIcon(callbackFunc)
	local gsID = self:GetGlobalStoreID();
	local gsTemplate = Map3DSystem.Item.ItemManager.ReadGlobalStoreItem(gsID);
	if(gsTemplate ~= nil) then
		if(gsTemplate.type == 2) then
			-- Exe_App
			local app = Map3DSystem.App.AppManager.GetApp(gsTemplate.appkey);
			if(app) then
				return app.icon or app.Icon;
			end
		elseif(gsTemplate.type == 3) then
			-- Exe_AppCommand
			local cmd = Map3DSystem.App.Commands.GetCommand(gsTemplate.CommandName)
			if(cmd) then
				return cmd.icon or cmd.Icon;
			end
		end
	end
end








-- invoke default method of this item
function Slot:InvokeDefaultMethod()
	self:InvokeMethod("Default");
end

-- invoke a given method of this ItemBase using appropriate ItemBase handler
function Slot:InvokeMethod(funcName, ...)
	if(funcName == "Default") then
		-- TODO: invoke default method
		if(self.type == "Bag") then
			return nil;
		elseif(self.type == "Link") then
			local gsTemplate = Map3DSystem.Item.ItemManager.ReadGlobalStoreItem(self.linkid);
			if(gsTemplate ~= nil) then
				gsTemplate:OnClick();
			end
		elseif(self.type == "Equip") then
			return nil;
		end
	end
end



-- Get the tooltip of this object
-- @param callbackFunc: function (text) end. if nil, it will return the text. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Slot:GetTooltip(callbackFunc)
	
end

-- Get the description in MCML format
-- @param callbackFunc: function (pageText) end. 
function Slot:GetDesc(callbackFunc)
end

-- see Map3DSystem.Item.ItemTypes
function Slot:GetType()
	return self.type
end

-- get attribute of an item
-- @param attrname: attribute name
function Slot:GetAttribute(attrname)
	return self[attrname];
end

-- When this item is clicked in 3d space
function Slot:OnClick3D(mouseButton)
end

function Slot:GetTitle()
	return self:GetTooltip();
end

function Slot:GetSubTitle()
	return self:GetTooltip();
end

-- When this item is clicked
-- @param mouseButton: "left", "middle", "right"
function Slot:OnClick(mouseButton)
	if(mouseButton == "left") then
		local ItemManager = Map3DSystem.Item.ItemManager;
		if(ItemManager.dragFromSlot ~= nil) then
			self:OnDragEnd();
		else
			self:OnDragBegin();
		end
	elseif(mouseButton == "right") then
		self:InvokeDefaultMethod();
	end
end

function Slot.DoFramemove()
	local ItemManager = Map3DSystem.Item.ItemManager;
	if(ItemManager.dragFromSlot ~= nil) then
		-- hide mouse cursor with empty texture
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = "none"});
		-- as soon as the dragFromSlot contains specific slot info, show the item in the slot on cursor
		local icon = ItemManager.dragFromSlot:GetIcon();
		local _cursorItemIcon = ParaUI.GetUIObject("CursorItemIcon");
		if(_cursorItemIcon:IsValid() == false) then
			_cursorItemIcon = ParaUI.CreateUIObject("container", "CursorItemIcon", "_lt", -32, -32, 32, 32);
			_cursorItemIcon.enabled = false;
			_cursorItemIcon:AttachToRoot();
		end
		-- set item icon and translation to the mouse cursor position
		_cursorItemIcon.background = icon;
		_cursorItemIcon.zorder = 1000;
		local mouseX, mouseY = ParaUI.GetMousePosition();
		_cursorItemIcon.translationx = mouseX + 32;
		_cursorItemIcon.translationy = mouseY + 32;
		_cursorItemIcon.visible = true;
	else
		-- show default mouse cursor
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = "default"});
		-- invisible the dragFromSlot icon
		local _cursorItemIcon = ParaUI.GetUIObject("CursorItemIcon");
		if(_cursorItemIcon:IsValid() == true) then
			_cursorItemIcon.translationx = 0;
			_cursorItemIcon.translationy = 0;
			_cursorItemIcon.visible = false;
		end
	end
end

-- set the ItemManager.dragFromSlot, turn on the click receiver when the dragFromSlot is not nil
-- SlotClickRecv button handles the clicking outside UI objects
local function SetDragFromSlot(slot)
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.dragFromSlot = slot;
	
	local _clickRecv = ParaUI.GetUIObject("SlotClickRecv");
	if(_clickRecv:IsValid() == false) then
		_clickRecv = ParaUI.CreateUIObject("button", "SlotClickRecv", "_fi", 0, 0, 0, 0);
		_clickRecv.background = "Texture/3DMapSystem/Chat/message.png: 6 6 6 6";
		_clickRecv.visible = false;
		_clickRecv.zorder = -10;
		-- set the cursor with transparent texture
		_clickRecv.cursor = "texture/Transparent.png";
		--_clickRecv.color = "255 255 255 10";
		_clickRecv.onclick = ";Map3DSystem.Item.Slot.OnClickSlotClickRecv();";
		_clickRecv:AttachToRoot();
	end
	local _clickRecv = ParaUI.GetUIObject("SlotClickRecv");
	if(_clickRecv:IsValid() == true) then
		if(slot == nil) then
			_clickRecv.visible = false;
		else
			_clickRecv.visible = true;
		end
	end
end

-- 
function Slot:OnDragBegin()
	local ItemManager = Map3DSystem.Item.ItemManager;
	if(ItemManager.dragFromSlot ~= nil) then
		if(self.type == "Bag") then
		elseif(self.type == "Link") then
			-- replace the target slot with the dragFromSlot
			local fromType = ItemManager.dragFromSlot:GetType();
			if(fromType == "Bag") then
			elseif(fromType == "Link") then
				local fromPosition = ItemManager.dragFromSlot:GetPosition();
				if(fromPosition == self:GetPosition()) then
					-- drag from self
					SetDragFromSlot(nil);
				elseif(self:GetGlobalStoreID() == nil or self:GetGlobalStoreID() == 0) then
					-- drag link to empty link
					Map3DSystem.Item.ItemManager.SwapLink(self:GetPosition(), ItemManager.dragFromSlot:GetPosition());
					--self.linkid = ItemManager.dragFromSlot.linkid;
					--ItemManager.dragFromSlot.linkid = 0;
					SetDragFromSlot(nil);
				elseif(type(self:GetGlobalStoreID()) == "number") then
					-- drag link to non-empty link
					Map3DSystem.Item.ItemManager.SwapLink(self:GetPosition(), ItemManager.dragFromSlot:GetPosition());
					SetDragFromSlot(self);
				end
			elseif(fromType == "Equip") then
			end
		elseif(self.type == "Equip") then
		end
	else
		if(self:GetGlobalStoreID() == nil or self:GetGlobalStoreID() == 0) then
			-- drag from slot reference to no GlobalStoreID, empty slot
		else
			-- set the dragFromSlot
			SetDragFromSlot(self);
		end
	end
	-- make sure that the dragging status is updated immediately
	Slot.DoFramemove();
end

-- drag end will be translated to OnDragBegin function calls to utilized to the click move metaphore
function Slot:OnDragEnd()
	local ItemManager = Map3DSystem.Item.ItemManager;
	if(self.type == "Bag") then
	elseif(self.type == "Link") then
		if(ItemManager.dragFromSlot ~= nil) then
			-- drag from slot
			--self:OnDragBegin();
			if(self.type == "Bag") then
			elseif(self.type == "Link") then
				-- replace the target slot with the dragFromSlot
				local fromType = ItemManager.dragFromSlot:GetType();
				if(fromType == "Bag") then
				elseif(fromType == "Link") then
					local fromPosition = ItemManager.dragFromSlot:GetPosition();
					
					if(fromPosition == 0) then
						-- drop from the temp slot
					elseif(fromPosition > 0) then
						-- drop from existing slot
					end
					if(fromPosition == self:GetPosition()) then
						-- drag from self
						SetDragFromSlot(nil);
					elseif(self:GetGlobalStoreID() == nil or self:GetGlobalStoreID() == 0) then
						-- drag link to empty link
						Map3DSystem.Item.ItemManager.SwapLink(self:GetPosition(), ItemManager.dragFromSlot:GetPosition());
						--self.linkid = ItemManager.dragFromSlot.linkid;
						--ItemManager.dragFromSlot.linkid = 0;
						SetDragFromSlot(nil);
					elseif(type(self:GetGlobalStoreID()) == "number") then
						-- drag link to non-empty link
						Map3DSystem.Item.ItemManager.SwapLink(self:GetPosition(), ItemManager.dragFromSlot:GetPosition());
						SetDragFromSlot(self);
					end
				elseif(fromType == "Equip") then
				end
			elseif(self.type == "Equip") then
			end
		else
			-- drag from nothing?!
		end
		--self.linkid
	elseif(self.type == "Equip") then
	end
	-- make sure that the dragging status is updated immediately
	Slot.DoFramemove()
end

-- slot item drop
function Slot:OnDrop()
end

-- slot click receiver will drop the dragFromSlot link or item if exists
function Slot.OnClickSlotClickRecv()
	local ItemManager = Map3DSystem.Item.ItemManager;
	if(ItemManager.dragFromSlot ~= nil) then
		-- drop the dragFromSlot link or item
		local type = ItemManager.dragFromSlot:GetType();
		if(type == "Bag") then
		elseif(type == "Link") then
			local position = ItemManager.dragFromSlot:GetPosition();
			if(position == 0) then
				-- drop an empty link slot
				SetDragFromSlot(nil);
			elseif(position > 0) then
				-- drop a non-empty link
				Map3DSystem.Item.ItemManager.SetLink(position, nil)
				SetDragFromSlot(nil);
			end
		elseif(type == "Equip") then
		end
		SetDragFromSlot(nil);
	else
		-- clicking on the SlotClickRecv container when the dragFromSlot is empty
		-- this should be some BUG generated when the container is visible but dragFromSlot is on
		log("error: SlotClickRecv container is visible but no dragFromSlot info available.\n")
		SetDragFromSlot(nil);
	end
end