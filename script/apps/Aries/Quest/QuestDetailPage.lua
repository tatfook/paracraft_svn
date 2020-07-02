--[[
Title: 
Author(s): Leio
Date: 2010/09/12
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestDetailPage.lua");
local QuestDetailPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPage");
-------------------------------------------------------
]]
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestDetailPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPage");
local LOG = LOG;
NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
function QuestDetailPage.OnInit()
	local self = QuestDetailPage;
	self.page = document:GetPageCtrl();
end
function QuestDetailPage.ClosePage()
	local self = QuestDetailPage;
	if(self.page)then
		self.page:CloseWindow();
	end	
end

-- called immediately after opening the dialog page
function QuestDetailPage.EnterDialogMode()
	MyCompany.Aries.HandleKeyboard.EnterDialogMode(QuestDetailPage.OnKeyDownProc);
end

-- called after closing the dialog page
function QuestDetailPage.LeaveDialogMode()
	MyCompany.Aries.HandleKeyboard.LeaveDialogMode();
end

function QuestDetailPage.OnKeyDownProc(virtual_key)
	-- virtual_key == Event_Mapping.EM_KEY_SPACE or 
	if(virtual_key == Event_Mapping.EM_KEY_ENTER or virtual_key == Event_Mapping.EM_KEY_X) then
		-- force user to click on the user interface or read the text. In case the user is pressing X key too fast. 
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		QuestDetailPage.ClosePage();
	end
end

function QuestDetailPage.ShowPage(id,showbutton)
	local self = QuestDetailPage;
	if(not id)then return end
	self.extra_reward_list,self.req_num,self.need_select= QuestPane.GetExtraReword(id);

	local url = string.format("script/apps/Aries/Quest/QuestDetailPage.html?id=%d&showbutton=%d",id,showbutton or -1);
	local params = {
		url = url, 
		name = "QuestDetailPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 1,
		isTopLevel = true,
		allowDrag = false,
		directPosition = true,
			align = "_ct",
			x = -422/2,
			y = -250,
			width = 422,
			height = 450,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page) then
		QuestDetailPage.EnterDialogMode();
		params._page.OnClose = function(bDestroy)
			QuestDetailPage.LeaveDialogMode();
		end
	end
end
function QuestDetailPage.GetExtraReword()
	local self = QuestDetailPage;
	return self.extra_reward_list,self.req_num,self.need_select;
end