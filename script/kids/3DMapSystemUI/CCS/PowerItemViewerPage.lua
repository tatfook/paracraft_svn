--[[
Title: power item viewer page
Author(s): WangTian
Date: 2009/5/5
Desc: script/kids/3DMapSystemUI/CCS/PowerItemViewerPage.html
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/PowerItemViewerPage.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local PowerItemViewerPage = {};
commonlib.setfield("Map3DSystem.App.CCS.PowerItemViewerPage", PowerItemViewerPage);

local page;
local globalstoreitems = {};
local globalstoreitems_count = 0;

-- on init show the current avatar in pe:avatar
function PowerItemViewerPage.OnInit()
	page = document:GetPageCtrl();
	NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.globalstore.lua");
	globalstoreitems = {};
	globalstoreitems_count = 0;
	local gsid;
	for gsid = 1001, 8999 do
		local gsItem = paraworld.globalstore.gettemplateinlocalserver_fortaurus(gsid);
		if(gsItem) then
			gsItem.template.stats = {};
			local i;
			for i = 1, 10 do
				local type = gsItem.template["stat_type_"..i]
				if(type ~= 0) then
					gsItem.template.stats[type] = gsItem.template["stat_value_"..i];
				end
			end
			globalstoreitems[gsid] = gsItem;
			globalstoreitems_count = globalstoreitems_count + 1;
		else
			break;
		end
	end
end


function PowerItemViewerPage.ClickDBUpdate()
	_guihelper.MessageBox("确认更新数据库？\n\n请确认database/characters.db文件为只读，数据更新需要花些时间，请耐心等待\n", function ()
				Map3DSystem.UI.CCS.DB.AutoGenerateItems();
				_guihelper.CloseMessageBox();
			end);
end

function PowerItemViewerPage.ClickLeftHandUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			PowerItemViewerPage.HandUpdate(gsid, 0);
		end
	end
end

function PowerItemViewerPage.ClickRightHandUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			PowerItemViewerPage.HandUpdate(gsid, 1);
		end
	end
end

function PowerItemViewerPage.ClickHatUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			playerChar:SetCharacterSlot(0, 0);
		end
	end
end

function PowerItemViewerPage.ClickBackUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			playerChar:SetCharacterSlot(26, 0);
		end
	end
end

function PowerItemViewerPage.HandUpdate(gsid, hand)
	local playerChar = ParaScene.GetPlayer():ToCharacter();
	if(gsid and hand == 0) then
		playerChar:SetCharacterSlot(11, gsid);
	elseif(gsid and hand == 1) then
		playerChar:SetCharacterSlot(10, gsid);
	end
end

NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.globalstore.lua");

function PowerItemViewerPage.DS_Func_Items(index)
	--ItemManager
	--local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	
	if(index ~= nil) then
		local gsid = 1000 + globalstoreitems_count - index + 1;
		local gsItem = globalstoreitems[gsid];
		if(not gsItem or index > globalstoreitems_count) then
			return;
		end
		return {img = gsItem.icon, tooltip = gsid.."\n"..gsItem.template.name, gsid = gsid};
	elseif(index == nil) then
		return globalstoreitems_count;
	end
end

function PowerItemViewerPage.TestItem(gsid)
	local scene = ParaScene.GetMiniSceneGraph("Taurus_PowerItemViewer");
	if(scene:IsValid()) then
		local obj = scene:GetObject("PowerItemViewerAvatar");
		if(obj:IsValid()) then
			local playerChar = obj:ToCharacter();
			local gsItem = globalstoreitems[gsid];
			if(gsItem) then
				local class = gsItem.template.class;
				local subclass = gsItem.template.subclass;
				if(class == 1) then
					if(subclass == 1) then
						playerChar:SetCharacterSlot(14, gsid);
					elseif(subclass == 2) then
						playerChar:SetCharacterSlot(0, gsid);
					elseif(subclass == 4) then
						local bForceCartoonFace = gsItem.template.stats[16];
						if(bForceCartoonFace == 1) then
							playerChar:SetCartoonFaceComponent(6, 0, gsid);
							playerChar:SetCharacterSlot(20, 0);
						else
							playerChar:SetCartoonFaceComponent(6, 0, 0);
							playerChar:SetCharacterSlot(20, gsid);
						end
						playerChar:SetCharacterSlot(20, gsid);
					elseif(subclass == 5) then
						playerChar:SetCharacterSlot(16, gsid);
					elseif(subclass == 6) then
						playerChar:SetCharacterSlot(17, gsid);
					elseif(subclass == 7) then
						playerChar:SetCharacterSlot(19, gsid);
					elseif(subclass == 8) then
						local bForceAttBack = gsItem.template.stats[13];
						if(bForceAttBack == 1) then
							playerChar:SetCharacterSlot(21, 0);
							playerChar:SetCharacterSlot(26, gsid);
						else
							playerChar:SetCharacterSlot(26, 0);
							playerChar:SetCharacterSlot(21, gsid);
						end
						playerChar:SetCharacterSlot(21, gsid);
					elseif(subclass == 9) then
						playerChar:SetCharacterSlot(18, gsid);
					elseif(subclass == 10) then
						playerChar:SetCharacterSlot(11, gsid);
					elseif(subclass == 11) then
						playerChar:SetCharacterSlot(10, gsid);
					end
				end
			end
		end
	end
end