--[[
Title: code behind for page AppDirectoryPage.html
Author(s): LiXizhi
Date: 2009/2/20
Desc:  script/apps/Aquarius/Desktop/AppDirectoryPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/AppDirectoryPage.lua");
MyCompany.Aquarius.AppDirectoryPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]

local AppDirectoryPage = {};
commonlib.setfield("MyCompany.Aquarius.AppDirectoryPage", AppDirectoryPage)

-- singleton
local page;
---------------------------------
-- page event handlers
---------------------------------

-- init
function AppDirectoryPage.OnInit()
	page = document:GetPageCtrl();
end

local AllApps = nil;
local function LoadUserInstalledApp()
	AllApps = {};
	-- load initial data set. 
	local key, app;
	for key, app in ipairs(Map3DSystem.App.AppDirectory) do
		AllApps[#AllApps+1] = {Title = app.Title or app.SubTitle or app.name, app_key = app.app_key, icon = app.icon};
	end
end

-- datasource function for pe:gridview
function AppDirectoryPage.DS_AppDirectory_Func(index)
	if(not AllApps) then
		LoadUserInstalledApp();
	end
	if(index == nil) then
		return #(AllApps);
	else
		return AllApps[index];
	end
end

