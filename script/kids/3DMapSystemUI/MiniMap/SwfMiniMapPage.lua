--[[
Title: 
Author(s): Leio
Date: 2009/8/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/SwfMiniMapPage.lua");
Map3DSystem.App.MiniMap.SwfMiniMapPage.Show();
Map3DSystem.App.MiniMap.SwfMiniMapPage.LoadMovie("Games/ComplexMap/ComplexMap.swf");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashPlayerControl.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local SwfMiniMapPage = {
	-- the top level control name
	name = "SwfMiniMapPage1",
	background = "", -- current background, it can be a swf file or image file.
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 512, 
	swf_width = 512,
	swf_height = 512, 
	parent = nil,
	swf_file = nil,
	bg = "", --Texture/bg_black.png
	viewRect = {
		x = 20000,
		y = 19800,
		width = 16 * 16,
		height = 16 * 16,
	},
	ishook = false;
	interval = 500,
	last_x = 0,
	last_y = 0,
}
commonlib.setfield("Map3DSystem.App.MiniMap.SwfMiniMapPage",SwfMiniMapPage);


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function SwfMiniMapPage.Show(bShow)
	local self = SwfMiniMapPage;
	local _this,_parent;
	if(self.name==nil)then
		log("SwfMiniMapPage instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name.."container");
	if(_this:IsValid() == false) then
	
		local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
		
		_this=ParaUI.CreateUIObject("container",self.name.."container",self.alignment,self.left,self.top,self.width,self.height);
		_this.background=self.bg;
		_parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		local left,top,width,height = self.left,self.top,self.swf_width,self.swf_height
		--local left,top,width,height = (screenWidth - self.swf_width)/2,(screenHeight - self.swf_height)/2,self.swf_width,self.swf_height
		_this=ParaUI.CreateUIObject("container",self.name.."container_swf","_lt",left,top,width,height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
		local name = self.name.."FlashPlayerControl1";
		NPL.load("(gl)script/ide/FlashPlayerControl.lua");
		local ctl = CommonCtrl.FlashPlayerWindow:new{
			name = name,
			alignment = "_fi",
			left = 0, 
			top = 0,
			width = 0,
			height = 0,
			parent = _this,
			
		};
		ctl:Show();
		CommonCtrl.AddControl(name, ctl);
		
		NPL.load("(gl)script/ide/timer.lua");
		self.timer = self.timer or commonlib.Timer:new({callbackFunc = SwfMiniMapPage.TimerHandle});
		self.timer:Change(self.interval, self.interval);
		
		self.GoToPos(0,0)
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end	
	self.ishook = _this.visible;
end
function SwfMiniMapPage.TimerHandle()
	local self = SwfMiniMapPage;
	if(self.ishook)then
		local x,__,y = ParaScene.GetPlayer():GetPosition();
		if(math.abs(x - self.last_x) > 1 or math.abs(y - self.last_y) > 1)then
			self.MoveMap();
			
			self.last_x = x;
			self.last_y = y;
		end
		self.CameraRot();
	end
end
function SwfMiniMapPage.OnDestroy()
	local self = SwfMiniMapPage;
	self.UnloadMovie(self.swf_file)
	local name = self.name.."container" ;
	ParaUI.Destroy(name);
	
	self.ishook = false;
	if(self.timer) then
		self.timer:Change();
	end
end

-- load a movie by name
function SwfMiniMapPage.LoadMovie(sFileName)
	local self = SwfMiniMapPage;
	local name = self.name.."FlashPlayerControl1";
	local ctl =  CommonCtrl.GetControl(name);
	if(ctl)then
		self.swf_file = sFileName;
		ctl:LoadMovie(sFileName);
		--hook FlashPlayerIndex after load swf file
		self.FlashPlayerIndex = ctl.FlashPlayerIndex;
	end
end
function SwfMiniMapPage.UnloadMovie(sFileName)
	local self = SwfMiniMapPage;
	local name = self.name.."FlashPlayerControl1";
	local ctl =  CommonCtrl.GetControl(name);
	if(ctl)then
		ctl:UnloadMovie(sFileName);
	end
end
function SwfMiniMapPage.SetPosRange(xRange,yRange)
	local self = SwfMiniMapPage;
	local center_x = self.viewRect.x + self.viewRect.width/2;
	local center_y = self.viewRect.y + self.viewRect.height/2;
	local x = center_x + xRange * self.viewRect.width/2;
	local z = center_y + yRange * self.viewRect.height/2;
	
	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = x, z = z});
end
function SwfMiniMapPage.GetPosRange()
	local self = SwfMiniMapPage;
	local x,__,y = ParaScene.GetPlayer():GetPosition();
	local center_x = self.viewRect.x + self.viewRect.width/2;
	local center_y = self.viewRect.y + self.viewRect.height/2;
	
	local xRange = 2 * (x - center_x)/self.viewRect.width;
	local yRange = -2 * (y - center_y)/self.viewRect.height;--取反
	
	return xRange,yRange,x,y;
end
--CallNPLFromAs
--跳转到某个位置
function SwfMiniMapPage.GoToPos(xRange,yRange)
	local self = SwfMiniMapPage;
	self.SetPosRange(xRange,yRange)
end
--InvokeAsFunction
function SwfMiniMapPage.MoveMap()
	local self = SwfMiniMapPage;
	local xRange,yRange,x,y = self.GetPosRange();
	local func_args = {
				funcName = "MoveMap",
				args = {
					xRange,yRange,x,y
				}
			} 
	--commonlib.echo({xRange,yRange});
	commonlib.CallFlashFunction(self.FlashPlayerIndex, func_args)
end
function SwfMiniMapPage.CameraRot()
	local self = SwfMiniMapPage;
	local camobjDist, LifeupAngle, CameraRotY = ParaCamera.GetEyePos()
	local func_args = {
				funcName = "CameraRot",
				args = {
					CameraRotY
				}
			} 
	commonlib.CallFlashFunction(self.FlashPlayerIndex, func_args)
end