--[[
Author(s): Leio
Date: 2007/12/13
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotAnimation.lua");
Map3DSystem.UI.RobotAnimation.Init(parent);
Map3DSystem.UI.RobotAnimation.Play(frame);frmae 1 2 3
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI.RobotAnimation) then Map3DSystem.UI.RobotAnimation={}; end
Map3DSystem.UI.RobotAnimation.name = "transitLayer";
Map3DSystem.UI.RobotAnimation.timerID = 0;
Map3DSystem.UI.RobotAnimation.textruePath = "Texture/3DMapSystem/RobotShop/animation.png";
Map3DSystem.UI.RobotAnimation.texTileSize = 64;
Map3DSystem.UI.RobotAnimation.parent = nil;
Map3DSystem.UI.RobotAnimation.left = 0;
Map3DSystem.UI.RobotAnimation.top = 0;
Map3DSystem.UI.RobotAnimation.width = 0;
Map3DSystem.UI.RobotAnimation.height = 0;
Map3DSystem.UI.RobotAnimation.animationFrame={};

function Map3DSystem.UI.RobotAnimation.Init(parent)
	local self=Map3DSystem.UI.RobotAnimation;
	self.parent=parent;
	local   _this,_parent=nil,parent;
	        _this=ParaUI.CreateUIObject("container","AnimationContainer", "_lt",0,0,64,64);
			_this.background=self.textruePath;
			_this:GetTexture("background").rect="0 0 0 0";
			_parent:AddChild(_this);
			_parent = _this;
			
	for i = 0,2 do
		    self.animationFrame[i+1] = math.mod(i,3)*self.texTileSize.." "..math.floor(i/3)*self.texTileSize.." "..
			self.texTileSize.." "..self.texTileSize;
			--log(self.animationFrame[i+1].."\n");
	end
	
end
function Map3DSystem.UI.RobotAnimation.Play(frame)
	if(frame==nil or frame>3 or frame<0)then return end;
	local self=Map3DSystem.UI.RobotAnimation;
	local AnimationContainer=ParaUI.GetUIObject("AnimationContainer");
	self.ReSet();
	AnimationContainer:BringToFront();
	AnimationContainer:GetTexture("background").rect=self.animationFrame[frame]
		
	NPL.SetTimer(self.timerID,0.05,";Map3DSystem.UI.RobotAnimation.PlayAnimation()");
end
function Map3DSystem.UI.RobotAnimation.PlayAnimation()
	local self=Map3DSystem.UI.RobotAnimation;
	local AnimationContainer=ParaUI.GetUIObject("AnimationContainer");
	local left,top,__,__ = AnimationContainer:GetAbsPosition();
	local alpha=self.GetAlpha(AnimationContainer);
	
	if (alpha>50) then
		self.SetAlpha(AnimationContainer,alpha-20);
		AnimationContainer.y=AnimationContainer.y-5;
	else
		self.ReSet();	
	end;
	
end
function Map3DSystem.UI.RobotAnimation.ReSet()
	local self=Map3DSystem.UI.RobotAnimation;
	local AnimationContainer=ParaUI.GetUIObject("AnimationContainer"); 
		  NPL.KillTimer(self.timerID);
		  self.timerID=self.timerID+1;
		  self.SetAlpha(AnimationContainer,255);
		  AnimationContainer.x=0;
		  AnimationContainer.y=0;
		  AnimationContainer:GetTexture("background").rect="0 0 0 0";	
end
function Map3DSystem.UI.RobotAnimation.SetTexture(path)
	local self=Map3DSystem.UI.RobotAnimation;
	self.left=left;
	self.top=top;
end
function Map3DSystem.UI.RobotAnimation.SetPosition(left,top)
	local self=Map3DSystem.UI.RobotAnimation;
	self.left=left;
	self.top=top;
end

function Map3DSystem.UI.RobotAnimation.GetAlpha(container)
	local texture=container:GetTexture("background");
	return texture.transparency;
end
function Map3DSystem.UI.RobotAnimation.SetAlpha(container,alpha)
	local texture=container:GetTexture("background");
	texture.transparency=alpha;--[0-255]
end