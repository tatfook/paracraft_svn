--[[
Title: 
Author(s): Leio
Date: 2011/02/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/CombatRoom/CombatRoomServerLogics.lua");

CreateRoom
创建房间
LeftRoom
离开房间
JoinRoom
加入房间
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local sID = "combatroom10000";
-- create class
local CombatRoomServerLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.CombatRoomServerLogics");
CombatRoomServerLogics.rooms_id_index = 0;
CombatRoomServerLogics.rooms_map = {
}
function CombatRoomServerLogics.UpdateClient(nid,alluser)
	local self = CombatRoomServerLogics;
	local msg = {
		rooms_id_index = self.rooms_id_index,
		rooms_map = self.rooms_map,
	}
	self.CallClient(nid,"MyCompany.Aries.ServerObjects.CombatRoomClientLogics.UpdateFromServer",msg,alluser);
end
function CombatRoomServerLogics.FindRoom(roomid)
	local self = CombatRoomServerLogics;
	if(not roomid)then return end
	local node = self.rooms_map[roomid];
	return node;
end
--是否已经在房间里面
function CombatRoomServerLogics.IsInRoom(nid,roomid)
	local self = CombatRoomServerLogics;
	if(not nid)then return end
	if(roomid)then
		local node = self.FindRoom(roomid);
		if(node)then
			local members = node.members;
			local k,v;
			for k,v in ipairs(members) do
				if(v.nid == nid)then
					return true,node;
				end
			end
		end
	end
	local k,v;
	for k,v in pairs(self.rooms_map) do
		local members = v.members;
		if(members)then
			local kk,member_node;
			for kk,member_node in ipairs(members) do
				if(member_node == nid)then
					return true,v;
				end
			end
		end
	end
end
function CombatRoomServerLogics.LoadRoomList(nid)
	local self = CombatRoomServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	self.UpdateClient(nid);
end
--加入房间
function CombatRoomServerLogics.JoinRoom(nid,msg)
	local self = CombatRoomServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	local roomid = msg.roomid;
	if(not roomid)then return end

	local room_node = self.FindRoom(roomid);
	--是否有这个房间
	if(room_node)then
		local master = room_node.master;
		if(nid == master)then
			--自己不能加入自己创建的房间
			return
		end
		local members = room_node.members;
		local len = #members;
		local max_open_num = room_node.max_open_num;
		local roomstate = self.GetRoomState(roomid);
		if(roomstate ~= 0)then
			--不是开放状态 不能进入
			return;
		end
		if(len >= max_open_num)then
			--超过最大人数限制
			return;
		end
		local k,v;
		for k,v in ipairs(members) do
			if(v.nid == nid)then
				--自己已经在这个房间中
				return
			end
		end
		--离开其他的房间
		local isinroom,roomnode = self.IsInRoom(nid);
		if(isinroom and roomnode)then
			self.LeftRoom(nid,{roomid = roomnode.roomid});
		end	
		table.insert(members,{nid = nid,state = 0,});
		self.UpdateClient(nid,true);
	end
end
--创建房间
function CombatRoomServerLogics.CreateRoom(nid,msg)
	local self = CombatRoomServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	if(not self.IsInRoom(nid))then
		self.rooms_id_index = self.rooms_id_index + 1;
		local roomid = self.rooms_id_index;
		local node = {
			roomid = roomid,
			label = msg.label or "一起摇滚吧",
			passworld = msg.passworld,
			roomtype = msg.roomtype or 0,
			templateid = msg.templateid or 1,
			--每个人的nid 和 状态
			members = { 
				{nid = nid, state = 0}, --state 0 没有准备 1 准备好
			},
			roomstate = 0,--0未进入战斗 1已经进入战斗状态
			max_open_num = msg.max_open_num or 4,
		}
		self.rooms_map[roomid] = node;
		self.UpdateClient(nid,true);
	end
end
--离开房间
function CombatRoomServerLogics.LeftRoom(nid,msg)
	local self = CombatRoomServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	if(self.IsInRoom(nid))then
		local roomid = msg.roomid;
		local room_node = self.FindRoom(roomid);
		if(room_node)then
			local roomid = room_node.roomid;
			local k,v;
			local members = room_node.members;
			local master_nid = members[1].nid;
			for k,v in ipairs(members) do
				if(nid == v.nid)then
					table.remove(members,k);
				end
			end
			local len = #members;
			--房间人数为0 销毁房间
			if(len == 0)then
				self.DeleteRoom(roomid);
				return
			end
			--如果是房间主人
			if(nid == master_nid)then
				local first_member = members[1];
				if(first_member and first_member[1])then
					--更换主人
					room_node.master = first_member[1].nid;
				end
			end
		end
		self.UpdateClient(nid,true);
	end
end
--我已经准备好
function CombatRoomServerLogics.ReadyGo(nid,msg)
	local self = CombatRoomServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	local roomid = msg.roomid;
	local isinroom,roomnode = self.IsInRoom(nid,roomid)
	if(roomnode and roomnode.roomid == roomid)then
		local members = roomnode.members;
		local k,v;
		local all_ready = true;
		for k,v in ipairs(members) do
			if(v.nid == nid)then
				v.state = 1;
			end
			if(v.state == 0)then
				all_ready = false;
			end
		end
		if(all_ready)then
			self.Login(roomid);
		end
		self.UpdateClient(nid,true);
	end
end
--进入副本
function CombatRoomServerLogics.Login(roomid)
	local self = CombatRoomServerLogics;
	if(not roomid)then return end
	local roomnode = self.FindRoom(roomid);
	if(roomnode)then
		roomnode.roomstate = 1;
		--TODO:进入副本
	end
end
--退出副本
function CombatRoomServerLogics.Logout(roomid)
	local self = CombatRoomServerLogics;
	if(not roomid)then return end
	local roomnode = self.FindRoom(roomid);
	if(roomnode)then
		roomnode.roomstate = 0;
		--TODO:退出副本
	end
end
--返回整个房间的状态
function CombatRoomServerLogics.GetRoomState(roomid)
	local self = CombatRoomServerLogics;
	local roomnode = self.FindRoom(roomid);
	if(roomnode)then
		return roomnode.roomstate;
	end	
end
function CombatRoomServerLogics.DeleteRoom(roomid)
	local self = CombatRoomServerLogics;
	if(not roomid)then return end
	self.rooms_map[roomid] = nil;
end

function CombatRoomServerLogics.Test(nid,msg)
	commonlib.echo({"server received",nid = nid,msg = msg});
	CombatRoomServerLogics.CallClient(nid,"MyCompany.Aries.ServerObjects.CombatRoomClientLogics.Test2",{"hello client"})
end
function CombatRoomServerLogics.CallClient(nid,func,msg,alluser)
	local self = CombatRoomServerLogics;
	nid = tostring(nid);
	if(not nid or not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std("","error","CombatRoomServerLogics", "the type of msg must be table!");
		return
	end

	local gridnode = gateway:GetPrimGridNode(nid)
	if(gridnode)then
		local server_object = gridnode:GetServerObject(sID);
		if(server_object) then
			msg = commonlib.serialize_compact(msg);
			local body = format("[Aries][CombatRoom][%s][%s]",func,msg);
			LOG.std("","info","CombatRoomServerLogics.CallClient", body);
			if(alluser)then
				server_object:AddRealtimeMessage(body);
			else
				server_object:SendRealtimeMessage(nid, body);
			end
		end
	end
end
