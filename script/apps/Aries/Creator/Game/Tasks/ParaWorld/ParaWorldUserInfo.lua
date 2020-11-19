﻿--[[
Title: paraworld user info panel
Author(s): chenjinxian
Date: 2020/11/18
Desc: 
use the lib:
------------------------------------------------------------
local ParaWorldUserInfo = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldUserInfo.lua");
ParaWorldUserInfo.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/World/generators/ParaWorldChunkGenerator.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.user.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.world.lua");
local ParaWorldChunkGenerator = commonlib.gettable("MyCompany.Aries.Game.World.Generators.ParaWorldChunkGenerator");
local ParaWorldCodeList = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldCodeList.lua");
local ParaWorldUserInfo = NPL.export();

local page;
local currentId;
local worldParams;
local isStared = false;
local starCount = 0;
local isCodeOn = true;
local asset = "character/CC/02human/paperman/boy01.x";

function ParaWorldUserInfo.OnInit()
	page = document:GetPageCtrl();
end

function ParaWorldUserInfo.ShowPage(world)
	isCodeOn = true;
	worldParams = world;
	local bShow = (worldParams ~= nil) and (worldParams.userId ~= nil)
	if (page) then
		if (bShow and page:IsVisible()) then
			ParaWorldUserInfo.Refresh(worldParams.userId, gridX, gridY);
			return;
		end
		if ((not bShow) and (not page:IsVisible())) then
			return;
		end
	end
	
	local params = {
		url = "script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldUserInfo.html",
		name = "ParaWorldUserInfo.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = false,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = false,
		bShow = bShow,
		enable_esc_key = false,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_lt",
		x = 20,
		y = 10,
		width = 305,
		height = 70,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if (bShow) then
		ParaWorldUserInfo.Refresh(worldParams.userId, gridX, gridY);
	end
end

function ParaWorldUserInfo.Refresh(userId, gridX, gridY)
	if (userId == currentId) then
		return;
	end
	page:Refresh(0);

	currentId = userId;

	keepwork.world.detail({router_params = {id = worldParams.projectId}}, function(err, msg, data)
		if (data and data.star) then
			starCount = data.star or 0;
		end

		keepwork.world.is_stared({router_params = {id = worldParams.projectId}}, function(err, msg, data)
			if (err == 200) then
				isStared = data == true;
				page:Refresh(0);
			end

			local id = "kp"..commonlib.Encoding.base64(commonlib.Json.Encode({userId = userId}));
			keepwork.user.getinfo({router_params = {id = id}}, function(err, msg, data)
				if (data and data.extra and data.extra.ParacraftPlayerEntityInfo and data.extra.ParacraftPlayerEntityInfo.asset) then
					asset = data.extra.ParacraftPlayerEntityInfo.asset;
				end
				page:CallMethod("MyPlayer", "SetAssetFile", asset);
			end);
		end);
	end);
end

function ParaWorldUserInfo.GetProjectName()
	if (_guihelper.GetTextWidth(worldParams.projectName, "System;16") > 108) then
		if (string.find(worldParams.projectName, L"的家园") or string.find(worldParams.projectName, "_main")) then
			local text = string.sub(worldParams.projectName, 1, 8);
			return string.format(L"%s...的家园", text);
		else
			return commonlib.utf8.sub(worldParams.projectName, 1, 8);
		end
	else
		return worldParams.projectName;
	end
end

function ParaWorldUserInfo.IsStared()
	return isStared;
end

function ParaWorldUserInfo.GetStarCount()
	return string.format("%d", starCount);
end

function ParaWorldUserInfo.OnClickStar()
	keepwork.world.star({router_params = {id = worldParams.projectId}}, function(err, msg, data)
		if (err == 200) then
			isStared = true;
			starCount = starCount + 1;
			page:Refresh(0);
			page:CallMethod("MyPlayer", "SetAssetFile", asset);
		end
	end);
end

function ParaWorldUserInfo.OnClickUserInfo()
	local page = NPL.load("Mod/GeneralGameServerMod/App/ui/page.lua");
	page.ShowUserInfoPage({userId = currentId});
end

function ParaWorldUserInfo.IsCodeEnabled()
	return worldParams.openCode == true and ParaWorldUserInfo.GetCodeCount() > 0;
end

function ParaWorldUserInfo.IsCodeTurnOn()
	return isCodeOn;
end

function ParaWorldUserInfo.OnClickEnableCode()
	ParaWorldChunkGenerator.EnableCodeBlocksInGrid(5 - worldParams.x, 5 - worldParams.y, true);
	isCodeOn = true;
	page:Refresh(0);
	page:CallMethod("MyPlayer", "SetAssetFile", asset);
end

function ParaWorldUserInfo.OnClickDisableCode()
	ParaWorldChunkGenerator.EnableCodeBlocksInGrid(5 - worldParams.x, 5 - worldParams.y, false);
	isCodeOn = false;
	page:Refresh(0);
	page:CallMethod("MyPlayer", "SetAssetFile", asset);
end

function ParaWorldUserInfo.GetCodeCount()
	local codeBlocks = ParaWorldChunkGenerator.GetCodeBlockListInGrid(5 - worldParams.x, 5 - worldParams.y);
	if (codeBlocks) then
		return #codeBlocks;
	else
		return 0;
	end
end

function ParaWorldUserInfo.OnClickCodeList()
	local codeBlocks = ParaWorldChunkGenerator.GetCodeBlockListInGrid(5 - worldParams.x, 5 - worldParams.y);
	ParaWorldCodeList.ShowPage(codeBlocks);
end

