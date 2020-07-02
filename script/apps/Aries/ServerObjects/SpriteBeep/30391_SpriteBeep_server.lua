--[[
Title: Server agent template class
Author(s): 
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/SpriteBeep/30391_SpriteBeep_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");
-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local SpriteBeep_server = {
}
Map3DSystem.GSL.config:RegisterNPCTemplate("spritebeep", SpriteBeep_server)
local static_hole_num = 6;

local sprite_info = {
	{ label = "水咕噜", total_holes = static_hole_num, holes = {}, },
	{ label = "枯木怪", total_holes = static_hole_num, holes = {}, },
	{ label = "金苍蝇", total_holes = static_hole_num, holes = {}, },
	{ label = "火毛怪", total_holes = static_hole_num, holes = {}, },
	{ label = "松木妖", total_holes = static_hole_num, holes = {}, },
	{ label = "粘土巨人", total_holes = static_hole_num, holes = {}, },
	{ label = "邪恶雪人", total_holes = static_hole_num, holes = {}, },
	{ label = "铁壳怪", total_holes = static_hole_num, holes = {}, },
	{ label = "沙漠毒蝎", total_holes = static_hole_num, holes = {}, },
	{ label = "烈火蟹", total_holes = static_hole_num, holes = {}, },
	{ label = "火鬃怪", total_holes = static_hole_num, holes = {}, },
	
	
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
	{ label = "", total_holes = static_hole_num, holes = {}, },
}

function SpriteBeep_server.InitHoles(list,len)
	if(not list or not len)then return end
	local k;
	for k = 1,len do
		list[k] = { label = k, isEmpty = true, item = nil,  }
	end
end
local k = 1;
local len = #sprite_info;
for k = 1, len do
	SpriteBeep_server.InitHoles(sprite_info[k].holes,sprite_info[k].total_holes);
end
function SpriteBeep_server.GetEmptyHoles()
	----找到空闲列表
	--local list_1 = commonlib.GetEmptyList(sprite_info[1].holes,3)
	--local list_2 = commonlib.GetEmptyList(sprite_info[2].holes,3)
	--local list_3 = commonlib.GetEmptyList(sprite_info[3].holes,3)
	--local list_4 = commonlib.GetEmptyList(sprite_info[4].holes,3)
	--local list_5 = commonlib.GetEmptyList(sprite_info[5].holes,3)
	--local list_6 = commonlib.GetEmptyList(sprite_info[6].holes,3)
	--local list_7 = commonlib.GetEmptyList(sprite_info[7].holes,3)
	--local list_8 = commonlib.GetEmptyList(sprite_info[8].holes,3)
	--local list_9 = commonlib.GetEmptyList(sprite_info[9].holes,3)
	--local list_10 = commonlib.GetEmptyList(sprite_info[10].holes,3)
	--
	----随机生成物品
	--SpriteBeep_server.MadeRandomItems(list_1,1)
	--SpriteBeep_server.MadeRandomItems(list_2,2)
	--SpriteBeep_server.MadeRandomItems(list_3,3)
	--SpriteBeep_server.MadeRandomItems(list_4,4)
	--SpriteBeep_server.MadeRandomItems(list_5,5)
	--SpriteBeep_server.MadeRandomItems(list_6,6)
	--SpriteBeep_server.MadeRandomItems(list_7,7)
	--SpriteBeep_server.MadeRandomItems(list_8,8)
	--SpriteBeep_server.MadeRandomItems(list_9,9)
	--SpriteBeep_server.MadeRandomItems(list_10,10)
	--return list_1,list_2,list_3,list_4,list_5,list_6,list_7,list_8,list_9,list_10;
	
	--@param index:第几块区域
	--@param num:每个区域每次生成几个怪
	function randomItems(index,num)
		if(not index or not num)then return end
		local holes = sprite_info[index].holes;
		if(holes)then
			--找到空闲列表
			local list = commonlib.GetEmptyList(holes,num);
			if(list)then
				--随机生成物品
				SpriteBeep_server.MadeRandomItems(list,index)
				return list;
			end
		end
	end
	local result = {};
	local k;
	local len = #sprite_info;
	for k = 1, len do
		local list = randomItems(k,2);
		if(list)then
			table.insert(result,list);
		end
	end
	return result;
end
--为每个位置随机分配物品
--@param list:位置列表
--@param square: 在哪个区域生成
function SpriteBeep_server.MadeRandomItems(list,square)
	if(not list or not square)then return end
	local k,v;
	for k,v in ipairs(list) do
		local place_index = v.label;
		
		local sprite_item_info = sprite_info[square];
		local label = sprite_item_info.label;
		local id = square;
		local tooltip_index = math.random(3);
		
		local item = {
			label = label,--"水咕噜"
			id = id,--即是id 又可以代表区域
			place_index = place_index,--这个区域的第几个点
			tooltip_index = tooltip_index,--冒泡的内容
		}
		v.item = item;
	end
end
function SpriteBeep_server.CreateItems(server,revision,isRealtime)
	if(not server)then return end
	local result = SpriteBeep_server.GetEmptyHoles();
	function updateList(list)
		if(list)then
			local k,v;
			for k,v in ipairs(list) do
				--v = {label = 1, isEmpty = true,item = item,}
				v.isEmpty = false;
				local item = v.item;
				if(item)then
					local id = item.id;
					local place_index = item.place_index;
					local tooltip_index = item.tooltip_index;
					if(id and place_index and tooltip_index)then
						if(isRealtime)then
							-- boardcast to all hosting clients
							local msg = "[Aries][ServerObject30391]CreateSpriteImmde:"..id..":"..place_index..":"..tooltip_index;
							commonlib.echo("====id");
							commonlib.echo(id);
							server:AddRealtimeMessage(msg);
						end
						server:SetValue("CreateSprite:"..id..":"..place_index, item, revision);
					end
				end
			end
		end
	end
	if(result)then
		local k,v;
		for k,v in ipairs(result) do
			updateList(v);
		end
	end
end
function SpriteBeep_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = SpriteBeep_server.OnNetReceive;
	self.OnFrameMove = SpriteBeep_server.OnFrameMove;
	
	SpriteBeep_server.CreateItems(self,revision,false)
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function SpriteBeep_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local id,place_index = string.match(msg.body, "^%[Aries%]%[ServerObject30391%]TryPickObj:(%d+):(%d+)$");
			id = tonumber(id);
			place_index = tonumber(place_index);
			if(id and place_index)then
				local sprite_item_info = sprite_info[id];
				if(sprite_item_info)then
					local hole_item = sprite_item_info.holes[place_index];
					if(hole_item)then
						if(not hole_item.isEmpty)then
							hole_item.isEmpty = true;--恢复为空的位置
							hole_item.item = nil;--清空hold的物品
							
							-- update the value
							self:SetValue("CreateSprite:"..id..":"..place_index, {}, revision);
							-- boardcast to all hosting clients
							local msg = "[Aries][ServerObject30391]DestroyInstance:"..id..":"..place_index;
							self:AddRealtimeMessage(msg);
						end	
					end
				end
			end
		end
	end
end
local nextupdate_time = 0;
local cur_sec = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function SpriteBeep_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		local duration = 5;
		local max_sec = 600;
		--每个周期更新一次
		nextupdate_time = curTime + duration * 1000;
		cur_sec = cur_sec + duration;
		if(cur_sec >= max_sec)then
			nextupdate_time = 0;
			cur_sec = 0;
			SpriteBeep_server.CreateItems(self,revision,true)
		end
	end
end
