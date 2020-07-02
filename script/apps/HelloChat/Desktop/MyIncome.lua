--[[
Title: code behind for page MyIncome.html
Author(s): LiXizhi
Date: 2008/10/27
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/Desktop/MyIncome.lua");
-------------------------------------------------------
]]

local MyIncome = {};
commonlib.setfield("MyCompany.HelloChat.MyIncome", MyIncome)

---------------------------------
-- page event handlers
---------------------------------

-- init
function MyIncome.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end
