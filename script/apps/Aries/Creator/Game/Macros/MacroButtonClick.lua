--[[
Title: Macro Button Click
Author(s): LiXizhi
Date: 2021/1/4
Desc: a macro for the clicking of a named button in GUI. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
local Application = commonlib.gettable("System.Windows.Application");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

local function SetKeyboardFromButtonText(emulatedKeys, button)
	-- mouse_button is a global variable
	emulatedKeys.shift_pressed = button and button:match("shift") and true 
	emulatedKeys.alt_pressed = button and button:match("alt") and true
	emulatedKeys.ctrl_pressed = button and button:match("ctrl") and true
end

-- native ParaUIObject's onclick event
--@param btnName: button name
--@param button: "left", "right", "shift+left"
function Macros.ButtonClick(btnName, button)
	local obj = ParaUI.GetUIObject(btnName)
	if(obj and obj:IsValid()) then
		if(button:match("left")) then
			mouse_button = "left"
		elseif(button:match("left")) then
			mouse_button = "right"
		else
			mouse_button = "middle"
		end
		local emulatedKeys = Keyboard:GetEmulatedKeys()
		SetKeyboardFromButtonText(emulatedKeys, button)

		-- trickly: id is a global variable for _guihelper.GetLastUIObjectPos()
		id = obj.id; 
		__onuievent__(id, "onclick");

		SetKeyboardFromButtonText(emulatedKeys, "")
	end
end


local function SetMouseEventFromButtonText(event, button)
	-- mouse_button is a global variable
	event.isEmulated= true;
	event.shift_pressed = button and button:match("shift") and true 
	event.alt_pressed = button and button:match("alt") and true
	event.ctrl_pressed = button and button:match("ctrl") and true
	if(button and button:match("left") ) then
		event.buttons_state = 1;
		event.mouse_button = "left"
	elseif(button and button:match("right") ) then
		event.buttons_state = 2;
		event.mouse_button = "right"
	elseif(button and button:match("middle") ) then
		event.buttons_state = 0;
		event.mouse_button = "middle"
	else
		event.buttons_state = 0;
	end
end

-- System.Window's click event
-- @param localX, localY: local mouse click position relative to the control
function Macros.WindowClick(btnName, button, localX, localY)
	local obj = Application.GetUIObject(btnName);
	if(obj) then
		local window = obj:GetWindow()
		if(window and window:testAttribute("WA_WState_Created")) then
			local x, y, width, height = obj:GetAbsPosition()
			
			if( not localX or (localX + 6) > width) then
				localX = math.floor(width/2+0.5)
			end

			if( not localY or (localY + 6) > height) then
				localY =  math.floor(height/2+0.5)
			end

			-- mouse_x, mouse_y, mouse_button are global variables
			mouse_x, mouse_y, mouse_button = x + localX, y + localY, button
			
			ParaUI.SetMousePosition(mouse_x, mouse_y);

			local emulatedKeys = Keyboard:GetEmulatedKeys()
			SetKeyboardFromButtonText(emulatedKeys, button)

			local event = MouseEvent:init("mousePressEvent", window)
			SetMouseEventFromButtonText(event, button)
			window:handleMouseEvent(event);

			local event = MouseEvent:init("mouseReleaseEvent", window)
			SetMouseEventFromButtonText(event, button)
			window:handleMouseEvent(event);

			window.isEmulatedFocus = true;
			window:handleActivateEvent(true)
			window.isEmulatedFocus = nil;

			SetKeyboardFromButtonText(emulatedKeys, "")
		end
	end
end





