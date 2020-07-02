--[[
Title: Desktop EXP Area for Aries App
Author(s): Leio
Date: 2010/06/29
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Area: 
	---------------------------------------------------------
	| Notification									Quest	|
	|														|
	| T														|
	| a													 	|
	| g													 	|
	| e													 	|
	| t													 	|
	| 													 S	|
	| 													 p	|
	| 													 e	|
	|													 c	|
	|													 i	|
	|													 a	|
	|													 l	|
	| 														|
	| Map		  | -------- Dock -------- |		Monthly	|
	|----------------------  EXP ---------------------------|
	---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
MyCompany.Aries.Desktop.EXPArea.Init();
MyCompany.Aries.Desktop.EXPArea.SetValue(combatlel,cur_value,max_value)
------------------------------------------------------------
]]

-- create class
local EXPArea = commonlib.createtable("MyCompany.Aries.Desktop.EXPArea", {
	name = "EXPArea_instance",
	cur_value = 0,
	max_value = 0,	
	combatlel = 0,
});

EXPArea.height = 10;
EXPArea.progress_bar_width = 946;

local page;

-- invoked at Desktop.InitDesktop()
function EXPArea.Init()
	EXPArea.Create();
	EXPArea.UpdateUI();
end

-- virtual function: invoked by EXPArea.Init()
function EXPArea.Create()
	local self = EXPArea;
	local _parent;

	EXPArea.is_created = true;
	local _this = ParaUI.GetUIObject(self.name.."EXPArea");
	if(_this and _this:IsValid())then
		return
	end
	if(System.options.version == "kids") then
		EXPArea.height = 16;
		EXPArea.progress_bar_width = 764
		_parent = ParaUI.CreateUIObject("container", self.name.."EXPArea", "_mb", 0, 0, 0, self.height);
		_parent:GetAttributeObject():SetField("ClickThrough", true);
	else
		EXPArea.height = 6;
		EXPArea.progress_bar_width = 774;
		_parent = ParaUI.CreateUIObject("container", self.name.."EXPArea", "_ctb", 0, 0, 960, self.height);
	end
	_parent.background = "";	
	_parent:AttachToRoot();
	
	page = page or Map3DSystem.mcml.PageCtrl:new({url=if_else(System.options.version=="kids", "script/apps/Aries/Desktop/EXPArea/EXPArea.kids.html", "script/apps/Aries/Desktop/EXPArea/EXPArea.teen.html"),click_through = true,});

	-- one can create a UI instance like this. 
	page:Create("Aries_EXPArea_mcml", _parent, "_fi", 0, 0, 0, 0);
end

-- virtual function: refresh exp bar UI
function EXPArea.UpdateUI()
	local self = EXPArea;
	local combatlel = self.combatlel or 0;
	local cur_value = self.cur_value or 0;
	local max_value = self.max_value or 100;
	cur_value = math.min(cur_value,max_value);
	local _bar = ParaUI.GetUIObject("my_aries_teen_exp_bar");
	if(_bar:IsValid() == true) then
		local width = self.progress_bar_width;
		width = math.ceil( (cur_value / max_value) * width );
		width = math.max(3,width);
		_bar.width = width;
	end	
	local _this = ParaUI.GetUIObject(self.name.."EXPArea");
	if(_this and _this:IsValid())then
		local s = string.format("战斗等级：%d 经验：%d/%d(%d%%)",combatlel,cur_value,max_value, math.floor(cur_value/max_value*100));
		_this.tooltip = s;
	end
end

local isLocked = false;

-- show or hide the map area, toggle the visibility if bShow is nil
function EXPArea.Show(bShow)
	if(isLocked) then
		return;
	end
	local self = EXPArea;
	local _hpExpArea = ParaUI.GetUIObject(self.name.."EXPArea");
	if(_hpExpArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _hpExpArea.visible;
		end
		_hpExpArea.visible = bShow;
	end
end

-- for combat tutorial only lock the exp bar show function
function EXPArea.LockShow()
	isLocked = true;
end
function EXPArea.UnlockShow()
	isLocked = false;
end

local exp_msg = { aries_type = "QuestClientLogics_SetCombatExp", 
	combat_level = combatlel, 
	wndName = "quest", 
};


function EXPArea.SetValue(combatlel,cur_value,max_value)
	local self = EXPArea;
	if(not combatlel or not cur_value or not max_value)then return end
	local value_changed;
	if(not EXPArea.is_updated or self.combatlel ~= combatlel or self.cur_value ~= cur_value or self.max_value ~= max_value) then
		self.combatlel = combatlel;
		self.cur_value = cur_value;
		self.max_value = max_value;
		
		if(EXPArea.is_created) then
			self.UpdateUI();
			EXPArea.is_updated = true;
		end

		--在每次加经验之后,更新战斗等级
		exp_msg.combat_level = combatlel;
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", exp_msg);
	end
end

function EXPArea.GetEXP()
	local cur_value = EXPArea.cur_value or 0;
	local max_value = EXPArea.max_value or 100;
	return cur_value,max_value;
end