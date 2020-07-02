--[[
Title: code behind for page RoomsPage.html
Author(s): LiXizhi
Date: 2008/10/27
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/Desktop/RoomsPage.lua");
-------------------------------------------------------
]]

local RoomsPage = {};
commonlib.setfield("MyCompany.HelloChat.RoomsPage", RoomsPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function RoomsPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end
