--[[
Title: Server agent template class
Author(s): 
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/RecycleBin/30383_RecycleBin_server.lua");

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local RecycleBin_server = {
}
local rubbish_prop = {
	1,--可回收垃圾
	2,--厨房垃圾
	3,--有害垃圾
	4,--其他垃圾
}
local rubbish_type = {
	--可回收垃圾
	{ label = "废纸片", item_id = 101, prop = 1, },
	{ label = "废塑料", item_id = 102, prop = 1,},
	{ label = "玻璃块", item_id = 103, prop = 1,},
	{ label = "锈铁皮", item_id = 104, prop = 1,},
	{ label = "小布片", item_id = 105, prop = 1,},
	--厨房垃圾
	{ label = "破蛋壳", item_id = 201, prop = 2,},
	{ label = "烂菜叶", item_id = 202, prop = 2,},
	--有害垃圾
	{ label = "废电池", item_id = 301, prop = 3,},
	{ label = "废灯泡", item_id = 302, prop = 3,},
	{ label = "过期百草丹", item_id = 303, prop = 3,},
	--其他垃圾
	{ label = "破陶罐", item_id = 401, prop = 4,},
	{ label = "渣土", item_id = 402, prop = 4,},
}
local rubbish_place = {
	1,--生命之泉水面上
	2,--小镇广场地面上
	3,--购物街地面上
}
--各个区域随机分布点的总数
local rubbish_place_totals = {
	12,
	12,
	12,
}
function RecycleBin_server.InitHoles(list,len)
	if(not list or not len)then return end
	local k;
	for k = 1,len do
		list[k] = { label = k, isEmpty = true, item = nil,  }
	end
end

--------------------
local rubbish_1_holes = {
}
local rubbish_2_holes = {
}
local rubbish_3_holes = {
}

local len = rubbish_place_totals[1];
RecycleBin_server.InitHoles(rubbish_1_holes,len)

local len = rubbish_place_totals[2];
RecycleBin_server.InitHoles(rubbish_2_holes,len)

local len = rubbish_place_totals[3];
RecycleBin_server.InitHoles(rubbish_3_holes,len)

function RecycleBin_server.GetEmptyHoles()
	--找到空闲列表
	local list_1 = commonlib.GetEmptyList(rubbish_1_holes,6)
	local list_2 = commonlib.GetEmptyList(rubbish_2_holes,6)
	local list_3 = commonlib.GetEmptyList(rubbish_3_holes,6)
	
	--随机生成物品
	RecycleBin_server.MadeRandomItems(list_1,1)
	RecycleBin_server.MadeRandomItems(list_2,2)
	RecycleBin_server.MadeRandomItems(list_3,3)
	
	return list_1,list_2,list_3;
end
--为每个位置随机分配物品
--@param list:位置列表
--@param square: 在哪个区域生成
function RecycleBin_server.MadeRandomItems(list,square)
	if(not list or not square)then return end
	local item_types_len = #rubbish_type;
	local k,v;
	for k,v in ipairs(list) do
		--物品的区域和位置
		local place_square = square;
		local place_index = v.label;
		
		--生成物品的属性
		local item_type_index = math.random(item_types_len);
		local item_type_info = rubbish_type[item_type_index];
		local label = item_type_info.label;
		local item_id = item_type_info.item_id;
		local prop = item_type_info.prop;
		
		local item = {
			label = label,
			item_id = item_id,
			prop = prop,
			place_square = place_square,
			place_index = place_index,
		};
		
		--把生成的新物品记录在 这个洞里面
		--local item = { label = "废纸片", item_id = 101, prop = 1, place_square = 1, place_index = 1, }
		v.item = item;
	end
end
Map3DSystem.GSL.config:RegisterNPCTemplate("recyclebin", RecycleBin_server)

function RecycleBin_server.CreateItems(server,revision,isRealtime)
	if(not server)then return end
	local list_1,list_2,list_3 = RecycleBin_server.GetEmptyHoles();
	function upateList(list)
		if(list)then
			local k,v;
			for k,v in ipairs(list) do
				--v = {label = 1, isEmpty = true,item = item,}
				v.isEmpty = false;
				local item = v.item;
				if(item)then
					local place_square = item.place_square;
					local place_index = item.place_index;
					local prop = item.prop;
					local item_id = item.item_id;
					if(place_square and place_index and prop and item_id)then
						if(isRealtime)then
							-- boardcast to all hosting clients
							local msg = "[Aries][ServerObject30383]CreateRubbishImmde:"..place_square..":"..place_index..":"..prop..":"..item_id;
							server:AddRealtimeMessage(msg);
						end
						server:SetValue("CreateRubbish:"..place_square..":"..place_index, item, revision);
					end
				end
			end
		end
	end
	upateList(list_1);
	upateList(list_2);
	upateList(list_3);
end
function RecycleBin_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = RecycleBin_server.OnNetReceive;
	self.OnFrameMove = RecycleBin_server.OnFrameMove;
	
	RecycleBin_server.CreateItems(self,revision,false)
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function RecycleBin_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local place_square,place_index,answer_prop = string.match(msg.body, "^%[Aries%]%[ServerObject30383%]TryPickObj:(%d+):(%d+):(%d+)$");
			place_square = tonumber(place_square);--在什么区域
			place_index = tonumber(place_index);--在第几个位置
			answer_prop = tonumber(answer_prop);--回答的物体属性
			if(place_square and place_index and answer_prop)then
				local holes;
				if(place_square == 1)then
					holes = rubbish_1_holes;
				elseif(place_square == 2)then
					holes = rubbish_2_holes;
				elseif(place_square == 3)then
					holes = rubbish_3_holes;
				end
				-- update the value
				self:SetValue("CreateRubbish:"..place_square..":"..place_index, {}, revision);
				-- boardcast to all hosting clients
				local msg = "[Aries][ServerObject30383]DestroyInstance:"..place_square..":"..place_index;
				self:AddRealtimeMessage(msg);
				if(holes)then
					local hole_item = holes[place_index];
					if(hole_item)then
						local isEmpty = hole_item.isEmpty;
						local item = hole_item.item;
						--如果已经是空的
						if(not item or isEmpty)then
							local msg = "[Aries][ServerObject30383]RecvCallBack:Faild";
							self:SendRealtimeMessage(from_nid, msg);
							return
						end
						hole_item.isEmpty = true;--恢复为空的位置
						hole_item.item = nil;--清空hold的物品
						if(item)then
							local correct_prop = item.prop;--正确的答案
							
							
							--如果回答正确
							if(correct_prop == answer_prop)then
								-- tell the user to receive a gift
								local msg = "[Aries][ServerObject30383]RecvCallBack:AnswerCorrect";
								self:SendRealtimeMessage(from_nid, msg);
							else
								local msg = "[Aries][ServerObject30383]RecvCallBack:AnswerWrong";
								self:SendRealtimeMessage(from_nid, msg);
							end
						end
					else
						local msg = "[Aries][ServerObject30383]RecvFaild";
						self:SendRealtimeMessage(from_nid, msg);
					end
				end
			end
		end
	end
end
local nextupdate_time = 0;
local cur_sec = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function RecycleBin_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		local duration = 60;
		local max_sec = 300;
		--每个周期更新一次
		nextupdate_time = curTime + duration * 1000;
		cur_sec = cur_sec + duration;
		if(cur_sec >= max_sec)then
			nextupdate_time = 0;
			cur_sec = 0;
			RecycleBin_server.CreateItems(self,revision,true)
		end
	end
end
