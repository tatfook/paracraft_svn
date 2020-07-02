--[[
Title: GSL server configuration.
Author(s): LiXizhi
Date: 2009/7/30
Desc: configuration is usually loaded from "config/GSL.config.xml". Please read the config file, it is self-explanatory.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");
Map3DSystem.GSL.config:load("config/GSL.config.xml")

-- in the server class file, we need to call following to register the class with a given npl template name. 
Map3DSystem.GSL.config:RegisterNPCTemplate("EchoNPC", myNPCTemplateClass)
------------------------------------------------------------
]]

local GSL = commonlib.gettable("Map3DSystem.GSL");
local config = commonlib.gettable("Map3DSystem.GSL.config");
local serveragent = commonlib.gettable("Map3DSystem.GSL.serveragent");

-- default settings 
-- an array of tables of {worldfilter, gridsize, fromx, fromy, tox, toy, npc_file}
config.GridNodeRules = {};

-- mapping from npc_file name to npc_table {npcs = { [npc_id] = npc:{id, npc_template={}}, ...}}
config.npc_files = {}

-- mapping from npc template name to npc_template {name=string, server_class={class used to create npc}}
config.npc_templates = {}

-- mapping from module name to table {src=string}}
config.modules = {}

-- load config from a given file. 
-- @param filename: if nil, it will be "config/GSL.config.xml"
function config:load(filename)
	filename = filename or "config/GSL.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "GSL", "failed loading GSL config file %s", filename);
		return;
	end	
	LOG.std(nil, "system", "GSL", "loading GSL config file %s", filename);
	
	local version = "kids";
	local locale = "zhCN";
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GSL/version") do
		if(node.attr) then
			version = node.attr.name or version;
			locale = node.attr.locale or locale;
		end
	end

	commonlib.gettable("Map3DSystem.options");
	System = Map3DSystem;
	System.options.version = System.options.version or version;
	System.options.locale = System.options.locale or locale;
	
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	MyCompany.Aries.ExternalUserModule:Init();

	-- all modules or services
	self.GridNodeRules = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GSL/modules/module") do
		if(node.attr) then
			config.modules[#(config.modules) + 1] = node.attr;
		end
	end

	-- grid node rules
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GSL/GridServer/GridNodeRules/rule") do
		if(node.attr) then
			local attr = {}
			-- always lower cased
			attr.worldfilter = node.attr.worldfilter;
			attr.UserRole = node.attr.UserRole;
			attr.gridsize = tonumber(node.attr.gridsize);
			attr.fromx = tonumber(node.attr.fromx);
			attr.fromy = tonumber(node.attr.fromy);
			attr.tox = tonumber(node.attr.tox);
			attr.toy = tonumber(node.attr.toy);
			attr.use_cell = (node.attr.use_cell == "true");
			attr.is_persistent = (node.attr.is_persistent == "true");
			attr.timeout_check_ticks = tonumber(node.attr.timeout_check_ticks);
			attr.framemove_check_ticks = tonumber(node.attr.framemove_check_ticks);
			attr.close_server_ticks = tonumber(node.attr.close_server_ticks);
			attr.max_users = tonumber(node.attr.max_users);
			attr.id = tonumber(node.attr.id);
			attr.MinStartUser = tonumber(node.attr.MinStartUser);
			attr.MaxStartUser = tonumber(node.attr.MaxStartUser);
			attr.ticket_gsid = tonumber(node.attr.ticket_gsid);
			
			attr.npc_file = node.attr.npc_file
			if(attr.worldfilter) then
				attr.worldfilter = string.lower(attr.worldfilter);
			end
			--if(node.attr.npc_file) then
			--	attr.npc_file = self:load_npc_file(node.attr.npc_file)
			--end
			attr.__index = attr; -- tricky: sometimes we will use attr as metatable.
			table.insert(self.GridNodeRules, attr);
		end
	end
end

function config:EachModule()
	return ipairs(self.modules)
end

function config:FindModuleBySrc(src)
	if(not src) then 
		return 
	end 
	local _, module
	for _, module in self:EachModule() do
		if(module.src == src) then
			return module;
		end
	end
end

-- register server NPC template. Multiple calls with the same name will overwrite settings in previous calls. 
-- This function is usually called via server npc template class at file loading time. 
-- @param name: name of the object
-- @param server_class: the server class object. 
function config:RegisterNPCTemplate(name, server_class)
	local npc_template = self.npc_templates[name]
	if(not npc_template) then
		npc_template = {
			name = name,
			server_class = server_class,
		}
		self.npc_templates[name] = npc_template;
	else
		npc_template.server_class = server_class;
	end	
end

-- return the npc template object by name
function config:GetNPCTemplate(name)
	return self.npc_templates[name];
end

-- all npc are derived from this class. 
local npc_class = {
	-- the shared id of all server npc objects
	id = nil,
	-- the npc template class. 
	npc_template = nil,
	-- the shared xml node read from the configuration section.
	npc_node = nil,
	-- the containing gridnode from which this npc instance is instantiated. This member is assigned when npc_class is created. 
	gridnode = nil,
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
	local o = serveragent:new({id = self.id, npc_node = self.npc_node, gridnode=gridnode  });
	if(self.npc_template and self.npc_template.server_class and self.npc_template.server_class.CreateInstance) then
		self.npc_template.server_class.CreateInstance(o,revision or 0);
	else
		LOG.std(nil, "warning", "GSL", "CreateInstance method is not found in npc_template id=%s", tostring(self.id));
	end
	return o;
end


-- parse and load NPC data in a given NPC file. 
-- it will only load once for the same filename. duplicate calls will return the same object. 
-- @param filename: such as "config/Aries.Demo.NPC.xml"
-- @return the NPC table is returned. 
function config:load_npc_file(filename)
	if(not filename) then return end
	local npc_file = self.npc_files[filename];
	if(npc_file) then
		return npc_file;
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
	LOG.std(nil, "system", "GSL", "server loaded npc_file %s", filename);
	
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/ServerWorld/ServerAgents/ServerAgent") do
		if(node.attr and node.attr.name) then
			local npc_template = self.npc_templates[node.attr.name]
			if(not npc_template) then
				npc_template = {name = node.attr.name}
				self.npc_templates[node.attr.name] = npc_template;
				-- load the server class 
				if(type(node.attr.server_class) == "string") then
					LOG.std(nil, "system", "GSL", "agent template %s server_class %s loaded", node.attr.name, node.attr.server_class);
					NPL.load("(gl)"..node.attr.server_class)
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
							npc_node = npc_node,
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