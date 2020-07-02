--[[
Title: Daily checkin page
Author(s): LiXizhi
Date: 2012/8/2
Desc:  script/apps/Aries/Login/DailyCheckin.html
For continous daily checkin. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/DailyCheckin.lua");
local DailyCheckin = commonlib.gettable("MyCompany.Aries.DailyCheckin");
DailyCheckin.OnUserLogin();
DailyCheckin.ShowPageIfNotCheckedin()
DailyCheckin.ShowPage();
-------------------------------------------------------
]]
local DailyCheckin = commonlib.gettable("MyCompany.Aries.DailyCheckin");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

-- singleton page
local page;

local daily_awards = {};
DailyCheckin.sumdaily_awards={is_fetched=false, };

local IsOnInit = false;
local login_ad={};

local CheckInAPI = if_else(System.options.version=="kids", paraworld.Users.Checkin, paraworld.Users.CheckinTeen);


function DailyCheckin.GetLoginItems()
	local mark_gsid = if_else(System.options.version=="kids", 52001, nil);
	if(mark_gsid) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(mark_gsid);
		if(gsItem) then
			local maxdailycount = gsItem.maxdailycount;
			local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(mark_gsid);
			if(gsObtain and gsObtain.inday < maxdailycount) then
				ItemManager.ExtendedCost( 3501, nil, nil, function(msg)
					if(msg and msg.issuccess == true)then
						LOG.std(nil, "debug", "DailyCheckin", "daily GetLoginItems succeeded")
					else
						LOG.std(nil, "debug", "DailyCheckin", "daily GetLoginItems failed")
					end
				end,function(msg)end);
			end
		end
	end
	ItemManager.ExtendedCost( 3503, nil, nil, function(msg)
		if(msg and msg.issuccess == true)then
			LOG.std(nil, "debug", "DailyCheckin", "get 3v3 free ticket succeeded")
		else
			LOG.std(nil, "debug", "DailyCheckin", "get 3v3 free ticket failed")
		end
	end,function(msg)end);
	--[[
	local function get3v3FreeTicket(times)
		if(times > 0) then
			ItemManager.ExtendedCost( 3503, nil, nil, function(msg)
				if(msg and msg.issuccess == true)then
					get3v3FreeTicket(times - 1)
					LOG.std(nil, "debug", "DailyCheckin", "get 3v3 free ticket succeeded")
				else
					LOG.std(nil, "debug", "DailyCheckin", "get 3v3 free ticket failed")
				end
			end,function(msg)end);
		end
	end

	if(System.options.version == "kids") then
		local ticket_gsItem = ItemManager.GetGlobalStoreItemInMemory(50420);
		local ticket_gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50420);
		local remain_times = ticket_gsItem.maxweeklycount - (ticket_gsObtain.inweek or 0);
		remain_times = if_else(remain_times < 5,remain_times,5);
		get3v3FreeTicket(remain_times);
	end
	--]]
end

-- call this when user first login.
function DailyCheckin.OnUserLogin(callback_func)
	local self = DailyCheckin;
	DailyCheckin.InitSumDailyAwards();
	DailyCheckin.GetLoginItems();
	DailyCheckin.ChangeEnergyStonePosition();

	if(Map3DSystem.User.has_daily_checkedin == nil) then
		-- check status
		CheckInAPI({type = 1}, "login", function (msg)
			if(System.User.daily_checkin_awards) then
				local _, day_award;
				for _, day_award in ipairs(System.User.daily_checkin_awards) do
					if(day_award.day) then
						daily_awards[day_award.day] = day_award.items[1];
					end
				end
			end

			-- 购买累计登录标记物品
			if(System.options.version == "kids") then
				--  day sums api
				Map3DSystem.Item.ItemManager.ExtendedCost(1848, nil, nil, function(msg)
					LOG.std("", "system","DailyCheckin", msg);
					if(msg.issuccess == true) then
					end
				end, function(msg) end);
			else
				-- purchase items
				local items = "";
				local _,_award;
				for _,_award in ipairs(self.sumdaily_awards) do
					local login_gsid = _award.login_gsid;
					if(login_gsid) then
						items = items..format("%d,%d,NULL|", _award.login_gsid, _award.login_gsid_count or 1);
					end
					System.Item.ItemManager.PurchaseItem(login_gsid, 1, function(msg) end, function(msg) end, nil, "none", false);
				end
				-- paraworld.inventory.PurchaseItems({items = items}, nil, function(msg) end);
			end

			if(callback_func) then
				callback_func();
			end

			LOG.std("", "debug","DailyCheckin", msg);
		end)
	end
end

-- get daily awards
function DailyCheckin.GetDailyAwards()
	return daily_awards;
end

function DailyCheckin.GetSumDailyAwards()
	local self = DailyCheckin;
	return self.sumdaily_awards;
end

function DailyCheckin.InitSumDailyAwards()
	local self = DailyCheckin;
	if( not self.sumdaily_awards.is_fetched) then
		self.sumdaily_awards.is_fetched = true;


		local exid_table;
		if(System.options.version == "kids") then
			exid_table={1845, 1846, 1847};
		else
			exid_table={30722, 30723};
		end

		local _,_exid;	
		for _,_exid in ipairs(exid_table) do
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(_exid);	
			local _award={};
			_award.exid = _exid;
			if(exTemplate and exTemplate.tos) then
				local _,_tos,_gsid,_num;
				for _,_tos in ipairs(exTemplate.tos) do
					_gsid = _tos.key;	
					if (_gsid) then
						_gsid = tonumber(_gsid);
						_award.gsid = _gsid;
						_award.cnt = _tos.value;
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
						_award.name = gsItem.template.name;

					end
				end
				if (exTemplate.froms) then
					local _k,_v;
					for _k,_v in ipairs(exTemplate.froms) do
						_award.login_gsid = tonumber(_v.key);
						_award.logindays = _v.value;
					end								
				end
				if (exTemplate.pres) then
					local _k,_v;
					for _k,_v in ipairs(exTemplate.pres) do
						_award.needlvl = _v.value;
					end								
				end
				_award.needlvl = _award.needlvl or 0;
				table.insert(self.sumdaily_awards,_award);
			end
		end
		LOG.std(nil, "debug", "InitSumDailyAwards", self.sumdaily_awards);
	end

	return self.sumdaily_awards;
end

function DailyCheckin.HasCheckedin()
	return System.User.has_daily_checkedin;
end

function DailyCheckin.HasSumCheckedin()
	return System.User.has_sumdaily_checkedin;
end

function DailyCheckin.GetSumCheckedinTimes(v)
	local self = DailyCheckin;
	local login_gsid = self.sumdaily_awards[v].login_gsid;
	local bhas,_,__,_login_days = hasGSItem(login_gsid);
	return _login_days or 0;
end

function DailyCheckin.GetCheckedinTimes()
	return math.min(#daily_awards, System.User.daily_checkedin_times or 0);
end

function DailyCheckin.DoCheckin()
	if(not DailyCheckin.HasCheckedin()) then
		CheckInAPI({type = 0}, "login", function (msg)
			page:Refresh();
		end)
	end
end

function DailyCheckin.DoSumCheckin(v)
	local self = DailyCheckin;
	local _index = string.match(v,"(%d+)");	
	if (_index) then
		local _v = tonumber(_index)
		if(DailyCheckin.HasSumCheckedin()~=self.sumdaily_awards[_v].logindays) then
			local exID = self.sumdaily_awards[_v].exid;
			ItemManager.ExtendedCost(exID, nil, nil, function(msg) end, function(msg)
				if(msg) then
					if(msg.issuccess == true) then	
						NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");		
						local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
						Dock.OnExtendedCostNotification(msg);
						System.User.has_sumdaily_checkedin = self.sumdaily_awards[_v].logindays;
						page:Refresh();
					end
				end
			end,"none");
		end
	end
end

function DailyCheckin.Init_LoginAd()
	local config_file="config/Aries/others/login_ad.teen.xml";
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading bigzone config file: %s\n", config_file);
		return;
	end
		
	local xmlnode = "/Login_Ad/ad_item";
	
	local _ad_item = nil;	
	login_ad={};
	for _ad_item in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		local _sub_ad = {};
		_sub_ad.imgurl = _ad_item.attr.img;
		_sub_ad.tips = _ad_item.attr.tips;
		if (_ad_item.attr.npcid) then
			_sub_ad.npcid = tonumber(_ad_item.attr.npcid);
		end
		if(_ad_item.attr.loadfile) then
			_sub_ad.loadfile = _ad_item.attr.loadfile;
		end
		if (_ad_item.attr.onclick) then
			_sub_ad.onclick = _ad_item.attr.onclick;
			local base_param = "param";
			local i;
			for i = 1,5 do
				local param = base_param..i;
				if(_ad_item.attr[param]) then
					if(_ad_item.attr[param] == "true") then
						_sub_ad[param] = true;
					elseif(_ad_item.attr[param] == "false") then
						_sub_ad[param] = false;
					else
						_sub_ad[param] = _ad_item.attr[param];
					end
					
				end
			end
		end

		_sub_ad.ad_style = string.format([[position:relative;float:left;margin-left:px;width:162px;height:207px;background:url(%s#0 0 181 231)]],_sub_ad.imgurl);
		table.insert(login_ad,_sub_ad);
	end
end

-- init
function DailyCheckin.OnInit()
	page = document:GetPageCtrl();
	if (not IsOnInit) then
		if (System.options.version == "kids") then
		else
			DailyCheckin.Init_LoginAd()
		end
		-- DailyCheckin.InitSumDailyAwards();
		IsOnInit = true;
	end
	DailyCheckin.OnUserLogin(function()
		page:Refresh();
	end);
end

function DailyCheckin.LoginAd_DS_Func(index)
	if(index == nil) then
		return #(login_ad);
	else
		return login_ad[index];
	end
end

function DailyCheckin.ClickAds(index)
	local function closeUI()
		System.User.pop_daily_checkedin = true;
		page:CloseWindow();
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		AutoTips.ShowAutoTips(true);
	end
	--if(index == 4) then
		--NPL.load("(gl)script/apps/Aries/Creator/Game/Login/InternetLoadWorld.lua");
		--local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld");
		--InternetLoadWorld.ShowPage(true)
		--return;
	--end
	local npc_id = login_ad[index].npcid;
	
	if(npc_id) then
		-- 显示累计登录特效
		if (npc_id==-999) then
			DailyCheckin.OutlineSumLogin=true;
			page:Refresh();
		-- 打开魔法星UI
		elseif (npc_id==-1) then
			closeUI();
			NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.lua");
			local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");
			MagicStarPage.ShowPage(2);
		-- 打开英雄副本UI
		elseif (npc_id==-2) then
			closeUI();
			if (System.options.version == "teen") then
				NPL.load("(gl)script/apps/Aries/CombatRoom/CreateRoomPage.lua");
				local CreateRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.CreateRoomPage");
				CreateRoomPage.ShowPage(nil,4);			
			end
		elseif (npc_id>0) then
			closeUI();
			local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
			WorldManager:GotoNPC(npc_id, function() end); 
		end
	end

	local fun = login_ad[index].onclick;
	if(fun) then
		local loadfile = login_ad[index].loadfile;
		if(loadfile and loadfile ~= "")then
			local s = string.format("(gl)%s",loadfile);
			NPL.load(s);
		end

		fun = commonlib.getfield(fun);
		if(fun) then
			local param1,param2,param3,param4,param5 = login_ad[index]["param1"],login_ad[index]["param2"],login_ad[index]["param3"],login_ad[index]["param4"],login_ad[index]["param5"];
			closeUI();
			fun(param1,param2,param3,param4,param5);
		end
	end
end

function DailyCheckin.ShowPageIfNotCheckedin()
	if(System.options.IsMobilePlatform) then
		LOG.std(nil, "debug", "DailyCheckin", "escaped for mobile version");
		return;
	end
	if(not DailyCheckin.HasCheckedin() and  not System.User.pop_daily_checkedin) then
		-- if AutoTips window is open, hide it.
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		AutoTips.ShowAutoTips(false);
		DailyCheckin.ShowPage();
	end
end

function DailyCheckin.ShowPage(zorder)
	local wnd_width,wnd_height;
	if(System.options.version == "kids") then
		wnd_width = 820; wnd_height=430;
	else
		wnd_width = 710; wnd_height=530;
	end

	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = if_else(System.options.version=="kids", "script/apps/Aries/Login/DailyCheckin.html", "script/apps/Aries/Login/DailyCheckin.teen.html"), 
				name = "Aries.DailyCheckin", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = zorder or 0,
				directPosition = true,
					align = "_ct",
					x = - wnd_width/2,
					y = - wnd_height/2,
					width = wnd_width,
					height = wnd_height,
			});	

end

-- change energyStone(gsid:998) position in bag 0;
-- 998 energy stone
-- @param nid: user nid
function DailyCheckin.ChangeEnergyStonePosition()
	
	--local beHas,guid,_,copies = hasGSItem(998, 0);
--
	--if(not beHas) then
		--return;
	--end
	--local item_gsid998 = ItemManager.GetItemByGUID(guid);
--
	--if(not item_gsid998) then
		--return;
	--end
	--if(item_gsid998.position and item_gsid998.position == 63) then
		--return;
	--end
	--local item63 = ItemManager.GetItemByBagAndPosition(0, 63)
	--if(item63.guid > 0) then
		--return;
	--end
	----System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ChangeEnergyStonePosition"});
	--Map3DSystem.Item.ItemManager.UnEquipItem(item_gsid998.position, function(msg) 
		--LOG.std(nil, "info", "DailyCheckin.ChangeEnergyStonePosition", "unequip the energy stone from position:%d",item_gsid998.position);
		----Map3DSystem.Item.ItemManager.EquipItem(guid, function(msg) 
			----LOG.std(nil, "info", "DailyCheckin.ChangeEnergyStonePosition", "equip the energy stone");
		----end);
	--end);
end