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
local world = AgentWorld:new():Init("Mod/Agents/MacroPlatform.xml");
world:Run()
-------------------------------------------------------
]]
local EntityCode = commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityCode")
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local AgentWorld = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("MyCompany.Aries.Game.Agent.AgentWorld"));

AgentWorld:Property({"centerPos", {0,0,0}, "GetCenterPosition", "SetCenterPosition", auto=true});

function AgentWorld:ctor()
	self.blocks = {};
	self.codeblocks = {};
	self.codeEntities = {};
end

function AgentWorld:Init(filename)
	GameLogic:Connect("WorldUnloaded", AgentWorld, AgentWorld.OnWorldUnload, "UniqueConnection");

	if(filename) then
		self:LoadFromAgentFile(filename);
	end
	return self;
end

local function GetSparseIndex(x, y, z)
	return y*900000000+x*30000+z;
end

-- convert from sparse index to block x,y,z
-- @return x,y,z
local function FromSparseIndex(index)
	local x, y, z;
	y = math.floor(index / (900000000));
	index = index - y*900000000;
	x = math.floor(index / (30000));
	z = index - x*30000;
	return x,y,z;
end

-- @param filename: agent xml or bmax or block template file. 
-- @param cx, cy, cz: center position where the entities in the agent world are created into the real world. default to 0. 
function AgentWorld:LoadFromAgentFile(filename, cx, cy, cz)
	self:SetCenterPosition({cx or 0, cy or 0, cz or 0})
	local blocks = self.blocks;
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		local root_node = commonlib.XPath.selectNode(xmlRoot, "/pe:blocktemplate");
		if(root_node) then
			local node = commonlib.XPath.selectNode(root_node, "/pe:blocks");
			if(node and node[1]) then
				local blocks_ = NPL.LoadTableFromString(node[1]);

				if(blocks_ and #blocks_>=1) then
					for _, b in ipairs(blocks_) do
						local blockId = b[4];
						blocks[GetSparseIndex(b[1], b[2], b[3])] = b;
						if(blockId == block_types.names.CodeBlock) then
							local attr = b[6] and b[6].attr;
							if(attr) then
								if(attr.isPowered == true or attr.isPowered == "true") then
									self.codeblocks[#(self.codeblocks) + 1] = b;
								end
							end
						end
					end
				end
			end
		end
	else
		LOG.std(nil, "warn", "AgentWorld", "failed to load template from file: %s", filename or "");
	end
end

function AgentWorld:Clear()
end

-- run all code blocks in the agent world
function AgentWorld:Run()
	NPL.load("(gl)script/apps/Aries/Creator/Game/Agent/AgentEntityCode.lua");
	local AgentEntityCode = commonlib.gettable("MyCompany.Aries.Game.EntityManager.AgentEntityCode");

	for _, b in ipairs(self.codeblocks) do
		local entityCode = AgentEntityCode:new();
		entityCode:LoadFromXMLNode(b[6])
		entityCode:SetPowered(true);
		self.codeEntities[#(self.codeEntities)+1] = entityCode
	end
end

function AgentWorld:OnWorldUnload()
	-- TODO: unload virtual entities and free memory?
end