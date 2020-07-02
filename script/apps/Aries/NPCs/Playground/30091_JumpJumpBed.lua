--[[
Title: 30091_JumpJumpBed
Author(s): WangTian
Date: 2009/8/27

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Playground/30091_JumpJumpBed.lua
------------------------------------------------------------
]]

-- create class
local libName = "JumpJumpBed";
local JumpJumpBed = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.JumpJumpBed", JumpJumpBed);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- JumpJumpBed.main
function JumpJumpBed.main()
end

function JumpJumpBed.PreDialog()
	
	do return false; end
	
	local bed = NPC.GetNpcCharacterFromIDAndInstance(30091);
	
	local _test = ParaScene.GetCharacter("test_jumpjumpbed_dragon");
	if(_test and _test:IsValid() == true) then
		
	else
		local obj_params = {};
		obj_params.name = "test_jumpjumpbed_dragon";
		obj_params.AssetFile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml";
		obj_params.IsCharacter = true;
		obj_params.x = 0;
		obj_params.y = 0;
		obj_params.z = 0;
		-- skip saving to history for recording or undo.
		System.SendMessage_obj({
			type = System.msg.OBJ_CreateObject, 
			obj_params = obj_params, 
			SkipHistory = true,
			silentmode = true,
		});
		_test = ParaScene.GetCharacter("test_jumpjumpbed_dragon");
	end
	if(bed and bed:IsValid() == true) then
		System.MountPlayerOnChar(_test, bed, false);
		System.Animation.PlayAnimationFile("character/Animation/v5/dalong/PurpleDragoonMajorFemale_faint.x", _test);
		headon_speech.Speek(bed.name, "这只是测试......", 5, true);
	end
	
	return false;
end