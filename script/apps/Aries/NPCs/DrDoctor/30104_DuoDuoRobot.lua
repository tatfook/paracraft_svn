--[[
Title: DuoDuoRobot
Author(s): Leio
Date: 2009/12/1

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30104_DuoDuoRobot.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");

-- create class
local libName = "DuoDuoRobot";
local DuoDuoRobot = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DuoDuoRobot", DuoDuoRobot);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- DuoDuoRobot.main
function DuoDuoRobot.main()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30104);

	if(memory)then
		
	end
end

function DuoDuoRobot.PreDialog()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30104);

end
--是否过期
function DuoDuoRobot.IsOutDay()
	local serverDate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day = string.match(serverDate, "^(%d+)%-(%d+)%-(%d+)$");
	commonlib.echo("============DuoDuoRobot.IsOutDay()");
	commonlib.echo({year = year, month = month, day = day});
	if(year and month and day) then
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);
		--2009-12-1  2009-12-17 有效
		if(year == 2009 and month == 12)then
			if(day >= 1 and day <= 17)then
				return false;
			end
		end
	end
	return true;
end
--是否有七色花
function DuoDuoRobot.HasFlower()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local gsid = 17005;
	local bHas, guid = hasGSItem(gsid, 12);
	local count = 0;
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			count = item.copies;
		end
	end
	if( count > 0)then
		return true;
	end
end
function DuoDuoRobot.GiveFlower(from, to)
	local ItemManager = System.Item.ItemManager;
	if(from == 4 and to == -1 and not DuoDuoRobot.IsOutDay() and DuoDuoRobot.HasFlower())then
		ItemManager.ExtendedCost(123, nil, nil, function() 
			log("+++++++ RainbowFlower_to_CrystalRock return: +++++++\n")
			commonlib.echo(msg);
		end, 12);
	end
end