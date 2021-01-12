--[[
Title: Macro Button Click Trigger
Author(s): LiXizhi
Date: 2021/1/4
Desc: a trigger for the clicking of a named button in GUI. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Mouse.lua");
NPL.load("(gl)script/ide/System/Windows/Screen.lua");
NPL.load("(gl)script/ide/System/Scene/Viewports/ViewportManager.lua");
NPL.load("(gl)script/ide/System/Core/SceneContextManager.lua");
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
NPL.load("(gl)script/ide/System/Scene/Cameras/Cameras.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Cameras = commonlib.gettable("System.Scene.Cameras");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local SceneContextManager = commonlib.gettable("System.Core.SceneContextManager");
local ViewportManager = commonlib.gettable("System.Scene.Viewports.ViewportManager");
local Screen = commonlib.gettable("System.Windows.Screen");
local Mouse = commonlib.gettable("System.Windows.Mouse");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")


--@param mouse_button: "left", "right", default to "left", such as "ctrl+left"
--@param angleX, angleY
-- @return nil or {OnFinish=function() end}
function Macros.SceneClickTrigger(button, angleX, angleY)
	local mouseX, mouseY = Macros.MouseAngleToScreenPos(angleX, angleY, button)

	local callback = {};
	MacroPlayer.SetClickTrigger(mouseX, mouseY, button, function()
		if(callback.OnFinish) then
			callback.OnFinish();
		end
	end);
	return callback;
end

function Macros.SceneDragTrigger(button, startAngleX, startAngleY, endAngleX, endAngleY)
	local startX, startY = Macros.MouseAngleToScreenPos(startAngleX, startAngleY)
	local endX, endY = Macros.MouseAngleToScreenPos(endAngleX, endAngleY)

	local callback = {};
	MacroPlayer.SetDragTrigger(startX, startY, endX, endY, button, function()
		if(callback.OnFinish) then
			callback.OnFinish();
		end
	end);
	return callback;
end




