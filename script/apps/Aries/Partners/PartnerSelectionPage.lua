--[[
Title: QQ login page
Author(s): LiXizhi
Date: 2012/10/25
Desc: QQ login page
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/PartnerSelectionPage.lua");
local PartnerSelectionPage = commonlib.gettable("MyCompany.Aries.Partners.PartnerSelectionPage");
PartnerSelectionPage.ShowPage(nil, function(platform_id) end)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Partners/PartnerPlatforms.lua");
local Platforms = commonlib.gettable("MyCompany.Aries.Partners.Platforms");
local PartnerSelectionPage = commonlib.gettable("MyCompany.Aries.Partners.PartnerSelectionPage");

function PartnerSelectionPage.OnInit()
end

-- @param url: the initial url to open
-- @param callback:  a callback function(result) end,  where result is a table {}. containing login result.
--  it defaults to PartnerSelectionPage.OnProcessResultDefault
function PartnerSelectionPage.ShowPage(params, callback)
	
	callback = callback or PartnerSelectionPage.OnProcessResultDefault;
	PartnerSelectionPage.params = params;
	PartnerSelectionPage.callback = callback;

	local width, height = 960, 560;
	local params = {
		url = "script/apps/Aries/Partners/PartnerSelectionPage.html", 
		name = "Platform.PartnerSelectionPagePage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		directPosition = true,
			align = "_ct",
			x = -width/2,
			y = -height/2+40,
			width = width,
			height = height,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	params._page.OnClose = function()
		if(callback) then
			local platform_id;
			if(PartnerSelectionPage.SelectedName) then
				platform_id = Platforms.PLATS[PartnerSelectionPage.SelectedName]
			end
			callback(platform_id);
		end
	end
end