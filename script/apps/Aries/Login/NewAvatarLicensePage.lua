--[[
Title: Aries Registration Page
Author(s): LiXizhi
Date: 2009/8/4
Desc:  script/apps/Aries/Login/NewAvatarPage.html
Creating a new avatar, provide nick name, etc, for newly registered users. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/NewAvatarLicensePage.lua");
local NewAvatarLicensePage = commonlib.gettable("MyCompany.Aries.NewAvatarLicensePage");
NewAvatarLicensePage.ShowPage();
-------------------------------------------------------
]]
local NewAvatarLicensePage = commonlib.gettable("MyCompany.Aries.NewAvatarLicensePage");

local CreateAvatarParams = commonlib.gettable("MyCompany.Aries.CreateAvatarParams");

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- true to display license page to the user, otherwise proceed directly to the next step. 
local bDisplayLicensePage = false;
function NewAvatarLicensePage.ShowPage()
	if(bDisplayLicensePage) then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Login/NewAvatarLicensePage.html", 
			name = "NewAvatarPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -960/2,
				y = -560/2,
				width = 960,
				height = 560,
			cancelShowAnimation = true,
		});
	else
		NewAvatarLicensePage.OnNext();
	end
end
-- init
function NewAvatarLicensePage.OnInit()
	page = document:GetPageCtrl();
	CreateAvatarParams.AgreementAssigned = nil;
end


function NewAvatarLicensePage.CheckRead()
	local bChecked = not page:GetValue("checkRead");
	page:SetValue("checkRead", bChecked);
	
	CreateAvatarParams.AgreementAssigned = bChecked;
	page:Refresh(0.1);
end

function NewAvatarLicensePage.OnNext()
	if(page) then
		page:CloseWindow();
	end
	CreateAvatarParams.AgreementAssigned = true;
	
	-- proceed to next step. 
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Login/NewAvatarDisplayPage.html", 
		name = "NewAvatarDisplayPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		allowDrag = false,
		directPosition = true,
			align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
		cancelShowAnimation = true,
	});
end	
