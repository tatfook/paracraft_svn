--[[
Title: HillJumperTeleport
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30271_HillJumperTeleport.lua
------------------------------------------------------------
]]

-- create class
local libName = "HillJumperTeleport";
local HillJumperTeleport = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HillJumperTeleport", HillJumperTeleport);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- HillJumperTeleport.main
function HillJumperTeleport.main()
end

function HillJumperTeleport.PreDialog(npc_id, instance)
	local position = {};
	local facing = nil;
	local camera_setting = {};
	if(instance == 1) then
		position = { 19867.74609375, 71.996391296387, 20461.443359375 };
		facing = -1.889675617218;
		camera_setting = { 12.14999961853, 0.56954967975616, -1.8897560834885 };
	elseif(instance == 2) then
		position = { 19768.958984375, 74.900451660156, 20479.2890625 };
		facing = -2.6311757564545;
		camera_setting = { 15, 0.76492780447006, -2.7910583019257 };
	end
    -- directly teleport to hill top
	local params = {
		asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
		binding_obj_name = ParaScene.GetPlayer().name,
		start_position = nil,
		duration_time = 800,
		force_name = nil,
		begin_callback = function() 
				local player = ParaScene.GetPlayer();
				if(player and player:IsValid() == true) then
					player:ToCharacter():Stop();
				end
			end,
		end_callback = nil,
		stage1_time = 600,
		stage1_callback = function()
				local player = ParaScene.GetPlayer();
				if(player and player:IsValid() == true) then
					player:SetPosition(position[1], position[2], position[3]);
					player:SetFacing(facing);
					local CameraObjectDistance, CameraLiftupAngle, CameraRotY = camera_setting[1], camera_setting[2], camera_setting[3];
					local att = ParaCamera.GetAttributeObject();
					att:SetField("CameraObjectDistance", CameraObjectDistance);
					att:SetField("CameraLiftupAngle", CameraLiftupAngle);
					att:SetField("CameraRotY", CameraRotY);
				end
			end,
		stage2_time = nil,
		stage2_callback = nil,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
	return false;
end