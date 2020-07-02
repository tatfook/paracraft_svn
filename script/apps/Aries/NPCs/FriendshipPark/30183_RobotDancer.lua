--[[
Title: RobotDancer
Author(s): WangTian, LiXizhi
Date: 2009/12/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/FriendshipPark/30183_RobotDancer.lua");
-- tell the robot dancer that we have performed dancing on the stage at least once since login. 
MyCompany.Aries.Quest.NPCs.RobotDancer.SetPerformedDancing();
------------------------------------------------------------
]]

-- create class
local libName = "RobotDancer";
local RobotDancer = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RobotDancer", RobotDancer);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local slow_count = 100;

function RobotDancer.main()
	slow_count = 100;
end

function RobotDancer.On_Timer()
	slow_count = slow_count + 1;
	if(slow_count >= 100) then
		local dancer = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30183);
		if(dancer and dancer:IsValid() == true) then
			System.Animation.PlayAnimationFile("character/Animation/v5/Elf_animation/ElfFemale_dance2_loop.x", dancer);
		end
	end
end

function RobotDancer.PreDialog()
	return true;
end

local bPerformedDancing;
-- tell the robot dancer that we have performed dancing on the stage at least once since login. 
function RobotDancer.SetPerformedDancing()
	bPerformedDancing = true;
end

function RobotDancer.HasPerformedDancing()
	-- 50232_DancedOnRobotDanceArena
	return hasGSItem(50232);
end