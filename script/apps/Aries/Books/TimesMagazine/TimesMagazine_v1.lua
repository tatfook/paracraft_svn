--[[
Title: 
Author(s): Leio
Date: 2009/10/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazine_v1.lua");
-------------------------------------------------------
]]
local TimesMagazine_v1 = {

	
}
commonlib.setfield("MyCompany.Aries.Books.TimesMagazine_v1",TimesMagazine_v1);
function TimesMagazine_v1.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/1.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/2.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/3.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/4.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/5.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/6.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/7.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v1/8.png" },

		{ filename = "Texture/Aries/Books/Magazine_bg2_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end