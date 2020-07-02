--[[
Title: code behind for page BrowseDiscountProduct.html
Author(s): WangTian
Date: 2009/1/6
Desc:  script/apps/Aquarius/Quest/IKEA/BrowseDiscountProduct.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local BrowseDiscountProductPage = {};
commonlib.setfield("MyCompany.Aquarius.BrowseDiscountProductPage", BrowseDiscountProductPage)

local items = System.DB.Items["NM_02furniture"];

BrowseDiscountProductPage.dsItems = {
	{name="勒克山", price="¥ 2,195.00", 
		desc=[[通过办公使用检测；坐在上面长时间办公，感觉舒适。
			]], 
		preview = items[122].IconFilePath },
	{name="亚历山大", price="¥ 349.00", 
		desc=[[椅子可挂放在桌子上，便于清洁地板
			]], 
		preview = items[120].IconFilePath },
	{name="莫西斯", price="¥ 695.00", 
		desc=[[高度可以调节，落坐舒适。
			]], 
		preview = items[121].IconFilePath },
	{name="马库斯", price="¥ 1,795.00", 
		desc=[[通过办公使用检测；坐在上面长时间办公，感觉舒适。
			]], 
		preview = items[52].IconFilePath },
};



local itemIndex = {122, 120, 121, 52};
local names = {"勒克山", "亚历山大", "莫西斯", "马库斯"};
local prices = {2195, 349, 695, 1795};
local discountprices = {1756, 280, 556, 1436};

-- datasource function for pe:gridview
function BrowseDiscountProductPage.DS_Func(index)
	if(index == nil) then
		commonlib.echo(#(names))
		return #(names);
	else
		commonlib.echo(prices)
		commonlib.echo(index)
		return {name = names[index], 
			price = "¥ "..prices[index]..".00",
			discountprice = "¥ "..discountprices[index]..".00",
			preview = items[itemIndex[index]].IconFilePath,
		};
	end
end

---------------------------------
-- page event handlers
---------------------------------

-- init
function BrowseDiscountProductPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end

function BrowseDiscountProductPage.AddToMyBag(index)
	local ikeaIndex = itemIndex[index];
	
	local modelFilePath = items[ikeaIndex].ModelFilePath;
	
	System.App.Commands.Call("Profile.Aquarius.AddToAssetBag", {
		dataSource = "temp/mybag/Aquarius/IKEA.bag.xml",
		AssetFile = modelFilePath,
	});
	
	MyCompany.Aquarius.Desktop.Dock.ShowNotification("您购买了物品: "..names[index].."\n信用卡消费: ¥ "..discountprices[index]..".00");
end