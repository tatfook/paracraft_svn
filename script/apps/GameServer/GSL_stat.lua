--[[
Title: stat users from every game server.
Author(s): gosling
Date: 2009/10/14
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/rest.lua");
local GSL_stat = commonlib.gettable("Map3DSystem.GSL.GSL_stat");
local GSL_ServerName = commonlib.gettable("Map3DSystem.GSL.GSL_ServerName");
local GSL_ServerCapability = commonlib.gettable("Map3DSystem.GSL.GSL_ServerCapability");

function GSL_stat:SendWebRequest(world_server, iCount)
	GameServer.rest:SendRequestRandomDB("WorldServers.Set",{id=world_server, cur=iCount or 0,}, 0, 0)
end

--function GSL_stat:StatOnlineInfo(curTime)
	--for world_server in pairs(GSL_stat) do
		--local iCount = 0;
		--local OnlineInfo=GSL_stat[world_server];
		--for nid in pairs(OnlineInfo) do
			--if(OnlineInfo[nid] == 'online') then 
				--iCount++;
			--else
				--table.remove(OnlineInfo,nid);
			--end
			--self.SendWebRequest(world_server,iCount);
		--end
	--end
--end

function GSL_stat:SetServerProperty(filename)
	filename = filename or "config/WorldServerProperty.config.xml";
	
	-- read all WorldServerProperty from config file
	local api_root = ParaXML.LuaXML_ParseFile(filename);
	if(not api_root) then
		commonlib.log("warning: failed loading config file %s\n", filename);
	else
		local node;
		for node in commonlib.XPath.eachNode(api_root, "/Worlds/world") do
			if(node.attr and node.attr.id and node.attr.name and node.attr.capability) then
				GSL_ServerName[node.attr.id] = node.attr.name;
				GSL_ServerCapability[node.attr.id] = node.attr.capability;
				--GSL_stat[node.attr.id] = GSL_stat[node.attr.id] or {};
				--self.Init(node.attr.id);		
				GameServer.rest:SendRequestRandomDB("WorldServers.Update", {id=node.attr.id, name=node.attr.name,max=tonumber(node.attr.capability),},0, 0)
			end	
		end	
	end	
	
	--NPL.load("(gl)script/ide/timer.lua");
	--self.mytimer = self.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
		--curTime = ParaGlobal.timeGetTime();
		--self:StatOnlineInfo(curTime);
	--end})
	--self.mytimer:Change(300, self.TimerInterval);
end

function GSL_stat:Init(world_server)
	GameServer.rest:SendRequestRandomDB("WorldServers.Update", {id=world_server, name=GSL_ServerName[world_server],max=GSL_ServerCapability[world_server],},0, 0)
end

local function activate()
	if(GSL.dump_server_msg) then
		commonlib.applog("GSL_stat started!")
		commonlib.echo(msg);
	end
	

end
NPL.this(activate);