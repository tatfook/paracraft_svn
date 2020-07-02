--[[
Title: Item manager
Author(s): WangTian
Date: 2009/4/21
Desc: Each item has an id in the GlobalStore. 
	Item system allows all users to pick, carry, use, sell, buy, wear items. The big picture is a set of worlds which 
	consists of various items and the related application upon them. The original implementation includes models, characters, animations 
	and many others that can be either officially packed or user generated. Currently we only take portion of the original design 
	for Aries item system.
	Global Store holds information on every item that exists in ParaWorld. All items are created from their information stored in this table.
	It works like a template that all item entities are instances of the item template. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local item = Map3DSystem.Item.ItemManager:FindItem(1)

Map3DSystem.Item.ItemManager:ItemManager:AddItem(item);
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/ItemBase.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Exe_App.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Exe_AppCommand.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Item_Bag.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Item_Apparel.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Item_LocalFunc.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Type_Unknown.lua");

NPL.load("(gl)script/kids/3DMapSystemItem/Slot.lua");

local ItemManager = {
	---- which type of item to handle. 
	--type = nil,
	-- mapping from item_instance id to instance data
	items = {},
	-- inventory bags
	bags = {}, -- [BagID][position]
	-- item links
	links = {}, -- [link position]
	-- equips
	equips = {}, -- [equipped slot]
	-- drag from slot
	dragFromSlot = nil,
};
commonlib.setfield("Map3DSystem.Item.ItemManager", ItemManager)

local EventListener = {
	["OnBagsUpdate"] = nil, -- OnBagsUpdate
	["OnEquipsUpdate"] = nil, -- OnEquipsUpdate
	["OnLinksUpdate"] = nil, -- OnLinksUpdate
};
ItemManager.EventListener = EventListener;

-- check the item version in local server
-- if the local server version is expired, notifiy the user to download or update to the latest
-- NOTE: this is for item_template items only, UGC assets and Executable apps or appcommands can be obtained from API calls
function ItemManager.ValidateGlobalStoreVersion()
	-- TODO:
end

---------------------------------
-- global store functions
---------------------------------
-- create item in global store
-- @param id: global store id
-- @param template: item data, including global store data and template data
function ItemManager.CreateGlobalStoreItem(id, template)
	-- TODO: invoke global store APIs
	-- TODO: update local data if succeed
end

-- read item in global store
-- @param id: global store id
function ItemManager.ReadGlobalStoreItem(id)
	-- TODO: invoke global store APIs
	-- TODO: update local data if needed
	
	if(id == 1) then
		--return {type = 2, appkey = "Creator_GUID"};
		return Map3DSystem.Item.Exe_App:new({appkey=System.App.appkeys["Creator"]});
	elseif(id == 2) then
		return {type = 2, appkey = "CCS_GUID"};
	elseif(id == 3) then
		return {type = 2, appkey = "Chat_GUID"};
	elseif(id == 4) then
		return {type = 3, CommandName = "File.Open.Asset"};
	elseif(id == 5) then
		return {type = 3, CommandName = "File.Open.PersonalWorld"};
	elseif(id == 6) then
		return {type = 3, CommandName = "File.SaveAndPublish"};
	elseif(id == 7) then
		return {type = 3, CommandName = "File.MCMLBrowser"};
	elseif(id == 8) then
		return {type = 3, CommandName = "Env.terrain", param = "adv"};
	elseif(id == 9) then
		return {type = 3, CommandName = "File.ArtTools"};
	elseif(id == 10) then
		return {type = 3, CommandName = "File.ProTools"};
	else
		return GlobalStoreItems[id];
	end
end

-- update item in global store
-- @param id: global store id
-- @param template: the updated item data, including global store data and template data
function ItemManager.UpdateGlobalStoreItem(id, template)
	-- TODO: invoke global store APIs
	-- TODO: update local data if succeed
end

-- delete item from global store
-- @param id: global store id
function ItemManager.DeleteGlobalStoreItem(id)
	-- TODO: invoke global store APIs
	-- TODO: update local data if succeed
end

-- version control

-- init the item manager 
function ItemManager.InitGlobalStore()
	local db, err = sqlite3.open("Database/Items.db");
	if( db == nil)then
		log("error: failed connecting to items db\n");
		if( err ~= nil)then
			log(err.."\n");
		end
		return;
	end
	
	-- use the wow icon to 
	local k, v;
	for k, v in pairs(GlobalStoreIcons) do
		-- register items for each category
		local InventoryType = v.InventoryType;
		local subclass = v.subclass;
		local class = v.class;
		
		local cmd = string.format(
"SELECT entry, class, subclass, name, displayid, Quality, BuyPrice, SellPrice, InventoryType, ItemLevel, RequiredLevel, maxcount, "..
"stat_type1, stat_value1, stat_type2, stat_value2, stat_type3, stat_value3, stat_type4, stat_value4, stat_type5, stat_value5, "..
"armor, bonding, Material, itemset, MaxDurability FROM item_template_wow where class = %d and subclass = %d and InventoryType = %d ORDER BY entry"
, class, subclass, InventoryType);
		local row;
		for row in db:rows(cmd) do
			-- create the category table if not exist
			GlobalStoreItemsByCategory[v.category] = GlobalStoreItemsByCategory[v.category] or {};
			table.insert(GlobalStoreItemsByCategory[v.category], row.entry);
			
			-- rows
			GlobalStoreItems[row.entry] = {
				GSID = row.entry,
				--AssetKey = 
				type = 1, -- 1 item_template
				category = v.category,
				--category = "Item."..v.category,
				icon = string.format("%s%s%02d.png", IconDir, v.IconPrefix, math.mod(row.displayid, v.TotalNum)+1),
				itemname = row.name,
				eBuyPrice = row.BuyPrice, 
				eSellPrice = row.SellPrice, 
				template = {
					name = row.name,
					class = row.class, 
					subclass = row.subclass, 
					InventoryType = row.InventoryType, 
					Quality = row.Quality, 
					ItemLevel = row.ItemLevel, 
					RequiredLevel = row.RequiredLevel, 
					maxcount = row.maxcount, 
					stat_type1 = row.stat_type1, 
					stat_value1 = row.stat_value1, 
					stat_type2 = row.stat_type2, 
					stat_value2 = row.stat_value2, 
					stat_type3 = row.stat_type3, 
					stat_value3 = row.stat_value3, 
					stat_type4 = row.stat_type4, 
					stat_value4 = row.stat_value4, 
					stat_type5 = row.stat_type5, 
					stat_value5 = row.stat_value5, 
					armor = row.armor, 
					bonding = row.bonding, 
					Material = row.Material, 
					itemset = row.itemset, 
					MaxDurability = row.MaxDurability, 
				},
			};
		end
		
		---- temp id for testing: InventoryType(2)..subclass(2)..class(1)..Num(2)
		--local GlobalStoreID = InventoryType * 100000 + subclass * 1000 + class * 100 + i;
		---- different templates
		--GlobalStoreItems[GlobalStoreID] = {
			--GSID = GlobalStoreID,
			----AssetKey = 
			--type = 1, -- 1 item_template
			--category = "Item."..v.category,
			--icon = string.format("%s%s%02d.png", IconDir, v.IconPrefix, i),
			--itemname = string.format("%s%02d", v.IconPrefix, i), -- currently use the icon name as the item name
			--template = {
				--class = class, 
				--subclass = subclass, 
				--InventoryType = InventoryType, 
			--},
		--};
	end
	
	
	
	local gsID, entry;
	for gsID, entry in pairs(GlobalStoreItems) do
--		insert the database
		local categoryDesc = GlobalStoreIcons[entry.category];
		if(gsID > 1000 and gsID < 5000) then
			entry.itemname = string.gsub(entry.itemname, "'", "''");
			db:exec(string.format("INSERT INTO global_store VALUES (%d, '', '', 1, '%s', %d, %d, %d, %d)", 
					gsID, entry.icon, entry.eBuyPrice, entry.eBuyPrice, entry.eSellPrice, entry.eSellPrice));
			if(categoryDesc.class_new == 2) then
				db:exec(string.format("INSERT INTO item_template VALUES (%d, %d, %d, '%s', %d, %d, %d)", 
						gsID, categoryDesc.class_new, categoryDesc.subclass_new, entry.itemname, categoryDesc.InventoryType_new, 100, categoryDesc.BagFamily_new));
			else
				db:exec(string.format("INSERT INTO item_template VALUES (%d, %d, %d, '%s', %d, %d, %d)", 
						gsID, categoryDesc.class_new, categoryDesc.subclass_new, entry.itemname, categoryDesc.InventoryType_new, 1, categoryDesc.BagFamily_new));
			end
		end
	
	end
	
	
	db:close();
end

-- init the item manager 
function ItemManager.Init()
	
	
	do return end
	
	ItemManager.InitGlobalStore();
	
	-- TODO: get bags items
	-- TODO: get equipped items
	
	-- init the links with nil MyDesktop MCML profile
	local links = ItemManager.slots.links;
	if(#links == 0) then
		local maxLinks = 100;
		local position;
		for position = 1, maxLinks do
			links[position] = Map3DSystem.Item.Slot:new({type = "Link", linkid = 0, position = position});
		end
	end
	
	-- init the links global store id with the MCML profile in memory
	local uid = Map3DSystem.App.profiles.ProfileManager.GetUserID();
	local profile;
	profile = Map3DSystem.App.MyDesktop.app:GetMCMLInMemory(uid);
	
	if(profile == nil or type(profile) ~= "table" or #profile == 0) then
		-- set the default MCML link table
		profile = {};
		local i = 1;
		for i = 1, 10 do
			profile[i] = i;
		end
		Map3DSystem.App.MyDesktop.app:SetMCML(uid, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				log("succeed setting the default MCML profile to quicklaunch slots of MyDesktop app\n");
			else
				log("failed setting the default MCML profile to quicklaunch slots of MyDesktop app\n");
			end	
		end)
	else
		-- update the link global store id with the MCML profile in memory
		local position, link;
		for position, link in pairs(links) do
			links[position].linkid = profile[position];
		end
	end
	
	-- parse my inventory MCML profile into item instances and inventory data
	--ItemManager.ParseMyInventory();
	
	-- init the inventory with nil Inventory MCML profile
	ItemManager.items = {};
	local items = ItemManager.items;
	--if(#items == 0) then
		--local maxItems = 500;
		--local position;
		--for position = 1, maxItems do
			--items[position] = {type = "Item", item_instance_guid = 0};
		--end
	--end
	
	-- reset the bags and equips
	ItemManager.slots.bags = {};
	ItemManager.slots.equips = {};
	local bags = ItemManager.slots.bags;
	local equips = ItemManager.slots.equips;
	
	-- init the inventory with the MCML profile in memory
	local uid = Map3DSystem.App.profiles.ProfileManager.GetUserID();
	local profile;
	profile = Map3DSystem.App.Inventory.app:GetMCMLInMemory(uid);
	
	if(profile == nil or type(profile) ~= "table" or #profile == 0 or profile.item_instance == nil or profile.character_inventory == nil) then
		-- set the default MCML link table, empty item_instance and character_inventory table
		profile = {
			["item_instance"] = {},
			["character_inventory"] = {},
		};
		Map3DSystem.App.Inventory.app:SetMCML(uid, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				log("succeed setting the default MCML profile to Inventory app\n");
				log("succeed setting the default MCML profile to Inventory app\n");
				log("succeed setting the default MCML profile to Inventory app\n");
				log("succeed setting the default MCML profile to Inventory app\n");
			else
				log("failed setting the default MCML profile to Inventory app\n");
			end	
		end)
	else
		local item_instance = profile.item_instance;
		local character_inventory = profile.character_inventory;
		local i, item_inv;
		-- init the character inventory
		for i, item_inv in pairs(character_inventory) do
			if(item_inv.ItemFamily == 0) then
				-- this item is equipped on character
				equips[item_inv.position] = {itemID = item_inv.itemID, gsID = item_inv.gsID};
			else
				-- this item is in the category of the user's inventory
				bags[item_inv.ItemFamily] = bags[item_inv.ItemFamily] or {};
				bags[item_inv.ItemFamily] = {itemID = item_inv.itemID, gsID = item_inv.gsID};
			end
		end
		-- init the item instance
		local guid, item_inst;
		for guid, item_inst in pairs(item_instance) do
			items[guid] = {guid = item_inst.guid, StackCount = item_inst.StackCount};
		end
	end
	
	local _ = ParaUI.CreateUIObject("container", "ItemManagerFrameTimer", "_lt", -10, -10, 1, 1);
	_.onframemove = ";Map3DSystem.Item.ItemManager.DoFramemove();";
	_:AttachToRoot();
	
	ItemManager.RegisterListenProxy();
	
	-- TODO: get link items
	-- get the link items via the MyDesktop MCML profile
	-- full profile of all apps are downloaded at login process stage 4
	
	do return end
	
	--Map3DSystem.App.MyDesktop.app:GetMCML()
	--
	--RefreshActionFeedView_(profile);
	--
	--Map3DSystem.App.MyDesktop.app:GetMCML(uid, function(uid, app_key, bSucceed)
		--local profile;
		--if(bSucceed) then
			--profile = Map3DSystem.App.ActionFeed.app:GetMCMLInMemory(uid);
		--else
			--log("warning: error fetching action feeds\n")    
		--end
		--RefreshActionFeedView_(profile)
	--end, cache_policy)
	
end

function ItemManager.DoFramemove()
	-- do the slot framemove, mainly for emulated item icon cursor
	Map3DSystem.Item.Slot.DoFramemove();
end

function ItemManager.RegisterListenProxy()
	NPL.load("(gl)script/kids/3DMapSystemApp/API/epoll_serverproxy.lua");
	ItemManager.proxy_ListenLinks = paraworld.epoll_serverproxy:new({
		KeepAliveInterval = 10000,
		ServerTimeOut = 60000,
	});
	
	ItemManager.proxy_ListenBags = paraworld.epoll_serverproxy:new({
		KeepAliveInterval = 2500,
		ServerTimeOut = 20000,
	});
	
	-- set listen link timer
	NPL.SetTimer(2489, 0.1, ";Map3DSystem.Item.ItemManager.ListenItemEvent();");
end

function ItemManager.ListenItemEvent()
	
	do return end
	
	ItemManager.ListenBags()
	ItemManager.ListenEquips()
	ItemManager.ListenLinks()
end

function ItemManager.SetGlobalStoreWithLocal()
	-- connect to all applications in the app registration db
	local db = Map3DSystem.App.Registration.ConnectToAppDB();
	if(db ~= nil) then
		local cmd = string.format("SELECT * FROM apps ORDER BY listorder ASC");
		local row;
		for row in db:rows(cmd) do
			Map3DSystem.App.AppManager.StartupApp(row)
		end
	end
end

function ItemManager.ListenBags()
	-- check if it is time to send another message with our proxy
	if( not ItemManager.proxy_ListenBags:CanSendUpdate() ) then
		return
	end
	
	ItemManager.proxy_ListenBags:Call(function()
		local uid = Map3DSystem.App.profiles.ProfileManager.GetUserID();
		Map3DSystem.App.Inventory.app:GetMCML(uid, function(uid, app_key, bSucceed)
			if(bSucceed) then
				local profile;
				profile = Map3DSystem.App.Inventory.app:GetMCMLInMemory(uid);
				log("ItemManager.proxy_ListenBags: ");
				commonlib.echo(profile);
				
				local bags = ItemManager.slots.bags;
				
				if(profile == nil or type(profile) ~= "table" or #profile == 0) then
					-- TODO: set the default MCML link table
					profile = {};
					local i = 1;
					for i = 1, 10 do
						profile[i] = i;
					end
					Map3DSystem.App.Inventory.app:SetMCML(uid, profile, function (uid, appkey, bSucceed)
						ItemManager.proxy_ListenBags:OnRespond();
						if(bSucceed) then
							log("succeed setting the default MCML profile to inventory slots of Inventory app\n");
						else
							log("failed setting the default MCML profile to inventory slots of Inventory app\n");
						end	
					end);
				else
					ItemManager.proxy_ListenBags:OnRespond();
					--local isUpdated = false;
					--local position, link;
					--for position, link in pairs(links) do
						--local gsID = link:GetGlobalStoreID();
						--if(gsID ~= profile[position]) then
							---- the links have been changed
							--links[position].linkid = profile[position];
							--isUpdated = true;
						--end
					--end
					--if(isUpdated == true) then
						---- TODO: refresh all PageCtrls that contain pe:slot tags
						--Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls()
						---- call "OnLinksUpdate" event handler
						--local callbackFunc = ItemManager.EventListener["OnBagsUpdate"]
						--if(type(callbackFunc) == "function") then
							--callbackFunc();
						--end
					--end
				end
			else
				log("warning: error fetching Inventory bag slots\n");
			end
		end, "access plus 0 day");
	end);
end

function ItemManager.ListenEquips()
end

function ItemManager.ListenLinks()
	-- check if it is time to send another message with our proxy
	if( not ItemManager.proxy_ListenLinks:CanSendUpdate() ) then
		return
	end
	
	ItemManager.proxy_ListenLinks:Call(function()
		local position, link;
		local profile = {};
		for position, link in pairs(ItemManager.slots.links) do
			local gsID = link:GetGlobalStoreID();
			if(gsID == nil or gsID == 0) then
				profile[position] = nil;
			else
				profile[position] = gsID;
			end
		end
		
		-- set the quicklaunch MCML profile every update interval
		-- TODO: on-demand MCML profile update
		Map3DSystem.App.MyDesktop.app:SetMCML(uid, profile, function (uid, appkey, bSucceed)
			ItemManager.proxy_ListenLinks:OnRespond();
			if(bSucceed == false) then
				log("failed SetMCML of MyDesktop app\n");
			end
		end);
	end);
end

-- set the quick launch link to the specific global store id
-- listen link proxy will be set to update immediately
-- @param position: quicklaunch position
-- @param id: global store id
function ItemManager.SetLink(position, id)
	local link = ItemManager.slots.links[position];
	if(link ~= nil) then
		link.linkid = id;
	end
	-- listen link proxy will be set to update immediately
	ItemManager.proxy_ListenLinks:OffsetLastSendTime(-ItemManager.proxy_ListenLinks.KeepAliveInterval);
end

-- swap quick launch link slots
-- listen link proxy will be set to update immediately
-- @param fromPosition: source launch link position
-- @param toPosition: destination launch link position
function ItemManager.SwapLink(fromPosition, toPosition)
	local fromLink = ItemManager.slots.links[fromPosition];
	local toLink = ItemManager.slots.links[toPosition];
	if(fromLink ~= nil and toLink ~= nil) then
		local temp;
		temp = fromLink.linkid;
		fromLink.linkid = toLink.linkid;
		toLink.linkid = temp;
	end
	-- listen link proxy will be set to update immediately
	ItemManager.proxy_ListenLinks:OffsetLastSendTime(-ItemManager.proxy_ListenLinks.KeepAliveInterval);
end

---------------------------------
-- item instance functions
---------------------------------
-- validate my inventory at user login
function ItemManager.ValidateMyInventory()
	-- NOTE: currently use local inventory
	-- head
	ItemManager.items[101] = Map3DSystem.Item.Item_Bag:new({id = 101, gsid = 1001, bag = 101, slot = -1, ContainerSlots = 40, BagFamily = 1001});
	-- face
	ItemManager.items[102] = Map3DSystem.Item.Item_Bag:new({id = 102, gsid = 1001, bag = 102, slot = -1, ContainerSlots = 40, BagFamily = 1002});
	-- neck
	ItemManager.items[103] = Map3DSystem.Item.Item_Bag:new({id = 103, gsid = 1001, bag = 103, slot = -1, ContainerSlots = 40, BagFamily = 1003});
	-- shoulder
	ItemManager.items[104] = Map3DSystem.Item.Item_Bag:new({id = 104, gsid = 1001, bag = 104, slot = -1, ContainerSlots = 40, BagFamily = 1004});
	-- hand
	ItemManager.items[105] = Map3DSystem.Item.Item_Bag:new({id = 105, gsid = 1001, bag = 105, slot = -1, ContainerSlots = 40, BagFamily = 1005});
	-- chest
	ItemManager.items[106] = Map3DSystem.Item.Item_Bag:new({id = 106, gsid = 1001, bag = 106, slot = -1, ContainerSlots = 40, BagFamily = 1006});
	-- hip
	ItemManager.items[107] = Map3DSystem.Item.Item_Bag:new({id = 107, gsid = 1001, bag = 107, slot = -1, ContainerSlots = 40, BagFamily = 1007});
	-- leg
	ItemManager.items[108] = Map3DSystem.Item.Item_Bag:new({id = 108, gsid = 1001, bag = 108, slot = -1, ContainerSlots = 40, BagFamily = 1008});
	-- foot
	ItemManager.items[109] = Map3DSystem.Item.Item_Bag:new({id = 109, gsid = 1001, bag = 109, slot = -1, ContainerSlots = 40, BagFamily = 1009});
	-- back
	ItemManager.items[110] = Map3DSystem.Item.Item_Bag:new({id = 110, gsid = 1001, bag = 110, slot = -1, ContainerSlots = 40, BagFamily = 1010});
	-- tattoo
	ItemManager.items[111] = Map3DSystem.Item.Item_Bag:new({id = 111, gsid = 1001, bag = 111, slot = -1, ContainerSlots = 40, BagFamily = 1011});
end

ItemManager.ValidateMyInventory();

-- get items by bag and slot
-- NOTE: there will might be not only one item in one slot, the items can be stackable
-- @params bag_id_instance: bag item instance id
-- @params slot: position in the bag
function ItemManager.GetItems(bag_id_instance, slot)
	--commonlib.echo({bag_id_instance, slot});
	if(bag_id_instance == 101) then
		if(slot < 17) then
			local id = bag_id_instance * 1000 + slot;
			local item = ItemManager.items[id];
			if(item == nil) then
				ItemManager.items[id] = Map3DSystem.Item.Item_Apparel:new({id = id, bag = bag_id_instance, slot = slot});
			end
			return {[1] = item};
		end
	end
end

-- get link by linkid
-- @params position: position of the link in quicklaunch bar
function ItemManager.GetLink(position)
	--commonlib.echo({bag_id_instance, slot});
	--local gsItem = ItemManager.ReadGlobalStoreItem(link);
	--if(gsItem) then
		--gsItem.id
	--end
	
	return ItemManager.slots.links[position];
	
	--if(ItemManager.items[1] == nil) then
		--ItemManager.items[1] = Map3DSystem.Item.Exe_App:new({appkey=System.App.appkeys["Creator"]});
		--ItemManager.items[2] = Map3DSystem.Item.Exe_App:new({appkey=System.App.appkeys["CCS"]});
		--ItemManager.items[3] = Map3DSystem.Item.Exe_App:new({appkey=System.App.appkeys["chat"]});
		--ItemManager.items[4] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="File.Open.Asset",});
		--ItemManager.items[5] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="File.Open.PersonalWorld",});
		--ItemManager.items[6] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="File.SaveAndPublish",});
		--ItemManager.items[7] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="File.MCMLBrowser",});
		--ItemManager.items[8] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="Env.terrain", params="adv",});
		--ItemManager.items[9] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="File.ArtTools",});
		--ItemManager.items[10] = Map3DSystem.Item.Exe_AppCommand:new({AppCommand="File.ProTools",});
	--end
	--
	--return ItemManager.items[link];
end

-- get all bags in user inventory
function ItemManager.GetMyBags()
	local i = 1;
	local _, item;
	local ret = {};
	for _, item in pairs(ItemManager.items) do
		if(item:GetType() == Map3DSystem.Item.Types.Item_Bag) then
			ret[i] = item;
			i = i + 1;
		end
	end
	return ret;
end

-- get all items in specific bag in user inventory
-- @params bag_id_instance: bag item instance id
function ItemManager.GetItemsInMyBag(bag_id_instance)
	
end

-- use item
-- @params id_instance: item instance id
function ItemManager.UseItemByInstance(id_instance)
end

-- use item
-- @params id_globalstore: item GlobalStore id
function ItemManager.UseItemByGlobalStore(id_globalstore)
end

-- use item
-- @params bag_id_instance: bag item instance id
-- @params position: position in the bag
function ItemManager.UseItemByBagPosition(bag_id_instance, position)
end

-- use item
-- @params id_instance: item instance id
function ItemManager.EquipItemByInstance(id_instance)
end


---------------------------------
-- events
---------------------------------
-- add event listener callbackFunc
-- @param eventType:
	--["OnBagsUpdate"] = nil, -- OnBagsUpdate
	--["OnEquipsUpdate"] = nil, -- OnEquipsUpdate
	--["OnLinksUpdate"] = nil, -- OnLinksUpdate
-- @callbackFunc function that will call on the event
function ItemManager.AddEventListener(eventType, callbackFunc)
	if(eventType == "OnBagsUpdate") then
		ItemManager.EventListener["OnBagsUpdate"] = callbackFunc;
	elseif(eventType == "OnEquipsUpdate") then
		ItemManager.EventListener["OnEquipsUpdate"] = callbackFunc;
	elseif(eventType == "OnLinksUpdate") then
		ItemManager.EventListener["OnLinksUpdate"] = callbackFunc;
	end
end
