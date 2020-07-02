--[[
Title: Lolicat
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30201_LoliCat.lua
------------------------------------------------------------
]]

-- create class
local libName = "LoliCat";
local LoliCat = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.LoliCat", LoliCat);

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
LoliCat.time_limit = 300;

-- LoliCat.main
function LoliCat.main()
	local memory = NPCAIMemory.GetMemory(30201);
	local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
	if(cat and cat:IsValid() == true) then
		-- record the born position
		memory.bornPos = {cat:GetPosition()};
	end
end

-- LoliCat.On_Timer
function LoliCat.On_Timer()
	local memory = NPCAIMemory.GetMemory(30201);
	if(memory.RevisibleGameTime) then
		if(ParaGlobal.GetGameTime() > memory.RevisibleGameTime) then
			memory.RevisibleGameTime = nil;
			local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
			if(cat and cat:IsValid() == true) then
				local params = {
					asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
					binding_obj_name = cat.name,
					start_position = nil,
					duration_time = 800,
					force_name = nil,
					begin_callback = function() end,
					end_callback = nil,
					stage1_time = 400,
					stage1_callback = function()
							local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
							if(cat and cat:IsValid() == true) then
								cat:SetVisible(true);
							end
						end,
					stage2_time = nil,
					stage2_callback = nil,
				};
				local EffectManager = MyCompany.Aries.EffectManager;
				EffectManager.CreateEffect(params);
			end
		end
	end
	if(memory.lockcatCount) then
		memory.lockcatCount = memory.lockcatCount - 1;
		if(memory.lockcatCount == 4) then
			LoliCat.RespawnCat();
		elseif(memory.lockcatCount == 0) then
			memory.lockcatCount = nil;
		end
	end
	
	if(memory.startedHiding == true) then
		local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
		local player = ParaScene.GetPlayer();
		if(cat and cat:IsValid() == true and player:IsValid() == true) then
			---- reset all lolicat status if user out of 50 meter range
			--local dist = cat:DistanceTo(player);
			--if(dist > 50) then
				--LoliCat.Reset();
			--end
			-- reset all lolicat status if hiding time exceeds 3 minutes
			if((ParaGlobal.GetGameTime() - memory.startedHidingTime) > LoliCat.time_limit * 1000) then
				local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
				local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
				if(targetNPC_id == 30201) then
					-- delay the reset by 2 seconds if selected
					-- the selection lay on the fact that the dialog is in progress
					memory.startedHidingTime = memory.startedHidingTime + 2000;
				else
					LoliCat.Reset(true);
				end
			else
				if(memory.isCaught) then
					memory.startedHidingTime = ParaGlobal.GetGameTime() - LoliCat.time_limit * 1000;
				end
			end
		end
	end
end

-- reset all lolicat status
function LoliCat.Reset(isFailed)
	local memory = NPCAIMemory.GetMemory(30201);
	memory.startedHiding = nil;
	memory.lockcatCount = nil;
	memory.isCaught = nil;
	local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
	if(cat and cat:IsValid() == true) then
        local catChar = cat:ToCharacter();
        catChar:Stop();
        
		local params = {
			asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
			binding_obj_name = cat.name,
			start_position = nil,
			duration_time = 1400,
			force_name = nil,
			begin_callback = function() 
					if(isFailed) then
						local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
						if(cat and cat:IsValid() == true) then
							local player = ParaScene.GetPlayer();
							local dist = cat:DistanceTo(player);
							if(dist <= 100) then
								---- say the following text with NPC_dialog
								--headon_speech.Speek(cat.name, headon_speech.GetBoldTextMCML("时间到了，你没找到我，啦啦~~"), 1, true);
								-- deselect object
								System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
								System.App.Commands.Call("File.MCMLWindowFrame", {
									url = "script/apps/Aries/NPCs/FollowPets/30201_LoliCat_dialog_answer.html", 
									app_key = MyCompany.Aries.app.app_key, 
									name = "NPC_Dialog", 
									isShowTitleBar = false,
									DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
									style = CommonCtrl.WindowFrame.ContainerStyle,
									zorder = 2,
									allowDrag = false,
									directPosition = true,
									align = "_ctb",
									x = 0,
									y = 22,
									width = 900,
									height = 230,
								});
							end
						end
					end
				end,
			end_callback = nil,
			stage1_time = 1000,
			stage1_callback = function()
					local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
					if(cat and cat:IsValid() == true) then
						-- set new position
						headon_speech.Speek(cat.name, "", 0);
						cat:SetVisible(false);
						memory.RevisibleGameTime = ParaGlobal.GetGameTime() + 10000;
						if(memory.bornPos) then
							cat:SetPosition(memory.bornPos[1], memory.bornPos[2], memory.bornPos[3]);
						end
					end
				end,
			stage2_time = nil,
			stage2_callback = nil,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function LoliCat.PreDialog()
	local memory = NPCAIMemory.GetMemory(30201);
	local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
	if(cat and cat:IsValid() == true) then
		-- 10104: FollowPetXML
		if(hasGSItem(10104)) then
			---- user the dialog to show the following text
			--headon_speech.Speek(cat.name, headon_speech.GetBoldTextMCML("我是萝莉猫，最喜欢玩藏猫猫，可是我只跟家里没有猫的哈奇玩儿～"), 3, true);
			return true;
		else
			if(memory.startedHiding == nil) then
				if(memory.lockcatCount) then
					return false;
				end
				local catChar = cat:ToCharacter();
				catChar:Stop();
				-- say: 我是萝莉猫，我们来玩藏猫猫吧，喵～ and start hiding
				return true;
			else
				if(memory.isCaught) then
					return true;
				else
					return false;
				end
			end
		end
	end
	return false;
end 

local hiding_Positions = {
	{ 20205.55078125, 3.5, 19698.16015625 },
	{ 20222.98828125, 3.4999856948853, 19710.76171875 },
	{ 20222.904296875, 3.4999895095825, 19733.005859375 },
	{ 20212.369140625, 3.4946413040161, 19736.025390625 },
	{ 20194.017578125, 3.4999980926514, 19744.48046875 },
	{ 20208.136719, 3.493654, 19680.875000, },
};

local hiding_Facings = {
	-1.13880610466,
	-2.7268214225769,
	2.4222111701965,
	1.3135290145874,
	0.82566505670547,
	1.7630157470703,
};

function LoliCat.RespawnCat()
	local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
	if(cat and cat:IsValid() == true) then
		local dx, dy, dz = cat:GetPosition();
		local respawnIndex = 1;
		while(true) do
			local r = math.random(0, 600);
			if(r <= 100) then
				respawnIndex = 1;
			elseif(r <= 200) then
				respawnIndex = 2;
			elseif(r <= 300) then
				respawnIndex = 3;
			elseif(r <= 400) then
				respawnIndex = 4;
			elseif(r <= 500) then
				respawnIndex = 5;
			elseif(r <= 600) then
				respawnIndex = 6;
			end
			
			if(math.abs(dx - hiding_Positions[respawnIndex][1]) > 0.1 and math.abs(dz - hiding_Positions[respawnIndex][3]) > 0.1) then
				break;
			end
		end
		
        local catChar = cat:ToCharacter();
        catChar:Stop();
        
        ---- play stealth sound
		--ParaAudio.PlayStatic3DSound("Stealth", "LoliCat_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
		local name = "Audio/Haqi/Stealth.wav";
		MyCompany.Aries.Scene.PlayGameSound(name);
		
        -- reposition the cat with effect
		local params = {
			asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
			binding_obj_name = cat.name,
			start_position = nil,
			duration_time = 1400,
			force_name = nil,
			begin_callback = function() end,
			end_callback = nil,
			stage1_time = 1000,
			stage1_callback = function()
					local cat = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30201);
					if(cat and cat:IsValid() == true) then
						-- deselect object and set new position
						System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
						cat:SetPosition(hiding_Positions[respawnIndex][1], hiding_Positions[respawnIndex][2], hiding_Positions[respawnIndex][3]);
						cat:SetFacing(hiding_Facings[respawnIndex]);
						headon_speech.Speek(cat.name, "", 0);
					end
				end,
			stage2_time = nil,
			stage2_callback = nil,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end