--[[
Title: a simple control to show model information,include model name,description,price,manufacturer and so on.
Author(s): Sun Lingfeng
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppModelInfoWnd.lua");
_this = Map3DApp.ModelInfoWnd:new{
	name ="modelInfoWnd",
	alignment = "_lt",
	left = 0,
	top = 0,
	parent = _parent;
}
_this:Show(true);
-------------------------------------------------------
]]


NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/ModelInfo.lua");

local ModelInfoWnd = {
	name = "modelInfoWnd";
	
	alignment = "_lt";
	left = 0;
	top = 0;
	width = 60;
	height =60;
	
	parent = nil;
	modelData = nil
}
Map3DApp.ModelInfoWnd = ModelInfoWnd;

function ModelInfoWnd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	CommonCtrl.AddControl(self.name,self);
	return o;
end

function ModelInfoWnd:Show(bShow)
	local _this = CommonCtrl.GetControl(self.name);
	if(_this == nil)then
		if(bShow == false)then
			return;
		end
		self:CreateUI();
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self:CreateUI();
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		end
	end
end

function ModelInfoWnd.Destroy()
	ParaUI.Destory(self.name);
	self.parent = nil;
	self.modelData = nil;
end

function ModelInfoWnd:CreateUI()
	local _this,_parent;
	_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
	_this.scrollable = true;
	_this.fastrender = false;
	if(self.parent == nil)then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	_parent = _this;

	_this = ParaUI.CreateUIObject("container",self.name.."modelView","_lt",10,10,128,128);
	_parent:AddChild(_this);

	local top = 30;
	local left = 143;
	--model name
	_this = ParaUI.CreateUIObject("text",self.name.."mn", "_lt", left, top, 0, 0)
	_this.text = "模型名称:";
	_parent:AddChild(_this);
	
	top = top + 15;
	_this = ParaUI.CreateUIObject("text",self.name.."modelName", "_lt", left + 5, top, 77, 12)
	_this.text = "lost templer";
	_parent:AddChild(_this);
	
	top = top + 20;
	--price
	_this = ParaUI.CreateUIObject("text", self.name.."p1", "_lt", left, top, 0, 0)
	_this.text = "价格:";
	_parent:AddChild(_this);
	
	top = top + 15;
	_this = ParaUI.CreateUIObject("text", self.name.."price", "_lt", left+5, top, 0, 0)
	_this.text = "150e";
	_parent:AddChild(_this);
	
	top = top + 20;	
	--model preferential price
	_this = ParaUI.CreateUIObject("text",self.name.."p2","_lt",left,top,0,0);
	_this.text = "优惠价:";
	_parent:AddChild(_this);
	
	top = top + 15;
	_this = ParaUI.CreateUIObject("text",self.name.."price2","_lt",left+5,top,0,0);
	_this.text = "N/A";
	_parent:AddChild(_this);
	
	top = 145;
	left = 15;
	--model description
	_this = ParaUI.CreateUIObject("text", self.name.."de", "_lt", left, top, 35, 12)
	_this.text = "描述:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text",self.name.."desc", "_lt", 56, top, 137, 12)
	_this.text = "An old ancient templer";
	_parent:AddChild(_this);
	
	top = top + 20;
	--model manufacturer name
	_this = ParaUI.CreateUIObject("text", self.name.."m", "_lt", left, top, 47, 12)
	_this.text = "制作者:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."manufacturer", "_lt", 70, top, 65, 12)
	_this.text = "ParaEngine";
	_parent:AddChild(_this);
	
	top = top + 20
	--model add date
	_this = ParaUI.CreateUIObject("text",self.name.."d","_lt",left,top,0,0);
	_this.text = "创建日期:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text",self.name.."adddate","_lt",78,top,0,0);
	_this.text = "N/A";
	_parent:AddChild(_this);
	
	
	--_this = ParaUI.CreateUIObject("container","s","_lt",0,0,10,
end

function ModelInfoWnd:SetPosition(x,y)
	self.left = x;
	self.top = y;
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.x = x;
		_this.y = y;
	end
end

function ModelInfoWnd:SetSize(width,height)
	self.width = width;
	self.height = height;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then	
		local scrollBar = _this:GetChild(self.name..".vscrollbar");
		if(scrollBar)then
			scrollBar.SetPageSize = self.height;
		end
		_this:SetSize(self.width,self.height);	
		
		
		
	end	
end


function ModelInfoWnd:Resize(width,height)
	self.width = width;
	self.height = height;
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this:SetSize(width,height);
	end
end

function ModelInfoWnd:GetAbsPosition()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		return _this:GetAbsPosition();
	end
end

function ModelInfoWnd:SetParent(parentWnd)
	self.parent = parentWnd;
end

function ModelInfoWnd:SetModelInfo(modelInfo)
	if(modelInfo == nil)then
		return;
	end
	
	--show model name
	local _this = ParaUI.GetUIObject(self.name.."modelName");
	if(_this:IsValid())then
		if(modelInfo.id)then
			_this.text = tostring(modelInfo.id);
		else
			_this.text = "N/A";
		end
	end
		
	--show manufacturer name
	_this = ParaUI.GetUIObject(self.name.."manufacturer");
	if(_this:IsValid())then
		if(modelInfo.manufacturerName)then
			_this.text = modelInfo.manufacturerName;
		else
			_this.text = "N/A";
		end
	end
	
	--show model price
	_this = ParaUI.GetUIObject(self.name.."price");
	if(_this:IsValid())then
		if(modelInfo.price)then
			_this.text = tostring(modelInfo.price);
		else
			_this.text = 0;
		end
	end
	
	--show preferential price
	_this = ParaUI.GetUIObject(self.name.."price2");
	if(_this:IsValid())then
		if(modelInfo.price2)then
			_this.text = tostring(modelInfo.price2);
		else
			_this.text = "N/A";
		end
	end
	
	--show model description
	_this = ParaUI.GetUIObject(self.name.."desc");
	if(_this:IsValid())then
		if(modelInfo.desc)then
			_this.text = modelInfo.desc;
		else
			_this.text = "N/A";
		end
	end
	
	--show model add time
	_this = ParaUI.GetUIObject(self.name.."addTime");
	if(_this:IsValid())then
		if(modelInfo.price)then
			_this.text = tostring(adddate);
		else
			_this.text = "N/A";
		end
	end
end

