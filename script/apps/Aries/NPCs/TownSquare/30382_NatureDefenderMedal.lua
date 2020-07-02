--[[
Title: NatureDefenderMedal
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30382_NatureDefenderMedal.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30382_NatureDefenderMedal_panel.lua");
-- create class
local libName = "NatureDefenderMedal";
local NatureDefenderMedal = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.NatureDefenderMedal", NatureDefenderMedal);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
-- NatureDefenderMedal.main
function NatureDefenderMedal.main()
end

function NatureDefenderMedal.PreDialog()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	
	--reset panel
    MyCompany.Aries.Quest.NPCs.NatureDefenderMedal_panel.Reset();
    local sendNum = 0;
    local has,__,__,copies = hasGSItem(50306);
    if(has)then
		sendNum = copies;
    end
	MyCompany.Aries.Quest.NPCs.NatureDefenderMedal_panel.sendNum = sendNum;--正确分类数量
    
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/TownSquare/30382_NatureDefenderMedal_panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30382_NatureDefenderMedal_panel", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -655/2,
            y = -512/2,
            width = 655,
            height = 512,
    });
    
    -- deselect the microoven itself
    System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	
	return false;
end