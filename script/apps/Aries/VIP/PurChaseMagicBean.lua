--[[
Title: code behind for page PurchaseMagicBean.html
Author(s): Spring
Date: 2010/12/10
Desc:  script/apps/Aries/VIP/PurChaseMagicBean.lua
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
commonlib.setfield("MyCompany.Aries.Inventory.PurchaseMagicBean", PurchaseMagicBean);

local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local item_name, item_gsid;
local pageCtrl;

NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

function PurchaseMagicBean.OnInit()
	pageCtrl = document:GetPageCtrl();
	PurchaseMagicBean.timer = PurchaseMagicBean.timer or commonlib.Timer:new({callbackFunc = function(timer)
		PurchaseMagicBean.CheckCount(item_name, item_gsid)
	end})
end

function PurchaseMagicBean.StartTimer(name, gsid)
	item_name, item_gsid = name, gsid;
	PurchaseMagicBean.timer:Change(0,30);
end

function PurchaseMagicBean.StopTimer()
	PurchaseMagicBean.timer:Change();
end

PurchaseMagicBean.lastValidValue = "3";
function PurchaseMagicBean.CheckCount(name, gsid)
	local ctl = CommonCtrl.GetControl(name);
	if(ctl) then
		local init_value = ctl:GetValue("count");
		local value = init_value;
		if(value) then
			if(string.match(value, "([^%d]+)")) then
				value = PurchaseMagicBean.lastValidValue;
			elseif(value == "") then
				value = PurchaseMagicBean.lastValidValue;
			else
				local count = tonumber(value);
				if(count > 1000) then
					value = "1000";
				elseif(count <10) then
					value = "300";
				else
					value = tostring(tonumber(value));
				end
			end
		else
			value = "300";
		end
		
		-- record the last valid count value and refresh the control is needed
		PurchaseMagicBean.lastValidValue = value;
		if(init_value ~= value) then
			ctl:SetValue("count", tostring(value));
		end
		local count=tonumber(value);
		local s = string.format("%d个魔豆需要%d%s，你确认要购买吗？",count,count*0.1,MyCompany.Aries.ExternalUserModule:GetConfig().currency_name);
		ctl:SetValue("buydesc", s);
	end
end

-- @ctype: pay or guide for kids version
function PurchaseMagicBean.Show(ctype)
	local region_id = ExternalUserModule:GetRegionID();

	if (region_id==0) then  -- taomee
		commonlib.echo("============== PurchaseMagicBean")
		
		--if (not ctype or hasGSItem(984)) then
			--PurchaseMagicBean.tab_type = "pay";
		--else
			--PurchaseMagicBean.tab_type = ctype;
		--end
		PurchaseMagicBean.tab_type = ctype or "guide";

		local params = {
			url = "script/apps/Aries/VIP/PurChaseMagicBean.html", 
			name = "PurChaseMagicBean", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -560/2,
				y = -320/2,
				width = 560,
				height = 320,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);

		params._page.OnClose = function()
			PurchaseMagicBean.StopTimer();
		end

	else -- if (region_id==2) then  -- kuaiwan
		PurchaseMagicBean.WebPay()
	end
end

function PurchaseMagicBean.BuyMagicBean()

    local count = pageCtrl:GetValue("count");
    count = tonumber(count);
    local passwd = pageCtrl:GetValue("passwd");
    local tonid=System.App.profiles.ProfileManager.GetNID();
	local errormsg={
		[424]="本次支付失败！你已经购买了太多的魔豆！",
		[411]=string.format("本次支付失败！你的%s不够哦，快去充值吧！",MyCompany.Aries.ExternalUserModule:GetConfig().currency_name),
		[439]=string.format("本次支付失败！你没有%s帐户哦，快去开通充值吧！",MyCompany.Aries.ExternalUserModule:GetConfig().currency_name),
		[440]=string.format("本次支付失败！你的%s帐户没有激活哦，快去激活吧！",MyCompany.Aries.ExternalUserModule:GetConfig().currency_name),
		[441]=string.format("本次支付失败！你这个月已经花了太多%s了，下个月再买吧！好孩子要节省哦！",MyCompany.Aries.ExternalUserModule:GetConfig().currency_name),
		[442]=string.format("本次支付失败！你这次花的%s太多了，减点数量吧！",MyCompany.Aries.ExternalUserModule:GetConfig().currency_name),
		[500]="本次支付失败！网络原因导致购买失败，请稍候再试！",
		[499]="本次支付失败！请重试一次！",
		[420]="本次支付失败！支付密码错误，请重试一次！",
		[497]="本次支付失败！请重试一次！",
		[419]="本次支付失败！请重试一次！",			    	
		}

    if (string.len(passwd)>32) then
        local s="你输入的支付密码太长了，请重新输入！"
	    _guihelper.Custom_MessageBox(s,function(result)			
	        end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
	else
        if (string.len(passwd)==0) then
            local s="请先输入支付密码，如果你还没有支付密码，请先设置哦！"
		    _guihelper.Custom_MessageBox(s,function(result)
				    if(result == _guihelper.DialogResult.Yes)then
						PurchaseMagicBean.Pay("setpaypasswd");
					else
						PurchaseMagicBean.WebPay();		                        
				    end
		    end,_guihelper.MessageBoxButtons.YesNo,{no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", yes = "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/paypasswd_set.png; 0 0 153 49"},12);
        else
            if(count and count >= 10 and count <= 2000) then
				local gsid=984;
	            ItemManager.BuyWithRMB(tonid, gsid, count, passwd, function(msg)
		            if(msg) then
			            --log("+++++++Purchase energyStone return: #"..tostring(gsid).." count: "..tostring(count).." +++++++\n")
			            --commonlib.echo(msg);
			            if (msg.issuccess) then
							local s;
							--if (count==300) then
								--s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已成功购买 %d 个魔豆!本次充值获得的礼品是：1个能量石 1个面包棒 1个黄金飞马</div>",count);
							--elseif (count==1000) then
								--s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已成功购买 %d 个魔豆!本次充值获得的礼品是：3个能量石 3个面包棒 1个霸王虎 1个顶级宝石镶嵌符</div>",count);
							--else
								s=string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已成功购买 %d 个魔豆!快快用它去商城买你喜欢的东西吧！</div>",count);
							--end
                            
	                        _guihelper.Custom_MessageBox(s,function(result)	
	                            end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
							MyCompany.Aries.Desktop.Dock.OnExtendedCostNotification(msg);
                            --MyCompany.Aries.Desktop.Dock.OnPurchaseNotification(gsid, count);
                            ItemPage.StopTimer();
                            pageCtrl:CloseWindow();
			            else                       
                            local s=errormsg[msg.errorcode];
                            if (msg.errorcode==411 or msg.errorcode==439 or msg.errorcode==440) then
		                        _guihelper.Custom_MessageBox(s,function(result)
				                        if(result == _guihelper.DialogResult.No)then		
											PurchaseMagicBean.Pay("recharge");
				                        end
		                        end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/getEmoney_btn_32bits.png; 0 0 153 49"},12);
                                ItemPage.StopTimer();
                                pageCtrl:CloseWindow();
                            else
                                _guihelper.Custom_MessageBox(s,function(result)			
	                                end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
                                return;
                            end;
			            end;
		            end
	            end, 10000, function () 
                    -- 如果超时，则返回 500 错误
                    local s=errormsg[500];
                    _guihelper.Custom_MessageBox(s,function(result)			
	                    end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
                    return;
                end);
            end
        end
    end
end

function PurchaseMagicBean.SetPayPasswd()
	PurchaseMagicBean.Pay("setpaypasswd");
end

function PurchaseMagicBean.WebPay()
	PurchaseMagicBean.Pay("buybean_onweb");
end

function PurchaseMagicBean.Pay(ctype)
	local region_id = ExternalUserModule:GetRegionID();
	local cfg = ExternalUserModule:GetConfig();
	local url_recharge= cfg.recharge_url;
	local url_pay= cfg.pay_url;

	if (region_id==0) then  -- taomee
		local url0="";
		if (ctype=="setpaypasswd") then
			url0 = "http://pay.61.com/account/pwd?game=haqi&";
		elseif (ctype=="recharge") then
			url0 = url_recharge;
		elseif (ctype=="buybean_onweb") then
			url0 = url_pay;
		end
		
		if (string.len(url0)>0) then
			local inputmsg={
				username = tostring(System.User.username), 
				password = System.User.Password,
				valicode = UserLoginProcess.last_veri_code or "",
				sessionid = System.User.sessionid or "",
			};		
			paraworld.auth.AuthUser(inputmsg, "login", function (msg)
				if(msg.issuccess) then	
					-- successfully recovered from connection. 
					LOG.std("", "system","Login", "Successfully authenticated for pay");
					local payurl = string.format("%suserid=%d&session=%s&gameid=21",url0,msg.nid,msg.sessionid);
					ParaGlobal.ShellExecute("open", payurl, "", "", 1);
					if (ctype~="setpaypasswd") then
						PurchaseMagicBean.RefreshBag0()
					end
				else
					if (msg.valibmp) then
						System.User.params=ctype;
						System.User.sessionid = msg.sessionid;
						Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();									
						UserLoginProcess.SavImg(msg.errorcode,msg.valibmp,msg.sessionid,"pay");
						return
					end				
				end
			end, nil, 20000, function(msg)	end);	
		end
	elseif (region_id==2) then -- kuaiwan
		local url0="";
		if (ctype=="recharge") then
			url0 = url_recharge .."&online_token";
		elseif (ctype=="buybean_onweb") then
			url0 = url_pay .."&online_token";
		end
		--commonlib.echo("===========kuaiwan pay");
		--commonlib.echo(System.User.username .. "|" .. url0);

		if (string.len(url0)>0) then
			paraworld.auth.AuthUser({
				username = System.User.username,
				password = System.User.Password,
				}, "login", function (msg)
				if(msg.issuccess) then	
					-- successfully recovered from connection. 
					LOG.std("", "system","Login", "Successfully authenticated for pay");
					local payurl = string.format("%s=%s",url0,msg.sessionid);
					ParaGlobal.ShellExecute("open", payurl, "", "", 1);
					PurchaseMagicBean.RefreshBag0()
				end
			end, nil, 20000, function(msg)	end);
		end	
    elseif(region_id == 7)then --keepwork
        	PurchaseMagicBean.PayKeepWork();
	else
		ParaGlobal.ShellExecute("open", url_pay, "", "", 1);
	end
end
function PurchaseMagicBean.PayKeepWork()
	if(System.options.isFromQQHall) then
		_guihelper.MessageBox("暂时不提供直接充值。通过学习Paracraft编程可以获得游戏币");
		return;
	end
    local username = System.User.username;  
	local password = System.User.Password;

	local oid = System.User.oid;
	local nid = tostring(System.User.nid);
    local price = 30;
    local additional = string.format([[{"user_nid":%s}]],nid);
    additional = Encoding.url_encode(additional)
	local payurl = string.format([[https://keepwork.com/a/orderConfirm?type=1&payment=rmb&app_name=魔法哈奇&goodsId=984&username=%s&price=%d&user_nid=%s]],oid,price,nid);
	if(System.User.keepworktoken) then
		payurl = format("%s&token=%s", payurl, System.User.keepworktoken);
	end
    payurl = Encoding.Utf8ToDefault(payurl)
	if(true) then
		ParaGlobal.ShellExecute("open", payurl, "", "", 1);
		PurchaseMagicBean.RefreshBag0()
	else
		paraworld.auth.AuthUser({
			username = username,
			password = password,
			}, "login", function (msg)
			if(msg.issuccess) then	
				-- successfully recovered from connection. 
				LOG.std("", "system","Login", "Successfully authenticated for pay");
				ParaGlobal.ShellExecute("open", payurl, "", "", 1);
				PurchaseMagicBean.RefreshBag0()
			end
		end, nil, 20000, function(msg)	end);
	end
end
--打开指定的支付页面
function PurchaseMagicBean.SetPage(ctype)
	local self = PurchaseMagicBean;
	if(PurchaseMagicBean)then
		PurchaseMagicBean.tab_type = ctype;
		if(pageCtrl)then
			pageCtrl:Refresh(0.01);
		end
	end
end

function PurchaseMagicBean.RefreshBag0()
	local s = string.format("<div style='margin-left:5px;margin-top:5px;text-align:left'>充值网页即将打开, 充值完成后点击 [确定]，刷新魔豆数量。或者退出游戏，再登录，查看当前魔豆数量。</div>");
	_guihelper.Custom_MessageBox(s,function(result)
		ItemManager.GetItemsInBag(0, "ariesitems_0", function(msg)
			end, "access plus 0 minutes");		
	end,_guihelper.MessageBoxButtons.OK,nil, nil, true);
end