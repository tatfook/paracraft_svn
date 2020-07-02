--[[
Title: character customization system UI face component
Author(s): WangTian
Date: 2007/7/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_FaceComponent.lua");
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_FaceComponent) then CCS_UI_FaceComponent = {}; end

--@param section: this is solely for debugging purposes. to make this class universal to all face component sections
CCS_UI_FaceComponent.Component = nil;


--@param section: set the current section of the face component
function CCS_UI_FaceComponent.SetFaceSection(Section)
	if(Section == "Face") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_FACE;
	elseif(Section == "Wrinkle") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_WRINKLE;
	elseif(Section == "Eye") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_EYE;
	elseif(Section == "Eyebrow") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_EYEBROW;
	elseif(Section == "Mouth") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_MOUTH;
	elseif(Section == "Nose") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_NOSE;
	elseif(Section == "Marks") then
		CCS_UI_FaceComponent.Component = CCS_db.CFS_MARKS;
	elseif(Section == "CharFace") then
		CCS_UI_FaceComponent.Component = 100;
	end
end


-- get the current section of the face component
function CCS_UI_FaceComponent.GetFaceSection()
	if(CCS_UI_FaceComponent.Component == CCS_db.CFS_FACE) then
		return "Face";
	elseif(CCS_UI_FaceComponent.Component == CCS_db.CFS_WRINKLE) then
		return "Wrinkle";
	elseif(CCS_UI_FaceComponent.Component == CCS_db.CFS_EYE) then
		return "Eye";
	elseif(CCS_UI_FaceComponent.Component == CCS_db.CFS_EYEBROW) then
		return "Eyebrow";
	elseif(CCS_UI_FaceComponent.Component == CCS_db.CFS_MOUTH) then
		return "Mouth";
	elseif(CCS_UI_FaceComponent.Component == CCS_db.CFS_NOSE) then
		return "Nose";
	elseif(CCS_UI_FaceComponent.Component == CCS_db.CFS_MARKS) then
		return "Marks";
	elseif(CCS_UI_FaceComponent.Component == 100) then
		return "CharFace";
	end
end

-- Function: set the face component parameters for the specific section
function CCS_UI_FaceComponent.SetFaceComponent(SubType, value, donot_refresh)
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, SubType, value, donot_refresh);
end