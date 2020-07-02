--[[
Title: 
Author(s): Yan Dongdong
Date: 2012/8/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.teen.lua");
MyCompany.Aries.Desktop.MiJiuHuLu.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.teen.lua");
NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");

local MiJiuHuLu = commonlib.gettable("MyCompany.Aries.Desktop.MiJiuHuLu");

--MiJiuHuLu.curtype
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");

MiJiuHuLu.onlinetime = MiJiuHuLu.onlinetime or 0;

local vipname="魔法星VIP";

-- whether it is finished. 
MiJiuHuLu.Is_Finished = nil;

local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
local VIPlvl=-1;
if(bean and VIP.IsVIP())then
    VIPlvl=bean.mlel;
end

-- VIP 领葫芦标志（按5个葫芦标记），vid: 0: 未领，1：已领取
--MiJiuHuLu.VIPgourd={
	--{vid=0,index=1},{vid=0,index=2},{vid=0,index=3},{vid=0,index=4},{vid=0,index=5},
--};

function MiJiuHuLu.ShowPage(zorder)	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local params = {
		url = "script/apps/Aries/Desktop/MiJiuHuLu.teen.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MiJiuHuLu.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
		--enable_esc_key = true,
        zorder = zorder or 1,
        allowDrag = true,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -700/2,
            y = -480/2,
            width = 700,
            height = 480,
    };
    System.App.Commands.Call("File.MCMLWindowFrame",  params);
	params._page.OnClose = function()
		MiJiuHuLu.page = nil;
	end
end

--function MiJiuHuLu.DoInitVIPgourd()
	--if(VIP.IsVIP()) then
		--local _id = ItemManager.GetGSObtainCntInTimeSpanInMemory(50342);
		--if (_id and _id.inday>0) then
			--local _i,_;
			--for _i,_ in ipairs(MiJiuHuLu.VIPgourd) do
				--if (_i> _id.inday) then
					--break;
				--end
				--MiJiuHuLu.VIPgourd[_i].vid=1; -- 1 抽奖标记，0 为未抽奖
			--end
		--end
	--end	
--end

function MiJiuHuLu.Init()
	MiJiuHuLu.page = document:GetPageCtrl();
	--if (not MiJiuHuLu.IsInited_VIPgourd) then
		--MiJiuHuLu.IsInited_VIPgourd = true;
		--MiJiuHuLu.DoInitVIPgourd();
	--end

	MiJiuHuLu.UpdataTime(MiJiuHuLu.onlinetime * 1000,false);
end

function MiJiuHuLu.UpdataTime(onlineTime,refresh)
	if(MiJiuHuLu.Is_Finished) then
		return;
	end
	onlineTime = (onlineTime or 0)/ 1000;	

	if (onlineTime<120) then return end;
	MiJiuHuLu.onlinetime = onlineTime;
	
	local i;
	local tag = 1;
	for i = 1, 5 do
		local state = MiJiuHuLu.GetObtainAwardState(i);
		if(state==2)then
			-- MapArea.SetMiJiuHuLuTips("可领取");
			LinksAreaPage.SetMiJiuHuLuTips("可领取");
			tag = 2;
			break;
		elseif(state==4)then
			local s = string.format("%s\r\n可领取",vipname);
			-- MapArea.SetMiJiuHuLuTips(s);
			LinksAreaPage.SetMiJiuHuLuTips(s);
			tag = 4;
			break;
		elseif(state==3)then
			tag = 3;
		end
	end

	if( tag == 3)then
		local remain = MiJiuHuLu.GetRemainTime();
		--if(remain 
		local tmp = remain*60*1000;

		LinksAreaPage.SetMiJiuHuLuTips(commonlib.timehelp.MillToTimeStr( tmp,"h-m" ));
		LinksAreaPage.FlashBtn("online",false);
		
	elseif(tag == 1)then
--		MapArea.SetMiJiuHuLuTips("领取完毕");
		LinksAreaPage.SetMiJiuHuLuTips("");
		LinksAreaPage.FlashBtn("online",false);
--		MapArea.ShowMijiuhulu(false);

		MiJiuHuLu.Is_Finished = true;
		    
	elseif(tag==2)then
		LinksAreaPage.FlashBtn("online",true);
	elseif(tag==4)then
		LinksAreaPage.FlashBtn("online",true);
	end

	if(refresh == nil)then
		refresh = true;
	end 
	 
	if(refresh and MiJiuHuLu.page)then
		MiJiuHuLu.page:Refresh(0.01);
	end

end

function MiJiuHuLu.HasAllHulu()
	local tag = 1;
	for i = 1, 5 do
		local state = MiJiuHuLu.GetObtainAwardState(i);
		if(state==2)then
			tag = 2;
			break;
		elseif(state==4)then
			tag = 4;
			break;
		elseif(state==3)then
			tag = 3;
		end
	end
	if(tag == 1)then
		return true
	else
		return false
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

--	local giftname={"1星面包*1","初级耐力药丸*1","自动战斗药丸*1","时空传送石*1","银币小钱袋*1",};
	local exid_table={1802,1803,1804,1805,1806,};
	local giftname={};
	local _,_exid;
	for _,_exid in ipairs(exid_table) do
		local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(_exid);	
		if(exTemplate and exTemplate.tos) then
			local _,_tos,_gsid,_num;
			for _,_tos in ipairs(exTemplate.tos) do
				_gsid = _tos.key;	
				if (_gsid) then
					_gsid = tonumber(_gsid);
					-- filter the mark items
					if (_gsid<50000) then
						_num = _tos.value;
			 			local gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
						local s = string.format("%s*%s",gsItem.template.name,_num);	
						table.insert(giftname,s);
					end
				end
			end
		end
	end

	local s="";
	if(index==1)then
		s = string.format([[累计在线%d分钟可获得奖励<br/>【%s】<div style="margin-left:90px;color:#ff0000;">%s</div>]],1,giftname[index], str );
	elseif(index==2)then
		s = string.format([[累计在线%d分钟可获得奖励<br/>【%s】<div style="margin-left:90px;color:#ff0000;">%s</div>]], 30, giftname[index], str );
	elseif(index==3)then
		s = string.format([[累计在线%d分钟可获得奖励<br/>【%s】<div style="margin-left:90px;color:#ff0000;">%s</div>]], 60, giftname[index], str );
	elseif(index==4)then
		s = string.format([[累计在线%d分钟可获得奖励<br/>【%s】<div style="margin-left:90px;color:#ff0000;">%s</div>]], 90, giftname[index], str );
	elseif(index==5)then
		s = string.format([[累计在线%d分钟可获得奖励<br/>【%s】<div style="margin-left:90px;color:#ff0000;">%s</div>]], 120, giftname[index], str );
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
	
	--local giftname="金币";
--
	--if (VIPlvl>=1) then
		--vipstr=string.format("%s奖励【%sx10】<br/>（目前仅开放了%s 1级的额外奖励, 更高等级尚未开放，敬请期待）<br/><font color='#ff0000'>%s</font>", vipname,giftname,vipname,str);
	--else
		--vipstr=string.format("%s奖励【%sx10】<br/>（目前仅开放了%s 1级的额外奖励, 更高等级尚未开放，敬请期待）<br/><font color='#ff0000'>可惜你未拥有%s!</font>", vipname,giftname,vipname,vipname);
	--end
	--return string.format("page://script/apps/Aries/Service/CommonTooltip.html?s=%s",vipstr);	
	return string.format("page://script/apps/Aries/Service/CommonTooltip.html?s=%s",str);
end

function MiJiuHuLu.GetRemainTime()
	if(MiJiuHuLu.onlinetime)then
		if( MiJiuHuLu.onlinetime < 1*60)then
			return math.ceil( (1*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 30*60)then
			return math.ceil( (30*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 60*60)then
			return math.ceil( (60*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 90*60)then
			return math.ceil( (90*60 - MiJiuHuLu.onlinetime)/60);
		elseif(MiJiuHuLu.onlinetime < 120*60)then
			return math.ceil( (120*60 - MiJiuHuLu.onlinetime)/60);
		else
			return nil;
		end
	end
end

function MiJiuHuLu.GetObtainAwardState(index)
	--commonlib.echo("=================GetObtainAwardState:   "..index)
	--commonlib.echo(MiJiuHuLu.onlinetime)

	local index = tonumber(index);
	local gsid,vipgsid=0,0;
	local chksecs;

	if (index>10) then
		_index = index -10;		
	else
		_index = index;
	end

	if (_index==1) then
		gsid=50321;
		vipgsid=50342;
		chksecs= 1*60;
	elseif (_index==2) then
		gsid=50322;
		vipgsid=50343;
		chksecs= 30*60;
	elseif (_index==3) then
		gsid=50323;
		vipgsid=50344;
		chksecs= 60*60;
	elseif (_index==4) then
		gsid=50324;
		vipgsid=50345;
		chksecs= 90*60;
	elseif (_index==5) then
		gsid=50341;
		vipgsid=50346;
		chksecs= 120*60;
	end
	
	local obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid);

	if (obtain and obtain.inday>=1) then--已经领取过
		if(VIPlvl>=1) then
			local _id = ItemManager.GetGSObtainCntInTimeSpanInMemory(vipgsid);			
			if (_id.inday==0 and MiJiuHuLu.onlinetime>=chksecs) then				
				return 4;
			else				
				return 1;
			end
		else			
			return 5;
		end
	elseif(MiJiuHuLu.onlinetime and MiJiuHuLu.onlinetime >= chksecs)then--没领取但可以领取		
		return 2;
	else--没达到领取条件		
		return 3;
	end
end

function MiJiuHuLu.OnClickAward(index)
	local index= tonumber(index);
	local WorldServerName = commonlib.getfield("MyCompany.Aries.WorldServerName") or "";
	local _chk = {
		{chktime=1*60,gsid=50321,vipgsid=50342},
		{chktime=30*60,gsid=50322,vipgsid=50343},
		{chktime=60*60,gsid=50323,vipgsid=50344},
		{chktime=90*60,gsid=50324,vipgsid=50345},
		{chktime=120*60,gsid=50341,vipgsid=50346},
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

	if (index>10) then
		_id = ItemManager.GetGSObtainCntInTimeSpanInMemory(_chk[_index].vipgsid);
	end

	if (_id.inday) then
		if (_id.inday==0) then
			if (not LinksAreaPage.InitFlashMiJiuHuLu) then
				LinksAreaPage.InitFlashMiJiuHuLu = true;
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
	elseif (index==11) then
		_exid = 1801;
	elseif (index==12) then
		_exid = 1807;
	elseif (index==13) then
		_exid = 1808;
	elseif (index==14) then
		_exid = 1809;
	elseif (index==15) then
		_exid = 1810;
	end

	ItemManager.ExtendedCost( _exid, nil, nil, function(msg)end, function(msg)
		if(msg and msg.issuccess == true)then
			MiJiuHuLu.UpdataTime(MiJiuHuLu.onlinetime * 1000,true);	

			local exp,_ = MyCompany.Aries.Desktop.EXPArea.GetEXP();
			local nid = System.App.profiles.ProfileManager.GetNID();
			paraworld.PostLog({action = "mijiuhulu_getaward", nid=nid,exp=exp,index=index}, 
					"mijiuhulu_getaward_log", function(msg)end);
		else
			if (msg.errorcode==428) then
				_guihelper.MessageBox("这个精灵礼包你已经领过了！");
			else
				_guihelper.MessageBox("这个精灵礼包出问题了，快去报告青龙！");
			end
		end
		if(callbackFunc)then
			callbackFunc(msg);
		end
	end,"purchase",true,nil,2000,function(msg)
		_guihelper.MessageBox("这个精灵礼包超时了，再领一次吧！");
	end);

end
