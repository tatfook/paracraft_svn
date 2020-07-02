--[[
Title: 
Author(s): Leio
Date: 2012/02/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererServer.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererCommon.lua");
local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local hasGSItem = PowerItemManager.IfOwnGSItem;

-- create class
local GathererServer = commonlib.gettable("ServerObjects.GathererServer");
Map3DSystem.GSL.config:RegisterNPCTemplate("gatherer", GathererServer)

local string_find = string.find;
local string_match = string.match;
GathererServer.valid_func_map= {
	["ServerObjects.GathererServer.TryPick_Handle"] = true,
	["ServerObjects.GathererServer.GetWorldData"] = true,
}
function GathererServer.DoFunction(from_nid,msg)
	local self = GathererServer;
	if(not from_nid or not msg)then return end
	local func_str,args_str = string_match(msg, "^%[Aries%]%[Gatherer%]%[(.-)%]%[(.-)%]$");
		
	LOG.std(nil, "debug","GathererServer.DoFunction",{func_str = func_str, args_str = args_str});
	if(func_str)then
		if(self.valid_func_map[func_str])then
			local func = commonlib.getfield(func_str);
			if(func)then
				local args;
				if(args_str)then
					args = commonlib.LoadTableFromString(args_str);
				end
				func(from_nid,args); 
			end
		else
			LOG.std(nil, "warn","client try call a invalid server function in GathererServer",{func_str = func_str, args_str = args_str});
		end
	end
end
function GathererServer.MsgProc(from_nid, msg)
	local self = GathererServer;
	if(not from_nid or not msg)then return end
	if(string_find(msg, "%[Aries%]%[Gatherer%]") == 1) then
		self.DoFunction(from_nid,msg);
	end
end
function GathererServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = GathererServer.OnNetReceive;
	self.OnFrameMove = GathererServer.OnFrameMove;

	if(self.gridnode)then
		GathererServer.template_map = GathererServer.template_map or GathererCommon.LoadTemplate();

		self.gridnode.all_node_map = {};
		self.gridnode.borned_map = {};
		self.gridnode.template_map = GathererServer.template_map
		self.gridnode.temp_uid = ParaGlobal.GenerateUniqueID();
		LOG.std(nil,"debug","GathererServer.CreateInstance",self.gridnode.temp_uid);
	end
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function GathererServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		GathererServer.MsgProc(from_nid, msg.body);	
	end
end
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function GathererServer:OnFrameMove(curTime, revision)
	if(not self.gridnode)then
		return;
	end
	local template_map = GathererServer.template_map;
	local all_node_map = self.gridnode.all_node_map;
	local borned_map = self.gridnode.borned_map;
	local temp_uid = self.gridnode.temp_uid;

	if(template_map and borned_map and all_node_map)then
		self.last_frame_move_time = self.last_frame_move_time or curTime;
		if( (curTime - self.last_frame_move_time) >= 5000) then
			-- only framemove every 5 seconds
			local delta = curTime - self.last_frame_move_time;
			self.last_frame_move_time = curTime;
			--增量
			local added_list;
			local k,v;
			for k,v in pairs(template_map) do
				local key = v.key;

				local born_time_node = all_node_map[key] or {born_sec = 0,};
				all_node_map[key] = born_time_node;
				local duration = v.duration or 0;

				if(not borned_map[key])then
					born_time_node.born_sec = born_time_node.born_sec + delta;
					if(born_time_node.born_sec >= duration)then
						borned_map[key] = true;

						added_list = added_list or  {}
						table.insert(added_list,key);
					end
				end
			end
			if(added_list)then
				-- LOG.std(nil,"debug","GathererServer added_list", added_list);
				GathererServer.CallAllUser(self.gridnode,"MyCompany.Aries.ServerObjects.GathererClientLogics.AddItemFromServer",added_list)
			end
		end
	end
end
function GathererServer.TryPick_Handle(nid,msg)
	local gridnode = gateway:GetPrimGridNode(nid);
	if(not gridnode)then return end

	local template_map = GathererServer.template_map;
	local all_node_map = gridnode.all_node_map;
	local borned_map = gridnode.borned_map;
	local temp_uid = gridnode.temp_uid;

	if(not template_map or not all_node_map or not borned_map)then
		return
	end
	nid = tonumber(nid);
	if(not nid or not msg)then return end;
	local id = msg.id
	local index = msg.index;
	local got_pt = nil;
	if(id and index)then
		local key = string.format("%d_%d",id,index);
		if(borned_map[key] and template_map[key] and all_node_map[key])then
			borned_map[key] = nil;
			local born_time_node = all_node_map[key];
			born_time_node.born_sec = 0;

			local node = template_map[key];
			local gsid = node.gsid;
			local level = node.level or 0;
			local quality = node.quality or 0;
			level = math.max(level,0);
			local enabled_native_quest = node.enabled_native_quest;--是否对任务系统有效
			local enabled_gather = node.enabled_gather;--是否对采集系统有效
			local got_pt = false;
			LOG.std(nil,"debug","GathererServer.TryPick_Handle", {temp_uid  = temp_uid, nid = nid, id = id, index = index, gsid = gsid, level = level, quality = quality,});
			if(gsid)then
				local can_get_gsid = false;
				--如果和任务相关
				if(enabled_native_quest)then
					can_get_gsid = true;
				end
				--如果和收集相关
				if(enabled_gather)then
					local userinfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid)
					if(userinfo)then
						local user = userinfo.user;
						local dragon = userinfo.dragon;
						if(dragon and dragon.stamina2 and dragon.stamina2 <= 0)then
							--体力值不够
							return
						end
					end
					can_get_gsid = true;
					--local skill_school_gsid = GathererCommon.quality_map[quality];
					----必须品质符合
					--if(skill_school_gsid)then
						--local bHas,__,__,copies = hasGSItem(nid,skill_school_gsid);
						--local skill_school_level = copies or 0;
						----技能必须要学习
						--if(skill_school_level > 0 and skill_school_level >= level)then
							----获得熟练度的概率
							--local skill_pts_percent = skill_school_level/(2*skill_school_level - level) - (skill_school_level - level) * 0.016;
							--LOG.std(nil,"debug","GathererServer got skill pts", {skill_pts_percent = skill_pts_percent, skill_school_level = skill_school_level,level = level});
							--skill_pts_percent = math.floor(skill_pts_percent * 100);
							--skill_pts_percent = math.max(skill_pts_percent,0);
							--skill_pts_percent = math.min(skill_pts_percent,100);
--
							--local random = math.random(100);
							--if(random <= skill_pts_percent)then
								--got_pt = true;
								----加1点熟练度
								--PowerItemManager.AddSkillPoint(nid, skill_school_gsid, 1);
							--end
							----扣1点体力值
							--PowerItemManager.CostStamina2(nid, 1, function(msg)
							--end);
						--end
					--end
					--扣1点体力值
					PowerItemManager.CostStamina2(nid, 1, function(msg)
					end);
				end
				if(can_get_gsid)then
					--获取到物品
					PowerItemManager.PurchaseItem(nid, gsid, 1);
				end
			end
			local args = {
				id = id,
				index = index,
				pick_nid = nid,
				got_pt = got_pt,
			}
			GathererServer.CallAllUser(gridnode,"MyCompany.Aries.ServerObjects.GathererClientLogics.DeleteItem_Handle",args);
			QuestServerLogics.Pick_ByServer(nid,id);
		end
	end
end
function GathererServer.GetWorldData(nid,msg)
	if(not nid)then return end
	local gridnode = gateway:GetPrimGridNode(nid)
	if(msg and gridnode and gridnode.template_map and gridnode.borned_map)then
		local temp_uid = gridnode.temp_uid;
		local template_map = gridnode.template_map;
		local borned_map = gridnode.borned_map;
		local worldname = msg.worldname;
		local list;
		if(not worldname)then
			list = GathererCommon.MapToList(borned_map);
		else
			list = {};
			local key,v;
			for key,v in pairs(borned_map) do
				local template_node = template_map[key]
				if(template_node.worldname and template_node.worldname == worldname)then
					table.insert(list,key);
				end
			end
		end
		-- LOG.std(nil,"debug","GathererServer.GetWorldData", {temp_uid = temp_uid,nid = nid});
		GathererServer.CallUser(gridnode,nid,"MyCompany.Aries.ServerObjects.GathererClientLogics.LoadItemFromServer",list);
	end
end
function GathererServer.CallAllUser(gridnode,func,msg)
	if(not gridnode or not func)then return end
	local server_object = gridnode:GetServerObject("gatherer");
	if(server_object) then
		msg = commonlib.serialize_compact(msg);
		local body = format("[Aries][Gatherer][%s][%s]",func,msg);
		local temp_uid = gridnode.temp_uid or "";
		LOG.std(nil,"debug","GathererServer.CallAllUser",body);
		server_object:AddRealtimeMessage(body);
	end
end
function GathererServer.CallUser(gridnode,nid,func,msg)
	nid = tostring(nid);
	if(not gridnode or not nid or not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std(nil,"error","GathererServer.CallUser", "the type of msg must be table!");
		return
	end
	local server_object = gridnode:GetServerObject("gatherer");
	if(server_object) then
		msg = commonlib.serialize_compact(msg);
		local body = format("[Aries][Gatherer][%s][%s]",func,msg);
		LOG.std(nil,"debug","GathererServer.CallUser", body);
		server_object:SendRealtimeMessage(nid, body);
	end
end