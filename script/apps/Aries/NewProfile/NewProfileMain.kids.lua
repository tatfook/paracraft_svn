--[[
Title: 
Author(s): leio
Date: 2011/01/06
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileMain.lua");
local NewProfileMain = commonlib.gettable("MyCompany.Aries.NewProfileMain");
NewProfileMain.ShowPage(nid,index);
-------------------------------------------------------
]]
local NewProfileMain = commonlib.gettable("MyCompany.Aries.NewProfileMain");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileCombat.lua");
local NewProfileCombat = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfileCombat");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileHonour.lua");
local NewProfileHonour = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfileHonour");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfilePvP.lua");
local NewProfilePvP = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfilePvP");


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
            x = -700/2,
            y = -460/2,
            width = 700,
            height = 460,
    };
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	self.OnClickTab(index)
end

function NewProfileMain.OnClickTab(index)
	local self = NewProfileMain;
	index = tonumber(index) or 2;
	local nid = self.nid;
	self.selected_index = index;
	if(index == 1)then
		local frame = self.page:GetNode("view_1");
		if(frame and frame.pageCtrl)then
			frame:SetAttribute("view_1", "script/apps/Aries/NewProfile/NewProfileInfo.html");
		end
	elseif(index == 2)then
		local url = "script/apps/Aries/NewProfile/NewProfileCombat.html";
		NewProfileCombat.GetInfo(nid)
		local frame = self.page:GetNode("view_2");
		if(frame and frame.pageCtrl)then
			frame:SetAttribute("view_2", url);
		end
	elseif(index == 3)then
		local url = "script/apps/Aries/NewProfile/NewProfileHonour.html";
		NewProfileHonour.GetItems(nid)
		local frame = self.page:GetNode("view_3");
		if(frame and frame.pageCtrl)then
			frame:SetAttribute("view_3", url);
		end
	elseif(index == 4)then
		local url = "script/apps/Aries/NewProfile/NewProfilePvP.html";
		NewProfilePvP.GetItems(nid)
		local frame = self.page:GetNode("view_4");
		if(frame and frame.pageCtrl)then
			frame:SetAttribute("view_4", url);
		end
	end

	if(self.nid == Map3DSystem.User.nid)then
		MyCompany.Aries.Pet.InitMyDragonPet(function(msg)
			self.page:Refresh(0.01);
		end);
	else
		MyCompany.Aries.Pet.InitOPCDragonPet(nid, function(msg) 
			self.page:Refresh(0.01);
		end);
	end
end