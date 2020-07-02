--[[
Title: code behind of SubmitBugPage.html
Author(s): LiXizhi
Date: 2008.8.29
Desc: submit bug via email
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Settings/SubmitBugPage.lua");
script/kids/3DMapSystemUI/Settings/SubmitBugPage.html?mailto=support@paraengine.com&subject=bug&body=hi
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local SubmitBugPage = {};
commonlib.setfield("Map3DSystem.App.Settings.SubmitBugPage",  SubmitBugPage);

-- init
function SubmitBugPage.OnInit()
	local self = document:GetPageCtrl();
	local subject = self:GetRequestParam("subject");
	if(subject) then
		self:SetNodeValue("subject", subject)
	end	
	
	local mailto = self:GetRequestParam("mailto");
	if(mailto) then
		self:SetNodeValue("mailto", mailto)
	end	
	
	local body = self:GetRequestParam("body");
	if(body) then
		self:SetNodeValue("body", body)
	end	
end

function SubmitBugPage.OnOK(name, values)
	local self = document:GetPageCtrl();
	
	-- close the window.
	local command = Map3DSystem.App.Commands.GetCommand("File.SendEmail");
	if(command) then
		command:Call(values);
	end
end