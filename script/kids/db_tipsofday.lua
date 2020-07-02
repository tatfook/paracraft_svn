--[[
Title: The kidsmovie database table for tips of day
Author(s): LiXizhi
Date: 2006/12/3
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/db_tipsofday.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("KidsUI");
if(not kids_db) then kids_db={}; end

kids_db.tipsofday = {
	[1] = {text = "", image = L"Texture/Tips/Tip1.png"},
	[2] = {text = "", image = L"Texture/Tips/Tip2.png"},
	[3] = {text = "", image = L"Texture/Tips/Tip3.png"},
	[4] = {text = "", image = L"Texture/Tips/Tip4.png"},
	[5] = {text = "", image = L"Texture/Tips/Tip5.png"},
	[6] = {text = "", image = L"Texture/Tips/Tip6.png"},
	[7] = {text = "", image = L"Texture/Tips/Tip7.png"},
	[8] = {text = "", image = L"Texture/Tips/Tip8.png"},
	[9] = {text = "", image = L"Texture/Tips/Tip9.png"},
	[10] = {text = "", image = L"Texture/Tips/Tip23.png"},
	[11] = {text = "", image = L"Texture/Tips/Tip11.png"},
	[12] = {text = "", image = L"Texture/Tips/Tip12.png"},
	[13] = {text = "", image = L"Texture/Tips/Tip13.png"},
	[14] = {text = "", image = L"Texture/Tips/Tip14.png"},
	[15] = {text = "", image = L"Texture/Tips/Tip15.png"},
	[16] = {text = "", image = L"Texture/Tips/Tip16.png"},
	[17] = {text = "", image = L"Texture/Tips/Tip17.png"},
	[18] = {text = "", image = L"Texture/Tips/Tip18.png"},
	[19] = {text = "", image = L"Texture/Tips/Tip5.png"},
	[20] = {text = "", image = L"Texture/Tips/Tip20.png"},
	[21] = {text = "", image = L"Texture/Tips/Tip21.png"},
	[22] = {text = "", image = L"Texture/Tips/Tip22.png"},
	[23] = {text = "", image = L"Texture/Tips/Tip23.png"},
	[24] = {text = "", image = L"Texture/Tips/Tip24.png"},
	[25] = {text = "", image = L"Texture/Tips/Tip25.png"},
	[26] = {text = "", image = L"Texture/Tips/Tip26.png"},
	[27] = {text = "", image = L"Texture/Tips/Tip27.png"},
	[28] = {text = "", image = L"Texture/Tips/Tip28.png"},
	[29] = {text = "", image = L"Texture/Tips/Tip29.png"},
	[30] = {text = "", image = L"Texture/Tips/Tip30.png"},
	[31] = {text = "", image = L"Texture/Tips/Tip31.png"},
	[32] = {text = "", image = L"Texture/Tips/Tip32.png"},
	[33] = {text = "", image = L"Texture/Tips/Tip33.png"},
	[34] = {text = "", image = L"Texture/Tips/Tip34.png"},
	[35] = {text = "", image = L"Texture/Tips/Tip35.png"},
	[36] = {text = "", image = L"Texture/Tips/Tip36.png"},
	[37] = {text = "", image = L"Texture/Tips/Tip37.png"},
	[38] = {text = "", image = L"Texture/Tips/Tip38.png"},
	[39] = {text = "", image = L"Texture/Tips/Tip39.png"},
	[40] = {text = "", image = L"Texture/Tips/Tip40.png"},
}