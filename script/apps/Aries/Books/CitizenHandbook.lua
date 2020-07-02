--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/CitizenHandbook.lua");
-------------------------------------------------------
]]
local CitizenHandbook = {

}
commonlib.setfield("MyCompany.Aries.Books.CitizenHandbook",CitizenHandbook);
function CitizenHandbook.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/CitizenHandbook_v1/1.png" },
		{ filename = "Texture/Aries/Books/CitizenHandbook_v1/2.png" },
		{ filename = "Texture/Aries/Books/CitizenHandbook_v1/3.png" },
		{ filename = "Texture/Aries/Books/CitizenHandbook_v1/4.png" },
		{ filename = "Texture/Aries/Books/CitizenHandbook_v1/5.png" },
		{ filename = "Texture/Aries/Books/Green_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end