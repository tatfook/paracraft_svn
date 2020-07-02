--[[
Title: compressed agent stream to be sent via network
Author(s): LiXizhi
Date: 2008/12/28
Desc: serialization of agent to/from compact data stream
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_agent.lua");

NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_opcode.lua");
local opcodes = Map3DSystem.JGSL.opcodes;

local User = Map3DSystem.User;


if(not Map3DSystem.JGSL.agentstream) then Map3DSystem.JGSL.agentstream = {};end;

local JGSL = Map3DSystem.JGSL;
local agentstream = Map3DSystem.JGSL.agentstream;

-- serialize agent structure to stream
function JGSL.AgentStreamWriter.Serialize(agent)
end

-- deserialize a stream data structure to stream
function JGSL.AgentStreamReader.Deserialize(stream)
end



-- create object if user does not provide one
function agentstream:new()
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end

