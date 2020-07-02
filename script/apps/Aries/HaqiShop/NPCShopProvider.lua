--[[
Title: 
Author(s): leio
Date: 2011/09/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
NPCShopProvider.DoResetDurability();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/DateTime.lua");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");

--通过gsid记录每天购买次数的常量
NPCShopProvider.gsid_daychoice_map = {};
--当天购买次数限制--------------------------------------------------------------------------
function NPCShopProvider.LoadDaychoice(gsid)
	local self = NPCShopProvider;
	if(not gsid)then return end
	local count = 0;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem and gsItem.maxdailycount and gsItem.maxdailycount~=0) then
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid);
		if(gsObtain and gsObtain.inday) then
			count = gsObtain.inday;
		end
	end
	local nid = Map3DSystem.User.nid;
	local date = Scene.GetServerDate();
	local key = string.format("NPCShopProvider.Daychoice");
	local map = MyCompany.Aries.Player.LoadLocalData(key, {});
	if(map.date==date)then
		count = math.max(count, map[gsid] or 0);
	end
	return count;
end
function NPCShopProvider.SaveDaychoice(gsid,num)
	local self = NPCShopProvider;
	local max_choice = NPCShopProvider.GetMaxChoice(gsid);
	--忽略记录
	if(max_choice == -1)then
		return
	end
	local nid = Map3DSystem.User.nid;
	local date = Scene.GetServerDate();
	local key = string.format("NPCShopProvider.Daychoice");
	local map = MyCompany.Aries.Player.LoadLocalData(key, {});
	if(map.date~=date)then
		map = {date = date};
	end
	map[gsid] = num;
	MyCompany.Aries.Player.SaveLocalData(key, map);
end

--获得后台配置最大数量
function NPCShopProvider.GetMaxCount(gsid)
	local self = NPCShopProvider;
	if(gsid)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			return gsItem.template.maxcount;
		end
		return 0;
	end
	return 0;
end
-- get max daily copies taking both client and server into consideration.  
function NPCShopProvider.GetMaxChoice(gsid)
	local self = NPCShopProvider;
	if(gsid)then
		local max_daily_count;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem and gsItem.maxdailycount and gsItem.maxdailycount~=0) then
			max_daily_count = gsItem.maxdailycount;
		end
		if(self.gsid_daychoice_map) then
			local client_daily_count = self.gsid_daychoice_map[gsid];
			if(client_daily_count) then
				return math.min(client_daily_count, max_daily_count or client_daily_count);
			end
		end
		return max_daily_count;
	end
end


----------------------------------------------------------------------------

function NPCShopProvider.GetFilePath()
	if(CommonClientService.IsKidsVersion())then
		return "config/Aries/NPCShop/npcshop.xml";
	else
		return "config/Aries/NPCShop_Teen/npcshop.teen.xml";
	end
end

local function add_npc_row_to_item(gsItem, row)
	-- only single item exchange is allowed. 
	if(not gsItem.npc_shop_items) then
		gsItem.npc_shop_items = {[1] = row};
	else
		local bDuplicatedExid;
		local _, item;
		for _, item in ipairs(gsItem.npc_shop_items) do
			if(item.exid == row.exid) then
				-- remove duplicated exid
				if(item.npcid  > row.npcid and row.npcid>0) then
					-- overwrite if npcid is smaller. we will always use the smaller npcid
					gsItem.npc_shop_items[_] = row;
				end
				bDuplicatedExid = true;
			end
		end
		if(not bDuplicatedExid) then
			if(row.npcid and row.npcid>0) then
				gsItem.npc_shop_items[#(gsItem.npc_shop_items) + 1] = row;
			end
		end
	end
end

function NPCShopProvider.LoadConfig()
	local self = NPCShopProvider;
	local file_path = self.GetFilePath();
	local xmlRoot = ParaXML.LuaXML_ParseFile(file_path);
	local k,v;
	local result = {};
	local gsid_daychoice_map = {};
	local index = 1;
	local nodes;
	if(not xmlRoot or #xmlRoot==0) then
		LOG.std(nil, "error", "NPCShopProvider", "Failed to LoadConfig: %s", file_path);
	else
		LOG.std(nil, "debug", "NPCShopProvider", "LoadConfig: %s", file_path)
	end
	
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day  = today:match("(%d+)%D(%d+)%D(%d+)");
	day = tonumber(day);
	month = tonumber(month);
	year = tonumber(year);

	local is_kids = System.options.version == "kids";
	local function to_table(s)
		if(not s)then return end
		local t = {};
		local gsid;
		for gsid in string.gfind(s, "[^#]+") do
			gsid = tonumber(gsid);
			--过滤 haqi_GameCurrency 和 haqi_RMB_Currency  因为默认总是显示这两种货币
			if(gsid and gsid > 0 and (is_kids or gsid ~= 984))then
				table.insert(t,{gsid = gsid});
			end
		end
		return t;
	end
	local my_region_id = MyCompany.Aries.ExternalUserModule:GetRegionID();
	local my_locale = System.options.locale;
	for nodes in commonlib.XPath.eachNode(xmlRoot, "/Workbook/Worksheet/Table/Row") do
		if(index > 1)then
			local cell_nodes;
			local row = {};
			local col_index = 1;
			local can_push = false;
			local gsid;
			for cell_nodes in commonlib.XPath.eachNode(nodes, "/Cell") do
				local cell_data = cell_nodes[1];
				if(cell_nodes.attr) then
					local col_force_index = cell_nodes.attr["ss:Index"];
					if(col_force_index) then
						col_index = tonumber(col_force_index) or col_index;
					end
				end
				if(cell_data and cell_data.name == "Data") then
					local value = cell_data[1];
					if(col_index == 1)then
						value = tonumber(value);
						row["npcid"] = value;
						if(value and value>-1000)then
							can_push = true;
						end
					elseif(col_index == 2)then
						row["superclass"] = value or "menu1";
					elseif(col_index == 3)then
						row["class"] = value or "normal";
					elseif(col_index == 4)then
						row["class_name"] = value or "通用";
					elseif(col_index == 5)then
						gsid = tonumber(value);
						row["gsid"] = gsid;
					elseif(col_index == 6)then
						row["exid"] = tonumber(value);
					elseif(col_index == 7)then
						row["money_list"] = to_table(value);
					elseif(col_index == 8)then
						--当天购买次数
						--记录每天购买最大次数 nil or -1为无限制
						row["daychoice"] = tonumber(value);
					elseif(col_index == 11)then
						-- locale plus region_id
						local locale, region_id = value:match("^(%D*)(%d*)$");
						if(locale == "") then
							locale = nil;
						end
						region_id = tonumber(region_id);
						
						if(region_id and my_region_id ~= region_id) then
							can_push = false;
						end
						if(locale and locale ~= my_locale) then
							can_push = false;
						end
					elseif(col_index == 12)then
						-- sell time range. (min hour day month [weekday])(min hour day month [weekday])
						row["time_range"] = value;
						local range = commonlib.timehelp.datetime_range:new(value);
						if(not range:is_matched(nil, nil, day, month, year)) then
							can_push = false;
						end
					end
				end
				col_index = col_index + 1;
			end
			if(can_push and gsid)then
				if(not gsid_daychoice_map[gsid])then
					gsid_daychoice_map[gsid] = row["daychoice"];
				end
				row["dailytotal"] = row["daychoice"] or 0;

				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					row["time_range"] = row["time_range"] or ""
					-- added 246 recommended_school(CG)
					local school_id = gsItem.template.stats[137] or gsItem.template.stats[169] or gsItem.template.stats[246];
					local require_school;
					if(school_id == 6) then
						require_school = "fire";
					elseif(school_id == 7) then
						require_school = "ice";
					elseif(school_id == 8) then
						require_school = "storm";
					elseif(school_id == 9) then
						require_school = "myth";
					elseif(school_id == 10) then
						require_school = "life";
					elseif(school_id == 11) then
						require_school = "death";
					elseif(school_id == 12) then
						require_school = "balance";
					end

					local require_level = gsItem.template.stats[138] or gsItem.template.stats[168] or 0;
					row["require_level"] = require_level;
					row["require_school"] = require_school;
					row["name"] = gsItem.template.name; -- for full text search

					local exTemplate;
					if(row.exid and row.exid ~= 0) then
						exTemplate = ItemManager.GetExtendedCostTemplateInMemory(row.exid);
					else
						row.exid = row.exid or 0;
					end
					if(exTemplate and exTemplate.tos)then
						local _,_v;
						for _,_v in pairs(exTemplate.tos) do
							local _gsid = tonumber(_v.key);
							if (_gsid>50000 and _gsid<60000) then
								local _gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
								if(_gsItem and _gsItem.maxdailycount and _gsItem.maxdailycount~=0) then
									row["dailytotal"] = _gsItem.maxdailycount;
								end
							end
							if(gsid == _gsid) then
								-- NOTE 2014/8/5: automatically add ShowCount to gsid
								local count = tonumber(_v.value);
								if(count and count > 1) then
									row.ShowCount = tonumber(_v.value);
								end
							end
						end
					end
					-- Important: verify extended cost, so that emoney selling price is always smaller than buying price. 
					if(row.exid == 0) then
						-- items that sell modou or qidou directly. 
						add_npc_row_to_item(gsItem, row);
					elseif(exTemplate and exTemplate.froms)then
						local node = exTemplate.froms[1];
						--if((node.key == 0 or node.key == -1)) then
							--echo({gsid,node.key, node.value, gsItem.esellprice})
						--end
						if(node and (node.key == 0 or node.key == -1) and gsItem.template.cansell and (node.value or 0)<(gsItem.esellprice or 0))then
							-- _guihelper.MessageBox("fatal error esell price is larger than buying price. check log.txt");
							LOG.std(nil, "error", "NPCShopProvider", "fatal error esell price is larger than buying price for gsid %d exid %s", gsid, row.exid);
							can_push = false;
						else						
							--if(node and node.key == gsid and node.key == 984)then
							if(node and node.key == gsid)then
								-- ignore selling items, and RMB modou items.
							else
								if(#(exTemplate.froms) >= 1) then
									if(exTemplate.tos and #(exTemplate.tos) == 1 and exTemplate.tos[1].key ~= gsid) then
										LOG.std(nil, "debug", "NPCShopProvider", "warning: gsid does not match the extended cost gsid %d exid %s(to.gsid %d)", gsid, row.exid, exTemplate.tos[1].key);
									end
									add_npc_row_to_item(gsItem, row);
								end
							end
						end
					end
				end
				if(can_push) then
					table.insert(result,row);
				end
			end
		end
		index = index + 1;
	end
	return result,gsid_daychoice_map;
end

-- load all item from csv file
function NPCShopProvider.Load()
	local self = NPCShopProvider;
	if(not self.list)then
		self.list,self.gsid_daychoice_map = self.LoadConfig();
	end
end

-- load all npc shop tips from csv file
function NPCShopProvider.TipsLoad()
	local self = NPCShopProvider;
	if(self.tips)then
		return;
	else
		self.tips = {};

		local function get_arr(s)
			if(not s)then return end
			if (string.match(s,"^#.*")) then return end

			local list = {};
			local line;
			for line in string.gfind(s, "([^,]+)") do
				table.insert(list,line);
			end
			return list;
		end

		local line;
		local file_path ="config/Aries/NPCShop_Teen/npcshop.teen.tips.csv";
		local file = ParaIO.open(file_path, "r");
		if(file:IsValid()) then
			line=file:readline();
			while line~=nil do 
				local arr = get_arr(line);
				if(arr)then
					local npcid = tonumber(arr[1]);
					local superclass = arr[2] or "menu1";
					local tip = arr[3];
					if(npcid and npcid>=0 and superclass and tip)then
						local node = {
							npcid = npcid,
							superclass = superclass,
							tip = tip,
						}
						table.insert(self.tips,node);
					end
				end
				line=file:readline();
			end
			file:close();
		end
	end
end

function NPCShopProvider.FindNPCshopTip(npcid,superclass)
	local self = NPCShopProvider;
	if(not npcid)then return end
	self.TipsLoad();
	if(self.tips)then
		superclass = superclass or "menu1";
		local temp_find = {}
		local shoptip = "";
		local k,v;
		for k,v in ipairs(self.tips) do
			if(v.npcid == npcid and v.superclass == superclass)then
				shoptip = v.tip or "";
			end
		end
		return shoptip;
	end
end
--获取货币列表
function NPCShopProvider.FindMoneyList(npcid,superclass)
	local self = NPCShopProvider;
	if(not npcid)then return end
	self.Load();
	if(self.list)then
		superclass = superclass or "menu1";
		local k,v;
		for k,v in ipairs(self.list) do
			if(v.npcid == npcid and v.superclass == superclass)then
				local money_list = v.money_list;
				if(money_list)then
					local r = {};
					local k,v;
					for k,v in ipairs(money_list) do
						local gsid = v.gsid;
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem)then
							local label = gsItem.template.name or "";
							label = string.format("%s:",label);
							table.insert(r,{label = label,gsid = gsid});
						end
					end
					return r;
				end
			end
		end
	end
end
function NPCShopProvider.FindClassNameList(npcid,superclass)
	local self = NPCShopProvider;
	if(not npcid)then return end
	self.Load();
	if(self.list)then
		superclass = superclass or "menu1";
		local temp_find = {}
		local source = {};
		local k,v;
		for k,v in ipairs(self.list) do
			if(v.npcid == npcid and v.superclass == superclass)then
				local class = v.class or "normal";
				local class_name = v.class_name or "通用";

				if(not temp_find[class])then
					temp_find[class] = class;
					table.insert(source,{class = class, class_name = class_name,});
				end
			end
		end
		return source;
	end
end

-- full text search by serial scanning all text. 
function NPCShopProvider.SearchByText(words,superclass,class)
	local self = NPCShopProvider;
	self.Load();
	if(self.list)then
		-- superclass = superclass or "menu1";
		local source = {};
		local k,v;
		local gsid_map = {};
		for k,v in ipairs(self.list) do
			if(v.name and v.name:match(words))then
				if(not gsid_map[v.gsid or ""] and (not superclass or v.superclass == superclass))then
					if(not class or v.class == class)then
						gsid_map[v.gsid or ""] = true;
						table.insert(source,v);
					end
				end
			end
		end
		local my_school = MyCompany.Aries.Combat.GetSchool();
		local my_level =  MyCompany.Aries.Player.GetLevel();

		commonlib.algorithm.sort_by_predicate(source, function(item)
			return not item.require_school or item.require_school == my_school;
		end)
		return source;
	end
end


-- find data source by npcid and class.
-- @param npcid:which id can be show in npc shop. it can also be a table of {npc_id=true, ...}
-- @param superclass:which superclass can be show in npc shop,default value is "menu1"
-- @param class(optional):which class can be show in npc shop,if nil return all data.
function NPCShopProvider.FindDataSource(npcid,superclass,class)
	local self = NPCShopProvider;
	if(not npcid)then return end
	self.Load();
	if(self.list)then
		-- superclass = superclass or "menu1";
		local source = {};
		local k,v;
		if(type(npcid) == "number") then
			for k,v in ipairs(self.list) do
				if(not superclass or v.superclass == superclass)then
					if(v.npcid == npcid)then
						if(not class)then
							table.insert(source,v);
						elseif(v.class == class)then
							table.insert(source,v);
						end
					end
				end
			end
		elseif(type(npcid) == "table") then
			local gsid_map = {};
			for k,v in ipairs(self.list) do
				if(not superclass or v.superclass == superclass)then
					if(npcid[v.npcid])then
						if(not class)then
							if( not gsid_map[v.gsid] or gsid_map[v.gsid] ~= v.exid) then
								gsid_map[v.gsid] = v.exid or true;
								table.insert(source,v);
							end
						elseif(v.class == class)then
							if( not gsid_map[v.gsid] or gsid_map[v.gsid] ~= v.exid) then
								gsid_map[v.gsid] = v.exid or true;
								table.insert(source,v);
							end
						end
					end
				end
			end
		end
		local my_school = MyCompany.Aries.Combat.GetSchool();
		local my_level =  MyCompany.Aries.Player.GetLevel();

		commonlib.algorithm.sort_by_predicate(source, function(item)
			return not item.require_school or item.require_school == my_school;
		end)
		return source;
	end
end
--[[
	获取兑换要求的信息 和 自己的信息
	return {
			req_pres = req_pres,
			req_froms = req_froms,
			my_pres = my_pres,
			my_froms = my_froms,
			tos = tos,
			emoney = emoney,
			pmoney = pmoney,
		}
--]]
--function NPCShopProvider.BuildExtendedInfo(exid,num,ignore_524)
	--local self = NPCShopProvider;
	--if(not exid)then return end
	--num = num or 1;
--
	--local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
	----[[
	--{	froms={{key=22000,value=3,},},
		--otos="[{\"gsid\":22169,\"cnt\":1,\"p\":1000}]",
		--exname="Get_22169_otherClass_CardQualification_22169_Life_LifePrism",tmpid=1000,
		--pres={{key=-14,value=22,},},
		--tos={{key=22169,value=1,},},}
----]]
	--if(exTemplate)then
		--local nid = System.App.profiles.ProfileManager.GetNID();
		--local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid) or {};
		--local accummodou = userinfo.accummodou or 0;--累计充值
		--local combatlel = userinfo.combatlel or 0;--战斗等级
		--
		--local emoney = userinfo.emoney or 0;--绑定货币
		--local pmoney = userinfo.pmoney or 0;
		--local mlvl = MyCompany.Aries.Player.GetVipLevel();
		--local pres = exTemplate.pres or {};
		--local froms = exTemplate.froms or {};
		--local tos = exTemplate.tos or {};
--
		--local function build_template(list)
			--local result = {};
			--local k,v;
			--for k,v in ipairs(list) do
				--local key = v.key;
				--local value = v.value or 0;
				----红蘑菇赛场1v1积分 红蘑菇赛场2v2积分 基数为1000
				--if(key == 20046 or key == 20048)then
					--value = value + 1000;
				--end
				--if(key >= 0 and ignore_524)then
					--local gsItem = ItemManager.GetGlobalStoreItemInMemory(key);
					--if(gsItem)then
						--local stat = gsItem.template.stats[524];
						--if(stat and stat == 1)then
							--num = 1;--忽略倍数
						--end
					--end
				--end
				--if(key == -17 or key == -103)then
					--num = 1;
				--end
				--value = value * num;
				--table.insert(result,{ key = key, value = value});
			--end
			--return result;
		--end
		--local function build(list)
			--local k,v;
			--local result = {};
			--for k,v in ipairs(list) do
				--local key = v.key;
				--if(key <= 0)then
					--if(key == -1)then
						--table.insert(result,{ key = key, value = pmoney});
					--elseif(key == 0)then
						--table.insert(result,{ key = key, value = emoney});
					--elseif(key == -17)then
						--table.insert(result,{ key = key, value = mlvl});
					--elseif(key == -103)then
						--table.insert(result,{ key = key, value = accummodou});
					--elseif(key == -14)then
						--table.insert(result,{ key = key, value = combatlel});
					--end
				--elseif(key == 20046)then
					----红蘑菇赛场1v1积分
					--local _value = Combat.GetMyPvPRanking("1v1") or 0;
					--table.insert(result,{ key = key, value = _value,});
				--elseif(key == 20048)then
					----红蘑菇赛场2v2积分
					--local _value = Combat.GetMyPvPRanking("2v2") or 0;
					--table.insert(result,{ key = key, value = _value,});
				--else
					--local bHas,__,__,copies = hasGSItem(key);
					--copies = copies or 0;
					--table.insert(result,{ key = key, value = copies});
				--end
			--end
			--return result;
		--end
		--local req_pres = build_template(pres);
		--local req_froms = build_template(froms);
		--local my_pres = build(pres);
		--local my_froms = build(froms);
--
		--return {
			--req_pres = req_pres,
			--req_froms = req_froms,
			--my_pres = my_pres,
			--my_froms = my_froms,
			--tos = build_template(tos),
			--emoney = emoney,
			--pmoney = pmoney,
		--}
	--end
--
--end
function NPCShopProvider.ShowHelpFunc(gsid,count)
	if(not gsid)then return end
	local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
	count = count or 1;
	if(gsid == 0)then
		command:Call({gsid = 17213,count = count,});
	elseif(gsid == 984)then
		if(CommonClientService.IsTeenVersion())then
			NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.teen.lua");
			local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
			PurchaseMagicBean.Show()
		else
			NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
			local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
			PurchaseMagicBean.Show()
		end
	elseif(gsid == 17213)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(17282);
		local s = string.format("%s暂时不能补充！",gsItem.template.name);
		_guihelper.MessageBox(s)
		--command:Call({gsid = 17282,count = count,});
	else
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(not gsItem)then
			return
		end
		--定价超过10W haqi_RMB_Currency的物品 不再提示自动购买
		if(gsItem.count and gsItem.count < 100000)then
			command:Call({gsid = gsid,count = count,});
		end
	end
end
function NPCShopProvider.PreCheckByExid(exid,cnt)
	if(not exid)then
		return
	end
	local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
	cnt = cnt  or 1;
	local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
	if(not exTemplate)then
		return
	end
	local list = CommonClientService.UnionList(exTemplate.pres,exTemplate.froms);
	local can_pass,key,my_value,need_value = NPCShopProvider.PreCheckByExid_internal(list,exid,cnt);
	if(not can_pass)then
		if(key and my_value and need_value)then
			if(key == 20046)then
				local s = string.format("红蘑菇赛场1v1积分%d才可以购买！",need_value);
				_guihelper.MessageBox(s)
			elseif(key == 20048)then
				local s = string.format("红蘑菇赛场2v2积分%d才可以购买！",need_value);
				_guihelper.MessageBox(s)
			elseif(key == -19)then
				local s = string.format("你的精力值不够，需要%d点精力值才可以购买！",need_value);
				_guihelper.MessageBox(s)
			elseif(key == -17)then
				local s = string.format("你的魔法星等级不够，需要%d级魔法星！",need_value);
				_guihelper.MessageBox(s)
			elseif(key == -14)then
				local s = string.format("战斗等级%d级才可以购买！",need_value);
				_guihelper.MessageBox(s)
			elseif(key == -103)then
				local s = string.format("累计充值%d%s才可以购买！",need_value,ystem.options.haqi_RMB_Currency);
				_guihelper.MessageBox(s)
			elseif(key == 0)then
				if(CommonClientService.IsTeenVersion())then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(17213);
					local name = gsItem.template.name;
					local s = string.format("你的%s不够，不能购买该物品，是否要购买%s兑换更多的%s?",System.options.haqi_GameCurrency,gsItem.template.name,System.options.haqi_GameCurrency);
					local count = math.floor((need_value - my_value) / 10000); -- fixed default value display, 10000银币 == 1银币钱带
					count = math.max(1,count);
					_guihelper.MessageBox(s, function(result)
						if(result==_guihelper.DialogResult.Yes) then
							command:Call({gsid = 17213,count = count,});
						end
					end, _guihelper.MessageBoxButtons.YesNo)  
				else
					local s = string.format("你的%s不够，不能购买该物品！",System.options.haqi_GameCurrency);
					_guihelper.MessageBox(s)
				end
			elseif(key == 984)then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(key);
				if(not gsItem)then
					return
				end
				local name = gsItem.template.name;
				local s = string.format("你的%s不够，不能购买该物品，是否充值?",name);
				_guihelper.MessageBox(s, function(result)
					if(result==_guihelper.DialogResult.Yes) then
						if(CommonClientService.IsTeenVersion())then
							NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.teen.lua");
							local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
							PurchaseMagicBean.Show()
						else
							NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
							local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
							PurchaseMagicBean.Show()
						end
					end
				end, _guihelper.MessageBoxButtons.YesNo) 
			elseif(key == 17213)then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(key);
				if(not gsItem)then
					return
				end
				local name = gsItem.template.name;
				if(not CommonClientService.IsTeenVersion())then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(17485);
					local s = string.format("你的%s不够，不能购买该物品，是否要购买%s兑换更多的%s?",name,gsItem.template.name,name);
					local count = math.floor((need_value - my_value) / 1000); --丰厚的仙豆口袋
					count = math.max(1,count);
					_guihelper.MessageBox(s, function(result)
						if(result==_guihelper.DialogResult.Yes) then
							command:Call({gsid = 17485,count = count,});
						end
					end, _guihelper.MessageBoxButtons.YesNo)  
					--local s = string.format("你的%s不够，不能购买该物品！",name);
					--_guihelper.MessageBox(s)
				else
					local s = string.format("你的%s不够，不能购买该物品！",name);
					_guihelper.MessageBox(s)
				end
			elseif(key >= 17331 and key <= 17340 and CommonClientService.IsKidsVersion())then
					local s = string.format("你还没有%s，带上乌晶石可以在我这里获得碎片。",name);
					_guihelper.MessageBox(s)
			else
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(key);
				if(not gsItem)then
					return
				end
				local name = gsItem.template.name;
				--定价超过5000 haqi_RMB_Currency的物品 不再提示自动购买
				if(gsItem.count and gsItem.count >= 5000)then
					local s = string.format("你的%s不够，不能购买该物品！",name);
					_guihelper.MessageBox(s)	
				else
					local s = string.format("你的%s不够，不能购买该物品，是否立即补充%s？",name,name);
					local count = need_value - my_value
					count = math.max(1,count);
					_guihelper.MessageBox(s, function(result)
						if(result==_guihelper.DialogResult.Yes) then
							command:Call({gsid = key,count = count,});
						end
					end, _guihelper.MessageBoxButtons.YesNo)  
				end
			end
		end
		return
	end
	return true;
end
--满足条件返回true
function NPCShopProvider.PreCheckByExid_internal(list,exid,cnt)
	if(not list or not exid)then
		return
	end
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid) or {};
	local accummodou = userinfo.accummodou or 0;--累计充值
	local combatlel = userinfo.combatlel or 0;--战斗等级
		
	local emoney = userinfo.emoney or 0;--绑定货币
	local mlel = userinfo.mlel or 0;
	local stamina = userinfo.stamina or 0;
	cnt = cnt or 1;
	local k,v;
	local last_key,last_need_value;
	for k,v in ipairs(list) do
		local key = v.key;
		local value = v.value or 0;
		if(key >= 0)then
			local gsid = key;
			if(gsid == 0)then
				local need_value = value * cnt;
				if(emoney < need_value)then
					return false,gsid,emoney,need_value;
				end
			else
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem)then
					local stat = gsItem.template.stats[524] or 0;
					if(stat == 1)then
						cnt = 1;--忽略倍数
					else
						--红蘑菇赛场1v1积分 红蘑菇赛场2v2积分 基数为1000
						if(gsid == 20046 or gsid == 20048)then
							value = value + 1000;
							cnt = 1;--忽略倍数
						end
					end
					local need_value = value * cnt;
					local __,__,__,copies = hasGSItem(gsid);
					copies = copies or 0
					--红蘑菇赛场1v1积分 红蘑菇赛场2v2积分 基数为1000
					if(gsid == 20046 or gsid == 20048)then
						copies = copies + 1000;	
					end
					if(copies < need_value)then
						return false,gsid,copies,need_value;
					end
				end
			end
		else
			if(key == -17 and mlel < value)then
				return false,key,mlel,value;
			end
			if(key == -14 and combatlel < value)then
				return false,key,combatlel,value;
			end
			if(key == -103 and accummodou < value)then
				return false,key,accummodou,value;
			end
			if(key == -19 and stamina < value)then
				return false,key,stamina,value;
			end
		end
		last_key = key;
		last_need_value = value * cnt;
	end
	return true,last_key,nil,last_need_value;
end

-- @param exid: if not nil, also check the exid
function NPCShopProvider.PreCheckByGsid(gsid,cnt, exid)
    local bean = MyCompany.Aries.Pet.GetBean();
	if(not gsid or not bean)then
		return
	end
	cnt = cnt or 1;
	local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
	local mlel = bean.mlel or 0;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
    if(gsItem)then
		local name = gsItem.template.name;
        local maxcopiesinstack = gsItem.template.maxcopiesinstack or 0;
		local maxcount = gsItem.template.maxcount or 0;
        if(hasGSItem(gsid) and (maxcopiesinstack == 1 or maxcount == 1))then
			local s = string.format("你已经拥有%s了，不需要再购买了。",name);
            _guihelper.MessageBox(s);
            return
        end
		local __,__,__,copies = hasGSItem(gsid);
		copies = copies or 0;
		if(copies >= maxcopiesinstack or copies >= maxcount)then
			local s = string.format("你已经拥有足够多的%s了，不需要再购买了。",name);
            _guihelper.MessageBox(s);
			return
		end
		local max_choice = NPCShopProvider.GetMaxChoice(gsid);
		local day_choice = NPCShopProvider.LoadDaychoice(gsid) or 0;
		day_choice = day_choice + cnt;
		if(max_choice and max_choice > 0 and day_choice > max_choice)then
				local s = string.format("%s一天只能购买%d个，你买的太多了！",name,max_choice);
				_guihelper.MessageBox(s);
			return;
		end

        local stat = gsItem.template.stats[180];
        if(stat and stat == 1 and tonumber(mlel) <= 0)then
			local s = string.format("魔法星用户才能使用%s，是否立即购买能量石激活魔法星?",name);
            _guihelper.MessageBox(s, function(result)
                if(result==_guihelper.DialogResult.Yes) then
                    Map3DSystem.mcml_controls.pe_item.OnClickGSItem(998,true);
                end
            end, _guihelper.MessageBoxButtons.YesNo)  
            return
        end
		-- 是否是炫彩卡
		local GoldCardProp = gsItem.template.stats[99];
		local BasicSkillName="";
		if (GoldCardProp) then									 
			local BasicSkillGSID = gsItem.template.stats[100];
			BasicSkillName = ItemManager.GetGlobalStoreItemInMemory(BasicSkillGSID).template.name;
			BuyGoldCardNoTips = hasGSItem(BasicSkillGSID);

			if (not BuyGoldCardNoTips) then
				_guihelper.Custom_MessageBox("你现在还没有学会该炫彩卡要求的基础技能【"..BasicSkillName.."】哦，" .. gsItem.template.name .. "需要学会基础技能才能使用哦，你确定要购买吗？",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						command:Call({gsid = gsid, exid=exid});
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/PurchaseImmediately_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});			
				return;
			end
		end
    end

	if(exid and not NPCShopProvider.PreCheckByExid(exid,1)) then
		return;
	end
	return true;
end
---- 是否可以执行兑换
---- @param exid:兑换id
---- @param num:兑换次数
---- @param showErrorMsg:是否显示错误提醒
--function NPCShopProvider.CanExtended(exid,num,showErrorMsg)
	--local self = NPCShopProvider;
	--if(not exid)then return end
	--num = num or 0;
	--if(self.list)then
		--local k,v;
		--for k,v in ipairs(self.list) do
			--if(v.exid and v.gsid and v.exid == exid)then
				--local gsid = v.gsid;
				--local max_choice = self.GetMaxChoice(gsid);
				--local day_choice = NPCShopProvider.LoadDaychoice(gsid) or 0;
				--day_choice = day_choice + num;
				--if(max_choice and max_choice > 0 and day_choice > max_choice)then
					--if(showErrorMsg)then
						--local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
						--local name = "";
						--if(gsItem)then
							--name = gsItem.template.name;
						--end
						--local s = string.format("%s一天只能购买%d个，你买的太多了！",name,max_choice);
						--_guihelper.MessageBox(s);
					--end
					--return;
				--end
				--local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				--if(gsitem)then
					---- 是否是炫彩卡
					--local GoldCardProp = gsitem.template.stats[99];
					--local BasicSkillName="";
					--if (GoldCardProp) then									 
						--local BasicSkillGSID = gsitem.template.stats[100];
						--BasicSkillName = ItemManager.GetGlobalStoreItemInMemory(BasicSkillGSID).template.name;
						--BuyGoldCardNoTips = hasGSItem(BasicSkillGSID);
--
						--if (not BuyGoldCardNoTips) then
							--if(showErrorMsg)then
								--_guihelper.Custom_MessageBox("你现在还没有学会该炫彩卡要求的基础技能【"..BasicSkillName.."】哦，" .. gsitem.template.name .. "需要学会基础技能才能使用哦，你确定要购买吗？",function(result)
									--if(result == _guihelper.DialogResult.Yes)then
										--Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
									--end
								--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/PurchaseImmediately_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});			
							--end
							--return;
						--end
					--end
				--end
			--end
		--end
	--end
	--local info = NPCShopProvider.BuildExtendedInfo(exid,num,true);
	--if(info)then
		--local req_pres = info.req_pres;
		--local req_froms = info.req_froms;
		--local my_pres = info.my_pres;
		--local my_froms = info.my_froms;
		--local emoney = info.emoney;
		--local pmoney = info.pmoney;
		--local mlvl = info.mlvl;
		--local function get_err_str(key,req_value,value)
			--local s = "";
			--if(key <= 0)then
				--if(key == -1 or key == 0)then
					--s = "你的钱不够!";
				--elseif(key == -17)then
					--s = string.format("你的魔法星等级不够，需要%d级魔法星！",req_value or 0);
				--end
			--elseif(key == 20046)then
				--s = string.format("你的红蘑菇赛场1v1积分不够，需要%d积分，你只有%d积分！",req_value or 0,value or 0);
			--elseif(key == 20048)then
				--s = string.format("你的红蘑菇赛场2v2积分不够，需要%d积分，你只有%d积分！",req_value or 0,value or 0);
			--else
				--local gsItem = ItemManager.GetGlobalStoreItemInMemory(key);
				--local name = "";
				--if(gsItem)then
					--name = gsItem.template.name;
				--end
				--if(CommonClientService.IsKidsVersion())then
					--if(key >= 17331 and key <= 17340)then
						--s = string.format("你还没有%s，带上乌晶石可以在我这里获得碎片。",name);
					--else
						--s = string.format("%s不够!",name);
					--end
				--else
					--s = string.format("%s不够!",name);
				--end
			--end
			--return s;
		--end
		--local function check(req_list,list)
			--if(not req_list or not list)then return end
--
			--local k,v;
			--for k,v in ipairs(req_list) do
				--local key = v.key;
				--local req_value = v.value;
--
				--local kk,vv;
				--for kk,vv in ipairs(list) do
					--if(key == vv.key)then
						--local value = vv.value;
						----如果是e币(绑定货币) 计算总和
						--if(key == 0)then
							--value = emoney + pmoney
						--end
						--if(value < req_value)then
							--if(showErrorMsg)then
								--local s = get_err_str(key,req_value,value);
								--if (key==20046 or key==20048 or key==-1 or key==50337 or key==17227 or key==17178) then
									--_guihelper.MessageBox(s);
								--else
									 ---- 青年版，key=-17, 0, 984, 其他 （不包括 key=17227, 17178, 20046, 20048, -1, 50337 ) 都将提示可用haqi_RMB_Currency购买补充
									--local _gsid=key;
									--local has_limited = false;
									----超过当日购买次数 取消显示
									--local max_choice = NPCShopProvider.GetMaxChoice(_gsid);
									--if(max_choice and max_choice > 0)then
										--local day_choice = NPCShopProvider.LoadDaychoice(_gsid) or 0;
										--if(day_choice >= max_choice)then
											--has_limited = true;
										--end
									--end
									--local gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
									----定价超过10W haqi_RMB_Currency的物品 不再提示自动购买
									--if(gsItem and gsItem.count and gsItem.count >= 100000)then
										--has_limited = true;
									--end
									--if (key==-17) then
										--_gsid=998;
										--if(has_limited)then
											--s="你的魔法星等级不够，不能购买该物品！";
										--else
											--s="你的魔法星等级不够，不能购买该物品，是否要购买能量石提升魔法星等级?";
										--end
									--elseif (key == -103) then
										--has_limited = true;
										--s = string.format("累计充值%d%s才可以购买！",value, System.options.haqi_RMB_Currency);
									--elseif (key == -14) then
										--has_limited = true;
										--s = string.format("战斗等级%d级才可以购买！",req_value);
									--elseif (key==0 and System.options.version == "teen") then
										--_gsid=17213;
										--value = (value or 0) / 10000; -- fixed default value display, 10000银币 == 1银币钱带
										--if(has_limited)then
											--s=string.format("你的%s不够，不能购买该物品！",System.options.haqi_GameCurrency);
										--else
											--s=string.format("你的%s不够，不能购买该物品，是否要购买%s大钱袋兑换更多的%s?",System.options.haqi_GameCurrency,System.options.haqi_GameCurrency,System.options.haqi_GameCurrency);
										--end
									--elseif(key==984) then
										--if(has_limited)then
											--s=string.format("%s. 不能购买该物品！",s);
										--else
											--s=string.format("%s. 不能购买该物品，是否充值?",s);
										--end
									--elseif (key==17213 and System.options.version == "kids") then
										--_gsid = 17282; -- 满满的仙豆口袋 策划需要配置 Count
										--value = (value or 0) / 10000;
										--if(has_limited)then
											--s = string.format("你的仙豆不够，不能购买该物品！");
										--else
											--s = string.format("你的仙豆不够，不能购买该物品，是否要购买仙豆大钱袋兑换更多的仙豆?");
										--end
									--else
										--if(has_limited)then
											--s=string.format("你的%s 不能购买该物品！",s);
										--else
											--s=string.format("你的%s 不能购买该物品，是否要用%s补充?",s,System.options.haqi_RMB_Currency);
										--end
									--end
									--if(has_limited)then
										--_guihelper.MessageBox(s)
										--return
									--end
									-----------
									--_guihelper.MessageBox(s, function(result)
										--if(result==_guihelper.DialogResult.Yes) then
											--if (_gsid==984) then
												--NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.teen.lua");
												--local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
												--PurchaseMagicBean.Show()
											--else
												--local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
												--command:Call({gsid = _gsid,count = value,});
											--end
										--end
									--end, _guihelper.MessageBoxButtons.YesNo)         
									------------
								--end
							--end
							--return false;
						--end
					--end
				--end
			--end
			--return true;
		--end
		--local canpass = check(req_pres,my_pres);
		--if(canpass)then
			--canpass = check(req_froms,my_froms);
		--end
		--return canpass;
	--end
--end
--是否有需要修理的装备,如果有返回true
function NPCShopProvider.CanResetDurability()
	local self = NPCShopProvider;
	local reset_list = {};
	local function find_bag(bag)
		local i;
		local cnt = ItemManager.GetItemCountInBag(bag);
		for i = 1, cnt do
			local item = ItemManager.GetItemByBagAndOrder(bag, i);
			if(item)then
				local gsid = item.gsid;
				local guid = item.guid;
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem)then
					local durability = 0;
					local max_durability = gsItem.template.stats[222] or 0;
					if(item.GetDurability)then
						durability = item:GetDurability() or 0;
						if(durability < max_durability)then
							table.insert(reset_list,{
								gsid = gsid,
								guid = guid, 
								name = gsItem.template.name,
								durability = durability,
								max_durability = max_durability,

							});
						end
					end
				end
			end
		end
	end
	--只修0号包
	find_bag(0,reset_list);
	--find_bag(1,reset_list);
	local len = #reset_list;
	local can_reset = false;
	if(len >0)then
		can_reset = true;
	end
	return can_reset,reset_list;
end
--修理装备需要的金钱
--return need_money,guids
function NPCShopProvider.GetRepairMoney()
	local self = NPCShopProvider;
	local can_reset,reset_list = self.CanResetDurability();
	if(not can_reset)then
		return -1;
	end
	local need_money = 0;
	local guids = {};
	local k,v;
	for k,v in ipairs(reset_list) do
		local num = (v.max_durability - v.durability) * 5;
		if(durability == 0)then
			num = num + num * 0.3;
		end
		need_money = need_money + num;
		guids[v.guid] = v.guid;
	end
	need_money = math.floor(need_money);
	return need_money,guids;
end
--修理装备
function NPCShopProvider.DoResetDurability(callbackFunc)
	local self = NPCShopProvider;
	local can_reset,reset_list = self.CanResetDurability();
	if(not can_reset)then
		_guihelper.MessageBox("你现在没有需要被修理的装备！");
		return
	end
	local need_money,guids = self.GetRepairMoney();
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory() or {};
	local emoney = userinfo.emoney or 0;
	if(emoney < need_money)then
		local s = string.format("你的银币不够，是否需要补充银币？");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
				if(command) then
					command:Call({gsid = 17213});
				end
			end
		end,_guihelper.MessageBoxButtons.YesNo,{show_label = true, yes = "马上补充", no = "下次再说"});
		return;
	end
	local s = string.format("修理装备需要%d银币，是否需要修理？",need_money);
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
			ItemManager.ResetDurability(guids,function(msg)
				if(msg and msg.issuccess)then
					_guihelper.MessageBox("修理成功！");
				end
				if(callbackFunc)then
					callbackFunc();
				end
			end)
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
end
function NPCShopProvider.GetSellHistory()
	local self = NPCShopProvider;
	local nid = Map3DSystem.User.nid;
	local key = string.format("NPCShopProvider.SellHistory_%s",tostring(nid));
	local list = MyCompany.Aries.Player.LoadLocalData(key, {});
	return list;
end
function NPCShopProvider.SetSellHistory(list)
	local self = NPCShopProvider;
	local nid = Map3DSystem.User.nid;
	if(not list)then return end
	local key = string.format("NPCShopProvider.SellHistory_%s",tostring(nid));
	MyCompany.Aries.Player.SaveLocalData(key, list);
end
function NPCShopProvider.PushSellHistory(gsid)
	local self = NPCShopProvider;
	if(not gsid)then return end
	local list = self.GetSellHistory();
	table.insert(list,gsid);
	local len = #list;
	if(len > 3)then
		table.remove(list,1);	
	end
	self.SetSellHistory(list);
end
--翻转列表
function NPCShopProvider.GetRecoverList()
	local self = NPCShopProvider;
    local history = self.GetSellHistory();
    local recover_list = {
	}
	if(history)then
		local len = #history;
		local k = 1;
		for k = 1,len do
			local gsid = history[len-k+1];
			recover_list[k] = {gsid = gsid};
		end
	end
    return recover_list;
end