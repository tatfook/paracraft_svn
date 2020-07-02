--[[
Title: code behind for page MagicMoneyBox.teen.html
Author(s): Spring
Date: 2012/3/18
Desc:  script/apps/Aries/NPCs/MagicMoneyBox/MagicMoneyBox.teen.lua
Use Lib:
NPL.load("(gl)script/apps/Aries/NPCs/MagicMoneyBox/MagicMoneyBox.teen.lua");
-------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/VIP/main.lua");

local MagicMoneyBox = commonlib.gettable("MyCompany.Aries.Quest.NPCs.MagicMoneyBox");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function MagicMoneyBox.GetEmoney(page)
  local s,mlel="",1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		if (bean.mlel) then
			mlel=bean.mlel;
		end
	end

	local bVIP=VIP.IsVIP();
	if (bVIP) then
		local AddbeanCount;
		if (mlel <= 10) then 
			AddbeanCount =mlel*5000;
		--else
			--AddbeanCount =(mlel-5)*1000;
		end
		local DailyJoybean_gsid = 50316;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(DailyJoybean_gsid);
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(DailyJoybean_gsid);
		if(gsItem and gsObtain) then
			if(gsObtain.inday == 0) then
				s=string.format("这是魔法星今天为你存下的%s银币。",AddbeanCount);
				local _exid=490+mlel;
				ItemManager.ExtendedCost(_exid, nil, nil, function(msg)
					commonlib.echo("============MagicStar GetEmoney======");
					--commonlib.echo(msg);
					if (msg) then
						if(msg.issuccess == true) then
							local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
							ChatChannel.AppendChat({
										ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
										fromname = "", 
										fromschool = classprop_gsid, 
										fromisvip = false, 
										words = string.format("你获得了: %s银币。",AddbeanCount),
										is_direct_mcml = true,
										bHideSubject = true,
										bHideTooltip = true,
										bHideColon = true,
									});
							--银币动画
							NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
							local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
							DockTip.GetInstance():PushGsid(0);
							local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
							Dock.RefreshPage();
							_guihelper.Custom_MessageBox(s,function(result)	
								if (page) then
									page:CloseWindow();	
								end
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
						elseif (msg.errorcode==429) then
							s="你今天已经取出魔法储蓄罐中的银币了，不要太贪心哦。";
	  						_guihelper.Custom_MessageBox(s,function(result)			
								if (page) then
									page:CloseWindow();	
								end
								end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
						else
							local s="网络出现问题，请重新领取银币！"
							_guihelper.Custom_MessageBox(s,function(result)											
								end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
							return;
						end
					else
						local s="网络出现问题，请重新领取银币！"
						_guihelper.Custom_MessageBox(s,function(result)			
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
						return;
					end
				end, function(msg) end, "none");
			else
				s="你今天已经取出魔法储蓄罐中的银币了，不要太贪心哦。";
	  			_guihelper.Custom_MessageBox(s,function(result)		
					if (page) then	
						page:CloseWindow();	
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
			end
		end        
	else
	    s="你的还没有拥有魔法星，不能从魔法储蓄罐中取出银币。用能量石赶快点亮魔法星吧！"
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then		
					local gsid=998;
					Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/GotMagicStone_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"},12);
	end;
end
