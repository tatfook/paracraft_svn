--[[
Title: Control for playing AVI or WMV videos.
Author(s): LiXizhi
Date: 2006/12
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/movie/VideoPlayerCtrl.lua");
local ctl = CommonCtrl.VideoPlayerCtrl:new{
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 320,
	height = 272,
	videowidth = 320,
	videoheight = 240,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "VideoPlayerCtrl1",
}
ctl:Show();
ctl:LoadFile("test.wmv");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/common_control.lua");

VideoPlayerCtrl = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 320,
	height = 272,
	videowidth = 320,
	videoheight = 240,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- current video file
	filename = nil,
	-- the top level control name
	name = "VideoPlayerCtrl",
};

CommonCtrl.VideoPlayerCtrl = VideoPlayerCtrl;

-- constructor
function VideoPlayerCtrl:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function VideoPlayerCtrl:Destroy()
	ParaUI.Destroy(self.name);
end

-- update the UI
function VideoPlayerCtrl:LoadFile(filename)
	local videoctlname = self.name.."video"
	if(not filename) then
		ParaUI.Destroy(videoctlname);
		return;
	end
	self.filename = filename;
	-- update recording time
	local _parent = ParaUI.GetUIObject(self.name);
	if(_parent:IsValid()==false) then return end
	local _this = ParaUI.GetUIObject(videoctlname);
	
	-- AVI or WMV player
	if(ParaIO.DoesFileExist(filename, false) == true) then
		if(_this:IsValid() == false) then
			_this=ParaUI.CreateUIObject("video",videoctlname, "_lt",0,0,self.videowidth,self.videoheight);
			_parent:AddChild(_this);
		end	
		_this:LoadFile(filename);
		_this:PlayVideo();
	else
		ParaUI.Destroy(videoctlname);
		_this=ParaUI.CreateUIObject("text",videoctlname, "_lt",0,0,self.videowidth,self.videoheight);
		_parent:AddChild(_this);
		_this.text = "Video File Not Found: \n"..filename;
	end	
end

function VideoPlayerCtrl:Show()
	local _this,_parent
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		_parent=_this;
		
		-- bottom row
		local width, height =32,32;
		local left = 0;
		local top = -height;
		_this=ParaUI.CreateUIObject("button","pause", "_lb",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/pause.png;";
		_this.onclick=string.format([[;VideoPlayerCtrl.pause("%s");]], self.name);
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","play", "_lb",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/play.png;";
		_this.onclick=string.format([[;VideoPlayerCtrl.play("%s");]], self.name);
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","stop", "_lb",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/stop.png;";
		_this.onclick=string.format([[;VideoPlayerCtrl.stop("%s");]], self.name);
		left = left+width;
		-- TODO: we can even add video progress bar. 
	end
end


function VideoPlayerCtrl.pause(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("VideoPlayerCtrl can not found instance "..sCtrlName);
		return;
	end
	local ctl = ParaUI.GetUIObject(self.name.."video");
	if(ctl:IsValid() and ctl.PauseVideo~=nil) then
		ctl:PauseVideo();
	end
end

function VideoPlayerCtrl.stop(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("VideoPlayerCtrl can not found instance "..sCtrlName);
		return;
	end
	local ctl = ParaUI.GetUIObject(self.name.."video");
	if(ctl:IsValid() and ctl.StopVideo~=nil) then
		ctl:StopVideo();
	end
end

function VideoPlayerCtrl.play(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("VideoPlayerCtrl can not found instance "..sCtrlName);
		return;
	end
	local ctl = ParaUI.GetUIObject(self.name.."video");
	if(ctl:IsValid() and ctl.PlayVideo~=nil) then
		ctl:PlayVideo();
	end
end