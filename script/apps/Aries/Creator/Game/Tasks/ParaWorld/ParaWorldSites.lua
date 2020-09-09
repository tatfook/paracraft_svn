--[[
Title: paraworld list
Author(s): chenjinxian
Date: 2020/9/8
Desc: 
use the lib:
------------------------------------------------------------
local ParaWorldSites = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldSites.lua");
ParaWorldSites.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.world.lua");
local ParaWorldSites = NPL.export();

ParaWorldSites.SitesNumber = {};
ParaWorldSites.Current_Item_DS = {};
ParaWorldSites.RowNumbers = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}};
ParaWorldSites.Locked = 1;
ParaWorldSites.Checked = 2;
ParaWorldSites.Available = 3;
ParaWorldSites.Unavailable = 4;

local rows = 10;
local column = 10;
local mainRange = {rows*4+5, rows*4+6, rows*5+5, rows*5+6};

local page;
function ParaWorldSites.OnInit()
	page = document:GetPageCtrl();
end

function ParaWorldSites.ShowPage()
	if (not ParaWorldSites.SitesNumber or #ParaWorldSites.SitesNumber < 1) then
		ParaWorldSites.InitSitesNumber();
	end
	if (not ParaWorldSites.Current_Item_DS or #ParaWorldSites.Current_Item_DS < 1) then
		ParaWorldSites.InitSitesData();
	end

	local params = {
		url = "script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldSites.html",
		name = "ParaWorldSites.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -520 / 2,
		y = -392 / 2,
		width = 520,
		height = 392,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	commonlib.TimerManager.SetTimeout(function()
		keepwork.world.list(nil, function(err, msg, data)
			if (data and data.rows) then
				for i = 1, #(data.rows) do
					keepwork.world.get({router_params={id=data.rows[i].id}}, function(err, msg, data)
						if (data and data.sites) then
							ParaWorldSites.SetCurrentSite(data.sites);
						end
					end);
				end
				page:Refresh(0);
			end
		end);
	end, 100);
end

function ParaWorldSites.OnClose()
	page:CloseWindow();
end

function ParaWorldSites.SetCurrentSite(sites)
	if (sites.sn and sites.status) then
		local site = ParaWorldSites.SitesNumber[sites.sn];
		local index = (site.row-1) * rows + site.column;
		if (sites.status == "locked") then
			ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Locked;
		elseif (sites.status == "checked") then
			ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Checked;
		end
	end
end

function ParaWorldSites.InitSitesData()
	for i = 1, 100 do
		local valid = true;
		for j = 1, #mainRange do
			if (i == mainRange[j]) then
				valid = false;
				break;
			end
		end
		ParaWorldSites.Current_Item_DS[i] = {valid=valid, state=ParaWorldSites.Available};
	end
end

function ParaWorldSites.InitSitesNumber()
	-- counterclockwise, start from row=5, column=4
	-- first down to radius unit, then right to radius unit, up to radius unit, last left to radius unit
	-- radius from 3 to 9, 3 5 7 9
	local index = 1;
	local radius = 3;
	local corner1, corner2 = 4, 7;
	for radius = 3, 9, 2 do
		-- down
		for i = 1, radius do
			ParaWorldSites.SitesNumber[index] = {row=corner1+i, column=corner1};
			index = index + 1;
		end
		-- right
		for i = 1, radius do
			ParaWorldSites.SitesNumber[index] = {row=corner2, column=corner1+i};
			index = index + 1;
		end
		-- up
		for i = 1, radius do
			ParaWorldSites.SitesNumber[index] = {row=corner2-i, column=corner2};
			index = index + 1;
		end
		-- left
		for i = 1, radius do
			ParaWorldSites.SitesNumber[index] = {row=corner1, column=corner2-i};
			index = index + 1;
		end
		corner1 = corner1 - 1;
		corner2 = corner2 + 1;
	end
end

function ParaWorldSites.OnClickItem(index)
	local item = ParaWorldSites.Current_Item_DS[index];
	if (item) then
	end
end