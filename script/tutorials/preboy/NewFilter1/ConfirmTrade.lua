--[[
Title: 
Author(s): yq/Leio
Date: 2009/12/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/tutorials/preboy/NewFilter1/ConfirmTrade.lua");
yq.ConfirmTrade.ShowPage();
yq.ConfirmTrade.ClosePage();
-------------------------------------------------------
]]
local ConfirmTrade = {
	page = nil,
	align = "_ct",
	left = -320,
	top = -280-20,
	width = 340,
	height = 360, 
	
	
	fruits_map = {
		[17001] = true,
		[17002] = true,
		[17003] = true,
		[17004] = true,
		[17044] = true,
	},

	
	selectedItem = nill,
    destroyNum = 0,
	maxNum = 0,
	price = 0,
}
--
commonlib.setfield("MyCompany.Aries.Inventory.ConfirmTrade",ConfirmTrade);

function ConfirmTrade.OnInit()
    local self = ConfirmTrade;
	self.pageCtrl = document:GetPageCtrl();
end

--页面关闭
function ConfirmTrade.ClosePage()
    local self = ConfirmTrade;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ConfirmTrade.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
   self.selectedItem = nil;
   self.destroyNum = 0;
   self.maxNum = 0;
   self.price = 0;
end



function ConfirmTrade.SetGUID(guid)
    local self = ConfirmTrade;
    local ItemManager = Map3DSystem.Item.ItemManager;
    local destroyNum = self.pageCtrl:GetValue("count");
    local item = ItemManager.GetItemByGUID(guid);
    if(item)then
      local gsItem = ItemManager.GetGlobalStoreItemInMemory(item,gsid)
      if(gsItem)then
           self.destroyNum = MyCompany.Aries.Inventory.confirmTrade.count;
           self.price = gsItem.psellprice;
           self.selectedItem = gsItem;
           if(self.pageCtrl)then
              self.pageCtrl.SetValue("destroyNum",count);
              self.pageCtrl:Refresh();
           end
       end
    end 
end

 

function GetSellDesc()
  
  --local destroyNum = MyCompany.Aries.Inventory.ConfirmTrade.destroyNum;
  local destroyNum = self.pageCtrl:GetValue("count");
  
end


--function ConfirmTrade.OnOk()
     --local self = ConfirmTrade;
     --if(self.selectedItem)then
        --local gsid = self.selectItem.gsid;
        --local destroyNum = self.pageCtrl:GetValue("count");
        --local price = self.price;
        --local s = string.format("恭喜你交易成功！你获得了%d奇豆。",price * count);
        --_guihelper.MessageBox(s);
     --end
--end