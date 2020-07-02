--[[
Title: SunshineStation
Author(s): WangTian
Date: 2009/7/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SunnyBeach/30141_SunshineStation.lua
------------------------------------------------------------
]]

-- create class
local libName = "SunshineStation";
local SunshineStation = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SunshineStation", SunshineStation);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- SunshineStation.main()
function SunshineStation.main()
end

-- SunshineStation.RefreshStatus()
function SunshineStation.RefreshStatus()
end

-- SunshineStation.PreDialog()
function SunshineStation.PreDialog()
	return true;
end


-- @return: if the user is over heated
function SunshineStation.IsOverHeat()
	-- 50184_SunshineStationTanTag
	local bHas, guid = hasGSItem(50184);
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local Scene = MyCompany.Aries.Scene;
			
			local date, elapsedSeconds = string.match(item.clientdata, "^([%-%d]+)%s(%d+)$")
			if(date and elapsedSeconds) then
				if(date ~= Scene.GetServerDate()) then
					-- not the same date
					return false;
				else
					elapsedSeconds = tonumber(elapsedSeconds);
					if((Scene.GetElapsedSecondsSince0000() - elapsedSeconds) > 10 * 60) then
						-- exceeding 1 hour since last tanned
						return false;
					else
						return true;
					end
				end
			end
		end
	end
	return false;
end

function SunshineStation.SyncOverHeatTime()
	local Scene = MyCompany.Aries.Scene;
	local currentTime = Scene.GetServerDate().." "..Scene.GetElapsedSecondsSince0000();
	
	-- 50184_SunshineStationTanTag
	local bHas, guid = hasGSItem(50184);
	if(bHas == false) then
		ItemManager.PurchaseItem(50184, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50184_SunshineStationTanTag return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
				end
			end
		end, currentTime);
	else
        ItemManager.SetClientData(guid, currentTime, function(msg_setclientdata)
			log("+++++++SetClientData 50184_SunshineStationTanTag return: +++++++\n")
            commonlib.echo(msg_setclientdata);
        end);
	end
end