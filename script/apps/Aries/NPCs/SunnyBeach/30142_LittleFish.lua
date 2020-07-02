--[[
Title: LittleFish
Author(s): WangTian
Date: 2009/7/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SunnyBeach/30142_LittleFish.lua
------------------------------------------------------------
]]

-- create class
local libName = "LittleFish";
local LittleFish = commonlib.gettable("MyCompany.Aries.Quest.NPCs.LittleFish");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");

LittleFish.respawn_interval = 600000;

-- LittleFish.main()
function LittleFish.main()
	LittleFish.Show(false);
end

-- LittleFish.main()
function LittleFish.On_Timer()
	local memory = NPCAIMemory.GetMemory(30142);
	if(memory.nextvisibletime == nil) then
		memory.nextvisibletime = ParaGlobal.GetGameTime() + math.random(LittleFish.respawn_interval/10, LittleFish.respawn_interval/5);
		LittleFish.Show(false);
	end
	if(ParaGlobal.GetGameTime() > memory.nextvisibletime) then
		LittleFish.Show(true);
	end
end

-- LittleFish.LeaveSeashore()
function LittleFish.Show(bShow)
	local memory = NPCAIMemory.GetMemory(30142);
	local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30142);
	if(npcChar and npcChar:IsValid() == true) then
		if(bShow == true) then
			npcChar:SnapToTerrainSurface(0);
			--npcChar:SetVisible(true);
			memory.nextvisibletime = ParaGlobal.GetGameTime() + LittleFish.respawn_interval;
		else
			local x, y, z = npcChar:GetPosition();
			npcChar:SetPosition(x, -1000, z);
			--npcChar:SetVisible(false);
		end
	end
end

-- LittleFish.LeaveSeashore()
function LittleFish.LeaveSeashore()
	System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	local memory = NPCAIMemory.GetMemory(30142);
	memory.nextvisibletime = ParaGlobal.GetGameTime() + LittleFish.respawn_interval;
	-- show the effect
	local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30142);
	if(npcChar and npcChar:IsValid() == true) then
		local x, y, z = npcChar:GetPosition();
		local params = {
			asset_file = "character/v5/02animals/GoldFish/GoldFish.x",
			binding_obj_name = nil,
			start_position = {x, y, z},
			scale = 1.6,
			duration_time = 5000,
			elapsedtime_callback = function(elapsedtime, obj)
				if(elapsedtime and obj and obj:IsValid() == true) then
					obj:SetFacing(2.14);
					obj:SetPosition(x, y - 1.6 * (elapsedtime / 5000), z - 50 * (elapsedtime / 5000) * (elapsedtime / 5000));
				end
			end,
			begin_callback = function() 
			end,
			end_callback = function()
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
	-- hide the fish to under ground
	LittleFish.Show(false);
end

-- LittleFish.RefreshStatus()
function LittleFish.RefreshStatus()
end

-- LittleFish.PreDialog()
function LittleFish.PreDialog()
	return true;
end

