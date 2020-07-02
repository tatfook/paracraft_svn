--[[
Title: Battle field Service (A GSL module)
Author(s): LiXizhi
Date: 2011/12/25
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BattlefieldService/BattlefieldService.lua");
-----------------------------------------------
]]
local BattlefieldService = {};
BattlefieldService.src = "script/apps/GameServer/BattlefieldService/BattlefieldService.lua";
Map3DSystem.GSL.system:AddService("BattlefieldService", BattlefieldService)

-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function BattlefieldService:Init(system)
	local options = Map3DSystem.GSL.config:FindModuleBySrc(self.src);
	
	-- trade service must wait until power item service is inited
	--local dependent_module = system:GetService("PowerItemService");
	--if(not dependent_module or not dependent_module:IsLoaded() ) then 
		--return 
	--end
	
	-- init the per-thread trade system
	NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleServer.lua");
	local GSL_BattleServer = commonlib.gettable("Map3DSystem.GSL.Battle.GSL_BattleServer");
	GSL_BattleServer.GetSingleton():init(options);
	
	BattlefieldService.state = "loaded";
	LOG.std(nil, "system", "BattlefieldService", "BattlefieldService is loaded");

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function BattlefieldService:IsLoaded()
	return BattlefieldService.state == "loaded";
end

