--[[
Title: HomelandSeries
Author(s): WangTian
Date: 2009/7/31

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/Homeland/HomelandSeries.lua
------------------------------------------------------------
]]

-- create class
local libName = "HomelandSeries";
local HomelandSeries = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HomelandSeries", HomelandSeries);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- HomelandSeries.main
function HomelandSeries.main()
end

--50037_WishHomeland1_Acquire
--50038_WishHomeland1_Complete
--50039_WishHomeland1_RewardFriendliness

-- 50141_WishHomeland1_Acquire

local questDesc = {
	{	acquire_gsid = 50141, 
		reward_gsid = 50122, 
		complete_exid = 43,
		title = "给别人家的植物浇水",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            有些小哈奇好粗心哦，家园里的植物都干枯了，我们去给那些旱渴的植物浇浇水吧!  ]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            他家的植物喝饱了水，长得多好呀！我们自己家的植物也别忘记浇水哦，这次我们的亲密度又增加了2点，爱心值也增加了1点。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland1_status.html",
	}, -- water plant 
	{	acquire_gsid = 50142, 
		reward_gsid = 50122, 
		complete_exid = 44,
		title = "给别人家的植物除虫",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            很多小哈奇家的植物都被坏虫子咬坏了，我们快去帮他们除除虫吧，我知道你最喜欢助人为乐啦。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            那些坏虫子都被你赶走了，你真是绿色卫士呀！我们家的植物也要当心虫子哦！这回我们的亲密度增加了2点，爱心值也增加了1点哦，好棒！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland2_status.html",
	}, -- debug plant 
	{	acquire_gsid = 50143, 
		reward_gsid = 50122, 
		complete_exid = 45,
		title = "给其他的哈奇送礼物",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            很多哈奇家的礼物盒还空空的，我们悄悄放件礼物进去，收到礼物的小哈奇该多高兴呀！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            收到礼物的小哈奇好开心，我们也好开心哦！我们的亲密度也增加了2点，爱心值也增加了3点哦，好棒！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland3_status.html",
	}, -- gift
	{	acquire_gsid = 50144, 
		reward_gsid = 50122, 
		complete_exid = 46,
		title = "给其他的哈奇家园投鲜花",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            很多小哈奇的家园打扮的真特别，我们去参观一下，顺便给漂亮的家园投鲜花吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            收到鲜花的小哈奇肯定很开心，我们也要好好装扮下我们的家，爱心值也增加了2点，以后肯定也会有很多人来给我们家投鲜花的！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland4_status.html",
	}, -- flower
	{	acquire_gsid = 50145, 
		reward_gsid = 50122, 
		complete_exid = 47,
		title = "去自动售货机买菠萝种子",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            我们家的菠萝种子不多了吧，赶紧去自动售货机那再买点回来吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            菠萝种子买回来咯，有空就多种点菠萝吧，好给我做菠萝派吃呢！想想都觉得开心，我们的亲密度又增加了2点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland5_status.html",
	}, -- pine apple seed
	{	acquire_gsid = 50146, 
		reward_gsid = 50122, 
		complete_exid = 48,
		title = "去自动售货机买炮竹",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            自动售货机那的炮竹真好玩，再给我买点回来吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            我们家也有炮竹咯！有空就可以多和其他小哈奇比比谁投得更准了，真是不错！我们的亲密度又增加了2点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland6_status.html",
	}, -- fire cracker
	{	acquire_gsid = 50147, 
		reward_gsid = 50122, 
		complete_exid = 49,
		title = "给小哈奇投票",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哈奇们学习舞蹈的热情高涨，都渴望能得到朋友们的投票，你快去找你的朋友，给他投一票吧。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            你真好，你的朋友也许因为你的这一票就能学更难的舞蹈动作呢！我们的亲密度又增加了2点，爱心值也增加了3点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Homeland/30011_WishHomeland7_status.html",
	}, -- vote other for popularity
};
HomelandSeries.questDesc = questDesc;

HomelandSeries.InnerMCML = "null";

-- get acquire page url
function HomelandSeries.GetAcquirePageURL(id)
	if(id) then
		local desc = questDesc[id];
		return "script/apps/Aries/NPCs/Dragon/Homeland/Template_Acquire.html?id="..id;
	end
end

-- refresh quest status
function HomelandSeries.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	local id = 1;
	for id = 1, #(questDesc) do
		local desc = questDesc[id];
		if(hasGSItem(desc.acquire_gsid)) then
			QuestArea.AppendQuestStatus(
				desc.status_page,
				"dragon", "", desc.title,  desc.acquire_gsid);
			HomelandSeries.RegisterHook(id);
		elseif(not hasGSItem(desc.acquire_gsid)) then
			QuestArea.DeleteQuestStatus(desc.status_page);
			HomelandSeries.UnregisterHook(id);
		end
	end
end

function HomelandSeries.CanAcquireQuest(id)
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

function HomelandSeries.AcquireQuest(id)
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
					Quest.AppendFeedIfNotAppended(HomelandSeries.GetAcquirePageURL(id));
				end
			end
		end);
	end
end

function HomelandSeries.CompleteQuest(id)
    local bHas, guid = hasGSItem(questDesc[id].acquire_gsid);
	if(bHas) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(questDesc[id].complete_exid, nil, nil, function(msg)end, function(msg)
			local exid = questDesc[id].complete_exid;
			local name = "";
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
			if(exTemplate) then
				name = exTemplate.exname or "";
			end
			log("+++++++ WishHomelandSeries ExtendedCost "..exid..": "..name.." return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				HomelandSeries.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/Homeland/Template_Finish.html?id="..id);
				-- use the reward item to increase pet friendliness
				local bHas, guid = hasGSItem(questDesc[id].reward_gsid);
				if(bHas and guid) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						item:OnClick("left");
					end
				end
			end
		end);
	end
end

-- register hook into 
function HomelandSeries.RegisterHook(id)
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(id == 1 and msg.aries_type == "OnWaterPlant") then
				-- on water other player plant
				if(msg.nid ~= System.App.profiles.ProfileManager.GetNID()) then
					HomelandSeries.CompleteQuest(id);
				end
			elseif(id == 2 and msg.aries_type == "OnDebugPlant") then
				-- on debug other player plant
				if(msg.nid ~= System.App.profiles.ProfileManager.GetNID()) then
					HomelandSeries.CompleteQuest(id);
				end
			elseif(id == 3 and msg.aries_type == "OnGiveGift") then
				-- on send gift
				HomelandSeries.CompleteQuest(id);
			elseif(id == 4 and msg.aries_type == "OnSendFlower") then
				-- on send gift
				HomelandSeries.CompleteQuest(id);
			elseif(id == 5 and msg.aries_type == "OnPurchaseItem" and msg.gsid == 30009) then
				-- 30009: OutdoorPlantPineapple
				-- on purchase pine apple seed
				HomelandSeries.CompleteQuest(id);
			elseif(id == 6 and msg.aries_type == "OnPurchaseItem" and msg.gsid == 9503) then
				-- 9503: ThrowableSpecialFirecracker
				-- on purchase pine apple seed
				HomelandSeries.CompleteQuest(id);
			elseif(id == 7 and msg.aries_type == "OnVoteOtherPopularity") then
				-- on vote other popularity
				HomelandSeries.CompleteQuest(id);
			end
		end, 
		hookName = "Wish_HomelandSeries_"..id, appName = "Aries", wndName = "main"});
end

-- unregister hook
function HomelandSeries.UnregisterHook(id)
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Wish_HomelandSeries_"..id, 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end