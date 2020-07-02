--[[
Title: handle update insert query
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_mem_table.lua");
local DAL_mem_table = commonlib.gettable("DBServer.TableDAL.DAL_mem_table");

local instance_table = DAL_mem_table:new({});
instance_table:LoadFromSchema(schema);
instance_table:Insert();

DAL_mem_table......getByGSID(NID, GSID)
getByBag(NID, bag);

function instance_table:GetByGSID()
	-- 
end

-----------------------------------------------
]]
NPL.load("(gl)script/ide/mysql/mysql.lua");
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_dirty_table.lua");
NPL.load("(gl)script/apps/DBServer/Helper.lua");

local DAL_dirty_table = commonlib.gettable("DBServer.TableDAL.DAL_dirty_table");
local DBSettings = commonlib.gettable("DBServer.DBSettings");
local Helper = commonlib.gettable("DBServer.Helper");
local luasql = commonlib.luasql;

local DAL_mem_table = commonlib.inherit(AsyncTask, commonlib.gettable("DBServer.TableDAL.DAL_mem_table"));

DAL_mem_table.ALLTBNUM = DBSettings.getTBCnt();


function DAL_mem_table:ctor(pParams)
	local o = {};
	o.dbcnf = pParams.dbcnf;
	o.tbname = pParams.tbname;
	o.use_partition = pParams.use_partition;
	o.entity_class = pParams.entity_class;
	o.primarykey_is_auto = pParams.primarykey_is_auto;
	o.primary_key = pParams.primary_key;
	o.primary_key_name = "";
	for _i = 1, #(o.primary_key) do
		if(_i > 1) then
			o.primary_key_name = o.primary_key_name .. "_";
		end
		o.primary_key_name = o.primary_key_name .. o.primary_key[_i];
	end
	o.partition_key = pParams.partition_key;
	o.keys = pParams.keys;
	table.insert(o.keys, {type = "primary", cols = o.primary_key});
	--[[
	for _i = 1, #(self.keys) do
		local _t = self.keys[_i];
		if(_t.type == "primary") then
			self.primaryKey = _t.cols;
		end
	end
	]]
	o.indices = {};
	o.funDbIndex = pParams.funDbIndex;

	setmetatable(o, self);
	self.__index = self;

	return o;
end


--[[
InstanceTable sample data:
{
	partition_key = "nid",
	primary_key = {"guid"},
		   -- type: primary | unique | multiple
	keys = { {type="multiple", cols={"gsid"}}, {type="multiple", cols={"bag"}} },
	indices = {
		["28282828"] = {
			["guid"] = { -- state: 0-正常 1-正在向DB读取  2-已删除或不存在
				["123"] = {state=0, data={guid="123", nid="888", gsid="456"}},
				["234"] = {state=0, data={guid="234", nid="888", gsid="789"}},
				["345"] = {state=0, callbacks={}, data={guid="345", nid="888", gsid="789"}},
			},
			["gsid"] = {
				["456"] = {
					state = 0,
					data = {
						["123"] = {state=0, data={guid="123", nid="123", gsid="456"}}
					}
				},
				["789"] = {
					state = 0,
					data = {
						["234"] = {guid="234", nid="321", gsid="789"},
						["345"] = {guid="345", nid="888", gsid="789"},
					}
				},
			},
			["bag"] = {
				["0"] = {
					state = 0,
					data = {
						["123"] = {guid="123", nid="123", gsid="456"},
					}
				},
				["1"] = {
					state = 0,
					data = {
						["123"] = {guid="123", nid="123", gsid="789"},
						["321"] = {guid="abc3", nid="321", gsid="789"},
					}
				}
			},
		}
	},
}
]]

function DAL_mem_table:getPrimaryKeyIndex(pRow)
	local _primarykey_index = "";
	for _i = 1, #(self.primary_key) do
		if(_i > 1) then
			_primarykey_index = _primarykey_index .. "_";
		end
		--LOG.std(nil, "warn", "XXXXXXXXXXXX", table.concat(self.primary_key, ","));
		--LOG.std(nil, "warn", "YYYYYYYYYYYY", pRow);
		_primarykey_index = _primarykey_index .. pRow[self.primary_key[_i]];
	end
	return _primarykey_index;
end

function DAL_mem_table:cloneToPrimaryData(pData)
	local _re;
	local _region_items;
	if(self.partition_key) then
		local _v = tostring(pData[self.partition_key]);
		if(self.indices[_v]) then
			_region_items = self.indices[_v];
		else
			_region_items = {};
			self.indices[_v] = _region_items;
		end
	else
		_region_items = self.indices;
	end

	local _primarykey_index = self:getPrimaryKeyIndex(pData);
	local _region_primary = _region_items[self.primary_key_name];
	if(not _region_primary) then
		_region_primary = {};
		_region_items[self.primary_key_name] = _region_primary;
	end
	if(not _region_primary[_primarykey_index]) then
		_re = {data = pData};
		_region_primary[_primarykey_index] = _re;
	else
		-- pData = commonlib.partialcopy(pData, _region_primary[_primarykey_index].data);
		-- pData = _region_primary[_primarykey_index].data;
		_re = _region_primary[_primarykey_index];
	end
	-- return pData;
	return _re;
end

-- @param pQuery: { key0=xxx, key1=xxx }
-- @return 
function DAL_mem_table:select(pQuery, callbackFunc)
	if((not self.partition_key) or pQuery[self.partition_key]) then
		local _select_items;
		local _queryKeys, _keys = {}, nil;
		local _k, _v;
		for _k, _v in pairs(pQuery) do
			table.insert(_queryKeys, _k);
		end
		if(#(_queryKeys) > 0) then
			--[[
			if(#self.primary_key == #_queryKeys) then
				local _bl = true;
				table.foreach(_self.primary_key, function(_pT)
					if(not _queryKeys[_pT]) then
						_bl = false;
					end
				end);
				if(_bl) then
					_keys = _t;
				end
			end
			]]
			for _i = 1, #(self.keys) do
				local _t = self.keys[_i];
				if(#(_t.cols) == #(_queryKeys)) then
					if(Helper.Array.trueForAll(_t.cols, function(_T)
						for _j = 1, #(_queryKeys) do
							if(_queryKeys[_j] == _T) then
								return true;
							end
						end
						return false;
					end)) then
						_keys = _t;
					end
				end
			end

			if(_keys) then
				local _region_items;
				if(self.partition_key) then
					local _region_key = tostring(pQuery[self.partition_key]);
					if(self.indices[_region_key]) then
						_region_items = self.indices[_region_key];
					else
						_region_items = {};
						self.indices[_region_key] = _region_items;
					end
				else
					_region_items = self.indices;
				end

				local _index_key = table.concat(_keys.cols, "_");
				local _index_items = _region_items[_index_key];
				if(not _index_items) then
					_index_items = {};
					_region_items[_index_key] = _index_items;
				end

				local _selectkey = "";
				for _i = 1, #(_keys.cols) do
					if(_i > 1) then
						_selectkey = _selectkey .. "_";
					end
					_selectkey = _selectkey .. pQuery[_keys.cols[_i]];
				end

				_select_items = _index_items[_selectkey];

				if(_select_items) then
					if(_select_items.state ~= 1) then
						LOG.std(nil, "warn", "DAL_mem_table:select", "from cache");
						if(_keys.type == "primary") then
							if(_select_items.state == 2) then -- 已删除或不存在
								callbackFunc(nil);
							else
								callbackFunc(_select_items.data);
							end
						else
							local _re = {};
							for _, _d in pairs(_select_items.data) do
								if(_d.state ~= 2) then
									_re[#(_re) + 1] = _d.data;
								end
							end
							if(_keys.type == "unique") then
								callbackFunc((#(_re) > 0 and _re[1]) or nil);
							else
								callbackFunc(_re);
							end
						end
					else
						LOG.std(nil, "warn", "DAL_mem_table:select", "waitting other select");
						_select_items.callbacks = _select_items.callbacks or {};
						_select_items.callbacks[#(_select_items.callbacks)+1] = callbackFunc;
					end
				else
					LOG.std(nil, "warn", "DAL_mem_table:select", "from db");
					local _cbs = commonlib.List:new();
					_cbs:add({fun = callbackFunc});
					_index_items[_selectkey] = {state = 1, callbacks = _cbs};
					-- TODO: 以下修改为异步方式
					self:db_select(_keys, pQuery, function(_pRe)
						_index_items[_selectkey].state = 0;
						if(_keys.type == "primary") then
							if(_pRe) then
								_index_items[_selectkey].data = _pRe;
							else
								_index_items[_selectkey].state = 2;
							end
						elseif(_keys.type == "unique") then
							--local _primarykey_index = "";
							--for _i = 1, #(self.primary_key) do
								--if(_i > 1) then
									--_primarykey_index = _primarykey_index .. "_";
								--end
								--_primarykey_index = _primarykey_index .. _pRe[self.primary_key[_i]];
							--end
							--local _region_primary = _region_items[self.primary_key_name];
							--if(not _region_primary) then
								--_region_primary = {};
								--_region_items[self.primary_key_name] = _region_primary;
							--end
							--if(not _region_primary[_primarykey_index]) then
								--_region_primary[_primarykey_index] = {data = _pRe};
							--else
								--_pRe = commonlib.partialcopy(_region_primary[_primarykey_index].data, _pRe);
							--end
							--_index_items[_selectkey].data = _pRe;
							_index_items[_selectkey].data = _index_items[_selectkey].data or {};
							if(_pRe) then
								_pRe = self:cloneToPrimaryData(_pRe);
								_index_items[_selectkey].data[self:getPrimaryKeyIndex(_pRe.data)] = _pRe;
								if(_pRe.state == 2) then
									_pRe = nil;
								else
									_pRe = _pRe.data;
								end
							else
								_pRe = nil;
							end
						else
							_index_items[_selectkey].data = {};
							local _reList = {};
							if(_pRe) then
								for _i = 1, #(_pRe) do
									-- _pRe[_i] = commonlib.partialcopy(_pRe[_i]);
									_pRe[_i] = self:cloneToPrimaryData(_pRe[_i]);
									_index_items[_selectkey].data[self:getPrimaryKeyIndex(_pRe[_i].data)] = _pRe[_i];
									if(_pRe[_i].state ~= 2) then
										_reList[#(_reList) + 1] = _pRe[_i].data;
									end
								end
							end
							_pRe = _reList;
						end
						--[[
						table.foreach(_index_items[_selectkey].callbacks, function(_pI, _pFun)
							_pFun(_pRe);
						end);
						]]
						while(_cbs:size() > 0) do
							local _cb = _cbs:first();
							_cb.fun(_pRe);
							_cbs:remove(_cb);
						end
					end);
				end
			else
				LOG.std(nil, "warn", "DAL_mem_table:select", "the key is undefined");
			end
		else
			LOG.std(nil, "warn", "DAL_mem_table:select", "queryKeys.length == 0");
		end
	else
		LOG.std(nil, "warn", "DAL_mem_table:select", "params is error");
	end
end



-- 
function DAL_mem_table:delete(row, callbackFun)
	--[[
	local _items = (self.partition_key and self.indices[tostring(row[self.partition_key])]) or self.indices;
	if(_items) then
		local _primaryKey = self:getPrimaryKeyIndex(row);
		for _i = 1, #(self.keys) do
			local _key = self.keys[_i];
			local _indexKey = table.concat(_key.cols, "_");
			if(_items[_indexKey]) then
				if(_key.type == "primary") then
					_items[_indexKey][_primaryKey] = nil;
				else
					for _, _v in pairs(_items[_indexKey]) do
						if(_v.data) then
							_v.data[_primaryKey] = nil;
						end
					end
				end
			end
		end
	end
	]]

	local _items = (self.partition_key and self.indices[tostring(row[self.partition_key])]) or self.indices;
	if(not _items and self.partition_key) then
		_items = {};
		self.indices[tostring(row[self.partition_key])] = _items;
	end
	local _primaryReg = _items[self.primary_key_name];
	if(not _primaryReg) then
		_primaryReg = {};
		_items[self.primary_key_name] = _primaryReg;
	end
	local _primaryKey = self:getPrimaryKeyIndex(row);
	local _item = _primaryReg[_primaryKey];
	if(not _item) then
		_item = {data = row};
		_primaryReg[_primaryKey] = _item;
	end
	_item.state = 2;

	DAL_dirty_table.put(self, _item);

	if(callbackFun) then
		--LOG.std(nil, "warn", "test AAAA", self.indices);
		callbackFun(true);
	end
end

-- 
function DAL_mem_table:update(row, callbackFun)
	--[[
	local _items = (self.partition_key and self.indices[tostring(row[self.partition_key])]) or self.indices;
	if(_items) then
		local _primaryDatas = _items[self.primary_key_name];
		if(_primaryDatas) then
			local _old = _primaryDatas[self:getPrimaryKeyIndex(row)];
			if(_old) then
				commonlib.partialcopy(_old.data, row);
			end
		end
	end
	]]

	local _items = (self.partition_key and self.indices[tostring(row[self.partition_key])]) or self.indices;
	if(not _items and self.partition_key) then
		_items = {};
		self.indices[tostring(row[self.partition_key])] = _items;
	end
	local _primaryReg = _items[self.primary_key_name];
	if(not _primaryReg) then
		_primaryReg = {};
		_items[self.primary_key_name] = _primaryReg;
	end
	local _primaryKey = self:getPrimaryKeyIndex(row);
	local _item = _primaryReg[_primaryKey];
	if(not _item) then
		_item = {data = row};
		_primaryReg[_primaryKey] = _item;
	end

	for _i = 1, #(self.keys) do
		local _key = self.keys[_i];
		if(_key.type ~= "primary") then
			local _indexKey = table.concat(_key.cols, "_");
			if(_items[_indexKey]) then
				local _keyName = "";
				for _j = 1, #(_key.cols) do
					if(_j > 1) then
						_keyName = _keyName .. "_";
					end
					_keyName = _keyName .. row[_key.cols[_j]];
				end
				if(not _items[_indexKey][_keyName] or not _items[_indexKey][_keyName].data or not _items[_indexKey][_keyName].data[_primaryKey]) then
					for _k, _v in pairs(_items[_indexKey]) do
						local _data = _v.data;
						if(_data) then
							if(_k == _keyName) then
								_data[_primaryKey] = _item;
							else
								_data[_primaryKey] = nil;
							end
						end
					end
				end
			end
		end
	end

	DAL_dirty_table.put(self, _item);

	if(callbackFun) then
		callbackFun(true);
	end
end

-- internal function:
function DAL_mem_table:insert_mem(row)
	local _newItem = {data = row};
	local _items = (self.partition_key and self.indices[tostring(row[self.partition_key])]) or self.indices;
	if(not _items and self.partition_key) then
		_items = {};
		self.indices[tostring(row[self.partition_key])] = _items;
	end
	if(_items) then
		local _primaryKey = self:getPrimaryKeyIndex(row);
		for _i = 1, #(self.keys) do
			local _key = self.keys[_i];
			local _indexKey = table.concat(_key.cols, "_");
			local _indexV = _items[_indexKey];
			if(not _indexV) then
				_indexV = {};
				_items[_indexKey] = _indexV
			end
			if(_key.type == "primary") then
				_indexV[_primaryKey] = _newItem;
			else
				local _theKey = "";
				for _k = 1, #(_key.cols) do
					if(_k > 1) then
						_theKey = _theKey .. "_";
					end
					local _kv = row[_key.cols[_k]];
					if(_kv ~= nil) then
						_theKey = _theKey .. _kv;
					else
						return;
					end
				end
				if(_indexV[_theKey]) then
					local _data = _indexV[_theKey].data;
					if(not _data) then
						_data = {};
						_indexV[_theKey].data = _data;
					end
					_data[_primaryKey] = _newItem;
				end
			end
		end
	end
	return _newItem;
end


function DAL_mem_table:insert(row, callbackFun)
	if(self.primarykey_is_auto) then
		self:db_insert_async(row, function(dbRe)
			if(dbRe and dbRe.newid) then
				row[self.primary_key_name] = dbRe.newid;
				self:insert_mem(row);
				if(callbackFun) then
					callbackFun(row);
				end
			else
				callbackFun(nil);
			end
		end);
	else
		local _newItem = self:insert_mem(row);
		_newItem.isnew = true;
		DAL_dirty_table.put(self, _newItem);

		if(callbackFun) then
			--LOG.std(nil, "warn", "test BBBBB", self.indices);
			callbackFun(row);
		end	
	end
end



function DAL_mem_table:getTableName(row)
	if(self.use_partition) then
		if(row[self.partition_key]) then
			return self.tbname .. tostring(tonumber(row[self.partition_key]) % DAL_mem_table.ALLTBNUM);
		else
			commonlib.log("DAL_mem_table:getTableName() nid not in row");
			return nil;
		end
	end
	return self.tbname;
end

function DAL_mem_table:db_select(keys, query, callbackFun)
	local _tbname = self:getTableName(query);
	if(_tbname) then
		local _sql = "select * from `" .. _tbname .. "` where ";
		for _i = 1, #(keys.cols) do
			if(_i > 1) then
				_sql = _sql .. " and ";
			end
			_sql = _sql .. keys.cols[_i] .. "=";
			local _v = query[keys.cols[_i]];
			local _type = type(_v);
			if(_type == "string") then
				_sql = _sql .. "\"" .. _v:gsub("\"", "\\\"") .. "\"";
			elseif(_type == "number") then
				_sql = _sql .. tostring(_v);
			else
				LOG.std(nil, "warn", "DAL_mem_table:db_select", "not support the type");
				callbackFun(nil);
				return;
			end
		end

		LOG.std(nil, "warn", "DAL_mem_table:db_select", _sql);
		if(keys.type == "primary" or keys.type == "unique") then
			callbackFun(self:db_exec_reader(_sql));
		else
			callbackFun(self:db_exec_reader_mul(_sql));
		end
	else
		LOG.std(nil, "warn", "DAL_mem_table:db_select", "the row is not contain partitionkey");
	end
end


function DAL_mem_table:gensql_delete(row)
	local _tbname = self:getTableName(row);
	if(_tbname) then
		local _sql = "delete from `" .. _tbname .. "` where ";
		for _i = 1, #(self.primary_key) do
			if(_i > 1) then
				_sql = _sql .. " and ";
			end
			_sql = _sql .. self.primary_key[_i] .. "=";
			local _v = row[self.primary_key[_i]];
			local _type = type(_v);
			if(_type == "string") then
				_sql = _sql .. "\"" .. _v:gsub("\"", "\\\"") .. "\"";
			elseif(_type == "number") then
				_sql = _sql .. tostring(_v);
			else
				LOG.std(nil, "warn", "DAL_mem_table:gensql_delete", "not support the type");
				return nil;
			end
		end
		return _sql;
	else
		LOG.std(nil, "warn", "DAL_mem_table:gensql_delete", "the row is not contain partitionkey");
		return nil;
	end
end

function DAL_mem_table:db_delete(row)
	local _sql = self:gensql_delete(row);
	if(_sql) then
		LOG.std(nil, "warn", "DAL_mem_table:db_delete", _sql);
		self:db_exec_nonQuery(_sql);
	end
end


function DAL_mem_table:db_update_async(row, callbackFunc)
	-- TODO: make this async
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		self:db_update(row);
	end})
	mytimer:Change(200);
end


function DAL_mem_table:gensql_update(row)
	local _tbname = self:getTableName(row);
	if(_tbname) then
		local _sql = "update `" .. _tbname .. "` set ";
		local _c = 0;
		for _k, _v in pairs(row) do
			local _bl = true;
			for _i = 1, #(self.primary_key) do
				if(self.primary_key[_i] == _k) then
					_bl = false;
					break;
				end
			end
			if(_bl) then
				if(_c > 0) then
					_sql = _sql .. ",";
				end
				_sql = _sql .. "`" .. _k .. "`=";
				local _t = type(_v);
				if(_t == "string") then
					_sql = _sql .. "\"" .. _v:gsub("\"", "\\\"") .. "\"";
				elseif(_t == "number") then
					_sql = _sql .. tostring(_v);
				else
					LOG.std(nil, "warn", "DAL_mem_table:gensql_update", "not support the type: " .. _t);
					return nil;
				end
				_c = _c + 1;
			end
		end
		_sql = _sql .. " where ";
		for _i = 1, #(self.primary_key) do
			if(_i > 1) then
				_sql = _sql .. " and ";
			end
			_sql = _sql .. self.primary_key[_i] .. "=";
			local _v = row[self.primary_key[_i]];
			local _type = type(_v);
			if(_type == "string") then
				_sql = _sql .. "\"" .. _v:gsub("\"", "\\\"") .. "\"";
			elseif(_type == "number") then
				_sql = _sql .. tostring(_v);
			else
				LOG.std(nil, "warn", "DAL_mem_table:gensql_update", "not support the type: " .. _t);
				return nil;
			end
		end
		return _sql;
	else
		LOG.std(nil, "warn", "DAL_mem_table:gensql_update", "the row is not contain partitionkey");
		return nil;
	end
end

function DAL_mem_table:db_update(row)
	local _sql = self:gensql_update(row);
	if(_sql) then
		LOG.std(nil, "warn", "DAL_mem_table:db_update", _sql);
		self:db_exec_nonQuery(_sql);
	end
end


function DAL_mem_table:db_insert_async(row, callbackFunc)
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		local res = self:db_insert(row)
		if(callbackFunc) then
			callbackFunc(res);
		end
	end})
	mytimer:Change(200);
end


function DAL_mem_table:gensql_insert(row)
	local _tbname = self:getTableName(row);
	if(_tbname) then
		local _sql = "insert into `" .. _tbname .. "`(";
		local _c = 0;
		local _vs = {};
		for _k, _v in pairs(row) do
			local _bl = true;
			if(self.primarykey_is_auto) then
				for _i = 1, #(self.primary_key) do
					if(self.primary_key[_i] == _k) then
						_bl = false;
						break;
					end
				end
			end
			if(_bl) then
				if(_c > 0) then
					_sql = _sql .. ",";
				end
				_sql = _sql .. _k;
				local _t = type(_v);
				local _v2 = _v;
				if(_t == "string") then
					_v2 = "\"" .. _v:gsub("\"", "\\\"") .. "\"";
				elseif(_t == "number") then
					_v2 = tostring(_v);
				else
					LOG.std(nil, "warn", "DAL_mem_table:gensql_insert", "not support the type: " .. _t);
					return nil;
				end
				_vs[#(_vs) + 1] = _v2;
				_c = _c + 1;
			end
		end
		_sql = _sql .. ") values(" .. table.concat(_vs, ",") .. ")";
		return _sql;
	else
		LOG.std(nil, "warn", "DAL_mem_table:gensql_insert", "the row is not contain partitionkey");
		return nil;
	end
end

function DAL_mem_table:db_insert(row)
	local _sql = self:gensql_insert(row);
	if(_sql) then
		LOG.std(nil, "warn", "DAL_mem_table:db_insert", _sql);
		self:db_exec_nonQuery(_sql, self.primarykey_is_auto);
	end
end


function DAL_mem_table:db_execMulSql(pSqls)
	if(pSqls and #(pSqls) > 0) then
		local _cn = self:db_createCn();
		for i = 1, #(pSqls) do
			local _sql = pSqls[i];
			if(_sql) then
				assert(_cn.cn:execute(_sql));
			end
		end
		_cn.cn:close();
		_cn.env:close();
	end
end



function DAL_mem_table:db_createCn()
	local _env = assert(luasql.mysql());
	return {env = _env, cn = _env:connect(self.dbcnf["Initial Catalog"], self.dbcnf["user id"], self.dbcnf["password"], self.dbcnf["Data Source"])};
end


function DAL_mem_table:db_exec_nonQuery(sql, returnAutoId)
	local _cn = self:db_createCn();
	local _re = assert(_cn.cn:execute(sql));

	local _reTb = {re = _re};

	if(returnAutoId) then
		local _re1 = assert(_cn.cn:execute("select @@identity"));
		local _identity = _re1:fetch ({}, "n");
		if _identity then
			_reTb.newid = _identity[1];
		end
	end

	_cn.cn:close();
	_cn.env:close();
	return _reTb;
end

function DAL_mem_table:db_exec_reader(sql)
	local _re = nil;
	local _cn = self:db_createCn();
	local _cur = assert(_cn.cn:execute(sql));
	local _row = _cur:fetch ({}, "a");
	if(_row) then
		_re = self.entity_class:clone(_row);
	end
	_cur:close();
	_cn.cn:close();
	_cn.env:close();
	return _re;
end

function DAL_mem_table:db_exec_reader_mul(sql, ctoFun)
	local _list = {};
	local _cn = self:db_createCn();
	local _cur = assert(_cn.cn:execute(sql));
	local _row = _cur:fetch ({}, "a");
	while _row do
		table.insert(_list, self.entity_class:clone(_row));
		_row = _cur:fetch(_row, "a");
	end
	_cur:close();
	_cn.cn:close();
	_cn.env:close();
	return _list;
end

