--[[
Title: code behind for page AriesQuestDialogPage.html
Author(s): LiXizhi
Date: 2010/8/31
Desc: Quest dialog page
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/AriesQuestDialogPage.lua");
-------------------------------------------------------
]]
local AriesQuestDialogPage = commonlib.gettable("MyCompany.Aries.Dialog.AriesQuestDialogPage");

local page;

function AriesQuestDialogPage.OnInit()
	page = document:GetPageCtrl();
end

