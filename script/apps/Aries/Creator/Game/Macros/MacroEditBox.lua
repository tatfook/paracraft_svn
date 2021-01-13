--[[
Title: Macro EditBox
Author(s): LiXizhi
Date: 2021/1/13
Desc: 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")


--@param uiName: UI name
--@param text: content text
function Macros.EditBox(uiName, text)
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		obj.text = text or ""
		obj:SetCaretPosition(-1);
		obj:Focus()
	end
end





