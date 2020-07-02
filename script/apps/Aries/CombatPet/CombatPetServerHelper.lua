--[[
Title: 
Author(s): Leio
Date: 2012/4/17
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetServerHelper.lua");
local CombatPetServerHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetServerHelper");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
-- create class
local CombatPetServerHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetServerHelper");
--青年版改名 第一次免费 第二次10魔豆
function CombatPetServerHelper.DoChangeName_FollowPet_Teen(nid,msg)
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","QuestServerLogics.DoChangeName_FollowPet_Teen", msg);
	--宠物id
	local pet_name = msg.pet_name;
	if(not pet_name)then
		return
	end
	local pet_gsid = msg.pet_gsid;
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	local pet_config = CombatPetConfig.GetInstance_Server(true);
	if(pet_config and hasItem)then
		--是否是战宠
		local is_combat_pet = pet_config:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local data = item:GetServerData();
			if(not data or data == "")then
				data = item:GetPrimitiveData_server();
			end
			if(type(data) ~= "table")then
				return
			end
			local name_cnt = data.name_cnt or 0;
			if(name_cnt < 0)then
				return
			end
			local name_cost;
			if(name_cnt == 0)then
				name_cost = 0;
			else
				name_cost = 10;
			end
			

			local loots = {};
			if(name_cost > 0)then
				loots[984] = -name_cost;
				local pres = {};
				pres[984] = name_cost;
			end
			--扣除物品
			LOG.std(nil, "info","QuestServerLogics.DoChangeName_FollowPet_Teen AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, data = data,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","QuestServerLogics.DoChangeName_FollowPet_Teen AddExpJoybeanLoots 2", msg);
				if(msg and msg.issuccess)then
					--保存数据
					--记录改名次数
					data.name_cnt = name_cnt + 1;
					data.pet_name = pet_name;
					local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
					if(item) then
						item:SaveServerData(data,function()
							local msg = {
								pet_gsid = pet_gsid,
							}
							QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatFollowPetPane.DoChangeName_Handler",msg)
						end);
					end
				end
			end, pres)
			
		end
	end
end
--青年版喂食
function CombatPetServerHelper.DoFeed_FollowPet_Teen_backup(nid,msg)
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet_Teen", msg);
	--宠物id
	local pet_gsid = msg.pet_gsid;
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	--食物id
	local food_gsid = msg.food_gsid;
	local pet_config = CombatPetConfig.GetInstance_Server(true);
	if(pet_config and hasItem)then
		--是否是战宠
		local is_combat_pet = pet_config:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local data = item:GetServerData();
			if(not data or data == "")then
				data = item:GetPrimitiveData_server();
			end
			if(type(data) ~= "table")then
				return
			end
			local cur_feed_num = data.cur_feed_num or 0;
			local cur_feed_date = data.cur_feed_date;
			local name_cnt = data.name_cnt;
			local pet_name = data.pet_name;
			
			local exp = data.exp or 0;
			
			if(not cur_feed_date)then
				cur_feed_date = serverdate;
				cur_feed_num = 0;
			else
				--如果不是在同一天
				if(cur_feed_date ~= serverdate)then
					cur_feed_date = serverdate;
					cur_feed_num = 0;
				end
			end
			local max_num = 15;
			--是否是测试用户
			local is_power_user = QuestServerLogics.IsPowerUser(nid);
			if( (max_num - cur_feed_num) <= 0 and not is_power_user)then
				--超过今天喂食次数
				return
			end
			local levels_info = pet_config:GetLevelsInfo(pet_gsid,exp or 0);
			local level = levels_info.cur_level;
			local isfull = levels_info.isfull;
			local max_exp = levels_info.max_exp;
			local start_evolve_level = levels_info.start_evolve_level;
			if(isfull)then
				return
			else
				if(start_evolve_level and level >= start_evolve_level)then
					if(not pet_config:IsSeniorFoodGsid(pet_gsid,food_gsid))then
						return
					end
				end
			end
			local add_exp = 0;
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(food_gsid);
			if(gsItem) then
				local stats = gsItem.template.stats;
				add_exp = stats[60] or 0; --+经验值
				if(add_exp < 0)then
					add_exp = 0;
				end

				local max_random_exp = stats[133] or 0; --+随机经验
				local random_exp = math.random(max_random_exp + 1);
				random_exp = random_exp - 1;
				if(random_exp < 0)then
					random_exp = 0;
				end
				add_exp = add_exp + random_exp;
			end
			--NOTE:add_exp = 0 也会消耗物品 ，随机经验当中有可能为0
			cur_feed_num = cur_feed_num + 1;
			
			exp = exp + add_exp;
			exp = math.min(exp,max_exp);
			local s_data = {
				exp = exp,
				cur_feed_num = cur_feed_num,
				cur_feed_date = cur_feed_date,
				name_cnt = name_cnt,
				pet_name = pet_name,
			};
			local loots = {};
			loots[food_gsid] = -1;
			local pres = {};
			pres[food_gsid] = 1;
			--扣除物品
			LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet_Teen AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, s_data = s_data,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet_Teen AddExpJoybeanLoots 2", msg);
				if(msg and msg.issuccess)then
					--保存数据
					local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
					if(item) then
						item:SaveServerData(s_data,function()
						end);
					end
					local msg = {
						pet_gsid = pet_gsid,
						food_gsid = food_gsid,
						add_exp = add_exp,
						exp = exp,
						cur_feed_num = cur_feed_num,
					}
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatFollowPetPane.DoFeed_Handler",msg)
				else
				end
			end, pres)
			
		end
	end
end
--青年版喂食
--[[
	local msg = {
		nid = nid,
		pet_gsid = pet_gsid,
		add_exp = add_exp,
	}
--]]
function CombatPetServerHelper.DoFeed_FollowPet_Teen(nid,msg)
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet_Teen", msg);
	--宠物id
	local pet_gsid = msg.pet_gsid;
	local add_exp = msg.add_exp;
	
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	--exp id
	local exp_gsid = 966;
	local __,__,__,total_useful_exp = PowerItemManager.IfOwnGSItem(nid,exp_gsid);
	---可消耗的训练点总数
	total_useful_exp = total_useful_exp or 0;
	if(not hasItem) then
		return 
	end

	-- By Xizhi: just in case the bag is not updated, we will update the server once. 
	if(total_useful_exp <= 0 or add_exp <= 0 or add_exp  > total_useful_exp)then
		local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(exp_gsid);
		if(gsItem) then
			local old_msg = msg;
			PowerItemManager.SyncUserItems(tonumber(nid), {gsItem.template.bagfamily}, function(msg) 
				local __,__,__,total_useful_exp = PowerItemManager.IfOwnGSItem(nid,exp_gsid);
				if(total_useful_exp) then
					if(add_exp  <= total_useful_exp) then
						CombatPetServerHelper.DoFeed_FollowPet_Teen(nid,old_msg);
					end
				end
			end, function() end);
		end
		return
	end

	local pet_config = CombatPetConfig.GetInstance_Server(true);
	if(pet_config)then
		--是否是战宠
		local is_combat_pet = pet_config:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local data = item:GetServerData();
			if(not data or data == "")then
				data = item:GetPrimitiveData_server();
			end
			if(type(data) ~= "table")then
				return
			end
			local name_cnt = data.name_cnt;
			local pet_name = data.pet_name;
			local exp = data.exp or 0;
			
			
			local levels_info = pet_config:GetLevelsInfo(pet_gsid,exp or 0);
			local level = levels_info.cur_level;
			local isfull = levels_info.isfull;
			local max_exp = levels_info.max_exp;
			local cur_level_exp = levels_info.cur_level_exp;
			local cur_level_max_exp = levels_info.cur_level_max_exp;

			local start_evolve_level = levels_info.start_evolve_level;
			if(isfull)then
				return
			end
			local need_exp = max_exp - exp;
			if(add_exp > need_exp)then
				add_exp = need_exp;
			end
			if(add_exp <= 0)then
				return
			end
			local level_up = false;
			if(add_exp >= (cur_level_max_exp - cur_level_exp))then
				level_up = true;
			end
			exp = exp + add_exp;
			local s_data = {
				exp = exp,
				name_cnt = name_cnt,
				pet_name = pet_name,
			};
			local loots = {};
			loots[exp_gsid] = -add_exp;
			local pres = {};
			pres[exp_gsid] = add_exp;
			--扣除物品
			LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet_Teen AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, s_data = s_data,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet_Teen AddExpJoybeanLoots 2", msg);
				if(msg and msg.issuccess)then
					--保存数据
					local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
					if(item) then
						item:SaveServerData(s_data,function()
						end);
					end
					local msg = {
						pet_gsid = pet_gsid,
						add_exp = add_exp,
						exp = exp,
						level = level,
						level_up = level_up,
					}
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatFollowPetPane.DoFeed_Handler",msg)
				else
				end
			end, pres)
			
		end
	end
end
--儿童版喂食 新逻辑
function CombatPetServerHelper.DoFeed_FollowPet(nid,msg)
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet", msg);
	--宠物id
	local pet_gsid = msg.pet_gsid;
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	--食物id
	local food_gsid = msg.food_gsid;
	local provider = CombatPetHelper.GetServerProvider(QuestServerLogics.IsTeenVersion());
	if(provider and hasItem)then
		--是否是战宠
		local is_combat_pet = provider:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local data = item:GetServerData();
			if(not data or data == "")then
				data = item:GetPrimitiveData_server();
			end
			if(type(data) ~= "table")then
				return
			end
			--存储的数据结构
			local cur_feed_num = data.cur_feed_num or 0;
			local cur_feed_date = data.cur_feed_date;
			local exp = data.exp or 0;
			local gem_gsid = data.gem_gsid;
			
			if(not cur_feed_date)then
				cur_feed_date = serverdate;
				cur_feed_num = 0;
			else
				--如果不是在同一天
				if(cur_feed_date ~= serverdate)then
					cur_feed_date = serverdate;
					cur_feed_num = 0;
				end
			end
			local max_num = 15;
			--是否是测试用户
			local is_power_user = QuestServerLogics.IsPowerUser(nid);
			if( (max_num - cur_feed_num) <= 0 and not is_power_user)then
				--超过今天喂食次数
				return
			end
			local p = provider:GetPropertiesByID(pet_gsid);
			--是否具有扩展等级
			local has_senior = provider:HasSeniorLevel(pet_gsid);
			local level,cur_exp,total_exp,isfull = provider:GetLevelInfo(pet_gsid,exp);
			local can_feed = false;
			local max_exp = p.max_exp;
			if(not isfull)then
				can_feed = true;
			else
				if(has_senior)then
					local level,cur_exp,total_exp,isfull = provider:GetSeniorLevelInfo(pet_gsid,exp);
					if(not isfull)then
						if(provider:IsSeniorFoodGsid(pet_gsid,food_gsid))then
							can_feed = true;
						end
					end
					max_exp = provider:GetTotalExp(pet_gsid);
				end
			end
			if(not can_feed)then
				return
			end
			local add_exp = 0;
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(food_gsid);
			if(gsItem) then
				local stats = gsItem.template.stats;
				add_exp = stats[60] or 0; --+经验值
				if(add_exp < 0)then
					add_exp = 0;
				end
			end
			if(add_exp <= 0)then
				return
			end
			cur_feed_num = cur_feed_num + 1;
			
			exp = exp + add_exp;
			exp = math.min(exp,max_exp);
			local s_data = {
				exp = exp,
				cur_feed_num = cur_feed_num,
				cur_feed_date = cur_feed_date,
				gem_gsid = gem_gsid,
			};
			local loots = {};
			loots[food_gsid] = -1;
			local pres = {};
			pres[food_gsid] = 1;
			--扣除物品
			LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, s_data = s_data,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","QuestServerLogics.DoFeed_FollowPet AddExpJoybeanLoots 2", msg);
				if(msg and msg.issuccess)then
					--保存数据
					local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
					if(item) then
						item:SaveServerData(s_data,function()
						end);
					end
					local msg = {
						pet_gsid = pet_gsid,
						food_gsid = food_gsid,
						add_exp = add_exp,
						exp = exp,
					}
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatPetPane.DoFeed_Handler",msg)
				else
				end
			end, pres)
			
		end
	end
end
-- added by LiXizhi, level a pet to full exp for testing purposes via GM command. 
function CombatPetServerHelper.DoFeed_FollowPet_GM(nid, pet_gsid, exp_add)
	if(QuestServerLogics.IsTeenVersion())then
		CombatPetServerHelper.DoFeed_FollowPet_GM_Teens(nid, pet_gsid, exp_add)
	else
		CombatPetServerHelper.DoFeed_FollowPet_GM_Kids(nid, pet_gsid, exp_add)
	end
end
function CombatPetServerHelper.DoFeed_FollowPet_GM_Teens(nid, pet_gsid, exp_add)
	nid = tonumber(nid);
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	local pet_config = CombatPetConfig.GetInstance_Server(true);

	if(pet_config and hasItem)then
		--是否是战宠
		local is_combat_pet = pet_config:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local data = item:GetServerData();
			if(not data or data == "")then
				data = item:GetPrimitiveData_server();
			end
			if(type(data) ~= "table")then
				return
			end
			local exp = data.exp or 0;
			exp = exp + (exp_add or 1000);
			local s_data = {
				exp = exp,
				cur_feed_num = data.cur_feed_num,
				cur_feed_date = data.cur_feed_date,
				cur_fruit_gsid = data.cur_fruit_gsid,
			};
			--保存数据
			local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
			if(item) then
				item:SaveServerData(s_data,function()
					LOG.std(nil, "info","GM", "add pet exp %s: pet_gsid:%s", tostring(nid), tostring(pet_gsid));
					local msg = {
						state = nil,
						pet_gsid = pet_gsid,
						--cur_fruit_gsid = cur_fruit_gsid,
						food_gsid = food_gsid,
					}
					msg.state = 4;
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatPetFoodsPage.DoFeed_Handler",msg)
				end);
			end
		end
	end
end
function CombatPetServerHelper.DoFeed_FollowPet_GM_Kids(nid, pet_gsid, exp_add)
	nid = tonumber(nid);
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);

	local provider = CombatPetHelper.GetServerProvider(QuestServerLogics.IsTeenVersion());

	if(provider and hasItem)then
		--是否是战宠
		local is_combat_pet = provider:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local data = item:GetServerData();
			if(not data or data == "")then
				data = item:GetPrimitiveData_server();
			end
			if(type(data) ~= "table")then
				return
			end
			local exp = data.exp or 0;

			local p = provider:GetPropertiesByID(pet_gsid)
			local has_senior = provider:HasSeniorLevel(pet_gsid);

			local level,cur_exp,total_exp,isfull = provider:GetLevelInfo(pet_gsid,exp);

			local can_feed = false;
			local max_exp = p.max_exp;
			if(not isfull)then
				can_feed = true;
			else
				if(has_senior)then
					local level,cur_exp,total_exp,isfull = provider:GetSeniorLevelInfo(pet_gsid,exp);
					if(not isfull)then
						can_feed = true;
					end
					max_exp = provider:GetTotalExp(pet_gsid);
				end
			end
			if(not can_feed)then
				return
			end
			
			
			exp = exp + (exp_add or 1000);
			exp = math.min(exp,max_exp);

			local s_data = {
				exp = exp,
				cur_feed_num = data.cur_feed_num,
				cur_feed_date = data.cur_feed_date,
				cur_fruit_gsid = data.cur_fruit_gsid,
			};
			--保存数据
			local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
			if(item) then
				item:SaveServerData(s_data,function()
					LOG.std(nil, "info","GM", "add pet exp %s: pet_gsid:%s", tostring(nid), tostring(pet_gsid));
					local msg = {
						state = nil,
						pet_gsid = pet_gsid,
						--cur_fruit_gsid = cur_fruit_gsid,
						food_gsid = food_gsid,
					}
					if(exp == max_exp)then
						--满级
						msg.state = 5;
					else
						msg.state = 4;
					end
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatPetFoodsPage.DoFeed_Handler",msg)
				end);
			end
		end
	end
end
--儿童版镶嵌宝石
function CombatPetServerHelper.AttachGem(nid,msg)
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","CombatPetServerHelper.AttachGem", msg);
	--宠物id
	local pet_gsid = msg.pet_gsid;
	--宝石id
	local gem_gsid = msg.gem_gsid;
	if(not gem_gsid)then
		return
	end
	--判断是否是宝石
	local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gem_gsid);
	if(not gsItem)then
		return
	end
	local gem_level = gsItem.template.stats[41] or 0;
	if(gem_level <= 0)then
		return
	end
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	local provider = CombatPetHelper.GetServerProvider(QuestServerLogics.IsTeenVersion());

	if(provider and hasItem)then
		--是否是战宠
		local is_combat_pet = provider:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local data = item:GetServerData();
			data.gem_gsid = gem_gsid;

			local loots = {};
			loots[gem_gsid] = -1;
			local pres = {};
			pres[gem_gsid] = 1;
			--扣除物品
			LOG.std(nil, "info","CombatPetServerHelper.AttachGem AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, data = data,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","CombatPetServerHelper.AttachGem AddExpJoybeanLoots 2", msg);
				if(msg and msg.issuccess)then
					--保存数据
					local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
					if(item) then
						item:SaveServerData(data,function()
						end);
					end
					local msg = {
						pet_gsid = pet_gsid,
						gem_gsid = gem_gsid,
					}
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatPetPane.AttachGem_Handler",msg)
				else
				end
			end, pres)
		end
	end
end
function CombatPetServerHelper.UnAttachGem(nid,msg)
	nid = tonumber(nid);
	msg = msg or {};
	msg.nid = nid;
	LOG.std(nil, "info","CombatPetServerHelper.UnAttachGem", msg);
	--宠物id
	local pet_gsid = msg.pet_gsid;
	
	local hasItem,pet_guid = PowerItemManager.IfOwnGSItem(nid,pet_gsid);
	local provider = CombatPetHelper.GetServerProvider(QuestServerLogics.IsTeenVersion());
	--扳手
	local gsid_arm = 17289;
	if(provider and hasItem)then
		--是否是战宠
		local is_combat_pet = provider:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
		if(item and item.GetServerData and item.GetPrimitiveData_server)then
			local serverdate = ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local data = item:GetServerData();
			local gem_gsid = data.gem_gsid;
			if(not gem_gsid)then
				return;
			end
			data.gem_gsid = nil;

			local loots = {};
			loots[gsid_arm] = -1;
			loots[gem_gsid] = 1;
			local pres = {};
			pres[gsid_arm] = 1;
			--扣除物品
			LOG.std(nil, "info","CombatPetServerHelper.UnAttachGem AddExpJoybeanLoots 1", {nid = nid, loots = loots, pres = pres, data = data,});
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg)
			LOG.std(nil, "info","CombatPetServerHelper.UnAttachGem AddExpJoybeanLoots 2", msg);
				if(msg and msg.issuccess)then
					--保存数据
					local item = PowerItemManager.GetItemByGUID(nid,pet_guid);
					if(item) then
						item:SaveServerData(data,function()
						end);
					end
					local msg = {
						pet_gsid = pet_gsid,
						gem_gsid = gem_gsid,
					}
					QuestServerLogics.CallClient(nid,"MyCompany.Aries.CombatPet.CombatPetPane.UnAttachGem_Handler",msg)
				else
				end
			end, pres)
		end
	end
end