--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/WatermelonFarm/30192_WatermelonFarm_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local WatermelonFarm_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("watermelonfarm", WatermelonFarm_server)

local maxMembers = 10;
local watermelon_holes= {
}
local k;
for k = 1, 20 do
	watermelon_holes[k] = { label = k, isEmpty = true, };
end
---random search a number of item from a list
---@param source_list: it is a table which will be searched
---@param goal_num:the number of search from source_list;
---NOTE:if #source_list < goal_num then goal_num = #source_list;
---return nil or a result table
function WatermelonFarm_server.GetEmptyList(source_list,goal_num)
	if(not source_list or not goal_num or goal_num < 1)then return end
	
	local canSearch = false;
	local k,v;
	for k,v in ipairs(source_list) do
		if(v.isEmpty)then
			canSearch = true;
			break;
		end
	end
	if(not canSearch)then return end
	local empty_holes = {};
	for k,v in ipairs(source_list) do
		if(v.isEmpty)then
			table.insert(empty_holes,v);
		end
	end
	local len = table.getn(empty_holes);
	goal_num = math.min(len,goal_num);
	
	if(goal_num <= 0)then return end
	function getRandomItem(list)
		if(not list)then return end
		local len = table.getn(list);
		if(len == 0)then return end
		local r = math.random(len);
		local item = list[r];
		table.remove(list,r);
		return item;
	end
	local result_list = {};
	for k = 1, goal_num do
		local item = getRandomItem(empty_holes);
		if(item)then
			table.insert(result_list,item);
		end
	end
	return result_list;
end
function WatermelonFarm_server.RefreshHoles()
	local k,v;
	local num = 0;
	for k,v in ipairs(watermelon_holes) do
		if(not v.isEmpty)then
			num = num + 1;
		end
	end
	num = maxMembers - num;
	local result_list = WatermelonFarm_server.GetEmptyList(watermelon_holes,num);
	return result_list;
end
function WatermelonFarm_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = WatermelonFarm_server.OnNetReceive;
	self.OnFrameMove = WatermelonFarm_server.OnFrameMove;
	
	local result_list = WatermelonFarm_server.RefreshHoles();
	if(result_list)then
		local k,v;
		for k,v in ipairs(result_list) do
			local i = v.label;
			self:SetValue("CreateWatermelon"..i, "true", revision);
			v.isEmpty = false;
		end
	end
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function WatermelonFarm_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local index = string.match(msg.body, "^%[Aries%]%[ServerObject30192%]TryPickObj:(%d+)$") or -1;
			index = tonumber(index);
			if(index)then
				local melon_hole = watermelon_holes[index];
				if(melon_hole and not melon_hole.isEmpty)then
					melon_hole.isEmpty = true;
					-- update the value
					self:SetValue("CreateWatermelon"..index,"false", revision);
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30192]DestroyInstance:"..index;
					self:AddRealtimeMessage(msg);
					-- tell the user to receive a watermelon
					local msg = "[Aries][ServerObject30192]RecvWatermelon";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
		end
	end
end


local last_refreshed_hour = 0;

local nextupdate_time = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function WatermelonFarm_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		nextupdate_time = curTime + 1000;
		
		local time = ParaGlobal.GetTimeFormat("HH");
		
		--local time = ParaGlobal.GetTimeFormat("HH:mm");
		--local __,__,__,min = string.find(time,"(.+):(.+)");
		--min = tonumber(min);
		--
		--commonlib.echo("============now");
		--commonlib.echo(time);
		--commonlib.echo(min);
		--commonlib.echo(last_refreshed_hour);
		--
		--time = min;
		
		time = tonumber(time);
		if(not time) then
			return;
		end
		if(time and last_refreshed_hour ~= time)then
			last_refreshed_hour = time;
			nextupdate_time = 0;
			local result_list = WatermelonFarm_server.RefreshHoles();
			--commonlib.echo("================result_list");
			--commonlib.echo(result_list);
			if(result_list)then
				local k, v;
				for k, v in ipairs(result_list) do
					local i = v.label;
					self:SetValue("CreateWatermelon"..i, "true", revision);
					v.isEmpty = false;
					
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30192]create_water_melon"..i;
					self:AddRealtimeMessage(msg);
				end
			end
		end
	end
end
