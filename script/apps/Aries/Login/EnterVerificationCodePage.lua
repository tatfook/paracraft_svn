--[[
Title: 
Author(s): LiXizhi
Date: 2009/8/1
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/EnterVerificationCodePage.lua");
-------------------------------------------------------
]]
local EnterVerificationCodePage = commonlib.gettable("MyCompany.Aries.EnterVerificationCodePage")
---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
-- init
function EnterVerificationCodePage.OnInit()
	page = document:GetPageCtrl();
	
end

