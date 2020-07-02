--[[
Title: JGSL server configuration.
Author(s): LiXizhi
Date: 2008/12/25
Desc: configuration is usually loaded from "config/jgsl.config.xml". Please read the config file, it is self-explanatory.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_config.lua");
Map3DSystem.JGSL.config:load("config/jgsl.config.xml")
------------------------------------------------------------
]]

if(not Map3DSystem.JGSL) then Map3DSystem.JGSL={} end
if(not Map3DSystem.JGSL.config) then Map3DSystem.JGSL.config={} end

local JGSL = Map3DSystem.JGSL;
local config = Map3DSystem.JGSL.config;

-- default settings 
config.GridNodeRules = {
	-- an array of tables of {worldfilter, gridsize, fromx, fromy, tox, toy}
};

-- load config from a given file. 
-- @param filename: if nil, it will be "config/jgsl.config.xml"
function config:load(filename)
	filename = filename or "config/jgsl.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading jgsl config file %s\n", filename);
		return;
	end	
	
	-- grid node rules
	self.GridNodeRules = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/JGSL/GridServer/GridNodeRules/rule") do
		if(node.attr) then
			local attr = {}
			attr.worldfilter = node.attr.worldfilter;
			attr.UserRole = node.attr.UserRole;
			attr.gridsize = tonumber(node.attr.gridsize);
			attr.fromx = tonumber(node.attr.fromx);
			attr.fromy = tonumber(node.attr.fromy);
			attr.tox = tonumber(node.attr.tox);
			attr.toy = tonumber(node.attr.toy);
			table.insert(self.GridNodeRules, attr);
		end
	end
end
