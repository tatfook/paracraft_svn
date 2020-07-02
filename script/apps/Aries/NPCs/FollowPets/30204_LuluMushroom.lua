--[[
Title: LuluMushroom
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30204_LuluMushroom.lua
------------------------------------------------------------
]]

-- create class
local libName = "LuluMushroom";
local LuluMushroom = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.LuluMushroom", LuluMushroom);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- lulu mushroom scale stages
local scale_stages = {2, 2.5, 3, 3.5, 4, 4.5};

-- LuluMushroom.main
function LuluMushroom.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					commonlib.echo(msg);
					memory.hit_gsid = msg.throwItem.gsid;
					--memory.hitpoint_x = msg.endPoint.x;
					--memory.hitpoint_y = msg.endPoint.y;
					--memory.hitpoint_z = msg.endPoint.z;
					memory.hitObjNameList = msg.hitObjNameList;
				end
			end
		end, 
	hookName = "OnThrowableHit_30204_LuluMushroom", appName = "Aries", wndName = "throw"});
	
	local instance;
	for instance = 1, 5 do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
		local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
		if(mushroom and mushroom:IsValid() == true) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
			if(memory.isFull == true) then
				mushroom:SetScale(4.5);
			end
		end
	end
end

-- LuluMushroom.On_Timer
function LuluMushroom.On_Timer()
	-- AI script will reset nextGossipInstance to nil if visualized
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
	local time = ParaGlobal.GetGameTime();
	memory.lastHeadonTextTime = memory.lastHeadonTextTime or 0;
	if((time - memory.lastHeadonTextTime) > 5000) then
		-- select one of the horse to say the headon text
		memory.lastHeadonTextTime = time;
		local r = math.random(1, 8); -- in case of 0
		local choice = math.ceil(r);
		local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, choice);
		local player = ParaScene.GetPlayer();
		if(mushroom and mushroom:IsValid() == true) then
			--local r = math.random(1, 4);
			--local choice = math.ceil(r) or 1;
			--local gossips = {"我是一只蘑菇噜噜噜，水弹吃的太多就会跳不动~",
							--"噜噜噜噜，水弹会让我变大，太大就跑不动了！",
							--"一跳一跳小蘑菇，满地都是蘑菇噜！",
							--"我最怕水弹了，这秘密谁都不能说的，噜噜噜~",};
			--local dist = mushroom:DistanceTo(player);
			--if(dist < 30) then
				--headon_speech.Speek(mushroom.name, headon_speech.GetBoldTextMCML(gossips[choice]), 3, true);
			--end
		end
	end
end

-- LuluMushroom.On_Shrink
-- @param instance: npc instance of the LuluMushroom
function LuluMushroom.On_Shrink(instance)
	if(not instance) then
		return;
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
	local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
	if(mushroom and mushroom:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		memory.stage = 1;
		local scale_from = mushroom:GetScale();
		local scale_to = scale_stages[1];
		memory.shrinkCountDown = nil;
		memory.shrinkStartTime = nil;
		memory.isShrinking = true;
		memory.isFull = nil;
		-- repick random
		memory.random = nil;
		-- linar shirinking scale
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
			if(mushroom and mushroom:IsValid() == true) then
				if(elapsedTime == 500) then
					mushroom:SetScale(scale_to);
					-- finish shrinking animation
					memory.isShrinking = nil;
				end
				local this_scale = (scale_to - scale_from) * elapsedTime / 500 + scale_from;
				mushroom:SetScale(this_scale);
			end
		end);
	end
end

-- LuluMushroom.On_Hit
-- @param instance: npc instance of the LuluMushroom
function LuluMushroom.On_Hit(instance)
	if(not instance) then
		return;
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
	local stepvalue = 1;
	local hit_gsid = memory.hit_gsid;
	--echo("11111111");
	--echo(hit_gsid);
	local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
	if(mushroom and mushroom:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		memory.stage = memory.stage or 1;
		
		if(hit_gsid == 9506) then
			stepvalue = #scale_stages - memory.stage;
		end

		if(memory.isShrinking == true) then
			-- skip the hit response while shrinking
			return;
		end
		
		if(scale_stages[memory.stage + stepvalue]) then
			-- scale to the next stage
			memory.shrinkStartTime = ParaGlobal.GetGameTime();
			memory.shrinkCountDown = 20000;
			local scale_from = scale_stages[memory.stage];
			local scale_to = scale_stages[memory.stage + stepvalue];
			local deltaScale = scale_to - scale_from;
			local times = {1, 50, 100, 150, 200, 250, 300, 350};
			local data = {0, 9,  16,  21,  24,  25,  24,  21};
			local name = mushroom.name;
			UIAnimManager.PlayCustomAnimation(350, function(elapsedTime)
				local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
				if(mushroom and mushroom:IsValid() == true) then
					if(elapsedTime == 350) then
						mushroom:SetScale(scale_to);
					end
					local first, second;
					local i, time;
					for i, time in pairs(times) do
						if(times[i + 1] and elapsedTime >= times[i] and elapsedTime < times[i + 1]) then
							first = i;
							second = i + 1;
							break;
						end
					end
					if(first and second) then
						local delta = ((elapsedTime - times[first])/(times[second] - times[first]) * (data[second] - data[first]) + data[first]) * deltaScale / 25;
						mushroom:SetScale(delta + scale_from);
					end
				end
			end);
			memory.stage = memory.stage + stepvalue;
			headon_speech.Speek(name, headon_speech.GetBoldTextMCML("我还没有变到最大，快拿上水弹来追我呀？"), 3, true);
			
			if(scale_stages[memory.stage + 1] == nil) then
				-- reach the final stage
				LuluMushroom.On_ReachFinalStage(instance);
			end
		else
			log("error: lulumushroom is full\n");
		end
	end
end

function LuluMushroom.On_ReachFinalStage(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
	local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
	if(mushroom and mushroom:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		memory.shrinkStartTime = ParaGlobal.GetGameTime();
		memory.shrinkCountDown = 10000000;
		memory.isFull = true;
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			{npc_id = 30204, instance = instance,}
		);
		
		local player = ParaScene.GetPlayer();
		local dx, dy, dz = mushroom:GetPosition();
		local px, py, pz = player:GetPosition();
		local mushroomChar = mushroom:ToCharacter();
		local s = mushroomChar:GetSeqController();
		mushroomChar:Stop();
		s:WalkTo((px - dx), 0, (pz - dz));
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function LuluMushroom.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30204);
	local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30204, instance);
	if(mushroom and mushroom:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		if(memory.isFull == true and memory.isRewarded ~= true) then
			return true;
		elseif(memory.isFull == true and memory.isRewarded == true) then
			log("error: lulumushroom rewarded and full \n")
			return false;
		end
		-- 10103: FollowPetMGBB
		if(hasGSItem(10103)) then
			headon_speech.Speek(mushroom.name, headon_speech.GetBoldTextMCML("用水弹来挑战一下我灵活的身材吧！"), 5, true);
		else
			headon_speech.Speek(mushroom.name, headon_speech.GetBoldTextMCML("你没有用水弹把我变到最大，我不想跟你回家！"), 3, true);
		end
	end
	return false;
end