--[[
Title: opcode is used to encode/decode agent streams. 
Author(s): LiXizhi
Date: 2009/7/29
Desc: agent streams are encoded with arrays of {opcode:data},
the following is a mapping from opcodes to their specification. 
	opcode.name: name of the opcode. it is also the key to the actual data in agent structure. 
	opcode.refreshrate: the data represented by the opcode needs to be refreshed with client or server at this rate. 
	opcode.reader: a reader function to decode string data to their real data
	opcode.writer: a writer function to encode real data to their string data. 
an agent stream to be transmitted via network is often of the following format

	"opcode:encoded_data\nopcode:encoded_data\n..."
	
encoded_data must be a string without \n separator.

e.g. 1:this is a string\n2:200.00;20.00;200.00\n3:3.14\n

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_opcode.lua");
local opcodes = commonlib.gettable("Map3DSystem.GSL.opcodes");
local rt_opcodes = commonlib.gettable("Map3DSystem.GSL.rt_opcodes");
local opcode_names = commonlib.gettable("Map3DSystem.GSL.opcode_names");

commonlib.echo(opcodes[opcode_names.AssetFile]:read("2"))  --> "character/v3/Elf/Female/ElfFemale.xml"
commonlib.echo(opcodes[opcode_names.AssetFile]:read("character/v3/Elf/Female/ElfFemale.xml"))  --> "character/v3/Elf/Female/ElfFemale.xml"
commonlib.echo(opcodes[opcode_names.AssetFile]:write("character/v3/Elf/Female/ElfFemale.xml"))  --> "2"

commonlib.echo(opcodes[opcode_names.rx]:read("2000.12"))  --> 2000.12
commonlib.echo(opcodes[3]:write(2000.1234))  --> "2000.12"
commonlib.echo(opcodes[3]:write("123"))  --> nil

commonlib.echo(opcodes[6]:read("ff"))  --> 3.14
commonlib.echo(opcodes[6]:read("7f")) --> 0 
commonlib.echo(opcodes[6]:write(3.14))  --> fe
commonlib.echo(opcodes[6]:write(0))  --> 7f

commonlib.echo(rt_opcodes[opcode_names.chat]:read("hello world"))  --> "hello world"
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_stringmap.lua");

local tonumber = tonumber;
local tostring = tostring;
local format = format;
local string_format = string.format;
local string_find = string.find;
local string_gsub = string.gsub;
local type = type;

local math_floor = math.floor
local User = commonlib.gettable("Map3DSystem.User");
local opcode = commonlib.gettable("Map3DSystem.GSL.opcode");

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

-- TODO: 2011.1.9: what happens if data contains separator"\n", we need to get rid of it. 
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
opcode.opcode_str = opcode_str;

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
		if(string_find(data, "@")) then
			return data
		else
			return format("%s@%s", data, User.ChatDomain or "");
		end
	end	
end
function opcode_jid:write(data)
	if(type(data) == "string") then
		-- remove the domain part. TODO: shall we send domain?
		return string_gsub(data, "@.+", "");
	end	
end
opcode.opcode_jid = opcode_jid;

---------------------------------------
-- opcode where data part is a nid (string only)
---------------------------------------
local opcode_nid = {
	name = "nid",
	refreshrate = 1,
	historycount = 1,
}

function opcode_nid:new(o)
	o = o or {}   
	setmetatable(o, self)
	self.__index = self
	return o
end

function opcode_nid:read(data)
	return tostring(data);
end

function opcode_nid:write(data)
	return tostring(data);
end
opcode.opcode_nid = opcode_nid;

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
		return format("%f", data);
	end	
end
opcode.opcode_float_d2 = opcode_float_d2;

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
		return format("%f", data);
	end	
end
opcode.opcode_float_hex2 = opcode_float_hex2;

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
		return string_format("%x", math_floor((data - self.min)/(self.max-self.min)*255));
	end	
end
opcode.opcode_float_hex2 = opcode_float_hex2;

----------------------------------------------
-- constructing all opcodes used in agent streams. 
----------------------------------------------

-- opcodes for normal update
local opcodes = {
	--[2] = opcode_str:new({ name = "AssetFile",refreshrate = 10,historycount = 5, stringmap=Map3DSystem.GSL.stringmap.AssetFile}),
	[3] = opcode_float_d2:new({name="rx",refreshrate=5,historycount=2}),
	[4] = opcode_float_d2:new({name="y",refreshrate=5,historycount=2}),
	[5] = opcode_float_d2:new({name="rz",refreshrate=5,historycount=2}),
	[6] = opcode_float_hex2:new({name="facing",refreshrate=5,historycount=2, min=-3.14159, max=3.14159}),
	[7] = opcode_str:new({name = "ccs",refreshrate = 10,historycount = 5, stringmap=Map3DSystem.GSL.stringmap.ccs}),
	-- [8] = opcode_str:new({name = "anim",refreshrate = 10,historycount = 5, stringmap=Map3DSystem.GSL.stringmap.anim}),
}
Map3DSystem.GSL.opcodes = opcodes;

-- opcodes for real time update
local rt_opcodes = {
	[9] = opcode_str:new({name = "chat", stringmap=Map3DSystem.GSL.stringmap.chat}),
	[10] = opcode_str:new({name = "action", stringmap=Map3DSystem.GSL.stringmap.action}),
	[11] = opcode_str:new({name = "sig", stringmap=Map3DSystem.GSL.stringmap.sig}),
	[12] = opcode_str:new({name = "anim", stringmap=Map3DSystem.GSL.stringmap.anim}),
}
Map3DSystem.GSL.rt_opcodes = rt_opcodes;

-- this is a mapping from opcode name to their id. 
local opcode_names = commonlib.gettable("Map3DSystem.GSL.opcode_names");

-- get opcode parser by its name
function Map3DSystem.GSL.GetOpcodeParser(name)
	local index = opcode_names[name];
	if(index) then
		return opcodes[index] or rt_opcodes[index];
	end
end

-- generate opcode to match their index. 
local function BuildOpcodes()
	local index, opcode
	for index, opcode in pairs(opcodes) do
		if(type(index)=="number" and type(opcode)=="table") then
			opcode.opcode = index;
			opcode_names[opcode.name] = index;
		end
	end
	
	for index, opcode in pairs(rt_opcodes) do
		if(type(index)=="number" and type(opcode)=="table") then
			opcode.opcode = index;
			opcode_names[opcode.name] = index
		end
	end
end
BuildOpcodes();

----------------------------------------------
-- constructing all opcodes used in agent streams. 
----------------------------------------------
local GetOpcodeParser = Map3DSystem.GSL.GetOpcodeParser

-- generate a new stream string from name, value pair. this function is usually called on server side. 
-- @param name: supported opcode name, such as "chat".
-- @param value: value 
-- @param stream: if nil, a new stream will be returned. otherwise the generated stream will be appended to the last_stream in the returned message. 
function Map3DSystem.GSL.SerializeToStream(name, value, stream)
	local opcode_parser = GetOpcodeParser(name);
	if(opcode_parser) then
		value = opcode_parser:write(value);
		if(value~=nil) then
			if(stream) then
				stream = format("%s\n%d:%s", stream, opcode_parser.opcode, value);
			else
				stream = format("%d:%s", opcode_parser.opcode, value);
			end
		end	
	end
	return stream;
end
