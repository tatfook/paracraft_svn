NPL.load("(gl)script/ide/Json.lua");

local GlobalStoreEntity = commonlib.gettable("DBServer.GlobalStoreEntity");
--[[
GlobalStoreEntity = {
	GSID = 0,
	AssetKey = "",
	AssetFile = "",
	DescFile = "",
	Type = 1,
	Category = "",
	Count = 0,
	Icon = "",
	PBuyPrice = 0,
	EBuyPrice = 0,
	PSellPrice = 0,
	ESellPrice = 0,
	ESellRandomBonus = 0,
	RequirePayment = 0,
	MaxDailyCount = 0,
	MaxWeeklyCount = 0,
	HourlyLimitedPurchase = 0,
	DailyLimitedPurchase = 0,
	-------------------------------------------
	ID = 0,
	Class = 1,
	Subclass = 1,
	Name = "",
	InventoryType = 1,
	MaxCount = 0,
	MaxCopiesInStack = 0,
	StatsCount = 0,
	Stat_type_1 = 0,
	Stat_type_2 = 0,
	Stat_type_3 = 0,
	Stat_type_4 = 0,
	Stat_type_5 = 0,
	Stat_type_6 = 0,
	Stat_type_7 = 0,
	Stat_type_8 = 0,
	Stat_type_9 = 0,
	Stat_type_10 = 0,
	Stat_value_1 = 0,
	Stat_value_2 = 0,
	Stat_value_3 = 0,
	Stat_value_4 = 0,
	Stat_value_5 = 0,
	Stat_value_6 = 0,
	Stat_value_7 = 0,
	Stat_value_8 = 0,
	Stat_value_9 = 0,
	Stat_value_10 = 0,
	Description = "",
	CanUseDirectly = true,
	DestroyAfterUse = true,
	CanSell = true,
	CanExchange = true,
	CanGift = true,
	ExpireType = 0,
	ExpireTime = 0,
	ExpireDate = os.date("*t"),
	DestroyAfterExpire = 0,
	Rechargeable = true,
	Material = 0,
	ItemSetID = 0,
	BagFamily = 1
};
]]

function GlobalStoreEntity:new(GSID, AssetKey, AssetFile, DescFile, Type, Category, Count, Icon, PBuyPrice, EBuyPrice, PSellPrice, ESellPrice, ESellRandomBonus,
			MaxDailyCount, MaxWeeklyCount, HourlyLimitedPurchase, DailyLimitedPurchase, Class, Subclass, Name, InventoryType, MaxCount, MaxCopiesInStack, StatsCount,
			Stat_type_1, Stat_type_2, Stat_type_3, Stat_type_4, Stat_type_5, Stat_type_6, Stat_type_7, Stat_type_8, Stat_type_9, Stat_type_10, Stat_value_1, Stat_value_2,
			Stat_value_3, Stat_value_4, Stat_value_5, Stat_value_6, Stat_value_7, Stat_value_8, Stat_value_9, Stat_value_10, Description, CanUseDirectly, DestroyAfterUse,
			CanSell, CanExchange, CanGift, RequirePayment, ExpireType, ExpireTime, ExpireDate, DestroyAfterExpire, Rechargeable, Material, ItemSetID, BagFamily)
    local _t = {
		GSID = tonumber(GSID),
		AssetKey = AssetKey,
		AssetFile = AssetFile,
		DescFile = DescFile,
		Type = tonumber(Type),
		Category = Category,
		Count = tonumber(Count),
		Icon = Icon,
		PBuyPrice = tonumber(PBuyPrice),
		EBuyPrice = tonumber(EBuyPrice),
		PSellPrice = tonumber(PSellPrice),
		ESellPrice = tonumber(ESellPrice),
		ESellRandomBonus = tonumber(ESellRandomBonus),
		RequirePayment = tonumber(RequirePayment),
		MaxDailyCount = tonumber(MaxDailyCount),
		MaxWeeklyCount = tonumber(MaxWeeklyCount),
		HourlyLimitedPurchase = tonumber(HourlyLimitedPurchase),
		DailyLimitedPurchase = tonumber(DailyLimitedPurchase),
		ID = tonumber(ID),
		Class = tonumber(Class),
		Subclass = tonumber(Subclass),
		Name = Name,
		InventoryType = tonumber(InventoryType),
		MaxCount = tonumber(MaxCount),
		MaxCopiesInStack = tonumber(MaxCopiesInStack),
		StatsCount = tonumber(StatsCount),
		Stat_type_1 = tonumber(Stat_type_1),
		Stat_type_2 = tonumber(Stat_type_2),
		Stat_type_3 = tonumber(Stat_type_3),
		Stat_type_4 = tonumber(Stat_type_4),
		Stat_type_5 = tonumber(Stat_type_5),
		Stat_type_6 = tonumber(Stat_type_6),
		Stat_type_7 = tonumber(Stat_type_7),
		Stat_type_8 = tonumber(Stat_type_8),
		Stat_type_9 = tonumber(Stat_type_9),
		Stat_type_10 = tonumber(Stat_type_10),
		Stat_value_1 = tonumber(Stat_value_1),
		Stat_value_2 = tonumber(Stat_value_2),
		Stat_value_3 = tonumber(Stat_value_3),
		Stat_value_4 = tonumber(Stat_value_4),
		Stat_value_5 = tonumber(Stat_value_5),
		Stat_value_6 = tonumber(Stat_value_6),
		Stat_value_7 = tonumber(Stat_value_7),
		Stat_value_8 = tonumber(Stat_value_8),
		Stat_value_9 = tonumber(Stat_value_9),
		Stat_value_10 = tonumber(Stat_value_10),
		Description = Description,
		CanUseDirectly = CanUseDirectly == "",
		DestroyAfterUse = DestroyAfterUse == "",
		CanSell = CanSell == "",
		CanExchange = CanExchange == "",
		CanGift = CanGift == "",
		ExpireType = tonumber(ExpireType),
		ExpireTime = tonumber(ExpireTime),
		ExpireDate = ExpireDate,
		DestroyAfterExpire = tonumber(DestroyAfterExpire),
		Rechargeable = Rechargeable == "",
		Material = tonumber(Material),
		ItemSetID = tonumber(ItemSetID),
		BagFamily = tonumber(BagFamily)
	};
    setmetatable(_t, self);
    self.__index = self;
    return _t;
end

function GlobalStoreEntity:GetStatValue(pStatType)
	for _i = 1, 10 do
		local _key = "Stat_type_" .. _i;
		if(self[_key] and self[_key] == pStatType) then
			return self["Stat_value_" .. _i];
		end
	end

	if(self.Description and string.len(self.Description) > 0) then
		-- TODO: Try .... Catch ....
		local _index = string.find(self.Description, "]");
		
		local _str = self.Description;
		if(_index) then
			_str = string.sub(_str, _index + 1);
		end
		local _json = commonlib.Json.Decode(_str);
		if(_json) then
			for _, _item in pairs(_json) do
				if(_item.k == pStatType) then
					return _item.v;
				end
			end
		end
	end
	return nil;
end