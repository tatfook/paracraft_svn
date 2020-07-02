--[[
Title: item system inventory
Author(s): WangTian
Date: 2009/5/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.inventory.lua");
-------------------------------------------------------
]]

-- create class
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.extendedcost.lua");
local inventory = commonlib.gettable("paraworld.inventory");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
local isLogInventoryTraffic = true;
local LOG = LOG;

-- public: helper function
-- secretly update the bag items of the current user in the local db store. 
-- @param update: a table of {copies=number, cnt=number, guid=number, serverdata=string or nil}
-- @param is_add_copies: if true, update.copies will be added. One can negate the sign of update.copies if one wants to substract. 
-- @return is_succeed, final_item; is_succeed is true if succeed, the second parameter is the updated final item in local db. 
function paraworld.inventory.UpdateItemsInBag(bag, update, is_add_copies)
	-- stack to existing items
	local copies = update.cnt or update.copies or 0;
	local guid = update.guid;
	local serverdata = update.newsvrdata or update.serverdata or update.svrdata;
	if(not guid or guid == -1) then
		return;
	end

	local ls = System.localserver.CreateStore(nil, 3);
	if(not ls) then
		return;
	end

	local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
	local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", bag, "nid", Map3DSystem.User.nid})
	local item = ls:GetItem(url_getitemsinbag)
	if(item and item.entry and item.payload) then
		local output_msg = commonlib.LoadTableFromString(item.payload.data);
		if(output_msg and output_msg.items) then
			-- update the copies
			local _, item;
			local final_item;
			for _, item in ipairs(output_msg.items) do
				if(item.guid == guid) then
					if(is_add_copies) then
						item.copies = item.copies + copies;
					else
						item.copies = copies;
					end
					if(serverdata) then
						item.serverdata = serverdata;
					end
					
					final_item = item;
					break;
				end
			end
			-- make entry
			local item = {
				entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
				payload = System.localserver.WebCacheDB.PayloadInfo:new({
					status_code = System.localserver.HttpConstants.HTTP_OK,
					data = (output_msg),
				}),
			}
			-- save to database entry
			local res = ls:PutItem(item);
			if(res) then 
				LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server", tostring(url_getitemsinbag));
				return true, final_item;
			else	
				LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server", tostring(url_getitemsinbag))
				LOG.std("", "warning","Inventory", output_msg);
			end
		end
	end
end

-- public: helper function
-- secretly update the bag items of the current user in the local db store. 
-- @param bag:  if nil, add.bag is used.
-- @param add: a table of {copies|cnt=number, guid=number, gsid=number, [svrdata|serverdata], [clientdata], [pos]}
-- @return is_success, new_item. is_success is true if succeed;new_item is the newly added item. 
function paraworld.inventory.AddItemsInBag(bag, add)
	if(not add) then
		return;
	end
	-- stack to existing items
	local copies = add.cnt or add.copies or 0;
	local guid = add.guid;
	bag = bag or add.bag;

	if(guid == -1) then
		return;
	end

	local ls = System.localserver.CreateStore(nil, 3);
	if(not ls) then
		return;
	end

	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(add.gsid);
	if(gsItem) then
		local bagfamily = gsItem.template.bagfamily;
		local inventorytype = gsItem.template.inventorytype;

		-- newly created items
		local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
		local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", bag, "nid", Map3DSystem.User.nid})
		local item = ls:GetItem(url_getitemsinbag)
		if(item and item.entry and item.payload) then
			local output_msg = commonlib.LoadTableFromString(item.payload.data);
			if(output_msg and output_msg.items) then
				-- add item into bag
				local isExist;
				local new_item;
				local _, item;
				for _, item in ipairs(output_msg.items) do
					if(item.guid == guid) then
						item.copies = item.copies + copies;
						-- item already exist in bag with the same guid
						LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(guid).." Count appended.");
						isExist = true;
						new_item = item;
						break;
					end
				end

				if(not isExist) then
					local position = add.pos;
					if(not position) then
						-- find the largest position in the bag if not specified. 
						local _, item_t;
						local max_position = 0;
						for _, item_t in pairs(output_msg.items) do
							if(item_t.position > max_position) then
								max_position = item_t.position;
							end
						end
						position = max_position + 1;
						if(inventorytype ~= 0 and bagfamily == 0) then
							-- inventorytype specifies the position of the item if bagfamily is 0
							position = inventorytype;
						elseif(inventorytype == 0 and bagfamily == 0 and add.gsid == 998) then
							-- energy stone
							position = inventorytype;
						elseif(inventorytype == 0 and bagfamily == 0) then
							LOG.std("", "error","Inventory", " inventorytype and bagfamily are both 0 for gsid:"..add.gsid..", check global store item template");
							return;
						end
					end
					
					new_item = {
						guid = add.guid, 
						gsid = add.gsid,
						obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
						-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
						position = position,
						clientdata = add.clientdata or "",
						serverdata = add.svrdata or add.serverdata or "",
						copies = copies,
					};
					table.insert(output_msg.items, new_item);
				end
				-- make entry
				local item = {
					entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
					payload = System.localserver.WebCacheDB.PayloadInfo:new({
						status_code = System.localserver.HttpConstants.HTTP_OK,
						data = (output_msg),
					}),
				}
				-- save to database entry
				local res = ls:PutItem(item);
				if(res) then 
					LOG.std("", "debug","Inventory", "Bag Items of %s added to local server", tostring(url_getitemsinbag));
					return true, new_item;
				else	
					LOG.std("", "warn","Inventory", "failed adding bag items of %s to local server", tostring(url_getitemsinbag))
					LOG.std("", "warn","Inventory", output_msg);
				end
			end
		end
	else
		
	end
end


--[[
	/// <summary>
	/// get all bag ids in the inventory that has at least one item in the bag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "bagids" ] = string  // bag ids separated with ","
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
-- NOTE: this service call is not commonly invoked, because the bag ids are implicitly defined in item system.
paraworld.create_wrapper("paraworld.inventory.GetMyBags", "%MAIN%/API/Items/GetMyBags.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetMyBags msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetMyBags msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// get all items in the specific bag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "nid" ] = int  // nid of the user, if nid is provided, sessionkey is omited
	///		[ "sessionkey" ] = string  // session key
	///		[ "bag" ] = string  // bag to be searched
	/// }
	/// </param>
	/// <returns>
	///		[ "items" ] = list{
	///			guid = int  // item instance id
	///			gsid = int
	///			obtaintime = string
	///			position = int
	///			clientdata = string
	///			serverdata = string
	///			copies = int
	///			}  // item count depending on the bag item count
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
local getitemsinbag_cache_policy = "access plus 10 minutes";
paraworld.create_wrapper("paraworld.inventory.GetItemsInBag", "%MAIN%/API/Items/GetItemsInBag.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	msg.nid = tonumber(msg.nid or Map3DSystem.User.nid);
	msg.bag = tonumber(msg.bag);
	
	-- cache policy
	local cache_policy = msg.cache_policy or getitemsinbag_cache_policy;
	if(type(cache_policy) == "string") then
		cache_policy = System.localserver.CachePolicy:new(cache_policy);
	end
	msg.cache_policy = nil;
	
	msg.isfirstinvokeincurrentloginsession = nil;
	
	-- always get from local server if offline mode
	if(paraworld.OfflineMode) then
		cache_policy = System.localserver.CachePolicies["always"];
	end
	
	local ls = System.localserver.CreateStore(nil, 3);
	if(not ls) then
		return;
	end
	
	if(msg.bag) then
		-- if local server has an unexpired result, remove the uid from msg.uid and return the result to callbackFunc otherwise, continue. 
		local HasResult;
		-- make url
		local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "bag", msg.bag, "nid", msg.nid})
		local item = ls:GetItem(url)
		if(item and item.entry and item.payload) then
			if(not cache_policy:IsExpired(item.payload.creation_date)) then
				-- we found an unexpired result for gsid, return the result to callbackFunc
				HasResult = true;
				-- make output msg
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				
				LOG.std("", "debug","Inventory", "unexpired local version for : %s", url)
				
				if(callbackFunc) then
					callbackFunc(output_msg, callbackParams)
				end	
			end
		end
		if(HasResult) then
			-- don't require web API call
			return true;
		end	
		-- commonlib.echo("fetching : "..url)
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBag msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if((msg == nil or msg.items == nil) and inputMsg and inputMsg.bag) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(not ls) then
			return
		end
		local gsItems = {};
		-- if results are not found, we will try local server expired version
		if(inputMsg.bag) then
			-- if local server has an result, remove the gsid from msg.uid and return the result to callbackFunc
			-- make url
			local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "bag", inputMsg.bag, "nid", inputMsg.nid})
			local item = ls:GetItem(url)
			if(item and item.entry and item.payload) then
				-- make output msg
				local lsMsg = commonlib.LoadTableFromString(item.payload.data);
				if(lsMsg and lsMsg.items and lsMsg.items[1]) then
					lsMsg.isexpiredversion = true;
					LOG.std("", "warning","Inventory", "expired GetItemsInBag local version used for %s", tostring(url));
					return lsMsg;
				end	
			end
		end
	elseif(type(msg) == "table" and msg.items) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			-- make output msg
			local output_msg = msg;
			-- make url
			local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "bag", inputMsg.bag, "nid", inputMsg.nid});
			-- if this is the first call of the API skip the setback strategy of the clientdata
			if(not originalMsg.isfirstinvokeincurrentloginsession) then
				local item_ls = ls:GetItem(url)
				if(item_ls and item_ls.entry and item_ls.payload) then
					--
					----------------------------------------------------------------------------------
					-- NOTE: clientdata are implemented as a local priority manner, that is:
					--		1. SetClientData always valids immediately in ItemManager.SetClientData
					--		2. clientdata is updated to the local server in pre function of SetClientData
					--		3. if failed setting afterwards, wait for the next GetItemsInBag
					--			in the next GetItemsInBag post function, newly fetched items are checked with 
					--			the same bag items in local version. if different, 
					--			SetClientData is invoked again to set the clientdata to local version
					--		4. clientdata setting utilizes a lazy setting strategy, only set invoke the call 
					--			when needed: first SetClientData after ItemManager.SetClientData and 
					--			GetItemsInBag on every new coming web traffic
					-- NOTE 2009/12/6: local priority clientdata setting only valids only if the GetItemsInBag API 
					--		is NOT the first call of the current login session
					--		First GetItemsInBag API will always updates the localserver with the server
					----------------------------------------------------------------------------------
					--
					-- make local server version msg
					local msg_ls = commonlib.LoadTableFromString(item_ls.payload.data);
					local clientdata_in_msg_ls = {};
					if(msg_ls and msg_ls.items and msg_ls.items[1]) then
						-- find all non-empty clientdata in local server version
						local _, item_t;
						for _, item_t in pairs(msg_ls.items) do
							if(item_t.guid and item_t.clientdata and item_t.clientdata ~= "") then
								clientdata_in_msg_ls[item_t.guid] = item_t.clientdata;
							end
						end
					end
					if(output_msg and output_msg.items and output_msg.items[1]) then
						-- for currently logged in user bag
						if(inputMsg.nid == Map3DSystem.User.nid) then
							-- traverse through all newly fetched items in bag
							local _, item_t;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.guid and clientdata_in_msg_ls[item_t.guid] 
									and clientdata_in_msg_ls[item_t.guid] ~= item_t.clientdata) then
									-- re-set the clientdata if local version is different to the remote version
									output_msg.items[_].clientdata = clientdata_in_msg_ls[item_t.guid];
									local msg_re_set = {
										guid = item_t.guid,
										bag = inputMsg.bag, 
										clientdata = clientdata_in_msg_ls[item_t.guid],
									};
									local id = ParaGlobal.GenerateUniqueID();
									paraworld.inventory.SetClientData(msg_re_set, "ResetClientData_"..id, function(msg)
										if(msg.issuccess == false) then
											LOG.std("", "error","Inventory", "failed re-set clientdata of item (guid:"..tostring(item_t.guid)..")");
										end
									end);
								end
							end
						end
					end
				end
			end
			
			-- make entry
			local item = {
				entry = System.localserver.WebCacheDB.EntryInfo:new({
					url = url,
				}),
				payload = System.localserver.WebCacheDB.PayloadInfo:new({
					status_code = System.localserver.HttpConstants.HTTP_OK,
					data = (output_msg),
				}),
			}
			-- save to database entry
			local res = ls:PutItem(item);
			if(res) then 
				LOG.std("", "debug","Inventory", {url, inputMsg, msg, })
				LOG.std("", "debug","Inventory", tostring(#(msg.items)).." Bag Items of %s saved to local server. queue:%s", tostring(url), id or "");
			else	
				LOG.std("", "warning","Inventory", "failed saving global store template info of %s to local server", tostring(url))
				LOG.std("", "warning","Inventory", output_msg);
			end
			if(isLogInventoryTraffic) then
				LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBag msg_out:");
				LOG.std("", "debug","Inventory", msg);
			end
		end -- if(ls) then
	else
		LOG.std("", "error","Inventory", "paraworld.inventory.GetItemsInBag: unsupported message format")	
		LOG.std("", "error","Inventory", msg);
	end
end, nil, nil, 5000, nil, 2000);


--[[
http://pedn/KidsDev/Items
        /// <summary>
        /// ȡ��ָ���û�ָ����һ����е���������
        /// ���ղ�����
        ///     nid
        ///     bags  ��ID�������ID֮����Ӣ�Ķ��ŷָ�
        /// ����ֵ��
        ///     list [list]
        ///         bag  ��ID
        ///         items [list]
        ///             guid = int  // item instance id
        ///             gsid = int
        ///             obtaintime = string yyyy-MM-dd HH:mm:ss
        ///             position = int
        ///             clientdata = string
        ///             serverdata = string
        ///             copies = int
        ///      [ errorcode ]
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.GetItemsInBags", "%MAIN%/API/Items/GetItemsInBags", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	msg.nid = tonumber(msg.nid or Map3DSystem.User.nid);
	
	-- we don't allow GetItemsInBags to be called with cache_policy
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBags msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg and not msg.errorcode) then
		-- if no items in bag, the message doesn't contain the bag item block
		-- keep a record of the unreturned bags
		local emptybags = {};
        local bag;
        for bag in string.gfind(inputMsg.bags, "([^,]+)") do 
			bag = tonumber(bag);
			emptybags[bag] = true;
        end
		
		local _, onebagmsg;
		for _, onebagmsg in ipairs(msg.list) do
			local msg = onebagmsg;
			if(msg == nil or msg.items == nil) then
				-- skip the unexpired local server data
			elseif(type(msg) == "table" and msg.items and msg.bag) then
				-- remove from the empty bags
				emptybags[msg.bag] = nil;
				local ls = System.localserver.CreateStore(nil, 3);
				if(ls) then
					-- make output msg
					local output_msg = {items = msg.items};
					-- make url
					local url = NPL.EncodeURLQuery(paraworld.inventory.GetItemsInBag.GetUrl(), {"format", 1, "bag", msg.bag, "nid", inputMsg.nid});
					-- if this is the first call of the API skip the setback strategy of the clientdata
					-- NOTE: no set back clientdata is supported for GetItemsInBags
					
					-- make entry
					local item = {
						entry = System.localserver.WebCacheDB.EntryInfo:new({
							url = url,
						}),
						payload = System.localserver.WebCacheDB.PayloadInfo:new({
							status_code = System.localserver.HttpConstants.HTTP_OK,
							data = (output_msg),
						}),
					}
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "debug","Inventory", {url, {nid = inputMsg.nid, bag = msg.bag}, msg, })
						LOG.std("", "debug","Inventory", tostring(#(msg.items)).." Bag Items of %s saved to local server during GetItemsInBags", tostring(url));
					else	
						LOG.std("", "warning","Inventory", "failed saving global store template info of %s to local server during GetItemsInBags", tostring(url))
						LOG.std("", "warning","Inventory", output_msg);
					end
				end -- if(ls) then
			else
				LOG.std("", "error","Inventory", "paraworld.inventory.GetItemsInBags: unsupported message format")	
				LOG.std("", "error","Inventory", msg);
			end
		end
		
		local bag;
		for bag, _ in pairs(emptybags) do
			local ls = System.localserver.CreateStore(nil, 3);
			if(ls) then
				-- make output msg
				local output_msg = {items = {}};
				-- make url
				local url = NPL.EncodeURLQuery(paraworld.inventory.GetItemsInBag.GetUrl(), {"format", 1, "bag", bag, "nid", inputMsg.nid});
				-- if this is the first call of the API skip the setback strategy of the clientdata
				-- NOTE: no set back clientdata is supported for GetItemsInBags
				
				-- make entry
				local item = {
					entry = System.localserver.WebCacheDB.EntryInfo:new({
						url = url,
					}),
					payload = System.localserver.WebCacheDB.PayloadInfo:new({
						status_code = System.localserver.HttpConstants.HTTP_OK,
						data = (output_msg),
					}),
				}
				-- save to database entry
				local res = ls:PutItem(item);
				if(res) then 
					LOG.std("", "debug","Inventory", "Empty Bag Items of %s saved to local server during GetItemsInBags", tostring(url));
				else	
					LOG.std("", "warning","Inventory", "warning: failed saving global store template info of %s to local server during GetItemsInBags", tostring(url))
					LOG.std("", "warning","Inventory", output_msg);
				end
			end -- if(ls) then
		end
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBags msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end, nil, nil, 5000, nil, 2000);

--[[
	/// <summary>
	/// purchase the item directly through global store id
	/// the item is then put into the default bag specified in BagFamily
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "gsid" ] = int  // global store id
	///		[ "count" ] = int  // purchase count
	///		[ "clientdata" ] = string  // (optional) clientdata that set to the newly purchased item
	///									NOTE: the clientdata is not garanteed, since the item could be stacked on existing item and respawn new entry
	///											if exceeds MaxCopiesInStack. Although in Aries project we assume all items is MaxCopiesInStack == MaxCount
	///											The only exception is the homeland bag 10001 ~ 10009, items distribute as single copy items even stackable. 
	///											No bagfamily is homeland bag.
	///											Clientdata is only set if the item is a NEW entry.
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "guid" ] = int   // the newly purchased item guid
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								not enough money, p&/e cash
	///								for monthly paid user only
	///								too many copies, exceed MaxCount (mostly unique items)
	///								too many items, exceed the category capacity
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.PurchaseItem", "%MAIN%/API/Items/PurchaseItem.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.PurchaseItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(inputMsg.gsid);
			if(gsItem) then
				local bagfamily = gsItem.template.bagfamily;
				local inventorytype = gsItem.template.inventorytype;
				
				-- pass 1: update the items in bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									break;
								end
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after PurchaseItem", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after PurchaseItem", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- find the largest position in the bag
							local _, item_t;
							local max_position = 0;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.position > max_position) then
									max_position = item_t.position;
								end
							end
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								local position = max_position + 1;
								if(inventorytype ~= 0 and bagfamily == 0) then
									-- inventorytype specifies the position of the item if bagfamily is 0
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0 and inputMsg.gsid == 998) then
									-- energy stone
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0) then
									LOG.std("", "error","Inventory", " inventorytype and bagfamily are both 0 for gsid:"..inputMsg.gsid..", check global store item template");
									return;
								end
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = inputMsg.gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = position,
									clientdata = inputMsg.clientdata or "",
									serverdata = "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s added to local server after PurchaseItem", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding bag items of %s to local server after PurchaseItem", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 2: update the user info
				local url_getinfo = paraworld.users.getInfo.GetUrl();
				--local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
				--fields = string.lower(commonlib.Encoding.SortCSVString(fields));
				local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid})
				local item = ls:GetItem(url_getinfo)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(type(output_msg) == "table") then
						-- NOTE 2010/1/21: update the emoney update source from globalstore to purchaseitem return message
						-- update the $E, using the return message
						if(output_msg.nid == Map3DSystem.User.nid) then
							output_msg.emoney = output_msg.emoney + msg.deltaemoney;
						end
						---- update the $P and $E, using the global store item price
						--local _, user;
						--for _, user in ipairs(output_msg.users) do
							--if(user.nid == Map3DSystem.User.nid) then
								--local gsItem = paraworld.globalstore.gettemplateinlocalserver(inputMsg.gsid);
								--if(gsItem) then
									--output_msg.users[_].emoney = user.emoney - gsItem.ebuyprice * inputMsg.count;
									--output_msg.users[_].pmoney = user.pmoney - gsItem.pbuyprice * inputMsg.count;
									--break;
								--end
							--end
						--end
						-- make entry
						local item = {
							entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
							payload = System.localserver.WebCacheDB.PayloadInfo:new({
								status_code = System.localserver.HttpConstants.HTTP_OK,
								data = (output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "User info of %s updated to local server after PurchaseItem", tostring(url_getinfo));
						else	
							LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after PurchaseItem", tostring(url_getinfo))
							LOG.std("", "warning","Inventory", output_msg);
						end
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.PurchaseItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);



--[[
	/// <summary>
	/// move the item from one bag to another, NOTE: all items must be in the same srcbag and move to the same dstbag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "items" ] = string  // item instance ids separated with "," and "|", e.x. guid1,count1|guid2,count2|guid3,count3|guid4,count4
	///		[ "srcbag" ] = int  // source bag   <---  NOTE: CYF require this field for cache optimization, 2009/5/31
	///		[ "dstbag" ] = int  // destination bag
	///		[ "clientdata" ] = string  // clientdata to be set to the item if and only the item created a new instance on the dstbag
	///		
	///		NOTE: suppose we have items:"1001,1|2002,10|3003,2" srcbag:"21" dstbag:"10001" 
	///		the service call will move 1 copy of item 1001 to bag 21, 10 copy of item 2002 to bag 21 and 2 copy of item 3003 from bag 21 to bag 10001
	///		
	///		NOTE: 
	///		maximum types of items per request is 10
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								guids and counts number don't match
	///								request item count exceed existing count
	///								target bag is full, exceed the category capacity
	///								too many item counts
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.MoveItems", "%MAIN%/API/Items/MoveItems.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.MoveItems msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			-- parse items into guid and count pairs
			local guid, count;
			for guid, count in string.gfind(inputMsg.items, "([^,^|]+),([^,^|]+)") do
				guid = tonumber(guid);
				count = tonumber(count);
				local sourceItem_gsid;
				-- pass 1: remove the item in the source bag
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.srcbag, "nid", Map3DSystem.User.nid});
				local item = ls:GetItem(url);
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.guid == guid) then
								item.copies = item.copies - count;
								sourceItem_gsid = item.gsid;
								break;
							end
						end
						-- make entry
						local item = {
							entry = System.localserver.WebCacheDB.EntryInfo:new({url = url,}),
							payload = System.localserver.WebCacheDB.PayloadInfo:new({
								status_code = System.localserver.HttpConstants.HTTP_OK,
								data = (output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "Source Bag Items of %s updated to local server after MoveItems", tostring(url));
						else	
							LOG.std("", "warning","Inventory", "failed updating source bag items of %s to local server after MoveItems", tostring(url))
							LOG.std("", "warning","Inventory", output_msg);
						end
					end
				end
				if(not sourceItem_gsid) then
					LOG.std("", "error","Inventory", " couldn't find source item gsid in local server cache after MoveItems");
					return;
				end
				-- pass 2: update the items in the destination bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									break;
								end
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Dest Bag Items of %s updated to local server after MoveItems", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating dest bag items of %s to local server after MoveItems", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				-- pass 3: append the items in the destination bag
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = sourceItem_gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = add.position,
									clientdata = inputMsg.clientdata or "",
									serverdata = "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Dest Bag Items of %s added to local server after MoveItems", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding dest bag items of %s to local server after MoveItems", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.MoveItems msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// equip the item in character slot
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = int  // item instance id
	///		[ "bag" ] = int  // NOTE: CYF require this field for cache optimization
	///		[ "clientdata" ] = string  // (optional) clientdata to be set
	///		[ "position" ] = int // NOTE: for local server optimization, added by andy 2009/8/4 
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								the item can't be mount to character slot, not clothes or hand-held items
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.EquipItem", "%MAIN%/API/Items/EquipItem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	msg.position = nil;
	msg.fromposition = nil;
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.EquipItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg.issuccess == true) then
		-- if originalMsg.fromposition is nil, skip local server write
		if(originalMsg.fromposition ~= nil) then
			local ls = System.localserver.CreateStore(nil, 3);
			if(ls) then
				-- unequip the item if position slot has item
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url_0 = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", 0, "nid", Map3DSystem.User.nid})
				local item = ls:GetItem(url_0)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						local unEquipedItem;
						-- remove from the equip bag
						local newOutput = {};
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.position == originalMsg.position) then
								unEquipedItem = item;
							else
								table.insert(newOutput, item);
							end
						end
						output_msg = {items = newOutput};
						if(unEquipedItem and unEquipedItem.guid) then
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_0,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_0));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_0))
								LOG.std("", "warning","Inventory", output_msg);
							end
							
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(unEquipedItem.gsid);
							if(gsItem) then
								local bagfamily = gsItem.template.bagfamily;
								-- put in the bagfamily bag
								local url_bagfamily = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", bagfamily, "nid", Map3DSystem.User.nid})
								local item = ls:GetItem(url_bagfamily);
								if(item and item.entry and item.payload) then
									local output_msg = commonlib.LoadTableFromString(item.payload.data);
									if(output_msg and output_msg.items) then
										-- find the largest position in the bag
										local guid_t, item_t;
										local max_position = 0;
										for guid_t, item_t in pairs(output_msg.items) do
											if(item_t.position > max_position) then
												max_position = item_t.position;
											end
										end
										if(inputMsg.bag == bagfamily) then
											-- use the original item position to perform an item swap
											unEquipedItem.position = originalMsg.fromposition;
										else
											-- append to the tail of the bag items
											unEquipedItem.position = max_position + 1;
										end
										table.insert(output_msg.items, unEquipedItem);
										-- make entry
										local item = {
											entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_bagfamily,}),
											payload = System.localserver.WebCacheDB.PayloadInfo:new({
												status_code = System.localserver.HttpConstants.HTTP_OK,
												data = (output_msg),
											}),
										}
										-- save to database entry
										local res = ls:PutItem(item);
										if(res) then 
											LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_bagfamily));
										else	
											LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_bagfamily));
											LOG.std("", "warning","Inventory", output_msg);
										end
									end
								end
							end
						end
					end
				end
				-- equip the item
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url_bag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.bag, "nid", Map3DSystem.User.nid})
				local item = ls:GetItem(url_bag)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						local equipedItem;
						-- remove from the original bag
						local newOutput = {};
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.guid == inputMsg.guid) then
								equipedItem = item;
							else
								table.insert(newOutput, item);
							end
						end
						output_msg = {items = newOutput};
						if(equipedItem.guid) then
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_bag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_bag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_bag))
								LOG.std("", "warning","Inventory", output_msg);
							end
							
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(equipedItem.gsid);
							if(gsItem) then
								local bagfamily = gsItem.template.bagfamily;
								-- put in the bagfamily bag
								local url_0 = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", 0, "nid", Map3DSystem.User.nid})
								local item = ls:GetItem(url_0);
								if(item and item.entry and item.payload) then
									local output_msg = commonlib.LoadTableFromString(item.payload.data);
									if(output_msg and output_msg.items) then
										equipedItem.position = originalMsg.position;
										equipedItem.bag = 0;
										table.insert(output_msg.items, equipedItem);
										-- make entry
										local item = {
											entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_0,}),
											payload = System.localserver.WebCacheDB.PayloadInfo:new({
												status_code = System.localserver.HttpConstants.HTTP_OK,
												data = (output_msg),
											}),
										}
										-- save to database entry
										local res = ls:PutItem(item);
										if(res) then 
											LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_0));
										else	
											LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_0));
											LOG.std("", "warning","Inventory", output_msg);
										end
									end
								end
							end
						end
					end
				end
			end -- if(ls) then
		end
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.EquipItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// unequip the item in character slot
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "position" ] = int  // position in character slot bag 0
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.UnEquipItem", "%MAIN%/API/Items/UnEquipItem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.UnEquipItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
			local url_0 = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", 0, "nid", Map3DSystem.User.nid})
			local item = ls:GetItem(url_0)
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(output_msg and output_msg.items) then
					local unEquipedItem;
					-- remove from the equip bag
					local newOutput = {};
					local _, item;
					for _, item in ipairs(output_msg.items) do
						if(item.position == inputMsg.position) then
							unEquipedItem = item;
						else
							table.insert(newOutput, item);
						end
					end
					output_msg = {items = newOutput};
					if(unEquipedItem.guid) then
						-- make entry
						local item = {
							entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_0,}),
							payload = System.localserver.WebCacheDB.PayloadInfo:new({
								status_code = System.localserver.HttpConstants.HTTP_OK,
								data = (output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after UnEquipItem", tostring(url_0));
						else	
							LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after UnEquipItem", tostring(url_0))
							LOG.std("", "warning","Inventory", output_msg);
						end
						
						local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(unEquipedItem.gsid);
						if(gsItem) then
							local bagfamily = gsItem.template.bagfamily;
							-- put in the bagfamily bag
							local url_bagfamily = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", bagfamily, "nid", Map3DSystem.User.nid})
							local item = ls:GetItem(url_bagfamily);
							if(item and item.entry and item.payload) then
								local output_msg = commonlib.LoadTableFromString(item.payload.data);
								if(output_msg and output_msg.items) then
									-- find the largest position in the bag
									local guid_t, item_t;
									local max_position = 0;
									for guid_t, item_t in pairs(output_msg.items) do
										if(item_t.position > max_position) then
											max_position = item_t.position;
										end
									end
									unEquipedItem.position = max_position + 1;
									table.insert(output_msg.items, unEquipedItem);
									-- make entry
									local item = {
										entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_bagfamily,}),
										payload = System.localserver.WebCacheDB.PayloadInfo:new({
											status_code = System.localserver.HttpConstants.HTTP_OK,
											data = (output_msg),
										}),
									}
									-- save to database entry
									local res = ls:PutItem(item);
									if(res) then 
										LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after UnEquipItem", tostring(url_bagfamily));
									else	
										LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after UnEquipItem", tostring(url_bagfamily));
										LOG.std("", "warning","Inventory", output_msg);
									end
								end
							end
						end
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.UnEquipItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// destroy the item directly through item instance id
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = int  // item instance id
	///		[ "count" ] = int  // destroy count
	///		[ "bag" ] = int  // NOTE: CYF require this field for cache optimization, 2009/5/27
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								item doesn't exist
	///								request item count exceed existing count
	///								item can't be destroyed
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.DestroyItem", "%MAIN%/API/Items/DestroyItem.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.DestroyItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
			local url = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.bag, "nid", Map3DSystem.User.nid})
			local item = ls:GetItem(url)
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(output_msg and output_msg.items) then
					local _, item;
					for _, item in ipairs(output_msg.items) do
						if(item.guid == inputMsg.guid) then
							item.copies = item.copies - inputMsg.count;
							break;
						end
					end
					-- make entry
					local item = {
						entry = System.localserver.WebCacheDB.EntryInfo:new({url = url,}),
						payload = System.localserver.WebCacheDB.PayloadInfo:new({
							status_code = System.localserver.HttpConstants.HTTP_OK,
							data = (output_msg),
						}),
					}
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after DestroyItem", tostring(url));
					else	
						LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after DestroyItem", tostring(url))
						LOG.std("", "warning","Inventory", output_msg);
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.DestroyItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);



--[[
	/// <summary>
	/// purchase item with non monetary price, be it profession items, monthly owned items or any combination of the above
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "buy_gsids" ] = string  // global store ids separated with ","
	///		[ "buy_counts" ] = string  // buy item counts separated with ","
	///		[ "cost_guids" ] = string  // item instance ids separated with ","
	///		[ "cost_counts" ] = string  // item counts separated with ","
	///		CYF: ��cost_guids����buy_gsids�������Ʒ, ��������һ�����ܵ�APIר�Ÿ�����µ�
	///			����cost_guids "12,34", cost_counts "1,1", buy_gsids "38432,2082,98021", buy_counts "1,2,1"
	///			��һ��12(guid) һ��34(guid) ��һ��38432(gsid) ����2082(gsid) һ��98021(gsid)
	///			����cost_guids "12,34", cost_counts "1,-1", buy_gsids "38432", buy_counts "1"
	///			��һ��12(guid) һ��34(guid) ��һ��38432(gsid), ����34��ɾ��, 34 -1����˼�ǽ���ʱҪ��1��34,��34��ɾ��
	///			����������൱��cost_guids "12,34", cost_counts "1,1", buy_gsids "38432,3798", buy_counts "1,1" (����guid12��gsid��5434, guid34��gsid��3798)
	///				5434�ǰײ� 3798�ǲ˵� 38432�ǰײ˶�
	///			ע��ֱ���guid��gsid, 
	///				��ע�� ����ĵõ�����ƷҲҪ��purchaseһ��,����ͨ��PurchaseItemExtended��������ĳ�ʼ��,���������õ�ҲҪ��ʼ��
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								cost item doesn't exist
	///								not enough cost item count
	///								too many buy item copies, exceed MaxCount (mostly unique items)
	///								too many buy items, exceed the category capacity
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
-- TODO: M3
--paraworld.create_wrapper("paraworld.inventory.PurchaseItemExtended", "%MAIN%/API/Items/PurchaseItemExtended.ashx");


local exid_exclude_map;
-- whether we need to log extended cost for the given exid.
function paraworld.inventory.shall_log_exid(exid)
	if(not exid_exclude_map) then
		exid_exclude_map = {};
		local filename
		if(System.options.version == "kids") then
			-- exclude: �׾ƺ�«�� ���������
			filename = "config/Aries/Others/client.logevent.excludelist.kids.csv"
		else
			-- TODO: for teen?
		end
		if(filename) then
			local file = ParaIO.open(filename, "r");
			if(file:IsValid()) then
				LOG.std(nil, "debug", "CSVDocReader", "load file:%s", filename);
				local line = file:readline();
				while(line) do
					local exid = line:match("^%d+");
					if(exid) then
						exid = tonumber(exid);
						exid_exclude_map[exid] = true;
					end
					-- read next line
					line = file:readline();
				end
				file:close();
			else
				LOG.std(nil, "warn", "CSVDocReader", "failed to load file:%s", filename);
			end
		end
	end
	if(exid and not exid_exclude_map[exid]) then
		return true;
	end
end
--[[
        /// <summary>
        /// ��ǰ��¼�û�ִ��ĳ���һ�
        /// ���ղ�����
        ///     nid
        ///     exID ���ƵĶһ���ID
		///		logevent �Ƿ��¼��־��0������¼��1����¼��Ĭ��Ϊ0
        ///     froms �ͻ���ѡ�����û��һ�����Ʒ��guid,cnt|guid,cnt|guid,cnt|......
        /// ����ֵ��
        ///     issuccess
        ///     [ updates ][list] ����һ�������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///     [ adds ][list] ����һ�������������
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        ///     [ stats ][list] ����һ��������ֵ�ı仯
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:����������
        ///         cnt
        ///     [ errorcode ]
        /// </summary>
        
paraworld.inventory.Test_ExtendedCost return:
echo:return { adds={  }, issuccess=true, updates={ { bag=12, cnt=1, guid=557 } } }
]]
paraworld.create_wrapper("paraworld.inventory.ExtendedCost", "%MAIN%/API/Items/ExtendedCost.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end
	
	if(paraworld.inventory.shall_log_exid(msg.exid)) then
		msg.logevent = 1;	
		LOG.std("", "debug","Inventory", "logevent ExtendedCost: %s", tostring(msg.exid))
	end

	local exTemplate = paraworld.inventory.getextendedcostinlocalserver(msg.exid);
	if(not exTemplate) then
		LOG.std("", "debug","Inventory", "warning: empty extended cost template not valid in local server when trying to invoke paraworld.inventory.ExtendedCost service call");
		LOG.std("", "debug","Inventory", "    exid:"..msg.exid.."")
	end
	-- remove the frombags field of the input message
	msg.frombags = nil;
	msg.mymountpetguid = nil;
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ExtendedCost msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			local exTemplate = paraworld.inventory.getextendedcostinlocalserver(inputMsg.exid);
			if(exTemplate) then
				--local bagfamily = gsItem.template.bagfamily;
				--local inventorytype = gsItem.template.inventorytype;
				
				-- NOTE 2011/9/29: remove froms section update
				-- CYF return the froms section changes in adds and updates
				---- pass 1: remove the items in bag, according to the froms section of exTemplate
				--local froms = {};
				--local i = 1;
				--local guid, cnt;
				--for guid, cnt in string.gmatch(originalMsg.froms, "(%d+),(%d+)|") do
					---- if guid == 0 stands for $E cash
					--guid = tonumber(guid);
					--cnt = tonumber(cnt);
					--if(guid > 0) then
						--froms[i] = {guid = guid, cnt = cnt, bag = originalMsg.frombags[i]};
					--end
					--i = i + 1;
				--end
				--local _, from;
				--for _, from in pairs(froms) do
					--local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					--local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", from.bag, "nid", Map3DSystem.User.nid})
					--local item = ls:GetItem(url_getitemsinbag)
					--if(item and item.entry and item.payload) then
						--local output_msg = commonlib.LoadTableFromString(item.payload.data);
						--if(output_msg and output_msg.items) then
							---- remove the copies
							--local _, item;
							--for _, item in ipairs(output_msg.items) do
								--if(item.guid == from.guid) then
									--output_msg.items[_].copies = output_msg.items[_].copies - from.cnt;
									--if(output_msg.items[_].copies < 0) then
										--LOG.std("", "error","Inventory", " negitive copies got in ExtendedCost remove process");
										--LOG.std("", "debug","Inventory", "original message:");
										--commonlib.echo(originalMsg);
										--LOG.std("", "debug","Inventory", "receive message:");
										--LOG.std("", "debug","Inventory", msg);
									--end
									--break;
								--end
							--end
							---- make entry
							--local item = {
								--entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								--payload = System.localserver.WebCacheDB.PayloadInfo:new({
									--status_code = System.localserver.HttpConstants.HTTP_OK,
									--data = (output_msg),
								--}),
							--}
							---- save to database entry
							--local res = ls:PutItem(item);
							--if(res) then 
								--LOG.std("", "debug","Inventory", "Bag Items of %s removed to local server after ExtendedCost", tostring(url_getitemsinbag));
							--else	
								--LOG.std("", "warning","Inventory", "failed removing bag items of %s to local server after ExtendedCost", tostring(url_getitemsinbag))
								--LOG.std("", "warning","Inventory", output_msg);
							--end
						--end
					--end
				--end
				
				-- pass 2: update the items in bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									update.gsid_fromlocalserver = item.gsid;
									break;
								end
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after ExtendedCost", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after ExtendedCost", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				-- pass 3: add the items in bag
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag);
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- find the largest position in the bag
							local _, item_t;
							local max_position = 0;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.position > max_position) then
									max_position = item_t.position;
								end
							end
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								local position = max_position + 1;
								local bagfamily;
								local inventorytype;
								local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(add.gsid);
								if(gsItem) then
									bagfamily = gsItem.template.bagfamily;
									inventorytype = gsItem.template.inventorytype;
								end
								if(inventorytype ~= 0 and bagfamily == 0) then
									-- inventorytype specifies the position of the item if bagfamily is 0
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0 and add.gsid == 998) then
									-- energy stone
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0) then
									LOG.std("", "error","Inventory", " inventorytype and bagfamily are both 0 for gsid:"..add.gsid..", check global store item template");
									return;
								end
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = add.gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = position,
									clientdata = add.clientdata or "",
									serverdata = add.svrdata or add.serverdata or "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s added to local server after ExtendedCost", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding bag items of %s to local server after ExtendedCost", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 4: update the user info
				local pmoney_delta = 0;
				local emoney_delta = 0;
				local popularity_delta = 0;
				if(msg.stats) then
					local _, stat;
					for _, stat in pairs(msg.stats) do
						if(stat.gsid == 0) then
							emoney_delta = stat.cnt;
						elseif(stat.gsid == -101) then
							popularity_delta = stat.cnt;
						end
					end
				end
				--local _, entry;
				--for _, entry in pairs(exTemplate.froms or {}) do
					--if(entry.key == -1) then -- $p cash
						--pmoney_delta = pmoney_delta - entry.value;
					--elseif(entry.key == 0) then -- $e cash
						--emoney_delta = emoney_delta - entry.value;
					--end
				--end
				--local _, entry;
				--for _, entry in pairs(exTemplate.tos or {}) do
					--if(entry.key == -1) then -- $p cash
						--pmoney_delta = pmoney_delta + entry.value;
					--elseif(entry.key == 0) then -- $e cash
						--emoney_delta = emoney_delta + entry.value;
					--end
				--end
				if(pmoney_delta ~= 0 or emoney_delta ~= 0 or popularity_delta ~= 0) then
					-- if no money changed, skip the user info update
					local url_getinfo = paraworld.users.getInfo.GetUrl();
					--local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
					--fields = string.lower(commonlib.Encoding.SortCSVString(fields));
					local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid,})
					local item = ls:GetItem(url_getinfo)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(type(output_msg) == "table") then
							-- update the $P and $E
							if(output_msg.nid == Map3DSystem.User.nid) then
								output_msg.emoney = output_msg.emoney + emoney_delta;
								output_msg.pmoney = output_msg.pmoney + pmoney_delta;
								output_msg.popularity = output_msg.popularity + popularity_delta;
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "User info of %s updated to local server after ExtendedCost", tostring(url_getinfo));
							else	
								LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after ExtendedCost", tostring(url_getinfo))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end -- if(pmoney_delta ~= 0 or emoney_delta ~= 0) then
				
				-- pass 5: update the user mount pet info if necessary
				local mymountpetguid = originalMsg.mymountpetguid;
				if(mymountpetguid and msg.stats) then
					-- update the petevolved.get infomation
					local url_petevolved_get = paraworld.users.getInfo.GetUrl();
					url_petevolved_get = NPL.EncodeURLQuery(url_petevolved_get, {"format", 1, "nids", Map3DSystem.User.nid, });
					local item = ls:GetItem(url_petevolved_get)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.health) then
							local _, stat;
							for _, stat in pairs(msg.stats) do
								if(stat.gsid == -3) then
									output_msg.kindness = output_msg.kindness + stat.cnt;
								elseif(stat.gsid == -4) then
									output_msg.strength = output_msg.strength + stat.cnt;
								elseif(stat.gsid == -5) then
									output_msg.agility = output_msg.agility + stat.cnt;
								elseif(stat.gsid == -6) then
									output_msg.intelligence = output_msg.intelligence + stat.cnt;
								elseif(stat.gsid == -7) then
									output_msg.archskillpts = output_msg.archskillpts + stat.cnt;
								elseif(stat.gsid == -1001) then
									output_msg.nextlevelexp = stat.cnt;
								elseif(stat.gsid == -1002) then
									output_msg.combatexp = stat.cnt;
								elseif(stat.gsid == -14) then
									output_msg.combatlel = stat.cnt;
								elseif(stat.gsid == -19) then
									output_msg.stamina = output_msg.stamina + stat.cnt;
								elseif(stat.gsid == -20) then
									output_msg.stamina2 = output_msg.stamina2 + stat.cnt;
								end
							end
							
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_petevolved_get,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then
								LOG.std("", "debug","Inventory", "Pet info of %s updated to local server after ExtendedCost", tostring(url_petevolved_get));
							else
								LOG.std("", "warning","Inventory", "failed updating pet info of %s to local server after ExtendedCost", tostring(url_petevolved_get));
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 6: calculate all obtains
				local obtains = {};
				local _, update;
				for _, update in ipairs(msg.updates) do
					if(update.gsid_fromlocalserver) then
						local gsid = update.gsid_fromlocalserver;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + update.cnt;
					end
				end
				local _, add;
				for _, add in ipairs(msg.adds) do
					if(add.gsid) then
						local gsid = add.gsid;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + add.cnt;
					end
				end
				local _, stat;
				for _, stat in pairs(msg.stats) do
					if(stat.gsid) then
						local gsid = stat.gsid;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + stat.cnt;
					end
				end
				msg.obtains = obtains;
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ExtendedCost msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end);

--[[
        /// <summary>
        /// ��ǰ��¼�û�ִ��ĳ���һ�
        /// ���ղ�����
        ///     sessionkey ��ǰ��¼�û�
        ///     exid ���ƵĶһ���ID
		///		logevent �Ƿ��¼��־��0������¼��1����¼��Ĭ��Ϊ0
        ///     times ִ�д���
        ///     froms �ͻ���ѡ�����û��һ�����Ʒ��guid,cnt|guid,cnt|guid,cnt|......
        /// ����ֵ��
        ///     issuccess
        ///     [ updates ][list] ����һ�������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///     [ adds ][list] ����һ�������������
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        ///     [ stats ][list] ����һ��������ֵ�ı仯
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:���������ȣ�-8:�������ȼ���-9:����ֵ��-10:���ֵ��-11:����ֵ��-12:����״̬��-13:ս������ֵ��-14:ս���ȼ���-1000:��������������һ����������ܶȣ�-1001:��ʾ�ڿͻ��˵���������һ������Ҫ��ս������ֵ��-1002:��ʾ�ڿͻ��˵ĵ�ǰս������ֵ
        ///         cnt
        ///     [ errorcode ]
        /// </summary>
]]
paraworld.create_wrapper("paraworld.inventory.ExtendedCost2", "%MAIN%/API/Items/ExtendedCost2.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end

	if(paraworld.inventory.shall_log_exid(msg.exid)) then
		msg.logevent = 1;
		LOG.std("", "debug","Inventory", "logevent ExtendedCost2: %s", tostring(msg.exid))
	end

	local exTemplate = paraworld.inventory.getextendedcostinlocalserver(msg.exid);
	if(not exTemplate) then
		LOG.std("", "debug","Inventory", "warning: empty extended cost template not valid in local server when trying to invoke paraworld.inventory.ExtendedCost2 service call");
		LOG.std("", "debug","Inventory", "    exid:"..msg.exid.."")
	end
	-- remove the frombags field of the input message
	msg.frombags = nil;
	msg.mymountpetguid = nil;
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ExtendedCost2 msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			local exTemplate = paraworld.inventory.getextendedcostinlocalserver(inputMsg.exid);
			if(exTemplate) then
				
				-- pass 2: update the items in bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									update.gsid_fromlocalserver = item.gsid;
									break;
								end
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after ExtendedCost2", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after ExtendedCost2", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				-- pass 3: add the items in bag
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag);
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- find the largest position in the bag
							local _, item_t;
							local max_position = 0;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.position > max_position) then
									max_position = item_t.position;
								end
							end
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								local position = max_position + 1;
								local bagfamily;
								local inventorytype;
								local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(add.gsid);
								if(gsItem) then
									bagfamily = gsItem.template.bagfamily;
									inventorytype = gsItem.template.inventorytype;
								end
								if(inventorytype ~= 0 and bagfamily == 0) then
									-- inventorytype specifies the position of the item if bagfamily is 0
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0 and add.gsid == 998) then
									-- energy stone
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0) then
									LOG.std("", "error","Inventory", " inventorytype and bagfamily are both 0 for gsid:"..add.gsid..", check global store item template");
									return;
								end
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = add.gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = position,
									clientdata = "",
									serverdata = add.svrdata or add.serverdata or "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s added to local server after ExtendedCost2", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding bag items of %s to local server after ExtendedCost2", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 4: update the user info
				local pmoney_delta = 0;
				local emoney_delta = 0;
				local popularity_delta = 0;
				if(msg.stats) then
					local _, stat;
					for _, stat in pairs(msg.stats) do
						if(stat.gsid == 0) then
							emoney_delta = stat.cnt;
						elseif(stat.gsid == -101) then
							popularity_delta = stat.cnt;
						end
					end
				end
				--local _, entry;
				--for _, entry in pairs(exTemplate.froms or {}) do
					--if(entry.key == -1) then -- $p cash
						--pmoney_delta = pmoney_delta - entry.value;
					--elseif(entry.key == 0) then -- $e cash
						--emoney_delta = emoney_delta - entry.value;
					--end
				--end
				--local _, entry;
				--for _, entry in pairs(exTemplate.tos or {}) do
					--if(entry.key == -1) then -- $p cash
						--pmoney_delta = pmoney_delta + entry.value;
					--elseif(entry.key == 0) then -- $e cash
						--emoney_delta = emoney_delta + entry.value;
					--end
				--end
				if(pmoney_delta ~= 0 or emoney_delta ~= 0 or popularity_delta ~= 0) then
					-- if no money changed, skip the user info update
					local url_getinfo = paraworld.users.getInfo.GetUrl();
					--local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
					--fields = string.lower(commonlib.Encoding.SortCSVString(fields));
					local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid,})
					local item = ls:GetItem(url_getinfo)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(type(output_msg) == "table") then
							-- update the $P and $E
							if(output_msg.nid == Map3DSystem.User.nid) then
								output_msg.emoney = output_msg.emoney + emoney_delta;
								output_msg.pmoney = output_msg.pmoney + pmoney_delta;
								output_msg.popularity = output_msg.popularity + popularity_delta;
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "User info of %s updated to local server after ExtendedCost2", tostring(url_getinfo));
							else	
								LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after ExtendedCost2", tostring(url_getinfo))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end -- if(pmoney_delta ~= 0 or emoney_delta ~= 0) then
				
				-- pass 5: update the user mount pet info if necessary
				local mymountpetguid = originalMsg.mymountpetguid;
				if(mymountpetguid and msg.stats) then
					-- update the petevolved.get infomation
					local url_petevolved_get = paraworld.users.getInfo.GetUrl();
					url_petevolved_get = NPL.EncodeURLQuery(url_petevolved_get, {"format", 1, "nids", Map3DSystem.User.nid, });
					local item = ls:GetItem(url_petevolved_get)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.health) then
							local _, stat;
							for _, stat in pairs(msg.stats) do
								if(stat.gsid == -3) then
									output_msg.kindness = output_msg.kindness + stat.cnt;
								elseif(stat.gsid == -4) then
									output_msg.strength = output_msg.strength + stat.cnt;
								elseif(stat.gsid == -5) then
									output_msg.agility = output_msg.agility + stat.cnt;
								elseif(stat.gsid == -6) then
									output_msg.intelligence = output_msg.intelligence + stat.cnt;
								elseif(stat.gsid == -7) then
									output_msg.archskillpts = output_msg.archskillpts + stat.cnt;
								elseif(stat.gsid == -1001) then
									output_msg.nextlevelexp = stat.cnt;
								elseif(stat.gsid == -1002) then
									output_msg.combatexp = stat.cnt;
								elseif(stat.gsid == -14) then
									output_msg.combatlel = stat.cnt;
								elseif(stat.gsid == -19) then
									output_msg.stamina = output_msg.stamina + stat.cnt;
								elseif(stat.gsid == -20) then
									output_msg.stamina2 = output_msg.stamina2 + stat.cnt;
								end
							end
							
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_petevolved_get,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then
								LOG.std("", "debug","Inventory", "Pet info of %s updated to local server after ExtendedCost2", tostring(url_petevolved_get));
							else
								LOG.std("", "warning","Inventory", "failed updating pet info of %s to local server after ExtendedCost2", tostring(url_petevolved_get));
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 6: calculate all obtains
				local obtains = {};
				local _, update;
				for _, update in ipairs(msg.updates) do
					if(update.gsid_fromlocalserver) then
						local gsid = update.gsid_fromlocalserver;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + update.cnt;
					end
				end
				local _, add;
				for _, add in ipairs(msg.adds) do
					if(add.gsid) then
						local gsid = add.gsid;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + add.cnt;
					end
				end
				local _, stat;
				for _, stat in pairs(msg.stats) do
					if(stat.gsid) then
						local gsid = stat.gsid;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + stat.cnt;
					end
				end
				msg.obtains = obtains;
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ExtendedCost2 msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end);


--[[
    /// <summary>
    /// ȡ�����е���Ʒ�һ����򣨷�ҳ��
    /// ���ղ�����
    ///     pageIndex
    ///     pageSize ���20
    /// ����ֵ��
    ///     pageCnt ������ҳ
    ///     exs[list]
    ///         exname
    ///         froms[list]
    ///             key
    ///             value
    ///         tos[list]
    ///             key
    ///             value
    ///         pres[list] �Ⱦ�����
    ///             key
    ///             value
    ///     [ errorcode ]
    /// </summary>
]]
paraworld.create_wrapper("paraworld.inventory.GetExtendedCostOfPage", "%MAIN%/API/Items/GetExtendedCostOfPage.ashx");

--[[
	/// <summary>
	/// use the item directly through global store id
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = int  // item instance id
	///		[ "count" ] = int  // use count, this field should always be "1"
	///		[ "targetguid" ] = int  // target item guid(optional), this could be optional if the gsid requires a target
	///		CYF: �����������Ӿ�������Ʒ, ���������Ե�, ���ĵ�һ����Ʒ, Ȼ����Ŀ�����guid��ʳ��, ��ԡ¶ ��ߵ���ֵ�ȵ�
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								item doesn't exist
	///								request item count exceed existing count
	///								item can't be destroyed
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
-- TODO: M3
--paraworld.CreateRESTJsonWrapper("paraworld.inventory.UseItem", "%MAIN%/API/Items/UseItem.ashx");


--[[
	/// <summary>
	/// get the items equipped on user(all bag 0 items)
	/// pay attention that this information can be accessed by every users in the community
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "uids" ] = string  // uids separated by ","    maximum uids per request is 10
	///		or [ "nids" ] = string  // nids separated by ","    maximum nids per request is 10
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "equips" ] = list{
	///				uid/nid = string, 
	///				gsids = string, // comma separated global store ids
	///				NOTE: if we have "102,0,0,205,0,0,0,0,32" as gsids, the user have an global store item 102 on character slot position 1, 
	///					item 205 on character slot position 4, and item 32 on character slot position 9.
	///			}
	///			NOTE: equips count depends on the request uid or nid count
	///		}
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								invalid uid or nid
	///								too many user count 
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.GetEquips", "%MAIN%/API/Items/GetEquips.ashx", nil, nil, nil, nil, 5000);

--[[
    /// <summary>
    /// ����û���԰�е���Ʒ�������������ֲ��ֱ��ɾ����������Ʒ���յ���BagFamily���У�ֻ������Լ���԰�е���Ʒ
    /// ���ղ�����
    ///     nid  ��ǰ��¼�û���NID
    /// ����ֵ��
    ///     issuccess
    ///     [ errorcode ]
    /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.RecycleHomelandItems", "%MAIN%/API/Items/RecycleHomelandItems.ashx");


--[[
	/// <summary>
	/// set the client data of the item instances
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = string  // item instance id
	///		[ "clientdata" ] = string  // item instance client data
	///		[ "bag" ] = int  // NOTE: CYF require this field for cache optimization, 2009/6/15
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								item not exists
	///								item count is not 1, we don't provide client data for stackable and stacked items 
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]]
paraworld.create_wrapper("paraworld.inventory.SetClientData", "%MAIN%/API/Items/SetClientData.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	local ls = System.localserver.CreateStore(nil, 3);
	if(ls) then
		local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl(); 
		local url_bagfamily = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", msg.bag, "nid", Map3DSystem.User.nid})
		local item = ls:GetItem(url_bagfamily)
		if(item and item.entry and item.payload) then
			--
			----------------------------------------------------------------------------------
			-- NOTE: clientdata are implemented as a local priority manner, that is:
			--		1. SetClientData always valids immediately in ItemManager.SetClientData
			--		2. clientdata is updated to the local server in pre function of SetClientData
			--		3. if failed setting afterwards, wait for the next GetItemsInBag
			--			in the next GetItemsInBag post function, newly fetched items are checked with 
			--			the same bag items in local version. if different, 
			--			SetClientData is invoked again to set the clientdata to local version
			--		4. clientdata setting utilizes a lazy setting strategy, only set invoke the call 
			--			when needed: first SetClientData after ItemManager.SetClientData and 
			--			GetItemsInBag on every new coming web traffic
			----------------------------------------------------------------------------------
			--
			local output_msg = commonlib.LoadTableFromString(item.payload.data);
			if(output_msg and output_msg.items) then
				-- find the item with the right guid
				local _, item;
				for _, item in ipairs(output_msg.items) do
					if(item.guid == msg.guid) then
						output_msg.items[_].clientdata = msg.clientdata;
						break;
					end
				end
				-- make entry
				local item = {
					entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_bagfamily,}),
					payload = System.localserver.WebCacheDB.PayloadInfo:new({
						status_code = System.localserver.HttpConstants.HTTP_OK,
						data = (output_msg),
					}),
				}
				-- save to database entry
				local res = ls:PutItem(item);
				if(res) then 
					LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after SetClientData", tostring(url_bagfamily));
				else	
					LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after SetClientData", tostring(url_bagfamily))
					LOG.std("", "warning","Inventory", output_msg);
				end
			end
		end
	end -- if(ls) then

	if(msg.bmemorydbonly) then
		-- don't require web API call
		return true;
	end

	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SetClientData msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SetClientData msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
nil, nil, 5000);



--[[
	/// <summary>
	/// get all items in the specific bag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "nid" ] = string  // user to be searched
	///		[ "bag" ] = string  // bag to be searched, we only allow bagid from 10001 to 19999 visible to other user such as homeland items
	/// }
	/// </param>
	/// <returns>
	///		[ "items" ] = list{
	///			guid = int  // item instance id
	///			gsid = int
	///			obtaintime = string
	///			position = int
	///			clientdata = string
	///			serverdata = string
	///			copies = int
	///			}  // item count depending on the bag item count
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
local getitemsinotheruserbag_cache_policy = "access plus 10 minutes";
paraworld.create_wrapper("paraworld.inventory.GetItemsInOtherUserBag", "%MAIN%/API/Items/GetItemsInOtherUserBag.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInOtherUserBag msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInOtherUserBag msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);

--[[
    /// <summary>
    /// ��ǰ�û�������Ʒ
    /// ���ղ�����
    ///     sessionkey  ��ǰ��¼�û���sessionKey
    ///     guid  ������Ʒ��GUID
    ///     bag  ������Ʒ���ڵİ�ID
    ///     cnt  ��������
    /// ����ֵ��
    ///     issuccess  �Ƿ�ɹ�
    ///     [ deltaemoney ]  ������Ʒ��õ�E������
    ///     [ errorcode ]  (���ݲ����ڻ��ѱ�ɾ��[�û������ڻ���Ʒ������]  ��������[ӵ�е���Ʒ��������])
    /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.SellItem", "%MAIN%/API/Items/SellItem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SellItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
			local url = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.bag, "nid", Map3DSystem.User.nid})
			local item = ls:GetItem(url)
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(output_msg and output_msg.items) then
					-- pass 1: update the bag items
					local _, item;
					for _, item in ipairs(output_msg.items) do
						if(item.guid == inputMsg.guid) then
							item.copies = item.copies - inputMsg.cnt;
							break;
						end
					end
					-- pass 2: update the emoney in user info
					local url_getinfo = paraworld.users.getInfo.GetUrl();
					--local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
					--fields = string.lower(commonlib.Encoding.SortCSVString(fields));
					local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid,})
					local item = ls:GetItem(url_getinfo)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(type(output_msg) == "table") then
							-- update the $E
							if(output_msg.nid == Map3DSystem.User.nid) then
								output_msg.emoney = output_msg.emoney + msg.deltaemoney;
							end
							-- make entry
							local item = {
								entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
								payload = System.localserver.WebCacheDB.PayloadInfo:new({
									status_code = System.localserver.HttpConstants.HTTP_OK,
									data = (output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "User info of %s updated to local server after SellItem", tostring(url_getinfo));
							else	
								LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after SellItem", tostring(url_getinfo))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
					-- make entry
					local item = {
						entry = System.localserver.WebCacheDB.EntryInfo:new({url = url,}),
						payload = System.localserver.WebCacheDB.PayloadInfo:new({
							status_code = System.localserver.HttpConstants.HTTP_OK,
							data = (output_msg),
						}),
					}
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after SellItem", tostring(url));
					else	
						LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after SellItem", tostring(url))
						LOG.std("", "warning","Inventory", output_msg);
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SellItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);

--[[
        /// <summary>
        /// �����ǵĿͻ���ʹ����ʵ���ҹ�����Ʒ
        /// ���ղ�����
        ///     sessionkey
        ///     tonid  �յ���Ʒ���û���NID
        ///      gsid  ������Ʒ��GSID
        ///      cnt  ��������
        ///      pass  ֧������
        ///   ����ֵ��
        ///       issuccess  �����Ƿ�ɹ�
        ///      [ errorCode ] (int) �����롣 //�����롣 500��δ֪����  499���ṩ�����ݲ�����  497����Ʒ������  424������������������  411�����Ҳ���  419���û������ڻ򲻿��� 
        ///                  439���ױ��ʻ�������  440���ױ��ʻ�δ����  441������������������  442������������������
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.BuyWithRMB", "%MAIN%/API/Items/Buy.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.BuyWithRMB msg_in:");
		LOG.std("", "debug", "Inventory", msg);
	end
	if(ExternalUserModule.Init) then
		msg.from = ExternalUserModule:GetRegionID();
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.BuyWithRMB msg_out:");
		LOG.std("", "debug", "Inventory", msg);
	end
end
);

--[[
        /// <summary>
        /// �ϳɱ�ʯ
        /// ���ղ�����
        ///     nid : ��ǰ��¼�û���NID
        ///     froms : �����ϳɲ��ϵı�ʯ��guid��������guid,cnt|guid,cnt|....�����������ϳɵı�ʯ������ͬ���͵ģ�������ͬGSID
        ///     togsid : �ϳɺ�ı�ʯ��GSID
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
        ///     errorcode : �����롣��API�Ĵ�����Ƚ����⡣issuccessֻ�Ǳ�ʾ�Ƿ�ִ�гɹ���������ʾ�ϳ��Ƿ�ɹ���
        ///                     ֻ�е�issuccessΪtrue������errorcode��0ʱ�ű�ʾ�ϳɳɹ���
        ///                     ��issuccessΪtrue����errorcodeΪ492ʱ����ʾδ���и��ʣ�ִ����δ���и��ʵ��߼�
        ///     [ updates ][list] ��������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///     [ adds ][list] �������������
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        ///     [ stats ][list] ����һ��������ֵ�ı仯������-12��ʾ��ǰ�Ľ���״̬��0��������1��������2����������-1000��ʾ��������������һ����������ܶ�
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:���������ȣ�-8:�������ȼ���-9:����ֵ��-10:���ֵ��
        ///                 -11:����ֵ��-12:����״̬��-13:ս������ֵ��-14:ս���ȼ���-15:ħ��������ֵ��-16:ħ����Mֵ��-17:ħ���ǵȼ�
        ///         cnt
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.MergeGem", "%MAIN%/API/Items/MergeGem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.MergeGem msg_in:");
		LOG.std("", "debug", "Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.MergeGem msg_out:");
		LOG.std("", "debug", "Inventory", msg);
	end
end
);

--[[
        /// <summary>
        /// �ϳɱ�ʯ�������������
        /// ���ղ�����
        ///     sessionkey :
        ///     froms : �����ϳɲ��ϵı�ʯ��guid��������guid,cnt|guid,cnt|....�����������ϳɵı�ʯ������ͬ���͵ģ�������ͬGSID
        ///     togsid : �ϳɺ�ı�ʯ��GSID
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
        ///     errorcode : �����롣��API�Ĵ�����Ƚ����⡣issuccessֻ�Ǳ�ʾ�Ƿ�ִ�гɹ���������ʾ�ϳ��Ƿ�ɹ���
        ///                     ֻ�е�issuccessΪtrue������errorcode��0ʱ�ű�ʾ�ϳɳɹ���
        ///                     ��issuccessΪtrue����errorcodeΪ492ʱ����ʾδ���и��ʣ�ִ����δ���и��ʵ��߼�
        ///     [ updates ][list] ��������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///     [ adds ][list] �������������
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        ///     [ stats ][list] ����һ��������ֵ�ı仯������-12��ʾ��ǰ�Ľ���״̬��0��������1��������2����������-1000��ʾ��������������һ����������ܶ�
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:���������ȣ�-8:�������ȼ���-9:����ֵ��-10:���ֵ��
        ///                 -11:����ֵ��-12:����״̬��-13:ս������ֵ��-14:ս���ȼ���-15:ħ��������ֵ��-16:ħ����Mֵ��-17:ħ���ǵȼ�
        ///         cnt
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.MergeGem2", "%MAIN%/API/Items/MergeGem2.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.MergeGem2 msg_in:");
		LOG.std("", "debug", "Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.MergeGem2 msg_out:");
		LOG.std("", "debug", "Inventory", msg);
	end
end
);

--[[
        /// <summary>
        /// ��ָ����װ����ף�����棩
        /// ���ղ�����
        ///     sessionkey : ��ǰ��¼�û�
        ///     guid : װ����GUID
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
        ///     errorcode : �����롣
        ///     [ updates ][list] ��������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///         [ newsvrdata ]  �µ�ServerData�������Ʒ��ServerData�ѸĶ�������д˽ڵ������
        ///     [ stats ][list] ����һ��������ֵ�ı仯������-12��ʾ��ǰ�Ľ���״̬��0��������1��������2����������-1000��ʾ��������������һ����������ܶ�
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:���������ȣ�-8:�������ȼ���-9:����ֵ��-10:���ֵ��
        ///                 -11:����ֵ��-12:����״̬��-13:ս������ֵ��-14:ս���ȼ���-15:ħ��������ֵ��-16:ħ����Mֵ��-17:ħ���ǵȼ�
        ///         cnt
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.CreateGemHole", "%MAIN%/API/Items/CreateGemHole.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.CreateGemHole msg_in:");
		LOG.std("", "debug", "Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.CreateGemHole msg_out:");
		LOG.std("", "debug", "Inventory", msg);
	end
end
);

--[[
        /// <summary>
        /// ����ָ����һ��װ�����;ö�
        /// ���ղ�����
        ///     sessionkey
        ///     guids һ��װ����GUID�����GUID֮����Ӣ�Ķ��ŷָ�
        /// ����ֵ��
        ///     issuccess  
        ///     [ consumep ] ���ĵ���P��
        ///     [ consumee ] ��Ϣ����E��
        ///     [ updates ] [ list ] ServerData������Ӱ���װ��
        ///         guid
        ///         bag
        ///         serverdata  ���º��ServerData
        ///     [ errorcode ] �����롣 419:�û������ڣ�497:��Ʒ���ݲ����ڣ�493:����������411:PE�Ҳ���
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.ResetDurability", "%MAIN%/API/Items/ResetDurability.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.ResetDurability msg_in:");
		LOG.std("", "debug", "Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = System.localserver.CreateStore(nil, 3);
		if(ls) then
			-- pass 1: update the items in bag
			local _, update;
			for _, update in ipairs(msg.updates) do
				-- stack to existing items
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
				local item = ls:GetItem(url_getitemsinbag)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						-- update the serverdata
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.guid == update.guid) then
								output_msg.items[_].serverdata = update.serverdata;
								break;
							end
						end
						-- make entry
						local item = {
							entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
							payload = System.localserver.WebCacheDB.PayloadInfo:new({
								status_code = System.localserver.HttpConstants.HTTP_OK,
								data = (output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after PurchaseItem", tostring(url_getitemsinbag));
						else	
							LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after PurchaseItem", tostring(url_getitemsinbag))
							LOG.std("", "warning","Inventory", output_msg);
						end
					end
				end
			end
			--local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
			--fields = string.lower(commonlib.Encoding.SortCSVString(fields));
			local url_getinfo = paraworld.users.getInfo.GetUrl();
			url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid,})
			local item = ls:GetItem(url_getinfo);
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(type(output_msg) == "table") then
					output_msg.pmoney = output_msg.pmoney - msg.consumep;
					output_msg.emoney = output_msg.emoney - msg.consumee;
					-- make entry
					local item = {
						entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
						payload = System.localserver.WebCacheDB.PayloadInfo:new({
							status_code = System.localserver.HttpConstants.HTTP_OK,
							data = (output_msg),
						}),
					};
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "system","API", "user info of %s updated to local server after ResetDurability\n", tostring(url_getinfo));
					else	
						LOG.std("", "system","API", LOG.tostring("warning: failed updating user info of %s to local server after ResetDurability\n", tostring(url_getinfo))..LOG.tostring(output_msg));
					end
				end
			end
		end -- if(ls) then
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.ResetDurability msg_out:");
		LOG.std("", "debug", "Inventory", msg);
	end
end
);

--[[
		/// <summary>
        /// �û�ϴ��
        /// ���ղ�����
        ///     sessionkey  ��ǰ��¼�û���sessionkey
        /// ����ֵ��
        ///     issuccess
        ///     [ updates ][list] ����Ѹ��µľ�����
        ///         guid
        ///         bag
        ///         cnt   �ھ����ݵĻ��������ӵ����������磺-10��ʾ�ھ����ݵĻ����ϼ�����10��
        ///     [ errorcode ]  500:δ֪����  419:�û�������  443:ħ������  493:��������
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.ResetTrainingPoint", "%MAIN%/API/Items/ResetTrainingPoint.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug", "Inventory", "paraworld.inventory.ResetTrainingPoint msg_in:");
		LOG.std("", "debug", "Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		--local ls = System.localserver.CreateStore(nil, 3);
		--if(ls) then		
			---- pass 1: update the items in bag
			--local _, update;
			--for _, update in ipairs(msg.updates) do
				---- stack to existing items
				--local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				--local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
				--local item = ls:GetItem(url_getitemsinbag)
				--if(item and item.entry and item.payload) then
					--local output_msg = commonlib.LoadTableFromString(item.payload.data);
					--if(output_msg and output_msg.items) then
						---- update the copies
						--local _, item;
						--for _, item in ipairs(output_msg.items) do
							--if(item.guid == update.guid) then
								--output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
								--break;
							--end
						--end
						---- make entry
						--local item = {
							--entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
							--payload = System.localserver.WebCacheDB.PayloadInfo:new({
								--status_code = System.localserver.HttpConstants.HTTP_OK,
								--data = (output_msg),
							--}),
						--}
						---- save to database entry
						--local res = ls:PutItem(item);
						--if(res) then 
							--LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after ResetTrainingPoint:guid:%d|cnt:%d", tostring(url_getitemsinbag),update.guid,update.cnt);
						--else	
							--LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after ResetTrainingPoint", tostring(url_getitemsinbag))
							--LOG.std("", "warning","Inventory", output_msg);
						--end
					--end
				--end
			--end -- for __,update
--
			--local _, add;
			--for _, add in ipairs(msg.adds) do
				---- newly created items
				--local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				--local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
				--local item = ls:GetItem(url_getitemsinbag)
				--if(item and item.entry and item.payload) then
					--local output_msg = commonlib.LoadTableFromString(item.payload.data);
					--if(output_msg and output_msg.items) then
						---- find the largest position in the bag
						--local _, item_t;
						--local max_position = 0;
						--for _, item_t in pairs(output_msg.items) do
							--if(item_t.position > max_position) then
								--max_position = item_t.position;
							--end
						--end
						---- add item into bag
						--local isExist = false;
						--local _, item;
						--for _, item in ipairs(output_msg.items) do
							--if(item.guid == add.guid) then
								--output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
								---- item already exist in bag with the same guid
								--LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." only appended.");
								--isExist = true;
								--break;
							--end
						--end
						--if(isExist == false) then
							--table.insert(output_msg.items, {
								--guid = add.guid, 
								--gsid = add.gsid,
								--obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
								---- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
								--position = add.position,
								--clientdata = "",
								--serverdata = "",
								--copies = add.cnt,
							--});
						--end
						---- make entry
						--local item = {
							--entry = System.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
							--payload = System.localserver.WebCacheDB.PayloadInfo:new({
								--status_code = System.localserver.HttpConstants.HTTP_OK,
								--data = (output_msg),
							--}),
						--}
						---- save to database entry
						--local res = ls:PutItem(item);
						--if(res) then 
							--LOG.std("", "debug","Inventory", "Bag Items of %s added to local server after ResetTrainingPoint:gsid:%d|guid:%d|cnt:%d", tostring(url_getitemsinbag),add.gsid,add.guid,add.cnt);
						--else	
							--LOG.std("", "warning","Inventory", "failed adding bag items of %s to local server after ResetTrainingPoint", tostring(url_getitemsinbag))
							--LOG.std("", "warning","Inventory", output_msg);
						--end
					--end
				--end
			--end	-- for __,add			
				--
		--end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ResetTrainingPoint msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);

--[[
        /// ʹ���Ż�ȯ���ҽ�ȯ
        /// ���ղ�����
        ///     sessionkey
        ///     code �Ż�ȯ���ҽ�ȯ
        ///     exid ʹ�ô�ȯ��ִ�е�Extended ID
        /// ����ֵ��
        ///     issuccess
        ///     [ updates ][list] ����һ�������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///     [ adds ][list] ����һ�������������
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        ///         [ svrdata ]
        ///     [ stats ][list] ����һ��������ֵ�ı仯
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:���������ȣ�-8:�������ȼ���-9:����ֵ��-10:���ֵ��-11:����ֵ��-12:����״̬��-13:ս������ֵ��-14:ս���ȼ���-1000:��������������һ����������ܶȣ�-1001:��ʾ�ڿͻ��˵���������һ������Ҫ��ս������ֵ��-1002:��ʾ�ڿͻ��˵ĵ�ǰս������ֵ
        ///         cnt
        ///     [ errorcode ]����421:ȯ�ѱ�ʹ�û򲻴��ڣ�
]] 
paraworld.create_wrapper("paraworld.inventory.UseVoucherCode", "%MAIN%/API/Items/UseVoucherCode.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	LOG.std("", "debug","UseVoucherCode.invoke", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std("", "debug","UseVoucherCode.result", msg);
	
	if(msg and msg.issuccess) then
		Map3DSystem.Item.ItemManager.UpdateBagItems(msg.ups or msg.updates, msg.adds, msg.stats);
	end
end
);

--[[
        /// <summary>
        /// ����û�����õ��Ѿ����ڵ���Ʒ�����������
        /// ���ղ�����
        ///     sessionkey
        ///     guids ֻ���ָ������Ʒ�����GUID֮����Ӣ�Ķ��ŷָ�����Ҫ���ȫ�����򲻴��˲���
        /// ����ֵ��
        ///     [] [list] �������ɹ�����᷵�ر������Ʒ��GUID�б�
        ///     [ errorcode ] �������ʧ�ܣ��򷵻ش�����
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.CheckExpire", "%MAIN%/API/Items/CheckExpire.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	LOG.std("", "debug","CheckExpire.invoke", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std("", "debug","CheckExpire.result", msg);
	
	--if(msg and msg.issuccess) then
		--Map3DSystem.Item.ItemManager.UpdateBagItems(msg.ups or msg.updates, msg.adds, msg.stats);
	--end
end
);

--[[
/// <summary>
/// ������Ʒ��һ��������
/// ���ղ�����
///     nid
///     items: Ҫ�޸ĵ����ݣ������ڣ�gsid,cnt,clientdata|gsid,cnt,clientdata|gsid,cnt,clientdata....������cnt��ʾҪ���ӵ�
///                ������ֻ��Ϊ���ڣ������֣�gsidҲ����Ϊ���ڣ������֣�clientData�в��ɰ����С�,����"|"�����ַ���Ҳ�����ǡ�NULL��������ָ������"NULL"��
/// ����ֵ��
///     issuccess
///     [ deltaemoney ]�����ĵ�E�����ݣ��磺-10��ʾ������10��E��
///     [ updates ][list] ��������ھ������ϵ���Ʒ
///         guid
///         bag
///         cnt
///     [ adds ][list] �������������
///         guid
///         gsid
///         bag
///         cnt
///         position
///     [ errorcode ]
/// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.PurchaseItems", "%MAIN%/API/Items/PurchaseItems.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	LOG.std("", "debug","PurchaseItems.invoke", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std("", "debug","PurchaseItems.result", msg);
	if(msg and msg.issuccess) then
		Map3DSystem.Item.ItemManager.UpdateBagItems(msg.ups or msg.updates, msg.adds, msg.stats);
	end
end
);

--[[
/// <summary>
/// ��ָ����Ʒ����ָ���û���ָ������
/// ���ղ�����
///     gsid
///     cnt
///     tonid ��������Ʒ���û���NID
///     tobag ����˱��������벻С��50000����tobag==50100ʱ����ǰ�û���tonid�û�������ͬһ�����Ա
///     [ pricegsid ] ���ô���Ʒ����
///     [ pricecnt ] ��֧�����ٸ�pricegsid��Ʒ�ſɹ���
/// ����ֵ��
///     errorcode 419:�û������ڣ�438:���ɽ��д˲�����427:��Ʒ����
/// </summary>
]]
paraworld.create_wrapper("paraworld.inventory.DonateToBag", "%MAIN%/API/Items/DonateToBag.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	LOG.std("", "debug","DonateToBag.invoke", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std("", "debug","DonateToBag.result", msg);
	if(msg and (msg.updates or msg.adds)) then
		Map3DSystem.Item.ItemManager.UpdateBagItems(msg.ups or msg.updates, msg.adds, msg.stats);
	end
end
);

--[[
/// <summary>
/// ����ָ���û�ָ��������Ʒ�ļ۸�
/// ���ղ�����
///     tonid �޸ĵ���Ʒ�Ǵ��û���
///     bag ��Ʒ���ڵİ�
///     guid
///     pricegsid �¼۸�
///     pricecnt
/// ����ֵ��
///     errorcode 438:���ɽ��д˲�����493:��������
/// </summary>
]]
paraworld.create_wrapper("paraworld.inventory.ChangeItemPriceInBag", "%MAIN%/API/Items/ChangeItemPriceInBag.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	LOG.std("", "debug","ChangeItemPriceInBag.invoke", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std("", "debug","ChangeItemPriceInBag.result", msg);
	if(msg and msg.issuccess) then
		Map3DSystem.Item.ItemManager.UpdateBagItems(msg.ups or msg.updates, msg.adds, msg.stats);
	end
end
);

--[[
/// <summary>
/// ����һ���û������ⱳ���й�����Ʒ
/// ���ղ�����
///     tonid: ����
///     bag�� ���bag>=200 and bag<=299 (Ϊֻ���������κ��û������Լ������ɹ��� ֻ��Server��PowerAPI����)
///     guid
///     cnt
/// ����ֵ��
///     errorcode: 438:���ɽ��д˲�����
/// </summary>
]]
paraworld.create_wrapper("paraworld.inventory.PurchaseFromBag", "%MAIN%/API/Items/PurchaseFromBag.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	LOG.std("", "debug","PurchaseFromBag.invoke", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std("", "debug","PurchaseFromBag.result", msg);
	if(msg and (not msg.errorcode or msg.errorcode == 0)) then
		Map3DSystem.Item.ItemManager.UpdateBagItems(msg.ups or msg.updates, msg.adds, msg.stats);
	end
end
);