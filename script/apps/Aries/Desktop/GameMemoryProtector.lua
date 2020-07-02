--[[
Title: Memory protector
Author(s): LiXizhi
Date: 2013/1/3
Desc:  protect the game from Software like CE(CheatEngine) to modify core game memory like System.User.nid
It makes a checkpoint of core memory location and periodically check if they are modified. 
One can add memory locations to this file. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GameMemoryProtector.lua");
local GameMemoryProtector = commonlib.gettable("MyCompany.Aries.Desktop.GameMemoryProtector");

-- call this when anything changed. the value can be string, number or pure data table
GameMemoryProtector.CheckPoint("System.User.nid");
GameMemoryProtector.CheckPoint("System.Item.ItemManager.bags", itemlist, GameMemoryProtector.hash_func_item_bag, 0);
-------------------------------------------------------
]]
local GameMemoryProtector = commonlib.gettable("MyCompany.Aries.Desktop.GameMemoryProtector");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

local static_memory_location = {
	{name = "System.User.nid", value = nil},
}

--local check_interval = 3000;
local check_interval = 15000;

local static_memory_location_map = {};
local _, mem_value;
for _, mem_value in ipairs(static_memory_location) do
	static_memory_location_map[mem_value.name] = mem_value;
end

-- get the md5 hash 
local function get_md5(value)
	local type_value = type(value)
	if(type_value == "table") then
		value = commonlib.serialize_compact(value);
	elseif(type_value == "number") then
		value = tostring(value);
	elseif(type_value == "string") then
	else
		return;
	end
	return ParaMisc.md5(value);
end

GameMemoryProtector.hash_func_md5 = get_md5;

-- only used to check for bag items. 
function GameMemoryProtector.hash_func_item_bag(value, bag)
	if(type(value) == "table") then
		local data = value[bag];
		if(data) then
			local hash = 0;
			local i, guid
			for i, guid in ipairs(data) do
				local item = ItemManager.GetItemByGUID(guid);
				if(item) then
					hash = hash + guid * i * (item.gsid or 1);
				end
			end
			return hash;
		end
	end
end

-- save all static memory locations to md5 hidden memory location. 
-- @param name: if nil, it will checkpoint all values. otherwise, it will only checkpoint the given value.  Such as "System.User.nid"
-- if the name does not exist, it will be added and checked thereafterwards. 
-- call this when anything changed. the name's  value can be string, number or pure data table
-- @param value: if nil, it will be read using commonlib.getfield(name). However it is recommended to provide a temporary copy of the input table just in case CheatEngine lock the memory position. 
-- @param hash_func: the hash function(name). if nil, it will simply hash using md5 
-- @param param1: additional parameter passed to hash function as second parameter;
function GameMemoryProtector.CheckPoint(name, value, hash_func, param1)
	if(System.options.isAB_SDK) then
		-- ignore memory protection for SDK version 
		return;
	end
	if(not name) then
		local _, mem_value;
		for _, mem_value in ipairs(static_memory_location) do
			mem_value.value = (mem_value.hash_func or get_md5)(commonlib.getfield(mem_value.name), mem_value.param1);
		end
	else
		local mem_value = static_memory_location_map[name];
		if(not mem_value) then
			mem_value = {name = name };
			static_memory_location[#static_memory_location+1] = mem_value;
			static_memory_location_map[name] = mem_value;
		end
		if(mem_value) then
			mem_value.hash_func = hash_func;
			mem_value.param1 = param1;
			if(value == nil) then
				value = commonlib.getfield(mem_value.name)
			end
			mem_value.value = (hash_func or get_md5)(value, param1);
		end
	end
	GameMemoryProtector.StartMonitor();
end

-- start the protector
function GameMemoryProtector.StartMonitor()
	GameMemoryProtector.timer = GameMemoryProtector.timer or commonlib.Timer:new({callbackFunc = function(timer)
		GameMemoryProtector.DoCheck();
	end})
	if(not GameMemoryProtector.timer:IsEnabled()) then
		GameMemoryProtector.timer:Change(check_interval,check_interval);
	end
end

-- this function is called periodically every minute. One can also call it programmatically. 
function GameMemoryProtector.DoCheck()
	local _, mem_value;
	for _, mem_value in ipairs(static_memory_location) do
		local value = (mem_value.hash_func or get_md5)(commonlib.getfield(mem_value.name), mem_value.param1);
		if(mem_value.value ~= value) then
			paraworld.PostLog({action = "memory_protector", msg="user modified memory"}, "memory_protector", function(msg) end);

			Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft", startup_msg=[[发现你的内存有修改! 请不要使用第三方软件修改游戏，否则会封IP或封号处理]]});
		end
	end
end

function GameMemoryProtector.StopMonitor()
	if(GameMemoryProtector.timer) then
		GameMemoryProtector.timer:Change();
	end
end