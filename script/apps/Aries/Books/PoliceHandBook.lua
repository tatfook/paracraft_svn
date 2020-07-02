--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/PoliceHandBook.lua");
-------------------------------------------------------
]]
local PoliceHandBook = {

}
commonlib.setfield("MyCompany.Aries.Books.PoliceHandBook",PoliceHandBook);
function PoliceHandBook.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/PoliceHandBook_v1/pic01.png" },
		{ filename = "Texture/Aries/Books/PoliceHandBook_v1/pic02.png" },
--		{ filename = "Texture/Aries/Books/PoliceHandBook_v1/pic03.png" },
		
		{ filename = "Texture/Aries/Books/Blue_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end