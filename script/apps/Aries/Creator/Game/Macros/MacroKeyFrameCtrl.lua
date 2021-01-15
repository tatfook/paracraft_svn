--[[
Title: Macro for KeyFrameCtrl
Author(s): LiXizhi
Date: 2021/1/15
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

function Macros.KeyFrameCtrlClickKey(name, keyIndex, mouseButton)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl) then
		--ctl:handleEvent("OnMouseWheel");
	end
end

function Macros.KeyFrameCtrlClickKeyTrigger(name, mouseWheel)
	local ctl = CommonCtrl.GetControl(name)
	if(ctl and ctl.handleEvent) then
		local _this = ctl:GetInnerControl()
		if(_this) then
			
		end
	end
end
