--[[
Title: Trade Service (A GSL module)
Author(s): LiXizhi
Date: 2011/10/13
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/TradeService/TradeService.lua");
-----------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeServer.lua");
local GSL_TradeServer = commonlib.gettable("Map3DSystem.GSL.Trade.GSL_TradeServer");

local TradeService = {};
TradeService.src = "script/apps/Aries/TradeService/TradeService.lua";
Map3DSystem.GSL.system:AddService("TradeService", TradeService)

-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function TradeService:Init(system)
	local options = Map3DSystem.GSL.config:FindModuleBySrc(self.src);
	if(options and options.version) then
		GSL_TradeServer.load_version = options.version;
	end

	-- trade service must wait until power item service is inited
	local dependent_module = system:GetService("PowerItemService");
	if(not dependent_module or not dependent_module:IsLoaded() ) then 
		return 
	end
	
	-- init the per-thread trade system
	GSL_TradeServer.GetSingleton():init();

	TradeService.state = "loaded";
	LOG.std(nil, "system", "TradeService", "TradeService is loaded");

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function TradeService:IsLoaded()
	return TradeService.state == "loaded";
end

