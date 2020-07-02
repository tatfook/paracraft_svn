--[[
Title: 
Author(s): Leio
Date: 2011/02/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/CombatRoom/CombatRoomClientLogics.lua");
local CombatRoomClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.CombatRoomClientLogics");
CombatRoomClientLogics.CreateRoom({});

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/RoomListPage.lua");
local RoomListPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomListPage");
local sID = "combatroom10000";
local LOG = LOG;
-- create class
local CombatRoomClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.CombatRoomClientLogics");

function CombatRoomClientLogics.LoadRoomList()
	local self = CombatRoomClientLogics;
	self.CallServer("MyCompany.Aries.ServerObjects.CombatRoomServerLogics.LoadRoomList",{});
end
function CombatRoomClientLogics.JoinRoom(roomid)
	local self = CombatRoomClientLogics;
	if(not roomid)then return end
	self.CallServer("MyCompany.Aries.ServerObjects.CombatRoomServerLogics.JoinRoom",{roomid = roomid,});
end
function CombatRoomClientLogics.CreateRoom(msg)
	local self = CombatRoomClientLogics;
	if(not msg)then return end
	self.CallServer("MyCompany.Aries.ServerObjects.CombatRoomServerLogics.CreateRoom",msg);
end
function CombatRoomClientLogics.LeftRoom(roomid)
	local self = CombatRoomClientLogics;
	if(not roomid)then return end
	self.CallServer("MyCompany.Aries.ServerObjects.CombatRoomServerLogics.LeftRoom",{roomid = roomid,});
end
function CombatRoomClientLogics.ReadyGo(roomid)
	local self = CombatRoomClientLogics;
	if(not roomid)then return end
	self.CallServer("MyCompany.Aries.ServerObjects.CombatRoomServerLogics.ReadyGo",{roomid = roomid,});
end
function CombatRoomClientLogics.UpdateFromServer(msg)
	commonlib.echo({"client received",msg = msg});
	RoomListPage.Update(msg)
end
function CombatRoomClientLogics.CallServer(func,msg)
	local self = CombatRoomClientLogics;
	if(not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std("","error","CombatRoomClientLogics", "the type of msg must be table!");
		return
	end
	msg = commonlib.serialize_compact(msg);
	local body = string.format("[Aries][CombatRoom][%s][%s]",func,msg);
	
	Map3DSystem.GSL_client:SendRealtimeMessage(sID, {body = body});
end