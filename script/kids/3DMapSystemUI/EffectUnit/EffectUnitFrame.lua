--[[
Title: EffectUnitFrame �ṩ��һ��������Ч�Ŀ�ܣ�����Լ̳�������дInitialization(),LoadContent(),DoEffect()��ʵ���Լ�����Ч
Author(s): Leio Zhang
Date: 2009/3/20
Note:
һ����Ч��Ԫ���ǲ���һ����Ч����С��Ԫ��
���������ɫ
	sender:��Ч�ķ�����
	receiver:��Ч�ĳ�����
	props:������Ч�ĵ���
��ɫ������
	һ����Чֻ��һ�������ߣ�1
	һ����Ч�ж�������ߣ�0---n
	һ����Ч�ж�����ߣ�0---n
��Ч����������
	begin:��ʼ
	effecting:������Ч��
	end:����
��Ч���ŵĹ��̵��У��Գ����ߵ�Ӱ��
	disturbed:ture or false
	��һ����Ч���ŵĹ��̵��У��Գ����ߵ�Ӱ��������������Ӱ�죬����û��
	��Ӱ�죺��ҵĽ�ɫ����Ч�����ڼ佫��������Լ����ƣ�ֱ��������ϡ�
	û��Ӱ�죺��Ч�Ĳ��Ų�Ӱ����ҿ����Լ���ɫ���κ���Ϊ��

��Ч��Ԫ������
local Descriptor = {
	sender =  {},
	receiver = {},
	props = {},
	disturbed = false,
	type = "OneToNil" , --"OneToNil" or "OneToHimself" or "OneToOne" or "OneToMulti"
}
��Ч������
OneToNil��ֻ�з����ߣ�û�ж�ȫ������㲥��ֻ���Լ��Ŀͻ��˿��Կ��������硰����1�롱
OneToHimself�������ߺͽ����߶����Լ���Ҫ��ȫ������㲥�����еĿͻ��˶����Կ��������硰����һ�����˵Ķ�����
OneToOne������Ҫѡһ��Ŀ�꣨receiver��,��һ�������ߺ�һ�������ߣ����硰�ڶԷ��Դ������ꡱ
OneToMulti�����Ժ�OneToOne����һ��
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