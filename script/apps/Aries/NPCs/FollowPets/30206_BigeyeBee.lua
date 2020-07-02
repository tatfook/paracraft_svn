--[[
Title: BigeyeBee
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30206_BigeyeBee.lua
------------------------------------------------------------
]]

-- create class
local libName = "BigeyeBee";
local BigeyeBee = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BigeyeBee", BigeyeBee);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- BigeyeBee.main
function BigeyeBee.main()
	BigeyeBee.CreateTime = ParaGlobal.GetGameTime();
end

-- BigeyeBee.On_Timer
function BigeyeBee.On_Timer()
	if(BigeyeBee.CreateTime) then
		if((ParaGlobal.GetGameTime() - BigeyeBee.CreateTime) > 120000) then
			BigeyeBee.CreateTime = nil;
            local bee = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30206);
            if(bee and bee:IsValid() == true) then
				System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
                local beeChar = bee:ToCharacter();
                beeChar:Stop();
                BigeyeBee.deleted_inanimation = nil;
                -- remove the bee from scene
                BigeyeBee.DeleteBeeFromScene();
            end
		end
	end
end

-- delete bee from scene
function BigeyeBee.DeleteBeeFromScene()
    local bee = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30206);
    if(bee and bee:IsValid() == true) then
        -- remove the bee from scene
        local params = {
            asset_file = "character/v5/09effect/Disappear/Disappear.x",
            binding_obj_name = bee.name,
            start_position = nil,
            duration_time = 1500,
            force_name = "BigEyeBeeDisappearEffect",
            begin_callback = function() end,
            end_callback = nil,
            stage1_time = 800,
            stage1_callback = function()
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.StopBinding("BigEyeBeeDisappearEffect");
	                MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30206);
                end,
            stage2_time = nil,
            stage2_callback = nil,
        };
        local EffectManager = MyCompany.Aries.EffectManager;
        EffectManager.CreateEffect(params);
    end
end