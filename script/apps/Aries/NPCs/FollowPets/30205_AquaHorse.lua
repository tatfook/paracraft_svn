--[[
Title: AquaHorse
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30205_AquaHorse.lua
------------------------------------------------------------
]]

-- create class
local libName = "AquaHorse";
local AquaHorse = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AquaHorse", AquaHorse);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- aqua horse scale stages
local scale_stages = {2, 2.5, 3, 3.5, 4, 4.5};

-- AquaHorse.main
function AquaHorse.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);
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
	hookName = "OnThrowableHit_30205_AquaHorse", appName = "Aries", wndName = "throw"});
	
	local instance;
	for instance = 1, 8 do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);
		local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
		if(aquaHorse and aquaHorse:IsValid() == true) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
			if(memory.isFull == true) then
				aquaHorse:SetScale(4.5);
			end
		end
	end
end

-- AquaHorse.On_Timer
function AquaHorse.On_Timer()
	-- AI script will reset nextGossipInstance to nil if visualized
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);
	local time = ParaGlobal.GetGameTime();
	memory.lastHeadonTextTime = memory.lastHeadonTextTime or 0;
	if((time - memory.lastHeadonTextTime) > 5000) then
		-- select one of the horse to say the headon text
		memory.lastHeadonTextTime = time;
		local r = math.random(1, 8); -- in case of 0
		local choice = math.ceil(r);
		local horse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, choice);
		local player = ParaScene.GetPlayer();
		if(horse and horse:IsValid() == true) then
			--local r = math.random(1, 4);
			--local choice = math.ceil(r) or 1;
			--local gossips = {"我是温顺的小蓝马，我肚子饿了，想吃果冻！",
							--"我是快乐的小蓝马，我最喜欢吃滑滑甜甜的东西，你知道是什么吗？",
							--"嘀哒嘀，嘀哒嘀，我的颜色最魅力！",
							--"你给我带果冻来了吗？",};
			--local dist = horse:DistanceTo(player);
			--if(dist < 30) then
				--headon_speech.Speek(horse.name, headon_speech.GetBoldTextMCML(gossips[choice]), 3, true);
			--end
		end
	end
end

-- AquaHorse.On_Shrink
-- @param instance: npc instance of the aquahorse
function AquaHorse.On_Shrink(instance)
	if(not instance) then
		return;
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);
	local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
	if(aquaHorse and aquaHorse:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		memory.stage = 1;
		local scale_from = aquaHorse:GetScale();
		local scale_to = scale_stages[1];
		memory.shrinkCountDown = nil;
		memory.shrinkStartTime = nil;
		memory.isShrinking = true;
		memory.isFull = nil;
		-- repick random
		memory.random = nil;
		-- linar shirinking scale
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
			if(aquaHorse and aquaHorse:IsValid() == true) then
				if(elapsedTime == 500) then
					aquaHorse:SetScale(scale_to);
					-- finish shrinking animation
					memory.isShrinking = nil;
				end
				local this_scale = (scale_to - scale_from) * elapsedTime / 500 + scale_from;
				aquaHorse:SetScale(this_scale);
			end
		end);
	end
end

-- AquaHorse.On_Hit
-- @param instance: npc instance of the aquahorse
function AquaHorse.On_Hit(instance)
	if(not instance) then
		return;
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);

	local stepvalue = 1;
	local hit_gsid = memory.hit_gsid;

	local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
	if(aquaHorse and aquaHorse:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		memory.stage = memory.stage or 1;

		if(hit_gsid == 9508) then
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
			local name = aquaHorse.name;
			UIAnimManager.PlayCustomAnimation(350, function(elapsedTime)
				local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
				if(aquaHorse and aquaHorse:IsValid() == true) then
					if(elapsedTime == 350) then
						aquaHorse:SetScale(scale_to);
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
						aquaHorse:SetScale(delta + scale_from);
					end
				end
			end);
			memory.stage = memory.stage + stepvalue;
			headon_speech.Speek(name, headon_speech.GetBoldTextMCML("我要果冻！肚子还没吃饱呢。。。"), 3, true);
			
			if(scale_stages[memory.stage + 1] == nil) then
				-- reach the final stage
				AquaHorse.On_ReachFinalStage(instance);
			end
		else
			log("error: aquahorse is full\n");
		end
	end
end

function AquaHorse.On_ReachFinalStage(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);
	local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
	if(aquaHorse and aquaHorse:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		memory.shrinkStartTime = ParaGlobal.GetGameTime();
		memory.shrinkCountDown = 10000000;
		memory.isFull = true;
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			{npc_id = 30205, instance = instance,}
		);
		
		local player = ParaScene.GetPlayer();
		local dx, dy, dz = aquaHorse:GetPosition();
		local px, py, pz = player:GetPosition();
		local aquaHorseChar = aquaHorse:ToCharacter();
		local s = aquaHorseChar:GetSeqController();
		aquaHorseChar:Stop();
		s:WalkTo((px - dx), 0, (pz - dz));
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function AquaHorse.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30205);
	local aquaHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30205, instance);
	if(aquaHorse and aquaHorse:IsValid() == true) then
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		if(memory.isFull == true and memory.isRewarded ~= true) then
			return true;
		elseif(memory.isFull == true and memory.isRewarded == true) then
			log("error: aquahorse rewarded and full \n")
			return false;
		end
		-- 10108: FollowPetXM
		if(hasGSItem(10108)) then
			headon_speech.Speek(aquaHorse.name, headon_speech.GetBoldTextMCML("我是小蓝马，我喜欢吃果冻！"), 3, true);
		else
			headon_speech.Speek(aquaHorse.name, headon_speech.GetBoldTextMCML("给我吃点果冻吧，吃饱了我就和你回家！"), 3, true);
		end
	end
	return false;
end