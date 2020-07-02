--[[
Title: ZodiacAnimals
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30212_ZodiacAnimals.lua
------------------------------------------------------------
]]

-- create class
local libName = "ZodiacAnimals";
local ZodiacAnimals = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ZodiacAnimals", ZodiacAnimals);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 10117_ZodiacAnimal_Rat
-- 10118_ZodiacAnimal_Ox
-- 10119_ZodiacAnimal_Tiger
-- 10120_ZodiacAnimal_Rabbit
-- 10121_ZodiacAnimal_Dragon
-- 10122_ZodiacAnimal_Snake
-- 10123_ZodiacAnimal_Horse
-- 10124_ZodiacAnimal_Ram
-- 10125_ZodiacAnimal_Monkey
-- 10126_ZodiacAnimal_Rooster
-- 10127_ZodiacAnimal_Dog
-- 10128_ZodiacAnimal_Boar

local weather_animal_pairs = {
	["sunny"] = {
		10117, -- 10117_ZodiacAnimal_Rat
		10126, -- 10126_ZodiacAnimal_Rooster
		10128, -- 10128_ZodiacAnimal_Boar
		10122, -- 10122_ZodiacAnimal_Snake
		10118, -- 10118_ZodiacAnimal_Ox
		10121, -- 10121_ZodiacAnimal_Dragon
	},
	["cloudy"] = {
		10120, -- 10120_ZodiacAnimal_Rabbit
		10127, -- 10127_ZodiacAnimal_Dog
		10125, -- 10125_ZodiacAnimal_Monkey
		10124, -- 10124_ZodiacAnimal_Ram
		10123, -- 10123_ZodiacAnimal_Horse
		10119, -- 10119_ZodiacAnimal_Tiger
	},
	["snow"] = {
		10120, -- 10120_ZodiacAnimal_Rabbit
		10127, -- 10127_ZodiacAnimal_Dog
		10125, -- 10125_ZodiacAnimal_Monkey
		10124, -- 10124_ZodiacAnimal_Ram
		10123, -- 10123_ZodiacAnimal_Horse
		10119, -- 10119_ZodiacAnimal_Tiger
	},
};

ZodiacAnimals.animal_levels = {
	[10117] = 0, -- 10117_ZodiacAnimal_Rat
	[10118] = 2, -- 10118_ZodiacAnimal_Ox
	[10119] = 3, -- 10119_ZodiacAnimal_Tiger
	[10120] = 0, -- 10120_ZodiacAnimal_Rabbit
	[10121] = 3, -- 10121_ZodiacAnimal_Dragon
	[10122] = 2, -- 10122_ZodiacAnimal_Snake
	[10123] = 2, -- 10123_ZodiacAnimal_Horse
	[10124] = 1, -- 10124_ZodiacAnimal_Ram
	[10125] = 1, -- 10125_ZodiacAnimal_Monkey
	[10126] = 0, -- 10126_ZodiacAnimal_Rooster
	[10127] = 0, -- 10127_ZodiacAnimal_Dog
	[10128] = 1, -- 10128_ZodiacAnimal_Boar
};

ZodiacAnimals.Real_GSIDs = {};

ZodiacAnimals.LastInvisibleTimes = {};

local respawn_time = 120000;

-- ZodiacAnimals.main
function ZodiacAnimals.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	memory.IsCatchSuccess = memory.IsCatchSuccess or {};
	
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldClosing") then
				-- first unhook the world closing
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_ZodiacAnimals", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				-- then reset the panel and all tags and effect
				ZodiacAnimals.focus_instance = nil;
				ZodiacAnimals.isCatchPanelEnabled = false;
				ZodiacAnimals.EndFocusEffect();
				System.App.Commands.Call("File.MCMLWindowFrame", {
					name = "ZodiacAnimals_RightPanel", 
					app_key = MyCompany.Aries.app.app_key, 
					bShow = false});
				-- reset the catch success memory of all animals
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
				memory.IsCatchSuccess = {};
			end
		end, 
		hookName = "WorldClosing_ZodiacAnimals", appName = "Aries", wndName = "main"});
	
	-- reset the base model of each animal according to weather-animal pairs
	local pairs = weather_animal_pairs[MyCompany.Aries.Scene.GetWeather()];
	local i = 1;
	for i = 1, 24 do
		local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, i);
		if(npcChar and npcChar:IsValid() == true) then
			if(memory.IsCatchSuccess[i] == nil) then
				local assetfile;
				local this_gsid = pairs[ math.ceil(i/4) ];
				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(this_gsid);
				if(gsItem) then
					assetfile = gsItem.assetfile;
				end
				if(assetfile) then
					local asset = ParaAsset.LoadParaX("", assetfile);
					local npcCharChar = npcChar:ToCharacter();
					npcCharChar:ResetBaseModel(asset);
					if(this_gsid == 10118 or this_gsid == 10119 or this_gsid == 10121) then
						npcChar:SetScale(1.5);
					elseif(this_gsid == 10122 or this_gsid == 10123) then
						npcChar:SetScale(1.4);
					elseif(this_gsid == 10120 or this_gsid == 10125) then
						npcChar:SetScale(1.2);
					else
						npcChar:SetScale(1.3);
					end
				end
			end
		end
		-- set the real gsid if not specified before
		if(not ZodiacAnimals.Real_GSIDs[i]) then
			-- set the real gsid index
			local real_index = math.floor(math.random(100, 699) / 100);
			ZodiacAnimals.Real_GSIDs[i] = pairs[real_index];
			-- generate reward gsid for each npc instance
			ZodiacAnimals.GenerateReward(i);
		end
	end
	
	local i = 1;
	for i = 1, 24 do
		if(ZodiacAnimals.LastInvisibleTimes[i]) then
			if((ParaGlobal.GetGameTime() - ZodiacAnimals.LastInvisibleTimes[i]) <= respawn_time) then
				NPC.DeleteNPCCharacter(30212, i);
			end
		end
	end
end

local probability_table = {
	[10120] = {0.3, 0.1, 0.08, 0.05, 0.04, 0.02, 0.1, 0.1, 0.08, 0.08, 0.04, 0.01, 0}; -- 10120_ZodiacAnimal_Rabbit
	[10127] = {0.1, 0.3, 0.08, 0.04, 0.05, 0.02, 0.1, 0.1, 0.08, 0.08, 0.04, 0.01, 0}; -- 10127_ZodiacAnimal_Dog
	[10125] = {0.08, 0.08, 0.2, 0.05, 0.05, 0.01, 0.08, 0.08, 0.15, 0.15, 0.05, 0.01, 0.01}; -- 10125_ZodiacAnimal_Monkey
	[10122] = {0.03, 0.03, 0.1, 0.2, 0.12, 0.07, 0.03, 0.03, 0.1, 0.1, 0.12, 0.04, 0.03}; -- 10122_ZodiacAnimal_Snake
	[10123] = {0.03, 0.03, 0.1, 0.12, 0.2, 0.07, 0.03, 0.03, 0.1, 0.1, 0.12, 0.04, 0.03}; --10123_ZodiacAnimal_Horse
	[10121] = {0.01, 0.01, 0.05, 0.12, 0.12, 0.2, 0.01, 0.01, 0.05, 0.05, 0.12, 0.15, 0.1}; -- 10121_ZodiacAnimal_Dragon
	[10117] = {0.1, 0.1, 0.08, 0.05, 0.04, 0.02, 0.3, 0.1, 0.08, 0.08, 0.04, 0.01, 0}; -- 10117_ZodiacAnimal_Rat
	[10126] = {0.1, 0.1, 0.08, 0.05, 0.04, 0.02, 0.1, 0.3, 0.08, 0.08, 0.04, 0.01, 0}; -- 10126_ZodiacAnimal_Rooster
	[10128] = {0.08, 0.08, 0.15, 0.05, 0.05, 0.01, 0.08, 0.08, 0.2, 0.15, 0.05, 0.01, 0.01}; -- 10128_ZodiacAnimal_Boar
	[10124] = {0.08, 0.08, 0.15, 0.05, 0.05, 0.01, 0.08, 0.08, 0.15, 0.2, 0.05, 0.01, 0.01}; -- 10124_ZodiacAnimal_Ram
	[10118] = {0.03, 0.03, 0.1, 0.12, 0.12, 0.07, 0.03, 0.03, 0.1, 0.1, 0.2, 0.04, 0.03}; -- 10118_ZodiacAnimal_Ox
	[10119] = {0.01, 0.01, 0.05, 0.1, 0.1, 0.16, 0.01, 0.01, 0.05, 0.05, 0.1, 0.2, 0.15}; -- 10119_ZodiacAnimal_Tiger
};

-- 16032_TransformPill_Ostrich
-- 16033_TransformPill_Rat
-- 16034_TransformPill_Ox
-- 16035_TransformPill_Tiger
-- 16036_TransformPill_Rabbit
-- 16037_TransformPill_Dragon
-- 16038_TransformPill_Snake
-- 16039_TransformPill_Horse
-- 16040_TransformPill_Ram
-- 16041_TransformPill_Monkey
-- 16042_TransformPill_Rooster
-- 16043_TransformPill_Dog
-- 16044_TransformPill_Boar

local reward_order = {
	16036, 16043, 16041, 16038, 16039, 16037, 
	16033, 16042, 16044, 16040, 16034, 16035, 
	16032, 
};

function ZodiacAnimals.GenerateReward(index)
	local real_gsid = ZodiacAnimals.Real_GSIDs[index];
	
	local p_table = probability_table[real_gsid];
	local r = math.random(0, 1000) / 1000;
	local reward_gsid = 16036;
	local accum = 0;
	local i;
	for i = 1, #reward_order do
		if(r >= accum) then
			reward_gsid = reward_order[i];
		else
			break;
		end
		accum = accum + p_table[i];
	end
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	memory.Rewards = memory.Rewards or {};
	memory.Rewards[index] = reward_gsid;
end

-- ZodiacAnimals.On_Timer
function ZodiacAnimals.On_Timer()
	if(not ZodiacAnimals.is_catch_started) then
		return
	end
	local bNeedClose = false;
	if(ZodiacAnimals.focus_instance) then
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		if(ZodiacAnimals.focus_instance ~= targetNPC_instance) then
			bNeedClose = true;
		else
			local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, ZodiacAnimals.focus_instance);
			if(npcChar and npcChar:IsValid() == true) then
				local dist = ParaScene.GetPlayer():DistanceTo(npcChar);
				if(dist > 7) then
					bNeedClose = true;
				end
			end
		end
	else
		bNeedClose = true;
	end
	
	if(bNeedClose == true) then
		ZodiacAnimals.is_catch_started = nil;
		ZodiacAnimals.focus_instance = nil;
		ZodiacAnimals.isCatchPanelEnabled = false;
		ZodiacAnimals.EndFocusEffect()
		System.App.Commands.Call("File.MCMLWindowFrame", {
			name = "ZodiacAnimals_RightPanel", 
			app_key = MyCompany.Aries.app.app_key, 
			bShow = false});
	end
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	-- remove fail catch animals
	local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
	local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
	if(not targetNPC_id or not targetNPC_instance) then
		local i = 1;
		for i = 1, 24 do
			if(memory.IsCatchSuccess[i] == false) then
				local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, i);
				if(npcChar and npcChar:IsValid() == true) then
					ZodiacAnimals.RemoveAnimal(i);
				end
			end
		end
	end
	local i = 1;
	for i = 1, 24 do
		if(ZodiacAnimals.LastInvisibleTimes[i]) then
			local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, i);
			if(npcChar and npcChar:IsValid() == true) then
				ZodiacAnimals.LastInvisibleTimes[i] = nil;
			else
				if((ParaGlobal.GetGameTime() - ZodiacAnimals.LastInvisibleTimes[i]) > respawn_time) then
					local params = MyCompany.Aries.Quest.NPCList.NPCs[30212];
					-- create npc
					local position = params.positions[i];
					local facing = params.facings[i];
					local scaling = params.scaling;
					local rotation = params.rotation;
					if(params.scalings) then
						scaling = params.scalings[i];
					end
					if(params.rotations) then
						rotation = params.rotations[i];
					end
					local params = commonlib.deepcopy(params);
					params.copies = nil;
					params.positions = nil;
					params.facings = nil;
					params.scalings = nil;
					params.position = position;
					params.facing = facing;
					params.scaling = scaling;
					params.rotation = rotation;
					params.instance = i;
					Quest.NPC.CreateNPCCharacter(30212, params);
				end
			end
		else
			local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, i);
			if(npcChar and npcChar:IsValid() == true) then
				ZodiacAnimals.LastInvisibleTimes[i] = nil;
			else
				ZodiacAnimals.LastInvisibleTimes[i] = ParaGlobal.GetGameTime();
			end
		end
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function ZodiacAnimals.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	if(memory.IsCatchSuccess[instance] == true) then
		local real_gsid = ZodiacAnimals.Real_GSIDs[instance];
		if(not hasGSItem(real_gsid)) then
			memory.dialog_state = 2;
		else
			memory.dialog_state = 3;
		end
	elseif(memory.IsCatchSuccess[instance] == false) then
		memory.dialog_state = 4;
	else
		memory.dialog_state = 1;
	end
	return true;
end

-- 17079_CatchingNet_Level0
-- 17080_CatchingNet_Level1
-- 17081_CatchingNet_Level2
-- 17082_CatchingNet_Level3

-- on click the catching net
-- @param: net item guid
function ZodiacAnimals.OnClickCatchingNet(guid)
	local net_item = System.Item.ItemManager.GetItemByGUID(guid);
	if(not net_item or net_item.guid <= 0) then
		return;
	end
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	if(memory.IsCatchSuccess[ZodiacAnimals.focus_instance] ~= nil) then
		-- skip multiple catch
		return;
	end
	if(ZodiacAnimals.focus_instance) then
		-- get the real animal gsid and catching net level
		local focus_instance = ZodiacAnimals.focus_instance;
		local real_gsid = ZodiacAnimals.Real_GSIDs[focus_instance];
		local real_level = ZodiacAnimals.animal_levels[real_gsid];
		local net_gsid = net_item.gsid;
		local net_level = net_gsid - 17079;
		-- probability table of animal and net gsid
		local isSuccessCatch = false;
		if(real_level <= net_level) then
			isSuccessCatch = true;
		elseif(real_level == net_level + 1) then
			local r = math.random(0, 1000);
			if(r <= 20) then
				isSuccessCatch = true;
			end
		end
		-- proceed to the rest of the catch process
		if(isSuccessCatch == true) then
			local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
			memory.IsCatchSuccess[focus_instance] = true;
			memory.LastNetGSID = net_gsid;
		else
			local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
			memory.IsCatchSuccess[focus_instance] = false;
			memory.LastNetGSID = net_gsid;
		end
		-- delete the catching net
		ItemManager.DestroyItem(guid, 1, function(msg) 
			if(msg.issuccess == true) then
				-- proceed catch if net throwing finish
				local function ProceedCatch()
					-- show the real animal at the end of the effect
					local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, focus_instance);
					if(npcChar and npcChar:IsValid() == true) then
						local assetfile;
						local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(real_gsid);
						if(gsItem) then
							assetfile = gsItem.assetfile;
						end
						if(assetfile) then
							local asset = ParaAsset.LoadParaX("", assetfile);
							local npcCharChar = npcChar:ToCharacter();
							npcCharChar:ResetBaseModel(asset);
						end
						-- transform effect
						local params = {
			                asset_file = "character/v5/09effect/Disappear/Disappear.x",
							binding_obj_name = npcChar.name,
							start_position = nil,
							duration_time = 1500,
							begin_callback = function() 
								end,
							end_callback = function()
								end,
						};
						local EffectManager = MyCompany.Aries.EffectManager;
						EffectManager.CreateEffect(params);
						
			            local asset_file = "model/06props/v5/03quest/HunterNet/HunterNet_Fail.x";
						local replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v01_Fail.dds";
			            if(isSuccessCatch) then
							asset_file = "model/06props/v5/03quest/HunterNet/HunterNet.x";
							if(net_gsid == 17079) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v01.dds";
							elseif(net_gsid == 17080) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v02.dds";
							elseif(net_gsid == 17081) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v03.dds";
							elseif(net_gsid == 17082) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v04.dds";
							end
						else
							asset_file = "model/06props/v5/03quest/HunterNet/HunterNet_Fail.x";
							if(net_gsid == 17079) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v01_Fail.dds";
							elseif(net_gsid == 17080) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v02_Fail.dds";
							elseif(net_gsid == 17081) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v03_Fail.dds";
							elseif(net_gsid == 17082) then
								replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v04_Fail.dds";
							end
			            end
						-- net effect
						local params = {
			                asset_file = asset_file,
							replaceable_texture_effect = replaceable_texture_effect,
			                ismodel = true,
							scale = 0.7,
							binding_obj_name = npcChar.name,
							start_position = nil,
							duration_time = 1000,
							begin_callback = function() 
								end,
							end_callback = function()
								end,
						};
						local EffectManager = MyCompany.Aries.EffectManager;
						EffectManager.CreateEffect(params);
					end
					-- auto talk to NPC
					MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30212, focus_instance, true);
				end
				-- play throwing effect
				local replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v01.dds";
				if(net_gsid == 17079) then
					replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v01.dds";
				elseif(net_gsid == 17080) then
					replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v02.dds";
				elseif(net_gsid == 17081) then
					replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v03.dds";
				elseif(net_gsid == 17082) then
					replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v04.dds";
				end
				local params = {
					asset_file = "model/06props/v5/03quest/HunterNet/HunterNet.x",
					replaceable_texture_effect = replaceable_texture_effect,
					ismodel = true,
					scale = 0.7,
					binding_obj_name = nil,
					start_position = {0, 0, 0},
					duration_time = 1000,
					force_name = "ZodiacAnimals_ThrowNetEffect",
					begin_callback = function() 
						end,
					end_callback = function()
							ProceedCatch();
						end,
					elapsedtime_callback = function(elapsedTime, obj) 
							local p_x, p_y, p_z;
							local a_x, a_y, a_z;
							local player = ParaScene.GetPlayer();
							if(player and player:IsValid() == true) then
								p_x, p_y, p_z = player:GetPosition();
							end
							local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, focus_instance);
							if(npcChar and npcChar:IsValid() == true) then
								a_x, a_y, a_z = npcChar:GetPosition();
							end
							if(p_x and p_y and p_z and a_x and a_y and a_z) then
								local e_x = p_x + (a_x - p_x) * elapsedTime / 1000;
								local e_z = p_z + (a_z - p_z) * elapsedTime / 1000;
								local e_y = a_y - (elapsedTime / 1000 - 0.5) * (elapsedTime / 1000 - 0.5) * 1.25 + 1.25;
								obj:SetPosition(e_x, e_y, e_z);
							end
						end,
				};
				local EffectManager = MyCompany.Aries.EffectManager;
				EffectManager.CreateEffect(params);
			end
		end);
	end
end

function ZodiacAnimals.StartFocusEffect()
	local params = {
		asset_file = "character/common/tutorial_pointer/tutorial_pointer.x",
					--asset_file = "model/06props/v5/03quest/HunterNet/HunterNet.x",
					--replaceable_texture_effect = "model/06props/v5/03quest/HunterNet/HunterNet_v04.dds",
					--ismodel = true,
		binding_obj_name = nil,
		start_position = {0, 0, 0},
		duration_time = 9000000,
		force_name = "ZodiacAnimals_FocusEffect",
		begin_callback = function() 
			end,
		end_callback = nil,
		elapsedtime_callback = function(elapsedTime, obj) 
				local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, ZodiacAnimals.focus_instance);
				if(npcChar and npcChar:IsValid() == true) then
					if(obj and obj:IsValid() == true) then
						local x, y, z = npcChar:GetPosition();
						obj:SetPosition(x, y + 2, z);
					end
				end
			end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
end

function ZodiacAnimals.EndFocusEffect()
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.DestroyEffect("ZodiacAnimals_FocusEffect");
end

-- start the catch process and show the MCML page on the right side of the screen
function ZodiacAnimals.StartCatch(instance)
	ZodiacAnimals.is_catch_started = true;
	ZodiacAnimals.focus_instance = instance;
	ZodiacAnimals.isCatchPanelEnabled = true;
	ZodiacAnimals.StartFocusEffect();
	-- show MCML page
	local url = "script/apps/Aries/NPCs/FollowPets/30212_ZodiacAnimals_panel.html";
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "ZodiacAnimals_RightPanel", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		directPosition = true,
			align = "_rt",
				x = -120,
				y = 120,
				width = 120,
				height = 400,
	});
end

-- take animal home
function ZodiacAnimals.TakeHerHome(instance)
	local real_gsid = ZodiacAnimals.Real_GSIDs[instance];
	ItemManager.PurchaseItem(real_gsid, 1, function(msg)
		if(msg.issuccess == true) then
			MyCompany.Aries.Desktop.TargetArea.ShowTarget("");
			ZodiacAnimals.RemoveAnimal(instance);
		end
	end, function(msg) end, nil, nil);
end

-- get reward
function ZodiacAnimals.GetReward(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	memory.Rewards = memory.Rewards or {};
	local reward_gsid = memory.Rewards[instance];
	ItemManager.PurchaseItem(reward_gsid, 1, function(msg)
		if(msg.issuccess == true) then
			ZodiacAnimals.RemoveAnimal(instance);
		end
	end, function(msg) end, nil, nil);
end

-- remove animal from scene
function ZodiacAnimals.RemoveAnimal(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30212);
	memory.IsCatchSuccess[instance] = nil;
	-- reset real gsid
	ZodiacAnimals.Real_GSIDs[instance] = nil;
    local animal = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30212, instance);
    if(animal and animal:IsValid() == true) then
        local animalChar = animal:ToCharacter();
        animalChar:Stop();
        -- remove the animal from scene
        local params = {
            asset_file = "character/v5/09effect/Disappear/Disappear.x",
            binding_obj_name = animal.name,
            start_position = nil,
            duration_time = 1500,
            force_name = "ZodiacAnimalDisappearEffect",
            begin_callback = function() end,
            end_callback = nil,
            stage1_time = 800,
            stage1_callback = function()
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.StopBinding("ZodiacAnimalDisappearEffect");
	                MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30212, instance);
                end,
            stage2_time = nil,
            stage2_callback = nil,
        };
        local EffectManager = MyCompany.Aries.EffectManager;
        EffectManager.CreateEffect(params);
    end
end
