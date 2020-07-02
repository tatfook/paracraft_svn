--[[
Title: 
Author(s): leio
Date: 2011/07/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/ProfileProvider.lua");
local ProfileProvider = commonlib.gettable("MyCompany.Aries.ProfileProvider");
-------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local ProfileProvider = commonlib.gettable("MyCompany.Aries.ProfileProvider");
function ProfileProvider.GetCombatInfo(nid,callbackFunc)
end
function ProfileProvider.GetHonour(nid,callbackFunc)
end
function ProfileProvider.GetPvPInfo(nid,callbackFunc)
end