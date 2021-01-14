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

-- called only once
function CustomCharItems:Init()
	commonlib.echo("CustomCharItems:Init()------------------------------------------");
	if(self.is_inited) then
		return;
	end
	self.is_inited = true;
	local filename = "config/Aries/creator/CustomCharItems.xml";
	local root = ParaXML.LuaXML_ParseFile(filename);
	if (root) then
		local id = 0;
		for itemNode in commonlib.XPath.eachNode(root, "/CustomCharItems/items/item") do
			local item = {};
			for _, node in ipairs(itemNode) do
				local attr = node.attr;
				local name = node.name;
				if (name == "geoset") then
					local slotId = attr.category or 0;
					local itemId = attr.id or 0;
					item.geoset = tonumber(slotId) * 100 + tonumber(itemId);
				elseif (name == "texture") then
					item.texture = string.format("%s:%s", attr.id or "0", attr.filename or "");
				elseif (name == "attachment") then
					item.attachment = string.format("%s:%s", attr.id or "11", attr.filename or "");
				end
				id = id + 1;
			end

			local modelPath = itemNode.attr.model;
			local gsid = itemNode.attr.gsid;
			if (modelPath and gsid) then
				local skinId = math.floor(tonumber(gsid) / 1000);
				for filename in modelPath:gmatch("[^;]+") do
					local model = models[filename] or {};
					local skins = model[skinId] or {};
					skins[#skins + 1] = item;
					model[skinId] = skins;
					models[filename] = model;
				end
			end
		end

		LOG.std(nil, "info", "CustomCharItems", "%d skins loaded from %s", id, filename);
	else
		LOG.std(nil, "error", "CustomCharItems", "can not find file at %s", filename);
	end
end

function CustomCharItems:GetModel(filename)
	return models[filename];
end
