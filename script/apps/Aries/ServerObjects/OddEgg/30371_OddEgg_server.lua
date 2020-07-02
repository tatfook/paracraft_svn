--[[
Title: Server agent template class
Author(s): Leio
Date: 2010/03/22
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/OddEgg/30371_OddEgg_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local OddEgg_server = {
	source_num = 30,
	goal_num = 18,
	egg_holes = {},
	--egg_map = {"intelligent","miser","jiaojiao","stone","hunger",},
	--gift_map = {"yoyo_deer","mimi_deer","tuo_niao","shan_dian","xue_qiu","none_effect","bean_5000","yu_mao","lei_zhen_yun","grass",},
}

Map3DSystem.GSL.config:RegisterNPCTemplate("oddegg", OddEgg_server)
--- clear all of egges and ready create new instance
function OddEgg_server.ClearAll()
	local self = OddEgg_server;
	self.egg_holes = {};
end
-- result_list = { 3, 4, 8, 9, 10 };
function OddEgg_server.GetEggList()
	local self = OddEgg_server;
	local result_list = {};
	function _add(list,index)
		if(not list or not index)then return end
		local k,v;
		for k,v in ipairs(list) do
			list[k] = v + index;
		end
	end
	function _append(target_list,list)
		if(not target_list or not list)then return end
		local k,v;
		for k,v in ipairs(list) do
			table.insert(target_list,v);
		end
	end
	local items =  commonlib.GetRandomList(10,6,true);
	_append(result_list, items);
	
	items =  commonlib.GetRandomList(10,6,true);
	_add(items,10)
	_append(result_list, items);
	
	items =  commonlib.GetRandomList(10,6,true);
	_add(items,20)
	_append(result_list, items);
	return result_list;
end
--- create new instance
function OddEgg_server.CreateEgges()
	local self = OddEgg_server;
	self.ClearAll();
	local egg_list = self.GetEggList();
	if(egg_list)then
		local k,v;
		for k,v in ipairs(egg_list) do
			local index = v;
			local egg_type = self.GetEggIndex();
			local gift_type = self.GetGiftIndex();
			local item = {
				index = index,
				egg_type = egg_type,--- type of egg
				gift_type = gift_type,--- type of gift
			}
			self.egg_holes[index] = item;
		end
	end
	return self.egg_holes;
end
function OddEgg_server.GetEggIndex()
	local self = OddEgg_server;
	local r = math.random(5);
	return r;
end
function OddEgg_server.GetGiftIndex()
	local self = OddEgg_server;
	local r = math.random(100);
	local index = 1;
	if(r <=5 )then
		index = 1;
	elseif(r > 5 and r <= 10)then
		index = 2;
	elseif(r > 10 and r <= 15)then
		index = 3;
	elseif(r > 15 and r <= 30)then
		index = 4;
	elseif(r > 30 and r <= 45)then
		index = 5;
	elseif(r > 45 and r <= 55)then
		index = 6;
	elseif(r > 55 and r <= 65)then
		index = 7;
	elseif(r > 65 and r <= 80)then
		index = 8;
	elseif(r > 80 and r <= 90)then
		index = 9;
	elseif(r > 90 and r <= 100)then
		index = 10;
	end
	return index;
end
function OddEgg_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = OddEgg_server.OnNetReceive;
	self.OnFrameMove = OddEgg_server.OnFrameMove;
	
	local result_list = OddEgg_server.CreateEgges();
	if(result_list)then
		local k,v;
		for k,v in pairs(result_list) do
			local index = v.index;
			self:SetValue("CreateEgg"..index, v, revision);
		end
	end
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function OddEgg_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30371%]CheckCanPickObj:(%d+)$") or -1;
			index = tonumber(index);
			if(index)then
				local egg = OddEgg_server.egg_holes[index];
				if(egg)then
					local msg = "[Aries][ServerObject30371]CanPickObj:true:"..index;
					self:SendRealtimeMessage(from_nid, msg);
				else
					--- this egg had been picked by another user or deleted by server
					local msg = "[Aries][ServerObject30371]CanPickObj:false:"..index;
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30371%]TryPickObj:(%d+)$") or -1;
			index = tonumber(index);
			if(index)then
				local egg = OddEgg_server.egg_holes[index];
				if(egg)then
					OddEgg_server.egg_holes[index] = nil;
					--- update the value
					self:SetValue("CreateEgg"..index,"false", revision);
					--- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30371]DestroyInstance:"..index;
					self:AddRealtimeMessage(msg);
					--- tell the user to receive a egg 
					local msg = "[Aries][ServerObject30371]RecvEgg";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
		end
	end
end
local nextupdate_time = 0;
local has_clearall = false;
local has_rebuild = false;
local clear_time = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function OddEgg_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		--每秒检查一次
		nextupdate_time = curTime + 1000;	
		
		clear_time = clear_time + 1;
		if(clear_time >= 240 and not has_clearall)then
			has_clearall = true;
			has_rebuild = false;
			
			local k;
			for k = 1,OddEgg_server.source_num do
				--- update the value
				self:SetValue("CreateEgg"..k,"false", revision);
				
				local msg = "[Aries][ServerObject30371]DestroyInstance:"..k;
				self:AddRealtimeMessage(msg);
			end
			OddEgg_server.ClearAll();
			
		end
		if(clear_time >= 300 and not has_rebuild)then
				has_clearall = false;
				has_rebuild = true;
				clear_time = 0;
				nextupdate_time = 0;
				local k;
				for k = 1,OddEgg_server.source_num do
					--- update the value
					self:SetValue("CreateEgg"..k,"false", revision);
					
					local msg = "[Aries][ServerObject30371]DestroyInstance:"..k;
					self:AddRealtimeMessage(msg);
				end
				OddEgg_server.ClearAll();
		
				-- if time is past after 10 minutes,create new instance on world
				local result_list = OddEgg_server.CreateEgges();
				if(result_list)then
					local k,v;
					for k,v in pairs(result_list) do
						if(v)then
							local index = v.index;
							local egg_type = v.egg_type or -1;
							local gift_type = v.gift_type or -1;
							self:SetValue("CreateEgg"..index, v, revision);
							-- boardcast to all hosting clients
							local msg = "[Aries][ServerObject30371]CreateEggByServerMsg"..index..":"..egg_type..":"..gift_type;
							self:AddRealtimeMessage(msg);
						end
					end
				end
		end
	end
end

