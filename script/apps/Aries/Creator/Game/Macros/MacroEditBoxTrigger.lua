--[[
Title: Macro EditBox Trigger
Author(s): LiXizhi
Date: 2021/1/13
Desc: 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

--@param uiName: UI name
--@param text: content text
function Macros.EditBoxTrigger(uiName, text)
	local obj = ParaUI.GetUIObject(btnName)
	if(obj and obj:IsValid()) then
		local x, y, width, height = obj:GetAbsPosition();
		local mouseX = math.floor(x + width /2)
		local mouseY = math.floor(y + height /2)
		-- TODO:
--		local callback = {};
--		MacroPlayer.SetClickTrigger(mouseX, mouseY, text, function()
--			if(callback.OnFinish) then
--				callback.OnFinish();
--			end
--		end);
--		return callback;
	end
end





