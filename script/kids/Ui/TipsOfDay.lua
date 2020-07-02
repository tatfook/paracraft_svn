--[[
Title: tips of the day dialog control
Author(s): LiXizhi
Date: 2006/12/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/TipsOfDay.lua");

local ctl = CommonCtrl.TipsOfDay:new{
	name = "TipsOfDay1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	imageWidth = 512,
	imageHeight = 256,
	pageindex = 1,
	content = {
		[1] = {text = "Tips 1", image = "Texture/productcover.png"},
		[2] = {text = "Tips 2", image = "Texture/ParaEngineLogo.png"},
	},
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local TipsOfDay = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, -- should be at least imageHeight+32
	imageLeft = nil, -- if nil, image is placed automatically after header buttons
	imageTop = nil,-- if nil, image is placed automatically after header buttons
	imageWidth = 512,
	imageHeight = 256,
	-- a table of tip pages
	pageindex = nil, -- if this is nil, a random page will be picked. the first page is 1. 
	content = {},-- must be a table of table {text="", image=""}
	parent = nil,
	-- the top level control name
	name = "TipsOfDay1",
}
CommonCtrl.TipsOfDay = TipsOfDay;

-- constructor
function TipsOfDay:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function TipsOfDay:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function TipsOfDay:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("TipsOfDay instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- Tips of the Day
		local left, top, width, height = 0,0, 124, 32
		_this=ParaUI.CreateUIObject("button","left_arrow","_lt",left,top,width,height);
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "255 255 255 128");
		_parent:AddChild(_this);
		
		left, top, width, height = 10,0, 32, 32
		-- navigations: left arrow, current page/total Pages, right arrow
		_this=ParaUI.CreateUIObject("button","left_arrow","_lt",left,top,width,width);
		_parent:AddChild(_this);
		_this.onclick=string.format([[;CommonCtrl.TipsOfDay.OnFlipPage("%s",-1);]],self.name);
		_this.background="Texture/kidui/rightup/left_arr.png";
		left = left+width+10
		
		_this=ParaUI.CreateUIObject("text",self.name.."pagenumber","_lt",left,top+5,55,25);
		_parent:AddChild(_this);
		_this.font="System;16;bold";
		
		left = left+20+10
		
		_this=ParaUI.CreateUIObject("button","right_arrow","_lt",left,top,width,width);
		_parent:AddChild(_this);
		_this.onclick=string.format([[;CommonCtrl.TipsOfDay.OnFlipPage("%s",1);]],self.name);
		_this.background="Texture/kidui/rightup/right_arr.png";
		
		left,top = 0,32
		-- content placeholder per page
		_this=ParaUI.CreateUIObject("text", self.name.."text", "_lt",left, top, self.imageWidth, self.imageHeight);
		_parent:AddChild(_this);
		_this.enable = false;
		_this:BringToBack();
		if(not self.imageLeft) then self.imageLeft = left end
		if(not self.imageTop) then self.imageTop = top end
		_this=ParaUI.CreateUIObject("container", self.name.."image", "_lt",self.imageLeft, self.imageTop, self.imageWidth, self.imageHeight);
		_parent:AddChild(_this);
		_this.enable = false;
		_this.background="Texture/whitedot.png;0 0 0 0";
		_this:BringToBack();
		
		-- randomly pick a page to display
		if(not self.pageindex) then
			self.pageindex = math.ceil(ParaGlobal.random()*table.getn(self.content));
			if(self.pageindex==0) then
				self.pageindex=1;
			end
		end
		self:ShowPage(self.pageindex);
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
end

-- show a given page by index. pageindex = 1 is the first page. 
-- return nil if page not found, or pageindex is returned
function TipsOfDay:ShowPage(pageindex)
	local tip = self.content[pageindex];
	if(tip==nil) then
		return
	end
	self.pageindex = pageindex;
	local tmp;
	-- update page number
	tmp=ParaUI.GetUIObject(self.name.."pagenumber");
	if(tmp:IsValid() == true) then		
		tmp.text = tostring(pageindex);
	end
	
	-- update text
	if(tip.text~=nil) then
		tmp=ParaUI.GetUIObject(self.name.."text");
		if(tmp:IsValid() == true) then		
			tmp.text = tip.text
		end
	end
	
	-- update image
	if(tip.image~=nil) then
		tmp=ParaUI.GetUIObject(self.name.."image");
		if(tmp:IsValid() == true) then		
			tmp.background = tip.image;
		end
	end
	return pageindex;
end

-- @param nRelativePage: 1 for next page, -1 or previous page. 
function TipsOfDay.OnFlipPage(sCtrlName, nRelativePage)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("err getting control TipsOfDay\r\n");
		return;
	end
	local nPageIndex = self.pageindex+nRelativePage;
	if(nPageIndex<=0 and self:ShowPage(table.getn(self.content)) ~= nil) then
		-- flip to last page
	elseif(self:ShowPage(nPageIndex) ~= nil) then
		-- middle pages
		ParaAudio.PlayUISound("Btn1");
	elseif(self:ShowPage(1) ~= nil) then
		-- flip to the beginning
	end
end
