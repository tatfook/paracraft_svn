--[[
Title: 
Author(s): Leio
Date: 2011/08/17

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/ResetRoomPage.lua");
local ResetRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.ResetRoomPage");
ResetRoomPage.ShowPage();
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

local ResetRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.ResetRoomPage");
ResetRoomPage.game_info = nil;
function ResetRoomPage.OnInit()
	local self = ResetRoomPage;
	self.page = document:GetPageCtrl();
end

function ResetRoomPage.ClosePage()
	local self = ResetRoomPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
		self.game_info = nil;
		self.selected_game_type = nil;
        self.selected_template = nil;
	end	
end
function ResetRoomPage.ShowPage(game_info)
	local self = ResetRoomPage;
	if(not game_info)then return end
	self.game_info = game_info;
	self.selected_game_type = game_info.game_type;

	local game_templates = LobbyClientServicePage.GetGameTemplates()
    if(game_templates and game_info)then
        self.selected_template = game_templates[game_info.keyname];
    end
	local url = "script/apps/Aries/CombatRoom/ResetRoomPage.html";
	local width = 950;
	local height = 550;
	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/CombatRoom/Teen/ResetRoomPage.v2.teen.html";
		width = 400;
		height = 250;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "ResetRoomPage.ShowPage", 
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
				x = -width/2,
				y = -height/2,
				width = width,
				height = height,
		});
	
end
