--[[
Title: building quest task
Author(s): LiXizhi
Date: 2013/11/13
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/GUI/HelpPage.lua");
local HelpPage = commonlib.gettable("ParaCraft.Mobile.GUI.HelpPage");
HelpPage.ShowPage();
-------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/BuildQuestTask.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/BuildQuestProvider.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/BuilderFramePage.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandManager.lua");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local BuilderFramePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.BuilderFramePage");
local BuildQuest = commonlib.gettable("MyCompany.Aries.Game.Tasks.BuildQuest");
local BuildQuestProvider =  commonlib.gettable("MyCompany.Aries.Game.Tasks.BuildQuestProvider");

local HelpPage = commonlib.gettable("ParaCraft.Mobile.GUI.HelpPage");

local type_ds = {
	{name = "type",attr = {text=L"新手教程",index = 1,category="tutorial"}},
	--{name = "type",attr = {text=L"建筑百科",index = 2,category="blockwiki"}},
	{name = "type",attr = {text=L"命令帮助",index = 2,category="command"}},
}

local page;
function HelpPage.ShowPage()
	MyCompany.Aries.Creator.Game.Desktop.ShowMobileDesktop(false);

	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/mobile/paracraft/GUI/HelpPage.html", 
		name = "HelpPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = false,
		bShow = bShow,
		zorder = -5,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
	});
end

function HelpPage.ClosePage()
	if(page) then
		page:CloseWindow();
		MyCompany.Aries.Creator.Game.Desktop.ShowMobileDesktop(true);
	end
end

function HelpPage.OnInit()
	BuildQuestProvider.Init();
	BuildQuest.cur_theme_index = BuildQuest.cur_theme_index or 1;
	page = document:GetPageCtrl();
	
	if(HelpPage.inited) then
		return;
	end
	HelpPage.select_type_index = HelpPage.select_type_index or 1;
	HelpPage.select_item_index = HelpPage.select_item_index or 1;
	HelpPage.cur_category = HelpPage.GetCurrentCategory();
	HelpPage.OnInitDS();
	HelpPage.select_task_index = HelpPage.select_task_index or 1;
	HelpPage.inited = true;
end

local blockTypes = {
	{text=L"方块", index=1, name="static",     enabled=true},
	{text=L"装饰", index=2, name="deco",       enabled=true},
	{text=L"人物", index=3, name="character",  enabled=true},
	{text=L"机关", index=4, name="gear",	     enabled=true},
}

function HelpPage.OnInitDS()
	for i = 1,#type_ds do
		local typ = type_ds[i];
		if(typ["attr"]) then
			typ["attr"]["select_item_index"] = 1;
		end
		if(i == 1 or i == 2) then
			local ds = BuildQuestProvider.GetThemes_DS(typ["attr"].category);
			for j = 1,#ds do
				local theme = ds[j];
				local item = {name="item",attr={text=theme.name,item_index=j,type_index = i,category=typ["attr"]["category"]}}
				typ[#typ + 1] = item;
			end
		elseif(i == 3) then
			local ds = CommandManager:GetCmdTypeDS();
			local j = 1;
			for k,v in pairs(ds) do
				local item = {name="item",attr={text=k,item_index=j,type_index = i,category=typ["attr"]["category"],}}
				typ[#typ + 1] = item;
				j = j + 1;
			end
		end
	end
end

function HelpPage.GetCurrentCategory(index)
	local ds = HelpPage.GetHelpDS();
	local category = ds[index or HelpPage.select_type_index]["attr"]["category"];
	return category
end

function HelpPage.GetHelpDS()
	return type_ds;
end

function HelpPage.GetCurGridviewDS(name)
	local ds;
	if(HelpPage.select_type_index == 3) then
		if(not name) then
			name = type_ds[3][1]["attr"]["text"];
		end
		local cmd_types = CommandManager:GetCmdTypeDS();
		ds = cmd_types[name] or {};
	else
		ds = {};
	end
	return ds;
end

function HelpPage.GetGridview_DS(index)
	local ds;
	if(HelpPage.select_type_index == 1 or HelpPage.select_type_index == 2) then
		ds = BuildQuestProvider.GetTasks_DS(HelpPage.select_item_index,HelpPage.cur_category);
	elseif(HelpPage.select_type_index == 3) then
		if(not HelpPage.cur_gridview_ds) then
			HelpPage.cur_gridview_ds = HelpPage.GetCurGridviewDS();
		end
		ds = HelpPage.cur_gridview_ds;
	end
	if(not ds) then
		return 0;
	end
	if(not index) then
		return #ds;
	else
		return ds[index];
	end
end

function HelpPage.ClosePage()
	if(page) then
		page:CloseWindow();
		if(System.options.IsMobilePlatform) then
			MyCompany.Aries.Creator.Game.Desktop.ShowMobileDesktop(true);
		end
	end
end

function HelpPage.ChangeTask(name,mcmlNode)
    local attr = mcmlNode.attr;
    local task_index = tonumber(attr.param1);
    HelpPage.select_task_index = task_index;
	page:Refresh(0.1);
end