--[[
Title: 
Author(s): Leio
Date: 2011/07/04
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Family/FamilyMembersPage.lua");
local FamilyMembersPage = commonlib.gettable("Map3DSystem.App.Family.FamilyMembersPage");
FamilyMembersPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

local FamilyMembersPage = commonlib.gettable("Map3DSystem.App.Family.FamilyMembersPage");
FamilyMembersPage.selected_node = nil;
FamilyMembersPage.is_edit_state = nil;
FamilyMembersPage.only_show_online = nil;
function FamilyMembersPage.OnInit()
	local self = FamilyMembersPage;
	self.page = document:GetPageCtrl();
end
function FamilyMembersPage.RefreshPage(bClearNode)
	local self = FamilyMembersPage;
	local manager = FamilyManager.CreateOrGetManager();
	if(self.page)then
		manager:Refresh(function()
			if(not manager:IsMember())then
				self.page:CloseWindow();
				return;	
			end
			if(bClearNode)then
				self.selected_node = nil;
			end
			self.page:Refresh(0);
		end)
	end
end

function FamilyMembersPage.OnlyRefreshPage()
	local self = FamilyMembersPage;
	if(self.page)then
		self.page:Refresh(0);
	end
end

function FamilyMembersPage.ShowPage()
	local self = FamilyMembersPage;
	local manager = FamilyManager.CreateOrGetManager();
	self.is_edit_state = nil;
	self.selected_node = nil;
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
				url = "script/apps/Aries/Family/FamilyMembersPage.teen.html", 
				name = "FamilyMembersPage.ShowPage", 
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
		if(params._page) then
			params._page.OnClose = function(bDestroy)
				Dock.OnClose("FamilyMembersPage.ShowPage")
			end
		end		
	end)
end
function FamilyMembersPage.TeleportToLaLa()
end
function FamilyMembersPage.ShowPage_InviteBox()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Family/FamilyInviteBox.teen.html", 
			name = "FamilyMembersPage.ShowPage_InviteBox", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -275/2,
				y = -130/2,
				width = 275,
				height = 130,
	});		
end