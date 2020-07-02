--[[
Title: Combat Service (a GSL module)
Author(s): WangTian
Date: 2010/9/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/CombatService.lua");
------------------------------------------------------------
]]
local CombatService = {};
CombatService.src = "script/apps/Aries/Combat/ServerObject/CombatService.lua";
Map3DSystem.GSL.system:AddService("CombatService", CombatService)

NPL.load("(gl)script/apps/Aries/Combat/ServerObject/combat_server.lua");
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");

-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function CombatService:Init(system)
	-- One can wait until some other modules have been loaded. 
	--local dependent_module = system:GetService("CombatService");
	--if(not dependent_module or not dependent_module:IsLoaded() ) then  return end
	
	local options = Map3DSystem.GSL.config:FindModuleBySrc(self.src);
	
	if(options and options.version) then
		-- version is kids or teen
		combat_server.version = options.version;
	end
	
	-- quest service must wait until power item service is inited
	local dependent_module = system:GetService("PowerItemService");
	if(not dependent_module or not dependent_module:IsLoaded() ) then 
		return 
	end

	-- TODO: put your async init code here

	-- One can register system events or events of other modules like this
	system:AddEventListener("OnUserDisconnect", self.OnUserDisconnect, self);
	system:AddEventListener("OnUserLoginWorld", self.OnUserLoginWorld, self);
	

	CombatService.state = "loaded";
	LOG.std(nil, "system", "CombatService", "CombatService is loaded");

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function CombatService:IsLoaded()
	return CombatService.state == "loaded";
end

-- event callback: only called when TCP connection is closed
function CombatService:OnUserDisconnect(msg)
	--LOG.std(nil, "system", "CombatService", "we see a user %s left us", msg.nid);	
end

-- event callback: This will be called when user logins or switches different worlds during game play, hence it maybe called multiple times. 
function CombatService:OnUserLoginWorld(msg)
	--LOG.std(nil, "system", "CombatService", "we see a user %s login a GSL world %s", msg.nid, tostring(msg.worldpath));
	
	-- One can delay sending the reply message by setting the delay_reply to msg;
	local delay_reply = msg.delay_reply or {};
	msg.delay_reply = delay_reply;
	delay_reply.Func_DoCombatReply = function()
		LOG.std(nil, "system", "Func_DoCombatReply", "Func_DoCombatReply");
		-- TODO: init the card templates
	end
end



