--[[
Title: 
Author(s): Leio
Date: 2010/12/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeServerLogics.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local hasGSItem = PowerItemManager.IfOwnGSItem;

NPL.load("(gl)script/apps/GameServer/GSL_transactions.lua");
local GSL_transaction = commonlib.gettable("Map3DSystem.GSL.GSL_transaction");
-- create class
local LuckyTreeServerLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeServerLogics");
local xml_path = "config/Aries/Others/lucky_lottery.xml";
LuckyTreeServerLogics.users = {
	--[nid] = { num = nil, date = "",},
}
--[[
	17144 1级玄玉
	17145 2级玄玉
	17146 3级玄玉
	17147 4级玄玉
	17148 5级玄玉

	17151 小金锤

	26701 低级宝石镶嵌符
	26702 高级宝石镶嵌符
	26703 顶级宝石镶嵌符

	17131 1星面包
	17132 2星面包
	17133 3星面包
	17134 4星面包
	17135 5星面包
	17136 6星面包
	17137 7星面包
	17138 8星面包
	17139 9星面包
	17140 10星面包

	16051 冲锋大象变身药丸

	17155 1级红枣
	17156 2级红枣
	17157 3级红枣
	17158 4级红枣
	17159 5级红枣

--]]
LuckyTreeServerLogics.gifts = {
	[0] = {
		{ {label = "4级宝石（除攻击宝石）", gsid = nil,num = 2,level = 4,isgem = true},{label = "顶级宝石镶嵌符", gsid = 26703,num = 3},{label = "小金锤", gsid = 17151,num = 1},{label = "火魔", gsid = 10187,num = 1},},
		{ {label = "4级宝石（除攻击宝石）", gsid = nil,num = 2,level = 4,isgem = true},{label = "暗影神驹", gsid = 16068,num = 1},{label = "小金锤", gsid = 17151,num = 1},{label = "火魔", gsid = 10187,num = 1},},
	},
	[1] = {
		{ {label = "1级宝石", gsid = nil,num = 5,level = 1,isgem = true},{label = "高级宝石镶嵌符", gsid = 26702,num = 1},{label = "鸭梨山大", gsid = 10150,num = 1},},
		{ {label = "1级宝石", gsid = nil,num = 5,level = 1,isgem = true},{label = "人气帖", gsid = 17167,num = 1},{label = "鸭梨山大", gsid = 10150,num = 1},},
		{ {label = "1级宝石", gsid = nil,num = 5,level = 1,isgem = true},{label = "小金锤", gsid = 17151,num = 1},{label = "鸭梨山大", gsid = 10150,num = 1},},
		{ {label = "1级宝石", gsid = nil,num = 5,level = 1,isgem = true},{label = "五星面包", gsid = 17135,num = 1},{label = "鸭梨山大", gsid = 10150,num = 1},},
	},
	[2] = {
		{ {label = "1级宝石", gsid = nil,num = 4,level = 1,isgem = true},{label = "4星面包", gsid = 17134,num = 1},},
		{ {label = "1级宝石", gsid = nil,num = 4,level = 1,isgem = true},{label = "消食丸", gsid = 16065,num = 1},},
		{ {label = "1级宝石", gsid = nil,num = 4,level = 1,isgem = true},{label = "高级亲密丸", gsid = 16060,num = 1},},
		{ {label = "1级宝石", gsid = nil,num = 4,level = 1,isgem = true},{label = "小金锤", gsid = 17151,num = 1},},
	},
	[3] = {
		{{label = "1级宝石", gsid = nil,num = 3,level = 1,isgem = true},{label = "3星面包", gsid = 17133,num = 1},},
		{{label = "1级宝石", gsid = nil,num = 3,level = 1,isgem = true},{label = "消食丸", gsid = 16065,num = 1},},
		{{label = "1级宝石", gsid = nil,num = 3,level = 1,isgem = true},{label = "高级亲密丸", gsid = 16060,num = 1},},
		--{{label = "1级宝石", gsid = nil,num = 3,level = 1,isgem = true},{label = "魔幻飞毯变身药丸", gsid = 16059,num = 1},},
	},
	[4] = {
		{{label = "1级宝石", gsid = nil,num = 2,level = 1,isgem = true},{label = "2星面包", gsid = 17132,num = 1},},
		{{label = "1级宝石", gsid = nil,num = 2,level = 1,isgem = true},{label = "消食丸", gsid = 16065,num = 1},},
		{{label = "1级宝石", gsid = nil,num = 2,level = 1,isgem = true},{label = "高级亲密丸", gsid = 16060,num = 1},},
		--{{label = "1级宝石", gsid = nil,num = 2,level = 1,isgem = true},{label = "冲锋大象变身药丸", gsid = 16051,num = 1},},
	},
	[5] = {
		{ {label = "1级红枣", gsid = 17155,num = 1}, {label = "2级红枣", gsid = 17156,num = 1}, {label = "消食丸", gsid = 16065,num = 1},},
		{ {label = "1级红枣", gsid = 17155,num = 1}, {label = "2级红枣", gsid = 17156,num = 1}, {label = "高级亲密丸", gsid = 16060,num = 1},},
	},
}
--记录用户抽奖的情况
LuckyTreeServerLogics.user_map = {};
--获取宝石
--@param level:宝石级别
--@param goal_num:随机选取的数量
function LuckyTreeServerLogics.GetGemByLevel(level,goal_num)
	local self = LuckyTreeServerLogics;
	if(not self.gems)then
		self.gems = {};
		local gsid;
		for gsid=26001,26699 do
			local gsitem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsitem)then
				local lvl = tonumber(gsitem.template.stats[41]);
				lvl = tonumber(lvl);
				if(lvl)then
					if( self.gems[lvl] == nil )then
						self.gems[lvl] = {};
					end
					table.insert(self.gems[lvl],gsid);
				end
			end
		end
	end
	local gem_list = self.gems[level];
	if(gem_list)then
		local source_num = #gem_list;
		local result_index_list = commonlib.GetRandomList(source_num,goal_num,true);

		local list = {};
		local k,v;
		for k,v in ipairs(result_index_list) do
			local gsid = gem_list[v];
			if(gsid)then
				table.insert(list,{gsid = gsid, num = 1});
			end
		end
		return list;
	end
end
function LuckyTreeServerLogics.GetLoots(gift_list)
	local self = LuckyTreeServerLogics;
	if(not gift_list)then return end
	local loots = {};
	local list = {};
	local gem_list;
	local k,v;
	for k,v in ipairs(gift_list) do
		if(v.isgem and v.num)then
			--宝石奖励
			local gem_list = self.GetGemByLevel(v.level or 1, v.num);
			if(gem_list)then
				local kk,vv;
				for kk,vv in ipairs(gem_list) do
					table.insert(list,vv);
				end
			end
		else
			table.insert(list,v);
		end
	end
	--发放奖励
	local k,v;
	for k,v in ipairs(list) do
		local gsid = v.gsid;
		local num = v.num;
		if(gsid and num)then
			loots[gsid] = num;
		end
	end
	return loots;
end
function LuckyTreeServerLogics.AddExpJoybeanLoots(msg)
	local self = LuckyTreeServerLogics;
	if(not msg or not msg.nid or not msg.user)then return end
	local nid = msg.nid;

	local cache_info = self.user_map[nid];
	--缓存用户的抽奖情况
	if(not cache_info)then
		cache_info = msg.user;
		self.user_map[nid] = msg.user;
	end
	local info = cache_info;
	
	info.num = info.num or 0;
	--几等奖
	local level = self.GetGiftLevel(info.num);
	if(level ~= -1)then
		local gift_list = self.GetGift(level,nid);

		if(gift_list)then
				
			local loots = self.GetLoots(gift_list)
			local pres = {};
			pres[17151] = 0;
			info.num = info.num + 1;
			if(info.num > 1)then
				--扣除小金锤
				local gold_hammer_num = loots[17151] or 0;
				gold_hammer_num = gold_hammer_num - 1;
				loots[17151] = gold_hammer_num;
				pres[17151] = 1;
			end
			PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg) 
				if(msg and msg.issuccess)then
					local msg = {
						nid = nid,
						loots = loots,
						level = level,
						num = info.num,
						info = info,
						issuccess = true,
					}
					self.CallClient(nid,"MyCompany.Aries.ServerObjects.LuckyTreeClientLogics.DoLottery_Handler",msg);
					if(level <= 2)then
						self.CallClient(nid,"MyCompany.Aries.ServerObjects.LuckyTreeClientLogics.DoBroadcast",msg,true);
					end
					
				end
				self.SaveServerData(nid,info,function(msg)
					end);
			end,pres);
		end
	end
end
function LuckyTreeServerLogics.DoLottery(nid)
	local self = LuckyTreeServerLogics;
	self.LoadLotteryInfo(nid,self.AddExpJoybeanLoots);
end
--获取奖励
function LuckyTreeServerLogics.GetGift(level,nid)
	local self = LuckyTreeServerLogics;
	if(not level or not nid)then return end
	local list = self.gifts[level];
	
	if(list)then
		local len = #list;
		if(level == 0)then
			--如果已经有10150 鸭梨山大,奖励中取消 鸭梨山大
			local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,10150,10010);
			if(hasItem)then
				len = 2;
			end
		end
		if(level == 1)then
			--如果已经有10150 鸭梨山大,奖励中取消 鸭梨山大
			local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,10150,10010);
			if(hasItem)then
				len = 1;
			end
		end
		local index = math.random(len);
		local item = list[index];
		return item,index;
	end
end
--return: -1 出错 0 特等奖 1 一等奖
function LuckyTreeServerLogics.GetGiftLevel(num)
	local self = LuckyTreeServerLogics;
	if(not num)then return end
	local r = math.random(1000);
	local level = -1;
	local odds;
	if(num < 1)then
		--第一次抽奖只能为5等奖
		level = 5;
	else
		if(r <= 2)then
			level = 0;
		elseif(r > 2 and r <= 50 )then
			level = 1;
		elseif(r > 50 and r <= 150 )then
			level = 2;
		elseif(r > 150 and r <= 400 )then
			level = 3;
		elseif(r > 400 and r <= 750 )then
			level = 4;
		elseif(r > 750 and r <= 1000 )then
			level = 5;
		end
	end
	return level;
end
function LuckyTreeServerLogics.LoadLotteryInfo(nid,callbackFunc)
	local self = LuckyTreeServerLogics;
	LOG.std("", "info","LuckyTreeServerLogics.LoadLotteryInfo",{nid = nid});
	nid = tonumber(nid);
	if(not nid)then return end
	
	local bag = 31401;
	local gsid = 50326;	
	local server_date =  ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local default_info = {
			num = 0,
			date = server_date,
	};
	local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,gsid,bag);
	LOG.std("", "info","LuckyTreeServerLogics.LoadLotteryInfo hasItem",{hasItem = hasItem, guid = guid});
	if(hasItem == false)then
		local serverdata = QuestHelp.SerializeTable(default_info);
		PowerItemManager.PurchaseItem(nid, gsid, 1, serverdata, nil, function(msg)
			if(msg and msg.issuccess)then
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({nid = nid,user = default_info});
				end
			end
		end)
	elseif(hasItem == true)then
		local item = PowerItemManager.GetItemByGUID(nid, guid);
		if(item)then
			local serverdata = item.serverdata;
			serverdata = QuestHelp.DeSerializeTable(serverdata);
			if(serverdata and type(serverdata) == "table")then
				local user = serverdata;

				local date = user.date;
				--如果是今天
				if(date == server_date)then
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({nid = nid,user = user});
					end
				else
					--如果不是今天
					self.SaveServerData(nid,default_info,function(msg)
						if(msg and msg.issuccess)then
							if(callbackFunc and type(callbackFunc) == "function")then
								callbackFunc({nid = nid,user = default_info});
							end
						end
					end);
				end
			end
		end
	end
end
function LuckyTreeServerLogics.SaveServerData(nid,serverdata,callbackFunc)
	local gsid = 50326;
	nid = tonumber(nid);
	if(not nid or not serverdata or type(serverdata) ~= "table")then return end
	local hasItem,guid = PowerItemManager.IfOwnGSItem(nid,gsid,31401);
	if(hasItem)then
		serverdata = QuestHelp.SerializeTable(serverdata);
		PowerItemManager.SetServerData(nid, guid, serverdata, function(msg)
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
		end)
	end
end
function LuckyTreeServerLogics.CallClient(nid,func,msg,alluser)
	local self = LuckyTreeServerLogics;
	nid = tostring(nid);
	if(not nid or not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std("","error","LuckyTreeServerLogics", "the type of msg must be table!");
		return
	end

	local gridnode = gateway:GetPrimGridNode(nid)
	if(gridnode)then
		local server_object = gridnode:GetServerObject("luckytree10000");
		if(server_object) then
			msg = commonlib.serialize_compact(msg);
			local body = format("[Aries][LuckyTree][%s][%s]",func,msg);
			LOG.std("","info","LuckyTreeServerLogics.CallClient", body);
			if(alluser)then
				server_object:AddRealtimeMessage(body);
			else
				server_object:SendRealtimeMessage(nid, body);
			end
		end
	end
end
--------------------------------------------------
--摇面包树
--------------------------------------------------
LuckyTreeServerLogics.LuckyBread_award = {
		[0] = 17140,
		[1] = 17140,
		[2] = 17139,
		[3] = 17138,
		[4] = 17137,
		[5] = 17136,
}
function LuckyTreeServerLogics.GetLevel_LuckyBread()
	local self = LuckyTreeServerLogics;
	local r = math.random(1000);
	local level = -1;
	if(r <= 5)then
		level = 0;
	elseif(r > 5 and r <= 25 )then
		level = 1;
	elseif(r > 25 and r <= 75 )then
		level = 2;
	elseif(r > 75 and r <= 275 )then
		level = 3;
	elseif(r > 275 and r <= 675 )then
		level = 4;
	elseif(r > 675 and r <= 1000 )then
		level = 5;
	end
	return level;
end
--摇面包树
function LuckyTreeServerLogics.DoLottery_Bread(nid)
	local self = LuckyTreeServerLogics;
	if(not nid)then return end
	local level = self.GetLevel_LuckyBread();
	local gift_gsid = self.LuckyBread_award[level];
	if(not gift_gsid)then return end

	local loots = {
		[17176] = -1,
		[gift_gsid] = 1,
	};
	if(level == 0)then
		loots = {
		[17176] = -1,
		[gift_gsid] = 2,
	};
	end
	local pres = {
		[17176] = 1,
	};
	PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg) 
		if(msg and msg.issuccess)then
			local msg = {
				nid = nid,
				loots = loots,
				level = level,
				pres = pres,
				issuccess = true,
				bread = 1,
			}
			self.CallClient(nid,"MyCompany.Aries.ServerObjects.LuckyTreeClientLogics.DoLottery_Handler",msg);
			if(level <= 2)then
				self.CallClient(nid,"MyCompany.Aries.ServerObjects.LuckyTreeClientLogics.DoBroadcast",msg,true);
			end
		end
	end,pres);
end