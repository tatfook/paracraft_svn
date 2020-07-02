--[[
Title: Server select 
Author(s): LiXizhi
Date: 2013/5/15
use the lib:
Automatically select server according to player level and big zone id. 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/FamilyServer/ServerSelect.lua");
local ServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.ServerSelect");
ServerSelect.IsCurrentServerMatchLevel()
ServerSelect.AutoSelectServer(10, function(msg)
	echo(msg)
end)
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");
local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");
local FamilyServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.FamilyServerSelect");

local ServerSelect = commonlib.gettable("MyCompany.Aries.FamilyServer.ServerSelect");

-- all world matching current zone
ServerSelect.dsMyZoneServers = {};
-- all world servers from all zones
ServerSelect.dsAllServers = {};

-- Automatically select world server for the current player level. if no server is found, return all servers. 
-- @param level: player level.
-- @param callbackFunc: function(msg) end,  {worlds = worlds, best_server=best_server,} 
--  msg.worlds contains all available worlds.  
--	msg.best_server contains the single most fit server.
function ServerSelect.AutoSelectServer(level, callbackFunc)
	local pageIndex, pageSize = 0, 100
	local region_id = ExternalUserModule:GetRegionID();
	
	paraworld.WorldServers.Get({pageIndex=pageIndex,pageSize=pageSize}, "RetrieveAllWorldServers", function (msg)
		ServerSelect.dsMyZoneServers = {};
		ServerSelect.dsAllServers = {};

		-- LOG.std(nil, "debug", "ServerSelect.AutoSelectServer.raw", msg.items);

		local index,world;
		for index, world in ipairs(msg.items) do 
			local ws_id, gs_nid = string.match(world.id,"%((%w+)%)(%w+)");
			local id = string.format("(%s)%s",ws_id,gs_nid);
			local zoneid = tonumber(world.zoning);
			-- "worldname(levelfrom-levelto-sid)"
			local worldname, levelfrom, levelto, sid = string.match(world.name,"^([^%(%)]*)%((%d+)%-(%d+)%-?([^%)]*)%)");
			if (levelfrom) then
				levelfrom, levelto, sid = tonumber(levelfrom), tonumber(levelto), tonumber(sid);
			end	

			local world_item = {
				-- display seq no string
				id = string.format("%03d.",world.vid),
				-- seq no 
				seqno = world.vid,
				-- world server id
				ws_id = ws_id, 
				-- game server id
				gs_nid = gs_nid,
				zoneid = zoneid,
				levelfrom = levelfrom or -1,  
				levelto = levelto or -1, 
				sid = sid or 999, 
				text = worldname or world.name:gsub("%([^%)]*%)", ""),
				percentage = (100 * world.cur) / world.max,
				people = world.level,
				type = if_else(world.cur > world.max, "full", ""),
			}
			table.insert(ServerSelect.dsAllServers, world_item);

			if (FamilyServerSelect.IsMyWorldZone(zoneid) and (FamilyServerSelect.IsRecommendBigZone(zoneid))) then
				table.insert(ServerSelect.dsMyZoneServers, world_item);
			end 
		end

		if(callbackFunc) then
			local worlds = ServerSelect.dsMyZoneServers;
			if(#worlds == 0) then
				worlds = ServerSelect.dsAllServers;
			end
			-- sorting by world sid
			table.sort(worlds, function(world1, world2)
				return (world1.sid or 999) < (world2.sid or 999);
			end);

			local best_server = ServerSelect.FindBestServer(worlds, level);
			LOG.std(nil, "debug", "ServerSelect.AutoSelectServer", worlds);
			if(best_server) then
				LOG.std(nil, "system", "ServerSelect.AutoSelectServer.best_server found", best_server);
			end
			callbackFunc({worlds=worlds, best_server=best_server});
		end
	end, nil, 7000, function(msg)
		-- timeout request
		LOG.std("", "error","ServerSelect.AutoSelectServer", "timed out");
		if(callbackFunc) then
			callbackFunc({timeout=true, worlds=ServerSelect.dsAllServers});
		end
	end)
end

-- if the current connected server is already the best server. 
function ServerSelect.IsCurrentServerMatchLevel()
	local gs_nid = Map3DSystem.User.gs_nid;
	local ws_id = Map3DSystem.User.ws_id;

	if(gs_nid and ws_id) then
		local has_matching_server;
		local servers = ServerSelect.dsMyZoneServers;
		local level = MyCompany.Aries.Player.GetLevel();
		local _, server
		for _, server in ipairs(servers) do
			if(server.levelfrom <=level and level<=server.levelto) then
				has_matching_server = true;
				if(server.gs_nid == gs_nid and server.ws_id == ws_id) then
					return true;
				end
			end
		end
		if(has_matching_server) then
			return false;
		end
	end
	return true;
end

-- @param servers: all servers. 
-- @param level: player level.
-- @return the most fit server is returned.  it may return nil, if not found. 
function ServerSelect.FindBestServer(servers, level)
	local best_server;
	servers = servers or ServerSelect.dsMyZoneServers;
	level = level or MyCompany.Aries.Player.GetLevel();

	local _, server
	for _, server in ipairs(servers) do
		if(server.levelfrom <=level and level<=server.levelto) then
			if(server.percentage < 70) then
				best_server = server;
				break;
			end
		end
	end

	return best_server;
end
