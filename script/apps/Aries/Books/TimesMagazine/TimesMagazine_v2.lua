--[[
Title: 
Author(s): Leio
Date: 2009/10/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazine_v2.lua");
-------------------------------------------------------
]]
local TimesMagazine_v2 = {

	
}
commonlib.setfield("MyCompany.Aries.Books.TimesMagazine_v2",TimesMagazine_v2);
function TimesMagazine_v2.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/TimesMagazine_v2/1.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v2/2.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v2/3.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v2/4.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v2/5.png" },
		{ filename = "Texture/Aries/Books/TimesMagazine_v2/6.png" },
		{ filename = "Texture/Aries/Books/Magazine_bg2_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end