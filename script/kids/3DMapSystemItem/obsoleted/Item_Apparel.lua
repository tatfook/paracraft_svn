--[[
Title: apparel items for CCS customization
Author(s): WangTian
Date: 2009/2/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemItem/Item_Apparel.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/ItemBase.lua");

local Item_Apparel = commonlib.inherit(Map3DSystem.Item.ItemBase, {type = Map3DSystem.Item.Types.Item_Apparel});
commonlib.setfield("Map3DSystem.Item.Item_Apparel", Item_Apparel)

---------------------------------
-- functions
---------------------------------

-- Get the Icon of this object
-- @param callbackFunc: function (filename) end. if nil, it will return the icon texture path. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Item_Apparel:GetIcon(callbackFunc)
	-- TODO: generate icon using unisex model and replace with item textures
	-- TODO: get assetFile
	--assetFile
	--assetFile/asset.xml unisex model file and replaceable textures
	return "texture/uncheckbox.png";
end

-- When this item is clicked
function Item_Apparel:OnClick(mouseButton)
	-- TODO: equip item on character
	local inventoryType = self:GetAttribute("InventoryType");
	-- TODO: check inventory type and equip the item on the game server
	-- NOTE: update the character database player_item_**
	-- NOTE: 
end

-- Get the tooltip of this object
-- @param callbackFunc: function (text) end. if nil, it will return the text. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Item_Apparel:GetTooltip(callbackFunc)
end

function Item_Apparel:GetSubTitle()
end