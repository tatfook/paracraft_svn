--[[
Title: CombatPipTutorial
Author(s): WangTian, LiXizhi
Company: ParaEnging Co.
Date: 2011/8/22
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatPipTutorial.teen.lua");
MyCompany.Aries.Quest.NPCs.CombatPipTutorial.main(function()
		NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		-- teleport back from instance world
		WorldManager:TeleportBack();
end);
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
local dragon_position = {20054.53, 1.99, 20009.66};
local foster_position = {19758.01171875, -10000, 20012.16796875};
local dragon_facing = -1.6;
local dragon_scaling = 0.6;
local user_position = {20053.64, 2.05, 20017.69};
local user_facing = 1.6;
local arena_position = {19753.158203125, 4.9713535308838, 19986.009765625};
local arena_position_str = "20055.33,2.37,20041.18";

local mob1_position = {19768.861328125, 3.7994797229767, 19989.6796875};
local mob1_facing = -2.170608997345;

local mob2_position = {20030.490234375, 0.80533516407013, 19695.6953125};
local mob2_facing = 2.0867621898651;

local init_camera_setting = {9.1744527816772,0.039396848529577,-0.32623481750488};

local mob1_name = "水咕噜";
local mob2_name = "红色噬灵鼠";
--local mob_asset = "character/v5/10mobs/HaqiTown/GreenDevouringRat/GreenDevouringRat.x";
local mob_asset = "character/v6/10mobs/01RainbowIsland/IceBubble/IceBubble.x";
local mob_asset_2 = "character/v5/10mobs/HaqiTown/RedDevouringRat/RedDevouringRat.x";
local mob_id_base = 51000;
local mob_level = 1;
local mob_scale = 1;

local user_nid = System.App.profiles.ProfileManager.GetNID();

local arena_id = 2001;

local current_hp = MsgHandler.GetCurrentHP();
local max_hp = MsgHandler.GetMaxHP();

local function GetArenaValue(mob1_hp, mob2_hp, user_hp, mob1_pips, mob2_pips, user_pips)
	local user_hp = 300;
	local r = arena_id..",pve,"..arena_position_str..",1{[true,"..(mob_id_base+1)..",5,"..mob1_name..",0,fire,"..mob_asset..","..mob_scale..",,"..mob1_hp..",600,"..mob_level..","..mob1_pips..",0#####]}{[false,"..user_nid..",1,life,0,"..user_hp..",300,1,"..user_pips..",0####][][][][][][][]}{"..user_pips..",0,0,0,"..mob1_pips..",0,0,0,}{0,0,0,0,0,0,0,0,}{}{}{}{0,0}{}{}{}";
	return r;
end

local empty_arena_value = arena_id..",pve,"..arena_position_str..",1{[true,"..(mob_id_base+1)..",5,"..mob1_name..",0,fire,"..mob_asset..","..mob_scale..",,0,600,"..mob_level..",0,0#####]}{[][][][]}{0,0,0,0,0,}{0,0,0,0,0,}{}{}{}{0,0}{}{}{}";

local init_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 1);

local pre_round1_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 1);
local mid_round1_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 1);
local post_round1_arena_value = GetArenaValue(600, 0, current_hp, 1, 1, 1);

local pre_round2_arena_value = GetArenaValue(600, 0, current_hp, 2, 2, 2);
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

local each_school_2pips_spell = {
	["fire"] = "Fire_SingleAttack_Level3",
	["ice"] = "Ice_SingleAttack_Level2",
	["storm"] = "Storm_SingleAttack_Level2",
	["life"] = "Life_SingleAttack_Level2",
	["death"] = "Death_SingleAttackWithLifeTap_Level2",
};

local myschool_2pips_spell = "Life_SingleAttack_Level2";

-- CombatPipTutorial.main
-- main entrance of the tutorial line
function CombatPipTutorial.main(callback)
	--AudioEngine.CreateGet("Area_SunnyBeach"):play();

	local school = MyCompany.Aries.Combat.GetSchool();
	if(school and school ~= "unknown" and each_school_2pips_spell[school]) then
		myschool_2pips_spell = each_school_2pips_spell[school];
	end

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
	
	
	-- init dragon npc
	local params = {
		position = dragon_position,
		assetfile_char = "character/v6/01human/EnlightenedTutor/EnlightenedTutor_green.x",
		facing = dragon_facing,
		scaling = dragon_scaling,
		isdummy = true,
		main_script = "script/apps/Aries/Login/Tutorial/CombatTutorial.teen.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.CombatTutorial.main_dragon();",
		selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		predialog_function = "MyCompany.Aries.Quest.NPCs.CombatTutorial.PreDialog_dragon",
	};
	NPC.CreateNPCCharacter(39002, params);

	
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

	---- NOTE 2011/12/13: very strange bug that will cause the old ccs implamentation is loaded again
	--NPL.load("(gl)script/apps/Aries/Pet/main.lua", true);

	if(Pet.ClearLastAppliedFullCCSMapping) then
		Pet.ClearLastAppliedFullCCSMapping();
	end

	System.Item.ItemManager.RefreshMyself();

	-- NOTE: some privious sections cause this character invisible
	-- maybe invisible camera
	player:SetVisible(true);
	
	NPL.load("(gl)script/ide/MotionEx/MotionFactory.lua");
	local player_name = "aries_combat_tutorial";
	local MotionFactory = commonlib.gettable("MotionEx.MotionFactory");
	local MotionRender = commonlib.gettable("MotionEx.MotionRender");
	local motion_player = MotionFactory.GetPlayer(player_name)
	
	----循环播放
	--motion_player:AddEventListener("end", function()
		--MotionRender.ForceEnd();
		---- start
		--CombatPipTutorial.main_cont();
	--end,{});
	--MotionFactory.PlayMotionFile(player_name, "config/Aries/Cameras/CombatTutorial_teen.xml");
	
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(39002);
	if(npcChar and npcChar:IsValid()) then
		Map3DSystem.Animation.PlayAnimationFile({144}, npcChar)
	end
	
	-- tricky: replay the tutor speaking animation
	UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
		if(elapsedTime == 500) then
			local npcChar = NPC.GetNpcCharacterFromIDAndInstance(39002);
			if(npcChar and npcChar:IsValid()) then
				Map3DSystem.Animation.PlayAnimationFile({144}, npcChar)
			end
		end
	end);

	NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
	local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
	MotionXmlToTable.PlayCombatMotion("config/Aries/Cameras/CombatTutorial_teen.xml", function()
		
		-- set init camera
		local att = ParaCamera.GetAttributeObject();
		att:SetField("CameraObjectDistance", 15.00);
		att:SetField("CameraLiftupAngle", 0.41);
		att:SetField("CameraRotY", 1.84);

		local npcChar = NPC.GetNpcCharacterFromIDAndInstance(39002);
		if(npcChar and npcChar:IsValid()) then
			Map3DSystem.Animation.PlayAnimationFile({0}, npcChar)
		end

		-- start
		NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatTutorial.teen.lua");
		local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
		CombatTutorial.BeginMovementTraining();
		CombatTutorial.Set_callback_pip_tutorial(CombatPipTutorial.main_cont);
	end);
	
	-- active and resume region BG music
	-- NOTE: MotionXmlToTable.PlayCombatMotion will stop the BG music internal
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	Scene.ResumeRegionBGMusic();

	-- block user input
	ParaScene.GetAttributeObject():SetField("BlockInput", true);
	ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	
	--CombatPipTutorial.main_cont();
end

function CombatPipTutorial.main_cont()
	
	-- stop the scene music
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	Scene.StopRegionBGMusic();
	
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
	--CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html");
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
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local worldinfo = WorldManager:GetCurrentWorld();
	if(worldinfo) then
		local worldname = worldinfo.name;
		if(worldname == "Tutorial" or worldname == "CombatTutorial") then
			return true;
		else
			return false;
		end
	end
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
			align = "_mb",
			x = 0,
			y = 0,
			width = 0,
			height = 135,
					
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
			--CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?npc_id=30563&start_state=6");
		--end
	--end);
end

-- handler stage 1: init fight and show HP potion intro dialog
function CombatPipTutorial.Handler_Stage1(...)
	
	--ParaScene.GetAttributeObject():SetField("BlockInput", false);
	--ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, init_arena_value);

	CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?npc_id=39002");
	
	
	
	NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
	MyCompany.Aries.Desktop.EXPArea.Show(false);
	
	-- wait till 3 seconds to proceed next step
	UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
		if(elapsedTime == 1000) then
			NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
			MyCompany.Aries.Desktop.EXPArea.Show(false);
		end
	end);
end

-- handler stage 3: show the round 1 card picker and tip
function CombatPipTutorial.Handler_Stage2(...)
	-- card picker handler
	MsgHandler.OnShowPick(1, "pve", 0, 0, 0, 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 1)..";", "1+false+0+"..myschool_2pips_spell.."+1", nil, "", "", "", nil, function()
		-- wait till 0.5 seconds to proceed next step
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime == 500) then
				-- hide all arrows
				ArrowPointer.HideAllArrows();
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
				-- stop CurrentPipHelper
				CombatPipTutorial.HideCurrentPipHelper()
			end
		end);
		-- to stop the network traffic
		return false;
	end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round1_arena_value);
	--CombatPipTutorial.ShowTip("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=8");
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

local function FindSymbolUI(_parent)
	local nCount = _parent:GetChildCount();
	-- traverse all children in a container
	-- pay attention the GetChildAt function indexed in C++ form which begins at index 0
	for i = 0, nCount - 1 do
		local _ui = _parent:GetChildAt(i);
		if(_ui.background == "Texture/Aries/Combat/CombatStateTeen/PosIcon4_32bits.png;0 0 64 64") then
			return _ui.id;
		else
			if(_ui.type == "container") then
				return FindSymbolUI(_ui);
			end
		end
	end
end
local timer_CurrentPipHelper;
local timer_CurrentPipHelper_myself_symbol_id;

function CombatPipTutorial.ShowCurrentPipHelper()
	if(not timer_CurrentPipHelper) then
		timer_CurrentPipHelper = commonlib.Timer:new({callbackFunc = function()
			local elapsedTime = ParaGlobal.GetGameTime();
			
			local _clicky = ParaUI.GetUIObject("Turorial_ClickFirstCardHelper_clicky");
			if(_clicky:IsValid() == false) then
				_clicky = ParaUI.CreateUIObject("container", "Turorial_ClickFirstCardHelper_clicky", "_lt", 0, 0, 64, 64);
				_clicky.background = "Texture/Aries/Cursor/clicky.png";
				_clicky.enabled = false;
				_clicky.zorder = 1000;
				_clicky:AttachToRoot();
			end
			_clicky.visible = false;

			if(not timer_CurrentPipHelper_myself_symbol_id) then
				local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Lower");
				if(_this:IsValid() == true) then
					timer_CurrentPipHelper_myself_symbol_id = FindSymbolUI(_this);
				end
			end
			local _symbol = ParaUI.GetUIObject(timer_CurrentPipHelper_myself_symbol_id);
			if(_symbol:IsValid() == true) then
				local abs_x, abs_y = _symbol:GetAbsPosition();
				local frames = math.mod(elapsedTime, 1000);
				local scale = frames / 1000;
				_clicky.scalingx = 0.5 + scale * 1;
				_clicky.scalingy = 0.5 + scale * 1;
				_clicky.visible = true;
				_clicky.translationx = -32 + abs_x + 115;
				_clicky.translationy = -32 + abs_y + 56;
			end
		end});
		timer_CurrentPipHelper:Change(0, 1);
	end
end

function CombatPipTutorial.HideCurrentPipHelper()
	if(timer_CurrentPipHelper) then
		timer_CurrentPipHelper:Change();
		timer_CurrentPipHelper = nil;
		timer_CurrentPipHelper_myself_symbol_id = nil;
		local _clicky = ParaUI.GetUIObject("Turorial_ClickFirstCardHelper_clicky");
		if(_clicky:IsValid() == true) then
			_clicky.visible = false;
		end
	end
end

local Turorial_ClickFirstCardHelper_FullAnimCycleLength = 1500;
local Turorial_ClickFirstCardHelper_MoveCursorLength = 1000;
local ClickPosition_x_from_screen_centor = -330;
local ClickPosition_y_from_screen_centor = -75;
local x_cursor_last, y_cursor_last;

local timer_ClickFirstCardHelper;

function CombatPipTutorial.ShowClickFirstCardHelper()
	CombatPipTutorial.bShowClickFirstCardHelper = true;
	CombatPipTutorial.nStartTimeShowClickFirstCardHelper = ParaGlobal.GetGameTime();
	
	timer_ClickFirstCardHelper = commonlib.Timer:new({callbackFunc = function()
		if(CombatPipTutorial.bShowClickFirstCardHelper) then
			
			local elapsedTime = ParaGlobal.GetGameTime() - CombatPipTutorial.nStartTimeShowClickFirstCardHelper;
			
			local _cursor = ParaUI.GetUIObject("Turorial_ClickFirstCardHelper_cursor");
			if(_cursor:IsValid() == false) then
				_cursor = ParaUI.CreateUIObject("container", "Turorial_ClickFirstCardHelper_cursor", "_lt", -5, 0, 64, 64);
				_cursor.background = "Texture/Aries/Cursor/cursor_big_32bits.png";
				_cursor.enabled = false;
				_cursor.zorder = 1000;
				_cursor:AttachToRoot();
			end
			local _clicky = ParaUI.GetUIObject("Turorial_ClickFirstCardHelper_clicky");
			if(_clicky:IsValid() == false) then
				_clicky = ParaUI.CreateUIObject("container", "Turorial_ClickFirstCardHelper_clicky", "_lt", 0, 0, 64, 64);
				_clicky.background = "Texture/Aries/Cursor/clicky.png";
				_clicky.enabled = false;
				_clicky.zorder = 1000;
				_clicky:AttachToRoot();
			end

			local frames = math.mod(elapsedTime, Turorial_ClickFirstCardHelper_FullAnimCycleLength);
			
			local x_cursor, y_cursor;
			if(not x_cursor_last or not y_cursor_last) then
				x_cursor_last, y_cursor_last = ParaUI.GetMousePosition();
			end
			x_cursor = x_cursor_last;
			y_cursor = y_cursor_last;

			local _, __, x_res, y_res = ParaUI.GetUIObject("root"):GetAbsPosition();

			if(frames <= Turorial_ClickFirstCardHelper_MoveCursorLength) then
				local move_duration = Turorial_ClickFirstCardHelper_MoveCursorLength;
				_cursor.translationx = x_res / 2 + ClickPosition_x_from_screen_centor + (x_cursor - (x_res / 2 + ClickPosition_x_from_screen_centor)) * ((move_duration - frames) * (move_duration - frames)) / (move_duration * move_duration);
				_cursor.translationy = y_res / 2 + ClickPosition_y_from_screen_centor + (y_cursor - (y_res / 2 + ClickPosition_y_from_screen_centor)) * ((move_duration - frames) * (move_duration - frames)) / (move_duration * move_duration);
				_clicky.visible = false;
			else
				_cursor.translationx = x_res / 2 + ClickPosition_x_from_screen_centor;
				_cursor.translationy = y_res / 2 + ClickPosition_y_from_screen_centor;
				_clicky.visible = true;
				_clicky.translationx = -32 + x_res / 2 + ClickPosition_x_from_screen_centor;
				_clicky.translationy = -32 + y_res / 2 + ClickPosition_y_from_screen_centor;
				local scale = (frames - Turorial_ClickFirstCardHelper_MoveCursorLength) / (Turorial_ClickFirstCardHelper_FullAnimCycleLength - Turorial_ClickFirstCardHelper_MoveCursorLength);
				_clicky.scalingx = 0.5 + scale * 2;
				_clicky.scalingy = 0.5 + scale * 2;
				x_cursor_last = nil;
				y_cursor_last = nil;
			end
		else
			--UIAnimManager.StopCustomAnimation("Turorial_ClickFirstCardHelper");
			ParaUI.Destroy("Turorial_ClickFirstCardHelper_cursor");
			ParaUI.Destroy("Turorial_ClickFirstCardHelper_clicky");
			-- stop timer
			timer_ClickFirstCardHelper:Change();
		end
	end});
	timer_ClickFirstCardHelper:Change(0, 1);
end

function CombatPipTutorial.HideClickFirstCardHelper()
	CombatPipTutorial.bShowClickFirstCardHelper = false;
end

-- handler stage 5: play round 1
function CombatPipTutorial.Handler_Stage4(...)
	local value = "1?"..user_nid..",???";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round1_arena_value,
		"movearrow:"..arena_id.."+1+1",
		"pass_tutorial_teen:"..arena_id..",1,false,"..user_nid,
		"update_arena:arena_"..arena_id.."+"..mid_round1_arena_value,
		"movearrow:"..arena_id.."+1+5",
		"pass_tutorial_teen:"..arena_id..",5,true,"..(mob_id_base + 1),
		"update_arena:arena_"..arena_id.."+"..post_round1_arena_value,
	};
	local _, seq;
	for _, seq in ipairs(sequence) do
		value = value.."<"..seq..">";
	end
	
	CombatPipTutorial.HideDialog();

	MsgHandler.OnPlayTurn(value, function()
		--ArrowPointer.ShowArrow(9841, 2, "_lb", 14, -290, 64, 64);
		CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=6");
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
	--CombatPipTutorial.ProcessNextStage();
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round2_arena_value);
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
	MsgHandler.OnShowPick(2, "pve", 1, 0, 0, 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 1)..";", "1+true+0+"..myschool_2pips_spell.."+1", nil, "", "", "", function()
		-- wait till 0.5 seconds to proceed next step
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			if(elapsedTime == 500) then
				CombatPipTutorial.HideDialog();
				-- process next stage
				CombatPipTutorial.ProcessNextStage(); -- continute to stage 5, stage 4 in an immediate process
			end
		end);
		-- stop the pointer anim
		CombatPipTutorial.HideClickFirstCardHelper()
		-- to stop the network traffic
		return false;
	end, nil, function()
		-- callback_after_card_click
		local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
		local npc_id = ObjectManager.GetPipSlot_NPC_ID(arena_id, 1, 1);
		local name;
		local x, y, z;
		local mob_char = NPC.GetNpcCharacterFromIDAndInstance(39001, mob_id_base + 1);
		if(mob_char and mob_char:IsValid() == true) then
			x, y, z = mob_char:GetPosition();
		end
		local screen_pos = {x, y, z, visible, distance};
		ParaScene.GetScreenPosFrom3DPoint(x, y, z, screen_pos);
		local x, y = screen_pos.x, screen_pos.y;
		if(x and y) then
			local _, __, x_res, y_res = ParaUI.GetUIObject("root"):GetAbsPosition();
		
			ClickPosition_x_from_screen_centor = x - x_res / 2;
			ClickPosition_y_from_screen_centor = y - y_res / 2 - 24;
		end
	end);
	MsgHandler.OnArenaNormalUpdate_by_key_value("arena_"..arena_id, pre_round2_arena_value);
	--CombatPipTutorial.ShowTip("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=9");
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
	local value = "2?"..user_nid..",???";
	local sequence = {
		"update_arena:arena_"..arena_id.."+"..pre_round2_arena_value,
		"movearrow:"..arena_id.."+1+1",
		myschool_2pips_spell.."_teen:"..myschool_2pips_spell.."_teen,"..arena_id..",1,false,"..user_nid..",1,true,"..(mob_id_base + 1)..",5,220,110########",
		"update_arena:arena_"..arena_id.."+"..mid_round2_arena_value,
		"movearrow:"..arena_id.."+1+5",
		"pass_tutorial_teen:"..arena_id..",5,true,"..(mob_id_base + 1),
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
	--MsgHandler.OnShowPick(3, "pve", 2, 0, 0, 0, false, tostring(user_nid), tostring(mob_id_base + 1), "1+true+0+Life_SingleHeal_ForNonLife_Level2", nil, "", "", "", function()
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
	CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=14");
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
	local value = "3?"..user_nid..",???";
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
	MsgHandler.OnShowPick(4, "pve", 3, 0, 0, 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 1)..";", "1+true+0+Fire_AreaAttack_Level4+1", nil, "", "", "", function()
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
	CombatPipTutorial.ShowTip("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=11");
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
	local value = "4?"..user_nid..",???";
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
	MsgHandler.OnShowPick(5, "pve", 4, 0, 0, 0, false, "false,"..tostring(user_nid)..";", "true,"..tostring(mob_id_base + 2)..";", "1+true+0+Death_SingleAttackWithLifeTap_Level4+1", nil, "", "", "", function()
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
	CombatPipTutorial.ShowTip("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=12");
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
	local value = "5?"..user_nid..",???";
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

	CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=13");
end

-- intro letter and every essentials
function CombatPipTutorial.Handler_Stage20(...)
	UIAnimManager.PlayCustomAnimation(50, function(elapsedTime)
		if(elapsedTime == 50) then
			CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=15");
		end
	end);
end

-- show exp bar
function CombatPipTutorial.Handler_Stage21(...)
	local params = {
		url = "script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.teen.html", 
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
			CombatPipTutorial.ShowTip("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?start_state=16");
		end
	end);
end

-- talk to captain foster
function CombatPipTutorial.Handler_Stage23(...)
	ArrowPointer.HideArrow(9843);
	UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
		if(elapsedTime == 2000) then
			CombatPipTutorial.ShowDialog("script/apps/Aries/Login/Tutorial/CombatPipTutorial_dialog.teen.html?npc_id=39003&start_state=17");
		end
	end);
end