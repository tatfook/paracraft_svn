--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/LuluMushroom_Panel.lua");
-------------------------------------------------------
]]
local LuluMushroom_Panel = {

}
commonlib.setfield("MyCompany.Aries.Books.LuluMushroom_Panel",LuluMushroom_Panel);
function LuluMushroom_Panel.GetAssetList()
	local list = {
		{ filename = "texture/Aries/Books/Panel_bg_32bits.png" },
		{ filename = "texture/Aries/Books/Panels/LuluMushroom_content_32bits.png" },
		{ filename = "Texture/Aries/Books/Panel_close_32bits.png" },
	}
	return list;
end