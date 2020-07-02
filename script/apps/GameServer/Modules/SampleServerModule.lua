--[[
Title: A Sample Game Server Module(Service)
Author(s): LiXizhi
Date: 2010.9.1
Desc: The GSL game server can be extended with custom server modules via server config file. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/Modules/SampleServerModule.lua");
------------------------------------------------------------
]]
local SampleServerModule = {};
Map3DSystem.GSL.system:AddService("SampleServerModule", SampleServerModule)

-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function SampleServerModule:Init(system)
	-- One can wait until some other modules have been loaded. 
	-- local dependent_module = system:GetService("module_name");
	-- if(not dependent_module or not dependent_module:IsLoaded() ) then return end

	-- TODO: put your async init code here

	-- One can register system events or events of other modules like this
	system:AddEventListener("OnUserDisconnect", self.OnUserDisconnect, self);
	system:AddEventListener("OnUserLoginWorld", self.OnUserLoginWorld, self);
	
	SampleServerModule.state = "loaded";
	LOG.std(nil, "system", "SampleServerModule", "SampleServerModule is loaded");

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function SampleServerModule:IsLoaded()
	return SampleServerModule.state == "loaded";
end

-- event callback: only called when TCP connection is closed
function SampleServerModule:OnUserDisconnect(msg)
	--LOG.std(nil, "system", "SampleServerModule", "we see a user %s left us", msg.nid);	
end

-- event callback: This will be called when user logins or switches different worlds during game play, hence it maybe called multiple times. 
function SampleServerModule:OnUserLoginWorld(msg)
	LOG.std(nil, "system", "SampleServerModule", "we see a user %s login a GSL world %s", msg.nid, tostring(msg.worldpath));

	-- One can delay sending the reply message by setting the delay_reply to msg;
	local delay_reply = msg.delay_reply or {};
	delay_reply.pending_count = (delay_reply.pending_count or 0) + 1;
	msg.delay_reply = delay_reply;

	-- we only send out the reply after
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		if(delay_reply.pending_count) then
			delay_reply.pending_count = delay_reply.pending_count -1;
			if(delay_reply.pending_count == 0) then
				if(delay_reply.DoReply) then
					delay_reply.DoReply();
				end
				LOG.std(nil, "system", "SampleServerModule", "finished with %s 's login procedure", msg.nid);
			end
		end
	end})

	mytimer:Change(2000,0)
end



