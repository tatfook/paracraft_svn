--[[
Title: (Deprecated) language for this application 
Author(s): LiXizhi
Date: 2006/11/25
Desc: *Deprecated* This file is no longer needed, instead use NPL.load("(gl)script/ide/Locale.lua");
this file should be called once before any game interface is loaded. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/lang/lang.lua");
-------------------------------------------------------
]]
-- One can set a different language other than the default one in the application command line.
local lang = ParaEngine.GetAppCommandLineByParam("lang", nil);
if(lang~=nil) then
	if(lang=="enUS" or lang=="zhCN") then
		ParaEngine.SetLocale(lang);
	end	
end

NPL.load("(gl)script/ide/Locale.lua");

CommonCtrl.Locale.AutoLoadFile("script/lang/IDE-zhCN.lua");
CommonCtrl.Locale.AutoLoadFile("script/lang/IDE-enUS.lua");

CommonCtrl.Locale.AutoLoadFile("script/lang/ParaWorld-zhCN.lua");
CommonCtrl.Locale.AutoLoadFile("script/lang/ParaWorld-enUS.lua");

CommonCtrl.Locale.AutoLoadFile("script/lang/ParaworldMCML-zhCN.lua");
CommonCtrl.Locale.AutoLoadFile("script/lang/ParaworldMCML-enUS.lua");

-- global L variable, one may overwrite this during startup.
L = CommonCtrl.Locale("ParaWorld");
-- Add your application specific locale file here