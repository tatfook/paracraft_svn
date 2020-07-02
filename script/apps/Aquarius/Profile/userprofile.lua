--[[
Title: code behind for page userprofile.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/userprofile.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local userprofilePage = {};
commonlib.setfield("MyCompany.Aquarius.userprofilePage", userprofilePage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function userprofilePage.OnInit()
	local self = document:GetPageCtrl();
	local uid = self:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
    if(uid and uid~="") then
		self:SetNodeValue("uid", uid);
		-- this is done elsewhere
		--local bFisrtTime = true;
		--Map3DSystem.App.profiles.ProfileManager.GetUserInfo(uid, "profilepage", function(msg)
			--if(msg and msg.users and msg.users[1]) then
				--local user = msg.users[1];
				--local nickname = user.nickname;
				--if(user.nickname) then
					--self:SetWindowText(string.format("%s 的个人信息", user.nickname));
				--end
			--end
		--end)
		--bFisrtTime = nil;
	end	
end

function userprofilePage.OnTeleportToUser(uid)
	Map3DSystem.App.profiles.ProfileManager.TeleportToUser(uid)
end

function userprofilePage.OnSendMail(uid)
end

function userprofilePage.OnAddAsFriend(uid)
	Map3DSystem.App.Commands.Call("Profile.Aquarius.AddAsFriend", {uid = uid});
end

function userprofilePage.OnChatWith(uid)
	Map3DSystem.App.Commands.Call("Profile.Chat.ChatWithContactImmediate", {uid = uid});
end

function userprofilePage.OnChatHistory(uid)
end

function userprofilePage.OnBlockUser(uid)
	Map3DSystem.App.Commands.Call("Profile.Aquarius.NA");
end
function userprofilePage.OnVisitHomeZone(uid)
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneView.lua");
	Map3DSystem.App.HomeZoneView.Start(uid)
end