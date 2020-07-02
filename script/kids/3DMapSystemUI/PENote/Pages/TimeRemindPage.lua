--[[
Title: 
Author(s): Leio
Date: 2009/10/10
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/TimeRemindPage.lua");
Map3DSystem.App.PENote.TimeRemindPage.Bind("toname","fromname","士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫士大夫离开士大夫克里斯多夫\顺口溜放声大哭雷锋精神的手段来开发建设带来快捷方式的斯洛伐克技术的克里夫","date")
--Map3DSystem.App.PENote.TimeRemindPage.Bind("toname","fromname","aaaa","date")
Map3DSystem.App.PENote.TimeRemindPage.ShowPage();
-------------------------------------------------------
]]
-- default member attributes
local TimeRemindPage = {
	page = nil,

	fromname = nil,
	toname = nil,
	content = nil,
}
commonlib.setfield("Map3DSystem.App.PENote.TimeRemindPage",TimeRemindPage);

function TimeRemindPage.OnInit()
	local self = TimeRemindPage;
	self.page = document:GetPageCtrl();
end
function TimeRemindPage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/PENote/Pages/TimeRemindPage.html", 
			name = "TimeRemindPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -509,
				y = -340,
				width = 1018,
				height = 681,
		});
end
function TimeRemindPage.ClosePage()
	local self = TimeRemindPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="TimeRemindPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.Clear();
end
function TimeRemindPage.Bind(toname,fromname,content,date)
	local self = TimeRemindPage;
	self.fromname = fromname;
	self.toname = toname;
	self.content = content;
	self.date = date;
end
function TimeRemindPage.Clear()
	local self = TimeRemindPage;
	self.page = nil;
	self.fromname = nil;
	self.toname = nil;
	self.content = nil;
	self.date = nil;
end
