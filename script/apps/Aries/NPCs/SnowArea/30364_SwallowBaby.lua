--[[
Title: SwallowBaby
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30364_SwallowBaby.lua
------------------------------------------------------------
]]

-- create class
local libName = "SwallowBaby";
local SwallowBaby = {
	can_hatch = false,
	can_feed = false,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SwallowBaby", SwallowBaby);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- SwallowBaby.main
function SwallowBaby.main()
	local self = SwallowBaby; 
	self.UpdateSwallowBabyState();
end
function SwallowBaby.CheckTime(clientdata)
	local self = SwallowBaby; 
	if(clientdata and type(clientdata) == "table")then
		local hatch_day = clientdata.hatch_day;
		local hatch_seconds = clientdata.hatch_seconds;
		local feed_day = clientdata.feed_day;
		local feed_seconds = clientdata.feed_seconds;
		if(hatch_day and hatch_seconds)then
			if(self.IsOutHour(hatch_day,hatch_seconds))then
				self.can_hatch = true;
			else
				self.can_hatch = false;
			end
		else
			self.can_hatch = true;
		end
		
		if(feed_day and feed_seconds)then
			if(self.IsOutHour(feed_day,feed_seconds))then
				self.can_feed = true;
			else
				self.can_feed = false;
			end
		else
			self.can_feed = true;
		end
	end
end
function SwallowBaby.PreDialog(npc_id, instance)
	local self = SwallowBaby; 
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30364);
	commonlib.echo("======memory in SwallowBaby.PreDialog");
	commonlib.echo(memory);
	
	if(self.IsAccepted() and not self.HatchIsFinished() and not memory.hatch_click)then
		self.can_hatch = false;
		self.ShowPage_Hatch();		
		return false;
	elseif(self.HatchIsFinished() and not self.FeedIsSaturation() and not memory.hatch_click and not memory.feed_click)then
		self.can_feed = false;
		self.ShowPage_Feed();		
		return false;
	end
end
--更新小燕子的状态 没有/鸟蛋/雏燕
function SwallowBaby.UpdateSwallowBabyState()
	commonlib.echo("======self.HatchIsOpened()");
	local self = SwallowBaby; 
	--如果喂养任务已经完成 或者 已经有燕子
	if(self.FeedIsFinished() or hasGSItem(10130))then
		NPC.DeleteNPCCharacter(30364);
		return;
	end
	commonlib.echo("======self.HatchIsOpened()1");
	commonlib.echo(self.HatchIsOpened());
	commonlib.echo(self.HatchIsFinished());
	commonlib.echo(self.FeedIsOpened());
	commonlib.echo(self.FeedIsFinished());
	if(self.HatchIsOpened() and not self.HatchIsFinished())then
		--鸟蛋形状
		commonlib.echo("================swallow egg");
		-- change npc character model asset
		NPC.ChangeModelAsset(30364, nil, "model/06props/v5/03quest/Roost/Roost.x");
		return;
	end
	if(self.HatchIsFinished() and not self.FeedIsFinished())then
		--雏燕形状
		commonlib.echo("================swallow young");
		-- change npc character model asset
		NPC.ChangeModelAsset(30364, nil, "model/06props/v5/03quest/Roost/Roost_bb.x");
		return;
	end
end
function SwallowBaby.ShowPage_Hatch()
	local self = SwallowBaby; 
	self.GetHatchAndFeedTime(function(msg)
			local clientdata = msg.clientdata;
			self.CheckTime(clientdata);
			
			local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
			System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/NPCs/SnowArea/30364_SwallowBaby_egg_panel.html", 
					name = "SwallowBaby.ShowPage_Hatch", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					style = CommonCtrl.WindowFrame.ContainerStyle,
					zorder = 1,
					allowDrag = false,
					isTopLevel = true,
					directPosition = true,
						align = "_ct",
						x = -820/2,
						y = -512/2,
						width = 820,
						height = 512,
				});	
		end)
end
function SwallowBaby.ShowPage_Feed()
	local self = SwallowBaby; 
	self.GetHatchAndFeedTime(function(msg)
			local clientdata = msg.clientdata;
			self.CheckTime(clientdata);
			
			local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
			System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/NPCs/SnowArea/30364_SwallowBaby_young_panel.html", 
					name = "SwallowBaby.ShowPage_Feed", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					style = CommonCtrl.WindowFrame.ContainerStyle,
					zorder = 1,
					allowDrag = false,
					isTopLevel = true,
					directPosition = true,
						align = "_ct",
						x = -820/2,
						y = -512/2,
						width = 820,
						height = 512,
				});
	end)
		
	
end
--在和燕子妈妈对话结束的时候 标准孵化鸟蛋任务开始
function SwallowBaby.IsAccepted()
	local self = SwallowBaby; 
	return hasGSItem(50287);
end
--标记孵化开始
function SwallowBaby.TagHatch()
	local self = SwallowBaby; 
	if(not self.IsAccepted())then
		--标记孵化鸟蛋任务开始
		ItemManager.PurchaseItem(50287, 1, function(msg) end, function(msg)
			if(msg and msg.issuccess)then
				self.ShowPage_Hatch();
			end
		end,nil,"none");
	else
		self.ShowPage_Hatch();
	end
end
--显示喂养页面
function SwallowBaby.TagFeed()
	local self = SwallowBaby; 
	self.ShowPage_Feed();
end
function SwallowBaby.HatchIsOpened()
	local self = SwallowBaby; 
	local has,__,__,copies = hasGSItem(50291);
	copies = copies or 0;
	if(has and copies < 3)then
		return true,copies;
	end
	return false,copies;
end
function SwallowBaby.HatchIsFinished()
	local self = SwallowBaby; 
	return hasGSItem(50288);
end
function SwallowBaby.FeedIsOpened()
	local self = SwallowBaby; 
	local has,__,__,copies = hasGSItem(50289);
	copies = copies or 0;
	if(has and copies < 3)then
		return true,copies;
	end
	return false,copies;
end
--喂食任务完成就代表着 获取燕子的任务全部完成
function SwallowBaby.FeedIsFinished()
	local self = SwallowBaby; 
	return hasGSItem(50290);
end
--喂食达到最大次数，但是还没有执行最后的确认
function SwallowBaby.FeedIsSaturation()
	local self = SwallowBaby;
	local opened,num = self.FeedIsOpened();
	if(num and num >= 3)then
		return true;
	end
end
function SwallowBaby.CanHatch()
	local self = SwallowBaby; 
	return self.can_hatch;
end
function SwallowBaby.CanFeed()
	local self = SwallowBaby; 
	return self.can_feed;
end
function SwallowBaby.HatchNum()
	local self = SwallowBaby;
	local opened,num = self.HatchIsOpened();
	return num;
end
function SwallowBaby.FeedNum()
	local self = SwallowBaby;
	local opened,num = self.FeedIsOpened();
	return num;
end
--孵化，如果不是最后一次，刷新页面，显示孵化成功的文字
--如果是最后一次，鸟蛋消失，小燕子出现
function SwallowBaby.DoHatch()
	local self = SwallowBaby;
	local opened,num = self.HatchIsOpened();
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30364);
	commonlib.echo("======self.CanHatch()");
	commonlib.echo(self.CanHatch());
	commonlib.echo(num);
	if(not self.CanHatch())then
		memory.hatch_click = true;
		self.RefreshPage();
		return
	end
	if(num < 3)then
		commonlib.echo("=========before PurchaseItem in SwallowBaby.DoHatch");
		ItemManager.PurchaseItem(50291, 1, function(msg) end, function(msg)
			commonlib.echo("=========after PurchaseItem in SwallowBaby.DoHatch");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				--标记成功调温一次
				memory.hatch_succeed = true;
				memory.hatch_click = true;
				
				local day,seconds = self.GetNow();
				local time = {
					hatch_day = day,
					hatch_seconds = seconds,
				}
				self.SetHatchAndFeedTime(time);
				if(num == 2)then
					--孵化完成
					commonlib.echo("=========before ExtendedCost in SwallowBaby.DoHatch");
					ItemManager.ExtendedCost(352, nil, nil, function(msg)end, function(msg) 
						commonlib.echo("=========after ExtendedCost in SwallowBaby.DoHatch");
						commonlib.echo(msg);
						if(msg and msg.issuccess)then
							--鸟蛋消失 小燕子出现
							self.UpdateSwallowBabyState();
							--刷新对话页面
							self.RefreshPage();
						end
					end);
				else
					self.RefreshPage();
				end
			end
		end,nil,"none");
	end
end

function SwallowBaby.DoFeed()
	local self = SwallowBaby;
	local opened,num = self.FeedIsOpened();
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30364);
	commonlib.echo("======self.CanFeed()");
	commonlib.echo(self.CanFeed());
	commonlib.echo(num);
	if(not self.CanFeed() or not self.HasEnougthBug())then
		memory.feed_click = true;
		self.RefreshPage();
		return
	end
	if(num < 3)then
		commonlib.echo("=========before SwallowBaby.DoFeed");
		ItemManager.ExtendedCost(353, nil, nil, function(msg)end, function(msg) 
			commonlib.echo("=========after SwallowBaby.DoFeed");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				--标记成功喂食一次
				memory.feed_succeed = true;
				memory.feed_click = true;
				
				local day,seconds = self.GetNow();
				local time = {
					feed_day = day,
					feed_seconds = seconds,
				}
				self.SetHatchAndFeedTime(time);
				self.RefreshPage();
			end
		end,"none");
	end
end
function SwallowBaby.DoFinished()
	local self = SwallowBaby; 
	if(not self.FeedIsSaturation())then return end
	--刷新对话页面
	commonlib.echo("=========before SwallowBaby.DoFeed Finished");
	ItemManager.ExtendedCost(354, nil, nil, function(msg)end, function(msg) 
		commonlib.echo("=========after SwallowBaby.DoFeed Finished");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			--喂食完成
			--燕子和鸟窝从当前场景消失 小燕子放入用户家园
			self.UpdateSwallowBabyState();
		end
	end);	
end
function SwallowBaby.HasEnougthBug()
	local self = SwallowBaby; 
	local has,__,__,copies = hasGSItem(17009);
	copies = copies or 0;
	if(copies > 0)then
		return true;
	end
end
function SwallowBaby.RefreshPage()
	local self = SwallowBaby; 
	UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
		if(elapsedTime == 500) then
			MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30364, nil, true);
			self.Clear_PanelClick();
		end
	end);
end
--调温成功一次
function SwallowBaby.HatchOnceSucceed()
	local self = SwallowBaby; 
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30364);
	local hatch_succeed = memory.hatch_succeed;
	if(self.CanHatch() and hatch_succeed)then
		return true;
	end
end
--喂食成功一次
function SwallowBaby.FeedOnceSucceed()
	local self = SwallowBaby; 
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30364);
	local feed_succeed = memory.feed_succeed;
	if(self.CanFeed() and feed_succeed)then
		return true;
	end
end
--清除 调温成功一次的标记
--清除 喂食成功一次的标记
--清除 点击调温按钮 或者 喂小青虫按钮
function SwallowBaby.Clear_PanelClick()
	local self = SwallowBaby; 
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30364);
	if(memory.hatch_succeed)then
		memory.hatch_succeed = nil;
	end
	if(memory.feed_succeed)then
		memory.feed_succeed = nil;
	end
	if(memory.hatch_click)then
		memory.hatch_click = nil;
	end
	if(memory.feed_click)then
		memory.feed_click = nil;
	end
end
--[[
return
time = {
	hatch_day = "2010-03-01",
	hatch_seconds = 100,
	feed_day = "2010-03-01",
	feed_seconds = 100,
}
]]
function SwallowBaby.GetHatchAndFeedTime(callbackFunc)
	local self = SwallowBaby; 
	local ItemManager = System.Item.ItemManager;
	local gsid = 50287;
	local bagFamily = 30011;
	ItemManager.GetItemsInBag(bagFamily, "GetHatchAndFeedTime", function(msg)
		local hasGSItem = ItemManager.IfOwnGSItem;
		local hasItem,guid = hasGSItem(gsid);
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				local clientdata = item.clientdata;
				commonlib.echo("================GetHatchAndFeedTime clientdata");
				commonlib.echo(clientdata);
				if(clientdata == "")then
					clientdata = "{}"
				end
				commonlib.echo("==========before commonlib.LoadTableFromString(clientdata) in GetHatchAndFeedTime");
				clientdata = commonlib.LoadTableFromString(clientdata);
				commonlib.echo("==========after commonlib.LoadTableFromString(clientdata) in GetHatchAndFeedTime");
				commonlib.echo(clientdata);
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
						clientdata = clientdata,--返回一个table
					});
				end
			end
		end
	end, "access plus 20 minutes");
end
function SwallowBaby.SetHatchAndFeedTime(clientdata,callbackFunc)
	local self = SwallowBaby; 
	if(not clientdata)then return end
	local ItemManager = System.Item.ItemManager;
	local gsid = 50287;
	local bagFamily = 30011;
	commonlib.echo("=========before SetHatchAndFeedTime");
	commonlib.echo(clientdata);
	ItemManager.GetItemsInBag(bagFamily, "SetHatchAndFeedTime", function(msg)
			local hasGSItem = ItemManager.IfOwnGSItem;
			local hasItem,guid = hasGSItem(gsid)
			if(hasItem)then
				local item = ItemManager.GetItemByGUID(guid);
				if(item)then
					--序列化
					clientdata = commonlib.serialize_compact2(clientdata);
					commonlib.echo("=========after serialization in SetHatchAndFeedTime");
					commonlib.echo(clientdata);
					ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
						commonlib.echo("============after SetChristmasSocksTag");
						commonlib.echo(msg_setclientdata);
						if(callbackFunc and type(callbackFunc) == "function")then
							callbackFunc({
								
							});
						end
					end);
				end
			end
		end, "access plus 20 minutes");
end
--是否超过一个小时
--@param day: "2010-03-01"
--@param seconds: 100
function SwallowBaby.IsOutHour(day,seconds)
	local self = SwallowBaby;
	if(not day or not seconds)then return end
	local today,hour = commonlib.timehelp.GetLocalTime();
	local now_seconds = commonlib.timehelp.GetSecondsFromStr(hour);
	local isSameDate = commonlib.timehelp.IsSameDate(day,today);
	if(not isSameDate)then
		return true;
	else
		if( (now_seconds - seconds) >= 3600 )then
			return true;
		end
	end
end
function SwallowBaby.GetNow()
	local self = SwallowBaby;
	local today,hour = commonlib.timehelp.GetLocalTime();
	local now_seconds = commonlib.timehelp.GetSecondsFromStr(hour);
	return today,now_seconds;
end