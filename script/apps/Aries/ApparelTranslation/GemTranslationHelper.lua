--[[
Title: GemTranslationHelper
Author(s): Leio 
Date: 2012/06/13
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
GemTranslationHelper.Translation(nid,1097,1152,is_server);
------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
NPL.load("(gl)script/ide/Json.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
--[[equip slots 
	Ĭ�ϵ�����Ӧ����һ����ֵ
	װ��������
	level	�ܿ���	�ѿ�����	�ɴ���� ���Ĵ��ʯ
	0~9		2		1		1		1			
	10~19	2		1		1		1
	20~29	3		2		1		1	
	30~39	4		3		1		1
	40~49	5		4		1		1
	50~59	6		5		1		1
--]]
-- @param gsItem: global store item
-- @param lvl:װ���ȼ�
-- @param holecnt:�Ѿ����׵�����
-- return:max_cnt,usable_slots,unusable_slots,cost
function GemTranslationHelper.OnRangeBetween1(gsItem, lvl, holecnt)
	-- 36 Item_Socket_Count(CS) װ������Ƕ�۵����� ֻ�ܴ�0��Ϊһ����ֵ ���ܸ� 
	-- 67 Item_CanCreateGemHole_Count(CS) װ���ɿ��۵����� ֻ�ܴ�0��Ϊһ����ֵ ���ܸ�  
	-- 68 Cost_CraftSlotCharm_Count(CS) װ����Ƕ��ʯ���Ĵ��ʯ������ ֻ�ܴ�0��Ϊһ����ֵ ���ܸ�  
	if(gsItem) then
		local stat_36 = gsItem.template.stats[36] or 0;
		local stat_67 = gsItem.template.stats[67] or 0;
		local stat_68 = gsItem.template.stats[68] or 0;
		return (stat_36 + stat_67), (stat_36 + holecnt), (stat_67 - holecnt), stat_68;
	else
		return 0,0,0,0;
	end
	--if(lvl >= 0 and lvl <= 9)then 
		--return 1,1,0,0
	--elseif(lvl >= 10 and lvl <= 19)then 
		--return 2,1 + holecnt,2-(1+holecnt),10
	--elseif(lvl >= 20 and lvl <= 29)then 
		--return 3,2 + holecnt,3-(2+holecnt),20
	--elseif(lvl >= 30 and lvl <= 39)then 
		--return 4,3 + holecnt,4-(3+holecnt),30
	--elseif(lvl >= 40 and lvl <= 49)then 
		--return 5,4+holecnt,5-(4+holecnt),40
	--elseif(lvl >= 50 and lvl <= 59)then 
		--return 6,5+holecnt,6-(5+holecnt),50
	--end
end
--[[equip slots 
	Ĭ�ϵ�����Ӧ����һ����ֵ
��Ʒlevel	�ܿ���	�ѿ�����	�ɴ���� ���Ĵ��ʯ
	0~9		2		1		1		1
	10~19	2		1		1		1
	20~29	2		1		1		1
	30~39	2		1		1		1
	40~49	3		2		1		1
	50~59	3		2		1		1
--]]
-- @param gsItem: global store item
-- @param lvl:װ���ȼ�
-- @param holecnt:�Ѿ����׵�����
-- return:max_cnt,usable_slots,unusable_slots,cost
function GemTranslationHelper.OnRangeBetween2(gsItem, lvl, holecnt)
	-- 36 Item_Socket_Count(CS) װ������Ƕ�۵����� ֻ�ܴ�0��Ϊһ����ֵ ���ܸ� 
	-- 67 Item_CanCreateGemHole_Count(CS) װ���ɿ��۵����� ֻ�ܴ�0��Ϊһ����ֵ ���ܸ�  
	-- 68 Cost_CraftSlotCharm_Count(CS) װ����Ƕ��ʯ���Ĵ��ʯ������ ֻ�ܴ�0��Ϊһ����ֵ ���ܸ�  
	if(gsItem) then
		local stat_36 = gsItem.template.stats[36] or 0;
		local stat_67 = gsItem.template.stats[67] or 0;
		local stat_68 = gsItem.template.stats[68] or 0;
		return (stat_36 + stat_67), (stat_36 + holecnt), (stat_67 - holecnt), stat_68;
	else
		return 0,0,0,0;
	end
	--if(lvl >= 0 and lvl <= 9)then 
		--return 1,1,0,0
	--elseif(lvl >= 10 and lvl <= 19)then 
		--return 1,1,0,0
	--elseif(lvl >= 20 and lvl <= 29)then 
		--return 2,1 + holecnt,2-(1+holecnt),10
	--elseif(lvl >= 30 and lvl <= 39)then 
		--return 2,1+holecnt,2-(1+holecnt),20
	--elseif(lvl >= 40 and lvl <= 49)then 
		--return 3,2+holecnt,3-(2+holecnt),30
	--elseif(lvl >= 50 and lvl <= 59)then 
		--return 3,2+holecnt,3-(2+holecnt),40
	--end
end
function GemTranslationHelper.HasIncluded(bag_list,subclass)
	if(bag_list and subclass)then
		local k,v;
		for k,v in ipairs(bag_list) do
			if(v.subclass)then
				local kk,vv;
				for kk,vv in ipairs(v.subclass) do
					if(vv == subclass)then
						return true;
					end
				end
			end
		end
	end
end
--��ȡװ���׵�������
--@param gsid:��Ʒgsid
--@param holecnt:�Ѿ��ֹ����׵�����
--@param is_server:�Ƿ���gameserver�ϵ��ж�
--return:max_cnt,usable_slots,unusable_slots,cost
function GemTranslationHelper.GetTotalHoleCount(gsid,holecnt,is_server)
	local self = GemTranslationHelper;
	if(not gsid)then return end
	holecnt = holecnt or 0;
	local gsItem;
	if(is_server)then
		gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
	else
		gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	end
	if(gsItem)then
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		local equip_level = gsItem.template.stats[138] or gsItem.template.stats[168];
		local quality = gsItem.template.stats[221] or 0;
		if(quality <= 0)then
			return 0,0,0,0;
		end
		if(class == 1)then
			local bag_list = BagHelper.GetBagList("Equipment","1");
			if(self.HasIncluded(bag_list,subclass))then
				local max_cnt,usable_slots,unusable_slots,cost = GemTranslationHelper.OnRangeBetween1(gsItem, equip_level, holecnt);
				return max_cnt,usable_slots,unusable_slots,cost;	
			end
			local bag_list = BagHelper.GetBagList("Equipment","2");
			if(self.HasIncluded(bag_list,subclass))then
				local max_cnt,usable_slots,unusable_slots,cost = GemTranslationHelper.OnRangeBetween1(gsItem, equip_level, holecnt);
				return max_cnt,usable_slots,unusable_slots,cost;	
			end
			local bag_list = BagHelper.GetBagList("Equipment","3");
			if(self.HasIncluded(bag_list,subclass))then
				local max_cnt,usable_slots,unusable_slots,cost = GemTranslationHelper.OnRangeBetween2(gsItem, equip_level, holecnt);
				return max_cnt,usable_slots,unusable_slots,cost;	
			end
		end
	end
end
--��ȡ�û�װ���׵�������
--@param nid:�û�nid
--@param gsid:��Ʒgsid
--@is_server:�Ƿ���gameserver�ϵ��ж�
--return:max_cnt,usable_slots,unusable_slots,cost
function GemTranslationHelper.GetUserTotalHoleCount(nid,gsid,is_server)
	local self = GemTranslationHelper;
	local item = self.GetUserItem(nid,gsid,is_server);
	if(item and item.GetHoleCount)then
		--�Ѿ����׵�����
		local holecnt = item:GetHoleCount();
		return self.GetTotalHoleCount(gsid,holecnt,is_server);
	end
end
function GemTranslationHelper.GetItemsInBag(nid,bag,is_server,callbackFunc,cache_policy)
	local self = GemTranslationHelper;
	if(not bag)then return end
	nid = nid or ProfileManager.GetNID();
	if(is_server)then

	else
		if(nid == ProfileManager.GetNID())then
			ItemManager.GetItemsInBag(bag, "", function(msg)
				if(callbackFunc)then
					callbackFunc();
				end
			end, cache_policy);
		else
			ItemManager.GetItemsInOPCBag(nid, bag, "", function(msg)
				if(callbackFunc)then
					callbackFunc();
				end
			end, cache_policy);
		end
	end
end
--����gsid��ȡ�û���itemʵ��
function GemTranslationHelper.GetUserItem(nid,gsid,is_server)
	local self = GemTranslationHelper;
	nid = nid or ProfileManager.GetNID();
	if(not nid or not gsid)then return end
	if(is_server)then
		local hasItem,guid,bag,copies = PowerItemManager.IfOwnGSItem(nid,gsid);
		if(hasItem)then
			local item = PowerItemManager.GetItemByGUID(nid, guid);
			return item;
		end
	else
		local item;
		if(nid == ProfileManager.GetNID())then
			local hasItem,guid,bag,copies = ItemManager.IfOwnGSItem(gsid);
			if(hasItem)then
				item = ItemManager.GetItemByGUID(guid);
			end
		else
			local hasItem,guid,bag,copies = ItemManager.IfOPCOwnGSItem(nid,gsid);
			if(hasItem)then
				item = ItemManager.GetOPCItemByGUID(nid, guid);
			end
		end
		return item;
	end
end
function GemTranslationHelper.GetGlobalStoreItem(gsid,is_server)
	local self = GemTranslationHelper;
	if(not gsid)then return end
	local gsItem;
	if(is_server)then
		gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
	else
		gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	end
	return gsItem;
end
--���������Ƿ����ƽ��
function GemTranslationHelper.CanTranslation_Addon(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	if(not from_gsid or not to_gsid)then return end
	if(from_gsid == to_gsid)then
		return
	end
	addonlevel.init();
	--�Ƿ����ǿ������
	if(not addonlevel.can_have_addon_property(from_gsid) or not addonlevel.can_have_addon_property(to_gsid))then
		return
	end
	local gsItem_from = self.GetGlobalStoreItem(from_gsid,is_server);
	local gsItem_to = self.GetGlobalStoreItem(to_gsid,is_server);
	if(gsItem_from and gsItem_to)then
		local class_from = gsItem_from.template.class;
		local subclass_from = gsItem_from.template.subclass;
		local equip_level_from = gsItem_from.template.stats[138] or gsItem_from.template.stats[168];
		equip_level_from = equip_level_from or 0;
		local quality_from = gsItem_from.template.stats[221] or 0;

		local class_to = gsItem_to.template.class;
		local subclass_to = gsItem_to.template.subclass;
		local equip_level_to = gsItem_to.template.stats[138] or gsItem_to.template.stats[168];
		equip_level_to = equip_level_to or 0;
		local quality_to = gsItem_to.template.stats[221] or 0;

		--װ��������1�Ű�
		--ͬһ����Ʒ
		--�����ǵͼ���߼�ƽ��
		--ͬ����Ƚ�Ʒ��
		if(quality_from > 0 and quality_to > 0 and class_from == 1 and class_from == class_to and subclass_from == subclass_to and (equip_level_to > equip_level_from or (equip_level_to == equip_level_from and quality_from <= quality_to)))then
			local from_item = self.GetUserItem(nid,from_gsid,is_server);
			local to_item = self.GetUserItem(nid,to_gsid,is_server);
			if(from_item.GetAddonLevel and to_item.GetAddonLevel)then
				local from_addon_level = from_item:GetAddonLevel();
				local to_addon_level = to_item:GetAddonLevel();
				local to_addon = addonlevel.tradein(from_gsid,from_addon_level,to_gsid)
				--�����Ƿ���������
				if(not to_addon)then
					return
				end
				--�ͼ�װ���Ѿ��и�������
				--�߼�װ��û�и�������
				if(from_addon_level > 0 and to_addon_level == 0)then
					return true;
				end
			end
		end
	end
end
--��ʯ�Ƿ����ƽ��
function GemTranslationHelper.CanTranslation_Gem(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	if(not from_gsid or not to_gsid)then return end
	if(from_gsid == to_gsid)then
		return
	end
	local gsItem_from = self.GetGlobalStoreItem(from_gsid,is_server);
	local gsItem_to = self.GetGlobalStoreItem(to_gsid,is_server);
	if(gsItem_from and gsItem_to)then
		local class_from = gsItem_from.template.class;
		local subclass_from = gsItem_from.template.subclass;
		local equip_level_from = gsItem_from.template.stats[138] or gsItem_from.template.stats[168];
		equip_level_from = equip_level_from or 0;
		local quality_from = gsItem_from.template.stats[221] or 0;
		local max_cnt_1,usable_slots_1,unusable_slots_1,__ = self.GetUserTotalHoleCount(nid,from_gsid,is_server)

		local class_to = gsItem_to.template.class;
		local subclass_to = gsItem_to.template.subclass;
		local equip_level_to = gsItem_to.template.stats[138] or gsItem_to.template.stats[168];
		equip_level_to = equip_level_to or 0;
		local quality_to = gsItem_to.template.stats[221] or 0;
		local max_cnt_2,usable_slots_2,unusable_slots_2,__ = self.GetUserTotalHoleCount(nid,to_gsid,is_server)
		--�п�λ����ƽ��
		if(usable_slots_1 and usable_slots_2 and usable_slots_1 > 0 and usable_slots_2 > 0 and usable_slots_2 >= usable_slots_1)then
			--װ��������1�Ű�
			--ͬһ����Ʒ
			--�����ǵͼ���߼�ƽ��
			--ͬ����Ƚ�Ʒ��
			if(quality_from > 0 and quality_to > 0  and class_from == 1 and class_from == class_to and subclass_from == subclass_to and (equip_level_to > equip_level_from or (equip_level_to == equip_level_from and quality_from <= quality_to)))then
				local from_item = self.GetUserItem(nid,from_gsid,is_server);
				local to_item = self.GetUserItem(nid,to_gsid,is_server);
				if(from_item.GetSocketedGems and to_item.GetSocketedGems)then
					local cnt_1 = #(from_item:GetSocketedGems() or {});
					local cnt_2 = #(to_item:GetSocketedGems() or {});
					--�ͼ�װ���Ѿ���Ƕ��ʯ
					--�߼�װ��û����Ƕ��ʯ
					if(cnt_1 > 0 and cnt_2 == 0)then
						return true;
					end
				end
			end
		end
	end
end
--�Ƿ����ƽ�� 
function GemTranslationHelper.CanTranslation(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	local gem_can = self.CanTranslation_Gem(nid,from_gsid,to_gsid,is_server);
	local addon_can = self.CanTranslation_Addon(nid,from_gsid,to_gsid,is_server);
	if(gem_can or addon_can)then
		return true;
	end
end
function GemTranslationHelper.DoGemTranslation(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	if(not nid or not from_gsid or not to_gsid)then return end
	LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslation",{from_gsid = from_gsid,to_gsid = to_gsid,});
	PowerItemManager.SyncUserItems(nid, {0, 1}, function(msg) 
		if(self.CanTranslation(nid,from_gsid,to_gsid,is_server))then
			self.__DoGemTranslation(nid,from_gsid,to_gsid,is_server)
		end
	end, function() end);
end
--װ��ƽ�� 
function GemTranslationHelper.__DoGemTranslation(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	local from_item = self.GetUserItem(nid,from_gsid,is_server);
	local to_item = self.GetUserItem(nid,to_gsid,is_server);
	

	if(from_item and to_item and from_item.GetServerData and to_item.GetServerData)then
		local serverdata_from = from_item:GetServerData();
		local serverdata_to = to_item:GetServerData();
		if(not serverdata_from or serverdata_from == "")then
			serverdata_from = {};
		end
		if(not serverdata_to or serverdata_to == "")then
			serverdata_to = {};
		end
		LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslation before",{serverdata_from = serverdata_from,serverdata_to = serverdata_to,});

		if(serverdata_from and serverdata_to)then
			local gem_from = serverdata_from.gem or {};
			local gem_to = serverdata_to.gem or {};
			local ins = gem_from.ins;
			--ƽ�Ʊ�ʯ��Ҫ��������
			local gem_cost = 0;
			--�����ʯ����ƽ��
			if(self.CanTranslation_Gem(nid,from_gsid,to_gsid,is_server))then
				--����б�ʯ�б�
				if(ins)then
					local clone_ins = commonlib.deepcopy(ins);

					serverdata_to.gem = gem_to;
					gem_to.ins = clone_ins;

					gem_from.ins = nil;
					if(not gem_from.holecnt)then
						serverdata_from.gem = nil;
					end
					if(clone_ins)then
						local k,gsid;
						for k,gsid in ipairs(clone_ins) do
    						local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
							if(gsItem)then
    							local stat = gsItem.template.stats[41] or 0;
								gem_cost = gem_cost + stat * 500;
							end
						end
					end
				end
			end
			--����������Կ���ƽ��
			if(self.CanTranslation_Addon(nid,from_gsid,to_gsid,is_server))then
				--����ƽ��
				local addlel_from = serverdata_from.addlel;
				local to_addon = addonlevel.tradein(from_gsid,addlel_from,to_gsid)
				if(to_addon and to_addon.level)then
					serverdata_to.addlel = tonumber(to_addon.level);
					serverdata_from.addlel = nil;
				end
			end
			local guid_from = from_item.guid;
			local guid_to = to_item.guid;
			local json_from = commonlib.Json.Encode(serverdata_from);
			local json_to = commonlib.Json.Encode(serverdata_to);
			local updates = string.format([[%d~0~%s~NULL|%d~0~%s~NULL]],guid_from,json_from,guid_to,json_to);
			local adds = nil;
			local pres = nil;
			if(gem_cost > 0)then
				adds = string.format([[0~-%d~NULL~NULL|]],gem_cost);
				pres = string.format([[0~%d|]],gem_cost);
			end
			LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslation after",{serverdata_from = serverdata_from,serverdata_to = serverdata_to, updates = updates, adds = adds, pres = pres, gem_cost = gem_cost,});
			PowerItemManager.ChangeItem(nid, adds, updates, function(msg)
				LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslation ChangeItem",msg);
				if(msg and msg.issuccess)then
					local gridnode = gateway:GetPrimGridNode(tostring(nid));
					if(gridnode) then
						local server_object = gridnode:GetServerObject("sPowerAPI");
						if(server_object) then
							local msg = {
								issuccess = true,
								from_gsid = from_gsid,
								to_gsid = to_gsid,
							};
							server_object:SendRealtimeMessage(tostring(nid), "[Aries][PowerAPI]DoGemTranslation:"..commonlib.serialize_compact(msg));
						end
					end
				end
			end,nil,pres);
		end
	end
end
function GemTranslationHelper.SearchItemListFromBag_Client()
	local self = GemTranslationHelper;
	local list = {};
	local function join(bag_list)
		if(bag_list)then
			local k,v;
			for k,v in ipairs(bag_list) do
				table.insert(list,v);
			end
		end
	end
	join(BagHelper.GetZeroBagList());
	join(BagHelper.GetBagList("Equipment","1"));
	join(BagHelper.GetBagList("Equipment","2"));
	join(BagHelper.GetBagList("Equipment","3"));
	return BagHelper.SearchBagList_Memory(nil,list)
end
--��ͯ��װ��ƽ��
function GemTranslationHelper.DoGemTranslationKids(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	if(not nid or not from_gsid or not to_gsid)then return end
	LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslation",{from_gsid = from_gsid,to_gsid = to_gsid,});
	
	PowerItemManager.SyncUserItems(nid, {0,1}, function(msg) 
		self.__DoGemTranslationKids(nid,from_gsid,to_gsid,is_server)
	end, function() end);
end
--��ͯ��װ��ƽ��
function GemTranslationHelper.__DoGemTranslationKids(nid,from_gsid,to_gsid,is_server)
	local self = GemTranslationHelper;
	local from_item = self.GetUserItem(nid,from_gsid,is_server);
	local to_item = self.GetUserItem(nid,to_gsid,is_server);
	

	if(from_item and to_item and from_item.GetServerData and to_item.GetServerData)then
		local serverdata_from = from_item:GetServerData();
		local serverdata_to = to_item:GetServerData();
		if(not serverdata_from or serverdata_from == "")then
			serverdata_from = {};
		end
		if(not serverdata_to or serverdata_to == "")then
			serverdata_to = {};
		end
		LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslationKids before",{serverdata_from = serverdata_from,serverdata_to = serverdata_to,});


		local gsItem_from = self.GetGlobalStoreItem(from_gsid,is_server);
		local gsItem_to = self.GetGlobalStoreItem(to_gsid,is_server);
		if(not gsItem_from or not gsItem_to)then
			return
		end
		local class_from = gsItem_from.template.class;
		local subclass_from = gsItem_from.template.subclass;
		local class_to = gsItem_to.template.class;
		local subclass_to = gsItem_to.template.subclass;
		if(class_from ~= class_to or subclass_from ~= subclass_to)then
			return
		end
		if(serverdata_from and serverdata_to)then
			local guid_from = from_item.guid;
			local guid_to = to_item.guid;
			local json_from = commonlib.Json.Encode(serverdata_from);
			--if(json_from == "[]") then
				--json_from = "NULL";
			--end
			local json_to = commonlib.Json.Encode(serverdata_to);
			--if(json_to == "[]") then
				--json_to = "NULL";
			--end
			--serverdata ����
			local updates = string.format([[%d~0~%s~NULL|%d~0~%s~NULL]],guid_from,json_to,guid_to,json_from);
			LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslationKids after",{serverdata_from = serverdata_from,serverdata_to = serverdata_to, updates = updates,});
			PowerItemManager.ChangeItem(nid, nil, updates, function(msg)
				if(msg and msg.issuccess)then
					local gridnode = gateway:GetPrimGridNode(tostring(nid));
					if(gridnode) then
						local server_object = gridnode:GetServerObject("sPowerAPI");
						if(server_object) then
							local msg_out = {
								issuccess = true,
								from_gsid = from_gsid,
								to_gsid = to_gsid,
								updates = msg.updates,
								adds = msg.adds,
							};
							if(msg.updates) then
								local _, item
								for _, item in ipairs(msg.updates) do
									if(item.guid == from_item.guid) then
										item.serverdata = item.serverdata or json_to;
									elseif(item.guid == to_item.guid) then
										item.serverdata = item.serverdata or json_from;
									end
								end
							end
							PowerItemManager.UpdateItemsWithAddsUpdatesStats(tonumber(nid), nil, msg.updates, nil, true);

							server_object:SendRealtimeMessage(tostring(nid), "[Aries][PowerAPI]DoGemTranslationKids:"..commonlib.serialize_compact(msg_out));
						end
					end
				end
				LOG.std(nil, "debug","GemTranslationHelper.DoGemTranslationKids ChangeItem",msg);
			end)
		end
	end
end