--[[
Title: TwistDancer
Author(s): WangTian, LiXizhi
Date: 2009/12/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/FriendshipPark/30183_TwistDancer.lua");
-- tell the robot dancer that we have performed dancing on the stage at least once since login. 
MyCompany.Aries.Quest.NPCs.TwistDancer.SetPerformedDancing();
------------------------------------------------------------
]]

-- create class
local libName = "TwistDancer";
local TwistDancer = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.TwistDancer", TwistDancer);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local slow_count = 100;
function TwistDancer.main()
	slow_count = 100;
end

function TwistDancer.On_Timer()
	slow_count = slow_count + 1;
	if(slow_count >= 100) then
		local dancer = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30184);
		if(dancer and dancer:IsValid() == true) then
			System.Animation.PlayAnimationFile("character/Animation/v5/Elf_animation/ElfFemale_dance4_loop.x", dancer);
		end
	end
end

function TwistDancer.PreDialog()
	return true;
end

local bPerformedDancing;
-- tell the robot dancer that we have performed dancing on the stage at least once since login. 
function TwistDancer.SetPerformedDancing()
	bPerformedDancing = true;
end

function TwistDancer.HasPerformedDancing()
	-- 50233_DancedOnTwistDanceArena
	return hasGSItem(50233);
end