--[[
Title: 
Author(s): leio
Date: 2012/5/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/EventTriggerManager.lua");
local EventTriggerManager = commonlib.gettable("MyCompany.Aries.EventTriggerManager");
EventTriggerManager:SwitchWorld();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local EventTriggerManager = commonlib.gettable("MyCompany.Aries.EventTriggerManager");
EventTriggerManager.filename = "config/Aries/Scene/AriesGameWorlds.config.xml";
EventTriggerManager.triggers = nil;
EventTriggerManager.used_triggers = nil;
EventTriggerManager.interval = 500;
EventTriggerManager.timer = nil;
EventTriggerManager.is_init = nil;
function EventTriggerManager:Init()
	if(self.is_init)then
		return
	end
	self.is_init = true;
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.filename);
	if(not xmlRoot) then
		return;
	end	
	self.triggers = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/Worlds/World") do
		local worldname = node.attr.name;
		local version = node.attr.version;
		-- only load if version matched. 
		if(worldname and System.options.version == version)then
			local file_path;
			if(version == "teen")then
				file_path = string.format("config/Aries/EventTrigger_Teen/%s.Trigger.xml",worldname);
			else
				file_path = string.format("config/Aries/EventTrigger/%s.Trigger.xml",worldname);
			end
			local trigger_xmlRoot = ParaXML.LuaXML_ParseFile(file_path);
			if(trigger_xmlRoot)then
				local list = {};
				self.triggers[worldname] = list;
				local trigger_node;
				for trigger_node in commonlib.XPath.eachNode(trigger_xmlRoot, "/items/item") do
					local uid = ParaGlobal.GenerateUniqueID();
					local action_type = trigger_node.attr.action_type;
					local moviefile = trigger_node.attr.moviefile;
					local pos = trigger_node.attr.pos;
					local radius = tonumber(trigger_node.attr.radius) or 5;--默认半径
					local wait = tonumber(trigger_node.attr.wait) or 0;--默认等待时间

					local x,y,z = string.match(pos,"(.+),(.+),(.+)");
					x = tonumber(x);
					y = tonumber(y);
					z = tonumber(z);
					if(x and y and z)then
						local v = {
							uid = uid,
							action_type = action_type,
							moviefile = moviefile,
							pos = pos,
							radius = radius,
							wait = wait,
							x = x,
							y = y,
							z = z,
						}
						table.insert(list,v);
					end
				end

			else
				--LOG.std(nil, "warning", "EventTriggerManager", "failed loading trigger config file %s", file_path);
			end
		end
	end
end
function EventTriggerManager:IncludePos(center_x,center_y,center_z,radius,x,y,z)
	local min_x = center_x - radius;
	local max_x = center_x + radius;

	local min_y = center_y - radius;
	local max_y = center_y + radius;

	local min_z = center_z - radius;
	local max_z = center_z + radius;

	if(x >= min_x and x <= max_x and y >= min_y and y <= max_y and z >= min_z and z <= max_z)then
		return true;
	end
end
--切换世界
function EventTriggerManager:SwitchWorld()
	self:Init();
	self.used_triggers = {};
	if(not self.timer)then
		self.timer = commonlib.Timer:new();
	end
	self.timer.callbackFunc = function(timer)
		local world_info = WorldManager:GetCurrentWorld();
		local worldname = world_info.name;
		local trigger_list = self.triggers[worldname];
		if(trigger_list)then
			local k,node;
			for k,node in ipairs(trigger_list) do
				local uid = node.uid;
				local tick_node = self.used_triggers[uid];
				if(not self.used_triggers[uid])then
					tick_node = { duration = 0, enabled = true,};
					self.used_triggers[uid] = tick_node;
				end
				local center_x,center_y,center_z = node.x,node.y,node.z;
				local radius = node.radius;
				local max_duration = node.wait;
				local action_type = node.action_type;
				local player = ParaScene.GetPlayer();
				if(player and player:IsValid())then
					local x,y,z = player:GetPosition();
					if(self:IncludePos(center_x,center_y,center_z,radius,x,y,z))then
						tick_node.duration = tick_node.duration + timer.delta;
						if(tick_node.duration >= max_duration and tick_node.enabled)then
							--触发
							tick_node.enabled = false;
							if(action_type == "movie")then
								self:Action_Movie(node);						
							end
						end
					else
						--重置时间
						tick_node.duration = 0;
					end
				end
			end
		end
	end
	self.timer:Change(0, self.interval)
end
function EventTriggerManager:Action_Movie(node)
	if(not node)then return end
	local moviefile = node.moviefile;
	if(moviefile)then
		MotionXmlToTable.PlayCombatMotion(moviefile);
	end
end

