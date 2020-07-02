--[[
Title: code behind for page BrowseProduct.html
Author(s): WangTian
Date: 2009/1/6
Desc:  script/apps/Aquarius/Quest/IKEA/BrowseProduct.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local BrowseProductPage = {};
commonlib.setfield("MyCompany.Aquarius.BrowseProductPage", BrowseProductPage)

local items = System.DB.Items["NM_02furniture"];

BrowseProductPage.dsItems = {
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
local discountprices = {2195, 349, 695, 1795};

-- datasource function for pe:gridview
function BrowseProductPage.DS_Func(index)
	if(index == nil) then
		return #(names);
	else
		return {name = names[index], 
			price = "¥ "..prices[index]..".00",
			preview = items[itemIndex[index]].IconFilePath,
		};
	end
end

---------------------------------
-- page event handlers
---------------------------------

-- init
function BrowseProductPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end

function BrowseProductPage.AddToMyBag(index)
	local ikeaIndex = itemIndex[index];
	
	local modelFilePath = items[ikeaIndex].ModelFilePath;
	
	System.App.Commands.Call("Profile.Aquarius.AddToAssetBag", {
		dataSource = "temp/mybag/Aquarius/IKEA.bag.xml",
		AssetFile = modelFilePath,
	});
	
	MyCompany.Aquarius.Desktop.Dock.ShowNotification("您购买了物品: "..names[index].."\n一卡通消费: ¥ "..prices[index]..".00");
end