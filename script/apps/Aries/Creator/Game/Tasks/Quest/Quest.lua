--[[
Title: quest data
Author(s): chenjinxian
Date: 2020/12/7
Desc: 
use the lib:
------------------------------------------------------------
local Quest = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/Quest.lua");
local quest = Quest:new():Init(extendedcost);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/ide/Graph.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local Graph = commonlib.gettable("commonlib.Graph");
local GraphNode = commonlib.gettable("commonlib.GraphNode");
local GraphArc = commonlib.gettable("commonlib.GraphArc");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local Quest = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.Quest"));

local questStartId = 40000;
local questEndId = 49999;

function Quest:ctor()
	self.graphData = Graph:new{};
end

function Quest:Init(extendedcost)
	local extendedDatas = {};
	local nodes = {};
	for _, data in ipairs(extendedcost) do
		if (data.exId >= questStartId and data.exId <= questEndId) then
			extendedDatas[#extendedDatas + 1] = data;
			local node = self.graphData:AddNode();
			node.data = {questId= data.exId};
			node.data = {templateData = {Id = data.exId, Title = data.name, Description = data.desc}};
			nodes[data.exId] = node;
		end
	end

	local arcs = {};
	function getArc(gsId, nodeId)
		if (not gsId) then
			return
		end
		for _, data in ipairs(extendedDatas) do
			if (data.exchangeTargets and #data.exchangeTargets > 0) then
				local hasArc = false;
				for _, target in ipairs(data.exchangeTargets) do
					for _, good in ipairs(target) do
						if (good.gsId == gsId) then
							arcs[#arcs + 1] = {preNodeId = nodeId, targetId = data.exId, tag = {condition = "and"}};
								hasArc = true;
							break;
						end
					end
					if (hasArc) then break end
				end
			end
		end
	end
	for _, data in ipairs(extendedDatas) do
		if (data.preconditions and #data.preconditions > 0) then
			for _, condition in ipairs(node.preconditions) do
				getArc(condition.goods.gsId, data.exId);
			end
		end
	end

	for _, arc in ipairs(arcs) do
		if (arc.preNodeId and arc.targetId) then
			self.graphData:AddArc(nodes[arc.preNodeId], nodes[arc.targetId], arc.tag);
		end
	end
end

function Quest:GetQuestList()
end

function Quest:UpdateQuestState()
end

function Quest:SaveQuestToDgml(filepath)
	QuestHelp.SaveToDgml(self.graphData, filepath);
end
