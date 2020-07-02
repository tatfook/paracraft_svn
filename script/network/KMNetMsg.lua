--[[
Title: all kids movie online version network message types are here
Author(s): LiXizhi
Date: 2007/8/3
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/KMNetMsg.lua");
if(msg.type == KMNetMsg.SC_InitGame) then
end
------------------------------------------------------------
]]

-- SC means server from client, CS means client to server msg. 
if(not KMNetMsg) then KMNetMsg={}; end

-----------------------------
-- init_server/client
-----------------------------
--[[
local msg = {
	type = KMNetMsg.SC_InitGame, -- SC: InitGame: first and basic world information.
	worldpath = ParaWorld.GetWorldDirectory(),
	worldname = ParaWorld.GetWorldName(),
	desc = "TODO",
	x=x,
	y=y,
	z=z,
	-- TODO: authenticate to decide "guest", "administrator", "friend"
	Role = UserRole,
	OnlineUserNum = ParaNetwork.GetConnectionList(0),
	StartTime = server.statistics.StartTime,
	VisitsSinceStart = server.statistics.VisitsSinceStart,
	ServerVersion = server.ServerVersion, 
	ClientVersion = server.ServerVersion, 
};
--]]
KMNetMsg.SC_InitGame = 1
--[[
local msg = {
		type = KMNetMsg.SC_RestartGame, -- restart the game server.
		worldpath = ParaWorld.GetWorldDirectory(),
		worldname = ParaWorld.GetWorldName(),
		desc = "TODO",
		x=px,
		y=py,
		z=pz,
	};
--]]
KMNetMsg.SC_RestartGame = 2

--[[ client to tell the server to restart. only admin clients can do so.
local msg = {
		type = KMNetMsg.CS_RestartGame, -- restart the game server.
		username="LiXizhi",
		password="",
	};
--]]
KMNetMsg.CS_RestartGame = 2
-----------------------------
-- chat_server/client
-----------------------------

--[[
local msg = {
	type = type,
	text = text,
};
--]]
KMNetMsg.CS_ChatNormal = 0
KMNetMsg.CS_ChatHeadOn = 1
KMNetMsg.CS_ChatSay = 2
KMNetMsg.SC_ChatNormal = 0
KMNetMsg.SC_ChatHeadOn = 1
KMNetMsg.SC_ChatSay = 2

-----------------------------
-- Creation_server/client
-----------------------------
--[[
local msg = {
	type = KMNetMsg.CS_RequestObjectCreation, -- creation ID
	name = ObjName,
	sCategoryName = sCategoryName,
	filepath = FilePath,
	x=pos[1], y=pos[2], z=pos[3],
};
--]]
KMNetMsg.CS_RequestObjectCreation = 0
KMNetMsg.SC_BroadcastObjectCreation = 0

--[[
local msg = {
	type = KMNetMsg.RequestObjectModification, -- modification ID
};
-- add other optional data fields to the packet.
msg.viewbox = obj:GetViewBox({});
msg.pos = pos;
msg.scale = scale;
msg.quat = quat;
--]]
KMNetMsg.CS_RequestObjectModification = 1
KMNetMsg.SC_BroadcastObjectModification = 1

--[[
local msg = {
	type = KMNetMsg.CS_RequestObjectDelete, -- deletion 
};
-- add other optional data fields to the packet.
msg.viewbox = obj:GetViewBox({});
--]]
KMNetMsg.CS_RequestObjectDelete = 2
KMNetMsg.SC_BroadcastObjectDelete = 2

--[[
local msg = {
	type = KMNetMsg.CS_RequestTerrainModify, -- terrain heightfield update
	cmd = cmd,
	x = x,
	y = y,
	z = z,
	radius = radius,
	height = height,
};
--]]
KMNetMsg.CS_RequestTerrainModify = 3
-- SC: uses internal function ParaWorld.SendTerrainUpdate

--[[
local msg = {
	type = KMNetMsg.CS_RequestTerrainTexModify, -- terrain texture
	TexFile = TexFile,
	x = x,
	y = y,
	z = z,
	brushsize = brushsize,
	bErase = bErase,
};
--]]
KMNetMsg.CS_RequestTerrainTexModify = 4
KMNetMsg.SC_BroadcastTerrainTexModify = 4

--[[
local msg = {
	type = KMNetMsg.CS_RequestOceanModify, -- ocean 
	height = height,
	bEnable = bEnable,
	r = r,
	g = g,
	b = b,
};
--]]
KMNetMsg.CS_RequestOceanModify = 5
KMNetMsg.SC_BroadcastOceanModify = 5

--[[
local msg = {
	type = KMNetMsg.CS_RequestSkyModify, -- sky
	skybox = skybox, -- mesh file name
	r = r,
	g = g,
	b = b,
};
--]]
KMNetMsg.CS_RequestSkyModify = 6
KMNetMsg.SC_BroadcastSkyModify = 6

--[[
local msg = {
	type = KMNetMsg.CS_RequestTimeModify, -- time of day
	timeofday = timeofday, 
};
--]]
KMNetMsg.CS_RequestTimeModify = 7
KMNetMsg.SC_BroadcastTimeModify = 7
