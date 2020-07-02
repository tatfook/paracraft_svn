--[[
Title: 
Author(s): Leio
Date: 2013/07/04
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Family/FamilyShopPage.lua");
local FamilyShopPage = commonlib.gettable("Map3DSystem.App.Family.FamilyShopPage");
FamilyShopPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local FamilyShopPage = commonlib.gettable("Map3DSystem.App.Family.FamilyShopPage");
function FamilyShopPage.OnInit()
	FamilyShopPage.page = document:GetPageCtrl();
end
function FamilyShopPage.ShowPage()
	local manager = FamilyManager.CreateOrGetManager();
	manager:Refresh(function()
		if(not manager:IsMember())then
			_guihelper.Custom_MessageBox("你尚未加入任何家族。要创建家族请找黎明城的城主索罗斯·莫汉。",function(result)
				if(result == _guihelper.DialogResult.Yes)then
					NPL.load("(gl)script/apps/Aries/Family/FamilyListPage.lua");
					local FamilyListPage = commonlib.gettable("Map3DSystem.App.Family.FamilyListPage");
					FamilyListPage.ShowPage();
				end
			end,_guihelper.MessageBoxButtons.YesNo,{show_label = true, yes = "查看家族列表", no = "取消"});
			return;
		end
		local params = {
				url = "script/apps/Aries/Family/FamilyShopPage.teen.html", 
				name = "FamilyShopPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -760/2,
					y = -470/2,
					width = 760,
					height = 470,
		}
		FamilyShopPage.list = nil;
        FamilyShopPage.is_editing_index = -1;
		FamilyShopPage.temp_edit_cnt = 0;
		FamilyShopPage.members = manager:GetMembers();
		FamilyShopPage.LoadAdminBag(function()
			System.App.Commands.Call("File.MCMLWindowFrame", params);
		end)
	end)
end
function FamilyShopPage.IsAdmin()
	local manager = FamilyManager.CreateOrGetManager();
	local family_info = manager:GetFamilyInfo();
	if(family_info and family_info.admin and family_info.admin == Map3DSystem.User.nid)then
		return true;
	end
end
function FamilyShopPage.LoadAdminBag(callbackFunc)
	local manager = FamilyManager.CreateOrGetManager();
	local family_info = manager:GetFamilyInfo();
	if(family_info and family_info.admin)then
		local nid = family_info.admin;
		BagHelper.SearchBag(nid,{bag = 50100,search_bag_all = true},function(msg)
			if(msg and msg.item_list)then
				FamilyShopPage.list = msg.item_list;
				local k,v;
				for k,v in ipairs(FamilyShopPage.list) do
					local clientdata = v.clientdata;
					local serverdata = v.serverdata or "";
					if(v.gsid and type(serverdata)=="string")then
						if(serverdata == "")then
							local gsItem = ItemManager.GetGlobalStoreItemInMemory(v.gsid);
							if(gsItem)then
								v.pricegsid = gsItem.template.stats[526] or 984;
								v.pricecnt = gsItem.template.stats[527] or 1;
							end
						else
							local parsed_serverdata = {};
							NPL.FromJson(serverdata, parsed_serverdata);
							if(parsed_serverdata.price)then
								v.pricegsid = parsed_serverdata.price.gsid;
								v.pricecnt = parsed_serverdata.price.cnt;
							end
						end
						
					end
				end
				local len = #FamilyShopPage.list;
				while(len > 0) do
					local node = FamilyShopPage.list[len];
					if(node and (node.gsid == 20054 or node.gsid == 20056  or node.gsid == 20053))then
						table.remove(FamilyShopPage.list,len);
					end
					len = len - 1;
				end
				if(callbackFunc)then
					callbackFunc();
				end
			end
		end,"access plus 0 minutes")
	end
end
function FamilyShopPage.GetMenus()
	if(not FamilyShopPage.menus)then
		FamilyShopPage.menus = {
			{ label="奖品", selected=true, keyname="",},
		}
	end
	return FamilyShopPage.menus;
end
function FamilyShopPage.GetMenu_CheckedNode()
	local k,v;
	for k,v in ipairs(FamilyShopPage.menus) do
		if(v.selected)then
			return v;
		end
	end
end
function FamilyShopPage.DS_Func_Items(index)
	if(not FamilyShopPage.list)then return 0 end
	if(index == nil) then
		return #(FamilyShopPage.list);
	else
		return FamilyShopPage.list[index];
	end
end
function FamilyShopPage.DS_Func_Members(index)
	if(not FamilyShopPage.members)then return 0 end
	if(index == nil) then
		return #(FamilyShopPage.members);
	else
		return FamilyShopPage.members[index];
	end
end