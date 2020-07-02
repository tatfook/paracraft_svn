--[[
Title:
Author(s): Leio
Date: 2010/10/26
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/MailManager_MagicStar.lua");
local MailManager_MagicStar = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager_MagicStar")
MailManager_MagicStar.SentLevelMail(0)

NPL.load("(gl)script/apps/Aries/Mail/MailManager_MagicStar.lua");
local MailManager_MagicStar = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager_MagicStar")
MailManager_MagicStar.SentRebornMail();

NPL.load("(gl)script/apps/Aries/Mail/MailManager_MagicStar.lua");
local MailManager_MagicStar = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager_MagicStar")
MailManager_MagicStar.SentMailByID(10021);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
local Friends = commonlib.gettable("MyCompany.Aries.Friends");

NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
local MailManager = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager")

local MailManager_MagicStar = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager_MagicStar")
--魔法星升级
function MailManager_MagicStar.SentLevelMail(mlel)
	if(not mlel)then return end
	local id;
	if(mlel == 0 or mlel == 1)then
		id = 10011
	elseif(mlel >= 10)then
		id = 10020
	else
		id = 10010+ mlel;
	end
	MailManager.PushMailByID(id);
end
--魔法星能量值从0变为非0
function MailManager_MagicStar.SentRebornMail()
	local count = Friends.GetFriendCountInMemory();
	local i;
	for i = 1, count do
		local nid = Friends.GetFriendNIDByIndexInMemory(i);
		if(nid) then
			Map3DSystem.App.profiles.ProfileManager.GetJID(nid, function(jid)
				if(jid)then
					MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
						msg_type = "magic_star_reborn_remind",
						nid = Map3DSystem.User.nid,
						mail_id = 10023,
					},jid);
				end
			end)
		end
	end

end
function MailManager_MagicStar.SentMailByID(id)
	MailManager.PushMailByID(id);
end