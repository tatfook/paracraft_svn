--[[
Title: Popup menu
Author(s): LiXizhi
Company: ParaEngine
Date: 2011/11/22
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Functions/SystemMenuPopup.lua");
local SystemMenuPopup = commonlib.gettable("MyCompany.Aries.Desktop.Functions.SystemMenuPopup");
------------------------------------------------------------
]]
local SystemMenuPopup = commonlib.gettable("MyCompany.Aries.Desktop.Functions.SystemMenuPopup");
local page;

function SystemMenuPopup.OnInit()
	page = document:GetPageCtrl();
end
