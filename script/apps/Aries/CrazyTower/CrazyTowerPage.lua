--[[
Title: 
Author(s): leio
Date: 2012/12/10
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CrazyTower/CrazyTowerPage.lua");
local CrazyTowerPage = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerPage");
CrazyTowerPage.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CrazyTower/CrazyTowerProvider.lua");
local CrazyTowerProvider = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerProvider")
local CrazyTowerPage = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerPage")
CrazyTowerPage.selected_index = nil;
CrazyTowerPage.games = nil;
CrazyTowerPage.loots = nil;
CrazyTowerPage.page = nil;
function CrazyTowerPage.OnInit()
	CrazyTowerPage.page = document:GetPageCtrl();
end
function CrazyTowerPage.ShowPage()
	local url = "script/apps/Aries/CrazyTower/CrazyTowerPage.html";
	local params = {
			url = url, 
			name = "CrazyTowerPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			enable_esc_key = true,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -950/2,
				y = -550/2,
				width = 950,
				height = 550,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	CrazyTowerPage.games = CrazyTowerProvider.GetTemplates();
	CrazyTowerPage.OnSelectGame(1);
	local opened_game = CrazyTowerProvider.LastOpendWorldTempate();
	if(opened_game) then
		-- preload the most recent game
		NPL.load("(gl)script/apps/Aries/Login/WorldAssetPreloader.lua");
		local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")
		WorldAssetPreloader.StartWorldPreload(opened_game.worldname);
	end
end
function CrazyTowerPage.Games_func(index)
    if(not CrazyTowerPage.games)then return 0 end
	if(index == nil) then
		return #(CrazyTowerPage.games);
	else
		return CrazyTowerPage.games[index];
	end
end
function CrazyTowerPage.Loots_func(index)
    if(not CrazyTowerPage.loots)then return 0 end
	if(index == nil) then
		return #(CrazyTowerPage.loots);
	else
		return CrazyTowerPage.loots[index];
	end
end
function CrazyTowerPage.OnSelectGame(index)
	CrazyTowerPage.selected_index = index;
	CrazyTowerPage.loots = nil;
	local game = CrazyTowerPage.games[index];
	if(game)then
		CrazyTowerPage.loots = CrazyTowerProvider.GetLoots(game.worldname);
	end
	if(CrazyTowerPage.page)then
		CrazyTowerPage.page:Refresh(0);
	end
end