--[[
Title: power api inventory
Author(s): WangTian
Date: 2010/8/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/AriesPowerAPI/paraworld.PowerAPI.inventory.lua");
-------------------------------------------------------
]]

-- create class
commonlib.setfield("paraworld.PowerAPI.inventory", {});
commonlib.setfield("paraworld.PowerAPI.globalstore", {});

local isLogInventoryTraffic = true;

--[[
	/// <summary>
	/// get the global store description and template data according to the global store id
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "gsids" ] = string  // global store ids separated with ","  maximum gsids per request is 10
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "globalstoreitems" ] = list{
	///			gsid = int
	///			assetfile = string
	///			descfile = string
	///			type = int
	///			category = string
	///			icon = string
	///			pbuyprice = int
	///			ebuyprice = int
	///			psellprice = int
	///			esellprice = int
	///			requirepayment = int
	///			template = {
	///				class = int
	///				subclass = int
	///				name = int
	///				inventorytype = int
	///				// and other template data fields
	///				}
	///			}  // item count depending on the gsids count
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
-- TODO: put item description into global store
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.globalstore.read", "Items.read", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = "1";
	msg._nid = "1";

	--if(isLogInventoryTraffic) then
		--LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.globalstore.read msg_in: "..commonlib.serialize_compact(msg));
	--end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	--if(isLogInventoryTraffic) then
		--LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.globalstore.read msg_out: "..commonlib.serialize_compact(msg));
	--end
end,
nil,nil, nil,nil, 100000);

--[[
        /// <summary>
        /// ȡ��ָ����һ��GlobalStore����read�������ǣ���������gsids����Ϊ���ַ���ʱ�������������Ѷ������Ʒ��
        /// ���Ҳ���ÿ�οɻ�ȡ�����������ֵ�����ơ���GameServerʹ�á�
        /// </summary>
        /// <param name="msg">
        /// msg = {
        ///      [ "gsids" ] = string  // global store ids separated with ","  maximum gsids per request is 10
        /// }
        /// </param>
        /// <returns>
        ///      [ �� Item.read ��ͬ ]
        /// </returns>
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.globalstore.GetALLGS", "Items.GetALLGS", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = "1";
	msg._nid = "1";

	--if(isLogInventoryTraffic) then
		--LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.globalstore.read msg_in: "..commonlib.serialize_compact(msg));
	--end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	--if(isLogInventoryTraffic) then
		--LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.globalstore.read msg_out: "..commonlib.serialize_compact(msg));
	--end
end);


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
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.GetItemsInBag", "Items.GetItemsInBag", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	msg.bag = tonumber(msg.bag);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBag got nil nid");
		return true;
	elseif(not msg.bag) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBag got nil bag");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBag msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBag msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
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
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.GetItemsInBags", "Items.GetItemsInBags", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	msg._nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBags got nil nid");
		return true;
	elseif(not msg.bags) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBags got nil bags");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBags msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.GetItemsInBags msg_out: "..commonlib.serialize_compact(msg));
	end
end);


--[[
        /// <summary>
        /// �޸�ָ���û�����Ʒ����
        /// ���ղ�����
        ///     nid
        ///     pres: ǰ�������������������㣬�򲻻�ִ�С������ڣ�gsid~cnt|gsid~cnt|gsid~cnt....��GSID����Ϊ������cntΪ������ʾ���ڵ��ڴ�ֵ��cntΪ������ʾС�ڵ��ڴ�ֵ
        ///     sets: ��ָ�����û���������Ϊָ����ֵ��gsid~cnt|gsid~cnt.....GSID����Ϊ����
        ///     adds: Ҫ�޸ĵ����ݣ������ڣ�gsid~cnt~serverdata~clientdata~isgreedy|gsid~cnt~serverdata~clientdata~isgreedy|gsid~cnt~serverdata~clientdata~isgreedy....������cnt��ʾҪ���ӵ�
        ///                    ��������Ϊ��������ʾ���ٵ�������clientData��serverData�в��ɰ����С�~����"|"�����ַ���Ҳ�����ǡ�NULL��������ָ������"NULL"��isgreedyָ��������������Ƿ���̰��ģʽ��
        ///                    0��ʾfalse����0��ʾtrue���ɲ����ݣ���������������ⲿ��isgreedy����ΪĬ��ֵ�����д��ݣ�������ⲿ��isgreedy������
        ///     updates: ��ָ����������������������Ʒ�������ڣ�guid~cnt~serverdata~clientdata~isgreedy|guid~cnt~serverdata~clientdata~isgreedy|guid~cnt~serverdata~clientdata~isgreedy....��
        ///                    ����cnt��ʾҪ���ӵ���������Ϊ��������ʾ���ٵ�������clientData��serverData�в��ɰ����С�~����"|"�����ַ���Ҳ�����ǡ�NULL��������ָ����
        ///                    ��"NULL"��ע���������GUID������GSID�����update��ָ������Ʒ��������update��ָ���������������С��0��������ݽ��ᱻɾ����
        ///                    �������GlobalStore���趨��MaxCopiesInStack����Ὣ������������ᱻ���ԡ�isgreedyָ��������������Ƿ���̰��ģʽ��0��ʾfalse����0��ʾtrue���ɲ����ݣ���������
        ///                    ������ⲿ��isgreedy����ΪĬ��ֵ�����д��ݣ�������ⲿ��isgreedy������
        ///     isgreedy��boolean���Ƿ���̰��ģʽ�������true����adds��updates�����в������������Ƶģ�����ԣ���������ִ�У������false����ֻҪ���κ�һ�����������������ع�����ֵ�ᱻadds��updates��
        ///                     ÿ�������Լ���isgreedy���ǡ�
        /// ����ֵ��
        ///     issuccess
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
        ///         gsid  -1:P�ң�0:E�ң�-2:���ܶȣ�-3:����ֵ��-4:����ֵ��-5:����ֵ��-6:�ǻ�ֵ��-7:���������ȣ�-8:�������ȼ���-9:����ֵ��-10:���ֵ��-11:����ֵ��-12:����״̬��-13:ս������ֵ��-14:ս���ȼ���
        ///         cnt
        ///     [ errorcode ]
        /// </summary>
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.ChangeItem", "Power_Items.ChangeItem", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.ChangeItem got nil nid");
		return true;
	elseif(not msg.adds and not msg.updates and not msg.sets) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.ChangeItem got nil adds or nil updates or nil sets");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ChangeItem msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ChangeItem msg_out: "..commonlib.serialize_compact(msg));
	end
end);

-- ExtendedCost is usually used in power version, not directly from user request.  
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.ExtendedCost", "Items.ExtendedCost", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ExtendedCost msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ExtendedCost msg_out: "..commonlib.serialize_compact(msg));
	end
end);

-- ExtendedCost2 is usually used in power version, not directly from user request.  
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.ExtendedCost2", "Items.ExtendedCost2", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ExtendedCost2 msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ExtendedCost2 msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
        /// <summary>
        /// ��ָ����װ����Ƕָ���ı�ʯ
        /// ���ղ�����
        ///     sessionkey : 
        ///     containerguid : װ����GUID
        ///     gemguid : Ҫװ���ı�ʯ��GUID
        ///     cards : һ��ʹ�õĿ������ӳɹ����ʵ���Ƕ����GUID��Cnt�������Ƕ��֮�������߷ָ���guid,cnt|guid,cnt|.....��
        ///                 ע�⣺�������ظ���guid�������Ǵ���ģ�1001,1|1002,1|1001,2�� �������Ӧ��д�ɣ�1001,3|1002,1
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
        ///     errorcode : �����롣��API�Ĵ�����Ƚ����⡣issuccessֻ�Ǳ�ʾ�Ƿ�ִ�гɹ���������ʾ��Ƕ�Ƿ�ɹ���
        ///                     ֻ�е�issuccessΪtrue������errorcode��0ʱ�ű�ʾ��Ƕ�ɹ���
        ///                     ��issuccessΪtrue����errorcodeΪ492ʱ����ʾδ���и��ʣ�ִ����δ���и��ʵ��߼�
        ///     [ updates ][list] ��������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///         [ newsvrdata ]  �µ�ServerData�������Ʒ��ServerData�ѸĶ�������д˽ڵ������
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
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.EquipGem", "Items.EquipGem", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem got nil nid");
		return true;
	elseif(not msg.containerguid or not msg.gemguid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem got nil containerguid or nil gemguid, msg: "..commonlib.serialize_compact(msg));
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
        /// <summary>
        /// ʹ�õ�����ָ����װ���ϵ�ָ����һ��ָ���ı�ʯ�Ƴ����Ƴ��ı�ʯ��������û��İ��У���ʯ������ʧ����ʯ����ֻ������һ��Instance���ݣ���Ϊ��ʯ�������ᱻ�ƶ���������
        /// ���ղ�����
        ///     sessionkey : ��ǰ��¼�û���SessionKey
        ///     containerguid : װ����GUID
        ///     gemgsids : һ�鱻�Ƴ��ı�ʯ��GSID�б����GSID֮����Ӣ�ﶺ�ŷָ�
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
        ///     errorcode : ������
        ///     [ updates ][list] ��������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///         [ newsvrdata ]  �µ�ServerData�������Ʒ��ServerData�ѸĶ�������д˽ڵ������
        ///     [ adds ][list] �������������
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        /// </summary>
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.UnEquipGem", "Items.UnEquipGem", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem got nil nid");
		return true;
	elseif(not msg.containerguid or not msg.gemgsids) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem got nil containerguid or nil gemgsids, msg: "..commonlib.serialize_compact(msg));
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem msg_out: "..commonlib.serialize_compact(msg));
	end
end);


--[[
        /// ��ָ����װ����Ƕָ���ı�ʯ������棩
        /// ���ղ�����
        ///     sessioneky : ��ǰ��¼�û�
        ///     containerguid : װ����GUID
        ///     gemguid : Ҫװ���ı�ʯ��GUID
        ///     cards : һ��ʹ�õĿ������ӳɹ����ʵ���Ƕ����GUID��Cnt�������Ƕ��֮�������߷ָ���guid,cnt|guid,cnt|.....��
        ///                 ע�⣺�������ظ���guid�������Ǵ���ģ�1001,1|1002,1|1001,2�� �������Ӧ��д�ɣ�1001,3|1002,1
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
        ///     errorcode : �����롣��API�Ĵ�����Ƚ����⡣issuccessֻ�Ǳ�ʾ�Ƿ�ִ�гɹ���������ʾ��Ƕ�Ƿ�ɹ���
        ///                     ֻ�е�issuccessΪtrue������errorcode��0ʱ�ű�ʾ��Ƕ�ɹ���
        ///                     ��issuccessΪtrue����errorcodeΪ492ʱ����ʾδ���и��ʣ�ִ����δ���и��ʵ��߼���
        ///                     433:û���㹻�Ŀ��ˣ�493:�ṩ��ĳ������������Ҫ��427:PE�Ҳ��㣻497:�����е�ĳ����Ʒ�����ڣ�417:����Ƕ��ͬ��ı�ʯ��
        ///     [ updates ][list] ��������ھ������ϵ���Ʒ
        ///         guid
        ///         bag
        ///         cnt
        ///         [ newsvrdata ]  �µ�ServerData�������Ʒ��ServerData�ѸĶ�������д˽ڵ������
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
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.EquipGem2", "Items.EquipGem2", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem2 got nil nid");
		return true;
	elseif(not msg.containerguid or not msg.gemguid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem2 got nil containerguid or nil gemguid, msg: "..commonlib.serialize_compact(msg));
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem2 msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.EquipGem2 msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
        /// <summary> TODO
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.UnEquipGem2", "Items.UnEquipGem2", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem2 got nil nid");
		return true;
	elseif(not msg.containerguid or not msg.gemgsids) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem2 got nil containerguid or nil gemgsids, msg: "..commonlib.serialize_compact(msg));
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem2 msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.UnEquipGem2 msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
        /// <summary>
        /// ʹ������һ�ָ������װ�е����
        /// ���ղ�����
        ///     sessionkey
        ///     gsid  ��װ�������GSID
        /// ����ֵ��
        ///     issuccess : �Ƿ�ɹ�
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
        ///     [ errorcode ] : �����롣427:���õ���ʯ���㣻493:���������ָ����GSID�����Ѷ������װ�е���Ʒ��497:ָ����GSID������
        /// </summary>
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.ItemSetExtendedCost", "Items.ItemSetExtendedCost", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.ItemSetExtendedCost got nil nid");
		return true;
	elseif(not msg.gsid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.ItemSetExtendedCost got nil gsid, msg: "..commonlib.serialize_compact(msg));
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ItemSetExtendedCost msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.ItemSetExtendedCost msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
        /// <summary>
        /// ȡ��ָ���û�ӵ��ָ������Ʒ��״̬
        /// ���ղ�����
        ///     nid
        ///     gsid
        /// ����ֵ��
        ///     allow�� int �Ƿ�������0������1����
        ///     cnt:  int ��ӵ�д���Ʒ������
        ///     max:  int ����ӵ�д���Ʒ������
        ///     [ errorcode ]:  int 497:��Ʒ������
        /// </summary>

]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.GetState", "Power_Items.GetState", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	msg.gsid = tonumber(msg.gsid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.GetState got nil nid");
		return true;
	elseif(not msg.gsid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.GetState got gsid");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.GetState msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.GetState msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
		/// <summary>
        /// �����û�֮�以����Ʒ
        /// ���ղ�����
        ///     nid0    ��һ���û���NID
        ///     items0  ��һ���û�������������Ʒ��guid,cnt|guid,cnt|guid,cnt....��guid==-1��ʾP��
        ///     nid1    �ڶ����û���NID
        ///     items1  �ڶ����û�������������Ʒ��guid,cnt|guid,cnt|guid,cnt....��guid==-1��ʾP��
        /// ����ֵ��
        ///     issuccess
        ///     [ ups0 ] [ list ] ִ�гɹ����һ���û����޸ĵ�����
        ///         guid  ���޸���Ʒ��GUID
        ///         copies  ���޸ĵ���Ʒ���ڵ�����
        ///     [ ups1 ] [ list ] ִ�гɹ���ڶ����û� ���޸ĵ�����
        ///         guid  ���޸���Ʒ��GUID
        ///         copies  ���޸ĵ���Ʒ���ڵ�����
        ///     [ adds0 ] [ list ] ִ�гɹ����һ���û�����������
        ///         guid  ������Ʒ��GUID
        ///         gsid  ������Ʒ��GSID
        ///         bag   ������Ʒ���ڵİ�
        ///         pos   ������Ʒ��Positionֵ
        ///         copies ������Ʒ��Copiesֵ
        ///         svrdata ������Ʒ��ServerDataֵ
        ///     [ adds1 ] [ list ] ִ�гɹ���ڶ����û�����������
        ///         guid  ������Ʒ��GUID
        ///         gsid  ������Ʒ��GSID
        ///         bag   ������Ʒ���ڵİ�
        ///         pos   ������Ʒ��Positionֵ
        ///         copies ������Ʒ��Copiesֵ
        ///         svrdata ������Ʒ��ServerDataֵ
        ///     [ errorcode ] 493:��������  419:�û�������  497:������������Ʒ������  424:����������ӵ�е�����  
        /// </summary>
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.Transaction", "Items.Transaction", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not msg.nid0 or not msg.nid1) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.Transaction got nil nid");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.Transaction msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.Transaction msg_out: "..commonlib.serialize_compact(msg));
	end
end);

--[[
/// <summary>
/// ����װ����ǿ���ȼ�
/// ���ղ�����
///     sessionkey
///     guid Ҫǿ���ȼ���װ����GUID
///     addlel ǿ���ĵȼ�
///     reqgsid ��Ҫ����Ʒ��GSID
///     reqcnt ��Ҫ����Ʒ������
/// ����ֵ��
///     issuccess
///     ups [ list ] ��Ӱ��������б�
///         guid ��Ӱ�����Ʒ��GUID
///         copies Ŀǰ��Copiesֵ
///         [ serverdata ] Ŀǰ��ServerDataֵ����û��Ӱ���ֵ���򲻻᷵�ش�������
///     [ errorcode ] 419:�û������ڣ�497:��Ʒ�����ڣ�427:��������
/// </summary>
]]
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.SetItemAddonLevel", "Items.SetItemAddonLevel", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not msg.guid or not msg.addlel) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.SetItemAddonLevel got nil guid or addlel");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.SetItemAddonLevel msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.SetItemAddonLevel msg_out: "..commonlib.serialize_compact(msg));
	end
end);


--[[
        /// <summary>
        /// ����û�����õ��Ѿ����ڵ���Ʒ�����������
        /// ���ղ�����
        ///     sessionkey
        /// ����ֵ��
        ///     [] [list] �������ɹ�����᷵�ر������Ʒ��GUID�б�
        ///     [ errorcode ] �������ʧ�ܣ��򷵻ش�����
        /// </summary>
]] 
paraworld.createPowerAPI("paraworld.PowerAPI.inventory.CheckExpire", "Power_Items.CheckExpire", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	msg.nid = tonumber(msg.nid);
	
	if(not msg.nid) then
		LOG.std(nil, "error", "PowerAPI", "paraworld.PowerAPI.inventory.CheckExpire got nil nid");
		return true;
	end
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.CheckExpire msg_in: "..commonlib.serialize_compact(msg));
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(isLogInventoryTraffic) then
		LOG.std(nil, "debug", "PowerAPI", "paraworld.PowerAPI.inventory.CheckExpire msg_out: "..commonlib.serialize_compact(msg));
	end
end);