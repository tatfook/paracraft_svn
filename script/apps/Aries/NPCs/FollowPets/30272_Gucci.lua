--[[
Title: Gucci
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30272_Gucci.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30362_UglyDuckling.lua");
-- create class
local libName = "Gucci";
local Gucci = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Gucci", Gucci);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Gucci.main
function Gucci.main()
	local self = Gucci;
end

function Gucci.PreDialog(npc_id, instance)
	local self = Gucci;
	return true;
end
function Gucci.HasChisel()
	local self = Gucci;
	return hasGSItem(1157);
end
function Gucci.HasAcceptedUglyDucklingQuest()
	local self = Gucci;
	return MyCompany.Aries.Quest.NPCs.UglyDuckling.IsAccepted();
end
function Gucci.GiveChisel()
	local self = Gucci;
	if(self.HasChisel())then return end
	ItemManager.PurchaseItem(1157, 1, function(msg) end, function(msg)
		if(msg and msg.issuccess)then
		end
	end);
end