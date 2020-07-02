--[[
Title: Jabber query
Author(s): LiXizhi
Date: 2008/6/27, 
use the lib:
JGSL query is a group of query and response messages that can be sent among clients (and/or servers). It is indepedent from client/server connections using JGSL.
so consider JGSL query as mini-web services on each JGSL computer either clients or servers. 

---++ Get WorldInfo
see code doc
<verbatim>
	Map3DSystem.JGSL.query.GetWorldInfo("lixizhi@pala5.cn", function(worldinfo)  
		-- {server, worldpath, worldzipfile, x,y,z, worldid}
		commonlib.echo(worldinfo)
	end);
</verbatim>
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_query.lua");
------------------------------------------------------------
]]

if(not Map3DSystem.JGSL) then Map3DSystem.JGSL = {};end;
if(not Map3DSystem.JGSL.query) then Map3DSystem.JGSL.query={}; end

local JGSL_server = Map3DSystem.JGSL_server;
local JGSL_client = Map3DSystem.JGSL_client;
local JGSL = Map3DSystem.JGSL;
local JGSL_msg = Map3DSystem.JGSL_msg;
local query = Map3DSystem.JGSL.query;

-- boolean: true to enable all message logging.
query.dump_query_msg = nil;

query.neuronfile = "script/kids/3DMapSystemNetwork/JGSL_query.lua";
-- how many milliseconds to time out. 
query.QueryTimeout = 7000;

-- mapping from JID to mini profile call back functions.  
local MiniProfile_pool = {};
local fakeurl_query_miniprofile = "http://jgsl.pala5.com/query/profile"
-- change to a day
local cache_policy_query_miniprofile = System.localserver.CachePolicy:new("access plus 2 days")
-- getting user profile like user id and full name from an active JID. 
-- @param JID: whom we are requesting
-- @param callbackFunc: function(JID, profile)  end, where JID is JID and profile is a table containing fields values. 
-- @param cache_policy: if nil, it default to 2 day.
-- @param fields: 
function query.GetMiniProfile(JID, callbackFunc, cache_policy)
	-- OBSOLETED
	log("warning: query.GetMiniProfile is obsoleted\n")
end

-- mapping from jid to world query call back functions.  
local World_pool = {};
query.WorldInfoTimerID = 1100;
function query.OnTimer(timerid, jid)
	if(timerid == query.WorldInfoTimerID) then
		NPL.KillTimer(timerid);
		local callbackFunc = World_pool[jid];
		if(type(callbackFunc) == "function") then
			-- call the call back.
			callbackFunc(nil)
			World_pool[jid] = nil;
		end	
	else
		log("warning: invalid timerid is found in query.ontimer()\n")
	end
end
-- getting world info where the given JID is at. so that we can move to its vicinity. 
-- @param jid: whom we are requesting
-- @param callbackFunc: function(worldinfo)  end, where worldinfo is a table containing {server, worldpath, worldzipfile, x,y,z, worldid}. Or the input is nil if timed out. 
function query.GetWorldInfo(jid, callbackFunc)
	if(not jid) then return end
	World_pool[jid] = callbackFunc;
	
	-- let us use a time out timer. 
	NPL.SetTimer(query.WorldInfoTimerID, query.QueryTimeout/1000, string.format(";Map3DSystem.JGSL.query.OnTimer(%d, %q);", query.WorldInfoTimerID, tostring(jid)));
	NPL.ChangeTimer(query.WorldInfoTimerID, query.QueryTimeout,query.QueryTimeout);
	JGSL_client:Send(jid, {type = Map3DSystem.JGSL_msg.QUERY_WORLD}, query.neuronfile)
end

-- log some data
function query.log(...)
	commonlib.log("jgsl query log:")
	commonlib.log(...)
	log("\n");
end

local function activate()
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local jid = string.gsub(msg.from, "/.*$", "");
	if(query.dump_query_msg) then
		commonlib.echo(msg);
	end
	
	if(msg.type == JGSL_msg.QUERY_PROFILE) then
		-- OBSOLETED
	elseif(msg.type == JGSL_msg.QUERY_PROFILE_REPLY) then
		-- OBSOLETED
		
	elseif(msg.type == JGSL_msg.QUERY_WORLD) then
		--------------------------------
		-- get world info
		--------------------------------
		if(not msg.silent) then
			autotips.AddMessageTips(string.format("%s询问了你的位置信息, 你自动回复了它", jid));
		end	
		local x,y,z;
		if(JGSL_client.playeragent) then
			x,y,z = JGSL_client.playeragent.x, JGSL_client.playeragent.y, JGSL_client.playeragent.z;
		end
		local worldinfo = {
			server = JGSL_client:GetGatewayServerJID(),
			worldpath = JGSL_client.worldpath,
			x=x,y=y,z=z,
			-- worldzipfile = Map3DSystem.world.worldzipfile,
		};
		-- send reply 
		JGSL_client:Send(jid, {type = JGSL_msg.QUERY_WORLD_REPLY,worldinfo = worldinfo}, query.neuronfile)
		
	elseif(msg.type == JGSL_msg.QUERY_WORLD_REPLY) then
		local callbackFunc = World_pool[jid];
		if(type(callbackFunc) == "function") then
			-- call the call back.
			callbackFunc(msg.worldinfo)
			World_pool[jid] = nil;
			NPL.KillTimer(query.WorldInfoTimerID);
		end	
	end	
end
NPL.this(activate);