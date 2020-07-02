--[[
Title: 
Author(s): leio 
Date: 2011/01/06 refactored by LiXizhi 2011.6.11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileMain.lua");
local NewProfileMain = commonlib.gettable("MyCompany.Aries.NewProfileMain");
NewProfileMain.ShowPage(nid,index);
-------------------------------------------------------
]]
local NewProfileMain = commonlib.gettable("MyCompany.Aries.NewProfileMain");

function NewProfileMain.CreatePage(nid,index,zorder)
	local self = NewProfileMain;
	nid = tonumber(nid);
	nid = nid or System.App.profiles.ProfileManager.GetNID();
	self.nid = nid;
	zorder = zorder or 1;
	self.SetEditState(false);
	local url = string.format("script/apps/Aries/NewProfile/NewProfileMain.kids.html?nid=%s",tostring(nid));
	local params = {
        url = url,
        app_key = MyCompany.Aries.app.app_key, 
        name = "NewProfileMain.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = zorder,
        allowDrag = false,
		isTopLevel = false,
        directPosition = true,
            align = "_ct",
            x = -350/2,
            y = -460/2,
            width = 350,
            height = 460,
    };
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	self.OnClickTab(index)
end
