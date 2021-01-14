--[[
Title: 
Author(s): chenjinxian
Date: 2020/1/11
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/CustomSkinPage.lua");
local CustomSkinPage = commonlib.gettable("MyCompany.Aries.Game.Movie.CustomSkinPage");
CustomSkinPage.ShowPage(entity)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerAssetFile.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/CustomCharItems.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/SkinPage.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local SkinPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SkinPage");
local CustomCharItems = commonlib.gettable("MyCompany.Aries.Game.EntityManager.CustomCharItems");
local PlayerAssetFile = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerAssetFile")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local CustomSkinPage = commonlib.gettable("MyCompany.Aries.Game.Movie.CustomSkinPage");

local page;
local currentModel;
local currentTab;
local currentSkins = {
		geosets = {1, 0, 1, 1, 1, 1, 0, 0, 3, 2},
		textures = {"Texture/blocks/Paperman/hair/Avatar_boy_hair_01.png",
					"Texture/blocks/Paperman/body/Avatar_boy_body_01.png",
					"Texture/blocks/Paperman/eye/eye1.png",
					"Texture/blocks/Paperman/mouth/mouth_01.png",
					"Texture/blocks/Paperman/leg/Avatar_boy_leg_01.png"},
		attachments = {}
}

function CustomSkinPage.OnInit()
	page = document:GetPageCtrl();
end

function CustomSkinPage.ShowPage(assetFilename, skins, OnClose)
	currentTab = 1;
	currentModel = CustomCharItems:GetModel(assetFilename);
	skins = skins or PlayerAssetFile:GetDefaultCustomGeosets();
	local geosets, textures, attachments =  string.match(skins, "([^@]+)@([^@]+)@?(.*)");
	if (geosets) then
		for geoset in string.gfind(geosets, "([^#]+)") do
			local id = tonumber(geoset);
			currentSkins.geosets[math.floor(id/100 + 1)] = id % 100;
		end
	end

	if (textures) then
		for id, filename in textures:gmatch("(%d+):([^;]+)") do
			id = tonumber(id)
			currentSkins.textures[id] = filename;
		end
	end

	local params = {
			url = "script/apps/Aries/Creator/Game/Movie/CustomSkinPage.html", 
			name = "CustomSkinPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			bToggleShowHide=false, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			bShow = true,
			click_through = false, 
			zorder = -1,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -410,
				y = -250,
				width = 820,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = function()
		if(OnClose) then
			OnClose();
		end
	end;
end

function CustomSkinPage.GetSkinDS(index)
	if (currentModel) then
		return currentModel[index];
	end
end

function CustomSkinPage.SetTabIndex(name)
	currentTab = tonumber(name);
end

function CustomSkinPage.UpdateCustomGeosets(index)
	local item = currentModel[currentTab][index];
	if (item.geoset) then
		currentSkins.geosets[math.floor(item.geoset/100) + 1] = item.geoset % 100;
	end
	if (item.texture) then
		local id, filename = string.match(item.texture, "(%d+):(.*)");
		currentSkins.textures[tonumber(id)] = filename;
	end
	if (item.attachment) then
		local id, filename = string.match(item.attachment, "(%d+):(.*)");
		currentSkins.attachments[tonumber(id)] = filename;
	end

	local customGeosets = CustomSkinPage.SkinTableToGeosets();
	page:CallMethod("MyPlayer", "SetCustomGeosets", customGeosets);
end

function CustomSkinPage.SkinTableToGeosets()
	local customGeosets = "";
	for i = 1, #currentSkins.geosets do
		customGeosets = customGeosets..format("%d#", (i-1) * 100 + currentSkins.geosets[i]);
	end
	customGeosets = customGeosets.."@";
	for i = 1, #currentSkins.textures do
		customGeosets = customGeosets..format("%d:%s;", i, currentSkins.textures[i]);
	end
	customGeosets = customGeosets.."@";
	for id, filename in pairs(currentSkins.attachments) do
		customGeosets = customGeosets..format("%d:%s;", id, filename);
	end

	return customGeosets;
end

function CustomSkinPage.OnClickOK()
	page:CloseWindow();
end

function CustomSkinPage.OnClose()
	page:CloseWindow();
end
