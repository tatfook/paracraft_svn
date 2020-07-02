--[[
Title: Skin Baker
Author(s): WangTian, refactored by LiXizhi
Date: 2009/12/14
Desc: change the skin color of the main character at will. 
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/SunnyBeach/30143_SkinBaker.lua
------------------------------------------------------------
]]

-- create class
local libName = "SkinBaker";
local SkinBaker = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SkinBaker", SkinBaker);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- SkinBaker.main()
function SkinBaker.main()
end

-- SkinBaker.RefreshStatus()
function SkinBaker.RefreshStatus()
end

-- SkinBaker.PreDialog()
function SkinBaker.PreDialog()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/SunnyBeach/30143_SkinBaker_panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30143_SkinBaker_panel", 
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
	
    -- deselect the MagicMirror itself
    System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
    
    return false;
end
