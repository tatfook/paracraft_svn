--[[
Title: Common UI functions for 3D Map system
Author(s): WangTian
Date: 2007/9/17
Desc: collection of UI common functions
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/UICommon.lua");
Map3DSystem.UI.***();
------------------------------------------------------------
]]

-- get the current screen resolution
-- @return: x, y
function Map3DSystem.UI.GetCurrentScreenResolution()
	local x, y, width, height = ParaUI.GetUIObject("root"):GetAbsPosition();
	return width, height;
end

-- calculate the text width
-- @param text: calculated text
-- @param font: font
-- @return: width in pixel
function Map3DSystem.UI.CalculateTextWidth(text, font)
	return _guihelper.GetTextWidth(text, font);
end