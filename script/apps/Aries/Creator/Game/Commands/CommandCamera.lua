--[[
Title: Command Camera
Author(s): LiXizhi
Date: 2014/1/22
Desc: slash command 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandCamera.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/Aries/SlashCommand/SlashCommand.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Direction.lua");
local Direction = commonlib.gettable("MyCompany.Aries.Game.Common.Direction")
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local block = commonlib.gettable("MyCompany.Aries.Game.block")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");


Commands["lookat"] = {
	name="lookat", 
	quick_ref="/lookat [@playername] [x y z]", 
	desc=[[look at a given direction or player
Example:
/lookat -1 ~ ~   lookat negative x direction
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		if(cmd_text) then
			local playerEntity, lookat_x, lookat_y, lookat_z, hasInputName;
			playerEntity, cmd_text, hasInputName  = CmdParser.ParsePlayer(cmd_text);
			if(not playerEntity) then
				if(hasInputName) then
					return;
				end
				lookat_x, lookat_y, lookat_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
				if(lookat_x) then
					lookat_x, lookat_y, lookat_z = BlockEngine:real(lookat_x, lookat_y, lookat_z);
					lookat_y =  lookat_y + BlockEngine.half_blocksize;
				end
			else
				lookat_x, lookat_y, lookat_z = playerEntity:GetPosition();
				if(lookat_y ) then
					lookat_y = lookat_y + playerEntity:GetPhysicsHeight();
				end
			end
			if(lookat_x and lookat_y and lookat_z) then
				local player = EntityManager.GetFocus() or EntityManager.GetPlayer();
				if(player) then
					local camx,camy,camz = player:GetPosition();
					camy = camy + player:GetPhysicsHeight();
					local facing = Direction.GetFacingFromCamera(camx,camy,camz, lookat_x,lookat_y,lookat_z)
					player:SetFacing(facing);
					local att = ParaCamera.GetAttributeObject();
					att:SetField("CameraRotY", facing);

					NPL.load("(gl)script/ide/math/vector.lua");
					local vector3d = commonlib.gettable("mathlib.vector3d");
					local v1 = vector3d:new(camx,camy,camz)
					local v2 = vector3d:new(lookat_x,lookat_y,lookat_z)
					local dist = v1:dist(v2);
					if(dist > 0.1) then
						local angle = math.asin((camy - lookat_y) / dist);
						att:SetField("CameraLiftupAngle", angle);
					end
				end
			end
		end
	end,
};

Commands["fov"] = {
	name="fov", 
	quick_ref="/fov [fieldofview:1.04] [animSpeed]", 
	desc=[[change field of view with an animation. default value is 1.04. e.g.
/fov   default field of view
/fov 0.5		zoomin
/fov 0.4 0.01   zoomin with animation
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		if(cmd_text) then
			local target_fov, speed_fov;
			target_fov, cmd_text  = CmdParser.ParseInt(cmd_text);
			target_fov = target_fov or GameLogic.options.normal_fov;

			if(target_fov) then
				speed_fov, cmd_text = CmdParser.ParseInt(cmd_text);

				NPL.load("(gl)script/apps/Aries/Creator/Game/World/CameraController.lua");
				local CameraController = commonlib.gettable("MyCompany.Aries.Game.CameraController")
				CameraController.AnimateFieldOfView(target_fov, speed_fov);
			end
		end
	end,
};

Commands["cameradist"] = {
	name="cameradist", 
	quick_ref="/cameradist [1-20]", 
	desc=[[change the camera to player distance
/cameradist 10   set eye distance to 10
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		if(cmd_text) then
			local dist;
			dist, cmd_text  = CmdParser.ParseInt(cmd_text);
			if(dist) then
				GameLogic.options:SetCameraObjectDistance(dist)
			end
		end
	end,
};

Commands["camerapitch"] = {
	name="camerapitch", 
	quick_ref="/camerapitch [-1.57, 1.57]", 
	desc=[[change the camera lift up angle between [-1.57, 1.57]
/camerapitch 0.5
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		if(cmd_text) then
			local value;
			value, cmd_text  = CmdParser.ParseInt(cmd_text);
			if(value) then
				local att = ParaCamera.GetAttributeObject();
				att:SetField("CameraLiftupAngle", value);
			end
		end
	end,
};

Commands["camerayaw"] = {
	name="camerayaw", 
	quick_ref="/camerayaw [-3.14, 3.14] ", 
	desc=[[change the camera yaw facing between [-3.14, 3.14]
/camerayaw 0
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		if(cmd_text) then
			local value;
			value, cmd_text  = CmdParser.ParseInt(cmd_text);
			if(value) then
				local att = ParaCamera.GetAttributeObject();
				att:SetField("CameraRotY", value);
			end
		end
	end,
};


Commands["panorama"] = {
	name="panorama", 
	quick_ref="/panorama x y z", 
	desc=[[
		create panorama screenshot and save
]], 
	handler = function(cmd_name, cmd_text, cmd_params)
		local x, y, z = CmdParser.ParsePos(cmd_text)
		
		function setPlayerPos(x, y, z)
			GameLogic.RunCommand(string.format("/goto %s %s %s", x, y, z))
		end
		
		GameLogic.RunCommand("/property -all-2 PasueScene true")
		GameLogic.RunCommand("/hide desktop")
		GameLogic.RunCommand("/hide tips")
		GameLogic.RunCommand("/hide")
		GameLogic.RunCommand("/fov 1.57")

		ParaUI.ShowCursor(false)
		ParaScene.EnableMiniSceneGraph(false);
		ParaEngine.ForceRender()
				
		local Screen = commonlib.gettable("System.Windows.Screen")
		local ViewportManager = commonlib.gettable("System.Scene.Viewports.ViewportManager")
		local viewport = ViewportManager:GetSceneViewport()

		local width = Screen:GetWidth()
		local height = Screen:GetHeight()
		local _width = math.max(width, height)
		local _height = math.min(width, height)

		local pos = {
			[0] = {x-1, y, z},
			[1] = {x, y, z+1},
			[2] = {x+1, y, z},
			[3] = {x, y, z-1},
			[4] = {x, y+1, z},
			[5] = {x, y-1, z},
		}

		function shot(pitch, yaw, name, chain)
			viewport:SetPosition("_ctt", 0, 0, _height, _height)
			-- viewport:SetPosition("_lt", 0, 0, Screen:GetHeight(), Screen:GetHeight())
	
			local p = pos[name]
			setPlayerPos(p[1], p[2], p[3])
			
			ParaCamera.SetEyePos(1, pitch, yaw)

			ParaUI.GetUIObject("root").visible = false

			commonlib.TimerManager.SetTimeout(function()
				local tempfile = string.format("Screen Shots/cubemap_tmp_%s_%s.jpg", name, os.time())
				ParaMovie.TakeScreenShot(tempfile)
				
				viewport:SetPosition("_fi", 0, 0, 0, 0)
				
				local r = ParaUI.GetUIObject("root")
				ParaUI.GetUIObject("root").visible = true

				local offset = (_width * _width / _height - _width) / 2
				local c = ParaUI.CreateUIObject("container", "RenderCubMapImage" .. os.time(), "_lt", -offset, 0, _width * _width / _height, _height);
				--local c = ParaUI.CreateUIObject("container", "RenderCubMapImage" .. os.time(), "_lt", 0, 0, _width * _width / _height, _height);
				c.background = tempfile

				r:AddChild(c)
				
				local filepath = string.format("Screen Shots/%s.jpg", name)
				ParaMovie.TakeScreenShot(filepath, _height, _height)
				ParaUI.DestroyUIObject(c)
				-- ParaIO.DeleteFile(tempfile)

				commonlib.TimerManager.SetTimeout(function()
--					chain()
				end, 1000)	
			end, 1000)
		end

		shot(0, 3.14, 0, function()
			GameLogic.RunCommand("/t 2 /property -all-2 PasueScene false")	
			GameLogic.RunCommand("/show desktop")
			GameLogic.RunCommand("/show")
			ParaUI.ShowCursor(true)
		end)

		--[[

		shot(0, 3.14, 0, function()
			shot(0, -1.57, 1, function()
				shot(0, 0, 2, function()
					shot(0, 1.57, 3, function()
						shot(-1.57, 3.14, 4, function()
							shot(1.57, 3.14, 5, function()
								GameLogic.RunCommand("/t 2 /property -all-2 PasueScene false")	
								GameLogic.RunCommand("/show desktop")
								GameLogic.RunCommand("/show")
								ParaUI.ShowCursor(true)
							end)	
						end)	
					end)
				end)
			end)
		end)
		]]

	end,
};
