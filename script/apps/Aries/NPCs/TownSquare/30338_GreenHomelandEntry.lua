--[[
Title: GreenHomelandEntry
Author(s): Leio
Date: 2010/01/04

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30338_GreenHomelandEntry.lua
------------------------------------------------------------
]]

-- create class
local libName = "GreenHomelandEntry";
local GreenHomelandEntry = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GreenHomelandEntry", GreenHomelandEntry);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


function GreenHomelandEntry.main()
end

function GreenHomelandEntry.PreDialog()
end
--是否已经是青青草原背景
function GreenHomelandEntry.HasGreenHome()
	--如果此位置已经装上物品，测不是青青草原
	local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 22);
	if(item and item.guid > 0)then
		return false
	end
	return true;
end
--是否有足够的钱
function GreenHomelandEntry.HasEnoughMoney()
	NPL.load("(gl)script/apps/Aries/Player/main.lua");
	local count = MyCompany.Aries.Player.GetMyJoybeanCount();
	if(count >= 2000)then
		return true;
	end
end
--兑换
function GreenHomelandEntry.TryExchange()
	if(GreenHomelandEntry.HasGreenHome() or not GreenHomelandEntry.HasEnoughMoney())then return end
	
	System.Item.ItemManager.ExtendedCost(192, nil, nil, function(msg)end, function(msg) 
		log("========= extendedcost CostJoybean_MoveBackToDefaultHomelandTemplate =========\n")
		commonlib.echo(msg);
	end);
	
	---- DEPRECATED, user extendedcost instead
	--ItemManager.PurchaseItem(50005, 20, function(msg) end, function(msg) 
		--log("+++++++Purchase item #50005_Joybean_Cost100 return: +++++++\n")
		--commonlib.echo(msg);
		--if(msg.issuccess) then
			--ItemManager.UnEquipItem(22, function(msg) 
				----如果有冰雪小屋 销毁它
				--GreenHomelandEntry.DestroyIceHome()
			--end);
		--end
	--end);
end

---- DEPRECATED, user extendedcost instead
--function GreenHomelandEntry.DestroyIceHome()
	--local gsid = 39101;
	--local bHas, guid = hasGSItem(gsid);
	--commonlib.echo("=========before destroy icehome");
	--commonlib.echo({bHas = bHas,guid = guid,});
	--if(bHas and guid)then
		--ItemManager.DestroyItem(guid,1,function(msg) end,function(msg)
			--commonlib.echo("=========after destroy icehome");
			--commonlib.echo(msg);
		--end);
	--end
--end