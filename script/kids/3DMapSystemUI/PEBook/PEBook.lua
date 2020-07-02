--[[
Title: PEBook
Author(s): Leio
Date: 2009/4/8
Desc:
root folder
	config.lua, -- it is a config file which control book's style,order of pages
	pages(mcml and lua), -- one page include both a mcml and a lua file
	images, -- a folder to store pictures
	media, -- a folder to store audio or video
	worlds, -- a foler to store pe worlds
config.lua
	data = {
		["style"] = 0, -- it is a book style to show whether cover is will be show or not,what cover style will be show and so on
		["pages"] = {
			"page1.mcml",
			"page2.mcml",
			"page3.mcml",
			"page4.mcml",
		} ,	
	}	

use the lib:
------------------------------------------------------------
local config = {
	["style"] = 0,
	["pages"] = {
			"Texture/Aries/Homeland/temp/book1/page1.html",
			"Texture/Aries/Homeland/temp/book1/page1.html",
			"Texture/Aries/Homeland/temp/book1/page1.html",
			"Texture/Aries/Homeland/temp/book1/page1.html",
		},	
}
NPL.load("(gl)script/kids/3DMapSystemUI/PEBook/PEBook.lua");
local book = Map3DSystem.App.PEBook.PEBook:new()
book:SetConfig(config);
book:Show();
------------------------------------------------------------
]]
local PEBook = {
	name = "PEBook_instance",
	parent = nil,
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 800,
	height = 600,
	
	style = nil,
	curPage = 1,
	totalPage = 0,
	pages = nil,
	
}
commonlib.setfield("Map3DSystem.App.PEBook.PEBook",PEBook);
function PEBook:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function PEBook:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
end
function PEBook:PrePage()
	if(self.curPage > 1 )then
		self.curPage  = self.curPage - 1;
		self:ParsePage();
	end
end
function PEBook:NextPage()
	if(self.curPage < self.totalPage )then
		self.curPage  = self.curPage + 1;
		self:ParsePage();
	end
end
function PEBook:GotoPage(index)
	if(index and (index > 0 and index < self.totalPage))then
		self.curPage = index;
		self:ParsePage();
	end
end
function PEBook:SetConfig(config)
	if(not config)then return end
	self.style = config.style;
	self.pages = config.pages;
	self.curPage = 1;
	self.totalPage = #config.pages;
end
function PEBook:ParsePage()
	if(not self.pages)then return end
	local page = self.pages[self.curPage];
	if(page)then
		if(not self.pageCtrl)then
			NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
			self.pageCtrl = Map3DSystem.mcml.PageCtrl:new({url = page});
			local parent = ParaUI.GetUIObject(self.name.."container");
			self.pageCtrl:Create(self.name.."PageCtrl", parent, "_fi", 0, 0, 0, 0)
		end
		self.pageCtrl:Goto(page);
		self:ShowOrHideBtn();
	end
end
function PEBook:Show(bShow)
	local _this,_parent;
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);	
		_this.background="Texture/whitedot.png;0 0 0 0";
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		_parent = _this;
		-- magazine bg
		_this = ParaUI.CreateUIObject("container",self.name.."bg","_fi",0,0,0,0);	
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		-- magazine container
		_this = ParaUI.CreateUIObject("container",self.name.."container","_fi",0,0,0,0);	
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
		-- firstBtn
		_this = ParaUI.CreateUIObject("button",self.name.."firstBtn","_lt",0,0,60,60);
		_this.text = "首页";
		_this.visible = false;
		_this.onclick = string.format(";Map3DSystem.App.PEBook.PEBook.DoGoToPage('%s',1);",self.name);
		_parent:AddChild(_this);
		-- preBtn
		_this = ParaUI.CreateUIObject("button",self.name.."preBtn","_lt",0,0,60,60);
		_this.text = "向前";
		_this.onclick = string.format(";Map3DSystem.App.PEBook.PEBook.DoPrePage('%s');",self.name);
		_parent:AddChild(_this);
		-- nextBtn
		_this = ParaUI.CreateUIObject("button",self.name.."nextBtn","_lt",0,50,60,60);
		_this.text = "向后";
		_this.onclick = string.format(";Map3DSystem.App.PEBook.PEBook.DoNextPage('%s');",self.name);
		_parent:AddChild(_this);
		-- closeBtn
		_this = ParaUI.CreateUIObject("button",self.name.."closeBtn","_lt",0,100,60,60);
		_this.text = "关闭";
		_this.onclick = string.format(";Map3DSystem.App.PEBook.PEBook.DoClosePage('%s');",self.name);
		_parent:AddChild(_this);
		
		self:GotoPage(1)
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
		if(bShow)then
			self:GotoPage(1)
		end
	end	
end
function PEBook:ShowOrHideBtn()
	local firstBtn = ParaUI.GetUIObject(self.name.."firstBtn");
	local preBtn = ParaUI.GetUIObject(self.name.."preBtn");
	local nextBtn = ParaUI.GetUIObject(self.name.."nextBtn");
	local closeBtn = ParaUI.GetUIObject(self.name.."closeBtn");
	local bg = ParaUI.GetUIObject(self.name.."bg");
	if(self.curPage == 1)then	
		if(preBtn:IsValid())then
			if(preBtn.visible)then
				preBtn.visible = false;
			end
		end
	else
		if(preBtn:IsValid())then
			if(not preBtn.visible)then
				preBtn.visible = true;
			end
		end
	end
	if(self.curPage == self.totalPage)then
		if(nextBtn:IsValid())then
			if(nextBtn.visible)then
				nextBtn.visible = false;
			end
		end
	else
		if(nextBtn:IsValid())then
			if(not nextBtn.visible)then
				nextBtn.visible = true;
			end
		end
	end
	local style = self.style;
	if(style == 0)then
		-- 时报，没有封面封底
		closeBtn.x = 773;
		closeBtn.y = 0;
			
		preBtn.x = 0;
		preBtn.y = 468;
		nextBtn.x = 773;
		nextBtn.y = 468;
		if(self.curPage == 1)then
			firstBtn.visible = false;
		else
			firstBtn.visible = true;
			firstBtn.x = 0;
			firstBtn.y = 0;
		end
	elseif(style == 1)then
		-- 杂志，有封面，封底
		if(self.curPage == 1)then
			closeBtn.x = 502;
			closeBtn.y = 0;
			
			nextBtn.x = 502;
			nextBtn.y = 427;
		elseif(self.curPage == self.totalPage)then
			closeBtn.x = 197;
			closeBtn.y = 0;
			
			preBtn.x = 197;
			preBtn.y = 427;
		else
			closeBtn.x = 677;
			closeBtn.y = 0;
			
			preBtn.x = 11;
			preBtn.y = 427;
			
			nextBtn.x = 677;
			nextBtn.y = 427;
		end
	end
end
function PEBook.DoPrePage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		self:PrePage();
	end
end
function PEBook.DoNextPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		self:NextPage();
	end
end
function PEBook.DoGoToPage(sCtrlName,index)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self and index)then
		self:GotoPage(index);
	end
end
function PEBook.DoClosePage(sCtrlName)
	
	-- very dirty code of time magazine using EBook
	-- TODO: depracate the ebook style time magazine, use MCML page instead
	local msg = { aries_type = "OnCloseTimeMagazine", gsid = gsid, count = count, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		self:Show(false);
	end
end
function PEBook.Test()
	local config = {
		["style"] = 0,
		["pages"] = {
				"Texture/Aries/Homeland/temp/book1/page1.html",
				"Texture/Aries/Homeland/temp/book1/page2.html",
				"Texture/Aries/Homeland/temp/book1/page3.html",
				"Texture/Aries/Homeland/temp/book1/page4.html",
			},	
	}
	NPL.load("(gl)script/kids/3DMapSystemUI/PEBook/PEBook.lua");
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	local width,height = 848,541
	local alignment,left,top,width,height = "_lt",(screenWidth - width)/2,(screenHeight - height)/2,width,height;
	if(not PEBook.Test_book)then
		PEBook.Test_book = Map3DSystem.App.PEBook.PEBook:new{
			alignment = alignment,
			left = left,
			top = top,
			width = width,
			height = height,
		}
	end
	PEBook.Test_book:SetConfig(config);
	PEBook.Test_book:Show(true);
end
function PEBook.Test2()
	local config = {
		["style"] = 1,
		["pages"] = {
				"Texture/Aries/Homeland/temp/book2/page1.html",
				"Texture/Aries/Homeland/temp/book2/page2.html",
				"Texture/Aries/Homeland/temp/book2/page3.html",
				"Texture/Aries/Homeland/temp/book2/page4.html",
			},	
	}
	NPL.load("(gl)script/kids/3DMapSystemUI/PEBook/PEBook.lua");
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	local width,height = 749,499
	local alignment,left,top,width,height = "_lt",(screenWidth - width)/2,(screenHeight - height)/2,width,height;
	if(not PEBook.Test2_book)then
		PEBook.Test2_book = Map3DSystem.App.PEBook.PEBook:new{
			alignment = alignment,
			left = left,
			top = top,
			width = width,
			height = height,
		}
	end
	PEBook.Test2_book:SetConfig(config);
	PEBook.Test2_book:Show(true);
end