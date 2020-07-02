--[[
Title: 30071_MicroOven
Author(s): WangTian
Date: 2009/8/27

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Playground/30071_MicroOven.lua
------------------------------------------------------------
]]

-- create class
local libName = "MicroOven";
local MicroOven = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MicroOven", MicroOven);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- MicroOven.main
function MicroOven.main()
end

function MicroOven.PreDialog()
	-- clear selected item ids before close
	NPL.load("(gl)script/apps/Aries/NPCs/Playground/30071_MicroOven_panel.lua");
	MyCompany.Aries.Quest.NPCs.MicroOvenPanelPage.ClearSelectedItems();
	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/Playground/30071_MicroOven_panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30071_MicroOven_panel", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -950/2,
            y = -500/2,
            width = 950,
            height = 450,
    });
    
    -- deselect the microoven itself
    System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	
	return false;
end