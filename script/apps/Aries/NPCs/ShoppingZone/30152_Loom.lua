--[[
Title: Loom
Author(s): Leio
Date: 2009/12/14

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30152_Loom.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30152_Loom_panel.lua");
local libName = "Loom";
local Loom = {
	
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Loom", Loom);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Loom.main
function Loom.main()
	
end

function Loom.PreDialog()
	local self = Loom;
	
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30152_Loom_compose_panel.lua");
	MyCompany.Aries.Quest.NPCs.Loom_compose_panel.ShowPage();

	--MyCompany.Aries.Quest.NPCs.Loom_panel.GetAllItems(function()
		--local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
		--style.shadow_bg = "texture/bg_black_20opacity.png";
		--style.fillShadowLeft = -10000;
		--style.fillShadowTop = -10000;
		--style.fillShadowWidth = -10000;
		--style.fillShadowHeight = -10000;
		---- show the panel
		--System.App.Commands.Call("File.MCMLWindowFrame", {
			--url = "script/apps/Aries/NPCs/ShoppingZone/30152_Loom_panel.html", 
			--app_key = MyCompany.Aries.app.app_key, 
			--name = "30152_Loom_panel", 
			--isShowTitleBar = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = style,
			--zorder = 2,
			--allowDrag = false,
			--isTopLevel = true,
			--directPosition = true,
				--align = "_ct",
				--x = -930/2,
				--y = -512/2,
				--width = 930,
				--height = 512,
		--});
    --end);
    ---- deselect the microoven itself
    --System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	
	return false;
end
