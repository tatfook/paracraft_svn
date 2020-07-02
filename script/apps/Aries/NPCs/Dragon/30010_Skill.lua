--[[
Title: DragonSkill
Author(s): WangTian
Date: 2010/1/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_Skill.lua
------------------------------------------------------------
]]

-- create class
local libName = "DragonSkill";
local DragonSkill = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DragonSkill", DragonSkill);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local NPCs = MyCompany.Aries.Quest.NPCs;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- DragonSkill.main
function DragonSkill.main()
	if(DragonSkill.isInit) then
		return;
	end
	DragonSkill.isInit = true;
	
	local Pet = MyCompany.Aries.Pet;
	if(Pet.IsMyDragonFetchedFromSophie()) then
		DragonSkill.RefreshStatus();
	end
end

-- DragonSkill.On_Timer
function DragonSkill.On_Timer()
end

-- update the NPC quest status in quest area
function DragonSkill.RefreshStatus()
	if(System.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled()) then
		return;
	end
	
	local Pet = MyCompany.Aries.Pet;
	if(not Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
end