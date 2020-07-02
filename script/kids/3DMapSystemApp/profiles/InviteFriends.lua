--[[
Title: code behind page for InviteFriends.html
Author(s): LiXizhi
Date: 2008/4/30
Desc: Invite friends by providing (or importing) a list of email addresses and a user-typed message. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/InviteFriends.lua");
-------------------------------------------------------
]]

local InviteFriends = {};
commonlib.setfield("Map3DSystem.App.profiles.InviteFriends", InviteFriends)

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function InviteFriends.OnInit()
	document:GetPageCtrl():SetNodeValue("from", Map3DSystem.User.Name);
end

-- send invitation
function InviteFriends.OnSend(name, values)
	local pageCtrl = document:GetPageCtrl();
	if(InviteFriends.Sending) then
		pageCtrl:SetUIValue("result", "上次的发送尚未返回");
		return 
	end
	
	-- validate emails.
	local to_emails;
	if(values.to) then
		local email;
		for email in string.gfind(values.to, "([A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?)")	 do
			if(not to_emails) then
				to_emails = email;
			else
				to_emails = to_emails..","..email;
			end
		end
	end
	if(not to_emails) then
		pageCtrl:SetUIValue("result", "输入的电子邮箱格式不正确或为空");
		return 
	end
	
	-- send emails.
	local msg = {
		from = values.from,
		to = to_emails,
		message = values.message,
		language = tonumber(values.language),
	};
	commonlib.echo(msg)
	pageCtrl:SetUIValue("result", "正在发送, 请稍后");
	
	InviteFriends.Sending = true;
	
	paraworld.users.Invite(msg, "paraworld", function(msg)
		if(msg and msg.issuccess) then
			pageCtrl:SetUIValue("result", "发送成功!");
		else
			pageCtrl:SetUIValue("result", "发送失败了!");
			commonlib.echo(msg);
		end
		InviteFriends.Sending = false;
	end);
end