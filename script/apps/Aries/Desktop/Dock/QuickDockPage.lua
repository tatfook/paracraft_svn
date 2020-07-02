--[[
Title: Quick QuickDockPage bar in Dock area.
Author(s): LiXizhi
Company: ParaEnging Co.
Date: 2012/3/16
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/QuickDockPage.lua");
MyCompany.Aries.Desktop.Dock.QuickDockPage.Init();
------------------------------------------------------------
]]
-- create class
local QuickDockPage = commonlib.gettable("MyCompany.Aries.Desktop.Dock.QuickDockPage");

local list = {
	{ gsid =12017, },{ gsid =12018, },{ gsid =12014, },{ gsid =12013, },{ gsid =12012, },{ gsid =12007, },{ gsid =12002, },{ gsid =12001, },
	--{ gsid =17155, },{ gsid =17156, },{ gsid =17157, },{ gsid =17158, },{ gsid =17159, },{ gsid = 0, },{ gsid = 0, },{ gsid = 0, },
	{ gsid =17159, },{ gsid = 0, },{ gsid = 0, },{ gsid = 0, },{ gsid = 0, },{ gsid = 0, },{ gsid = 0, },{ gsid = 0, },
}

local pills_list = {};
local category_menus = {};
QuickDockPage.category_index = 1;

local page;

function QuickDockPage.Init()
	page = document:GetPageCtrl();
	if(QuickDockPage.inited) then
		return;
	end;
	QuickDockPage.inited = true;
	--local ItemManager = commonlib.gettable("System.Item.ItemManager");
	--local hasGSItem = ItemManager.IfOwnGSItem;
	if(System.options.version == "kids") then
		QuickDockPage.LoadPillsDSFromFile();
		category_menus[QuickDockPage.category_index].selected = true;
		QuickDockPage.category_menus = category_menus;
	end
	--local k,v;
	--for k,v in ipairs(list) do
		--local bHas,guid = hasGSItem(v.gsid);
		--v.bHas = bHas;
		--v.guid = guid;
		--local gsItem = ItemManager.GetGlobalStoreItemInMemory(v.gsid);
		--if(gsItem)then		
			--local name = gsItem.template.name;	
			--v.tooltip = string.format("点击可以直接购买【%s】",name);
		--end 
	--end
end

function QuickDockPage.LoadPillsDSFromFile()

	local filename = "config/Aries/Others/medicine_chest_ds.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		for node in commonlib.XPath.eachNode(xmlRoot, "/pills/category") do
			local category = {};
			category.name = node.attr.name;
			table.insert(category_menus,{label = node.attr.name});
			local ds = {};
			for pill in commonlib.XPath.eachNode(node, "/pill") do
				local pill_item = {};
				pill_item.gsid = tonumber(pill.attr.gsid);
				pill_item.exid = tonumber(pill.attr.exid);
				pill_item.empty_click_goto_npc = tonumber(pill.attr.empty_click_goto_npc);
				--if(pill.attr.empty_click_buy == "true") then
					--pill_item.empty_click_buy = true;
				--else
					--pill_item.empty_click_buy = false;
				--end
				table.insert(ds,pill_item);
			end
			category.ds = ds;
			table.insert(pills_list,category);
		end
	end
end

function QuickDockPage.GetCategoryDS()
	return pills_list;
end

function QuickDockPage.DS_Func_Items(index)
	local list = pills_list[QuickDockPage.category_index].ds;
	if(index == nil) then
		return #(list);
	else
		return list[index];
	end
end

function QuickDockPage.OnClickFolder(index)
	QuickDockPage.category_index = index or QuickDockPage.category_index;
	if(page) then
		page:Refresh(0.01);
	end
end