--[[
Title: 
Author(s): leio
Date: 2011/07/29
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.lua");
local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");
MagicStarPage.ShowPage()
-------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local MagicStarPage = commonlib.gettable("MyCompany.Aries.Inventory.MagicStarPage");
MagicStarPage.stone_list = {{gsid=998}, {gsid=977}};
MagicStarPage.staff_list = nil;
MagicStarPage.nid= nil;
MagicStarPage.mlvl=nil;
MagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory(); 

function MagicStarPage.OnInit()
	local self = MagicStarPage;
	self.page = document:GetPageCtrl();
end

function MagicStarPage.GetM() 
	local bean = MagicStarPage.bean;
	if(bean)then
        return "能量值: " .. bean.m .. "/" .. bean.nextlelm;
	end
end

function MagicStarPage.ClosePage()
	local self = MagicStarPage;
	if (self.page) then
	 self.page:CloseWindow();
	end
end

function MagicStarPage.GetMlvl()
	MagicStarPage.bean = MyCompany.Aries.Pet.GetBean();
	--commonlib.echo("=================MagicStarPage.bean");
	--commonlib.echo(MagicStarPage.bean);
	return MyCompany.Aries.Player.GetVipLevel();
end

function MagicStarPage.DS_Func_Items_stone_list(index)
	local self = MagicStarPage;
	if(not self.stone_list)then return 0 end
	if(index == nil) then
		return #(self.stone_list);
	else
		return self.stone_list[index];
	end
end

function MagicStarPage.DS_Func_Items_staff_list(index)
	local self = MagicStarPage;
	if(not self.staff_list)then return 0 end
	if(index == nil) then
		return #(self.staff_list);
	else
		return self.staff_list[index];
	end
end

function MagicStarPage.ShowPage(zorder,nid)
	local self = MagicStarPage;
	zorder = zorder or 1
	self.nid = nid or System.User.nid;
	self.staff_list = self.Search_MagicStaffList();
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Desktop/CombatCharacterFrame/MagicStarPage.teen.html", 
				name = "MagicStarPage.ShowPage", 
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
		});	
	self.ReloadData();
end

function MagicStarPage.ReloadData()
	local self = MagicStarPage;
	self.staff_list = self.Search_MagicStaffList();
	self.GetMlvl();
	if(self.page)then
		self.page:Refresh(0.01);
	end
end

--获取魔法星物品列表
function MagicStarPage.Search_MagicStoneList(callbackFunc)
	local self = MagicStarPage;
	--刷新0号包 获得 gsid=998的物品
	local bag = 0;
	ItemManager.GetItemsInBag( bag, "" .. bag, function(msg)
		local list = {
			[1] = {guid = -1},
			[2] = {guid = -1},
			[3] = {guid = -1},
			[4] = {guid = -1},
		};
		-- energy stone
		local bHas,guid = hasGSItem(998);
		if(bHas)then
			list[1].guid = guid;
			list[1].gsid = 998;
		end
		-- energy stone shard
		local _bHas,_guid = hasGSItem(977);
		if(_bHas)then
			list[2].guid = _guid;
			list[2].gsid = 977;
		end

		if(callbackFunc)then
			callbackFunc({
				list = list,
			});
		end
	end, "access plus 30 second");
end

--获取魔法星手杖列表
function MagicStarPage.Search_MagicStaffList()
	local self = MagicStarPage;
	local list = {};
	local gsids = MyCompany.Aries.VIP.GetAvailableVIPLeftHandItemGSIDs();
	if(gsids)then
		local k, gsid;
		for k,gsid in ipairs(gsids) do
			local has_item,guid = hasGSItem(gsid);
			table.insert(list,{
				gsid = gsid,
				has_item = has_item, 
			});
		end
	end
	return list;
end