--[[
Title: GameSeries
Author(s): WangTian
Date: 2009/7/31

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/Game/GameSeries.lua
------------------------------------------------------------
]]

-- create class
local libName = "GameSeries";
local GameSeries = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GameSeries", GameSeries);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- GameSeries.main
function GameSeries.main()
end

--50037_WishHomeland1_Acquire
--50038_WishHomeland1_Complete
--50039_WishHomeland1_RewardFriendliness

-- 50141_WishHomeland1_Acquire

local questDesc = {
	{	acquire_gsid = 50171, 
		reward_gsid = 50123, 
		complete_exid = 73,
		title = "整理农场仓库",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            呼噜大叔不知道又跑哪睡觉去了，他的农场仓库好乱呀，我们去帮他整理整理吧!]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            这个爱打盹的呼噜大叔，一定以为他自己在梦里把仓库整理好了吧，我们的亲密度又长了3点，敏捷值也增加了1点哦。 ]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game1_status.html",
	}, -- 对对碰游戏
	{	acquire_gsid = 50172, 
		reward_gsid = 50123, 
		complete_exid = 74,
		title = "终止葱头菜头大战",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            跳跳农场的吵吵葱头和闹闹菜头打得不可开交，你快去制止它们吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哼哼，那对儿葱头菜头这下可吃苦头了，朋友之间应该团结友爱嘛，怎么能总是打架呢。这下我们的亲密度又加了3点，敏捷值也增加了1点哦。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game2_status.html",
	}, -- 葱头菜头
	{	acquire_gsid = 50173, 
		reward_gsid = 50123, 
		complete_exid = 75,
		title = "捡一朵七色花",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            七色花漂亮又美味，我们去捡一朵来吧，给我做菜的时候用的着呢。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            好漂亮的七色花啊，有空记得用它给我做菜哦。我们的亲密度又长了3点，敏捷值也增加了1点。开心！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game3_status.html",
	}, -- 七色花 
	{	acquire_gsid = 50174, 
		reward_gsid = 50123, 
		complete_exid = 76,
		title = "沙滩摘椰子",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            沙滩边有一片漂亮的椰树，我们一起去那里摘椰子吧。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            你真厉害，摘椰子都能上窜下跳的爬这么高！这下我们的亲密度又加了3点，敏捷值也增加了1点哦。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game4_status.html",
	}, -- 沙滩摘椰子 
	{	acquire_gsid = 50175, 
		reward_gsid = 50123, 
		complete_exid = 77,
		title = "鬼脸泡泡机",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            龙龙乐园旁边的鬼脸泡泡机好好玩，我也想去玩一下嘛，快带我去吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            鬼脸泡泡机真好玩，还能赚奇豆，我以后要经常来！这下我们的亲密度又加了3点，敏捷值也增加了1点哦。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game5_status.html",
	}, -- 鬼脸泡泡机 
	{	acquire_gsid = 50176, 
		reward_gsid = 50123, 
		complete_exid = 78,
		title = "去滚雪球咯",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            下雪啦，好多小动物都在雪地里开心的玩，我也想去滚雪球，快带我去吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            滚雪球真是太好玩啦，这下我们亲密度又增加了3点，敏捷值也增加了1点！以后经常来玩，听说雪球滚大了，还有可能获得冬菇呢！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game6_status.html",
	}, -- 滚雪球
	{	acquire_gsid = 50177, 
		reward_gsid = 50123, 
		complete_exid = 79,
		title = "去玩跳舞机咯",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哈奇们跳舞真是不亦乐乎呀，你也去跳舞机那里练练你的熟练度吧，我真想看到你成为舞蹈高手！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            舞蹈当然是练得越多越熟练呀，真开心看到你越玩越好，我们的亲密度又增加了3点，敏捷值也增加了1点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game7_status.html",
	}, -- 跳舞机
	{	acquire_gsid = 50178, 
		reward_gsid = 50123, 
		complete_exid = 80,
		title = "去玩雪山大挑战咯",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            白皑皑的雪山终于揭开了神秘的面纱，快去雪山脚下玩雪山大挑战吧，挑战无极限哦。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            雪山大挑战，挑战无极限，你真棒，我们的亲密度又增加了3点，敏捷值也增加了1点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game8_status.html",
	}, -- 雪山大挑战
	{	acquire_gsid = 50179, 
		reward_gsid = 0, 
		complete_exid = 81,
		title = "去玩趣味表情祖玛咯",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            星星游乐场终于开放了，里面太多好玩的东西了，我们先去玩一把趣味表情祖玛吧。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            真不错，这个游戏好好玩，我还增加了1点智力值呢。以后要多带我去玩呀。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game9_status.html",
	}, -- 趣味表情祖玛
	{	acquire_gsid = 50180, 
		reward_gsid = 0, 
		complete_exid = 82,
		title = "去玩眼力大比拼咯",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            购物街附近有个购物车，我们去看看，玩玩那个眼力大比拼吧，我相信你的眼力肯定很好。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哇，你的眼睛没有看花吧，观察力真不多，我还增加了1点力量值呢，以后要多多带我去玩哦。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Game/30011_Wish_Game10_status.html",
	}, -- 眼力大比拼
	
};
GameSeries.questDesc = questDesc;

GameSeries.InnerMCML = "null";

-- get acquire page url
function GameSeries.GetAcquirePageURL(id)
	if(id) then
		local desc = questDesc[id];
		return "script/apps/Aries/NPCs/Dragon/Game/Template_Acquire.html?id="..id;
	end
end

-- refresh quest status
function GameSeries.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	--local petLevel = 0;
	---- get pet level
	--local bean = MyCompany.Aries.Pet.GetBean();
	--if(bean) then
		--petLevel = bean.level or 0;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	local id = 1;
	for id = 1, #(questDesc) do
		local desc = questDesc[id];
		if(hasGSItem(desc.acquire_gsid)) then
			QuestArea.AppendQuestStatus(
				desc.status_page,
				"dragon", "", desc.title,  desc.acquire_gsid);
			GameSeries.RegisterHook(id);
		elseif(not hasGSItem(desc.acquire_gsid)) then
			QuestArea.DeleteQuestStatus(desc.status_page);
			GameSeries.UnregisterHook(id);
		end
	end
end

function GameSeries.CanAcquireQuest(id)
	local desc = questDesc[id];
	local acquire_gsid = desc.acquire_gsid;
	if(not hasGSItem(acquire_gsid)) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(acquire_gsid);
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(acquire_gsid);
		if(gsItem and gsObtain) then
			local remainingDailyCount = (gsItem.maxdailycount or 1000) - (gsObtain.inday or 0);
			if(remainingDailyCount > 0) then
				return true;
			end
		else
			return true;
		end
	end
	return false;
end

function GameSeries.AcquireQuest(id)
	local desc = questDesc[id];
	local acquire_gsid = desc.acquire_gsid;
	if(not hasGSItem(acquire_gsid)) then
		ItemManager.PurchaseItem(acquire_gsid, 1, function(msg) end, function(msg)
			if(msg) then
				local assetkey = "";
				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(acquire_gsid);
				if(gsItem) then
					assetkey = gsItem.assetfile;
				end
				log("+++++++Purchase "..assetkey.." return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended(GameSeries.GetAcquirePageURL(id));
				end
			end
		end);
	end
end

function GameSeries.CompleteQuest(id)
    local bHas, guid = hasGSItem(questDesc[id].acquire_gsid);
	if(bHas) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(questDesc[id].complete_exid, nil, nil, function(msg)
			local exid = questDesc[id].complete_exid;
			local name = "";
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
			if(exTemplate) then
				name = exTemplate.exname or "";
			end
			log("+++++++ WishGameSeries ExtendedCost "..exid..": "..name.." return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				GameSeries.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/Game/Template_Finish.html?id="..id);
				-- use the reward item to increase pet friendliness
				if(questDesc[id].reward_gsid > 0) then
					local bHas, guid = hasGSItem(questDesc[id].reward_gsid);
					if(bHas and guid) then
						local item = ItemManager.GetItemByGUID(guid);
						if(item and item.guid > 0) then
							item:OnClick("left");
						end
					end
				end
			end
		end);
	end
end

-- register hook into 
function GameSeries.RegisterHook(id)
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(id == 1 and msg.aries_type == "OnFarmClipGameFinish") then
				-- FarmClip game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 2 and msg.aries_type == "OnHitShrewGameFinish") then
				-- HitShrew game finish
				if((msg.score and msg.score > 0) or msg.hasGainCaiTou or msg.hasGainCongTou) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 3 and msg.aries_type == "OnRainbowFlowerGameFinish") then
				-- RainbowFlower game finish
				GameSeries.CompleteQuest(id);
			elseif(id == 4 and msg.aries_type == "OnChuanYunGameFinish") then
				-- ChuanYun game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 5 and msg.aries_type == "OnPaoPaoLongFinish") then
				-- PaoPaoLong game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 6 and msg.aries_type == "OnSnowBallFinish") then
				-- SnowBall game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 7 and msg.aries_type == "OnSuperDancerGameFinish") then
				-- SuperDancer game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 8 and msg.aries_type == "OnJumpFloorGameFinish") then
				-- JumpFloor game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 9 and msg.aries_type == "OnZumaGameFinish") then
				-- Zuma game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			elseif(id == 10 and msg.aries_type == "OnCrazySpotsGameFinish") then
				-- CrazySpots game finish
				if(msg.score and msg.score > 0) then
					GameSeries.CompleteQuest(id);
				end
			end
		end, 
		hookName = "Wish_GameSeries_"..id, appName = "Aries", wndName = "main"});
end

-- unregister hook
function GameSeries.UnregisterHook(id)
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Wish_GameSeries_"..id, 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end