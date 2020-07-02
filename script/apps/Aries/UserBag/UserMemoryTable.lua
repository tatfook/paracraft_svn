--[[
Title: 
Author(s): leio
Date: 2012/08/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/UserBag/UserMemoryTable.lua");
local UserMemoryTable = commonlib.gettable("MyCompany.Aries.Inventory.UserMemoryTable");
]]
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/UserBag/UserMemoryTable.lua");
local UserMemoryTable = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Inventory.UserMemoryTable"))
UserMemoryTable.valid_key_map = nil;
UserMemoryTable.nid = nil;
UserMemoryTable.bag = 1002;
UserMemoryTable.gsid_list = {
	985
};
UserMemoryTable.memory_list = nil;
--[[
	UserMemoryTable.memory_list = {
		{ gsid = gsid , used_size = used_size, memory = {   [key] = usedata,
															[key] = usedata,
															[key] = usedata,
														},
		{ gsid = gsid , used_size = used_size, memory = {   [key] = usedata,
															[key] = usedata,
															[key] = usedata,
														},
		{ gsid = gsid , used_size = used_size, memory = {   [key] = usedata,
															[key] = usedata,
															[key] = usedata,
														},
	};
--]]
UserMemoryTable.single_memory_size = 2048;--byte
UserMemoryTable.client_is_init = false;
------------------------------------------------------------------
function UserMemoryTable:FreeSize()
	return self:MaxSize() - self:UsedSize();
end
--reutrn byte
function UserMemoryTable:UsedSize()
	local k,space;
	local size = 0;
	for k,space in ipairs(self.memory_list) do
		size = size + (space.used_size or 0);
	end
	return size;
end
--reutrn byte
function UserMemoryTable:MaxSize()
	local len = #self.gsid_list;
	return len * self.single_memory_size
end
--每个字符按双字节计算
function UserMemoryTable:GetStringSize(s)
	if(not s)then
		return 0;
	end
	local len = ParaMisc.GetUnicodeCharNum(s);
	return len * 2;
end

function UserMemoryTable:Reload(callbackFunc)
	self.memory_list = {};
	GemTranslationHelper.GetItemsInBag(self.nid,self.bag,false,function(msg)
		local k,gsid;
		for k,gsid in ipairs(self.gsid_list) do
			local item = GemTranslationHelper.GetUserItem(nid,gsid);
			if(item)then
				local clientdata = item.clientdata;
				local used_size = self:GetStringSize(clientdata);
				clientdata = commonlib.LoadTableFromString(clientdata);
				if(not clientdata or type(clientdata) ~= "table")then
					clientdata = {};
				end
				local space = {
					gsid = gsid,
					used_size = used_size,
					memory = clientdata,
				}
				table.insert(self.memory_list,space);
			end
		end
		if(callbackFunc)then
			callbackFunc();
		end
	end,"access plus 0 minutes")
end

--if found return true,space
function UserMemoryTable:HasKey(key)
	if(not self:KeyIsValid(key))then
		return
	end
	local k,space;
	for k,space in ipairs(self.memory_list) do
		local memory = space.memory;
		if(memory)then
			local k,__;
			for k,__ in pairs(memory) do
				return true,space;
			end
		end
	end
end
function UserMemoryTable:ClearMemory(gsid)
	if(not gsid)then
		return
	end
	local k,space;
	for k,space in ipairs(self.memory_list) do
		if(space.gsid == gsid)then
			space.memory = {};
		end
	end
	self:SaveMemory(gsid,"");
end
--保存数据到server
function UserMemoryTable:SaveMemory(gsid,memory)
	if(not gsid or not memory)then
		return
	end
	local memory_str = commonlib.serialize_compact2(memory);
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas,guid = hasGSItem(gsid);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			ItemManager.SetClientData(guid,memory_str,function(msg_setclientdata)
				if(callbackFunc)then
					callbackFunc(msg_setclientdata);
				end
			end);
		end
	end
end
--查找一个自由存储空间
function UserMemoryTable:FindFreeSpace(size)
	if(not size or size <= 0)then
		return
	end
	local k,space;
	for k,space in ipairs(self.memory_list) do
		local gsid = space.gsid;
		local used_size = space.used_size;
		if( (used_size + size ) <= self.single_memory_size)then
			return space;
		end
	end
end
function UserMemoryTable:GetData(key)
	if(not self:KeyIsValid(key))then
		LOG.std(nil, "warning","UserMemoryTable:get an invaild key",key);
		return
	end
	local k,space;
	for k,space in ipairs(self.memory_list) do
		local memory = space.memory;
		if(memory)then
			return memory[key];
		end
	end
end
function UserMemoryTable:KeyIsValid(key)
	if(not key)then return end
	return self.valid_key_map[key];
end
--NOTE:不能存储字符串 ~ and |
function UserMemoryTable:SetData(key,value)
	if(not self:KeyIsValid(key))then
		LOG.std(nil, "warning","UserMemoryTable try to set an invaild key",key);
		return
	end
	local value_str = commonlib.serialize_compact2(value);
	if(string.find(value_str, "~") or string.find(value_str, "|")) then
		LOG.std(nil, "error", "UserMemoryTable", "UserMemoryTable:SetData got client data including ~ or | character for input: ".. value_str);
		return;
	end
	local size = self:GetStringSize(value_str);
	if(size > self.single_memory_size or self:FreeSize() <= 0)then
		LOG.std(nil, "warning","UserMemoryTable not enough space to save %s",key);
		return
	end
	local bHas,space = self:HasKey(key);
	--是否已经有key
	if(not bHas)then
		space = self:FindFreeSpace(size);
	end
	if(not space)then
		LOG.std(nil, "warning","UserMemoryTable not free space to save %s",key);
		return
	end
	local gsid = space.gsid;
	local used_size = space.used_size;
	local memory = space.memory;
	--有空余空间
	if((size + used_size) <= self.single_memory_size)then
		if(value == nil)then
			--清空数据
			memory[key] = nil;
			space.used_size  = used_size - size;
		else
			--保存数据
			memory[key] = value;
			space.used_size  = used_size + size;
		end
		self:SaveMemory(gsid,memory);
	end
end
function UserMemoryTable:ctor()
	self:OnInit();
end
function UserMemoryTable:GetConfigPath()
	local path = "config/Aries/UserMemoryDefine/memory_define.xml";
	return path;
end
function UserMemoryTable:OnInit()
	if(not self.nid)then
		return
	end
	self.valid_key_map = {};
	self.memory_list = {};
	local path = self:GetConfigPath();
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	if(xmlRoot)then
		local item;
		for item in commonlib.XPath.eachNode(xmlRoot, "/memory/item") do
			local key = item.attr["key"];
			local datatype = item.attr["datatype"];
			if(key and datatype)then
				self.valid_key_map[key] = true;
			end
		end
	end
end
