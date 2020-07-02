--[[
Title: 
Author(s): leio
Date: 2011/08/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Inventory/PetOtherPlayerPage.lua");
local PetOtherPlayerPage = commonlib.gettable("MyCompany.Aries.Inventory.PetOtherPlayerPage");
PetOtherPlayerPage.ShowPage()
-------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local PetOtherPlayerPage = commonlib.gettable("MyCompany.Aries.Inventory.PetOtherPlayerPage");
PetOtherPlayerPage.nid = nil;
PetOtherPlayerPage.gsid = nil;
function PetOtherPlayerPage.OnInit()
	local self = PetOtherPlayerPage;
	self.page = document:GetPageCtrl();
end

function PetOtherPlayerPage.ShowPage(nid,zorder)
	local self = PetOtherPlayerPage;
	zorder = zorder or 1;
	self.nid = nid or Map3DSystem.User.nid;
	local function show()
		System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/Inventory/PetOtherPlayerPage.teen.html", 
					name = "PetOtherPlayerPage.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					zorder = zorder,
					directPosition = true,
						align = "_ct",
						x = -330/2,
						y = -470/2,
						width = 330,
						height = 470,
			});	
	end
	if(self.nid == Map3DSystem.User.nid)then
	    local item = ItemManager.GetItemByBagAndPosition(0, 33);
		if(item)then
			self.gsid = item.gsid;
			show();
		end
	else
		ItemManager.GetItemsInOPCBag(self.nid, 0, "", function(msg)
			local item = ItemManager.GetOPCItemByBagAndPosition(self.nid, 0, 33);
			if(item)then
				self.gsid = item.gsid;
				show();
			end
		end,"access plus 30 seconds");
	end
end
