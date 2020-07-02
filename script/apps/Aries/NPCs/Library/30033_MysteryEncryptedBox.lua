--[[
Title: 
Author(s): WangTian
Date: 2009/12/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Library/30033_MysteryEncryptedBox.lua");
-------------------------------------------------------
]]
local MysteryEncryptedBox = {

};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MysteryEncryptedBox", MysteryEncryptedBox);
function MysteryEncryptedBox.main()

end
function MysteryEncryptedBox.PreDialog()
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = ExternalUserModule:GetRegionID();

	if (region_id==0) then  -- 仅淘米
		-- show the page as a game object reading MCML page
		local url = "script/apps/Aries/NPCs/Library/30033_MysteryEncryptedBox_codebox.html";
		MyCompany.Aries.Desktop.TargetArea.ShowURLAsGameObjectMCMLPage(url);
	end
	return false
end