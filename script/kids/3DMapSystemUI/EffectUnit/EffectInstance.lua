--[[
Title: EffectInstance
Author(s): Leio Zhang
Date: 2009/3/23
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectInstance.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectInstance.lua");
local EffectInstance = {	
	isPlaying = false,
	-- the path of effect.xml
	path = nil,
	--event
	OnPlay = nil,
	OnStop = nil,
}
commonlib.setfield("Map3DSystem.EffectUnit.EffectInstance",EffectInstance); 
function EffectInstance:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function EffectInstance:Init()
	--self.uid = ParaGlobal.GenerateUniqueID();
	-- effect parameters
	self.params = {};
end
function EffectInstance:SetPath(path)
	self.path = path;
end
function EffectInstance:GetPath()
	return self.path;
end
function EffectInstance:IsPlaying()
	return self.isPlaying;
end
local ParamNames = {
	storyboard = true,
	rootcontainer = true,
	sender = true,
	receiver = true,
	origin = true,
	type = true,
}
-- set the effect parameters such as sender and receiver, etc. 
-- @param name: supported names are "sender", "receiver","storyboard","rootcontainer"
-- @param value: can be value or table.
function EffectInstance:SetParams(name, value)
	if(not name or not value or not ParamNames[name])then return end
	self.params[name] = value;
end
function EffectInstance:SetConfig()
	local rootcontainer = self.params["rootcontainer"];
	local sender = self.params["sender"];
	local receiver = self.params["receiver"];
	local type = self.params["type"];
	local origin = self.params["origin"];
	local storyboard = self.params["storyboard"];
	if(not origin)then
		if(not type or type == "OneToNil" or type == "OneToHimself")then
			--TODO:get the place of sender
			local player = ParaScene.GetPlayer()
			local x,y,z = player:GetPosition();
			origin = {x = x,y = y,z = z};
		elseif(type == "OneToOne")then
			--TODO:get the place of receiver
			local player = ParaScene.GetPlayer()
			local x,y,z = player:GetPosition();
			origin = {x = x,y = y,z = z};
		end
	end
	if(rootcontainer)then
		rootcontainer:SetPosition(origin.x,origin.y,origin.z);
	end
	if(storyboard)then
		storyboard:SetEffectInstance(self);
	end
end
-- get the effect parameters such as sender and receiver, etc. 
-- @param name: supported names are "sender", "receiver"
function EffectInstance:GetParams(name)
	return self.params[name];
end
-- play the effect still finished. 
function EffectInstance:Play(sender,receiver)
	self:SetParams("sender", true);
	local mc = self.params["storyboard"];
	local rootcontainer = self.params["rootcontainer"];
	self:SetConfig()
	if(mc and rootcontainer)then
		rootcontainer:SetVisible(true);
		mc.OnEnd = EffectInstance.MC_MotionEnd;
		mc:SetEffectInstance(self);
		mc:Play();
		self.isPlaying = true;
		-- call event callback
		if(type(self.OnPlay)== "function")then
			self.OnPlay(self)
		end
	end	
end
function EffectInstance:Stop()	
	local mc = self.params["storyboard"];
	if(mc)then
		mc:End();
	end
end
function EffectInstance.MC_MotionEnd(mc)
	if(not mc)then return end
	local self = mc:GetEffectInstance();
	if(not self)then return end;
	local rootcontainer = self.params["rootcontainer"];
	if(rootcontainer)then
		rootcontainer:SetVisible(false);
	end
	if(type(self.OnStop)== "function")then
		self.OnStop(self);
	end
	self.isPlaying = false;
end
