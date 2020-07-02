--[[
Title: code behind for page PurchaseEnergyStone.html
Author(s): Spring
Date: 2010/10/18
Desc:  script/apps/Aries/VIP/PurChaseEnergyStone.lua
Use Lib:
NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");
-------------------------------------------------------
-------------------------------------------------------
]]
local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local item_name, item_gsid;
local pageCtrl;

function PurchaseEnergyStone.OnInit()
	pageCtrl = document:GetPageCtrl();
	PurchaseEnergyStone.timer = timer or commonlib.Timer:new({callbackFunc = function(timer)
		PurchaseEnergyStone.CheckCount(item_name, item_gsid)
	end})
end

function PurchaseEnergyStone.StartTimer(name, gsid)
	item_name, item_gsid = name, gsid;
	PurchaseEnergyStone.timer:Change(0,30);
end

function PurchaseEnergyStone.StopTimer()
	PurchaseEnergyStone.timer:Change();
end

PurchaseEnergyStone.lastValidValue = "3";
function PurchaseEnergyStone.CheckCount(name, gsid)
	local ctl = CommonCtrl.GetControl(name);
	if(ctl) then
		local init_value = ctl:GetValue("count");
		local value = init_value;
		if(value) then
			if(string.match(value, "([^%d]+)")) then
				value = PurchaseEnergyStone.lastValidValue;
			elseif(value == "") then
				value = PurchaseEnergyStone.lastValidValue;
			else
				local count = tonumber(value);
				if(count > 99) then
					value = "99";
				elseif(count < 1) then
					value = "3";
				else
					value = tostring(tonumber(value));
				end
			end
		else
			value = "3";
		end
		
		-- record the last valid count value and refresh the control is needed
		PurchaseEnergyStone.lastValidValue = value;
		if(init_value ~= value) then
			ctl:SetValue("count", tostring(value));
		end
		local count=tonumber(value);
		local s = string.format("%d个能量石需要%d%s，你确认要购买吗？",count,count*10,MyCompany.Aries.ExternalUserModule:GetConfig().currency_name);
		ctl:SetValue("buydesc", s);
	end
end

function PurchaseEnergyStone.Show()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/VIP/PurChaseEnergyStone.html", 
		name = "PurChaseEnergyStone", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 10,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -466/2,
			y = -355/2,
			width = 466,
			height = 355,
		});
end

function PurchaseEnergyStone.BuyEnergyStone()
	NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
	local PurchaseMagicBean = MyCompany.Aries.Inventory.PurChaseMagicBean;

    local count = pageCtrl:GetValue("count");
    count = tonumber(count);
    local passwd = pageCtrl:GetValue("passwd");
    local tonid=System.App.profiles.ProfileManager.GetNID();
	local errormsg={
		[424]="本次支付失败！你已经购买了太多的能量石！",
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
                        -- ParaGlobal.ShellExecute("open", "http://pay.61.com/account/pwd", "", "", 1);
				    end
		    end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/paypasswd_set.png; 0 0 153 49"},12);
        else
            if(count and count >= 1 and count <= 99) then
				local gsid=998;
	            ItemManager.BuyWithRMB(tonid, gsid, count, passwd, function(msg)
		            if(msg) then
			            log("+++++++Purchase energyStone return: #"..tostring(gsid).." count: "..tostring(count).." +++++++\n")
			            commonlib.echo(msg);
			            if (msg.issuccess) then
                            local s=string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已成功购买 %d 颗能量石!快快用它给魔法星补充能量吧！</div>",count);
	                        _guihelper.Custom_MessageBox(s,function(result)	
                                if(result == _guihelper.DialogResult.Yes)then
                                    -- 弹出魔法星资料窗口
						            NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
						            local CombatCharacterFrame = commonlib.gettable("MyCompany.Aries.Desktop.CombatCharacterFrame");
						            if (CombatCharacterFrame) then
							            CombatCharacterFrame.ShowMainWnd(5);
						            end
                                end
	                            end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/MapHelp/MagicStarHelp/useEnergy.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"},12);
                            MyCompany.Aries.Desktop.Dock.OnPurchaseNotification(gsid, count);
                            ItemPage.StopTimer();
                            pageCtrl:CloseWindow();
			            else                       
                            local s=errormsg[msg.errorcode];
                            if (msg.errorcode==411 or msg.errorcode==439 or msg.errorcode==440) then
		                        _guihelper.Custom_MessageBox(s,function(result)
				                        if(result == _guihelper.DialogResult.No)then		
											PurchaseMagicBean.Pay("recharge");
                                         --   ParaGlobal.ShellExecute("open", "http://pay.61.com/buy/paytype?type=cardpay", "", "", 1);
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