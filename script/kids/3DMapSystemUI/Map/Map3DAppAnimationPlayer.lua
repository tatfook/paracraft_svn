--[[
Title: SpriteAnimationPlayer
Author(s): SunLingfeng @ paraengine.com
Date: 2008/1/29
Desc: SpriteAnimationPlayer is a sprite sheet player,it receive a paraUIObject as
target window, draw animation on it.SpriteAnimationPlayer assume the sprite sheet texture
size is power of 2,eg,256*256,512*512. frameSize is the size of each frame in the 
texture.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppAnimationPlayer.lua");
local cloudPlayer = Map3DApp.SpriteAnimationPlayer:new{
	name = self.cloudLayer,
	targetWndName = self.name,
	totalFrame = 16,
	defaultFrame = 1,
	frameSize = 256,
	spriteSheet = "model/map3D/texture/clouds.dds",
};
cloudLayer:Play(false,false)
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/SpriteAnimation_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");

local SpriteAnimationPlayer = {
	name = "cloudLayer",
	parent = nil,
	
	--animation info
	--private:
	frames = {},
	--public:
	totalFrame = 16,
	defaultFrame = 16,
	frameSize = 256,
	spriteSheet = "model/map3D/texture/clouds.dds",
	
	--event
	onAnimationEnd = nil,
	onAnimationEndSubscriber = nil,
	
	--play state
	playSpeed = 2,
	frameCount = 0,
	totalFrame = 0,
	timeCount = 0;
	isInvertAnimation = false,
	isRepeat = false,
	play = false;
	
	listeners = {};
}
Map3DApp.SpriteAnimationPlayer = SpriteAnimationPlayer;

--===========public=================
function SpriteAnimationPlayer:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	return o;
end

function SpriteAnimationPlayer:Destory()
end

function SpriteAnimationPlayer:Show(bShow)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		else
			self:CreateUI();
		end
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
end

function SpriteAnimationPlayer:Play(isInvertAnimation,isRepeat)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	
	_this.onframemove = string.format(";Map3DApp.SpriteAnimationPlayer.OnFrameMove(%q)",self.name);
	_this.background = self.spriteSheet;
	if(self.isInvertAnimation)then
		_this:GetTexture("background").rect = self.frames[self.totalFrame];
	else
		_this:GetTexture("background").rect = self.frames[1];
	end
	
	if(isInvertAnimation)then
		self.isInvertAnimation = isInvertAnimation;
	end
	
	if(isRepeat ~= nil)then
		self.isRepeat = isRepeat;
	end
	
	self.frameCount = 1;
	self.timeCount = 0;

	self.play = true;
end

function SpriteAnimationPlayer:Stop()
	self.play = false;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.onframemove = nil;
	end;
	self:SendMessage(Map3DApp.Msg.onAnimationEnd);
end

function SpriteAnimationPlayer:SetParent(parent)
	self.parent = parent;
end

function SpriteAnimationPlayer:AddListener(name,listener)
	self.listeners[name] = listener;
end

function SpriteAnimationPlayer:RemoveListener(name)
	self.listeners[name] = nil;
end

function SpriteAnimationPlayer:SendMessage(msg)
	if(self.listeners ~= nil)then
		for __,listener in pairs(self.listeners) do
			listener:SetMessage(self.name,msg);
		end
	end
end

--================private==============
function SpriteAnimationPlayer:Init()
	for i = 0,self.totalFrame - 1 do
		self.frames[i+1] = math.mod(i,4) * self.frameSize.." "..math.floor(i/4) * self.frameSize.." "..
			self.frameSize.." "..self.frameSize;
	end
	
	CommonCtrl.AddControl(self.name,self);
end

function SpriteAnimationPlayer:CreateUI()
	local _this = ParaUI.CreateUIObject("container",self.name,"_fi",0,0,0,0);
	_this.enabled = false;
	if(self.parent == nil)then
		_this:AttachToRoot()
	else
		self.parent:AddChild(_this);
	end
end

function SpriteAnimationPlayer:GetNextFrame()
	local frame;
	if(self.isInvertAnimation)then
		frame = self.frames[self.totalFrame - self.frameCount+1];
	else
		frame = self.frames[self.frameCount];
	end
	
	self.frameCount = math.mod(self.frameCount,self.totalFrame)+1;
	return frame;
end

function SpriteAnimationPlayer.OnFrameMove(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	self.timeCount = self.timeCount + 1;
	if(self.timeCount < self.playSpeed)then
		return;
	else
		self.timeCount = 0;
	end

	if(self.play == false)then
		return;
	end
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this:GetTexture("background").rect = self:GetNextFrame();
	end
	
	if(self.isRepeat == false)then
		if(self.frameCount == 1)then
			self:Stop();
		end
	end
end

