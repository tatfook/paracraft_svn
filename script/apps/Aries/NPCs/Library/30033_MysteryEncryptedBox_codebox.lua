--[[
Title: MysteryEncryptedBox_codebox
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Library/30033_MysteryEncryptedBox_codebox.lua");
MyCompany.Aries.Quest.NPCs.MysteryEncryptedBox_codebox.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "MysteryEncryptedBox_codebox";
local MysteryEncryptedBox_codebox = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MysteryEncryptedBox_codebox", MysteryEncryptedBox_codebox);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function MysteryEncryptedBox_codebox.DS_Func(index)
end