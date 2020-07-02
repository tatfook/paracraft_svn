--[[
Title: LazyPanda
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30208_LazyPanda.lua
------------------------------------------------------------
]]

-- create class
local libName = "LazyPanda";
local LazyPanda = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.LazyPanda", LazyPanda);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- initial panda position
local init_panda_position = {19886.53515625, 13.165970802307, 20200.15625};

-- LazyPanda.main
function LazyPanda.main()
	-- 10114_FollowPet_Panda
	--if(hasGSItem(10114)) then
		------ delete the panda if the user own one
		----NPC.DeleteNPCCharacter(30208);
		---- teleport the panda far away
		--local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
		--if(lazypanda and lazypanda:IsValid() == true) then
			---- set to some place far away
			--lazypanda:SetPosition(10000,0,0);
		--end
	--end
	---- refresh quest status
	--LazyPanda.RefreshStatus();
	
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
	--
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
	--local LazyPanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
	--if(LazyPanda and LazyPanda:IsValid() == true) then
		--if(memory.isClean == true) then
			--LazyPanda.SetStage(5);
		--else
			--LazyPanda.SetStage(1);
		--end
	--end
	--
    --local ElkLeaveDate = MyCompany.Aries.app:ReadConfig("ElkLeaveDate"..System.App.profiles.ProfileManager.GetNID());
    --local ElkLeaveTime = MyCompany.Aries.app:ReadConfig("ElkLeaveTime"..System.App.profiles.ProfileManager.GetNID());
    --if(ElkLeaveDate == MyCompany.Aries.Scene.GetServerDate() and 
		--((MyCompany.Aries.Scene.GetElapsedSecondsSince0000() or 0) - (ElkLeaveTime or 0)) < respawntime_inseconds) then
		--NPC.DeleteNPCCharacter(30208);
    --end
end

-- LazyPanda.RefreshStatus
function LazyPanda.RefreshStatus()
	---- 50246_TalkedWithPanda
	---- 10114_FollowPet_Panda
	--if(not hasGSItem(10114) and hasGSItem(50246)) then
		---- don't own panda and has talked to panda
		---- refresh the quest status panel
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/FollowPets/30208_LazyPanda_status.html", 
			--"normal", "Texture/Aries/Quest/Props/RescuePandaStatusIcon_32bits.png;0 0 80 75", "营救熊猫", nil, 20, nil);
	--else
		---- hide the newbiequest icon
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/FollowPets/30208_LazyPanda_status.html");
	--end
end
function LazyPanda.CanShow()
	if(not hasGSItem(10114) and hasGSItem(50246)) then
		return true;
	end
end
function LazyPanda.ShowStatus()
	NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
	MyCompany.Aries.Desktop.QuestArea.ShowNormalQuestStatus("script/apps/Aries/NPCs/FollowPets/30208_LazyPanda_status.html");
end
-- LazyPanda.LeaveTown
function LazyPanda.LeaveTown()
    --local LazyPanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
    --if(LazyPanda and LazyPanda:IsValid() == true) then
        --local LazyPandaChar = LazyPanda:ToCharacter();
        --LazyPandaChar:Stop();
        ---- remove the elk from scene
        --local params = {
            --asset_file = "character/v5/09effect/Disappear/Disappear.x",
            --binding_obj_name = LazyPanda.name,
            --start_position = nil,
            --duration_time = 800,
            --force_name = nil,
            --begin_callback = function() end,
            --end_callback = nil,
            --stage1_time = 400,
            --stage1_callback = function()
					---- delete the character from scene if valid
					--MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30208);
					---- reset the memory
					--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
					--memory.stage = 1;
					--memory.cleanCountDown = nil;
					--memory.cleanStartTime = nil;
					--memory.isClean = nil;
                --end,
            --stage2_time = nil,
            --stage2_callback = nil,
        --};
        --local EffectManager = MyCompany.Aries.EffectManager;
        --EffectManager.CreateEffect(params);
    --end
    --
    --MyCompany.Aries.app:WriteConfig("ElkLeaveDate"..System.App.profiles.ProfileManager.GetNID(), MyCompany.Aries.Scene.GetServerDate());
    --MyCompany.Aries.app:WriteConfig("ElkLeaveTime"..System.App.profiles.ProfileManager.GetNID(), MyCompany.Aries.Scene.GetElapsedSecondsSince0000());
end

local nextyelltime = 0;

-- LazyPanda.On_Timer
function LazyPanda.On_Timer()
	-- yell every 10 seconds
	local currentTime = ParaGlobal.GetGameTime();
	if(currentTime > nextyelltime) then
		nextyelltime = currentTime + 10000;
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		if(targetNPC_id ~= 30208) then
			-- 10114_FollowPet_Panda
			if(not hasGSItem(10114)) then
				-- 30209: panda_headon_speech
				local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30209);
				if(lazypanda and lazypanda:IsValid() == true) then
					-- show the yell text headon speech
					headon_speech.Speek(lazypanda.name, headon_speech.GetBoldTextMCML("救命啊，谁来救救我！"), 3, false);
				end
			end
		end
	end
	
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
	---- pass 1: check if hit on the horse instance itself
	--if(memory.hit_gsid == 9504) then
		----local dx, dy, dz = dirtyElk:GetPosition();
		----if(math.abs(memory.hitpoint_x - dx) < 1 and 
			----math.abs(memory.hitpoint_y - dy) < 1 and 
			----math.abs(memory.hitpoint_z - dz) < 1) then
			------ hit on self
			----MyCompany.Aries.Quest.NPCs.DirtyElk.On_Hit(instance);
			------ reset the hit gsid in case of multiple hit response
			----memory.hit_gsid = nil;
		----end
		--local _, name;
		--for _, name in pairs(memory.hitObjNameList or {}) do
			--if(name == dirtyElk.name) then
				---- hit on self
				--DirtyElk.On_Hit();
				---- reset the hit gsid in case of multiple hit response
				--memory.hit_gsid = nil;
			--end
		--end
	--end
	---- countdown if cleaning
	--if(memory.cleanCountDown) then
		--if((ParaGlobal.GetGameTime() - memory.cleanStartTime) > memory.cleanCountDown) then
			--MyCompany.Aries.Quest.NPCs.DirtyElk.On_Dirty();
		--end
	--end
	--
	--if(delay_timer > 1000) then
		--delay_timer = 0;
		--local ElkLeaveDate = MyCompany.Aries.app:ReadConfig("ElkLeaveDate"..System.App.profiles.ProfileManager.GetNID());
		--local ElkLeaveTime = MyCompany.Aries.app:ReadConfig("ElkLeaveTime"..System.App.profiles.ProfileManager.GetNID());
		--
		--if(ElkLeaveDate ~= MyCompany.Aries.Scene.GetServerDate() or 
			--((MyCompany.Aries.Scene.GetElapsedSecondsSince0000() or 0) - (ElkLeaveTime or 0)) >= respawntime_inseconds) then
			--local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
			--if(not dirtyElk or dirtyElk:IsValid() == false) then
				---- recreate the elk npc
				--MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30208, MyCompany.Aries.Quest.NPCList.NPCs[30208]);
			--end
		--end
	--else
		--delay_timer = delay_timer + 1;
	--end
end

-- 50240_HasCuredPandaLeg
-- 50241_HasRescuedWithBalloon
-- 50242_HasRescuedWithRope
-- 50246_TalkedWithPanda

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function LazyPanda.PreDialog(npc_id)
	-- show the yell text headon speech
	-- 30209: panda_headon_speech
	local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30209);
	if(lazypanda and lazypanda:IsValid() == true) then
		headon_speech.Speek(lazypanda.name, "", 0);
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
	memory.dialog_state = 1;
	-- mark the TalkedWithPanda tag
	-- 50246_TalkedWithPanda
	if(not hasGSItem(50246)) then
	    ItemManager.PurchaseItem(50246, 1, function(msg)
		    log("+++++++Purchase 50246_TalkedWithPanda return: +++++++\n")
		    commonlib.echo(msg);
		end, function(msg) 
		    -- refresh status after purchase
		    LazyPanda.RefreshStatus();
		end, nil, "none");
	end
	-- 50240_HasCuredPandaLeg
	-- 50241_HasRescuedWithBalloon
	-- 50242_HasRescuedWithRope
	-- 10114_FollowPet_Panda
	if(hasGSItem(10114)) then
		-- already have the panda, the panda should be extendedcost successful
		memory.dialog_state = 10;
	elseif(not hasGSItem(50240)) then
		-- not cured panda leg
		memory.dialog_state = 1;
	elseif(not hasGSItem(50241) and not hasGSItem(50242)) then
		-- haven't rescued in any way
		memory.dialog_state = 2;
	elseif(hasGSItem(50241) and not hasGSItem(50242)) then
		-- tried balloon, but not rope
		memory.dialog_state = 3;
	elseif(not hasGSItem(50241) and hasGSItem(50242)) then
		-- tried rope, but not balloon
		memory.dialog_state = 4;
	elseif(hasGSItem(50241) and hasGSItem(50242)) then
		-- rescued with both ways
		memory.dialog_state = 5;
	end
	
	return true;
end

-- LazyPanda.RescueWithBalloon()
-- NOTE: after extendedcost success 
function LazyPanda.RescueWithBalloon()
	-- RescueWithRope effect
	local params = {
		asset_file = "character/v5/02animals/Panda/animation/Panda_balloon.x",
		--binding_obj_name = lazypanda.name,
		start_position = init_panda_position,
		duration_time = 6000,
		force_name = nil,
		scale = 2.5,
		facing = -2.4391388893127,
		begin_callback = function() 
			local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
			if(lazypanda and lazypanda:IsValid() == true) then
				-- set to some place far away
				lazypanda:SetPosition(0,0,0);
			end
		end,
		end_callback = function() 
			local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
			if(lazypanda and lazypanda:IsValid() == true) then
				-- teleport back
				lazypanda:SetPosition(init_panda_position[1], init_panda_position[2], init_panda_position[3]);
				-- auto talk to panda
				MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30208, nil, true);
			end
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
end

-- LazyPanda.RescueWithRope()
-- NOTE: after extendedcost success 
function LazyPanda.RescueWithRope()
	-- RescueWithBalloon effect
	local params = {
		asset_file = "character/v5/02animals/Panda/animation/Panda_climb.x",
		--binding_obj_name = lazypanda.name,
		start_position = init_panda_position,
		duration_time = 11000,
		force_name = nil,
		scale = 2.5,
		facing = -2.4391388893127,
		begin_callback = function() 
			local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
			if(lazypanda and lazypanda:IsValid() == true) then
				-- set to some place far away
				lazypanda:SetPosition(0,0,0);
			end
		end,
		end_callback = function() 
			local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
			if(lazypanda and lazypanda:IsValid() == true) then
				-- teleport back
				lazypanda:SetPosition(init_panda_position[1], init_panda_position[2], init_panda_position[3]);
				-- auto talk to panda
				MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30208, nil, true);
			end
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
end


-- LazyPanda.NinjaJump()
function LazyPanda.NinjaJump()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
	local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
	if(lazypanda and lazypanda:IsValid() == true) then
		--local x, y, z = lazypanda:GetPosition();
		lazypanda:SetVisible(false);
		
		-- light effect
		local params = {
			asset_file = "character/v5/temp/Effect/Moonfire_Impact_Base.x",
			start_position = init_panda_position,
			duration_time = 1000,
			scale = 3,
			begin_callback = function() 
			end,
			end_callback = function()
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
		
		-- jump effect
		local params = {
			asset_file = "character/v5/02animals/Panda/Panda.x",
			start_position = init_panda_position,
			duration_time = 1000,
			scale = 2.5,
			facing = -2.4391388893127,
			begin_callback = function() 
			end,
			end_callback = function()
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30208);
				local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
				if(lazypanda and lazypanda:IsValid() == true) then
					local x, y, z = lazypanda:GetPosition();
					local p_x, p_y, p_z = ParaScene.GetPlayer():GetPosition();
					local facing = ParaScene.GetPlayer():GetFacing();
					lazypanda:SetPosition(p_x + 3*math.cos(facing), p_y, p_z - 3*math.sin(facing));
					lazypanda:SetFacing(facing + 3.14);
					lazypanda:SetVisible(true);
					lazypanda:SnapToTerrainSurface(0);
					-- spawn effect
					local params = {
						asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
						binding_obj_name = lazypanda.name,
						start_position = nil,
						duration_time = 800,
						force_name = nil,
						begin_callback = function() end,
						end_callback = function()
							-- auto talk to panda
							MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30208, nil, true);
						end,
					};
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.CreateEffect(params);
				end
			end,
			elapsedtime_callback = function(elapsedTime, obj)
				-- direct flying
				obj:SetPosition(init_panda_position[1], init_panda_position[2] + (elapsedTime / 1000) * 40, init_panda_position[3]);
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end

-- LazyPanda.PandaGoHome()
function LazyPanda.PandaGoHome()
	local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
	if(lazypanda and lazypanda:IsValid() == true) then
		-- go home with effect
		local params = {
			asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
			binding_obj_name = lazypanda.name,
			start_position = nil,
			duration_time = 1400,
			force_name = nil,
			begin_callback = function() end,
			end_callback = nil,
			stage1_time = 400,
			stage1_callback = function()
					local lazypanda = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30208);
					if(lazypanda and lazypanda:IsValid() == true) then
						-- set to some place far away
						lazypanda:SetPosition(0,0,0);
					end
				end,
			stage2_time = nil,
			stage2_callback = nil,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end