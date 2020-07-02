--[[
Title: TutorialPage.html code-behind script
Author(s): LiXizhi
Date: 2008/6/17
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/TutorialPage.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Encoding.lua");
local L = CommonCtrl.Locale("ParaWorld");
local F = commonlib.Encoding.Utf8ToDefault;

local TutorialPage = {};
commonlib.setfield("Map3DSystem.App.Login.TutorialPage", TutorialPage)




-- template db table
TutorialPage.dsOfflineTutorials = {
	{Title=L"基础篇", SubTitle=L"教你基本人物操作, 使用工具, 创造3D家园, 探索3D社交网络", worldpath=F"worlds/Official/新手之路", preview=F"worlds/Official/新手之路/preview.jpg", },
	{Title=L"儿童篇", SubTitle=L"如果你有7-12岁的孩子, 可以陪他们一起创作, 全面提高儿童的想像力, 创造力, 领导力(建设中...)", worldpath="worlds/Official/DisneyLand", preview="worlds/Official/DisneyLand/preview.jpg", },
	{Title=L"开发篇", SubTitle=L"介绍PEDN开发网, 应用程序架构, 创建属于你的3D互联网产业.(建设中...)", worldpath="worlds/Official/NewUserVillage3", preview="worlds/Official/NewUserVillage3/preview.jpg", },
	{Title=L"提高篇", SubTitle=L"教你制作智能人物, 拍摄电影, 以及部分社交平台功能(建设中...)", worldpath="worlds/Official/NewUserVillage2", preview="worlds/Official/NewUserVillage2/preview.jpg", },
};

-- datasource function for pe:gridview
function TutorialPage.DS_OfflineTutorial_Func(index)
	if(index == nil) then
		return #(TutorialPage.dsOfflineTutorials);
	else
		return TutorialPage.dsOfflineTutorials[index];
	end
end

-- template db table
TutorialPage.dsOnlineTutorials = {
	{Title=L"新手村", SubTitle=L"教你基本人物操作, 使用工具, 创造3D家园, 探索3D社交网络", worldpath=F"worlds/Official/新手之路", preview=F"worlds/Official/新手之路/preview.jpg", },
	{Title=L"儿童村", SubTitle=L"如果你有7-12岁的孩子, 可以陪他们一起创作, 全面提高儿童的想像力, 创造力, 领导力(建设中...)", worldpath="worlds/Official/DisneyLand", preview="worlds/Official/DisneyLand/preview.jpg", },
	{Title=L"开发者村", SubTitle=L"介绍PEDN开发网, 应用程序架构, 创建属于你的3D互联网产业(建设中...)", worldpath="worlds/Official/NewUserVillage3", preview="worlds/Official/NewUserVillage3/preview.jpg", },
	
	{Title=L"高级篇", SubTitle=L"教你制作智能人物, 拍摄电影, 以及部分社交平台功能(建设中...)", worldpath="worlds/Official/NewUserVillage1", preview="worlds/Official/NewUserVillage1/preview.jpg", },
	{Title=L"颁奖岛", SubTitle=L"各种评选活动的颁奖地点(建设中...)", worldpath="worlds/Official/NewUserVillage2", preview="worlds/Official/NewUserVillage2/preview.jpg", },
	{Title=L"情侣岛", SubTitle=L"结交新朋友(建设中...)", worldpath="worlds/Official/NewUserVillage3", preview="worlds/Official/NewUserVillage3/preview.jpg", },
};

-- datasource function for pe:gridview
function TutorialPage.DS_OnlineTutorial_Func(index)
	if(index == nil) then
		return #(TutorialPage.dsOnlineTutorials);
	else
		return TutorialPage.dsOnlineTutorials[index];
	end
end

function TutorialPage.OnInit()
	
	local tabpage = document:GetPageCtrl():GetRequestParam("tab");
    if(tabpage and tabpage~="") then
        document:GetPageCtrl():SetNodeValue("TutorialPageTabs", tabpage);
    end
end
