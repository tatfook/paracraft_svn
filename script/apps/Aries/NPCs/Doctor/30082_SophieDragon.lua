--[[
Title: SophieDragon
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Doctor/30082_SophieDragon.lua
------------------------------------------------------------
]]

-- create class
local libName = "SophieDragon";
local SophieDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SophieDragon", SophieDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- SophieDragon.main
function SophieDragon.main()
end

-- 50188_WishElkFeed_Acquire
-- 50189_WishElkFeed_Complete
-- 50190_WishElkFeed_RewardFriendliness
-- 50191_WishElkFeed_TalkedToSophieDragon

-- SophieDragon.PreDialog
function SophieDragon.PreDialog()
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30082);
	--
	--if(not hasGSItem(50188) and not hasGSItem(50189)) then
		--memory.dialog_state = 3;
	--elseif(hasGSItem(50188) and not hasGSItem(50189)) then
		--if(hasGSItem(50191)) then
			---- 16001_SeaweedFlavorCone
			--if(hasGSItem(16001)) then
				--memory.dialog_state = 6;
			--else
				--memory.dialog_state = 5;
			--end
		--else
			--memory.dialog_state = 4;
		--end
	--elseif(hasGSItem(50188) and hasGSItem(50189)) then
		--memory.dialog_state = 3;
	--end
	
	return true;
end