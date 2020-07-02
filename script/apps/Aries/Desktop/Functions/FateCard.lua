--[[
Title: FateCard 
Author(s): LiPeng
Date: 2013/8/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Functions/FateCard.lua");
local FateCard = commonlib.gettable("MyCompany.Aries.Desktop.FateCard");
FateCard.ShowPage();
-------------------------------------------------------
]]

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

local FateCard = commonlib.gettable("MyCompany.Aries.Desktop.FateCard");

function FateCard.init()
	if(FateCard.inited) then
		FateCard.UpCardNumber();
		return;
	end
	
	FateCard.inited = true;

	FateCard.timelist= {1,3,5,7,9,11,13,15,17,19};
	FateCard.curWorld = 1;
	FateCard.state = 1;
	FateCard.remaintime = "01:00";
	--FateCard.playTimeList = {};
	--for i = 1,10 do
		--FateCard.playTimeList[i] = (1+2*i)*60;
	--end
	FateCard.onlinetime = FateCard.onlinetime or 0;
	FateCard.cardList = {};
	FateCard.cardGSIDList = {};
	FateCard.exidList = {
		[50408] = "HaqiFateCard",
		[50409] = "FlamingPhoenixFateCardLimited",
		[17518] = "FlamingPhoenixFateCardinfinite", 
	};
	FateCard.fruitlist = {};

	local i;
	for i = 17522,17528 do
		table.insert(FateCard.fruitlist,i);
	end

	local goodsXML = ParaXML.LuaXML_ParseFile("config/Aries/Others/fate_cards.xml");
    local worldnode;

	local namelist = {"哈奇岛","火鸟岛","寒冰岛","沙漠岛","幽暗岛","节日","水果",};
    for worldnode in commonlib.XPath.eachNode(goodsXML,"/worlds/world") do
        
		local worldname = tonumber(worldnode.attr.name);
		-- 所有卡牌和奖励
		-- worldname  怪物所在世界，1 哈奇岛 2 火鸟岛 3 寒冰岛 4 沙漠岛 5 幽暗岛 6 节日  7水果
		if(not FateCard.cardList[worldname]) then
			FateCard.cardList[worldname] = {
				cards = {},
				awards = {},
				item = {},
				bigAward = nil;
			};
		end
		FateCard.cardList[worldname]["name"] = namelist[worldname];
		if(worldnode.attr and worldnode.attr.marker) then
			FateCard.cardList[worldname]["marker"] = tonumber(worldnode.attr.marker);
		end

		if(worldname == 7) then  -- 水果篮特殊处理
			local itemnode;
			for itemnode in commonlib.XPath.eachNode(worldnode,"/item") do
				if(itemnode.attr) then
					local canEx = true;
					local pos = tonumber(itemnode.attr.pos);

					local list = {};
					local lacklist = {};
					local gsid,from_num;
					
					for gsid,from_num in string.gmatch(itemnode.attr.from_gsid,"(%d+),(%d+)") do
						
						gsid = tonumber(gsid);
						from_num = tonumber(from_num);

						local hasBe,_,_,copies = hasGSItem(gsid);
						local own_num;
						if(hasBe) then
							own_num = copies;
						else
							own_num = 0;
						end

						table.insert(list,{gsid = gsid,from_num = from_num,own_num = own_num});
						if(own_num < from_num) then
							table.insert(lacklist,gsid);
							canEx = false;
						end
					end
					itemnode.attr.canEx = canEx;
					itemnode.attr.lacklist = lacklist;
					itemnode.attr.gsidlist = list;
					FateCard.cardList[worldname]["item"][pos] = itemnode.attr;
				end
			end


			local bigAwardNode;
			for bigAwardNode in commonlib.XPath.eachNode(worldnode,"/bigaward") do
				if(bigAwardNode.attr) then
					local canEx = true;
					local lacklist = {};
					local list = {};
					local gsid,from_num;
					
					for gsid,from_num in string.gmatch(bigAwardNode.attr.from_gsid,"(%d+),(%d+)") do
						gsid = tonumber(gsid);
						from_num = tonumber(from_num);

						local hasBe,_,_,copies = hasGSItem(gsid);
						local own_num;
						if(hasBe) then
							own_num = copies;
						else
							own_num = 0;
						end

						table.insert(list,{gsid = gsid,from_num = from_num,own_num = own_num});
						if(own_num < from_num) then
							table.insert(lacklist,gsid);
							canEx = false;
						end
					end

					bigAwardNode.attr.canEx = canEx;
					bigAwardNode.attr.lacklist = lacklist;
					bigAwardNode.attr.gsidlist = list;
					FateCard.cardList[worldname]["bigAward"] = bigAwardNode.attr;
				end
			
			end
		else
			local cardnode;
			for cardnode in commonlib.XPath.eachNode(worldnode,"/cards/card") do
				if(cardnode.attr) then
					local hasBe,_,_,copies = hasGSItem(tonumber(cardnode.attr.gsid));
					if(hasBe) then
						--cardnode.attr.own = true;
						cardnode.attr.ownNumber = copies;
					else
						cardnode.attr.ownNumber = 0;
					end
					local pos = tonumber(cardnode.attr.pos);
					cardnode.attr.tooltip = "page://script/apps/Aries/Desktop/Functions/FateCard.html?gsid="..cardnode.attr.gsid;
					FateCard.cardList[worldname]["cards"][pos] = cardnode.attr;
					--table.insert(FateCard.cardList[worldname]["cards"][cardnode.attr.type],attr);
					FateCard.cardGSIDList[tonumber(cardnode.attr.gsid)] = true;
				end
			end

			local awardnode;
			for awardnode in commonlib.XPath.eachNode(worldnode,"/awards/award") do
				if(awardnode.attr) then
					--local canEx;
					local pos = tonumber(awardnode.attr.pos);

					awardnode.attr.count = tonumber(awardnode.attr.count);
					FateCard.cardList[worldname]["awards"][pos] = awardnode.attr;
				end
			end
	--		
			local bigAwardNode;
			for bigAwardNode in commonlib.XPath.eachNode(worldnode,"/bigaward") do
				if(bigAwardNode.attr and next(bigAwardNode.attr)) then
					local list = {};
					local gsid;
					for gsid in string.gmatch(bigAwardNode.attr.needgsid,"%d+") do
						gsid = tonumber(gsid);
						table.insert(list,gsid);
					end
					bigAwardNode.attr.gsidlist = list;
					FateCard.cardList[worldname]["bigAward"] = bigAwardNode.attr;
				end
			
			end
		end
    end
	FateCard.timer = commonlib.Timer:new({callbackFunc = function(timer)

		if(FateCard.state == 1) then
			local remaintime = commonlib.timehelp.MillToTimeStr(FateCard.remaintime_number,"h-m-s");

			local minute = tonumber(string.sub(FateCard.remaintime,1,2));
			local second = tonumber(string.sub(FateCard.remaintime,4,5));
			if(second == 0 and minute == 0) then
				MyCompany.Aries.Desktop.QuestArea.SetFateCardTips("等待中");
				if(FateCard.page) then
					FateCard.page:SetUIValue("remaintime","等待中");	
				end
				return;
			elseif(second == 0) then
				second = 59;
				minute = minute - 1;
				if(minute <10) then
					minute = "0"..tostring(minute);
				else
					minute = tostring(minute);
				end
				second = tostring(second);
				minute = tostring(minute);
			elseif(second > 0) then
				second = second - 1;
				if(minute <10) then
					minute = "0"..tostring(minute);
				else
					minute = tostring(minute);
				end
				if(second <10) then
					second = "0"..tostring(second);
				else
					second = tostring(second);
				end
				--FateCard.remaintime = minute..":"..second;
			end

			FateCard.remaintime = minute..":"..second;
			MyCompany.Aries.Desktop.QuestArea.SetFateCardTips(FateCard.remaintime);
			if(FateCard.page) then
				FateCard.page:SetUIValue("remaintime",FateCard.remaintime);	
			end
			
			--FateCard.remaintime = FateCard.remaintime - 1000;

		end
		
	end})
	FateCard.timer:Change(1000,1000);
	
end

function FateCard.UpCardNumber()
	--FateCard.cardList
	local worID,node;
	for worID,node in pairs(FateCard.cardList) do
		if(worID == 7) then
			local itemnode;
			for _,itemnode in pairs(node.item) do
				if(itemnode.gsidlist) then
					local canEx = true;
					local lacklist = {};
					for i = 1,#itemnode.gsidlist do
						local fruit = itemnode.gsidlist[i];
						local gsid = fruit.gsid;
						local hasBe,_,_,copies = hasGSItem(gsid);
						if(hasBe) then
							fruit.own_num = copies;
						else
							fruit.own_num = 0;
						end
						if(fruit.own_num < fruit.from_num) then
							canEx = false;
							table.insert(lacklist,gsid);
						end
					end
					itemnode.canEx = canEx;
					itemnode.lacklist = nil;
					itemnode.lacklist = lacklist;
				end
			end
			if(node.bigAward and node.bigAward.gsidlist) then
				local canEx = true;
				local lacklist = {};
				local t = node.bigAward.gsidlist;
				for i = 1,#t do
					local gsid = t[i].gsid;
					local hasBe,_,_,copies = hasGSItem(gsid);
					if(hasBe) then
						t[i].own_num = copies;
					else
						t[i].own_num = 0;
					end
					if(t[i].own_num < t[i].from_num) then
						canEx = false;
						table.insert(lacklist,gsid);
					end
				end
				node.bigAward.canEx = canEx;
				node.bigAward.lacklist = nil;
				node.bigAward.lacklist = lacklist;
			end
		else
			if(node.cards) then
				local cardNode;
				for _,cardNode in pairs(node.cards) do
					local gsid = tonumber(cardNode.gsid);
					local hasBe,_,_,copies = hasGSItem(gsid);
					if(hasBe) then
						--cardnode.attr.own = true;
						cardNode.ownNumber = copies;
					else
						cardNode.ownNumber = 0;
					end
				end
			end
		end

		
	end
end

function FateCard.UpdataTime(onlineTime)
	FateCard.init();
	local hasBe,_,_,copies = hasGSItem(50408);

	local systemRefresh = true;
	if(tonumber(onlineTime) == tonumber(FateCard.onlinetime)) then
		systemRefresh = false;
	end

	if(hasBe) then
		FateCard.Is_Finished = false;
	end
	if(FateCard.Is_Finished) then
		return;
	end

	--echo(onlineTime);
	FateCard.onlinetime = onlineTime or 0;
	--echo(FateCard.onlinetime)
	--FateCard.init();
	
	local num = tonumber(copies);
	-- tag   1表示时间不到，2表示时间已到，3表示今天次数已经消耗完
	local tag;
	local itemTime = 0;
	local onlineMinute = 0;
	if(not hasBe) then
		FateCard.Is_Finished = true;
		tag = 3;
		--return;
	else
		--num = tonumber(num);
		num = 11 - num;
		--FateCard.timelist
		-- itemTime 触发每个命运卡牌需要的在线时间
		
		--echo("222222")
		--echo();
		--if(not FateCard.timelist) then
			--FateCard.timelist= {1,3,5,7,9,11,13,15,17,19};
		--end
		for i = 1,num do
			if(not FateCard.timelist[i]) then
				return;
			end
			itemTime = itemTime + FateCard.timelist[i];
		end
		--echo(onlineTime);
		onlineMinute = math.floor(tonumber(onlineTime)/60000);
		--echo(onlineMinute);
		if(onlineMinute >= itemTime) then
			tag = 2;
		else
			tag = 1;
		end
	end

	if(tag == 1) then
		local time = itemTime*60000 - onlineTime;
		FateCard.remaintime_number = time;
		time = commonlib.timehelp.MillToTimeStr(time,"h-m-s");
		time = string.sub(time,4,8);
		FateCard.remaintime = time;
		FateCard.state = 1;

		MyCompany.Aries.Desktop.QuestArea.SetFateCardTips(time);
		MyCompany.Aries.Desktop.QuestArea.SetFateCardIcon(false);

	elseif(tag == 2) then
		FateCard.remaintime = "可抽取";
		FateCard.state = 2;

		MyCompany.Aries.Desktop.QuestArea.SetFateCardTips("可抽取");
		MyCompany.Aries.Desktop.QuestArea.SetFateCardIcon(true);
	elseif(tag == 3) then
		FateCard.remaintime = "";
		FateCard.state = 3;
		MyCompany.Aries.Desktop.QuestArea.SetFateCardTips("");
		MyCompany.Aries.Desktop.QuestArea.SetFateCardIcon(true);
	end
	if(FateCard.page) then
		local _wnd = MyCompany.Aries.app._app:FindWindow("FateCard.ShowCardPage");
		if(_wnd) then
			_wnd.MyPage:Refresh();
		end	
	end
end

--function FateCard.UpOnlineTime()
--
	--local current_time = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
		--
	--if (not System.User.login_time) then
		--System.User.login_time = current_time;
		--FateCard.onlinetime = System.User.used_sec_load/1000;
	--else
		--FateCard.onlinetime = System.User.used_sec_load/1000 + current_time - System.User.login_time;
	--end
--end

function FateCard.DS_Func_Items(index,worldname,type)

	--FateCard.cardList[worldname]["cards"][cardnode.attr.type][pos]
	--echo(worldname);
	--echo(type);
	--echo(FateCard.cardList[worldname])
	if(index == nil) then
		if(type == "cards") then
			return #FateCard.cardList[worldname]["cards"];
		elseif(type == "awards") then
			return #FateCard.cardList[worldname]["awards"];
		end 
	else
		if(type == "cards") then
			return FateCard.cardList[worldname]["cards"][index];
		elseif(type == "awards") then
			return FateCard.cardList[worldname]["awards"][index];
		end 
	end
end

function FateCard.OnClickFateIcon()
	FateCard.init();
	local markGSID = FateCard.cardList[1]["marker"];
	local hasBe,_,_,num = hasGSItem(markGSID);
	--local exid = FateCard.exidList[markGSID];
	--echo()
	--if(FateCard.curWorld == 1) then
		--if(hasBe) then
			--if(FateCard.state == 2) then
				--System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid = exid}});
				----FateCard.UpdataTime(FateCard.onlineTime);
			--else
				--FateCard.ShowPage();
			--end
		--else
			--FateCard.ShowPage();
		--end
	--else
		--System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid = exid}});
	--end
	if(hasBe) then
		if(FateCard.state == 2) then
			System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid="HaqiFateCard"}});
			--FateCard.UpdataTime(FateCard.onlineTime);
		else
			FateCard.ShowPage();
		end
	else
		FateCard.ShowPage();
	end
end

function FateCard.OpenFateCardBag()
	local markGSID = FateCard.cardList[FateCard.curWorld]["marker"];
	local hasBe,_,_,num = hasGSItem(markGSID);
	local exid = FateCard.exidList[markGSID];
	if(markGSID == 17518 and FateCard.GetStamina() < 5) then
		--_guihelper.MessageBox("你的精力值低于5点，不能使用命运卡包，先去补充精力值吧");
		FateCard.ReplenishStamina();
		return;
	end
	--echo("2222222");
	if(hasBe) then
		System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid = exid}});
	end
	
end

function FateCard.GetBigAward()
	local list = FateCard.cardList[FateCard.curWorld]["bigAward"]["gsidlist"];
	local enoughCards = true;
	for i = 1,#list do
		if(not hasGSItem(list[i])) then
			enoughCards = false;
			break;
		end
	end
	if(enoughCards) then
		local exid;
		if(FateCard.curWorld == 1) then
			exid = "HaqiFateCardBigAward";
		end
		System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid=exid}});
	else
		local s;
		if(FateCard.curWorld == 1) then
			s = "集齐所有哈奇岛命运卡牌即可领取";
		end
		_guihelper.MessageBox(s);
	end
	
end

function FateCard.GetAward(index)
	local canEx;
	local cardList = FateCard.cardList[FateCard.curWorld]["cards"];
	local awardList = FateCard.cardList[FateCard.curWorld]["awards"];
	local _index = tonumber(index);
	--echo(_index);
	--echo(cardList);
	if(cardList[_index]["ownNumber"] > 0 and cardList[_index+5]["ownNumber"] > 0 and cardList[_index+10]["ownNumber"] > 0) then
		canEx = true;
	else
		canEx = false;
	end
	local exid = tonumber(awardList[_index]["exid"]);
	--echo("1111")
	--echo(exid);
    --local exid = awardList[index]["exid"];
    if(canEx) then
        ItemManager.ExtendedCost(exid,nil,nil,function(msg)
			--log("+++++++ExtendedCost 1923:  return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				FateCard.page:Refresh();
			end
		
		end,function(msg) end,"pick");    
    else
        _guihelper.MessageBox("集齐上面一列卡牌，即可获得该奖品。");
    end
end

function FateCard.ExchangeFruit(pos)
	local t;
	--echo("2222222");
	--echo(pos);
    if(pos == 0) then
        t = FateCard.cardList[7]["bigAward"];
    else
        t = FateCard.cardList[7]["item"][pos];
    end
	if(t.canEx) then
		local exid = tonumber(t.exid);
		ItemManager.ExtendedCost(exid,nil,nil,function(msg)
			--log("+++++++ExtendedCost 1923:  return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				FateCard.page:Refresh();
			end
		
		end,function(msg) end,"pick");   
	else
		local s = "";
		local list = t.lacklist
		for i = 1,#list do
			local gsid = list[i];
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(s == "") then
				s = s..gsItem.template.name;
			else
				s = s.."、"..gsItem.template.name;
			end
			--s = s..gsItem.template.name;
		end
		local s = string.format("你的%s数量不足，不能获得该物品",s);
		_guihelper.MessageBox(s);
	end
end

function FateCard.ShowPage(index)
	local tabIndex = index or 1;
	FateCard.curWorld = tabIndex;
	local params = {
		url = "script/apps/Aries/Desktop/Functions/FateCardPage.html",
		name = "FateCard.ShowCardPage",
		app_key = MyCompany.Aries.app.app_key,
		isShowTitleBar = false,
		DestroyOnClose = true,
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 10,
		directPosition = true,
			align = "_ct",
			x = -680/2,
			y = -530/2,
			width = 680,
			height = 530,
		cancelShowAnimation = true,
	};
	System.App.Commands.Call("File.MCMLWindowFrame",params);

	if(FateCard.page) then
		FateCard.page:SetUIValue("remaintime",FateCard.remaintime);	
	end
end

-- the msg's structure like this: {input_msg={exid="FlamingPhoenixFateCardLimited",},type="reply",name="PowerExtendedCost",msg={issuccess=true,stats={},updates={{cnt=-1,bag=1003,gsid=50409,guid=1719,},{cnt=1,bag=12,gsid=17494,guid=1621,},{cnt=-200,bag=12,gsid=17213,guid=1372,},},adds={},},}
function FateCard.MsgHandle(msg)
	if(msg.input_msg.exid == "HaqiFateCardBigAward") then
		if(msg.msg.issuccess) then
			FateCard.page:Refresh();
		end
		return;
	end
	
	if(msg.input_msg.exid == "HaqiFateCard") then
		NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua")
		local time = MyCompany.Aries.Desktop.AntiIndulgenceArea.GetUsedSec(); 
		FateCard.UpdataTime(time);
	end
	if(msg.msg.issuccess) then
		local cardGSID;
		local loseXianDou = false;
		local loseCount;
		if(#msg.msg.updates ~= 0) then
			for i = 1,#msg.msg.updates do
				local gsid = tonumber(msg.msg.updates[i].gsid);
				if(FateCard.cardGSIDList[gsid]) then
					cardGSID = gsid;
				end
				local count = tonumber(msg.msg.updates[i].cnt);
				if(gsid == 17213 and count < 0) then
					loseXianDou = true;
					loseCount = count;
				end
			end
		end

		if(#msg.msg.adds ~= 0) then
			--echo("2222");
			for i = 1,#msg.msg.adds do
				--echo(msg.msg.adds);
				local gsid = tonumber(msg.msg.adds[i].gsid);
				if(FateCard.cardGSIDList[gsid]) then
					cardGSID = gsid;
				end
				local count = tonumber(msg.msg.adds[i].cnt);
				if(gsid == 17213 and count < 0) then
					loseXianDou = true;
					loseCount = count;
				end
			end
		end
		MyCompany.Aries.Desktop.Dock.ShowNotificationInChannel(cardGSID, 1);
		if(loseXianDou and loseCount) then
			MyCompany.Aries.Desktop.Dock.ShowNotificationInChannel(17213, loseCount);
		end
		--local zorder = zorder or 1;
		--gsid = tonumber(gsid);
		if(cardGSID) then
			local params = {
				url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/CardTips.kids.html?gsid=%d&tiptype=%s",cardGSID,"fatecard");
				name = "FateCardTips", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,	
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 11,
				allowDrag = true,
				enable_esc_key = true,
				directPosition = true,
					align = "_ct",
					x = -358/2,
					y = -529/2,
					width = 358,
					height = 439,
				cancelShowAnimation = true,
			}
			System.App.Commands.Call("File.MCMLWindowFrame", params)
		end
		if(FateCard.page) then
			FateCard.page:Refresh(0.1);							
		end
	else
		-- 
	end
end
-- param loots: structure like this  {{17213,4},{50409,1}}
function FateCard.HasFateCardMaker(loots)
	local exidlist = {
		[50409] = "FlamingPhoenixFateCardLimited",
	}
	local k,v;
	for k,v in pairs(exidlist) do
		if(loots[k]) then
			System.GSL_client:SendRealtimeMessage("sPowerAPI",{name = "PowerExtendedCost",params={exid = v}});
			--System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid="HaqiFateCard"}});
		end	
	end
end

function FateCard.BeFateCardMaker(gsid)
	local exidlist = {
		[17518] = "FlamingPhoenixFateCardinfinite",
	};

	if(gsid == 17518 and FateCard.GetStamina() < 5) then
		FateCard.ReplenishStamina();
		--_guihelper.MessageBox("你的精力值低于5点，不能使用命运卡包，先去补充精力值吧");
		return;
	end

	if(exidlist[gsid]) then
		System.GSL_client:SendRealtimeMessage("sPowerAPI",{name = "PowerExtendedCost",params={exid = exidlist[gsid]}});
	end
	
end

function FateCard.GetStamina()
	local self = CatchFish;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean)then
		return bean.stamina or 0;
	end
	return 0;
end

function FateCard.ReplenishStamina()
	local self = FateCard;
	local s = "";
	--精力值药剂大、中
	local staminaList = {17393,17344,17345};
	local hasStaminaPill = false;
	local pillGUID;
	local k,v;
	local gsid,exid;
	for k,v in pairs(staminaList) do
		gsid = tonumber(v);
		gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
		exid = gsItem.template.stats[51];
		hasStaminaPill,pillGUID = Map3DSystem.Item.ItemManager.IfOwnGSItem(gsid,12,nil);	
		if(hasStaminaPill == true) then
			if(gsid == 17393) then
				if(MyCompany.Aries.VIP.IsVIP()) then
					s = format("你的精力值低于5，不能再开启命运卡包。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用补充精力值！",gsid);
					break;
				end
				--local VIP = commonlib.gettable("MyCompany.Aries.VIP");
				--MyCompany.Aries.VIP.IsVIP
			else
				s = format("你的精力值低于5，不能再开启命运卡包。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用补充精力值！",gsid);
				break;
			end
		end
	end
	if(s == "") then
		s = format("你的精力值低于5，不能再开启命运卡包，现在购买精力值药剂？");
	end
	if(hasStaminaPill) then
		_guihelper.MessageBox(s,function(result) 
			if(result == _guihelper.DialogResult.Yes) then
				Map3DSystem.Item.ItemManager.ExtendedCost(exid, nil, nil, function(msg) 
					MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI();
					_guihelper.MessageBox("你已补充了精力值，可以继续开启命运卡包了");
				end);
			end
			if(result == _guihelper.DialogResult.No) then
				--self.DoQuitInternal();
				--self.ForceAway();
				_guihelper.MessageBox("你的精力值低于5，不能再开启命运卡包，补充了精力值再来吧！");
				return;
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	else
		_guihelper.MessageBox(s,function(result) 
			if(result == _guihelper.DialogResult.Yes) then
				Map3DSystem.mcml_controls.pe_item.OnClickGSItem(17344,true);
			end
			if(result == _guihelper.DialogResult.No) then
				_guihelper.MessageBox("你的精力值低于5，不能再开启命运卡包，补充了精力值再来吧！");
				return;
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	end
end