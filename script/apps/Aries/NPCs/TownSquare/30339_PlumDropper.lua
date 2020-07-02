--[[
Title: 30339_PlumDropper
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30339_PlumDropper.lua
------------------------------------------------------------
]]

-- create class
local libName = "PlumDropper";
local PlumDropper = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.PlumDropper", PlumDropper);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local plum_positions = {
	{19814.921875, 24.491579055786, 20187.5546875},
	{19820.271484375, 24.518144607544, 20188.353515625},
	{19835.77734375, 24.891942977905, 20186.748046875},
	{19846.955078125, 24.894592285156, 20187.396484375},
	{19858.94140625, 24.893606185913, 20190.494140625},
	{19857.64453125, 24.790935516357, 20175.48046875},
	{19867.75, 25.019578933716, 20198.12890625},
	{19876.0234375, 24.893594741821, 20179.4609375},
	{19880.517578125, 24.880222320557, 20179.419921875},
	{19901.990234375, 23.791410446167, 20190.923828125},
	{19915.376953125, 24.786800384521, 20200.47265625},
	{19909.552734375, 24.889768600464, 20211.2109375},
	{19919.416015625, 24.650672912598, 20220.041015625},
	{19907.341796875, 24.939348220825, 20233.927734375},
	{19897.10546875, 25.063083648682, 20230.330078125},
	{19884.49609375, 25.824840545654, 20224.990234375},
	{19890.67578125, 24.623937606812, 20213.3125},
	{19894.59375, 24.835708618164, 20214.134765625},
};

local nextupdate_time = 0;

-- PlumDropper.main
function PlumDropper.main()
	nextupdate_time = 0;
end

local update_interval = 600000;

-- generate one plum seed every
-- PlumDropper.On_Timer
function PlumDropper.On_Timer()
	local curTime = ParaGlobal.GetGameTime();
	if(curTime > nextupdate_time) then
		nextupdate_time = curTime + update_interval;
		local i = 1;
		for i = 1, #plum_positions do
			if(not PlumDropper.IsSeedCreated(i)) then
				if(math.random(0, 100) > 95) then
					PlumDropper.GenerateRandomPlumSeed(i);
				end
			end
		end
	end
end

-- PlumDropper.IsSeedCreated
function PlumDropper.IsSeedCreated(index)
	local gameobjectChar = Quest.GameObject.GetGameObjectCharacterFromIDAndInstance(40166, index);
	if(gameobjectChar and gameobjectChar:IsValid() == true) then
		return true;
	end
	return false;
end

-- generate seed
function PlumDropper.GenerateRandomPlumSeed(index)
	if(not index or index > #plum_positions) then
		return;
	end
	local params = { 
		name = "西梅种子",
		position = plum_positions[index],
		facing = 4,
		scaling = 1,
		scaling_model = 1,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = "model/05plants/v5/08homelandPlant/Plum/PlumStage0.x",
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		gsid = 30096, -- 30096_OutdoorPlantPlum
		instance = index,
	};
	GameObject.CreateGameObjectCharacter(40166, params);
end