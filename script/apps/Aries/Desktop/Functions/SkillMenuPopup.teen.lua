--[[
Title: Popup menu
Author(s): leio
Company: ParaEngine
Date: 2012/03/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Functions/SystemMenuPopup.lua");
local SystemMenuPopup = commonlib.gettable("MyCompany.Aries.Desktop.Functions.SystemMenuPopup");
------------------------------------------------------------
]]
local SkillMenuPopup = commonlib.gettable("MyCompany.Aries.Desktop.Functions.SkillMenuPopup");
local page;

function SkillMenuPopup.OnInit()
	page = document:GetPageCtrl();
end
