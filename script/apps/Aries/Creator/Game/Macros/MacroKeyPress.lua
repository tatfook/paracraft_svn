--[[
Title: Macro Key Press
Author(s): LiXizhi
Date: 2021/1/4
Desc: a macro for key(s) press. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macros.lua");
-------------------------------------------------------
]]
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

-- @param event: key press event object
-- @return string like "ctrl+DIK_C", ""
function Macros.GetButtonTextFromKeyEvent(event)
	local buttons = event.keyname or "";
	if(event.ctrl_pressed) then
		buttons = "ctrl+"..buttons;
	end
	if(event.alt_pressed) then
		buttons = "alt+"..buttons;
	end
	if(event.shift_pressed) then
		buttons = "shift+"..buttons;
	end
	return buttons;
end

-- @param buttons: nil or a string to append button text. 
-- @return string like "ctrl+shift", ""
function Macros.GetButtonTextFromKeyboard(buttons)
	buttons = buttons or "";
	if(Keyboard:IsCtrlKeyPressed()) then
		buttons = "ctrl+"..buttons;
	end
	if(Keyboard:IsAltKeyPressed()) then
		buttons = "alt+"..buttons;
	end
	if(Keyboard:IsShiftKeyPressed()) then
		buttons = "shift+"..buttons;
	end
	buttons = buttons:gsub("%+$", "")
	return buttons;
end


local function SetKeyEventFromButtonText(event, button)
	-- mouse_button is a global variable
	event.isEmulated= true;
	event.keyname = button:match("(DIK_%w+)");
	event.shift_pressed = button:match("shift") and true 
	event.alt_pressed = button:match("alt") and true
	event.ctrl_pressed = button:match("ctrl") and true
	event.key_sequence = event:GetKeySequence();
end

local nextKeyPressMouseX, nextKeyPressMouseY;


function Macros.GetNextKeyPressWithMouseMove()
	return nextKeyPressMouseX, nextKeyPressMouseY
end

-- this macro will force the next key stroke to have a given mouse position. 
-- such as some ctrl+C and ctrl+v operations in the scene. 
function Macros.NextKeyPressWithMouseMove(angleX, angleY)
	nextKeyPressMouseX, nextKeyPressMouseY = Macros.MouseAngleToScreenPos(angleX, angleY);
end

local function AdjustMousePosition_()
	if(nextKeyPressMouseX and nextKeyPressMouseY) then
		-- mouse_x, mouse_y, mouse_button are global variables
		mouse_x, mouse_y = nextKeyPressMouseX, nextKeyPressMouseY;
		ParaUI.SetMousePosition(mouse_x, mouse_y);
		nextKeyPressMouseX, nextKeyPressMouseY = nil, nil;
	end
end

--@param button: string like "C" or "ctrl+C"
function Macros.KeyPress(button)
	AdjustMousePosition_();

	local event = KeyEvent:init("keyPressEvent")
	SetKeyEventFromButtonText(event, button)
	local ctx = GameLogic.GetSceneContext()
	ctx:keyPressEvent(event);
end





