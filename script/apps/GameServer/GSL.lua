--[[
Title: GSL server and client.
Author(s): LiXizhi
Date: 2009/7/30
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_agent.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gateway.lua");
NPL.load("(gl)script/apps/GameServer/GSL_client.lua");
NPL.load("(gl)script/apps/GameServer/GSL_query.lua");
NPL.load("(gl)script/apps/GameServer/GSL_proxy.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MsgProc_game.lua");
	
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
--local GSL_server = commonlib.gettable("Map3DSystem.GSL_server");
local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");
local GSL = commonlib.gettable("Map3DSystem.GSL");

-- dump all msg to log. should always be nil, except u are debugging
GSL.dump_server_msg = GSL.dump_server_msg or false;
GSL.dump_client_msg = GSL.dump_client_msg or false;
-- dump file
local dumpfile = "log/GSL"

local LOG = LOG;

if(not paraworld or not paraworld.PostServerLog) then
	commonlib.setfield("paraworld.PostServerLog", function() end);
end
-----------------------------
-- public function
-----------------------------
-- get the NID of this computer.
function GSL.GetNID()
	return Map3DSystem.User.nid;
end

-- when client and server connect, they must exchange their session keys. By regenerating session keys, we 
-- will reject any previous established GSL game connections. Usually we need to regenerate session when we load a different world.
-- @note: we will logout currently connected server if any. 
function GSL.Reset()
	GSL_client:LogoutServer();
	gateway:Reset();
end

-- reset if not. 
function GSL.ResetIfNot()
	if(not GSL.IsResetBefore) then
		GSL.IsResetBefore = true;
		GSL.Reset();
	end
end

-- write service log messages. 
-- @param : any variable or string format like "%s", "abc"
function GSL.dump(...)
	commonlib.servicelog(dumpfile, ...);
end

-- display text to in-game log panel. 
-- @param text: string
-- @param level: the level of importance of the message. it can be nil. 
function GSL.Log(text, level)
	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_LOG, text=text})
end

-- return the index of a value from table Req_group, which equals value.  Return nil if not found
-- e.g SearchRequestGroup({[1] = "lxz@pe"}, "lxz@pe") returns 1
function GSL.SearchRequestGroup(Req_group, value)
	if(Req_group~=nil) then
		local index, data;
		for index, data in ipairs(Req_group) do
			if(data == value) then
				return index;
			end
		end
	end
end

-- compress environment updates, removing redundent ones. 
-- It will ensure that the following messages will only have one latest copy in env array.
--  OCEAN_SET_WATER,  SKY_SET_Sky
-- @param env: array of env messages. 
function GSL.CompressEnvs(env)
	if(env==nil) then return end
	
	local lastSetWaterIndex = nil;
	local lastSetSkyIndex = nil;
	
	local i=1;
	while true do
		-- create without writing to history
		local msg = env[i];
		if(msg==nil) then
			break;
		else
			if(msg.type == Map3DSystem.msg.OCEAN_SET_WATER) then
				if(lastSetWaterIndex ~= nil) then
					-- merge with previous ones
					commonlib.mincopy(msg, env[lastSetWaterIndex]);
					commonlib.removeArrayItem(env, lastSetWaterIndex);
					i = i-1;
				end
				lastSetWaterIndex = i;
			elseif(msg.type == Map3DSystem.msg.SKY_SET_Sky) then
				if(lastSetSkyIndex ~= nil) then
					-- merge with previous ones
					commonlib.mincopy(msg, env[lastSetSkyIndex]);
					commonlib.removeArrayItem(env, lastSetSkyIndex);
					i = i-1;
				end	
				lastSetSkyIndex = i;
			end
		end
		i=i+1;
	end
end
