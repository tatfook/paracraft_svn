--[[
Title: Macro Scene Click
Author(s): LiXizhi
Date: 2021/1/4
Desc: a macro for the clicking of a named button in GUI. 

Use Lib:
-------------------------------------------------------
GameLogic.Macros.SceneClick("left", GameLogic.Macros.GetSceneClickParams())
-------------------------------------------------------
]]
-------------------------------------
-- single Macro base
-------------------------------------
NPL.load("(gl)script/ide/System/Windows/Mouse.lua");
NPL.load("(gl)script/ide/System/Windows/Screen.lua");
NPL.load("(gl)script/ide/System/Scene/Viewports/ViewportManager.lua");
NPL.load("(gl)script/ide/System/Core/SceneContextManager.lua");
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
NPL.load("(gl)script/ide/System/Scene/Cameras/Cameras.lua");
local Cameras = commonlib.gettable("System.Scene.Cameras");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local SceneContextManager = commonlib.gettable("System.Core.SceneContextManager");
local ViewportManager = commonlib.gettable("System.Scene.Viewports.ViewportManager");
local Screen = commonlib.gettable("System.Windows.Screen");
local Mouse = commonlib.gettable("System.Windows.Mouse");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

-- @return angleX, angleY: angle offset from the center
function Macros.GetSceneClickParams()
	local mouse_x, mouse_y = Mouse:GetMousePosition()

	local viewport = ViewportManager:GetSceneViewport();
	local screenWidth, screenHeight = Screen:GetWidth()-viewport:GetMarginRight(), Screen:GetHeight() - viewport:GetMarginBottom();

	local camobjDist, LiftupAngle, CameraRotY = ParaCamera.GetEyePos();
	local lookatX, lookatY, lookatZ = ParaCamera.GetLookAtPos();

	local fov = Cameras:GetCurrent():GetFieldOfView()
	local aspectRatio = Cameras:GetCurrent():GetAspectRatio()
	
	return (mouse_x / screenWidth * 2 - 1) * fov * aspectRatio * 0.5, (mouse_y /screenHeight * 2 - 1) * (fov) * 0.5;
end

--@param mouse_button: "left", "right", default to "left"
--@param angleX, angleY
function Macros.SceneClick(button, angleX, angleY)
	local viewport = ViewportManager:GetSceneViewport();
	local curScreenWidth, curScreenHeight = Screen:GetWidth()-viewport:GetMarginRight(), Screen:GetHeight() - viewport:GetMarginBottom();

	local curFov = Cameras:GetCurrent():GetFieldOfView()
	local curAspectRatio = Cameras:GetCurrent():GetAspectRatio()
	
	-- mouse_x and mouse_y are global variable
	mouse_x = math.floor(angleX / (curFov * curAspectRatio  / 2) * (curScreenWidth / 2) + (curScreenWidth / 2));
	mouse_y = math.floor(angleY / (curFov / 2) * (curScreenHeight / 2) + (curScreenHeight / 2));

	mouse_button = button;
	ParaUI.SetMousePosition(mouse_x, mouse_y);

	local event = MouseEvent:init("mouseMoveEvent");
	event.isEmulated= true;
	local ctx = GameLogic.GetSceneContext()
	ctx:mousePressEvent(event);

	local event = MouseEvent:init("mouseReleaseEvent");
	event.isEmulated= true;
	event.dragDist = 0;
	ctx:mouseReleaseEvent(event);
end





