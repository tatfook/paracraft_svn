--[[
Title: only for teen version. 
Author(s): leio
Date: 2011/08/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Inventory/PetPage.lua");
local PetPage = commonlib.gettable("MyCompany.Aries.Inventory.PetPage");
PetPage.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
--加载文件 避免出错
NPL.load("(gl)script/apps/Aries/Inventory/TabMountExPage.lua");

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local PetPage = commonlib.gettable("MyCompany.Aries.Inventory.PetPage");

PetPage.pagesize = 30;--每页显示数据
PetPage.isFirstShow = false;
PetPage.editState = false;
PetPage.bags = {
	{bag = 23, class = 2, subclass = {6}, },
	{bag = 26, class = 2, subclass = {8}, },
}
function PetPage.OnInit()
	local self = PetPage;
	self.page = document:GetPageCtrl();
	-- tricky: this function ensures that transformed pet is always mounted, and non-transformed (empty pet) is always following the user. 
	--local mount_state = PetPage.WhereAmI();
		--
	--if(PetPage.IsTransformed()) then
		--if(mount_state ~= "mount") then
			---- this ensures that the pet is always mounted. 
			--local item = ItemManager.GetMyMountPetItem();
			--if(item) then
				--item:MountMe();
			--end
		--end
	--else
		--if(mount_state ~= "follow") then
			--local item = ItemManager.GetMyMountPetItem();
			--if(item) then
				--item:FollowMe();
			--end
		--end
	--end
end
function PetPage.DS_Func_Items(index)
	local self = PetPage;
	if(not self.cur_list)then return 0 end
	if(index == nil) then
		return #(self.cur_list);
	else
		return self.cur_list[index];
	end
end
function PetPage.RefreshPage()
	local self = PetPage;
	self.GetDataSource(function()
		if(self.page)then
			self.page:Refresh(0);
		end
	end)
end
function PetPage.ClosePage()
	local self = PetPage;
	if(self.page)then
		self.page:CloseWindow();
		self.isFirstShow = false;
	end
end

function PetPage.ShowPage(zorder)
	local self = PetPage;
	zorder = zorder or 1;
	local params = {
				url = "script/apps/Aries/Inventory/PetPage.teen.html", 
				name = "PetPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -760/2,
					y = -470/2,
					width = 760,
					height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("PetPage.ShowPage")
		end
	end
	PetPage.RefreshPage();
end
function PetPage.GetDataSource(callbackFunc)
	local self = PetPage;
	local bags = self.bags;
	 BagHelper.SearchBagList(nil,bags,function(msg)
			if(msg and msg.item_list)then
				self.cur_list = msg.item_list;

				local k,v;
				for k,v in ipairs(self.cur_list) do
					local gsid = v.gsid;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					v.is_marker = 0;
					if(gsItem)then
						local bagfamily = gsItem.template.bagfamily;
						local class = gsItem.template.class;
						local subclass = gsItem.template.subclass;
						if(bagfamily == 26 and class == 2 and subclass == 8)then
							v.is_marker = 1;
						end
					end
				end
				if(self.pagesize and self.pagesize > 0)then
					local count = #self.cur_list;
					local displaycount = math.ceil(count / self.pagesize) * self.pagesize;

					if(count == 0 )then
						displaycount = self.pagesize;
					end

					local i;
					for i = count + 1, displaycount do
						self.cur_list[i] = { gsid = 0,guid = 0,obtaintime = "",is_marker = 0, };
					end
					
				end
				table.sort(self.cur_list,function(a,b)
					if(a.obtaintime and b.obtaintime)then
						return a.is_marker > b.is_marker or (a.is_marker == b.is_marker and a.obtaintime > b.obtaintime);
					end
				end);
				if(callbackFunc)then
					callbackFunc();
				end
			end
		 end)
end
function PetPage.DoRid()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
	item:MountMe();
end

-- return true if pet is transformed. 
function PetPage.IsTransformed()
	local item_marker = ItemManager.GetItemByBagAndPosition(0, 33);
	if(item_marker and item_marker.guid > 0) then
		return true;
	end
end

local last_mount_slot_index = 1;

-- switch to the next mount pet that has not been expired. 
-- @param is_empty: if true, it will use the empty mount pet. if not, it will cycle through all active mount pets. 
function PetPage.SwitchMountPet(is_empty)
	local item = ItemManager.GetMyMountPetItem();
	if(is_empty) then
		-- 33 Transformation Marker
		local item_marker = ItemManager.GetItemByBagAndPosition(0, 33);
		if(item_marker and item_marker.guid > 0) then
			item_marker:OnClick("left");
		end
	else
		local max_count = 3;
		local i;
		for i = 0,max_count-1 do
			local index = (last_mount_slot_index+i)%max_count+1
			local active_mount_pet = ItemManager.GetItemByBagAndOrder(26, index);
			if(active_mount_pet and active_mount_pet.guid > 0) then
				active_mount_pet:OnClick("left");
				last_mount_slot_index = index;
				break;
			end
		end
	end
end

function PetPage.DoHome()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
    item:GoHome();
end
function PetPage.DoFollow()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
	if(MyCompany.Aries.Player.IsFlying() or MyCompany.Aries.Player.IsInAir()) then
        _guihelper.MessageBox("你的坐骑正飞在天空中呢，如果要变成“跟随”状态，请先按F键降落。")
	else
        item:FollowMe();
	end
end

-- get pet place status, 
-- NOTE: currently we only support mount and homeland
-- return "home", "mount", "follow", "unknown", nil
function PetPage.WhereAmI()
	local item = ItemManager.GetMyMountPetItem();
	if(not item)then return end
	return item:WhereAmI();
end