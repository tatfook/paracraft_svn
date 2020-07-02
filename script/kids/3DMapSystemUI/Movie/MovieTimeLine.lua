--[[
Title: MovieTimeLine
Author(s): Leio Zhang
Date: 2008/10/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTimeLine.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");

local MovieTimeLine = {
	name = "MovieTimeLine_instance",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	container_bg = nil,
	parent = nil,
	
	onchange = nil,
	_curTime = nil,
	_curFrame = 0,
	_curTimeRank = nil,
	_rankIndex = 1,
	-- a global value
	MinStep = 1,
	
}
commonlib.setfield("Map3DSystem.Movie.MovieTimeLine",MovieTimeLine);
function MovieTimeLine:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()	
	return o
end
function MovieTimeLine:Initialization()
	NPL.load("(gl)script/ide/Animation/Motion/AnimationEditor/AnimationEditor.lua");
	self._rankIndex = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.TimeRankStartIndex;
	self._curTimeRank = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.TimeRank[self._rankIndex];
end
function MovieTimeLine:Show()
	if(not self.parent)then return; end
	local _this = ParaUI.GetUIObject(self.name.."container");
	self.parent:AddChild(_this);
	self:CreateControl()
end
function MovieTimeLine.OnSliderBarChanged(value)
	local ctl = CommonCtrl.GetControl(MovieTimeLine.name.."SliderBar");	
	if(ctl ~= nil and ctl.MovieTimeLine)then
		ctl.MovieTimeLine._curFrame = value;
		if(ctl.MovieTimeLine.Onchange)then
			ctl.MovieTimeLine.Onchange(ctl.MovieTimeLine,value);
		end
	end
end
function MovieTimeLine:GetTime()
	local time = CommonCtrl.Animation.Motion.TimeSpan.GetTime(self._curFrame);
	return time;
end
function MovieTimeLine:GetFrame()
	return self._curFrame;
end
function MovieTimeLine:UpdateBarValue(frame)
	if(not frame)then return; end							
	local ctl = CommonCtrl.GetControl(self.name.."SliderBar");
		if(ctl ~= nil)then
			local percent = frame;
			ctl:SetValue(percent)
		end
end
function MovieTimeLine:CreateControl()
	local _this = ParaUI.GetUIObject(self.name.."container");
	if(_this:IsValid())then
		ParaUI.Destroy(self.name.."container");		
	end
	_this = ParaUI.CreateUIObject("container", self.name.."container", self.alignment, self.left, self.top, self.width, self.height);
	self.parent:AddChild(_this);
	local parent = _this;
	
	-- sliderbar
		local const_width,const_height,const_frame = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameWidth,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameHeight,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.TimeLineDefaultFrame;	
		local min_step = (self._curTimeRank * 1000) /CommonCtrl.Animation.Motion.TimeSpan.framerate;
		min_step = math.floor(min_step);
		local len = const_frame/min_step;
		len = math.floor(len);
		local width,height = const_width*len,20
		_this = ParaUI.CreateUIObject("container", self.name.."container_bar", "lt", 0, 0, width, height);
		_this.background= "";
		_this.fastrender = false;
		parent:AddChild(_this);

		-- a global value
		MovieTimeLine.MinStep = min_step;
		NPL.load("(gl)script/ide/SliderBar.lua");
		local ctl = CommonCtrl.SliderBar:new{
			name = self.name.."SliderBar",
			alignment = "_lt",
			left = 0,
			top = 0,
			width = width,
			height = height,
			parent = _this,
			value = self._curFrame or 0 , -- current value
			min = 0,
			max = const_frame,
			min_step = min_step,
			canDrag = true,
			onchange = Map3DSystem.Movie.MovieTimeLine.OnSliderBarChanged,
			onMouseDownEvent = Map3DSystem.Movie.MovieTimeLine.__OnMouseDownEvent,
			onMouseUpEvent = Map3DSystem.Movie.MovieTimeLine.__OnMouseUpEvent,
		};
		ctl:Show(true);
		ctl.MovieTimeLine = self;
end
function MovieTimeLine:ZoomIn()
	local timeRank = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.TimeRank;
	if(not timeRank)then return; end
	local len = #timeRank;
	if(self._rankIndex < len)then
		self._rankIndex = self._rankIndex + 1;	
	else
		self._rankIndex = 1;
	end
	self._curTimeRank = timeRank[self._rankIndex];
	self:CreateControl();
end
function MovieTimeLine:ZoomOut()
	local timeRank = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.TimeRank;
	if(not timeRank)then return; end
	local len = #timeRank;
	if(self._rankIndex > 1)then
		self._rankIndex = self._rankIndex - 1;	
	else
		self._rankIndex = len;
	end
	self._curTimeRank = timeRank[self._rankIndex];
	self:CreateControl();
end
function MovieTimeLine.OnMouseDownEvent(self)

end
function MovieTimeLine.OnMouseUpEvent(self)

end
function MovieTimeLine.__OnMouseDownEvent()
	local ctl = CommonCtrl.GetControl(MovieTimeLine.name.."SliderBar");	
	if(ctl ~= nil and ctl.MovieTimeLine)then
		ctl.MovieTimeLine.OnMouseDownEvent(ctl.MovieTimeLine)
	end
end
function MovieTimeLine.__OnMouseUpEvent()
	local ctl = CommonCtrl.GetControl(MovieTimeLine.name.."SliderBar");	
	if(ctl ~= nil and ctl.MovieTimeLine)then
		ctl.MovieTimeLine.OnMouseUpEvent(ctl.MovieTimeLine)
	end
end