--[[
Title: FoodSeries
Author(s): WangTian
Date: 2009/7/31

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/Food/FoodSeries.lua
------------------------------------------------------------
]]

-- create class
local libName = "FoodSeries";
local FoodSeries = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FoodSeries", FoodSeries);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FoodSeries.main
function FoodSeries.main()
end

--50037_WishHomeland1_Acquire
--50038_WishHomeland1_Complete
--50039_WishHomeland1_RewardFriendliness

-- 50141_WishHomeland1_Acquire

local questDesc = {
	{	acquire_gsid = 50151, 
		reward_gsid = 50123, 
		complete_exid = 53,
		title = "抱抱龙想吃蜂窝蜜花粥",
		petlevel_require = 2,
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            我闻到了蜂窝蜜花粥的香味了，在我饿的时候如果能喂我一个蜂窝蜜花粥就太好了。爱你哟！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            老远我就闻到蜂窝蜜花粥的香味了，真好吃呀！谢谢你为我做的一切。这次我们的亲密度又增加了3点，开心唉！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food1_status.html",
	}, -- 蜂窝蜜花粥
	{	acquire_gsid = 50152, 
		reward_gsid = 50123, 
		complete_exid = 54,
		title = "抱抱龙想吃樱桃小丸子",
		petlevel_require = 2,
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            我闻到了樱桃小丸子的香味了，在我饿的时候如果能喂我一个樱桃小丸子就太好了。爱你哟！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            樱桃小丸子最清香可口了，yummy yummy！谢谢你哦。我们的亲密度又增加了3点，好吔！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food2_status.html",
	}, -- 樱桃小丸子
	{	acquire_gsid = 50153, 
		reward_gsid = 50123, 
		complete_exid = 55,
		title = "抱抱龙想吃菠萝派",
		petlevel_require = 2,
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            饿的时候就很想吃一个你亲手做的菠萝派，那会是一个充满爱心的香甜可口的菠萝派。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            这个菠萝派真的是你亲手做的吗？太好吃了，谢谢你的爱心菠萝派！我们的亲密度又增加了3点，真棒！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food3_status.html",
	}, -- 菠萝派 
	{	acquire_gsid = 50154, 
		reward_gsid = 50122, 
		complete_exid = 56,
		title = "抱抱龙想吃巧克力泡芙",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            好想吃巧克力泡芙呀，饿的时候如果能吃上一个，肯定很美！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            嗯嗯，好饱好yummy！巧克力泡芙果然好吃。我们的亲密度又增加了2点，好吔！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food4_status.html",
	}, -- 巧克力泡芙 
	{	acquire_gsid = 50155, 
		reward_gsid = 50122, 
		complete_exid = 57,
		title = "抱抱龙想吃桂味奶香饼",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            好想尝尝桂味奶香饼啊，你去买一个回来喂我嘛！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哇，桂味奶香饼真是太好吃了！你真好，我们的亲密度也增加了2点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food5_status.html",
	}, -- 桂味奶香饼 
	{	acquire_gsid = 50156, 
		reward_gsid = 50122, 
		complete_exid = 58,
		title = "抱抱龙用龙皮锃亮乳液洗澡",		
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            用龙皮锃亮乳液洗澡，是件很有风度的事，脏的时候给我试试吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哇，我太喜欢龙皮锃亮乳液的香味了，我们的亲密度也增加了2点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food6_status.html",
	}, -- 龙皮锃亮乳液 
	{	acquire_gsid = 50157, 
		reward_gsid = 50122, 
		complete_exid = 59,
		title = "抱抱龙想用光亮洁面奶",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            光亮洁面奶的效果应该不错，要不你给我用一下试试？]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            哇，光亮洁面奶的效果真不是吹的，我太喜欢了！我们的亲密度也增加了2点哦！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food7_status.html",
	}, -- 光亮洁面奶 
	{	acquire_gsid = 50158, 
		reward_gsid = 50122, 
		complete_exid = 60,
		title = "抱抱龙想吃喷喷香批萨",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            喷喷香批萨，香飘万里，给我做一个来吃嘛。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            这个批萨的味道果然不同凡响，太好吃了，下次还要吃这个！我们的亲密度也增加了2点吔！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food8_status.html",
	}, -- 喷喷香批萨 
	{	acquire_gsid = 50159, 
		reward_gsid = 50122, 
		complete_exid = 61,
		title = "抱抱龙想吃海味什锦",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            海味什锦，口味清淡，风味独特，给我做一个嘛。]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            海味什锦，天然一派，我好爱吃哦！我们的亲密度也增加了2点！]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food9_status.html",
	}, -- 海味什锦 
	
------------------------------ DEPRECATED ------------------------------
	--{	acquire_gsid = 50160, 
		--reward_gsid = 50122, 
		--complete_exid = 62,
		--title = "抱抱龙想要雪绒花地毯",
		--acquire_mcml = [[
		--亲爱的<pe:name linked=false/>，<br/>
            --雪绒花地毯是放在家里的绝佳装饰，快去做一个来，多多益善哦！]],
		--finish_mcml = [[
		--亲爱的<pe:name linked=false/>，<br/>
            --我喜欢这个雪绒花地毯，快把它铺到屋子里吧。我们的亲密度也增加了2点哦。]],
		--status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food10_status.html",
	--}, -- 雪绒花地毯
	--{	acquire_gsid = 50221, 
		--reward_gsid = 50122, 
		--complete_exid = 172,
		--title = "抱抱龙想要毛线娃娃",
		--acquire_mcml = [[
		--亲爱的<pe:name linked=false/>，<br/>
            --嘎嘎，如果你能编一个毛线娃娃送我，算你厉害！]],
		--finish_mcml = [[
		--亲爱的<pe:name linked=false/>，<br/>
            --你果然厉害！这么漂亮的毛线娃娃，快点摆出来哦。我们的亲密度又增加了2点。]],
		--status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food11_status.html",
	--}, -- 毛线娃娃
	--{	acquire_gsid = 50222, 
		--reward_gsid = 50122, 
		--complete_exid = 173,
		--title = "抱抱龙想要海苔冰灯",
		--acquire_mcml = [[
		--亲爱的<pe:name linked=false/>，<br/>
            --海苔造型的海苔冰灯，散发着柔光，我想要嘛！]],
		--finish_mcml = [[
		--亲爱的<pe:name linked=false/>，<br/>
            --哇～，这款海苔冰灯，真是很时尚呀！我好喜欢，我们的亲密度也增加了2点哦。]],
		--status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food12_status.html",
	--}, -- 海苔冰灯
------------------------------ DEPRECATED ------------------------------

	{	acquire_gsid = 50223, 
		reward_gsid = 50122, 
		complete_exid = 174,
		title = "抱抱龙想要小红花凳",
		acquire_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            好想给家里多增添一个小红花凳，去多克特博士屋造一个吧！]],
		finish_mcml = [[
		亲爱的<pe:name linked=false/>，<br/>
            我喜欢这个小红花凳，如果把它摆到蘑菇小屋旁边，还挺配套的。我们的亲密度也增加了2点哦，我的力量值和智慧值也都增加了1点。]],
		status_page = "script/apps/Aries/NPCs/Dragon/Food/30011_Wish_Food10_status.html",
	}, -- 海苔冰灯
	
};
FoodSeries.questDesc = questDesc;

FoodSeries.InnerMCML = "null";

-- get acquire page url
function FoodSeries.GetAcquirePageURL(id)
	if(id) then
		local desc = questDesc[id];
		return "script/apps/Aries/NPCs/Dragon/Food/Template_Acquire.html?id="..id;
	end
end

-- refresh quest status
function FoodSeries.RefreshStatus()
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
			FoodSeries.RegisterHook(id);
		elseif(not hasGSItem(desc.acquire_gsid)) then
			QuestArea.DeleteQuestStatus(desc.status_page);
			FoodSeries.UnregisterHook(id);
		end
	end
end

function FoodSeries.CanAcquireQuest(id)
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

function FoodSeries.AcquireQuest(id)
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
					Quest.AppendFeedIfNotAppended(FoodSeries.GetAcquirePageURL(id));
				end
			end
		end);
	end
end

function FoodSeries.CompleteQuest(id)
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
			log("+++++++ WishFoodSeries ExtendedCost "..exid..": "..name.." return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				FoodSeries.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/Food/Template_Finish.html?id="..id);
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
function FoodSeries.RegisterHook(id)
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(id == 1 and msg.aries_type == "PetFeed") then
				-- 16014_HoneyBeeHiveSoup
				if(msg.gsid == 16014) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 2 and msg.aries_type == "PetFeed") then
				-- 16013_CherryBall
				if(msg.gsid == 16013) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 3 and msg.aries_type == "PetFeed") then
				-- 16012_PineApplePie
				if(msg.gsid == 16012) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 4 and msg.aries_type == "PetFeed") then
				-- 16016_ChocolatePuff
				if(msg.gsid == 16016) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 5 and msg.aries_type == "PetFeed") then
				-- 16017_FragransMilkCake
				if(msg.gsid == 16017) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 6 and msg.aries_type == "PetBath") then
				-- 16018_ShinySkinPotion
				if(msg.gsid == 16018) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 7 and msg.aries_type == "PetBath") then
				-- 16019_BrightFacialPotion
				if(msg.gsid == 16019) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 8 and msg.aries_type == "PetFeed") then
				-- 16002_DeliciousPizza
				if(msg.gsid == 16002) then
					FoodSeries.CompleteQuest(id);
				end
			elseif(id == 9 and msg.aries_type == "PetFeed") then
				-- 16021_AssoetedSeafood
				if(msg.gsid == 16021) then
					FoodSeries.CompleteQuest(id);
				end
------------------------------ DEPRECATED ------------------------------
			--elseif(id == 10 and msg.aries_type == "OnObtainItem") then
				---- 30081_EdelweissCarpet
				--if(msg.gsid == 30081) then
					--FoodSeries.CompleteQuest(id);
				--end
			--elseif(id == 11 and msg.aries_type == "OnObtainItem") then
				---- 30082_YarnToy
				--if(msg.gsid == 30082) then
					--FoodSeries.CompleteQuest(id);
				--end
			--elseif(id == 12 and msg.aries_type == "OnObtainItem") then
				---- 30080_SeaWeedIceLamp
				--if(msg.gsid == 30080) then
					--FoodSeries.CompleteQuest(id);
				--end
------------------------------ DEPRECATED ------------------------------
			elseif(id == 10 and msg.aries_type == "OnObtainItem") then
				-- 30032_RedFlowerStool
				if(msg.gsid == 30032) then
					FoodSeries.CompleteQuest(id);
				end
			end
		end, 
		hookName = "Wish_FoodSeries_"..id, appName = "Aries", wndName = "items"});
end

-- unregister hook
function FoodSeries.UnregisterHook(id)
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Wish_FoodSeries_"..id, 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end