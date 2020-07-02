--[[
Title: MailClient
Author(s): Leio
Date: 2009/5/26
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
MyCompany.Aries.Quest.Mail.MailClient.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
local MailManager = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager")
local MailClient = commonlib.inherit({
		name = "MailClient_instance",
		DefaultFile = "script/apps/Aries/Mail/MailClient.lua",
	}, commonlib.gettable("MyCompany.Aries.Quest.Mail.MailClient"));

function MailClient.Init()
	local self = MailClient;
	if(not self.jc)then
		self.jc = JabberClientManager.CreateJabberClient(Map3DSystem.User.jid);
	end
	MailManager.OnInit();
end
function MailClient.GetJC()
	local self = MailClient;
	return self.jc;
end
function MailClient.GetJID()
	return Map3DSystem.User.jid;
end
function MailClient.SendMessage(msg,jid)
	local self = MailClient;
	commonlib.echo("==============MailClient.SendMessage");
	commonlib.echo({msg,jid});
	if(msg and self.jc and jid)then
		self.jc:activate(jid..":"..self.DefaultFile, msg);
	end
end
function MailClient.HandleMessage(msg)
	local self = MailClient;
	commonlib.echo("==============MailClient.HandleMessage");
	commonlib.echo(msg);
	if(not msg)then return end
	--挑战之旗 挑战成功
	--[[
		msg = {
			msg_type = "challenged",
			sender = nid,
		}
	--]]
	if(msg.msg_type == "challenged")then
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			sender = msg.sender,
			ShowCallbackFunc = function(msg) 
				if(not msg)then return end
				local from_nid = msg.sender or -1;
	
				local nids = tostring(from_nid);
				Map3DSystem.App.HomeLand.HomeLandGateway.GetUserInfo(nids,function(msg)
					if(msg and not msg.error and msg.usersinfo)then
						local usersinfo = msg.usersinfo;
						userinfo = usersinfo[from_nid] or {};
						local name = userinfo.nickname or "";
						local s = string.format([[<div style='margin-left:15px;margin-top:15px;'><a onclick="MyCompany.Aries.Quest.Mail.MailClient.ShowUserInfo" param1='%d'>%s(%d)</a>成功触摸到了你家的挑战之旗，你也获得了1片红枫叶哦！</div>]],from_nid,name,from_nid);
						_guihelper.Custom_MessageBox(s,function(result)
							if(result == _guihelper.DialogResult.OK)then
								Map3DSystem.Item.ItemManager.GetItemsInBag(12, "", function(msg2)
						
								end, "access plus 0 day");
							end
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					end
				end);

			end,
		});
	elseif(msg.msg_type == "gift_remind")then
		if(msg.mail_id)then
			local mail = MailManager.GetMail(msg.mail_id);
			if(mail)then
				mail = commonlib.deepcopy(mail);
				mail.sender = msg.sender;
				MailManager.PushMail(mail);
			end
		end
	elseif(msg.msg_type == "magic_star_reborn_remind")then
		if(msg.mail_id)then
			local mail = MailManager.GetMail(msg.mail_id);
			local nid = msg.nid;
			if(mail and nid)then
				System.App.profiles.ProfileManager.GetUserInfo(nid, "magic_star_reborn_remind", function(msg)
					if(msg == nil or not msg.users or not msg.users[1]) then
						return;
					end	
					local nickname = tostring(msg.users[1].nickname);
					mail = commonlib.deepcopy(mail);
					mail.content = string.format("你的好友%s(%d)的魔法星已经复活了，它拥有神奇的魔法，以后有什么事情可以找他帮忙哦！",nickname or "",nid);
					MailManager.PushMail(mail);
				end);
			end
		end
	elseif(msg.msg_type == "redfruit_remind")then
		if(msg.mail_id)then
			local mail = MailManager.GetMail(msg.mail_id);
			local nid = msg.nid;
			local msg_type = msg.msg_type;
			if(mail and nid)then
				System.App.profiles.ProfileManager.GetUserInfo(nid, "redfruit_remind", function(msg)
					if(msg == nil or not msg.users or not msg.users[1]) then
						return;
					end	
					local nickname = tostring(msg.users[1].nickname);
					mail = commonlib.deepcopy(mail);
					if(mail.page_params)then
						mail.page_params.nid = nid;
					end
					mail.content = string.format([[在你的热情邀请下<a onclick="MyCompany.Aries.Quest.Mail.MailClient.ShowUserInfo" param1='%d'>%s(%d)</a>也来哈奇小镇居住啦！同时你也获得了1颗热心果，记得常联系他哦！！]],nid,nickname or "",nid);
					MailManager.PushMail(mail);
				end);
			end
		end
	--组队 队长邀请队员立即到副本门口
	elseif(msg.msg_type == "team_invite_comehere")then
		--local world_key = msg.world_key;
		--local world = WorldManager:GetWorldInfo(world_key);
		--local name = "";
		--local born_pos;
		--if(world)then
			--name = world.world_title;
			--born_pos = world.born_pos;
		--end
		--local s = string.format("你的队长召唤你们前往%s副本，你是否要立刻过去呢？",name or "");
		--_guihelper.MessageBox(s);
	end
end
function MailClient.ShowUserInfo(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
local function activate()
	if(MyCompany.Aries.Quest.Mail.MailClient and msg.jckey == MyCompany.Aries.Quest.Mail.MailClient.GetJID()) then
		MyCompany.Aries.Quest.Mail.MailClient.HandleMessage(msg)
	end	
end
NPL.this(activate);