--[[
Title: BindingContext
Author(s): LiXizhi
Date: 2019/10/31
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/BindingContext.lua");
local BindingContext = commonlib.gettable("System.Windows.mcml.BindingContext");
local bindingcontext = BindingContext:new():Init(page);
------------------------------------------------------------
]]
local BindingContext = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.mcml.BindingContext"));

function BindingContext:ctor()
	self:Clear()
end

function BindingContext:Init(page)
	self.page = page
	return self;
end

function BindingContext:Clear()
	self.getter = {};
	self.setter = {};
end

function BindingContext:GetPage()
	return self.page;
end

function BindingContext:GetWindow()
	if(self.page) then
	end
end

-- get the environment table of the binding context
function BindingContext:GetPageScope()
	return self.page:GetPageScope()
end

function BindingContext:AddGetter(uiElement, funcName, getterFunc)
	self.getter[uiElement] = self.getter[uiElement] or {};
	self.getter[uiElement][funcName] = getterFunc;
end

function BindingContext:AddSetter(uiElement, funcName, setterFunc)
	-- TODO: 
end

function BindingContext:ApplyGetters()
	for uiElement, props in pairs(self.getter) do
		for prop, func in pairs(props) do
			uiElement[prop](uiElement, func());
		end
	end
end

-- @param setterName: should be the name of the function or the value itself. such as "setValue" or "item.data"
function BindingContext:SetValue(setterName, value)
	local env = self:GetPageScope()
	local setter = commonlib.getfield(setterName, env);
	if(type(setter) == "function") then
		setter(value)
	else
		commonlib.setfield(setterName, value, env);
	end
end

