--[[
Title: all messages used by JGSL
Author(s): LiXizhi
Date: 2007/11/6
Desc: odd number is usually client to server. even number is server to client
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_msg_def.lua");
if(msg.type == Map3DSystem.JGSL_msg.SC_InitGame) then
end
------------------------------------------------------------
]]

-- SC means server from client, CS means client to server msg. 
if(not Map3DSystem.JGSL_msg) then Map3DSystem.JGSL_msg={}; end

-----------------------------
-- ping and exchange session keys
-----------------------------
--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_PING,
--	csk = client_side_session_key,
--};
Map3DSystem.JGSL_msg.CS_PING = 1

--local msg = {
--	type = Map3DSystem.JGSL_msg.SC_PING_REPLY,
--	sk = server_side_session_key,
--	csk = forwarding_client_side_session_key,
--};
Map3DSystem.JGSL_msg.SC_PING_REPLY = 2

-----------------------------
-- login/logout
-----------------------------

--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_Login,
--	ClientVersion = server.ServerVersion,
--	worldpath = ParaWorld.GetWorldDirectory(),
--	x=x,
--	y=y,
--	z=z,
--};
Map3DSystem.JGSL_msg.CS_Login = 3
--local msg = {
--	type = Map3DSystem.JGSL_msg.SC_Login_Reply
--	-- true if refused. if true, all other fields are nil.
--	refused = nil or true,
--	worldpath = ParaWorld.GetWorldDirectory(),
--	gk=grid_node_session_key,
--	gjid=grid_node_jid,
--	gid=grid_node_id,
--	gx=grid node tile x position,
--	gy=grid node tile y position,
--	gsize=grid node sim size,
--	-- TODO: authenticate to decide "guest", "administrator", "friend"
--	Role = UserRole,
--	OnlineUserNum = ParaNetwork.GetConnectionList(0),
--	StartTime = server.statistics.StartTime,
--	VisitsSinceStart = server.statistics.VisitsSinceStart,
--	ServerVersion = server.ServerVersion, 
--	ClientVersion = server.ServerVersion, 
--	};
Map3DSystem.JGSL_msg.SC_Login_Reply = 4
--local msg = {type = Map3DSystem.JGSL_msg.CS_Logout,};
Map3DSystem.JGSL_msg.CS_Logout = 5
--local msg = {type = Map3DSystem.JGSL_msg.SC_Closing,};
Map3DSystem.JGSL_msg.SC_Closing = 6

-----------------------------
-- normal updates for avatar position, animation, and appearance.
-----------------------------
--local msg = { 
--	type = Map3DSystem.JGSL_msg.CS_NormalUpdate,
--	agent = {data=agentstream, other fields like env, creation update, etc. }, -- for the current player
--  dummy = true, -- this is optional, if one does not wants to receive other agents update such as emulation users. 
--};
Map3DSystem.JGSL_msg.CS_NormalUpdate = 7
--local msg = { 
--	type = Map3DSystem.JGSL_msg.SC_NormalUpdate,
--	-- information about each agent on server including the host player
--	agents = {[jidname] = agent_data_string},
--  -- commar separated list of jid name without domains. if there is no agent update in msg.agents, they are added to msg.ping to prevent time out. 
--	ping = "jidname, jidname, jidname,...",
--};
Map3DSystem.JGSL_msg.SC_NormalUpdate = 8

--local msg = { 
--	type = Map3DSystem.JGSL_msg.CS_ObserverUpdate,
--	-- only position is sent, Current version does not send position. 
--	x=x, y=y, z=z,
--};
Map3DSystem.JGSL_msg.CS_ObserverUpdate = 9
-- SC_ObserverUpdate is actually SC_NormalUpdate
--Map3DSystem.JGSL_msg.SC_ObserverUpdate = Map3DSystem.JGSL_msg.SC_NormalUpdate

-----------------------------
-- query 
-----------------------------
--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_QUERY,
--	csk = client_side_session_key,
--  fields = {"systime", "agentcount", "uptime"}
--  forward = "", a string that is forwarded from client to server and then back to client. 
--};
Map3DSystem.JGSL_msg.CS_QUERY = 11

--local msg = {
--	type = Map3DSystem.JGSL_msg.SC_QUERY_REPLY,
--	sk = server_side_session_key,
--	csk = forwarding_client_side_session_key,
--  forward = "", -- forwarding the client input.
--  result ={systime=nil, agentcount=nil, uptime=nil}, -- a table containing the result of the query fields
--};
Map3DSystem.JGSL_msg.SC_QUERY_REPLY = 12

-----------------------------
-- init_server/client
-----------------------------

Map3DSystem.JGSL_msg.SC_InitGame = 22
--local msg = {
--		type = Map3DSystem.JGSL_msg.SC_RestartGame, -- restart the game server.
--		worldpath = ParaWorld.GetWorldDirectory(),
--		worldname = ParaWorld.GetWorldName(),
--		desc = "TODO",
--		x=px,
--		y=py,
--		z=pz,
--	};
Map3DSystem.JGSL_msg.SC_RestartGame = 24

-- client to tell the server to restart. only admin clients can do so.
--local msg = {
--		type = Map3DSystem.JGSL_msg.CS_RestartGame, -- restart the game server.
--		username="LiXizhi",
--		password="",
--	};
Map3DSystem.JGSL_msg.CS_RestartGame = 25
-----------------------------
-- chat_server/client
-----------------------------

--
--local msg = {
--	type = type,
--	text = text,
--};
Map3DSystem.JGSL_msg.CS_ChatNormal = 0
Map3DSystem.JGSL_msg.CS_ChatHeadOn = 1
Map3DSystem.JGSL_msg.CS_ChatSay = 2
Map3DSystem.JGSL_msg.SC_ChatNormal = 0
Map3DSystem.JGSL_msg.SC_ChatHeadOn = 1
Map3DSystem.JGSL_msg.SC_ChatSay = 2

-----------------------------
-- Creation_server/client
-----------------------------
--
--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestObjectCreation, -- creation ID
--	name = ObjName,
--	sCategoryName = sCategoryName,
--	filepath = FilePath,
--	x=pos[1], y=pos[2], z=pos[3],
--};
Map3DSystem.JGSL_msg.CS_RequestObjectCreation = 51
Map3DSystem.JGSL_msg.SC_BroadcastObjectCreation = 52

--
--local msg = {
--	type = Map3DSystem.JGSL_msg.RequestObjectModification, -- modification ID
--};
---- add other optional data fields to the packet.
--msg.viewbox = obj:GetViewBox({});
--msg.pos = pos;
--msg.scale = scale;
--msg.quat = quat;
Map3DSystem.JGSL_msg.CS_RequestObjectModification = 53
Map3DSystem.JGSL_msg.SC_BroadcastObjectModification = 54

--
--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestObjectDelete, -- deletion 
--};
---- add other optional data fields to the packet.
--msg.viewbox = obj:GetViewBox({});
Map3DSystem.JGSL_msg.CS_RequestObjectDelete = 55
Map3DSystem.JGSL_msg.SC_BroadcastObjectDelete = 56

--
--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestTerrainModify, -- terrain heightfield update
--	cmd = cmd,
--	x = x,
--	y = y,
--	z = z,
--	radius = radius,
--	height = height,
--};
Map3DSystem.JGSL_msg.CS_RequestTerrainModify = 57

-- SC: uses internal function ParaWorld.SendTerrainUpdate
--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestTerrainTexModify, -- terrain texture
--	TexFile = TexFile,
--	x = x,
--	y = y,
--	z = z,
--	brushsize = brushsize,
--	bErase = bErase,
--};
Map3DSystem.JGSL_msg.CS_RequestTerrainTexModify = 59
Map3DSystem.JGSL_msg.SC_BroadcastTerrainTexModify = 60

--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestOceanModify, -- ocean 
--	height = height,
--	bEnable = bEnable,
--	r = r,
--	g = g,
--	b = b,
--};
Map3DSystem.JGSL_msg.CS_RequestOceanModify = 61
Map3DSystem.JGSL_msg.SC_BroadcastOceanModify = 62

--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestSkyModify, -- sky
--	skybox = skybox, -- mesh file name
--	r = r,
--	g = g,
--	b = b,
--};
Map3DSystem.JGSL_msg.CS_RequestSkyModify = 63
Map3DSystem.JGSL_msg.SC_BroadcastSkyModify = 64

--local msg = {
--	type = Map3DSystem.JGSL_msg.CS_RequestTimeModify, -- time of day
--	timeofday = timeofday, 
--};
Map3DSystem.JGSL_msg.CS_RequestTimeModify = 65
Map3DSystem.JGSL_msg.SC_BroadcastTimeModify = 66


-----------------------------
-- query profile fields
-----------------------------
--local msg = {
--	type = Map3DSystem.JGSL_msg.QUERY_PROFILE,
--	fields = "uid, username, fullname, gender",  -- supported fields: uid, username, fullname, and all profile userInfo field. 
--};
Map3DSystem.JGSL_msg.QUERY_PROFILE = 101
--local msg = {
--	type = Map3DSystem.JGSL_msg.QUERY_PROFILE_REPLY,
--	profile = {}, -- name, value pairs of profiles
--};
Map3DSystem.JGSL_msg.QUERY_PROFILE_REPLY = 102

--local msg = {
--	type = Map3DSystem.JGSL_msg.QUERY_WORLD,
--};
Map3DSystem.JGSL_msg.QUERY_WORLD = 103
--local msg = {
--	type = Map3DSystem.JGSL_msg.QUERY_WORLD_REPLY,
--	worldinfo = {}, -- name, value pair of current world info where the character is in. 
--};
Map3DSystem.JGSL_msg.QUERY_WORLD_REPLY = 104
