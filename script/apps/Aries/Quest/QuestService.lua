--[[
Title: Quest Service (A GSL module)
Author(s): LiXizhi
Date: 2010/9/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestService.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");

local QuestService = {};
QuestService.src = "script/apps/Aries/Quest/QuestService.lua";
Map3DSystem.GSL.system:AddService("QuestService", QuestService)

-- virtual: this function must be provided. This function will be called every frame move until it returns true. 
-- @param system: one can call system:GetService("module_name") to get other service for init dependency.
-- @return: true if loaded, otherwise this function will be called every tick until it returns true. 
function QuestService:Init(system)
	local options = Map3DSystem.GSL.config:FindModuleBySrc(self.src);
	if(options and options.version) then
		--server区分儿童版和青年版
		QuestServerLogics.load_version = options.version;
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
	
	QuestService.state = "loaded";
	LOG.std(nil, "system", "QuestService", "QuestService is loaded");

	return self:IsLoaded();
end

-- virtual: this function must be provided. 
function QuestService:IsLoaded()
	return QuestService.state == "loaded";
end

-- event callback: only called when TCP connection is closed
function QuestService:OnUserDisconnect(msg)
	--LOG.std(nil, "system", "QuestService", "we see a user %s left us", msg.nid);	
	QuestServerLogics.DoUserDisconnect(msg.nid);
end

-- event callback: This will be called when user logins or switches different worlds during game play, hence it maybe called multiple times. 
function QuestService:OnUserLoginWorld(msg)
	local nid = msg.nid;
	--LOG.std(nil, "system", "QuestService", "we see a user %s login a GSL world %s", msg.nid, tostring(msg.worldpath));
	
	-- One can delay sending the reply message by setting the delay_reply to msg;
	local delay_reply = msg.delay_reply or {};
	msg.delay_reply = delay_reply;
	delay_reply.Func_DoQuestReply = function()
		LOG.std(nil, "system", "Func_DoQuestReply", "Func_DoQuestReply");
		--QuestServerLogics.DoInit(nid)
	end
end



