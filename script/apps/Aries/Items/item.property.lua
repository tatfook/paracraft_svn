--[[
Title: Desktop property
Author(s): LiXizhi
Date: 2012/7/31
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Items/item.property.lua");
local addonproperty = commonlib.gettable("MyCompany.Aries.Items.addonproperty");
addonproperty.init();
------------------------------------------------------------
]]

-- create class
local addonproperty = commonlib.gettable("MyCompany.Aries.Items.addonproperty");

-- mapping from gsid to itemset table. 

-- load everything from file
-- calling this multiple times has no effect
-- @param filename: load from config/Aries/Others/globalstore.addonproperty.kids.xml
function addonproperty.init(filename)
	if(addonproperty.is_inited) then
		return
	end
	addonproperty.is_inited = true;
	filename = filename or if_else(System.options.version=="kids", "config/Aries/Others/globalstore.property.kids.xml", "config/Aries/Others/globalstore.property.teen.xml");
	
	local xmlDocRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlDocRoot) then
		LOG.std(nil, "error", "addonproperty", "can not open file from %s", filename);
		return;
	end
	local ItemManager = Map3DSystem.Item.ItemManager;
	local node;
	for node in commonlib.XPath.eachNode(xmlDocRoot, "/itemsets/itemset") do
		if(node.attr and node.attr.gsids) then
			local items = {};
			local gsid;
			for gsid in node.attr.gsids:gmatch("%d+") do
				items[tonumber(gsid)] = true;
			end
			local sub_node;
			for sub_node in commonlib.XPath.eachNode(node, "/property") do
				local property = sub_node.attr;
				if(property and property.name) then
					local name = property.name;
					if(name == "goto_npc") then
						local property_type = property.type;
						local npcid = property.value;
						local maxlevel = property.maxlevel;
						local minlevel = property.minlevel;
						local show_npctips = property.show_npctips;

						--local newnpcItem = {npcid = npcid,maxlevel = maxlevel,minlevel = minlevel,show_npctips = show_npctips};

						local gsid, _;
						for gsid, _ in pairs(items) do
							local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
							if(not gsItem["goto_npc"]) then
								gsItem["goto_npc"] = {};
							end
							table.insert(gsItem["goto_npc"],{npcid = npcid,maxlevel = maxlevel,minlevel = minlevel,show_npctips = show_npctips});	
						end
						--newnpcItem = nil;

					else
						--local name = property.name;
						local property_type = property.type;
						local value = property.value or sub_node[1];
						if(not property_type or property_type == "string") then
						elseif(property_type == "number") then
							value = tonumber(value);
						end
					
						local gsid, _
						for gsid, _ in pairs(items) do
							local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
							gsItem[name] = value;
						end
						
					end
				end
			end
		end
	end
end