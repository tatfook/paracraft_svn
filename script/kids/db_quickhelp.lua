--[[
Title: The kidsmovie database table for quick help
Author(s): LiXizhi
Date: 2006/12/3
use the lib: a TipsOfDay control uses this. see kids/ui/TipsOfDay.lua
------------------------------------------------------------
NPL.load("(gl)script/kids/db_quickhelp.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("KidsUI");
if(not kids_db) then kids_db={}; end

kids_db.db_quickhelp = {
	[1] = {text = L("Quick Help").." 1", image = L"Texture/KeysHelp.png"},
	[2] = {text = L("Quick Help").." 2", image = L"Texture/MainHelp.png"},
}
