--[[
Title: EarthQuake
Author(s): WangTian
Date: 2009/8/1

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Environment/30021_EarthQuake.lua
------------------------------------------------------------
]]

-- create class
local libName = "EarthQuake";
local EarthQuake = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.EarthQuake", EarthQuake);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- EarthQuake.main
function EarthQuake.main()
end

-- EarthQuake.On_Timer
function EarthQuake.On_Timer()
end

-- EarthQuake.ShakeTownAss
function EarthQuake.ShakeTownAss()
	
	-- skip shake town ass
	do return end
	
	local att = ParaCamera.GetAttributeObject();
	local dist = att:GetField("CameraObjectDistance", 10);
	local angle = att:GetField("CameraLiftupAngle", 0);
	local rot = att:GetField("CameraRotY", 0);
	
	-- refactored by LXZ 2010.1.6: using offset = amp * sin(wt)
	local total_time = 3; -- length of the animation in seconds
	local total_time_ms = total_time*1000;
	
	UIAnimManager.PlayCustomAnimation(total_time_ms, function(elapsedTime)
		if(elapsedTime == total_time_ms) then
			local att = ParaCamera.GetAttributeObject();
			att:SetField("CameraObjectDistance", dist);
			att:GetField("CameraLiftupAngle", angle);
			att:GetField("CameraRotY", rot);
		else
			elapsedTime = elapsedTime / 1000
			local amp = 0.8*(-(elapsedTime - total_time*0.5)*(elapsedTime - total_time*0.5) + 0.25*elapsedTime*elapsedTime);
			local frequency = 70;
			local offset = amp * math.sin(frequency*elapsedTime);
			
			local att = ParaCamera.GetAttributeObject();
			att:SetField("CameraObjectDistance", dist + offset);
			att:SetField("CameraLiftupAngle", angle);
			att:SetField("CameraRotY", rot);
		end
	end);
end