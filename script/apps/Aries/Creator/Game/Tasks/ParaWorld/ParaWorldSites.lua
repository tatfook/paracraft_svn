﻿--[[
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
NPL.load("(gl)script/apps/Aries/Creator/Game/World/generators/ParaWorldMiniChunkGenerator.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/BlockTemplatePage.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldMinimapSurface.lua");
local ParaWorldMinimapSurface = commonlib.gettable("Paracraft.Controls.ParaWorldMinimapSurface");
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
local BlockTemplatePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.BlockTemplatePage");
local ParaWorldMiniChunkGenerator = commonlib.gettable("MyCompany.Aries.Game.World.Generators.ParaWorldMiniChunkGenerator");
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

ParaWorldSites.currentRow = 5;
ParaWorldSites.currentColumn = 5;
ParaWorldSites.currentName = L"主世界";
ParaWorldSites.currentItem = nil;

ParaWorldSites.paraWorldName = L"并行世界";

ParaWorldSites.IsOwner = false;
ParaWorldSites.AllMiniWorld = {};

local rows = 10;
local columns = 10;
local mainRange = {rows*4+5, rows*4+6, rows*5+5, rows*5+6};

local page;
function ParaWorldSites.OnInit()
	page = document:GetPageCtrl();
end

function ParaWorldSites.ShowPage()
	ParaWorldSites.currentRow = 5;
	ParaWorldSites.currentColumn = 5;
	ParaWorldSites.currentName = L"主世界";
	ParaWorldSites.currentItem = nil;
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

	ParaWorldSites.IsOwner = false;
	if (ParaWorldLoginAdapter.ParaWorldId) then
		commonlib.TimerManager.SetTimeout(function()
			ParaWorldSites.UpdateSitesState();
			ParaWorldSites.CheckIsMyParaworld(function(world)
				ParaWorldSites.IsOwner = true;
			end);
		end, 10);
	end
end

function ParaWorldSites.OnClose()
	page:CloseWindow();
end

function ParaWorldSites.GetParaWorldName()
	return ParaWorldSites.paraWorldName;
end

function ParaWorldSites.UpdateSitesState(callback)
	local state = ParaWorldSites.Locked;
	if (ParaWorldLoginAdapter.ParaWorldId) then
		state = ParaWorldSites.Available;
	end
	for i = 1, #ParaWorldSites.Current_Item_DS do
		ParaWorldSites.Current_Item_DS[i].state = state;
		ParaWorldSites.Current_Item_DS[i].name = L"空地";
	end
	keepwork.world.get({router_params={id=ParaWorldLoginAdapter.ParaWorldId}}, function(err, msg, data)
		if (data and data.sites) then
			ParaWorldSites.paraWorldName = data.name;
			ParaWorldSites.SetCurrentSite(data.sites);
			if (page) then
				page:Refresh(0);
			end
			if (callback) then
				callback();
			end
		end
	end);
end

function ParaWorldSites.CheckIsMyParaworld(callback)
	local projectId = GameLogic.options:GetProjectId();
	if (not projectId) then return end
	projectId = tonumber(projectId);
	if (not projectId) then return end
	local userId = tonumber(Mod.WorldShare.Store:Get("user/userId"));

	keepwork.world.worlds_list({projectId = projectId}, function(err, msg, data)
		if (data and type(data) == "table") then
			for i = 1, #data do
				local world = data[i];
				if (world.projectId == projectId and world.userId == userId) then
					if (callback) then
						callback(world);
					end
					break;
				end
			end
		end
	end);
end

function ParaWorldSites.SetCurrentSite(sites)
	for i = 1, #sites do
		local seat = sites[i];
		if (seat.sn and seat.status) then
			local pos = ParaWorldSites.SitesNumber[seat.sn];
			for j = 1, #ParaWorldSites.Current_Item_DS do
				local item = ParaWorldSites.Current_Item_DS[j];
				if (item.x == pos.row and item.y == pos.column) then
					if (seat.status == "locked") then
						item.state = ParaWorldSites.Locked;
					elseif (seat.status == "checked") then
						item.state = ParaWorldSites.Checked;
						local userId = tonumber(Mod.WorldShare.Store:Get("user/userId"));
						if (seat.paraMini and seat.paraMini.userId == userId) then
							item.state = ParaWorldSites.Selected;
						end
					end
					if (seat.paraMini and seat.paraMini.name) then
						item.name = seat.paraMini.name;
						if (_guihelper.GetTextWidth(item.name, "System;16") > 132) then
							if (string.find(item.name, L"的家园") or string.find(item.name, "_main")) then
								local text = string.sub(item.name, 1, 8);
								item.name = string.format(L"%s...的家园", text);
							else
								item.name = commonlib.utf8.sub(item.name, 1, 8);
							end
						end
					end
					break;
				end
			end
		end
	end
end

function ParaWorldSites.InitSitesData()
	local state = ParaWorldSites.Locked;
	if (ParaWorldLoginAdapter.ParaWorldId) then
		state = ParaWorldSites.Available;
	end
	for i = 1, 10 do
		for j = 1, 10 do
			local valid = true;
			local index = (i-1) * rows + j;
			for k = 1, #mainRange do
				if (index == mainRange[k]) then
					valid = false;
					break;
				end
			end
			ParaWorldSites.Current_Item_DS[index] = {x = i, y = j, valid=valid, state=state};
		end
	end
end

function ParaWorldSites.InitSitesNumber()
	-- counterclockwise, start from row=5, column=4
	-- first down to radius unit, then right to radius unit, up to radius unit, last left to radius unit
	-- radius from 3 to 9, 3 5 7 9
	local index = 1;
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

function ParaWorldSites.GetSeatNumFromPos(row, column)
	for i = 1, #ParaWorldSites.SitesNumber do
		local pos = ParaWorldSites.SitesNumber[i];
		if (pos.row == row and pos.column == column) then
			return i;
		end
	end
end

function ParaWorldSites.GetItemFromPos(row, column)
	for i = 1, #ParaWorldSites.Current_Item_DS do
		local item = ParaWorldSites.Current_Item_DS[i];
		if (item.x == row and item.y == column) then
			return item;
		end
	end
end

function ParaWorldSites.GotoSelectWorld()
	local item = ParaWorldSites.currentItem;
	if (item) then
		local gen = GameLogic.GetBlockGenerator();
		local x, y = gen:GetGridXYBy2DIndex(item.y, item.x);
		local bx, by, bz = gen:GetBlockOriginByGridXY(x, y);
		bx = bx + 64;
		bz = bz + 64;
		local y = ParaWorldMinimapSurface:GetHeightByWorldPos(bx, bz)
		y = y or by;
		GameLogic.RunCommand(format("/goto %d %d %d", bx, y+1, bz));
		ParaWorldSites.LoadMiniWorldOnSeat(item.x, item.y, true, function(x, y, z)
			local cx, _, cz = gen:GetWorldCenter();
			local bornX = bx + x - cx;
			local bornZ = bz + z - cz;
			GameLogic.RunCommand(format("/goto %d %d %d", bornX, y, bornZ));
		end);
	else
		GameLogic.RunCommand("/home");
	end
end

function ParaWorldSites.OnClickItem(index)
	ParaWorldSites.currentItem = nil;
	local projectId = GameLogic.options:GetProjectId();
	local item = ParaWorldSites.Current_Item_DS[index];
	if (item and projectId and tonumber(projectId)) then
		ParaWorldSites.currentItem = item;
		ParaWorldSites.currentRow, ParaWorldSites.currentColumn = item.x, item.y;
		if (item.state == ParaWorldSites.Locked) then
			ParaWorldSites.currentName = L"该地块已锁定";
			page:Refresh(0);
			if (ParaWorldSites.IsOwner) then
				_guihelper.MessageBox("该地块已锁定，你确定要解锁吗？", function(res)
					if(res and res == _guihelper.DialogResult.OK) then
						local id = ParaWorldSites.GetSeatNumFromPos(item.x, item.y);
						keepwork.world.unlock_seat({paraWorldId=ParaWorldLoginAdapter.ParaWorldId, sn=id}, function(err, msg, data)
							if (err == 200) then
								ParaWorldSites.UpdateSitesState();
							end
						end);
					end
				end, _guihelper.MessageBoxButtons.OKCancel);
			end
		elseif (item.state == ParaWorldSites.Checked or item.state == ParaWorldSites.Selected) then
			ParaWorldSites.currentName = item.name or L"该地块已有人入驻";
			page:Refresh(0);
			local gen = GameLogic.GetBlockGenerator();
			local x, y = gen:GetGridXYBy2DIndex(item.y, item.x);
			local bx, by, bz = gen:GetBlockOriginByGridXY(x, y);
			bx = bx + 64;
			bz = bz + 64;
			local y = ParaWorldMinimapSurface:GetHeightByWorldPos(bx, bz)
			y = y or by;
			GameLogic.RunCommand(format("/goto %d %d %d", bx, y+1, bz));
			ParaWorldSites.LoadMiniWorldOnSeat(item.x, item.y, true, function(x, y, z)
				local cx, _, cz = gen:GetWorldCenter();
				local bornX = bx + x - cx;
				local bornZ = bz + z - cz;
				GameLogic.RunCommand(format("/goto %d %d %d", bornX, y, bornZ));
			end);
		else
			ParaWorldSites.currentName = item.name or L"空地";

			if (ParaWorldSites.IsOwner) then
				_guihelper.MessageBox(L"该地块为空地，你确定要锁定吗（否则占座）？", function(res)
					if(res and res == _guihelper.DialogResult.OK) then
						local id = ParaWorldSites.GetSeatNumFromPos(item.x, item.y);
						keepwork.world.lock_seat({paraWorldId=ParaWorldLoginAdapter.ParaWorldId, sn=id}, function(err, msg, data)
							if (err == 200) then
								ParaWorldSites.UpdateSitesState();
							end
						end);
					else
						ParaWorldSites.ShowTakeSeat(item, index);
					end
				end, _guihelper.MessageBoxButtons.OKCancel_CustomLabel,nil,nil,nil,nil,{ ok = L"锁定", cancel = L"占座", });
			else
				ParaWorldSites.ShowTakeSeat(item, index);
			end
		end
	end
end

function ParaWorldSites.ShowTakeSeat(item, index)
	local function resetState()
		ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Available;
		page:Refresh(0);
	end
	
	ParaWorldTakeSeat.ShowPage(function(res, worldId)
		if (res) then
			local id = ParaWorldSites.GetSeatNumFromPos(item.x, item.y);
			if (not id) then
				resetState();
				_guihelper.MessageBox(L"所选的座位无效！");
				return;
			end
			keepwork.world.take_seat({paraMiniId=worldId, paraWorldId=ParaWorldLoginAdapter.ParaWorldId, sn=id}, function(err, msg, data)
				if (err == 200) then
					_guihelper.MessageBox(L"入驻成功！");
				else
					_guihelper.MessageBox(L"该座位已被占用，请选择其他座位入驻！");
				end
				ParaWorldSites.UpdateSitesState();
			end);
		else
			ParaWorldSites.Current_Item_DS[index].state = ParaWorldSites.Available;
			page:Refresh(0);
		end
	end);
end

function ParaWorldSites.OnClickMain()
	ParaWorldSites.currentRow = 5;
	ParaWorldSites.currentColumn = 5;
	ParaWorldSites.currentName = L"主世界";
	ParaWorldSites.currentItem = nil;
	page:Refresh(0);
end

function ParaWorldSites.LoadMiniWorldOnSeat(row, column, center, callback)
	if (not ParaWorldSites.SitesNumber or #ParaWorldSites.SitesNumber < 1) then
		ParaWorldSites.InitSitesNumber();
	end
	if (not ParaWorldSites.Current_Item_DS or #ParaWorldSites.Current_Item_DS < 1) then
		ParaWorldSites.InitSitesData();
	end
	local currentItem;
	for i = 1, #ParaWorldSites.Current_Item_DS do
		local item = ParaWorldSites.Current_Item_DS[i];
		if (item.x == row and item.y == column) then
			currentItem = item;
			if (currentItem.loaded) then
				if (center and currentItem.projectName and currentItem.projectName ~= "") then
					GameLogic.AddBBS(nil, string.format(L"欢迎来到【%s】", currentItem.projectName), 3000, "0 255 0");
					if (currentItem.bornAt and callback) then
						callback(currentItem.bornAt[1], currentItem.bornAt[2], currentItem.bornAt[3]);
					end
				end
				return;
			else
				break;
			end
		end
	end
	if (not currentItem) then
		return;
	end

	currentItem.loaded = true;
	local sn = ParaWorldSites.GetSeatNumFromPos(row, column);
	keepwork.world.get({router_params={id=ParaWorldLoginAdapter.ParaWorldId}}, function(err, msg, data)
		if (data and data.sites) then
			for i = 1, #data.sites do
				local seat = data.sites[i];
				if (seat.sn and seat.paraMini and seat.sn == sn) then
					local path = ParaWorldMiniChunkGenerator:GetTemplateFilepath();
					local filename = ParaIO.GetFileName(path);
					local KeepworkServiceWorld = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/World.lua");
					KeepworkServiceWorld:GetSingleFile(seat.paraMini.projectId, filename, function(content)
						if (not content) then
							currentItem.loaded = false;
							return;
						end

						--local name = commonlib.Encoding.Utf8ToDefault(seat.paraMini.name);
						local miniTemplateDir = ParaIO.GetCurDirectory(0).."temp/miniworlds/";
						ParaIO.CreateDirectory(miniTemplateDir);
						local template_file = miniTemplateDir..seat.paraMini.projectId..".xml";
						local file = ParaIO.open(template_file, "w");
						if (file:IsValid()) then
							file:write(content, #content);
							file:close();
							local gen = GameLogic.GetBlockGenerator();
							local x, y = gen:GetGridXYBy2DIndex(column,row);
							gen:LoadTemplateAtGridXY(x, y, template_file);
							currentItem.loaded = true;
							currentItem.projectName = seat.paraMini.name;
							currentItem.bornAt = seat.paraMini.bornAt;
							if (center) then
								GameLogic.AddBBS(nil, string.format(L"欢迎来到【%s】", seat.paraMini.name), 3000, "0 255 0");
								if (seat.paraMini.bornAt and callback) then
									callback(seat.paraMini.bornAt[1], seat.paraMini.bornAt[2], seat.paraMini.bornAt[3]);
								end
							end
						end
					end);
					return;
				end
			end
			currentItem.loaded = false;
		else
			currentItem.loaded = false;
		end
	end);
end

function ParaWorldSites.LoadMiniWorldInRandom(row, column, center, callback)
	--[[
	if (row < 1) then
		keepwork.miniworld.list({searchType = "school"}, function(err, msg, data)
			commonlib.echo(data);
		end);
	elseif (row > 10) then
		keepwork.miniworld.list({searchType = "latest"}, function(err, msg, data)
			commonlib.echo(data);
		end);
	elseif (column < 1) then
		keepwork.miniworld.list({searchType = "rank"}, function(err, msg, data)
			commonlib.echo(data);
		end);
	elseif (column > 10) then
		keepwork.miniworld.list({searchType = "friend"}, function(err, msg, data)
			commonlib.echo(data);
		end);
	end
	]]
	local key = string.format("%d_%d", row, column);
	if (ParaWorldSites.AllMiniWorld[key] and ParaWorldSites.AllMiniWorld[key].loaded) then
		if (center and ParaWorldSites.AllMiniWorld[key].projectName and ParaWorldSites.AllMiniWorld[key].projectName ~= "") then
			GameLogic.AddBBS(nil, string.format(L"欢迎来到【%s】", ParaWorldSites.AllMiniWorld[key].projectName), 3000, "0 255 0");
			if (ParaWorldSites.AllMiniWorld[key].bornAt and callback) then
				callback(ParaWorldSites.AllMiniWorld[key].bornAt[1], ParaWorldSites.AllMiniWorld[key].bornAt[2], ParaWorldSites.AllMiniWorld[key].bornAt[3]);
			end
		end
		return;
	end
	ParaWorldSites.AllMiniWorld[key] = {loaded = true};
	keepwork.miniworld.list({searchType = "latest"}, function(err, msg, data)
		if (data and data.count and data.rows) then
			local worlds = {};
			for i = 1, #data.rows do
				if (data.rows[i].block and (data.rows[i].block > 100 or data.rows[i].block == -1)) then
					worlds[#worlds + 1] = data.rows[i];
				end
			end
			if (#worlds < 1) then
				ParaWorldSites.AllMiniWorld[key].loaded = false;
				return;
			end

			math.randomseed(ParaGlobal.GetGameTime());
			local index = math.random(1, #worlds);
			local path = ParaWorldMiniChunkGenerator:GetTemplateFilepath();
			local filename = ParaIO.GetFileName(path);
			local KeepworkServiceWorld = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/World.lua");
			KeepworkServiceWorld:GetSingleFile(worlds[index].projectId, filename, function(content)
				if (not content) then
					ParaWorldSites.AllMiniWorld[key].loaded = false;
					return;
				end

				local miniTemplateDir = ParaIO.GetCurDirectory(0).."temp/miniworlds/";
				ParaIO.CreateDirectory(miniTemplateDir);
				local template_file = miniTemplateDir..worlds[index].projectId..".xml";
				local file = ParaIO.open(template_file, "w");
				if (file:IsValid()) then
					file:write(content, #content);
					file:close();
					local gen = GameLogic.GetBlockGenerator();
					local x, y = gen:GetGridXYBy2DIndex(column,row);
					gen:LoadTemplateAtGridXY(x, y, template_file);
					ParaWorldSites.AllMiniWorld[key].loaded = true;
					ParaWorldSites.AllMiniWorld[key].projectName = worlds[index].name;
					ParaWorldSites.AllMiniWorld[key].bornAt = worlds[index].bornAt;
					if (center) then
						GameLogic.AddBBS(nil, string.format(L"欢迎来到【%s】", worlds[index].name), 3000, "0 255 0");
						if (worlds[index].bornAt and callback) then
							callback(worlds[index].bornAt[1], worlds[index].bornAt[2], worlds[index].bornAt[3]);
						end
					end
				else
					ParaWorldSites.AllMiniWorld[key].loaded = false;
				end
			end);
		else
			ParaWorldSites.AllMiniWorld[key].loaded = false;
		end
	end);
end

function ParaWorldSites.LoadMiniWorldOnPos(x, z, callback)
	function loadMiniWorld(row, column, center, callback)
		if (row < 1 or column < 1 or row > 10 or column > 10) then
			ParaWorldSites.LoadMiniWorldInRandom(row, column, center, callback);
		else
			ParaWorldSites.LoadMiniWorldOnSeat(row, column, center, callback);
		end
	end
	if (GameLogic.IsReadOnly() and ParaWorldLoginAdapter.ParaWorldId and WorldCommon.GetWorldTag("world_generator") == "paraworld") then
		local gen = GameLogic.GetBlockGenerator();
		local gridX, gridY = gen:FromWorldPosToGridXY(x, z);
		local row, column = gen:Get2DIndexByGridXY(gridX, gridY);
		loadMiniWorld(row, column, true, callback);
		for i = -1, 1, 2 do
			loadMiniWorld(row + i, column);
			loadMiniWorld(row, column + i);
		end
	end
end

function ParaWorldSites.Reset()
	if (not ParaWorldSites.SitesNumber or #ParaWorldSites.SitesNumber < 1) then
		ParaWorldSites.InitSitesNumber();
	end
	if (not ParaWorldSites.Current_Item_DS or #ParaWorldSites.Current_Item_DS < 1) then
		ParaWorldSites.InitSitesData();
	end

	for i = 1, #ParaWorldSites.Current_Item_DS do
		ParaWorldSites.Current_Item_DS[i].loaded = false;
		ParaWorldSites.Current_Item_DS[i].projectName = "";
		ParaWorldSites.Current_Item_DS[i].bornAt = nil; 
	end

	for _, item in pairs(ParaWorldSites.AllMiniWorld) do
		item.loaded = false;
		item.projectName = "";
		item.bornAt = nil;
	end
end

function ParaWorldSites.LoadAdvertisementWorld()
	function loadTemplate(projectId, row, column)
		local path = ParaWorldMiniChunkGenerator:GetTemplateFilepath();
		local filename = ParaIO.GetFileName(path);
		local KeepworkServiceWorld = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/World.lua");
		KeepworkServiceWorld:GetSingleFile(projectId, filename, function(content)
			if (not content) then
				return;
			end

			local miniTemplateDir = ParaIO.GetCurDirectory(0).."temp/miniworlds/";
			ParaIO.CreateDirectory(miniTemplateDir);
			local template_file = miniTemplateDir..projectId..".xml";
			local file = ParaIO.open(template_file, "w");
			if (file:IsValid()) then
				file:write(content, #content);
				file:close();
				local gen = GameLogic.GetBlockGenerator();
				local x, y = gen:GetGridXYBy2DIndex(column,row);
				gen:LoadTemplateAtGridXY(x, y, template_file);
			end
		end);
	end

	keepwork.world.paraWorldFillings({}, function(err, msg, data)
		if (err == 200 and data and #data > 0) then
			ParaWorldSites.UpdateSitesState(function()
				local count = 1;
				for i = 1, #data do
					if (i > 1) then
						count = count + data[i-1].quantity;
					end
					local index = 1;
					local projectIds = data[i].projectIds;
					for j = count, count + data[i].quantity - 1 do
						if (#projectIds < index) then
							break;
						end
						local projectId = projectIds[index];
						local row, column = ParaWorldSites.SitesNumber[j].row, ParaWorldSites.SitesNumber[j].column;
						local item = ParaWorldSites.GetItemFromPos(row, column);
						if (item and item.state == ParaWorldSites.Available) then
							loadTemplate(projectId, row, column);
							index = index + 1;
						end
					end
				end
			end);
		end
	end);
end