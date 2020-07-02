--[[
Title: EffectUnitFrame 提供了一个播放特效的框架，你可以继承它，重写Initialization(),LoadContent(),DoEffect()，实现自己的特效
Author(s): Leio Zhang
Date: 2009/3/20
Note:
一个特效单元，是播放一种特效的最小单元，
它有三类角色
	sender:特效的发起者
	receiver:特效的承受者
	props:产生特效的道具
角色的数量
	一个特效只有一个发起者，1
	一个特效有多个承受者，0---n
	一个特效有多个道具，0---n
特效的生命周期
	begin:开始
	effecting:播放特效中
	end:结束
特效播放的过程当中，对承受者的影响
	disturbed:ture or false
	在一个特效播放的过程当中，对承受者的影响分两种情况，有影响，或者没有
	有影响：玩家的角色在特效播放期间将不受玩家自己控制，直到播放完毕。
	没有影响：特效的播放不影响玩家控制自己角色的任何行为。

特效单元的描述
local Descriptor = {
	sender =  {},
	receiver = {},
	props = {},
	disturbed = false,
	type = "OneToNil" , --"OneToNil" or "OneToHimself" or "OneToOne" or "OneToMulti"
}
特效的种类
OneToNil：只有发起者，没有对全体世界广播，只有自己的客户端可以看到，比如“黑屏1秒”
OneToHimself：发起者和接收者都是自己，要对全体世界广播，所有的客户端都可以看到，比如“播放一个高兴的动作”
OneToOne：必须要选一个目标（receiver）,有一个发起者和一个接收者，比如“在对方脑袋上下雨”
OneToMulti：可以和OneToOne合在一起
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectUnitFrame.lua");
local myEffect = Map3DSystem.EffectUnitFrame:new();
myEffect:SetParam("sender");
myEffect:Play();


-- network packet:  effectid, sender_uid, recevier_uid,
-- create or get an effect
local myEffect = Map3DSystem.EffectManager:CreateEffect(1, "OneToOne/Rain.effect.xml"); -- :EffectFile
if(myEffect) then
	local effectObject = myEffect:CreateInstance(); -- :EffectInstance
	effectObject:SetParam("sender", ParaScene.GetPlayer());
	effectObject:SetParam("receiver", ParaScene.GetPlayer());
	
	--effectObject:GetParam("bStopReceiver");
	
	effectObject:Play();
end

EffectManager
EffectFile
EffectInstance
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClipHelper.lua");
local EffectUnitFrame = {
	-- effect parameters
	params = nil,
	isPlaying = false,
	bInit,
	--event
	OnPlay = nil,
	OnStop = nil,
}
commonlib.setfield("Map3DSystem.EffectUnitFrame",EffectUnitFrame); 
function EffectUnitFrame:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

-- set the effect parameters such as sender and recevier, etc. 
-- @param name: supported names are "sender", "recevier"
-- @param value: can be value or table.
function EffectUnitFrame:SetParams(name, value)
end

-- get the effect parameters such as sender and recevier, etc. 
-- @param name: supported names are "sender", "recevier"
function EffectUnitFrame:GetParams(name)
end

-- play the effect still finished. 
function EffectUnitFrame:Play()
	self.isPlaying = true;
	self:Init();
	self:LoadContent();
	if(not self.descriptor)then return end
	
	-- call event callback
	if(type(self.OnPlay)== "function")then
		self:OnPlay()
	end
	
	self:DoEffect();
end

function EffectUnitFrame:Stop()
	if(not self.descriptor)then return end
	if(self.endFunc and type(self.endFunc)== "function")then
		self.endFunc(self)
	end
	self.isPlaying = false;
end

function EffectUnitFrame:Start()	
	
end

-- load some assets of animation you want to affect sender or receiver
function EffectUnitFrame:LoadContent()

end
-- override this method and implement your effect
function EffectUnitFrame:DoEffect()

end