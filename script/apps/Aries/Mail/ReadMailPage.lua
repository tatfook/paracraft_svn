--[[
Title: 
Author(s): leio
Date: 2013/4/9
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/ReadMailPage.lua");
local ReadMailPage = commonlib.gettable("MyCompany.Aries.Mail.ReadMailPage");
ReadMailPage.ShowPage(eid)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Mail/MailPage.lua");
local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local ReadMailPage = commonlib.gettable("MyCompany.Aries.Mail.ReadMailPage");
ReadMailPage.mail_info = nil;
ReadMailPage.eid = nil;
ReadMailPage.page = nil;
function ReadMailPage.OnInit()
	ReadMailPage.page = document:GetPageCtrl();	
end
function ReadMailPage.RefreshPage()
	if(ReadMailPage.page)then
		ReadMailPage.page:Refresh(0);
	end
end
function ReadMailPage.ShowPage(eid)
	ReadMailPage.eid = eid;
	local url = "script/apps/Aries/Mail/ReadMailPage.teen.html";
	local params = {
			url = url, 
			name = "ReadMailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -760/2,
				y = -470/2,
				width = 760,
				height = 470,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	ReadMailPage.ReadMail(eid);
end
function ReadMailPage.ReadMail(eid)
	MailPage.ReadMail(eid,nil,function(msg)
		ReadMailPage.mail_info = msg;
		ReadMailPage.RefreshPage();
	end)
end
function ReadMailPage.DS_Func(index)
	if(not ReadMailPage.attaches_list)then return 0 end
	if(index == nil) then
		return #(ReadMailPage.attaches_list);
	else
		return ReadMailPage.attaches_list[index];
	end
end