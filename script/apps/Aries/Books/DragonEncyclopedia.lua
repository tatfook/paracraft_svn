--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/DragonEncyclopedia.lua");
-------------------------------------------------------
]]
local CitizenHandbook = {

}
commonlib.setfield("MyCompany.Aries.Books.DragonEncyclopedia",DragonEncyclopedia);
function DragonEncyclopedia.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/DragonEncyclopedia_v1/book_pic01.png" },
		{ filename = "Texture/Aries/Books/DragonEncyclopedia_v1/book_pic02.png" },
		{ filename = "Texture/Aries/Books/DragonEncyclopedia_v1/book_pic03.png" },
		{ filename = "Texture/Aries/Books/DragonEncyclopedia_v1/book_pic04.png" },
		{ filename = "Texture/Aries/Books/DragonEncyclopedia_v1/book_pic05.png" },
		{ filename = "Texture/Aries/Books/Green_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end