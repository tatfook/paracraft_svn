--[[
Title: 
Author(s): leio
Date: 2012/05/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/UserBag/BagExtendServerHelper.lua");
local BagExtendServerHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagExtendServerHelper");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local BagExtendServerHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagExtendServerHelper");

--扩展背包配置文件路径
BagExtendServerHelper.file_path = "config/Aries/BagDefine_Teen/bag_extend.xml";
--加载模板数据
function BagExtendServerHelper.Load()
	local self = BagExtendServerHelper;
	if(self.is_load)then
		return
	end
	self.is_load = true;
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.file_path);
	local node;
	local bag_template_list = {};
	for node in commonlib.XPath.eachNode(xmlRoot, "//items/item") do
		local level = tonumber(node.attr.level);
		local bag_size = tonumber(node.attr.bag_size);
		local price = tonumber(node.attr.price);
		if(level and bag_size and price)then
			table.insert(bag_template_list,{
				level = level, bag_size = bag_size, price = price,
			});
		end
	end
	table.sort(bag_template_list,function(a,b)
		if(a.level and b.level)then
			return a.level < b.level;
		end
	end);
	self.bag_template_list = bag_template_list;
end
function BagExtendServerHelper.GetNextLevelNode(level)
	local self = BagExtendServerHelper;
	local bag_template_list = self.bag_template_list;
	if(not level or not bag_template_list)then return end
	level = level + 1;

	local len = #bag_template_list;
	local max_level = bag_template_list[len].level;
	if(level == max_level)then
		return bag_template_list[len];
	end
	local k,v;
	for k,v in ipairs(bag_template_list) do
		if(v.level == level)then
			return v;
		end
	end
end
function BagExtendServerHelper.DoBagExtend(nid,msg)
	local self = BagExtendServerHelper;
	self.Load();
	nid = tonumber(nid);
	local bag_template_list = self.bag_template_list;
	if(not nid or not bag_template_list)then return end

	local len = #bag_template_list;
	local max_level = bag_template_list[len].level;

	PowerItemManager.SyncUserItems(nid, {1003}, function(msg) 
		local hasItem,guid,bag,level = PowerItemManager.IfOwnGSItem(nid,976);
		level = level or 0;

		if(level >= max_level)then
			--已经满级
			return;
		end
		local next_level_node = BagExtendServerHelper.GetNextLevelNode(level);
		if(next_level_node)then
			local price = next_level_node.price;
			local loots = {
				[984] = -price,
				[976] = 1,
			};
			LOG.std(nil, "info","before BagExtendServerHelper.BagExtend_Handle",{nid = nid, loots = loots,next_level_node = next_level_node,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg) 
			LOG.std(nil, "info","after BagExtendServerHelper.BagExtend_Handle",msg);
				if(msg and msg.issuccess)then
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.Inventory.CharacterBagPage.BagExtend_Handle",{level = next_level_node.level})
				end
			end,nil,nil,true);
		end

	end, function() end);
end
