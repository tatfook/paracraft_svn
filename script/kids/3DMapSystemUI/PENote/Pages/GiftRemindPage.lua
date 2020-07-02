--[[
Title: 
Author(s): Leio
Date: 2009/10/10
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/GiftRemindPage.lua");
-------------------------------------------------------
]]
-- default member attributes
local GiftRemindPage = {
	page = nil,

	fromname = nil,
	toname = nil,
	content = nil,
}
commonlib.setfield("Map3DSystem.App.PENote.GiftRemindPage",GiftRemindPage);

function GiftRemindPage.OnInit()
	local self = GiftRemindPage;
	self.page = document:GetPageCtrl();
end
function GiftRemindPage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/PENote/Pages/GiftRemindPage.html", 
			name = "GiftRemindPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -460,
				y = -260,
				width = 920,
				height = 512,
		});
end
function GiftRemindPage.ClosePage()
	local self = GiftRemindPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="GiftRemindPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	--如果在自己家并且 有收到新的礼物
	if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
		Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftInfo();
		Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftDetail();
	end
	self.Clear();
end
function GiftRemindPage.Bind(toname,fromname,content,date)
	local self = GiftRemindPage;
	self.fromname = fromname;
	self.toname = toname;
	self.content = content;
	self.date = date;
end
function GiftRemindPage.Clear()
	local self = GiftRemindPage;
	self.page = nil;
	self.fromname = nil;
	self.toname = nil;
	self.content = nil;
	self.date = nil;
end
function GiftRemindPage.GoHomeNow()
	local self = GiftRemindPage;
	self.ClosePage();
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
	--如果在自己家并且 有收到新的礼物
	if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
		Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftInfo();
		Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftDetail();
	else
		Map3DSystem.App.HomeLand.HomeLandGateway.Gohome(Map3DSystem.User.nid)
	end
end
