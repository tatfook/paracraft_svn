--[[
Title: 
Author(s): zrf
Date: 2010/12/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/40201_NoticePanel.lua");
------------------------------------------------------------
]]


local NoticePanel = commonlib.gettable("MyCompany.Aries.Quest.NPCs.NoticePanel");

function NoticePanel.main()

end

function NoticePanel.PreDialog()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/TownSquare/40201_NoticePanel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "40201_NoticePanel", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -475/2,
            y = -435/2,
            width = 475,
            height = 435,
    });
	System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	return false;
end