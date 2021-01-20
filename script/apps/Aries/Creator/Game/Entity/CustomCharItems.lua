--[[
Title: Custom Char Models and Skins
Author(s): chenjinxian
Date: 2020/12/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/CustomCharItems.lua");
local CustomCharItems = commonlib.gettable("MyCompany.Aries.Game.EntityManager.CustomCharItems")
CustomCharItems:Init();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local CustomCharItems = commonlib.gettable("MyCompany.Aries.Game.EntityManager.CustomCharItems")

local defaultModelFile = "character/CC/02human/CustomGeoset/actor.x";

local models = {};
local items = {};
local category_items = {};

-- called only once
function CustomCharItems:Init()
	if(self.is_inited) then
		return;
	end
	self.is_inited = true;

	local root = ParaXML.LuaXML_ParseFile("config/Aries/creator/CustomCharItems.xml");
	if (root) then
		local id = 0;
		for itemNode in commonlib.XPath.eachNode(root, "/CustomCharItems/items/item") do
			local item = {};
			item.data = {};
			for _, node in ipairs(itemNode) do
				local attr = node.attr;
				local name = node.name;
				if (name == "geoset") then
					local slotId = attr.category or 0;
					local itemId = attr.id or 0;
					item.data.geoset = tonumber(slotId) * 100 + tonumber(itemId);
				elseif (name == "texture") then
					item.data.texture = string.format("%s:%s", attr.id or "0", attr.filename or "");
				elseif (name == "attachment") then
					item.data.attachment = string.format("%s:%s", attr.id or "11", attr.filename or "");
				end
				id = id + 1;
			end

			local modelPath = itemNode.attr.model;
			local itemId = itemNode.attr.id;
			if (modelPath and itemId) then
				item.id = itemId;
				item.model = {};
				for groupName in modelPath:gmatch("[^;]+") do
					item.model[#item.model+1] = groupName;
				end
			end
			items[#items+1] = item;
		end

		for modelGroup in commonlib.XPath.eachNode(root, "/CustomCharItems/models") do
			local type = modelGroup.attr.type;
			local groups = {};
			for _, node in ipairs(modelGroup) do
				groups[#groups+1] = node.attr.filename;
			end
			models[type] = groups;
		end

		LOG.std(nil, "info", "CustomCharItems", "%d skins loaded from %s", id, filename);

		root = ParaXML.LuaXML_ParseFile("config/Aries/creator/CustomCharList.xml");
		if (root) then
			for group in commonlib.XPath.eachNode(root, "/customcharlist/category") do
				local name = group.attr.name;
				local groups = {};
				for _, node in ipairs(group) do
					local item = {};
					item.id = node.attr.id;
					item.gsid = node.attr.gsid;
					groups[#groups+1] = item;
				end
				category_items[name] = groups;
			end
		end
	else
		LOG.std(nil, "error", "CustomCharItems", "can not find file at %s", filename);
	end
end

function CustomCharItems:GetModelItems(filename, category)
	for type, names in pairs(models) do
		for _, name in ipairs(names) do
			if (name == filename) then
				return self:GetItemsByCategory(category, type);
			end
		end
	end
end

function CustomCharItems:GetItemsByCategory(category, modelType)
	local groups = category_items[category];
	if (groups) then
		local itemList = {};
		for _, item in ipairs(groups) do
			local data = self:GetItemById(item.id, modelType);
			if (data) then
				data.gsid = item.gsid;
				itemList[#itemList+1] = data;
			end
		end
		return itemList;
	end
end

function CustomCharItems:GetItemById(id, modelType)
	for _, item in ipairs(items) do
		if (item.id == id) then
			for _, model in ipairs(item.model) do
				if (model == modelType) then
					return item.data;
				end
			end
		end
	end
end
