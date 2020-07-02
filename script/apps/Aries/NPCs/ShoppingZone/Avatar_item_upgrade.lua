--[[
Title: avater item upgrade
Author(s): LiXizhi
Date: 2012/08/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_item_upgrade.lua");
local Avatar_item_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_item_upgrade");
Avatar_item_upgrade.LoadFromFile();
Avatar_item_upgrade.ShowPage();
------------------------------------------------------------
--]]


NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
local Avatar_item_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_item_upgrade");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

Avatar_item_upgrade.items = {}; -- all items that can be upgraded to.
Avatar_item_upgrade.gem_gsids = {};  -- gems on the source item
Avatar_item_upgrade.source_gsid = nil;
Avatar_item_upgrade.target_gsid = nil;
Avatar_item_upgrade.available_target_gsids = {}; -- all available target items
Avatar_item_upgrade.unavailable_target_gsids = {}; -- all available target items
Avatar_item_upgrade.from_level = 0;
Avatar_item_upgrade.properties = { attack_percentage = 0,attack_absolute = 0, hp_absolute = 0}

local page;
function Avatar_item_upgrade:Init()
	Avatar_item_upgrade.LoadFromFile();
	page = document:GetPageCtrl();
end

function Avatar_item_upgrade.ShowPageWithGsid(gsid)
	Avatar_item_upgrade.ShowPage(gsid);
end

function Avatar_item_upgrade.ShowPageWithGuid(guid)
	Avatar_item_upgrade.ShowPage(nil, guid);
end

function Avatar_item_upgrade.ShowPage(gsid, guid)

	local page_addr;
	local width, height;
	if(System.options.version == "kids") then
		page_addr = "script/apps/Aries/NPCs/ShoppingZone/Avatar_item_upgrade.kids.html";
		width, height = 540, 370;
	else
		page_addr =  "script/apps/Aries/NPCs/ShoppingZone/Avatar_item_upgrade.teen.html";
		width, height = 540, 370;
	end


	local has_item;
	if(type(gsid) == "number") then
		page_addr = format("%s?gsid=%d", page_addr, gsid);
		has_item = true;
		local bHas,guid_ = hasGSItem(gsid);
        if(bHas)then
			guid = guid_;
		end
	elseif(type(guid) == "number") then
		local item = ItemManager.GetItemByGUID(guid);
		if(item) then
			page_addr = format("%s?gsid=%d", page_addr, item.gsid);
			has_item = true;
		end
	end

	local params = {
			url = page_addr, 
			name = "Avatar_item_upgrade.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
			align = "_ct",
			x = -width * 0.5,
			y = -height * 0.5,
			width = width,
			height = height,}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function Avatar_item_upgrade.OnHandleUpgradeCallback(msg)
	if(msg.issuccess) then
		_guihelper.MessageBox("恭喜! 继承成功. 当前装备的全部属性已经转移到新装备上了")
		if(page) then
			page:CloseWindow();
		end
	end
end

function Avatar_item_upgrade.OnChangeItem(guid, bDoNotRefresh)
	local self = Avatar_item_upgrade;
    guid = tonumber(guid);
    local item = ItemManager.GetItemByGUID(guid);
	if(item)then
		local gsid = item.gsid;
        self.selected_gsid = gsid;
        self.gem_gsids = {};
        self.GetDataSource();

		if(item.GetAddonLevel) then
			self.from_level = item:GetAddonLevel() or 0;
			self.properties.attack_percentage = addonlevel.get_attack_percentage(gsid,self.from_level) or 0;
			self.properties.attack_absolute = addonlevel.get_attack_absolute(gsid,self.from_level) or 0;
			self.properties.hp_absolute = addonlevel.get_hp_absolute(gsid,self.from_level) or 0;
		end

		Avatar_item_upgrade.available_target_gsids = {};
		Avatar_item_upgrade.unavailable_target_gsids = {};
		Avatar_item_upgrade.target_gsid = nil;

		local gsid_map = {};
		local player_level = Player.GetLevel();
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local items = Avatar_item_upgrade.GetItems(gsItem.template.class, gsItem.template.subclass);
			if(items) then
				local gsid, item; -- {gsid, exid, minlevel, maxlevel}
				for gsid, item in pairs(items) do
					local target_item = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(target_item and (Avatar_item_upgrade.source_gsid~=gsid)) then
						local needLvl = target_item.template.stats[138] or 0; 
						local needSchool = target_item.template.stats[137] or target_item.template.stats[246]; 
						if ((player_level>= needLvl) and 
							(player_level>=(item.minlevel or 0) and player_level<=(item.maxlevel or player_level)) and 
							(not needSchool or CommonClientService.IsRightSchool(gsid, nil, nil, needSchool)) ) then
							-- only add items with the right school.
							gsid_map[gsid] = true;
							Avatar_item_upgrade.available_target_gsids[#(Avatar_item_upgrade.available_target_gsids) + 1] = item;
						elseif((player_level<item.minlevel or player_level<needLvl) and 
							(not needSchool or CommonClientService.IsRightSchool(gsid, nil, nil, needSchool))) then 
							Avatar_item_upgrade.unavailable_target_gsids[#(Avatar_item_upgrade.unavailable_target_gsids) + 1] = item;
						end
					end
				end
			end
			
			NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
			local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
			local items = BagHelper.SearchBagList_Memory(nil, {{
					bag=0, 
					class = gsItem.template.class,
					subclass = {gsItem.template.subclass},
				},
				{
					bag=1, 
					class = gsItem.template.class,
					subclass = {gsItem.template.subclass},
				}
			});
			if(items) then
				local _, item; -- {gsid, exid, minlevel, maxlevel}
				for _, item in ipairs(items) do
					local gsid = item.gsid;
					local target_item = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(target_item and not gsid_map[gsid] and (Avatar_item_upgrade.source_gsid~=gsid) and 
						addonlevel.can_have_addon_property(gsid) ) then
						local needLvl = target_item.template.stats[138] or 0; 
						local needSchool = target_item.template.stats[137] or target_item.template.stats[246]; 
						if ((player_level>= needLvl) and 
							(player_level<= (needLvl+10)) and 
							(not needSchool or CommonClientService.IsRightSchool(gsid, nil, nil, needSchool)) ) then
							-- only add items with the right school of the current user.
							Avatar_item_upgrade.available_target_gsids[#(Avatar_item_upgrade.available_target_gsids) + 1] = {gsid=gsid, guid=item.guid, minlevel=needLvl, maxlevel=needLvl+10};
						end
					end
				end
			end
		end


		table.sort(Avatar_item_upgrade.unavailable_target_gsids, function(a, b)
			return (a.minlevel or 0) < (b.minlevel or 0)
		end)
		

		if(not bDoNotRefresh) then 
			self.DoRefresh();
		end
    end
end

function Avatar_item_upgrade.DoRefresh()
	if(page) then
		page:Refresh();
	end
end

function Avatar_item_upgrade.GetDataSource()
	local self = Avatar_item_upgrade;
	local gsid = self.selected_gsid;
    local gem_gsids = self.gem_gsids;
    if(gsid)then
        local bHas,guid = hasGSItem(gsid);
        if(bHas)then
            local item = ItemManager.GetItemByGUID(guid);
            if(item and item.GetSocketedGems)then
                local gems = item:GetSocketedGems() or {};
                local k,v;
                for k,v in ipairs(gems) do
                    table.insert(gem_gsids,{gsid = v});
                end
            end
        end
    end
end


local function GetIDByClass(class, subclass)
	return  (class or 0)*1000 + (subclass or 0);
end

-- return a table containing all items that can be upgraded.  the returned table is gsid to property {gsid, exid, minlevel, maxlevel} map.
function Avatar_item_upgrade.GetItems(class, subclass)
	local item_key = GetIDByClass(class, subclass);
	return Avatar_item_upgrade.items[item_key];
end

-- whether a given gsid item can be upgraded. 
function Avatar_item_upgrade.CanUpgrade(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		local items = Avatar_item_upgrade.GetItems(gsItem.template.class, gsItem.template.subclass);
		if(items) then
			if(items[gsid]) then
				return true;
			end
		end
	end
end

-- load everything from file
-- calling this multiple times has no effect
-- @param filename: load from config/Aries/Others/item_upgrade.kids.xml
function Avatar_item_upgrade.LoadFromFile(filename)
	if(Avatar_item_upgrade.is_inited) then
		return
	end
	Avatar_item_upgrade.is_inited = true;
	
	filename = filename or if_else(System.options.version=="kids", "config/Aries/Others/item_upgrade.kids.excel.xml", "config/Aries/Others/item_upgrade.teen.xml");
	
	if(filename:match("excel")) then
		NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
		local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
		local reader = ExcelDocReader:new();

		-- schema is optional, which can change the row's keyname to the defined value. 
		reader:SetSchema({
			[1] = {name="name"},
			[2] = {name="school", },
			[3] = {name="slot", },
			[4] = {name="gsid", type="number"},
			[5] = {name="exid", type="number"},
			[6] = {name="minlevel", type="number"},
			[7] = {name="maxlevel", type="number"},
		})
		-- read from the second row
		if(reader:LoadFile(filename, 2)) then 
			local rows = reader:GetRows();
			if(rows) then
				local _, row;
				for _, row in ipairs(rows) do
					if(row.gsid) then
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(row.gsid);
						if(gsItem) then
							local item_key = GetIDByClass(gsItem.template.class, gsItem.template.subclass);
							local items = Avatar_item_upgrade.items[item_key];
							if(not items) then
								items = {}
								Avatar_item_upgrade.items[item_key] = items;
							end
							local xiandou = 0;
							local money_gsid, money_count = 0,0;
							if(row.exid) then
								local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(row.exid);
								if(exTemplate and exTemplate.froms and exTemplate.tos)then
									local node = exTemplate.froms[1]
									if(node and node.key == 17213)then
										xiandou = node.value;
									end
									if(#(exTemplate.froms) == 1) then
										money_gsid = node.key;
										money_count = node.value;
									end
								end
							end
							items[row.gsid] = {gsid=row.gsid, exid=row.exid, minlevel=row.minlevel, maxlevel=row.maxlevel, xiandou=xiandou, money_gsid=money_gsid, money_count=money_count}
						end
					end
				end
			else
				LOG.std(nil, "warn", "Avatar_item_upgrade", "unable to read file %s", filename);
			end
		end
	else
		local xmlDocRoot = ParaXML.LuaXML_ParseFile(filename);
		if(not xmlDocRoot) then
			LOG.std(nil, "error", "Avatar_item_upgrade", "can not open file from %s", filename);
			return;
		end
	
		local node;
		for node in commonlib.XPath.eachNode(xmlDocRoot, "/item_upgrade/items") do
			if(node.attr and node.attr.class and node.attr.subclass) then
				local items = {class=tonumber(node.attr.class), subclass=tonumber(node.attr.subclass), items = {}};
				local item_key = GetIDByClass(items.class, items.subclass);
				Avatar_item_upgrade.items[item_key] = items;

				local sub_node;
				for sub_node in commonlib.XPath.eachNode(node, "/item") do
					local attr = sub_node.attr;
					if(attr) then
						local gsid = tonumber(attr.gsid);
						local exid = tonumber(attr.exid);
						local minlevel = tonumber(attr.minlevel);
						local maxlevel = tonumber(attr.maxlevel);
						local xiandou = 0;
						if (gsid) then
							if(exid) then
								local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
								if(exTemplate and exTemplate.froms and exTemplate.tos)then
									local node = exTemplate.froms[1]
									if(node and node.key == 17213)then
										xiandou = node.value;
									end
								end
							end
							items.items[gsid] = {gsid=gsid, exid=exid, minlevel=minlevel, maxlevel=maxlevel, xiandou=xiandou};
						end
					end
				end
			end
		end
	end
	
end
