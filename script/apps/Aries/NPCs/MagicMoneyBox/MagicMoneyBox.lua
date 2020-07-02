--[[
Title: code behind for page MagicMoneyBox.html
Author(s): Spring
Date: 2010/10/18
Desc:  script/apps/Aries/VIP/MagicMoneyBox.lua
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/MagicMoneyBox/MagicMoneyBox.lua");
local MagicMoneyBox = commonlib.gettable("MyCompany.Aries.Quest.NPCs.MagicMoneyBox");
MagicMoneyBox.CanGetMoney()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/VIP/main.lua");

local MagicMoneyBox = commonlib.gettable("MyCompany.Aries.Quest.NPCs.MagicMoneyBox");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function MagicMoneyBox.CanGetMoney()
	local s,mlel="",1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		if (bean.mlel) then
			mlel=bean.mlel;
		end
	end
	local bVIP=VIP.IsVIP();
    if (bVIP) then
		local AddbeanCount=(mlel+4)*1000;
        local WeeklyJoybean_gsid = 50316;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(WeeklyJoybean_gsid);
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(WeeklyJoybean_gsid);
		if(gsItem and gsObtain) then
			local remainingWeekCount = (gsItem.maxweeklycount or 1) - (gsObtain.inweek or 0);
			if(remainingWeekCount > 0) then
				return true;
			end
		end
	end
end

function MagicMoneyBox.GetEmoney()
    local s,mlel="",1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		if (bean.mlel) then
			mlel=bean.mlel;
		end
	end
	local bVIP=VIP.IsVIP();
    if (bVIP) then
        local AddbeanCount=(mlel+4)*1000;
        local WeeklyJoybean_gsid = 50316;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(WeeklyJoybean_gsid);
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(WeeklyJoybean_gsid);
		if(gsItem and gsObtain) then
			local remainingWeekCount = (gsItem.maxweeklycount or 1) - (gsObtain.inweek or 0);
			if(remainingWeekCount > 0) then
				local exid = 1658; -- 598
                ItemManager.ExtendedCost(exid, nil, nil, function(msg)
					--commonlib.echo("============MagicStar GetEmoney======");
					--commonlib.echo(msg);
                    if(msg and msg.issuccess == true) then
						if(msg.obtains) then
							-- 17213_GodBean
							local count = msg.obtains[17213];
							if(count) then
								s = string.format("这是魔法星本周为你存下的%s仙豆。", tostring(count));
    							_guihelper.Custom_MessageBox(s,function(result)			
									end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
							end
						end
					else
						local s="网络出现问题，请重新领取仙豆！"
    					_guihelper.Custom_MessageBox(s,function(result)			
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
						return;
                    end
	            end, function(msg) end, "none");
			else
				s="你本周已经取出魔法储蓄罐中的仙豆了，不要太贪心哦。";
    			_guihelper.Custom_MessageBox(s,function(result)			
					end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"},12);
			end
		end        
    else
		ItemManager.UseOrBuy_EnergyStone(nil,function(msg) return "非魔法星用户不能领取仙豆。<br/>" end);
        --s="你的魔法星能量值为0，失去魔法了，不能从魔法储蓄罐中取出仙豆了。小哈奇用能量石赶快给魔法星补充能量吧！"
		--_guihelper.Custom_MessageBox(s,function(result)
				--if(result == _guihelper.DialogResult.No)then		
					----NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");
					----local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");
					----PurchaseEnergyStone.Show();
					--local gsid=998;
					--Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
				--end
		--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/getstone_btn_32bits.png; 0 0 153 49"},12);
    end;
end

