--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/FashionMagazine.lua");
-------------------------------------------------------
]]
local FashionMagazine = {

}
commonlib.setfield("MyCompany.Aries.Books.FashionMagazine",FashionMagazine);
function FashionMagazine.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic01.png" },
		{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic02.png" },
		{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic03.png" },
		{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic04.png" },
		{ filename = "Texture/Aries/Books/FashionMagazine_v1/cloth_pic05.png" },
		
		{ filename = "Texture/Aries/Books/Purple_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
		
		{ filename = "Texture/Aries/Books/joybean_32bits.png" },
		{ filename = "Texture/Aries/Books/purchase_btn_32bits.png" },
	}
	return list;
end