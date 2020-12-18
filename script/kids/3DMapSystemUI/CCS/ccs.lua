--[[
Title: Character Customization System public functions
Author(s): WangTian
Date: 2007/10/29, refactored 2008.6.12 by LiXizhi
Desc: Basic ccs functions 

ccs string format is like below[facing]@[cartoon face]@[slot]@[skinmask]
CCSInfoStr="
-- facial
5#1#0#7#1#@ 
-- cartoon face
5#F#0#0#0#0# 
0#F#0#0#0#0#
10#F#0#0#0#0#
9#F#0#0#0#0#
9#F#0#0#0#0#
4#F#0#0#0#0#
0#F#0#0#0#0#@
-- equipment and slots
2#10001#0#1#11010#0#0#0#0#0#1078#0#0#1069#1093#1095#0#1079#0#0#0#0#0#@
-- skin mask
F
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/ccs.lua");
-------------------------------------------------------
]]
local CCS = commonlib.gettable("Map3DSystem.UI.CCS");

NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DB.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/InventorySlot.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Inventory.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CartoonFaceComponent.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DefaultAppearance.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Predefined.lua");

-- get the CCS information string from the obj_param
-- @param obj_param: object parameter(table) or ParaObject object
-- @return: the ccs info string if CCS character
--		or nil if no CCS information is found
if(not CCS.GetCCSInfoString) then
	function CCS.GetCCSInfoString(obj_params)
		if(type(obj_params) == "table") then
			obj_params = ObjEditor.GetObjectByParams(obj_params);
		elseif(type(obj_params) == "userdata") then
		else
			log("error: obj_params not table or userdata value in GetCCSInfoString.\n");
			return;
		end
	
		if(obj_params and obj_params:IsValid()) then
			local facial_info_string = CCS.Predefined.GetFacialInfoString(obj_params) or "";
			local cartoonface_info_string = CCS.DB.GetCartoonfaceInfoString(obj_params) or "";
			local characterslot_info_string = CCS.Inventory.GetCharacterSlotInfoString(obj_params) or "";

			local skin_color_mask = obj_params:ToCharacter():GetSkinColorMask();
		
			return string.format("%s@%s@%s@%s", facial_info_string, cartoonface_info_string, characterslot_info_string, skin_color_mask);
		end	
	end
end

-- apply the ccs information string to the obj_params object
-- @param obj_param: object parameter(table) or ParaObject object
-- @param sInfo: ccs information string
-- NOTE: obj can be ParaScene object or mini scene graph object
if(not CCS.ApplyCCSInfoString) then
	function CCS.ApplyCCSInfoString(obj_params, sInfo)
	
		if(sInfo == nil or sInfo == "") then
			--log("warning: trying to apply empty ccs information to a character object.\n");
			return;
		end
	
		if(type(obj_params) == "userdata") then
		elseif(type(obj_params) == "table") then
			obj_params = ObjEditor.GetObjectByParams(obj_params);
		else
			log("error: obj_params not table or userdata value in ApplyCCSInfoString.\n");
			return;
		end
	
		if(obj_params and obj_params:IsValid()) then
			local facial_info_string, cartoonface_info_string, characterslot_info_string, skin_color_mask =  string.match(sInfo, "([^@]+)@([^@]+)@([^@]+)@?(.*)");

			if(characterslot_info_string) then
				if(skin_color_mask) then
					obj_params:ToCharacter():SetSkinColorMask(skin_color_mask);
				end
				CCS.Predefined.ApplyFacialInfoString(obj_params, facial_info_string);
				CCS.DB.ApplyCartoonfaceInfoString(obj_params, cartoonface_info_string);
				CCS.Inventory.ApplyCharacterSlotInfoString(obj_params, characterslot_info_string);
			else
				log("error: didn't found any CCS infomation\n");
			end
		end	
	end
end
CCS.ApplyCCSInfoString_MC = CCS.ApplyCCSInfoString;
function Map3DSystem.UI.CCS.LoadIdentityInfo()
	local identity = {
		["characterslot_info"] = {
			["itemBoots"] = 0,
			["itemNeck"] = 0,
			["itemChest"] = 0,
			["itemBracers"] = 0,
			["itemBelt"] = 0,
			["itemHead"] = 0,
			["itemHandLeft"] = 0,
			["itemHandRight"] = 0,
			["itemShirt"] = 0,
			["itemCape"] = 0,
			["itemPants"] = 0,
			["itemGloves"] = 0,
			["itemTabard"] = 0,
			["itemShoulder"] = 0,
		},
		["cartoonface_info"] = {
			["cartoonFace_Marks_Scale"] = 0,
			["cartoonFace_Nose_Y"] = 0,
			["cartoonFace_Face_Scale"] = 0,
			["cartoonFace_Eyebrow_Color"] = 4294967295,
			["cartoonFace_Eye_Rotation"] = 0,
			["cartoonFace_Wrinkle_X"] = 0,
			["cartoonFace_Eye_Color"] = 4294967295,
			["cartoonFace_Eye_X"] = 0,
			["cartoonFace_Nose_Color"] = 4294967295,
			["cartoonFace_Mouth_X"] = 0,
			["cartoonFace_Wrinkle_Y"] = 0,
			["cartoonFace_Nose_Rotation"] = 0,
			["cartoonFace_Mouth_Rotation"] = 0,
			["cartoonFace_Marks_Y"] = 0,
			["cartoonFace_Marks_X"] = 0,
			["cartoonFace_Face_Type"] = 0,
			["cartoonFace_Eyebrow_Scale"] = 0,
			["cartoonFace_Eyebrow_Y"] = 0,
			["cartoonFace_Mouth_Type"] = 0,
			["cartoonFace_Mouth_Y"] = 0,
			["cartoonFace_Nose_Scale"] = 0,
			["cartoonFace_Face_Rotation"] = 0,
			["cartoonFace_Marks_Color"] = 4294967295,
			["cartoonFace_Mouth_Scale"] = 0,
			["cartoonFace_Wrinkle_Rotation"] = 0,
			["cartoonFace_Face_X"] = 0,
			["cartoonFace_Mouth_Color"] = 4294967295,
			["cartoonFace_Eyebrow_Type"] = 0,
			["cartoonFace_Marks_Type"] = 0,
			["cartoonFace_Wrinkle_Scale"] = 0,
			["cartoonFace_Eye_Y"] = 0,
			["cartoonFace_Wrinkle_Color"] = 4294967295,
			["cartoonFace_Nose_X"] = 0,
			["cartoonFace_Wrinkle_Type"] = 0,
			["cartoonFace_Nose_Type"] = 0,
			["cartoonFace_Face_Y"] = 0,
			["cartoonFace_Face_Color"] = 4294967295,
			["cartoonFace_Eye_Scale"] = 0,
			["cartoonFace_Eyebrow_X"] = 0,
			["cartoonFace_Eyebrow_Rotation"] = 0,
			["cartoonFace_Eye_Type"] = 0,
			["cartoonFace_Marks_Rotation"] = 0,
		},
		["facial_info"] = {
			["facialHair"] = 1,
			["skinColor"] = 0,
			["hairStyle"] = 0,
			["hairColor"] = 0,
			["faceType"] = 0,
		},
	};
	
	return identity;
end

Map3DSystem.UI.CCS.Matrix = {
	["00"] = {0, 0, 255},
	["01"] = {0, 255, 0},
	["02"] = {255, 0, 0},
	["10"] = {0, 255, 255},
	["11"] = {255, 0, 255},
	["12"] = {255, 255, 0},
	["20"] = {127, 0, 255},
	["21"] = {127, 255, 0},
	["22"] = {255, 127, 0},
	["30"] = {0, 127, 255},
	["31"] = {0, 255, 127},
	["32"] = {255, 0, 127},
	["40"] = {127, 127, 255},
	["41"] = {127, 255, 127},
	["42"] = {255, 127, 127},
	["50"] = {255, 255, 127},
	["51"] = {255, 127, 255},
	["52"] = {127, 255, 255},
	["60"] = {0, 0, 127},
	["61"] = {0, 127, 0},
	["62"] = {127, 0, 0},
	["70"] = {0, 127, 127},
	["71"] = {127, 0, 127},
	["72"] = {127, 127, 0},
	["03"] = {0, 0, 0},
	["13"] = {32, 32, 32},
	["23"] = {64, 64, 64},
	["33"] = {96, 96, 96},
	["43"] = {128, 128, 128},
	["53"] = {160, 160, 160},
	["63"] = {192, 192, 192},
	["73"] = {224, 224, 224},
};
