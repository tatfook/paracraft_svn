--[[
Title: code behind for page PurchaseMagicBean.teen.html
Author(s): Spring
Date: 2012/4/6
Desc:  script/apps/Aries/VIP/PurChaseMagicBean.teen.lua
Use Lib:
NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.teen.lua");
-------------------------------------------------------
-------------------------------------------------------
]]
local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
local ItemManager = System.Item.ItemManager;
local item_name, item_gsid;
local pageCtrl;

NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

function PurchaseMagicBean.OnInit()
	pageCtrl = document:GetPageCtrl();
	PurchaseMagicBean.timer = timer or commonlib.Timer:new({callbackFunc = function(timer)
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
		local s = string.format("%d个金币需要%d%s，你确认要购买吗？",count,count*0.1,MyCompany.Aries.ExternalUserModule:GetConfig().currency_name);
		ctl:SetValue("buydesc", s);
	end
end

function PurchaseMagicBean.Show()
	--_guihelper.MessageBox("封测期间，暂不开放兑金币！");
	
	local region_id = ExternalUserModule:GetRegionID();
	
	if (System.options.locale=="zhCN") then
		if (region_id==0 or region_id==7) then  -- taomee or keepwork
			local params = {
				url = "script/apps/Aries/Desktop/Functions/RechargeGuide.teen.html", 
				name = "OnPayGuide", 
				enable_esc_key = true,
				isShowTitleBar = false,
				app_key = MyCompany.Aries.app.app_key, 
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder=1,
				isTopLevel = true,
				is_click_to_close = true,
				directPosition = true,
					align = "_ct",
					x = -250,
					y = - 150,
					width = 500,
					height = 300,
			};
			System.App.Commands.Call("File.MCMLWindowFrame", params);
		elseif (region_id==2) then   -- kuaiwan	
			PurchaseMagicBean.WebPay()
		end
	else
		PurchaseMagicBean.WebPay()
	end
end

function PurchaseMagicBean.BuyMagicBean()

    local count = pageCtrl:GetValue("count");
    count = tonumber(count);
    local passwd = pageCtrl:GetValue("passwd");
    local tonid=System.App.profiles.ProfileManager.GetNID();
	local errormsg={
		[424]="本次支付失败！你已经购买了太多的金币！",
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
				    if(result == _guihelper.DialogResult.No)then	
						PurchaseMagicBean.Pay("setpaypasswd");			                        
				    end
		    end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/paypasswd_set.png; 0 0 153 49"},12);
        else
            if(count and count >= 10 and count <= 2000) then
				local gsid=984;
	            ItemManager.BuyWithRMB(tonid, gsid, count, passwd, function(msg)
		            if(msg) then
			            log("+++++++Purchase energyStone return: #"..tostring(gsid).." count: "..tostring(count).." +++++++\n")
			            commonlib.echo(msg);
			            if (msg.issuccess) then
							local s;
							s=string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已成功购买 %d 个金币!快快用它去VIP商店买你喜欢的东西吧！</div>",count);
                            
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
	PurchaseMagicBean.RefreshBag0();
end

function PurchaseMagicBean.Pay(type)
	--local payurl = string.format("http://192.168.0.51:85/cgi-bin/test_pay.pl?nid=%s",System.User.nid);
	--ParaGlobal.ShellExecute("open", payurl, "", "", 1);

	local region_id = ExternalUserModule:GetRegionID();
	local cfg = ExternalUserModule:GetConfig();
	local url_recharge= cfg.recharge_url;
	local url_pay= cfg.pay_url;
	if (System.options.locale == "zhCN") then
		if (region_id==0) then  -- taomee
			local url0="";
			if (type=="setpaypasswd") then
				url0 = "http://pay.61.com/account/pwd?game=haqi";
			elseif (type=="recharge") then
				url0 = url_recharge;
			elseif (type=="buybean_onweb") then
				url0 = url_pay;
			end
			if (string.len(url0)>0) then
				if(false) then
					paraworld.auth.AuthUser({
						username = System.User.username,
						password = System.User.Password,
						}, "login", function (msg)
						if(msg.issuccess) then	
							-- successfully recovered from connection. 
	--						LOG.std("", "system","Login", "Successfully authenticated for pay");
							local payurl = string.format("%s&userid=%d&session=%s&gameid=29",url0,msg.nid,msg.sessionid);
							ParaGlobal.ShellExecute("open", payurl, "", "", 1);
							PurchaseMagicBean.RefreshBag0();
						end
					end, nil, 20000, function(msg)	end);	
				else
					local payurl = string.format("%s&userid=%s&gameid=29",url0,tostring(System.User.nid or ""));
					ParaGlobal.ShellExecute("open", payurl, "", "", 1);
					PurchaseMagicBean.RefreshBag0();
				end
			end
		elseif (region_id==2) then -- kuaiwan
			local url0="";
			if (type=="recharge") then
				url0 = url_recharge .."&online_token";
			elseif (type=="buybean_onweb") then
				url0 = url_pay .."&online_token";
			end
			if (string.len(url0)>0) then
				paraworld.auth.AuthUser({
					username = System.User.username,
					password = System.User.Password,
					}, "login", function (msg)
					if(msg.issuccess) then	
						-- successfully recovered from connection. 
--						LOG.std("", "system","Login", "Successfully authenticated for pay");
						local payurl = string.format("%s=%s",url0,msg.sessionid);
						ParaGlobal.ShellExecute("open", payurl, "", "", 1);
						PurchaseMagicBean.RefreshBag0();
					end
				end, nil, 20000, function(msg)	end);
			end	
		end
	else
		local payurl;
		if (System.options.locale == "zhTW") then
			payurl = string.format("%s/?uid=%s&nid=%s",url_pay,System.options.login_tokens.oid,Map3DSystem.User.nid);
		end
		ParaGlobal.ShellExecute("open", payurl, "", "", 1);
		PurchaseMagicBean.RefreshBag0();
	end
end

function PurchaseMagicBean.RefreshBag0()
	local s = string.format("<div style='margin-left:5px;margin-top:5px;text-align:left'>充值网页即将打开, 充值完成后点击 [确定]，刷新金币数量。或者退出游戏，再登录，查看当前金币数量。</div>");
	_guihelper.Custom_MessageBox(s,function(result)
		ItemManager.GetItemsInBag(0, "ariesitems_0", function(msg)
			end, "access plus 0 minutes");		
	end,_guihelper.MessageBoxButtons.OK,nil, nil, true);
end