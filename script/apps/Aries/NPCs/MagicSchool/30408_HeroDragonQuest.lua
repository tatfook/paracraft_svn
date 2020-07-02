--[[
Title: 30408_HeroDragonQuest
Author(s): Leio
Date: 2010/08/11

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest.lua");
local HeroDragonQuest = commonlib.gettable("MyCompany.Aries.Quest.NPCs.HeroDragonQuest");
HeroDragonQuest.RefreshStatus();

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
-- create class
local libName = "HeroDragonQuest";
local HeroDragonQuest = commonlib.gettable("MyCompany.Aries.Quest.NPCs.HeroDragonQuest");
HeroDragonQuest.mobs = {
	--{ type = "config/Aries/Mob/MobTemplate_BlazeHairMonster.xml", label = "火毛怪", place = "火焰山洞", level = 9, },
	--{ type = "config/Aries/Mob/MobTemplate_DeadTreeMonster.xml", label = "松木妖", place = "雪山脚下", level = 15, },
	--{ type = "config/Aries/Mob/MobTemplate_EvilSnowman.xml", label = "邪恶雪人", place = "雪山脚下", level = 20, },
	--{ type = "config/Aries/Mob/MobTemplate_FireRockyOgre.xml", label = "火鬃怪", place = "岩浆沙漠", level = 30, },
	----{ type = "config/Aries/Mob/MobTemplate_FireRockyOgre_Boss.xml", label = "火石头人Boss", place = "", level = -1, },
	--{ type = "config/Aries/Mob/MobTemplate_FireRockyOgre02.xml", label = "火鬃怪首领", place = "岩浆沙漠", level = 30, isBoos = true, },
	--{ type = "config/Aries/Mob/MobTemplate_ForestSpikyOgre.xml", label = "大力土猿首领", place = "岩浆沙漠", level = 10, isBoos = true, },
	----{ type = "config/Aries/Mob/MobTemplate_HammerBear.xml", label = "", place = "", level = , },
	--{ type = "config/Aries/Mob/MobTemplate_IronBee.xml", label = "金苍蝇", place = "魔法密林", level = 7, },
	--{ type = "config/Aries/Mob/MobTemplate_IronShell.xml", label = "铁壳怪", place = "阳光海岸", level = 22, },
	--{ type = "config/Aries/Mob/MobTemplate_RedCrab.xml", label = "烈火蟹", place = "阳光海岸", level = 27, },
	--{ type = "config/Aries/Mob/MobTemplate_SandScorpion.xml", label = "沙漠毒蝎", place = "探索号", level = 24, },
	----{ type = "config/Aries/Mob/MobTemplate_SkeletonNinja.xml", label = "", place = "", level = , },
	--{ type = "config/Aries/Mob/MobTemplate_StoneMonster.xml", label = "粘土巨人", place = "绿野郊外", level = 10, },
	--{ type = "config/Aries/Mob/MobTemplate_TreeMonster.xml", label = "老树妖", place = "魔法密林", level = 4, },
	--{ type = "config/Aries/Mob/MobTemplate_WaterBubble.xml", label = "水咕噜", place = "生命之泉", level = 1, },
}
HeroDragonQuest.mobs = QuestHelp.GetHeroDragonData();
--[[
HeroDragonQuest.allQuests = {
	{
		pIndex = 1,--第几个任务
		actived = false,--是否已经激活
		quests = {
			{ type = "MobTemplate_StoneMonster.xml", label = "粘土巨人", level = 10, cur_num = 0, req_num = 10,},
			{ type = "b", label = "", level = 10, cur_num = 0, req_num = 10,},
		},
	},
	{
		pIndex = 2,--第几个任务
		actived = false,--是否已经激活
		quests = {
			{ type = "MobTemplate_StoneMonster.xml", label = "粘土巨人", level = 10, cur_num = 0, req_num = 10,},
			{ type = "b", label = "", level = 10, cur_num = 0, req_num = 10,},
		},
	},
	date = "2010-08-11";
}
--]]
HeroDragonQuest.allQuests = nil;
HeroDragonQuest.selectedIndex = nil;
local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- HeroDragonQuest.main
function HeroDragonQuest.main()
	local self = HeroDragonQuest;
	self.RefreshStatus();
end

function HeroDragonQuest.RefreshStatus()
	--local self = HeroDragonQuest;
	--if(MyCompany.Aries.Pet.CombatIsOpened())then
		--self.LoadQuest();
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest_panel.html", 
			--"normal", "Texture/Aries/NPCs/HeroDragon/ico_32bits.png", "勇者之龙", nil, 1, nil, function()
				--self.PreDialog();
				--if(self.HasBounced())then
					--QuestArea.BounceNormalQuestIcon("script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest_panel.html", "stop")
				--end
			--end);
	--end
end
function HeroDragonQuest.PreDialog()
	local self = HeroDragonQuest;
	function showPage()
		-- clear selected item ids before close
		local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
		-- show the panel
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest_panel.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "30408_HeroDragonQuest_panel", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = style,
			zorder = 2,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -774/2,
				y = -496/2,
				width = 774,
				height = 496,
		});
	end
	if(self.IsNull())then
		self.LoadQuest(function()
			showPage();
		end);
	else
		showPage();
	end
	return false;
end
function HeroDragonQuest.FindMob_0_3()
	local self = HeroDragonQuest;
	local result = self.FindMobHelpFunc(0,4,1,1,nil,true);
	return result;
end
function HeroDragonQuest.FindMob_4_6()
	local self = HeroDragonQuest;
	local result = self.FindMobHelpFunc(5,9,1,2,nil,true);
	return result;
end

function HeroDragonQuest.FindMob_7_10()
	local self = HeroDragonQuest;
	local result = self.FindMobHelpFunc(7,10,2,1,1,false);
	return result;
end
function HeroDragonQuest.FindMob_11_15()
	local self = HeroDragonQuest;
	local result = self.FindMobHelpFunc(11,15,2,2,1,true);
	return result;
end
function HeroDragonQuest.FindMob_16_19()
	local self = HeroDragonQuest;
	local result = self.FindMobHelpFunc(15,18,2,2,2,true);
	return result;
end
function HeroDragonQuest.FindMob_20()
	local self = HeroDragonQuest;
	local result = self.FindMobHelpFunc(15,19,2,2,2,false);
	return result;
end
--@param mobLevel_1:怪的开始等级
--@param mobLevel_2:怪的结束等级
--@param mobTypeNum:怪种类的数量
--@param n1 n2:对应每种怪的数量
function HeroDragonQuest.FindMobHelpFunc(mobLevel_1,mobLevel_2,mobTypeNum,n1,n2,excludeBoos)
	local self = HeroDragonQuest;
	local candidates = self.FindMobsRange(mobLevel_1,mobLevel_2,excludeBoos);
	local result = {};
	if(candidates)then
		local len = #candidates;
		local list = commonlib.GetRandomList(len,mobTypeNum);
		
		function push(i,n)
			local index = list[i];
			local mob = candidates[index];
			if(mob and n > 0)then
				mob = self.CloneMob(mob,n);
				table.insert(result,mob);
			end
		end
		n1 = n1 or 0;
		n2 = n2 or 0;
		if(n1 > 0)then
			push(1,n1);
		end
		if(n2 > 0)then
			push(2,n2);
		end
	end
	return result;
end
function HeroDragonQuest.CloneMob(mob,n)
	local self = HeroDragonQuest;
	if(not mob or not n)then return end
	mob = commonlib.deepcopy(mob);
	mob["cur_num"] = 0;
	mob["req_num"] = n;
	return mob;
end
--find mobs which level between beginLevel and endLevel
function HeroDragonQuest.FindMobsRange(beginLevel,endLevel,excludeBoos)
	local self = HeroDragonQuest;
	if(not beginLevel or not endLevel)then return end
	beginLevel = math.min(beginLevel,endLevel);
	endLevel = math.max(beginLevel,endLevel);
	local k,mob;
	local candidates = {};
	for k,mob in pairs(self.mobs) do
		if(mob.level >= beginLevel and mob.level <= endLevel)then
			local item = {
				type = mob.type,
				--label = mob.label,
				--level = mob.level,
				--place = mob.place,
			}
			if(excludeBoos)then
				if(not mob.isBoos)then
					table.insert(candidates,item);
				end
			else
				table.insert(candidates,item);
			end
		end
	end
	return candidates;
end
--任务最后一个索引
function HeroDragonQuest.GetLastIndex()
	local self = HeroDragonQuest;
	local q = self.GetQuestsTable();
	if(q)then
		local len = #q;
		local item = q[len];
		if(item)then
			local pIndex = item.pIndex or 0;
			return pIndex;	
		end
	end
	return 0;
end
function HeroDragonQuest.SetQuestsTable(v)
	local self = HeroDragonQuest;
	self.allQuests = v;
end
--获取当天所有任务的描述
function HeroDragonQuest.GetQuestsTable()
	local self = HeroDragonQuest;
	return self.allQuests;
end
--产生N个新的任务,并保存
function HeroDragonQuest.PushQuest(n)
	local self = HeroDragonQuest;
	n = n or 1;
	local q = self.GetQuestsTable();
	if(not q)then
		q = {};
		self.SetQuestsTable(q);
	end
	local lastIndex = self.GetLastIndex();
	if(n > 0)then
		local i;
		for i = 1,n do
			lastIndex = lastIndex + 1;
			local quests = self.BuildQuest();
			local item = {
				pIndex = lastIndex,
				actived = false,
				quests = quests,
			}
			table.insert(q,item);
		end
	end
	local date = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	q.date = date;
	self.SaveQuest();
end
--获取第一个任务，因为只有第一个任务完成才能完成下一个
function HeroDragonQuest.GetTopQuest()
	local self = HeroDragonQuest;
	local q = self.GetQuestsTable();
	if(q)then
		local item = q[1];
		return item;
	end
end
--删除第一个任务，在最后增加一个新的任务,并且保存
function HeroDragonQuest.PopAndPushQuest()
	local self = HeroDragonQuest;
	local q = self.GetQuestsTable();
	if(q)then
		commonlib.removeArrayItem(q, 1)
		local lastIndex = self.GetLastIndex() + 1;
		local quests = self.BuildQuest();
		local item = {
			pIndex = lastIndex,
			actived = false,
			quests = quests,
		}
		--table.insert(q,item);
		commonlib.insertArrayItem(q, 5, item)
	end
	self.SaveQuest();
end
--create a quest
function HeroDragonQuest.BuildQuest()
	local self = HeroDragonQuest;
	--if(not self.loadxmldata)then
		----加载怪的数据
		--self.mobs = QuestHelp.GetHeroDragonData();
		--self.loadxmldata = true;
	--end
	local combatlel = 0;
	-- get pet level
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlel = bean.combatlel or 0;
	end
	local result;
	if(combatlel >=0 and combatlel <=3)then
		result = self.FindMob_0_3();
	elseif(combatlel >=4 and combatlel <=6)then
		result = self.FindMob_4_6();
	elseif(combatlel >=7 and combatlel <=10)then
		result = self.FindMob_7_10();
	elseif(combatlel >=11 and combatlel <=15)then
		result = self.FindMob_11_15();
	elseif(combatlel >=16 and combatlel <=19)then
		result = self.FindMob_16_19();
	else
		result = self.FindMob_20();
	end
	return result;
end
--所有的任务是否为空
function HeroDragonQuest.IsNull()
	local self = HeroDragonQuest;
	if(not self.allQuests)then
		return true;
	end	
end
--最上层的任务是否被激活
function HeroDragonQuest.IsActived()
	local self = HeroDragonQuest;
	local item = self.GetTopQuest();
	if(item)then
		return item.actived;
	end
end
--激活当前的任务
function HeroDragonQuest.DoActive_Quest()
	local self = HeroDragonQuest;
	if(not MyCompany.Aries.Pet.CombatIsOpened())then
		local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>战斗的任务很危险，需要有战斗能力的抱抱龙才能接受，你先去魔法学院门口找青龙开启抱抱龙的战斗天赋吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	if(self.IsActived() and not self.IsFinished_Quest())then
		local index = self.GetLastIndex();
		local s = string.format("<div style='margin-left:15px;margin-top:15px;text-align:center'>你已经成功领取了今天的第%d个任务，快快去努力吧，任务完成后记得来领取奖励哦！</div>",index);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	local item = self.GetTopQuest();
	if(item)then
		item.actived = true;
		self.SaveQuest(function()
			if(self.page)then
				self.page:Refresh(0.01);
				paraworld.PostLog({action="combat_accept_task"}, "quest_log", function(msg)
					end);
				self.SetBounced(false);
			end	
		end);
	end
end
--提交任务
function HeroDragonQuest.DoFinish_Quest()
	local self = HeroDragonQuest;
	if(not self.IsFinished_Quest())then
		local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>你的任务还没有完成呢，还不能领取奖励！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	else
		local items = self.GetReward() or {};
		local reward_str = string.format("%d经验值，%d个奇豆",items.exp or 0,items.coin or 0);
		local s = string.format("<div style='margin-left:0px;margin-top:15px;text-align:center'>任务完成！恭喜你获得了%s！赶紧领取下一个勇者之龙任务吧！</div>",reward_str);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				--发放奖励
				self.GiveReward(items);
				--产生新的任务
				self.PopAndPushQuest();
				local item = self.GetTopQuest();
				--自动激活第一个任务
				if(item)then
					self.selectedIndex = 1;
					--item.actived = true;
					self.SaveQuest(function()
					--刷新页面
						if(self.page)then
							self.page:Refresh(0.01);
							paraworld.PostLog({action="combat_finish_task"}, "quest_log", function(msg)
								end);
						end	
					end);
				end
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end
--发放奖励
function HeroDragonQuest.GiveReward(items)
	local self = HeroDragonQuest;
	if(not items)then return end
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local week = Scene.GetDayOfWeek();
	local n = 1;
	if(week == 6 or week == 7)then
		n = 2;
	end
	local exp = items.exp or 0;
	local coin = items.coin or 0;
	exp = exp * n;
	coin = coin * n;
	MyCompany.Aries.Player.AddMoney(coin,nil,false);
	local Player = commonlib.gettable("MyCompany.Aries.Player");
	Player.AddExp(exp, nil, false);
	-- user gain exp post log
	paraworld.PostLog({action = "user_gain_exp", exp_pt = exp, reason = "DailyMobFarmingQuest"}, "user_gain_exp_log", function(msg)
	end);
end
--当前任务是否已经完成
function HeroDragonQuest.IsFinished_Quest()
	local self = HeroDragonQuest;
	if(not self.IsNull())then
		local q = self.GetTopQuest();
		if(not q)then return end
		local quests = q.quests;
		if(quests)then
			local labels = {};
			local k,quest;
			for k,quest in ipairs(quests) do
				local cur_num = quest.cur_num;
				local req_num = quest.req_num;
				if(cur_num >= req_num)then
					labels[k] = true;
				else
					labels[k] = false;
				end
			end
			local k,v;
			for k,v in ipairs(labels) do
				if(not v)then
					return false;
				end
			end
			return true;
		end
	end
end
function HeroDragonQuest.LoadQuest(callbackFunc)
	local self = HeroDragonQuest;
		local gsid = 50313;
		local bagFamily = 30011;
		ItemManager.GetItemsInBag(bagFamily, "50313_DailyMobFarmingQuest", function(msg)
				local hasGSItem = ItemManager.IfOwnGSItem;
				local hasItem,guid = hasGSItem(gsid);
				if(hasItem)then
					local item = ItemManager.GetItemByGUID(guid);
					if(item)then
						local clientdata = item.clientdata;
						if(clientdata == "")then
							clientdata = "{}"
						end
						commonlib.stdlog("","debug","HeroDragonQuest","before load 50313_DailyMobFarmingQuest:%s",commonlib.serialize_compact(clientdata))
						clientdata = commonlib.LoadTableFromString(clientdata);
						commonlib.stdlog("","debug","HeroDragonQuest","after load 50313_DailyMobFarmingQuest:%s",commonlib.serialize_compact(clientdata))

						if(clientdata and type(clientdata) == "table")then
							local date = clientdata.date;

							local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
							--如果是第二天,产生新的任务
							if(date ~= today)then
								self.PushQuest(5);
							else
								local q = clientdata;
								self.SetQuestsTable(q);
							end
							
							if(callbackFunc and type(callbackFunc) == "function")then
								callbackFunc({
								});
							end
						end
					
					end
				end
			end, "access plus 1 minutes");
end
--clientdata is a table
function HeroDragonQuest.SaveQuest(callbackFunc)
	local self = HeroDragonQuest;
	local gsid = 50313;
	local bagFamily = 30011;
	ItemManager.GetItemsInBag(bagFamily, "50313_DailyMobFarmingQuest", function(msg)
		local hasGSItem = ItemManager.IfOwnGSItem;
		local hasItem,guid = hasGSItem(gsid)
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				--序列化
				local info = self.GetQuestsTable() or "";
				local clientdata = commonlib.serialize_compact2(info);
				commonlib.stdlog("","debug","HeroDragonQuest","before save 50313_DailyMobFarmingQuest:%s",commonlib.serialize_compact(clientdata))
				ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
				commonlib.stdlog("","debug","HeroDragonQuest","after save 50313_DailyMobFarmingQuest:%s",commonlib.serialize_compact(msg_setclientdata))
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({
								
						});
					end
				end);
			end
		end
	end, "access plus 1 minutes");
end
function HeroDragonQuest.GetReward(idx)
	local self = HeroDragonQuest;
	idx = idx or 1;
	local quests = self.GetQuestsTable();
	if(not quests)then return end
	local item = quests[idx];
	if(item)then
		local index = item.pIndex or 6;
		local combatlel = 0;
		-- get pet level
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean) then
			combatlel = bean.combatlel or 0;
		end
		local lv = combatlel + 1;
		local exp = 0;
		local coin = 0;
		if(index == 1)then
			exp = lv * 3;
			coin = 200;
		elseif(index == 2)then
			exp = lv * 3 * 2;
			coin = 200;
		elseif(index == 3)then
			exp = lv * 3 * 4;
			coin = 400;
		elseif(index == 4)then
			exp = lv * 3 * 2;
			coin = 200;
		elseif(index == 5)then
			exp = lv * 3;
			coin = 100;
		else
			exp = math.floor(lv * 3 / 5);
			coin = 20;
		end
		local items = {
			exp = exp,
			coin = coin,
		}
		return items;
	end
end
--完成的任务是否提醒过
function HeroDragonQuest.HasBounced()
	local self = HeroDragonQuest;
	local b = MyCompany.Aries.Player.LoadLocalData("HeroDragonQuest.HasBounced", false);
	return b;
end
function HeroDragonQuest.SetBounced(b)
	local self = HeroDragonQuest;
	MyCompany.Aries.Player.SaveLocalData("HeroDragonQuest.HasBounced", b)
end
--[[
NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest.lua");
local HeroDragonQuest = commonlib.gettable("MyCompany.Aries.Quest.NPCs.HeroDragonQuest");
local msg = {};
local k,v;
for k,v in ipairs(HeroDragonQuest.mobs) do
	msg[k] = { type = v.type, killed = 100,};
end
HeroDragonQuest.HandleCombat(msg);

local msg = {
	{ type = "MobTemplate_BlazeHairMonster.xml",killed = 100,},
	{ type = "MobTemplate_DeadTreeMonster.xml",killed = 100,},
}
--]]
function HeroDragonQuest.HandleCombat(msg)
	local self = HeroDragonQuest;
	if(not msg)then
		return
	end
	--如果任务已经完成，不接收信息
	if(self.IsFinished_Quest())then
		return
	end
	function doAdd(msg)
		local k,item
		for k,item in ipairs(msg) do
			local type = string.lower(item.type);
			local num = item.killed or 0;
			local j,quest;
			local q = self.GetTopQuest();
			for j,quest in ipairs(q.quests) do
				local _type = string.lower(quest.type);
				--小写比较
				if(_type == type)then
					quest.cur_num = quest.cur_num + num;
				end
			end
		end
	end
	--如果任务为空
	if(self.IsNull())then
		self.LoadQuest(function()
			--如果任务已经激活
			if(self.IsActived())then
				--处理怪物的累加
				doAdd(msg);
				self.SaveQuest();
			end
		end);
	else
		--如果任务已经激活
		if(self.IsActived())then
			--处理怪物的累加
			doAdd(msg);
			self.SaveQuest();
		end
	end
	if(self.IsFinished_Quest())then
		if(not self.HasBounced())then
			self.SetBounced(true);
			self.BounceIcon();
		end
	end
end
function HeroDragonQuest.DS_Func_TitleList(index)
	local self = HeroDragonQuest;
	local quests = self.GetQuestsTable();
	if(not quests)then return 0 end
	if(index == nil) then
		return #(quests);
	else
		return quests[index];
	end
end
function HeroDragonQuest.DS_Func(index,item)
	local self = HeroDragonQuest;
	item = item or {};
	local quests = item.quests;
	if(not quests)then return 0 end
	if(index == nil) then
		return #(quests);
	else
		return quests[index];
	end
end
function HeroDragonQuest.DoClick(index)
	local self = HeroDragonQuest;
    index = tonumber(index);
    self.selectedIndex = index;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
function HeroDragonQuest.DoClosePage()
	local self = HeroDragonQuest;
    self.selectedIndex = nil;
	if(self.page)then
		self.page:CloseWindow();
	end
end
--如果任务完成 图标晃动
function HeroDragonQuest.BounceIcon()
	local self = HeroDragonQuest;
	QuestArea.Bounce_Static_Icon("HeroDragon","bounce");
	--QuestArea.BounceNormalQuestIcon("script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest_panel.html", "bounce")
end
