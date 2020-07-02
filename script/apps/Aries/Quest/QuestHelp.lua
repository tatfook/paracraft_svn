--[[
Title: 
Author(s): Leio
Date: 2010/8/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local path = "config/Aries/Quests/quest_list.xml";
local data = QuestHelp.LoadAllQuests(path);
local graph = QuestHelp.CreateGraph(data,true);
QuestHelp.SaveToDgml(graph,"HaqiQuestTools/quest_template_parsed.dgml",false)

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local path = "config/Aries/Quests_Teen/quest_list.xml";
local data = QuestHelp.LoadAllQuests(path);
local graph = QuestHelp.CreateGraph(data,true);
QuestHelp.SaveToDgml(graph,"HaqiQuestTools/quest_template_parsed.teen.dgml",false)

--生成NPC
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.is_kids_version = false;--teen
QuestHelp.BuildNpcListXml_OutPut();
--生成奖励物品
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.BuildRewardListXml(output_path)

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local map = QuestHelp.BuildMobMap();
commonlib.echo(map);

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.GetHeroDragonData()

local command = System.App.Commands.GetCommand("Aries.Quest.DoAddValue");
if(command) then
	command:Call({
		increment = { {id = id,value = score}, },
		});
end
增加一种任务类型 步骤：
QuestHelp.ParseQuestBlock()
QuestClientLogics.OnInit() QuestClientLogics.GetCustomGoalList()
script/apps/Aries/Quest/QuestDetailFramePage.html goalProgress() goalProgressInfo()

QuestProvider:TryAccept QuestProvider:CanFinished QuestProvider:DoAddValue

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.DoAutoJoinRoom_PvE("FrostRoarIsland_IceKingCave");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/SunnyBeach/PvPTicket.lua");
local PvPTicket_NPC = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvPTicket_NPC");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererCommon.lua");
local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");

NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");

NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");

NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/ide/Graph.lua");
local Graph = commonlib.gettable("commonlib.Graph");
local GraphNode = commonlib.gettable("commonlib.GraphNode");
local GraphArc = commonlib.gettable("commonlib.GraphArc");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");

-- create class
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.is_kids_version = true;
function QuestHelp.IsKidsVersion()
	if(System and System.options and System.options.version)then
		if(System.options.version ~= "kids")then
			QuestHelp.is_kids_version = false;
		end
	end
	return QuestHelp.is_kids_version;
end
--[[
初始化table

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local t = {
	{id = 20000, value = 10 },
	{id = 20001, value = 11 },
}
t = QuestHelp.Table_Init(t);
commonlib.echo(t);
--]]
function QuestHelp.Table_Init(template,value)
	local self = QuestHelp;
	value = value or 0;
	local result;
	if(template)then
		template = commonlib.deepcopy(template);
		local k,v;
		for k,v in ipairs(template) do
			local max_value = v.value;
			v.value = value;
			v.max_value = max_value;
		end
	end
	return template;
end
--[[
local input = {
				{name="item",attr={id="20000",value="1",},},{name="item",attr={id="20001",value="10",},},
				attr={condition="0",},
				name="RequestAttr",
				n=2,
				}

 to:
 {	
	condition = 0,
	{id = 20000,value = 1},
	{id = 20001,value = 10},
 }

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local input = {
				{name="item",attr={id="20000",value="1",},},{name="item",attr={id="20001",value="10",},},
				attr={condition="0",},
				name="RequestAttr",
				n=2,
				}
input = QuestHelp.XmlSplitTableToTable(input);
commonlib.echo(input);
--]]
function QuestHelp.XmlSplitTableToTable(input)
	local self = QuestHelp;
	if(not input)then return end
	local condition = input.attr.condition;
	condition = tonumber(condition);
	--难度
	local mode = input.attr.mode;
	mode = tonumber(mode);

	local k,v;
	local output = {};
	local function get_arr(s)
		if(not s)then return end
		local list = {};
		local id;
		for id in string.gfind(s, "([^#]+)") do
			id = tonumber(id);
			if(id)then
				table.insert(list,id);
			end
		end
		return list;
	end
	for k,v in ipairs(input) do
		local attr = v.attr;
		if(attr)then
			local id = attr.id;
			local value = attr.value;

			local producer_id = attr.producer_id;
			local producer_odds = attr.producer_odds;
			local producer_num = attr.producer_num;
			local producer_value = attr.producer_value;
			--多个怪物的id,类似:"30002#30003"
			local append_producer_id_list = attr.append_producer_id_list;
			--前置属性增加了最大值
			local topvalue = attr.topvalue;
			local need_destroy = attr.need_destroy;
			id = tonumber(id);
			value = tonumber(value);

			producer_id = tonumber(producer_id);
			producer_odds = tonumber(producer_odds);
			producer_num = tonumber(producer_num);
			producer_value = tonumber(producer_value);

			topvalue = tonumber(topvalue);
			need_destroy = tonumber(need_destroy);
			local item;
			--id value 必须有
			if(id and value)then
				item = { id = id, value = value};
				--只有GoalItem节点有下面两个属性
				if(producer_id)then
					item.producer_id = producer_id;
				end
				if(producer_odds)then
					item.producer_odds = producer_odds;
				end
				if(producer_num)then
					item.producer_num = producer_num;
				end
				if(producer_value)then
					item.producer_value = producer_value;
				end
				if(append_producer_id_list)then
					--转换成table
					item.append_producer_id_list = get_arr(append_producer_id_list);
				end
				if(topvalue)then
					item.topvalue = topvalue;
				end
				if(need_destroy)then
					item.need_destroy = need_destroy;
				end
				table.insert(output,item);
			end
		end
	end
	output.condition = condition;
	output.mode = mode;
	return output;
end

--[[
--字符串是否相等，默认为>=,如果bStrict,条件为=
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local source = {
	condition = 0, --0 and ,1 or
	{id = 20000,value = 1,},
	{id = 20001,value = 2,},
	{id = 20002,value = 3,},
}
local target = {
	condition = 0, --0 and ,1 or
	{id = 20000,value = 1,},
	{id = 20001,value = 2,},
	{id = 20002,value = 3,},
}
local b = QuestHelp.Table_Equals(source,target);
commonlib.echo(b);
--]]
function QuestHelp.Table_Equals(source,target,bStrict)
	if(source and target and source.condition and target.condition)then
		local index = 0;
		local s_condition = source.condition;
		local t_condition = target.condition;
		if(s_condition ~= t_condition)then
			return
		end
		local k,v;
		for k,v in ipairs(target) do
			local t_id = v.id;
			local t_value = v.value;
			if(t_id and t_value)then
				local kk,vv;
				for kk,vv in ipairs(source) do
					local s_id = vv.id;
					local s_value = vv.value;
					if(s_id and s_value)then
						if(t_id == s_id)then
							--or
							if(t_condition == 1)then
								if(bStrict)then
									if(s_value == t_value)then
										return true;
									end
								else
									if(s_value >= t_value)then
										return true;
									end
								end
							elseif(t_condition == 0 or t_condition == 2 )then
								if(bStrict)then
									if(s_value == t_value)then
										index = index + 1;
									end
								else
									if(s_value >= t_value)then
										index = index + 1;
									end
								end
							end
						end
					end
				end
			end
		end
		local len = #target;
		if(index >= len)then
			return true;
		end
	end
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local old = {
	{id = 20000, value = 10, max_value = 15, },
	{id = 20001, value = 11, max_value = 15,},
}
local increment = {
	{id = 20000, value = 2 },
	{id = 20001, value = 2 },
}
local condition = 2;
local t = QuestHelp.Table_Add(old,increment);
commonlib.echo(t);
--param questid:任务id
--]]
--@param old:
--@param increment:增量
--@param condition:0:and 1:or 2:order
--@param questid:
--@param goal_mode:要求的难度 0(easy),1(normal),2(hard)
--@param source_mode:难度 0(easy),1(normal),2(hard)
function QuestHelp.Table_Add(old,increment,condition,questid,goal_mode,source_mode)
	local self = QuestHelp;
	if(not old or not increment)then return end
	condition = condition or 1;
	goal_mode = goal_mode or 0;
	source_mode = source_mode or 0;
	local k,v;
	local bAdd = false;
	for k,v in ipairs(increment) do
		local inc_id = tonumber(v.id);

		local inc_value = v.value or 0;
		if(inc_id and inc_value)then
			local kk,vv;
			for kk,vv in ipairs(old) do
				local old_id = tonumber(vv.id);
				local old_value = vv.value  or 0;
				local max_value;
				--NOTE:2011/03/15 从任务目标判断 任务目标最大值
				local max_value =  self.GetGoalValue(questid,old_id);
				if(not max_value)then
					--最初 任务目标最大值是记录在 serverdata里面了，现在从任务模板读取
					max_value = vv.max_value;
				else
					vv.max_value = max_value;
				end
				if(inc_id == old_id)then
					local can_add = true;
					if(condition == 2 and kk > 1)then
						local pre_node = old[kk-1];
						--NOTE:2011/03/15 从任务目标判断 任务目标最大值
						local pre_node_max_value =  self.GetGoalValue(questid,pre_node.id);
						if(not pre_node_max_value)then
							pre_node_max_value = pre_node.max_value;
						else
							pre_node.max_value = pre_node_max_value;
						end
						if(pre_node and pre_node.value < pre_node_max_value)then
							can_add = false;
						end
					end
					--判断难度
					if(source_mode < goal_mode)then
						can_add = false;
					end
					if(can_add)then
						local new_value = old_value + inc_value;
						bAdd = true;
						if(max_value)then
							new_value = math.min(new_value,max_value);
						end
						vv.value = new_value;
					end
				end
			end
		end
	end
	return old,bAdd;
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local old = {
	{id = 30000, value = 10, max_value = 15, producer_id = 20000, append_producer_id_list = {20002,20003,}, producer_odds = 1, producer_num = 1, producer_value = 1, },
	{id = 30001, value = 10, max_value = 15,  producer_id = 20001, producer_odds = 1, producer_num = 1, producer_value = 1, },
}
local increment = {
	{id = 20000, value = 2 },
	{id = 20001, value = 11 },
	{id = 20002, value = 1 },
	{id = 20003, value = 1 },
}
local condition = 1;
local t,increment_result = QuestHelp.Table_Add_Item(old,increment,condition);
commonlib.echo(t);
commonlib.echo(increment_result);
--]]
--@param old:
--@param increment:增量
--@param condition:0:and 1:or 2:order
--@param questid:
--@param goal_mode:要求的难度 0(easy),1(normal),2(hard)
--@param source_mode:难度 0(easy),1(normal),2(hard)
function QuestHelp.Table_Add_Item(old,increment,condition,questid,goal_mode,source_mode)
	local self = QuestHelp;
	if(not old or not increment)then return end
	condition = condition or 1;
	goal_mode = goal_mode or 0;
	source_mode = source_mode or 0;
	local k,v;
	local increment_result = {};
	local bAdd = false;

	local function has_id(list,id)
		if(list and id)then
			local k,v;
			for k,v in ipairs(list) do
				if(id == v)then
					return true;
				end
			end
		end
	end
	for k,v in ipairs(increment) do
		local inc_id = v.id;
		local inc_value = v.value or 0;
		if(inc_id and inc_value)then
			local kk,vv;
			for kk,vv in ipairs(old) do
				--需要的物品id
				local old_item_id = vv.id;
				--需要的数量
				local old_value = vv.value  or 0;
				--NOTE:2011/04/22 从任务目标判断 任务目标最大值
				local max_value =  self.GetGoalValue(questid,old_item_id);
				if(not max_value)then
					--最初 任务目标最大值是记录在 serverdata里面了，现在从任务模板读取
					max_value = vv.max_value;
				else
					vv.max_value = max_value;
				end

				--怪物id
				local old_producer_id = vv.producer_id;
				local append_producer_id_list = vv.append_producer_id_list;

				local odds = vv.producer_odds  or 1;--默认概率为1
				local producer_num = vv.producer_num  or 1;--单位
				producer_num = math.max(producer_num,1);--最小为1

				local producer_value = vv.producer_value  or 1;--产生的值

				if(inc_id == old_producer_id or has_id(append_producer_id_list,inc_id))then
					local can_add = true;
					if(condition == 2 and kk > 1)then
						local pre_node = old[kk-1];

						--NOTE:2011/04/22 从任务目标判断 任务目标最大值
						local pre_node_max_value =  self.GetGoalValue(questid,pre_node.id);
						if(not pre_node_max_value)then
							--最初 任务目标最大值是记录在 serverdata里面了，现在从任务模板读取
							pre_node_max_value = pre_node.max_value;
						else
							pre_node.max_value = pre_node_max_value;
						end
						if(pre_node and pre_node.value < pre_node_max_value)then
							can_add = false;
						end
					end
					--判断难度
					if(goal_mode and source_mode and source_mode < goal_mode)then
						can_add = false;
					end
					if(can_add)then
						local r = math.random(100);
						local odds = math.floor(odds * 100);
					
						if(r <= odds)then
							local scale = math.floor(inc_value/producer_num);
							inc_value = scale * producer_value;
							local new_value = old_value + inc_value;
							bAdd = true;
							if(max_value)then
								new_value = math.min(new_value,max_value);
							end
							vv.value = new_value;
							--记录增量
							local item = increment_result[old_item_id];
							if(not item)then
								item = { id = old_item_id, value = 0, };
								increment_result[old_item_id] = item;
							end
							--记录了所有的增量 
							item.value = item.value + inc_value;
						end
					end
				end
			end
		end
	end
	return old,increment_result,bAdd;
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local path = "script/apps/Aries/Quest/Test/quest_block.xml";
local r = QuestHelp.ParseQuestBlockFile(path);
commonlib.echo(r);
--]]
function QuestHelp.ParseQuestBlockFile(path)
	local self = QuestHelp;
	if(not path)then return end
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", path);
	end
	local result = self.ParseQuestBlock(xmlRoot[1]);
	return result;
end
function QuestHelp.ParseQuestBlockStr(input)
	local self = QuestHelp;
	if(not input)then return end
	local xmlRoot = ParaXML.LuaXML_ParseString(input);
	local result = self.ParseQuestBlock(xmlRoot[1]);
	return result;
end
function QuestHelp.ParseQuestBlock(xmlnodes,is_debug)
	local self = QuestHelp;
	if(not xmlnodes)then return end
	local result = {};
	local k,v;
	for k,v in ipairs(xmlnodes) do
		local name = v.name;
		--忽略废除的任务
		if(name == "Obsolesced" and not is_debug)then
			local is_obs = v[1];
			if(is_obs and (is_obs == 1 or is_obs == "1"))then
				return
			end
		end
		if(name == "Title" or name == "Detail" or name == "Icon" or name == "ValidDate" or name == "Comment" or name == "RecommendMembers")then
			result[name] = v[1] or "";
		elseif(name == "Reward" )then
			result[name] = self.RewardXmlToTable(v);
		elseif(name == "Goal" or name == "GoalItem" or name == "ClientGoalItem" or name == "ClientExchangeItem" or name == "FlashGame" or name == "RequestAttr" or name == "RequestQuest" or name == "CustomGoal")then
			result[name] = self.XmlSplitTableToTable(v);
		elseif(name == "StartDialog" or name == "EndDialog")then
			result[name] = self.DialogXmlToTable(v);
		elseif(name == "ClientDialogNPC")then
			result[name] = self.ClientDialogNPC_XmlToTable(v);
		else
			result[name] = tonumber(v[1]);
		end
	end
	return result;
end
--[[
 <dialog state="start" npcid="1" questid="10">
        <item>
            <id>npc</id>
            <content>NPC 说: 1</content>
            <buttons>
                <button action="gotonext" label="按钮1"/>
            </buttons>
        </item>
        <item>
            <id>npc</id>
            <content>NPC 说: 2</content>
            <buttons>
                <button action="gotonext" label="按钮2"/>
            </buttons>
        </item>
        <item>
            <id>user</id>
            <content>我 说: 1</content>
            <buttons>
                <button action="gotonext" label="按钮3"/>
            </buttons>
        </item>
        <item>
            <id>npc</id>
            <content>NPC 说: 3</content>
            <buttons>
                <button action="doaccept" label="我要接受任务"/>
                <button action="docancel" label="下次再说"/>
                <button action="gotonext" label="测试最后一页"/>
            </buttons>
        </item>
    </dialog>
to:
{
	{id = ",content = "", buttons = { action = "", label = ""},},
	{id = ",content = "", buttons = { action = "", label = ""},},
	{id = ",content = "", buttons = { action = "", label = ""},},
	{id = ",content = "", buttons = { action = "", label = ""},},
}
--]]
function QuestHelp.DialogXmlToTable(xmlnodes)
	local self = QuestHelp;
	if(not xmlnodes)then return end
	local result = {};
	for node in commonlib.XPath.eachNode(xmlnodes, "/dialog/item") do
		local k,v;
		local item = {};
		for k,v in ipairs(node) do
			local name = v.name;
			if(name ~= "buttons")then
				local value;
				--NOTE:id is number
				if(name == "id")then
					value = tonumber(v[1]);
				elseif(name == "content")then
					value = commonlib.Lua2XmlString(v);
				else
					value = v[1];
				end
				item[name] = value;
			else
				local buttons = {};
				item[name] = buttons;

				local kk,vv;
				for kk,vv in ipairs(v) do
					local t = vv.attr;
					table.insert(buttons,t);
				end
			end
		end
		table.insert(result,item);
	end
	return result;
end
--[[
	<ClientDialogNPC condition="0">
		<item id="10000" value="1">
		  <item><id></id><content>NPC 说: 1</content><buttons><button action="gotonext" label="按钮"/></buttons></item>
		  <item><id></id><content>NPC 说: 2</content><buttons><button action="gotonext" label="按钮"/></buttons></item>
		</item>
		<item id="10001" value="1">
		  <item><id></id><content>NPC 说: 1</content><buttons><button action="gotonext" label="按钮"/></buttons></item>
		  <item><id></id><content>NPC 说: 2</content><buttons><button action="gotonext" label="按钮"/></buttons></item>
		</item>
  </ClientDialogNPC>

	to:
	{
		condition = 0,
		{
			{ id = 10000, value = 1,{
					{id = nil, content = "", buttons = { action = "", label = ""},},
					{id = nil, content = "", buttons = { action = "", label = ""},},
					{id = nil, content = "", buttons = { action = "", label = ""},},
				}
			},
			{ id = 10001, value = 1,{
					{id = nil, content = "", buttons = { action = "", label = ""},},
					{id = nil, content = "", buttons = { action = "", label = ""},},
					{id = nil, content = "", buttons = { action = "", label = ""},},
				}
			},
		}
	}
--]]
function QuestHelp.ClientDialogNPC_XmlToTable(xmlnodes)
	local self = QuestHelp;
	if(not xmlnodes)then return end
	local result = {};
	local condition = tonumber(xmlnodes.attr.condition) or 0;
	result.condition = condition;
	local p_node;
	for p_node in commonlib.XPath.eachNode(xmlnodes, "/item") do
		local id = tonumber(p_node.attr.id);
		local value = tonumber(p_node.attr.value);
		local label = p_node.attr.label;
		local p_item = {
			id = id,
			value = value,
			label = label,
		}
		local kk,vv;
		for kk,vv in ipairs(p_node) do
			local node = vv;

			local k,v;
			local item = {};
			for k,v in ipairs(node) do
				local name = v.name;
				if(name ~= "buttons")then
					local value;
					--NOTE:id is number
					if(name == "id")then
						value = tonumber(v[1]);
					elseif(name == "content")then
						value = commonlib.Lua2XmlString(v);
					else
						value = v[1];
					end
					item[name] = value;
				else
					local buttons = {};
					item[name] = buttons;

					local kk,vv;
					for kk,vv in ipairs(v) do
						local t = vv.attr;
						table.insert(buttons,t);
					end
				end
			end
			table.insert(p_item,item);
		end
		table.insert(result,p_item);
	end
	return result;
end
--[[
 <items id="0" choice="-1">
      <item id="10000" value="1" />
      <item id="10001" value="1" />
      <item id="10002" value="1" />
    </items>
    <!--id:1 手工选择 choice:2 最多选择数量-->
    <items id="1" choice="2">
      <item id="10000" value="1" />
      <item id="10001" value="1" />
      <item id="10002" value="1" />
    </items>
to:
{
	{ 
		id = 0, choice = -1,
		{id = 10000, value = 1},
		{id = 10001, value = 1},
		{id = 10002, value = 1},
	},
	{ 
		id = 1, choice = 2,
		{id = 10000, value = 1},
		{id = 10001, value = 1},
		{id = 10002, value = 1},
	},
}
--]]
function QuestHelp.RewardXmlToTable(xmlnodes)
	local self = QuestHelp;
	if(not xmlnodes)then return end
	local result = {};
	for node in commonlib.XPath.eachNode(xmlnodes, "/items") do
		local k,v;
		local items = {};
		for k,v in ipairs(node) do
			local attr = v.attr;
			if(attr)then
				local id = tonumber(attr.id);
				local value = tonumber(attr.value);
				table.insert(items,{ id = id, value = value});
			end
			
		end
		local attr = node.attr;
		if(attr)then
			items.id = tonumber(attr.id);
			items.choice = tonumber(attr.choice);
			--默认只显示本系物品
			items.schoolfilter = tonumber(attr.schoolfilter) or 1;
		end
		table.insert(result,items);
	end
	return result;
end
--[[

 <item>
    <id>30191</id>
    <label>呼噜大叔</label>
    <desc>跳跳农场生机勃勃呀，瞧瞧我的西瓜、庄稼，今年可是要大丰收啦！</desc>
    <nativebuttons>
      <button label="鉴定西瓜种子" action="showpage" />
    </nativebuttons>
  </item>
  to:
  {
	id = id,
	label = label,
	desc = desc,
	nativebuttons = {
		{ label = "", action = "",},
	},
  }
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local path = "config/Aries/Quests/npc_list.xml";
local result,result_map = QuestHelp.NpcXmlFileToTable(path);
commonlib.echo(result);
commonlib.echo(result_map);
--]]
function QuestHelp.NpcXmlFileToTable(path)
	if(not path)then return end
	local self = QuestHelp;
	local xmlnodes = ParaXML.LuaXML_ParseFile(path);
	if(not xmlnodes) then 
		LOG.std(nil, "error", "QuestHelp", "file %s does not exist", path);
		return 
	end
	local result = {};
	local result_map = {};

	local my_region_id = MyCompany.Aries.ExternalUserModule:GetRegionID();
	local my_locale = System.options.locale;

	for node in commonlib.XPath.eachNode(xmlnodes, "/items/item") do
		local k,v;
		local item = {};
		local id;
		for k,v in ipairs(node) do
			local name = v.name;
			if(name ~= "nativebuttons")then
				local value = v[1];
				--NOTE:id is number
				if(name == "id")then
					value = tonumber(value);
					id = value;
				end
				item[name] = value;
			else
				local nativebuttons = {};
				item[name] = nativebuttons;

				local kk,vv;
				for kk,vv in ipairs(v) do
					local t = vv.attr;
					if( (not t.locale or t.locale== my_locale) and (not t.region or t.region== my_region_id) ) then
						table.insert(nativebuttons,t);
					end
				end
			end
		end
		table.insert(result,item);
		result_map[id] = item;
	end
	return result,result_map;
end
--[[
 <item>
      <id>40001</id>
      <label>火毛怪</label>
      <desc>火焰山洞</desc>
    </item>
	to:
	{id = "", label = "", desc = ""}
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local path = "config/Aries/Quests/goal_list.xml";
local result,result_map = QuestHelp.CommonConfigFileToTable(path);
commonlib.echo(result);
commonlib.echo(result_map);
--]]
function QuestHelp.CommonConfigFileToTable(path)
	local self = QuestHelp;
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", path);
	end
	local k,v;
	local result = {};
	local result_map = {};
	local nodes;
	for nodes in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
		local kk,node;
		local line = {};
		local id;
		for kk,node in ipairs(nodes) do
			local name = node.name;
			local value = node[1];
			if(name == "id")then
				value = tonumber(value);
				id = value;
			end
			line[name] = value;
		end
		table.insert(result,line);
		if(id)then
			result_map[id] = line;
		end
	end
	return result,result_map;
end
--[[
<items>
	<item>
		<id>60</id> 
		<name>测试_影响宠物爱心值</name> 
	</item>
</items>

to:
<items>
	<item>
		<id>60</id> 
		<label>测试_影响宠物爱心值</label> 
	</item>
</items>
  --]]
function QuestHelp.CommonConfigFileToTable_Reward(path)
	local self = QuestHelp;
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", path);
	end
	local k,v;
	local result = {};
	local result_map = {};
	local nodes;
	local value;
	if(load_version == "kids") then
		value = { id = 100, label = "奇豆",};
	else
		value = { id = 100, label = "银币",};
	end
	table.insert(result,value);
	result_map[100] = value;
	value = { id = 113, label = "战斗经验值",};
	table.insert(result,value);
	result_map[113] = value;

	for nodes in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
		local kk,node;
		local line = {};
		local id;
		for kk,node in ipairs(nodes) do
			local name = node.name;
			local value = node[1];
			if(name == "id")then
				value = tonumber(value);
				id = value;
			end
			if(name == "name")then
				name = "label";
			end
			line[name] = value;
		end
		table.insert(result,line);
		if(id)then
			result_map[id] = line;
		end
	end
	return result,result_map;
end
--混合custom_goal_list.xml 和 reward_list.xml
function QuestHelp.Combine_CustomGoal_And_Reward(custom_goal_path,reward_path)
	local result = {};
	local result_map = {};
	--custom_goal_list.xml
	local xmlRoot = ParaXML.LuaXML_ParseFile(custom_goal_path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", custom_goal_path);
	end
	local k,v;
	local nodes;
	for nodes in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
		local kk,node;
		local line = {};
		local id;
		local id_arr;
		local has_id_arr;
		for kk,node in ipairs(nodes) do
			local name = node.name;
			local value = node[1];
			if(name == "id")then
				id_arr = commonlib.split(value,",");
				if(id_arr and #id_arr > 1)then
					has_id_arr = true;		
				else
					value = tonumber(value);
					id = value;
				end
				
			elseif(name == "goalpointer")then
				value = node.attr;
			end

			line[name] = value;

		end
		if(has_id_arr)then
			local k,v;
			for k,v in ipairs(id_arr) do
				local id = tonumber(v);
				if(id)then
					local clone_line = commonlib.deepcopy(line);
					clone_line["id"] = id;
					table.insert(result,clone_line);
					result_map[id] = clone_line;
				end
			end
		else
			table.insert(result,line);
			if(id)then
				result_map[id] = line;
			end
		end
		
	end
	--reward_list.xml
	local xmlRoot = ParaXML.LuaXML_ParseFile(reward_path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", reward_path);
	end
	for nodes in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
		local kk,node;
		local line = {};
		local id;
		for kk,node in ipairs(nodes) do
			local name = node.name;
			local value = node[1];
			if(name == "id")then
				value = tonumber(value);
				id = value;
			end
			if(name == "name")then
				name = "label";
			end
			line[name] = value;
		end
		--优先显示custom_goal_list.xml里面的数据
		if(id)then
			if(not result_map[id])then
				table.insert(result,line);
				result_map[id] = line;
			else
				local temp = result_map[id];
				temp["label"] = line["label"]
			end
		end
	end
	return result,result_map;
end
--[[
  <item id="0" label="主线任务">
  <item>
      <id>0</id>
      <label>主线任务-开天辟地</label>
	 </item>
    <item>
      <id>1</id>
      <label>主线任务-开天辟地2</label>
    </item>
  </item>
  to:
  {
	{id = "", label = "",},
	{id = "", label = "",},
	id = "",
	label = "",
  }
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local path = "config/Aries/Quests/quest_types.xml";
local result,result_map = QuestHelp.QuestTypesXmlFileToTable(path);
commonlib.echo(result);
commonlib.echo(result_map);
--]]
function QuestHelp.QuestTypesXmlFileToTable(path)
	local self = QuestHelp;
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", path);
	end
	local result = {};
	local result_map = {};
	local parentnode;
	for parentnode in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
		local id = tonumber(parentnode.attr.id);
		local label = parentnode.attr.label;
		local childrens = {
			id = id,
			label = label,
		}
		
		local k,node;
		for k,node in ipairs(parentnode) do
			local kk,node_node;
			local line = {};
			for kk,node_node in ipairs(node) do
				local name = node_node.name;
				local value = node_node[1];
				if(name == "id")then
					value = tonumber(value);
				end
				line[name] = value;
			end
			table.insert(childrens,line);
		end
		
		table.insert(result,childrens);
		if(id)then
			result_map[id] = childrens;
		end
	end
	return result,result_map;
end

-- loaded template file.
local loaded_templates = {};

--@param path:任务配置路径
--@param is_debug:如果is_debug = true,会加载已经废除的任务
function QuestHelp.LoadAllQuests(path,is_debug)
	if(not path)then return end
	local template = loaded_templates[path];
	if(not template) then
		
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		if(not xmlRoot) then
			LOG.std(nil, "error", "QuestHelp", "file %s does not exist", path);
		else
			LOG.std(nil, "debug", "quest", "quest template:%s loaded", path);
		end
		local k,v;
		local data = {};
		local map = {};
		for node in commonlib.XPath.eachNode(xmlRoot, "/Quests/Quest") do
			local item = QuestHelp.ParseQuestBlock(node,is_debug)
			if(item)then
				table.insert(data,item);
				local id = item.Id;
				map[id] = item;
			end
		end
		template = {data, map}
		loaded_templates[path] = template;
	end
	return template[1], template[2];
end

function QuestHelp.CreateGraph(templateData,include_mirror)
	local self = QuestHelp;
	if(not templateData)then return end
	local graph = Graph:new{
	};
	local node_map = {};
	local arcs_map = {};
	local k,v;
	for k,v in ipairs(templateData) do
		local Id = tonumber(v.Id) or 0;
		local gNode = graph:AddNode();
		node_map[Id] = gNode;
		gNode.data = {
			templateData = v; --模板原始数据
		}
		local RequestQuest = v.RequestQuest;--前置任务
		if(RequestQuest)then
			
			local condition = RequestQuest.condition;
			--记录弧的对应
			function getArcs(condition)
				if(not condition)then return end
				local k,v;
				for k,v in ipairs(RequestQuest) do
					local target_id = v.id;
					local state = v.value;
					--弧的附加信息
					local arc_tag = {condition = condition,state = state};
					if(target_id)then
						local source_id = Id;
						local arcs = {source_id,target_id,arc_tag};
						table.insert(arcs_map,arcs);
					end
				end
			end
			--确认有前置任务
			-- 0 is and,1 ir or
			getArcs(condition);
			
		end
	end
	local k,v;
	for k,v in ipairs(arcs_map) do
		local source_id = v[1];
		local target_id = v[2];
		local arc_tag = v[3];
		if(source_id and target_id)then
			local source_node = node_map[source_id];
			local target_node = node_map[target_id];
			if(source_node and target_node)then
				graph:AddArc(source_node,target_node,arc_tag);
				if(include_mirror)then
					graph:AddArc(target_node,source_node,{is_mirror = true,});
				end
			end
		end
	end
	return graph,node_map;
end
function QuestHelp.SaveToDgml(graph,filepath,include_mirror,provider)
	if(not graph or not filepath)then return end
	local xml = QuestHelp.ToDgml(graph,include_mirror,provider);
	if(xml)then
		ParaIO.CreateDirectory(filepath);
		local file = ParaIO.open(filepath, "w");
		if(file:IsValid()) then
			file:WriteString(xml);
			file:close();
		end
	end
	_guihelper.MessageBox(string.format("生成成功:%s",filepath));
end
function QuestHelp.ToDgml(graph,include_mirror,provider)
	if(not graph)then return end
	function drawNodesArcs(gNode,output)
		if(not gNode or not output)then return end
		local str = "";
		local source_node = gNode;
		local source_data = source_node:GetData();

		if(source_data)then
			local templateData = source_data.templateData;--模板原始数据
			if(templateData)then
				local id = templateData["Id"] or -1;
				local title = templateData["Title"] or "";
				local Obsolesced = templateData["Obsolesced"];
				if(Obsolesced and Obsolesced == 1)then
					Obsolesced = "(已经废除)";
				else
					Obsolesced = "";
				end
				local line = "";
				--取消详细内容的显示
				--local k,v;
				--for k,v in pairs(templateData) do
					--if(type(v) == "table")then
						--v = commonlib.serialize_compact(v);
						--v = string.gsub(v,"\"","'");
					--else
						--v = tostring(v);
					--end
					--local s = string.format([[%s="%s" ]],k,v);
					--line = line .. s;
				--end
				line = string.format([[Id="%s" ]],id);
				local label = string.format("'%d %s %s'",id,title,Obsolesced);
				local category = "";
				local q_item = "";
				if(provider)then
					q_item = provider:GetQuest(id);
					q_item = commonlib.serialize_compact(q_item);
					q_item = string.gsub(q_item,"\"","'");
					local hasAccept = provider:HasAccept(id);
					local canAccept = provider:CanAccept(id);
					local canFinished = provider:CanFinished(id);
					local finished = provider:HasFinished(id);
					local isvalid = provider:IsValid(id);
					if(finished)then
						category = "user_hasfinished";
					elseif(hasAccept)then
						if(not isvalid)then
							category = "user_hasaccept_invalid";
						elseif(canFinished)then
							category = "user_hasaccept_canfinished";
						elseif(not canFinished)then
							category = "user_hasaccept_not_canfinished";
						end
					elseif(canAccept)then
						category = "user_canaccept";
					end
				end
				if(category and category ~= "")then
					category = string.format("Category='%s'",category);
				end
				if(q_item and q_item ~= "")then
					q_item = string.format("UserInfo='%s'",q_item);
				end
				line = string.format([[<Node %s  Label=%s %s %s/>]],line,label,category,q_item);
				output.NodesStr = output.NodesStr..line;
			end
		end

		local list = source_node.arcs;
		local arc = list:first();
		while (arc) do
			local target_node = arc:GetNode();
			local target_data = target_node:GetData();
			local arc_tag = arc:GetTag();--弧的额外信息
			local condition = "and";--默认是and
			local state = 1; --默认是完成任务
			if(arc_tag and arc_tag.condition)then
				condition = arc_tag.condition;
			end
			if(arc_tag and arc_tag.state)then
				state = arc_tag.state;
			end
			if(source_data and target_data)then
				local source_templateData = source_data["templateData"];
				local target_templateData = target_data["templateData"];
				if(source_templateData and target_templateData)then
					if(condition == 0)then
						condition = "and";
					elseif(condition == 1)then
						condition = "or";
					end
					if(state == 1)then
						state = "finished";
					elseif(state == 3)then
						state = "valid";
					end
					local c;
					if(arc_tag and arc_tag.is_mirror)then
						c = "mirror";
					else
						c = string.format("%s_%s",condition,state);
					end
					local s_id = source_templateData.Id or 0;
					local t_id = target_templateData.Id or 0;
					local s = string.format([[<Link Source="%d" Target="%d" Category="%s" />]],s_id,t_id,c);
					if(c == "mirror" and not include_mirror)then
						s = "";
					end
					str = str..s;
				end
			end
			arc = list:next(arc)
		end
		output.LinksStr = output.LinksStr..str;
	end
	local NodesStr = "";
	local LinksStr = "";
	local PropertiesStr = "";
	local node;
	local temp_node;
	for node in graph:Next() do
		if(node)then
			local output = { NodesStr = "", LinksStr = "",};
			GraphHelp.DepathFirst(node,drawNodesArcs,output);
			NodesStr = NodesStr..output.NodesStr;
			LinksStr = LinksStr..output.LinksStr;
			if(not temp_node)then
				temp_node = node;
			end
		end
	end
	if(temp_node)then
		local source_data = temp_node:GetData();
		if(source_data)then
			local source_templateData = source_data["templateData"];
			if(source_templateData)then
				local k,v;
				for k,v in pairs(source_templateData) do
					local s = string.format([[<Property Id="%s" Label="%s" DataType="System.String" />]],k,k);
					PropertiesStr = PropertiesStr..s;
				end
			end
		end
	end	
	return QuestHelp.ReplaceStr(NodesStr,LinksStr,PropertiesStr);
end
function QuestHelp.ReplaceStr(NodesStr,LinksStr,PropertiesStr)
	local xml = string.format([[<?xml version="1.0" encoding="utf-8"?>
<DirectedGraph GraphDirection="BottomToTop" Layout="Sugiyama" xmlns="http://schemas.microsoft.com/vs/2009/dgml">
  <Nodes>
    %s
  </Nodes>
  <Links>
   %s
  </Links>
  <Categories>
    <Category Id="mirror" />
    <Category Id="and_finished" Label="and_finished" />
    <Category Id="and_valid" Label="and_valid" />
    <Category Id="or_finished" Label="or_finished" />
    <Category Id="or_valid" Label="or_valid" />
    <Category Id="Quest" Label="Quest" />
  </Categories>
  <Properties>
    <Property Id="GraphDirection" DataType="Microsoft.VisualStudio.Progression.Layout.GraphDirection" />
    <Property Id="Layout" DataType="System.String" />
    <Property Id="UserInfo" Label="UserInfo" DataType="System.String" />
	%s
  </Properties>
   <Styles>
    <Style TargetType="Node" GroupLabel="已经接受 并且可以完成" ValueLabel="Has category">
      <Condition Expression="HasCategory('user_hasaccept_canfinished')" />
      <Setter Property="Background" Value="#FFFFFF00" />
    </Style>
    <Style TargetType="Node" GroupLabel="已经接受 但没有完成" ValueLabel="Has category">
      <Condition Expression="HasCategory('user_hasaccept_not_canfinished')" />
      <Setter Property="Background" Value="#abdcff" />
    </Style>
    <Style TargetType="Node" GroupLabel="可以接受的" ValueLabel="Has category">
      <Condition Expression="HasCategory('user_canaccept')" />
      <Setter Property="Background" Value="#83c83c" />
    </Style>
    <Style TargetType="Node" GroupLabel="已经接受 但失效的" ValueLabel="Has category">
      <Condition Expression="HasCategory('user_hasaccept_invalid')" />
      <Setter Property="Background" Value="#00b4b4" />
    </Style>
    <Style TargetType="Node" GroupLabel="已经完成" ValueLabel="Has category">
      <Condition Expression="HasCategory('user_hasfinished')" />
      <Setter Property="Background" Value="#3d342e" />
    </Style>
   <Style TargetType="Link" GroupLabel="mirror" ValueLabel="Has category">
      <Condition Expression="HasCategory('mirror')" />
      <Setter Property="Stroke" Value="#FFFFFF00" />
    </Style>
    <Style TargetType="Link" GroupLabel="红色实线 完成and" ValueLabel="Has category">
      <Condition Expression="HasCategory('and_finished')" />
      <Setter Property="Stroke" Value="#FFFF0000" />
    </Style>
    <Style TargetType="Link" GroupLabel="红色虚线 完成or" ValueLabel="Has category">
      <Condition Expression="HasCategory('or_finished')" />
      <Setter Property="Stroke" Value="#FFFF0000" />
      <Setter Property="StrokeDashArray" Value="3 3" />
    </Style>
    <Style TargetType="Link" GroupLabel="紫色实线 激活and" ValueLabel="Has category">
      <Condition Expression="HasCategory('and_valid')" />
      <Setter Property="Stroke" Value="#FF400080" />
    </Style>
    <Style TargetType="Link" GroupLabel="紫色虚线 激活or" ValueLabel="Has category">
      <Condition Expression="HasCategory('or_valid')" />
      <Setter Property="Stroke" Value="#FF400080" />
      <Setter Property="StrokeDashArray" Value="3 3" />
    </Style>
  </Styles>
</DirectedGraph>
]],NodesStr or "",LinksStr or "",PropertiesStr or "");
	return xml;
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	local input = {
		a = 10,
		b = "|",
		c = ",",
	}
input = QuestHelp.SerializeTable(input);
commonlib.echo(input);
input = QuestHelp.DeSerializeTable(input);
commonlib.echo(input);
--]]
function QuestHelp.SerializeTable(input)
	local self = QuestHelp;
	if(not input or type(input) ~= "table")then
		return
	end
	input = commonlib.serialize_compact(input);
	input = string.gsub(input,",","@");
	input = string.gsub(input,"|","#");
	input = string.gsub(input,"~","*");
	return input;
end
function QuestHelp.DeSerializeTable(input)
	local self = QuestHelp;
	if(not input or type(input) ~= "string")then
		return
	end
	if(input == "")then
		return
	end
	input = string.gsub(input,"@",",");
	input = string.gsub(input,"#","|");
	input = string.gsub(input,"*","~");
	input = commonlib.LoadTableFromString(input);
	return input;
end
--合并所有世界中的npc list
function QuestHelp.BuildNpcListXml()
	local self = QuestHelp;
	local result = {};
	local result_map = {};
	local worlds_list = QuestHelp.GetWorldList();
	if(not worlds_list)then return end
	local my_region_id = MyCompany.Aries.ExternalUserModule:GetRegionID();
	local my_locale = System.options.locale;

	local function get_item(node,npc_id)
		if(not node)then return end
		local k,v;
		local item = {};
		local id;
		for k,v in ipairs(node) do
			local name = v.name;
			if(name ~= "nativebuttons")then
				local value = v[1];
				--NOTE:id is number
				if(name == "id")then
					value = tonumber(value);
					id = value;
				end
				item[name] = value;
			else
				local nativebuttons = {};
				item[name] = nativebuttons;

				for kk,vv in ipairs(v) do
					local t = vv.attr;
					for page_node in commonlib.XPath.eachNode(vv, "/page") do
						local page_index = tonumber(page_node.attr.index);
						local page_item = {};
						page_item["content"] = page_node[1];
						page_item["id"] = npc_id;
						page_item["buttons"] = {};
						table.insert(page_item["buttons"],{label = "下一步", action = "gotonext"});
						t[page_index] = page_item;
					end
					if(#t > 0) then
						t[#t]["buttons"][1]["action"] = "gofirstpage";
						t[#t]["buttons"][1]["label"] = "再了解下别的物品";
						t["action"] = "thingsinfo";
					end
					if( (not t.locale or t.locale== my_locale) and (not t.region or t.region== my_region_id) ) then
						table.insert(nativebuttons,t);
					end
				end
			end
		end
		return item;
	end
	
	local function get_gossip_item(node)
		if(not node) then
			return;
		end
		local locale = System.options.locale;
		local k, v;
		local item = {
			last_hello_index = nil,
			last_goodbye_index = nil,
			hellos = {},
			goodbyes = {},
		};
		local word_node;
		for word_node in commonlib.XPath.eachNode(node, "/hello/word") do
			local each_hello = {
				text = word_node.attr.text,
				sound = word_node.attr.sound, 
			};
			if(locale ~= "zhCN") then
				each_hello.sound = nil;
			end
			table.insert(item.hellos, each_hello);
		end
		for word_node in commonlib.XPath.eachNode(node, "/goodbye/word") do
			local each_goodbye = {
				text = word_node.attr.text,
				sound = word_node.attr.sound, 
			};
			if(locale ~= "zhCN") then
				each_goodbye.sound = nil;
			end
			table.insert(item.goodbyes, each_goodbye);
		end
		return item;
	end

	local first_item = {
		id = -1,
		label = "自己",
	}
	table.insert(result,first_item);
	result_map[-1] = first_item;
	
	for k,world_node in ipairs(worlds_list) do
		local input_path = world_node.npcfile or "";
		local world_num = world_node.id or 0;--世界编号
		local node;
		-- LOG.std(nil, "info", "QuestHelp", "about to open file %s", input_path);
		local xmlRoot = input_path~="" and ParaXML.LuaXML_ParseFile(input_path);
		if(not xmlRoot and input_path~="") then
			LOG.std(nil, "error", "QuestHelp", "file %s does not exist", input_path);
		end

		for node in commonlib.XPath.eachNode(xmlRoot, "/NPCList/NPC/") do
			if(node.attr)then
				local item = {};
				local gossip_item = {};
				local name = node.attr.name;
				local npc_id = tonumber(node.attr.npc_id);
				local node_ex;
				for node_ex in commonlib.XPath.eachNode(node, "/item_ex") do
					item = get_item(node_ex,npc_id) or {};
					break;
				end
				local node_gossip;
				for node_gossip in commonlib.XPath.eachNode(node, "/gossip") do
					gossip_item = get_gossip_item(node_gossip) or {};
					item.gossip_item = gossip_item;
					break;
				end
				if(npc_id)then
					item.id = npc_id;
					item.label = name;
					item.world = world_num;
					table.insert(result,item);
					--同一个npc_id有可能在多个世界中存在
					result_map[npc_id] = item;
				else
					
				end
			end
		end
	end
	return result,result_map;
end

-- say hello to npc with text bubble and sound
-- @param npc_id: npc id
function QuestHelp.SayHelloToNPC(npc_id)
	local npc_list, npc_list_map = QuestHelp.GetNpcList();
	if(npc_list_map) then
		local value = npc_list_map[npc_id];
		if(value and value.gossip_item) then
			local gossip_item = value.gossip_item

			gossip_item.last_hello_index = gossip_item.last_hello_index or 0;
			gossip_item.last_hello_index = gossip_item.last_hello_index + 1;

			local this_hello = gossip_item.hellos[gossip_item.last_hello_index];
			if(not this_hello) then
				gossip_item.last_hello_index = 1;
				this_hello = gossip_item.hellos[gossip_item.last_hello_index];
			end
			
			if(this_hello) then
				if(this_hello.text) then
					local npcChar = NPC.GetNpcCharacterFromIDAndInstance(npc_id);
					if(npcChar and npcChar:IsValid() == true) then
						headon_speech.Speek(npcChar.name, this_hello.text, 3);
					end
				end
				if(this_hello.sound) then
					QuestHelp.audio_src_hello = AudioEngine.CreateGet(this_hello.sound)
					QuestHelp.audio_src_hello.file = this_hello.sound;
					QuestHelp.audio_src_hello:play(); -- then play with default. 

					if(QuestHelp.audio_src_goodbye) then
						QuestHelp.audio_src_goodbye:release(); -- stop goodbye
					end
				end
			end
		end
	end
end

-- say goodbye to npc with text bubble and sound
-- @param npc_id: npc id
function QuestHelp.SayGoodbyeToNPC(npc_id)
	local npc_list, npc_list_map = QuestHelp.GetNpcList();
	if(npc_list_map) then
		local value = npc_list_map[npc_id];
		if(value and value.gossip_item) then
			local gossip_item = value.gossip_item

			gossip_item.last_goodbye_index = gossip_item.last_goodbye_index or 0;
			gossip_item.last_goodbye_index = gossip_item.last_goodbye_index + 1;

			local this_goodbye = gossip_item.goodbyes[gossip_item.last_goodbye_index];
			if(not this_goodbye) then
				gossip_item.last_goodbye_index = 1;
				this_goodbye = gossip_item.goodbyes[gossip_item.last_goodbye_index];
			end
			
			if(this_goodbye) then
				if(this_goodbye.text) then
					local npcChar = NPC.GetNpcCharacterFromIDAndInstance(npc_id);
					if(npcChar and npcChar:IsValid() == true) then
						headon_speech.Speek(npcChar.name, this_goodbye.text, 3);
					end
				end
				if(this_goodbye.sound) then
					QuestHelp.audio_src_goodbye = AudioEngine.CreateGet(this_goodbye.sound)
					QuestHelp.audio_src_goodbye.file = this_goodbye.sound;
					QuestHelp.audio_src_goodbye:play(); -- then play with default. 

					if(QuestHelp.audio_src_hello) then
						QuestHelp.audio_src_hello:release(); -- stop hello
					end
				end
			end
		end
	end
end

--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.is_kids_version = false;--teen
QuestHelp.BuildNpcListXml_OutPut();
--]]
--合并所有的npc file 并且生成npc_list_output.xml 
function QuestHelp.BuildNpcListXml_OutPut(output_path)
	local self = QuestHelp;
	local list = self.BuildNpcListXml();
	if(not list)then return end
	if(QuestHelp.IsKidsVersion()) then
		output_path = output_path or "config/Aries/Quests/npc_list_output.xml";
	else
		output_path = output_path or "config/Aries/Quests_Teen/npc_list_output.xml";
	end
	function toxmlstr(nativebuttons)
		if(not nativebuttons)then return end
		local all_str = "";
		local k,v;
		for k,v in ipairs(nativebuttons) do
			local str = "";
			for kk,vv in pairs(v) do
				local s = string.format([[%s="%s" ]],tostring(kk),tostring(vv));
				str = str .. s;
			end
			str = string.format([[<button %s />]],str);
			all_str = all_str .. str;
		end
		return all_str;
	end
	local out_put_str = "";
	local k,node;
	for k,node in ipairs(list) do
		local id = tonumber(node.id) or -1;
		local label = node.label or "";
		local desc = node.desc or "";
		local place = node.place or "";
		local world = node.world or 0;
		local nativebuttons = toxmlstr(node.nativebuttons) or "";
		local s = string.format("<item><id>%d</id><label>%s</label><desc>%s</desc><nativebuttons>%s</nativebuttons><place>%s</place><world>%d</world></item>",id,label,desc,nativebuttons,place,world);
		out_put_str = out_put_str .. s;
	end
	out_put_str = string.format("<!--这是个只读文件 由程序自动生成--><items>%s</items>",out_put_str);
	if(not ParaIO.DoesFileExist("output_path")) then
		ParaIO.CreateNewFile("output_path");
	end
	ParaIO.CreateDirectory(output_path);
	local file = ParaIO.open(output_path, "w");
	if(file:IsValid()) then
		file:WriteString(out_put_str);
		file:close();
	end
	_guihelper.MessageBox("生成成功："..output_path);
end
--读取 reward_list_common_info.xml 和 装备 技能，生成奖励列表
function QuestHelp.BuildRewardListXml(output_path)
	local self = QuestHelp;
	local common_info_path;
	if(QuestHelp.IsKidsVersion()) then
		common_info_path = "config/Aries/Quests/reward_list_common_info.xml";
	else
		common_info_path = "config/Aries/Quests_Teen/reward_list_common_info.xml";
	end
	local common_info_str = "";
	local file = ParaIO.open(common_info_path, "r");
	if(file:IsValid()) then
		common_info_str = file:GetText();
		file:close();
	end
	if(common_info_str)then
		common_info_str = string.match(common_info_str,"<items>(.+)</items>");
	end
	if(QuestHelp.IsKidsVersion()) then
		output_path = output_path or "config/Aries/Quests/reward_list_output.xml";
	else
		output_path = output_path or "config/Aries/Quests_Teen/reward_list_output.xml";
	end
	local ids = {
		{ start_index = 1001, end_index = 8999 },
		{ start_index = 17144, end_index = 17999 },
		{ start_index = 22101, end_index = 22999 },
		{ start_index = 24001, end_index = 24999 },
		{ start_index = 26001, end_index = 26999 },
		{ start_index = 41101, end_index = 41999 },
		{ start_index = 42101, end_index = 42999 },
		{ start_index = 43101, end_index = 43999 },
		{ start_index = 44101, end_index = 44999 },
	}
	local all_str = "";
	for k,v in ipairs(ids)do
		local start_index,end_index = v.start_index,v.end_index;
		local i;
		for i = start_index,end_index do
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(i);
			if(gsItem and gsItem.template) then
				local gsid = i;
				local name = gsItem.template.name;
				local s = string.format("<item><id>%d</id><label>%s</label><desc/></item>",gsid,name);
				all_str = all_str .. s;
			end
		end
	end
	all_str = string.format("<items>%s%s</items>",common_info_str or "",all_str);
	ParaIO.CreateDirectory(output_path);
	local file = ParaIO.open(output_path, "w");
	if(file:IsValid()) then
		file:WriteString(all_str);
		file:close();
	end
	_guihelper.MessageBox("生成成功："..output_path);
end
--生成勇者之龙的数据
function QuestHelp.GetHeroDragonData()
	local self = QuestHelp;
	local input_path;	
	if(QuestHelp.IsKidsVersion()) then
		input_path = "config/Aries/Quests/goal_list.xml";	
	else
		input_path = "config/Aries/Quests_Teen/goal_list.xml";	
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(input_path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", input_path);
	end
	local list;
	local result = {};
	for list in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
		local k,v;
		local node = {};
		local enabled;
		for k,v in ipairs(list) do
			local name = v.name;
			local value = v[1];
			if(name == "id")then
				value = tonumber(value);
				node["id"] = value;
			end
			if(name == "world")then
				value = tonumber(value);
				node["world"] = value;
			end
			if(name == "level")then
				value = tonumber(value);
				if(value == -1)then
					node["isBoss"] = true;
				end
				node["level"] = value;
			end
			if(name == "enabled")then
				value = tonumber(value);
				if(value == 1)then
					enabled = true;
				end
			end
			if(name == "path")then
				node["type"] = value;--change path to type
			end
			if(name == "label" or name == "place")then
				node[name] = value;
			end
		end
		if(enabled)then
			table.insert(result,node);
		end
	end
	return result;
end
--生成怪名称的映射
--根据儿童版 或者 青年版生成怪物映射
function QuestHelp.BuildMobMap(is_teen_version)
	local self = QuestHelp;
	local input_path;
	--if(not is_teen_version) then
		--input_path = "config/Aries/Quests/goal_list.xml";	
	--else
		--input_path = "config/Aries/Quests_Teen/goal_list.xml";	
	--end
	--local list,id_map = QuestHelp.CommonConfigFileToTable(input_path)
	if(not is_teen_version) then
		input_path = "config/Aries/Quests/goal_list_excel.xml";	
	else
		input_path = "config/Aries/Quests_Teen/goal_list_excel.teen.xml";	
	end
	local list,id_map = QuestHelp.LoadGoalListFromExcel(input_path)
	local path_map = {};
	local k,v;
	if(list)then
		for k,v in ipairs(list) do
			local path = v.path;
			if(path)then
				path = string.lower(path);
				path_map[path] = v;
			end
		end
	end
	return path_map;
end
function QuestHelp.InSameWorldByKey(worldname)
	local self = QuestHelp;
    if(worldname)then
		local world_info = WorldManager:GetCurrentWorld()
		if(world_info.name == worldname)then
			return true;
		end
    end
end
function QuestHelp.InSameWorldByNum(world_num)
	local self = QuestHelp;
	world_num = tonumber(world_num);
	if(not world_num)then return end
    local worldname = QuestHelp.WorldNumToWorldName(world_num);
	return self.InSameWorldByKey(worldname);
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local result,result_map_id,result_map_desc = QuestHelp.GetWorldList();
commonlib.echo(result);
--]]
--获取世界对应的编号
function QuestHelp.GetWorldList()
	local self = QuestHelp;
	local input_path;
	if(QuestHelp.IsKidsVersion()) then
		input_path = "config/Aries/Quests/worlds_list.xml";
	else
		input_path = "config/Aries/Quests_Teen/worlds_list.xml";
	end
	if(self.world_list and self.world_map_id and self.world_map_desc)then
		return self.world_list ,self.world_map_id ,self.world_map_desc;
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(input_path);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "QuestHelp", "file %s does not exist", input_path);
	end
	local list;
	local result = {};
	local result_map_id = {};
	local result_map_desc = {};
	for list in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
	local k,v;
		local node = {};
		local id;
		local desc;
		for k,v in ipairs(list) do
			local name = v.name;
			local value = v[1];
			if(name == "id")then
				if(value)then
					value = tonumber(value);
				end
				id = value;
				node["id"] = id;
			else
				if(name == "desc")then
					--转换为小写
					if(value)then
						value = string.lower(value);
					end
					desc = value;
				end
				node[name] = value;
			end
		end
		if(id)then
			result_map_id[id] = node;
		end
		if(desc)then
			result_map_desc[desc] = node;
		end
		table.insert(result,node);
	end
	self.world_list = result;
	self.world_map_id = result_map_id;
	self.world_map_desc = result_map_desc;
	return result,result_map_id,result_map_desc;
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local position = "20413.36,19996.89,20104.87|15.00,0.52,1.71#20413.36,19996.89,20104.87|15.00,0.52,1.71";
local all_info = QuestHelp.GetPosAndCameraFromString(position);
commonlib.echo(all_info);

return all_info = {
	{pos  = {x,y,z}, camera = {x,y,z}},
	{pos  = {x,y,z}, camera = {x,y,z}},
	{pos  = {x,y,z}, camera = {x,y,z}},
	{pos  = {x,y,z}, camera = {x,y,z}},
}
--]]
function QuestHelp.GetPosAndCameraFromString(position)
	if(not position)then return end
	local all_info = {};
	function get_item(pos)
		if(not pos)then return end
		local x,y,z,camera_x,camera_y,camera_z;
		if(string.find(pos,"|"))then
			x,y,z,camera_x,camera_y,camera_z = string.match(pos,"(.+),(.+),(.+)|(.+),(.+),(.+)")
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
			camera_x = tonumber(camera_x);
			camera_y = tonumber(camera_y);
			camera_z = tonumber(camera_z);

			if(x and camera_x)then
				return {x,y,z},{camera_x,camera_y,camera_z};
			end
		else
			x,y,z= string.match(pos,"(.+),(.+),(.+)")
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
			camera_x,camera_y,camera_z = 8.70, 0.27, 3;
			if(x and camera_x)then
				return {x,y,z},{camera_x,camera_y,camera_z};
			end
		end
	end

    if(string.find(position,"#"))then
		local pos;
		for pos in string.gfind(position,"([^#]+)") do
			local pos_info,camera_info = get_item(pos);
			if(pos_info and camera_info)then
				table.insert(all_info,{pos  = pos_info, camera = camera_info});
			end
		end
	else
		local pos_info,camera_info = get_item(position);
		if(pos_info and camera_info)then
			table.insert(all_info,{pos  = pos_info, camera = camera_info});
		end
	end
	return all_info;
end
--------------------------------------------------------------------
--load quest xml files
--------------------------------------------------------------------
function QuestHelp.LoadAllXmlFiles(load_version)
	local self = QuestHelp;
	load_version = load_version or "kids";
	if(not self.load_xml_files)then
		self.load_xml_files = true;
		if(load_version == "kids") then
			self.quest_types,self.quest_types_map = QuestHelp.QuestTypesXmlFileToTable("config/Aries/Quests/quest_types.xml");
			self.npc_list,self.npc_list_map = QuestHelp.BuildNpcListXml();
			self.attr_list,self.attr_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests/attr_list.xml");
			--self.goal_list,self.goal_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests/goal_list.xml");
			--加载excel格式
			self.goal_list,self.goal_list_map = QuestHelp.LoadGoalListFromExcel("config/Aries/Quests/goal_list_excel.xml");
			self.quest_item_list,self.quest_item_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests/quest_item_list.xml");
			self.client_item_list,self.client_item_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests/client_item_list.xml");
			self.client_exchange_item_list,self.client_exchange_item_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests/client_exchange_item_list.xml");
			self.flash_game_list,self.flash_game_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests/flash_game_list.xml");
			self.custom_goal_list,self.custom_goal_list_map = QuestHelp.Combine_CustomGoal_And_Reward("config/Aries/Quests/custom_goal_list.xml","config/Aries/Quests/reward_list.xml");
			--和custom_goal_list不一致 奇豆编号不一致 奖励里面为100 物品gsid认为是0
			self.reward_list,self.reward_list_map = QuestHelp.CommonConfigFileToTable_Reward("config/Aries/Quests/reward_list.xml");
		else
			self.quest_types,self.quest_types_map = QuestHelp.QuestTypesXmlFileToTable("config/Aries/Quests_Teen/quest_types.xml");
			self.npc_list,self.npc_list_map = QuestHelp.BuildNpcListXml();
			self.attr_list,self.attr_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests_Teen/attr_list.xml");
			--self.goal_list,self.goal_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests_Teen/goal_list.xml");
			--加载excel格式
			self.goal_list,self.goal_list_map = QuestHelp.LoadGoalListFromExcel("config/Aries/Quests_Teen/goal_list_excel.teen.xml");
			self.quest_item_list,self.quest_item_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests_Teen/quest_item_list.xml");
			--青年版用新的物品收集系统
			local map,quest_used_list,quest_used_map = GathererCommon.LoadTemplate();
			self.client_item_list,self.client_item_list_map = quest_used_list,quest_used_map;
			--self.client_item_list,self.client_item_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests_Teen/client_item_list.xml");
			
			self.client_exchange_item_list,self.client_exchange_item_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests_Teen/client_exchange_item_list.xml");
			self.flash_game_list,self.flash_game_list_map = QuestHelp.CommonConfigFileToTable("config/Aries/Quests_Teen/flash_game_list.xml");
			self.custom_goal_list,self.custom_goal_list_map = QuestHelp.Combine_CustomGoal_And_Reward("config/Aries/Quests_Teen/custom_goal_list.xml","config/Aries/Quests_Teen/reward_list.xml");

			--和custom_goal_list不一致 奇豆编号不一致 奖励里面为100 物品gsid认为是0
			self.reward_list,self.reward_list_map = QuestHelp.CommonConfigFileToTable_Reward("config/Aries/Quests_Teen/reward_list.xml");
		end
	end
end
function QuestHelp.IsServerID(id)
	local self = QuestHelp;
	if(not id)then return end
	--兼容儿童版客户端兑换任务类型 因为兑换成功的物品 和 真实物品id有重叠 QuestHelp.GetCustomGoalList()
	--所以优先判断QuestHelp.GetClientExchangeItemList()
	local __,map = QuestHelp.GetClientExchangeItemList();
	if(map and map[id])then
		return;
	end
	--npcid 人物是客户端目标
	--NOTE:npcid和物品id有重叠，所以先判断是否是npc
	local __,map = QuestHelp.GetNpcList();
	if(map and map[id])then
		return;
	end
	local __,map = QuestHelp.GetGoalList();
	if(map and map[id])then
		return true;
	end
	local __,map = QuestHelp.GetQuestItemList();
	if(map and map[id])then
		return true;
	end
	local __,map = QuestHelp.GetCustomGoalList();
	if(map and map[id])then
		local item = map[id];
		if(not item.isclient or item.isclient == "" or item.isclient == "false" or item.isclient == "False")then
			return true;
		end
	end
end
function QuestHelp.GetQuestTypesList()
	local self = QuestHelp;
	return self.quest_types,self.quest_types_map;
end
--NOTE:同一个npc_id 可能在多个世界中存在，所以self.npc_list_map有可能并不准确
--建议使用self.npc_list
function QuestHelp.GetNpcList()
	local self = QuestHelp;
	return self.npc_list,self.npc_list_map;
end
function QuestHelp.GetGoalList()
	local self = QuestHelp;
	return self.goal_list,self.goal_list_map;
end
function QuestHelp.GetQuestItemList()
	local self = QuestHelp;
	return self.quest_item_list,self.quest_item_list_map;
end
function QuestHelp.GetRewardList()
	local self = QuestHelp;
	return self.reward_list,self.reward_list_map;
end
function QuestHelp.GetAttrList()
	local self = QuestHelp;
	return self.attr_list,self.attr_list_map;
end
function QuestHelp.GetClientItemList()
	local self = QuestHelp;
	return self.client_item_list,self.client_item_list_map;
end
function QuestHelp.GetClientExchangeItemList()
	local self = QuestHelp;
	return self.client_exchange_item_list,self.client_exchange_item_list_map;
end
function QuestHelp.GetFlashGameList()
	local self = QuestHelp;
	return self.flash_game_list,self.flash_game_list_map;
end
function QuestHelp.GetCustomGoalList()
	local self = QuestHelp;
	return self.custom_goal_list,self.custom_goal_list_map;
end
function QuestHelp.GetTemplates()
	local self = QuestHelp;
	if(not self.load_template)then
		self.load_template = true;
		local path;
		if(QuestHelp.IsKidsVersion()) then
			path = "config/Aries/Quests/quest_list.xml";
			--时间模板
			QuestTimeStamp.Load("config/Aries/Quests/time_stamp.xml");

			--周长任务
			QuestWeekRepeat.Load("config/Aries/Quests/week_repeat.xml");
		else
			path = "config/Aries/Quests_Teen/quest_list.xml";
			--时间模板
			QuestTimeStamp.Load("config/Aries/Quests_Teen/time_stamp.xml");

			--周长任务
			QuestWeekRepeat.Load("config/Aries/Quests_Teen/week_repeat.xml");
		end
		local data,map = QuestHelp.LoadAllQuests(path);
		self.template_quests = map;
	end
	return self.template_quests;
end
--查找某个任务相关物品的具体描述 只读
--[[
	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	local itemid=30341;
	local item_desc = QuestHelp.GetQuestItemDescription(itemid);
	commonlib.echo(item_desc);

	npc 30341 return:{nativebuttons={{npcid="30341",label="创建家族",},{loadfile="script/apps/Aries/NPCs/TownSquare/30342_HaqiGroupJoin.lua",dofunction="MyCompany.Aries.Quest.NPCs.HaqiGroupJoin.PreDialog()",label="加入家族",},{loadfile="script/apps/Aries/Creator/CreateOpenWorld.lua",dofunction="MyCompany.Aries.Creator.CreateOpenWorld.ShowPage()",label="创意空间",},},label="拉拉",id=30341,world=0,desc="请哈奇们团结起来，让我们一起把黑暗魔法赶走吧！",}
	mob 40001 return:{enabled="1",path="config/Aries/Mob/MobTemplate_BlazeHairMonster.xml",place="火焰山洞",label="火毛怪",id=40001,level="10",position="20413.36,19996.89,20104.87|15.00,0.52,1.71",world="0",}
	custom goal 79101 return:{id=79101,world="0",position="20092.80,0.44,19631.16|15.00,0.30,-0.74",label="试炼徽章",}
--]]
function QuestHelp.GetQuestItemDescription(itemid)
	local self = QuestHelp;
	if(not itemid)then return end
	local __,_map = QuestHelp.GetGoalList();
	if(_map[itemid])then
		return _map[itemid];
	end
	__,_map = QuestHelp.GetQuestItemList();
	if(_map[itemid])then
		return _map[itemid];
	end
	__,_map = QuestHelp.GetNpcList();
	if(_map[itemid])then
		return _map[itemid];
	end
	__,_map = QuestHelp.GetClientItemList();
	if(_map[itemid])then
		return _map[itemid];
	end
	__,_map = QuestHelp.GetClientExchangeItemList();
	if(_map[itemid])then
		return _map[itemid];
	end
	__,_map = QuestHelp.GetFlashGameList();
	if(_map[itemid])then
		return _map[itemid];
	end
	
	__,_map = QuestHelp.GetCustomGoalList();
	if(_map[itemid])then
		return _map[itemid];
	end
end
--获取任务目标的最大值
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local questid=60085;--找人
QuestHelp.GetGoalValue(questid,30398);
QuestHelp.GetGoalValue(questid,30399);
local questid=60180;--goal
QuestHelp.GetGoalValue(questid,40044);
local questid=60181;--goal item
QuestHelp.GetGoalValue(questid,70027);
--]]
function QuestHelp.GetGoalValue(questid,goalid)
	local self = QuestHelp;
	if(not questid or not goalid)then return end
	local template_quests = QuestHelp.GetTemplates();
	local function has_value(t)
		if(type(t) == "table")then
			local len = #t;
			if(len > 0)then
				return true;
			end
		end
	end
	local function get_value(list,goalid)
		if(not list or not goalid)then return end
		local k,v;
		for k,v in ipairs(list) do
			local id = v.id;
			local value = v.value;
			if(goalid == id)then
				return value;
			end
		end
	end
	local template = template_quests[questid];
	if(template)then
		local Goal = template.Goal;
		local GoalItem = template.GoalItem;
		local ClientGoalItem = template.ClientGoalItem;
		local ClientExchangeItem = template.ClientExchangeItem;
		local FlashGame = template.FlashGame;
		local ClientDialogNPC = template.ClientDialogNPC;
		local CustomGoal = template.CustomGoal;
		local value;
		if(has_value(Goal))then
			value = get_value(Goal,goalid);
		end
		if(has_value(GoalItem))then
			value = get_value(GoalItem,goalid);
		end
		if(has_value(ClientGoalItem))then
			value = get_value(ClientGoalItem,goalid);
		end
		if(has_value(ClientExchangeItem))then
			value = get_value(ClientExchangeItem,goalid);
		end
		if(has_value(FlashGame))then
			value = get_value(FlashGame,goalid);
		end
		if(has_value(ClientDialogNPC))then
			value = get_value(ClientDialogNPC,goalid);
		end
		if(has_value(CustomGoal))then
			value = get_value(CustomGoal,goalid);
		end
		return value;
	end
end

-- get world info by world number id
function QuestHelp.GetWorldInfoByNum(world)
	local worldname = QuestHelp.WorldNumToWorldName(world)
	if(worldname) then
		return WorldManager:GetWorldInfo(worldname);
	end
end


--根据世界编号返回worldname
function QuestHelp.WorldNumToWorldName(world)
	local map;
	world = tonumber(world);
	if(QuestHelp.IsKidsVersion())then
		map = {
			[0] = "61HaqiTown",
			[1] = "FlamingPhoenixIsland",
			[2] = "FrostRoarIsland",
			[3] = "HaqiTown_FireCavern",
			[4] = "FlamingPhoenixIsland_TheGreatTree",
			[5] = "AncientEgyptIsland",
			[6] = "DarkForestIsland",--死亡岛
		}
	else
		map = {
			[0] = "61HaqiTown_teen",--彩虹岛
			[1] = "FlamingPhoenixIsland",--火鸟岛
			[2] = "FrostRoarIsland",--寒冰岛
			[3] = "HaqiTown_FireCavern",
			[4] = "FlamingPhoenixIsland_TheGreatTree",
			[5] = "AncientEgyptIsland",--沙漠岛
			[6] = "DarkForestIsland",--死亡岛
			[7] = "CloudFortressIsland",--云海秘境
		}
	end
	return map[world];
end
function QuestHelp.WorldNameToWorldNum(worldname)
	if(not worldname)then return end
	local map;
	if(QuestHelp.IsKidsVersion())then
		map = {
			["61HaqiTown"] = 0,
			["FlamingPhoenixIsland"] = 1,
			["FrostRoarIsland"] = 2,
			["HaqiTown_FireCavern"] = 3,
			["FlamingPhoenixIsland_TheGreatTree"] = 4,
			["AncientEgyptIsland"] = 5,
			["DarkForestIsland"] = 6,--死亡岛
		}
	else
		map = {
			["61HaqiTown_teen"] = 0,--彩虹岛
			["FlamingPhoenixIsland"] = 1,--火鸟岛
			["FrostRoarIsland"] = 2,--寒冰岛
			["HaqiTown_FireCavern"] = 3,
			["FlamingPhoenixIsland_TheGreatTree"] = 4,
			["AncientEgyptIsland"] = 5,--沙漠岛
			["DarkForestIsland"] = 6,--死亡岛
			["CloudFortressIsland"] = 7,--云海秘境
		}
	end
	return map[worldname];
end
--查找任务相关的物品描述 包括npc 有效查找npc
--return item_info,about_questtype
function QuestHelp.SearchTemplateItemByID(id)
	if(not id)then return end
    local __, map = QuestHelp.GetGoalList();
	if(map and map[id])then
		return map[id],"Goal";
	end
	local __,map = QuestHelp.GetQuestItemList();
	if(map and map[id])then
		return map[id],"GoalItem";
	end
	local __,map = QuestHelp.GetClientItemList();
	if(map and map[id])then
		return map[id],"ClientGoalItem";
	end
	local __,map = QuestHelp.GetClientExchangeItemList();
	if(map and map[id])then
		return map[id],"ClientExchangeItem";
	end
	local __,map = QuestHelp.GetFlashGameList();
	if(map and map[id])then
		return map[id],"FlashGame";
	end
	local __,map = QuestHelp.GetNpcList();
	if(map and map[id])then
		return map[id],"ClientDialogNPC";
	end
	local __,map = QuestHelp.GetCustomGoalList();
	if(map and map[id])then
		return map[id],"CustomGoal";
	end
end
--[[
通过唯一id查找详细信息
先查找npclist,然后查找任务目标
返回
	item_info = {
			worldname = worldname,
			worldInfo = worldInfo,
			id = id,
			facing = facing,
			x = x,
			y = y,
			z = z,
			camera_x = camera_x,
			camera_y = camera_y,
			camera_z = camera_z,
			label = label,
			is_npc = true,
			multi_jump_position = nil,
			state="npc", --"npc" or "mob" or "clientitem" or "others"
		}
测试：
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local id = 30341;
local id = 40001;
local item_info = QuestHelp.GetItemInfoByID(id);
commonlib.echo(item_info);
--]]
--@param is_nearest_pos: whether to find the closest user-specified jump position.
function QuestHelp.GetItemInfoByID(id,is_nearest_pos)
	if(not id)then return end
	local item_info;
	--先找是否是npc
	local npc, worldname, npc_data = NPCList.GetNPCByIDAllWorlds(id);
	if(npc)then
		local facing = npc.facing or 0;
		local position = npc.position;
		local x,y,z;
		local label = npc.name;
		local camera_x, camera_y, camera_z;
		if(position)then
	        x,y,z = position[1],position[2],position[3];
			camera_x, camera_y, camera_z = 15, 0.27, (facing + 1.57 - 1);
		end
		local worldInfo = WorldManager:GetWorldInfo(worldname);
		item_info = {
			worldname = worldname,
			worldInfo = worldInfo,
			id = id,
			facing = facing,
			x = x,
			y = y,
			z = z,
			camera_x = camera_x,
			camera_y = camera_y,
			camera_z = camera_z,
			label = label,
			is_npc = true,
			multi_jump_position = nil,
			state = "npc"
		}
		return item_info;
	end
	local function find(map,state)
		if(not map)then return end
		local item = map[id];
		if(item)then
			local worldname = item.worldname;
			if(not worldname)then
				local world = tonumber(item.world) or 0;
				--转换编号为worldname
				worldname = QuestHelp.WorldNumToWorldName(world);
			end
			local facing = 0;
			local position = item.position;
			local label = item.label;
			
			if(worldname)then
				local worldInfo = WorldManager:GetWorldInfo(worldname);
				local x,y,z,camera_x,camera_y,camera_z;
				local all_info = QuestHelp.GetPosAndCameraFromString(position);
				if(not all_info) then
					-- we shall default to the world's login or born position and camera 
					local pos = worldInfo.born_pos or worldInfo.entry_pos;
					if(pos) then
						all_info = {
							{pos = {pos.x, pos.y, pos.z}, camera_info={pos.CameraObjectDistance or 15, pos.CameraLiftupAngle or 0.233537, pos.CameraRotY or -1.8} },
						};
					end
				end

				if(all_info)then
					local len = #all_info;
					if(len > 0)then
						local index = math.random(len);
						local info = all_info[index];
						if(info)then
							local pos_info = info.pos;
							if(pos_info)then
								x,y,z = pos_info[1],pos_info[2],pos_info[3];
							end
							local camera_info = info.camera;
							if(camera_info)then
								camera_x,camera_y,camera_z = camera_info[1],camera_info[2],camera_info[3];
							end
						end
					end
				end
				
				local item_info = {
					worldname = worldname,
					worldInfo = worldInfo,
					id = id,
					facing = facing,
					x = x,
					y = y,
					z = z,
					camera_x = camera_x,
					camera_y = camera_y,
					camera_z = camera_z,
					label = label,
					is_npc = false,
					multi_jump_position = all_info,
					state = state,
				}
				local function get_nearest_pos(item_info)
					local min_x,min_y,min_z = item_info.x,item_info.y,item_info.z;
					local multi_jump_position = item_info.multi_jump_position;
					local player = MyCompany.Aries.Player.GetPlayer();
					if(multi_jump_position and player)then
						local min_dist = 0;
						--player position
						local  _x,_y,_z = player:GetPosition();
						local k,v;
						for k,v in ipairs(multi_jump_position) do
							local pos = v.pos;
							if(pos and pos[1] and pos[2] and pos[3])then
								local dx = pos[1] - _x;
								local dy = 0;--ignore coordinate of y
								local dz = pos[3] - _z;
								local dist = dx*dx + dy*dy + dz*dz;
								if(min_dist == 0)then
									min_dist = dist;
								elseif(dist < min_dist)then
									min_dist = dist;
									min_x,min_y,min_z = pos[1],pos[2],pos[3];
								end
							end
						end
					end
					return min_x,min_y,min_z;
				end
				if(is_nearest_pos and state ~= "clientitem")then
					local x,y,z = get_nearest_pos(item_info);
					item_info.x = x;
					item_info.y = y;
					item_info.z = z;
				end
				return item_info;
			end
		end
	end
	-- "Goal" or "GoalItem"
    local __, map = QuestHelp.GetGoalList();
	local item_info = find(map,"mob");
	if(not item_info)then
		-- "ClientGoalItem"
		__,map = QuestHelp.GetClientItemList();
		item_info = find(map,"clientitem");
	end
	if(not item_info)then
		-- "FlashGame"
		__,map = QuestHelp.GetFlashGameList();
		item_info = find(map,"others");
	end
	if(not item_info)then
		-- "CustomGoal"
		__,map = QuestHelp.GetCustomGoalList();
		item_info = find(map,"others");
	end
	return item_info;
end
--生成任务的显示信息
-- @param questid:任务id
-- @param is_my_info:is_my_info is false 显示模板信息, is_my_info is true 显示个人任务进度
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local item_info = QuestHelp.BuildQuestShowInfo(60192,true)
commonlib.echo(item_info);
--]]
function QuestHelp.BuildQuestShowInfo(questid,is_my_info)
	local self = QuestHelp;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	if(templates)then
		template = templates[questid];
	end
	local result;
	if(not is_my_info)then
		result = commonlib.deepcopy(template);
	else
		local q_item = provider:GetQuest(questid);
		result = commonlib.deepcopy(template);
		if(q_item)then
			result.Goal = q_item.Cur_Goal;
			result.GoalItem = q_item.Cur_GoalItem;
			result.ClientGoalItem = q_item.Cur_ClientGoalItem;
			result.ClientExchangeItem = q_item.Cur_ClientExchangeItem;
			result.FlashGame = q_item.Cur_FlashGame;
			result.ClientDialogNPC = q_item.Cur_ClientDialogNPC;
			result.CustomGoal = q_item.Cur_CustomGoal;
		end
	end
	return result;
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local goalid = QuestHelp.GetFirstGoalID(60001);
commonlib.echo(goalid);
--]]
function QuestHelp.GetFirstGoalID(questid)
	local self = QuestHelp;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	if(templates)then
		template = templates[questid];
	end
	local state = provider:GetState(questid);
	local q_item = provider:GetQuest(questid);
	local function get_template_node(id,template_goal,is_GoalItem)
		if(id and template_goal)then
			local k,v;
			for k,v in ipairs(template_goal) do
				if(is_GoalItem)then
					if(id == v.producer_id)then
						return v;
					end
				else
					if(id == v.id)then
						return v;
					end
				end
			end
		end
	end
	local function get_progressing_id(template_goal,cur_goal,is_GoalItem)
		if(template_goal and cur_goal)then
			local k,v;
			for k,v in ipairs(cur_goal) do
				local id = v.id;
				if(is_GoalItem)then
					id = v.producer_id;
				end
				local template_node = get_template_node(id,template_goal,is_GoalItem);
				if(template_node)then
					if(v.value < template_node.value)then
						return id;
					end
				end
			end
		end
	end
	if(state)then
		if(state == 0)then
			local EndNPC = template.EndNPC;
			return EndNPC;
		elseif(state == 2)then
			local StartNPC = template.StartNPC;
			return StartNPC;
		elseif(state == 1)then
			local id;
			local isNull = provider:ReturnTrueIfNull(template.Goal);
			if(not isNull)then
				id = get_progressing_id(template.Goal,q_item.Cur_Goal);
				if(id)then
					return id
				end
			end
			isNull = provider:ReturnTrueIfNull(template.GoalItem);
			if(not isNull)then
				--producer_id
				id = get_progressing_id(template.GoalItem,q_item.Cur_GoalItem,true);
				if(id)then
					return id
				end
			end
			isNull = provider:ReturnTrueIfNull(template.ClientGoalItem);
			if(not isNull)then
				id = get_progressing_id(template.ClientGoalItem,q_item.Cur_ClientGoalItem);
				if(id)then
					return id
				end
			end
			isNull = provider:ReturnTrueIfNull(template.ClientExchangeItem);
			if(not isNull)then
				id = get_progressing_id(template.ClientExchangeItem,q_item.Cur_ClientExchangeItem);
				if(id)then
					return id
				end
			end
			isNull = provider:ReturnTrueIfNull(template.FlashGame);
			if(not isNull)then
				id = get_progressing_id(template.FlashGame,q_item.Cur_FlashGame);
				if(id)then
					return id
				end
			end
			isNull = provider:ReturnTrueIfNull(template.ClientDialogNPC);
			if(not isNull)then
				id = get_progressing_id(template.ClientDialogNPC,q_item.Cur_ClientDialogNPC);
				if(id)then
					return id
				end
			end
			isNull = provider:ReturnTrueIfNull(template.CustomGoal);
			if(not isNull)then
				id = get_progressing_id(template.CustomGoal,q_item.Cur_CustomGoal);
				if(id)then
					return id
				end
			end
		end
	end
end
--是否有领取任务的时间段
function QuestHelp.HasTimeStamp(questid)
	local self = QuestHelp;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	if(templates)then
		template = templates[questid];
	end
	if(template and template.TimeStamp)then
		local id = template.TimeStamp;
		return QuestTimeStamp.HasTemplate(id);
	end
end
function QuestHelp.GetTimeStampString(questid)
	local self = QuestHelp;
	if(not self.HasTimeStamp(questid))then
		return "wu";
	end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template = templates[questid];
	local id = template.TimeStamp;
	local s = "";
	--每日任务
	if(id == 0)then
		s = string.format("周一至周日");
	--周末任务
	elseif(id == 1)then
		s = string.format("周六 周日");
	end
	return s;
end
--是否有前置条件和前置任务
function QuestHelp.HasRequestAttr_and_RequestQuest(questid)
	local self = QuestHelp;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	if(templates)then
		template = templates[questid];
	end
	if(template and template.RequestAttr and template.RequestQuest)then
        local len_1 = #template.RequestAttr;
        local len_2 = #template.RequestQuest;
		if(len_1 > 0 or len_2 >0)then
			return true;
		end
	end
end
--是否有任务目标
function QuestHelp.HasGoal(questid)
	local self = QuestHelp;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	local function has_value(list)
		if(list)then
			local len = #list;
			if(len > 0)then
				return true;
			end
		end
	end
	if(templates)then
		template = templates[questid];
		if(template)then
			local Goal = template.Goal;
			local GoalItem = template.GoalItem;
			local ClientGoalItem = template.ClientGoalItem;
			local ClientExchangeItem = template.ClientExchangeItem;
			local FlashGame = template.FlashGame;
			local ClientDialogNPC = template.ClientDialogNPC;
			local CustomGoal = template.CustomGoal;
			if(has_value(Goal) or has_value(GoalItem) or has_value(ClientGoalItem) or has_value(ClientExchangeItem) or has_value(FlashGame) or has_value(ClientDialogNPC) or has_value(CustomGoal))then
				return true;
			end
		end
	end
end
--是否是收集任务
function QuestHelp.IsQuest_ClientGoalItem(questid)
	local self = QuestHelp;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	if(templates and templates[questid])then
		template = templates[questid];
		local ClientGoalItem = template.ClientGoalItem;
		if(ClientGoalItem)then
			local len = #ClientGoalItem;
			if(len > 0)then
				return true;
			end
		end
	end
end
--------------------------------------------------------------------
function QuestHelp.test_main()
end
function QuestHelp.test_predialog()
end
function QuestHelp.ShowHelp_60289()
	--60289任务弹出 撮合面板
	if(QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.DirectShowPage("PvE",{HaqiTown_FireCavern_Hero = true,},true);
		-- MyCompany.Aries.Instance.EnterInstancePortal("HaqiTown_FireCavern_Hero");
	end
end
function QuestHelp.ShowHelp_60293()
	if(QuestHelp.IsKidsVersion())then
		-- LobbyClientServicePage.DirectShowPage("PvE",{HaqiTown_YYsNightmare = true,},true);
		MyCompany.Aries.Instance.EnterInstancePortalDirect("HaqiTown_YYsNightmare");
	end
end
function QuestHelp.ShowHelp_60302()
	if(QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.DirectShowPage("PvE",{HaqiTown_LightHouse_Hero = true,},true);
	end
end
function QuestHelp.ShowHelp_60303()
	if(QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.DirectShowPage("PvE", {FlamingPhoenixIsland_TheGreatTree_Hero = true,},true);
	end
end
function QuestHelp.ShowHelp_60309()
	if(QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.AutoFindRoom("HaqiTown_GraduateExam_54_55", "PvE");
	end
end
function QuestHelp.ShowHelp_60100()
	if(not QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.DirectShowPage("PvE",
		{
			HaqiTown_LightHouse_S1 = true,
		},true);
	end
end
function QuestHelp.ShowHelp_60101()
	if(not QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.DirectShowPage("PvE",
		{
			HaqiTown_LightHouse_S2 = true,
		},true);
	end
end
--打开撮合面板
function QuestHelp.OnClickDoAutoJoinRoom_PvE(name, mcmlNode)
	local worldname = mcmlNode:GetAttributeWithCode("param1", nil);
	if(worldname) then
		local mode_difficulty = mcmlNode:GetAttributeWithCode("param2", nil);
		if(mode_difficulty) then
			mode_difficulty = tonumber(mode_difficulty);
		end
		QuestHelp.DoAutoJoinRoom_PvE(worldname, mode_difficulty);
	end
end

function QuestHelp.DoAutoJoinRoom_PvE(worldname, mode_difficulty)
	if(not worldname)then
		return;
	end
	if(QuestHelp.IsKidsVersion())then
		LobbyClientServicePage.AutoFindRoom(worldname, "PvE");
	else
		LobbyClientServicePage.SearchModeWorld(worldname, "PvE")
	end
end
function QuestHelp.GotoTaomeePage()
	NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
	local PurchaseMagicBean = MyCompany.Aries.Inventory.PurChaseMagicBean;
	PurchaseMagicBean.Pay("recharge");
end
--客户端 加载任务模板
function QuestHelp.LoadQuestTempaltesByClient()
	local path;
	if(CommonClientService.IsKidsVersion())then
		path = "config/Aries/Quests/quest_list.xml";
	else
		path = "config/Aries/Quests_Teen/quest_list.xml";
	end
	local list,map = QuestHelp.LoadAllQuests(path);
	return list,map;
end
function QuestHelp.ShowPracticeArenaDialog()
	NPL.load("(gl)script/apps/Aries/Instance/main.lua");
	local Instance = commonlib.gettable("MyCompany.Aries.Instance");
	Instance.ShowPracticeArenaDialog();
end
function QuestHelp.DoOpenCrazyTower(worldname)
	if(not worldname)then
		return
	end

	local cur_world = WorldManager:GetCurrentWorld();
	
	if(cur_world.name == worldname)then
		_guihelper.MessageBox("任务目标就在当前世界，仔细找找吧！");
		return;
	end

	NPL.load("(gl)script/apps/Aries/CrazyTower/CrazyTowerProvider.lua");
	local CrazyTowerProvider = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerProvider")
	local game = CrazyTowerProvider.GetGameTemplate(worldname);
	if(not game)then
		_guihelper.MessageBox("找不到追踪目标！");
		return
	end
	local name = game.name;
	if(CrazyTowerProvider.IsLocked(worldname))then
            local opened_game = CrazyTowerProvider.LastOpendWorldTempate();
			local s;
			local opened_game = CrazyTowerProvider.LastOpendWorldTempate();
            if(opened_game)then
                s = string.format("%s还处于锁定状态，不能开启！请先挑战%s。",name,opened_game.name);
            else
                s = string.format("%s还处于锁定状态，不能开启！",name);
            end
			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					NPL.load("(gl)script/apps/Aries/CrazyTower/CrazyTowerPage.lua");
					local CrazyTowerPage = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerPage");
					CrazyTowerPage.ShowPage();
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
		return
	end
	NPL.load("(gl)script/apps/Aries/Instance/main.lua");
	local Instance = commonlib.gettable("MyCompany.Aries.Instance");
    Instance.EnterInstancePortal(game.worldname);

end
function QuestHelp.PurchaseMagicBean_Show()
	NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.teen.lua");
	local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
	PurchaseMagicBean.Show();
end
function QuestHelp.GoToNPC(npcid)
	npcid = tonumber(npcid);
	if(not npcid)then
		return
	end
    NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
    local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
    WorldManager:GotoNPC(npcid,function()
    end)
end
function QuestHelp.ShowNPCDialog(npc_id,dialog_url)
	npc_id = tonumber(npc_id);
	if(not npc_id or not dialog_url)then
		return
	end
	
	if(CommonClientService.IsKidsVersion())then
		NPL.load("(gl)script/apps/Aries/Dialog/Dialog_NPC.lua");
		local Dialog = commonlib.gettable("MyCompany.Aries.Dialog");
		Dialog.ShowNPCTalk(npc_id, nil, dialog_url,true);
	else
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog_Teen_Native",{
			dialog_url = dialog_url,
			npc_id = npc_id,
		});
	end
	
end
function QuestHelp.Join1v1()
	PvPTicket_NPC.Join1v1();
end
function QuestHelp.Join2v2()
	PvPTicket_NPC.Join2v2();
end
function QuestHelp.OpenBearShop()
	NPL.load("(gl)script/apps/Aries/NPCs/Commons/CommonNPCs.teen.lua");
    local CommonNPCs = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CommonNPCs");
    CommonNPCs.ShowBear(function()
        NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
        local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
        NPCShopPage.ShowPage(-1);
    end,true);
end
function QuestHelp.OpenProfilePane(type)
	type = type or "pvpinfo";
	NPL.load("(gl)script/apps/Aries/NewProfile/ProfilePane.lua");
	local ProfilePane = commonlib.gettable("MyCompany.Aries.ProfilePane");
	ProfilePane.ShowPage(nil,type);
end
function QuestHelp.OpenAuctionHouse(gsid)
	gsid = tonumber(gsid);
	if(not gsid)then
		return
	end
	NPL.load("(gl)script/apps/Aries/HaqiShop/AuctionHouse.lua");
    local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
    AuctionHouse.OnClickViewItem(gsid);
end
function QuestHelp.OpenWorldTeamQuest()
	NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
	local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
	WorldTeamQuest.ShowPage();
end

-- 创建沼泽魔窟副本房间
function QuestHelp.EntranceDarkForestIslandMarshNest()
	local game_setting = {game_type="PvE",guard_map={},leader_text="",min_level=50,keyname="DarkForestIsland_MarshNest",mode=3,requirement_tag="storm|fire|life|death|ice",max_level=55,max_players=3,name="——————",};
	LobbyClientServicePage.DoCreateGame(game_setting);
end

function QuestHelp.SetGoalPointer()
end
