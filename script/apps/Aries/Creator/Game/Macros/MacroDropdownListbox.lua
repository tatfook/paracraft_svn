--[[
Title: Macro for Dropdown listbox
Author(s): LiXizhi
Date: 2021/1/29
Desc: 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/Macros.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")


function Macros.DropdownTextChange(name, text)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl and ctl.handleEvent) then
		if(ctl:GetText() ~= text) then
			ctl:SetText(text);
			ctl:handleEvent("OnTextChange");
		end
	end
end

function Macros.DropdownTextChangeTrigger(name, text)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl and ctl.handleEvent) then
		if(ctl:GetText() ~= text) then
			local _parent = ctl:GetParentUIObject()
			if(_parent) then
				local editbox = _parent:GetChild("e")
				local x, y, width, height = editbox:GetAbsPosition();
				local mouseX, mouseY = math.floor(x + width/2), math.floor(y + height/2);
		
				local callback = {};
				MacroPlayer.SetClickTrigger(mouseX, mouseY, "left", function()
					if(callback.OnFinish) then
						callback.OnFinish();
					end
				end);
				return callback;
			end
		end
	end
end

function Macros.DropdownClickDropDownButton(name)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl and ctl.handleEvent) then
		ctl:handleEvent("OnClickDropDownButton");
	end
end

function Macros.DropdownClickDropDownButtonTrigger(name)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl and ctl.handleEvent) then
		if(ctl:GetText() ~= text) then
			local _parent = ctl:GetParentUIObject()
			if(_parent) then
				local editbox = _parent:GetChild("b")
				local x, y, width, height = editbox:GetAbsPosition();
				local mouseX, mouseY = math.floor(x + width/2), math.floor(y + height/2);
		
				local callback = {};
				MacroPlayer.SetClickTrigger(mouseX, mouseY, "left", function()
					if(callback.OnFinish) then
						callback.OnFinish();
					end
				end);
				return callback;
			end
		end
	end
end