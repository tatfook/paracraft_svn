--[[
Title: KingKongSnail Fixer
Author(s): LiXizhi
Date: 2009/12/20
Desc: an NPC to fix KingKong Snail
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/DrDoctor/30107_KingKongSnail_Fixer.lua
------------------------------------------------------------
]]
-- create class
local KingKongSnail_Fixer = commonlib.gettable("MyCompany.Aries.Quest.NPCs.KingKongSnail_Fixer");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

--KingKongSnail_Fixer.main
function KingKongSnail_Fixer.main()
	
end
function KingKongSnail_Fixer.CanShow()
	 return not hasGSItem(10112);
end
function KingKongSnail_Fixer.PreDialog()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30107);
end

function KingKongSnail_Fixer.GiveKingKongSnail()
	local ItemManager = System.Item.ItemManager;
	ItemManager.ExtendedCost(168, nil, nil, function(msg) 
			log("+++++++ Get_10112_FollowPet_IronSnail return: +++++++\n")
			commonlib.echo(msg);
			NPC.DeleteNPCCharacter(30108);
		end);
end


