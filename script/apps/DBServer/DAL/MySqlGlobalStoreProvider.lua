NPL.load("(gl)script/ide/mysql/mysql.lua");

NPL.load("(gl)script/apps/DBServer/DBSettings.lua");
NPL.load("(gl)script/apps/DBServer/DataAccess.lua");
NPL.load("(gl)script/apps/DBServer/Entity/GlobalStoreEntity.lua");

local luasql = commonlib.luasql;

local DataAccess = commonlib.gettable("DBServer.DataAccess");
local GlobalStoreEntity = commonlib.gettable("DBServer.GlobalStoreEntity");

local MySqlGlobalStoreProvider = commonlib.inherit(DataAccess, commonlib.gettable("DBServer.DAL.MySqlGlobalStoreProvider"));

--[[
local MySqlGlobalStoreProvider = DataAccess:new({_instance = nil});
function MySqlGlobalStoreProvider:new(o)
	o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end
]]

function MySqlGlobalStoreProvider:getListFromReader(reader)
	local _list = {};
	--[[
	for GSID, AssetKey, AssetFile, DescFile, Type, Category, Count, Icon, PBuyPrice, EBuyPrice, PSellPrice, ESellPrice, ESellRandomBonus,
			MaxDailyCount, MaxWeeklyCount, HourlyLimitedPurchase, DailyLimitedPurchase, Class, Subclass, Name, InventoryType, MaxCount, MaxCopiesInStack, StatsCount,
			Stat_type_1, Stat_type_2, Stat_type_3, Stat_type_4, Stat_type_5, Stat_type_6, Stat_type_7, Stat_type_8, Stat_type_9, Stat_type_10, Stat_value_1, Stat_value_2,
			Stat_value_3, Stat_value_4, Stat_value_5, Stat_value_6, Stat_value_7, Stat_value_8, Stat_value_9, Stat_value_10, Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, RequirePayment, ExpireType, ExpireTime, ExpireDate, DestroyAfterExpire, Rechargeable, Material, ItemSetID, BagFamily in reader do
	  table.insert(_list, GlobalStoreEntity:new(tonumber(GSID), AssetKey, AssetFile, DescFile, tonumber(Type), tonumber(Category), tonumber(Count), Icon, tonumber(PBuyPrice), tonumber(EBuyPrice), tonumber(PSellPrice), tonumber(ESellPrice), tonumber(ESellRandomBonus),
			tonumber(MaxDailyCount), tonumber(MaxWeeklyCount), tonumber(HourlyLimitedPurchase), tonumber(DailyLimitedPurchase), tonumber(Class), tonumber(Subclass), Name, tonumber(InventoryType), tonumber(MaxCount), tonumber(MaxCopiesInStack), tonumber(StatsCount),
			tonumber(Stat_type_1), tonumber(Stat_type_2), tonumber(Stat_type_3), tonumber(Stat_type_4), tonumber(Stat_type_5), tonumber(Stat_type_6), tonumber(Stat_type_7), tonumber(Stat_type_8), tonumber(Stat_type_9), tonumber(Stat_type_10), tonumber(Stat_value_1), tonumber(Stat_value_2),
			tonumber(Stat_value_3), tonumber(Stat_value_4), tonumber(Stat_value_5), tonumber(Stat_value_6), tonumber(Stat_value_7), tonumber(Stat_value_8), tonumber(Stat_value_9), tonumber(Stat_value_10), Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, tonumber(RequirePayment), tonumber(ExpireType), tonumber(ExpireTime), ExpireDate, tonumber(DestroyAfterExpire), Rechargeable, tonumber(Material), tonumber(ItemSetID), tonumber(BagFamily)));
	end
	]]

	--[[
	while reader() do
		commonlib.log(reader.GSID .. " __ ");
		table.insert(_list, GlobalStoreEntity:new(tonumber(reader.GSID), reader.AssetKey, reader.AssetFile, reader.DescFile, tonumber(reader.Type), tonumber(reader.Category), tonumber(reader.Count), reader.Icon, tonumber(reader.PBuyPrice), tonumber(reader.EBuyPrice), tonumber(reader.PSellPrice), tonumber(reader.ESellPrice), tonumber(reader.ESellRandomBonus),
			tonumber(reader.MaxDailyCount), tonumber(reader.MaxWeeklyCount), tonumber(reader.HourlyLimitedPurchase), tonumber(reader.DailyLimitedPurchase), tonumber(reader.Class), tonumber(reader.Subclass), reader.Name, tonumber(reader.InventoryType), tonumber(reader.MaxCount), tonumber(reader.MaxCopiesInStack), tonumber(reader.StatsCount),
			tonumber(reader.Stat_type_1), tonumber(reader.Stat_type_2), tonumber(reader.Stat_type_3), tonumber(reader.Stat_type_4), tonumber(reader.Stat_type_5), tonumber(reader.Stat_type_6), tonumber(reader.Stat_type_7), tonumber(reader.Stat_type_8), tonumber(reader.Stat_type_9), tonumber(reader.Stat_type_10), tonumber(reader.Stat_value_1), tonumber(reader.Stat_value_2),
			tonumber(reader.Stat_value_3), tonumber(reader.Stat_value_4), tonumber(reader.Stat_value_5), tonumber(reader.Stat_value_6), tonumber(reader.Stat_value_7), tonumber(reader.Stat_value_8), tonumber(reader.Stat_value_9), tonumber(reader.Stat_value_10), reader.Description, reader.CanUseDirectly, reader.DestroyAfterUse,
			reader.CanSell, reader.CanExchange, reader.CanGift, tonumber(reader.RequirePayment), tonumber(reader.ExpireType), tonumber(reader.ExpireTime), reader.ExpireDate, tonumber(reader.DestroyAfterExpire), reader.Rechargeable, tonumber(reader.Material), tonumber(reader.ItemSetID), tonumber(reader.BagFamily)));
	end
	]]

	for _i in pairs(reader.list) do
		local _row = reader.list[_i];
		-- commonlib.log("AABB: " .. _row.GSID .. " __ ");
		table.insert(_list, GlobalStoreEntity:new(tonumber(_row.GSID), _row.AssetKey, _row.AssetFile, _row.DescFile, tonumber(_row.Type), tonumber(_row.Category), tonumber(_row.Count), _row.Icon, tonumber(_row.PBuyPrice), tonumber(_row.EBuyPrice), tonumber(_row.PSellPrice), tonumber(_row.ESellPrice), tonumber(_row.ESellRandomBonus),
			tonumber(_row.MaxDailyCount), tonumber(_row.MaxWeeklyCount), tonumber(_row.HourlyLimitedPurchase), tonumber(_row.DailyLimitedPurchase), tonumber(_row.Class), tonumber(_row.Subclass), _row.Name, tonumber(_row.InventoryType), tonumber(_row.MaxCount), tonumber(_row.MaxCopiesInStack), tonumber(_row.StatsCount),
			tonumber(_row.Stat_type_1), tonumber(_row.Stat_type_2), tonumber(_row.Stat_type_3), tonumber(_row.Stat_type_4), tonumber(_row.Stat_type_5), tonumber(_row.Stat_type_6), tonumber(_row.Stat_type_7), tonumber(_row.Stat_type_8), tonumber(_row.Stat_type_9), tonumber(_row.Stat_type_10), tonumber(_row.Stat_value_1), tonumber(_row.Stat_value_2),
			tonumber(_row.Stat_value_3), tonumber(_row.Stat_value_4), tonumber(_row.Stat_value_5), tonumber(_row.Stat_value_6), tonumber(_row.Stat_value_7), tonumber(_row.Stat_value_8), tonumber(_row.Stat_value_9), tonumber(_row.Stat_value_10), _row.Description, _row.CanUseDirectly, _row.DestroyAfterUse,
			_row.CanSell, _row.CanExchange, _row.CanGift, tonumber(_row.RequirePayment), tonumber(_row.ExpireType), tonumber(_row.ExpireTime), _row.ExpireDate, tonumber(_row.DestroyAfterExpire), _row.Rechargeable, tonumber(_row.Material), tonumber(_row.ItemSetID), tonumber(_row.BagFamily)));
	end
	--reader.cur.close();
	
	return _list;
end


function MySqlGlobalStoreProvider.getFromRow(row)
	return GlobalStoreEntity:new(tonumber(row.GSID), row.AssetKey, row.AssetFile, row.DescFile, tonumber(row.Type), tonumber(row.Category), tonumber(row.Count), row.Icon, tonumber(row.PBuyPrice), tonumber(row.EBuyPrice), tonumber(row.PSellPrice), tonumber(row.ESellPrice), tonumber(row.ESellRandomBonus),
			tonumber(row.MaxDailyCount), tonumber(row.MaxWeeklyCount), tonumber(row.HourlyLimitedPurchase), tonumber(row.DailyLimitedPurchase), tonumber(row.Class), tonumber(row.Subclass), row.Name, tonumber(row.InventoryType), tonumber(row.MaxCount), tonumber(row.MaxCopiesInStack), tonumber(row.StatsCount),
			tonumber(row.Stat_type_1), tonumber(row.Stat_type_2), tonumber(row.Stat_type_3), tonumber(row.Stat_type_4), tonumber(row.Stat_type_5), tonumber(row.Stat_type_6), tonumber(row.Stat_type_7), tonumber(row.Stat_type_8), tonumber(row.Stat_type_9), tonumber(row.Stat_type_10), tonumber(row.Stat_value_1), tonumber(row.Stat_value_2),
			tonumber(row.Stat_value_3), tonumber(row.Stat_value_4), tonumber(row.Stat_value_5), tonumber(row.Stat_value_6), tonumber(row.Stat_value_7), tonumber(row.Stat_value_8), tonumber(row.Stat_value_9), tonumber(row.Stat_value_10), row.Description, row.CanUseDirectly, row.DestroyAfterUse,
			row.CanSell, row.CanExchange, row.CanGift, tonumber(row.RequirePayment), tonumber(row.ExpireType), tonumber(row.ExpireTime), row.ExpireDate, tonumber(row.DestroyAfterExpire), row.Rechargeable, tonumber(row.Material), tonumber(row.ItemSetID), tonumber(row.BagFamily));
end



function MySqlGlobalStoreProvider:add(GSID, AssetKey, AssetFile, DescFile, Type, Category, Count, Icon, PBuyPrice, EBuyPrice, PSellPrice, ESellPrice, ESellRandomBonus,
			MaxDailyCount, MaxWeeklyCount, HourlyLimitedPurchase, DailyLimitedPurchase, Class, Subclass, Name, InventoryType, MaxCount, MaxCopiesInStack, StatsCount,
			Stat_type_1, Stat_type_2, Stat_type_3, Stat_type_4, Stat_type_5, Stat_type_6, Stat_type_7, Stat_type_8, Stat_type_9, Stat_type_10, Stat_value_1, Stat_value_2,
			Stat_value_3, Stat_value_4, Stat_value_5, Stat_value_6, Stat_value_7, Stat_value_8, Stat_value_9, Stat_value_10, Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, RequirePayment, ExpireType, ExpireTime, ExpireDate, DestroyAfterExpire, Rechargeable, Material, ItemSetID, BagFamily)
	-- TODO:
end


function MySqlGlobalStoreProvider:update(GSID, AssetKey, AssetFile, DescFile, Type, Category, Count, Icon, PBuyPrice, EBuyPrice, PSellPrice, ESellPrice, ESellRandomBonus,
			MaxDailyCount, MaxWeeklyCount, HourlyLimitedPurchase, DailyLimitedPurchase, Class, Subclass, Name, InventoryType, MaxCount, MaxCopiesInStack, StatsCount,
			Stat_type_1, Stat_type_2, Stat_type_3, Stat_type_4, Stat_type_5, Stat_type_6, Stat_type_7, Stat_type_8, Stat_type_9, Stat_type_10, Stat_value_1, Stat_value_2,
			Stat_value_3, Stat_value_4, Stat_value_5, Stat_value_6, Stat_value_7, Stat_value_8, Stat_value_9, Stat_value_10, Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, RequirePayment, ExpireType, ExpireTime, ExpireDate, DestroyAfterExpire, Rechargeable, Material, ItemSetID, BagFamily)
	-- TODO:
end


function MySqlGlobalStoreProvider:delete(GSID)
	-- TODO:
end


function MySqlGlobalStoreProvider:get()
	local _con = self:getConnection_Items();
	
	if(not _con) then
		commonlib.log("_con is null");
	else
		if(not _con.cn) then
			commonlib.log("_con.cn is null");
		end
	end
	
	--local _reader = self:execReader(_con.cn, "select A.`AssetKey`, A.`AssetFile`, A.`DescFile`, A.`Type`, A.`Category`, A.`Count`, A.`Icon`, A.`PBuyPrice`, A.`EBuyPrice`, A.`PSellPrice`, A.`ESellPrice`, A.`ESellRandomBonus`, A.`RequirePayment`, A.`MaxDailyCount`, A.`MaxWeeklyCount`, A.`HourlyLimitedPurchase`, A.`DailyLimitedPurchase`, B.* from `GlobalStore` as A left join `Template` as B on A.`GSID` = B.`GSID`", MySqlGlobalStoreProvider.getFromRow);
	local _list = self:execReader(_con.cn, "select A.`AssetKey`, A.`AssetFile`, A.`DescFile`, A.`Type`, A.`Category`, A.`Count`, A.`Icon`, A.`PBuyPrice`, A.`EBuyPrice`, A.`PSellPrice`, A.`ESellPrice`, A.`ESellRandomBonus`, A.`RequirePayment`, A.`MaxDailyCount`, A.`MaxWeeklyCount`, A.`HourlyLimitedPurchase`, A.`DailyLimitedPurchase`, B.* from `GlobalStore` as A left join `Template` as B on A.`GSID` = B.`GSID`", MySqlGlobalStoreProvider.getFromRow);
	_con.cn:close();
	_con.env:close();
	return _list;
end