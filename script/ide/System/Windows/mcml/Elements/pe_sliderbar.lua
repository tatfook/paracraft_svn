--[[
Title: sliderbar
Author(s): LiPeng
Date: 2017/10/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_sliderbar.lua");
Elements.pe_sliderbar:RegisterAs("pe:sliderbar", "sliderbar");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Controls/SliderBar.lua");
local mcml = commonlib.gettable("System.Windows.mcml");
local SliderBar = commonlib.gettable("System.Windows.Controls.SliderBar");

local pe_sliderbar = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_sliderbar"));
pe_sliderbar:Property({"class_name", "pe:sliderbar"});

function pe_sliderbar:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	local default_css = mcml:GetStyleItem(self.class_name);
	css.float = css.float or true;
	css.height = css.height or default_css.iconSize;

	local _this = self.control;
	if(not _this) then
		_this = SliderBar:new():init(parentElem);
		self:SetControl(_this);
	else
		_this:SetParent(parentElem);
	end
	_this:SetTooltip(self:GetAttributeWithCode("tooltip", nil, true));
	_this:SetMin(tonumber(self:GetAttributeWithCode("min", 1, true)));
	_this:SetMax(tonumber(self:GetAttributeWithCode("max", 100, true)));
	_this:SetValue(tonumber(self:GetAttributeWithCode("value", 0, true)));
	local min_step = tonumber(self:GetAttributeWithCode("min_step", 1, true));
	_this:SetDirection(self:GetAttributeWithCode("direction", nil, true));
	_this:setStep(min_step, min_step * 10);
	_this:SetSliderBackground(self:GetAttributeWithCode("button_bg", nil, true));
	_this:SetSliderWidth(self:GetNumber("button_width", nil));
	_this:SetSliderHeight(self:GetNumber("button_height", nil));
	_this:SetGrooveBackground(self:GetAttributeWithCode("background", nil, true) or css["background"]);
	_this:SetGrooveWidth(self:GetNumber("background_width", nil));
	_this:SetGrooveHeight(self:GetNumber("background_height", nil));

	--local buttonName = self:GetAttributeWithCode("name"); -- touch name

	_this:Connect("valueChanged", self, self.OnChange, "UniqueConnection")

	self:UpdateGetters();

	pe_sliderbar._super.OnLoadComponentBeforeChild(self, parentElem, parentLayout, css)
end

function pe_sliderbar:OnAddGetter(name, func, bindingContext)
	if(name == "value") then
		bindingContext:AddGetter(self.control, "SetValue", func)
	end
end


function pe_sliderbar:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end

function pe_sliderbar:SetValue(value)
	self:SetAttribute("value", value);
	if(self.control) then
		self.control:SetValue(value, true);
	end
end

function pe_sliderbar:GetValue()
	if(self.control) then
		return self.control:GetValue();
	end
end

function pe_sliderbar:OnChange(value)
	local code, bindingContext = self:GetSetter("value")
	if(code) then
		bindingContext:SetValue(code, value)
	end

	local result;
	local onchange = self:GetString("onchange");
	if(onchange == "")then
		onchange = nil;
	end
	if(onchange) then
		-- the callback function format is function(buttonName, self) end
		result = self:DoPageEvent(onchange, value, self);
	end
	return result;
end

