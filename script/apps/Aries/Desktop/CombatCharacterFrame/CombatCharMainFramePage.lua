--[[
Title: 
Author(s): zrf
Date: 2010/9/3
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
MyCompany.Aries.Desktop.CombatCharacterFrame.ShowMainWnd();
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatMagicStarPage.lua");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileHonour.lua");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileCombat.lua");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfilePvP.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");

local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");

-- create class
local libName = "CombatCharacterFrame";
local CombatCharacterFrame = commonlib.gettable("MyCompany.Aries.Desktop.CombatCharacterFrame");
CombatCharacterFrame.showcollectall = false;

CombatCharacterFrame.gems_list = nil;--背包中的宝石列表
CombatCharacterFrame.translation_list = nil;--可以平移的装备列表

--
CombatCharacterFrame.Tabs = {
	[1] = {	name = "CharInfomation",
		on_bg = "Texture/Aries/Inventory/TabCharacterOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabCharacterOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharInfoSubPage.html",
		pageCtrl = nil,
	},
	[2] = {	name = "CharCard",
		on_bg = "Texture/Aries/Inventory/TabMountOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabMountOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSelect.html",
		pageCtrl = nil,
	},
	[3] = {	name = "CharInventory",
		on_bg = "Texture/Aries/Inventory/TabFollowOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabFollowOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatInventorySubPage.html",
		pageCtrl = nil,
	},
	[4] = {	name = "CharCollection",
		on_bg = "Texture/Aries/Inventory/TabMonthlyOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabMonthlyOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatCollectableSubPage.html",
		pageCtrl = nil,
	},
	[5] = {	name = "CharMagicStar",
		on_bg = "Texture/Aries/Inventory/TabMonthlyOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabMonthlyOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatMagicStarPage.html",
		pageCtrl = nil,
	},
	[6] = {	name = "TotemPage",
		on_bg = "Texture/Aries/Inventory/TabMonthlyOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabMonthlyOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Desktop/CombatCharacterFrame/TotemPage.html",
		pageCtrl = nil,
	},
};

function CombatCharacterFrame.ShowMainWnd(tab,showcolall, bForceShow, zorder)
	--if(MyCompany.Aries.Player.IsInCombat()) then
		--return;
	--end
	tab = tonumber(tab);
	local self = CombatCharacterFrame;
	CombatCharacterFrame.showcollectall = showcolall;

	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);

	if(CombatCharacterFrame.CurTab ~= (tab or 1)) then	
		bForceShow = true;
	end
	CombatCharacterFrame.CurTab = tab or 1;

	local nid = System.App.profiles.ProfileManager.GetNID();
	MyCompany.Aries.NewProfile.NewProfileHonour.GetItems(nid);-- set nid
	MyCompany.Aries.NewProfile.NewProfileCombat.GetInfo(nid);-- set nid
	MyCompany.Aries.NewProfile.NewProfilePvP.GetItems(nid); -- NOTE andy: dirty code

	local params = {
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "CombatCharacterFrame.ShowMainWnd", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		bToggleShowHide = not bForceShow,
		cancelShowAnimation = true,
		style = style,
		zorder = zorder,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -690/2,
			y = -443/2,
			width = 690,
			height = 443,
	}
    System.App.Commands.Call("File.MCMLWindowFrame", params);

	CombatCharacterFrame.UpdateSelectState();

	if(params._page) then
		params._page.OnClose = function(bDestroy)
			NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
			local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
			QuestClientLogics.NeedRefresh_DynamicAttr_Quest();
		end
	end
	
	-- click button sound
	AudioEngine.PlayUISound("Btn7");

	--self.gems_list = EquipHelper.GetGems();
	--self.translation_list = GemTranslationPage.SearchItemListFromBag_Client();
end
function CombatCharacterFrame.RefreshPage()
	if(CombatCharacterFrame.pagectrl)then
		CombatCharacterFrame.pagectrl:Refresh(0);
	end
end
function CombatCharacterFrame.Init()
	CombatCharacterFrame.pagectrl = document:GetPageCtrl();
	--local tmp = tostring(CombatCharacterFrame.CurTab);
	--if(CombatCharacterFrame.pagectrl:GetValue("combatchartab") ~= tmp)then
		--CombatCharacterFrame.pagectrl:SetValue("combatchartab", tmp);
	--end
--
	if(CombatCharacterFrame.pagectrl and CombatCharacterFrame.pagectrl.GetNode and CombatCharacterFrame.CurTab)then
		local mcmlNode = CombatCharacterFrame.pagectrl:GetNode(tostring(CombatCharacterFrame.CurTab));
		if(mcmlNode and mcmlNode.SetAttribute)then
			mcmlNode:SetAttribute("selected", true);
		end
	end
	MyCompany.Aries.Desktop.CombatMagicStarPage.GetItems();
end

function CombatCharacterFrame.GetCurPage()
	return CombatCharacterFrame.CurTab;
end

function CombatCharacterFrame.OnRadioClick(value)
	value = tonumber(value);
	CombatCharacterFrame.CurTab = value;
	CombatCharacterFrame.UpdateSelectState()
end

function CombatCharacterFrame.UpdateSelectState()
	if(CombatCharacterFrame.pagectrl and CombatCharacterFrame.pagectrl.GetNode and CombatCharacterFrame.CurTab)then
		local mcmlNode = CombatCharacterFrame.pagectrl:GetNode(tostring(CombatCharacterFrame.CurTab));
		if(mcmlNode and mcmlNode.SetAttribute)then
			mcmlNode:SetAttribute("selected", true);
		end
	end
	if(CombatCharacterFrame.pagectrl)then
		CombatCharacterFrame.pagectrl:Refresh(0.1);	
	end
end

function CombatCharacterFrame.GetFrame()
	local s=string.format([[<iframe name="AriesInventoryAvatarView" src="%s"/>]],
							CombatCharacterFrame.Tabs[CombatCharacterFrame.CurTab].content_page );
	return s;
end

function CombatCharacterFrame.GetTitle()
	local s = string.format( [[<img src="Texture/Aries/Desktop/CombatCharacterFrame/common/title%d.png; 0 0 142 60" zorder="2" style="width:142px;height:60px;"/>]], CombatCharacterFrame.CurTab );
	return s;
end

function CombatCharacterFrame.GetTitleBG()
	local s = string.format( [[<img src="Texture/Aries/Desktop/CombatCharacterFrame/common/title%d_bg.png; 0 0 142 60" zorder="1" style="margin-top:0px;width:142px;height:60px;"/>]], CombatCharacterFrame.CurTab );
	return s;
end