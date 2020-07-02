--[[
Title: Environment Manager
Author(s): andy
Date: 2011/8/10
Desc: environment attribute manager, including sky, fog, ocean etc.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/EnvManager.lua");
local EnvManager = commonlib.gettable("MyCompany.Aries.Scene.EnvManager");
EnvManager.Init(); -- during login process
EnvManager.OnWorldLoad();
EnvManager.InsertKeyFrame();
------------------------------------------------------------
]]

local EnvManager = commonlib.gettable("MyCompany.Aries.Scene.EnvManager");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

-- invoked at MyCompany.Aries.OnActivateDesktop()
function EnvManager.Init()
	-- start a global timer to keep consistent update
	EnvManager.update_timer = EnvManager.update_timer or commonlib.Timer:new({callbackFunc = EnvManager.UpdateEnv});
	EnvManager.update_timer:Change(0, 100);
end

-- on world load to set the env with the current world key frames
function EnvManager.OnWorldLoad()
end

-- get base key frame 
function EnvManager.GetBaseKeyFrame()
end

-- build key frame fragment with the spell node
function EnvManager.BuildKeyFrameFragment(xml_node)
	
end

-- insert key frame fragement into the current env
function EnvManager.InsertKeyFrameFragment(time, fragment, bImmediate)
end

-- force update the env, e.x. world change
function EnvManager.ForceUpdate()
	EnvManager.UpdateEnv();
end


-- 19:59 is evening time and take 30 minutes to progress
local evening_time = 3600 * 19 + 60 * 59;
--local evening_time = 3600 * 9 + 60 * 59;
local evening_process_time = 60 * 30;

local isEnvEditing = false;

function EnvManager.SetEveningParams(time, progress)
	evening_time = time;
	evening_process_time = progress;
end

local prior_worldname_env_params = {
	["HaqiTown_RedMushroomArena_4v4"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox15/skybox15.x",
			skybox_cloudy_name = "skybox15",
			fog = {fog_start = 80, fog_range = 42, fog_plane = 420, },
		},
		night = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox15/skybox15.x",
			skybox_cloudy_name = "skybox15",
			fog = {fog_start = 80, fog_range = 42, fog_plane = 420, },
		},
	},
};

local public_worlds_env_params = {
	["worlds/MyWorlds/61HaqiTown"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox7/skybox7.x",
			skybox_cloudy_name = "skybox7",
			fog = {fog_start = 80, fog_range = 42, fog_plane = 420, },
		},
		night = {
			ambient = {r = 60, g = 147, b = 255},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 255, g = 0, b = 255},
			fog_volume = {_start = 0.010, _end = 0.523, _density = 0.214},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 80, fog_range = 80, fog_plane = 600, },
		},
	},
};

-- update frame move
function EnvManager.UpdateEnv()
	local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
	
	local world_info = WorldManager:GetCurrentWorld()
	local current_worlddir = world_info.worldpath;
	if(not world_info.apply_env_effect) then
		return;
	end

	if(type(HomeLandGateway.IsInHomeland) ~= "function") then
		return
	end
	if(HomeLandGateway.IsInHomeland()) then
		local env_param = homeland_env_params[current_worlddir];
		if(env_param) then
			-- set the homeland enviroment from the env_template
			if(env_param.ocean_color) then
				ParaScene.GetAttributeObjectOcean():SetField("OceanColor", {env_param.ocean_color.r/255, env_param.ocean_color.g/255, env_param.ocean_color.b/255});
			end
			if(env_param.fog_color) then
				ParaScene.GetAttributeObject():SetField("FogColor", {env_param.fog_color.r/255, env_param.fog_color.g/255, env_param.fog_color.b/255});
			end
			if(env_param.skybox and env_param.skybox_name) then
				Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_param.skybox, skybox_name = env_param.skybox_name});
			end
			--if(env_param.fog) then
				--local att = ParaEngine.GetAttributeObject();
				--att:SetField("FogStart", env_param.fog.fog_start);
				--att:SetField("FogEnd", env_param.fog.fog_end);
				--att:SetField("FarPlane", env_param.fog.fog_plane);
			--end
			-- slow down the timer
			if(EnvManager.update_timer) then
				EnvManager.update_timer:Change(10000, 10000);
			end
			return;
		end
	end
	
	if(isEnvEditing == true) then
		return;
	end

	-- disable fog for indoor and model based instance
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	if(y > 4000) then
		ParaScene.GetAttributeObject():SetField("EnableFog", false)
	else
		ParaScene.GetAttributeObject():SetField("EnableFog", true)
	end


	local isSnowing = false;
	if(MyCompany.Aries.Scene.GetWeather() == "snow") then
		isSnowing = true;
	end
	local isCloudy = false;
	if(MyCompany.Aries.Scene.GetWeather() == "cloudy") then
		isCloudy = true;
	end
	
	local env_config = public_worlds_env_params[current_worlddir] or public_worlds_env_params["worlds/MyWorlds/61HaqiTown"];

	local world_info = WorldManager:GetCurrentWorld();
	if(world_info) then
		if(prior_worldname_env_params[world_info.name]) then
			env_config = prior_worldname_env_params[world_info.name];
		end
	end
	
	local seconds_since0000 = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	if(seconds_since0000 < (evening_time - evening_process_time)) then
		-- set the sunlight
		local ambient = env_config.day.ambient;
		local diffuse = env_config.day.diffuse;
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("Ambient", {ambient.r/255, ambient.g/255, ambient.b/255});
		att:SetField("Diffuse", {diffuse.r/255, diffuse.g/255, diffuse.b/255});
		att:SetField("TimeOfDaySTD", env_config.day.TimeOfDaySTD);
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color = env_config.day.fog_color;
		att:SetField("FogColor", {fog_color.r/255, fog_color.g/255, fog_color.b/255});
		local fog = env_config.day.fog;
		--att:SetField("FogStart", fog.fog_start);
		--att:SetField("FogRange", fog.fog_range);
		--att:SetField("FarPlane", fog.fog_plane);
		local fog_volume = env_config.day.fog_volume;
		att:SetField("FogDensity", fog_volume._density);
		local att = ParaScene.GetAttributeObjectSky();
		att:SetField("SkyFogAngleFrom", fog_volume._start);
		att:SetField("SkyFogAngleTo", fog_volume._end);
		att:SetField("SkyColor", {255/255, 255/255, 255/255});
		--local ocean_color = env_config.day.ocean_color;
		--local att = ParaScene.GetAttributeObjectOcean();
		--att:GetField("OceanColor", {ocean_color.r/255, ocean_color.g/255, ocean_color.b/255});
		-- set the sky box if daytime
		if(isSnowing) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		elseif(isCloudy) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		else
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_sunny,  skybox_name = env_config.day.skybox_sunny_name})
		end
		-- slow down the timer
		if(EnvManager.update_timer) then
			EnvManager.update_timer:Change(10000, 10000);
		end
	elseif(seconds_since0000 < evening_time) then
		local ratio = (seconds_since0000 - (evening_time - evening_process_time)) / evening_process_time;
		local R = math.floor(187 + -187 * ratio);
		local G = math.floor(230 + -191 * ratio);
		local B = math.floor(255 + -155 * ratio);
		local start = math.floor(80 + 20 * ratio);
		local range = math.floor(42 + 8 * ratio);
		-- set the sunlight
		local ambient_day = env_config.day.ambient;
		local ambient_night = env_config.night.ambient;
		local diffuse_day = env_config.day.diffuse;
		local diffuse_night = env_config.night.diffuse;
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("Ambient", {
			((ambient_night.r - ambient_day.r) * ratio + ambient_day.r)/255, 
			((ambient_night.g - ambient_day.g) * ratio + ambient_day.g)/255, 
			((ambient_night.b - ambient_day.b) * ratio + ambient_day.b)/255, 
		});
		att:SetField("Diffuse", {
			((diffuse_night.r - diffuse_day.r) * ratio + diffuse_day.r)/255, 
			((diffuse_night.g - diffuse_day.g) * ratio + diffuse_day.g)/255, 
			((diffuse_night.b - diffuse_day.b) * ratio + diffuse_day.b)/255, 
		});
		att:SetField("TimeOfDaySTD", ((env_config.night.TimeOfDaySTD - env_config.day.TimeOfDaySTD) * ratio + env_config.day.TimeOfDaySTD));
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color_day = env_config.day.fog_color;
		local fog_color_night = env_config.night.fog_color;
		att:SetField("FogColor", {
			((fog_color_night.r - fog_color_day.r) * ratio + fog_color_day.r)/255, 
			((fog_color_night.g - fog_color_day.g) * ratio + fog_color_day.g)/255, 
			((fog_color_night.b - fog_color_day.b) * ratio + fog_color_day.b)/255, 
		});
		local fog = env_config.night.fog;
		--att:SetField("FogStart", fog.fog_start);
		--att:SetField("FogRange", fog.fog_range);
		--att:SetField("FarPlane", fog.fog_plane);
		local fog_volume_day = env_config.day.fog_volume;
		local fog_volume_night = env_config.night.fog_volume;
		att:SetField("FogDensity", ((fog_volume_night._density - fog_volume_day._density) * ratio + fog_volume_day._density));
		local att = ParaScene.GetAttributeObjectSky();
		att:SetField("SkyFogAngleFrom", ((fog_volume_night._start - fog_volume_day._start) * ratio + fog_volume_day._start));
		att:SetField("SkyFogAngleTo", ((fog_volume_night._end - fog_volume_day._end) * ratio + fog_volume_day._end));
		att:SetField("SkyColor", {
			((fog_color_night.r - 255) * ratio + 255)/255, 
			((fog_color_night.g - 255) * ratio + 255)/255, 
			((fog_color_night.b - 255) * ratio + 255)/255, 
		});
		--local ocean_color = env_config.night.ocean_color;
		--local att = ParaScene.GetAttributeObjectOcean();
		--att:GetField("OceanColor", {ocean_color.r/255, ocean_color.g/255, ocean_color.b/255});
		-- set the sky box if nighttime
		if(isSnowing) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		elseif(isCloudy) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		else
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_sunny,  skybox_name = env_config.day.skybox_sunny_name})
		end
		-- fast up the timer
		if(EnvManager.update_timer) then
			EnvManager.update_timer:Change(2000, 2000);
		end
	else
		-- set the sunlight
		local ambient = env_config.night.ambient;
		local diffuse = env_config.night.diffuse;
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("Ambient", {ambient.r/255, ambient.g/255, ambient.b/255});
		att:SetField("Diffuse", {diffuse.r/255, diffuse.g/255, diffuse.b/255});
		att:SetField("TimeOfDaySTD", env_config.night.TimeOfDaySTD);
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color = env_config.night.fog_color;
		att:SetField("FogColor", {fog_color.r/255, fog_color.g/255, fog_color.b/255});
		local fog = env_config.night.fog;
		--att:SetField("FogStart", fog.fog_start);
		--att:SetField("FogRange", fog.fog_range);
		--att:SetField("FarPlane", fog.fog_plane);
		local fog_volume = env_config.night.fog_volume;
		att:SetField("FogDensity", fog_volume._density);
		local att = ParaScene.GetAttributeObjectSky();
		att:SetField("SkyFogAngleFrom", fog_volume._start);
		att:SetField("SkyFogAngleTo", fog_volume._end);
		att:SetField("SkyColor", {255/255, 255/255, 255/255});
		--local ocean_color = env_config.night.ocean_color;
		--local att = ParaScene.GetAttributeObjectOcean();
		--att:GetField("OceanColor", {ocean_color.r/255, ocean_color.g/255, ocean_color.b/255});
		-- set the sky box if nighttime
		if(isSnowing) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.night.skybox_cloudy,  skybox_name = env_config.night.skybox_cloudy_name})
		elseif(isCloudy) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.night.skybox_cloudy,  skybox_name = env_config.night.skybox_cloudy_name})
		else
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.night.skybox_sunny,  skybox_name = env_config.night.skybox_sunny_name})
		end
		-- slow down the timer
		if(EnvManager.update_timer) then
			EnvManager.update_timer:Change(10000, 10000);
		end
	end
end