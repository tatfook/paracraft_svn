--[[
Title: scene main
Author(s): WangTian, LiXizhi
Date: 2009/10/17
Desc: scene loading, teleporting, background music, weather system, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
Scene.StopGameBGMusic()
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/TooltipHelper.lua");
NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");

-- create class
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local HomeLandGateway = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandGateway");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");					
local Player = commonlib.gettable("MyCompany.Aries.Player");


NPL.load("(gl)script/apps/Aries/Scene/TerrainRegionProvider.lua");
local TerrainRegionProvider = commonlib.gettable("MyCompany.Aries.TerrainRegionProvider");
local RegionSoundMapping = commonlib.gettable("MyCompany.Aries.RegionSoundMapping");

-- invoked at MyCompany.Aries.OnActivateDesktop()
function Scene.Init()
end

-- on world open
function Scene.OnWorldLoad()
	Scene.LastKey = nil;
	Scene.LastLabel = nil;
	-- hook into region radar
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnGlobalRegionRadar") then
				Scene.OnGlobalRegionRadar(msg);
			end
		end, 
		hookName = "OfficialWorld_OnGlobalRegionRadar", appName = "Aries", wndName = "RegionRadar"});
	-- hook into OnMapTeleport
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnMapTeleport") then
				Scene.OnMapTeleport(msg);
			end
		end, 
		hookName = "OfficialWorld_OnMapTeleport", appName = "Aries", wndName = "map"});


	if(System.options.version == "teen")then
		local worldName = WorldManager:GetCurrentWorld().name;
		TerrainRegionProvider.EnableIfExist(worldName);
		TerrainRegionProvider.Reset();
		Scene.currentBgSound = -1;
		Scene.currentAmbSound = -1;

		TerrainRegionProvider.onBgSoundRegionChanged = Scene.OnBgSoundRegionChanged;
		TerrainRegionProvider.onAmbSoundRegionChanged = Scene.OnAmbSoundRegonChanged;
	end
end

-- callback when player region changes. 
-- @param msg: msg.args = {key}
function Scene.OnGlobalRegionRadar(msg)
	if(not HomeLandGateway.IsInMyHomeland or System.options.mc) then
		return
	end
	if(msg.args) then
		if(msg.args.key == "none" and Scene.LastKey == nil) then
			Scene.LastKey = msg.args.key;
						
			if(HomeLandGateway.IsInMyHomeland()) then
				Scene.ShowRegionLabel("我的家园", "240 226 43");
				-- play background music for region
				Scene.PlayRegionBGMusic("homeland");
			elseif(HomeLandGateway.IsInOtherHomeland()) then
				-- NOTE: leio, i manually get the nid from the table
				local nid = HomeLandGateway.nid;
				if(nid) then
					ProfileManager.GetUserInfo(nid, "EnterHomelandZoneNotification", function(msg)
						local userinfo = ProfileManager.GetUserInfoInMemory(nid);
						if(userinfo) then
							Scene.ShowRegionLabel(userinfo.nickname.."的家园", "240 226 43");
						end
					end);
				end
				-- play background music for region
				Scene.PlayRegionBGMusic("homeland");
			else
				-- play the world's default bg music, if "none" is defined. 
				local world_info = WorldManager:GetCurrentWorld();
				Scene.ShowRegionLabel(world_info.world_title);
				if(world_info.bg_music_name) then
					Scene.PlayRegionBGMusic(world_info.bg_music_name);
				end
			end
		elseif(msg.args.key == "unopen_square") then
			Scene.ShowRegionLabel("该区域目前未开放", "224 127 69");
		elseif(Scene.LastKey ~= msg.args.key) then
			Scene.LastKey = msg.args.key;
			Scene.LastLabel = msg.args.label;

			-- NOTE 2011/11/9: some indoor buildings are beyond the original terrain region,
			--				   we don't play region background music change and region lable change for user height above 9000
			local isindoor = false;
			local myself = MyCompany.Aries.Pet.GetUserCharacterObj();
			if(myself and myself:IsValid() == true) then
				local px, py, pz = myself:GetPosition();
				if((py > 9000 and py < 11000) or py > 21000) then
					isindoor = true;
				end
			end
			if(not isindoor) then
				-- show region label
				if(msg.args.label and msg.args.label ~= "none")then
					Scene.ShowRegionLabel(msg.args.label);
				end
				-- play the world's default bg music, if "none" is defined. 
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info.bg_music_name) then
					-- play background music from world config
					Scene.PlayRegionBGMusic(world_info.bg_music_name);
				else
					-- play background music for region
					Scene.PlayRegionBGMusic(msg.args.key);
				end
			end
		end
	end
end

-- processing map teleporting
function Scene.OnMapTeleport(msg)
	if(not msg.bIgnoreCombatCheck and Player.IsInCombat()) then
		LOG.std("", "system", "aries", "can not do map teleport because we are involved in a combat.")
		return 
	end

	local CameraObjectDistance, CameraLiftupAngle, CameraRotY = msg.camera[1], msg.camera[2], msg.camera[3]

	local duration_time = 800;

	-- play on teleport effect
	if(System.options.version == "teen") then
		NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
		local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
		local spell_file = "config/Aries/Spells/Action_OnTeleport.xml";
		local current_playing_id = ParaGlobal.GenerateUniqueID();

		local user_char = MyCompany.Aries.Player.GetPlayer();
		if(user_char and user_char:IsValid()) then
			SpellCast.EntitySpellCast(0, user_char, 1, user_char, 1, spell_file, nil, nil, nil, nil, nil, function()
			end, nil, true, current_playing_id, true);
		end
	end
	
	local params = {
		asset_file = "character/v5/09effect/Move/MoveStart.x",
		binding_obj_name = MyCompany.Aries.Player.GetPlayer().name,
		start_position = nil,
		duration_time = 800,
		force_name = "TeleportPrepare"..ParaGlobal.GenerateUniqueID(),
		begin_callback = function() 
		end,
		end_callback = function()
			if(Player.IsInCombat()) then
				return;
			end
						
			local world_info = WorldManager:GetCurrentWorld();
			if(not msg.bForceSkipTeleportCheck and (not world_info.can_save_location and not world_info.local_map_url)) then
				-- if no teleport or map is allowed, we will teleport to default world.
				WorldManager:SetTeleportBackPosition(msg.position[1], msg.position[2], msg.position[3]);
				WorldManager:SetTeleportBackCamera(CameraObjectDistance, CameraLiftupAngle, CameraRotY);
				WorldManager:TeleportBackCheckSave();
			else
				if(msg.bCheckBagWeight and Player.IsBagTooHeavy() and System.options.version ~= "teen") then
					-- Note: uncomment to enable bag size checking
					local VIP = commonlib.gettable("MyCompany.Aries.VIP");
					if(VIP.IsVIP())then
						_guihelper.MessageBox("你背包中的物品太多了，快去打开背包，出售一些装备或收集品吧！");
					else
						_guihelper.MessageBox([[你背包物品已达到容量上限，快开通魔法星<span style="color:#ff0000">(魔法星玩家背包容量翻倍)</span>或者出售掉一些物品和装备吧！]]);
					end
					return
				end
				-- auto toggle fly if in air
				if(Player.IsFlying() == true) then
					Player.ToggleFly();
				end
				-- deselect object on map teleport
				System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
				-- set the position and camera setting
				local player = MyCompany.Aries.Player.GetPlayer();
				player:SetPosition(msg.position[1], msg.position[2], msg.position[3]);
				-- NOTE: for position in the air and above terrain elevation plus 1 meters
				local elev = ParaTerrain.GetElevation(msg.position[1], msg.position[3]);
				local height;
				if(System.options.version == "kids")then
					height = 1;
				else
					height = 4;
				end
				if(not ((elev + height) < msg.position[2])) then
					player:SnapToTerrainSurface(0);
				end
				local facing = msg.position[4];
				if(facing) then
					player:SetFacing(facing);
				elseif(CameraRotY) then
					player:SetFacing(CameraRotY);
				end
				
				player:SetField("normal", {0,1,0}); -- force normal to be upward
				player:ToCharacter():Stop();
				local att = ParaCamera.GetAttributeObject();
				if(MyCompany.Aries.AutoCameraController:GetStyleName() == "3d") then
					--att:SetField("CameraObjectDistance", CameraObjectDistance);
					--att:SetField("CameraLiftupAngle", CameraLiftupAngle);
				end
				att:SetField("CameraRotY", CameraRotY);

				if(System.options.version == "kids") then
					local params = {
						asset_file = "character/v5/09effect/Move/MoveEnd.x",
						binding_obj_name = MyCompany.Aries.Player.GetPlayer().name,
						start_position = nil,
						duration_time = 800,
						force_name = "TeleportFinish"..ParaGlobal.GenerateUniqueID(),
						begin_callback = msg.begin_callback,
						end_callback = msg.end_callback,
					};
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.CreateEffect(params);
				else
					if(msg.begin_callback) then
						msg.begin_callback();
					end
					if(msg.end_callback) then
						msg.end_callback();
					end
				end
				-- auto refresh myself
				System.Item.ItemManager.RefreshMyself();

				--[[ disabled mouse tutorial	
				local ItemManager = System.Item.ItemManager;
				local hasGSItem = ItemManager.IfOwnGSItem;
				local bHas, guid = hasGSItem(50042);
				-- 50042_DoneMouseTutorial
				if(bHas) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						local clientdata = item.clientdata;
						if(clientdata == "3") then
							-- skip the mouse tutorial
							return;
						elseif(clientdata == "") then
							ItemManager.SetClientData(item.guid, "1", function(msg) end);
						elseif(clientdata == "1") then
							ItemManager.SetClientData(item.guid, "2", function(msg) end);
						elseif(clientdata == "2") then
							ItemManager.SetClientData(item.guid, "3", function(msg) end);
						else
							ItemManager.SetClientData(item.guid, "1", function(msg) end);
						end
					end
				end
				-- show the mouse tutorial in town teleport
				Scene.ShowRightMouseTutorial()
				]]
			end
			if(msg.finish_callback) then
				msg.finish_callback();
			end
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
				
	-- hide the local map
	NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
	MyCompany.Aries.Desktop.LocalMap.Hide();
end

-- on world closing
function Scene.OnWorldClosing()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OfficialWorld_OnGlobalRegionRadar", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OfficialWorld_OnMapTeleport", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end

-- if the user is in official world
function Scene.IsInOfficialWorld()
	local world_info = WorldManager:GetCurrentWorld()
	return world_info.is_default;
end

function Scene.CreateHomelandAwayPortal()
	-- create the portal
	local obj_params = {};
	obj_params.name = "teleport-portal:1000";
	obj_params.x = 19957.716796875;
	obj_params.y = 29.073292160034;
	obj_params.z = 20264.740234375;
	obj_params.AssetFile = "character/common/dummy/elf_size/elf_size.x";
	obj_params.scaling = 2;
	obj_params.IsCharacter = true;
	-- skip saving to history for recording or undo.
	System.SendMessage_obj({
		type = System.msg.OBJ_CreateObject, 
		obj_params = obj_params, 
		SkipHistory = true,
	});
	portal = ParaScene.GetCharacter("teleport-portal:1000");
	-- set onload and onframemove scripts
	local att = portal:GetAttributeObject();
	portal:SetSentientField(MyCompany.Aries.SentientGroupIDs["Player"], true);
	att:SetField("On_FrameMove", [[;MyCompany.Aries.Scene.OnFrameMove_HomelandAwayPortal();]]);
	
	local params = {
		asset_file = "character/v5/09effect/TransmittalDoor/TransmittalDoor.x",
		binding_obj_name = nil,
		start_position = {19957.716796875, 29.173292160034, 20264.740234375},
		scale = 1,
		duration_time = nil,
		period = 200,
		begin_callback = function() 
		end,
		elapsedtime_callback = function(elapsedTime, obj) 
			if(HomeLandGateway.IsInMyHomeland() and HomeLandGateway.IsEditing()) then
				obj:SetVisible(false);
				return;
			else
				obj:SetVisible(true);
			end
		end,
		end_callback = function()
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
	
	--local params = {
		--asset_file = "character/v5/temp/Effect/GreaterHeal_Low_Base.x",
		--binding_obj_name = nil,
		--start_position = {19957.716796875, 29.073292160034, 20264.740234375},
		--duration_time = nil,
		--period = 200,
		--begin_callback = function() 
		--end,
		--elapsedtime_callback = function(elapsedTime, obj) 
			--local HomeLandGateway = System.App.HomeLand.HomeLandGateway;
			--if(HomeLandGateway.IsInMyHomeland() and HomeLandGateway.IsEditing()) then
				--obj:SetVisible(false);
				--return;
			--else
				--obj:SetVisible(true);
			--end
		--end,
		--end_callback = function()
		--end,
	--};
	--local EffectManager = MyCompany.Aries.EffectManager;
	--EffectManager.CreateEffect(params);
end

local lastHomelandPortalDist;

-- onframemove of the teleport back portal of homeland
function Scene.OnFrameMove_HomelandAwayPortal()
	local portal = ParaScene.GetObject(sensor_name);
	if(portal:IsValid() == true) then
		if(HomeLandGateway.IsInMyHomeland() and HomeLandGateway.IsEditing()) then
			portal:SetVisible(false);
			return;
		else
			portal:SetVisible(true);
		end
		portal:SetDynamicField("name", "");
		local player = MyCompany.Aries.Player.GetPlayer();
		if(string.find(player.name, "teleport-")) then
			return;
		end
		if(player and player:IsValid() == true) then
			local dist = portal:DistanceTo(player);
			if(lastHomelandPortalDist and lastHomelandPortalDist >= 2.5 and dist < 2.5) then
				local params = {
					asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
					binding_obj_name = MyCompany.Aries.Player.GetPlayer().name,
					start_position = nil,
					duration_time = 800,
					begin_callback = function() 
						local portal = ParaScene.GetCharacter("teleport-portal:1000");
						-- reset onload and onframemove scripts
						local att = portal:GetAttributeObject();
						att:SetField("On_FrameMove", "");
					end,
					end_callback = function()
						WorldManager:TeleportBackCheckSave();
					end,
				};
				local EffectManager = MyCompany.Aries.EffectManager;
				EffectManager.CreateEffect(params);
			end
			lastHomelandPortalDist = dist;
		end
	end
end

-- show the region label
function Scene.ShowRegionLabel(label, color)
	if(label) then
		BroadcastHelper.PushLabel({
				id = "GameRegion",
				label = label,
				color = color or "255 210 71",
				shadow = true,
				bold = true,
				font_size = 16,
				scaling = 1.1,
				priority = 2,
				background = "Texture/Aries/Common/gradient_white_32bits.png",
				background_color = "#1f3243",
				});
	else
		BroadcastHelper.Clear("GameRegion");
	end
end

-- show the right mouse tutorial
function Scene.ShowRightMouseTutorial()
	local _this = ParaUI.GetUIObject("RightClickMouse_Teleport");
	if(_this and _this:IsValid() == true) then
		return;
	end
	local _, __, res_width, res_height = ParaUI.GetUIObject("root"):GetAbsPosition();
	
    local margin_mouse_left = res_width - 1020 + 670;
    local margin_mouse_top = res_height - 680 + 470 - 128;
    local _this = ParaUI.CreateUIObject("container", "RightClickMouse_Teleport", 
        "_lt", margin_mouse_left, margin_mouse_top, 256, 256);
	_this.background = "Texture/Aries/Quest/TutorialMouse_RightClick_32bits.png";
	_this.enabled = false;
	_this:AttachToRoot();
	
    local fileName = "script/UIAnimation/CommonBounce.lua.table";
	UIAnimManager.PlayUIAnimationSequence(_this, fileName, "ShakeLR", true);
	
    local _LR = ParaUI.CreateUIObject("container", "LeftRightMouse", 
        "_lt", 64, -80, 128, 64);
	_LR.background = "Texture/Aries/Quest/TutorialMouse_LeftRight_32bits.png";
	_this:AddChild(_LR);
	
	local _tip_cont = ParaUI.CreateUIObject("container", "LeftRightMouseTip", "_lt", -80, -150, 400, 50);
	_tip_cont.background = "Texture/Aries/Quest/Dialog_BG_32bits.png: 31 31 31 31";
	_tip_cont.enabled = false;
	_this:AddChild(_tip_cont);
	local _text = ParaUI.CreateUIObject("button", "text", "_lt", 0, 0, 400, 50);
	_text.text = "按住鼠标右键，同时移动鼠标，可以看清周围的环境。";
	_text.background = "";
	_tip_cont:AddChild(_text);
	_guihelper.SetFontColor(_text, "#d58302");
	
	local lastCameraRotY = nil;
	local accum_CameraRotY = 0;
	
	UIAnimManager.PlayCustomAnimation(90000000, function(elapsedTime)
        local att = ParaCamera.GetAttributeObject();
        local CameraRotY = att:GetField("CameraRotY", 0);
        if(lastCameraRotY == nil) then
            lastCameraRotY = CameraRotY;
        else
            accum_CameraRotY = accum_CameraRotY + math.abs(CameraRotY - lastCameraRotY);
            lastCameraRotY = CameraRotY;
            if(accum_CameraRotY > 0.5 and not ParaUI.IsMousePressed(1)) then
                ParaUI.Destroy("RightClickMouse_Teleport");
                UIAnimManager.StopCustomAnimation("Mouse_Detect_Teleport");
            end
        end
	    --commonlib.echo(att:GetField("CameraObjectDistance", CameraObjectDistance));
	end, "Mouse_Detect_Teleport");
end

local weather_table = {
	[1] = {
		[8] = "snow",
		[9] = "sunny",
		[10] = "sunny",
		[11] = "snow",
		[12] = "sunny",
		[13] = "snow",
		[14] = "sunny",
		[15] = "sunny",
		[16] = "snow",
		[17] = "snow",
		[18] = "sunny",
		[19] = "sunny",
		[20] = "snow",
		[21] = "snow",
		[22] = "sunny",
		[23] = "sunny",
		[24] = "snow",
		[25] = "snow",
		[26] = "sunny",
		[27] = "sunny",
		[28] = "snow",
	},
	[2] = {
		[8] = "snow",
		[9] = "sunny",
		[10] = "sunny",
		[11] = "snow",
		[12] = "sunny",
		[13] = "snow",
		[14] = "sunny",
		[15] = "sunny",
		[16] = "snow",
		[17] = "snow",
		[18] = "sunny",
		[19] = "sunny",
		[20] = "snow",
		[21] = "snow",
		[22] = "sunny",
		[23] = "sunny",
		[24] = "snow",
		[25] = "snow",
		[26] = "sunny",
		[27] = "sunny",
		[28] = "snow",
	},
	[3] = {
		[1] = "sunny",
		[2] = "snow",
		[3] = "sunny",
		[4] = "snow",
		[5] = "sunny",
		[6] = "snow",
		[7] = "sunny",
		[8] = "snow",
		[9] = "sunny",
		[10] = "snow",
		[11] = "sunny",
		[12] = "sunny",
		[13] = "sunny",
		[14] = "cloudy",
		[15] = "cloudy",
		[16] = "sunny",
		[17] = "cloudy",
		[18] = "cloudy",
		[19] = "sunny",
		[20] = "cloudy",
		[21] = "sunny",
		[22] = "sunny",
		[23] = "sunny",
		[24] = "cloudy",
		[25] = "sunny",
		[26] = "cloudy",
		[27] = "cloudy",
		[28] = "sunny",
		[29] = "sunny",
		[30] = "cloudy",
		[31] = "sunny",
	},
	[4] = {
		[1] = "sunny",
		[2] = "cloudy",
		[3] = "sunny",
		[4] = "cloudy",
		[5] = "cloudy",
		[6] = "sunny",
		[7] = "sunny",
		[8] = "cloudy",
		[9] = "sunny",
		[10] = "cloudy",
		[11] = "sunny",
		[12] = "sunny",
		[13] = "cloudy",
		[14] = "cloudy",
		[15] = "sunny",
		[16] = "cloudy",
		[17] = "sunny",
		[18] = "sunny",
		[19] = "cloudy",
		[20] = "sunny",
		[21] = "cloudy",
		[22] = "cloudy",
		[23] = "sunny",
		[24] = "cloudy",
		[25] = "cloudy",
		[26] = "sunny",
		[27] = "sunny",
		[28] = "cloudy",
		[29] = "sunny",
		[30] = "cloudy",
	},
	[5] = {
		[1] = "sunny",
		[2] = "sunny",
		[3] = "cloudy",
		[4] = "sunny",
		[5] = "cloudy",
		[6] = "cloudy",
		[7] = "sunny",
		[8] = "sunny",
		[9] = "cloudy",
		[10] = "sunny",
		[11] = "sunny",
		[12] = "cloudy",
		[13] = "cloudy",
		[14] = "sunny",
		[15] = "cloudy",
		[16] = "sunny",
		[17] = "cloudy",
		[18] = "sunny",
		[19] = "sunny",
		[20] = "cloudy",
		[21] = "cloudy",
		[22] = "sunny",
		[23] = "cloudy",
		[24] = "sunny",
		[25] = "sunny",
		[26] = "cloudy",
		[27] = "cloudy",
		[28] = "sunny",
		[29] = "cloudy",
		[30] = "sunny",
		[31] = "sunny",
	},
	[6] = {
		[1] = "cloudy",
		[2] = "cloudy",
		[3] = "sunny",
		[4] = "cloudy",
		[5] = "sunny",
		[6] = "sunny",
		[7] = "cloudy",
		[8] = "sunny",
		[9] = "cloudy",
		[10] = "cloudy",
		[11] = "sunny",
		[12] = "sunny",
		[13] = "cloudy",
		[14] = "sunny",
		[15] = "cloudy",
		[16] = "cloudy",
		[17] = "sunny",
		[18] = "sunny",
		[19] = "cloudy",
		[20] = "sunny",
		[21] = "cloudy",
		[22] = "cloudy",
		[23] = "sunny",
		[24] = "cloudy",
		[25] = "cloudy",
		[26] = "sunny",
		[27] = "sunny",
		[28] = "cloudy",
		[29] = "sunny",
		[30] = "cloudy",
	},
	[7] = {
		[1] = "sunny",
		[2] = "sunny",
		[3] = "cloudy",
		[4] = "sunny",
		[5] = "cloudy",
		[6] = "cloudy",
		[7] = "sunny",
		[8] = "sunny",
		[9] = "cloudy",
		[10] = "sunny",
		[11] = "sunny",
		[12] = "cloudy",
		[13] = "cloudy",
		[14] = "sunny",
		[15] = "cloudy",
		[16] = "sunny",
		[17] = "cloudy",
		[18] = "sunny",
		[19] = "sunny",
		[20] = "cloudy",
		[21] = "cloudy",
		[22] = "sunny",
		[23] = "cloudy",
		[24] = "sunny",
		[25] = "sunny",
		[26] = "cloudy",
		[27] = "cloudy",
		[28] = "sunny",
		[29] = "cloudy",
		[30] = "sunny",
		[31] = "sunny",
	},
	[12] = {
		[8] = "snow",
		[9] = "sunny",
		[10] = "sunny",
		[11] = "snow",
		[12] = "sunny",
		[13] = "snow",
		[14] = "sunny",
		[15] = "sunny",
		[16] = "snow",
		[17] = "snow",
		[18] = "sunny",
		[19] = "sunny",
		[20] = "snow",
		[21] = "snow",
		[22] = "sunny",
		[23] = "snow",
		[24] = "snow",
		[25] = "snow",
		[26] = "snow",
		[27] = "sunny",
		[28] = "snow",
	},
};

--------------- date and time ---------------
-- get the weather by month and day
-- @param month: if nil today
-- @param day: if nil today
-- @return: "sunny" | "snow"
function Scene.GetWeather(month, day)
	if(not month or not day) then
		local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
		local y, m, d = string.match(today, "^(%d+)%-(%d+)%-(%d+)$");
		if(y and m and d) then
			y = tonumber(y);
			m = tonumber(m);
			d = tonumber(d);
			month = m;
			day = d;
		end
	end
	local weather = "sunny"; --default weather sunny
	if(weather_table[month]) then
		if(weather_table[month][day]) then
			weather = weather_table[month][day];
		end
	else
		-- 3571: the 500th prime number
		-- 1046527: Carol primes
		-- 27644437: Bell number primes
		local i = math.mod(math.mod((month * 1046527 + day * 27644437), 3571), 2)
		if(i <= 0) then
			weather = "sunny";
		else
			weather = "cloudy";
		end	
	end
	return weather;
end

--------------- date and time ---------------

-- NOTE: date and time format:   "yyyy-MM-dd HH:mm:ss"
-- we assume that the server date will never change in one auth time
-- @return: date in format yyyy-MM-dd 
function Scene.GetServerDate()
	if(System.User.LastAuthServerTime) then
		return string.match(System.User.LastAuthServerTime, "^([%-%d%S]+)");
	end
end

-- we assume that the server date will never change in one auth time
-- get the next date
-- @param date: date
-- @return: date in format yyyy-MM-dd 
function Scene.GetNextDate(date)
	local today = date;
	if(today) then
		local t_y, t_m, t_d = string.match(today, "^(%d+)%-(%d+)%-(%d+)$");
		if(t_y and t_m and t_d) then
			t_y = tonumber(t_y);
			t_m = tonumber(t_m);
			t_d = tonumber(t_d);
			if(t_m == 1 or t_m == 3 or t_m == 5 or t_m == 7 or t_m == 8 or t_m == 10) then
				if(t_d == 31) then
					t_m = t_m + 1;
					t_d = 1;
				else
					t_d = t_d + 1;
				end
			elseif(t_m == 12) then
				if(t_d == 31) then
					t_y = t_y + 1;
					t_m = 1;
					t_d = 1;
				else
					t_d = t_d + 1;
				end
			elseif(t_m == 4 or t_m == 6 or t_m == 9 or t_m == 11) then
				if(t_d == 30) then
					t_m = t_m + 1;
					t_d = 1;
				else
					t_d = t_d + 1;
				end
			elseif(t_m == 2) then
				if(math.mod(t_y, 4) == 0) then
					if(t_d == 29) then
						t_m = t_m + 1;
						t_d = 1;
					else
						t_d = t_d + 1;
					end
				else
					if(t_d == 28) then
						t_m = t_m + 1;
						t_d = 1;
					else
						t_d = t_d + 1;
					end
				end
			end
			return string.format("%04d-%02d-%02d", t_y, t_m, t_d);
		end
	end
end

-- get day of week. 
-- @return day of week, 1 is monday, 7 is sunday.
function Scene.GetDayOfWeek()
	local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day = string.match(serverDate, "^(%d+)%-(%d+)%-(%d+)$");
	if(year and month and day) then
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);
		
		return commonlib.timehelp.get_day_of_week(year, month, day)
	end
end

-- NOTE: date and time format:   "yyyy-MM-dd HH:mm:ss"
-- return: LastAuthServerTime elapsed seconds since 00:00   
function Scene.GetLastAuthServerTimeSince0000()
	if(System.User.LastAuthServerTime) then
		local date, hours, minutes, seconds = string.match(System.User.LastAuthServerTime, "^([%-%d]+)%s(%d+):(%d+):(%d+)$");
		if(date and hours and minutes and seconds) then
			hours = tonumber(hours);
			minutes = tonumber(minutes);
			seconds = tonumber(seconds);
		
			return seconds + minutes * 60 + hours * 60 * 60;
		end
	end
end

local last_seconds, last_sTime;
-- @param sTime: in the format of "HH:mm:ss"
local function GetSecondFromTimeStr(sTime)
	if(sTime) then
		if(last_sTime == sTime) then
			return last_seconds;
		end
		local hours, minutes, seconds = string.match(sTime, "^(%d+):(%d+):(%d+)$");
		if(hours and minutes and seconds) then
			hours = tonumber(hours);
			minutes = tonumber(minutes);
			seconds = tonumber(seconds);
			last_sTime = sTime;
			last_seconds = seconds + minutes * 60 + hours * 3600
			return last_seconds;
		end
	end
end

-- NOTE: date and time format:   "yyyy-MM-dd HH:mm:ss"
-- the time is synced with game server every few seconds.
-- return: elapsed seconds since 00:00   
function Scene.GetElapsedSecondsSince0000()
	local seconds = GetSecondFromTimeStr(Scene.GetServerTime())
	if(seconds) then
		return seconds;
	elseif(System.User.LastAuthServerTime) then
		local date, hours, minutes, seconds = string.match(System.User.LastAuthServerTime, "^([%-%d]+)%s(%d+):(%d+):(%d+)$");
		if(date and hours and minutes and seconds) then
			hours = tonumber(hours);
			minutes = tonumber(minutes);
			seconds = tonumber(seconds);
		
			local elapsedSecondsSinceAuth = math.floor((ParaGlobal.timeGetTime() - System.User.LastAuthGameTime) / 1000);
		
			return seconds + minutes * 60 + hours * 60 * 60 + elapsedSecondsSinceAuth;
		end
		-- fall back to client time if no server time is available.
		return GetSecondFromTimeStr(ParaGlobal.GetTimeFormat("HH:mm:ss"))
	end
end

-- the time is local and may be cheated
function Scene.GetElapsedSecondsSinceLogin()
	return  math.floor((ParaGlobal.timeGetTime() - System.User.LastAuthGameTime) / 1000);
end

-- get most recent server time received in normal update in the format of ParaGlobal.GetTimeFormat("HH:mm:ss")
function Scene.GetServerTime()
	return Map3DSystem.GSL_client:GetServerTime();
end

-- get the current server time, if no server is available, use the local system time. 
-- @return seconds, min, hour, day, month, year
function Scene.GetServerDateTime()
	local time = Scene.GetServerTime() or ParaGlobal.GetTimeFormat("HH:mm:ss");
	local hour, min, seconds = time:match("(%d+)%D(%d+)%D(%d+)");
	hour = tonumber(hour);
	min = tonumber(min);
	seconds = tonumber(seconds);

	local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day  = today:match("(%d+)%D(%d+)%D(%d+)");
	day = tonumber(day);
	month = tonumber(month);
	year = tonumber(year);

	return seconds, min, hour, day, month, year;
end

--------------- server objects ---------------

Scene.ServerObjects = {
	--["patch_version"] = "5_28", 
	--["patch_version"] = "6_11", 
	["patch_version"] = "6_25", 
};

-- fetch all server objects during user login process
-- NOTE: this GetServerObjects is different from the GSL_client GetServerObject.
function Scene.GetAllServerObjects(callbackFunc, cache_policy, timeout, timeout_callback)
	local msg = {keys = ""};
	paraworld.WorldServers.GetServerObject(msg, "GetAllServerObjects", function(msg)
		if(msg and not msg.errorcode) then
			local _, pair;
			for _, pair in ipairs(msg.list) do
				Scene.ServerObjects[pair.key] = pair.value;
			end
			callbackFunc({issuccess = true});
		else
			callbackFunc({issuccess = false});
		end
	end, nil, timeout, timeout_callback);
end

-- get server object value
function Scene.GetServerObjectValue(key)
	if(key) then
		return Scene.ServerObjects[key];
	end
end

function Scene.SetServerObjectValue(key, value)
	if(key) then
		Scene.ServerObjects[key] = value;
	end
end

-- check if the nid is GM account
function Scene.IsGMAccount(nid)
	if (nid) then
		local gm_nids = Scene.GetServerObjectValue("GMAccounts");
		local gm_nid;
		if(type(gm_nids) == "string") then
			local gm_nids_ = {}
			for gm_nid in string.gmatch(gm_nids, "[^,]+") do
				gm_nid = tonumber(gm_nid);
				if(gm_nid) then
					gm_nids_[gm_nid] = true;
				end
			end
			Scene.SetServerObjectValue("GMAccounts", gm_nids_);
			gm_nids = gm_nids_;
		end
		if(gm_nids) then
			return gm_nids[tonumber(nid)];
		end
	end
	return false;
end

--------------- region background music ---------------
local bg_sound_maps = {
	Region_MagicForest = "Area_Forest",
	Region_LifeSpring = "Area_Forest",
	Region_DragonForest = "Area_Forest",
	Region_WildForest = "Area_Forest",
	Region_SnowArea1 = "Area_Snow",
	Region_SquirrelValley = "Area_Snow",
	Region_SnowArea3 = "Area_Snow",
	Region_FireCavern = "Area_Town", -- "Area_FireCavern",
	Region_Desert = "Area_FireCavern",
	Region_Bee = "Area_Town",
	Region_AquaHorse = "Area_Town",
	Region_Carnival = "Area_Town",
	Region_TownSquare = "Area_Christmas", -- "Area_Christmas" "Area_NewYear"
	Region_TriumphSquare = "Area_Town",
	Region_JumpJumpFarm = "Area_Farm",
	Region_JumpField = "Area_Farm",
	Region_WatermelonField = "Area_Farm",
	Region_CommonField = "Area_Farm",
	Region_StarStar = "Area_Carnival",
	Region_SunnyBeach = "Area_SunnyBeach",
	Region_SeaLine = "Area_SunnyBeach",
	Region_SunLine = "Area_SunnyBeach",
	Region_MagmaCave = "Area_MagmaCave",
	-- for homelands
	homeland = nil,
}

-- change the current BG music to a given one
-- this function is used in pairs with RestoreBGMusic().
-- @param music_name: such as "Combat_Drumbeat"
function Scene.ReplaceBGMusic(music_name)
	if(music_name and music_name~=Scene.curReplaceMusic and music_name ~= Scene.lastBGMusic) then
		
		if(Scene.curReplaceMusic) then
			AudioEngine.CreateGet(Scene.curReplaceMusic):stop();
			Scene.curReplaceMusic = nil;
		end
		if(Scene.lastBGMusic) then
			AudioEngine.CreateGet(Scene.lastBGMusic):stop();
		end
		if(music_name) then
			Scene.curReplaceMusic = music_name;
			if(System.options.EnableBackgroundMusic)then
				AudioEngine.CreateGet(music_name):play();
			end
		end
	end
end

-- restore the current BG music to previous one. 
function Scene.RestoreBGMusic()
	if(Scene.curReplaceMusic) then
		AudioEngine.CreateGet(Scene.curReplaceMusic):stop();
		Scene.curReplaceMusic = nil;
	end
	if(Scene.lastBGMusic and System.options.EnableBackgroundMusic) then
		AudioEngine.CreateGet(Scene.lastBGMusic):play();
	end
end


-- @param key: region key. the key name of bg_sound_maps
function Scene.PlayRegionBGMusic(key)
	if(not key or key == "unopen_square" or key == "forbidden" or key == "none") then
		return;
	end
	
	if(System.options.EnableBackgroundMusic ~= true) then
		--return;
	end
	
	local waveFile;
	
	if(key == "homeland") then
		-- for home land
		waveFile = nil;
		--local ran = math.random(0, 300);
		--if(ran <= 100) then
			--waveFile = "Audio/Haqi/MusicBox1.wav";
		--elseif(ran <= 200) then
			--waveFile = "Audio/Haqi/MusicBox2.wav";
		--elseif(ran <= 300) then
			--waveFile = "Audio/Haqi/MusicBox3.wav";
		--end
	else
		-- for public world regions
		waveFile = bg_sound_maps[key] or key;
	end

	-- replacement files
	--if(waveFile == "Area_Town") then
		--waveFile = "Area_NewYear";
	--end
	
	if(Scene.lastBGMusic == waveFile) then
		-- continue with the current one
	else
		-- stop old and start new one. Show I apply a fade in/out music effect here?
		if(Scene.lastBGMusic) then
			AudioEngine.CreateGet(Scene.lastBGMusic):stop();
		end
		if(waveFile and System.options.EnableBackgroundMusic) then
			AudioEngine.CreateGet(waveFile):play();
		end
	end
	Scene.lastBGMusic = waveFile;
	--System.options.EnableBackgroundMusic = true;
end

function Scene.StopRegionBGMusic()
	if(Scene.lastBGMusic) then
		---ParaAudio.StopWaveFile(Scene.lastBGMusic, true);
		AudioEngine.CreateGet(Scene.lastBGMusic):stop();
	end
	--System.options.EnableBackgroundMusic = false;
end

function Scene.ResumeRegionBGMusic()
	if(Scene.lastBGMusic and System.options.EnableBackgroundMusic) then
		AudioEngine.CreateGet(Scene.lastBGMusic):play();
		--ParaAudio.PlayWaveFile(Scene.lastBGMusic, 1000);
	end
	--System.options.EnableBackgroundMusic = true;
end


-- obsoleted function. use StopRegionBGMusic() and ResumeRegionBGMusic()
function Scene.ActiveRegionBGMusic(bActive)
	--System.options.EnableBackgroundMusic = bActive;
	if(bActive == false)then
		Scene.StopRegionBGMusic()
	end
end

--------------- game background music ---------------

function Scene.PlayGameBGMusic(wavefile)
	if(Scene.lastGameMusic) then
		ParaAudio.StopWaveFile(Scene.lastGameMusic, true);
	end
	ParaAudio.PlayWaveFile(wavefile, 1000);
	Scene.lastGameMusic = wavefile;
end

function Scene.StopGameBGMusic()
	if(Scene.lastGameMusic) then
		ParaAudio.StopWaveFile(Scene.lastGameMusic, true);
		Scene.lastGameMusic = nil;
	end
end

--------------- game sound ---------------

function Scene.PlayGameSound(wavefile)
	--ParaAudio.PlayWaveFile(wavefile, 0);
end

--------------- game ambient sound ---------------
function Scene.ReplaceAmbMusic(music_name)
	if(music_name and music_name~=Scene.curReplaceAmbMusic and music_name ~= Scene.lastAmbMusic) then
		
		if(Scene.curReplaceAmbMusic) then
			AudioEngine.CreateGet(Scene.curReplaceAmbMusic):stop();
			Scene.curReplaceAmbMusic = nil;
		end
		if(Scene.lastAmbMusic) then
			AudioEngine.CreateGet(Scene.lastAmbMusic):stop();
		end
		if(music_name) then
			Scene.curReplaceAmbMusic = music_name;
			AudioEngine.CreateGet(music_name):play();
		end
	end
end

-- restore the current BG music to previous one. 
function Scene.RestoreAmbMusic()
	if(Scene.curReplaceAmbMusic) then
		AudioEngine.CreateGet(Scene.curReplaceAmbMusic):stop();
		Scene.curReplaceAmbMusic = nil;
	end
	if(Scene.lastBGAmbMusic) then
		AudioEngine.CreateGet(Scene.lastBGMusic):play();
	end
end

Scene.bActiveRegionAmbMusic = true;

-- @param key: region key. the key name of bg_sound_maps
function Scene.PlayRegionAmbMusic(key)
	if(not key or key == "unopen_square" or key == "forbidden" or key == "none") then
		return;
	end
	if(Scene.bActiveRegionAmbMusic ~= true) then
		return;
	end
		
	local waveFile;
	
	if(key == "homeland") then
		-- for home land
		waveFile = nil;
	else
		waveFile = key;
	end
	
	if(Scene.lastAmbMusic == waveFile) then
		-- continue with the current one
	else
		-- stop old and start new one. Show I apply a fade in/out music effect here?
		if(Scene.lastAmbMusic) then
			AudioEngine.CreateGet(Scene.lastAmbMusic):stop();
		end
		if(waveFile) then
			AudioEngine.CreateGet(waveFile):play();
		end
	end
	Scene.lastAmbMusic = waveFile;
	Scene.bActiveRegionAmbMusic = true;
end

function Scene.StopRegionAmbMusic()
	if(Scene.lastAmbMusic) then
		ParaAudio.StopWaveFile(Scene.lastAmbMusic, true);
	end
	Scene.bActiveRegionAmbMusic = false;
end

function Scene.ResumeRegionAmbMusic()
	if(Scene.lastAmbMusic) then
		ParaAudio.PlayWaveFile(Scene.lastAmbMusic, 1000);
	end
	Scene.bActiveRegionAmbMusic = true;
end

function Scene.ActiveRegionAmbMusic(bActive)
	Scene.bActiveRegionAmbMusic = bActive;
end

-------------teen version sound-----------
Scene.bgSoundCooldown = 0;
Scene.ambSoundCooldown = 0;
Scene.currentBgSound = -1;
Scene.currentAmbSound = -1;
Scene.desiredBgSound = -1;
Scene.desiredAmbSound = -1;
Scene.currentWorldName = nil;
Scene.soundCooldownTime = 4000;
Scene.soundCooldownInterval = 500;
Scene.soundCooldownTimer = nil;
Scene.isCoolingDown = false;

function Scene.OnBgSoundRegionChanged(regionId)
	local self = Scene;
	if(self.desiredBgSound ~= regionId or self.currentBgSound ~= regionId)then
		self.desiredBgSound = regionId;
		if(self.bgSoundCooldown <= 0)then
			self.ChangeBgSound();
		end
	end
end

function Scene.OnAmbSoundRegonChanged(regionId)
	local self = Scene;
	if(self.desiredAmbSound ~= regionId or self.currentAmbSound ~= regionId)then
		self.desiredAmbSound = regionId;
		if(self.ambSoundCooldown <= 0)then
			self.ChangeAmbSound(self.desiredBgSound);
		end
	end
end

function Scene.ChangeBgSound()
	local self = Scene;

	if(self.desiredBgSound == self.currentBgSound)then
		return;
	end

	local worldName = WorldManager:GetCurrentWorld().name;
	local soundName = TerrainRegionProvider.GetBgSoundName(worldName,self.desiredBgSound);
	if(soundName ~= nil)then
		self.PlayRegionBGMusic(soundName);
	end
	self.currentBgSound = self.desiredBgSound;
	self.bgSoundCooldown = self.soundCooldownTime;

	if(self.isCoolingDown == false)then
		self.soundCooldownTimer = self.soundCooldownTimer or commonlib.Timer:new({callbackFunc = Scene.OnCooldownTimer});
		self.soundCooldownTimer:Change(0,self.soundCooldownInterval);
		self.isCoolingDown = true;
	end
end

function Scene.ChangeAmbSound()
	local self = Scene;
	if(self.desiredAmbSound == self.currentAmbSound)then
		return;
	end

	local worldName = WorldManager:GetCurrentWorld().name;
	local soundName = TerrainRegionProvider.GetAmbSoundName(worldName,self.desiredAmbSound);
	
	if(soundName ~= nil)then
		self.PlayRegionAmbMusic(soundName);
	end
	self.desiredAmbSound = self.currentAmbSound
	self.ambSoundCooldown = self.soundCooldownTime;
	if(self.isCoolingDown == false)then
		self.soundCooldownTimer = self.soundCooldownTimer or commonlib.Timer:new({callbackFunc = Scene.OnCooldownTimer});
		self.soundCooldownTimer:Change(0,self.soundCooldownInterval);
		self.isCoolingDown = true;
	end
end

function Scene.OnCooldownTimer()
	local self = Scene;

	if(self.bgSoundCooldown > 0)then
		self.bgSoundCooldown = self.bgSoundCooldown - self.soundCooldownInterval;
		if(self.bgSoundCooldown <= 0)then
			Scene.ChangeBgSound();
		end
	end

	if(self.ambSoundCooldown>0)then
		self.ambSoundCooldown = self.ambSoundCooldown - self.soundCooldownInterval;
		if(self.soundCooldownInterval <= 0)then
			Scene.ChangeAmbSound();
		end
	end

	if(self.bgSoundCooldown <=0  and self.ambSoundCooldown <=0)then
		self.soundCooldownTimer:Change();
		self.isCoolingDown = false;
	end
end
