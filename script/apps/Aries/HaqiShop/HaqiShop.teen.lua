--[[
Title: 
Author(s): zhangruofei
Date: 2010/12/13
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.teen.lua");
MyCompany.Aries.HaqiShop.CreatePage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");
NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local HaqiShop = commonlib.gettable("MyCompany.Aries.HaqiShop");
HaqiShop.curpage = HaqiShop.curpage or 1;
HaqiShop.show = HaqiShop.show or 1001;
HaqiShop.data = HaqiShop.data or {};

-- virtual function: create UI
function HaqiShop.CreatePage(tabname,tabname2)
	local width,height = 827,542;

	local params = {
        url = format("script/apps/Aries/HaqiShop/HaqiShop.teen.html?tab=%s", tabname or ""), 
        app_key = MyCompany.Aries.app.app_key, 
        name = "HaqiShop.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 2,
        allowDrag = true,
		isTopLevel = true,
        directPosition = true,
        align = "_ct",
        x = -width * 0.5,
        y = -height * 0.5,
        width = width,
        height = height,
		SelfPaint = System.options.IsMobilePlatform,
	};

	HaqiShop.RegisterHook();

	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = HaqiShop.OnPageClose;
	
	HaqiShop.LoadCurAvatar();
	HaqiShop.ShowAvatar(HaqiShop.head_gsid_cur,HaqiShop.body_gsid_cur,HaqiShop.pants_gsid_cur,HaqiShop.shoe_gsid_cur,HaqiShop.backside_gsid_cur,HaqiShop.leftweapon_gsid_cur,HaqiShop.rightweapon_gsid_cur);
	
	HaqiShop.ViewData(1003);
	if(tabname)then
		HaqiShop.page:SetValue("tabShop",tostring(tabname) );
	end

	if(tabname2)then
		HaqiShop.page:SetValue(tabname .. "2",tostring(tabname2) );
	end
end


function HaqiShop.GotoTaomeePage()
	NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
	local PurchaseMagicBean = MyCompany.Aries.Inventory.PurChaseMagicBean;
	PurchaseMagicBean.Pay("recharge");
	-- ParaGlobal.ShellExecute("open", "http://pay.61.com/buy/paytype?type=cardpay", "", "", 1);
end
