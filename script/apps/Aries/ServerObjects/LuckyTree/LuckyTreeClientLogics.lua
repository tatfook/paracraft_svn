--[[
Title: 
Author(s): Leio
Date: 2010/12/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");
LuckyTreeClientLogics.DoLottery();

NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");
LuckyTreeClientLogics.DoInit()

NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");

local k;
for k=1,50 do
	LuckyTreeClientLogics.CallServer("MyCompany.Aries.ServerObjects.LuckyTreeServerLogics.DoLottery",nil);
end
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30420_Lucky_Tree_Bread.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

NPL.load("(gl)script/apps/Aries/Scene/main.lua");
-- create class
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");
local sID = "luckytree10000";
local LOG = LOG;
local Scene = commonlib.gettable("MyCompany.Aries.Scene");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
LuckyTreeClientLogics.canShow = false;
function LuckyTreeClientLogics.SetWindowsHook()
	local self = LuckyTreeClientLogics;
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
	callback = function(nCode, appName, msg, value)
		if(msg.aries_type == "OnGlobalRegionRadar") then
			if(msg.args) then
				if(msg.args.key == "Region_TownSquare") then
					self.canShow = true;
				else
					self.canShow = false;
				end
			end
		end
		return nCode;
	end, 
	hookName = "LuckyTreeClientLogics.SetWindowsHook", appName = "Aries", wndName = "RegionRadar"});
end
----登录赠送 小金锤
--function LuckyTreeClientLogics.DoInit()
	--local self = LuckyTreeClientLogics;
	--local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	--local year, month, day = string.match(serverDate, "^(%d+)%-(%d+)%-(%d+)$");
	--if(year and month and day) then
		--year = tonumber(year);
		--month = tonumber(month);
		--day = tonumber(day);
		--local canPush;
		----用户自2010年12月24日-2011年3月1日期间
		--if(year == 2010)then
			--if(month == 12 and day >=22)then
				--canPush = true;
			--end
		--elseif(year == 2011)then
			--if( (month == 1 or month == 2 )or (month == 3 and day <=1) )then
				--canPush = true;
			--end
		--end
		--if(canPush)then
			--local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50327);
			----local hasItem,guid,bag,copies = hasGSItem(50327);
			--if(gsObtain and gsObtain.inday > 0) then
				--return;
			--end
			--ItemManager.ExtendedCost(664, nil, nil, function(msg)
				--LOG.std("","info","LuckyTreeClientLogics.DoInit", msg);
			--end, function(msg) end,"none");
		--end
	--end
--end
--今天抽奖的次数
function LuckyTreeClientLogics.GetTodayNum()
	local self = LuckyTreeClientLogics;
	local bHas,guid = hasGSItem(50326);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		local serverdata = item.serverdata;
		if(not serverdata or serverdata == "")then
			return 0;
		end
		serverdata = QuestHelp.DeSerializeTable(serverdata);
		if(serverdata and type(serverdata) == "table")then
			local server_date = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local date = serverdata.date;
			local num = serverdata.num;
			
			if(date and date == server_date)then
				return num or 0;
			else
				return 0;
			end
		end
	end
	return 0;
end
--开始抽奖
function LuckyTreeClientLogics.DoLottery()
	local self = LuckyTreeClientLogics;
	local num = self.GetTodayNum();
	if(num > 0)then
		local bHas = hasGSItem(17151);
		if(not bHas)then
			_guihelper.MessageBox("需要小金锤");
			return
		end
	end
	self.CallServer("MyCompany.Aries.ServerObjects.LuckyTreeServerLogics.DoLottery",nil);
end
function LuckyTreeClientLogics.DoLottery_Handler(msg)
	local self = LuckyTreeClientLogics;
	LOG.std("","info","LuckyTreeClientLogics.DoLottery_Handler", msg);
	if(not msg or not msg.issuccess or not msg.loots)then return end
	local loots = msg.loots;
	local notification_msg = {};
	notification_msg.adds = {};
	notification_msg.updates = {};
	notification_msg.stats = {};
	local id,value;
	for id,value in pairs(loots) do
		if(id == 17151)then
			value = value + 1;
		end
		if(value > 0)then
			table.insert(notification_msg.adds, {gsid = id, cnt = value});
		end
	end
	--客户端奖励提醒
	Dock.OnExtendedCostNotification(notification_msg);
	

	local level = msg.level;
	local num = msg.num;
	local loots = notification_msg.adds;
	if(msg.bread == 1)then
		local Lucky_Tree_Bread = commonlib.gettable( "MyCompany.Aries.Quest.NPCs.Lucky_Tree_Bread" );
		Lucky_Tree_Bread.DoLottery_Hanlder(msg);
		paraworld.PostLog({action = "do_lottery_bread", level = level,loots = loots,}, 
						"do_lottery_bread_log", function(msg)
					end);
	else
		local Lucky_Tree = commonlib.gettable( "MyCompany.Aries.Quest.NPCs.Lucky_Tree" );
		Lucky_Tree.DoLottery_Hanlder(msg);
		paraworld.PostLog({action = "do_lottery", level = level,num = num, loots = loots,}, 
						"do_lottery_log", function(msg)
					end);
	end
	ItemManager.GetItemsInBag(12, "", function(msg)end, "access plus 0 minutes");
	
end
function LuckyTreeClientLogics.DoBroadcast(msg)
	local self = LuckyTreeClientLogics;
	if(not msg or not msg.issuccess)then return end
	if(msg.bread == 1)then
		self.DoBroadcast_Bread(msg);
	else
		self.DoBroadcast_LuckyTree(msg);
	end	
end
function LuckyTreeClientLogics.DoBroadcast_Bread(msg)
	local self = LuckyTreeClientLogics;
	if(not msg or not msg.issuccess)then return end
	local nid = msg.nid;
	local level = msg.level;
	nid = tonumber(nid);
	if(not nid or not level or level > 3 or not self.canShow)then return end
	local title = "幸运树活动";
	local breads = {
		[0] = 10,
		[1] = 10,
		[2] = 9,
		[3] = 8,
		[4] = 7,
		[5] = 6,
	}
	local title = "";
	if(breads[level])then
		title = breads[level] .. "星面包";
	end
	if(nid == Map3DSystem.User.nid)then
		if(level == 0)then
			str = "你人品爆发啦！获得【特等奖】--" .. title.."x2"
		elseif(level == 1)then
			str = "恭喜你获得【一等奖】--" .. title
		elseif(level == 2)then
			str = "恭喜你获得【二等奖】--" .. title
		elseif(level == 3)then
			str = "恭喜你获得【三等奖】--" .. title
		end
		if(str)then
			BroadcastHelper.PushLabel({label = str,color = "255 0 0",shadow = true,bold = true,font_size = 14, priority=1}); 
		end
	else
		System.App.profiles.ProfileManager.GetUserInfo(nid, "luckytree", function(msg)
			if(msg == nil or not msg.users or not msg.users[1]) then
				return;
			end	
			local nickname = tostring(msg.users[1].nickname);

			if(level == 0)then
				str = string.format("【%s】人品爆发啦！获得【特等奖】--%s",nickname,title);
			elseif(level == 1)then
				str = string.format("恭喜【%s】获得【一等奖】--%s",nickname,title);
			elseif(level == 2)then
				str = string.format("恭喜【%s】获得【二等奖】--%s",nickname,title);
			elseif(level == 3)then
				str = string.format("恭喜【%s】获得【三等奖】--%s",nickname,title);
			end
			if(str)then
				BroadcastHelper.PushLabel({label = str,color = "255 0 0",shadow = true,bold = true,font_size = 14, priority=1}); 
			end
		end);
	end
end

function LuckyTreeClientLogics.DoBroadcast_LuckyTree(msg)
	local self = LuckyTreeClientLogics;
	if(not msg or not msg.issuccess)then return end
	local nid = msg.nid;
	local level = msg.level;
	nid = tonumber(nid);
	if(not nid or not level or level > 3 or not self.canShow)then return end
	local title = "幸运树活动";
	if(msg.bread == 1)then
		title = "面包树活动";
	end
	if(nid == Map3DSystem.User.nid)then
		if(level == 0)then
			str = "你人品爆发啦！获得价值1000魔豆的【特等奖】宝贝--" .. title
		elseif(level == 1)then
			str = "恭喜你获得了价值30魔豆的【一等奖】宝贝--" .. title
		elseif(level == 2)then
			str = "恭喜你获得了【二等奖】宝贝--" .. title
		elseif(level == 3)then
			str = "恭喜你获得了【三等奖】宝贝--" .. title
		end
		if(str)then
			BroadcastHelper.PushLabel({label = str,color = "255 0 0",shadow = true,bold = true,font_size = 14, priority=1}); 
		end
	else
		System.App.profiles.ProfileManager.GetUserInfo(nid, "luckytree", function(msg)
			if(msg == nil or not msg.users or not msg.users[1]) then
				return;
			end	
			local nickname = tostring(msg.users[1].nickname);

			if(level == 0)then
				str = string.format("【%s】人品爆发啦！获得价值1000魔豆的【特等奖】宝贝--%s",nickname,title);
			elseif(level == 1)then
				str = string.format("恭喜【%s】获得了价值30魔豆的【一等奖】宝贝--%s",nickname,title);
			elseif(level == 2)then
				str = string.format("恭喜【%s】获得了【二等奖】宝贝--%s",nickname,title);
			elseif(level == 3)then
				str = string.format("恭喜【%s】获得了【三等奖】宝贝--%s",nickname,title);
			end
			if(str)then
				BroadcastHelper.PushLabel({label = str,color = "255 0 0",shadow = true,bold = true,font_size = 14, priority=1}); 
			end
		end);
	end
end
function LuckyTreeClientLogics.CallServer(func,msg)
	local self = LuckyTreeClientLogics;
	if(not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std("","error","LuckyTreeClientLogics", "the type of msg must be table!");
		return
	end
	msg = commonlib.serialize_compact(msg);
	local body = string.format("[Aries][LuckyTree][%s][%s]",func,msg);
	
	Map3DSystem.GSL_client:SendRealtimeMessage(sID, {body = body});
end
--开始抽奖
function LuckyTreeClientLogics.DoLottery_Bread()
	local self = LuckyTreeClientLogics;
	local num = self.GetTodayNum();
	if(num > 0)then
		local bHas = hasGSItem(17176);
		if(not bHas)then
			_guihelper.MessageBox("需要面包棒");
			return
		end
	end
	self.CallServer("MyCompany.Aries.ServerObjects.LuckyTreeServerLogics.DoLottery_Bread",nil);
end