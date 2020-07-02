--[[
Title: KingKongSnail
Author(s): Leio
Date: 2009/12/20
Desc: an NPC to fix KingKong Snail
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/DrDoctor/30107_KingKongSnail.lua
------------------------------------------------------------
]]
-- create class
local KingKongSnail = commonlib.gettable("MyCompany.Aries.Quest.NPCs.KingKongSnail");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

--如果用户已经拥有蜗牛，销毁场景中的
function KingKongSnail.main()
	commonlib.echo("=============KingKongSnail.main");
	local bHas, guid = hasGSItem(10112);
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			NPC.DeleteNPCCharacter(30108);
		end
	end
end




