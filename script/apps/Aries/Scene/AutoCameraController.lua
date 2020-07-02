--[[
Title: Auto camera controller 
Author(s): LiXizhi
Date: 2010/11/4
Desc: this is an intelligent, yet predictable camera controller.
It will ensure that the camera is at a proper distance to character and liftup angle is also fine. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
MyCompany.Aries.AutoCameraController:Init();
MyCompany.Aries.AutoCameraController:MakeEnable(false); 
MyCompany.Aries.AutoCameraController:ApplyStyle("2d");
MyCompany.Aries.AutoCameraController:ApplyStyle({min_dist=10,min_liftup_angle=0.7, max_liftup_angle=0.8});
log(MyCompany.Aries.AutoCameraController:GetStyleName());
------------------------------------------------------------
]]
-- this is an intelligent, yet predictable camera controller 
local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");

local math_abs = math.abs;
-- minimum camera to character distance
AutoCameraController.min_dist = 4;
-- min/max camera lift up angle
AutoCameraController.min_liftup_angle = 0.25;
AutoCameraController.max_liftup_angle = 0.7;
-- timer interval to watch for wrong camera positions. in milliseconds
AutoCameraController.watcher_interval = 1500;
-- how many milliseconds to delay adjusting the camera. If this is 0, it means immediate, otherwise this is usually multiples of watcher_interval
AutoCameraController.delay_adjust_period = 0;
--  private: used internally for counting the delay_adjust_period
AutoCameraController.delay_adjust_counter = 0;
-- timer period to adjust camera position
AutoCameraController.adjust_interval = 33;
-- home much to adjust the camera by percentage per frame
AutoCameraController.adjust_dist_step_percentage = 0.02;
AutoCameraController.adjust_angle_step_percentage = 0.02;
AutoCameraController.enabled = true;
-- we will ignore curent setting and adjust the camera to self.target setting. 
-- this is usually used to set to a default setting which is inside the permitted range of a given camera mode. 
AutoCameraController.is_targetting = false;
-- target animation
AutoCameraController.target = nil;
-- the last style name of ApplyStyle() in case it is called by string name
AutoCameraController.style_name = nil;

-- predefined styles
AutoCameraController.styles = {
["2d"] = {
	min_dist = 17,
	max_dist = 46,
	min_liftup_angle = 0.7,
	max_liftup_angle = 0.8,
	watcher_interval = 1500,
	adjust_interval = 33,
	delay_adjust_period = 60000,
	disable_delay_adjustment = true,
	adjust_dist_step_percentage = 0.02,
	adjust_angle_step_percentage = 0.02,
	enable_mouse_left_drag = false,
	-- optional default style that will inherit the parent setting. this is used during style toggling. 
	default_style = {min_dist = 22, max_dist=22, min_liftup_angle=0.7, max_liftup_angle=0.7},
},
["3d"] = {
	min_dist = 4,
	max_dist = 35,
	min_liftup_angle = 0.25,
	max_liftup_angle = 0.5,
	watcher_interval = 1500,
	adjust_interval = 33,
	delay_adjust_period = 60000,
	disable_delay_adjustment = true,
	enable_mouse_left_drag = true,
	adjust_dist_step_percentage = 0.02,
	adjust_angle_step_percentage = 0.02,
	-- optional default style that will inherit the parent setting. this is used during style toggling. 
	default_style = {min_dist=10, max_dist= 10, min_liftup_angle=0.4,max_liftup_angle=0.4 },
},
};

-- called once per game world load, it just starts an internal timer to watch for camera state
function AutoCameraController:Init()
	
	if(System.options.version == "teen") then
		--AutoCameraController.styles["3d"].enable_mouse_left_drag = false;
	end
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer(timer);
	end})
	self.timer:Change(0, self.watcher_interval);
end

-- get the current style name that is set by last call of ApplyStyle(). 
function AutoCameraController:GetStyleName()
	return self.style_name;
end

-- apply style in a batch
-- @param style: a table containing {min_dist, min_liftup_angle, ..., enabled,default_style={min_dist,...}}, or it can also be a string of style name. 
--  see self.styles for some predefined styles like "2d", "3d". style.default_style is used during ApplyStyle. 
function AutoCameraController:ApplyStyle(style)
	if(type(style) == "string") then
		self.style_name = style;
		style = AutoCameraController.styles[style];
	end

	if(type(style) == "table") then
		commonlib.partialcopy(self, style);
		if(style.max_dist) then
			ParaCamera.GetAttributeObject():SetField("MaxCameraObjectDistance", style.max_dist);
		end
		ParaCamera.GetAttributeObject():SetField("EnableMouseLeftDrag", (style.enable_mouse_left_drag == true));
		
		ParaCamera.GetAttributeObject():SetField("CameraRollbackSpeed", style.CameraRollbackSpeed or 6);
		

		if (self.style_name=="2d") then
			paraworld.PostLog({action = "set_camera", msg="camera_2d"}, "set_camera_log", function(msg)
			end);			
		elseif (self.style_name=="3d") then
			paraworld.PostLog({action = "set_camera", msg="camera_3d"}, "set_camera_log", function(msg)
			end);		
		end
		-- so that the adjust will occur immediately. 
		self.delay_adjust_counter = self.delay_adjust_period;
		self:PlayTarget(style.default_style);
		if(self.enabled and self.timer) then
			self.timer:Change(0, self.watcher_interval);
		end
	end
end

-- play the target animation.
-- @param target: {min_dist, ... } all params are supported. if nil, it will cancel the current target. 
function AutoCameraController:PlayTarget(target)
	if(target) then
		self.target = target;
		self.is_targetting = true;
		-- so that the adjust will occur immediately. 
		self.delay_adjust_counter = self.delay_adjust_period;
	else
		self.is_targetting = false;
	end
end

-- make the controller enabled or not.
-- one can enable or disable at any time. 
function AutoCameraController:MakeEnable(bActive)
	if(bActive == nil) then
		bActive = true;
	end
	if(not bActive) then
		self.is_targetting = false;
	end
	self.enabled = bActive;
end

-- return whether the camera is enabled. 
function AutoCameraController:IsEnabled()
	return self.enabled;
end

function AutoCameraController:SaveCamera(params)
	local att = ParaCamera.GetAttributeObject();
	self.last_save = self.last_save or {};
	self.last_save.CameraObjectDistance = att:GetField("CameraObjectDistance", 5);
	self.last_save.CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0.4);
	self.last_save.CameraRotY = att:GetField("CameraRotY", 0);
end

function AutoCameraController:RestoreCamera()
	if(self.last_save) then
		local att = ParaCamera.GetAttributeObject();
		att:SetField("CameraObjectDistance", self.last_save.CameraObjectDistance);
		att:SetField("CameraLiftupAngle", self.last_save.CameraLiftupAngle);
		-- self.last_save = nil;
	end
end

-- a timer that is called periodically. 
function AutoCameraController:OnTimer(timer)
	if(not self.enabled) then
		return 
	end
	local att = ParaCamera.GetAttributeObject();
	self.BlockInput = att:GetField("BlockInput", false);
	
	if(not self.BlockInput and not ParaUI.IsMouseLocked()) then
		
		self.CameraObjectDistance = att:GetField("CameraObjectDistance", 5);
		self.CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0.4);
		self.CameraRotY = att:GetField("CameraRotY", 0);

		local min_dist = self.min_dist;
		local max_dist = self.max_dist;
		local min_liftup_angle = self.min_liftup_angle;
		local max_liftup_angle = self.max_liftup_angle;
		if(self.is_targetting and self.target) then
			local target = self.target;
			min_dist = target.min_dist or min_dist;
			max_dist = target.max_dist or max_dist;
			min_liftup_angle = target.min_liftup_angle or min_liftup_angle;
			max_liftup_angle = target.max_liftup_angle or max_liftup_angle;
		end

		local destObjectDistance;
		local destLiftupAngle;
		if(self.CameraObjectDistance < min_dist) then
			destObjectDistance = min_dist;
		elseif(max_dist and max_dist<self.CameraObjectDistance) then
			destObjectDistance = max_dist;
		end
		if(destObjectDistance and math_abs(self.CameraLiftupAngle-destObjectDistance) < 0.001 ) then
			destObjectDistance = nil;
		end

		if(self.CameraLiftupAngle < min_liftup_angle) then
			destLiftupAngle = min_liftup_angle;
		elseif(self.CameraLiftupAngle > max_liftup_angle) then
			destLiftupAngle = max_liftup_angle;
		end
		if(destLiftupAngle and math_abs(self.CameraLiftupAngle-destLiftupAngle) < 0.01 ) then
			destLiftupAngle = nil;
		end
		
		local bNeedAdjust = destObjectDistance or destLiftupAngle;
		
		if(bNeedAdjust and self.delay_adjust_counter>=self.delay_adjust_period) then
			
			-- we will adjust at 30 FPS approximately.
			timer:Change(0 ,self.adjust_interval);

			if(destObjectDistance) then
				if(self.CameraObjectDistance > destObjectDistance) then
					local step = self.CameraObjectDistance*self.adjust_dist_step_percentage;
					if((self.CameraObjectDistance - step) > destObjectDistance) then
						destObjectDistance = self.CameraObjectDistance - step;
					end
				else
					local step = destObjectDistance*self.adjust_dist_step_percentage;
					if((self.CameraObjectDistance + step) < destObjectDistance) then
						destObjectDistance = self.CameraObjectDistance + step;
					end
				end
				att:SetField("CameraObjectDistance", destObjectDistance);
			end
			if(destLiftupAngle) then
				if(self.CameraLiftupAngle > destLiftupAngle) then
					local step = self.CameraLiftupAngle*self.adjust_angle_step_percentage;
					if((self.CameraLiftupAngle - step) > destLiftupAngle) then
						destLiftupAngle = self.CameraLiftupAngle - step;
					end
				else
					local step = destLiftupAngle*self.adjust_angle_step_percentage;
					if((self.CameraLiftupAngle + step) < destLiftupAngle) then
						destLiftupAngle = self.CameraLiftupAngle + step;
					end
				end
				att:SetField("CameraLiftupAngle", destLiftupAngle);
			end
		else
			-- no adjustment is needed
			if(bNeedAdjust) then
				if(not self.disable_delay_adjustment) then
					self.delay_adjust_counter = self.delay_adjust_counter + self.watcher_interval;
				end
			else
				self.delay_adjust_counter = 0;
				if(self.is_targetting) then
					self.is_targetting = false;
				end
			end
			timer:Change(self.watcher_interval,self.watcher_interval);
		end
	end
end