--[[
Title: 
Author(s): Leio
Date: 2010/01/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/MapHelpPage.lua");
MyCompany.Aries.Help.MapHelpPage.ShowPage_ByState("find_npc");
MyCompany.Aries.Help.MapHelpPage.ShowPage_ByState("find_game");
MyCompany.Aries.Help.MapHelpPage.ShowPage_ByState("find_item");
------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
local MapHelp = commonlib.gettable("MyCompany.Aries.Help.MapHelp");
local MapHelpPage = {
	cur_map = nil,
	loaded = {},
};
commonlib.setfield("MyCompany.Aries.Help.MapHelpPage", MapHelpPage);
function MapHelpPage.DS_Func_MapHelpPage(index)
	local self = MapHelpPage;
	if(not self.cur_map)then return 0 end
	if(index == nil) then
		return #(self.cur_map);
	else
		return self.cur_map[index];
	end
end
function MapHelpPage.OnInit()
	local self = MapHelpPage;
	self.page = document:GetPageCtrl();
end

--[[
	args = {
		cur_map = find_npc_map,
	}
--]]
function MapHelpPage.Bind(args)
	local self = MapHelpPage;
	self.cur_map = args.cur_map;
end
function MapHelpPage.ShowPage(args)
	local self = MapHelpPage;
	if(not args)then return end
	self.Bind(args);
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Help/MapHelpPage.html", 
			name = "MapHelpPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -450/2,
				y = -150,
				width = 450,
				height = 228,
		});
end
function MapHelpPage.ClosePage()
	local self = MapHelpPage;
	self.Reset();
	if(self.page)then
		self.page:CloseWindow();
	end
end
function MapHelpPage.RefreshPage()
	local self = MapHelpPage;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
function MapHelpPage.Reset()
	local self = MapHelpPage;
	self.cur_map = nil;
	self.state = nil;
end
function MapHelpPage.GotoPlace(index)
	local self = MapHelpPage;
	index = tonumber(index);
	if(self.cur_map and index)then
		local item = self.cur_map[index];
		MapHelp.GotoPlaceByItem(item);
		self.ClosePage();
	end
end
--@param path:xml 路径
--@param state:"find_npc" or "find_game" or "find_item"
function MapHelpPage.LoadMapFileAndShowPage(path,state)
	local self = MapHelpPage;
	if(not path)then return end
	local cur_map = self.loaded[path];
	local temp_map;
	if(not cur_map)then
		cur_map,temp_map = MapHelp.ParseXMLFile(path);
		if(cur_map)then
			local k,item;
			local clone_map = {};
			for k,item in ipairs(cur_map) do
				local noshow = item["NoShowInMap"];
				if(not noshow or noshow == "" or noshow == "false")then
					table.insert(clone_map,item);
				end
			end
			cur_map = clone_map;
		end
		self.loaded[path] = cur_map;
	end
	self.state = state;
	self.ShowPage({
		cur_map = cur_map,
	});
end