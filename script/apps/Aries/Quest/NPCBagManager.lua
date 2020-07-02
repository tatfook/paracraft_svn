--[[
Title: Aries quest NPC bag manager
Author(s): WangTian
Date: 2009/7/21

Desc: helper functions for NPC bag items

---++ Aries Quest System
Aries quest system uses a complete item system implementation.

---++ Computing Analogy
Each NPC entity has various attributes, including:
	Apparaence: name, position, asset file, customizable info
	AI script: On_Perception, On_Framemove, .etc script and sentient radius
	Memory: items in each user's bag and a RAM memory on each item
	FSM: MCML dialog script containing all the dialog status

At login procedure, bag 30000 is fetched for NPCs that need initialization. On each world load the windows

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/NPCBagManager.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Quest/main.lua");

-- create class
local libName = "NPCBagManager";
local NPCBagManager = commonlib.gettable("MyCompany.Aries.Quest.NPCBagManager");

local tonumber = tonumber
local type = type

NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local LOG = LOG;

NPCBagManager.BagsFetchedInCurrentSession = {};
NPCBagManager.NPC_valid_bags = {};

-- reset NPC bag session
function NPCBagManager.ResetBagsFetchedInCurrentSession()
	NPCBagManager.BagsFetchedInCurrentSession = {};
	
	-- append quest NPC tag bags
	local i;
	for i = 50000, 59999 do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(i);
		if(gsItem) then
			local bagfamily = tonumber(gsItem.template.bagfamily);
			if(bagfamily > 30000) then
				NPCBagManager.NPC_valid_bags[bagfamily] = true;
			end
		end
	end
end

-- get the NPC bag from npc_id
-- @param npc_id: npc id
-- @param callbackFunc: the callback function(msg) end
-- @param cache_policy: nil or string or a cache policy object, default to "access plus 0 day"
function NPCBagManager.GetNPCBag(npc_id, callbackFunc, cachepolicy)
	if(type(npc_id) ~= "number") then
		LOG.std("", "error", "NPC", "non-number npc_id got in NPCBagManager.GetNPCBag");
		return;
	end
	-- bag uses 2byte smallint range: -2^15 (-32,768) to 2^15-1 (32,767)
	if(npc_id > 32760) then
		-- LOG.std("", "debug", "NPC", "npc_id %d doesn't require item memory, npc bag fetch skiped", npc_id)
		callbackFunc({});
		return;
	end
	
	-- NOTE: the bags are fetched by force in the user login process(stage sync inventory)
	if(not cachepolicy) then
		-- mod the npc_id to avoid a large number of npc bags retrieve call at the same time
		cachepolicy = "access plus "..(15 + (npc_id % 23)).." minutes";
	end
	
	-- skip npc bags that has no items related to them
	if(NPCBagManager.NPC_valid_bags[npc_id] ~= true) then
		callbackFunc({items={}});
		return;
	end
	
	-- NOTE: execute the callback function first instead of async calls, incase of timer function invoked before NPC_main()
	callbackFunc();
	
	local id = ParaGlobal.GenerateUniqueID();
	ItemManager.GetItemsInBag(npc_id, "GetNPCBag_"..npc_id.."_"..id, function(msg)
		if(msg and msg.items) then
			NPCBagManager.BagsFetchedInCurrentSession[npc_id] = true;
		end
		--callbackFunc(msg);
	end, cachepolicy, 10000, function()
		--callbackFunc(msg);
	end);
end

-- check if the NPC bag is ever fetched from the server
-- @return: true or false
function NPCBagManager.IsNPCBagFetched(npc_id)
	if(type(npc_id) ~= "number") then
		LOG.std("", "error", "NPC", "non-number npc_id got in NPCBagManager.IsNPCBagFetched");
		return;
	end
	-- directly use the itemmanager user bag item list for NPC bag fetch checking
	local itemlist = ItemManager.bags[tonumber(npc_id)];
	if(itemlist) then
		return true;
	else
		return false;
	end
end

-- get the NPC item count in npc bag
-- @param npc_id: npc id
-- @return: item count
function NPCBagManager.GetNPCBagItemCount(npc_id)
	if(type(npc_id) ~= "number") then
		LOG.std("", "error", "NPC", "non-number npc_id got in NPCBagManager.GetNPCBagItemCount");
		return;
	end
	return ItemManager.GetItemCountInBag(npc_id);
end

-- get the NPC item by order
-- @param npc_id: npc id
-- @param order: the local order of the item in the same bag, starts from 1
-- @return: item data, nil if not found
function NPCBagManager.GetNPCBagItemByOrder(npc_id, order)
	if(type(npc_id) ~= "number") then
		LOG.std("", "error", "NPC", "non-number npc_id got in NPCBagManager.GetNPCBagItemByOrder");
		return;
	end
	return ItemManager.GetItemByBagAndOrder(npc_id, order);
end

-- get the NPC item by position
-- @param npc_id: npc id
-- @param position: item position in item_instance
-- @return: item data, {guid = 0} if not found
function NPCBagManager.GetNPCBagItemByPosition(npc_id, position)
	if(type(npc_id) ~= "number") then
		LOG.std("", "error", "NPC", "non-number npc_id got in NPCBagManager.GetNPCBagItemByOrder");
		return;
	end
	return ItemManager.GetItemByBagAndPosition(npc_id, position);
end

-- destroy all items in npc bag
-- @param npc_id: npc id
-- @param callbackFunc: the callback function(msg) end
function NPCBagManager.DestroyNPCBagItemsInMemory(npc_id)
	if(type(npc_id) ~= "number") then
		LOG.std("", "error", "NPC", "non-number npc_id got in NPCBagManager.DestroyNPCBagItemsInMemory");
		return;
	end
	
	local count = NPCBagManager.GetNPCBagItemCount(npc_id);
	local items = {};
	local i;
	for i = 1, count do
		local item = NPCBagManager.GetNPCBagItemByOrder(npc_id, i);
		if(item and item.guid > 0) then
		end
		table.insert(items, {guid = item.guid, copies = item.copies});
	end
	
	local _, item;
	for _, item in pairs(items) do
        ItemManager.DestroyItem(item.guid, item.copies, function(msg) 
	        log("+++++++Destroy guid:"..item.guid.." with copies:"..item.copies.." return: +++++++\n")
	        commonlib.echo(msg);
        end);
	end
end