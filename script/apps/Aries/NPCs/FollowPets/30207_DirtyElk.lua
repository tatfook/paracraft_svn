--[[
Title: DirtyElk
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30207_DirtyElk.lua
------------------------------------------------------------
]]

-- create class
local libName = "DirtyElk";
local DirtyElk = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DirtyElk", DirtyElk);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- aqua horse scale stages
local scale_stages = {2, 2.5, 3, 3.5, 4, 4.5};

local respawntime_inseconds = 60 * 60;

-- replaceable textures
local stages_texture = {
	"character/v5/02animals/Elk/Elk_Dirty_05.dds",
	"character/v5/02animals/Elk/Elk_Dirty_04.dds",
	"character/v5/02animals/Elk/Elk_Dirty_03.dds",
	"character/v5/02animals/Elk/Elk_Dirty_02.dds",
	"character/v5/02animals/Elk/Elk_Dirty_01.dds",
	"character/v5/02animals/Elk/Elk_Regular.dds",
};

-- DirtyElk.main
function DirtyElk.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					log("=========== on dirty elk hit check ===========\n")
					commonlib.echo(msg);
					-- on hit dirty elk with snow ball
					if(msg.throwItem.gsid == 9504) then
						local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
						if(dirtyElk and dirtyElk:IsValid() == true) then
							local _, name;
							for _, name in pairs(msg.hitObjNameList or {}) do
								if(name == dirtyElk.name) then
									-- hit on self
									DirtyElk.On_Hit();
								end
							end
						end
					end
				end
			end
		end, 
	hookName = "OnThrowableHit_30207_DirtyElk", appName = "Aries", wndName = "throw"});
	
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
		end
	});
	loader:AddAssets(ParaAsset.LoadTexture("", stages_texture[1], 1));
	loader:AddAssets(ParaAsset.LoadTexture("", stages_texture[2], 1));
	loader:AddAssets(ParaAsset.LoadTexture("", stages_texture[3], 1));
	loader:AddAssets(ParaAsset.LoadTexture("", stages_texture[4], 1));
	loader:AddAssets(ParaAsset.LoadTexture("", stages_texture[5], 1));
	loader:AddAssets(ParaAsset.LoadTexture("", stages_texture[6], 1));
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
	if(dirtyElk and dirtyElk:IsValid() == true) then
		if(memory.isClean == true) then
			DirtyElk.SetStage(5);
		else
			DirtyElk.SetStage(1);
		end
	end
	
    local ElkLeaveDate = MyCompany.Aries.app:ReadConfig("ElkLeaveDate"..System.App.profiles.ProfileManager.GetNID());
    local ElkLeaveTime = MyCompany.Aries.app:ReadConfig("ElkLeaveTime"..System.App.profiles.ProfileManager.GetNID());
    if(ElkLeaveDate == MyCompany.Aries.Scene.GetServerDate() and 
		((MyCompany.Aries.Scene.GetElapsedSecondsSince0000() or 0) - (ElkLeaveTime or 0)) < respawntime_inseconds) then
		NPC.DeleteNPCCharacter(30207);
    end
end

-- DirtyElk.LeaveTown
function DirtyElk.LeaveTown()
    local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
    if(dirtyElk and dirtyElk:IsValid() == true) then
        local dirtyElkChar = dirtyElk:ToCharacter();
        dirtyElkChar:Stop();
        -- remove the elk from scene
        local params = {
            asset_file = "character/v5/09effect/Disappear/Disappear.x",
            binding_obj_name = dirtyElk.name,
            start_position = nil,
            duration_time = 1500,
            force_name = "DirtyElkDisappearEffect",
            begin_callback = function() end,
            end_callback = nil,
            stage1_time = 800,
            stage1_callback = function()
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.StopBinding("DirtyElkDisappearEffect");
					-- delete the character from scene if valid
					MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30207);
					-- reset the memory
					local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
					memory.stage = 1;
					memory.cleanCountDown = nil;
					memory.cleanStartTime = nil;
					memory.isClean = nil;
                end,
            stage2_time = nil,
            stage2_callback = nil,
        };
        local EffectManager = MyCompany.Aries.EffectManager;
        EffectManager.CreateEffect(params);
    end
    
    MyCompany.Aries.app:WriteConfig("ElkLeaveDate"..System.App.profiles.ProfileManager.GetNID(), MyCompany.Aries.Scene.GetServerDate());
    MyCompany.Aries.app:WriteConfig("ElkLeaveTime"..System.App.profiles.ProfileManager.GetNID(), MyCompany.Aries.Scene.GetElapsedSecondsSince0000());
end

-- DirtyElk.SetStage and replaceable texture
function DirtyElk.SetStage(index)
	if(index > #stages_texture) then
		return;
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	memory.stage = index;
	local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
	if(dirtyElk and dirtyElk:IsValid() == true) then
		local assetfile = stages_texture[index];
		dirtyElk:SetReplaceableTexture(1, ParaAsset.LoadTexture("", assetfile, 1));
	end
end

-- DirtyElk.GetStage
function DirtyElk.GetStage()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	return memory.stage;
end

local delay_timer = 0;
-- DirtyElk.On_Timer
function DirtyElk.On_Timer()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	-- pass 1: check if hit on the horse instance itself
	if(memory.hit_gsid == 9504) then
		--local dx, dy, dz = dirtyElk:GetPosition();
		--if(math.abs(memory.hitpoint_x - dx) < 1 and 
			--math.abs(memory.hitpoint_y - dy) < 1 and 
			--math.abs(memory.hitpoint_z - dz) < 1) then
			---- hit on self
			--MyCompany.Aries.Quest.NPCs.DirtyElk.On_Hit(instance);
			---- reset the hit gsid in case of multiple hit response
			--memory.hit_gsid = nil;
		--end
		local _, name;
		for _, name in pairs(memory.hitObjNameList or {}) do
			if(name == dirtyElk.name) then
				-- hit on self
				DirtyElk.On_Hit();
				-- reset the hit gsid in case of multiple hit response
				memory.hit_gsid = nil;
			end
		end
	end
	-- countdown if cleaning
	if(memory.cleanCountDown) then
		if((ParaGlobal.GetGameTime() - memory.cleanStartTime) > memory.cleanCountDown) then
			MyCompany.Aries.Quest.NPCs.DirtyElk.On_Dirty();
		end
	end
	
	if(delay_timer > 1000) then
		delay_timer = 0;
		local ElkLeaveDate = MyCompany.Aries.app:ReadConfig("ElkLeaveDate"..System.App.profiles.ProfileManager.GetNID());
		local ElkLeaveTime = MyCompany.Aries.app:ReadConfig("ElkLeaveTime"..System.App.profiles.ProfileManager.GetNID());
		
		if(ElkLeaveDate ~= MyCompany.Aries.Scene.GetServerDate() or 
			((MyCompany.Aries.Scene.GetElapsedSecondsSince0000() or 0) - (ElkLeaveTime or 0)) >= respawntime_inseconds) then
			local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
			if(not dirtyElk or dirtyElk:IsValid() == false) then
				-- recreate the elk npc
				MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30207, MyCompany.Aries.Quest.NPCList.NPCs[30207]);
			end
		end
	else
		delay_timer = delay_timer + 1;
	end
end

-- DirtyElk.On_Dirty
-- @param instance: npc instance of the dirtyElk
function DirtyElk.On_Dirty()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
	if(dirtyElk and dirtyElk:IsValid() == true) then
		-- set the start time
		memory.cleanStartTime = nil;
		memory.cleanCountDown = nil;
		memory.isClean = nil;
		-- set to init stage
		DirtyElk.SetStage(1);
	end
end

-- DirtyElk.On_Hit
function DirtyElk.On_Hit()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207);
	if(dirtyElk and dirtyElk:IsValid() == true) then
		if(not memory.isClean) then
			-- set the start time
			memory.cleanStartTime = ParaGlobal.GetGameTime();
			memory.cleanCountDown = 30000;
			-- set to the next stage
			DirtyElk.SetStage(DirtyElk.GetStage() + 1);
			
			if(DirtyElk.GetStage() == 2) then
				headon_speech.Speek(dirtyElk.name, headon_speech.GetBoldTextMCML("好喜欢雪球的清凉，再来点吧！"), 3, true);
			elseif(DirtyElk.GetStage() == 3) then
				headon_speech.Speek(dirtyElk.name, headon_speech.GetBoldTextMCML("好舒服，不过身上还有泥土，还要再洗洗！"), 3, true);
			elseif(DirtyElk.GetStage() == 4) then
				headon_speech.Speek(dirtyElk.name, headon_speech.GetBoldTextMCML("越来越干净了，再来点雪球会更好！"), 3, true);
			elseif(DirtyElk.GetStage() == 5) then
				headon_speech.Speek(dirtyElk.name, headon_speech.GetBoldTextMCML("再给我一个雪球，我让你看看我原来的样子！"), 3, true);
			end
			if(DirtyElk.GetStage() == #stages_texture) then
				memory.isClean = true;
				DirtyElk.On_ReachFinalStage()
			end
		elseif(memory.isClean) then
			-- automatically show the dialog page
			System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
				{npc_id = 30207}
			);
		end
	end
end

-- DirtyElk.On_ReachFinalStage
function DirtyElk.On_ReachFinalStage()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207, instance);
	if(dirtyElk and dirtyElk:IsValid() == true) then
		memory.cleanStartTime = ParaGlobal.GetGameTime();
		memory.cleanCountDown = 10000000;
		memory.isClean = true;
		-- automatically show the dialog page
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			{npc_id = 30207}
		);
		-- automatically walk to the player
		local player = ParaScene.GetPlayer();
		local dx, dy, dz = dirtyElk:GetPosition();
		local px, py, pz = player:GetPosition();
		local dirtyElkChar = dirtyElk:ToCharacter();
		local s = dirtyElkChar:GetSeqController();
		dirtyElkChar:Stop();
		s:WalkTo((px - dx), 0, (pz - dz));
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function DirtyElk.PreDialog(npc_id)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
	local dirtyElk = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30207, instance);
	if(dirtyElk and dirtyElk:IsValid() == true) then
		if(memory.isClean == true) then
			return true;
		end
		headon_speech.Speek(dirtyElk.name, headon_speech.GetBoldTextMCML("我从远方来，满身的泥土，谁能用雪帮我洗洗呢？"), 3, true);
	end
	return false;
end