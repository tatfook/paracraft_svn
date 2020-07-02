--[[
Title: 
Author(s): Leio
Date: 2009/10/10
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/OpenGameRemindPage.lua");
Map3DSystem.App.PENote.OpenGameRemindPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
-- default member attributes
local OpenGameRemindPage = {
	page = nil,
	isShow = false,
	fromname = nil,
	toname = nil,
	content = nil,
}
commonlib.setfield("Map3DSystem.App.PENote.OpenGameRemindPage",OpenGameRemindPage);

function OpenGameRemindPage.OnInit()
	local self = OpenGameRemindPage;
	self.page = document:GetPageCtrl();
end
function OpenGameRemindPage.ShowPage()
	local self = OpenGameRemindPage;
	if(self.isShow)then return end
	local url;
	if(CommonClientService.IsTeenVersion())then
		return
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/PENote/Pages/OpenGameRemindPage.html", 
			name = "OpenGameRemindPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -283,
				y = -204,
				width = 566,
				height = 408,
		});
	self.isShow = true;
end
function OpenGameRemindPage.ClosePage()
	local self = OpenGameRemindPage;
	if(not self.isShow)then return end
	
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="OpenGameRemindPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.isShow = false;
end

function OpenGameRemindPage.Update(h,m,s)
	local self = OpenGameRemindPage;
	if(self.page and h and m and s)then
		function getString(t)
			t = tonumber(t);
			if(not t)then return "" end
			if(t< 10)then
				t = "0" .. t;
			else
				t = tostring(t);
			end
			return t;
		end
		h = getString(h);
		m = getString(m);
		s = getString(s);
		self.page:SetUIValue("time_text_sprite_h",h);
		self.page:SetUIValue("time_text_sprite_m",m);
		self.page:SetUIValue("time_text_sprite_s",s);
	end
end
function OpenGameRemindPage.OpenWeb()
	local url = "http://haqi.61.com/main/";
	Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath= url, silentmode=true});
end
