--[[
Title: 
Author(s): Leio
Date: 2010/07/01
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/MainWnd.lua");
MyCompany.Aries.Inventory.ShowMainWnd(true, 2);
NPL.load("(gl)script/apps/Aries/Inventory/TabMountExPage.lua");
MyCompany.Aries.Inventory.TabMountExPage.ShowItemView("1","3");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Inventory/MainWnd.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local TabMountExPage = {
	editState = false,--是否正在更改坐骑的名字
	language = nil,--喂食的时候坐骑的语言
	speak_timer = nil,
	page = nil,
	isFirstShow = false,--是否是第一次显示
};
commonlib.setfield("MyCompany.Aries.Inventory.TabMountExPage", TabMountExPage);
function TabMountExPage.OnInit()
	local self = TabMountExPage;
	self.page = document:GetPageCtrl();

	TabMountExPage.RegisterHook();

	if(not self.isFirstShow)then
		self.isFirstShow = true;
		--重新加载自己坐骑的成长数据
		MyCompany.Aries.Pet.GetRemoteValue(nil,function(msg)
			if(self.page)then
				self.page:Refresh(0.01);	
			end
		end)
	end

	self.page.OnClose = function()
	end
end
-- data source for items
function TabMountExPage.DS_Func_Items(index)
	if(index ~= nil) then
		return {};
	elseif(index == nil) then
		return 0;
	end
end
function TabMountExPage.SetEditState(v)
	local self = TabMountExPage;
	self.editState = v;
end
function TabMountExPage.GetEditState()
	local self = TabMountExPage;
	return self.editState
end

function TabMountExPage.RegisterHook()
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = MyCompany.Aries.Inventory.TabMountExPage.HookHandler, 
		hookName = "TabMountPage_PetAction", appName = "Aries", wndName = "mountpet"});

	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = MyCompany.Aries.Inventory.TabMountExPage.HookHandler, 
		hookName = "TabMountPage_ShowPageState", appName = "Aries", wndName = "mountpet"});
end


function TabMountExPage.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TabMountPage_PetAction", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		
	MyCompany.Aries.Inventory.TabMountExPage.language = nil;
	if(TabMountExPage.speak_timer)then
		TabMountExPage.speak_timer:Change();
	end
end
--[[
local msg = { pet_action_type == "pet_action_feeding", wndName = "mountpet", };
CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
--]]
function TabMountExPage.HookHandler(nCode, appName, msg, value)
	local self = TabMountExPage;
	if(msg.pet_action_type == "pet_action_feeding")then
		TabMountExPage.language = msg.language;
		
		--刷新在这里 MyCompany.Aries.Inventory.RefreshMainWnd(2);
		
		--说话周期
		NPL.load("(gl)script/ide/timer.lua");
		if(TabMountExPage.speak_timer)then
			TabMountExPage.speak_timer:Change();
		else
			TabMountExPage.speak_timer = commonlib.Timer:new({callbackFunc = function(timer)
				--清空语言
				TabMountExPage.language = nil;
				if(TabMountExPage.page)then
					TabMountExPage.page:Refresh(0.1);
				end
			end})
		end
		--5000 millisecond 后结束
		TabMountExPage.speak_timer:Change(5000, nil)
	end
	return nCode;
end
--[[
local params = {
	tabvalue = 1,
}
--]]
function TabMountExPage.RefreshPage(params)
	local self = TabMountExPage;
	if(not params)then return end

end
function TabMountExPage.ClosePage()
	local self = TabMountExPage;
	 
    local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
    MyCardsManager.OnClose();

    MyCompany.Aries.Inventory.HideMainWnd();
    MyCompany.Aries.Inventory.TabMountExPage.SetEditState(false);
    
    
    --unhook 龙的语言
    MyCompany.Aries.Inventory.TabMountExPage.UnregisterHook();
    
    --恢复
    MyCompany.Aries.Inventory.TabMountExPage.isFirstShow = false;
end

-- obsoleted renamed to ShowItemView1
function TabMountExPage.ShowItemView(index,subindex)
	--LOG.std("", "debug","TabMonutExPage", "BBBB" .. index);
	local self = TabMountExPage;
	local page = self.page;
	if(not page)then return end
	index = tostring(index);
	subindex = tostring(subindex);

	local frame = page:GetNode("AriesInventoryMountItemView");
	local urls = {
        --卡片
	    --["1"] = "script/apps/Aries/Inventory/Cards/CardsSelectionPage.html",
	    --龙背包 喂食
        ["1"] = "script/apps/Aries/Inventory/DragonBags/DragonBagsSelectionPage.html",
	    --技能
        ["2"] = "script/apps/Aries/Inventory/Skills/SkillsSelectionPage.html",
	    --龙装备
        ["3"] = "script/apps/Aries/Inventory/Equipments/EquipmentsSelectionPage.html",
	};
	local titles = {
        --["1"] = "Texture/Aries/Combat/BagPack/Card/card_title_32bits.png; 0 0 267 72",
        ["1"] = "Texture/Aries/Combat/BagPack/DragonBag/TitleDragonBag_32bits.png; 0 0 267 72",
        ["2"] = "Texture/Aries/Combat/BagPack/Skill/TitleSkill_32bits.png; 0 0 267 72",
        ["3"] = "Texture/Aries/Combat/BagPack/Equipment/TitleEquipment_32bits.png; 0 0 267 72",
    }
    if(frame ~= nil) then
		local cachePolicy = "access plus 1 minute";
        if(index) then
            TabMountExPage.TabValue = index;
            page:SetValue("Level2Tabs", index);
            page:SetValue("title_bg", titles[index]);
            page:GetNode("AriesInventoryMountItemView");
			local url = urls[index];
			if(index == "1" and subindex and subindex~= "nil")then
				local DragonBagsSelectionPage = commonlib.gettable("MyCompany.Aries.Inventory.DragonBagsSelectionPage");
				DragonBagsSelectionPage.TabValue = subindex;
			end
            frame:SetAttribute("src", url);
            page:Refresh(0.1);
        end
    end
end

function TabMountExPage.ShowItemView1(index,subindex)
	--LOG.std("", "debug","TabMonutExPage", "AAAA" .. index);
	local self = TabMountExPage;
	local page = self.page;
	if(not page)then return end
	index = tostring(index);
	subindex = tostring(subindex);

	local frame = page:GetNode("AriesInventoryMountItemView");
	local urls = {
        --卡片
	    --["1"] = "script/apps/Aries/Inventory/Cards/CardsSelectionPage.html",
	    --龙背包 喂食
        ["1"] = "script/apps/Aries/Inventory/DragonBags/DragonBagsSelectionPage1.html",
	    --技能
        ["2"] = "script/apps/Aries/Inventory/Skills/SkillsSelectionPage1.html",
	    --龙装备
        ["3"] = "script/apps/Aries/Inventory/Equipments/EquipmentsSelectionPage.html",
	};
	local titles = {
        --["1"] = "Texture/Aries/Combat/BagPack/Card/card_title_32bits.png; 0 0 267 72",
        ["1"] = "Texture/Aries/Combat/BagPack/DragonBag/TitleDragonBag_32bits.png; 0 0 267 72",
        ["2"] = "Texture/Aries/Combat/BagPack/Skill/TitleSkill_32bits.png; 0 0 267 72",
        ["3"] = "Texture/Aries/Combat/BagPack/Equipment/TitleEquipment_32bits.png; 0 0 267 72",
    }
    if(frame ~= nil) then
		local cachePolicy = "access plus 1 minute";
        if(index) then
            TabMountExPage.TabValue = index;
            page:SetValue("Level2Tabs", index);
            page:SetValue("title_bg", titles[index]);
            page:GetNode("AriesInventoryMountItemView");
			local url = urls[index];
			if(index == "1" and subindex and subindex~= "nil")then
				local DragonBagsSelectionPage = commonlib.gettable("MyCompany.Aries.Inventory.DragonBagsSelectionPage");
				DragonBagsSelectionPage.TabValue = subindex;
			end
            frame:SetAttribute("src", url);
            page:Refresh(0.1);
        end
    end
end
TabMountExPage.ShowItemView = TabMountExPage.ShowItemView1; -- override