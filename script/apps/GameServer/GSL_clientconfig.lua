--[[
Title: GSL client configuration.
Author(s): LiXizhi
Date: 2009/11/16
Desc: configuration is usually loaded from "config/GameClient.config.xml". Please read the config file, it is self-explanatory.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_clientconfig.lua");
Map3DSystem.GSL.client.config:load("config/GameClient.config.xml")
Map3DSystem.GSL.client.config:CheckLoad();

-- in the server class file, we need to call following to register the class with a given npl template name. 
Map3DSystem.GSL.client.config:RegisterNPCTemplate("EchoNPC", myNPCTemplateClass)
------------------------------------------------------------
]]

local GSL = commonlib.gettable("Map3DSystem.GSL");
local config = commonlib.gettable("Map3DSystem.GSL.clientconfig");
local serveragent = commonlib.gettable("Map3DSystem.GSL.serveragent");

config.npc_files = {
	-- mapping from npc_file name to npc_table {npcs = { [npc_id] = npc_class, ...}}
}
local delayload_npc_files;

config.npc_templates = {
	-- mapping from npc template name to npc_template {name=string, client_class={class used to create npc}}
}

-- load config from a given file. Only the first call to this function takes effects 
-- it will only search for "/GameClient/npc_files/npc_file" and load all NPC files. 
-- @param filename: if nil, it will be "config/GSL.config.xml"
function config:load(filename)
	if(self.IsLoaded) then
		return
	end
	self.IsLoaded = true;
	filename = filename or "config/GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "GSL_client", "failed loading GSL config file %s", filename);
		return;
	end	
	
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameClient/npc_files/npc_file") do
		if(node.attr) then
			--local attr = {}
			--attr.worldfilter = node.attr.worldfilter;
			
			if(node.attr.npc_file) then
				if(not config.npc_files[node.attr.npc_file]) then
					-- just keep the file name for delayed loading
					delayload_npc_files = delayload_npc_files or {};
					delayload_npc_files[node.attr.npc_file] = {version=node.attr.version};
				end
			end
		end
	end
end

-- load all delayload NPC files. 
-- this function is called when GSL_client is started. 
function config:CheckLoad()
	if(delayload_npc_files) then
		local npc_file,params
		for npc_file,params in pairs(delayload_npc_files) do
			if(type(npc_file) == "string") then
				self:load_npc_file(npc_file, params);
			end
		end
		delayload_npc_files = nil;
	end
end

-- register server NPC template. Multiple calls with the same name will overwrite settings in previous calls. 
-- This function is usually called via server npc template class at file loading time. 
-- @param name: name of the object
-- @param client_class: the server class object. 
function config:RegisterNPCTemplate(name, client_class)
	local npc_template = self.npc_templates[name]
	if(not npc_template) then
		npc_template = {
			name = name,
			client_class = client_class,
		}
		self.npc_templates[name] = npc_template;
	else
		npc_template.client_class = client_class;
	end	
end

-- return the npc template object by name
function config:GetNPCTemplate(name)
	return self.npc_templates[node.attr.name];
end

-- return the npc template object by server id
-- it will server in all loaded NPC files to search for the first match. 
function config:GetNPCTemplateBySID(sid)
	local _, npc_file
	for _, npc_file in pairs(config.npc_files) do
		if(npc_file.npcs[sid]) then
			return npc_file.npcs[sid]
		end
	end
end

-- all npc are derived from this class. 
local npc_class = {
	-- the shared id of all server npc objects
	id = nil,
	-- the npc template class. 
	npc_template = nil,
}

function npc_class:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- create this npc at the given revision (timeid)
-- this function is usually called by the gridnode at init time to create all npc instances in a given game world.
-- @param revision: the revision number on the gridnode. default to 0. 
-- @param gridnode: the grid node instance that contains this npc instance. 
function npc_class:create(revision, gridnode)
	local o = serveragent:new({id = self.id, gridnode=gridnode })
	if(self.npc_template and self.npc_template.client_class and self.npc_template.client_class.CreateInstance) then
		self.npc_template.client_class.CreateInstance(o,revision or 0);
	else
		LOG.std(nil, "warning", "GSL", "CreateInstance method is not found in npc_template id=%s", tostring(self.id));
	end
	return o;
end


-- parse and load NPC data in a given NPC file. 
-- it will only load once for the same filename. duplicate calls will return the same object. 
-- @param filename: such as "config/Aries.Demo.NPC.xml"
-- @param params: {version="abc"}
-- @return the NPC table is returned. 
function config:load_npc_file(filename, params)
	if(not filename) then return end
	local npc_file = self.npc_files[filename];
	if(npc_file) then
		return npc_file;
	elseif(params and params.version and System.options.version~=params.version) then
		-- skip if version does not match
		return;
	end
	npc_file = {
		-- maping from npc to npc info. 
		npcs = {},
	};
	self.npc_files[filename] = npc_file;
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "GSL", "failed loading npl_file %s", filename);
		return npc_file;
	end
	LOG.std(nil, "system", "GSL", "client loaded npc_file %s", filename);
	
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/ServerWorld/ServerAgents/ServerAgent") do
		if(node.attr and node.attr.name) then
			local npc_template = self.npc_templates[node.attr.name]
			if(not npc_template) then
				npc_template = {name = node.attr.name}
				self.npc_templates[node.attr.name] = npc_template;
				-- load the server class 
				if(type(node.attr.client_class) == "string") then
					LOG.std(nil, "system", "GSL", "agent template %s client_class %s loaded", node.attr.name, node.attr.client_class);
					NPL.load("(gl)"..node.attr.client_class)
				end
			end

			local npc_node;
			for npc_node in commonlib.XPath.eachNode(node, "/npc") do
				if(npc_node.attr.id) then
					local npc = npc_file.npcs[npc_node.attr.id];
					if(not npc) then
						npc_file.npcs[npc_node.attr.id] = npc_class:new({
							id = npc_node.attr.id,
							npc_template = npc_template,
						})
						-- TODO: support custom_field and persistent_data, currently only id is supported,everything else is specified from template class. 
						LOG.std(nil, "system", "GSL", "npc instance template %s is loaded", npc_node.attr.id);
					else
						LOG.std(nil, "warning", "GSL", "duplicate npc id is found in npc_file %s", filename);
					end
				end	
			end
		end
	end
	return npc_file;
end