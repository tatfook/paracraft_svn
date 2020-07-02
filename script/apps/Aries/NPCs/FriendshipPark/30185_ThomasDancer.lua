--[[
Title: ThomasDancer
Author(s): WangTian, LiXizhi
Date: 2009/12/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/FriendshipPark/30183_ThomasDancer.lua");
-- tell the robot dancer that we have performed dancing on the stage at least once since login. 
MyCompany.Aries.Quest.NPCs.ThomasDancer.SetPerformedDancing();
------------------------------------------------------------
]]

-- create class
local libName = "ThomasDancer";
local ThomasDancer = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ThomasDancer", ThomasDancer);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local slow_count = 100;
function ThomasDancer.main()
	slow_count = 100;
end

function ThomasDancer.On_Timer()
	slow_count = slow_count + 1;
	if(slow_count >= 100) then
		local dancer = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30185);
		if(dancer and dancer:IsValid() == true) then
			System.Animation.PlayAnimationFile("character/Animation/v5/Elf_animation/ElfFemale_dance6_loop.x", dancer);
		end
	end
end

function ThomasDancer.PreDialog()
	return true;
end

local bPerformedDancing;
-- tell the robot dancer that we have performed dancing on the stage at least once since login. 
function ThomasDancer.SetPerformedDancing()
	bPerformedDancing = true;
end

function ThomasDancer.HasPerformedDancing()
	-- 50234_DancedOnThomasDanceArena
	return hasGSItem(50234);
end