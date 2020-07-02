--[[
Title: FamilyListPage.lua
Author(s): Leio
Date: 2011/11/08
Desc: this page show two kinds of result the most hot and fresh family
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Family/FamilyListPage.lua");
local FamilyListPage = commonlib.gettable("Map3DSystem.App.Family.FamilyListPage");
FamilyListPage.ShowPage(search_type);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Family/FamilyMsg.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local FamilyMsg = commonlib.gettable("Map3DSystem.App.Family.FamilyMsg");
NPL.load("(gl)script/apps/Aries/Family/FamilyHelper.lua");
local FamilyHelper = commonlib.gettable("Map3DSystem.App.Family.FamilyHelper");

local FamilyListPage = commonlib.gettable("Map3DSystem.App.Family.FamilyListPage");
FamilyListPage.search_type = "hot"; --two types:hot and fresh
FamilyListPage.list = nil; --searched result
FamilyListPage.page = nil; --mcml page instance
FamilyListPage.selected_node = nil; --a selected node
FamilyListPage.search_result_node = nil; -- used in FamilySearchResultPage.teen.html
function FamilyListPage.OnInit()
	local self = FamilyListPage;
	self.page = document:GetPageCtrl();
end
function FamilyListPage.ShowPage(search_type)
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("view_family_group");
	
	local self = FamilyListPage;
	search_type = search_type or "hot";
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Family/FamilyListPage.teen.html", 
				name = "FamilyListPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true,
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -530/2,
					y = -470/2,
					width = 630,
					height = 470,
		});		
	FamilyListPage.DoChangeType(search_type);
end
function FamilyListPage.DoChangeType(search_type)
	local self = FamilyListPage;
	self.search_type = search_type;
	self.SearchResult(function(msg)
		if(msg and msg.list)then
			self.list = msg.list;
			self.OnClickItem(1)
			if(self.page)then
				self.page:Refresh(0.1);
			end
		end
	end)
end
function FamilyListPage.SearchResult(callbackFunc)
	local self = FamilyListPage;
	if(self.search_type == "hot")then
		FamilyHelper.SearchHotFamily(callbackFunc);
	else
		FamilyHelper.SearchNewestFamily(callbackFunc);
	end
end
function FamilyListPage.DS_Func(index)
	local self = FamilyListPage;
	if(not self.list)then return 0 end
	if(index == nil) then
		return #(self.list);
	else
		return self.list[index];
	end
end
-- do selecte a node
function FamilyListPage.OnClickItem(index)
	local self = FamilyListPage;
	index = index or 1;
	if(self.list)then
       local node = self.list[index];
       self.selected_node = node;
       local k,v;
       for  k,v in ipairs(self.list)do
		    v.checked = false;
       end
       if(node)then
		    if(node.checked)then
			    node.checked = false;
		    else
			    node.checked = true;
		    end
       end
   end
end
function FamilyListPage.ShowPage_SearchBox()
	local self = FamilyListPage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Family/FamilySearchBox.teen.html", 
				name = "FamilyListPage.ShowPage_SearchBox", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true,
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
function FamilyListPage.ShowPage_SearchResult(search_result_node)
	local self = FamilyListPage;
	self.search_result_node = search_result_node;
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Family/FamilySearchResultPage.teen.html", 
				name = "FamilyListPage.ShowPage_ShowPage_SearchResult", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true,
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -330/2,
					y = -470/2,
					width = 330,
					height = 470,
		});		
end