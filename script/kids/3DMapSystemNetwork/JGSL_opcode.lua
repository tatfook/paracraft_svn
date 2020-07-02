--[[
Title: opcode is used to encode/decode agent streams. 
Author(s): LiXizhi
Date: 2008/12/29
Desc: agent streams are encoded with arrays of {opcode:data},
the following is a mapping from opcodes to their specification. 
	opcode.name: name of the opcode. it is also the key to the actual data in agent structure. 
	opcode.refreshrate: the data represented by the opcode needs to be refreshed with client or server at this rate. 
	opcode.reader: a reader function to decode string data to their real data
	opcode.writer: a writer function to encode real data to their string data. 
an agent stream to be transmitted via network is often of the following format

	"opcode:encoded_data,opcode:encoded_data,..."
	
encoded_data must be a string without : and , separator. if data contains separator, they are usually put inside quotation marks. 	
e.g. 1:"this is a string",2:200.00;20.00;200.00,3:3.14,

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_opcode.lua");
local opcodes = Map3DSystem.JGSL.opcodes;

commonlib.echo(opcodes[1]:read("jid@domain.com"))  --> "jid@domain.com"
commonlib.echo(opcodes[1]:read("jid"))  --> "jid@defaultdomain.com"
commonlib.echo(opcodes[1]:write("jid@domain.com"))  --> "jid"
commonlib.echo(opcodes[1]:write("jid"))  --> "jid"

commonlib.echo(opcodes[2]:read("2"))  --> "character/v3/Human/Female/HumanFemale.xml"
commonlib.echo(opcodes[2]:read("character/v3/Human/Female/HumanFemale.xml"))  --> "character/v3/Human/Female/HumanFemale.xml"
commonlib.echo(opcodes[2]:write("character/v3/Human/Female/HumanFemale.xml"))  --> "2"

commonlib.echo(opcodes[3]:read("2000.12"))  --> 2000.12
commonlib.echo(opcodes[3]:write(2000.1234))  --> "2000.12"
commonlib.echo(opcodes[3]:write("123"))  --> nil

commonlib.echo(opcodes[6]:read("ff"))  --> 3.14
commonlib.echo(opcodes[6]:read("7f")) --> 0 
commonlib.echo(opcodes[6]:write(3.14))  --> fe
commonlib.echo(opcodes[6]:write(0))  --> 7f
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_stringmap.lua");

local User = Map3DSystem.User;
if(not Map3DSystem.JGSL.opcode) then Map3DSystem.JGSL.opcode = {};end;

---------------------------------------
-- opcode where data part is a string. string map is supported. 
---------------------------------------
local opcode_str = {
	name = "unknown",
	refreshrate = 10,
	historycount = 2,
	-- it is a commonlib.stringmap instance or nil. 
	stringmap = nil,
}
-- @param o may contain {stringmap}, where stringmap is a commonlib.stringmap instance. 
function opcode_str:new(o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end
function opcode_str:read(data)
	if(type(data) == "string") then
		if(self.stringmap) then
			local id = tonumber(data);
			if(id) then
				return self.stringmap(id)
			else
				return data;
			end	
		else
			return data;
		end
	end	
end
function opcode_str:write(data)
	if(type(data) == "string") then
		if(self.stringmap) then
			return tostring(self.stringmap(data) or data)
		else
			return data;
		end
	elseif(type(data) == "number") then
		return tostring(data);
	end	
end
Map3DSystem.JGSL.opcode.opcode_str = opcode_str;

---------------------------------------
-- opcode where data part is a jid. jid can be nid without domain. 
---------------------------------------
local opcode_jid = {
	name = "jid",
	refreshrate = 1,
	historycount = 1,
}
function opcode_jid:new(o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end
function opcode_jid:read(data)
	if(type(data) == "string") then
		if(string.find(data, "@")) then
			return data
		else
			return string.format("%s@%s", data, User.ChatDomain or "");
		end
	end	
end
function opcode_jid:write(data)
	if(type(data) == "string") then
		-- remove the domain part. TODO: shall we send domain?
		return string.gsub(data, "@.+", "");
	end	
end
Map3DSystem.JGSL.opcode.opcode_jid = opcode_jid;

---------------------------------------
-- opcode where data part is float with 2 decimal point
---------------------------------------
local opcode_float_d2 = {
	name = "unknown",
	refreshrate = 1,
	historycount = 1,
}
function opcode_float_d2:new(o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end
function opcode_float_d2:read(data)
	if(type(data) == "string") then
		return tonumber(data)
	end	
end
function opcode_float_d2:write(data)
	if(type(data) == "number") then
		return string.format("%.2f", data);
	end	
end
Map3DSystem.JGSL.opcode.opcode_float_d2 = opcode_float_d2;

---------------------------------------
-- opcode where data part is float which is encoded with 2 hex letters, thus only have 256 values between min, and max. 
---------------------------------------
local opcode_float_hex2 = {
	name = "unknown",
	refreshrate = 1,
	historycount = 1,
	min = 0,
	max = 0,
}
function opcode_float_d2:new(o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end
function opcode_float_d2:read(data)
	if(type(data) == "string") then
		return tonumber(data)
	end	
end
function opcode_float_d2:write(data)
	if(type(data) == "number") then
		return string.format("%.2f", data);
	end	
end
Map3DSystem.JGSL.opcode.opcode_float_hex2 = opcode_float_hex2;

---------------------------------------
-- opcode where data part is float which is encoded with 2 hex letters, thus only have 256 values between min, and max. 
---------------------------------------
local opcode_float_hex2 = {
	name = "unknown",
	refreshrate = 1,
	historycount = 1,
	min = 0,
	max = 1,
}
function opcode_float_hex2:new(o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end
function opcode_float_hex2:read(data)
	if(type(data) == "string") then
		local v = tonumber(data, 16)
		if (v) then
			return (self.min + (self.max-self.min)*v/255)
		end
	end	
end
function opcode_float_hex2:write(data)
	if(type(data) == "number") then
		return string.format("%x", math.floor((data - self.min)/(self.max-self.min)*255));
	end	
end
Map3DSystem.JGSL.opcode.opcode_float_hex2 = opcode_float_hex2;

----------------------------------------------
-- constructing all opcodes used in agent streams. 
----------------------------------------------
local opcodes = {
	--[1] = opcode_jid:new({ name="jid",refreshrate=1,historycount=1}),
	[2] = opcode_str:new({ name = "AssetFile",refreshrate = 10,historycount = 5, stringmap=Map3DSystem.JGSL.stringmap.AssetFile}),
	[3] = opcode_float_d2:new({name="rx",refreshrate=5,historycount=2}),
	[4] = opcode_float_d2:new({name="y",refreshrate=5,historycount=2}),
	[5] = opcode_float_d2:new({name="rz",refreshrate=5,historycount=2}),
	[6] = opcode_float_hex2:new({name="facing",refreshrate=5,historycount=2, min=-3.14159, max=3.14159}),
	[7] = opcode_str:new({name = "ccs",refreshrate = 10,historycount = 5, stringmap=Map3DSystem.JGSL.stringmap.ccs}),
	[8] = opcode_str:new({name = "anim",refreshrate = 10,historycount = 5, stringmap=Map3DSystem.JGSL.stringmap.anim}),
}
Map3DSystem.JGSL.opcodes = opcodes;
local opcode_names = {};

-- get opcode parser by its name
function Map3DSystem.JGSL.GetOpcodeParser(name)
	local index = opcode_names[name];
	if(index) then
		return opcodes[index];
	end
end

-- generate opcode to match their index. 
local function BuildOpcodes()
	local index, opcode
	for index, opcode in pairs(opcodes) do
		if(type(index)=="number" and type(opcode)=="table") then
			opcode.opcode = index;
			opcode_names[opcode.name] = index
		end
	end
end
BuildOpcodes();
