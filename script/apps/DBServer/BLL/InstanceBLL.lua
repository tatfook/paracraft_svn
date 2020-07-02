--[[
NPL.load("(gl)script/apps/DBServer/BLL/InstanceBLL.lua");
local InstanceBLL = commonlib.gettable("DBServer.BLL.InstanceBLL");
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/Helper.lua");
NPL.load("(gl)script/apps/DBServer/ErrorCodes.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_router.lua");
NPL.load("(gl)script/apps/DBServer/Entity/ItemStruct.lua");
NPL.load("(gl)script/apps/DBServer/Entity/ItemGSIDs.lua");
NPL.load("(gl)script/apps/DBServer/Entity/ItemStateType.lua");
NPL.load("(gl)script/apps/DBServer/BLL/GlobalStoreBLL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/ServerObjectBLL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/SellInTsBLL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/UserBLL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/GSCntInTimeSpanBLL.lua");
NPL.load("(gl)script/apps/DBServer/Entity/SellInTsEntity.lua");
NPL.load("(gl)script/apps/DBServer/Entity/GSCntInTimeSpanEntity.lua");
NPL.load("(gl)script/apps/DBServer/Entity/InstanceEntity.lua");

local ErrorCodes = commonlib.gettable("DBServer.ErrorCodes");
local ItemStruct = commonlib.gettable("DBServer.ItemStruct");
local ItemAddStruct = commonlib.gettable("DBServer.ItemAddStruct");
local ItemGSIDs = commonlib.gettable("DBServer.ItemGSIDs");
local ItemStateType = commonlib.gettable("DBServer.ItemStateType");
local SellInTsEntity = commonlib.gettable("DBServer.SellInTsEntity");
local GSCntInTimeSpanEntity = commonlib.gettable("DBServer.GSCntInTimeSpanEntity");
local InstanceEntity = commonlib.gettable("DBServer.InstanceEntity");

local Helper = commonlib.gettable("DBServer.Helper");
local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");
local GlobalStoreBLL = commonlib.gettable("DBServer.BLL.GlobalStoreBLL");
local ServerObjectBLL = commonlib.gettable("DBServer.BLL.ServerObjectBLL");
local SellInTsBLL = commonlib.gettable("DBServer.BLL.SellInTsBLL");
local UserBLL = commonlib.gettable("DBServer.BLL.UserBLL");
local GSCntInTimeSpanBLL = commonlib.gettable("DBServer.BLL.GSCntInTimeSpanBLL");

local Array = Helper.Array;


local InstanceBLL = commonlib.gettable("DBServer.BLL.InstanceBLL");

InstanceBLL.tbkey = "instance";
InstanceBLL.strDonateMsgKey = "donateMsg";
InstanceBLL.strDonateFromNID = "donateFromNID";



function InstanceBLL.getMaxPositionInBag(nid, bag, callbackFun)
	InstanceBLL.getInBag(nid, bag, function(_list)
		if(_list and #(_list) > 0) then
			local _, _maxv = Array.max(_list, function(_item)
				return _item.Position;
			end);
			callbackFun(_maxv);
		else
			callbackFun(0);
		end
	end);
end


function InstanceBLL.get(nid, guid, callbackFun)
	DAL_router.select(InstanceBLL.tbkey, {NID = nid, GUID = guid}, callbackFun);
end


function InstanceBLL.getInBag(nid, bag, callbackFun)
	DAL_router.select(InstanceBLL.tbkey, {NID = nid, Bag = bag}, callbackFun);
end


function InstanceBLL.getInBags(nid, bags, callbackFun)
	local _list, _len = {}, (bags and #(bags)) or 0;
	if(_len > 0) then
		Array.forEach(bags, function(_bag)
				InstanceBLL.getInBag(nid, _bag, function(_items)
						if(_items) then
							Array.concat(_list, _items);
						end
						_len = _len - 1;
						if(_len <= 0) then
							callbackFun(_list);
						end
					end);
			end);
	else
		callbackFun(_list);
	end
end


function InstanceBLL.getByGSID(nid, gsid, callbackFun)
	DAL_router.select(InstanceBLL.tbkey, {NID = nid, GSID = gsid}, callbackFun);
end


function InstanceBLL.getByGSIDs(nid, gsids, callbackFun)
	local _list, _len = {}, (gsids and #(gsids)) or 0;
	if(_len > 0) then
		Array.forEach(gsids, function(_gsid)
				InstanceBLL.getByGSID(nid, _gsid, function(_items)
						if(_items) then
							Array.concat(_list, _items);
						end
						_len = _len - 1;
						if(_len <= 0) then
							callbackFun(_list);
						end
					end);
			end);
	else
		callbackFun(_list);
	end
	-- TODO: get all in once
end


function InstanceBLL.purchaseItem(nid, items, callbackFun)
	local _re = {
		ups = {},
		adds = {},
		deltaemoney = 0,
		err = 0
	};
	local _upGsInTss = nil;
	local _gsids = Array.select(items, function(_item)
			return _item.ID;
		end);
	_gsids[#(_gsids) + 1] = ItemGSIDs["魔豆"];
	local _gss = GlobalStoreBLL.gets(_gsids);
	local _bags = Array.distinct(Array.select(_gss, function(_pT)
			return _pT.BagFamily;
		end));

	if(#(_gss) >= #(_gsids) - 1) then
		local _sod = ServerObjectBLL.get(ServerObjectBLL.EMoneyDiscount);
		local _allP, _allE, _allM = 0, 0, 0;
		Array.forEach(items, function(_pT)
				local _gs = Array.find(items, function(_pT2)
						return _pT2.GSID == _pT.ID;
					end);
				_allP = _allP + _gs.PBuyPrice * _pT.Cnt;
				_allE = _allE + _gs.EBuyPrice * _pT.Cnt;
				_allM = _allM + _gs.Count * _pT.Cnt;
			end);
		if(_sod) then
			_allE = math.floor(_allE * tonumber(_sod.Value));
		end
		SellInTsBLL.gets(_gsids, function(_sellInTss)
				local _listGSCntInTime = nil;
				UserBLL.getByNID(nid, function(_pf)
						if(_pf ~= nil) then
							local _pmoney, _emoney = _pf.PMoney, _pf.EMoney;
							if(_pmoney >= _allP and _emoney >= _allE) then
								InstanceBLL.getByGSIDs(nid, _gsids, function(_allexists)
										InstanceBLL.getInBags(nid, _bags, function(_allInBags)
												local _instanceM = Array.find(_allexists, function(_T)
														return _T.GSID == ItemGSIDs["魔豆"];
													end);
												local _existMCnt = (_instanceM and _instanceM.Copies) or 0;
												if(_existMCnt > _allM) then
													local _itemsCnt = #(items);
													local _adds = {};
													local _updates = {};
													local _funForeachItemsAfter = function()
														_itemsCnt = _itemsCnt - 1;
														if(_itemsCnt == 0) then
															if(_re.err == 0 and (#(_adds) > 0 or #(_updates) > 0)) then
																InstanceBLL.handleItems(nid, _updates, _adds, _listGSCntInTime, nil, nil, function(_hdItemRe)
																		_re.adds = _hdItemRe;
																		_re.deltaemoney = -_allE;
																		callbackFun(_re);
																	end);
															else
																callbackFun(_re);
															end
														end
													end;

													for _i = 1, #(items) do
														local _item = items[_i];
														local _gs = Array.find(_gss, function(_T)
																return _T.GSID == _item.id;
															end);
														local _listExists = Array.findAll(_allexists, function(_T)
																return _T.GSID == _item.id;
															end);
														if(_gs.MaxCount == 0 or Array.sum(_listExists, function(_T)
																return _T.Copies;
															end) + _item.cnt <= _gs.MaxCount) then
															if(_gs.HourlyLimitedPurchase > 0 or _gs.DailyLimitedPurchase > 0) then
																local _sellInTs = Array.find(_sellInTss, function(_T)
																		return _T.GSID == _item.id;
																	end);
																if(_sellInTs) then
																	if(_gs.HourlyLimitedPurchase > 0 and _gs.HourlyLimitedPurchase < _sellInTs.InHour + _item.cnt) then
																		_re.err = ErrorCode["超过小时总购买数"];
																	elseif(_gs.DailyLimitedPurchase > 0 and _gs.DailyLimitedPurchase < _sellInTs.InDay + _item.cnt) then
																		_re.err = ErrorCode["超过当天总购买数"];
																	end
																else
																	_sellInTs = SellInTsEntity:new({GSID = _item.id, InDay = 0, InHour = 0, LastUpdate = Helper.DateTime.now()});
																end
																if(_re.err == 0) then
																	_sellInTs.InHour = _sellInTs.InHour + _item.cnt;
																	_sellInTs.InDay = _sellInTs.InDay + _item.cnt;
																	_sellInTs.LastUpdate = Helper.DateTime.now();
																	if(not _upGsInTss) then
																		_upGsInTss = {};
																	end
																	_upGsInTss[#(_upGsInTss) + 1] = _sellInTs;
																end
															end

															if(_re.err == 0) then
																local _funChkInTimeSpanAfter = function()
																		if(_re.err == 0) then
																			local _listInBag = Array.findAll(_allInBags, function(_T)
																					return _T.Bag == _gs.BagFamily;
																				end);
																			local _listExistsInBag = Array.findAll(_listInBag, function(_T)
																					return _T.GSID == _gs.GSID;
																				end);
																			local _json = nil;
																			local _serverData = nil;
																			local _maxdur = _gs:GetStatValue(ItemStateType["装备耐久度"]);
																			if(_maxdur > 0) then
																				_json = {dur = _maxdur};
																			end
																			local _bound = _gs:GetStatValue(ItemStateType["装备绑定方式"]);
																			if(_bound == 2) then
																				if(not _json) then
																					_json = {};
																				end
																				_json.bound = 1;
																			end
																			if(_json) then
																				_serverData = commonlib.Json.Encode(_json);
																			end
																			if(_gs.BagFamily == 0) then
																				local _existInstance = (#(_listExistsInBag) > 0 and _listExistsInBag[1]) or nil;
																				if(not _existInstance and (_gs.MaxCopiesInStack <= 0 or _item.cnt <= _gs.MaxCopiesInStack)) then
																					-- _adds[#(_adds) + 1] = ItemAddStruct:new(_item.id, _gs.Class, _gs.SubClass, _gs.BagFamily, _gs.InventoryType, _item.cnt, _serverData, _item.clientData);
																					_adds[#(_adds) + 1] = InstanceEntity:new({ GUID = 0, NID = nid, GSID = _item.id, ObtainTime = Helper.DateTime.toString(Helper.DateTime.now()), Bag = _gs.BagFamily, Position = _gs.InventoryType, ClientData = (_item.clientData and _item.clientData) or "", ServerData = (_serverData and _serverData) or "", Copies = _item.cnt });
																				elseif(_existInstance and (_gs.MaxCopiesInStack <= 0 or _existInstance.Copies + _item.cnt <= _gs.MaxCopiesInStack)) then
																					-- _updates[#(_updates) + 1] = ItemStruct:new(_existInstance.GUID, _existInstance.Copies + _item.cnt, nil, nil);
																					_existInstance.Copies = _existInstance.Copies + _item.cnt;
																					_updates[#(_updates) + 1] = _existInstance;
																					_re.ups[#(_re.ups) + 1] = {_existInstance.GUID, _existInstance.Bag, _item.cnt};
																				else
																					_re.err = ErrorCode["购买数量超过限制"];
																				end
																			else
																				if(_gs.MaxCopiesInStack <= 0) then
																					if(#(_listExistsInBag) > 0) then
																						local _exist = _listExistsInBag[1];
																						-- _updates[#(_updates) + 1] = ItemStruct:new(_exist.GUID, _exist.Copies + _item.cnt, nil, nil);
																						_exist.Copies = _exist.Copies + _item.cnt;
																						_updates[#(_updates) + 1] = _exist;
																						_re.ups[#(_re.ups) + 1] = {_exist.GUID, _exist.Bag, _item.cnt};
																					else
																						local _p = (#(_listInBag) > 0 and Array.max(_listInBag, function(_T)
																									return _T.Position
																								end) + 1) or 1;
																						-- _adds[#(_adds) + 1] = ItemAddStruct:new(_gs.GSID, _gs.Class, _gs.Subclass, _gs.BagFamily, _p, _item.cnt, _serverData, _item.clientData);
																						_adds[#(_adds) + 1] = InstanceEntity:new({ GUID = 0, NID = nid, GSID = _gs.GSID, ObtainTime = Helper.DateTime.toString(Helper.DateTime.now()), Bag = _gs.BagFamily, Position = _p, ClientData = (_item.clientData and _item.clientData) or "", ServerData = (_serverData and _serverData) or "", Copies = _item.cnt });
																					end
																				else
																					local _Cnt = _item.cnt;
																					for _i = 1, #(_listExistsInBag) do
																						local _exist = _listExistsInBag[_i];
																						local _n = _gs.MaxCopiesInStack - _exist.Copies;
																						if(_n > 0) then
																							if(_n > _Cnt) then
																								_n = _Cnt;
																							end
																							-- _updates[#(_updates) + 1] = ItemStruct:new(_exist.GUID, _n + _exist.Copies, nil, nil);
																							_exist.Copies = _exist.Copies + _n;
																							_updates[#(_updates) + 1] = _exist;
																							_re.ups[#(_re.ups) + 1] = {_exist.GUID, _exist.Bag, _n};
																							_Cnt = _Cnt - _n;
																							if(_Cnt <= 0) then
																								break;
																							end
																						end
																					end
																					if(_Cnt > 0) then
																						local _p = (#(_listInBag) > 0 and Array.max(_listInBag, function(_T)
																									return _T.Position
																								end) + 1) or 1;
																						while _Cnt > 0 do
																							local _n = _Cnt;
																							if(_gs.MaxCopiesInStack < _Cnt) then
																								_n = _gs.MaxCopiesInStack;
																								-- _adds[#(_adds) + 1] = ItemAddStruct:new(_gs.GSID, _gs.Class, _gs.Subclass, _gs.BagFamily, _p, _n, _serverData, _item.clientData);
																								_adds[#(_adds) + 1] = InstanceEntity:new({ GUID = 0, NID = nid, GSID = _gs.GSID, ObtainTime = Helper.DateTime.toString(Helper.DateTime.now()), Bag = _gs.BagFamily, Position = _p, ClientData = (_item.clientData and _item.clientData) or "", ServerData = (_serverData and _serverData) or "", Copies = _n });
																								_p = _p + 1;
																								_Cnt = _Cnt - _n;
																							end
																						end
																					end
																				end
																			end
																		end
																		_funForeachItemsAfter();
																	end;
																if(_gs.MaxDailyCount > 0) then
																	GSCntInTimeSpanBLL.get(nid, _item.id, function(_gscntInTime)
																			if(not _gscntInTime) then
																				_gscntInTime = GSCntInTimeSpanEntity:new({NID = nid, GSID = _item.id});
																			end
																			if(_gscntInTime:isClearWeek()) then
																				_gscntInTime.CntInWeek = 0;
																			end
																			if(_gscntInTime:isClearDay()) then
																				_gscntInTime.CntInDay = 0;
																			end
																			if(_gs.MaxWeeklyCount <= 0 or _gscntInTime.CntInWeek + _item.cnt <= _gs.MaxWeeklyCount) then
																				if(_gscntInTime.CntInDay + _item.cnt <= _gs.MaxDailyCount) then
																					_gscntInTime.CntInWeek = _gscntInTime.CntInWeek + _item.cnt;
																					_gscntInTime.CntInDay = _gscntInTime.CntInDay + _item.cnt;
																					_gscntInTime.LastDate = Helper.DateTime.now();
																					if(not _listGSCntInTime) then
																						_listGSCntInTime = {};
																					end
																					_listGSCntInTime[#(_listGSCntInTime) + 1] = _gscntInTime;
																				else
																					_re.err = ErrorCode["超过单日购买限制"];
																				end
																			else
																				_re.err = ErrorCode["超过周购买限制"];
																			end
																			_funChkInTimeSpanAfter();
																		end);
																else
																	_funChkInTimeSpanAfter();
																end
															end
														else
															_re.err = ErrorCode["购买数量超过限制"];
														end
													end
												else
													_re.err = ErrorCode["魔豆不足"];
												end
												if(_re.err ~= 0) then
													callbackFun(_re);
												end
											end);
									end);
							else
								_re.err = ErrorCode["P币和信用度不够"];
							end
						else
							_re.err = ErrorCode["用户不存在或不可用"];
						end
						if(_re.err ~= 0) then
							callbackFun(_re);
						end
					end);
			end);
			return;
	else
		_re.err = ErrorCodes["数据不存在或已被删除"];
	end
	if(_re.err ~= 0) then
		callbackFun(_re);
	end
end






function InstanceBLL.handleItems(nid, updates, adds, timespans, userpf, uevent, callbackFun)
	local _guids = nil;
	local _upCnt, _addCnt, _tsCnt, _pfCnt, _ueCnt = 0, 0, 0, 0, 0;
	if(updates) then
		_upCnt = #(updates);
	end
	if(adds) then
		_addCnt = #(adds);
	end
	if(timespans) then
		_tsCnt = #(timespans);
	end
	if(userpf) then
		_pfCnt = 1;
	end
	if(uevent) then
		_ueCnt = 1;
	end
	local _funChkOver = function()
			if(_upCnt == 0 and _addCnt == 0 and _tsCnt == 0 and _pfCnt == 0 and _ueCnt == 0) then
				callbackFun(_guids);
			end
		end
	if(_upCnt > 0) then
		Array.forEach(updates, function(_T)
				DAL_router.update(InstanceBLL.tbkey, _T, function(_upRe)
						_upCnt = _upCnt - 1;
						_funChkOver();
					end);
			end);
	end
	if(_addCnt > 0) then
		_guids = {};
		Array.forEach(adds, function(_T)
				DAL_router.insert(InstanceBLL.tbkey, _T, function(_addRe)
						_addCnt = _addCnt - 1;
						if(_addRe.newid) then
							_guids[#(_guids) + 1] = _addRe.newid;
						end
						_funChkOver();
					end);
			end);
	end
	if(_tsCnt > 0) then
		-- TODO:
	end
	if(_pfCnt > 0) then
		UserBLL.update(userpf, function()
				_pfCnt = _pfCnt - 1;
				_funChkOver();
			end);
	end
	if(_ueCnt > 0) then
		-- TODO:
	end
end