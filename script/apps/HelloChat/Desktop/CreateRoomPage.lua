--[[
Title: code behind for page CreateRoomPage.html
Author(s): LiXizhi
Date: 2008/10/27
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/Desktop/CreateRoomPage.lua");
-------------------------------------------------------
]]

local CreateRoomPage = {};
commonlib.setfield("MyCompany.HelloChat.CreateRoomPage", CreateRoomPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function CreateRoomPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end
