--[[
Title: Push unreceived gifts to NPC tip stack
Author(s): LiXizhi
Date: 2012/9/27
Desc: Push unreceived gifts to NPC tip stack
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTips_GiftBox.lua");
local NPCTips_GiftBox = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTips_GiftBox");
NPCTips_GiftBox.TryPushGifts();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.lua");
local NPCTipsPage = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTipsPage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

local NPCTips_GiftBox = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTips_GiftBox");

local npc_tips = {
	-- uncomment this to enable. 
	-- ["old_user_gift_2012_10_1"] = {title="老用户大礼包",npc_icon="Texture/Aries/NPCs/Portrait/Gift_GiftPackage_32bits.png", url="script/apps/Aries/Desktop/NotificationArea/NPCTips_GiftBox.kids.html?gsid=17275", }, -- width=640, height=480, 
	--["new_user_levelup_gift_2012_12_7"] = {title="新人成长礼包", has_action=true, [1]= [[
--欢迎加入新人成长计划! <br/>
--登录<a href='http://haqi.61.com/webplayer/kidslauncher/haqi_activity20121204.html'>哈奇活动页(点击进入)</a>, 领取激活码, 然后找我兑换海量经验与装备！]], 
			--type="shop", npcid=30530, npc_icon="Texture/Aries/NPCs/Portrait/Gift_GiftPackage_32bits.png", }, -- width=640, height=480, 
	["lucky_lottery"] = {title="幸运卡牌大乐透",has_action=true, type="lucky_lottery", npc_icon="Texture/Aries/NPCs/Portrait/Gift_GiftPackage_32bits.png", [1] = "你今天还有一次免费参加幸运卡牌大乐透的机会哦，100%能获得各种神奇的宝贝，机不可失，赶紧去看看吧！",},
}
function NPCTips_GiftBox.TryPushGifts()
	if(System.options.version == "kids") then
		if(npc_tips["lucky_lottery"]) then
			local has_free_lottery;
			local obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50375);
			if (obtain and obtain.inday==0) then
				has_free_lottery = true;
			end
			local obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50376);
			if (obtain and obtain.inday==0) then
				has_free_lottery = true;
			end
			local myCombatLevel = Player.GetLevel();
			if(myCombatLevel > 11) then
				if(has_free_lottery) then
					local tip = npc_tips["lucky_lottery"];
					if(tip and not tip.is_shown) then
						NPCTipsPage.PushTip(npc_tips["lucky_lottery"]);
					end
				end
			end
		end
		if(npc_tips["new_user_levelup_gift_2012_12_7"]) then
			local myCombatLevel = Player.GetLevel();
			if(myCombatLevel < 45) then
				local bHas = hasGSItem(50349);
				if(not bHas) then
					local tip = npc_tips["new_user_levelup_gift_2012_12_7"];
					if(tip and not tip.is_shown) then
						NPCTipsPage.PushTip(npc_tips["new_user_levelup_gift_2012_12_7"]);
					end
				end
			end
		elseif(npc_tips["old_user_gift_2012_10_1"]) then
			local myCombatLevel = Player.GetLevel();
			if(myCombatLevel > 45) then
				local bHas = hasGSItem(50347);
				if(not bHas) then
					bHas = hasGSItem(17275);
					if(bHas) then
						-- NPCTipsPage.PushTip({title="老用户大礼包",npc_icon="Texture/Aries/NPCs/Portrait/Gift_GiftPackage_32bits.png", title="你的国庆大礼包还没有打开" });
					else
						local tip = npc_tips["old_user_gift_2012_10_1"];
						if(tip and not tip.is_shown) then
							NPCTipsPage.PushTip(npc_tips["old_user_gift_2012_10_1"]);
						end
					end
				end
			end
		end
	end
end

