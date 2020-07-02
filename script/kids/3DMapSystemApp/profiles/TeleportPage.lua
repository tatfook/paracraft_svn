--[[
Title: code behind page for TeleportPage.html
Author(s): LiXizhi
Date: 2008/7/15
Desc: 
teleport page displays necessary info to guide the current user to teleport to another user's avatar. 
This is usually used when we meet a stranger via chat or search and wants to teleport to the world where the user avatar is currently in. 
This allows face-to-face communication between the two users in real time.

The procedure is below. 
   * It first finds the JID of the target uid.
   * Next it ask the JID via JGSL_query interface about the world info, such as serverJID and world fileID.
   * Next it ask for the world file download url from the world file id. 
   * finally, it is able to construct the final page to download the world and connects to the serverJID. The user needs to click teleport button to launch the world
   * once inside the world, the user can first teleport to the side of the avatar via in-world user list page. 

<verbatim>
	script/kids/3DMapSystemApp/profiles/TeleportPage.html?uid=loggedinuser
	-- one can force using a given jid or serverJID
	script/kids/3DMapSystemApp/profiles/TeleportPage.html?uid=loggedinuser&jid=001@test.pala5.cn
	script/kids/3DMapSystemApp/profiles/TeleportPage.html?uid=loggedinuser&server=1100@pala5.cn
	-- nickname is only used for display and nothing else.
	script/kids/3DMapSystemApp/profiles/TeleportPage.html?uid=loggedinuser&nickname=ABC
</verbatim>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/TeleportPage.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");

local TeleportPage = {};
commonlib.setfield("Map3DSystem.App.profiles.TeleportPage", TeleportPage)

---------------------------------
-- page event handlers
---------------------------------

-- there 4 fetching stages: 
-- It first finds the JID of the target uid.
-- Next it ask the JID via JGSL_query interface about the world info, such as serverJID and world fileID.
-- Next it ask for the world file download url from the world file id. 
-- finally, it is able to construct the final page to download the world and connects to the serverJID. The user needs to click teleport button to launch the world
-- once inside the world, the user can first teleport to the side of the avatar via in-world user list page. 
function TeleportPage.OnInit()
	local self = document:GetPageCtrl();
	
	local uid = self:GetRequestParam("uid");
	if(uid == nil or uid=="" or uid == "loggedinuser") then
		-- get current user ID as the uid
		uid = Map3DSystem.App.profiles.ProfileManager.GetUserID();
	end
	
	if(uid==nil) then
		self:SetNodeValue("result", "没有指定用户");
	end	
	
	if(not Map3DSystem.JGSL.GetJID()) then
		self:SetNodeValue("result", "您没有登录到服务器, 无法传送");
		return;
	end
	
	local nickname = self:GetRequestParam("nickname"); -- only used for display
	if(nickname) then
		self:SetNodeValue("value", nickname)
	end

	local jid = self:GetNodeValue("jid") or self:GetRequestParam("jid");
	if(self:GetRequestParam("jid")) then
		self:SetNodeValue("jid", self:GetRequestParam("jid"))
	end
	
	local server = self:GetNodeValue("server") or self:GetRequestParam("server");
	if(self:GetRequestParam("server")) then
		self:SetNodeValue("server", self:GetRequestParam("server"))
	end
	
	local worldpath = self:GetNodeValue("worldpath");
	
	local pos = self:GetNodeValue("pos");
	
	--
	-- fetch the jid of the given uid 
	-- 
	if(not jid) then
		self:SetNodeValue("progress", 20);
		local bFirstTime = true
		Map3DSystem.App.profiles.ProfileManager.GetJID(uid, function(jid_)
			if(not jid_) then
				self:SetNodeValue("result", "无法读取目标用户的JID");
			else
				self:SetNodeValue("jid", jid_)
				jid = jid_;
			end
			if(not bFirstTime) then
				self:Refresh();
			end	
		end);
		bFirstTime = nil;
		if(not jid) then return end
	end
	
	--
	-- query the jid user about its server, worldpath and pos.
	-- 
	if(not server or not worldpath or not pos) then
		self:SetNodeValue("progress", 40);
		local bFirstTime = true
		-- get land info
		Map3DSystem.JGSL.query.GetWorldInfo(jid, function(worldinfo)
			if(worldinfo) then
				server = worldinfo.server;
				worldpath = worldinfo.worldpath;
				local displayPos;
				if(worldinfo.x and worldinfo.y and worldinfo.z) then
					pos = string.format("%f,%f,%f", worldinfo.x, worldinfo.y, worldinfo.z)
					displayPos = string.format("%.0f,%.0f,%.0f", worldinfo.x, worldinfo.y, worldinfo.z);
				end	
				--update node values
				self:SetNodeValue("server", server)
				self:SetNodeValue("worldpath", worldpath)
				self:SetNodeValue("pos", pos)
			else
				self:SetNodeValue("result", string.format("传送失败, %s不希望被别人找到", nickname or "用户"));
			end	
			if(not bFirstTime) then
				self:SetNodeValue("progress", 60);
				self:Refresh();
			end	
		end);
		bFirstTime = nil;
		if(not server or not worldpath or not pos) then return end
	end
	
	-- 
	-- we have complete info of where the target user is, let us teleport to it
	--
	if(server and worldpath and pos) then
		if(worldpath == ParaWorld.GetWorldDirectory()) then
			local x,y,z = string.match(pos, "([^,]+),([^,]+),([^,]+)");
			x = tonumber(x)
			y = tonumber(y)
			z = tonumber(z)
			if(x and y and z) then
				commonlib.log("successfully teleported the user to %s\n", pos)
				local radius = 2;
				ParaScene.GetPlayer():SetPosition(x+ParaGlobal.random()*radius, y, z+ParaGlobal.random()*radius);
				self:SetValue("progress", 100);
				self:SetNodeValue("result", "传送成功!");
				self:CloseWindow();
			else
				self:SetNodeValue("result", "对方提供的位置有误");
			end
		else
			self:SetNodeValue("result", "您和对方不在同一个世界中");
		end	
	end
end

