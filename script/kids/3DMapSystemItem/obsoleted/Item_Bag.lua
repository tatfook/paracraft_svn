--[[
Title: bag container items
Author(s): WangTian
Date: 2009/2/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemItem/Item_Bag.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/ItemBase.lua");

local Item_Bag = commonlib.inherit(Map3DSystem.Item.ItemBase, {type=Map3DSystem.Item.Types.Item_Bag});
commonlib.setfield("Map3DSystem.Item.Item_Bag", Item_Bag)

---------------------------------
-- functions
---------------------------------

-- Get the Icon of this object
-- @param callbackFunc: function (filename) end. if nil, it will return the icon texture path. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Item_Bag:GetIcon(callbackFunc)
	return self.icon or "Texture/Aquarius/Dock/Bag.png";
end

-- When this item is clicked
function Item_Bag:OnClick(mouseButton)
	return;
end

-- Get the tooltip of this object
-- @param callbackFunc: function (text) end. if nil, it will return the text. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Item_Bag:GetTooltip(callbackFunc)
	return "BAG";
end

function Item_Bag:GetSubTitle()
	return "BAG";
end