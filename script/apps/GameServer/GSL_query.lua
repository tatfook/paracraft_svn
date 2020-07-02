--[[
Title: World Server Query Interface
Author(s): LiXizhi
Date: 2009/7/29
use the lib:
GSL query is a group of query and response messages that can be sent among clients (and/or servers). 
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_query.lua");
------------------------------------------------------------
]]
local GSL_server = commonlib.gettable("Map3DSystem.GSL_server");
local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local query = commonlib.gettable("Map3DSystem.GSL.query");

-- boolean: true to enable all message logging.
query.dump_query_msg = nil;

query.neuronfile = "script/apps/GameServer/GSL_query.lua";

-- how many milliseconds to time out. 
query.QueryTimeout = 7000;

-- log some data
function query.log(...)
	commonlib.log("GSL query log:")
	commonlib.log(...)
	log("\n");
end

local function activate()
	if (not msg.nid) then
		-- needs authentication.
		return;
	end
	if(query.dump_query_msg) then
		commonlib.echo(msg);
	end
	
	if(msg.type == GSL_msg.QUERY_PROFILE) then
	elseif(msg.type == GSL_msg.QUERY_PROFILE_REPLY) then
		
	elseif(msg.type == GSL_msg.QUERY_WORLD) then
		
	elseif(msg.type == GSL_msg.QUERY_WORLD_REPLY) then
	
	end	
end
NPL.this(activate);