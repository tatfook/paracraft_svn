--[[
Title: character customization system UI inventory slot
Author(s): WangTian
Date: 2007/7/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_InventorySlot.lua");
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_InventorySlot) then CCS_UI_InventorySlot = {}; end

--@param section: this is solely for debugging purposes. to make this class universal to all inventory slots
CCS_UI_InventorySlot.Component = nil;



--@param section: set the current item slot of the inventory
function CCS_UI_InventorySlot.SetInventorySlot(Section)
	if(Section == "Head") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_HEAD;
	elseif(Section == "Neck") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_NECK;
	elseif(Section == "Shoulder") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_SHOULDER;
	elseif(Section == "Boots") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_BOOTS;
	elseif(Section == "Belt") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_BELT;
	elseif(Section == "Shirt") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_SHIRT;
	elseif(Section == "Pants") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_PANTS;
	elseif(Section == "Chest") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_CHEST;
	elseif(Section == "Bracers") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_BRACERS;
	elseif(Section == "Gloves") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_GLOVES;
	elseif(Section == "HandRight") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_HAND_RIGHT;
	elseif(Section == "HandLeft") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_HAND_LEFT;
	elseif(Section == "Cape") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_CAPE;
	elseif(Section == "Tabard") then
		CCS_UI_InventorySlot.Component = CCS_db.CS_TABARD;
	end
end


-- get the current item slot of the inventory
function CCS_UI_InventorySlot.GetInventorySlot()
	if(CCS_UI_InventorySlot.Component == CCS_db.CS_HEAD) then
		return "Head";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_NECK) then
		return "Neck";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_SHOULDER) then
		return "Shoulder";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_BOOTS) then
		return "Boots";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_BELT) then
		return "Belt";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_SHIRT) then
		return "Shirt";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_PANTS) then
		return "Pants";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_CHEST) then
		return "Chest";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_BRACERS) then
		return "Bracers";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_GLOVES) then
		return "Gloves";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_HAND_RIGHT) then
		return "HandRight";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_HAND_LEFT) then
		return "HandLeft";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_CAPE) then
		return "Cape";
	elseif(CCS_UI_InventorySlot.Component == CCS_db.CS_TABARD) then
		return "Tabard";
	end
end

-- Function: set the inventory slot parameters for the specific item slot
function CCS_UI_InventorySlot.MountInventorySlot(SubType, value, donot_refresh)
	--CCS_db.SetFaceComponent(CCS_UI_InventorySlot.Component, SubType, value, donot_refresh);
end