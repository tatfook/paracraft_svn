--[[
Title: World Team List iFrame Page
Author(s): LiXizhi
Date: 2013/6/7
Desc: Displaying all active teams that are waiting for new users to join. All teams belong to the same instance world. 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamListPage.lua");
local WorldTeamListPage = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamListPage");
WorldTeamListPage.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");

local page;
function WorldTeamListPage.OnInit()
	page = document:GetPageCtrl();
end


function WorldTeamListPage.ShowPage()
end
