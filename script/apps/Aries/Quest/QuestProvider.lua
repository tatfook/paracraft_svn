--[[
Title: 
Author(s): Leio
Date: 2010/8/18
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");

local msg = {
	nid = nid,
	id = id,--任务id
}
QuestProvider:HasAccept(id);
QuestProvider:HasFinished(id);
QuestProvider:CanAccept(id);
QuestProvider:CanFinished(id);
QuestProvider:CanDelete(id);
QuestProvider:TryAccept(msg);
QuestProvider:TryFinished(msg);
QuestProvider:TryDelete(msg);

local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local hasItem,guid = PowerItemManager.IfOwnGSItem(171379414,60004,999);
commonlib.echo(hasItem);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/ide/GraphHelp.lua");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
-- create class
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");
QuestProvider.remote = false;
QuestProvider.template_quests = nil;
QuestProvider.quests_list = nil;
QuestProvider.map_quests = nil;
QuestProvider.template_graph = nil;
QuestProvider.template_graph_nodes_map = nil;
QuestProvider.local_is_init = false;
QuestProvider.nid = nil;
QuestProvider.load_version = nil;
--人物属性缓存 gameserver获取人物属性需要异步调用，调用成功后的结果存储在这里
QuestProvider.dynamic_attr_cache_map = {};
QuestProvider.dynamic_attr_ids = {
		[79030] = "魔法星等级",
		[79031] = "战斗等级",
		[79032] = "超魔生成率",
		[79033] = "本系攻击力",
		[79034] = "最大防御力",
		[79035] = "充值次数",
	}
--当天有效的日常任务id nil代表没有限制，
--[[ 
	local weekly_valid_maps = {
		[0] = {},--每日任务 nil 代表不限制
		[1] = {},--每周任务 nil 代表不限制
		date = date,
	}
}
--]]
QuestProvider.weekly_valid_maps = nil;
QuestProvider.is_dirty = false;
function QuestProvider:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	return o
end
--初始化
function QuestProvider:OnInit()
	
	if(self.load_version == "teen") then
		QuestProvider.dynamic_attr_ids[79032] = "双倍魔力生成率";
	end

	local path;
	if(not self.load_version)then
		LOG.std(nil, "error","unkown version in QuestProvider");
		return;
	end
	if(self.load_version == "kids") then
		path = "config/Aries/Quests/quest_list.xml";
	elseif(self.load_version == "teen")then
		path = "config/Aries/Quests_Teen/quest_list.xml";
	end
	self.is_dirty = false;
	local data,map = QuestHelp.LoadAllQuests(path);
	self.template_quests = map;
	self:Reset();
	--必须先初始化 self.quests_list 和 self.map_quests
	self:LoadAllServerData();
	
	self.template_graph,self.template_graph_nodes_map = QuestHelp.CreateGraph(data,true);
end
--已经接受的任务里面是否包含目标id
function QuestProvider:IsIncludeGoal_AllAccepted(goalid)
	if(not goalid)then
		return
	end
	local k,q_item;
	for k,q_item in ipairs(self.quests_list) do
		local questid = q_item.id;
		if(self:HasAccept(questid))then
			if(self:IsIncludeGoal(questid,goalid))then
				return true;
			end
		end
	end	
end
function QuestProvider:IsIncludeGoal(questid,goalid)
	if(not questid or not goalid)then
		return
	end
	local q_item = self:GetQuest(questid);
	if(q_item)then
		local function check_1(key)
			if(key and q_item[key])then
				local result = q_item[key];
				local k,v;
				for k,v in ipairs(result) do
					if(v.id == goalid)then
						return true;
					end
				end
			end
		end
		local function check_2(key)
			if(key and q_item[key])then
				local result = q_item[key];
				local k,v;
				for k,v in ipairs(result) do
					if(v.producer_id == goalid)then
						return true;
					end
				end
			end
		end
		if(check_2("Cur_GoalItem") 
			or check_1("Cur_Goal") or check_1("Cur_ClientGoalItem") 
			or check_1("Cur_ClientExchangeItem") or check_1("Cur_FlashGame") 
			or check_1("Cur_ClientDialogNPC") or check_1("Cur_CustomGoal"))then
			return true;
		end
	end
end
--测试杀怪增加数据
--[[
	local msg = {
		{id = 10000,--怪物id value = 10,--消灭怪物的数量},
	}
--]]
--@param mode:0(easy) 1(normal) 2(hard)
function QuestProvider:DoAddValue(msg,mode)
	if(not msg)then return end
	local q_item;
	local added_quest_map = {};
	local templates = self:GetTemplateQuests();
	for q_item in self:NextQuest() do
		local id = q_item.id;
		local template = templates[id];
		if(template and self:HasAccept(id) and not self:CanFinished(id))then
			local Cur_Goal = q_item.Cur_Goal;
			local Cur_GoalItem = q_item.Cur_GoalItem;
			--儿童版 不检查这个
			local Cur_ClientGoalItem = q_item.Cur_ClientGoalItem;
			local Cur_ClientExchangeItem = q_item.Cur_ClientExchangeItem;
			local Cur_FlashGame = q_item.Cur_FlashGame;
			local Cur_ClientDialogNPC = q_item.Cur_ClientDialogNPC;
			local Cur_CustomGoal = q_item.Cur_CustomGoal;
			local increment = msg;
			local bAdd_1;
			local bAdd_2;
			local bAdd_3;
			local bAdd_4;
			local bAdd_5;
			local bAdd_6;
			local bAdd_7;
			if(Cur_Goal)then
				local Goal = template.Goal;
				local goal_mode;
				local condition;
				if(Goal)then
					condition = Goal.condition;
					goal_mode = Goal.mode;
				end
				local value;
				value,bAdd_1 = QuestHelp.Table_Add(Cur_Goal,increment,condition,id,goal_mode,mode);
				q_item.Cur_Goal = value;
			end
			if(Cur_GoalItem)then
				local GoalItem = template.GoalItem;
				local goal_mode;
				local condition;
				if(GoalItem)then
					condition = GoalItem.condition;
					goal_mode = GoalItem.mode;
				end
				local value_item,value_item_increment;
				value_item,value_item_increment,bAdd_2 = QuestHelp.Table_Add_Item(Cur_GoalItem,increment,condition,id,goal_mode,mode);
				q_item.Cur_GoalItem = value_item;
			end
			if(self.load_version == "teen")then
				if(Cur_ClientGoalItem)then
					local ClientGoalItem = template.ClientGoalItem;
					local condition;
					if(ClientGoalItem)then
						condition = ClientGoalItem.condition;
					end
					local value;
					value,bAdd_3 = QuestHelp.Table_Add(Cur_ClientGoalItem,increment,condition,id);
					q_item.Cur_ClientGoalItem = value;
				end
			end
			if(Cur_ClientExchangeItem)then
				local ClientExchangeItem = template.ClientExchangeItem;
				local condition;
				if(ClientExchangeItem)then
					condition = ClientExchangeItem.condition;
				end
				local value;
				value,bAdd_4 = QuestHelp.Table_Add(Cur_ClientExchangeItem,increment,condition,id);
				q_item.Cur_ClientExchangeItem = value;
			end
			if(Cur_FlashGame)then
				local FlashGame = template.FlashGame;
				local condition;
				if(FlashGame)then
					condition = FlashGame.condition;
				end
				local value;
				value,bAdd_5 = QuestHelp.Table_Add(Cur_FlashGame,increment,condition,id);
				q_item.Cur_FlashGame = value;
			end
			if(Cur_ClientDialogNPC)then
				local ClientDialogNPC = template.ClientDialogNPC;
				local condition;
				if(ClientDialogNPC)then
					condition = ClientDialogNPC.condition;
				end
				local value;
				value,bAdd_6 = QuestHelp.Table_Add(Cur_ClientDialogNPC,increment,condition,id);
				q_item.Cur_ClientDialogNPC = value;
			end
			if(Cur_CustomGoal)then
				local CustomGoal = template.CustomGoal;
				local condition;
				if(CustomGoal)then
					condition = CustomGoal.condition;
				end
				local value;
				value,bAdd_7 = QuestHelp.Table_Add(Cur_CustomGoal,increment,condition,id);
				q_item.Cur_CustomGoal = value;

			end
			--commonlib.echo("=============badd");
			--commonlib.echo(increment);
			--commonlib.echo(bAdd_1);
			--commonlib.echo(bAdd_2);
			--commonlib.echo(bAdd_3);
			--commonlib.echo(bAdd_4);
			--commonlib.echo(bAdd_5);
			--commonlib.echo(bAdd_6);
			if(bAdd_1 or bAdd_2 or bAdd_3 or bAdd_4 or bAdd_5 or bAdd_6 or bAdd_7 )then
				self:SaveServerData(id,q_item);
				added_quest_map[id] = commonlib.deepcopy(q_item);
			end
		end
	end
	return added_quest_map;
end
--同步client 收集物品的数据
function QuestProvider:DoSync_Client_ClientGoalItem()
	if(self.remote)then return end
	NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
	local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
	local q_item;
	local sync_quest_item_map = {};
	local bHas = false;
	local templates = self:GetTemplateQuests();
	for q_item in self:NextQuest() do
		local id = q_item.id;
		local template = templates[id];
		if(template and self:HasAccept(id))then
			local Cur_ClientGoalItem = q_item.Cur_ClientGoalItem;
			if(Cur_ClientGoalItem)then
				
				local k,v;
				for k,v in ipairs(Cur_ClientGoalItem) do
					local gsid = v.id
					--NOTE:2011/01/15 从任务目标判断 任务目标最大值
					local max_value = QuestHelp.GetGoalValue(id,gsid);
					if(not max_value)then 
						max_value = v.max_value;
					else
						v.max_value = max_value;
					end
					local __,__,__,value = ItemManager.IfOwnGSItem(gsid);
					value = value or 0;
					value = math.min(value,max_value);
					v.value = value;
				end
				sync_quest_item_map[id] = q_item;
				bHas = true;
			end
		end
	end
	return sync_quest_item_map,bHas;
end
--同步server 收集物品的数据
function QuestProvider:DoSync_Server_ClientGoalItem(sync_quest_item_map)
	if(not self.remote)then return end
	if(not sync_quest_item_map)then return end
	local k,q_item;
	local templates = self:GetTemplateQuests();
	for k,q_item in pairs(sync_quest_item_map) do
		local id = q_item.id;
		local template = templates[id];
		if(template and self:HasAccept(id))then
			self:SaveServerData(id,q_item);
		end
	end
	self:ResetQuestByMap(sync_quest_item_map)
end
--任务目标是否符合
function QuestProvider:Goal_Equals(player_value,template_value)
	local isNull = self:ReturnTrueIfNull(template_value);
	if(isNull)then
		return true;
	end
	local b = QuestHelp.Table_Equals(player_value,template_value);
	return b;
end
function QuestProvider:SetLocalCombatLevel(value)
	if(self.remote)then return end
	value = tonumber(value);
	self.users_backup_combat_level = value;
end
function QuestProvider:GetLocalCombatLevel()
	if(self.remote)then return end
	return self.users_backup_combat_level;
end
--获取用户 前置条件的所有信息
function QuestProvider:GetUserInfo()
	local users = self.users;
	if(not users) then
		users = {
			[0] = { label = "奇豆", value = 0,},
			[214] = { label = "战斗等级", value = 0,},
			[79030] = { label = "魔法星等级", value = 0,},
			[79035] = { label = "充值次数", value = 0,},
		};
		self.users = users;
	end
	local nid = self.nid;
	if(nid)then
		local user;
		local dragon;
		if(self.remote)then
			local userinfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid)
			if(userinfo)then
				user = 	userinfo.user;
				dragon = userinfo.dragon;
			end
		else
			dragon = MyCompany.Aries.Pet.GetBean(nid);
			user = ProfileManager.GetUserInfoInMemory(self.nid);
		end
		if(dragon)then
			users[214].value = dragon.combatlel or 0;
			--魔法星等级
			users[79030].value = dragon.mlel or 0;
			if(not self.remote)then
				--本地战斗等级
				local level = self:GetLocalCombatLevel();
				if(level)then
					users[214].value = level;
				end
			end
		end
		
		if(user) then
			--奇豆
			users[0].value = user.emoney or 0;
			--充值次数
			users[79035].value = user.accummodou or 0;
		end
	end
	return users;
end
--根据前置条件，返回用户当前信息table
--前置条件接受战斗等级和真实物品数量
function QuestProvider:GetUserRequestAttr(template_value)
	local isNull = self:ReturnTrueIfNull(template_value);
	if(isNull)then
		return;
	end
	local target = template_value;
	local user_items = self:GetUserInfo();
	if(target and user_items)then
		local source = {};
		local k,v;
		source.condition = target.condition;
		for k,v in ipairs(target) do
			local id = v.id;
			local value = v.value;
			if(id and value)then
				
				local source_value = 0;
				if(self:IsDynamicItemGsid(id))then
					--如果是真实物品
					source_value = self:GetUserItemValue(id);

				elseif(self.dynamic_attr_ids[id])then
					source_value = self:GetCombatValue(id);
				else
					--如果是用户信息
					local temp = user_items[id];
					if(temp)then
						source_value = temp.value or 0;
					end
				end
				local item = {
					id = id,
					value = source_value;
				}
				table.insert(source,item);
			end
		end	
		return source;
	end
end
--[[
NOTE:
前置条件接受战斗等级和真实物品数量 包含最低值 和 最大值
<item id="30000" value="1" topvalue=""/>topvalue 默认为最低等级
<item id="gsid" value="1" topvalue=""/>topvalue 默认为最低等级
 --]]
function QuestProvider:RequestAttr_Equals(template_value,equation)
	local isNull = self:ReturnTrueIfNull(template_value);
	if(isNull)then
		return true;
	end
	local player_value = self:GetUserRequestAttr(template_value);
	local k,v_tempalte;
	for k,v_tempalte in ipairs(template_value) do
		local kk,v_user;
		for kk,v_user in ipairs(player_value) do
			if(v_tempalte.id == v_user.id)then
				local min_level = v_tempalte.value or 0;
				local max_level = v_tempalte.topvalue;
				local level = v_user.value or 0;
				if(max_level)then
					if(level < min_level or  level > max_level)then
						return false;
					end
				else
					if(level < min_level)then
						return false;
					end
				end
			end
		end
	end
	return true;
end
function QuestProvider:GetUserRequestQuest(template_value)
	local isNull = self:ReturnTrueIfNull(template_value);
	if(isNull)then
		return;
	end
	local target = template_value;
	if(target)then
		local condition = target.condition;
		--至少有一个前置任务
		local temp = target[1];
		if(temp)then
			local state = temp.value; -- 1:finished 3:actived
			local source_actived = { condition = condition, };
			local source_finished = { condition = condition, };
			local k,v;
			for k,v in ipairs(target) do
				local t_id = v.id;
				local q_item = self:GetQuest(t_id);
				if(q_item)then
					if(self:IsActivedState(q_item))then
						local item = {
							id = t_id,
							value = 3,
						}
						table.insert(source_actived,item);
					elseif(self:IsFinishedState(q_item))then
						local item = {
							id = t_id,
							value = 1,
						}
						table.insert(source_finished,item);
					end
				end
			end
			return source_actived,source_finished;
		end
	end
end
function QuestProvider:ReturnTrueIfNull(v)
	if(not v or v == "")then
		return true;
	end
	if(type(v) ~= "table")then
		return true
	end
	local len = #v;
	if(len == 0)then
		return true;
	end
end
-- 986_CombatSchool_Fire 1
-- 987_CombatSchool_Ice 3
-- 988_CombatSchool_Storm 2
-- 989_CombatSchool_Myth
-- 990_CombatSchool_Life 4
-- 991_CombatSchool_Death 5
-- 992_CombatSchool_Balance
function QuestProvider:Role_Equals(role)
	role = tonumber(role);
	if(not role or role == 0)then 
		return true;
	end
	local role_str;
	local static_role;
	if(self.remote)then
		role_str = PowerItemManager.GetUserSchool(self.nid)
	else
		role_str = Combat.GetSchool();
	end
	if(role_str == "fire")then
		static_role = 1;
	elseif(role_str == "storm")then
		static_role = 2;
	elseif(role_str == "ice")then
		static_role = 3;
	elseif(role_str == "life")then
		static_role = 4;
	elseif(role_str == "death")then
		static_role = 5;
	end
	if(static_role and role == static_role)then
		return true;
	end
end
--前置任务是否符合
function QuestProvider:RequestQuest_Equals(template_value)
	local isNull = self:ReturnTrueIfNull(template_value);
	if(isNull)then
		return true;
	end
	local target = template_value;
	if(target)then
		local condition = target.condition;
		--至少有一个前置任务
		local temp = target[1];
		if(temp)then
			local state = temp.value; -- 1:finished 3:actived
			local list;
			local source_actived,source_finished = self:GetUserRequestQuest(template_value)
			if(state == 1)then
				local b = QuestHelp.Table_Equals(source_finished,target);
				return b;
			elseif(state == 3)then
				local b = QuestHelp.Table_Equals(source_actived,target);
				if(b)then
					return true;
				else
					if(source_finished)then
						local k,v;
						for k,v in ipairs(source_finished) do
							v.value = 3;--假设它是激活状态
						end
						b = QuestHelp.Table_Equals(source_finished,target);
						return b;
					end
				end
			end
			
		end
	end
end
--有效期是否符合
function QuestProvider:ValidDate_LessEquals(player_value,template_value)
	if(not template_value or template_value == "")then
		return true;
	end
end

-- if any quest in the given table is finished. 
-- @param id_table: array of ids
function QuestProvider:HasFinishedAny(id_table)
	local _, id 
	for _, id in ipairs(id_table) do
		if(self:HasFinished(id)) then
			return true;
		end
	end
end

function QuestProvider:HasFinished(id)
	if(not id)then return end
	local q_item = self:GetQuest(id);
	return self:IsFinishedState(q_item);
end

-- if any quest in the given table is accepted.
-- @param id_table: array of ids
function QuestProvider:HasAcceptAny(id_table)
	local _, id 
	for _, id in ipairs(id_table) do
		if(self:HasAccept(id)) then
			return true;
		end
	end
end

function QuestProvider:HasAccept(id)
	if(not id)then return end
	local q_item = self:GetQuest(id);
	return self:IsActivedState(q_item);
end
function QuestProvider:HasDropped(id)
	if(not id)then return end
	local q_item = self:GetQuest(id);
	return self:IsDropState(q_item);
end
--是否有效
function QuestProvider:IsValid(id)
	return true;
end
--是否可以接受
QuestProvider.debug_canaccept = {debug = "hasaccept or hasfinished or hasdropped"};
function QuestProvider:CanAccept(id)
	if(not id)then return end
	if(self:HasAccept(id) or self:HasFinished(id) or self:HasDropped(id))then
		return false,QuestProvider.debug_canaccept;
	end
	local templates = self:GetTemplateQuests();
	if(templates)then
		local template = templates[id];
		if(template)then
			--前置条件
			local b1 = self:RequestAttr_Equals(template.RequestAttr);
			--前置任务
			local b2 = self:RequestQuest_Equals(template.RequestQuest);

			local isMyRole = self:Role_Equals(template.Role);
			local right_time = true;
			--周长任务
			if(self:IsWeekRepeat(id))then
				local WeekRepeat = template.WeekRepeat;
				local date,time;
				if(self.remote)then
					date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
					time = ParaGlobal.GetTimeFormat("H:mm:ss");
				else
					date,time = QuestTimeStamp.GetClientDateTime()
				end
				if(not QuestWeekRepeat.CanAccept(WeekRepeat,date,time))then
					right_time = false;
				end
			elseif(template.TimeStamp)then
				local TimeStamp = template.TimeStamp;
				if(QuestTimeStamp.HasTemplate(TimeStamp))then
					right_time = false;
					local date,time;
					if(self.remote)then
						date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
						time = ParaGlobal.GetTimeFormat("H:mm:ss");
					else
						date,time = QuestTimeStamp.GetClientDateTime()
					end
					if(QuestTimeStamp.IsValidDate(TimeStamp,date,time))then
						right_time = true;
					end
					--如果有限制，但是不在map里面，则认为任务不能接受
					if(self.weekly_valid_maps)then
						
						local map_type_0 = self.weekly_valid_maps[0];
						if(TimeStamp and TimeStamp == 0 and map_type_0 and not map_type_0[id])then
							right_time = false;
						end
						local map_type_1 = self.weekly_valid_maps[1];
						if(TimeStamp and TimeStamp == 1 and map_type_1 and not map_type_1[id])then
							right_time = false;
						end
					end
				end
			end
			if(b1 and b2 and isMyRole and right_time)then
				return true;
			end
			local debug_msg = {id = id,nid = self.nid, b_attr = b1, b_quest = b2, isMyRole = isMyRole, right_time = right_time,template = template,};
			return false,debug_msg;
		end
	end
	return false,{debug = "template is nothing",id = id,};
end
function QuestProvider:SetCombatValue(id,value)
	if(not self.dynamic_attr_ids[id])then return end
	self.dynamic_attr_cache_map[id] = value or 0;
end

--获取用户物品数量 和所处的bag编号
function QuestProvider:GetUserItemValue(gsid)
	if(not gsid)then return 0 end
	if(self.remote)then
		local hasItem,guid,bag,copies = PowerItemManager.IfOwnGSItem(self.nid,gsid);
		copies = copies or 0;
		if(not hasItem)then
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem)then
				bag = gsItem.template.bagfamily;
			end
		end
		--正负相加
		if(gsid == 20046 or gsid == 20048)then
			local temp_gsid;
			if(gsid == 20046)then
				temp_gsid = 20047;
			else
				temp_gsid = 20049;
			end
			local __,__,__,_copies = PowerItemManager.IfOwnGSItem(self.nid,temp_gsid);
			_copies = _copies or 0;
			copies = copies - _copies;
		end
		return copies,bag;
	else
		local hasItem,guid,bag,copies = ItemManager.IfOwnGSItem(gsid);
		copies = copies or 0;
		if(not hasItem)then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem)then
				bag = gsItem.template.bagfamily;
			end
		end
		--正负相加
		if(gsid == 20046 or gsid == 20048)then
			local temp_gsid;
			if(gsid == 20046)then
				temp_gsid = 20047;
			else
				temp_gsid = 20049;
			end
			local __,__,__,_copies = ItemManager.IfOwnGSItem(temp_gsid);
			_copies = _copies or 0;
			copies = copies - _copies;
		end
		return copies,bag;
	end
end
--获取人物属性
function QuestProvider:GetCombatValue(id)
	if(not id)then return 0 end
	local userinfo = self:GetUserInfo() or {};
	if(self.remote)then
		if(id == 79031)then
			return userinfo[214].value;
		elseif(id == 79030 or id == 79035)then
			return userinfo[id].value;
		else
			return self.dynamic_attr_cache_map[id] or 0;
		end
	else
		if(id == 79031)then
			return userinfo[214].value;
		elseif(id == 79030 or id == 79035)then
			return userinfo[id].value;
		elseif(id == 79032)then
			local v = Combat.GetPowerPipChance(nil,nil);
			return v;
		elseif(id == 79033)then
			local role_str = Combat.GetSchool();
			local v = Combat.GetStats(role_str,if_else(self.load_version == "teen", "damage_absolute_base", "damage"));
			return v;
		elseif(id == 79034)then
			--最大防御力
			local v = 0;
			v = math.max(v,Combat.GetStats("fire",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			v = math.max(v,Combat.GetStats("ice",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			v = math.max(v,Combat.GetStats("storm",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			v = math.max(v,Combat.GetStats("myth",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			v = math.max(v,Combat.GetStats("life",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			v = math.max(v,Combat.GetStats("death",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			v = math.max(v,Combat.GetStats("balance",if_else(self.load_version == "teen", "resist_absolute_base", "resist")));
			return v;
		end
	end
	return 0;
end
--获取用户的动态属性
--包括用户物品的数量
--[[
	return {
		[79031] = 0,
		[79032] = 0,
		[79033] = 0,
		[79034] = 0,
		[item_gsid] = 0,
		[item_gsid] = 0,
		[item_gsid] = 0,
		[item_gsid] = 0,
	},has_dynamic_value
--]]
function QuestProvider:GetDynamicAttrValue(template_CustomGoal)
	if(not template_CustomGoal)then return end
	local has_dynamic_value = false;
	local result = {};
	local k,v;
	local bag_map = {};
	local bag_list = {};
	for k,v in ipairs(template_CustomGoal) do
		local id = v.id;
		local value = 0;
		if(self.dynamic_attr_ids[id])then
			value = self:GetCombatValue(id);
			if(id ~= 79031)then
				has_dynamic_value = true;
			end
			result[id] = value;
		elseif(self:IsDynamicItemGsid(id) or id == 0)then
			has_dynamic_value = true;
			local bag;
			value,bag = self:GetUserItemValue(id);
			if(bag)then
				if(not bag_map[bag])then
					bag_map[bag] = bag;
					table.insert(bag_list,bag);
				end
			end
			result[id] = value;
		end
	end
	return result,has_dynamic_value,bag_list;
end
--列表里面是否包含真实物品
function QuestProvider:HasGSItem_list(list)
	if(not list)then return end
	local k,v;
	local has_gsItem = false;
	local bag_list = {};
	local bag_map = {};
	for k,v in ipairs(list) do
		if(v.id and v.value and v.value > 0)then
			local has,bag = self:OnlyGSItemIsValid(v.id);
			if(has and bag)then
				if(not bag_map[bag])then
					bag_map[bag] = true;
					table.insert(bag_list,bag);
				end
			end
		end
	end
	local len = #bag_list;
	if(len > 0)then
		has_gsItem = true;
	end
	return has_gsItem,bag_list;
end
--是否是真实物品
function QuestProvider:OnlyGSItemIsValid(gsid)
	if(not gsid)then return end
	if(self.remote)then
		local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem)then
			local bag = gsItem.template.bagfamily;
			return true,bag,gsItem;
		end
	else
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem)then
			local bag = gsItem.template.bagfamily;
			return true,bag,gsItem;
		end
	end
end
--是否是物品属性的gsid
function QuestProvider:IsDynamicItemGsid(gsid)
	if(not gsid)then return end
	if(self:OnlyGSItemIsValid(gsid))then
		return true;
	end
	local list,map = QuestHelp.GetRewardList()
	if(map[gsid])then
		return true;
	end
end
--是否可以完成
function QuestProvider:CanFinished(id)
	if(not id)then return end
	if(not self:HasAccept(id) or self:HasFinished(id))then
		return false;
	end
	local templates = self:GetTemplateQuests();
	if(templates)then
		local template = templates[id];
		if(template)then
			local q_item = self:GetQuest(id);
			--判断是否是已经激活的任务
			if(self:IsActivedState(q_item))then
				--任务目标
				local b1 = self:Goal_Equals(q_item.Cur_Goal,template.Goal);
				local b2 = self:Goal_Equals(q_item.Cur_GoalItem,template.GoalItem);
				local b3 = self:Goal_Equals(q_item.Cur_ClientGoalItem,template.ClientGoalItem);
				local b4 = self:Goal_Equals(q_item.Cur_ClientExchangeItem,template.ClientExchangeItem);
				local b5 = self:Goal_Equals(q_item.Cur_FlashGame,template.FlashGame);
				local b6 = self:Goal_Equals(q_item.Cur_ClientDialogNPC,template.ClientDialogNPC);
				--获取动态属性
				local dynamic_value_map = self:GetDynamicAttrValue(template.CustomGoal);
				if(dynamic_value_map and q_item.Cur_CustomGoal)then
					local k,v;
					for k,v in ipairs(q_item.Cur_CustomGoal) do
						local id = v.id;
						if(dynamic_value_map[id])then
							v.value = dynamic_value_map[id];
						end
					end
				end
				local b7 = self:Goal_Equals(q_item.Cur_CustomGoal,template.CustomGoal);
				--有效期
				local now;--TODO:获取现在的时间
				local bTime = self:ValidDate_LessEquals(now,template.ValidDate);
				--LOG.std(nil, "info","QuestProvider:CanFinished",{
					--id = id,
					--nid = self.nid,
					--b1 = b1,
					--b2 = b2,
					--b3 = b3,
					--b4 = b4,
					--b5 = b5,
					--b6 = b6,
					--b7 = b7,
					--bTime = bTime,
					--});
				if(bTime and b1 and b2 and b3 and b4 and b5 and b6 and b7)then
					return true;
				end
			end
		end
	end
end
--是否可以删除
function QuestProvider:CanDelete(id)
	if(not id)then return end
	--只有激活的任务可以删除
	if(not self:HasAccept(id))then
		return false;
	end
	return true;
end
--[[
	msg = {
		nid = nid,
		id = id,
		is_power_user = is_power_user,
	}
--]]	
function QuestProvider:TryAccept(msg,callbackFunc)
	if(not self.remote)then
		return
	end
	if(not msg)then return end
	local id = msg.id;
	id = tonumber(id);
	local bCanAccept,error_msg = self:CanAccept(id);
	local bHasAccept = self:HasAccept(id);
	local item = self:GetQuest(id);
	local server_info = {id = id,nid = self.nid, bCanAccept = bCanAccept, bHasAccept = bHasAccept,item = item,error_msg = error_msg,};
	LOG.std(nil, "info","QuestProvider:TryAccept",server_info);
	if(bHasAccept)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = true,
				id = id,
				item = item,--必须
				state="has_accept",
				server_info = server_info,
			});
		end
		return
	end
	--如果是测试用户,可以直接接取任务
	if(msg.is_power_user)then
		bCanAccept = true;
	end
	if(not bCanAccept)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = false,
				id = id,
				state="accept",
				error_msg = error_msg or {},
				server_info = server_info,
			});
		end
		return
	end
	if(id)then
		local templates = self:GetTemplateQuests();
		local template = templates[id];
		if(template)then
			--local q_item = self:GetQuest(id);
			local q_item;
			--if(not q_item)then
				--Goal----------------------------------
				--消灭怪的次数
				local Goal = template.Goal;
				local Cur_Goal = QuestHelp.Table_Init(Goal);

				--GoalItem----------------------------------
				--需要掉落物品的数量
				local GoalItem = template.GoalItem;
				--[[
					 <!--id: 需要的物品，value：需要的数量，producer_id：谁掉落，producer_odds：掉落的几率, producer_value:成功产生的数量，默认为1-->
					<!--<item id="30000" value="10" producer_id="30001" producer_odds="0.5" producer_num="1" producer_value="1"/>-->
					
				--]]
				local Cur_GoalItem = QuestHelp.Table_Init(GoalItem);

				--ClientGoalItem----------------------------------
				local ClientGoalItem = template.ClientGoalItem;
				local Cur_ClientGoalItem = QuestHelp.Table_Init(ClientGoalItem);

				--ClientExchangeItem----------------------------------
				local ClientExchangeItem = template.ClientExchangeItem;
				local Cur_ClientExchangeItem = QuestHelp.Table_Init(ClientExchangeItem);

				--FlashGame----------------------------------
				local FlashGame = template.FlashGame;
				local Cur_FlashGame = QuestHelp.Table_Init(FlashGame);

				--ClientDialogNPC----------------------------------
				--修剪ClientDialogNPC
				local ClientDialogNPC = template.ClientDialogNPC;
				local Cur_ClientDialogNPC;
				if(ClientDialogNPC)then
					local temp_ClientDialogNPC = {
						condition = ClientDialogNPC.condition or 0,
					};
					local k,v;
					for k,v in ipairs(ClientDialogNPC) do
						local node = {
							id = v.id,
							value = v.value,
							--label = v.label,
						}
						table.insert(temp_ClientDialogNPC,node);
					end
					Cur_ClientDialogNPC = QuestHelp.Table_Init(temp_ClientDialogNPC);
				end
				--CustomGoal----------------------------------
				local CustomGoal= template.CustomGoal;
				local Cur_CustomGoal = QuestHelp.Table_Init(CustomGoal);
				------------------------------------

				local function clipTable(t)
					if(t)then
						local len = #t;
						if(len == 0)then
							t = nil;
						end
					end
					return t;
				end
				Cur_Goal = clipTable(Cur_Goal);
				Cur_GoalItem = clipTable(Cur_GoalItem);
				Cur_ClientGoalItem = clipTable(Cur_ClientGoalItem);
				Cur_ClientExchangeItem = clipTable(Cur_ClientExchangeItem);
				Cur_FlashGame = clipTable(Cur_FlashGame);
				Cur_ClientDialogNPC = clipTable(Cur_ClientDialogNPC);
				Cur_CustomGoal = clipTable(Cur_CustomGoal);
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
				local time = ParaGlobal.GetTimeFormat("H:mm:ss");
				--初始化任务数据
				q_item = {
					Cur_Goal = Cur_Goal,
					Cur_GoalItem = Cur_GoalItem,
					Cur_ClientGoalItem = Cur_ClientGoalItem,
					Cur_ClientExchangeItem = Cur_ClientExchangeItem,
					Cur_FlashGame = Cur_FlashGame,
					Cur_ClientDialogNPC = Cur_ClientDialogNPC,
					Cur_CustomGoal = Cur_CustomGoal,
					id = id,
					QuestState = 3,
					date = date,
					time = time,
				};
				
				---------------------------------power api
				self:SaveServerData(id,q_item,function(msg)
					if(msg and msg.issuccess)then
						self:AddQuest(q_item);
						if(callbackFunc and type(callbackFunc) == "function")then
							callbackFunc({
								issuccess = true,
								id = id,
								state="accept",
								item = q_item,
							});
						end
					end
				end);
			--end
		end
	end
end
function QuestProvider:TryFinished(msg,callbackFunc)
	if(not self.remote)then
		return
	end
	if(not msg)then return end
	local id = msg.id;
	id = tonumber(id);
	local bHasFinished = self:HasFinished(id);
	local item = self:GetQuest(id);
	local server_info = {id = id,nid = self.nid, bHasFinished = bHasFinished,item = item,};
	LOG.std(nil, "info","QuestProvider:TryFinished",server_info);
	if(bHasFinished)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = true,
				id = id,
				state="has_finished",
				internal_tag = "tag0",
				server_info = server_info,
			});
		end
		return
	end
	if(id)then
		local templates = self:GetTemplateQuests();
		local template = templates[id];

		if(template)then
			local q_item = self:GetQuest(id);
			if(q_item)then
				local QuestRepeat = tonumber(template.QuestRepeat) or 0;
				if(QuestRepeat == 0)then
					q_item.QuestState = 1;
					local date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
					local time = ParaGlobal.GetTimeFormat("H:mm:ss");
					--保存数据,只保存完成的标记
					local clone_item = {
						id = id,
						QuestState = 1,
						date = date,
						time = time,
					}
					self:UpdateServerData(id,clone_item,function(msg)
						if(msg and msg.issuccess)then
							if(callbackFunc and type(callbackFunc) == "function")then
								callbackFunc({
									issuccess = true,
									id = id,
									state="finished",
									internal_tag = "tag2",
								});
							end		
						end
					end);
				else
					--清除数据
					self:ClearServerData(id,function(msg)
						if(msg and msg.issuccess)then
							--可以重复接
							self:RemoveQuest(id);

							if(callbackFunc and type(callbackFunc) == "function")then
								callbackFunc({
									issuccess = true,
									id = id,
									state="finished",
									internal_tag = "tag3",
								});
							end		
						end
					end);
				end		
			end
		end
	end
end
--放弃任务 重新接取
function QuestProvider:TryReAccept(msg,callbackFunc)
	if(not self.remote)then
		return
	end
	if(not msg)then return end
	local id = msg.id;
	id = tonumber(id);

	local bHasAccept = self:HasAccept(id);
	local bHasFinished = self:HasFinished(id);
	local item = self:GetQuest(id);
	local server_info = {id = id,nid = self.nid, bHasAccept = bHasAccept, bHasFinished = bHasFinished,item = item};

	if(bHasAccept or bHasFinished)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = true,
				id = id,
				state="reaccept",
				server_info = server_info,
			});
		end
		return
	end
	if(not self:HasDropped(id))then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = false,
				id = id,
				state="reaccept",
				server_info = server_info,
			});
		end
		return
	end
	if(id)then
		--清除数据
		self:ClearServerData(id,function(msg)
			if(msg and msg.issuccess)then
				self:RemoveQuest(id);
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
						issuccess = true,
						id = id,
						state="reaccept",
					});
				end
			end
		end);
	end
end
--放弃任务
function QuestProvider:TryDrop(msg,callbackFunc)
	if(not self.remote)then
		return
	end
	if(not msg)then return end
	local id = msg.id;
	id = tonumber(id);
	local bHasDropped = self:HasDropped(id);
	local bHasAccept = self:HasAccept(id);
	local item = self:GetQuest(id);
	local server_info = {id = id,nid = self.nid, bHasAccept = bHasAccept, bHasDropped = bHasDropped,item = item,};
	LOG.std(nil, "info","QuestProvider:TryDrop",server_info);
	if(bHasDropped)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = true,
				id = id,
				state="drop",
				server_info = server_info,
			});
		end
		return
	end
	if(not bHasAccept)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = false,
				id = id,
				state="drop",
				server_info = server_info,
			});
		end
		return
	end
	if(id)then
		local q_item = self:GetQuest(id);
		if(q_item)then
			q_item.QuestState = 5;
			--保存数据
			local clone_item = {
				id = id,
				QuestState = 5,
			}
			self:SaveServerData(id,clone_item,function(msg)
				if(msg and msg.issuccess)then
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({
							issuccess = true,
							id = id,
							state="drop",
						});
					end		
				end
			end);
		end
	end
end
--指定的用户可以直接删除任务
function QuestProvider:TryDelete(msg,callbackFunc)
	if(not self.remote)then
		return
	end
	if(not msg)then return end
	local id = msg.id;
	id = tonumber(id);
	--if(not self:HasAccept(id))then
		--if(callbackFunc and type(callbackFunc) == "function")then
			--callbackFunc({
				--issuccess = false,
				--id = id,
				--state="delete",
			--});
		--end
		--return
	--end
	if(id)then
		--清除数据
		self:ClearServerData(id,function(msg)
			if(msg and msg.issuccess)then
				self:RemoveQuest(id);
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
						issuccess = true,
						id = id,
						state="delete",
					});
				end
			end
		end);
	end
end
--删除前一天已经完成的日常任务 和已经废除的任务
function QuestProvider:DeleteWeeklyQuest(callbackFunc)
	if(not self.remote)then return end
	local id_list = {};
	local id_map = {};
	local templates = self:GetTemplateQuests();
	local k,q_item;
	for k,q_item in ipairs(self.quests_list) do
		local id = q_item.id;
		local template = templates[id];
		--处理已经完成的任务
		if(template)then
			local ForceResetTimeStamp = template.ForceResetTimeStamp or 0;
			--如果是周长任务
			if(self:IsWeekRepeat(id))then
				if(q_item.QuestState == 1)then
					local date = q_item.date;
					local time = q_item.time;
					local cur_date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
					local cur_time = ParaGlobal.GetTimeFormat("H:mm:ss");
					if(QuestWeekRepeat.IsOutoff(template.WeekRepeat,date,time,cur_date,cur_time))then
						if(not id_map[id])then
							table.insert(id_list,id);
							id_map[id] = id;
						end
					end
				end
			--如果是日常任务
			elseif(self:IsWeeklyQuest(id))then
				local date = q_item.date;
				local time = q_item.time;
				local cur_date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
				local cur_time = ParaGlobal.GetTimeFormat("H:mm:ss");
				--没有日期 或者日期不相同 都认为是日常任务
				if(not date or date ~= cur_date)then
					--已经完成 或者 强制重置
					if(q_item.QuestState == 1 or ForceResetTimeStamp == 1)then
						if(not id_map[id])then
							table.insert(id_list,id);
							id_map[id] = id;
						end
					end
				end
			end
		end
	end
	local len = #id_list;
	if(len == 0)then 
		if(callbackFunc)then
			callbackFunc();
		end
		return 
	end
	local i = 1;
	local function delete()
		local id = id_list[i];
		if(not id)then 
			if(callbackFunc)then
				callbackFunc();
			end
			return 
		end
		self:ClearServerData(id,function(msg)
			if(msg and msg.issuccess)then
				self:RemoveQuest(id);
				i = i + 1;
				delete();
			end
		end);
	end
	delete();
end
function QuestProvider:GetTemplateQuests()
	local q = self.template_quests;
	return q;
end
----------------------------------------------------
-- visit quest list
----------------------------------------------------
--周长任务
function QuestProvider:IsWeekRepeat(id)
	if(not id)then return end
	local templates = self:GetTemplateQuests();
	local template = templates[id];
	if(template and template.WeekRepeat)then
		local WeekRepeat = template.WeekRepeat;
		if(WeekRepeat > 0)then
			return true;
		end 
	end
end
--每日 周末
function QuestProvider:IsWeeklyQuest(id)
	if(not id)then return end
	local templates = self:GetTemplateQuests();
	local template = templates[id];
	if(template and template.TimeStamp)then
		local TimeStamp = template.TimeStamp;
		--0:每日任务 1:周末任务
		if(TimeStamp == 0 or TimeStamp == 1)then
			return true;
		end 
	end
end
--是否是已经放弃的任务
function QuestProvider:IsDropState(q_item)
	if(not q_item)then return end
	if(q_item.QuestState == 5)then
		return true;
	end
end
--是否是激活状态
function QuestProvider:IsActivedState(q_item)
	if(not q_item)then return end
	if(q_item.QuestState == 3)then
		return true;
	end
end
--是否是完成状态
function QuestProvider:IsFinishedState(q_item)
	if(not q_item)then return end
	if(q_item.QuestState == 1)then
		return true;
	end
end
function QuestProvider:GetQuestsList()
	local q = self.quests_list;
	return q;
end
function QuestProvider:GetQuest(id)
	if(not id)then return end
	return self.map_quests[id];
end
function QuestProvider:AddQuest(q)
	if(not q or not q.id)then return end
	local id = q.id;
	if(self:GetQuest(id))then
		return
	end
	self.map_quests[id] = q;
	table.insert(self.quests_list,q);
end
function QuestProvider:RemoveQuest(id)
	if(not self:GetQuest(id))then
		return
	end
	self.map_quests[id] = nil;
	local k,v;
	for k,v in ipairs(self.quests_list) do
		if(id == v.id)then
			table.remove(self.quests_list,k);
			return;
		end
	end
end
function QuestProvider:NextQuest()
	local nSize = table.getn(self.quests_list);
	local i = 1;
	return function ()
		local node;
		while i <= nSize do
			node = self.quests_list[i];
			i = i+1;
			return node;
		end
	end	
end
function QuestProvider:ResetQuestMap()
	self.map_quests = {};
	local q_item;
	for q_item in self:NextQuest() do
		local id = q_item.id;
		self.map_quests[id] = q_item;
	end
end

function QuestProvider:ResetQuestByMap(quest_map)
	if(not quest_map)then return end
	local old_quest_map = {};
	local id,new_item;
	for id,new_item in pairs(quest_map) do
		local k,old_item;
		for k,old_item in ipairs(self.quests_list) do
			local _id = old_item.id;
			if(id == _id)then
				old_quest_map[id] = commonlib.deepcopy(old_item);
				self.quests_list[k] = new_item;
				self.map_quests[id] = new_item;
			end
		end
	end
	return old_quest_map;
end
function QuestProvider:Reset()
	self.quests_list = {};
	self.map_quests = {};
end
function QuestProvider:GetQuestType(id)
	if(not id)then return end
	local templates = self:GetTemplateQuests();
	local template = templates[id];
	if(template)then
		local types = {
			"Goal","GoalItem","ClientGoalItem","ClientExchangeItem","FlashGame","ClientDialogNPC","CustomGoal",
		}
		local k,v;
		for k,v in ipairs(types) do
			local item = template[v];
			if(item)then
				local len = #item;
				if(len > 0)then
					return v;
				end
			end
		end
	end
end
----------------------------------------------------
function QuestProvider:Debug()
	LOG.std(nil, "info","QuestProvider:Debug self.template_quests",self.template_quests);
	LOG.std(nil, "info","QuestProvider:Debug self.quests_list",self.quests_list);
	LOG.std(nil, "info","QuestProvider:Debug usersinfo",self:GetUserInfo());

	if(self.remote)then
		role_str = PowerItemManager.GetUserSchool(self.nid)
	else
		role_str = Combat.GetSchool();
	end
	LOG.std(nil, "info","QuestProvider:Debug role",role_str);
end
----------------------------------------------------
function QuestProvider:NotifyChanged()
	self.is_dirty = true;
end

-- optimized by LiXizhi. 
-- @param npc_map: table map from npc_id to value. 
-- @param callbackFinished, callbackCanAccept, callbackInProgress: 
--	callbackCanFinished(npc_id, quest_id, EndDialog)
--	callbackCanAccept(npc_id, quest_id, StartDialog)
--	callbackInProgress(npc_id, quest_id, state)
function QuestProvider:FindQuestsByNPCMap(npc_map, callbackCanFinished, callbackCanAccept, callbackInProgress)
	local quest_list = self:FindQuests();
	if(not quest_list or not npc_map)then
		return 
	end
	local templates = self:GetTemplateQuests();
	for k,v in ipairs(quest_list) do
		local questid = v.questid;
		local id = questid;
		local state = v.state;
		if(questid and state and templates[questid])then
			local template = templates[questid];
			local StartNPC = template.StartNPC;
			local EndNPC = template.EndNPC;
			if(npc_map[StartNPC] or npc_map[EndNPC])then
				local ShowProgressingDialog = template.ShowProgressingDialog or 0;
				--state:  0 hasaccept and canfinished
				--1 hasaccept and not canfinished
				--2 canaccept
				--9 locked
				--10 finished
				--11 drop 放弃的任务
				local hasAccept = (state == 0 or state == 1);
				local canAccept = (state == 2);
				local canFinished = (state == 0);

				if(npc_map[StartNPC] and canAccept)then
					if(callbackCanAccept) then
						callbackCanAccept(StartNPC, id, template.StartDialog);
					end
				end
				if(npc_map[EndNPC] and canFinished)then
					if(callbackCanFinished) then
						callbackCanFinished(EndNPC, id, template.EndDialog);
					end
				end

				if(ShowProgressingDialog == 1)then
					if(ShowProgressingDialog == 1 and hasAccept and not canFinished)then
						if(npc_map[StartNPC])then
							if(callbackInProgress) then
								callbackInProgress(StartNPC, id, StartDialog);
							end
						else
							--没有处理交任务npc的状态
						end
					end
				end
			end
		end
	end
end

--返回和npc关联的任务列表
function QuestProvider:FindQuestsByNPC(npcid)
	if(not npcid)then return end
	local templates = self:GetTemplateQuests();
	local result = {};
	local result_map = {};

	local result_canfinished = {};
	local result_canaccept = {};
	local result_progressing = {};

	local result_canfinished_map = {};
	local result_canaccept_map = {};
	local result_progressing_map = {};
	local result_clientdialog = nil;

	local quest_list = self:FindQuests();
	
	if(quest_list)then
		for k,v in ipairs(quest_list) do
			local questid = v.questid;
			local id = questid;
			local state = v.state;
			if(questid and state and templates[questid])then
				local template = templates[questid];
				local StartNPC = template.StartNPC;
				local EndNPC = template.EndNPC;
				local TimeStamp = template.TimeStamp;
				local ShowProgressingDialog = template.ShowProgressingDialog or 0;
				local ClientDialogNPC = template.ClientDialogNPC;
				local StartDialog = template.StartDialog;
				local EndDialog = template.EndDialog;

				--state:  0 hasaccept and canfinished
				--1 hasaccept and not canfinished
				--2 canaccept
				--9 locked
				--10 finished
				--11 drop 放弃的任务
				local hasAccept = if_else((state == 0 or state == 1),true,false);
				local canAccept = if_else(state == 2,true,false);
				local canFinished = if_else(state == 0,true,false);

				if(npcid == StartNPC and canAccept)then
					local node = { npcid = npcid, questid = id, state="start", Dialog = StartDialog, };
					table.insert(result,node);
					result_map[id] = node;

					table.insert(result_canaccept,node);
					result_canaccept_map[id] = node;
				end
				if(npcid == EndNPC and canFinished)then
					local node = { npcid = npcid, questid = id, state="end", Dialog = EndDialog, };
					table.insert(result,node);
					result_map[id] = node;

					table.insert(result_canfinished,node);
					result_canfinished_map[id] = node;

				end
				--进行中的任务
				if(npcid == StartNPC or npcid == EndNPC)then
					if(ShowProgressingDialog == 1)then
						if(ShowProgressingDialog == 1 and hasAccept and not canFinished and not result_progressing_map[id])then
							if(npcid == StartNPC)then
								local node = { npcid = npcid, questid = id, state="progressing", Dialog = StartDialog, };
								table.insert(result_progressing,node);
								result_progressing_map[id] = node;
							else
								--没有处理交任务npc的状态
							end
						end
					else
						if(hasAccept and not result_progressing_map[id])then
							local node = { npcid = npcid, questid = id, state="internal_progressing",};
							table.insert(result_progressing,node);
							result_progressing_map[id] = node;
						end
					end
				end

				if(hasAccept and ClientDialogNPC)then
					local q_item = self:GetQuest(id);
					if(q_item)then
						local cur_p = q_item.Cur_ClientDialogNPC;
						for k,v in ipairs(ClientDialogNPC) do
							local _npcid = v.id
							local _label = v.label or "";
							local req_value = v.value;
							if(npcid == _npcid and cur_p)then
								for kk,vv in ipairs(cur_p) do
									local cur_id = vv.id;
									local cur_value = vv.value;
									--如果已经完成对话 忽略显示
									if(cur_id == _npcid and cur_value < req_value)then
										result_clientdialog = {
											label = _label,
											buttons = v;
										};
										break;
									end
								end         
							end
						end
					end
		            
				end
			end
		end
	end
	return result,
	result_canfinished,
	result_canaccept,
	result_progressing,
	result_map,
	result_canfinished_map,
	result_canaccept_map,
	result_progressing_map,
	result_clientdialog--激活任务后 和某个npc的对话
end
--[[
	任务列表里面显示的内容
	state:  0 hasaccept and canfinished
			1 hasaccept and not canfinished
			2 canaccept
			9 locked
			10 finished
			11 drop 放弃的任务
返回任务列表，包含任务id和任务状态
--]]
--@param bCustomSort:是否 自定义排序
function QuestProvider:FindQuests(bCustomSort)
	if(self.is_dirty or not self.memory_quest_states)then
		--npl_profiler.perf_begin("FindQuests", true);
		self.memory_quest_states = self:FindQuests_Internal(bCustomSort);
		self.is_dirty = false;
		--npl_profiler.perf_end("FindQuests", true);
		-- only 0.175s on mobile phone 2015.3.30
		--LOG.std(nil, "info", "FindQuests Perf", npl_profiler.perf_get("FindQuests"));
	end
	return self.memory_quest_states;
end
function QuestProvider:FindQuests_Internal(bCustomSort)
	local graph = self.template_graph;
	if(graph)then
		local output = { };
		local output_map = {};
		local bean = MyCompany.Aries.Pet.GetBean();

		local function drawNodesArcs(gNode)
			if(not gNode or not output or not output_map)then return end
			local data = gNode:GetData();

			if(data)then
				local template = data.templateData;--模板原始数据
				if(template)then
					local id = template.Id;
					if(id)then
						id = tonumber(id);
						local Role = template.Role;
						local hasAccept = self:HasAccept(id);
						
						local QuestGroup1 = template.QuestGroup1 or 0;--默认主线任务
						local QuestGroup2 = template.QuestGroup2 or 0;--默认主线任务的 第一个分类
						local QuestGroup3 = template.QuestGroup3 or 0;--子分类
						local RequestAttr = template.RequestAttr;
						local RecommendLevel = template.RecommendLevel or 0;--推荐等级
						local TimeStamp = template.TimeStamp;
						local WeekRepeat = template.WeekRepeat;
						local attr_level = -1;
						local attr_max_level = nil;
						local state = self:GetState(id);

						if(RequestAttr)then
							local k,v;
							for k,v in ipairs(RequestAttr) do
								local id = v.id;
								local value = v.value;
								value = tonumber(value);
								local topvalue = v.topvalue;
								topvalue = tonumber(topvalue);
								if(id == 214 and value)then
									attr_level = value;

									attr_max_level = topvalue;
								end
							end
						end

						local isMyRole = self:Role_Equals(Role);
						
						--如果有级别限制，只显示 高于战斗等级 3级以内的任务
						local canpush = true;
						if(bean)then
							local combatlel = bean.combatlel or 0;
							if(self.load_version == "kids") then
								if(attr_level)then
									if(attr_level > (combatlel + 3))then
										canpush = false;
									end
									if(attr_level and attr_max_level)then
										if(combatlel > attr_max_level)then
											canpush = false;
										end
									end
									--过滤locked的任务
									if(state and state == 9)then
										canpush = false;
									end
								end
							else
								if(RecommendLevel > (combatlel + 3))then
									canpush = false;
								end
							end
						end
						if(hasAccept)then
							canpush = true;
						end
						--日常任务过滤
						if(not hasAccept)then
							if(self.load_version ~= "kids") then
								canpush = true;
							end
							if(self:IsWeekRepeat(id))then
								--周长任务过滤
								local date,time;
								if(self.remote)then
									date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
									time = ParaGlobal.GetTimeFormat("H:mm:ss");
								else
									date,time = QuestTimeStamp.GetClientDateTime()
								end
								if(not QuestWeekRepeat.CanAccept(WeekRepeat,date,time))then
									canpush = false;
								end
							elseif(self.weekly_valid_maps)then
								--每日 周末任务过滤
								local map_type_0 = self.weekly_valid_maps[0];
								if(TimeStamp and TimeStamp == 0 and map_type_0 and not map_type_0[id])then
									canpush = false;
								end
								local map_type_1 = self.weekly_valid_maps[1];
								if(TimeStamp and TimeStamp == 1 and map_type_1 and not map_type_1[id])then
									canpush = false;
								end
								local date = self.weekly_valid_maps.date;
								local week = QuestTimeStamp.GetWeek(date) 
								if(TimeStamp and TimeStamp == 1)then
									if(week and week < 6)then
										canpush = false;
									end
								end
							end
						end
						local label = template.Title;
						local node;
						--设置追踪的时间
						--local track_time = self:LoadQuestTrackState(id)
						--取消追踪时间
						local track_time = "";
						node = { track_time = track_time, questid = id, state = state, attr_level = attr_level, label = label, QuestGroup1 = QuestGroup1, QuestGroup2 = QuestGroup2, QuestGroup3 = QuestGroup3, RecommendLevel = RecommendLevel, TimeStamp = TimeStamp,};
					
						if(not output_map[id] and isMyRole and canpush)then
							table.insert(output,node);
							output_map[id] = node;
						end
					end
				end
			end

		end
		GraphHelp.Search_DepthFirst_FromRoot(graph,drawNodesArcs);
		if(self.load_version == "teen")then
			if(not bCustomSort)then
				table.sort(output,function(a,b)
					return (a.state < b.state) or ( (a.state == b.state) and (a.RecommendLevel < b.RecommendLevel) ) ;
				end);
			end
		else
			if(not bCustomSort)then
				table.sort(output,function(a,b)
					return (a.state < b.state) or ( (a.state == b.state) and (a.attr_level < b.attr_level) ) ;
				end);
			end
		end
		return output;
	end
end
--任务大全
function QuestProvider:FindAllQuestsTemplate(bCustomSort)
	local graph = self.template_graph;
	if(graph)then
		local output = { };
		local output_map = {};
		local function drawNodesArcs(gNode)
			if(not gNode or not output or not output_map)then return end
			local data = gNode:GetData();

			if(data)then
				local template = data.templateData;--模板原始数据
				if(template)then
					local id = template.Id;
					if(id)then
						id = tonumber(id);
						local Role = template.Role;
						local QuestGroup1 = template.QuestGroup1 or 0;--默认主线任务
						local QuestGroup2 = template.QuestGroup2 or 0;--默认主线任务的 第一个分类
						local QuestGroup3 = template.QuestGroup3 or 0;--子分类
						local RecommendLevel = template.RecommendLevel or 0;--推荐等级
						local isMyRole = self:Role_Equals(Role);
						local RequestAttr = template.RequestAttr;
						local attr_level = -1;
						local attr_max_level = nil;
						local state = self:GetState(id);
						if(RequestAttr)then
							local k,v;
							for k,v in ipairs(RequestAttr) do
								local id = v.id;
								local value = v.value;
								value = tonumber(value);
								local topvalue = v.topvalue;
								topvalue = tonumber(topvalue);
								if(id == 214 and value)then
									attr_level = value;

									attr_max_level = topvalue;
								end
							end
						end

						local label = template.Title;
						local node;
						node = { questid = id, state = state, attr_level = attr_level, label = label, QuestGroup1 = QuestGroup1, QuestGroup2 = QuestGroup2, QuestGroup3 = QuestGroup3, RecommendLevel = RecommendLevel,};
					
						if(not output_map[id] and isMyRole)then
							table.insert(output,node);
							output_map[id] = node;
						end
					end
				end
			end

		end
		GraphHelp.Search_DepthFirst_FromRoot(graph,drawNodesArcs);
		if(self.load_version == "teen")then
			if(not bCustomSort)then
				table.sort(output,function(a,b)
					return (a.RecommendLevel < b.RecommendLevel) or ( (a.RecommendLevel == b.RecommendLevel) and (a.QuestGroup1 < b.QuestGroup1) ) ;
				end);
			end
		else
			if(not bCustomSort)then
				table.sort(output,function(a,b)
					return (a.attr_level < b.attr_level) or ( (a.attr_level == b.attr_level) and (a.QuestGroup1 < b.QuestGroup1) ) ;
				end);
			end
		end
		return output;
	end
end
--获取任务的状态
--[[
	任务列表里面显示的内容
	state:  0 hasaccept and canfinished
			1 hasaccept and not canfinished
			2 canaccept
			9 locked
			10 finished
			11 drop 放弃的任务
--]]
function QuestProvider:GetState(id)
	if(not id)then return end
	local state = 9;
	local hasAccept = self:HasAccept(id);
	local canAccept = self:CanAccept(id);
	local canFinished = self:CanFinished(id);
	local finished = self:HasFinished(id);
	local drop = self:HasDropped(id);
	if(hasAccept and canFinished)then
		state = 0;
	elseif(hasAccept and not canFinished)then
		state = 1;
	elseif(canAccept)then
		state = 2;
	elseif(finished)then
		state = 10;
	elseif(drop)then
		state = 11;
	else
		state = 9;
	end
	return state;
end
--根据目标模板替换任务进度
function QuestProvider:CheckQuestItemGoalValue(q_item)
	if(not q_item)then
		return
	end
	local id = q_item.id;
	local QuestState = q_item.QuestState;
	local templates = self:GetTemplateQuests();
	if(templates and QuestState and QuestState ~= 1)then
		local template = templates[id];
		if(template)then
			q_item.Cur_Goal = self:CheckQuestGoalValue(q_item.Cur_Goal,template["Goal"],"Goal");
			q_item.Cur_GoalItem = self:CheckQuestGoalValue(q_item.Cur_GoalItem,template["GoalItem"],"GoalItem");
			q_item.Cur_ClientGoalItem = self:CheckQuestGoalValue(q_item.Cur_ClientGoalItem,template["ClientGoalItem"],"ClientGoalItem");
			q_item.Cur_ClientExchangeItem = self:CheckQuestGoalValue(q_item.Cur_ClientExchangeItem,template["ClientExchangeItem"],"ClientExchangeItem");
			q_item.Cur_FlashGame = self:CheckQuestGoalValue(q_item.Cur_FlashGame,template["FlashGame"],"FlashGame");
			q_item.Cur_ClientDialogNPC = self:CheckQuestGoalValue(q_item.Cur_ClientDialogNPC,template["ClientDialogNPC"],"ClientDialogNPC");
			q_item.Cur_CustomGoal = self:CheckQuestGoalValue(q_item.Cur_CustomGoal,template["CustomGoal"],"CustomGoal");
		end
	end
	return q_item;
end
--根据任务目标的模板 和serverdata里面的数据生成 任务进度列表
--可以避免更换任务目标后，任务不能完成
-- @param source:serverdata里面的原始数据
-- @param template:任务进度的模板
-- @param template_type:任务进度的模板类型
function QuestProvider:CheckQuestGoalValue(source,template,template_type)
	if(not template or not template_type)then
		return
	end
	local len = #template;
	if(len == 0)then
		return
	end
	source = source or {};
	local source_map = {};
	local k,v;
	for k,v in ipairs(source) do
		local id = v.id;
		if(id)then
			source_map[id] = v;
		end
	end
	local result = {
		condition = template.condition or 0
	};
	local k,v;
	for k, v in ipairs(template) do
		local id = v.id;
		if(id)then
			local source_node = source_map[id] or {};
			local value = source_node.value or 0;
			local max_value = v.value;
			local node = {
				id = id,
				value = value,
				max_value = max_value,
			}
			if(template_type == "GoalItem")then
				node.producer_id = v.producer_id;
				node.append_producer_id_list = v.append_producer_id_list;
				node.producer_odds = v.producer_odds;
				node.producer_num = v.producer_num;
				node.producer_value = v.producer_value;
			end
			table.insert(result,node);
		end
	end
	return result;
end
-----------------------------------------------------------------------
--server data
-----------------------------------------------------------------------
function QuestProvider:ClearServerData(gsid,callbackFunc)
	local nid = self.nid;
	if(not nid or not gsid)then return end
    local templates = self:GetTemplateQuests();
    if(not templates[gsid])then
		LOG.std(nil, "warn","try to delete an unexisting quest through QuestProvider:ClearServerData",gsid);
        return;
    end
	local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,gsid);
	if(hasItem)then
		PowerItemManager.DestroyItem(nid, guid, 1, callbackFunc)
	end
end
function QuestProvider:ClearAllServerData(callbackFunc)
	if(not self.remote)then return end
	local nid = self.nid;
	local bag = 999;	
	local list = PowerItemManager.GetItemsInBagInMemory(nid,bag);
	LOG.std(nil, "info","before QuestProvider:ClearAllServerData",{nid = nid});
	if(list)then
		local guids = {};
		local k,guid;
		for k,guid in ipairs(list) do
			guids[guid] = 1;
		end
		PowerItemManager.DestroyItemBatch(nid, guids, function(msg)
			LOG.std(nil, "info","after QuestProvider:ClearAllServerData",msg);
			if(msg and msg.issuccess)then
				self:Reset();
			end
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end	
		end)
	end
end
function QuestProvider:LoadAllServerData()
	if(not self.remote)then return end
	local nid = self.nid;
	local bag = 999;	
	local list = PowerItemManager.GetItemsInBagInMemory(nid,bag);
	--LOG.std(nil, "info","QuestProvider:LoadAllServerData",{nid = nid,});
	if(list)then
		local k,guid;
		for k,guid in ipairs(list) do
			local item = PowerItemManager.GetItemByGUID(nid, guid);
			if(item)then
				local serverdata = item.serverdata;
				--LOG.std(nil, "info","QuestProvider:LoadAllServerData====item",item);
				serverdata = QuestHelp.DeSerializeTable(serverdata);
				--LOG.std(nil, "info","QuestProvider:LoadAllServerData====serverdata",serverdata);
				if(serverdata and type(serverdata) == "table")then
					self:CheckQuestItemGoalValue(serverdata);
					--初始化所有任务完成情况
					self:AddQuest(serverdata);
				end
			end
		end
	end
end
function QuestProvider:SaveServerData(gsid,serverdata,callbackFunc)
	if(not self.remote)then return end
	local nid = self.nid;
	if(not nid or not gsid or not serverdata or type(serverdata) ~= "table")then return end
	local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,gsid);
	serverdata = QuestHelp.SerializeTable(serverdata);
	LOG.std(nil, "info","QuestProvider:SaveServerData",{nid = nid, gsid = gsid, hasItem = hasItem, guid = guid, serverdata = serverdata });
	if(not hasItem)then
		LOG.std(nil, "info","before PowerItemManager.PurchaseItem");
		PowerItemManager.PurchaseItem(nid, gsid, 1, serverdata, nil, function(msg)
		LOG.std(nil, "info","after PowerItemManager.PurchaseItem",msg);
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
		end)
	else
		LOG.std(nil, "info","before PowerItemManager.SetServerData");
		PowerItemManager.SetServerData(nid, guid, serverdata, function(msg)
		LOG.std(nil, "info","after PowerItemManager.SetServerData",msg);
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
		end)
	end
end

function QuestProvider:UpdateServerData(gsid,serverdata,callbackFunc)
	if(not self.remote)then return end
	local nid = self.nid;
	if(not nid or not gsid or not serverdata or type(serverdata) ~= "table")then return end
	local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,gsid);
	serverdata = QuestHelp.SerializeTable(serverdata);
	LOG.std(nil, "info","QuestProvider:UpdateServerData",{nid = nid, gsid = gsid, hasItem = hasItem, guid = guid, serverdata = serverdata });
	LOG.std(nil, "info","before PowerItemManager.SetServerData in QuestProvider:UpdateServerData");
	local maxTryNum = 5;
	local curNum = 0;

	function dosave()
		curNum = curNum + 1;
		if(curNum > maxTryNum)then
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc({issuccess = false});
			end
			return
		end
		PowerItemManager.SetServerData(nid, guid, serverdata, function(msg)
			LOG.std(nil, "info","after PowerItemManager.SetServerData  in QuestProvider:UpdateServerData",msg);
			if(msg and msg.issuccess)then
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc(msg);
				end
			else
				LOG.std(nil, "info","Retry PowerItemManager.SetServerData in QuestProvider:UpdateServerData",curNum);
				dosave();
			end
		end)
	end
	dosave();
end
--加载取消追踪的时间
function QuestProvider:LoadQuestTrackState(questid)
	if(not questid)then return end
	local key = string.format("QuestTrackerPane.LoadQuestTraceState_%d",System.User.nid or 0);
	local result = MyCompany.Aries.Player.LoadLocalData(key) or {};
	return result[questid] or "";
end
--保存取消追踪的时间
function QuestProvider:SaveQuestTrackState(questid,v)
	if(not questid)then return end
	local key = string.format("QuestTrackerPane.LoadQuestTraceState_%d",System.User.nid or 0);
	local result = MyCompany.Aries.Player.LoadLocalData(key) or {};
	result[questid] = v;
	MyCompany.Aries.Player.SaveLocalData(key,result);
end
function QuestProvider:ResetAllTrackState()
	local key = string.format("QuestTrackerPane.LoadQuestTraceState_%d",System.User.nid or 0);
	MyCompany.Aries.Player.SaveLocalData(key,nil);
end