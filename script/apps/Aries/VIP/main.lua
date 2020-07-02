--[[
Title: VIP Entry for Aries App
Author(s): WangTian
Date: 2010/10/18
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/VIP/main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
-- create class
local VIP = commonlib.gettable("MyCompany.Aries.VIP");

local ItemManager = commonlib.gettable("System.Item.ItemManager");
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");

-- VIP.init()
function VIP.Init()
end

-- VIP.IsVIP()
function VIP.IsVIP()
	--if(ProfileManager.GetNID() == 46650264) then
		--return true;
	--end
	local bean = MyCompany.Aries.Pet.GetBean();
	if(CommonClientService.IsTeenVersion())then
		if(bean)then
			local mlel = bean.mlel or 0;
			local energy = bean.energy or 0;
			if(mlel > 0)then
				return true;
			else
				if(energy > 0)then
					return true;
				end
			end
		end
		return
	end
	if(bean) then
		if(bean.energy and bean.energy > 0) then
			bVIP = true;
		else
			bVIP = false;
		end
		return bVIP;
	else
		return false;
	end
end

-- @param nid: other player nid
function VIP.IsUserVIPInMemory(nid)
	local bean = MyCompany.Aries.Pet.GetBean(nid);
	if(bean) then
		if(bean.energy and bean.energy > 0) then
			bVIP = true;
		else
			bVIP = false;
		end
		return bVIP;
	else
		return false;
	end
end

local bActivated = nil;
-- is vip is activated
function VIP.IsActivated()
	--if(bActivated == nil) then
		--if(ParaIO.DoesFileExist("config/VIP.txt", false)) then
			--bActivated = true;
		--else
			--bActivated = false;
		--end
	--end
	--return bActivated;
	return true;
end

-- is vip and activated
function VIP.IsVIPAndActivated()
	return (VIP.IsVIP() and VIP.IsActivated());
end

-- if we can teleport freely
function VIP.CanTeleportFree()
	return true;
	--if(System.options.version == "teen") then
		--return (VIP.GetMagicStarLevel()>=2);
	--else
		--return true;
	--end
end

-- get magic star level
function VIP.GetMagicStarLevel()
	local mlel = 0;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		mlel = bean.mlel;
	end
	return mlel;
end

function VIP.GetHomeLandItemMaxCount()
	return 600+VIP.GetMagicStarLevel()*20;
end

-- get magic star level
-- @param nid: other player nid
function VIP.GetUserMagicStarLevelInMemory(nid)
	local mlel = 0;
	local bean = MyCompany.Aries.Pet.GetBean(nid);
	if(bean) then
		mlel = bean.mlel;
	end
	return mlel;
end

-- is magic star equipped
function VIP.IsMagicStarEquipped()
	-- 10000_MagicStar
	local item = ItemManager.GetItemByBagAndPosition(0, 30); -- position 30 is magic star
	if(item and item.guid > 0 and item.gsid == 10000) then
		return true;
	end
	return false;
end

-- equip magic star
function VIP.EquipMagicStar()
	local hasGSItem = ItemManager.IfOwnGSItem;
	-- 10000_MagicStar
	local bHas, guid = hasGSItem(10000);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0 and item.gsid == 10000) then
			item:OnClick("left", true); -- true for bSkipMessageBox
		end
	end
end

-- unequip magic star
function VIP.UnequipMagicStar()
	local item = ItemManager.GetItemByBagAndPosition(0, 30); -- position 30 is magic star
	if(item and item.guid > 0 and item.gsid == 10000) then
		item:OnClick("left", true); -- true for bSkipMessageBox
	end
end

local mask_unavailable_gsids = {
	[1293] = true, -- 1293_VIPStaff4
	[1294] = true, -- 1294_VIPStaff5
	[1295] = true, -- 1295_VIPStaff6
	[1298] = true, -- 1298_VIPStaff9
	[1299] = true, -- 1299_VIPStaff10
	[1300] = true, -- 1300_VIPStaff11
};
-- get available combat left hand item gsids
local gsids_vip_lefthand = nil;
function VIP.GetAvailableVIPLeftHandItemGSIDs()
	if(not gsids_vip_lefthand) then
		gsids_vip_lefthand = {};
		local gsid;
		for gsid = 1001, 8999 do
			if(not mask_unavailable_gsids[gsid]) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					if(gsItem.category == "CombatVIPLeftHand") then
						table.insert(gsids_vip_lefthand, gsid);
					end
				end
			end
		end
	end
	return gsids_vip_lefthand;
end