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
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldLoginAdapter.lua");
local ParaWorldLoginAdapter = commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.ParaWorldLoginAdapter");
local ParaWorldTakeSeat = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldTakeSeat.lua");
local ParaWorldSites = NPL.export();

ParaWorldSites.SitesNumber = {};
ParaWorldSites.Current_Item_DS = {};
ParaWorldSites.RowNumbers = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}};
ParaWorldSites.Locked = 1;
ParaWorldSites.Checked = 2;
ParaWorldSites.Selected = 3;
ParaWorldSites.Available = 4;

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

	if (ParaWorldLoginAdapter.ParaWorldId) then
		commonlib.TimerManager.SetTimeout(function()
			keepwork.world.get({router_params={id=ParaWorldLoginAdapter.ParaWorldId}}, function(err, msg, data)
				if (data and data.sites) then
					ParaWorldSites.SetCurrentSite(data.sites);
					page:Refresh(0);
				end
			end);
		end, 100);
	end
end

function ParaWorldSites.OnClose()
	page:CloseWindow();
end

function ParaWorldSites.SetCurrentSite(sites)
	for i = 1, #sites do
		local seat = sites[i];
		if (seat.sn and seat.status) then
			local pos = ParaWorldSites.SitesNumber[seat.sn];
			local index = (pos.row-1) * rows + pos.column;
			if (seat.status == "locked") then
				ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Locked;
			elseif (seat.status == "checked") then
				ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Checked;
			end
		end
	end
end

function ParaWorldSites.InitSitesData()
	local state = ParaWorldSites.Locked;
	if (ParaWorldLoginAdapter.ParaWorldId) then
		state = ParaWorldSites.Available;
	end
	for i = 1, 100 do
		local valid = true;
		for j = 1, #mainRange do
			if (i == mainRange[j]) then
				valid = false;
				break;
			end
		end
		ParaWorldSites.Current_Item_DS[i] = {valid=valid, state=state};
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
	local projectId = GameLogic.options:GetProjectId();
	local item = ParaWorldSites.Current_Item_DS[index];
	if (item and projectId and tonumber(projectId)) then
		if (item.state == ParaWorldSites.Checked) then
		else
			ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Selected;
			page:Refresh(0);
			ParaWorldTakeSeat.ShowPage(function(res, worldId)
				if (res) then
					keepwork.world.take_seat({paraMiniId=worldId, paraWorldId=tonumber(projectId), sn=index}, function(err, msg, data)
						if (err == 200) then
							ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Checked;
							page:Refresh(0);
						end
					end);
				else
					ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Available;
					page:Refresh(0);
				end
			end);
		end
	end
end