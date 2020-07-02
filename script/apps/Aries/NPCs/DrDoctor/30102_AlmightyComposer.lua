--[[
Title: AlmightyComposer
Author(s): Leio
Date: 2009/11/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/DrDoctor/30102_AlmightyComposer.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");

NPL.load("(gl)script/apps/Aries/NPCs/DrDoctor/30102_AlmightyComposer_panel.lua");
-- create class
local libName = "AlmightyComposer";
local AlmightyComposer = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AlmightyComposer", AlmightyComposer);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- AlmightyComposer.main
function AlmightyComposer.main()
end

function AlmightyComposer.PreDialog()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;

	MyCompany.Aries.Quest.NPCs.AlmightyComposer_panel.ShowPage()
    
    -- deselect the microoven itself
    System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	
	return false;
end