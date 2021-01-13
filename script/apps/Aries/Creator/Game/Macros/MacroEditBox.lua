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
	Macros.SetNextKeyPressWithMouseMove(nil, nil);
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		obj.text = text or ""
		obj:SetCaretPosition(-1);
		--obj:Focus()
		__onuievent__(obj.id, "onmodify");
	end
	return Macros.Idle();
end

function Macros.EditBoxKeyup(uiName, keyname)
	Macros.SetNextKeyPressWithMouseMove(nil, nil);
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		local vKey = keyname:gsub("DIK_", "EM_KEY_");
		if(Event_Mapping[vKey]) then
			virtual_key = Event_Mapping[vKey];
			__onuievent__(obj.id, "onkeyup");
		end
	end
	return Macros.Idle();
end





