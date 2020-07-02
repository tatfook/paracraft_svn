--[[
Title: Server agent template class
Author(s): 
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/BigToothOgre/30379_BigToothOgre_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local BigToothOgre_server = {
	item_uid = 0,
}

Map3DSystem.GSL.config:RegisterNPCTemplate("bigtoothogre", BigToothOgre_server)

local tooth_ogre_instance = {
	max_anger = 300,
	cur_anger = 0,
	born_place_range = 4,--出现地点的范围
	cur_born_place_index = 1,--当前出现地点
	gift_types = 5, --奖励物品的类型
	gift_max_num = 15,--奖励物品的总数量
	max_lived_sec = 600,--最长存活时间 秒
	duration = 5,--多久更新一次时间
	hole_num = 45,--礼物分布位置的总数量
	gift_pools = {
		-- [uid] = { 
			--uid = uid, 
			--gift_type = 1, 
			--lived_sec = 0, --已经存活的秒数 
			--place_index = 1,--礼物随机分布的位置
			--center_index = 1,--当前怪的位置
		--}
	},--还没有被捡取的礼物
}
function BigToothOgre_server.OnReset()
	local born_place_range = tooth_ogre_instance.born_place_range;
	local old_index = tooth_ogre_instance.cur_born_place_index;
	tooth_ogre_instance.cur_born_place_index = commonlib.GetRandomIndex(born_place_range,old_index);
	--tooth_ogre_instance.cur_born_place_index = math.random(born_place_range);
	tooth_ogre_instance.cur_anger = 0;
end
function BigToothOgre_server.GetParams()
	local params = {
		cur_anger = tooth_ogre_instance.cur_anger,
		max_anger = tooth_ogre_instance.max_anger,
		cur_born_place_index = tooth_ogre_instance.cur_born_place_index,
		gift_pools = tooth_ogre_instance.gift_pools,
	}
	return params;
end
function BigToothOgre_server.IsMaxLevel()
	local cur_anger = tooth_ogre_instance.cur_anger;
	local max_anger = tooth_ogre_instance.max_anger; 
	return cur_anger >= max_anger;
end
--累计击中次数
--如果到达最大值 生成物品列表并返回
function BigToothOgre_server.OnHit(v)
	v = tonumber(v);
	if(v)then
		tooth_ogre_instance.cur_anger = tooth_ogre_instance.cur_anger + v;
	else
		tooth_ogre_instance.cur_anger = tooth_ogre_instance.cur_anger + 1;
	end
	local list;
	if(BigToothOgre_server.IsMaxLevel())then
		list = BigToothOgre_server.GetGiftList();
		BigToothOgre_server.AppendGiftList(list);
	end
	return list;
end
function BigToothOgre_server.GetUID()
	BigToothOgre_server.item_uid = BigToothOgre_server.item_uid + 1;
	if(BigToothOgre_server.item_uid > 1000000)then
		BigToothOgre_server.item_uid = 0;
	end
	return BigToothOgre_server.item_uid;
end
--生成礼物列表
function BigToothOgre_server.GetGiftList()
	local k = 1;
	local max_num = tooth_ogre_instance.gift_max_num or 15;
	local gift_types =  tooth_ogre_instance.gift_types or 5;
	local hole_num = tooth_ogre_instance.hole_num;
	local place_list =  commonlib.GetRandomList(hole_num,max_num,false) or {};
	local list = {};
	local center_index = tooth_ogre_instance.cur_born_place_index;
	for k = 1,max_num do
		--local gift_type = math.floor(k/gift_types) + 1;
		local gift_type = math.mod(k - 1,5) + 1;
		--local uid = ParaGlobal.GenerateUniqueID();
		local uid = BigToothOgre_server.GetUID();
		local place_index = place_list[k];
		local item = {
			uid = uid,
			gift_type = gift_type,
			lived_sec = 0,
			place_index = place_index,
			center_index = center_index,
		}
		table.insert(list,item);
	end
	return list;
end
--存储所有生成的礼物
function BigToothOgre_server.AppendGiftList(list)
	if(not list)then return end
	local k,item;
	for k,item in ipairs(list) do
		local uid = item.uid;
		tooth_ogre_instance.gift_pools[uid] = item;
	end
end
function BigToothOgre_server.UpdateTime()
	local uid,item;
	local duration = tooth_ogre_instance.duration;
	local gift_pools = tooth_ogre_instance.gift_pools;
	for uid,item in pairs(gift_pools) do
		item.lived_sec = item.lived_sec or 0;
		item.lived_sec = item.lived_sec + duration;
	end
end
--清除/返回 过期的礼物
function BigToothOgre_server.CleanInvalidItems()
	local list = {};
	local gift_pools = tooth_ogre_instance.gift_pools;
	local max_lived_sec = tooth_ogre_instance.max_lived_sec;
	local uid,item;
	for uid,item in pairs(gift_pools) do
		local sec = item.lived_sec or max_lived_sec;
		if(sec >= max_lived_sec)then
			table.insert(list,item);
			tooth_ogre_instance.gift_pools[uid] = nil; --清除这条记录
		end
	end
	return list;
end
function BigToothOgre_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = BigToothOgre_server.OnNetReceive;
	self.OnFrameMove = BigToothOgre_server.OnFrameMove;
	
	--选取出生地点
	BigToothOgre_server.OnReset();
	local params = BigToothOgre_server.GetParams();
	self:SetValue("BackupLivedItems",params.gift_pools, revision);
	self:SetValue("BackupBornIndex",params.cur_born_place_index, revision);
	self:SetValue("BackupAnger",params.cur_anger, revision);
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function BigToothOgre_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			--如果捡取一个物品
			local uid = string.match(msg.body, "^%[Aries%]%[ServerObject30379%]TryPickObj:(%d+)$") or "";
			uid = tonumber(uid);
			if(uid)then
				local item = tooth_ogre_instance.gift_pools[uid];
				if(item)then
					self:SetValue("BackupLivedItems",tooth_ogre_instance.gift_pools, revision);
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30379]DestroyGiftInstance:"..uid;
					self:AddRealtimeMessage(msg);
					-- tell the user to receive a gift
					local gift_type = item.gift_type;
					local msg = "[Aries][ServerObject30379]RecvGift:"..gift_type;
					self:SendRealtimeMessage(from_nid, msg);
					
					tooth_ogre_instance.gift_pools[uid] = nil;
				end
			end
			--如果击中
			--通知客户端+1
			local onhit =  string.match(msg.body, "^%[Aries%]%[ServerObject30379%]OnHit:(%d+)$");
			local new_gift_list;
			if(onhit)then
				new_gift_list = BigToothOgre_server.OnHit(onhit);
			end
			--如果生成新的礼物
			if(new_gift_list)then
				local old_index = tooth_ogre_instance.cur_born_place_index;
				--重新生成大牙怪
				BigToothOgre_server.OnReset();
				local params = BigToothOgre_server.GetParams()
				local cur_born_place_index = params.cur_born_place_index;
				
				--怪的新位置
				local msg = "[Aries][ServerObject30379]RebornIndex:"..cur_born_place_index;
				self:AddRealtimeMessage(msg);
				
				local k,item;
				for k,item in ipairs(new_gift_list) do
					local uid = item.uid; 
					local gift_type = item.gift_type; 
					local place_index = item.place_index; --礼物随机分布的位置
					local center_index = item.center_index;
					local msg = "[Aries][ServerObject30379]CreateGiftInstance:"..uid..":"..gift_type..":"..place_index..":"..center_index;
					self:AddRealtimeMessage(msg);
				end
				
				
				self:SetValue("BackupLivedItems",tooth_ogre_instance.gift_pools, revision);
				self:SetValue("BackupBornIndex",params.cur_born_place_index, revision);
				
				local msg = "[Aries][ServerObject30379]TestIndex1:"..old_index..":"..cur_born_place_index;
				self:AddRealtimeMessage(msg);
			end
			
			if(onhit)then
				local params = BigToothOgre_server.GetParams()
				if(params)then
					local msg = "[Aries][ServerObject30379]SetCurAnger:"..params.cur_anger or 0;
					--self:SendRealtimeMessage(from_nid, msg);
					self:AddRealtimeMessage(msg);
					self:SetValue("BackupAnger",params.cur_anger, revision);
				end
			end
		end
	end
end
local nextupdate_time = 0;
local cur_sec = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function BigToothOgre_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		local duration = tooth_ogre_instance.duration;
		--每个周期更新一次
		nextupdate_time = curTime + duration * 1000;
		cur_sec = cur_sec + duration;
		--更新时间
		BigToothOgre_server.UpdateTime();
		
		local max_lived_sec = tooth_ogre_instance.max_lived_sec;
		if(cur_sec >= max_lived_sec)then
			nextupdate_time = 0;
			cur_sec = 0;
			--清除过期的
			local invalid_list = BigToothOgre_server.CleanInvalidItems();
			if(invalid_list)then
				local k,item;
				for k,item in ipairs(invalid_list) do
					local uid = item.uid;
					if(uid)then
						local msg = "[Aries][ServerObject30379]DestroyGiftInstance:"..uid;
						self:AddRealtimeMessage(msg);
					end
				end
				self:SetValue("BackupLivedItems",tooth_ogre_instance.gift_pools, revision);
			end
		end
	end
end
