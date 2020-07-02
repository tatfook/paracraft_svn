--[[
Title: code behind page for ProToolsPage.html
Author(s): LiXizhi
Date: 2008/9/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/ProToolsPage.lua");
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");
NPL.load("(gl)script/kids/3DMapSystemApp/Translator/Translator.lua");

local ProToolsPage = {};
commonlib.setfield("Map3DSystem.App.Developers.ProToolsPage", ProToolsPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function ProToolsPage.OnInit()
	local self = document:GetPageCtrl();

	self:SetNodeValue("checkProfiling", ParaEngine.GetAttributeObject():GetField("EnableProfiling", false));
end

function ProToolsPage.OnRunAppCommand()
	local commandName = document:GetPageCtrl():GetUIValue("commandName", "");
	if(commandName~=nil and commandName~="") then
		Map3DSystem.App.Commands.Call(commandName)
	end
end

function ProToolsPage.OnCheckProfiling(checked)
	ParaEngine.GetAttributeObject():SetField("EnableProfiling", checked)
end