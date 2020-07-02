--[[
Title: 
Author(s): Leio
Date: 2012/3/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestChoice.lua");
local QuestChoice = commonlib.gettable("MyCompany.Aries.Quest.QuestChoice");
local filepath = "config/Aries/Quests/weekly_choice.xml";
local map = QuestChoice.GetValidQuestIDs(filepath,0,1);
_guihelper.MessageBox(map);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/ide/commonlib.lua");
local QuestChoice = commonlib.gettable("MyCompany.Aries.Quest.QuestChoice");
QuestChoice.templates = nil;

--获取今天的日常任务id
--@param filepath:模板配置文件路径
--@param type:0 每日任务 1 每周任务
--@param week:1-7 周几
--return nil 忽略判断 or id_maps 
function QuestChoice.GetValidQuestIDs(filepath,type,week)
	if(not filepath or not type)then return end
	local self = QuestChoice;
	local xmlRoot = ParaXML.LuaXML_ParseFile(filepath);
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/choice/items") do
		local _type = node.attr.type;
		_type = tonumber(_type);
		if(_type and type == _type)then
			local weekly_node;
			for weekly_node in commonlib.XPath.eachNode(node, "/item") do
				local _week = weekly_node.attr.week;
				_week = tonumber(_week);
				if(_week and _week == week)then
					local choice = weekly_node.attr.choice;
					if(choice == "all")then
						return
					end
					if(choice == "all_children")then
						local map = {};
						local questnode;
						for questnode in commonlib.XPath.eachNode(weekly_node, "/quest") do
							local id = questnode.attr.id;
							id = tonumber(id);
							map[id] = 1;
						end
						return map;
					end
					choice = tonumber(choice);
					if(choice)then
						local map = {};
						if(choice <= 0)then
							return map;
						end
						local list = {};
						local questnode;
						for questnode in commonlib.XPath.eachNode(weekly_node, "/quest") do
							local id = questnode.attr.id;
							id = tonumber(id);
							if(id)then
								table.insert(list,id);
							end
						end
						local len = #list;
						choice = math.min(choice,len);
						if(len >= choice)then
							local result = commonlib.GetRandomList(len,choice);
							if(result)then
								local k,index;
								for k,index in ipairs(result) do
									local id = list[index];
									map[id] = 1;
								end
							end
						end
						return map;
					end
				end
				
			end
		end 
	end
end
