--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/DragonItemMagazine.lua");
-------------------------------------------------------
]]
local DragonItemMagazine = {

}
commonlib.setfield("MyCompany.Aries.Books.DragonItemMagazine",DragonItemMagazine);
function DragonItemMagazine.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/DragonItemMagazine_v1/food_pic01.png" },
		{ filename = "Texture/Aries/Books/DragonItemMagazine_v1/food_pic02.png" },
		{ filename = "Texture/Aries/Books/DragonItemMagazine_v1/food_pic03.png" },
	--	{ filename = "Texture/Aries/Books/DragonItemMagazine_v1/food_pic04.png" }, 
		
		
		{ filename = "Texture/Aries/Books/yellowlight_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
		
		{ filename = "Texture/Aries/Books/joybean_32bits.png" },
		{ filename = "Texture/Aries/Books/purchase_btn_32bits.png" },
	}
	return list;
end