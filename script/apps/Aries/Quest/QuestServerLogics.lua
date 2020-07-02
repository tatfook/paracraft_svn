--[[
Title: 
Author(s): Leio
Date: 2010/8/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
------------------------------------------------------------
]]
local type = type;
local format = format;
local LOG = LOG;
local tonumber = tonumber;
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetServerHelper.lua");
local CombatPetServerHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetServerHelper");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/arena_server.lua");
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/player_server.lua");
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");

NPL.load("(gl)script/apps/GameServer/GSL_transactions.lua");
local GSL_transaction = commonlib.gettable("Map3DSystem.GSL.GSL_transaction");

NPL.load("(gl)script/apps/Aries/Quest/QuestChoice.lua");
local QuestChoice = commonlib.gettable("MyCompany.Aries.Quest.QuestChoice");
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
-- create class
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
QuestServerLogics.server = nil;
QuestServerLogics.mob_path_map = nil;
QuestServerLogics.providers = {};
--server区分儿童版和青年版
QuestServerLogics.load_version = "kids";-- kids or teen
function QuestServerLogics.IsTeenVersion()
	local self = QuestServerLogics;
	if(self.load_version == "teen")then
		return true;
	end
end
--针对pvp专用，根据奖励 20030试炼徽章 20031赛场英雄徽章 20043 英雄谷奖章 产生任务进度
function QuestServerLogics.DoAddValue_ByLoots(nid,loots)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info", "QuestServerLogics.DoAddValue_ByLoots", {nid = nid, loots = loots, });
	
	if(not nid or not loots)then return end
	if(loots[20030] or loots[20031] or loots[20043])then
		local result = {};
		local gsid,v;
		for gsid,v in pairs(loots) do
			local custom_goal_id;
			if(gsid == 20030)then
				custom_goal_id = 79101;
			elseif(gsid == 20031)then
				custom_goal_id = 79102;
			elseif(gsid == 20043)then
				custom_goal_id = 79104;
			end
			if(custom_goal_id)then
				table.insert(result,{
					id = custom_goal_id,
					value = v,
				});
			end
		end
		local provider = self.CreateOrGetProvider(nid)
		LOG.std(nil, "info","QuestServerLogics.DoAddValue_ByLoots result",result);
		local added_quest_map = provider:DoAddValue(result);
		local msg = {
			nid = nid,
			added_quest_map = added_quest_map,
		}
		LOG.std(nil, "info","QuestServerLogics.DoAddValue_ByLoots",msg);
		self.DoAddValue(nid,msg);
	end
end
function QuestServerLogics.DoAddValue_FromClient(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	local provider = self.CreateOrGetProvider(nid)
    local increment = msg.increment;
	LOG.std(nil, "info","QuestServerLogics.DoAddValue_FromClient input",increment);

	--id区间验证
	if(increment)then
		local clone_increment = {};
		local k,v;
		for k,v in ipairs(increment) do
			if(not QuestHelp.IsServerID(v.id))then
				table.insert(clone_increment,{
					id = v.id,
					value = v.value,
				});
			end
		end
		increment = clone_increment;
	end
	LOG.std(nil, "info","QuestServerLogics.DoAddValue_FromClient input2",increment);
	if(not increment or #increment == 0)then
		return
	end
	local added_quest_map = provider:DoAddValue(increment);
	local msg = {
		nid = nid,
		added_quest_map = added_quest_map,
	}
	LOG.std(nil, "info","QuestServerLogics.DoAddValue_FromClient",msg);
	self.DoAddValue(nid,msg);
end

function QuestServerLogics.DoSync_Server_ClientGoalItem(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	local provider = self.CreateOrGetProvider(nid)
    local sync_quest_item_map = msg.sync_quest_item_map;
	LOG.std(nil, "info","QuestServerLogics.DoSync_Server_ClientGoalItem",sync_quest_item_map);
	--TODO:增加sync_quest_item_map 里面 q_item 的gsid区间验证
	provider:DoSync_Server_ClientGoalItem(sync_quest_item_map);
end
function QuestServerLogics.Pick_ByServer(nid,item_id)
	local self = QuestServerLogics;
	if(not nid or not item_id)then return end
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.Pick_ByServer 1",item_id);
	local provider = self.CreateOrGetProvider(nid)
	local result = {
		{id = item_id,value = 1},
		{id = 79036,value = 1},--采集草药或者矿石
	}
	local added_quest_map = provider:DoAddValue(result);
	local msg = {
		nid = nid,
		added_quest_map = added_quest_map,
	}
	LOG.std(nil, "info","QuestServerLogics.Pick_ByServer 2",msg);
	self.DoAddValue(nid,msg);
end
QuestServerLogics.PvP_WorldInstance_Map = {

}
--红蘑菇竞技场 或者战场胜利 触发任务进度 
--@param nid:user's nid
--@param worldname:红蘑菇 "HaqiTown_RedMushroomArena" 公平竞技场"HaqiTown_TrialOfChampions" 战场 "BattleField_ChampionsValley" "BattleField_ChampionsValley_Master"
function QuestServerLogics.PvP_Successful_Handler_By_Worldname(nid,worldname,is_win)
	local self = QuestServerLogics;
	LOG.std(nil, "info","QuestServerLogics.PvP_Successful_Handler_By_Worldname",{nid,worldname,is_win});
	nid = tonumber(nid);
	if(not nid or not worldname)then return end
	local result;
	if(worldname == "BattleField_ChampionsValley" or worldname == "BattleField_ChampionsValley_Master")then
		result = {{ id = 79203, value = 1, }};
		if(is_win)then
			result[2] = { id = 79205, value = 1, };
		end
	elseif(worldname == "HaqiTown_TrialOfChampions")then
		result = {{ id = 79204, value = 1, }};
	elseif(worldname == "HaqiTown_RedMushroomArena")then
		result = {{ id = 79202, value = 1, }};
		if(is_win)then
			result[2] = { id = 79102, value = 1, };--机器人赛场胜利
		end
	end
	if(not result)then return end 
	local provider = self.CreateOrGetProvider(nid)
	local added_quest_map = provider:DoAddValue(result);
	local msg = {
		nid = nid,
		added_quest_map = added_quest_map,
	}
	self.DoAddValue(nid,msg);
end
--指定副本触发一次
function QuestServerLogics.WorldInstance_Actived_Handler_By_Worldname(nid,worldname)
	local self = QuestServerLogics;
	LOG.std(nil, "info","QuestServerLogics.WorldInstance_Actived_Handler_By_Worldname",{nid,worldname});
	nid = tonumber(nid);
	if(not nid or not worldname)then return end
	local __,_map = QuestHelp.GetCustomGoalList();
	worldname = string.lower(worldname);
	if(_map)then
		local k,v;
		for k,v in pairs(_map) do
			local id = v.id;
			local includeworld = v.includeworld;
			if(id and includeworld and includeworld ~= "")then
				includeworld = string.lower(includeworld);

				local _worldname;
				for _worldname in string.gfind(includeworld, "([^%s,]+)") do
					if(_worldname == worldname)then
						local result = {{ id = id, value = 1, }};
						local provider = self.CreateOrGetProvider(nid)
						local added_quest_map = provider:DoAddValue(result);
						local msg = {
							nid = nid,
							added_quest_map = added_quest_map,
						}
						self.DoAddValue(nid,msg);
					end
				end
			end
		end
	end
end
function QuestServerLogics.IncludeSpecialWorld(worldname)
	if(not worldname)then
		return
	end
	local world = {
		"BattleField_ChampionsValley","BattleField_ChampionsValley_Master","HaqiTown_TrialOfChampions"
	};
	local k,v;
	for k,v in ipairs(world) do
		if(string.lower(v) == string.lower(worldname))then
			return true;
		end
	end
end
--pvp副本触发一次
function QuestServerLogics.PvP_WorldInstance_Actived_Handler(nid,arena_world_config_file)
	local self = QuestServerLogics;
	LOG.std(nil, "info","QuestServerLogics.PvP_WorldInstance_Actived_Handler",{nid,arena_world_config_file});
	nid = tonumber(nid);
	if(not nid or not arena_world_config_file)then return end
	arena_world_config_file = string.lower(arena_world_config_file);
	
	local __,_map = QuestHelp.GetCustomGoalList();
	if(_map)then
		local k,v;
		for k,v in pairs(_map) do
			local id = v.id;
			local includeworld = v.includeworld;
			if(id and includeworld and includeworld ~= "")then
				includeworld = string.lower(includeworld);
				local worldname;
				for worldname in string.gfind(includeworld, "([^%s,]+)") do
					if(string.find(arena_world_config_file,worldname))then
						--忽略战场 公平竞技场
						if(not QuestServerLogics.IncludeSpecialWorld(worldname))then
							local result = {{ id = id, value = 1, }};
							local provider = self.CreateOrGetProvider(nid)
							local added_quest_map = provider:DoAddValue(result);
							local msg = {
								nid = nid,
								added_quest_map = added_quest_map,
							}
							self.DoAddValue(nid,msg);
						end
					end
				end
			end
		end
	end
end
--@param nid:user nid
--@param mobs:{[key] = count, [key] = count}
--@param difficulty:"easy" "normal" "hard",default value is "normal"
function QuestServerLogics.Kill_Handler(nid,mobs,difficulty)
	local self = QuestServerLogics;
	local mode = 2;
	difficulty = difficulty or "normal";
	if(difficulty == "easy")then
		mode = 0;
	elseif(difficulty == "normal")then
		mode = 1;
	elseif(difficulty == "hard")then
		mode = 2;
	elseif(difficulty == "hero")then
		mode = 3;
	elseif(difficulty == "nightmare")then
		mode = 4;
	end
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.Kill_Handler input nid",nid);
	LOG.std(nil, "info","QuestServerLogics.Kill_Handler input mobs",mobs);
	if(not nid or not mobs)then return end
	local key,value;
	local result = {};
	if(not self.mob_path_map)then
		LOG.std(nil, "info","QuestServerLogics reload mob_path_map",nid);
		self.mob_path_map = QuestHelp.BuildMobMap(self.IsTeenVersion());
	end
	for key,value in pairs(mobs) do
		if(self.mob_path_map)then
			key = string.lower(key);
			local mob = self.mob_path_map[key];
			if(mob and mob.id)then
				table.insert(result,{
					id = mob.id,
					value = value,
				});
			else
				LOG.std(nil, "info","QuestServerLogics mob_path is nil",key);
			end
		else
			LOG.std(nil, "info","QuestServerLogics mob_path_map is nil",nid);
		end
	end
	LOG.std(nil, "info","QuestServerLogics.Kill_Handler killed",result);
	local provider = self.CreateOrGetProvider(nid)
	--有任务药丸 任务目标数量增大1000倍
	QuestServerLogics.Expend_IfUsedQuestBonus(nid,result);
	local added_quest_map = provider:DoAddValue(result,mode);
	local msg = {
		nid = nid,
		added_quest_map = added_quest_map,
	}
	LOG.std(nil, "info","QuestServerLogics.Kill_Handler",msg);
	self.DoAddValue(nid,msg);
end
	--有任务药丸 任务目标数量增大1000倍
function QuestServerLogics.Expend_IfUsedQuestBonus(nid,result)
	if(QuestServerLogics.IsUsedQuestBonus(nid) and result)then
		local scale = 1000;
		local k,v;
		for k,v in ipairs(result) do
			v.value = v.value * scale;
		end
	end
end
--是否使用的任务药丸
function QuestServerLogics.IsUsedQuestBonus(nid)
	if(not nid)then return end
	local item = PowerItemManager.GetItemByBagAndPosition(nid, 0, 45);
	if(item and item.gsid)then
		local gsid = item.gsid;
		local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem)then
			local stat = gsItem.template.stats[73];
			if(stat and stat == 1)then
				return true;
			end
		end
	end
end
function QuestServerLogics.DoUserDisconnect(nid)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	if(not nid)then return end
	if(self.providers[nid])then
		self.providers[nid] = nil;
		LOG.std(nil, "info","QuestServerLogics.DoUserDisconnect",nid);
	end
end
function QuestServerLogics.CallInit_Handler(nid,msg)
	local self = QuestServerLogics;
	LOG.std(nil, "info","QuestServerLogics.CallInit_Handler 1",nid);
	self.DoInit(nid);
	if(not self.mob_path_map)then
		self.mob_path_map = QuestHelp.BuildMobMap(self.IsTeenVersion());
		LOG.std(nil, "info","QuestServerLogics.CallInit_Handler 2",self.mob_path_map);
	end
	QuestHelp.LoadAllXmlFiles(self.load_version);
end
--初始化
function QuestServerLogics.DoInit(nid)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.DoInit",nid);
	if(not nid)then return end
	--重新清空数据
	self.DoUserDisconnect(nid);
	--加载周长任务模板
	QuestServerLogics.LoadQuestWeekRepeat();
	local provider = self.CreateOrGetProvider(nid)
	--删除前一天已经完成的日常任务
	provider:DeleteWeeklyQuest(function()
		local quests_list = provider.quests_list;
		--生成今天有效的日常任务
		local weekly_valid_maps = self.LoadWeeklyQuest();
		local msg = {
			issuccess = true,
			state = "init_quest",
			quests_list = quests_list,
			weekly_valid_maps = weekly_valid_maps,
		};
		LOG.std(nil, "info","QuestServerLogics.DoInit 2", nid);
		self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.DoInitRemoteQuest_Handler",msg)
	end);

end
function QuestServerLogics.CreateOrGetProvider(nid)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	if(not nid)then return end
	local provider = self.providers[nid];
	if(not provider)then
		local load_version = self.load_version;
		provider = QuestProvider:new{
			remote = true,
			nid = nid,
			load_version = load_version,
		};
		self.providers[nid] = provider;
		provider:OnInit();
		
	end
	return provider;
end
--用所有世界的server object 发消息
function QuestServerLogics.DoAddValue(nid,msg)
	local self = QuestServerLogics;
	nid = tostring(nid);
	if(not nid or not msg)then return end
	--self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.DoAddValue_Handler",msg)
	local func = "MyCompany.Aries.Quest.QuestClientLogics.DoAddValue_Handler";
	local gridnode = gateway:GetPrimGridNode(nid)
	if(gridnode)then
		local server_object = gridnode:GetServerObject("quest10000");
		if(server_object) then
			local body = format("[Aries][Quest][%s][%s]",func, commonlib.serialize_compact(msg) );
			LOG.std(nil,"info","QuestServerLogics.DoAddValue", body);
			server_object:SendRealtimeMessage(nid, body);
		end
	end
end
------------------------------------------------------------------------------------
--内部用户使用
------------------------------------------------------------------------------------
--可以直接删除任务的用户
function QuestServerLogics.IsPowerUser(nid)
	return QuestHelp.IsPowerUser(nid);
end
function QuestServerLogics.Test_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	local canDelete = self.IsPowerUser(nid);
	if(not canDelete)then
		LOG.std(nil, "info","QuestServerLogics.TryKillMobByUser",nid);
		return
	end
	local mode = msg.mode;
	local provider = self.CreateOrGetProvider(nid)
	local msg = {};
	local k;
	for k = 1,5000 do
		local id = 40000+k;
		msg[k] = {
			id = id,
			value = 1,
		}
	end
    local added_quest_map = provider:DoAddValue(msg,mode);
	local msg = {
		nid = nid,
		added_quest_map = added_quest_map,
	}
	LOG.std(nil, "info","QuestServerLogics.Test_Handler",msg);
	self.DoAddValue(nid,msg);
end
--指定的用户可以直接删除任务
function QuestServerLogics.DoReset_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	if(not nid or not msg)then return end
	local canDelete = self.IsPowerUser(nid);
	if(not canDelete)then
		LOG.std(nil, "info","QuestServerLogics.TryDeleteByUser",nid);
		return
	end
	local provider = self.CreateOrGetProvider(nid)
	provider:ClearAllServerData(function(msg)
		if(msg and msg.issuccess)then
			provider:OnInit();
			local msg = {
			};
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.DoReset_Handler",msg)
		end
	end);
end
--指定的用户可以直接删除任务
function QuestServerLogics.TryDelete_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.TryDelete_Handler",msg);
	if(not nid or not msg)then return end
	local canDelete = self.IsPowerUser(nid);
	if(not canDelete)then
		LOG.std(nil, "info","QuestServerLogics.TryDeleteByUser",nid);
		return
	end

	local provider = self.CreateOrGetProvider(nid)
	local userinfo = provider:GetUserInfo();
	msg = {
		nid = nid,
		id = msg.id,
	}
	provider:TryDelete(msg,function(msg)
		if(msg)then
			msg.userinfo = userinfo;
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryDelete_Handler",msg)
		end
	end);
end
------------------------------------------------------------------------------------
function QuestServerLogics.TryAccept_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.TryAccept_Handler",msg);
	if(not nid or not msg)then return end
	local is_power_user = self.IsPowerUser(nid);
	local provider = self.CreateOrGetProvider(nid)
	local userinfo = provider:GetUserInfo();
	local quest_msg = {
		nid = nid,
		id = msg.id,
		is_power_user = is_power_user,
	}
	local templates = provider:GetTemplateQuests();
	if(templates)then
		local template = templates[quest_msg.id];
		--local has_gsItem,bag_list = provider:HasGSItem_list(template.RequestAttr);
		--LOG.std(nil, "info","QuestServerLogics.TryAccept_Handler GetDynamicAttrValue",{ has_gsItem = has_gsItem, bag_list = bag_list, });
		----如果前置条件包含真实物品数量
		--if(has_gsItem)then
			--PowerItemManager.SyncUserItems(nid, bag_list, function(msg) 
				--provider:TryAccept(quest_msg,function(msg)
					--if(msg)then
						--msg.userinfo = userinfo;
						--self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryAccept_Handler",msg)
					--end
				--end);		
			--end, function() end);
		--else
			--provider:TryAccept(quest_msg,function(msg)
				--if(msg)then
					--msg.userinfo = userinfo;
					--self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryAccept_Handler",msg)
				--end
			--end);		
		--end

		if(template and template.RequestAttr)then
			local RequestAttr = template.RequestAttr;
			--检测是否有动态属性:人物自身的属性
			local result,has_dynamic_value,bag_list = provider:GetDynamicAttrValue(RequestAttr);
			LOG.std(nil, "info","TryAccept_Handler QuestServerLogics GetDynamicAttrValue",{ has_dynamic_value = has_dynamic_value, bag_list = bag_list, });
			if(has_dynamic_value)then
				local function GetResist(player,school)
					local v = player:GetResist(school) or 0;
					return -v;
				end
				local len = #bag_list;
				local function check_stats()
					Arena.OnReponse_CheckStats(nid, function(player)
						local role_str = PowerItemManager.GetUserSchool(nid)
						local k,v;
						for k,v in ipairs(RequestAttr) do
							local id = v.id;
							--超魔生成率
							if(id == 79032)then
								local value = player:GetPowerPipChance() or 0;
								provider:SetCombatValue(id,value);
							--本系攻击力
							elseif(id == 79033)then
								local value = player:GetDamageBoost(role_str) or 0;
								provider:SetCombatValue(id,value);
							--最大防御力
							elseif(id == 79034)then
								local value = 0;
								value = math.max(value,GetResist(player,"fire"));
								value = math.max(value,GetResist(player,"ice"));
								value = math.max(value,GetResist(player,"storm"));
								value = math.max(value,GetResist(player,"myth"));
								value = math.max(value,GetResist(player,"life"));
								value = math.max(value,GetResist(player,"death"));
								value = math.max(value,GetResist(player,"balance"));
								provider:SetCombatValue(id,value);
							end
						end
						LOG.std(nil, "info","QuestServerLogics OnReponse_CheckStats",{nid = provider.nid,dynamic_attr_cache_map = provider.dynamic_attr_cache_map,});
						provider:TryAccept(quest_msg,function(msg)
							if(msg)then
								msg.userinfo = userinfo;
								self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryAccept_Handler",msg)
							end
						end);		
					end)
				end
				if(len > 0)then
					PowerItemManager.SyncUserItems(nid, bag_list, function(msg) 
						check_stats();
					end, function() end);
				else
					check_stats();
				end
			
			else
				provider:TryAccept(quest_msg,function(msg)
					if(msg)then
						msg.userinfo = userinfo;
						self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryAccept_Handler",msg)
					end
				end);		
			end
		else
			provider:TryAccept(quest_msg,function(msg)
				if(msg)then
					msg.userinfo = userinfo;
					self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryAccept_Handler",msg)
				end
			end);		
		end
	end
end
function QuestServerLogics.GetRewardList(nid,questid,reward_index_list)
	local self = QuestServerLogics;
	if(not nid or not questid)then return end
	local provider = self.CreateOrGetProvider(nid)
	local templates = provider:GetTemplateQuests();
	local template = templates[questid];
	LOG.std(nil, "info","QuestServerLogics.GetRewardList",{nid = nid,questid = questid,reward_index_list = reward_index_list});
	local result = {};
	if(template and template.Reward)then
		local Reward = template.Reward;
		local auto = Reward[1];
		local temp_auto = {};
		if(auto)then
			local k,v;
			for k,v in ipairs(auto) do
				local id = tonumber(v.id);
				local value = tonumber(v.value);
				table.insert(result,{
					id = id,
					value = value,
				});

				table.insert(temp_auto,{
					id = id,
					value = value,
				});
			end
		end
		LOG.std(nil, "info","QuestServerLogics.GetRewardList auto",temp_auto);
		local manual = Reward[2];
		local temp_manual = {};
		if(reward_index_list and manual)then
			local k,v;
			for k,v in ipairs(reward_index_list) do
				local index = tonumber(v);
				local kk,vv;
				for kk,vv in ipairs(manual) do
					local id = vv.id;
					local value = vv.value;
					id = tonumber(id);
					value = tonumber(value);
					if(index == kk)then
						table.insert(result,{
							id = id,
							value = value,
						});

						table.insert(temp_manual,{
							id = id,
							value = value,
						});
					end
				end
			end
		end
		LOG.std(nil, "info","QuestServerLogics.GetRewardList manual",temp_manual);
	end
	LOG.std(nil, "info","QuestServerLogics.GetRewardList all",result);
	return result;
end
function QuestServerLogics.AddExpToFollowPet(nid,exp,only_calculate)
	local self = QuestServerLogics;
	if(not nid or not exp or exp <= 0)then
		return
	end
	local pet_config = CombatPetConfig.GetInstance_Server(true);
	if(pet_config)then
		local common_template = pet_config:GetCommonTemplate();
		if(common_template)then
			local odds = common_template.exp_percent or 5;--默认5%
			local add_exp_max_default = common_template.get_max_exp or 2048;--默认获取经验最大值
			exp = tonumber(exp) or 0;
			exp = math.ceil(exp * odds / 100);

			exp = math.min(exp,add_exp_max_default);
			exp = math.max(exp,0);
			if(exp == 0)then
				return
			end
			if(not only_calculate)then
				local exp_gsid = 966;
				local loots = {};
				loots[exp_gsid] = exp;
				local pres = {};
				--扣除物品
				LOG.std(nil, "info","QuestServerLogics.AddExpToFollowPet 1", {nid = nid, loots = loots, pres = pres, });
				PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
					LOG.std(nil, "info","QuestServerLogics.AddExpToFollowPet 2", msg);
					local msg = {
						add_exp = exp,
					}
					self.CallClient(nid,"MyCompany.Aries.CombatPet.CombatFollowPetPane.UpdateExp",msg)
				end, pres)
			end
			return exp;
		end
	end
end
function QuestServerLogics.AddExpToFollowPet_backup(nid,guid,exp)
	if(not nid or not guid or not exp or exp <= 0)then
		return
	end
	local function add_exp(item,exp)
		if(item and item.guid > 0 and item.OnCombatComplete_server)then
			return item:OnCombatComplete_server(exp);
		end
	end
	local item = PowerItemManager.GetItemByGUID(nid, guid);
	if(item)then
		local result = add_exp(item,exp);
		return result; 
	else
		PowerItemManager.SyncUserItems(nid, {0,1,}, function(msg) 
			local item = PowerItemManager.GetItemByGUID(nid, guid);
			if(item) then
				add_exp(item,exp);
			end
		end, function() end);
	end
	
end
function QuestServerLogics.TryFinished_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.TryFinished_Handler",msg);
	if(not nid or not msg)then return end
	local provider = self.CreateOrGetProvider(nid)
	local questid = msg.id;
	local templates = provider:GetTemplateQuests();
	local template = templates[questid];
	if(not template)then
		self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",{issuccess = false,id = questid,state="finished",tag= "quest template can't find"});
		return
	end
	local q_item = provider:GetQuest(questid);
	--检测是否有动态属性:人物自身的属性
	local result,has_dynamic_value,bag_list = provider:GetDynamicAttrValue(template.CustomGoal);
	LOG.std(nil, "info","QuestServerLogics GetDynamicAttrValue",{ has_dynamic_value = has_dynamic_value, bag_list = bag_list, });
	if(has_dynamic_value and q_item) then
		local Cur_CustomGoal = q_item.Cur_CustomGoal;
		if(Cur_CustomGoal)then
			local function GetResist(player,school)
				local v = player:GetResist(school) or 0;
				return -v;
			end
			local len = #bag_list;
			local function check_stats()
				Arena.OnReponse_CheckStats(nid, function(player)
					local role_str = PowerItemManager.GetUserSchool(nid)
					local k,v;
					for k,v in ipairs(Cur_CustomGoal) do
						local id = v.id;
						--超魔生成率
						if(id == 79032)then
							local value = player:GetPowerPipChance() or 0;
							provider:SetCombatValue(id,value);
						--本系攻击力
						elseif(id == 79033)then
							local value = player:GetDamageBoost(role_str) or 0;
							provider:SetCombatValue(id,value);
						--最大防御力
						elseif(id == 79034)then
							local value = 0;
							value = math.max(value,GetResist(player,"fire"));
							value = math.max(value,GetResist(player,"ice"));
							value = math.max(value,GetResist(player,"storm"));
							value = math.max(value,GetResist(player,"myth"));
							value = math.max(value,GetResist(player,"life"));
							value = math.max(value,GetResist(player,"death"));
							value = math.max(value,GetResist(player,"balance"));
							provider:SetCombatValue(id,value);
						end
					end
					LOG.std(nil, "info","QuestServerLogics OnReponse_CheckStats",{nid = provider.nid,dynamic_attr_cache_map = provider.dynamic_attr_cache_map,});
					self.Internal_TryFinished_Handler(nid,msg);
				end)
			end
			if(len > 0)then
				PowerItemManager.SyncUserItems(nid, bag_list, function(msg) 
					check_stats();
				end, function() end);
			else
				check_stats();
			end
			
		end
	else
		self.Internal_TryFinished_Handler(nid,msg);
	end
end
function QuestServerLogics.Internal_TryFinished_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.Internal_TryFinished_Handler",msg);
	if(not nid or not msg)then return end
	local provider = self.CreateOrGetProvider(nid)
	local questid = msg.id;
	local pet_guid = msg.pet_guid;
	local pet_gsid = msg.pet_gsid;
	local reward_index_list = msg.reward_index_list;
	local userinfo = provider:GetUserInfo();
	local quest_msg = {
		nid = nid,
		id = questid,
		reward_index_list = reward_index_list,
	}
	local q_item = provider:GetQuest(questid);
	local bCanFinished = provider:CanFinished(questid);
	local bHasFinished = provider:HasFinished(questid);
	--如果已经完成 直接返回
	if(bHasFinished)then
		self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",{issuccess = true,id = questid,state="has_finished",userinfo = userinfo,q_item = q_item,});
		return
	end
	if(not bCanFinished)then
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",{issuccess = false,id = questid,state="finished",userinfo = userinfo,tag= "TryFinished_Tag_1",q_item = q_item});
		return
	end
	--防沉迷 奖励惩罚 0-1
	local loot_scale = msg.loot_scale or 1;
	loot_scale = math.max(loot_scale,0);
	loot_scale = math.min(loot_scale,1);
	if(self.load_version == "kids")then
		--忽略经验惩罚
		loot_scale = 1;
	end
	local reward_list = self.GetRewardList(nid,questid,reward_index_list)
	local need_destroy_items = QuestHelp.BuildReallyItemsFromCustomGoal(provider,questid) or {};
	if(reward_list) then
		--100  E币 奇豆  
		--113  战斗经验值 
		local gained_exp = 0;
		local gained_joybean = 0;
		local loots = {};
		-- parse reward list
		local _, pair;
		for _, pair in ipairs(reward_list) do
			if(pair.id == 100) then
				gained_joybean = pair.value * loot_scale;
			elseif(pair.id == 113) then
				gained_exp = pair.value * loot_scale;
			elseif(pair.id >= 1001) then
				local value = pair.value;
				--最低1个
				if(value > 1 and loot_scale < 1)then
					value = pair.value * loot_scale;
					value = math.ceil(value);
					value = math.max(value,1);
				end
				loots[pair.id] = value;
			elseif(pair.id == 977 or pair.id == 998 or pair.id == 984) then
				loots[pair.id] = pair.value* loot_scale;
			else
				LOG.std(nil, "error","QuestServerLogics", "reward list got invalid type:"..tostring(pair.id));
			end
		end
		--需要销毁的物品
		local _,node;
		for _,node in ipairs(need_destroy_items) do
			if(loots[node.gsid])then
				loots[node.gsid] = loots[node.gsid] - node.value;
			else
				loots[node.gsid] = -node.value;
			end
		end
		--宠物训练点
		local pet_exp = QuestServerLogics.AddExpToFollowPet(nid,gained_exp,true);
		if(pet_exp and pet_exp > 0)then
			local cnt = loots[966] or 0;
			loots[966] = cnt + pet_exp;
		end
		local len = #reward_list;
		local len_need_destroy_items = #need_destroy_items;
		if(len > 0 or len_need_destroy_items > 0)then
			-- PowerItemManager.AddExpJoybeanLoots will automatically invoked as isgreedy mode
			LOG.std(nil, "info","QuestServerLogics before AddExpJoybeanLoots",{nid = nid, reward_list = reward_list, gained_exp = gained_exp, gained_joybean,loots = loots,});
			PowerItemManager.AddExpJoybeanLoots(nid, gained_exp, gained_joybean, loots, function(msg) 
				LOG.std(nil, "info","QuestServerLogics after AddExpJoybeanLoots",msg);
				if(msg)then
					if(msg.issuccess)then
						provider:TryFinished(quest_msg,function(msg)
								msg.pet_gsid = pet_gsid;
								msg.pet_guid = pet_guid;
								msg.pet_exp = pet_exp;--宠物获得的经验
								msg.userinfo = userinfo;
								msg.tag = "TryFinished_Tag_2";
								msg.reward_list = reward_list;
								self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",msg)
						end);
					else
						msg.userinfo = userinfo;
						msg.tag = "TryFinished_Tag_3";
						self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",msg)
					end
				else
					local msg = {
						userinfo = userinfo,
						item_info = "item msg is nil",
						tag = "TryFinished_Tag_4",
					}
					self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",msg)
				end
			end,nil,"AddExpJoybeanLoots_Quest");
		else
			provider:TryFinished(quest_msg,function(msg)
				if(msg)then
					msg.tag = "TryFinished_Tag_5";
					msg.userinfo = userinfo;
					msg.reward_list = reward_list;
					self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",msg)
				end
			end);
		end
	else
		provider:TryFinished(quest_msg,function(msg)
			if(msg)then
				msg.userinfo = userinfo;
				msg.tag = "TryFinished_Tag_6";
				msg.reward_list = reward_list;
				self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryFinished_Handler",msg)
			end
		end);
	end
end

function QuestServerLogics.TryDrop_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.TryDrop_Handler",msg);
	if(not nid or not msg)then return end
	local provider = self.CreateOrGetProvider(nid)
	local quest_id = tonumber(msg.id);
	if(provider:HasFinished(quest_id))then
		return
	end
	local userinfo = provider:GetUserInfo();
	msg = {
		nid = nid,
		id = msg.id,
	}
	--直接删除任务
	provider:TryDelete(msg,function(msg)
		if(msg)then
			msg.userinfo = userinfo;
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryDelete_Handler",msg)
		end
	end);
	--local load_version = self.load_version;
	--if(load_version == "teen")then
		----青年版直接删除任务
		--provider:TryDelete(msg,function(msg)
			--if(msg)then
				--msg.userinfo = userinfo;
				--self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryDelete_Handler",msg)
			--end
		--end);
	--else
		--provider:TryDrop(msg,function(msg)
			--if(msg)then
				--msg.userinfo = userinfo;
				--self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryDrop_Handler",msg)
			--end
		--end);
	--end
end
function QuestServerLogics.TryReAccept_Handler(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.TryReAccept_Handler",msg);
	if(not nid or not msg)then return end
	local provider = self.CreateOrGetProvider(nid)
	local userinfo = provider:GetUserInfo();
	msg = {
		nid = nid,
		id = msg.id,
	}
	provider:TryReAccept(msg,function(msg)
		if(msg)then
			msg.userinfo = userinfo;
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryReAccept_Handler",msg)
		end
	end);

end
function QuestServerLogics.CallClient(nid,func,msg)
	local self = QuestServerLogics;
	nid = tostring(nid);
	if(not nid or not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std(nil, "error","QuestServerLogics", "the type of msg must be table!");
		return
	end

	local server = self.server;
	if(server)then
		msg = commonlib.serialize_compact(msg);
		local body = format("[Aries][Quest][%s][%s]",func,msg);
		if(not nid)then
			--server:AddRealtimeMessage(body);
		else
			LOG.std(nil, "info","QuestServerLogics.CallClient", body);
			server:SendRealtimeMessage(nid, body);
		end
	end
end

function QuestServerLogics.LoadQuestWeekRepeat()
	local self = QuestServerLogics;
	local filepath;
	if(self.load_version == "teen")then
		filepath = "config/Aries/Quests_Teen/week_repeat.xml";
	else
		filepath = "config/Aries/Quests/week_repeat.xml";
	end
	LOG.std(nil, "debug","QuestServerLogics", "LoadQuestWeekRepeat:%s", filepath);
	QuestWeekRepeat.Load(filepath)
end
function QuestServerLogics.rebuild_weekly()
	local self = QuestServerLogics;
	local filepath;
	
	if(self.load_version == "teen")then
		filepath = "config/Aries/Quests_Teen/weekly_choice.xml";
	else
		filepath = "config/Aries/Quests/weekly_choice.xml";
	end

	LOG.std(nil, "debug","QuestServerLogics", "weekly quest rebuild:%s", filepath);

	local week,date = QuestTimeStamp.GetServerWeek();
	local map_type_0;
	local map_type_1;
	map_type_0 = QuestChoice.GetValidQuestIDs(filepath,0,week)
	if(week == 6 or week == 7)then
		map_type_1 = QuestChoice.GetValidQuestIDs(filepath,1,week)
	end
	local map = {
		[0] = map_type_0, 
		[1] = map_type_1,
		date = date,
	};
	return map;
end	

--获取今天的日常任务
--[[
	return
	local weekly_valid_maps = {
		[0] = {},--每日任务 nil 代表不限制
		[1] = {},--每周任务 nil 代表不限制
		date = date,
	}
--]]
function QuestServerLogics.LoadWeeklyQuest()
	local self = QuestServerLogics;
	
	local date = QuestTimeStamp.GetServerDate();
	if(not self.weekly_valid_maps or self.weekly_valid_maps.date ~= date)then
		self.weekly_valid_maps = QuestServerLogics.rebuild_weekly();
	end
	return self.weekly_valid_maps;
end
function QuestServerLogics.DoAcceptQuest_GM(nid, questid)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.DoAcceptQuest_GM",{nid = nid, questid = questid,});
	if(not nid or not questid)then return end
	local provider = self.CreateOrGetProvider(nid)
	local userinfo = provider:GetUserInfo();
	local msg = {
		nid = nid,
		id = questid,
		is_power_user = true,
	}
	provider:TryAccept(msg,function(msg)
		if(msg)then
			msg.userinfo = userinfo;
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryAccept_Handler",msg)
		end
	end);
end
function QuestServerLogics.DoDeleteQuest_GM(nid, questid)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	LOG.std(nil, "info","QuestServerLogics.DoDeleteQuest_GM",{nid = nid, questid = questid,});
	if(not nid or not questid)then return end
	local provider = self.CreateOrGetProvider(nid)
	local userinfo = provider:GetUserInfo();
	local msg = {
		nid = nid,
		id = questid,
	}
	--直接删除任务
	provider:TryDelete(msg,function(msg)
		if(msg)then
			msg.userinfo = userinfo;
			self.CallClient(nid,"MyCompany.Aries.Quest.QuestClientLogics.TryDelete_Handler",msg)
		end
	end);
end
-- @param nid:用户id
-- @param goalid:任务目标的id
-- @param value:完成目标的数量 默认1
-- @param mode:副本难度 默认1
function QuestServerLogics.DoAddGoalValue_GM(nid,goalid,value,mode)
	local self = QuestServerLogics;
	goalid = tonumber(goalid);
	if(not nid or not goalid)then return end
	value = value or 1;
	mode = mode or 1;
	local values = {
		{id = goalid, value = value},
	}
	local provider = self.CreateOrGetProvider(nid)
	local added_quest_map = provider:DoAddValue(values,mode);
	local msg = {
		nid = nid,
		added_quest_map = added_quest_map,
	}
	LOG.std(nil, "info","QuestServerLogics.DoAddGoalValue_GM",msg);
	self.DoAddValue(nid,msg);
end
----------------------
--宠物喂养
----------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
function QuestServerLogics.CheckDate_FollowPet(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	--宠物id
	local pet_gsid = msg.pet_gsid;
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	local provider = CombatPetHelper.GetServerProvider(QuestServerLogics.IsTeenVersion());
	if(provider and hasItem)then
		--是否是战宠
		local is_combat_pet = provider:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData)then
			local data = item:GetServerData();
			if(type(data) ~= "table")then
				return
			end
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local cur_feed_date = data.cur_feed_date;
			--如果不是今天 重新生成数据
			if(cur_feed_date and cur_feed_date ~= serverdate)then
				data.cur_feed_num = 0;
				data.cur_feed_date = serverdate;
				data.cur_fruit_gsid = item:GetRandomFruitGsid();
				--保存数据
				item:SaveServerData(data,function(msg)
				QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatPetFoodsPage.CheckDate_FollowPet_Handler",{pet_gsid = pet_gsid});

				end);
			end
		end
	end
end
function QuestServerLogics.DoChangeName_FollowPet(nid,msg)
	local self = QuestServerLogics;
	if(self.load_version == "kids")then
		--do nothing
	else
		CombatPetServerHelper.DoChangeName_FollowPet_Teen(nid,msg);
	end
end
function QuestServerLogics.DoFeed_FollowPet(nid,msg)
	local self = QuestServerLogics;
	if(self.load_version == "kids")then
		CombatPetServerHelper.DoFeed_FollowPet(nid,msg);
	else
		CombatPetServerHelper.DoFeed_FollowPet_Teen(nid,msg);
	end
end
function QuestServerLogics.AttachGem(nid,msg)
	local self = QuestServerLogics;
	if(self.load_version == "kids")then
		CombatPetServerHelper.AttachGem(nid,msg);
	end
end
function QuestServerLogics.UnAttachGem(nid,msg)
	local self = QuestServerLogics;
	if(self.load_version == "kids")then
		CombatPetServerHelper.UnAttachGem(nid,msg);
	end
end

-- added by LiXizhi, level a pet to full exp for testing purposes via GM command. 
function QuestServerLogics.DoFeed_FollowPet_GM(nid, pet_gsid, exp_add)
	CombatPetServerHelper.DoFeed_FollowPet_GM(nid, pet_gsid, exp_add);
end

-------------------------------
--经验强化药丸 假日努力药丸
-------------------------------
function QuestServerLogics.DoUseItem_AddExpPercent(nid,msg)
	local self = QuestServerLogics;
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","QuestServerLogics.DoUseItem_AddExpPercent 1", msg);
	--使用的物品
	local item_gsid = msg.item_gsid;
	--涨经验的物品
	local exp_percent_gsid;
	
	NPL.load("(gl)script/ide/TooltipHelper.lua");
	local HolidayHelper = commonlib.gettable("CommonCtrl.HolidayHelper");
	if(item_gsid == 12002 and not HolidayHelper.IsHoliday(nil,QuestServerLogics.IsTeenVersion()))then
		--只能在节假日使用 假日努力药丸
		LOG.std(nil, "info","QuestServerLogics.DoUseItem_AddExpPercent must in holiday", msg);
		return
	end
	--获取对应的gsid
	local function get_gsid(item_gsid)
		if(not item_gsid)then return end
		local t = {
			[12001] = {
				12001,--经验强化药丸
				40001,--经验提成的次数
			},
			[12002] = {
				12002,--假日努力药丸
				40003,--经验提成的次数
			},
			[12046] = {
				12046,--10倍经验药丸
				40006,--经验提成的次数
			},
		}
		local p = t[item_gsid];
		if(p)then
			return p[1],p[2];
		end
	end
	item_gsid,exp_percent_gsid= get_gsid(item_gsid);
	if(not item_gsid or not exp_percent_gsid)then return end

	local hasItem,item_guid = PowerItemManager.IfOwnGSItem(nid,item_gsid);
	LOG.std(nil, "info","QuestServerLogics.DoUseItem_AddExpPercent 2", {hasItem = hasItem, item_guid = item_guid});
	if(hasItem)then
		local __,__,__,copies = PowerItemManager.IfOwnGSItem(nid,exp_percent_gsid);
		LOG.std(nil, "info","QuestServerLogics.DoUseItem_AddExpPercent copies", {copies = copies, });
		copies = copies or 0;
		copies = math.max(copies,0);
		copies = math.min(copies,20);
		copies = 20 - copies;
		local loots = {};
		--消耗一个物品
		loots[item_gsid] = -1;
		--最多增长的物品
		loots[exp_percent_gsid] = copies;
		local pres = {};
		--前提条件
		pres[item_gsid] = 1;

		--扣除物品
		LOG.std(nil, "info","QuestServerLogics.DoUseItem_AddExpPercent AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, });
		PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","QuestServerLogics.DoUseItem_AddExpPercent AddExpJoybeanLoots 2", msg);
			QuestServerLogics.CallClient(nid,"MyCompany.Aries.Desktop.EXPBuffArea.UpdateBuff",{})
		end,pres);
	end
end
