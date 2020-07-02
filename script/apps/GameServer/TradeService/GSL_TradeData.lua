--[[
Title: Data structures used in Trade service
Author(s): LiXizhi
Date: 2011/10/12
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeData.lua");
local TradeMSG = commonlib.gettable("Map3DSystem.GSL.Trade.TradeMSG")
local trade_container = commonlib.gettable("Map3DSystem.GSL.Trade.trade_container");
local trade_transaction = commonlib.gettable("Map3DSystem.GSL.Trade.trade_transaction");
-----------------------------------------------
]]
local tostring = tostring;

-- max trade items in a trade container
local max_trade_item_count = 10;

local TradeMSG = commonlib.createtable("Map3DSystem.GSL.Trade.TradeMSG",{
	-- from client to server: start trading with a given user {target_nid = string}
	-- from server to client: ask a user to start trade from another user {from_nid = string}
	TRADE_REQUEST = 1,
	-- from client to server: a user either accept or reject the trade request {to_nid=string, accepted=boolean,}
	-- from server to client: {from_nid=string, accepted=boolean,}
    TRADE_RESPONSE = 2,
	-- from client to server: the client changes its trade items or money  {trad_cont={...}}
    TRADE_ITEM_UPDATE = 3,
	-- from server to client: the state of the trade changes. {trad_trans={}} to prevent data loss, the entire trade_transaction is sent back when data changes.
    TRADE_ITEM_RESPONSE = 4,
	-- from client to server: confirm the trade of the current user
	TRADE_CONFIRM = 5,
	-- from client to server: say ok to the trade
    TRADE_OK = 6,
	-- from client to server: cancel trade
	-- from server to client: cancel trade
    TRADE_CANCEL = 7,
	-- from server to client: trade is started and submmited to the db server. any user action should be locked, and client should wait for the TRADE_COMPLETE in the next moment. 
    TRADE_STARTED = 8,
	-- from server to client: {issuccess=boolean, ...}
    TRADE_COMPLETE = 9,
});

-----------------------
-- trade_container class: represent a single player's trade info
------------------------
local trade_container = commonlib.createtable("Map3DSystem.GSL.Trade.trade_container", {
	-- current user nid
	nid,
	-- the unbinded money to be traded. 
	money = 0,
	-- all inventory items to be traded. array of {guid, count,gsid, server_data} pair {{guid,count,gsid, server_data}, ...}
	items,
	-- if current user has confirmed (view locked) items to be traded with the other player. 
	is_confirmed = nil,
	-- if this user thinks that transaction can begin.
	is_ok = nil,
});

function trade_container:new(o)
	o = o or {}   -- create object if user does not provide one
	o.items = o.items or {};
	setmetatable(o, self)
	self.__index = self
	return o
end

-- if there is already items, the count is overridden. 
function trade_container:add_item(guid, count, gsid, server_data)
	local _, item
	for _, item in ipairs(self.items) do
		if(item[1] == guid) then
			item[2] = count;
			item[3] = gsid;
			item[4] = server_data;
			return
		end
	end
	if(#(self.items) < max_trade_item_count) then
		self.items[#(self.items) +1] = {guid, count, gsid, server_data};
	end
end

-- return the iterator index, item_table{guid, count, gsid}
function trade_container:each_item()
	return ipairs(self.items);
end

-- return item_table{guid, count, gsid}
function trade_container:get_item_by_gsid(gsid)
	local item_found;
	local _, item
	for _, item in ipairs(self.items) do
		if(item[3] == gsid) then
			item_found = item;
			break;
		end
	end
	return item_found;
end

-- return item_table{guid, count, gsid}
function trade_container:get_item_by_guid(guid)
	local item_found;
	local _, item
	for _, item in ipairs(self.items) do
		if(item[3] == guid) then
			item_found = item;
			break;
		end
	end
	return item_found;
end

-- this will ensure that the same items are not traded both ways. 
function trade_container:normalize_with(cont2)
	local remove_list;
	local _, item
	for _, item in ipairs(self.items) do
		local gsid = item[3];
		if(gsid) then
			local duplicated_item = cont2:get_item_by_gsid(gsid);
			if(duplicated_item and item[2] and duplicated_item[2]) then
				local count_self = item[2];
				local count_other = duplicated_item[2];
				if(count_self>count_other) then
					-- remove the lesser count
					item[2] = count_self - count_other;
					cont2:remove_item(duplicated_item[1]);
				elseif(count_self == count_other) then
					-- remove both
					remove_list = remove_list or {};
					remove_list[#remove_list+1] = item[1];
					cont2:remove_item(duplicated_item[1]);
				else
					-- remove the lesser count
					duplicated_item[2] = count_other - count_self;
					remove_list = remove_list or {};
					remove_list[#remove_list+1] = item[1];
				end
			end
		end
	end
	if(remove_list) then
		local _, guid
		for _, guid in ipairs(remove_list) do
			self:remove_item(guid);
		end
	end
end

function trade_container:remove_item(guid)
	local i, item
	for i, item in ipairs(self.items) do
		if(item[1] == guid) then
			commonlib.removeArrayItem(self.items, i);
			return;
		end
	end
end

-- return true if there is at least one item that is changed. 
function trade_container:set_items_and_money(items, money)
	local bChanged;
	if(money and self.money ~= money) then
		self.money = tonumber(money); 
		bChanged = true;
	end
	if(items) then
		local i;
		for i = 1, max_trade_item_count do
			local from_item = items[i];

			-- Note: this code test gsid injection bug. 
			--if(from_item and from_item[3]) then
				--from_item[3] = 10187 -- FireBeast
			--end

			local to_item = self.items[i];
			if(from_item and to_item and from_item[1]==to_item[1] and from_item[2]==to_item[2]  and from_item[3]==to_item[3]) then
				-- same
			elseif(from_item or to_item) then
				bChanged = true;
				self.items[i] = from_item;
			else
				break;
			end
		end
	end
	return bChanged;
end

function trade_container:set_money(money)
	self.money = money;
end

-- if the container has neither money nor items. 
function trade_container:is_empty()
	if(self.money == 0 and #(self.items) == 0) then
		return true;
	end
end

-- return true
function trade_container:verify_items()
	local gsid_map = {};
	local guid_map = {};
	local _, item
	for _, item in ipairs(self.items) do
		local guid = item[1];
		local gsid = item[3];
		if(guid and not guid_map[guid] and gsid and not gsid_map[gsid] and item[2] and item[2]>0) then
			guid_map[guid] = true;
			gsid_map[gsid] = true;
		else
			return false;
		end
	end

	return true;
end
------------------------
-- trade_transaction class: 
------------------------
local trade_transaction = commonlib.createtable("Map3DSystem.GSL.Trade.trade_transaction", {
	-- trade container 1
	trad_cont1 = nil,
	-- trade container 2
	trad_cont2 = nil,
	-- time when trade is first requested. 
	start_time = nil,
	-- nil waiting for player request,  1 oked but waiting for db reply, 2 completed, 3 failed. 
	state = nil,
	-- the revision number. every time the transaction items are changed, the revision number is increased by 1. 
	revision = nil,
	-- we are expecting this user to join
	expecting_nid = nil,
	-- true if anything is modified, and data should be sync back to both clients. 
	is_modified = nil,
});

function trade_transaction:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	o.trad_cont1 = trade_container:new(o.trad_cont1);
	o.trad_cont2 = trade_container:new(o.trad_cont2);
	return o
end

function trade_transaction:clear()
end

-- The first one added is the started. 
-- we will refresh self.start_time to current time whenever a player is added. 
-- @return true if added
function trade_transaction:add_player(nid)
	if( not self:get_container_by_nid(nid) ) then
		if(not self.trad_cont1.nid) then
			self.trad_cont1.nid = nid;
			self.start_time = commonlib.TimerManager.GetCurrentTime();
			return true;
		elseif(not self.trad_cont2.nid) then
			self.trad_cont2.nid = nid;
			self.start_time = commonlib.TimerManager.GetCurrentTime();
			return true;
		end
	else
		return true;
	end
end

-- the nid that started the trade by requesting another player.  
function trade_transaction:get_starter_nid()
	return self.trad_cont1.nid;
end

-- get users by nids
-- return nid1, nid2
function trade_transaction:get_player_nids()
	return self.trad_cont1.nid, self.trad_cont2.nid;
end

-- get container info by nid
-- @return cont, other_cont: the first parameter is the cont of nid, the second one is the other person's container. 
function trade_transaction:get_container_by_nid(nid)
	if(self.trad_cont1.nid == nid) then
		return self.trad_cont1, self.trad_cont2;
	elseif(self.trad_cont2.nid == nid) then
		return self.trad_cont2, self.trad_cont1;
	end
end

-- if there is already a player
function trade_transaction:has_player(nid)
	if(self.trad_cont1.nid == nid or self.trad_cont2.nid == nid) then
		return true;
	end
end

-- if both players are validd
function trade_transaction:is_valid()
	if(self.trad_cont1.nid and self.trad_cont2.nid) then
		return true;
	end
end

-- return true if anything changed and a message should be sent back to inform both clients. 
-- @param revision: the revision number as seen by the client. 
function trade_transaction:update_items(nid, trad_cont, revision)
	local cont, cont2 = self:get_container_by_nid(nid);
	local bChanged;
	if(cont and trad_cont) then
		if( cont:set_items_and_money(trad_cont.items, trad_cont.money) ) then
			-- cancel any ok state if items changes. 
			if(trad_cont.is_confirmed == true) then
				cont.is_confirmed = true;
			elseif(trad_cont.is_confirmed == false) then
				cont.is_confirmed = nil;
			end
			self.revision = (self.revision or 0) + 1;
			cont2.is_confirmed = nil;
			cont.is_ok = nil;
			cont2.is_ok = nil;
			bChanged = true;
		else
			-- If the client revision is different from the server revision, we will cancel all ok states and resend the current revision to client. 
			if(revision and revision ~= self.revision) then
				cont.is_ok = nil;
				cont2.is_ok = nil;
				cont.is_confirmed = nil;
				cont2.is_confirmed = nil;
				bChanged = true;
			else
				-- the most tricky logics goes here. is_confirmed and is_ok are automatically turned on/off for both clients. 
				if(trad_cont.is_confirmed == false) then
					if(cont.is_ok) then
						cont.is_ok = nil;
						bChanged = true;
					end
					if(cont.is_confirmed) then
						cont.is_confirmed = nil;
						bChanged = true;
					end
					cont2.is_ok = nil;
				elseif(trad_cont.is_confirmed == true) then
					if(not cont.is_confirmed) then
						cont.is_confirmed = true;
						bChanged = true;
					end
				end
			
				if(trad_cont.is_ok) then
					if(self:is_confirmed()) then
						if(not cont.is_ok) then
							cont.is_ok = true;
							bChanged = true;
						end
					else
						bChanged = true;
					end
				elseif(trad_cont.is_ok == false) then
					if(cont.is_ok) then
						cont.is_confirmed = nil;
						cont.is_ok = nil;
						cont2.is_confirmed = nil;
						cont2.is_ok = nil;
						bChanged = true;
					end
				end
			end
		end
	end
	self.is_modified = self.is_modified or bChanged;
	return bChanged;
end

function trade_transaction:is_confirmed()
	return (self.trad_cont1.is_confirmed and self.trad_cont2.is_confirmed);
end

function trade_transaction:is_ok()
	return (self.trad_cont1.is_ok and self.trad_cont2.is_ok)
end

-- if this is an empty transaction. 
function trade_transaction:is_both_empty()
	return (self.trad_cont1:is_empty() and self.trad_cont2:is_empty())
end

-- a finished transaction is either succeded or failed. 
function trade_transaction:is_finished()
	return (self.state and self.state>=2)
end

-- this will ensure that the same items are not traded both ways. 
function trade_transaction:normalize()
	self.trad_cont1:normalize_with(self.trad_cont2)
end

-- it will check if all item information are valid.
function trade_transaction:verify_items()
	if(self.trad_cont1 and self.trad_cont2) then
		return self.trad_cont1:verify_items() and self.trad_cont2:verify_items();
	end
end