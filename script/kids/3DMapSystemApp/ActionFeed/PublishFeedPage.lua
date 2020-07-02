--[[
Title: code behind page for PublishFeedPage.html
Author(s): LiXizhi
Date: 2008/6/1
Desc: publish user defined action feed to all or selected friends
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/PublishFeedPage.lua");

-- you can specify who to receive by uid parameter and content
script/kids/3DMapSystemApp/ActionFeed/PublishFeedPage.html?uid=ABC&content=hello there
-- this will send to all user. 
script/kids/3DMapSystemApp/ActionFeed/PublishFeedPage.html
-------------------------------------------------------
]]

local PublishFeedPage = {};
commonlib.setfield("Map3DSystem.App.ActionFeed.PublishFeedPage", PublishFeedPage)

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function PublishFeedPage.OnInit()
	local touid = document:GetPageCtrl():GetRequestParam("uid");
    if(touid and touid~="") then
        document:GetPageCtrl():SetNodeValue("receiver", "uid");
    end
    
    local content = document:GetPageCtrl():GetRequestParam("content");
    if(content and content~="") then
		document:GetPageCtrl():SetNodeValue("content", content);
    end
end

function PublishFeedPage.OnClose()
	document:GetPageCtrl():CloseWindow();
end

-- user clicks to send the feed. 
function PublishFeedPage.SendFeed(btnName, values)
	local pageCtrl = document:GetPageCtrl();
	local content = values["content"];
	if(content and content~="") then
		values["content"] = string.gsub(content, "[\r\n]" , "") -- remove return letters. 
		
		NPL.load("(gl)script/ide/XPath.lua");
		-- encode the content string
		values["content"] = commonlib.XPath.XMLEncodeString(values["content"]);

		pageCtrl:SetUIValue("result", "正在发送, 请稍候...");
		local to_uids;
		if(values["receiver"]~="all") then
			values.uid = pageCtrl:GetRequestParam("uid")
		end
		
		values.silentMode = true;
		values.callbackFunc = function(issuccess)
			if(issuccess) then
				pageCtrl:SetUIValue("result", "发送成功");
			else
				pageCtrl:SetUIValue("result", "无法发送");
			end	
		end
		Map3DSystem.App.Commands.Call("Profile.ActionFeed.Add", values)
	else
		pageCtrl:SetUIValue("result", "请输入正文");	
	end	
end

-- open a dialog to select to which friends we will send the message. 
function PublishFeedPage.SelectFriends(btnName)
	_guihelper.MessageBox("此功能稍后可用");
end