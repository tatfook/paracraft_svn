--[[
Title: 
Author(s): ZRF
Date: 2010/12/20
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.lua");
MyCompany.Aries.Desktop.MiJiuHuLu.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
local MiJiuHuLu = commonlib.gettable("MyCompany.Aries.Desktop.MiJiuHuLu");

--MiJiuHuLu.curtype
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");

MiJiuHuLu.onlinetime = MiJiuHuLu.onlinetime or 0;

local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
local VIPlvl=-1;
if(bean and VIP.IsVIP())then
    VIPlvl=bean.mlel;
end

local vipname="";
if (System.options.version=="kids") then
	vipname = "魔法星";
else
	vipname = "魔法星VIP";
end

-- whether it is finished. 
MiJiuHuLu.Is_Finished = nil;
MiJiuHuLu.LotteryFinished = false;
MiJiuHuLu.LotteryFinished_Normal = false;
MiJiuHuLu.LotteryFinished_VIP = false;

-- luckyid: 1-已抽中，2-未抽中/展示，3-可抽奖
MiJiuHuLu.Lottery = {
	{gsid=-999,luckyid=3,index=1,},{gsid=-999,luckyid=3,index=2,},{gsid=-999,luckyid=3,index=3,},
	{gsid=-999,luckyid=3,index=4,},{gsid=-999,luckyid=3,index=5,},{gsid=-999,luckyid=3,index=6,},
};

MiJiuHuLu.LotteryDisplay = MiJiuHuLu.LotteryDisplay  or {};
MiJiuHuLu.Lottery_id1 = 0;
MiJiuHuLu.Lottery_id2 = 0;

-- VIP 领葫芦标志（按5个葫芦标记），vid: 0: 未领，1：已领取
MiJiuHuLu.VIPgourd={
	{vid=0,index=1},{vid=0,index=2},{vid=0,index=3},{vid=0,index=4},{vid=0,index=5},
};

function MiJiuHuLu.ShowPage(zorder)	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local params = {
		url = "script/apps/Aries/Desktop/MiJiuHuLu.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MiJiuHuLu.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = zorder or 1,
        allowDrag = true,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -560/2,
            y = -480/2,
            width = 560,
            height = 480,
    };
    System.App.Commands.Call("File.MCMLWindowFrame",  params);
	params._page.OnClose = function()
		MiJiuHuLu.page = nil;
	end
end

function MiJiuHuLu.DoInitVIPgourd()
	if(VIP.IsVIP()) then
		local _id = ItemManager.GetGSObtainCntInTimeSpanInMemory(50342);
		if (_id.inday>0) then
			local _i,_;
			for _i,_ in ipairs(MiJiuHuLu.VIPgourd) do
				if (_i> _id.inday) then
					break;
				end
				MiJiuHuLu.VIPgourd[_i].vid=1; -- 1 抽奖标记，0 为未抽奖
			end
		end
		-- 普通用户抽过奖，VIP 未抽奖，初始化奖品列表
		if (MiJiuHuLu.LotteryFinished_Normal and (not MiJiuHuLu.LotteryFinished_VIP)) then
			for _i,_l in ipairs(MiJiuHuLu.Lottery) do
				if (_l.gsid==-999 and _i<=3) then				
					MiJiuHuLu.Lottery[_i].luckyid = 2;
				end
			end
		end
	end
	--commonlib.echo("==============mijiu Hulu lottery init:")
	--commonlib.echo(MiJiuHuLu.Lottery);
	--commonlib.echo(MiJiuHuLu.LotteryFinished_Normal);
	--commonlib.echo(MiJiuHuLu.LotteryFinished_VIP);
end

function MiJiuHuLu.Init()
	MiJiuHuLu.page = document:GetPageCtrl();
	--commonlib.echo("==============mijiu Hulu lottery online:")
	--commonlib.echo(MiJiuHuLu.onlinetime)	
	if (not MiJiuHuLu.IsInited_VIPgourd) then
		MiJiuHuLu.IsInited_VIPgourd = true;
		local date = ParaGlobal.GetDateFormat("yyyyMMdd")
        local key = string.format("MijiuHulu.LotteryFinished_%s_%s",date ,tostring(Map3DSystem.User.nid));
		MiJiuHuLu.LotteryFinished_Normal = MyCompany.Aries.Player.LoadLocalData(key, false) or false;
		if (VIP.IsVIP()) then
			key = string.format("MijiuHulu.VIPLotteryFinished_%s_%s",date ,tostring(Map3DSystem.User.nid));
			MiJiuHuLu.LotteryFinished_VIP = MyCompany.Aries.Player.LoadLocalData(key, false) or false;			
		end
		MiJiuHuLu.DoInitVIPgourd();
	end

	if (not VIP.IsVIP()) then
		MiJiuHuLu.LotteryFinished = MiJiuHuLu.LotteryFinished_Normal
	else
		if (not MiJiuHuLu.LotteryFinished_VIP) then
			if (MiJiuHuLu.Lottery_id2==0 and MiJiuHuLu.Lottery_id1>0 and MiJiuHuLu.LotteryFinished_Normal) then
				for _i,_l in ipairs(MiJiuHuLu.Lottery) do
					if (_l.gsid==-999) then				
						MiJiuHuLu.Lottery[_i].luckyid = 3;
					end
				end
			end
		end
		MiJiuHuLu.LotteryFinished = MiJiuHuLu.LotteryFinished_Normal and MiJiuHuLu.LotteryFinished_VIP;
	end
	--commonlib.echo("==============mijiu Hulu lottery online:")
	--commonlib.echo(MiJiuHuLu.Lottery);
	--commonlib.echo(MiJiuHuLu.LotteryFinished_Normal);
	--commonlib.echo(MiJiuHuLu.LotteryFinished_VIP);
	MiJiuHuLu.UpdataTime(MiJiuHuLu.onlinetime * 1000,false);

	if(MiJiuHuLu.LotteryFinished) then
		goal_manager.finish("open_lottery");
	end
end

function MiJiuHuLu.UpdataTime(onlineTime,refresh)
	if(MiJiuHuLu.Is_Finished) then
		return;
	end
	onlineTime = (onlineTime or 0)/ 1000;
	--commonlib.echo("============onlinetime: "..onlineTime)
	if (onlineTime<120) then return end;

	MiJiuHuLu.onlinetime = onlineTime;

	local i;
	local tag = 1;
	for i = 1, 5 do
		local state = MiJiuHuLu.GetObtainAwardState(i);
		if(state==2)then
			MyCompany.Aries.Desktop.QuestArea.SetMiJiuHuLuTips("可领取");
			tag = 2;
			break;
		elseif(state==4)then
			local s = string.format("%s\r\n可领取",vipname);
			MyCompany.Aries.Desktop.QuestArea.SetMiJiuHuLuTips(s);
			tag = 4;
			break;
		elseif(state==3)then
			tag = 3;
		end
	end

	if( tag == 3)then
		local remain = MiJiuHuLu.GetRemainTime() or 0;
		--if(remain 
		local tmp = remain*60*1000;

		MyCompany.Aries.Desktop.QuestArea.SetMiJiuHuLuTips(commonlib.timehelp.MillToTimeStr( tmp,"h-m" ));
		MyCompany.Aries.Desktop.QuestArea.FlashMiJiuHuLu(false);
		
	elseif(tag == 1)then
		MyCompany.Aries.Desktop.QuestArea.SetMiJiuHuLuTips("领取完毕");
		MyCompany.Aries.Desktop.QuestArea.FlashMiJiuHuLu(false);
		MyCompany.Aries.Desktop.QuestArea.ShowMijiuhulu(false);

		MiJiuHuLu.Is_Finished = true;
		    
	elseif(tag==2)then
		MyCompany.Aries.Desktop.QuestArea.FlashMiJiuHuLu(true);
	elseif(tag==4)then
		MyCompany.Aries.Desktop.QuestArea.FlashMiJiuHuLu(true);
	end

	if(refresh == nil)then
		refresh = true;
	end 
	 
	if(refresh and MiJiuHuLu.page)then
		MiJiuHuLu.page:Refresh(0.01);
	end

end


function MiJiuHuLu.GetTip2(index)
	local index = tonumber(index);
	local state = MiJiuHuLu.GetObtainAwardState(index);
	local str,vipstr="","";
	if(state == 1)then
		str = "已领取";
	elseif (state==4) then
		local s = string.format("%s未领取",vipname);
		str = s;
	elseif (state==5) then
		str = "已领取";
	else
		str = "未领取";
	end
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	local godbean_num=0;	
	if (bean.combatlel >=0 and bean.combatlel<=15) then
		--godbean_num = 2*index;
		godbean_num = 100 + 20*(index - 1);
	elseif (bean.combatlel >=16 and bean.combatlel<=25) then
		--godbean_num = 2*(index+1);
		godbean_num = 100 + 20*(index - 1);
	elseif (bean.combatlel >=26 and bean.combatlel<=35) then
		--godbean_num = 2*(index+2);
		godbean_num = 100 + 20*(index - 1);
	elseif (bean.combatlel >=36 and bean.combatlel<=45) then
		--godbean_num = 2*(index+3);
		godbean_num = 100 + 20*(index - 1);
	elseif (bean.combatlel >=46 and bean.combatlel<=55) then
		--godbean_num = 2*(index+4);
		godbean_num = 100 + 20*(index - 1);
	end
	local s="";
	if(index==1)then
		s = string.format([[酿造%d分钟可获得当前等级奖励<div>【仙豆x%d】【普通捕鱼网x5】</div><div>【精力值药剂(小)x1】</div><div>【白色魔力晶石x1】</div><div style="margin-left:90px;color:#ff0000;">%s</div>]], 1,  godbean_num, str );
	elseif(index==2)then
		s = string.format([[酿造%d分钟可获得当前等级奖励<div>【仙豆x%d】【特大捕鱼网x1】</div><div style="margin-left:90px;color:#ff0000;">%s</div>]], 15, godbean_num, str );
	elseif(index==3)then
		s = string.format([[酿造%d分钟可获得当前等级奖励<div>【仙豆x%d】【抽奖铜币x1】</div><div style="margin-left:90px;color:#ff0000;">%s</div>]], 30, godbean_num, str );
	elseif(index==4)then
		s = string.format([[酿造%d分钟可获得当前等级奖励<div>【仙豆x%d】【自动战斗药丸x5】</div><div style="margin-left:90px;color:#ff0000;">%s</div>]], 60, godbean_num, str );
	elseif(index==5)then
		s = string.format([[酿造%d分钟可获得当前等级奖励<div>【仙豆x%d】【翻倍捕鱼网x1】</div><div style="margin-left:90px;color:#ff0000;">%s</div>]], 90, godbean_num, str );
	end
	return string.format("page://script/apps/Aries/Service/CommonTooltip.html?s=%s",s);
end

function MiJiuHuLu.GetVipTip(index)
	local index = tonumber(index);
	local state = MiJiuHuLu.GetObtainAwardState(index);
	local str,vipstr="","";
	if(state == 1)then
		str = "已领取";
	elseif (state==4) then
		local s = string.format("%s未领取",vipname);
		str = s;
	elseif (state==5) then
		str = "已领取";
	else
		str = "未领取";
	end
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	if (VIP.IsVIP()) then
		vipstr=string.format("%s<br/>1级奖励 仙豆x150 ,<br/>2级奖励 仙豆x160 <br/>3级奖励 仙豆x170 ,4级奖励 仙豆x180 <br/>5级奖励 仙豆x190 ,6级奖励 仙豆x200 <br/>7级奖励 仙豆x220 ,8级奖励 仙豆x240 <br/>9级奖励 仙豆x260 ,10级奖励 仙豆x300 <br/><font color='#ff0000'>%s</font>", vipname,vipname,str);
	else
		vipstr=string.format("%s<br/>1级奖励 仙豆x150 ,<br/>2级奖励 仙豆x160 <br/>3级奖励 仙豆x170 ,4级奖励 仙豆x180 <br/>5级奖励 仙豆x190 ,6级奖励 仙豆x200 <br/>7级奖励 仙豆x220 ,8级奖励 仙豆x240 <br/>9级奖励 仙豆x260 ,10级奖励 仙豆x300 <br/><font color='#ff0000'>可惜你未拥有%s!</font>", vipname,vipname,vipname);
	end
	return string.format("page://script/apps/Aries/Service/CommonTooltip.html?s=%s",vipstr);	
end

function MiJiuHuLu.GetRemainTime()
	if(MiJiuHuLu.onlinetime)then
		if( MiJiuHuLu.onlinetime < 1*60)then
			return math.ceil( (1*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 15*60)then
			return math.ceil( (15*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 30*60)then
			return math.ceil( (30*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 60*60)then
			return math.ceil( (60*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 90*60)then
			return math.ceil( (90*60 - MiJiuHuLu.onlinetime)/60);
		else
			return nil;
		end
	end
end

function MiJiuHuLu.GetObtainAwardCount(bIsVip)
	local count = 0;
	
	if(bIsVip) then
		local _, value;
		for _, value in ipairs(MiJiuHuLu.VIPgourd) do
			if(value.vid ==1) then
				count = count + 1;
			end
		end
	else
		local i;
		for i=1, 5 do
			local idx = i;	
			local state = MiJiuHuLu.GetObtainAwardState(idx);
			if(not (state == 2 or state==3) ) then
				count = count + 1;
			end
		end
	end
	return count;
end

function MiJiuHuLu.GetObtainAwardState(index)
	--commonlib.echo("=================GetObtainAwardState:   "..index)

	local index = tonumber(index);
	local gsid,_vid=0,0;
	local chksecs;

	if (index>10) then
		_index = index -10;		
	else
		_index = index;
	end
	_vid = MiJiuHuLu.VIPgourd[_index].vid;

	if (_index==1) then
		gsid=50321;
		chksecs= 1*60;
	elseif (_index==2) then
		gsid=50322;
		chksecs= 15*60;
	elseif (_index==3) then
		gsid=50323;
		chksecs= 30*60;
	elseif (_index==4) then
		gsid=50324;
		chksecs= 60*60;
	elseif (_index==5) then
		gsid=50341;
		chksecs= 90*60;
	end
	
	local obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid);
	--commonlib.echo("==============gsid: ");
	--commonlib.echo(obtain)
	--commonlib.echo(gsid)
	--commonlib.echo(MiJiuHuLu.onlinetime)
	--commonlib.echo(System.User.login_time)
	--commonlib.echo(System.User.used_sec_load)

	if (obtain and obtain.inday>=1) then--已经领取过
		if(VIP.IsVIP()) then
			local _id = ItemManager.GetGSObtainCntInTimeSpanInMemory(50342);
			--commonlib.echo("==============_vid: ".._vid);
			--commonlib.echo(index)
			--commonlib.echo(_id)
			--commonlib.echo(gsid)
			--commonlib.echo(chksecs)
			
			if ((_vid==0 or _id.inday==0) and MiJiuHuLu.onlinetime>chksecs) then
				--commonlib.echo("stat:4")
				return 4;
			else
				--commonlib.echo("stat:1")
				return 1;
			end
		else
			--commonlib.echo("stat:5")
			return 5;
		end
	elseif(MiJiuHuLu.onlinetime and MiJiuHuLu.onlinetime > chksecs)then--没领取但可以领取
		--commonlib.echo("stat:2")
		return 2;
	else--没达到领取条件
		--commonlib.echo("stat:3")
		return 3;
	end
end

function MiJiuHuLu.OnClickAward(index)
	local index= tonumber(index);
	local WorldServerName = commonlib.getfield("MyCompany.Aries.WorldServerName") or "";
	local _chk = {
		{chktime=1*60,gsid=50321},{chktime=15*60,gsid=50322},{chktime=30*60,gsid=50323},{chktime=60*60,gsid=50324},{chktime=90*60,gsid=50341},
	}

	local current_time = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	
	LOG.std(nil, "system", "MiJiuHuLu", "try check_hulu %s", tostring(index));
	if (MiJiuHuLu.last_send_time) then
		if( (current_time - MiJiuHuLu.last_send_time)<2 or 
			((MiJiuHuLu.last_index == index) and (current_time - MiJiuHuLu.last_send_time)<3) )  then
			_guihelper.MessageBox("你点击的太快了")
			return;
		end
	end
	MiJiuHuLu.last_index = index;

	LOG.std(nil, "system", "MiJiuHuLu", "check_hulu %s", tostring(index));
		
	if (not System.User.login_time) then
		System.User.login_time = current_time;
		MiJiuHuLu.onlinetime = System.User.used_sec_load/1000;
	else
		MiJiuHuLu.onlinetime = System.User.used_sec_load/1000 + current_time - System.User.login_time;
	end
		

	local _id={};
	local _index;
	if (index>10) then
		_index = index -10;
	else
		_index = index;
	end
	if (MiJiuHuLu.onlinetime>_chk[_index].chktime) then
		_id = ItemManager.GetGSObtainCntInTimeSpanInMemory(_chk[_index].gsid);
	end

	--commonlib.echo("============================gourd===")
	--commonlib.echo(MiJiuHuLu.onlinetime)
	--commonlib.echo(System.User.used_sec_load)
	--commonlib.echo(_id)
	--commonlib.echo(index)

	if (index>10) then
		_id = ItemManager.GetGSObtainCntInTimeSpanInMemory(50342);
	end

	if (_id.inday) then
		if ((_id.inday==0 and index<10) or (_id.inday<=5 and index>10)) then
			if (index>10 and index<=15) then
				MiJiuHuLu.VIPgourd[_index].vid=1;
			end
			MiJiuHuLu.last_send_time = current_time;
			
			MiJiuHuLu.GetAward(index, function(msg)
				MiJiuHuLu.last_send_time = nil;
				LOG.std(nil, "system", "MiJiuHuLu", "successfully obtained hulu %s ", tostring(index));
			end);
		else
			MiJiuHuLu.UpdataTime(MiJiuHuLu.onlinetime,true);
		end
	else
		_guihelper.MessageBox("还没有到时间，请再等一会儿");
		MiJiuHuLu.UpdataTime(MiJiuHuLu.onlinetime,true);
	end				
end

function MiJiuHuLu.GetAward(index, callbackFunc)-- index:1~5

	--commonlib.echo("==============!!:GetAward :"..index);
	--commonlib.echo(MiJiuHuLu.VIPgourd);

	local _exid = 0;
	if (index==1) then
		_exid=1802;
	elseif (index==2) then
		_exid=1803;
	elseif (index==3) then
		_exid=1804;
	elseif (index==4) then
		_exid=1805;
	elseif (index==5) then
		_exid=1806;
	elseif (index>=11) then
		_exid = 1801;
	end

	ItemManager.ExtendedCost( _exid, nil, nil, function(msg)
		if(msg and msg.issuccess == true)then
			MiJiuHuLu.UpdataTime(MiJiuHuLu.onlinetime * 1000,true);	
			local exp,_ = MyCompany.Aries.Desktop.EXPArea.GetEXP();
			local nid = System.App.profiles.ProfileManager.GetNID();
			paraworld.PostLog({action = "mijiuhulu_getaward", nid=nid,exp=exp,index=index}, 
					"mijiuhulu_getaward_log", function(msg)end);
		else
			if (msg.errorcode==428) then
				_guihelper.MessageBox("这个米酒葫芦你已经领过了或者某个礼物超过了当日最大获得上限！");
			else
				_guihelper.MessageBox("这个米酒葫芦出问题了，可能你的背包已经无法装下某个礼物了, 清理下背包或报告镇长！");
			end
		end
		if(callbackFunc)then
			callbackFunc(msg);
		end
	end,function(msg)end);
end

function MiJiuHuLu.DoLottery(v)
	goal_manager.finish("open_lottery");

	local msg = {
	};
	v = tonumber(v);
	--commonlib.echo("==============mijiu Hulu lottery:")
	paraworld.users.Lottery(msg,nil,function(msg) 
		--commonlib.echo("==============mijiu Hulu lottery:")
		--commonlib.echo(msg)
		if (msg.gsid) then
			if (MiJiuHuLu.Lottery_id1>0 or MiJiuHuLu.LotteryFinished_Normal) then
				MiJiuHuLu.Lottery_id2 = v;
			else
				MiJiuHuLu.Lottery_id1 = v;
			end

			--local _lottery ={gsid=msg.gsid, cnt=msg.cnt,index=v,};			
			--table.insert(MiJiuHuLu.Lottery,_lottery);

			MiJiuHuLu.LotteryDisplay = msg.items or {};

			local _id,items;
			for _id,items in ipairs(MiJiuHuLu.Lottery) do
				if (_id==v and items.gsid==-999) then
					MiJiuHuLu.Lottery[_id].gsid = msg.gsid;
					MiJiuHuLu.Lottery[_id].cnt = msg.cnt;
					MiJiuHuLu.Lottery[_id].luckyid = 1;
					--commonlib.echo("================lottery AA")
					--commonlib.echo(MiJiuHuLu.Lottery)
					if (MiJiuHuLu.Lottery_id2==0 and VIP.IsVIP()) then
						if (v==1) then
							local _i,_l;
							if (next(MiJiuHuLu.LotteryDisplay)~=nil) then
								for _i,_l in ipairs(MiJiuHuLu.LotteryDisplay) do
									--commonlib.echo("================lottery BB")
									--commonlib.echo(v)
									--commonlib.echo(_i)
									if (_i>2) then
										break;
									end
									MiJiuHuLu.Lottery[v+_i].gsid = _l.gsid;
									MiJiuHuLu.Lottery[v+_i].cnt = _l.cnt;
									MiJiuHuLu.Lottery[v+_i].luckyid = 2;									
								end
							end
						elseif (v==6) then
							local _i,_l;
							if (next(MiJiuHuLu.LotteryDisplay)~=nil) then
								for _i,_l in ipairs(MiJiuHuLu.LotteryDisplay) do
									if (_i>2) then
										break;
									end
									MiJiuHuLu.Lottery[v-_i].gsid = _l.gsid;
									MiJiuHuLu.Lottery[v-_i].cnt = _l.cnt;
									MiJiuHuLu.Lottery[v-_i].luckyid = 2;									
								end
							end
						else
							local _i,_l;
							if (next(MiJiuHuLu.LotteryDisplay)~=nil) then
								for _i,_l in ipairs(MiJiuHuLu.LotteryDisplay) do									
									if (_i>2) then
										break;
									end
									MiJiuHuLu.Lottery[(v-1)+(_i-1)*2].gsid = _l.gsid;
									MiJiuHuLu.Lottery[(v-1)+(_i-1)*2].cnt = _l.cnt;
									MiJiuHuLu.Lottery[(v-1)+(_i-1)*2].luckyid = 2;
								end
							end
						end
					end					
					break;
				end
			end

			local date = ParaGlobal.GetDateFormat("yyyyMMdd")
			local key = string.format("MijiuHulu.LotteryFinished_%s_%s",date ,tostring(Map3DSystem.User.nid));
			MyCompany.Aries.Player.SaveLocalData(key, true);	

			if (MiJiuHuLu.Lottery_id2>0 or (not VIP.IsVIP())) then
				local _i,_l;
				if (next(MiJiuHuLu.LotteryDisplay)~=nil) then
					for _i,_l in ipairs(MiJiuHuLu.LotteryDisplay) do
						if ((not VIP.IsVIP()) and _i>2) then
							break;
						end
						local _id,items;
						-- 检查展示列表里 _l.gsid 是否已展示
						local chkid=0; 
						for _id,items in ipairs(MiJiuHuLu.Lottery) do
							if (_l.gsid==items.gsid and _l.cnt==items.cnt) then								
								chkid=1;
								break;
							end
						end		

						if (chkid==0) then
							for _id,items in ipairs(MiJiuHuLu.Lottery) do
								if (items.gsid==-999 and items.luckyid==3) then				
									MiJiuHuLu.Lottery[_id].luckyid = 2;
									MiJiuHuLu.Lottery[_id].gsid = _l.gsid;
									MiJiuHuLu.Lottery[_id].cnt = _l.cnt;
									break;
								end
							end		
						end
					end
				end
				
				for _i,_l in ipairs(MiJiuHuLu.Lottery) do
					if (_l.gsid==-999) then				
						MiJiuHuLu.Lottery[_i].luckyid = 2;
					end
				end
				MiJiuHuLu.LotteryFinished_Normal = true;

				if (VIP.IsVIP() and MiJiuHuLu.Lottery_id2>0) then
					MiJiuHuLu.LotteryFinished_VIP = true;
					key = string.format("MijiuHulu.VIPLotteryFinished_%s_%s",date ,tostring(Map3DSystem.User.nid));
					MyCompany.Aries.Player.SaveLocalData(key, true);				
				elseif (VIP.IsVIP()) then
					MiJiuHuLu.LotteryFinished_VIP = false;
				end
			end

			if (not VIP.IsVIP()) then
				MiJiuHuLu.LotteryFinished = MiJiuHuLu.LotteryFinished_Normal;
			else
				MiJiuHuLu.LotteryFinished = MiJiuHuLu.LotteryFinished_Normal and MiJiuHuLu.LotteryFinished_VIP;
			end
			--commonlib.echo("======================miJiuHuLu.LotteryFinished")
			--commonlib.echo(MiJiuHuLu.LotteryFinished_Normal)
			--commonlib.echo(MiJiuHuLu.LotteryFinished_VIP)
			--commonlib.echo(MiJiuHuLu.Lottery_id1)
			--commonlib.echo(MiJiuHuLu.Lottery_id2)
			--commonlib.echo(_lottery)
			--commonlib.echo(MiJiuHuLu.Lottery)
			--commonlib.echo(MiJiuHuLu.LotteryDisplay)
			MiJiuHuLu.page:Refresh(0.01);

		elseif (msg.errorcode) then
			local s;
			if (msg.errorcode==431) then
				s="今天你已抽过奖了，明天再来吧"
				local date = ParaGlobal.GetDateFormat("yyyyMMdd")
				local key = string.format("MijiuHulu.LotteryFinished_%s_%s",date ,tostring(Map3DSystem.User.nid));
				MyCompany.Aries.Player.SaveLocalData(key, true);	
				if (not VIP.IsVIP()) then
					MiJiuHuLu.LotteryFinished_Normal = true;
				else
					key = string.format("MijiuHulu.VIPLotteryFinished_%s_%s",date ,tostring(Map3DSystem.User.nid));
					MyCompany.Aries.Player.SaveLocalData(key, true);	
					MiJiuHuLu.LotteryFinished_VIP = true;
				end	
				MiJiuHuLu.LotteryFinished = true;
			elseif  (msg.errorcode==424) then
				s="这可惜，这次抽到奖品，你已经有太多了，放不进背包了"
			else
				s="悲剧了，葫芦里的宝贝被怪物抢走了"
			end
			_guihelper.MessageBox(s);
		end
	end);
end

function MiJiuHuLu.CanLottery()
	local items;
    local gsid_novip = 50343;
    local gsid_vip = 50344;
    local gsid_reward;

	local _obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid_novip);

	if (_obtain.inday==0) then
		return true;
    elseif (VIP.IsVIP()) then
		_obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid_vip);
		if (_obtain.inday==0) then
			return true;
		else
			return false;	
		end
	else
		return false;
	end
end

function MiJiuHuLu.DS_Lottery(index)
	local self = MiJiuHuLu;
	if(index == nil) then
		return #(self.Lottery);
	else
		return self.Lottery[index];
	end		
end

function MiJiuHuLu.IsLucky(v)
	--commonlib.echo("===========mijiu islucky: "..v)
	local _id,item;
	for _id,item in ipairs(MiJiuHuLu.Lottery) do
		if(item.index ==v)then
			return 1;
		end
	end

	if (#(MiJiuHuLu.Lottery)==1) then
		if (MiJiuHuLu.Lottery_id1==1) then
			if (v==2 or v==3) then 
				return 2
			else
				return 3
			end
		elseif (MiJiuHuLu.Lottery_id1==6) then
			if (v==4 or v==5) then 
				return 2
			else
				return 3
			end
		else
			if (v==(MiJiuHuLu.Lottery_id1-1) or v==(MiJiuHuLu.Lottery_id1+1)) then
				return 2
			else
				return 3
			end						
		end
	elseif (#(MiJiuHuLu.Lottery)==2) then
		if (MiJiuHuLu.Lottery_id1~=v and MiJiuHuLu.Lottery_id2~=v) then
			return 2
		end	
	end
	return 3;
end

function MiJiuHuLu.getLuckyItem(v)
	local _,item;
	for _,item in ipairs(MiJiuHuLu.Lottery) do
		if(item.index ==v)then
			return item.gsid;
		end
	end
	return -1;
end

function MiJiuHuLu.getDisplayItem(v)
	local _,item;

	for _,item in ipairs(MiJiuHuLu.LotteryDisplay) do
		if (MiJiuHuLu.IsLucky(v)==2) then
			return item.gsid;
		end
	end		
end