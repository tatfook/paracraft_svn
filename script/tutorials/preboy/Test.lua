--[[
Title:
Author(s):
Date: 
Note: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/tutorials/preboy/Test.lua");
local t_1 = Preboy.Test:new{
	--x = 10,
	
	left = 10,
	top = 10,
	my_data = {
	
	},
}
t_1:CreateUI();
t_1.my_data.name = "preboy 1";

local t_2 = Preboy.Test:new{
	--x = 100,
	
		
	left = 10,
	top = 100,
	my_data = {
	},
}
t_2:CreateUI();
commonlib.echo(t_2.my_data.name);

-------------------------------------------------------
]]


-- Displays hierarchical data, such as a table of contents, in a tree structure.
local Test = {
	uid = "test_instance",
	x = 0,

	left = 0,
	top = 0,
	
	my_data = {
	
	},
}

commonlib.setfield("Preboy.Test", Test);
-- constructor
function Test:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.uid = ParaGlobal.GenerateUniqueID();
	return o;
end
function Test:CreateUI()
	local _dock = ParaUI.CreateUIObject("container", "Aries_Dock", "_lt", self.left,self.top, 100, 100);
	_dock.background = "";
	_dock:AttachToRoot();
	
	
	local _quickword = ParaUI.CreateUIObject("button", "Quickword", "_lt",30,30,50,50);
	_quickword.background = "Texture/Aries/Dock/Quickword_32bits.png; 0 0 39 39";
	_quickword.onclick = string.format(";Preboy.Test.DoClick('%s');",self.uid);
	_quickword.tooltip = "点击按钮";
	_dock:AddChild(_quickword);
	
	 CommonCtrl.AddControl(self.uid,self)
end
function Test:GetX()
	return self.x;
end
function Test.DoClick(sName)
	local ctl =  CommonCtrl.GetControl(sName);
	if(ctl)then
		commonlib.echo(ctl:GetX());
	end
end

--------------------
local exercise_static = {

}
commonlib.setfield("Preboy.exercise_static", exercise_static);
Preboy.exercise_static.name = "aaa";


