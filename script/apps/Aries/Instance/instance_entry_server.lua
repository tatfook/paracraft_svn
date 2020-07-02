--[[
Title: Server agent template class
Author(s): 
Date: 2011/1/25
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Instance/instance_entry_server.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local Instance_Entry_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("aries_instance_entry", Instance_Entry_server)

local string_find = string.find;
local string_match = string.match;
local table_insert = table.insert;
local math_random = math.random;
local math_floor = math.floor;

local entry_all = {
	--["61HaqiTown"] = {
		--entries = {},
		--portal_count = portal_count,
		--out_of = out_of,
		--switches = {
			--{opentime = "11:00", closetime = "12:00", },
			--{opentime = "15:00", closetime = "16:00", },
			--{opentime = "20:00", closetime = "21:00", },
		--}
	--},
};

local currentTime = 0;

function Instance_Entry_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = Instance_Entry_server.OnNetReceive;
	self.OnFrameMove = Instance_Entry_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = Instance_Entry_server.AddRealtimeMessage;
	
	
	-- read instance portal data
	local entry;
	local count = 1;
	for entry in commonlib.XPath.eachNode(self.npc_node, "/entry") do
		local portal_count = entry.attr.portal_count;
		local out_of = entry.attr.out_of;
		local instance_key = entry.attr.instance_key;
		local world_name = entry.attr.world_name;
		if(portal_count and out_of and instance_key and world_name) then
			portal_count = tonumber(portal_count);
			out_of = tonumber(out_of);
			-- init the instance entry
			self.unique_id = ParaGlobal.GenerateUniqueID();
			Instance_Entry_server.InitInstanceEntry(self, portal_count, out_of, instance_key, world_name, count, entry, revision);
			count = count + 1;
		else
			LOG.std(nil, "user", "Instance_Entry_server", "invalid entry attributes:%s",commonlib.serialize_compact({portal_count, out_of, instance_key, world_name}));
		end
	end
end

-- NOTE: we assume the time limited and random entry is ONLY available in normal game worlds (persistant world)
function Instance_Entry_server.InitInstanceEntry(serverobject_self, portal_count, out_of, instance_key, world_name, count, entry_node, revision)
			
	local switches = {};
	local entry;
	for entry in commonlib.XPath.eachNode(entry_node, "/time") do
		table.insert(switches, {
			opentime = entry.attr.opentime;
			closetime = entry.attr.closetime;
		})
	end
			
	local entries = {};
	local i = 1;
	for i = 1, out_of do
		table.insert(entries, 0);
	end

	serverobject_self.entry_all = {
		serverobj_unique_id = serverobject_self.unique_id,
		world_name = world_name,
		portal_count = portal_count,
		out_of = out_of,
		instance_key = instance_key,
		entries = entries,
		switches = switches,
	};
	-- update the normal update entries
	Instance_Entry_server.NormalUpdateValues(serverobject_self, revision)
end

function Instance_Entry_server.NormalUpdateValues(serverobject_self, revision)
	local entry = serverobject_self.entry_all
	if(serverobject_self.unique_id == entry.serverobj_unique_id) then
		local value_str = "";
		local i = 1;
		for i = 1, #entry.entries do
			value_str = value_str..entry.entries[i]..",";
		end
		
		-- update the normal update entries
		serverobject_self:SetValue(entry.world_name.."_entries", value_str, revision);
	end
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function Instance_Entry_server:OnNetReceive(from_nid, gridnode, msg, revision)
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local world_name, entry_id = string.match(msg.body, "^%[Aries%]%[ServerObject_Instance_Entry%]IsEntryValid:(.-)%+(%d+)$");
			if(world_name and entry_id) then
				entry_id = tonumber(entry_id);
				--local entry = entry_all[world_name];
				local entry = self.entry_all
				if(entry and entry.entries[entry_id] == 1) then
					-- tell the user to receive an entry
					local msg = "[Aries][ServerObject_Instance_Entry]ValidEntry:"..entry.instance_key.."+"..world_name.."+"..entry_id;
					self:SendRealtimeMessage(from_nid, msg);
				elseif(entry and entry.entries[entry_id] == 0) then
					-- tell the user to receive an entry
					local msg = "[Aries][ServerObject_Instance_Entry]FailEntry";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			local world_name, entry_id = string.match(msg.body, "^%[Aries%]%[ServerObject_Instance_Entry%]OnSuccessfulEnterEntry:(.-)%+(%d+)$");
			if(world_name and entry_id) then
				entry_id = tonumber(entry_id);
				--local entry = entry_all[world_name];
				local entry = self.entry_all
				if(entry and entry.entries[entry_id] == 1) then
					entry.entries[entry_id] = 0;
					-- tell all user to destroy entry
					local msg = "[Aries][ServerObject_Instance_Entry]DestroyEntry:"..world_name.."+"..entry_id;
					self:AddRealtimeMessage(msg);
					-- update the normal update entries
					Instance_Entry_server.NormalUpdateValues(self, revision);
				end
			end
		end
	end
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function Instance_Entry_server:OnFrameMove(curTime, revision)
	self.nextupdate_time = self.nextupdate_time or 0;
	if(curTime > self.nextupdate_time) then
		self.nextupdate_time = curTime + 10000;
		
		local time = ParaGlobal.GetTimeFormat("HH:mm");
		
		local entry = self.entry_all;
		if(self.unique_id == entry.serverobj_unique_id) then
			-- traverser each switch and check the open time and close time
			local _, each_switch;
			for _, each_switch in pairs(entry.switches) do
				if(time == each_switch.opentime) then
					-- reset all entries
					entry.entries = {};
					local i = 1;
					for i = 1, entry.out_of do
						table.insert(entry.entries, 0);
					end
					-- open all entries
					local candidates = Instance_Entry_server.GenerateCandidates(1, entry.out_of, entry.portal_count)
					local _, candidate;
					for _, candidate in ipairs(candidates) do
						entry.entries[candidate] = 1;
					end
					Instance_Entry_server.NormalUpdateValues(self, revision);
					-- tricky: reset to some pass time
					each_switch.opentime = "01:00";
				end
				if(time == each_switch.closetime) then
					-- reset the entries
					entry.entries = {};
					local i = 1;
					for i = 1, entry.out_of do
						table.insert(entry.entries, 0);
					end
					Instance_Entry_server.NormalUpdateValues(self, revision);
					-- tricky: reset to some pass time
					each_switch.closetime = "02:00";
				end
			end
		end
	end
	
	
	--local old_value = self:GetValue("versioned_data");
	--old_value.nCount = old_value.nCount + 1;
	--self:SetValue("versioned_data", old_value, revision);
end

function Instance_Entry_server.GenerateCandidates(lower, upper, count)
	-- generate the instance
	local candidate_count = upper - lower + 1;
	local candidates = {};
	if(candidate_count <= count) then
		local i
		for i = lower, upper do
			table_insert(candidates, i);
		end
		return candidates;
	end
	
	local picked = {};
	-- select candidates for update respawn
	while(#candidates < count) do
		local seed = math_random(1, 10000);
		local candidate = (math_floor(seed) % candidate_count) + lower;
		
		while(picked[candidate]) do
			candidate = candidate + 1
			if(candidate >= candidate_count) then
				candidate = 1;
			end
		end
		table_insert(candidates, candidate);
		picked[candidate] = true;
	end
	return candidates;
end