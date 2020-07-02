--[[
Title: HaqiAmbassadorSignContract
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Ambassador/30133_HaqiAmbassadorSignContract.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/NPCs/Ambassador/30133_HaqiAmbassadorSignContract_panel.lua");
-- create class
local libName = "HaqiAmbassadorSignContract";
local HaqiAmbassadorSignContract = {
	
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiAmbassadorSignContract", HaqiAmbassadorSignContract);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- HaqiAmbassadorSignContract.main
function HaqiAmbassadorSignContract.main()
end

function HaqiAmbassadorSignContract.PreDialog()
	local self = HaqiAmbassadorSignContract;
	--签约只对淘米有效
	local region_id = ExternalUserModule:GetRegionID();
	if(region_id ~= 0)then
		return false;
	end
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/Ambassador/30133_HaqiAmbassadorSignContract_panel.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "30133_HaqiAmbassadorSignContract_panel", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -854/2,
			y = -549/2,
			width = 854,
			height = 549,
	});
	MyCompany.Aries.Quest.NPCs.HaqiAmbassadorSignContract_panel.Load();
	return false;
end
----是否已经签约
--function HaqiAmbassadorSignContract.IsSigned()
	--local ItemManager = System.Item.ItemManager;
	--local hasGSItem = ItemManager.IfOwnGSItem;
	--local gsid = 50193;
	--local bHas, guid = hasGSItem(gsid);
	--local count = 0;
	--local item;
	--if(bHas == true) then
		--item = ItemManager.GetItemByGUID(guid);
		--if(item and item.guid > 0) then
			--count = item.copies;
		--end
	--end
	--commonlib.echo("=========HaqiAmbassadorSignContract.IsSigned item");
	--commonlib.echo(item);
	--if( count > 0)then
		--return true;
	--end
--end