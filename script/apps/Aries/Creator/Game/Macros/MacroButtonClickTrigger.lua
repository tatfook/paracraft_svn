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
function Macros.ButtonClickTrigger(btnName, button, eventName)
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

function Macros.ContainerDragEndTrigger(btnName, offsetX, offsetY)
	local obj = ParaUI.GetUIObject(btnName)
	if(obj and obj:IsValid()) then
		local x, y, width, height = obj:GetAbsPosition();
		local startX = math.floor(x + width /2)
		local startY = math.floor(y + height /2)
		local endX, endY = x + offsetX, y + offsetY

		local callback = {};
		MacroPlayer.SetDragTrigger(startX, startY, endX, endY, "left", function()
			if(callback.OnFinish) then
				callback.OnFinish();
			end
		end);
		return callback;
	end
end

-- System.Window's click event
-- @param localX, localY: local mouse click position relative to the control
function Macros.WindowClickTrigger(btnName, button, localX, localY)
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

			local mouseX = x + localX
			local mouseY = y + localY
			
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


