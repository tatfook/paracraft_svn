--[[
Title: 
Author(s): Leio
Date: 2011/03/31

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/AutoFindRoomPage.lua");
local AutoFindRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.AutoFindRoomPage");
AutoFindRoomPage.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");

local AutoFindRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.AutoFindRoomPage");
AutoFindRoomPage.templates_list = nil;
AutoFindRoomPage.selected_template = nil;
AutoFindRoomPage.selected_game_type = "PvE";
AutoFindRoomPage.find_mode = "random"; --"random" or "specification"

function AutoFindRoomPage.OnInit()
	local self = AutoFindRoomPage;
	self.page = document:GetPageCtrl();
end
function AutoFindRoomPage.DS_Func(index)
	local self = AutoFindRoomPage;
	if(not self.templates_list)then return nil end
	if(index == nil) then
		return #(self.templates_list);
	else
		return self.templates_list[index];
	end
end
function AutoFindRoomPage.ClosePage()
	local self = AutoFindRoomPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
		self.templates_list = nil;
		self.selected_template = nil;
		self.selected_game_type = "PvE";
	end	
end
function AutoFindRoomPage.OnSelectGame(index)
	local self = AutoFindRoomPage;
	if(not index or not self.templates_list)then return end
	local template = self.templates_list[index];
	self.selected_template = template;
	self.loots_list = LobbyClientServicePage.BuildLootsList(template.keyname);
	if(template)then
		local k,v;
		for k,v in ipairs(self.templates_list) do
			v.is_selected = nil;
		end
		template.is_selected = true;
		if(self.page)then
			self.page:Refresh(0);
		end
	end
end
function AutoFindRoomPage.LoadTemplates()
	local self = AutoFindRoomPage;
	local game_type = self.selected_game_type or "PvE";
	local combat_level = LobbyClient:GetMyCombatLevel()
	local game_key_array = LobbyClient:GetGameKeysByUserLevel(combat_level, game_type, true);
	local game_templates = LobbyClient:GetGameTemplates();
	local isAB_SDK = System.options.isAB_SDK;
	if(game_key_array and game_templates)then
		self.templates_list = {};
		local k,v; 
		for k,v in pairs(game_templates) do
			local __,keyname;
			for __,keyname in ipairs(game_key_array) do
				--是否在客户端隐藏
				if(not v.hide_from_createpage)then
					if(v.keyname == keyname)then
						table.insert(self.templates_list,v);
					end
				end
			end
		end
		table.sort(self.templates_list,function(a,b)
			if(a.min_level and b.min_level and a.min_level < b.min_level)then
				return true;
			end
		end);
	end
end
function AutoFindRoomPage.ShowPage(game_type)
	local self = AutoFindRoomPage;
	--if(AntiIndulgenceArea.IsAntiSystemIsEnabled()) then
		--game_type = "PvP";
	--end
	self.selected_game_type = game_type or "PvE";
	self.find_mode = "random";
	self.LoadTemplates();
	local url = "script/apps/Aries/CombatRoom/AutoFindRoomPage.html";
	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/CombatRoom/Teen/AutoFindRoomPage.teen.html";
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "AutoFindRoomPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -680/2,
				y = -340/2,
				width = 680,
				height = 340,
		});
	self.OnSelectGame(1);
end
