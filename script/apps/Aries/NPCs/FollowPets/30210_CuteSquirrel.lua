--[[
Title: CuteSquirrel
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30210_CuteSquirrel.lua
------------------------------------------------------------
]]

-- create class
local libName = "CuteSquirrel";
local CuteSquirrel = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CuteSquirrel", CuteSquirrel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- CuteSquirrel.main
function CuteSquirrel.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30210);
end

-- CuteSquirrel.On_Timer
function CuteSquirrel.On_Timer()
end

-- 10107_FollowPetXJBB
-- 50048_FleaChick_Feed
-- 17009_BeehiveWorm

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function CuteSquirrel.PreDialog(npc_id, instance)
	return true;
end

function CuteSquirrel.GetSquirrel(instance)
	-- exid 197: Get_10115_FollowPet_Squirrel
    ItemManager.ExtendedCost(197, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 197: Get_10115_FollowPet_Squirrel return: +++++++\n")
	    commonlib.echo(msg);
        local squirrel = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30210, instance);
        if(squirrel and squirrel:IsValid() == true) then
            local squirrelChar = squirrel:ToCharacter();
            squirrelChar:Stop();
            -- remove the chick from scene
            local params = {
                asset_file = "character/v5/09effect/Disappear/Disappear.x",
                binding_obj_name = squirrel.name,
                start_position = nil,
                duration_time = 1500,
                force_name = "CureSquirrelDisappearEffect",
                begin_callback = function() end,
                end_callback = nil,
                stage1_time = 800,
                stage1_callback = function()
						local EffectManager = MyCompany.Aries.EffectManager;
						EffectManager.StopBinding("CureSquirrelDisappearEffect");
                        MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30210, instance);
                    end,
                stage2_time = nil,
                stage2_callback = nil,
            };
            local EffectManager = MyCompany.Aries.EffectManager;
            EffectManager.CreateEffect(params);
        end
    end);
end

function CuteSquirrel.GetReward()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30210);
	if(memory.last_random) then
		if(memory.last_random <= 40) then
			-- exid 198: SquirrelReward_17047_PineNut 
			ItemManager.ExtendedCost(198, nil, nil, function(msg)end, function(msg)
				log("+++++++ExtendedCost 198: SquirrelReward_17047_PineNut return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					memory.last_random = nil;
				end
			end);
		elseif(memory.last_random <= 80) then
			-- exid 199: SquirrelReward_30098_OutdoorPlantMeiHua 
			ItemManager.ExtendedCost(199, nil, nil, function(msg)end, function(msg)
				log("+++++++ExtendedCost 199: SquirrelReward_30098_OutdoorPlantMeiHua return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					memory.last_random = nil;
				end
			end);
		elseif(memory.last_random <= 100) then
			-- exid 200: SquirrelReward_30065_Jackstraw 
			ItemManager.ExtendedCost(200, nil, nil, function(msg)end, function(msg)
				log("+++++++ExtendedCost 200: SquirrelReward_30065_Jackstraw return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					memory.last_random = nil;
				end
			end);
		end
	end
end

function CuteSquirrel.GetRewardName()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30210);
	if(memory.last_random) then
		if(memory.last_random <= 40) then
			return "松子";
		elseif(memory.last_random <= 80) then
			return "梅花种子";
		elseif(memory.last_random <= 100) then
			return "晃晃稻草人";
		end
	end
end