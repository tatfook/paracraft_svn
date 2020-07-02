--[[
Title: 
Author(s): leio
Date: 2012/05/22
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/UserBag/UserBagTestPage.lua");
local UserBagTestPage = commonlib.gettable("MyCompany.Aries.Inventory.UserBagTestPage");
UserBagTestPage.ShowPage(nid);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local UserBagTestPage = commonlib.gettable("MyCompany.Aries.Inventory.UserBagTestPage");
UserBagTestPage.nid = nil;
UserBagTestPage.page = nil;
UserBagTestPage.subfolder_map = nil;
UserBagTestPage.folder_menu = nil;
UserBagTestPage.subfolder_menu = nil;
UserBagTestPage.grid_view_item_list = nil;
UserBagTestPage.selected_folder = nil;
UserBagTestPage.selected_subfolder = nil;
function UserBagTestPage.OnInit()
	local self = UserBagTestPage;
	self.page = document:GetPageCtrl();
end
function UserBagTestPage.ShowPage(nid)
	local self = UserBagTestPage;
	self.nid= nid;
	self.folder_menu,self.subfolder_map = UserBagTestPage.CreateMenu();

	local params = {
		url = "script/apps/Aries/UserBag/UserBagTestPage.html", 
		name = "UserBagTestPage.ShowPage", 
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
	System.App.Commands.Call("File.MCMLWindowFrame", params);		
	self.DoChange(nil,nil);
end
function UserBagTestPage.CreateMenu()
	local self = UserBagTestPage;
	local bags_menu = BagHelper.GetBagsMenu();
	local folder_menu = {};
	local subfolder_map = {};
	table.insert(folder_menu,{label = "全部", selected = true, keyname = nil,});
	local k,v;
	for k,v in ipairs(bags_menu) do
		table.insert(folder_menu,{label = v.label , keyname = v.keyname,});

		local kk,vv;
		local subfolder_menu = {};
		for kk,vv in ipairs(v) do
			local selected;
			if(kk == 1)then
				selected = true;
			end
			table.insert(subfolder_menu,{label = vv.label , selected = selected, keyname = vv.keyname,});
		end
		subfolder_map[v.keyname] = subfolder_menu;
	end
	return folder_menu,subfolder_map;
end
function UserBagTestPage.DoChangeFolder(folder)
	local self = UserBagTestPage;
	self.DoChange(folder,subfolder,true);
end
function UserBagTestPage.DoChangeSubfolder(subfolder)
	local self = UserBagTestPage;
	self.DoChange(self.selected_folder,subfolder);
end
function UserBagTestPage.DoChange(folder,subfolder,bResetSubMenu)
	local self = UserBagTestPage;
	self.selected_folder = folder;
	self.selected_subfolder = subfolder;

	self.subfolder_menu = nil;
	BagHelper.Search(self.nid,self.selected_folder,self.selected_subfolder,function(msg)
		if(msg and msg.item_list)then
			self.grid_view_item_list = msg.item_list;
			if(self.subfolder_map and folder)then
				self.subfolder_menu = self.subfolder_map[folder];
				if(self.subfolder_menu and bResetSubMenu)then
					local k,v;
					for k,v in ipairs(self.subfolder_menu) do
						if(k == 1)then
							v.selected = true;
						else
							v.selected = false;
						end
					end
				end
			end
			if(self.page)then
				self.page:Refresh(0);
			end
		end
	end)
end
function UserBagTestPage.DS_Func_Items(index)
	local self = UserBagTestPage;
	if(not self.grid_view_item_list)then return 0 end
	if(index == nil) then
		return #(self.grid_view_item_list);
	else
		return self.grid_view_item_list[index];
	end
end