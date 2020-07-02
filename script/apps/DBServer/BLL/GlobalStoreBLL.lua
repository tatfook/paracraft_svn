--[[
NPL.load("(gl)script/apps/DBServer/BLL/GlobalStoreBLL.lua");
local GlobalStoreBLL = commonlib.gettable("DBServer.BLL.GlobalStoreBLL");
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/LocalCache.lua");
NPL.load("(gl)script/apps/DBServer/DBProvider.lua");
NPL.load("(gl)script/apps/DBServer/Entity/GlobalStoreEntity.lua");

local LocalCache = commonlib.gettable("DBServer.LocalCache");
local DBProvider = commonlib.gettable("DBServer.DBProvider");
local GlobalStoreEntity = commonlib.gettable("DBServer.GlobalStoreEntity");

local GlobalStoreBLL = commonlib.gettable("DBServer.BLL.GlobalStoreBLL");
GlobalStoreBLL.dbProvider = DBProvider.getGlobalStore();
--[[
GlobalStoreBLL = {
	dbProvider = DBProvider.getGlobalStore();
};
]]


function GlobalStoreBLL.getAll()
	local _list = LocalCache.get("gss");
	if(not _list) then
		_list = {};
		local _all = GlobalStoreBLL.dbProvider:get();
		if(_all) then
			for _i in pairs(_all) do
				local _item = _all[_i];
				_list[tostring(_item.GSID)] = _item;
			end
		end
		LocalCache.set("gss", _list);
	end
	return _list;
end


function GlobalStoreBLL.get(gsid)
	local _list = GlobalStoreBLL.getAll();
	if(_list) then
		return _list[tostring(gsid)];
	end
	return nil;
end

function GlobalStoreBLL.gets(gsids)
	local _list = GlobalStoreBLL.getAll();
	if(_list) then
		local _re = {};
		table.foreach(gsids, function(_gsid)
			local _gs = _list[tostring(_gsid)];
			if(_gs) then
				_re[#(_re) + 1] = _gs;
			end
		end);
	end
	return nil;
end



function GlobalStoreBLL.add(GSID, AssetKey, AssetFile, DescFile, Type, Category, Count, Icon, PBuyPrice, EBuyPrice, PSellPrice, ESellPrice, ESellRandomBonus,
			MaxDailyCount, MaxWeeklyCount, HourlyLimitedPurchase, DailyLimitedPurchase, Class, Subclass, Name, InventoryType, MaxCount, MaxCopiesInStack, StatsCount,
			Stat_type_1, Stat_type_2, Stat_type_3, Stat_type_4, Stat_type_5, Stat_type_6, Stat_type_7, Stat_type_8, Stat_type_9, Stat_type_10, Stat_value_1, Stat_value_2,
			Stat_value_3, Stat_value_4, Stat_value_5, Stat_value_6, Stat_value_7, Stat_value_8, Stat_value_9, Stat_value_10, Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, RequirePayment, ExpireType, ExpireTime, ExpireDate, DestroyAfterExpire, Rechargeable, Material, ItemSetID, BagFamily)
	-- TODO:
end



function GlobalStoreBLL.update(GSID, AssetKey, AssetFile, DescFile, Type, Category, Count, Icon, PBuyPrice, EBuyPrice, PSellPrice, ESellPrice, ESellRandomBonus,
			MaxDailyCount, MaxWeeklyCount, HourlyLimitedPurchase, DailyLimitedPurchase, Class, Subclass, Name, InventoryType, MaxCount, MaxCopiesInStack, StatsCount,
			Stat_type_1, Stat_type_2, Stat_type_3, Stat_type_4, Stat_type_5, Stat_type_6, Stat_type_7, Stat_type_8, Stat_type_9, Stat_type_10, Stat_value_1, Stat_value_2,
			Stat_value_3, Stat_value_4, Stat_value_5, Stat_value_6, Stat_value_7, Stat_value_8, Stat_value_9, Stat_value_10, Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, RequirePayment, ExpireType, ExpireTime, ExpireDate, DestroyAfterExpire, Rechargeable, Material, ItemSetID, BagFamily)
	-- TODO:
end



function GlobalStoreBLL.delete(GSID)
	-- TODO:
end