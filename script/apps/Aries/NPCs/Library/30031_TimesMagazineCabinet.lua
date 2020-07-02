--[[
Title: 
Author(s): Leio
Date: 2009/12/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Library/TimesMagazineCabinet.lua");
-------------------------------------------------------
]]
local TimesMagazineCabinet = {

};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.TimesMagazineCabinet", TimesMagazineCabinet);
function TimesMagazineCabinet.main()

end
function TimesMagazineCabinet.PreDialog()
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = ExternalUserModule:GetRegionID();

	if (region_id==0) then  -- ½öÌÔÃ×
		NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.lua");
		MyCompany.Aries.Books.TimesMagazineCabinet.ShowPage();
	end
	return false;
end