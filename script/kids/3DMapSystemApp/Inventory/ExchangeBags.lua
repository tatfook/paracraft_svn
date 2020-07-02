--[[
Title: Exchanges bags (instanced) are UI for two bags and their money slots. One bag is for a remote user, the other is for the current user.
the two people can exchange stuffs and money using the Exchanges bags interface. It is actually an transaction completed on the server.
Author(s): LiXizhi
Date: 2008/1/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Inventory/ExchangeBags.lua");
local ctl = Map3DSystem.App.Inventory.ExchangeBags:new{
	name = "ExchangeBags1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
	bag = nil,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/kids/3DMapSystemApp/Inventory/BagCtl.lua");

-- default member attributes
local ExchangeBags = {
	-- the top level control name
	name = "ExchangeBags1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 290, 
	parent = nil,
	
	-- the Map3DSystem.App.Inventory.InventoryWnd.Bag object that this control is bound to. 
	bag = nil,
}
Map3DSystem.App.Inventory.ExchangeBags = ExchangeBags;

-- constructor
function ExchangeBags:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function ExchangeBags:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function ExchangeBags:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("ExchangeBags instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			_this.background="";
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		local ctl = Map3DSystem.App.Inventory.BagCtl:new{
			name = self.name.."ExchangeBox_RemoteUser",
			alignment = "_lt",
			left=0, top=0,
			width = 300,
			height = 100,
			parent = _parent,
			bag = self.bag,
		};
		ctl:Show();
		
		local ctl = Map3DSystem.App.Inventory.BagCtl:new{
			name = self.name.."ExchangeBox_ThisUser",
			alignment = "_lt",
			left=0, top=110,
			width = 300,
			height = 100,
			parent = _parent,
			bag = self.bag,
		};
		ctl:Show();
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- close the given control
function ExchangeBags.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ExchangeBags instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end