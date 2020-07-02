--[[
Title: FootprintNote
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30360_FootprintNote.lua
------------------------------------------------------------
]]

-- create class
local libName = "FootprintNote";
local FootprintNote = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FootprintNote", FootprintNote);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FootprintNote.main
function FootprintNote.main()
	local self = FootprintNote; 
end

function FootprintNote.PreDialog(npc_id, instance)
	local self = FootprintNote; 
	return false;
end
function FootprintNote.ShowPage(index)
	local self = FootprintNote; 
	self.index = index or 1;
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/SnowArea/30360_FootprintNote_panel.html", 
			name = "FootprintNote.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -608/2,
				y = -300,
				width = 608,
				height = 408,
		});
end