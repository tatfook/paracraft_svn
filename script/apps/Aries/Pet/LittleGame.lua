--[[
Title: Gifting For recharge in holiday
Author(s): LiPeng
Date: 2012/7/16
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Pet/LittleGame.lua");
local LittleGame = commonlib.gettable("MyCompany.Aries.Pet.LittleGame");
LittleGame.ShowPage();
-------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local LittleGame = commonlib.gettable("MyCompany.Aries.Pet.LittleGame");

function LittleGame.init()
	if(LittleGame.inited) then
		return;
	end
	LittleGame.inited = true;
	LittleGame.PetList = {
		{gsid = 10108,npcid = 30205,exid = 1907,tooltip = "喂我吃果冻，吃饱了就给你奖励哦"},
		{gsid = 10103,npcid = 30204,exid = 1907,tooltip = "和我玩水弹，让我变最大就给你奖励哦"},
		{gsid = 10110,npcid = 30203,exid = 1908,tooltip = "你能抓到我，就给你奖励哦"},
	};
	local k,v;
	for k,v in ipairs(LittleGame.PetList) do
		if(v.tooltip) then
			v.tooltip = "page://script/apps/Aries/Pet/MonsterHandBook/MonsterTooltip.html?tooltip="..v.tooltip;
		end
		local item = {must = {},may = {}};
		exid = v.exid;
		local exItem = ItemManager.GetExtendedCostTemplateInMemory(exid);
		local kk,vv;
		for kk,vv in ipairs(exItem.tos) do
			if(vv.key >0 and vv.value > 0) then
				local itemK,itemV;
				local hasBe = false;
				for itemK,itemV in pairs(item.must) do
					if(itemV.gsid == tonumber(vv.key)) then
						hasBe = true;
					end
				end
				if(not hasBe) then
					table.insert(item.must,{gsid = vv.key, mustappear = true});
				end
			end
		end
		if(exid == 1907) then
			table.insert(item.may,{gsid = 2131,mustappear = false});
		elseif(exid == 1908) then
			table.insert(item.may,{gsid = 2129,mustappear = false});
		end
		v.goods = item;
	end
end

function LittleGame.ShowPage()
	local params = {
		url = "script/apps/Aries/Pet/LittleGame.html",
		name = "LittleGame.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 10,
		directPosition = true,
			align = "_ct",
			x = -606/2,
			y = -486/2,
			width = 605,
			height = 486,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end