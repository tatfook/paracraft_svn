--[[
Title: 30094_Beehive
Author(s): WangTian
Date: 2009/8/27

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Playground/30094_Beehive.lua
------------------------------------------------------------
]]

-- create class
local libName = "Beehive";
local Beehive = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Beehive", Beehive);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Beehive.main
function Beehive.main()
end

-- Beehive.main
function Beehive.On_Timer()
	if(Beehive.StunTime and (ParaGlobal.GetGameTime() - Beehive.StunTime) > 45000) then
		Beehive.StunTime = nil;
		Beehive.Stunned = nil;
		NPC.DeleteNPCCharacter(300941);
		NPC.DeleteNPCCharacter(300942);
	end
	if(Beehive.StunTime and (ParaGlobal.GetGameTime() - Beehive.StunTime) > 30000) then
		NPC.DeleteNPCCharacter(300941);
		NPC.DeleteNPCCharacter(300942);
	end
end

function Beehive.PreDialog()
	local beehive = NPC.GetNpcCharacterFromIDAndInstance(30094);
	if(beehive and beehive:IsValid() == true) then
		--if(commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigeyeBee.CreateTime")) then
			----headon_speech.Speek(beehive.name, headon_speech.GetBoldTextMCML("我已经被你摇晕了，你过会再来吧。"), 3, true);
			--Beehive.GetHoneyCrystal = nil;
			--Beehive.GetWorm = nil;
			--Beehive.Stunned = true;
			--return true;
		--end
		if(Beehive.Stunned and Beehive.StunTime) then
			--headon_speech.Speek(beehive.name, headon_speech.GetBoldTextMCML("我已经被你摇晕了，你过会再来吧。"), 3, true);
			Beehive.Stunned = true;
			return true;
		end
		Beehive.Stunned = true;
		Beehive.StunTime = ParaGlobal.GetGameTime();
		
		-- call hook for OnShakeBeehive
		local hook_msg = { aries_type = "OnShakeBeehive", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

		local hook_msg = { aries_type = "onShakeBeehive_MPD", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
		
		local dx, dy, dz = beehive:GetPosition();
		local r = math.random(0, 100)
		if(r <= 30) then
			--30% chance to get a honey cone
			Beehive.GetHoneyCrystal = true;
			Beehive.GetWorm = nil;
			local npcChar = NPC.GetNpcCharacterFromIDAndInstance(300941);
			if(npcChar and npcChar:IsValid() == true) then
			else
				local params = {
					name = "",
					--gsid = 17008,
					position =  { 19803.521484, 10.216177, 19778.083984, },
					assetfile_char = "character/common/dummy/cube_size/cube_size.x",
					assetfile_model = "model/05plants/v5/04other/HoneyCrystal/HoneyCrystal.x",
					facing = 0.91666221618652,
					scaling = 2.0,
					scaling_char = 0.3,
					main_script = "",
					main_function = "",
					dialog_page = "script/apps/Aries/NPCs/Playground/30094_Beehive_dialog.html", -- forcestate = 1
					EnablePhysics = false,
					cursor = "Texture/Aries/Cursor/Pick.tga",
					--gameobj_type = "FreeItem",
					--isdeleteafterpick = true,
					--pick_count = 1,
					--EnablePhysics = false,
					--onpick_msg = "你真幸运啊，老蜂窝要酝酿很久才会产出一个蜂蜜结晶呢，你的抱抱龙这下有口福了，快去给它做吃的吧。",
				};
				local NPC = MyCompany.Aries.Quest.NPC;
				local honey, honeyModel = NPC.CreateNPCCharacter(300941, params);
				if(honey and honey:IsValid() == true) then
					honey:ToCharacter():FallDown();
					UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
						local honey, honeyModel = NPC.GetNpcCharModelFromIDAndInstance(300941);
						if(honey and honeyModel) then
							honeyModel:SetPosition(honey:GetPosition());
						end
					end);
				end
			end
			return false;
		elseif(r <= 60) then
			--30% chance to drop a worm
			Beehive.GetHoneyCrystal = nil;
			Beehive.GetWorm = true;
			local npcChar = NPC.GetNpcCharacterFromIDAndInstance(300942);
			if(npcChar and npcChar:IsValid() == true) then
			else
				local params = {
					name = "",
					--gsid = 17009,
					position = { 19803.521484, 10.216177, 19778.083984, },
					assetfile_char = "character/common/dummy/cube_size/cube_size.x",
					assetfile_model = "model/05plants/v5/04other/GreenBug/GreenBug.x",
					facing = 0.91666221618652,
					scaling = 2.0,
					scaling_char = 0.3,
					main_script = "",
					main_function = "",
					dialog_page = "script/apps/Aries/NPCs/Playground/30094_Beehive_dialog.html", -- forcestate = 2
					EnablePhysics = false,
					cursor = "Texture/Aries/Cursor/Pick.tga",
					--gameobj_type = "FreeItem",
					--isdeleteafterpick = true,
					--pick_count = 1,
					--EnablePhysics = false,
					--onpick_msg = "老树长了蛀牙，这条小虫就躲在里面折磨老树，你快把它捡去喂小鸡，也许还会有意外收获。",
				};
				local NPC = MyCompany.Aries.Quest.NPC;
				local worm, wormModel = NPC.CreateNPCCharacter(300942, params);
				if(worm and worm:IsValid() == true) then
					worm:ToCharacter():FallDown();
					UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
						local worm, wormModel = NPC.GetNpcCharModelFromIDAndInstance(300942);
						if(worm and wormModel) then
							wormModel:SetPosition(worm:GetPosition());
						end
					end);
				end
			end
			return false;
		elseif(r <= 100) then
			--40% chance to explode
			Beehive.Bee_Created = false;
			local bCreateBee = false;
			-- 10102: FollowPetMFBB
			if(not hasGSItem(10102)) then
				-- 50% chance to spawn the bee
				if(r < 80) then
					bCreateBee = true;
				end
			end
			-- effect of Beehive explode
            local params = {
                asset_file = "character/v5/09effect/Bee/Bee.x",
                binding_obj_name = beehive.name,
                start_position = nil,
                duration_time = 800,
                force_name = nil,
                begin_callback = function() end,
                end_callback = function() 
						-- 10102: FollowPetMFBB
						if(bCreateBee) then
							-- remove the cat from scene
			                local params = {
				                asset_file = "character/v5/09effect/Disappear/Disappear.x",
				                binding_obj_name = nil,
				                start_position = { 19803.521484, 10.216177, 19778.083984, },
				                duration_time = 1600,
				                force_name = nil,
				                begin_callback = function() end,
				                end_callback = nil,
				                stage1_time = 800,
				                stage1_callback = function()
										Beehive.Bee_Created = true;
										local npc_id = 30206;
										local params = { 
											name = "大眼蜂",
											position = { 19803.521484, 10.216177, 19778.083984, },
											facing = 0.91666221618652,
											scaling = 2,
											isalwaysshowheadontext = false;
											assetfile_char = "character/v3/Pet/MFBB/MFBB.xml",
											main_script = "script/apps/Aries/NPCs/FollowPets/30206_BigeyeBee.lua",
											main_function = "MyCompany.Aries.Quest.NPCs.BigeyeBee.main();",
											on_timer = ";MyCompany.Aries.Quest.NPCs.BigeyeBee.On_Timer();",
											dialog_page = "script/apps/Aries/NPCs/FollowPets/30206_BigeyeBee_dialog.html",
											AI_script = "script/apps/Aries/NPCs/FollowPets/30206_BigeyeBee_AI.lua",
											On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.BigeyeBee_AI.On_FrameMove();",
										};
										local bee = NPC.CreateNPCCharacter(npc_id, params);
					                end,
				                stage2_time = nil,
				                stage2_callback = nil,
			                };
			                local EffectManager = MyCompany.Aries.EffectManager;
			                EffectManager.CreateEffect(params);
						end
					end,
                stage1_time = nil,
                stage1_callback = nil,
                stage2_time = nil,
                stage2_callback = nil,
            };
            local EffectManager = MyCompany.Aries.EffectManager;
            EffectManager.CreateEffect(params);
            if(bCreateBee == true) then
				return false;
			else
				-- very dirty code
				Beehive.TellDialogBeeCreated = true;
				return true;
            end
		end
	end
	-- never enter the dialog
	return false;
end