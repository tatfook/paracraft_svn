--[[
Title: PENoteWnd
Author(s): Leio
Date: 2009/5/26
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteWnd.lua");
Map3DSystem.App.PENote.PENoteWnd.Init();

local jid = "16344@test.pala5.cn";
local to_name =  "16344"
local from_name =  "16344"
local msg = {to_name = to_name, from_name = from_name, note = "pet_dead",};
Map3DSystem.App.PENote.PENote_Client:SendMessage(msg,jid);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteClient.lua");
local PENoteWnd = {
	name = "PENoteWnd_instance",
}
commonlib.setfield("Map3DSystem.App.PENote.PENoteWnd",PENoteWnd);
function PENoteWnd.OnPush(noteClient)
	if(not noteClient)then return end
	local msgPool = Map3DSystem.App.PENote.PENote_Client.msgPool;
	local len = #msgPool;
	MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(true,len);
	PENoteWnd.CheckIsEmpty();
end
function PENoteWnd.OnPush_Loudspeaker(noteClient)
	MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			ShowCallbackFunc = function(msg) PENoteWnd.OnPush_Loudspeaker_Callback() end,
		});
end
function PENoteWnd.OnPush_Loudspeaker_Callback()
	local msgPool_loudspeaker = Map3DSystem.App.PENote.PENote_Client.msgPool_loudspeaker;
	if(not msgPool_loudspeaker)then return end
	local len = #msgPool_loudspeaker;
	
	local msg = msgPool_loudspeaker[len];
	table.remove(msgPool_loudspeaker,len);
	len =  #msgPool_loudspeaker;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteTemplate.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteLibs.lua");
	local note = Map3DSystem.App.PENote.PENoteLibs.GetNote(msg);
	Map3DSystem.App.PENote.PENoteTemplate.Show(note);
	
end
function PENoteWnd.__ShowBox()
	local msgPool = Map3DSystem.App.PENote.PENote_Client.msgPool;
	if(not msgPool)then return end
	local len = #msgPool;
	
	local msg = msgPool[len];
	table.remove(msgPool,len);
	len =  #msgPool;
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteTemplate.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteLibs.lua");
	local note = Map3DSystem.App.PENote.PENoteLibs.GetNote(msg);
	Map3DSystem.App.PENote.PENoteTemplate.Show(note);
	PENoteWnd.CheckIsEmpty();
end
function PENoteWnd.ShowBox()
	if(MyCompany.Aries.Quest.Mail.MailManager.HasMail())then
		MyCompany.Aries.Quest.Mail.MailManager.ShowMail();
	else
		PENoteWnd.__ShowBox();
	end
end
function PENoteWnd.Init()
	if(not Map3DSystem.App.PENote.PENote_Client)then
		Map3DSystem.App.PENote.PENote_Client = Map3DSystem.App.PENote.PENoteClient:new();
		Map3DSystem.App.PENote.PENote_Client.OnPush = Map3DSystem.App.PENote.PENoteWnd.OnPush;
		Map3DSystem.App.PENote.PENote_Client.OnPush_Loudspeaker = Map3DSystem.App.PENote.PENoteWnd.OnPush_Loudspeaker;
	end
	
end
function PENoteWnd.CheckIsEmpty()
	local msgPool = Map3DSystem.App.PENote.PENote_Client.msgPool;
	local len = 0;
	if(msgPool)then 
		len = len + #msgPool;
	end
	len = len + MyCompany.Aries.Quest.Mail.MailManager.GetLength() or 0;
	if(len <= 0)then
		MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(false,len);
	else
		MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(true,len);
	end
end
	
	