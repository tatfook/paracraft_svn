--[[
Title: NOT USED: Doing RPC in the game thread. 
Author(s): LiXizhi
Date: 2010.12.21
Desc: It is dependent on PowerItemService.  
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/Modules/ServerRPCModule.lua");
------------------------------------------------------------
]]
local SampleServerModule = {};
Map3DSystem.GSL.system:AddService("SampleServerModule", SampleServerModule)

-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function SampleServerModule:Init(system)
	-- One can wait until some other modules have been loaded. 
	local dependent_module = system:GetService("PowerItemService");
	if(not dependent_module or not dependent_module:IsLoaded() ) then return end

	SampleServerModule.state = "loaded";
	LOG.std(nil, "system", "ServerRPCModule", "ServerRPCModule is loaded");

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function SampleServerModule:IsLoaded()
	return SampleServerModule.state == "loaded";
end

local function activate()
	
end
NPL.this(activate)