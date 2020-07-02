--[[
Title: menu item 3 handler
Author(s): LiXizhi
Date: 2006/7/15
Desc: Currently it is used for GUI inspection at the current mouse location.
Use Lib:
-------------------------------------------------------
NPL.activate("(gl)script/function3.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/GUI_inspector_simple.lua");

local function activate(intensity)
	-- call this function at any time to inspect UI at the current mouse position
	CommonCtrl.GUI_inspector_simple.InspectUI(); 
end
NPL.this(activate);