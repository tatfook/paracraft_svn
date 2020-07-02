--[[
Title: 
Author(s): Leio
Date: 2009/11/19
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/SystemChat.lua");
MyCompany.Aries.Chat.SystemChat.ShowPage("test");

Map3DSystem.App.PENote.PENote_Client:HandleMessage({tag = "hello斯蒂芬斯蒂芬斯蒂芬斯蒂芬收到仿盛大发生的发生的仿盛大发生的发生大幅生大幅上的放松地方上的都是",
													note = "from_manager_to_10000"
													});
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
-- default member attributes
local SystemChat = {
	page = nil,
	txt = nil,
}
commonlib.setfield("MyCompany.Aries.Chat.SystemChat",SystemChat);

function SystemChat.OnInit()
	local self = SystemChat;
	self.page = document:GetPageCtrl();
end
function SystemChat.ShowPage(txt)
	local self = SystemChat;
	if(not txt or txt == "" or txt == "refresh")then return end
	local url = "";
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/Chat/SystemChat.teen.html";
	else
		url = "script/apps/Aries/Chat/SystemChat.html";
		txt = "<b>哈奇小镇管理处说:</b><br />"..txt
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "SystemChat.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -265,
				y = -170,
				width = 535,
				height = 340,
		});
	if(self.page)then
		self.txt = txt;
		self.page:Refresh(0);
	end
end
function SystemChat.ClosePage()
	local self = SystemChat;
	if(self.page)then
		self.page:CloseWindow();
	end
	self.txt = nil;
end
