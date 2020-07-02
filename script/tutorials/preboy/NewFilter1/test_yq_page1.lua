--[[
Title: 
Author(s): yq/Leio
Date: 2009/12/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/tutorials/preboy/NewFilter1/test_yq_page1.lua");
yq.test_yq_page1.ShowPage();
yq.test_yq_page1.ClosePage();
-------------------------------------------------------
]]
local test_yq_page1 = {
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

	
	selectedItem = nil,
	destroyNum = 0,
	maxNum = 0,
	price = 0,
}
commonlib.setfield("yq.test_yq_page1",test_yq_page1);


--
function test_yq_page1.OnInit()
	local self = test_yq_page1;
	self.pageCtrl = document:GetPageCtrl();
	-- guid
end


function test_yq_page1.SetGUID(value)
	guid = value;
end

--function test_yq_page1.ShowPage()
	--local self = test_yq_page1;
	--System.App.Commands.Call("File.MCMLWindowFrame", {
			--url = "script/tutorials/preboy/NewFilter1/test_yq_page1.html", 
			--name = "test_yq_page1.ShowPage", 
			--app_key=MyCompany.Aries.app.app_key, 
			--isShowTitleBar = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			--zorder = 1,
			--isTopLevel = true,
			--allowDrag = false,
			--directPosition = true,
				--align = "_lt",
				--x = 0,
				--y = 0,
				--width = 300,
				--height =250,
		--});
--end

function test_yq_page1.ClosePage()
	local self = test_yq_page;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="test_yq_page1.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
		
	self.destroyNum = nil;
	self.maxNum = nil;
	self.price = nil;
	self.selectedItem = nil;
end

function test_yq_page1.SetGS(guid)
    local self = test_yq_page1;
    local ItemManager = Map3DSystem.Item.ItemManager;
    local item = ItemManager.GetItemByGUID(guid);
    if(item)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
		if(gsItem) then
			--commonlib.echo(gsItem);
			self.maxNum = item.copies;
			self.price = gsItem.psellprice;
			self.selectedItem = gsItem;
			if(self.pageCtrl)then
				
				self.pageCtrl:SetValue("icon",gsItem.icon);
				self.pageCtrl:Refresh();
			end
		end
	end
end
          

function test_yq_page1.OnOk()
    local self = test_yq_page1;
    if(self.selectedItem)then
		local gsid = self.selectedItem.gsid;
		local destroyNum = self.pageCtrl:GetValue("count");
		local price = self.price;
		local s = string.format("恭喜你交易成功！你获得了%d奇豆。",price * count);
		_guihelper.MessageBox(s);
   end
end


----the data source for item
--function test_yq_page.DS_Func_Items(dsTable, index, pageCtrl)      
	---- get the class of the 
	--local class = "character";
	--local subclass = "collect";
	--
    --if(not dsTable.status) then
        ---- use a default cache
        --test_yq_page.GetItems(class, subclass, pageCtrl, "access plus 0", dsTable)
    --elseif(dsTable.status == 2) then    
        --if(index == nil) then
			--return dsTable.Count;
        --else
			--return dsTable[index];
        --end
    --end 
--end
--


		
