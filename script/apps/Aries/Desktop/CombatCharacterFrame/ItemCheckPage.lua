--[[
Title: 
Author(s): leio
Date: 2013/1/21
Desc:  

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemCheckPage.lua");
local ItemCheckPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemCheckPage");
ItemCheckPage.ShowPage(gsid);
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerExtendedCost.lua");
local PowerExtendedCost = commonlib.gettable("Map3DSystem.Item.PowerExtendedCost");
local ItemCheckPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemCheckPage");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
function ItemCheckPage.OnInit()
	ItemCheckPage.page = document:GetPageCtrl();
end

ItemCheckPage.selected_gsid = nil;
ItemCheckPage.rate_gsid = nil;
ItemCheckPage.rate_gsid_count = nil;
ItemCheckPage.material_gsid = nil;
ItemCheckPage.ex_template = nil;
ItemCheckPage.material_gsid_cnt = nil;

ItemCheckPage.exids = {
	[1] = { rate_0 = "Identify_Lv1", rate = "Identify_Lv1_safe", },
	[2] = { rate_0 = "Identify_Lv2", rate = "Identify_Lv2_safe", },
	[3] = { rate_0 = "Identify_Lv3", rate = "Identify_Lv3_safe", },
	[4] = { rate_0 = "Identify_Lv4", rate = "Identify_Lv4_safe", },
	[5] = { rate_0 = "Identify_Lv5", rate = "Identify_Lv5_safe", },
	[6] = { rate_0 = "Identify_Lv6", rate = "Identify_Lv6_safe", },
	[7] = { rate_0 = "Identify_Lv7", rate = "Identify_Lv7_safe", },
	[8] = { rate_0 = "Identify_Lv8", rate = "Identify_Lv8_safe", },
	[9] = { rate_0 = "Identify_Lv9", rate = "Identify_Lv9_safe", },
	[10] = { rate_0 = "Identify_Lv10", rate = "Identify_Lv10_safe", },
}

function ItemCheckPage.BuildBags()
	if(CommonClientService.IsKidsVersion())then
		ItemCheckPage.menus = {
			{ label = "所有魂珠", selected = true, keyname = "folder_level_all", },
			{ label = "1-3级魂珠", keyname = "folder_level_1_3", },
			{ label = "4-6级魂珠", keyname = "folder_level_4_6", },
			{ label = "7-10级魂珠", keyname = "folder_level_7_10", },
		}
		ItemCheckPage.bags = {
			["folder_level_all"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
			["folder_level_1_3"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
			["folder_level_4_6"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
			["folder_level_7_10"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
		}
	else
		ItemCheckPage.menus = {
			{ label = "所有碎片", selected = true, keyname = "folder_level_all", },
			{ label = "1-3级碎片", keyname = "folder_level_1_3", },
			{ label = "4-6级碎片", keyname = "folder_level_4_6", },
			{ label = "7-10级碎片", keyname = "folder_level_7_10", },
		}
		ItemCheckPage.bags = {
			["folder_level_all"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
			["folder_level_1_3"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
			["folder_level_4_6"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
			["folder_level_7_10"] = {
				["subfolder_1"] = 
				{
					{
						bag = 14, class = 3, subclass = {22}, 
					},
				},
			},
		}
	end
end
function ItemCheckPage.GetTransNode(from_gsid,exid)
	from_gsid = tostring(from_gsid);
	if(not from_gsid or not exid)then
		return
	end
	local template = PowerExtendedCost.GetExtendedCostTemplateInMemory(exid);
	if(template)then
		local k,v;
		for k,v in ipairs(template) do
			if(v.attr and v.attr.from == from_gsid)then
				return v;
			end
		end
	end
end
function ItemCheckPage.GetExid(gsid,rate_cnt)
	if(not gsid)then
		return
	end
	rate_cnt = rate_cnt or 0;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local stat = gsItem.template.stats[70] or 0;
	local node = ItemCheckPage.exids[stat];
	if(node)then
		if(rate_cnt > 0)then
			return node.rate;
		else
			return node.rate_0;
		end
	end
end
function ItemCheckPage.PowerExtendedCost_Handle(msg)
	if(msg)then
		local msg_data = msg.msg or {};
		local input_msg = msg.input_msg or {};
		if(msg_data.issuccess)then
			ItemCheckPage.Clear();
			if(ItemCheckPage.page)then
				ItemCheckPage.page:Refresh(0);
			end
		else
			_guihelper.MessageBox("鉴定失败！");
		end
	end
end
function ItemCheckPage.Clear()
	ItemCheckPage.is_pending = nil;
	ItemCheckPage.selected_gsid = nil;
	ItemCheckPage.rate_gsid = nil;
	ItemCheckPage.rate_gsid_count = 0;
	ItemCheckPage.material_gsid = nil;
	ItemCheckPage.ex_template = nil;
	ItemCheckPage.material_gsid_cnt = nil;
	ItemCheckPage.trans_node = nil;
end
function ItemCheckPage.ShowPage(gsid)
	
	NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.lua");
	local MinorSkillPage = commonlib.gettable("MyCompany.Aries.Desktop.MinorSkillPage");
	if(CommonClientService.IsTeenVersion()) then
		if(not MinorSkillPage.IsIdentifier()) then
			_guihelper.MessageBox("你的职业不是驯灵师, 不能鉴定物品; 交给其他人鉴定吧！");
			return;
		end
	else
		if(not MinorSkillPage.IsIdentifier()) then
			_guihelper.MessageBox("你的职业不是魔法鉴定师, 不能鉴定物品; 交给其他哈奇鉴定吧！");
			return;
		end
	end
	ItemCheckPage.BuildBags();
	ItemCheckPage.Clear();
	local url;
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/ItemCheckPage.teen.html";
	else
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/ItemCheckPage.html";
	end
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local params = {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "ItemCheckPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		cancelShowAnimation = true,
		style = style,
		bToggleShowHide = true,
		-- zorder = 0,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -690/2,
			y = -443/2,
			width = 690,
			height = 443,
	}
    System.App.Commands.Call("File.MCMLWindowFrame", params);


	PowerExtendedCost.LoadFromConfig();
	local node = ItemCheckPage.GetMenu_CheckedNode();
	if(node)then
		ItemCheckPage.OnClickFolder(node.keyname,nil,true);
	end
	ItemCheckPage.DoSelectedItemByGsid(gsid);
end
function ItemCheckPage.GetMenu_CheckedNode()
	local k,v;
	for k,v in ipairs(ItemCheckPage.menus) do
		if(v.selected)then
			return v;
		end
	end
end
function ItemCheckPage.DS_Func_Items(index)
	if(not ItemCheckPage.items)then return 0 end
	if(index == nil) then
		return #(ItemCheckPage.items);
	else
		return ItemCheckPage.items[index];
	end
end
function ItemCheckPage.FilteItems(items,folder_key,subfolder_key)
	if(not folder_key or folder_key == "folder_level_all")then
		return items;
	end
	local result = {};
	if(items)then
		local k,v;
		for k,v in ipairs(items) do
			local gsid = v.gsid;
			if(gsid)then
				local can_push = false;
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				local stat = gsItem.template.stats[70] or 0;
				if(stat <= 3 and folder_key == "folder_level_1_3")then
					can_push = true;
				elseif(stat > 3 and stat <= 6 and folder_key == "folder_level_4_6")then
					can_push = true;
				elseif(stat > 6 and folder_key == "folder_level_7_10")then
					can_push = true;
				end
				if(can_push)then
					table.insert(result,v);
				end
			end
		end
	end
	return result;
end
function ItemCheckPage.OnClickFolder(folder_key,subfolder_key,need_refresh)
	local bag_list = BagHelper.GetBagList(folder_key,subfolder_key,ItemCheckPage.bags);
	local items = BagHelper.SearchBagList_Memory(nil,bag_list);
	items = ItemCheckPage.FilteItems(items,folder_key,subfolder_key);
	CommonClientService.Fill_List(items,25);
	ItemCheckPage.items = items;
	ItemCheckPage.folder_key = folder_key;
	ItemCheckPage.subfolder_key = subfolder_key;
	if(ItemCheckPage.page and need_refresh)then
		ItemCheckPage.page:Refresh(0);
	end
end

function ItemCheckPage.DoSelectedItemByGsid(gsid)
    if(gsid)then
	    ItemCheckPage.Clear();
        ItemCheckPage.selected_gsid = gsid;
        ItemCheckPage.UpdateExTemplate();
        
        if(ItemCheckPage.ex_template and ItemCheckPage.ex_template.attr)then
            ItemCheckPage.rate_gsid = ItemCheckPage.ex_template.attr.rate_gsid;
            ItemCheckPage.rate_gsid_count = 0;
            local from = ItemCheckPage.ex_template.attr.from;
            if(from)then
			    ItemCheckPage.material_gsid, ItemCheckPage.material_gsid_cnt = from:match("(%d+),(%d+)");
            end
            
        end
		if(ItemCheckPage.page) then
			ItemCheckPage.page:Refresh(0.01);    
		end
    end
end

function ItemCheckPage.UpdateExTemplate()
    local exid = ItemCheckPage.GetExid(ItemCheckPage.selected_gsid,ItemCheckPage.rate_gsid_count);
    if(exid)then
        ItemCheckPage.ex_template = PowerExtendedCost.GetExtendedCostTemplateInMemory(exid);
        ItemCheckPage.trans_node = ItemCheckPage.GetTransNode(ItemCheckPage.selected_gsid,exid)
    end
end