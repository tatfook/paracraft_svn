--[[
Title: code behind for page ActionsPage.html
Author(s): LiXizhi
Date: 2008/10/27
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/Desktop/ActionsPage.lua");
-------------------------------------------------------
]]

local ActionsPage = {};
commonlib.setfield("MyCompany.HelloChat.ActionsPage", ActionsPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function ActionsPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end
