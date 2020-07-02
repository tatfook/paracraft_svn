--[[
Title: PetState
Author(s): Leio
Date: 2009/4/8
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/PetState.lua");
local pet = Map3DSystem.App.HomeLand.PetState:new{
	identity = "master",
	state = "ride",
};
local bean = {
	["friendliness"]=100,	["strong"]=50,	["nextlevelfr"]=0,	["cleanness"]=50,	["petid"]=2,	["health"]=0,	["nickname"]="",	["level"]=20,	["birthday"]="05/15/2009 11:31:08",	["mood"]=50,
}
pet:BindBean(bean);
pet:Start();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/PetMsg.lua");
local PetState = {
	name = "PetState_instance",
	identity = "",
	level = "",
	state = "",-- follow or ride or home
	pre_state = "",-- 上一个状态
	
	timerInterval = 5000,-- 毫秒
	--
	curMinute = 0,
	totalMinute = 60000,-- 毫秒
	odds = 30,
	const_hunger = 150,
	const_dirty = 150,
	const_depressed = 150,
	const_singleLevelGrownMaxValue = 500,--单级成长最大值
	const_healthy = 0,
	const_sick = 1,
	const_dead = 2,
	const_eggLevel = 2,
	const_childLevel = 7,
	const_adultLevel = 8,
	const_minAIRadius = 5,-- 智能感应最小距离
	const_waitDuration = "00:00:01",--在被送回家的时候，需要说话，这是等待说完话的时间
	TimerHandler_Short = nil,
	TimerHandler_Long = nil,
	
	speakLifeTime = 2000,--毫秒，说话显示的时间
	
	--[[
	支持的事件名称：
		TimerHandler_Short
		TimerHandler_Long
	--]]
	events = nil,--事件池子
	
	timers = {},--timer池子
}
commonlib.setfield("Map3DSystem.App.HomeLand.PetState",PetState);
function PetState:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function PetState:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
	self.events = {};
	Map3DSystem.App.HomeLand.PetMsg.Load();
	local allConst = Map3DSystem.App.HomeLand.PetMsg.allConst or {};
	self.timerInterval = allConst.SpeakInterval or self.timerInterval;
	self.totalMinute = allConst.RefreshDuration or self.totalMinute;
	self.odds = allConst.SpeakOdds or self.odds;
	self.const_hunger = allConst.Hunger or self.const_hunger;
	self.const_dirty = allConst.Dirty or self.const_dirty;
	self.const_depressed = allConst.Depressed or self.const_depressed;
	self.const_healthy = allConst.Healthy or self.const_healthy;
	self.const_sick = allConst.Sick or self.const_sick;
	self.const_dead = allConst.Dead or self.const_dead;
	self.const_eggLevel = allConst.EggLevel or self.const_eggLevel;
	self.const_childLevel = allConst.ChildLevel or self.const_childLevel;
	self.const_adultLevel = allConst.AdultLevel or self.const_adultLevel;
	self.const_minAIRadius = allConst.MinAIRadius or self.const_minAIRadius;
	self.speakLifeTime = allConst.SpeakLifeTime or self.const_speakLifeTime;
	self.const_singleLevelGrownMaxValue = allConst.SingleLevelGrownMaxValue or self.const_singleLevelGrownMaxValue;
	self.const_waitDuration = allConst.WaitDuration or self.const_waitDuration;
	
	NPL.load("(gl)script/ide/timer.lua");
	PetState.timer = PetState.timer or commonlib.Timer:new({callbackFunc = PetState.TimeHandle});
	PetState.timer:Change(self.timerInterval, self.timerInterval);
end
function PetState:Start()
	self.timers[self.name] = true;
end
function PetState:Stop()
	self.timers[self.name] = nil;
end
function PetState:GetSpeakLifeTime()
	return self.speakLifeTime;
end
-- 设置身份，主人还是游客
function PetState:SetIdentity(combinedState)
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.identity = "master";		
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.identity = "master";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.identity = "guest";
	else
		self.identity = combinedState;
	end		
end
-- 获取坐骑的远程数据
--[[
["friendliness"]=0,["strong"]=0,["nextlevelfr"]=0,["cleanness"]=0,["petid"]=2,["health"]=0,["nickname"]="",["level"]=-1,["birthday"]="05/15/2009 11:31:08",["mood"]=0,
]]

function PetState:BindBean(bean)
	if(not bean)then return end
	self.bean = bean;
end
function PetState:GetIdentity()
	return self.identity;
end
-- 获取坐骑的等级
function PetState:GetLevel(_bean)
	if(_bean)then
		local level = _bean.level;
		level = tonumber(level);
		if(not level)then return end
		local s;
		if(level <= self.const_eggLevel)then
			--s = "egg";
			s = "child";
		elseif(level > self.const_eggLevel and level<= self.const_childLevel)then
			s = "child";
		else
			s = "adult";
		end
		return s;
	end
end
-- 获取坐骑的驾驭状态
--return follow or ride or home or fly
function PetState:GetState()
	return self.state;
end
--------------------------------------------------
-- 产生语言的方式有:
-- 改变坐骑的状态
-- 手工操作
-- Timer操作
-- 智能感应
--------------------------------------------------
-- 改变宠物的状态 follow or ride or home or fly
-- @param newState:follow or ride or home or fly
function PetState:ChangeState(newState)
	if(not newState)then return end
	self.pre_state = self.state;
	self.state = newState;
	
	local identity = self:GetIdentity();
	local level = self:GetLevel(self.bean);
	local state = "stateChange";
	local triggerMode = self.pre_state.."To"..self.state;
	local triggerCondition = "stateSuccessful";
	local msg = Map3DSystem.App.HomeLand.PetMsg.GetMsg(identity,level,state,triggerMode,triggerCondition);
	local key = string.format("%s_%s_%s_%s_%s",identity or "",level or "",state or "",triggerMode or "",triggerCondition or "");
	LOG.std("", "debug", "pet", {"get pet msg:",key,msg});	
	return msg;
end
-- 返回前一个状态
function PetState:SwapStateToBefore()
	local msg = self:ChangeState(self.pre_state);
	return msg;
end
-- 手工操作 
-- @param mode:feed bath playtoy medicine especial
function PetState:ManualOP(mode)
	-- FeedBefore FeedAfter BathBefore BathAfter PlayToyBefore PlayToyAfter MedicineBefore MedicineAfter DoEspecial
end
-- Timer操作 include:free calculate nearby5m
function PetState:AutoOP()
	--启动Timer
end
-- AI操作 include:nearby5m
function PetState:AIOP()
	--启动智能感应
end
--------------------------------------------------
function PetState:AddEventListener(event_type,event_holder,func)
	self.events[event_type] = {event_holder = event_holder,func = func};
end
function PetState:DispatchEvent(event_type,args)
	local func_table = self.events[event_type];
	if(func_table)then
		local event_holder = func_table.event_holder;
		local func = func_table.func;
		if(func and type(func) == "function")then
			func(event_holder,args);
		end
	end
end
function PetState.TimeHandle()
	local timers = PetState.timers;
	if(timers)then
		local name,v;
		for name,v in pairs(timers) do
			if(v)then
				local pet_state = CommonCtrl.GetControl(name);
				if(pet_state)then
					pet_state:TimeHandle_Internal()
				end
			end
		end
	end
end
function PetState:TimeHandle_Internal()
	self.curMinute = self.curMinute + self.timerInterval;
	if(self.curMinute >= self.totalMinute)then
		self.curMinute = 0;
		local triggerMode = "calculate";
		local triggerCondition = self:GetTriggerCondition();
		local msg = self:GetMsg(triggerMode,triggerCondition);
			
		self:DispatchEvent("TimerHandler_Long",msg)
	else
		local n = math.random(100);
		if(n > self.odds)then return end;
		local triggerMode = "free";
		local triggerCondition = self:GetTriggerCondition2();
		local msg = self:GetMsg(triggerMode,triggerCondition);
			
		self:DispatchEvent("TimerHandler_Short",msg)
	end
end
function PetState:GetTriggerCondition2()
	if(not self)then return end
	local triggerCondition;
	if(self:IsHunger())then
		triggerCondition = "hunger";
	elseif(self:IsDirty())then
		triggerCondition = "dirty";
	elseif(self:IsDepressed())then
		triggerCondition = "depressed";
	elseif(self:IsNormal())then
		triggerCondition = "normal";
	end
	return triggerCondition;
end

function PetState:GetTriggerCondition()
	if(not self)then return end
	local triggerCondition;
	if(self:IsDead())then
		triggerCondition = "dead";
	elseif(self:IsSick())then
		triggerCondition = "sick";
	elseif(self:IsHunger())then
		triggerCondition = "hunger";
	elseif(self:IsDirty())then
		triggerCondition = "dirty";
	elseif(self:IsDepressed())then
		triggerCondition = "depressed";
	elseif(self:IsNormal())then
		triggerCondition = "normal";
	end
	return triggerCondition;
end
function PetState:SpeakInSquare()
	local triggerMode = "nearby5m";
	local triggerCondition = self:GetTriggerCondition();
	local msg = self:GetMsg(triggerMode,triggerCondition);
	return msg;
end
--------------------------------------------------
function PetState:GetMsg(_triggerMode,_triggerCondition)
	if(not _triggerMode or not _triggerCondition)then return end
	local identity = self:GetIdentity();
	local level = self:GetLevel(self.bean);
	local state = self:GetState();
	local triggerMode = _triggerMode;
	local triggerCondition = _triggerCondition;
	local msg = Map3DSystem.App.HomeLand.PetMsg.GetMsg(identity,level,state,triggerMode,triggerCondition);
	local key = string.format("%s_%s_%s_%s_%s",identity,level,state,triggerMode,triggerCondition);
	LOG.std("", "debug", "pet", {"get pet msg:",key,msg});	
	return msg;
end
function PetState:GetLevelUpMsg(level)
	local msg = Map3DSystem.App.HomeLand.PetMsg.GetLevelUpMsg(level);
	LOG.std("", "debug", "pet", {"get pet level up msg:",level,msg});	
	return msg;
end
function PetState:FeedBefore()
	-- 如果不饿
	if(self:IsNotHunger())then
		local triggerMode = "feed";
		local triggerCondition = "feedFailed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
	---- 如果生病
	--if(self:IsSick())then
		--local triggerMode = "feed";
		--local triggerCondition = "stillSick";
		--local msg = self:GetMsg(triggerMode,triggerCondition);
		--return msg;
	--end
end
--操作别人的龙
function PetState:FeedBefore_ToGuest()
	--超过300
	if(self:FeedIsGreater())then
		local triggerMode = "feed";
		local triggerCondition = "feedFailed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
end
function PetState:FeedAfter()
		local triggerCondition;
		--如果生病
		if(self:IsSick())then
			triggerCondition = "stillSick";
		-- 如果还是饿
		elseif(self:IsHunger())then
			triggerCondition = "stillHunger";
		else
			triggerCondition = self:GetTriggerCondition();
			triggerCondition = "still"..(triggerCondition or "");
		end
		local triggerMode = "feed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
end
function PetState:BathBefore()
	--如果不脏
	if(self:IsNotDirty())then
		local triggerMode = "bath";
		local triggerCondition = "bathFailed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
	---- 如果生病
	--if(self:IsSick())then
		--local triggerMode = "bath";
		--local triggerCondition = "stillSick";
		--local msg = self:GetMsg(triggerMode,triggerCondition);
		--return msg;
	--end
end
--操作别人的龙
function PetState:BathBefore_ToGuest()
	--超过300
	if(self:BathIsGreater())then
		local triggerMode = "bath";
		local triggerCondition = "bathFailed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
end
function PetState:BathAfter()
		local triggerCondition;
		--如果生病
		if(self:IsSick())then
			triggerCondition = "stillSick";
		-- 如果还是脏
		elseif(self:IsDirty())then
			triggerCondition = "stillDirty";
		else
			triggerCondition = self:GetTriggerCondition();
			triggerCondition = "still"..(triggerCondition or "");
		end
		local triggerMode = "bath";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
end
function PetState:PlayToyBefore()
	-- 如果生病了
	if(self:IsSick())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed1";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	-- 如果饥饿
	elseif(self:IsHunger())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed2";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	--如果脏
	elseif(self:IsDirty())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed3";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
end
--操作别人的龙
function PetState:PlayToyBefore_ToGuest()
	-- 如果超过300
	if(self:PlayToyIsGreater())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	-- 如果生病了
	elseif(self:IsSick())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed1";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	-- 如果饥饿
	elseif(self:IsHunger())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed2";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	--如果脏
	elseif(self:IsDirty())then
		local triggerMode = "playToy";
		local triggerCondition = "toyFailed3";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
end
function PetState:PlayToyAfter()
		local triggerCondition;
		-- 还是郁闷
		if(self:IsDepressed())then
			triggerCondition = "stillDepressed";
		else
			triggerCondition = self:GetTriggerCondition();
			triggerCondition = "still"..(triggerCondition or "");
		end
		local triggerMode = "playToy";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
end
function PetState:MedicineBefore()
	-- 如果是正常，不需要喂药
	if(self:IsNormal())then
		local triggerMode = "medicine";
		local triggerCondition = "medicineFailed";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
	end
end
function PetState:MedicineAfter()
		local triggerCondition;
		triggerCondition = self:GetTriggerCondition();
		triggerCondition = "still"..(triggerCondition or "");
		
		local triggerMode = "medicine";
		local msg = self:GetMsg(triggerMode,triggerCondition);
		return msg;
end
function PetState:DoEspecial()
	-- 如果郁闷
	if(self:IsDepressed())then
		local triggerMode = "especial";
		local triggerCondition = "especialFailed";
		self:GetMsg(triggerMode,triggerCondition);
	end
end
--------------------------------------------
function PetState:IsNormal()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.health;
		if(v and v == self.const_healthy)then
			return true;	
		end
	end
end
function PetState:IsHunger()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.strong;
		if(v and v < self.const_hunger)then
			return true;	
		end
	end
end
function PetState:IsDirty()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.cleanness;
		if(v and v < self.const_dirty)then
			return true;	
		end
	end
end
function PetState:IsDepressed()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.mood;
		if(v and v < self.const_depressed)then
			return true;	
		end
	end
end
function PetState:IsSick()
	--if(self.bean)then
		--local bean = self.bean;
		--local v = bean.health;
		--if(v and v == self.const_sick)then
			--return true;	
		--end
	--end
	return false;
end
function PetState:IsDead()
	--if(self.bean)then
		--local bean = self.bean;
		--local v = bean.health;
		--if(v and v == self.const_dead)then
			--return true;	
		--end
	--end
	return false;
end
--体力值>=300
function PetState:FeedIsGreater()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.strong;
		if(v and v >= 300)then
			return true;	
		end
	end
	return false;
end
--清洁值>=300
function PetState:BathIsGreater()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.cleanness;
		if(v and v >= 300)then
			return true;	
		end
	end
	return false;
end
--心情值>=300
function PetState:PlayToyIsGreater()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.mood;
		if(v and v >= 300)then
			return true;	
		end
	end
	return false;
end
-- 达到满值
function PetState:IsNotHunger()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.strong;
		if(v)then
			return (v >= self.const_singleLevelGrownMaxValue);
		end
	end
end
-- 达到满值
function PetState:IsNotDirty()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.cleanness;
		if(v)then
			return (v >= self.const_singleLevelGrownMaxValue);
		end
	end
end
-- 达到满值
function PetState:IsNotDepressed()
	if(self.bean)then
		local bean = self.bean;
		local v = bean.mood;
		if(v)then
			return (v >= self.const_singleLevelGrownMaxValue);
		end
	end
end
--------------------------------------------
function PetState:Speak(msg)
	if(not msg)then return end
	--_guihelper.MessageBox(msg);
end