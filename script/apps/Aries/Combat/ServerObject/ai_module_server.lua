--[[
Title: combat system ai module server for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/ai_module_server.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AriesCombat_Server_AI_Module";
local AI_Module = commonlib.gettable("MyCompany.Aries.Combat_Server.AI_Module");

-- create AI module
-- @param o: typical AI_Module params including:
--			
function AI_Module.CreateAIModule(ai_module_name)
	NPL.load("(gl)script/apps/Aries/Combat/ServerObject/AI_Modules/"..ai_module_name..".lua");
	return commonlib.getfield("MyCompany.Aries.Combat_Server.AIModuleObjects."..ai_module_name);
end

-- get ai module object
function AI_Module.GetAIModule(ai_module_name)
	return commonlib.getfield("MyCompany.Aries.Combat_Server.AIModuleObjects."..ai_module_name);
end