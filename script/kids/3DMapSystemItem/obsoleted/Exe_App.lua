--[[
Title: executable items including application and appcommand
Author(s): WangTian, originally drafted by LiXizhi
Date: 2009/2/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemItem/Exe_App.lua");
local dummyItem = Map3DSystem.Item.Exe_App:new({appkey=Map3DSystem.App.appkeys["Creator"]});
Map3DSystem.Item.ItemManager:AddItem(dummyItem);
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/ItemBase.lua");

local Exe_App = commonlib.inherit(Map3DSystem.Item.ItemBase, {type=Map3DSystem.Item.Types.App});
commonlib.setfield("Map3DSystem.Item.Exe_App", Exe_App)

---------------------------------
-- functions
---------------------------------

-- Get the Icon of this object
-- @param callbackFunc: function (filename) end. if nil, it will return the icon texture path. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Exe_App:GetIcon(callbackFunc)
	if(self.icon) then
		return self.icon;
	elseif(self.appkey or self.app) then
		
		self.app = self.app or Map3DSystem.App.AppManager.GetApp(self.appkey);
		if(self.app) then
			self.icon = self.app.icon or self.app.Icon;
			return self.icon;
		end	
	else
		return ItemBase:GetIcon(callbackFunc);
	end
end

-- When this item is clicked
function Exe_App:OnClick(mouseButton)
	Map3DSystem.App.Commands.Call(Map3DSystem.options.SwitchAppCommand, self.appkey);
end

-- Get the tooltip of this object
-- @param callbackFunc: function (text) end. if nil, it will return the text. otherwise it will use the callback,since the icon may not be immediately available at call time.  
function Exe_App:GetTooltip(callbackFunc)
	if(self.tooltip) then
		return self.tooltip;
	elseif(self.appkey or self.app) then
		self.app = self.app or Map3DSystem.App.AppManager.GetApp(self.appkey);
		if(self.app) then
			self.tooltip = self.app.Title;
			return self.tooltip;
		end	
	else
		return ItemBase:GetTooltip(callbackFunc);
	end
end

function Exe_App:GetSubTitle()
	if(self.subtitle) then
		return self.subtitle;
	elseif(self.appkey or self.app) then
		
		self.app = self.app or Map3DSystem.App.AppManager.GetApp(self.appkey);
		if(self.app) then
			self.subtitle = self.app.SubTitle;
			return self.subtitle;
		end	
	else
		return ItemBase:GetSubTitle(callbackFunc);
	end
end