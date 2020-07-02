--[[
Title: the base class for all game Items
Author(s): WangTian, originally drafted by LiXizhi
Date: 2009/2/12
Desc: the base class for all game Item, such as slotted toolbar item, tradable bag item, castable skill effects, and 3D pickable items.
Each item has a type, one can derive your own item (handler) class from the ItemBase class. Please see Iten_Unknown.lua for an example. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemItem/ItemBase.lua");
local ItemBase = Map3DSystem.Item.ItemBase:new{}
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/Types.lua");

local ItemBase = {
	type = nil,
	id = nil, -- item instance id
	--copies = nil, -- number of copies in the item, NOTE: a stack of item instance is an item, not individually as database tables
	icon = nil, 
	bag = nil, -- bag instance id
	slot = nil, -- slot in bag container, -1 if it is a bag
};
commonlib.setfield("Map3DSystem.Item.ItemBase", ItemBase)


---------------------------------
-- functions
---------------------------------
function ItemBase:new()
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- get item instance id
function ItemBase:GetID()
	return self.id;
end

-- invoke default method of this item
function ItemBase:InvokeDefaultMethod()
	self:InvokeMethod("Default");
end

-- invoke a given method of this ItemBase using appropriate ItemBase handler
function ItemBase:InvokeMethod(funcName, ...)
	if(funcName == "Default") then
		-- TODO: invoke default method
	end
end

-- Get the Icon of this object
-- @param callbackFunc: function (filename) end. if nil, it will return the icon texture path. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function ItemBase:GetIcon(callbackFunc)
	return self.icon or "Texture/Aquarius/Quest/Question_Mark_32bits.png"
end

-- When this item is clicked
-- @param mouseButton: "left", "middle", "right"
function ItemBase:OnClick(mouseButton)
	if(mouseButton == "left") then
		self:OnDragBegin();
	elseif(mouseButton == "right") then
		self:InvokeDefaultMethod();
	end
end

-- Get the tooltip of this object
-- @param callbackFunc: function (text) end. if nil, it will return the text. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function ItemBase:GetTooltip(callbackFunc)
	
end

-- Get the description in MCML format
-- @param callbackFunc: function (pageText) end. 
function ItemBase:GetDesc(callbackFunc)
end

-- see Map3DSystem.Item.ItemTypes
function ItemBase:GetType()
	return self.type
end

-- get attribute of an item
-- @param attrname: attribute name
function ItemBase:GetAttribute(attrname)
	return self[attrname];
end

-- When this item is clicked in 3d space
function ItemBase:OnClick3D(mouseButton)
end

function ItemBase:GetTitle()
	return self:GetTooltip();
end

function ItemBase:GetSubTitle()
	return self:GetTooltip();
end

-- 
function ItemBase:OnDragBegin()
end

-- 
function ItemBase:OnDragEnd()
end

