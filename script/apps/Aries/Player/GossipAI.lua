--[[ 
Title: Gossip AI module
Author: LiXizhi
Date: 2012/4/12
Desc: Gossip AI module. randomly pick a group of sentences. This class can be used by mob or NPC ai. 
Sample file: "config/Aries/Others/GossipAI.xml"
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Player/GossipAI.lua");
local GossipAI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.GossipAI");
GossipAI.OnInit();
local rule = GossipAI.GetRuleByName("boss0")
if(rule) then
	local random_gossip_index = 12345;
	echo(rule:GetNextSentence(nil, random_gossip_index));
end
------------------------------------------------------------	
]]
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");

local math_mod = math.mod
local math_random = math.random

-- create class
local GossipAI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.GossipAI");

local gossip_rules = {};

-- mapping from id to gossip sentence
local reusable_gossips = {};

------------------------------
-- gossip: a short seqwence of sentences
------------------------------
local gossip_class = {
	-- default loop time in milliseconds. default to 10 second. 
	--  this value will be calculated automatically when new sentences are added to it. 
	loop_time = 10000,
	-- default interval between two sentences
	default_sentence_interval = 5000, 
	default_sentence_duration = 3000,
	-- default interval between the last sentence and first sentence
	default_loop_interval = 5000, 
};
function gossip_class:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- @param sentence: string of a table {name="sentence", [1]= sentence}
function gossip_class:add_sentence(sentence)
	if(type(sentence) == "text") then
		self[#self+1] = {name="sentence", [1]= sentence};
	else
		self[#self+1] = sentence;
	end

	local time = 0;
	local _, sentence;
	for _, sentence in ipairs(self) do
		sentence.begin_time = time;
		time = time + self.default_sentence_duration;
		sentence.end_time = time;
		time = time + self.default_sentence_interval;
	end
	time = time + self.default_loop_interval;
	self.loop_time = time;
end

-- get sentence by time
-- @param cur_time: the local time of the ai. if nil, the current time is used. 
function gossip_class:GetNextSentence(cur_time)
	cur_time = math.mod(cur_time or commonlib.TimerManager.GetCurrentTime(), self.loop_time);
	local _, sentence;
	for _, sentence in ipairs(self) do
		if(sentence.begin_time < cur_time and cur_time< sentence.end_time) then
			return sentence[1];
		end
	end
end

------------------------------
-- rule class: this usually represent a single talk AI
------------------------------
local rule_class = {};
function rule_class:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- @param gossip: text of a xml table of gossip
function rule_class:add_gossip(gossip)
	self.gossips = self.gossips or {};
	if(type(gossip) == "text") then
		local gossip_instance = gossip_class:new();
		gossip_instance:add_sentence(gossip);
		self.gossips[#self.gossips + 1] = gossip_instance;
	elseif(type(gossip) == "table") then
		local gossip_instance;
		if(gossip.loop_time) then
			gossip_instance = gossip;
		else
			gossip_instance = gossip_class:new();
			local _, sentence;
			for _, sentence in ipairs(gossip) do
				gossip_instance:add_sentence(sentence);
			end
		end
		self.gossips[#self.gossips + 1] = gossip_instance;
	end
end

-- public: call this function to get the next sentence
-- @param cur_time: the local time of the ai. if nil, the current time is used. 
-- @param gossip_index: this is a random integer, usually the mob's id. If nil, it will randomly pick a sentence from all gossip. 
-- if specified, it will use math.mod(random_id, #gossip);
function rule_class:GetNextSentence(cur_time, gossip_index)
	if(self.gossips) then
		local count = #self.gossips;
		if(count>0) then
			local cur_time = cur_time or commonlib.TimerManager.GetCurrentTime()
			local gossip_index = math.mod((gossip_index or cur_time), count) + 1;
			local gossip = self.gossips[gossip_index];
			return gossip:GetNextSentence(cur_time);
		end
	end
end

-- call this only once. multple calls have no effect. 
-- @param bForceReLoad: true to reload from xml file
function GossipAI.OnInit(bForceReLoad)
	if(GossipAI.is_inited and not bForceReLoad) then
		return
	end
	GossipAI.is_inited = true
	local filename = if_else(System.options.version=="kids", "config/Aries/Others/GossipAI.xml", "config/Aries/Others/GossipAI.teen.xml");
	-- load from file
	local node;
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "GossipAI", "failed to load from file %s", filename)
		return;
	end
	local count = 0;
	for node in commonlib.XPath.eachNode(xmlRoot, "/gossip_ai/reuseable_gossips/gossip") do
		if(node.attr.id) then
			local gossip_instance = gossip_class:new();
			local _, sentence;
			for _, sentence in ipairs(node) do
				gossip_instance:add_sentence(sentence);
			end
			reusable_gossips[node.attr.id] = gossip_instance;
		end
	end

	for node in commonlib.XPath.eachNode(xmlRoot, "/gossip_ai/rules/rule") do
		if(node.attr.name) then
			local rule = rule_class:new({name = node.attr.name});
			gossip_rules[node.attr.name] = rule;
			local _, sub_node;
			for _, sub_node in ipairs(node) do
				if(type(sub_node) == "table" and #sub_node == 0 and sub_node.attr.id) then
					local gossip = reusable_gossips[sub_node.attr.id]
					if(gossip) then
						rule:add_gossip(gossip);
					end
				else
					rule:add_gossip(sub_node);
				end
			end
		end
	end
	LOG.std(nil, "info", "GossipAI", "loaded gossip file from %s", filename);
end

-- get gossip by name
function GossipAI.GetRuleByName(name)
	return gossip_rules[name];
end