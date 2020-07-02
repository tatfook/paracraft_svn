--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/TownHistoryBook.lua");
-------------------------------------------------------
]]
local TownHistoryBook = {

}
commonlib.setfield("MyCompany.Aries.Books.TownHistoryBook",TownHistoryBook);
function TownHistoryBook.GetAssetList()
	local list = {
		{ filename = "Texture/transparent.png" },
		{ filename = "Texture/Aries/Quest/Props/Lollipop2.png" },
		{ filename = "Texture/transparent.png" },
		{ filename = "model/02furniture/v5/PoliceStationDeco/10Lollipop/Lollipop.x" },
		
		{ filename = "Texture/Aries/Books/bluelight_bg_32bits.png" },
		{ filename = "Texture/Aries/Books/close_32bits.png" },
		{ filename = "Texture/Aries/Books/left_arrow_32bits.png" },
		{ filename = "Texture/Aries/Books/right_arrow_32bits.png" },
	}
	return list;
end