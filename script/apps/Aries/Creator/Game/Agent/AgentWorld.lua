--[[
Title: Agent World
Author(s): LiXizhi
Date: 2021/3/8
Desc: a simulated world in memory, in which we can add code blocks and movie block. 
Entities from agent world are created into the real world, however, the agent world itself does not take any real world space. 
We can load agent world from agent file (template file). 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Agent/AgentWorld.lua");
local AgentWorld = commonlib.gettable("MyCompany.Aries.Game.Agent.AgentWorld");
local world = AgentWorld:new():Init();
world:Run()
-------------------------------------------------------
]]
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local AgentWorld = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("MyCompany.Aries.Game.Agent.AgentWorld"));

AgentWorld:Property({"centerPos", {0,0,0}, "GetCenterPosition", "SetCenterPosition", auto=true});

function AgentWorld:ctor()
	self.blocks = {};
	self.codeblocks = {};
end

function AgentWorld:Init()
	GameLogic:Connect("WorldUnloaded", AgentWorld, AgentWorld.OnWorldUnload, "UniqueConnection");

	return self;
end

-- @param filename: agent xml or bmax or block template file. 
-- @param cx, cy, cz: center position where the entities in the agent world are created into the real world. default to 0. 
function AgentWorld:LoadFromAgentFile(filename, cx, cy, cz)
	self:SetCenterPosition({cx or 0, cy or 0, cz or 0})
	-- TODO:
end

-- run all code blocks in the agent world
function AgentWorld:Run()
	-- TODO:
end

function AgentWorld:OnWorldUnload()
	-- TODO: unload virtual entities and free memory?
end