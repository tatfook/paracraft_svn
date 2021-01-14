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
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Application = commonlib.gettable("System.Windows.Application");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

-- native ParaUIObject's onclick event
--@param btnName: button name
--@param button: "left", "right", default to "left"
function Macros.ButtonClickTrigger(btnName, button)
	local obj = ParaUI.GetUIObject(btnName)
	if(obj and obj:IsValid()) then
		local x, y, width, height = obj:GetAbsPosition();
		local mouseX = math.floor(x + width /2)
		local mouseY = math.floor(y + height /2)
		local callback = {};
		MacroPlayer.SetClickTrigger(mouseX, mouseY, button, function()
			if(callback.OnFinish) then
				callback.OnFinish();
			end
		end);
		return callback;
	end
end

-- System.Window's click event
function Macros.UIClickTrigger(btnName, button)
	local obj = Application.GetUIObject(btnName);
	if(obj) then
		local window = obj:GetWindow()
		if(window and window:testAttribute("WA_WState_Created")) then
			local x, y, width, height = obj:GetAbsPosition()
			local mouseX = math.floor(x + width /2)
			local mouseY = math.floor(y + height /2)
			
			local callback = {};
			MacroPlayer.SetClickTrigger(mouseX, mouseY, button, function()
				if(callback.OnFinish) then
					callback.OnFinish();
				end
			end);
			return callback;
		end
	end
end


