--[[
Title: HaemostaticHerb_SophieDragon
Author(s): Leio
Date: 2010/01/04

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Doctor/30082_HaemostaticHerb_SophieDragon.lua");
------------------------------------------------------------
]]

-- create class
local libName = "HaemostaticHerb_SophieDragon";
local HaemostaticHerb_SophieDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaemostaticHerb_SophieDragon", HaemostaticHerb_SophieDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function HaemostaticHerb_SophieDragon.main()

end

function HaemostaticHerb_SophieDragon.PreDialog()
end
--ÊÇ·ñÓÐÖ¹Ñª²ÝÒ©
function HaemostaticHerb_SophieDragon.HasHerb()
	return hasGSItem(17043)
end
--ÊÇ·ñÂú×ã¶Ò»»Ìõ¼þ
function HaemostaticHerb_SophieDragon.CanExchange()
	--ÆßÉ«»¨
	local bHas_17005, guid_17005, __, copies_17005 = hasGSItem(17005, 12);
	--Õ³Õ³¹û
	local bHas_17030, guid_17030, __, copies_17030 = hasGSItem(17030, 12);
	--ÉúÃüÈªË®
	local bHas_17006, guid_17006, __, copies_17006 = hasGSItem(17006, 12);
	if(bHas_17005 and bHas_17030 and bHas_17006 and copies_17005 > 0 and copies_17030 > 0 and copies_17006 > 0)then
		return true;
	end
	return false;
end
--¶Ò»»
function HaemostaticHerb_SophieDragon.Exchange_Herb()
	if(not HaemostaticHerb_SophieDragon.CanExchange())then return end
	ItemManager.ExtendedCost(191, nil, nil, function(msg)end, function(msg)
		log("+++++++ExtendedCost 191: Get_17043_HaemostaticHerb return: +++++++\n")
		commonlib.echo(msg);
	end, nil, nil, 12);
end