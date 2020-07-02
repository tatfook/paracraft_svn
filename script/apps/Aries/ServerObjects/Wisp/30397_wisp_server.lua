--[[
Title: Server agent template class
Author(s): LiXizhi
Date: 2010/06/11
Desc: wisps are subdivided into groups of wisp scenes.  Each wisp scene contains a number of wisps.
Each wisp scene is synchronized as a single entity between client and server. 
usually there is only one scene per world
<wisp_scenes>
	<wisp_scene update_interval="180000">
		<key name="wisp_scene_name_haqi"/>
		<instances copies="2" positions="{{20193.215,3.949,20012.939,},{20194.357,4.07,20018.508,}}"/>
	</wisp_scene>
</wisp_scenes>
| *attribute name* | *description* |
| update_interval | how many milliseconds to respawn all wisps in the scene. Set this to very big value if one do not want wisps to respawn. |
| isntances.copies | total number of wisps in the scene |
| isntances.positions | wisp positions. please note that wisp positions are only used on client. The server does not care about it. |

One the server's framemove, disappeared wisps will be reborn after update_interval milliseconds. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Wisp/30397_wisp_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

local tostring = tostring
local tonumber = tonumber
local string_find = string.find;
local string_match = string.match;
local table_insert = table.insert;
local table_concat = table.concat;
local math_random = math.random;
local math_floor = math.floor;
-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local Wisp_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("wisp", Wisp_server)

--local self.wisp_scenes = {  
	--{range = {1, 10},  update_count = 10, update_interval = 2000000, clear_afterupdate = 1995000, },
	--{range = {11, 20}, update_count = 5, update_interval = 20000, clear_afterupdate = 15000, },
--};

-- mapping from wisp config file name to wisp config data. 
-- we will cache all wisp files 
local wisp_templates = {};

local empty_wisp_template = {
	wisp_scenes = {},
	all_wisp_count = 0,
}

-- static function: loading wisp configuration template file from config_file
-- calling this function with same config_file will return cached data
function Wisp_server.GetWispTemplateFromConfigFile(config_file)
	if(not config_file or config_file == "") then
		return;
	end
	local wisp_template = wisp_templates[config_file];
	if(not wisp_template) then
		-- load the template if not loaded before.
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		if(not xmlRoot) then
			LOG.std(nil, "warn","wisp_server","failed loading wisp_scene config file: %s\n", config_file);
			wisp_templates[config_file] = empty_wisp_template;
			return empty_wisp_template;
		end
		
		wisp_template = {all_wisp_count=0};
		local wisp_scenes = {};
		wisp_template.wisp_scenes = wisp_scenes;
		
		-- load all wisp scene
		local i = 1;
		local all_copies=0;
		local each_wisp_scene,instances;
		for each_wisp_scene in commonlib.XPath.eachNode(xmlRoot, "/wisp_scenes/wisp_scene") do
			local wisp_begin = 0;
			local wisp_end = 0;
			local update_count = tonumber(each_wisp_scene.attr.update_count);
			local update_interval = tonumber(each_wisp_scene.attr.update_interval);
			local clear_afterupdate = tonumber(each_wisp_scene.attr.clear_afterupdate);
			
			if(update_count and update_interval and clear_afterupdate) then
				instances = commonlib.XPath.selectNode(each_wisp_scene, "/instances");
				if(instances) then
					wisp_scenes[i] = {};
					wisp_scenes[i].update_count = update_count;
					wisp_scenes[i].update_interval = update_interval;
					wisp_scenes[i].clear_afterupdate = clear_afterupdate;
					local copies = tonumber(instances.attr.copies);
					wisp_begin = all_copies + 1;
					wisp_end =  all_copies + copies;
					wisp_scenes[i].range = {wisp_begin,wisp_end};
					all_copies = wisp_end;
					i = i + 1;
				end
			end		
		end
		wisp_template.all_wisp_count = all_copies;
		if(all_copies > 0) then
			wisp_templates[config_file] = wisp_template;
		else
			-- if no wisps in the scene
			wisp_templates[config_file] = empty_wisp_template;
		end
		LOG.std(nil, "system","wisp_server","loaded wisp config file %s. %d wisps in %d wisp scenes",config_file, all_copies, #wisp_scenes);
	end
	return wisp_templates[config_file];
end

-- reset all instances
function Wisp_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.wisp_scene_config = "";
	self.instances = {};
	self.wisp_scenes = {};
	self.wispscene_count = 0;
	self.all_wisp_count = 0;
	-- read serverobject npc data
	local wisp_scene;
	for wisp_scene in commonlib.XPath.eachNode(self.npc_node, "/wisp_scene") do
		-- there can be multiple config file, where wisps are appended
		self.wisp_scene_config = wisp_scene.attr.config;
		local wisp_template = Wisp_server.GetWispTemplateFromConfigFile(self.wisp_scene_config)

		if(wisp_template) then
			local i;
			for i = 1, #(wisp_template.wisp_scenes) do
				local wisp_scene = commonlib.deepcopy(wisp_template.wisp_scenes[i]);
				wisp_scene.nextupdate_time = 0;
				wisp_scene.nextclear_time = 0;
				self.wisp_scenes[#(self.wisp_scenes)+1] = wisp_scene;
			end
			self.all_wisp_count = self.all_wisp_count + wisp_template.all_wisp_count;
		end
	end

	self.wispscene_count = #(self.wisp_scenes);
	local i;
	for i = 1, self.all_wisp_count do
		self.instances[i] = 0;
	end

	self.OnNetReceive = Wisp_server.OnNetReceive;
	self.OnFrameMove = Wisp_server.OnFrameMove;
	self.GetWispSceneValue = Wisp_server.GetWispSceneValue;
	self.GetWispSceneIndexByInstID = Wisp_server.GetWispSceneIndexByInstID;
	self.ClearWispInstance = Wisp_server.ClearWispInstance;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = Wisp_server.AddRealtimeMessage;
	
	-- set init value for each wisp
	local i;
	for i = 1, self.wispscene_count do
		self:SetValue("wisp"..i, self:GetWispSceneValue(i), revision);
	end
end

-- get the wisp scene index from wisp instance id. 
-- @return nil if not found
function Wisp_server:GetWispSceneIndexByInstID(instance_id)
	local scene_index;
	local i;
	for i = 1, self.wispscene_count do
		local wisp_scene = self.wisp_scenes[i];
		if(instance_id >= wisp_scene.range[1] and instance_id <= wisp_scene.range[2]) then
			scene_index = i;
			break;
		end
	end
	return scene_index;
end

local msg_recv_wisp_template = {
	type="recv_wisp",wisp_id=nil,
}

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function Wisp_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(msg.type == "try_pick") then
			local wisp_id = msg.wisp_id;
			if(wisp_id) then
				if(self.instances[wisp_id] == 1) then
					self.instances[wisp_id] = 0;
					-- find the wisp_scene
					local scene_index = self:GetWispSceneIndexByInstID(wisp_id);
					if(scene_index) then
						-- update the value
						self:SetValue("wisp"..scene_index, self:GetWispSceneValue(scene_index), revision);
					
						-- tell the caller to receive the wisp, since it need to be more reactive
						msg_recv_wisp_template.wisp_id = wisp_id;
						self:SendRealtimeMessage(from_nid, msg_recv_wisp_template);
					end
				end
			end
		end
	end
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function Wisp_server:OnFrameMove(curTime, revision)
	-- update persistent data and let normal update to broadcast to all agents. 
	local i;
	for i = 1, self.wispscene_count do
		local wisp_scene = self.wisp_scenes[i];
		if(wisp_scene.nextupdate_time <= curTime) then
			-- update the update and clear time
			wisp_scene.nextupdate_time = curTime + wisp_scene.update_interval;
			
			-- respawn the wisps 
			local changed;
			local j
			for j = wisp_scene.range[1], wisp_scene.range[2] do
				if(self.instances[j] == 0) then
					self.instances[j] = 1;
					changed = true;
				end
			end
			
			-- update the value
			if(changed) then
				self:SetValue("wisp"..i, self:GetWispSceneValue(i), revision);
			end
		end
	end
end

-- clear a given wisp scene by scene id. 
function Wisp_server:ClearWispInstance(wispscene_id)
	local i;
	local wisp_scene = self.wisp_scenes[wispscene_id];
	for i = wisp_scene.range[1], wisp_scene.range[2] do
		self.instances[i] = 0;
	end
end

-- get the wisp scene value string for transmission.
function Wisp_server:GetWispSceneValue(wispscene_id)
	local wisp_scene = self.wisp_scenes[wispscene_id];
	return table_concat(self.instances, ",", wisp_scene.range[1], wisp_scene.range[2]);
end
