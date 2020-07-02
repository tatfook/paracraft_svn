--[[
Title: FollowPetState
Author(s): Leio
Date: 2009/10/13
Desc:
说话：
	欢迎 1次
	植物成长情况 1次
	访客情况 1次
	随机冒泡 3分钟%30概率 一次

	编辑状态下：取消显示
	恢复浏览状态：只触发随机冒泡
初始化 前三种状态的语言
启动timer,3分钟后清空 前三种状态语言，开始触发随机冒泡

启动第n个说话
当走到主人身边时
	说话
	开启说话周期timer，结束后，宠物离开，n = n + 1; 如果 小于 3 返回到开始，否则启动 random timer
当random timer 达到一个周期
	走到主人身边
	说话
	开启说话周期，结束后，宠物离开
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/FollowPetState.lua");
local follow_pet_state = Map3DSystem.App.HomeLand.FollowPetState:new{
	identity = "follow_guest", --follow_master or follow_guest
	plant_datasource = {
		{ name = "1", has_fruit = nil, is_bug = nil, is_drought = nil, is_normal = true, },
		{ name = "2", has_fruit = nil, is_bug = nil, is_drought = true, is_normal = nil, },
		{ name = "3", has_fruit = nil, is_bug = true, is_drought = nil, is_normal = nil, },
		{ name = "4", has_fruit = true, is_bug = nil, is_drought = nil, is_normal = nil, },
		{ name = "5", has_fruit = true, is_bug = true, is_drought = true, is_normal = true, },
	},
	follow_pet_datasource = {
		{ pet_type = "a",gsid = 1, bag_index = 1, init_state = nil,},
		{ pet_type = "c",gsid = 2, bag_index = 2, init_state = nil,},
		{ pet_type = "b",gsid = 3, bag_index = 3, init_state = nil,},
	},
	visit_datasource = {
		has_gift = true,
		has_visitor = true,
	},
}
follow_pet_state:Start();
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/FollowPetState.lua");
local nid = 24216;
local nid = nil;
local follow_pet_state = Map3DSystem.App.HomeLand.FollowPetState:new{
			nid = nid,
		}
				
local plant_datasource = {
						{ name = "1", has_fruit = nil, is_bug = nil, is_drought = nil, is_normal = true, },
						{ name = "2", has_fruit = nil, is_bug = nil, is_drought = true, is_normal = nil, },
						{ name = "3", has_fruit = nil, is_bug = true, is_drought = nil, is_normal = nil, },
						{ name = "4", has_fruit = true, is_bug = nil, is_drought = nil, is_normal = nil, },
						{ name = "5", has_fruit = true, is_bug = true, is_drought = true, is_normal = true, },
					}
follow_pet_state:SetPlantData(plant_datasource);
follow_pet_state:SetVisitedData(true);
follow_pet_state:SetGiftData(true);

Map3DSystem.App.HomeLand.FollowPetState.LoadPets(nid,function(msg)
	if(msg and msg.data)then
		local follow_pet_datasource = msg.data;
		follow_pet_state:SetPetsData(follow_pet_datasource);
	end
end);

follow_pet_state:ResetPetItemState();
follow_pet_state:Pause();
follow_pet_state:Resume();
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/FollowPetMsg.lua");
local FollowPetState = {
	name = "FollowPetState_instance",
	nid = nil,--宠物的拥有者
	identity = "follow_master", --follow_master or follow_guest
	plant_datasource = nil,--植物的成长信息，it is a table
	follow_pet_datasource = nil,--跟随宠物的列表
	visit_datasource = nil,--访问情况
	
	normal_msg = nil,-- 欢迎 植物成长情况 访客情况
	normal_speak_duration = 5000,--milliseconds 说话周期
	random_speak_duration = 180000,--触发随机冒泡的周期
	check_position_duration = 100,--监听 主人 和宠物之间的距离的刷新周期
	random_speak_ratio = 30,--随机冒泡的几率
	
	normal_speak_timer = nil,
	random_speak_timer = nil, --随机冒泡的timer
	check_position_timer = nil, --随机冒泡的timer
	
	normal_speak_pointer = nil,--当前语言在哪里
	speak_len = 3,--1 or 3 欢迎 植物成长情况 访客情况 3种状态
	
	ai_radius = 3,--感应半径，如果小于它就可以说话了
	cur_msg = nil,--当前要说的话
	
	pause = false,--是否暂停
	loaded = {
		pets = false,
		plant = false,
		visited = false,
		gift = false,
		inhome = false,
	},
	follow_pet_type_map = {
		[10104] = "a",-- 罗莉猫
		[10102] = "a",-- 大眼蜂
		[10106] = "b",-- 汪汪狗
		[10108] = "b",-- 小蓝马
		[10110] = "c",-- 皇冠蛇
		[10109] = "c",-- 菜头
		[10101] = "c",-- 葱头
		[10103] = "c",-- 蘑咕噜
		[10105] = "d",-- 西瓜仔
		[10107] = "d",-- 跳蚤鸡
	},
	
	build_random_arr = true,
}
commonlib.setfield("Map3DSystem.App.HomeLand.FollowPetState",FollowPetState);
function FollowPetState:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
--加载宠物列表
function FollowPetState.LoadPets(nid, callbackFunc, cache_policy)
	local ItemManager = Map3DSystem.Item.ItemManager;
	local bag = 10010;
	if(not nid or nid == Map3DSystem.User.nid)then
			
		ItemManager.GetItemsInBag(bag, "", function(msg)
			if(msg and msg.items)then
				local follow_pet_datasource = {};
				local items = msg.items;
				local k,v;
				commonlib.echo("===================GetAITemplateName");
				for k,v in ipairs(items) do
					local gsid = v["gsid"];
					local pet_type = FollowPetState.follow_pet_type_map[gsid] or "";
					local pet_item = ItemManager.GetItemByBagAndOrder(bag, k);--获取宠物实例
					local init_state = "idle";
					if(pet_item)then
						init_state = pet_item:GetAITemplateName();
						commonlib.echo(init_state);
					end
					local item = {
						gsid = gsid,
						bag_index = k,
						pet_type = pet_type,
						init_state = init_state,--follow or idle
					}
					--初始化 跟随宠物列表
					table.insert(follow_pet_datasource,item);
				end
				
				if(callbackFunc and type(callbackFunc) == "function")then
					local msg = {
						data = follow_pet_datasource,
					}
					callbackFunc(msg);
				end
			end
		end, cache_policy or "access plus 0 day");
	else
		
		Map3DSystem.Item.ItemManager.GetItemsInOPCBag(nid,10010, "", function(msg)
			if(msg and msg.items)then
				local follow_pet_datasource = {};
				local items = msg.items;
				local k,v;
				for k,v in ipairs(items) do
					local gsid = v["gsid"];
					local pet_type = FollowPetState.follow_pet_type_map[gsid] or "";
					local pet_item = ItemManager.GetOPCItemByBagAndOrder(nid,bag, k);--获取宠物实例
					local init_state = "idle";
					if(pet_item)then
						init_state = pet_item:GetAITemplateName();
					end
					local item = {
						gsid = gsid,
						bag_index = k,
						pet_type = pet_type,
						init_state = init_state,--follow or idle
					}
					--初始化 跟随宠物列表
					table.insert(follow_pet_datasource,item);
				end
				if(callbackFunc and type(callbackFunc) == "function")then
					local msg = {
						data = follow_pet_datasource,
					}
					callbackFunc(msg);
				end
			end
		end, cache_policy or "access plus 0 day");
	end
end
function FollowPetState:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	
	self.normal_speak_timer = commonlib.Timer:new{
			callbackFunc = FollowPetState.CallBack_Normal,
		}
	self.normal_speak_timer.holder = self;
	self.random_speak_timer = commonlib.Timer:new{
			callbackFunc = FollowPetState.CallBack_Random,
		}
	self.random_speak_timer.holder = self;
	self.check_position_timer = commonlib.Timer:new{
			callbackFunc = FollowPetState.CallBack_CheckPosition,
		}
	self.check_position_timer.holder = self;
	
	--通过nid区分身份
	if(not self.nid or self.nid == Map3DSystem.User.nid)then
		self.identity = "follow_master";
	else
		self.identity = "follow_guest";
	end
	--如果是主人身份，有三种状态需要播放
	if(self.identity == "follow_master")then
		self.speak_len = 3;
	else
		--如果是游客身份，只有一种正常的播放状态，welcome
		self.speak_len = 1;
	end
	
	--等待load
	self.loaded = {
		pets = false,
		plant = false,
		visited = false,
		gift = false,
		inhome = false,
	};
	--访问 和 礼物情况，默认是没有
	self.visit_datasource = {
		has_visitor = false,
		has_gift = false,
	}
	
	self.normal_speak_pointer = 1;
	--加载语言库
	Map3DSystem.App.HomeLand.FollowPetMsg.Load();
end
function FollowPetState.CallBack_Normal(timer)
	if(timer and timer.holder)then
		local self = timer.holder;
		self:AwayFromUser()
		--如果正常说话 还有
		if(self.normal_speak_pointer < self.speak_len)then
			self.normal_speak_pointer = self.normal_speak_pointer + 1;
			self:Speaking_Normal();
			
		else
			--开始随机冒泡监听，180秒后执行一次
			self.random_speak_timer:Change(self.random_speak_duration,nil);
		end
	end
end
--随机冒泡的回调函数
function FollowPetState.CallBack_Random(timer)
	if(timer and timer.holder)then
		local self = timer.holder;
		self:Speaking_Random();
	end
end
--检测 主人 和 宠物的距离，如果达到一定范围就认为可以说话了
function FollowPetState.CallBack_CheckPosition(timer)
	if(timer and timer.holder)then
		local self = timer.holder;
		local player_obj = ParaScene.GetPlayer();
		
		local pet_obj;
		local item = self:GetPetItemByMsg();
		if(item)then
			local name = item:GetSceneObjectNameInHomeland();
			pet_obj = ParaScene.GetCharacter(name);
		end
		if(player_obj and pet_obj and player_obj:IsValid() and pet_obj:IsValid())then
			local dist = player_obj:DistanceTo(pet_obj);
			if(dist < self.ai_radius)then
				--已经达到主人身边，停止距离监听
				timer:Change();
				self:DoSpeak();
			end
		end
	end
end
function FollowPetState:SetPetsData(v)
	commonlib.echo("============================get follow_pet_datasource");
	if(not v)then return end
	self.follow_pet_datasource = v;
	self.loaded["pets"] = true;
	self:Start();
end
--可以为空，空代表没有植物
function FollowPetState:SetPlantData(v)
	commonlib.echo("============================get plant_datasource");
	self.plant_datasource = v;
	self.loaded["plant"] = true;
	self:Start();
end
function FollowPetState:SetVisitedData(v)
	commonlib.echo("============================get visit_datasource visited");
	self.visit_datasource["has_visitor"] = v;
	self.loaded["visited"] = true;
	self:Start();
end
function FollowPetState:SetGiftData(v)
	commonlib.echo("============================get visit_datasource gift");
	self.visit_datasource["has_gift"] = v;
	self.loaded["gift"] = true;
	self:Start();
end
function FollowPetState:SetInHome()
	commonlib.echo("============================in home");
	self.loaded["inhome"] = true;
	self:Start();
end
function FollowPetState:DoSpeak()
	--kill the timer
	self.normal_speak_timer:Change();
	--显示说话的语言
	local item = self:GetPetItemByMsg();
	if(item)then
		local name = item:GetSceneObjectNameInHomeland();
		local content = self.cur_msg.content;
		if(name and content and content ~= "")then
			headon_speech.Speek(name, content, 5, true)
		end
	end
	--开始周期说话监听
	self.normal_speak_timer:Change(self.normal_speak_duration,nil);
end
--停止所有的timer
function FollowPetState:StopAllTimers()
	self.normal_speak_timer:Change();
	self.random_speak_timer:Change();
	self.check_position_timer:Change();
end
function FollowPetState:Start()
	if( not self:CanStart() )then return end
	commonlib.echo("==========================FollowPetState:Start");
	self:Reset();
	--立即移动第一个宠物
	self:Speaking_Normal();
	
end
--重新加载宠物列表
--在说话的过程当中，有可能改变了可以说话的宠物的数量
function FollowPetState:ReloadPetItems()
	--停止监听
	self:StopAllTimers();
	--恢复所有宠物的初始状态
	self:ResetPetItemState();
	Map3DSystem.App.HomeLand.FollowPetState.LoadPets(self.nid,function(msg)
		if(msg and msg.data)then
			--改变宠物列表的数据结构
			self.follow_pet_datasource = msg.data;
			--从头开始说话
			self.normal_speak_pointer = 1;
			--重置要说话的列表
			self.normal_msg = self:MatchMsg();
			--如果满足说话的条件
			if(self:CanStart())then
				--立即移动第一个宠物
				self:Speaking_Normal();
			end
		end
	end, "access plus 10 minutes");
end
--重新开始，没有改变宠物列表的数据结构follow_pet_datasource
function FollowPetState:Reset()
	--停止监听
	self:StopAllTimers();
	--恢复所有宠物的初始状态
	self:ResetPetItemState();
	self.normal_speak_pointer = 1;
	--重置要说话的列表
	self.normal_msg = self:MatchMsg();
	
	self.pause = false;
end
--暂停
function FollowPetState:Pause()
	self.pause = true;
	--停止监听
	self:StopAllTimers();
	
	--恢复所有宠物的初始状态
	self:ResetPetItemState();
end
--恢复说话
function FollowPetState:Resume()
	self.pause = false;
	if(self:IsNormalSpeaking())then
		--继续正常说话
		self:Speaking_Normal();
	else
		--启动随机说话
		self.random_speak_timer:Change(self.random_speak_duration,self.random_speak_duration);
	end
end
--停止一切
function FollowPetState:Stop()
	--恢复所有宠物的初始状态
	self:ResetPetItemState();
	
	self:StopAllTimers();
	
	self.pause = false;
	
	self.normal_msg = nil;
	self.plant_datasource = nil;
	self.follow_pet_datasource = nil;
	--等待load
	self.loaded = {
		pets = false,
		plant = false,
		visited = false,
		gift = false,
		inhome = false,
	};
	--访问 和 礼物情况，默认是没有
	self.visit_datasource = {
		visited = false,
		gift = false,
	}
	self.normal_speak_pointer = 1;
end
--是否处于正常说话状态
function FollowPetState:IsNormalSpeaking()
	if(self.normal_speak_pointer <= self.speak_len)then
		return true;
	end
end
function FollowPetState:Speaking_Normal()
	if(self.normal_msg)then
		local msg = self.normal_msg[self.normal_speak_pointer];
		if(msg)then
			self.cur_msg = msg;
			if(self.normal_speak_pointer == 1)then
				self:RunToUser();
			else
				self:MoveToUser();
			end
			--立即检测主人和宠物间的距离
			self.check_position_timer:Change(self.check_position_duration,self.check_position_duration);
		end
	end	
end
function FollowPetState:Speaking_Random()
	local r = math.random(1,100);
	if(r <= self.random_speak_ratio)then
		local msg = self:MatchRandomMsg();
		self.cur_msg = msg;
		self:MoveToUser()
		--立即检测主人和宠物间的距离
		self.check_position_timer:Change(self.check_position_duration,self.check_position_duration);
	end
end
--直接飞到主人身边
function FollowPetState:RunToUser()
	local item = self:GetPetItemByMsg();
	if(item)then
		local pet = item:GetSceneObjectInHomeland();
		item:ApplyFollow_AITemplate();
		local player = ParaScene.GetPlayer();
		if( pet and pet:IsValid() == true and player and player:IsValid() )then
			local x, y , z = player:GetPosition();
			x = x + 5 * math.cos(player:GetFacing());
			z = z - 5 * math.sin(player:GetFacing());
			pet:SetPosition(x,y,z);
		end
	end
end
--开始移动到主人身边
function FollowPetState:MoveToUser()
	local item = self:GetPetItemByMsg();
	if(item)then
		item:ApplyFollow_AITemplate();
	end
end
--从主人身边离开
function FollowPetState:AwayFromUser()
	local item = self:GetPetItemByMsg();
	if(item)then
		item:ApplyIdle_AITemplate();
	end
end
--获取宠物实例
function FollowPetState:GetPetItemByMsg()
	local msg = self.cur_msg;
	if(msg)then
		local bag_index = msg.bag_index;
		if(bag_index)then
			local item = self:GetPetItem(bag_index);
			return item;
		end
	end
end
--如果没有宠物列表不能启动
function FollowPetState:CanStart()
	--如果暂停 或者 三类数据没有加载完 返回false
	if(self.pause or not self.loaded["pets"] or not self.loaded["plant"] or not self.loaded["visited"] or not self.loaded["gift"] or not self.loaded["inhome"] )then return end
	if(self.follow_pet_datasource)then
		local len = #self.follow_pet_datasource;
		if(len > 0)then
			return true;
		end
	end
end
--匹配动物--语言
function FollowPetState:MatchMsg()
	local list = self:GetBroadcasters(self.speak_len);
	--commonlib.echo(list);
	if(list)then
		local msg = {};
		local k,v;
		local len = #list;
		for k = 1,self.speak_len do
			local index = math.mod(k - 1,len) + 1;
			local v = list[index];
			local gsid = v["gsid"]
			local pet_type = v["pet_type"];
			local bag_index = v["bag_index"];
			local key;
			local content = "";
			if(k == 1)then
				key,content = self:GetWelcomeMsg(pet_type);
			elseif(k == 2)then
				key,content = self:GetPlantMsg();
			elseif(k == 3)then
				key,content = self:GetVisitedMsg();
			end
			local item = {
					gsid = gsid,
					pet_type = pet_type,
					bag_index = bag_index,
					content = content,
					key = key,
			}
			table.insert(msg,item);
		end
		commonlib.echo("FollowPetState:MatchMsg:");
		commonlib.echo(msg);
		return msg;
	end
end
--返回播报员
--@param num:返回的长度
function FollowPetState:GetBroadcasters(num)
	if(self.follow_pet_datasource)then
		local clone_list = commonlib.deepcopy(self.follow_pet_datasource);
		local len = #clone_list;
		if(len == 0)then return end
		--TODO:打散clone_list顺序
		if(self.build_random_arr)then
			clone_list = self:GetRandomArr(clone_list);
		end
		local list = {};
		local k;
		for k = 1,num do
			local index = math.mod(k-1,len) + 1;
			local item = clone_list[index];
			table.insert(list,item);
		end
		return list;
	end
end
--获取欢迎的语言
function FollowPetState:GetWelcomeMsg(pet_type)
	local identity,state,condition = self.identity,"welcome",pet_type;
	local key,content = Map3DSystem.App.HomeLand.FollowPetMsg.GetMsg(identity,state,condition);
	return key,content;
end
--根据优先级，获取播报植物的语言
function FollowPetState:GetPlantMsg()
	--默认是没有植物
	local identity,state,condition = self.identity,"plant","is_nothing";
	local plantname = "";
	--如果有植物的话
	if(self.plant_datasource)then
		--随机找出一个
		local len = #self.plant_datasource;
		local i = math.random(1,len);
		local p = self.plant_datasource[i];
		if(p["has_fruit"])then
			condition = "has_fruit";
		elseif(p["is_bug"])then
			condition = "is_bug";
		elseif(p["is_drought"])then
			condition = "is_drought";
		else
			condition = "is_normal";
		end
		plantname = p["name"];
	end
	local key,content = Map3DSystem.App.HomeLand.FollowPetMsg.GetMsg(identity,state,condition);
	if(content)then
		content = string.gsub(content, "%[plantname%]", plantname);
	end
	return key,content;
end
--根据优先级，获取播报访客情况的语言
function FollowPetState:GetVisitedMsg()
	--默认是没有访问信息
	local identity,state,condition = self.identity,"visited","is_nothing";
	--如果有访问信息的话
	if(self.visit_datasource)then
		local p = self.visit_datasource;
		if(p["has_gift"])then
			condition = "has_gift";
		elseif(p["has_visitor"])then
			--这种情况数据暂时没有
			condition = "has_visitor";
		end
	end
	local key,content = Map3DSystem.App.HomeLand.FollowPetMsg.GetMsg(identity,state,condition);
	return key,content;
	
end
--匹配动物--随机语言
function FollowPetState:MatchRandomMsg()
	local list = self:GetBroadcasters(1);
	if(list and list[1])then
		local b = list[1];
		local gsid = b["gsid"];
		local pet_type = b["pet_type"];
		local bag_index = b["bag_index"];
		local identity,state,condition = self.identity,"random","random";
		local key,content = Map3DSystem.App.HomeLand.FollowPetMsg.GetMsg(identity,state,condition);
		
		local item = {
				gsid = gsid,
				pet_type = pet_type,
				bag_index = bag_index,
				content = content,
				key = key,
			}
		return item;
	end
end
--重新找回所有宠物的初始状态
function FollowPetState:ResetPetItemState()
	local item = self:GetPetItemByMsg();
	if(item)then
		local name = item:GetSceneObjectNameInHomeland();
		if(name)then
			headon_speech.Speek(name, "", 0)
		end
	end
	if(self.follow_pet_datasource)then
		--commonlib.echo("================ResetPetItemState:");
		local k,item;
		for k,item in ipairs(self.follow_pet_datasource) do
			local init_state = item.init_state;
			local index = item.bag_index;
			local p = self:GetPetItem(index);
			--commonlib.echo(init_state);
			if(p)then
				if(init_state == "idle")then
					p:ApplyIdle_AITemplate();
				else
					p:ApplyFollow_AITemplate();
				end
				local name = p:GetAITemplateName();
				--commonlib.echo(name);
				--commonlib.echo("====");
			end
		end	
	end
end
--获取跟随宠物
function FollowPetState:GetPetItem(index)
	local bag = 10010;
	local ItemManager = Map3DSystem.Item.ItemManager;
	local item;
	if(self.identity == "follow_master")then
		item = ItemManager.GetItemByBagAndOrder(bag, index);
	else
		item = ItemManager.GetOPCItemByBagAndOrder(self.nid,bag, index);
	end
	return item;
end
function FollowPetState:GetRandomArr(arr)
	if(not arr)then return end
	local len = table.getn(arr);
	local new_arr = {};
	local k;
	for k = 1,len do
		local now_len = table.getn(arr);
		local n = math.floor(math.random() * now_len + 1);
		table.insert(new_arr,arr[n]);
		table.remove(arr,n);
	end
	return new_arr;
end