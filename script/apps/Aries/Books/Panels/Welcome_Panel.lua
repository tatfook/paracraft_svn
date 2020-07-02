--[[
Title: 
Author(s): Leio
Date: 2009/10/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/Welcome_Panel.lua");
-------------------------------------------------------
]]
local Welcome_Panel = {

}
commonlib.setfield("MyCompany.Aries.Books.Welcome_Panel",Welcome_Panel);
function Welcome_Panel.GetAssetList()
	local list = {
		{ filename = "texture/Aries/Books/BBS_bg_32bits.png" },
		{ filename = "texture/Aries/Books/Panels/BBS_content_32bits.png" },
		{ filename = "Texture/Aries/Books/BBS_close_32bits.png" },
	}
	return list;
end