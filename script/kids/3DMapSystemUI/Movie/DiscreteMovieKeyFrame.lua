--[[
Title: DiscreteMovieKeyFrame
Author(s): Leio
Date: 2008/12/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/DiscreteMovieKeyFrame.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TargetAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/BaseObject.lua");
--local DiscreteMovieKeyFrame = commonlib.multi_inherit(CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame,Map3DSystem.App.Inventor.BaseObject)
--commonlib.setfield("Map3DSystem.App.Inventor.DiscreteMovieKeyFrame",DiscreteMovieKeyFrame);   
local DiscreteMovieKeyFramePool = {};
commonlib.setfield("Map3DSystem.App.Inventor.DiscreteMovieKeyFramePool",DiscreteMovieKeyFramePool); 
local DiscreteMovieKeyFrame = commonlib.inherit(Map3DSystem.App.Inventor.BaseObject,{

});
commonlib.setfield("Map3DSystem.App.Inventor.DiscreteMovieKeyFrame",DiscreteMovieKeyFrame); 
function DiscreteMovieKeyFrame:InitKeyFrame()
	local keyFrame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new();
	DiscreteMovieKeyFramePool[self:GetID()] = keyFrame;
	self.name = self:GetID();
end
function DiscreteMovieKeyFrame:GetRef()
	local id = self:GetID();
	return Map3DSystem.App.Inventor.DiscreteMovieKeyFramePool[id];
end
function DiscreteMovieKeyFrame:SetParent(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetParent(v)
end
function DiscreteMovieKeyFrame:GetParent()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetParent()
end
function DiscreteMovieKeyFrame:SetActivate(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetActivate(v)
end
function DiscreteMovieKeyFrame:GetActivate(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetActivate(v)
end
function DiscreteMovieKeyFrame:SetValue(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetValue(v)
end
function DiscreteMovieKeyFrame:GetValue()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetValue()
end
function DiscreteMovieKeyFrame:SetKeyTime(v)
	if(not v)then return; end
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetKeyTime(v)
	self.KeyTime = v;
	self.ToFrame = self:GetFrames();
end
function DiscreteMovieKeyFrame:SetKeyFrame(v)
	if(not v)then return; end	
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetKeyFrame(v)
	self.ToFrame = v;
	self.KeyTime = CommonCtrl.Animation.Motion.TimeSpan.GetTime(v);
end
function DiscreteMovieKeyFrame:GetKeyFrame()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetKeyFrame()
end
function DiscreteMovieKeyFrame:GetKeyTime()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetKeyTime()
end
function DiscreteMovieKeyFrame:GetFrames()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetFrames()
end

function DiscreteMovieKeyFrame:ReverseToMcml()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:ReverseToMcml();
end   