
--[[
Title: bbs message display rolling bar
Author(s): SunLingFeng
Date: 2007/12/28
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppBBSBar.lua");
_this = CommonCtrl.MapScrollBar:new{
	name = "bbsScrollBar";
	parent = nil;
}
_this.Show(true);
-------------------------------------------------------]]


NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/ide/common_control.lua");

if(not Map3DApp)then Map3DApp = {};end;
---rolling state enum
Map3DApp.RollState = {};
Map3DApp.RollState.rolling = 1;
Map3DApp.RollState.stop = 2;
Map3DApp.RollState.pause = 3;


-----MapBBSBar
local MapBBSBar = {
	name = "rollingBar";
	parent = nil;
	
	--layout
	alignment = "_lt";
	left = 5;
	top = 0;
	width = 600;
	height = 24;
	
	--msg list,a circle queue
	maxMsgCount = 30;
	
	rollSpeed = 2;
	
	--private data
	billboards = {};
	billboardCount = 4;
	billboardSpace = 15;
	
	freeBillboards = nil;
	activeBillboards = nil;	
	
	font = nil;
	fontColorCount = 1;
	fontHighLight = "130 30 130";
	
	timerID;
	rollingState = Map3DApp.RollState.stop;
	lastRollingState = Map3DApp.RollState.stop;
	
	selectItem = nil;
	
	--event
	onItemSelect = nil;
	onMsgPop = nil;
	onMsgEmpty = nil;
}
CommonCtrl.MapBBSBar = MapBBSBar;

--public
function MapBBSBar:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

--public 
function MapBBSBar:Destroy()
	if(self.freeBllBoards ~= nil)then
		self.freeBillboards:Dispose();
		self.freeBillboards = nil;
	end
	
	if(self.activeBillboards ~= nil)then
		self.activeBillboards:Dispose();
		self.activeBillboards = nil;
	end
	
	self.msg = nil;
	selectItem = nil;
	onItemSelect = nil;
	onRolling = nil;
	
	if(self.timerID ~= nil)then
		NPL.KillTimer(self.timerID);
	end
	ParaUI.Destroy(self.name);
end

--public
function MapBBSBar:Show(bShow)
	local _this;
	_this = CommonCtrl.GetControl(self.name);
	--init control if it is not exist
	if(_this == nil)then
		if(bShow == false)then
			return;
		end
		self:Init();
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	--recreate ui if it is invalid
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self:ResetUI();
		--return;
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
		
		if(_this.visible == true)then
			self:Resume();
		else
			self:Pause();
		end
	end
end

--private function, once called once on oject creation
function MapBBSBar:Init()
	--create msg queue;
	self.msgs = Map3DApp.CycleQueue:new{
		maxElementCount = self.maxMsgCount;
	}
	
	self.freeBillboards = Map3DApp.Queue:new{};
	self.activeBillboards = Map3DApp.Queue:new{};
	
	self.fontColor = {};
	self.fontColor[1] = "0 0 0";
	self.fontColor[2] = "255 0 0";
	
	--create ui related things
	self:ResetUI();
	
	CommonCtrl.AddControl(self.name,self);
	
	self.timerID =  Map3DApp.Timer.GetNewTimerID();
	--timer callback command
	self.onRolling = string.format(";temp=CommonCtrl.GetControl(%q);if(temp~= nil)then temp:Update();end",self.name);
end

--private function,reset all ui related object
--call this method after sence reset 
function MapBBSBar:ResetUI()
	local _parent = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
	if(self.parent == nil)then
		_parent:AttachToRoot();
	else
		self.parent:AddChild(_parent)
	end
	
	local _this = ParaUI.CreateUIObject("container",self.name.."clip","_lt",6,5,self.width-12,self.height-9);
	_this.onmouseup = string.format(";CommonCtrl.MapBBSBar.OnMouseUp(%q)",self.name);
	_this.background = "";
	_this.fastrender = false;
	_parent:AddChild(_this);
	_parent = _this;
	
	self.freeBillboards:Clear();
	self.activeBillboards:Clear();
	
	for i = 1,self.billboardCount do
		_this = ParaUI.CreateUIObject("text",self.name..i,"_lt",0,0,100,self.height-8);
		_this:GetFont("text").color = self.fontColor[ math.mod(i,2)+1];
		_this.onmouseleave = string.format(";CommonCtrl.MapBBSBar.OnMouseLeave(%q,%s)",self.name,i);
		_this.onmouseenter = string.format(";CommonCtrl.MapBBSBar.OnMouseEnter(%q,%s)",self.name,i);
		_this.visible = false;
		_parent:AddChild(_this);
		self.freeBillboards:AddElement(self.name..i);
	end
	
	if(self.rollingState ~= Map3DApp.RollState.stop)then
		NPL.KillTimer(self.timerID);
		NPL.SetTimer(self.timerID,0.05,self.onRolling);
	end
end

--private method,stop rolling when mouse enter a billboard
function MapBBSBar.OnMouseEnter(ctrName,index)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("can not find "..ctrName.."\r\n");
		return;
	end
	
	--stop rolling if it is on rolling
	self:Pause();
	
	--high light select item
	local _this = ParaUI.GetUIObject(self.name..index);
	if(_this:IsValid())then
		_this:GetFont("text").color = self.fontHighLight;
		self.selectItem = _this.text;
	end
end

--private,resume rolling state when mouse leave billboard
function MapBBSBar.OnMouseLeave(ctrName,index)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("can not find "..ctrName.."\r\n");
		return;
	end
	
	self:Resume();
	
	local _this = ParaUI.GetUIObject(self.name..index);
	if(_this:IsValid())then
		_this:GetFont("text").color = self.fontColor[math.mod(index,2)+1];
		self.selectItem = nil;
	end
end

--private,fired when click on a billboard
function MapBBSBar.OnMouseUp(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("can not find "..ctrName.."\r\n");
		return;
	end
	
	--fire on item select event
	if(self.selectItem ~= nil and self.onItemSelect ~= nil)then
		self.onItemSelect(self.selectItem);
	end
end

--private,AddMessage will automatic call this method to roll when 
--new message come
function MapBBSBar:ActiveRolling()
	--only start timer if it's stopped
	if(self.rollingState == Map3DApp.RollState.stop)then
		self.rollingState = Map3DApp.RollState.rolling;
		NPL.SetTimer(self.timerID,0.02,self.onRolling);
	end
end

--private,update display
function MapBBSBar:Update()
	--pause rolling
	if(self.rollingState == Map3DApp.RollState.pause)then
		return;
	end

	self:RefreshBillboard();
	
	--no more msg? stop rolling
	if(self.activeBillboards:GetElementCount() < 1)then
		self.rollingState = Map3DApp.RollState.stop;
	end
	
	if(self.rollingState == Map3DApp.RollState.stop)then
		NPL.KillTimer(self.timerID);
		--fire message empty event
		if(self.msgs:GetElementCount() < 1 and self.onMsgEmpty ~= nil)then
			self.onMsgEmpty(self.name);
		end
		return
	end
	
	self:Rolling();
end

--private
function MapBBSBar:RefreshBillboard()
	--show a new msg
	local billboardName,_this;
	
	if(self.msgs:GetElementCount() > 0 and self.freeBillboards:GetElementCount() > 0)then
		if(self.activeBillboards:GetElementCount() > 0)then
			billboardName = self.activeBillboards:LastElement();
			if(billboardName ~= nil)then
				_this = ParaUI.GetUIObject(billboardName);
				if(_this:IsValid())then
					local x,__,width = _this:GetAbsPosition();
					local parent = ParaUI.GetUIObject(self.name);
					if(parent:IsValid())then
						local __,__,pWidth = parent:GetAbsPosition();
						if( x + width <= pWidth)then
							billboardName = self.freeBillboards:PopElement();
							if(billboardName ~= nil)then
								_this = ParaUI.GetUIObject(billboardName);
								if(_this:IsValid())then
									_this.text = self:PopMessage();
									_this.x = x + width + self.billboardSpace;
									_this.width = _this:GetTextLineSize();
									_this.visible = true;
									self.activeBillboards:AddElement(billboardName);
								end
							end
						end
					end
				end
			end
		else
			_this = ParaUI.GetUIObject(self.name);
			if(_this:IsValid())then
				local __,__,width = _this:GetAbsPosition();
				billboardName = self.freeBillboards:PopElement();
				if(billboardName ~= nil)then
					_this = ParaUI.GetUIObject(billboardName);
					if(_this:IsValid())then
						_this.text = self:PopMessage();
						_this.x = width;
						_this.width = _this:GetTextLineSize() + 5;
						_this.visible = true;
						self.activeBillboards:AddElement(billboardName);
					end
				end
			end
		end
	end

	
	--recycle billboard if it is out of view
	if(self.activeBillboards:GetElementCount() > 0)then
		billboardName = self.activeBillboards:Peek();
		if(billboardName ~= nil)then
			_this = ParaUI.GetUIObject(billboardName);
			if(_this:IsValid())then
				if(-_this.x > _this.width)then
					self.activeBillboards:PopElement();
					self.freeBillboards:AddElement(billboardName);
					_this.visible = false;
				end
			end
		end
	end
end

--private move the position of each billboard
function MapBBSBar:Rolling()
	local iter = self.activeBillboards:GetEnumerator();
	for i=1,self.activeBillboards:GetElementCount() do
		local billboardName = iter();
		if(billboardName ~= nil)then
			local _this = ParaUI.GetUIObject(billboardName);
			if(_this:IsValid())then
				_this.x = _this.x - self.rollSpeed;
			end
		end
	end
end

--public
function MapBBSBar:SetParent(_parent)
	if(_parent ~= nil and _parent:IsValid())then
		self.parent = _parent;
	end
end

--public
function MapBBSBar:SetPosition(x,y,width,height)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	
	local lastWidth = _this.width;
	--update container position
	_this.x = x;
	_this.y = y;
	_this.width = width;
	_this.height = height;
	
	--update clip container position
	_this = ParaUI.GetUIObject(self.name.."clip");
	if(_this:IsValid())then
		_this.width = width - 12;
		_this.height = height - 9;
	end
	
	--update billboards position
	if(self.rollingState == Map3DApp.RollState.stop)then
		self.lastActiveBillboardsPos = width;
	else
		local billboardName = self.activeBillboards:Peek();
		if(billboardName ~= nil)then
			local distToEnd;
			_this = ParaUI.GetUIObject(billboardName);
			if(_this:IsValid())then
				if(_this.x > 0)then
					distToEnd = lastWidth - _this.x;
				else
					distToEnd = math.abs(_this.x) + lastWidth;
				end
				local delta = width -distToEnd - _this.x;
				
				local iter = self.activeBillboards:GetEnumerator()
				for i = 1,self.activeBillboards:GetElementCount() do
					billboardName = iter();
					if(billboardName ~= nil)then
						_this = ParaUI.GetUIObject(billboardName);
						if(_this:IsValid())then
							_this.x = _this.x + delta;
						end
					end
				end
			end
		end
	end		
end

function MapBBSBar:GetPosition()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	
	return _this:GetAbsPosition();
end

--public 
function MapBBSBar:AddMessage(newMsg)
	--do nothing if the msg queue is full 
	if(self.msgs:GetElementCount() >= self.msgs:GetMaxElementCount())then
		log(self.name.."message queue is full,add message failed-_-#\n");
		return false;
	end
	
	self.msgs:AddElement(newMsg);
	
	--active rolling if the rolling bar is stopped
	self:ActiveRolling();
	return true;
end

--public
function MapBBSBar:PopMessage()
	if(self.msgs:GetElementCount() < 1)then
		return nil;
	end
	
	--fire onPopMsg event
	if(self.onMsgPop ~= nil)then
		self.onMsgPop(self.msgs:Peek());
	end
	
	return(self.msgs:PopElement());
end

--public
function MapBBSBar:Pause()
	if(self.rollingState == Map3DApp.RollState.pause)then
		return;
	end
	self.lastRollingState = ((self.rollingState == Map3DApp.RollState.rolling) and Map3DApp.RollState.rolling ) or Map3DApp.RollState.stop;
	self.rollingState = Map3DApp.RollState.pause;
end

--public
function MapBBSBar:Resume()
	if(self.rollingState == Map3DApp.RollState.pause)then
		self.rollingState = self.lastRollingState;
	end
end

--public 
function MapBBSBar:IsMsgFull()
	if(self.msgs.GetElementCount() < self.msgs.GetMaxElementCount())then
		return false;
	else
		return true;
	end
end

--public
function MapBBSBar:SetFontColor(color,colorIndex)
	if(self.fontColor[colorIndex] == nil)then
		return;
	end
	
	self.fontColor[colorIndex] = color;
	
	for i=1,self.billboardCount do
		local _this = GetUIObject(self.name..i);
		if(_this:IsValid())then
			_this:GetFont("text").color = self.fontColor[math.mod(i,2)+1];
		end
	end
end

function MapBBSBar:SetRollingSpeed(speed)
	self.rollSpeed = speed;
end

function MapBBSBar.Test(bbsBarInstance)
	bbsBarInstance:AddMessage("帕拉巫(ParaWorld) 是一个3D社交网络平台. 在帕拉巫世界中, 每个玩家有自己的3D化身, 虚拟的3D家园, 并且能够轻易的创造出属于自己的游戏世界");
	
end




