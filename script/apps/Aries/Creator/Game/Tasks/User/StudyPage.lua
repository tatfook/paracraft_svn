--[[
Title: StudyPage
Author(s): 
Date: 2020/8/7
Desc:  
Use Lib:
-------------------------------------------------------
local StudyPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/User/StudyPage.lua");
StudyPage.ShowPage();
--]]
local StudyPage = NPL.export()
local page

StudyPage.grid_data_sources = {
	{name="碎片化学习"},{name="知识岛"},{name="孙子子兵法"},
	{name="视频资源"},{name="Doc"},{name="百度知道"},
}
function StudyPage.OnInit()
    page = document:GetPageCtrl();
end
function StudyPage.ShowPage()
	local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/User/StudyPage.html",
			name = "StudyPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			zorder = 100,
			--app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -600/2,
				y = -500/2,
				width = 600,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

