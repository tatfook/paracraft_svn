--[[
Title: code behind of welcome page
Author(s): LiXizhi
Date: 2008.6.16
Desc: a common welcome page that all application can use to display an application welcome page that only shows to the user for the first time. 
the user can click whether the application will show up the next time the application is switched to. 

---++ Page redirect
Any application also display this mcml page with a redirect url that when the user clicks OK button, the current page will be redirected to it. 
<verbatim>
script/kids/3DMapSystemUI/Settings/WelcomePage.html?url=ContentPage&redirect=RedirectPage&autoredirect=true
</verbatim>
if the autoredirect is true, it will automatically redirect to a page when the user has previously canceled content url page

if redirect page is not specified it will close the window call calling the "File.WelcomePage" command. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Settings/WelcomePage.lua");
script/kids/3DMapSystemUI/Settings/WelcomePage.html?appkey=Creator_GUID&url=the mcml page url containing the welcome page for a given application.
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local WelcomePage = {};
commonlib.setfield("Map3DSystem.App.Settings.WelcomePage",  WelcomePage);

-- init
function WelcomePage.OnInit()
	local self = document:GetPageCtrl();
	local url = self:GetRequestParam("url");
	local appkey = self:GetRequestParam("appkey");
	local autoredirect = self:GetRequestParam("autoredirect");
	local redirect = self:GetRequestParam("redirect");
	if(url) then
		local url_pages = Map3DSystem.App.Settings.app:ReadConfig("urls", {})
		local bDonotShowNextTime = url_pages[url];
		
		if(bDonotShowNextTime and autoredirect and redirect) then
			self:Redirect(redirect,nil,nil, 0);
		else
			-- set content
			self:SetNodeValue("content", url)
			self:SetNodeValue("bShowNextTime", not bDonotShowNextTime)
		end	
	end	
end

-- save welcome page settings. 
-- @param filepath: world path 
function WelcomePage.SaveSettings(bDonotShowNextTime)
	if(not bDonotShowNextTime) then
		bDonotShowNextTime = nil;
	end
	local self = document:GetPageCtrl();
	local url = self:GetRequestParam("url")
	if(url) then
		local url_pages = Map3DSystem.App.Settings.app:ReadConfig("urls", {})
		
		if(url_pages[url] ~= bDonotShowNextTime) then
			url_pages[url] = bDonotShowNextTime;
			Map3DSystem.App.Settings.app:WriteConfig("urls", url_pages)
			Map3DSystem.App.Settings.app:SaveConfig();
		end
	end
end

function WelcomePage.OnOK(name, values)
	local self = document:GetPageCtrl();
	-- save settings. 
	WelcomePage.SaveSettings(not values["bShowNextTime"]);
	
	local url = self:GetRequestParam("url");
	local redirect = self:GetRequestParam("redirect");
	if(redirect and url) then
		self:Redirect(redirect,nil,nil, 0);
	else
		-- close the window.
		local command = Map3DSystem.App.Commands.GetCommand("File.WelcomePage");
		if(command) then
			command:Call({bShow=false});
		end		
	end	
end