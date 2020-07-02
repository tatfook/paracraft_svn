--[[
Title: 
Author(s): zhangruofei
Date: 2010/12/13
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
MyCompany.Aries.HaqiShop.ShowMainWnd()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");
NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");

local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local HaqiShop = commonlib.gettable("MyCompany.Aries.HaqiShop");
HaqiShop.curpage = HaqiShop.curpage or 1;
HaqiShop.default_page = 1003;
HaqiShop.show = HaqiShop.show or 1001;
HaqiShop.data = HaqiShop.data or {};

local shop_tab_map = {
	["1001"] = {tabname="tabShop", name="���"},
	["1002"] = {tabname="tabShop", name="����"},
	["1003"] = {tabname="tabShop", name="��Ʒ"},
	["1004"] = {tabname="tabShop", name="����"}, -- not used
	["2001"] = {tabname="tabInventory", name="10����װ"},
	["2002"] = {tabname="tabInventory", name="20����װ"},
	["2003"] = {tabname="tabInventory", name="30����װ"},
	["2004"] = {tabname="tabInventory", name="40����װ"},
	["2005"] = {tabname="tabInventory", name="����"},
	["2006"] = {tabname="tabInventory", name="����"},
	["2007"] = {tabname="tabInventory", name="����"},
	["2008"] = {tabname="tabInventory", name=""},
	["2009"] = {tabname="tabInventory", name="װ��"},
	["2010"] = {tabname="tabInventory", name="��Ʒ"},

	["2011"] = {tabname="tabXC", name="��װ"},
	["2012"] = {tabname="tabXC", name="Ůװ"},
	["2013"] = {tabname="tabXC", name="����"},
	["2014"] = {tabname="tabXC", name="ħ����ר��"},
	
	["3001"] = {tabname="tabGems", name="��ʯ���"},
	["3002"] = {tabname="tabGems", name="1����ʯ"},
	["3003"] = {tabname="tabGems", name="2����ʯ"},
	["3004"] = {tabname="tabGems", name="3����ʯ"},
	["3005"] = {tabname="tabGems", name="4����ʯ"},

	
	["4001"] = {tabname="tabDragon", name="ι������"},
	["4002"] = {tabname="tabZJ", name="����"},
	
	["5001"] = {tabname="tabTool", name="���⹦��"},
	["5002"] = {tabname="tabTool", name="1ս��ҩ��"},
	["5003"] = {tabname="tabTool", name="2����"},

	["7001"] = {tabname="tabRune", name="�籩ϵ"},
	["7002"] = {tabname="tabRune", name="�һ�ϵ"},
	["7003"] = {tabname="tabRune", name="����ϵ"},
	["7004"] = {tabname="tabRune", name="����ϵ"},
	["7005"] = {tabname="tabRune", name="����ϵ"},
	["7006"] = {tabname="tabRune", name="ͨ��ϵ"},
}
-- virtual function: create UI
-- @param tabname: it can be string. if nil, it will lookup tabname2 in shop_tab_map to get 
-- @param tabname2: 
function HaqiShop.CreatePage(tabname,tabname2, zorder)
	if(not tabname and tabname2) then
		local tab = shop_tab_map[tostring(tabname2)];
		if(tab) then
			tabname,tabname2 = tab.tabname, tostring(tabname2);
		end
	end

	local params = {
        url = format("script/apps/Aries/HaqiShop/HaqiShop.kids1.html?tab=%s", tabname or ""), 
        app_key = MyCompany.Aries.app.app_key, 
        name = "HaqiShop.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = tonumber(zorder or 2),
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -864/2,
            y = -522/2,
            width = 864,
            height = 522,
		cancelShowAnimation = true,
		SelfPaint = System.options.IsMobilePlatform,
    };

	HaqiShop.RegisterHook();

	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = HaqiShop.OnPageClose;

	HaqiShop.LoadCurAvatar();
	HaqiShop.ShowAvatar(HaqiShop.head_gsid_cur,HaqiShop.body_gsid_cur,HaqiShop.pants_gsid_cur,HaqiShop.shoe_gsid_cur,HaqiShop.backside_gsid_cur,HaqiShop.leftweapon_gsid_cur,HaqiShop.rightweapon_gsid_cur, HaqiShop.page);
	
	--HaqiShop.ViewData(1001);
	if(tabname)then
		HaqiShop.page:SetValue("tabShop",tostring(tabname) );

		if(not tabname2) then
			tabname2 = tonumber(HaqiShop.page:GetValue(tabname.. "2"));
		end
	end

	if(tabname2)then
		HaqiShop.ViewData(tabname2);
		HaqiShop.page:SetValue(tabname .. "2",tostring(tabname2) );
	else
		HaqiShop.ViewData(HaqiShop.default_page);
		-- HaqiShop.ResetPreviewModel(HaqiShop.page);
	end
	-- HaqiShop.page:Refresh(0.01);
end


function HaqiShop.GotoTaomeePage()
	NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
	local PurchaseMagicBean = MyCompany.Aries.Inventory.PurChaseMagicBean;
	local region_id = ExternalUserModule:GetRegionID();
	if (region_id==0) then  -- taomee
		PurchaseMagicBean.Show("guide");
	else
		PurchaseMagicBean.Pay("recharge");
	end
end
