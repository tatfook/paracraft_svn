--[[
Title: Popup menu
Author(s): LiXizhi
Company: ParaEngine
Date: 2011/11/22
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Functions/MountPetMenuPopup.lua");
local MountPetMenuPopup = commonlib.gettable("MyCompany.Aries.Desktop.Functions.MountPetMenuPopup");
------------------------------------------------------------
]]
local MountPetMenuPopup = commonlib.gettable("MyCompany.Aries.Desktop.Functions.MountPetMenuPopup");
local page;

function MountPetMenuPopup.OnInit()
	page = document:GetPageCtrl();
end
