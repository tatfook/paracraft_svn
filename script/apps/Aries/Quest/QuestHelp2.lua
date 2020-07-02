--[[
Title: 
Author(s): Leio
Date: 2011/12/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local id = 40113;
local template = QuestHelp.GetMobTemplateByID();
local x,y,z = QuestHelp.GetClosetArenaPosByMobID(id)
QuestHelp.ActiveAreaTip(true,x,y,z);

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.QuestToExcel()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/GraphHelp.lua");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");

local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local ObjEditor = commonlib.gettable("ObjEditor");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.mob_template_map = {};
QuestHelp.mini_scene_name = "QuestHelp_arena_mini_scene";
--获取怪物的名称
--@param mob_path:怪物描述路径 e.g."config/Aries/Mob_Teen/AncientEgyptIsland/MobTemplate_MudMonster.xml"
function QuestHelp.GetMobNameByMobTemplatePath(mob_path)
	local self = QuestHelp;
	local template = self.GetMobTemplate(mob_path);
	if(template)then
		local displayname = template.attr.displayname;
		return displayname;
	end
end
--获取描述怪物的属性
--@param mob_path:怪物描述路径 e.g."config/Aries/Mob_Teen/AncientEgyptIsland/MobTemplate_MudMonster.xml"
--return xmlnode
function QuestHelp.GetMobTemplate(mob_path)
	local self = QuestHelp;
	if(not mob_path)then return end
	mob_path = string.lower(mob_path);
	local template = self.mob_template_map[mob_path];
	if(not template)then
		local xmlRoot = ParaXML.LuaXML_ParseFile(mob_path);
		if(xmlRoot)then
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "//mobtemplate/mob") do
				self.mob_template_map[mob_path] = node;
				template = node;
				break;		
			end
		end
	end	
	return template;
end
--通过怪物id获取怪物属性
function QuestHelp.GetMobTemplateByID(id)
	local self = QuestHelp;
	if(not id)then return end
	local list,map = QuestHelp.GetGoalList();
	if(map and map[id])then
		local path = map[id].path
		return self.GetMobTemplate(path);
	end
end
--通过怪物id获取怪物名称
function QuestHelp.GetMobNameByID(id)
	local self = QuestHelp;
	local template = self.GetMobTemplateByID(id);
	if(template)then
		local displayname = template.attr.displayname;
		return displayname;
	end
end

-- @param id: mob id
-- @param pos: relative to which position to find the closest mob. if nil it is the current player position. 
-- otherwise it can be a {x,y,z} array
-- @return nil or x,y,z
function QuestHelp.GetClosetArenaPosByMobID(id, pos)
	local name = QuestHelp.GetMobNameByID(id);
	if(name)then
		--return MsgHandler.Get_closest_alive_mob_position(name, pos);
		return MsgHandler.Get_Highest_HP_mob_position(name, pos);
	end
end

-- show or hide the area tip. 
function QuestHelp.ShowHideAreaTip(bShow)
	local effectGraph = ParaScene_GetMiniSceneGraph(QuestHelp.mini_scene_name);
	effectGraph:SetVisible(bShow);
end

--在法阵中心点显示指示
--@param bActive:true 显示法阵提示 false 隐藏
function QuestHelp.ActiveAreaTip(bActive,x,y,z)
	local self = QuestHelp;
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_name);
	local arena_name = "QuestHelp.ActiveAreaTip";
	local obj = effectGraph:GetObject(arena_name);
	
	if(not bActive or not x or not y or not z)then
		if(obj and obj:IsValid()) then
			obj:SetVisible(false);
			-- effectGraph:DestroyObject(obj);
		end
	else
		if(obj and obj:IsValid()) then
			obj:SetPosition(x,y,z);
			obj:SetVisible(true);
		else
			local entity_params = {
				name = arena_name,
				x = x,
				y = y,
				z = z,
				--AssetFile = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_teen.x",
				AssetFile = "character/v5/09effect/Combat_Common/CombatArea/CombatArea.x",
				IsCharacter = true,
				facing = 0,
			}
			-- create arena
			local arena_model = ObjEditor.CreateObjectByParams(entity_params);
			arena_model:GetAttributeObject():SetField("progress",1);
			effectGraph:AddChild(arena_model);
		end
	end
end
--从excel格式转换 代替原来config/Aries/Quests/goal_list.xml的解析
--[[
	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	local path="config/Aries/Workspace/goal_list_excel.xml";
	local result,result_map = QuestHelp.LoadGoalListFromExcel(path)
	commonlib.echo(result_map);
--]]
function QuestHelp.LoadGoalListFromExcel(path)
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	local k,v;
	local result = {};
	local result_map = {};
	local index = 1;
	local nodes;
	--commonlib.echo("============load QuestHelp.LoadGoalListFromExcel");
	--commonlib.echo(path);
	for nodes in commonlib.XPath.eachNode(xmlRoot, "/Workbook/Worksheet/Table/Row") do
		if(index > 1)then
			local cell_nodes;
			local row = {};
			local col_index = 1;
			local id;
			local can_push = false;
			for cell_nodes in commonlib.XPath.eachNode(nodes, "/Cell/Data") do
				local value = cell_nodes[1];
				if(col_index == 1)then
					value = tonumber(value);
					
					row["id"] = value;

					id = value;
					if(value)then
						can_push = true;
					end
				elseif(col_index == 2)then
					row["label"] = value;
				elseif(col_index == 3)then
					row["path"] = value;
				elseif(col_index == 4)then
					row["worldname_location"] = value;--怪物所在的副本
				elseif(col_index == 5)then
					row["level"] = value;
				elseif(col_index == 6)then
					row["worldname"] = value;--跳转坐标所处的世界
					row["world"] = QuestHelp.WorldNameToWorldNum(value);
				elseif(col_index == 7)then
					row["worldlabel"] = value;
				elseif(col_index == 8)then
					row["place"] = value;
				elseif(col_index == 9)then
					row["enabled"] = value;
				elseif(col_index == 10)then
					if(value and value ~= "none")then
						row["helpfunction"] = value;
					end
				elseif(col_index == 11)then

					row["position"] = value;
				end
				col_index = col_index + 1;
			end
			if(can_push)then
				table.insert(result,row);
				if(id)then
					result_map[id] = row;
				end
			else
				--commonlib.echo(string.format("============unable parse ndoes QuestHelp.LoadGoalListFromExcel:%d",index));
				--commonlib.echo(nodes);
			end
		end
		index = index + 1;
	end
	return result,result_map;
end
--可以直接删除任务的用户
function QuestHelp.IsPowerUser(nid)
	local self = QuestHelp;
	nid = tonumber(nid);
	if(not nid)then return end
	local path = "config/Aries/Others/specialids.xml";
	if(CommonClientService.IsTeenVersion()) then
		if(System.options.locale == "zhCN") then
			path = "config/Aries/Others/specialids_teen_zhCN.xml";
		end
	end
	if(not self.special_ids)then
		self.special_ids = {};
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		for item in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
			local id = tonumber(item.attr.id);
			if(id)then
				self.special_ids[id] = true;
			end
		end
	end
	local b = self.special_ids[nid];
	return b;
end
function QuestHelp.QuestToExcel()
	local self = QuestHelp;
	local provider = QuestClientLogics.provider;
	if(not provider)then return end
	local excel_template_path = "config/aries/workspace/quest_to_excel_template.xml";
	local output_path = "config/aries/workspace/quest_to_excel.xml";
	local template_str = "";
	local file = ParaIO.open(excel_template_path, "r");
	if(file:IsValid()) then
		template_str = file:GetText();
		file:close();
	end
	local all_template_quest = provider:FindAllQuestsTemplate();
	local templates = provider:GetTemplateQuests();
	local function get_npc_str(id)
		if(not id)then return end
		local __,map = QuestHelp.GetNpcList();
		local label = "";
		local item = map[id];
		if(item)then
			label = item.label;
		end
		local s = string.format("%s(%d)",label,id);
		return s;
	end
	local function get_reward_str(reward)
		if(not reward)then return end
		local __,map = QuestHelp.GetRewardList();
		local info = "";
		for k,v in ipairs(reward) do
			local id = v.id;
			local value = v.value;
			local label = "";
			local item = map[id];
			if(item)then
				label = item.label;
			end
			local s = string.format("[%s:%d]",label,value);
			info = info .. s;
		end
		return info;
	end
	local all_rows = "";
	if(all_template_quest)then
		local k,v;
		local len = #all_template_quest;
		for k,v in ipairs(all_template_quest) do
			local questid = v.questid;
			if(questid)then
				local template = templates[questid];
				if(template)then
					local RecommendLevel = template.RecommendLevel;
					local Title = template.Title;
					local Detail = template.Detail;
					local StartNPC = template.StartNPC;
					local EndNPC = template.EndNPC;
					local Reward = template.Reward;
					local Reward_1,Reward_2;
					if(Reward)then
						Reward_1 = Reward[1];
						Reward_2 = Reward[2];
					end
					local StartNPC_Str = get_npc_str(StartNPC);
					local EndNPC_Str = get_npc_str(EndNPC);
					local Reward_1_Str = get_reward_str(Reward_1);
					local Reward_2_Str = get_reward_str(Reward_2);
					local row = string.format([[
					 <Row>
						<Cell><Data ss:Type="Number">%d</Data></Cell>
						<Cell><Data ss:Type="Number">%d</Data></Cell>
						<Cell><Data ss:Type="String">%s</Data></Cell>
						<Cell><Data ss:Type="String">%s</Data></Cell>
						<Cell><Data ss:Type="String">%s</Data></Cell>
						<Cell><Data ss:Type="String">%s</Data></Cell>
						<Cell><Data ss:Type="String">%s</Data></Cell>
						<Cell><Data ss:Type="String">%s</Data></Cell>
					</Row>]],questid or -1,RecommendLevel or -1,Title or "无",Detail or "无",StartNPC_Str or "无",EndNPC_Str or "无",Reward_1_Str or "无",Reward_2_Str or "无");
					all_rows = all_rows .. row;
				end
			end
		end
		template_str = string.gsub(template_str,[[<QuestData/>]],all_rows);
		local rowcnt_str = string.format([[ss:ExpandedRowCount="%d"]],len+1);
		template_str = string.gsub(template_str,[[ss:ExpandedRowCount="1"]],rowcnt_str);
		ParaIO.CreateDirectory(output_path);
		local file = ParaIO.open(output_path, "w");
		if(file:IsValid()) then
			file:WriteString(template_str);
			file:close();
		end
		_guihelper.MessageBox("生成成功："..output_path);
	end
end
function QuestHelp.AddEventListener()
	MyCompany.Aries.event:AddEventListener("custom_goal_client", function(self, event, questid) 
		if(questid)then
			QuestClientLogics.DoAddValue_FromClient({
				{ id = questid,value = 1,}
			});
		end
	end, nil, "aries_quest_custom_goal_client");
end
--返回任务类型标题
function QuestHelp.GetQuestGroup1_Title(num)
	num = tonumber(num);
	if(not num)then return end
	local s;
	if(num == 0)then
		s = "主线";
	elseif(num == 1)then
		s = "支线";
	elseif(num == 2)then
		s = "每日";
	elseif(num == 3)then
		s = "剧情";
	elseif(num == 4)then
		s = "导师";
	elseif(num == 5)then
		s = "家族";
	elseif(num == 6)then
		s = "悬赏";
	elseif(num == 7)then
		s = "副本";
	elseif(num == 8)then
		s = "生活";
	elseif(num == 9)then
		s = "活动";
	elseif(num == 10)then
		s = "周长";
	end
	return s;
end
--投掷 触发任务进度
function QuestHelp.Quest_ThrowBall(gsid)
	if(not gsid or not CommonClientService.IsKidsVersion())then return end
	local goal_id;
	if(gsid == 9501)then
		--水球
		goal_id = 79020;
	elseif(gsid == 9502)then
		--果冻
		goal_id = 79021;
	elseif(gsid == 9503)then
		--鞭炮
		goal_id = 79022;
	elseif(gsid == 9504)then
		--雪球
		goal_id = 79023;
	elseif(gsid == 9505)then
		--糖豆豆
		goal_id = 79024;
	end
	if(goal_id)then
		QuestClientLogics.DoAddValue_FromClient({
			{ id = goal_id,value = 1,}
		});
	end
end
function QuestHelp.ShowMessage(s)
	if(not s)then return end
	_guihelper.MessageBox(s);
end
function QuestHelp.DoAction(id)
	if(id == 79014)then
		--辅修专业
		NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/ForgetSkill.teen.lua");
		local ForgetSkill = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.ForgetSkill");
		ForgetSkill.ShowPage();
	end
end
QuestHelp.disable_jump_ids = {
	61129,61130,61131,61132,61133,61134,61135,61136,61137,61138,61139,61140,61141,
}
function QuestHelp.Jump_Enabled_Kids(questid,show_messagebox)
	if(CommonClientService.IsTeenVersion())then
		return true;
	end
	local provider = QuestClientLogics.GetProvider();
	if(not questid or not provider)then
		return
	end
	local k,v;
	for k,v in ipairs(QuestHelp.disable_jump_ids) do
		if(v == questid)then
			if(show_messagebox)then
				_guihelper.MessageBox("博士希望你可以脚踏实地的去送信，一个优秀的小信使是不可以偷懒的哦！（该任务无法使用便捷的传送功能） ");
			end
			return
		end
	end
	return true;
end
--根据任务目标CustomGoal生成需要销毁的真实物品列表
--local custom_goal_loots = { {gsid = gsid, value = value},{gsid = gsid, value = value},}
function QuestHelp.BuildReallyItemsFromCustomGoal(provider,questid)
	if(not provider or not questid)then return end
	local templates = provider:GetTemplateQuests();
	local template = templates[questid];
	if(template and template.CustomGoal)then
		local result = {};
		local k,v;
		for k,v in ipairs(template.CustomGoal) do
			local gsid = v.id;
			local value = v.value;
			local need_destroy = v.need_destroy;
			if(gsid and value and need_destroy and value > 0 and need_destroy == 1)then
				table.insert(result,{gsid = gsid, value = value,});
			end
		end
		return result;
	end
end
function QuestHelp.BuildChart(gamever,IsSvr)

	local save_filepath = "quest_chart.teen.csv";
	local path = "config/Aries/Quests_Teen/quest_list.xml";

	if (gamever=="kids") then
		save_filepath = "quest_chart.kids.csv";
		path = "config/Aries/Quests/quest_list.xml";
	end

	local data,map = QuestHelp.LoadAllQuests(path);
	local graph = QuestHelp.CreateGraph(data,true);
	if(graph)then
		local output = { };
		local output_map = { };
		local function drawNodesArcs(gNode)
			if(not gNode or not output or not output_map)then return end
			local data = gNode:GetData();

			if(data)then
				local template = data.templateData;--模板原始数据
				if(template)then
					local id = template.Id;
					if(id)then
						id = tonumber(id);
						local Title = template.Title
						local Role = template.Role;
						local RecommendLevel = template.RecommendLevel or 0;--推荐等级
						local node = { questid = id, Title = Title, Role = Role, RecommendLevel = RecommendLevel, };
						if(not output_map[id])then
							table.insert(output,node);
							output_map[id] = node;
						end	
					end
				end
			end

		end
		GraphHelp.Search_DepthFirst_FromRoot(graph,drawNodesArcs);
		table.sort(output,function(a,b)
			return (a.RecommendLevel < b.RecommendLevel) ;
		end);
		ParaIO.CreateDirectory(filepath);
		local file = ParaIO.open(save_filepath, "w");
		if(file:IsValid()) then
			local str = "";
			local k,v;
			for k,v in ipairs(output) do
				str = string.format("%s,%s,%s",tostring(v.Title),tostring(v.RecommendLevel),tostring(v.questid));
				if(k >1)then
					str = string.format("\n%s",str);
				end
				file:WriteString(commonlib.Encoding.Utf8ToDefault(str));
			end
		end
		file:close();

		if (IsSvr) then			
		else
			_guihelper.MessageBox(save_filepath.."成功！");
		end
	end
end
function QuestHelp.Avatar_equip_upgrade()
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
	local Avatar_equip_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade");
	Avatar_equip_upgrade.ShowPage();
end