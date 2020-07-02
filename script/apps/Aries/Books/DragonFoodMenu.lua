--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/DragonFoodMenu.lua");
-------------------------------------------------------
]]
local DragonFoodMenu = {

}
commonlib.setfield("MyCompany.Aries.Books.DragonFoodMenu",DragonFoodMenu);
function DragonFoodMenu.GetAssetList()
	local list = {
		{ filename = "Texture/Aries/Books/DragonFoodMenu_v1/page01_32bits.png" },
		{ filename = "Texture/Aries/Books/DragonFoodMenu_v1/page02_32bits.png" },
		{ filename = "Texture/Aries/Books/DragonFoodMenu_v1/page03_32bits.png" },
		{ filename = "Texture/Aries/Books/DragonFoodMenu_v1/page04_32bits.png" },
		{ filename = "Texture/Aries/Books/DragonFoodMenu_v1/page05_32bits.png" },
		
		{ filename = "Texture/Aries/Books/yellowlight_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end