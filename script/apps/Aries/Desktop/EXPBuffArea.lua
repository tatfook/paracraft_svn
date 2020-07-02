--[[
Title: Desktop EXPBuff Area for Aries App
Author(s): Leio
Date: 2011/03/07
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Area: 
	---------------------------------------------------------
	| Notification		   expbuff1	expbuff2		Quest	|
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
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local item_gsid = 12001;
QuestClientLogics.DoUseItem_AddExpPercent(item_gsid);


NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local gsid = 40001;
local bHas,guid = ItemManager.IfOwnGSItem(gsid);
if(guid)then
	ItemManager.DestroyItem(guid,1);
end

NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");
EXPBuffArea.UpdateBuff();

NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");
EXPBuffArea.Show_LobbyBtn(false)

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BubbleHelper = commonlib.gettable("CommonCtrl.BubbleHelper");

local hasGSItem = ItemManager.IfOwnGSItem;
-- create class
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");
commonlib.partialcopy(EXPBuffArea, {
	buffmap = {
		[12001] = {
			12001,--经验强化药丸
			40001,--经验提成的次数
		},
		[12002] = {
			12002,--假日努力药丸
			40003,--经验提成的次数
		},
	},
});

EXPBuffArea.name = "EXPArea_instance";
function EXPBuffArea.CanCreateBuff()
	return true;
end
--经验强化药丸
function EXPBuffArea.CreateBuff(parent_name)
	local self = EXPBuffArea;
	self.parent_name = parent_name;
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", self.name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_icon_32bits.png";
	_btn.tooltip = "经验强化药丸：\n平日使用\n使用后20场战斗经验加成100%";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", self.name.."btntips", "_lt", -15, 5, 60, 40);
	_btntips.background = "";
	_btntips.tooltip = "经验强化药丸：\n平日使用\n使用后20场战斗经验加成100%";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	--_btntips.scalingx = 1.1;
	--_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);
	self.UpdateBuff()
end
function EXPBuffArea.ShowBuff(bShow)
	local self = EXPBuffArea;
	local parent = ParaUI.GetUIObject(self.parent_name);
	if(parent and parent:IsValid())then
		parent.visible = bShow;
	end
end
function EXPBuffArea.CanCreateBuff_Holiday()
	return true;
end
--假日努力药丸
function EXPBuffArea.CreateBuff_Holiday(parent_name_holiday)
	local self = EXPBuffArea;
	self.parent_name_holiday = parent_name_holiday;
	local parent = ParaUI.GetUIObject(parent_name_holiday);
	if(not parent)then
		return
	end
	local _btn = ParaUI.CreateUIObject("container", self.name.."_btn_holiday", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_holiday_icon_32bits.png";
	_btn.tooltip = "假日努力药丸：\n假日使用\n使用后20场战斗经验加成50%";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", self.name.."btntips_holiday", "_lt", -15, 5, 60, 40);
	_btntips.background = "";
	_btntips.tooltip = "假日努力药丸：\n假日使用\n使用后20场战斗经验加成50%";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	--_btntips.scalingx = 1.1;
	--_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);
	self.UpdateBuff();
end
function EXPBuffArea.ShowBuff_Holiday(bShow)
	local self = EXPBuffArea;
	local parent = ParaUI.GetUIObject(self.parent_name_holiday);
	if(parent and parent:IsValid())then
		parent.visible = bShow;
	end
end

function EXPBuffArea.UpdateBuff()
	local self = EXPBuffArea;
	LOG.std("","info","EXPBuffArea.UpdateBuff", nil);
	self._UpdateBuff();
	self._UpdateBuff_Holiday();
	-- refresh all pe:slot tag
	Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
end
function EXPBuffArea._UpdateBuff()
	local self = EXPBuffArea;
	local hasGSItem,__,__,copies = hasGSItem(40001);
	copies = copies or 0;
	if(copies == 0)then
		self.ShowBuff(false)
	else
		self.ShowBuff(true)
		local _btntips = ParaUI.GetUIObject(self.name.."btntips");
		if(_btntips and _btntips:IsValid())then
			local s = string.format("%d/%d",copies,20);
			_btntips.text = s;
		end
	end
end
function EXPBuffArea._UpdateBuff_Holiday()
	local self = EXPBuffArea;
	local hasGSItem,__,__,copies = hasGSItem(40003);
	copies = copies or 0;
	if(copies == 0)then
		self.ShowBuff_Holiday(false)
	else
		self.ShowBuff_Holiday(true)
		local _btntips = ParaUI.GetUIObject(self.name.."btntips_holiday");
		if(_btntips and _btntips:IsValid())then
			local s = string.format("%d/%d",copies,20);
			_btntips.text = s;
		end
	end
end


-- global double exp buff
function EXPBuffArea.CreateBuff_global_double_exp(parent_name)
	EXPBuffArea.parent_name_global_double_exp = parent_name;
	local name = "global_double_exp";
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png";
	--_btn.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btn.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", name.."_btntips", "_lt", 0, 0, 62, 60);
	_btntips.background = "";
	_btntips.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);

	-- first hide the exp buff, wait for server data
	EXPBuffArea.ShowBuff_global_double_exp(false);
end
--青龙祝福
function EXPBuffArea.ShowBuff_global_double_exp(bShow, n_ExpScaleAcc)
	--if(EXPBuffArea.parent_name_global_double_exp) then
		--local parent = ParaUI.GetUIObject(EXPBuffArea.parent_name_global_double_exp);
		--if(parent and parent:IsValid())then
			--parent.visible = bShow;
			---- set tooltip
			--local name = "global_double_exp";
			--local _btntips = ParaUI.GetUIObject(name.."_btntips");
			--if(_btntips and _btntips:IsValid() == true) then
				--if(n_ExpScaleAcc == 1) then
					--_btntips.tooltip = "青龙的祝福：\n青龙大人赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
				--elseif(n_ExpScaleAcc == 2) then
					--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
				--elseif(n_ExpScaleAcc == 3) then
					--_btntips.tooltip = "青龙的节日祝福：\n青龙大人在节日赐予所有哈奇的强大祝福，\n战斗经验得到4倍强化！";
				--end
			--end
		--end
	--end
	if(QuestArea.ResetGsidStatus_global_double_exp)then
		QuestArea.ResetGsidStatus_global_double_exp(bShow, n_ExpScaleAcc)
	end
end


-- global double exp buff
function EXPBuffArea.CreateBuff_damage_boost_pill(parent_name)
	EXPBuffArea.parent_name_damage_boost_pill_buff = parent_name;
	local name = "damage_boost_pill_buff";
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png";
	-- 12012_CombatPills_DamageBoost
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(12012);
	if(gsItem) then
		_btn.background = gsItem.icon;
	end
	--_btn.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btn.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", name.."_btntips", "_lt", 0, 0, 62, 60);
	_btntips.background = "";
	_btntips.tooltip = "攻击药丸\n3天有效\n通用攻击:+5%";
	--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);

	-- first hide the exp buff, wait for server data
	EXPBuffArea.ShowBuff_damage_boost_pill_buff();
end

function EXPBuffArea.ShowBuff_damage_boost_pill_buff()
	-- 15512_12012_CombatPills_DamageBoost_Marker
	local bShow = false;
	if(hasGSItem(15512) or hasGSItem(15566)) then
		bShow = true;
	end
	if(EXPBuffArea.parent_name_damage_boost_pill_buff) then
		local parent = ParaUI.GetUIObject(EXPBuffArea.parent_name_damage_boost_pill_buff);
		if(parent and parent:IsValid())then
			parent.visible = bShow;
			-- set tooltip
			local name = "damage_boost_pill_buff";
			local _btntips = ParaUI.GetUIObject(name.."_btntips");
			if(_btntips and _btntips:IsValid() == true) then
				--if(n_ExpScaleAcc == 1) then
					--_btntips.tooltip = "青龙的祝福：\n青龙大人赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
				--elseif(n_ExpScaleAcc == 2) then
					--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
				--elseif(n_ExpScaleAcc == 3) then
					--_btntips.tooltip = "青龙的节日祝福：\n青龙大人在节日赐予所有哈奇的强大祝福，\n战斗经验得到4倍强化！";
				--end
			end
		end
	end
end


-- global double exp buff
function EXPBuffArea.CreateBuff_resist_boost_pill(parent_name)
	EXPBuffArea.parent_name_resist_boost_pill_buff = parent_name;
	local name = "resist_boost_pill_buff";
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png";
	-- 12013_CombatPills_ResistBoost
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(12013);
	if(gsItem) then
		_btn.background = gsItem.icon;
	end
	--_btn.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btn.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", name.."_btntips", "_lt", 0, 0, 62, 60);
	_btntips.background = "";
	_btntips.tooltip = "防御药丸\n3天有效\n通用防御:+2%";
	--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);

	-- first hide the exp buff, wait for server data
	EXPBuffArea.ShowBuff_resist_boost_pill_buff();
end

function EXPBuffArea.ShowBuff_resist_boost_pill_buff()
	-- 15513_12013_CombatPills_ResistBoost_Marker
	local bShow = false;
	if(hasGSItem(15513) or hasGSItem(15567)) then
		bShow = true;
	end
	if(EXPBuffArea.parent_name_resist_boost_pill_buff) then
		local parent = ParaUI.GetUIObject(EXPBuffArea.parent_name_resist_boost_pill_buff);
		if(parent and parent:IsValid())then
			parent.visible = bShow;
			-- set tooltip
			local name = "resist_boost_pill_buff";
			local _btntips = ParaUI.GetUIObject(name.."_btntips");
			if(_btntips and _btntips:IsValid() == true) then
				--if(n_ExpScaleAcc == 1) then
					--_btntips.tooltip = "青龙的祝福：\n青龙大人赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
				--elseif(n_ExpScaleAcc == 2) then
					--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
				--elseif(n_ExpScaleAcc == 3) then
					--_btntips.tooltip = "青龙的节日祝福：\n青龙大人在节日赐予所有哈奇的强大祝福，\n战斗经验得到4倍强化！";
				--end
			end
		end
	end
end


-- global double exp buff
function EXPBuffArea.CreateBuff_HP_boost_pill(parent_name)
	EXPBuffArea.parent_name_HP_boost_pill_buff = parent_name;
	local name = "HP_boost_pill_buff";
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png";
	-- 12014_CombatPills_HPBoost
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(12014);
	if(gsItem) then
		_btn.background = gsItem.icon;
	end
	--_btn.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btn.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", name.."_btntips", "_lt", 0, 0, 62, 60);
	_btntips.background = "";
	_btntips.tooltip = "耐力药丸\n3天有效\nHP:+200";
	--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);

	-- first hide the exp buff, wait for server data
	EXPBuffArea.ShowBuff_HP_boost_pill_buff();
end

function EXPBuffArea.ShowBuff_HP_boost_pill_buff()
	-- 15514_12014_CombatPills_HPBoost_Marker
	local bShow = false;
	if(hasGSItem(15514) or hasGSItem(15568)) then
		bShow = true;
	end
	if(EXPBuffArea.parent_name_HP_boost_pill_buff) then
		local parent = ParaUI.GetUIObject(EXPBuffArea.parent_name_HP_boost_pill_buff);
		if(parent and parent:IsValid())then
			parent.visible = bShow;
			-- set tooltip
			local name = "HP_boost_pill_buff";
			local _btntips = ParaUI.GetUIObject(name.."_btntips");
			if(_btntips and _btntips:IsValid() == true) then
				--if(n_ExpScaleAcc == 1) then
					--_btntips.tooltip = "青龙的祝福：\n青龙大人赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
				--elseif(n_ExpScaleAcc == 2) then
					--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
				--elseif(n_ExpScaleAcc == 3) then
					--_btntips.tooltip = "青龙的节日祝福：\n青龙大人在节日赐予所有哈奇的强大祝福，\n战斗经验得到4倍强化！";
				--end
			end
		end
	end
end


-- global double exp buff
function EXPBuffArea.CreateBuff_criticalstrike_boost_pill(parent_name)
	EXPBuffArea.parent_name_criticalstrike_boost_pill_buff = parent_name;
	local name = "criticalstrike_boost_pill_buff";
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png";
	-- 12017_CritPill
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(12017);
	if(gsItem) then
		_btn.background = gsItem.icon;
	end
	--_btn.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btn.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", name.."_btntips", "_lt", 0, 0, 62, 60);
	_btntips.background = "";
	_btntips.tooltip = "暴击药丸\n3天有效\n暴击率:+10%";
	--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);

	-- first hide the exp buff, wait for server data
	EXPBuffArea.ShowBuff_criticalstrike_boost_pill_buff();
end

function EXPBuffArea.ShowBuff_criticalstrike_boost_pill_buff()
	-- 15535_12017_CritPill_Marker
	local bShow = false;
	if(hasGSItem(15535) or hasGSItem(15569)) then
		bShow = true;
	end
	if(EXPBuffArea.parent_name_criticalstrike_boost_pill_buff) then
		local parent = ParaUI.GetUIObject(EXPBuffArea.parent_name_criticalstrike_boost_pill_buff);
		if(parent and parent:IsValid())then
			parent.visible = bShow;
			-- set tooltip
			local name = "criticalstrike_boost_pill_buff";
			local _btntips = ParaUI.GetUIObject(name.."_btntips");
			if(_btntips and _btntips:IsValid() == true) then
				--if(n_ExpScaleAcc == 1) then
					--_btntips.tooltip = "青龙的祝福：\n青龙大人赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
				--elseif(n_ExpScaleAcc == 2) then
					--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
				--elseif(n_ExpScaleAcc == 3) then
					--_btntips.tooltip = "青龙的节日祝福：\n青龙大人在节日赐予所有哈奇的强大祝福，\n战斗经验得到4倍强化！";
				--end
			end
		end
	end
end


-- global double exp buff
function EXPBuffArea.CreateBuff_resilience_boost_pill(parent_name)
	EXPBuffArea.parent_name_resilience_boost_pill_buff = parent_name;
	local name = "resilience_boost_pill_buff";
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end

	local _btn = ParaUI.CreateUIObject("container", name.."_btn", "_lt", 0, 0, 30, 30);
	_btn.background = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png";
	-- 12018_ResiliencePill
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(12018);
	if(gsItem) then
		_btn.background = gsItem.icon;
	end
	--_btn.tooltip = "青龙的祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
	--_btn.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	parent:AddChild(_btn);

	local _btntips = ParaUI.CreateUIObject("button", name.."_btntips", "_lt", 0, 0, 62, 60);
	_btntips.background = "";
	_btntips.tooltip = "韧性药丸\n3天有效\n韧性:+10%";
	--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在节假日赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);

	-- first hide the exp buff, wait for server data
	EXPBuffArea.ShowBuff_resilience_boost_pill_buff();
end

function EXPBuffArea.ShowBuff_resilience_boost_pill_buff()
	-- 15536_12018_ResiliencePill_Marker
	local bShow = false;
	if(hasGSItem(15536) or hasGSItem(15570)) then
		bShow = true;
	end
	if(EXPBuffArea.parent_name_resilience_boost_pill_buff) then
		local parent = ParaUI.GetUIObject(EXPBuffArea.parent_name_resilience_boost_pill_buff);
		if(parent and parent:IsValid())then
			parent.visible = bShow;
			-- set tooltip
			local name = "resilience_boost_pill_buff";
			local _btntips = ParaUI.GetUIObject(name.."_btntips");
			if(_btntips and _btntips:IsValid() == true) then
				--if(n_ExpScaleAcc == 1) then
					--_btntips.tooltip = "青龙的祝福：\n青龙大人赐予所有哈奇的祝福，\n战斗经验得到双倍强化！";
				--elseif(n_ExpScaleAcc == 2) then
					--_btntips.tooltip = "青龙的假日祝福：\n青龙大人在周末晚上赐予所有哈奇的祝福，\n战斗经验得到3倍强化！";
				--elseif(n_ExpScaleAcc == 3) then
					--_btntips.tooltip = "青龙的节日祝福：\n青龙大人在节日赐予所有哈奇的强大祝福，\n战斗经验得到4倍强化！";
				--end
			end
		end
	end
end

------------------
--队伍大厅
function EXPBuffArea.Create_LobbyBtn(parent_name)
	local self = EXPBuffArea;
	self.parent_name_lobbyBtn = parent_name;
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end
	local btn = ParaUI.CreateUIObject("button", self.name.."btn_lobbyservice", "_lt", 0, -5, 64, 64);
	btn.background = "Texture/Aries/LobbyService/team_32bits.png";
	btn.tooltip = "组队大厅";
	btn.animstyle = 23;
	btn.onclick = ";MyCompany.Aries.Desktop.EXPBuffArea.ShowLobbyPage();";
	parent:AddChild(btn);

	local _btntips = ParaUI.CreateUIObject("button", self.name.."btntips_lobbyservice", "_lt", -20, 20, 102, 40);
	_btntips.background = "";
	_btntips.tooltip = "组队大厅";
	_btntips.font = "System;11;bold";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.onclick = ";MyCompany.Aries.Desktop.EXPBuffArea.ShowLobbyPage();";
	_btntips.scalingx = 1.1;
	_btntips.scalingy = 1.1;
	parent:AddChild(_btntips);
end
function EXPBuffArea.Create_LobbyBtn_V2(parent_name)
	local self = EXPBuffArea;
	self.parent_name_lobbyBtn = parent_name;
	local parent = ParaUI.GetUIObject(parent_name);
	if(not parent)then
		return
	end
	local btn = ParaUI.CreateUIObject("button", self.name.."btn_lobbyservice", "_lt", 12, 0, 36, 49);
	btn.background = "Texture/Aries/Dock/kids/teamplay_32bits.png;0 0 36 49";
	btn.tooltip = "组队大厅";
	btn.onclick = ";MyCompany.Aries.Desktop.EXPBuffArea.ShowLobbyPage();";
	parent:AddChild(btn);

	local _btntips = ParaUI.CreateUIObject("button", self.name.."btntips_lobbyservice", "_lt", -20, 36, 102, 40);
	_btntips.background = "";
	_btntips.tooltip = "组队大厅";
	_btntips.font = "System;11;";
	_guihelper.SetFontColor(_btntips, "0 0 0");
	_btntips.shadow = true;
	_btntips.enabled = false;
	_btntips:GetAttributeObject():SetField("TextShadowColor", _guihelper.ColorStr_TO_DWORD("#60ffffff"));
	_btntips:GetAttributeObject():SetField("TextShadowQuality", 8);
	parent:AddChild(_btntips);
end

function EXPBuffArea.Show_LobbyBtn(bShow)
	local self = EXPBuffArea;
	local parent = ParaUI.GetUIObject(self.parent_name_lobbyBtn);
	if(parent and parent:IsValid())then
		parent.visible = bShow;
	end
end
function EXPBuffArea.ShowLobbyPage()
	local self = EXPBuffArea;
	LobbyClientServicePage.ShowPage();
	self.Bounce_Static_Icon(self.name.."btn_lobbyservice","stop")
end

local last_room_users = {};
--[[
更新状态
	   state:null 没有进入房间
			waiting 进入房间 人未满 
			full 进入放进 人已满
			gaming 游戏进行中,pve:已经开启副本 pvp:已经进行匹配
--]]
function EXPBuffArea.Update_LobbyBtn()
	local self = EXPBuffArea;
	local state;
	local login_room_id = LobbyClientServicePage.GetRoomID();
	if(login_room_id)then
		LobbyClient:GetGameDetail(login_room_id, true, function(result)
				local player_count = 0;
				local max_players = 0;
				local game_type;
				local status;
				local is_master = false;
				local game_info;
				if(result and result.formated_data) then
					game_info = result.formated_data;
					if(game_info and game_info.players)then
						local nid = tostring(System.User.nid);
						local has_player = game_info.players[nid];
						max_players = game_info.max_players or 4;
						player_count = game_info.player_count or 0;
						local start_time = game_info.start_time;
						game_type = game_info.game_type;
						status = game_info.status;

						local modelist = LobbyClientServicePage.LoadModeList(game_info.keyname);
						local node = LobbyClient:GetModeNode(modelist,game_info.mode)
						--if(node and game_type == "PvE")then
							----pve 读推荐人数
							--max_players = node.recommend_players or max_players;
						--end
						if(game_info.owner_nid and nid == game_info.owner_nid)then
							is_master = true;
						end
						local player_nid, _;
						for player_nid, _ in pairs(game_info.players) do
							if(not last_room_users[player_nid]) then
								NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
								local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
								ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.Lobby, from=player_nid, words="加入了组队房间"});
							end
						end
						for player_nid, _ in pairs(last_room_users) do
							if(not game_info.players[player_nid]) then
								NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
								local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
								ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.Lobby, from=player_nid, words="离开了组队房间"});
							end
						end
						last_room_users = commonlib.copy(game_info.players);

						if(has_player)then
							if(status == "started" or status == "match_making")then
								state = "gaming";
								if(status == "match_making")then
									if(player_count < max_players)then
										state = "waiting";
									end
								end
							else
								state = "waiting";
								if(player_count >= max_players)then
									state = "full";
								end
							end
						else
							state = "null";
						end
					end
				else
					state = "null"
				end

				local txt = "";
				if(state == "waiting")then
					txt = string.format("等待中:%d/%d",player_count,max_players);

				elseif(state == "full")then
					txt = string.format("人齐了:%d/%d",player_count,max_players);
					-- self.Bounce_Static_Icon(self.name.."btn_lobbyservice","bounce")
					if(max_players > 1 and is_master and (not status or status == "open") )then
						LobbyClientServicePage.PoP_PanelForMaster();
					end
				elseif(state == "gaming")then
					if(status == "started")then
						txt = "进行中";
					elseif(status == "match_making")then
						txt = "排队中";
					end
				end

				if(game_info and (state ~= "null")) then
					if(TeamClientLogics:IsInTeam()) then
						--只比较已经存在的房间
						if(game_info.owner_nid)then
							-- if team leader is not room owner, exit the room. 
							if(game_info.owner_nid ~= tostring(TeamClientLogics:GetTeamLeaderNid() or nil)) then
								LobbyClientServicePage.DoLeaveGame(login_room_id);
								txt = "";
							end
						end
					else
						-- try to join the team leader. 
						if(not is_master and status~="started" and status~="gaming" and status~="match_making") then
							-- added some status
							TeamClientLogics:JoinTeamMember(game_info.owner_nid, true);
						end
					end
				end
				local btntips = ParaUI.GetUIObject(self.name.."btntips_lobbyservice");
				if(btntips and btntips:IsValid())then
					if(txt=="")then
						self.Bounce_Static_Icon(self.name.."btn_lobbyservice", "stop");
					elseif((status=="match_making" or state == "waiting" or state == "full") and  btntips.text~=text) then
						self.Bounce_Static_Icon(self.name.."btn_lobbyservice", "bounce");
					end
					btntips.text = txt;
					if(txt == "") then
						btntips.visible = false;
						BroadcastHelper.PushLabel({id="match_making", label = nil, max_duration=0, color = "0 255 0", scaling=1, bold=true, shadow=true,});
					else
						btntips.visible = true;
						btntips:DoAutoSize();
						if(state == "gaming" and status == "started") then
							BroadcastHelper.PushLabel({id="match_making", label = format("组队撮合：%s", txt), max_duration=5000, color = "0 255 0", scaling=1, bold=true, shadow=true,});
						else
							BroadcastHelper.PushLabel({id="match_making", label = format("组队撮合：%s", txt), max_duration=30000, color = "0 255 0", scaling=1, bold=true, shadow=true,});
						end
					end
				end
		end,true)
	else
		last_room_users = {};
		local btntips = ParaUI.GetUIObject(self.name.."btntips_lobbyservice");
		if(btntips and btntips:IsValid())then
			btntips.text = "";
			btntips.visible = false;
			self.Bounce_Static_Icon(self.name.."btn_lobbyservice", "stop");
			BroadcastHelper.PushLabel({id="match_making", label = nil, max_duration=0, color = "0 255 0", scaling=1, bold=true, shadow=true,});
		end
	end
end
function EXPBuffArea.Bounce_Static_Icon(name,bounce_or_stop)
	local _icon = ParaUI.GetUIObject(name);
	if(_icon and _icon:IsValid() == true) then
		if(bounce_or_stop == "bounce") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Bounce", true);
		elseif(bounce_or_stop == "stop") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Bounce");
		end
	end
end
