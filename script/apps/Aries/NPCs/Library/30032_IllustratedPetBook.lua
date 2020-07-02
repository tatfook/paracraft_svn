--[[
Title: 
Author(s): Leio
Date: 2009/12/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Library/IllustratedPetBook.lua");
-------------------------------------------------------
]]
local IllustratedPetBook = {

};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.IllustratedPetBook", IllustratedPetBook);
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function IllustratedPetBook.main()
	IllustratedPetBook.DeleteObj()
end
function IllustratedPetBook.PreDialog()
	
end
function IllustratedPetBook.GetBook()
	local bHas, guid = hasGSItem(19003);
	if(not bHas)then
		ItemManager.PurchaseItem(19003,1,function(msg) end,function(msg)
			log("+++++++Purchase item 19003_IllustratedPetBook return: +++++++\n")
			commonlib.echo(msg);
			IllustratedPetBook.DeleteObj()
		end)
	end
end
function IllustratedPetBook.DeleteObj()
	local bHas, guid = hasGSItem(19003);
	commonlib.echo("==================IllustratedPetBook.main");
	commonlib.echo(bHas);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			--Ïú»Ùnpc
			NPC.DeleteNPCCharacter(30032);
		end
	end
end