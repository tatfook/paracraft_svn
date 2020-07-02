--[[
Title: MagicMirror
Author(s): WangTian
Date: 2009/11/28

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30061_MagicMirror.lua
------------------------------------------------------------
]]

-- create class
local libName = "MagicMirror";
local MagicMirror = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MagicMirror", MagicMirror);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- MagicMirror.main
function MagicMirror.main()
end

function MagicMirror.PreDialog()
	---- clear selected item ids before close
	--NPL.load("(gl)script/apps/Aries/NPCs/Playground/30071_MicroOven_panel.lua");
	--MyCompany.Aries.Quest.NPCs.MicroOvenPanelPage.ClearSelectedItems();
	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/ShoppingZone/30061_MagicMirror_panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30061_MagicMirror_panel", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -730/2,
            y = -556/2,
            width = 730,
            height = 556,
    });
    
	MyCompany.Aries.MagicMirrorPanelPage.RefreshAvatar();
	
    -- deselect the MagicMirror itself
    System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	
	return false;
end