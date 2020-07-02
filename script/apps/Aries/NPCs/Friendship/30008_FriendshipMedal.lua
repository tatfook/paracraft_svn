--[[
Title: FriendshipMedal
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Friendship/30008_FriendshipMedal.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/Friendship/30008_FriendshipMedal_panel.lua");
-- create class
local libName = "FriendshipMedal";
local FriendshipMedal = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FriendshipMedal", FriendshipMedal);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- FriendshipMedal.main
function FriendshipMedal.main()
end

function FriendshipMedal.PreDialog()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	
	
	--reset panel
    MyCompany.Aries.Quest.NPCs.FriendshipMedal_panel.Reset();
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/Friendship/30008_FriendshipMedal_panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30008_FriendshipMedal_panel", 
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
    --加载礼物数量信息
    MyCompany.Aries.Quest.NPCs.FriendshipMedal_panel.GetGiftInfo(function(msg)
		if(msg and msg.issuccess)then
			MyCompany.Aries.Quest.NPCs.FriendshipMedal_panel.RefreshPage();
		end
    end)
    
    -- deselect the microoven itself
    System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	
	return false;
end