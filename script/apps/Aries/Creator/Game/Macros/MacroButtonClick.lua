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
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

local function SetKeyboardFromButtonText(emulatedKeys, button)
	-- mouse_button is a global variable
	emulatedKeys.shift_pressed = button and button:match("shift") and true 
	emulatedKeys.alt_pressed = button and button:match("alt") and true
	emulatedKeys.ctrl_pressed = button and button:match("ctrl") and true
end

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

		__onuievent__(obj.id, "onclick");

		SetKeyboardFromButtonText(emulatedKeys, "")
	end
end





