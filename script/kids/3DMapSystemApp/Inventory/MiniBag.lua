--[[
Title:Mini Bag (instanced) is used to display sub folders(bags) of the root bag of the current user. 
All sub bags of a user need to be purchased via the inventory application. It not only gives more server storage space of user stuffs, 
but also allow a user to bind a sub bag with an NPC, so that the NPC can sell stuffs in that bag on behalf of the user in the virtual world. 
An application developer also needs to put sellable stuffs to sub bag to open a marcket place on its application home page, etc. 
Author(s): LiXizhi
Date: 2008/1/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Inventory/MiniBag.lua");
local ctl = Map3DSystem.App.Inventory.MiniBag:new{
	name = "MiniBag1",
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
local MiniBag = {
	-- the top level control name
	name = "MiniBag1",
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
Map3DSystem.App.Inventory.MiniBag = MiniBag;

-- constructor
function MiniBag:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function MiniBag:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function MiniBag:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("MiniBag instance name can not be nil\r\n");
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
			name = self.name.."minibag",
			alignment = "_fi",
			left=0, top=0,
			width = 0,
			height = 0,
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
function MiniBag.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting MiniBag instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end