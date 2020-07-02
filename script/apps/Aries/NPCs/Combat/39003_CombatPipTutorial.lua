--[[
Title: CombatPipTutorial
Author(s): WangTian
Company: ParaEnging Co. & Taomee Inc.
Date: 2010/9/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial.lua
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Quest/main.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/ArrowPointer.lua");
NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Areas/BattleChatArea.lua");

local BattleChatArea = commonlib.gettable("MyCompany.Aries.Combat.UI.BattleChatArea");
local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");

local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

local ArrowPointer = commonlib.gettable("MyCompany.Aries.Desktop.GUIHelper.ArrowPointer");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

--local dragon_position = {19758.01171875, 3.6933343410492, 20012.16796875};
local dragon_position = {19758.01171875, -103.6933343410492, 20012.16796875};
local foster_position = {19758.01171875, -10000, 20012.16796875};
local dragon_facing = 1.9785141944885;
local user_position = {19752.802734375, 3.6932513713837, 20007.62890625};
local user_facing = -0.32623481750488;
local arena_position = {19753.158203125, 4.9713535308838, 19986.009765625};
local arena_position_str = "19753.15,4.97,19986.00";

local mob1_position = {19768.861328125, 3.7994797229767, 19989.6796875};
local mob1_facing = -2.170608997345;

local mob2_position = {20030.490234375, 0.80533516407013, 19695.6953125};
local mob2_facing = 2.0867621898651;

local init_camera_setting = {9.1744527816772,0.039396848529577,-0.32623481750488};

local mob1_name = "蓝色噬灵鼠";
local mob2_name = "红色噬灵鼠";
local mob_asset = "character/v5/10mobs/HaqiTown/GreenDevouringRat/GreenDevouringRat.x";
local mob_asset_2 = "character/v5/10mobs/HaqiTown/RedDevouringRat/RedDevouringRat.x";
local mob_id_base = 51000;
local mob_level = 1;
local mob_scale = 1;

local user_nid = System.App.profiles.ProfileManager.GetNID();

local arena_id = 2001;

local current_hp = MsgHandler.GetCurrentHP();
local max_hp = MsgHandler.GetMaxHP();

local function GetArenaValue(mob1_hp, mob2_hp, user_hp, mob1_pips, mob2_pips, user_pips)
	return arena_id..",pve,"..arena_position_str..",1{[true,"..(mob_id_base+1)..",5,"..mob1_name..",fire,"..mob_asset..","..mob_scale..","..mob1_hp..",600,"..mob_level..",0,0#####][true,"..(mob_id_base+2)..",6,"..mob2_name..",fire,"..mob_asset_2..","..mob_scale..","..mob2_hp..",600,"..mob_level..",0,0#####]}{[false,"..user_nid..",1,life,"..user_hp..",300,1,0,0####][][][]}{0,0,0,0,0,0,0,0,}{0,0,0,0,0,0,0,0,}{}{}{}";
end

local empty_arena_value = arena_id..",pve,"..arena_position_str..",1{[true,"..(mob_id_base+1)..",5,"..mob1_name..",fire,"..mob_asset..","..mob_scale..",0,600,"..mob_level..",0,0#####]}{[][][][]}{0,0,0,0,0,}{0,0,0,0,0,}{}{}{}";
local init_arena_value = arena_id..",pve,"..arena_position_str..",0{[true,"..(mob_id_base+1)..",5,"..mob1_name..",fire,"..mob_asset..","..mob_scale..",600,600,"..mob_level..",0,0#####]}{[false,"..user_nid..",1,life,"..current_hp..","..max_hp..",1,0,0####][][][]}{1,0,0,0,1,}{0,0,0,0,0,}{}{}{}";


local pre_round1_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 0);
local mid_round1_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 0);
local post_round1_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 0);

local pre_round2_arena_value = GetArenaValue(600, 0, current_hp, 2, 2, 0);
local mid_round2_arena_value = GetArenaValue(380, 0, current_hp, 2, 0, 0);
local post_round2_arena_value = GetArenaValue(380, 0, current_hp, 2, 0, 0);

local pre_round3_arena_value = GetArenaValue(380, 0, current_hp, 3, 1, 1);
local mid_round3_arena_value = GetArenaValue(380, 0, current_hp, 3, 1, 1);
local post_round3_arena_value = GetArenaValue(380, 600, current_hp, 3, 1, 1);

local pre_round4_arena_value = GetArenaValue(120, 600, current_hp, 0, 0, 0);
local mid_round4_arena_value = GetArenaValue(0, 280, current_hp, 0, 0, 0);
local post_round4_arena_value = GetArenaValue(0, 280, current_hp, 0, 0, 0);

local pre_round5_arena_value = GetArenaValue(0, 280, current_hp, 0, 0, 0);
local mid_round5_arena_value = GetArenaValue(0, 0, current_hp, 0, 0, 0);
local post_round5_arena_value = GetArenaValue(0, 0, current_hp, 0, 0, 0);

local stage = -1;

local callback_finished = nil;

-- CombatPipTutorial.main
-- main entrance of the tutorial line
function CombatPipTutorial.main(callback)
	
	AudioEngine.CreateGet("Area_SunnyBeach"):play();

	---- start UI animation framework.
	--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	--UIAnimManager.Init();
	--ArrowPointer.Init();
	--NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	--MyCompany.Aries.Desktop.EXPArea.Init();
	--NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
	--MyCompany.Aries.Desktop.HPMyPlayerArea.Init();

	-- follow the user
	local ItemManager = System.Item.ItemManager;
	local item = ItemManager.GetMyMountPetItem();
    if(item and item.guid > 0) then
		if(item.clientdata ~= "mount") then
			item:MountMe();
		end
	end

	-- keep callback reference
	callback_finished = callback;

	-- hide all desktop areas
	MyCompany.Aries.Desktop.HideAllAreas();
	-- show exp and hp bar
	NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	MyCompany.Aries.Desktop.EXPArea.Show(false);
	NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
	MyCompany.Aries.Desktop.HPMyPlayerArea.Show(false);
	
	-- init dragon npc
	local params = {
		position = dragon_position,
		assetfile_char = "character/v5/01human/Dragon/Dragon.x",
		facing = dragon_facing,
		scaling = 3.5,
		isdummy = true,
	};
	NPC.CreateNPCCharacter(39002, params);
--
	---- init dragon npc
	--local params = {
		--position = foster_position,
		--assetfile_char = "character/v5/01human/CaptainFoster/CaptainFoster.x",
		--facing = dragon_facing,
		--scaling = 3,
		--isdummy = true,
	--};
	--NPC.CreateNPCCharacter(39003, params);
	
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	local player
	if(Pet.GetRealPlayer) then
		player = Pet.GetRealPlayer();
	else
		player = ParaScene.GetPlayer();
	end

	-- set init user position and facing
	player:SetPosition(user_position[1], user_position[2], user_position[3]);
	player:SetFacing(user_facing);

	-- NOTE 2011/12/13: very strange bug that will cause the old ccs implamentation is loaded again
	NPL.load("(gl)script/apps/Aries/Pet/main.lua", true);

	System.Item.ItemManager.RefreshMyself();

	-- block user input
	ParaScene.GetAttributeObject():SetField("BlockInput", false);
	ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	
	CombatPipTutorial.main_cont();
end

function CombatPipTutorial.main_cont()
	
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	local player
	if(Pet.GetRealPlayer) then
		player = Pet.GetRealPlayer();
	else
		player = ParaScene.GetPlayer();
	end

	-- set init user position and facing
	player:SetPosition(user_position[1], user_position[2], user_position[3]);
	player:SetFacing(user_facing);

	ParaCamera.SetLookAtPos(user_position[1], user_position[2] + 2, user_position[3])
	
	-- set init camera position
	local att = ParaCamera.GetAttributeObject();
	att:SetField("CameraObjectDistance", init_camera_setting[1]);
	att:SetField("CameraLiftupAngle", init_camera_setting[2]);
	att:SetField("CameraRotY", init_camera_setting[3]);
	
	---- init dragon npc
	--local params = {
		--position = mob1_position,
		--assetfile_char = mob_asset,
		--facing = mob1_facing,
		--scaling = 1,
		--isdummy = true,
	--};
	--NPC.CreateNPCCharacter(30563, params);

	-- init state machine
	stage = 0;
	
	--stage = 18;
	--MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, init_arena_value);
	
	ParaScene.GetAttributeObject():SetField("BlockInput", true);
	ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	
	-- start
	CombatPipTutorial.Start();
end

-- start the tutorial line
function CombatPipTutorial.Start()
	-- show the dialog
	--CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html");
	NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	MyCompany.Aries.Desktop.EXPArea.Show(false);
	MyCompany.Aries.Desktop.EXPArea.LockShow();
	-- lock user input
	ParaScene.GetAttributeObject():SetField("BlockInput", true);
	ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	-- start process
	CombatPipTutorial.ProcessNextStage();
end

function CombatPipTutorial.Restart()
	-- wait till 3 seconds to proceed next step
	UIAnimManager.PlayCustomAnimation(300, function(elapsedTime)
		if(elapsedTime == 300) then
			stage = 0;
			CombatPipTutorial.Start();
		end
	end);
end

-- finish the tutorial line
function CombatPipTutorial.Finish()
	stage = 0;
	NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	MyCompany.Aries.Desktop.EXPArea.UnlockShow();
	ParaScene.GetAttributeObject():SetField("BlockInput", false);
	ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	
	AudioEngine.CreateGet("Area_SunnyBeach"):stop();

	-- reset the scene music
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	Scene.lastBGMusic = nil;

	-- show all desktop areas
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, empty_arena_value);

	if(callback_finished) then
		callback_finished();
		callback_finished = nil;
	end
end

-- is in combat tutorial
function CombatPipTutorial.IsInTutorial()
	return (stage >= 0);
end

-- get stage
function CombatPipTutorial.GetStage()
	return stage;
end

-- CombatPipTutorial.ProcessNextStage
-- on each stage finish proceed to the next stage
-- NOTE: it passes all params to the stage handler
-- NOTE: each stage handles all assets need cleaned or created
function CombatPipTutorial.ProcessNextStage(...)
	stage = stage + 1;

	if(CombatPipTutorial["Handler_Stage"..stage]) then
		CombatPipTutorial["Handler_Stage"..stage](...)
	else
		-- finish if not tutorial stage is available
		CombatPipTutorial.Finish();
	end
end

function CombatPipTutorial.ShowTip(url)
	-- show the dialog
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		name = "Tutorial_Tip", 
		app_key = (MyCompany.Aries.app or MyCompany.Taurus.app).app_key, 
		isShowTitleBar = false,
		--refresh = true,
		refreshEvenSameURLIfFrameExist = true,
		allowDrag = false,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 100,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -450,					
			y = 30,
			width = 900,
			height = 230,
					
		DestroyOnClose = true,
		cancelShowAnimation = true,
	});
end

function CombatPipTutorial.ShowDialog(url)
	-- show the dialog
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		name = "Tutorial_Dialog", 
		app_key = (MyCompany.Aries.app or MyCompany.Taurus.app).app_key, 
		isShowTitleBar = false,
		--refresh = true,
		refreshEvenSameURLIfFrameExist = true,
		allowDrag = false,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		directPosition = true,
			align = "_ctb",
			x = 0,
			y = 22,
			width = 900,
			height = 230,
					
		DestroyOnClose = true,
		cancelShowAnimation = true,
	});
end

function CombatPipTutorial.HideDialog()
	System.App.Commands.Call("File.MCMLWindowFrame", {name="Tutorial_Dialog", 
			app_key = MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end

-- handler stage 0
function CombatPipTutorial.Handler_Stage0(...)
	-- show the dialog
	-- wait till 3 seconds to proceed next step
	--UIAnimManager.PlayCustomAnimation(50, function(elapsedTime)
		--if(elapsedTime == 50) then
			--CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?npc_id=30563&start_state=6");
		--end
	--end);
end

-- handler stage 1: init fight and show HP potion intro dialog
function CombatPipTutorial.Handler_Stage1(...)
	
	--ParaScene.GetAttributeObject():SetField("BlockInput", false);
	--ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, init_arena_value);

	CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?npc_id=39002");
	
	
	NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	MyCompany.Aries.Desktop.EXPArea.Show(false);
	NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
	MyCompany.Aries.Desktop.HPMyPlayerArea.Show(false);
	MyCompany.Aries.Desktop.HPMyPlayerArea.SetMode("tutorial");

	-- wait till 3 seconds to proceed next step
	UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
		if(elapsedTime == 1000) then
			-- show the HP potion pointer
			NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
			MyCompany.Aries.Desktop.HPMyPlayerArea.Show(true);
			NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
			MyCompany.Aries.Desktop.EXPArea.Show(false);
		end
	end);
end

-- handler stage 3: show the round 1 card picker and tip
function CombatPipTutorial.Handler_Stage2(...)
	-- card picker handler
	MsgHandler.OnShowPick(1, "pve", 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 1)..";", "1+false+0+Life_SingleAttack_Level2", nil, "", "", "", nil, function()
		-- wait till 0.5 seconds to proceed next step
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime == 500) then
				-- hide all arrows
				ArrowPointer.HideAllArrows();
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			end
		end);
		-- to stop the network traffic
		return false;
	end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round1_arena_value);
	--CombatPipTutorial.ShowTip("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=8");
end

-- handler stage 4: show the round 1 card picker arrow
function CombatPipTutorial.Handler_Stage3(...)
	CombatPipTutorial.ProcessNextStage();
	--ArrowPointer.ShowArrow(9842, 2, "_ct", -342, -170, 64, 64);
	---- wait till 2 seconds to hide the arrow
	--UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		--if(elapsedTime == 2000) then
			---- hide arrow
			--ArrowPointer.HideArrow(9842);
		--end
	--end);
end

function CombatPipTutorial.ShowPipPointer()
	-- pip pointer
	local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
	local npc_id = ObjectManager.GetPipSlot_NPC_ID(arena_id, 1, 1);
	local name;
	local x, y, z;
	local binding_obj = NPC.GetNpcCharacterFromIDAndInstance(npc_id);
	if(binding_obj and binding_obj:IsValid() == true) then
		x, y, z = binding_obj:GetPosition();
		name = binding_obj.name;
	end
	if(name) then
		-- pip effect
		local params = {
			asset_file = "character/common/tutorial_pointer/tutorial_pointer.x",
			binding_obj_name = name,
			start_position = {x, y, z},
			duration_time = 999999999,
			scale = 5,
			force_name = "Turorial_PipPointer",
			begin_callback = function() 
			end,
			end_callback = function() 
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
	
	-- caster circle
	local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
	local npc_id = ObjectManager.GetSlot_NPC_ID(arena_id, 1);
	local name;
	local x, y, z;
	local binding_obj = NPC.GetNpcCharacterFromIDAndInstance(npc_id);
	if(binding_obj and binding_obj:IsValid() == true) then
		x, y, z = binding_obj:GetPosition();
		name = binding_obj.name;
		y = y - 0.2;
	end
	if(name) then
		-- pip effect
		local params = {
			asset_file = "character/v5/09effect/Combat_Common/TargetPicker/CasterCircle/CasterCircle.x",
			--binding_obj_name = name,
			start_position = {x, y, z},
			duration_time = 999999999,
			scale = 1,
			force_name = "Turorial_CasterCircle",
			begin_callback = function() 
			end,
			end_callback = function() 
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end

function CombatPipTutorial.ShowPowerPipPointer()
	-- pip pointer
	local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
	local npc_id = ObjectManager.GetPipSlot_NPC_ID(arena_id, 1, 2);
	local name;
	local x, y, z;
	local binding_obj = NPC.GetNpcCharacterFromIDAndInstance(npc_id);
	if(binding_obj and binding_obj:IsValid() == true) then
		x, y, z = binding_obj:GetPosition();
		name = binding_obj.name;
	end
	if(name) then
		-- pip effect
		local params = {
			asset_file = "character/common/tutorial_pointer/tutorial_pointer.x",
			binding_obj_name = name,
			start_position = {x, y, z},
			duration_time = 999999999,
			scale = 5,
			force_name = "Turorial_PowerPipPointer",
			begin_callback = function() 
			end,
			end_callback = function() 
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end

function CombatPipTutorial.HidePipPointer()
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.DestroyEffect("Turorial_PipPointer");
	EffectManager.DestroyEffect("Turorial_CasterCircle");
end

function CombatPipTutorial.HidePowerPipPointer()
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.DestroyEffect("Turorial_PowerPipPointer");
end

-- handler stage 5: play round 1
function CombatPipTutorial.Handler_Stage4(...)
	local value = "1?"..user_nid..",?";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round1_arena_value,
		"movearrow:"..arena_id.."+1+1",
		"pass:"..arena_id..",1,false,"..user_nid,
		"update_arena:arena_"..arena_id.."+"..mid_round1_arena_value,
		"movearrow:"..arena_id.."+1+5",
		"pass:"..arena_id..",5,true,"..(mob_id_base + 1),
		"update_arena:arena_"..arena_id.."+"..post_round1_arena_value,
	};
	local _, seq;
	for _, seq in ipairs(sequence) do
		value = value.."<"..seq..">";
	end
	
	CombatPipTutorial.HideDialog();

	MsgHandler.OnPlayTurn(value, function()
		--ArrowPointer.ShowArrow(9841, 2, "_lb", 14, -290, 64, 64);
		CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=6");
		-- process next stage
		CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
		-- to stop the network traffic
		return false;
	end);
end

-- handler stage 2: hide the HP potion pointer
function CombatPipTutorial.Handler_Stage5(...)
	-- hide arrow
	--ArrowPointer.HideArrow(9841);
	CombatPipTutorial.ProcessNextStage();
	---- wait till 0.5 seconds to proceed next step
	--UIAnimManager.PlayCustomAnimation(50, function(elapsedTime)
		--if(elapsedTime == 50) then
			---- process next stage
			--CombatPipTutorial.ProcessNextStage();
		--end
	--end);
end

-- handler stage 6: show the round 2 card picker and tip
function CombatPipTutorial.Handler_Stage6(...)
	-- card picker handler
	MsgHandler.OnShowPick(2, "pve", 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 1)..";", "1+true+0+Life_SingleAttack_Level2", nil, "", "", "", function()
		-- wait till 0.5 seconds to proceed next step
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime == 500) then
				CombatPipTutorial.HideDialog();
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			end
		end);
		-- to stop the network traffic
		return false;
	end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round2_arena_value);
	--CombatPipTutorial.ShowTip("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=9");
end

-- handler stage 7: show the round 2 card picker arrow
function CombatPipTutorial.Handler_Stage7(...)
	CombatPipTutorial.ProcessNextStage();
	--ArrowPointer.ShowArrow(9842, 2, "_ct", -342, -170, 64, 64);
	---- wait till 2 seconds to hide the arrow
	--UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		--if(elapsedTime == 2000) then
			---- hide arrow
			--ArrowPointer.HideArrow(9842);
		--end
	--end);
end

-- handler stage 8: play round 2
function CombatPipTutorial.Handler_Stage8(...)
	local value = "2?"..user_nid..",?";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round2_arena_value,
		"movearrow:"..arena_id.."+1+1",
		"Life_SingleAttack_Level2:Life_SingleAttack_Level2,"..arena_id..",1,false,"..user_nid..",1,true,"..(mob_id_base + 1)..",5,220,0########",
		"update_arena:arena_"..arena_id.."+"..mid_round2_arena_value,
		"movearrow:"..arena_id.."+1+5",
		"pass:"..arena_id..",5,true,"..(mob_id_base + 1),
		"update_arena:arena_"..arena_id.."+"..post_round2_arena_value,
	};
	local _, seq;
	for _, seq in ipairs(sequence) do
		value = value.."<"..seq..">";
	end
	
	MsgHandler.OnPlayTurn(value, function()
		-- process next stage
		CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
		-- to stop the network traffic
		return false;
	end);
end

-- handler stage 9: show the round 3 card picker and tip
function CombatPipTutorial.Handler_Stage9(...)
	---- card picker handler
	--MsgHandler.OnShowPick(3, "pve", 0, false, tostring(user_nid), tostring(mob_id_base + 1), "1+true+0+Life_SingleHeal_ForNonLife_Level2", nil, "", "", "", function()
		---- wait till 0.5 seconds to proceed next step
		--UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			--if(elapsedTime == 500) then
				---- process next stage
				--CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			--end
		--end);
		---- to stop the network traffic
		--return false;
	--end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round3_arena_value);
	CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=14");
end

-- handler stage 10: show the round 3 card picker arrow
function CombatPipTutorial.Handler_Stage10(...)
	ArrowPointer.ShowArrow(9842, 2, "_ct", -342, -170, 64, 64);
	---- wait till 2 seconds to hide the arrow
	--UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		--if(elapsedTime == 2000) then
			---- hide arrow
			--ArrowPointer.HideArrow(9842);
		--end
	--end);
end

-- handler stage 11: play round 3
function CombatPipTutorial.Handler_Stage11(...)
	local value = "3?"..user_nid..",?";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round3_arena_value,
		"movearrow:"..arena_id.."+1+1",
		"Life_SingleHeal_ForNonLife_Level2:Life_SingleHeal_ForNonLife_Level2,"..arena_id..",1,false,"..user_nid..",1,false,"..user_nid..",1,400,0########",
		"update_arena:arena_"..arena_id.."+"..mid_round3_arena_value,
		"movearrow:"..arena_id.."+1+5",
		"fizzle:"..arena_id..",5,true,"..(mob_id_base + 1)..",5,false,"..user_nid..",1,ice",
		"speak:"..arena_id..",true,"..(mob_id_base + 1).."[额…该死的，关键时刻发招失败了！大哥，大哥，快，快来帮帮我！]";
		"update_arena:arena_"..arena_id.."+"..post_round3_arena_value,
	};
	local _, seq;
	for _, seq in ipairs(sequence) do
		value = value.."<"..seq..">";
	end
	
	MsgHandler.OnPlayTurn(value, function()
		UIAnimManager.PlayCustomAnimation(3000, function(elapsedTime)
			if(elapsedTime == 3000) then
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			end
		end);
		-- to stop the network traffic
		return false;
	end);
end

-- handler stage 12: show the round 4 card picker and tip
function CombatPipTutorial.Handler_Stage12(...)
	-- card picker handler
	MsgHandler.OnShowPick(4, "pve", 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 1)..";", "1+true+0+Fire_AreaAttack_Level4", nil, "", "", "", function()
		-- wait till 0.5 seconds to proceed next step
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime == 500) then
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			end
		end);
		-- to stop the network traffic
		return false;
	end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round4_arena_value);
	CombatPipTutorial.ShowTip("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=11");
end

-- handler stage 13: show the round 4 card picker arrow
function CombatPipTutorial.Handler_Stage13(...)
	ArrowPointer.ShowArrow(9842, 2, "_ct", -342, -170, 64, 64);
	---- wait till 2 seconds to hide the arrow
	--UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		--if(elapsedTime == 2000) then
			---- hide arrow
			--ArrowPointer.HideArrow(9842);
		--end
	--end);
end

-- handler stage 14: play round 4
function CombatPipTutorial.Handler_Stage14(...)
	local value = "4?"..user_nid..",?";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round4_arena_value,
		"movearrow:"..arena_id.."+1+1",
		"Fire_AreaAttack_Level4:Fire_AreaAttack_Level4,"..arena_id..",1,false,"..user_nid.."+++(true,"..(mob_id_base + 1)..",5,320######)(true,"..(mob_id_base + 2)..",5,320######)",
		"dead:"..arena_id..",5,true,"..(mob_id_base + 1),
		"update_arena:arena_"..arena_id.."+"..mid_round4_arena_value,
		"movearrow:"..arena_id.."+1+6",
		"speak:"..arena_id..",true,"..(mob_id_base + 2).."[我的老弟啊，我要为你报仇！]";
		"Storm_SingleAttack_Level1:Storm_SingleAttack_Level1,"..arena_id..",6,true,"..(mob_id_base + 2)..",6,false,"..user_nid..",1,120,0########",
		"update_arena:arena_"..arena_id.."+"..post_round4_arena_value,
	};
	local _, seq;
	for _, seq in ipairs(sequence) do
		value = value.."<"..seq..">";
	end
	
	MsgHandler.OnPlayTurn(value, function()
		-- process next stage
		CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
		-- to stop the network traffic
		return false;
	end);
end

-- handler stage 15: show the round 5 card picker and tip
function CombatPipTutorial.Handler_Stage15(...)
	-- card picker handler
	MsgHandler.OnShowPick(5, "pve", 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 2)..";", "1+true+0+Death_SingleAttackWithLifeTap_Level4", nil, "", "", "", function()
		-- wait till 0.5 seconds to proceed next step
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime == 500) then
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			end
		end);
		-- to stop the network traffic
		return false;
	end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round5_arena_value);
	CombatPipTutorial.ShowTip("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=12");
end

-- handler stage 16: show the round 5 card picker arrow
function CombatPipTutorial.Handler_Stage16(...)
	ArrowPointer.ShowArrow(9842, 2, "_ct", -342, -170, 64, 64);
	---- wait till 2 seconds to hide the arrow
	--UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		--if(elapsedTime == 2000) then
			---- hide arrow
			--ArrowPointer.HideArrow(9842);
		--end
	--end);
end

-- handler stage 17: play round 5
function CombatPipTutorial.Handler_Stage17(...)
	local value = "5?"..user_nid..",?";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round5_arena_value,
		"movearrow:"..arena_id.."+1+1",
		"Death_SingleAttackWithLifeTap_Level4:Death_SingleAttackWithLifeTap_Level4,"..arena_id..",1,false,"..user_nid..",1,true,"..(mob_id_base + 2)..",6,300,150########",
		"speak:"..arena_id..",true,"..(mob_id_base + 2).."[哼，别以为我们就这么轻易能被打败，我们的黑暗精神与黑暗势力同在！]";
		"dead:"..arena_id..",6,true,"..(mob_id_base + 2),
		"update_arena:arena_"..arena_id.."+"..mid_round5_arena_value,
		"update_arena:arena_"..arena_id.."+"..post_round5_arena_value,
	};
	local _, seq;
	for _, seq in ipairs(sequence) do
		value = value.."<"..seq..">";
	end
	
	MsgHandler.OnPlayTurn(value, function()
		-- process next stage
		CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
		-- to stop the network traffic
		return false;
	end);
end

-- finish the combat
function CombatPipTutorial.Handler_Stage18(...)
	-- wait till 2 seconds to hide the arrow
	UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
		if(elapsedTime == 500) then
			-- hide arrow
			MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, empty_arena_value);
			-- process next stage
			CombatPipTutorial.ProcessNextStage();
		end
	end);

end

-- finish master congrats
function CombatPipTutorial.Handler_Stage19(...)
	
	-- hide all desktop areas
	MyCompany.Aries.Desktop.HideAllAreas();
	
	NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
	MyCompany.Aries.Desktop.HPMyPlayerArea.Show(true);

	-- lock user input
	ParaScene.GetAttributeObject():SetField("BlockInput", true);
	ParaCamera.GetAttributeObject():SetField("BlockInput", true);

	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	local player
	if(Pet.GetRealPlayer) then
		player = Pet.GetRealPlayer();
	else
		player = ParaScene.GetPlayer();
	end
	-- set init user position and facing
	player:SetPosition(user_position[1], user_position[2], user_position[3]);
	player:SetFacing(user_facing);
	
	-- set init camera position
	local att = ParaCamera.GetAttributeObject();
	att:SetField("CameraObjectDistance", init_camera_setting[1]);
	att:SetField("CameraLiftupAngle", init_camera_setting[2]);
	att:SetField("CameraRotY", init_camera_setting[3]);

	CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=13");
end

-- intro letter and every essentials
function CombatPipTutorial.Handler_Stage20(...)
	UIAnimManager.PlayCustomAnimation(50, function(elapsedTime)
		if(elapsedTime == 50) then
			CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=15");
		end
	end);
end

-- show exp bar
function CombatPipTutorial.Handler_Stage21(...)
	local params = {
		url = "script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.kids.html", 
		name = "OnPickSchoolOfSpell", 
		isShowTitleBar = false,
		app_key = MyCompany.Aries.app.app_key, 
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = -1,
		allowDrag = false,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	--if(params._page) then
		--params._page.OnClose = function()
			----stats.spell_class = MyCompany.Aries.Tutorial.PickSchoolOfSpell.SelectedSchoolID;
			----Goto("OnFinishedPickingSpell");
			----MyCompany.Aries.Quest.NPCs.CombatPipTutorial.SelectedSchoolID
            ----MyCompany.Aries.Quest.NPCs.CombatPipTutorial.ProcessNextStage();
            ----_guihelper.MessageBox(""..tostring(MyCompany.Aries.Tutorial.PickSchoolOfSpell.SelectedSchoolID));
		--end;
	--end
end

-- show exp bar
function CombatPipTutorial.Handler_Stage22(...)
	System.App.Commands.Call("File.MCMLWindowFrame", {name="OnPickSchoolOfSpell", 
			app_key = MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});

	UIAnimManager.PlayCustomAnimation(50, function(elapsedTime)
		if(elapsedTime == 50) then
			NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
			MyCompany.Aries.Desktop.EXPArea.UnlockShow();
			MyCompany.Aries.Desktop.EXPArea.Show(true);
			ArrowPointer.ShowArrow(9843, 2, "_ctb", 0, -50, 64, 64);
			CombatPipTutorial.ShowTip("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?start_state=16");
		end
	end);
end

-- talk to captain foster
function CombatPipTutorial.Handler_Stage23(...)
	ArrowPointer.HideArrow(9843);
	UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		if(elapsedTime == 2000) then
			CombatPipTutorial.ShowDialog("script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial_dialog.html?npc_id=39003&start_state=17");
		end
	end);
end