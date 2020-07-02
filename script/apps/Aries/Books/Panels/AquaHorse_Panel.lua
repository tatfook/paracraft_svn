--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/AquaHorse_Panel.lua");
-------------------------------------------------------
]]
local AquaHorse_Panel = {

}
commonlib.setfield("MyCompany.Aries.Books.AquaHorse_Panel",AquaHorse_Panel);
function AquaHorse_Panel.GetAssetList()
	local list = {
		{ filename = "texture/Aries/Books/Panel_bg_32bits.png" },
		{ filename = "texture/Aries/Books/Panels/AquaHorse_content_32bits.png" },
		{ filename = "Texture/Aries/Books/Panel_close_32bits.png" },
	}
	return list;
end