--[[
Title: kid ui middle container
Author(s): LiXizhi
Date: 2006/7/7
Desc: CommonCtrl.CKidMiddleContainer displays the middle container of the ui
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/middle_container.lua");
CommonCtrl.CKidMiddleContainer.Initialize();
------------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/kids/ui/left_container.lua");
NPL.load("(gl)script/kids/ui/right_container.lua");
NPL.load("(gl)script/ide/coloreditor_control.lua");
NPL.load("(gl)script/ide/itemlist_control.lua");
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/terrain_editor.lua");
NPL.load("(gl)script/ide/ParaEngineSettings.lua");
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/kids/ui/OnAICommand.lua");
NPL.load("(gl)script/movie/ActorMovieCtrl.lua");
NPL.load("(gl)script/kids/ui/kidspainter.lua");


NPL.load("(gl)script/kids/CCS/CCS_main.lua");
NPL.load("(gl)script/kids/BCS/BCS_UI_Main.lua");

NPL.load("(gl)script/kids/CCS/CCS_UI_Predefined.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");
	
-- define a new control in the common control libary
local L = CommonCtrl.Locale("KidsUI");

local rootUI = ParaUI.GetUIObject("root");	
	
-- default member attributes
local CKidMiddleContainer = {
	-- normal window size
	state="text",
	obj_btn_width=30,
	name = "kidmiddlecontainer",
	contName="kidui_middle_container",
	char_type={
		[1] = {text = L"player", container="", tooltip=L"I can see every one", bg = "Texture/kidui/common/btn_bg.png", GroupID=0,SentientField=65535},
		[2] = {text = L"NPC", container="NPC_behavior_cont",tooltip=L"I can see players", bg = "Texture/kidui/common/btn_bg.png", GroupID=1,SentientField=1},
		[3] = {text = L"actor", container="Actor_behavior_cont",tooltip=L"I can see both NPC and players", bg = "Texture/kidui/common/btn_bg.png", GroupID=2,SentientField=3},
		[4] = {text = L"dummy", container="",tooltip=L"I can not see anyone", bg = "Texture/kidui/common/btn_bg.png", GroupID=3,SentientField=0},
		[5] = {text = L"custom", container="",tooltip=L"other character types", bg = "Texture/kidui/common/btn_bg.png", GroupID=4,SentientField=0},
	},
	behaviorContList = {"NPC_behavior_cont","Actor_behavior_cont"},--only one container is visible for a given char_type.
	currentCharType = 5, -- current index in char_type, which is displayed in UI.
	ai_buttons = {
		[1] = {text = L"bla bla bla", bg = "Texture/kidui/common/ai_blablabla.png"},
		[2] = {text = L"random walk", bg = "Texture/kidui/common/ai_random.png"},
		[3] = {text = L"follower", bg = "Texture/kidui/common/ai_followany.png"},
		[4] = {text = L"shopkeeper", bg = "Texture/kidui/common/ai_rest.png"},
		[5] = {text = L"groceryman", bg = "Texture/kidui/common/ai_market.png"},
		[6] = {text = L"No IQ", bg = "Texture/kidui/common/ai_empty.png"},
		--[7] = {text = "讲笑话", bg = "Texture/kidui/common/ai_joke.png"},
		--[8] = {text = "鬼故事", bg = "Texture/kidui/common/ai_ghost.png"},
	},
	skyboxes = {
		[1] = {name = "skybox1", file = "model/Skybox/Skybox1/Skybox1.x", bg = "Texture/kidui/middle/sky/btn_sky1.png"},
		[2] = {name = "skybox2", file = "model/Skybox/skybox2/skybox2.x", bg = "Texture/kidui/middle/sky/btn_sky2.png"},
		[3] = {name = "skybox3", file = "model/Skybox/Skybox3/Skybox3.x", bg = "Texture/kidui/middle/sky/btn_sky3.png"},
		[4] = {name = "skybox4", file = "model/Skybox/skybox4/skybox4.x", bg = "Texture/kidui/middle/sky/btn_sky4.png"},
		[5] = {name = "skybox5", file = "model/Skybox/Skybox5/Skybox5.x", bg = "Texture/kidui/middle/sky/btn_sky5.png"},

	},
	terrainTexList = {
		[1]={filename = "Texture/tileset/generic/StoneRoad.dds"},
		[2]={filename = "Texture/tileset/generic/sandRock.dds"},
		[3]={filename = "Texture/tileset/generic/sandSmallRock.dds"},
		--[4]={filename = "Texture/tileset/generic/greengrass.dds"},
		--[5]={filename = "Texture/tileset/generic/stonegrass.dds"},
		--[6]={filename = "Texture/tileset/generic/GridMarker.dds"},
		--[7]={filename = "Texture/tileset/generic/custom1.dds"},
		--[8]={filename = "Texture/tileset/generic/custom2.dds"},
		--[9]={filename = "Texture/tileset/generic/custom3.dds"},
		--[10]={filename = "Texture/tileset/generic/custom4.dds"},
		--[11]={filename = "Texture/tileset/generic/custom5.dds"},
		--[12]={filename = "Texture/tileset/generic/custom6.dds"},
	},
	-- names of characer type buttons for radio buttons
	char_type_buttons = {},
	LastOceanSliderValue = 50,
}
CommonCtrl.CKidMiddleContainer = CKidMiddleContainer;
CommonCtrl.AddControl(CKidMiddleContainer.name, CKidMiddleContainer);


--[[ switch to a new state
@param sName:it can be one of the following: "text", "modify","sky","water","terrain", "empty"
]]
function CKidMiddleContainer.SwitchUI(sName)
	local self = CommonCtrl.GetControl("kidmiddlecontainer");
	if(self==nil)then
		log("err getting control kidmiddlecontainer\r\n");
		return;
	end
	
	if(self.state ~= sName) then
		self.state=sName;
		self.Update();
	elseif(self.state == "property") then
		local _this;
		-- needs some update on content if it is a property
		local player = ObjEditor.GetCurrentObj();
		if(player:IsCharacter() == true) then
			-- this is a character
			_this=ParaUI.GetUIObject("kidui_property_char_container");
			_this.visible=true;
			_this=ParaUI.GetUIObject("kidui_property_model_container");
			_this.visible=false;
			
			-- update UI for the current object
			_this=ParaUI.GetUIObject("kidui_property_charname");
			_this.text = player.name;
			CommonCtrl.CKidMiddleContainer.OnUpdateCharacterTypeUI();
		else
			-- this is a model
			_this=ParaUI.GetUIObject("kidui_property_char_container");
			_this.visible=false;
			_this=ParaUI.GetUIObject("kidui_property_model_container");
			_this.visible=true;
			
			-- update UI for the current object	
			CommonCtrl.CKidMiddleContainer.OnUpdateModelPropertyUI(player);
		end
	end
end
function CKidMiddleContainer.SetText(sText)
	local self = CommonCtrl.GetControl("kidmiddlecontainer");
	if(self==nil)then
		log("err getting control kidmiddlecontainer\r\n");
		return;
	end
	local _this=ParaUI.GetUIObject("kidui_text_text");
	_this.text=sText;
end

-- update the state, 
--@param newState: if this is nil, the current state is being updated.
function CKidMiddleContainer.Update(newState)
	local self = CommonCtrl.GetControl("kidmiddlecontainer");
	if(self==nil)then
		log("err getting control kidmiddlecontainer\r\n");
		return;
	end
	if(newState~=nil) then
		self.state=newState;
	end
	
	local tag = false;
	
	if(ParaUI.GetUIObject("kidui_bcs_container").visible == true) then
		tag = true;
	end
		
	local _this;
	if(self.state=="text")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=true;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
	elseif(self.state=="modify")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=true;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
	elseif(self.state=="sky")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=true;
		CKidMiddleContainer.UpdateSkyColorUI();
		CKidMiddleContainer.UpdateFogColorUI();
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
	elseif(self.state=="water")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=true;
		CKidMiddleContainer.UpdateOceanColorUI();
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
	elseif(self.state=="terrain")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=true;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
	elseif(self.state=="CCSMenu")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=true;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
		
		CCS_main.UpdateCharacterInfo();
		
	elseif(self.state=="BCSMenu")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=true;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
		
	elseif(self.state=="CharacterModel")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=true;
		
	elseif(self.state=="property")then
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
		
		local player = ObjEditor.GetCurrentObj();
		if(player:IsCharacter() == true) then
			-- this is a character
			_this=ParaUI.GetUIObject("kidui_property_char_container");
			_this.visible=true;
			_this=ParaUI.GetUIObject("kidui_property_model_container");
			_this.visible=false;
			
			-- update UI for the current object
			_this=ParaUI.GetUIObject("kidui_property_charname");
			_this.text = player.name;
			CommonCtrl.CKidMiddleContainer.OnUpdateCharacterTypeUI();
		else
			-- this is a model
			_this=ParaUI.GetUIObject("kidui_property_char_container");
			_this.visible=false;
			_this=ParaUI.GetUIObject("kidui_property_model_container");
			_this.visible=true;
			
			-- update UI for the current object	
			CommonCtrl.CKidMiddleContainer.OnUpdateModelPropertyUI(player);
		end
		
	elseif(self.state=="empty") then
		-- hide all
		_this=ParaUI.GetUIObject("kidui_text_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_modify_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_sky_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_water_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_terrain_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_char_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_property_model_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_bcs_container");
		_this.visible=false;
		_this=ParaUI.GetUIObject("kidui_character_container");
		_this.visible=false;
	end
	
		_this=ParaUI.GetUIObject("kidui_ccs_container");
		if(_this.visible == true) then
			CCS_main.UpdateCharacterInfo();
		end
		
	if(tag == true) then
		if(ParaUI.GetUIObject("kidui_bcs_container").visible == false) then
			BCS_main.OnLeaveEditMarker();
		end
	end
end

function CKidMiddleContainer.Initialize()
	local self = CommonCtrl.GetControl("kidmiddlecontainer");
	if(self==nil)then
		log("err getting control kidmiddlecontainer\r\n");
		return;
	end
	local _this,texture,_parent,_partext,_parmod,_parproperty,_parsky,_parwater,_parterrain,left,top,btn_width;
	_parent=ParaUI.GetUIObject(self.contName);
	if(_parent:IsValid()) then
		return;
	end
	
	self.state="text";
	
-- background images: left, middle(strenghable), right
	local BGLeftWidth,BGLeftHeight = 128,256;
	local BGRightWidth,BGRightHeight = 128,256;
	local BGMiddleHeight = 256;
	_this=ParaUI.CreateUIObject("container",self.contName.."bg","_lb",256,-BGLeftHeight,BGLeftWidth,BGLeftHeight);
	_this:AttachToRoot();
	_this.enabled = false;
	_this.background="Texture/kidui/middle/bg_mid_left.png";
	
	_this=ParaUI.CreateUIObject("container",self.contName.."bg","_mb",256+BGLeftWidth,0,256+BGRightWidth,BGMiddleHeight);
	_this:AttachToRoot();
	_this.enabled = false;
	_this.background="Texture/kidui/middle/bg_mid_mid.png";
	
	_this=ParaUI.CreateUIObject("container",self.contName.."bg","_rb",-256-BGRightWidth ,-BGRightHeight,BGRightWidth,BGRightHeight);
	_this:AttachToRoot();
	_this.enabled = false;
	_this.background="Texture/kidui/middle/bg_mid_right.png";

	local i;
	local ToLeft,ToBottom,ToRight, MidHeight = 200, 10, 256, 160;
	local left, top, width, height;
--text	
	_partext=ParaUI.CreateUIObject("container","kidui_text_container","_mb",ToLeft,ToBottom,ToRight, MidHeight);
	_partext:AttachToRoot();
	_partext.background="Texture/whitedot.png;0 0 0 0";
	--_partext.background="Texture/alphadot.png";
	_partext.visible=true;
	--_partext.scrollable=true;
	
	-- player commands
	left, top, width, height = 10, 10, 64, 64;
	_this=ParaUI.CreateUIObject("button","kidui_switchtoplayer_btn","_lt",left, top, width, height);
	_partext:AddChild(_this);
	_this.tooltip=L"switch to main player";
	_this.background="Texture/kidui/common/cmd_toplayer.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.CMD_SwithToPlayer();";
	
	left = left + width+10;
	_this=ParaUI.CreateUIObject("button","kidui_wayhome_btn","_lt",left, top, width, height);
	_partext:AddChild(_this);
	_this.tooltip=L"go home automatically";
	_this.background="Texture/kidui/common/cmd_wayhome.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.CMD_WayHome();";
	
	left = left + width+10;
	_this=ParaUI.CreateUIObject("button","kidui_toggleplayer_btn","_lt",left, top, width, height);
	_partext:AddChild(_this);
	_this.tooltip=L"switch to the nearest character\r\nshortcut key <Left Shift>";
	_this.background="Texture/kidui/common/cmd_followme.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.CMD_ShiftToClosestPlayer();";
	
	--[[
	left = left + width+10;
	_this=ParaUI.CreateUIObject("button","kidui_followme_btn","_lt",left, top, width, height);
	_partext:AddChild(_this);
	_this.tooltip="跟我来";
	_this.background="Texture/kidui/common/cmd_followme.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.CMD_FollowMe();";
	
	
	left = left + width+10;
	_this=ParaUI.CreateUIObject("button","kidui_leaveme_btn","_lt",left, top, width, height);
	_partext:AddChild(_this);
	_this.tooltip="别过来";
	_this.background="Texture/kidui/common/cmd_leaveme.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.CMD_LeaveMe();";
	]]
	
	-- talk and action panel
	_this=ParaUI.CreateUIObject("imeeditbox","kidui_text_text","_mb",20,10,120,30);
	_partext:AddChild(_this);
	_this.background="Texture/kidui/main/bg_266X48.png";
	_this.onchange=";CommonCtrl.CKidMiddleContainer.OnTextChange();";
	
	
	_this=ParaUI.CreateUIObject("button","kidui_text_btn","_rb",-110,-40,32,32);
	_partext:AddChild(_this);
	--_this.tooltip="说话";
	_this.background="Texture/kidui/common/text_input.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnTextInput();";
	
	_this=ParaUI.CreateUIObject("button","kidui_text_act_btn","_rb",-60,-40,32,32);
	_partext:AddChild(_this);
	_this.background="Texture/kidui/common/smile.png";
	--_this.tooltip="动作";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnTextAction();";
		
--modify
	_parmod=ParaUI.CreateUIObject("container","kidui_modify_container","_mb",ToLeft,ToBottom,ToRight, MidHeight);
	_parmod:AttachToRoot();
	_parmod.background="Texture/whitedot.png;0 0 0 0";
	--_parmod.background="Texture/alphadot.png";
	_parmod.visible=false;

	left=15-255;
	top=16-MidHeight/2;
	-- translate object
	_this=ParaUI.CreateUIObject("button","kidui_m_translate_btn","_ct",left,top,128,128);
	_parmod:AddChild(_this);
	_this.background="Texture/kidui/middle/modify/object_move.png";
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnTranslationClick();"
	
	left=left+128+30;
	-- rotate object
	_this=ParaUI.CreateUIObject("button","kidui_m_rotate_btn","_ct",left,top,128,128);
	_parmod:AddChild(_this);
	_this.background="Texture/kidui/middle/modify/object_rotate.png";
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnRotationClick();"
		
	left=left+128+30;
	-- magnify object
	_this=ParaUI.CreateUIObject("button","kidui_m_magnify_btn","_ct",left,top,64,64);
	_parmod:AddChild(_this);
	_this.background="Texture/kidui/middle/modify/magnify.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnMagnifyClick();";
	
	-- minify object
	_this=ParaUI.CreateUIObject("button","kidui_m_minify_btn","_ct",left,top+66,64,64);
	_parmod:AddChild(_this);
	_this.background="Texture/kidui/middle/modify/minify.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnMinifyClick();";
	left=left+95;
	
	-- translate to here	
	_this=ParaUI.CreateUIObject("button","kidui_m_here_btn","_ct",left,top,64,64);
	_parmod:AddChild(_this);
	_this.background=L"Texture/kidui/middle/modify/btn_here.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnMoveHereClick();";
	
	-- reset button
	_this=ParaUI.CreateUIObject("button","kidui_m_reset_btn","_ct",left,top+70,64,64);
	_parmod:AddChild(_this);
	_this.background=L"Texture/kidui/middle/modify/btn_reset.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnResetClick();";
--sky
	_parsky=ParaUI.CreateUIObject("container","kidui_sky_container","_mb",210,3,300,160);
	_parsky:AttachToRoot();
	_parsky.background="Texture/whitedot.png;0 0 0 0";
	_parsky.visible=false;

	left,top = 100,0;
	_this=ParaUI.CreateUIObject("text","static","_lt",0,top,80,25);
	_parsky:AddChild(_this);
	_this.text=L"lighting:";
	
	_this=ParaUI.CreateUIObject("slider","kidui_s_light_slider","_lt",left-10,top,280,32);
	_parsky:AddChild(_this);
	_this.background="Texture/kidui/middle/sky/slider_bg.png";
	_this.button="Texture/kidui/middle/sky/slider_btn.png";
	_this.value = (ParaScene.GetTimeOfDaySTD()/2+0.5)*100;
	_this.onchange=string.format([[;if(kids_db.User.CheckRight("TimeOfDay")) then ParaSettingsUI.OnTimeSliderChanged("%s") end]],_this.name);

	top = top+32;
	btn_width = 32;
	_this=ParaUI.CreateUIObject("text","static","_lt",0,top,120,25);
	_parsky:AddChild(_this);
	_this.text=L"sky background:";
	
	local skyboxes = self.skyboxes;
	
	for i=1, table.getn(skyboxes) do
		local item = skyboxes[i];
		_this=ParaUI.CreateUIObject("button","kidui_s_skybtn"..i,"_lt",left,top,btn_width,btn_width);
		_parsky:AddChild(_this);
		_this.background = item.bg;
		_this.animstyle = 12;
		_this.onclick=string.format([[;CommonCtrl.CKidMiddleContainer.OnChangeSkybox(%d)]],i);
		left = left+btn_width+5;
	end

	-- sky color
	left, top = 0,76;
	width = 70;
	_this=ParaUI.CreateUIObject("text","static","_lt",left, top, width, 25);
	_parsky:AddChild(_this);
	_this.text=L"sky color:";
	left=left+width+1;
	
	local ctl = CommonCtrl.CCtrlColorEditor:new {
		name = "KidUI_s_skycolor",
		parent = _parsky,
		left = left, top = top, 
		r = 255,g = 255,b = 255,
		onchange = "CommonCtrl.CKidMiddleContainer.OnSkyColorChanged();",
	};
	ctl:Show();
	
-- fog color
	left= 260;
	_this=ParaUI.CreateUIObject("text","static","_lt",left, top, width, 25);
	_parsky:AddChild(_this);
	_this.text=L"fog color:";
	left=left+width+1;
	
	local ctl = CommonCtrl.CCtrlColorEditor:new {
		name = "KidUI_s_fogcolor",
		parent = _parsky,
		left = left, top = top, 
		r = 255,g = 255,b = 255,
		onchange = "CommonCtrl.CKidMiddleContainer.OnFogColorChanged();",
	};
	ctl:Show();
	
--water
	_parwater=ParaUI.CreateUIObject("container","kidui_water_container","_mb",210,3,300,160);
	_parwater:AttachToRoot();
	_parwater.background="Texture/whitedot.png;0 0 0 0";
	_parwater.visible=false;
	
	_this=ParaUI.CreateUIObject("text","static","_lt",0, 10, 70,25);
	_parwater:AddChild(_this);
	_this.text=L"water level:";
	left=left+width;
	
	_this=ParaUI.CreateUIObject("container","c","_lt",71,0,145,81);
	_parwater:AddChild(_this);
	_this.background="Texture/kidui/middle/water/water_bg.png;0 0 145 81";
	
	_this=ParaUI.CreateUIObject("button","kidui_w_height2_btn","_lt",76,45,32,32);
	_parwater:AddChild(_this);
	_this.onclick=";TerrainEditorUI.WaterLevel(-1, true);";
	_this.tooltip=L"down 1 meter";
	_this.background="Texture/kidui/middle/water/btn_h1.png";
	_this.animstyle = 12;
	
	_this=ParaUI.CreateUIObject("button","kidui_w_height3_btn","_lt",115,23,52,32);
	_parwater:AddChild(_this);
	_this.onclick=";TerrainEditorUI.WaterLevel(0, true);";
	_this.tooltip=L"To current player's feet";
	_this.background="Texture/kidui/middle/water/btn_h3.png;0 0 52 32";
	_this.animstyle = 12;

	_this=ParaUI.CreateUIObject("button","kidui_w_height5_btn","_lt",175,3,36,36);
	_parwater:AddChild(_this);
	_this.background="Texture/kidui/middle/water/btn_h5.png;0 0 36 36";
	_this.onclick=";TerrainEditorUI.WaterLevel(1, true);";
	_this.tooltip=L"up 1 meter";
	_this.animstyle = 12;
	
	
	_this=ParaUI.CreateUIObject("button","kidui_w_disable_btn","_lt",240,10,32,32);
	_parwater:AddChild(_this);
	_this.background="Texture/player/close.png";
	_this.onclick=";TerrainEditorUI.WaterLevel(0, false);";
	_this.tooltip=L"no water";
	
	_this=ParaUI.CreateUIObject("slider","kidui_w_level_slider","_lt",272,14,200,25);
	_parwater:AddChild(_this);
	_this.background="Texture/kidui/middle/sky/slider_bg.png";
	_this.button="Texture/kidui/middle/sky/slider_btn.png";
	_this.value = 50;
	_this.onchange=";CommonCtrl.CKidMiddleContainer.OnOceanLevelChanged();";
	_this.onmousedown=";CommonCtrl.CKidMiddleContainer.OnOceanLevelSliderBegin();";
	_this.onmouseup=";CommonCtrl.CKidMiddleContainer.OnOceanLevelSliderEnd();";
	
	-- TODO: instead of writing a handler, we can bind it attribute field
	left, top = 0,76;
	width = 70;
	_this=ParaUI.CreateUIObject("text","static","_lt",left, top, width, 25);
	_parwater:AddChild(_this);
	_this.text=L"water color:";
	left=left+width+1;
	
	local ctl = CommonCtrl.CCtrlColorEditor:new {
		name = "KidUI_w_color",
		parent = _parwater,
		left = left, top = top, 
		r = 255,g = 255,b = 255,
		onchange = "CommonCtrl.CKidMiddleContainer.OnOceanColorChanged();",
	};
	ctl:Show();
		
--terrain
	_parterrain=ParaUI.CreateUIObject("container","kidui_terrain_container","_mb",210,13,320,153);
	_parterrain:AttachToRoot();
	_parterrain.background="Texture/whitedot.png;0 0 0 0";
	_parterrain.visible=false;

	left, top =0, 0;
	width = 60;
	_this=ParaUI.CreateUIObject("text","static","_lt",left,top+25,width,25);
	_parterrain:AddChild(_this);
	_this.text=L"height:";
	
	left = left+width;
	width = 144;
	_this=ParaUI.CreateUIObject("container","kidui_t_cont","_lt",left,top,width,84);
	_parterrain:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_bg.png;0 0 144 84";
	_parent = _this;
	
	_this=ParaUI.CreateUIObject("button","kidui_t_height1_btn","_lt",22,44,32,32);
	_parent:AddChild(_this);
	_this.tooltip=L"Lower terrain";
	_this.animstyle = 12;
	_this.background="Texture/kidui/middle/terrain/btn_h1.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.GaussianHill(-1);";
	
	_this=ParaUI.CreateUIObject("button","kidui_t_height3_btn","_lt",47,22,32,32);
	_parent:AddChild(_this);
	_this.tooltip=L"Flatten terrain";
	_this.animstyle = 14;
	_this.background="Texture/kidui/middle/terrain/btn_h3.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.Flatten();";
	
	_this=ParaUI.CreateUIObject("button","kidui_t_height5_btn","_lt",85,0,32,32);
	_parent:AddChild(_this);
	_this.tooltip=L"Raise terrain";
	_this.animstyle = 12;
	_this.background="Texture/kidui/middle/terrain/btn_h5.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.GaussianHill(1);";
	
	left = left+width+10;
	width = 32;
	_this=ParaUI.CreateUIObject("button","b","_lt",left,top+25,width,width);
	_parterrain:AddChild(_this);
	_this.tooltip=L"Reset";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.Reset_TerrainMod();";
	_this.background="Texture/kidui/middle/terrain/btn_reset.png";
	left=left+width+5;
	
	_this=ParaUI.CreateUIObject("button","b","_lt",left,top+25,width,width);
	_parterrain:AddChild(_this);
	_this.tooltip=L"smooth";
	_this.background="Texture/kidui/middle/terrain/btn_pinghua.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.Roughen_Smooth(false);";
	left=left+width+5;
	
	_this=ParaUI.CreateUIObject("button","b","_lt",left,top+25,width,width);
	_parterrain:AddChild(_this);
	_this.tooltip=L"Roughen";
	_this.background="Texture/kidui/middle/terrain/btn_ruihua.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.Roughen_Smooth(true);";
	left=left+width+10;
	
	-- terrain brush range
	width = 128;
	_this=ParaUI.CreateUIObject("container","kidui_t_brush_cont","_lt",left,top+16,width,64);
	_parterrain:AddChild(_this);
	_this.background=L"Texture/kidui/middle/terrain/btn_range_bg1.png";
	_parent = _this;
	
	_this=ParaUI.CreateUIObject("button","kidui_t_range1_btn","_lt",5,2,32,32);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_range1.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSetTerrainBrushSize(15);";
	
	_this=ParaUI.CreateUIObject("button","kidui_t_range2_btn","_lt",40,4,32,32);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_range2.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSetTerrainBrushSize(20);";
	
	_this=ParaUI.CreateUIObject("button","kidui_t_range3_btn","_lt",77,5,32,32);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_range3.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSetTerrainBrushSize(30);";
	
	_this=ParaUI.CreateUIObject("editbox","kidui_t_range_editbox","_lt",9,39,40,22);
	_parent:AddChild(_this);
	_this.text="15";
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this.onchange=";CommonCtrl.CKidMiddleContainer.OnSetCustomTerrainBrushSize();";
	
	CommonCtrl.CKidMiddleContainer.OnSetTerrainBrushSize();
	
	-- terrain texture paints
	left,top=0,80;
	width = 60;
	_this=ParaUI.CreateUIObject("text","static","_lt",left,top+15,width,25);
	_parterrain:AddChild(_this);
	_this.text=L"Texture:";
	
	left = left+width;
	width = 50;
	_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top+15,width, 32);
	_parterrain:AddChild(_this);
	_this.text = L"base";
	_this.tooltip=L"Left click to paint\nRight click to erase";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnTerrainTexturePaint();";
	
	left = left+width+5;
	width = 16;
	_this=ParaUI.CreateUIObject("button","kidui_t_leftarr_btn","_lt",left,top+15,width,32);
	_parterrain:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/left_arr.png";
	--_this.tooltip = "上一页";
	_this.onclick=[[;local ctl = CommonCtrl.GetControl("KidUI_t_texture");if(ctl~=nil) then ctl:PageUp();end]];
	
	left=left+width+5;
	width = 48;

	-- load the terrain paint texture list for this version.
	TerrainEditorUI.LoadTextureList(self.terrainTexList);
	
	local ctl = CommonCtrl.CCtrlItemList:new{
		name = "KidUI_t_texture",
		parent = _parterrain,
		left = left, top = top+8, 
		spacing = 2,
		columncount=3,
		width= (width+2)*3+2;
		height= width+4;
		items=TerrainEditorUI.textures,
		btnpool={},
		rowcount=1,
		tooltip = L"Left click to paint\nRight click to erase",
		placeholder="Texture/kidui/common/item_bg.png";
		onclick = CommonCtrl.CKidMiddleContainer.OnTerrainTexturePaint,
	};
	ctl:Show();
	left=left+ctl.width+5;
	
	width = 16;
	_this=ParaUI.CreateUIObject("button","kidui_t_rightarr_btn","_lt",left,top+15,16,32);
	_parterrain:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/right_arr.png";
	--_this.tooltip = "下一页";
	_this.onclick=[[;local ctl = CommonCtrl.GetControl("KidUI_t_texture");if(ctl~=nil) then ctl:PageDown();end]];
	left=left+width+21;
		
	-- terrain texture brush range
	width = 128;
	_this=ParaUI.CreateUIObject("container","kidui_t_brush_cont","_lt",left,top,width,64);
	_parterrain:AddChild(_this);
	_this.background=L"Texture/kidui/middle/terrain/btn_range_bg2.png";
	_parent = _this;
	
	_this=ParaUI.CreateUIObject("button","kidui_t_tex_range1_btn","_lt",5,1,32,32);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_range1.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSetTextureBrushSize(1);";
	
	_this=ParaUI.CreateUIObject("button","kidui_t_tex_range2_btn","_lt",40,3,32,32);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_range2.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSetTextureBrushSize(2);";
	
	_this=ParaUI.CreateUIObject("button","kidui_t_tex_range3_btn","_lt",77,4,32,32);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/terrain/btn_range3.png";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSetTextureBrushSize(3);";
	
	_this=ParaUI.CreateUIObject("editbox","kidui_t_tex_range_editbox","_lt", 10,35,40,22);
	_parent:AddChild(_this);
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this.onchange=";CommonCtrl.CKidMiddleContainer.OnSetCustomTextureBrushSize();";
	
	-- update the default
	CommonCtrl.CKidMiddleContainer.OnSetTextureBrushSize();


--property character
	_parproperty=ParaUI.CreateUIObject("container","kidui_property_char_container","_mb",ToLeft,ToBottom,ToRight, MidHeight);
	_parproperty:AttachToRoot();
	_parproperty.background="Texture/whitedot.png;0 0 0 0";
	_parproperty.visible=false;
	
	local char_type	= self.char_type;
	char_type_buttons = self.char_type_buttons;
	
	-- section1
	left,top,width,height = 10, 0, 60, 30; 
	_this=ParaUI.CreateUIObject("text","static","_lt",left,top,width,height);
	_parproperty:AddChild(_this);
	_this.text=L"Name";
	left = left+width;
	
	width = 145;
	_this=ParaUI.CreateUIObject("imeeditbox","kidui_property_charname","_lt",left,top+3,width,height-3);
	_parproperty:AddChild(_this);
	_this.background="Texture/kidui/main/bg_266X48.png";
	left = left+width+5;
	
	width = 100;
	_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top,width,height);
	_parproperty:AddChild(_this);
	_this.text = L"change";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnChangeCharacterName();";
	left = left+width+5;
	
	_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top,width,height);
	_parproperty:AddChild(_this);
	_this.text = L"appearance";
	_this.tooltip = L"change appearance or skin";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnChangeCharacterSkin();";
	left = left+width+20;
	
	width = 32;
	_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top,width,width);
	_parproperty:AddChild(_this);
	_this.background="Texture/kidui/right/btn_save.png";
	_this.tooltip = L"save to disk";
	_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSaveCharacterProperty();";
	
	-- section2
	left,top,btn_width  = 10, 35, 80; 
	_this=ParaUI.CreateUIObject("text","static","_lt",left,top,60,25);
	_parproperty:AddChild(_this);
	_this.text=L"I am";
	left = left+60;
	
	for i=1, table.getn(char_type) do
		local item = char_type[i];
		char_type_buttons[i] = "kidui_AItype_btn"..i;
		_this=ParaUI.CreateUIObject("button",char_type_buttons[i],"_lt",left,top,btn_width,height);
		_parproperty:AddChild(_this);
		_this.text = item.text;
		_this.tooltip = item.tooltip;
		_this.background = item.bg;
		_this.onclick=string.format([[;CommonCtrl.CKidMiddleContainer.OnChangeCharacterType(%d);]], i);
		left = left+btn_width+5;
	end
		
	-- section3
	left,top, btn_width =10,70,64;
	
	_this=ParaUI.CreateUIObject("text","static","_lt",left,top,60,25);
	_parproperty:AddChild(_this);
	_this.text=L"behavior";
	left = left+60;
	
	-- create the NPC_behavior_cont
	local ai_buttons = self.ai_buttons;
	_parent=ParaUI.CreateUIObject("container","NPC_behavior_cont","_mt",left,top,0, 80);
	_parent.background="Texture/whitedot.png;0 0 0 0";
	_parproperty:AddChild(_parent);
	left,top = 0,0;
	
	for i=1, table.getn(ai_buttons) do
		local item = ai_buttons[i];
		_this=ParaUI.CreateUIObject("button","kidui_AI_btn"..i,"_lt",left,top,btn_width,btn_width);
		_parent:AddChild(_this);
		_this.tooltip = item.text;
		_this.background = item.bg;
		_this.onclick=string.format([[;CommonCtrl.CKidMiddleContainer.OnAssignAIClick(%d);]], i);
		left = left+btn_width+5;
	end
	
	-- create actor behavior container.
	local ctl = CommonCtrl.ActorMovieCtrl:new{
		-- normal window size
		alignment = "_mt",
		left = 70,
		top = 70,
		width = 0,
		height = 90,
		-- parent UI object, nil will attach to root.
		parent = _parproperty,
		-- the top level control name
		name = "Actor_behavior_cont",
	}
	ctl:Show();

	--TODO: add property control
--property model
	ToBottom,MidHeight = 5, 170;
	_parproperty=ParaUI.CreateUIObject("container","kidui_property_model_container","_mb",ToLeft,ToBottom,ToRight, MidHeight);
	_parproperty:AttachToRoot();
	_parproperty.background="Texture/whitedot.png;0 0 0 0";
	_parproperty.visible=false;	
	
	-- kidui_property_model_Texture_replace
	_this = ParaUI.CreateUIObject("container", "kidui_property_model_Texture_replace", "_fi", 0, 0, 0, 0)
	_this.background="Texture/whitedot.png;0 0 0 0";
	_parproperty:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "label5", "_lt", 266, 0, 130, 16)
	_this.text = L"Random images:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "kidsui_mid_model_replaceTex_candidate1", "_lt", 269, 28, 66, 58)
	_this.animstyle = 11;
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnClickRandomReplaceTexture(1);";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "kidsui_mid_model_replaceTex_candidate2", "_lt", 340, 28, 66, 58)
	_this.animstyle = 11;
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnClickRandomReplaceTexture(2);";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "kidsui_mid_model_replaceTex_candidate3", "_lt", 412, 28, 66, 58)
	_this.animstyle = 11;
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnClickRandomReplaceTexture(3);";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "kidsui_mid_model_replaceTex_ads", "_lt", 269, 92, 209, 68)
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnClickRandomReplaceTexture(0);";
	_this.animstyle = 11;
	_parent:AddChild(_this);

	-- display some random images
	CommonCtrl.CKidMiddleContainer.UpdateRandomModelTextureList();
	
	-- Canvas
	_this = ParaUI.CreateUIObject("button", "kidui_p_m_painter", "_lt", 34, 9, 160, 160)
	_this.background="Texture/whitedot.png;0 0 0 0";
	_guihelper.SetUIColor(_this, "255 255 255");
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container", "MPP_Canvas", "_lt", 12, 0, 200, 170)
	_parent:AddChild(_this);
	_this.background="Texture/kidui/middle/painter/replace_tex_bg.png";
	_parent = _this;
	
	_this = ParaUI.CreateUIObject("button", "button10", "_lt", 162, 62, 36, 36)
	_this.tooltip = L"Reset image";
	_this.animstyle = 12;
	_this.background="Texture/kidui/middle/painter/resetreplaceTex.png";
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnUndoModelTexture();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "button11", "_lt", 162, 98, 36, 36)
	_this.tooltip = L"Draw by myself";
	_this.animstyle = 12;
	_this.background="Texture/kidui/middle/painter/selfdraw.png";
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnEditModelTexture();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "button17", "_lt", 162, 135, 30, 30)
	_this.tooltip = L"Open file...";
	_this.animstyle = 12;
	_this.background="Texture/kidui/middle/painter/openfile.png";
	_this.onclick = ";CommonCtrl.CKidMiddleContainer.OnOpenFileForModelTexture();";
	_parent:AddChild(_this);
	

-- BCS Main menu
	--ToLeft;
	--ToBottom;
	ToRight = 560;
	--MidHeight;
	
	_BCSMainMenu=ParaUI.CreateUIObject("container","kidui_bcs_container","_lb",ToLeft,-ToBottom-MidHeight,ToRight, MidHeight);
	_BCSMainMenu:AttachToRoot();
	_BCSMainMenu.background="Texture/whitedot.png;0 0 0 0";
	_BCSMainMenu.visible=false;
	
	
	_BCSIcon=ParaUI.CreateUIObject("container","kidui_bcs_sub_container","_fi",0,0,0,0);
	_BCSMainMenu:AddChild(_BCSIcon);
	_BCSIcon.background="Texture/whitedot.png;0 0 0 0";
	
-- Ordinary character model menu
	
	_characterMenu=ParaUI.CreateUIObject("container","kidui_character_container","_lb",ToLeft,-ToBottom-MidHeight,ToRight, MidHeight);
	_characterMenu:AttachToRoot();
	_characterMenu.background="Texture/whitedot.png;0 0 0 0";
	_characterMenu.visible=false;
	
	
	_characterIcon=ParaUI.CreateUIObject("container","kidui_character_sub_container","_fi",0,0,0,0);
	_characterMenu:AddChild(_characterIcon);
	_characterIcon.background="Texture/whitedot.png;0 0 0 0";
	
-- CCS Main menu

	--ToLeft;
	--ToBottom;
	ToRight = 560;
	--MidHeight;

	_CCSMainMenu=ParaUI.CreateUIObject("container","kidui_ccs_container","_lb",ToLeft,-ToBottom-MidHeight,ToRight, MidHeight);
	_CCSMainMenu:AttachToRoot();
	_CCSMainMenu.background="Texture/whitedot.png;0 0 0 0";
	_CCSMainMenu.visible=false;
	
	_parent = _CCSMainMenu;
	
	CCS_main.ToLeft = ToLeft;
	CCS_main.ToBottom = ToBottom;
	CCS_main.ToRight = ToRight;
	CCS_main.MidHeight = MidHeight;


	if(KidsMovie_FunctionSet_CCS == true) then

		_this = ParaUI.CreateUIObject("container","kidui_ccs_level0_container","_lt",0,0,ToRight,MidHeight)
		_this.background="";
		_parent:AddChild(_this);

		_parent = _this;


		_this = ParaUI.CreateUIObject("button", "btnMain1", "_lt", 0, 6, 48, 48)
		_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_Toggle_FaceType.png", 
			"Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png");
		--_this.text = "C";
		_this.animstyle = 11;
		_this.onclick = ";CommonCtrl.CKidMiddleContainer.ToggleFace();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain2", "_lt", 48, 6, 48, 48)
		_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_FaceType_Icon.png", 
			"Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png");
		_this.onclick = ";CommonCtrl.CKidMiddleContainer.FaceClick();";
		--_this.onclick = ";CommonCtrl.CKidMiddleContainer.ShowCCSMenu(\"CartoonFace\");";
		--_this.text = "I";
		_this.animstyle = 11;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain3", "_lt", 96, 6, 48, 48)
		_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_Inventory_Icon.png", 
			"Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png");
		--_this.text = "FaceType";
		_this.animstyle = 11;
		_this.onclick = ";CommonCtrl.CKidMiddleContainer.ShowCCSMenu(\"Inventory\");";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain4", "_lt", 0, 54, 48, 48)
		_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_HairStyle_Icon.png", 
			"Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png");
		--_this.text = "HairStyle";
		_this.animstyle = 11;
		_this.onclick = ";CommonCtrl.CKidMiddleContainer.NextHairStyle();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain5", "_lt", 48, 54, 48, 48)
		_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_HairColor_Icon.png", 
			"Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png");
		--_this.text = "HairColor";
		_this.animstyle = 11;
		_this.onclick = ";CommonCtrl.CKidMiddleContainer.NextHairColor();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain6", "_lt", 96, 54, 48, 48)
		--_this.text = "6";
		_this.background="Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain7", "_lt", 0, 102, 48, 48)
		--_this.text = "7";
		_this.background="Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain8", "_lt", 48, 102, 48, 48)
		--_this.text = "8";
		_this.background="Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMain9", "_lt", 96, 102, 48, 48)
		--_this.text = "9";
		_this.background="Texture/kidui/CCS/btn_CCS_EmptySlot_Icon.png";
		_parent:AddChild(_this);


		_this = ParaUI.CreateUIObject("text", "labelRace", "_lt", 165, 23, 88, 16)
		_this.text = "种族:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelGender", "_lt", 165, 77, 104, 16)
		_this.text = "性别:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelHeight", "_lt", 165, 115, 104, 16)
		_this.text = "身高:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRaceHuman", "_lt", 222, 8, 48, 48)
		--_this.text = "H";
		_this.background="Texture/kidui/CCS/btn_CCS_Race_Human.png";
		_this.onclick=";CCS_main.UpdateCharacterInfo(\"HumanClick\");";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRaceChild", "_lt", 284, 8, 48, 48)
		--_this.text = "C";
		_this.background="Texture/kidui/CCS/btn_CCS_Race_Child.png;";
		_this.onclick=";CCS_main.UpdateCharacterInfo(\"ChildClick\");";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "buttonMale", "_lt", 238, 68, 32, 32)
		--_this.text = "M";
		_this.background="Texture/kidui/CCS/btn_CCS_Gender_Male.png";
		_this.onclick = ";CCS_main.UpdateCharacterInfo(\"MaleClick\");";
		--CCS_UI_Predefined.ResetBaseModel(\"character/v3/Child/\", \"Male\"); 
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "buttonFemale", "_lt", 284, 68, 32, 32)
		--_this.text = "F";
		_this.background="Texture/kidui/CCS/btn_CCS_Gender_Female.png";
		_this.onclick = ";CCS_main.UpdateCharacterInfo(\"FemaleClick\");";
		--CCS_UI_Predefined.ResetBaseModel(\"character/v3/Child/\", \"Female\"); 
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnCharZoomIn", "_lt", 238, 106, 32, 32)
		--_this.text = "+";
		_this.background="Texture/kidui/CCS/btn_CCS_Height_Up.png";
		_this.onclick=";CommonCtrl.CKidMiddleContainer.OnMagnifyClick();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnCharZoomOut", "_lt", 284, 106, 32, 32)
		--_this.text = "-";
		_this.background="Texture/kidui/CCS/btn_CCS_Height_Down.png";
		_this.onclick=";CommonCtrl.CKidMiddleContainer.OnMinifyClick();";
		_parent:AddChild(_this);

	end

end


function CommonCtrl.CKidMiddleContainer.ShowCCSMenu(name)

	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			if(name == "CartoonFace") then
				CCS_main.ShowCartoonFace(true);
			elseif(name == "Inventory") then
				CCS_main.ShowInventory(true);
			end
			return;
		end
	end
	
	CCS_main.PleaseSelectRaceOrGender();
end


function CommonCtrl.CKidMiddleContainer.FaceClick()

	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			if(CCS_UI_Predefined.CurrentFaceType == "CartoonFace") then
				CommonCtrl.CKidMiddleContainer.ShowCCSMenu("CartoonFace");
			elseif(CCS_UI_Predefined.CurrentFaceType == "CharacterFace") then
				CCS_UI_Predefined.NextFaceType();
			end
			return;
		end
	end
	
	CCS_main.PleaseSelectRaceOrGender();
end

function CommonCtrl.CKidMiddleContainer.ToggleFace()


	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			CCS_UI_Predefined.ToggleFace();
			local button1 = ParaUI.GetUIObject("btnMain1");
			local button2 = ParaUI.GetUIObject("btnMain2");
			if(CCS_UI_Predefined.CurrentFaceType == "CartoonFace") then
				button1.background = "Texture/kidui/CCS/btn_Toggle_CartoonFace.png";
				button2.background = "Texture/kidui/CCS/btn_CCS_CartoonFace_Icon.png";
			elseif(CCS_UI_Predefined.CurrentFaceType == "CharacterFace") then
				button1.background = "Texture/kidui/CCS/btn_Toggle_FaceType.png";
				button2.background = "Texture/kidui/CCS/btn_CCS_FaceType_Icon.png";
				
			end
			return;
		end
	end
	
	CCS_main.PleaseSelectRaceOrGender();
end

				
function CommonCtrl.CKidMiddleContainer.NextHairColor()

	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			CCS_UI_Predefined.NextHairColor();
			return;
		end
	end
	
	CCS_main.PleaseSelectRaceOrGender();
end

function CommonCtrl.CKidMiddleContainer.NextHairStyle()

	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			CCS_UI_Predefined.NextHairStyle();
			return;
		end
	end

	CCS_main.PleaseSelectRaceOrGender();
end

-- call this function to randomly display some replaceable textures to be displayed at the model replaceable texture property panel
-- internally, it uses the current time as the random seed. 
function CommonCtrl.CKidMiddleContainer.UpdateRandomModelTextureList()
	-- for shared media file
	local candidates = {};
	local folder = L"Shared Media Folder";
	
	commonlib.SearchFiles(candidates, ParaIO.GetCurDirectory(0)..folder, {"*.png", "*.jpg", "*.dds"}, 0, 50, true);	
	
	local nItemCount = 3; -- how many items to pick
	local count = table.getn(candidates);
	local nOffset = 0;
	if(count>nItemCount ) then
		nOffset = math.mod( math.floor(ParaGlobal.random()*count), count);
		if((nOffset+nItemCount )>count) then
			nOffset = count-nItemCount ;
		end
	end	
	
	local i;
	for i=1,nItemCount  do
		local tmp = ParaUI.GetUIObject("kidsui_mid_model_replaceTex_candidate"..i);
		if(tmp:IsValid()) then
			if(not candidates[i+nOffset]) then
				tmp.background="Texture/whitedot.png;0 0 0 0";
				tmp.tooltip = "";
				tmp.visible = false;
			else
				local filepath = string.gsub(folder..candidates[i+nOffset], "\\", "/");
				tmp.tooltip = filepath;
				tmp.background = filepath;
				tmp.visible = true;
			end	
		end
	end
	
	-- for advertisement file
	local candidates = {};
	local folder = L"Advertisement Folder";
	commonlib.SearchFiles(candidates, ParaIO.GetCurDirectory(0)..folder, {"*.png", "*.jpg", "*.dds"}, 0, 50, true);	

	local count = table.getn(candidates);
	local nOffset = math.mod( math.floor(ParaGlobal.random()*count), count);
	
	local tmp = ParaUI.GetUIObject("kidsui_mid_model_replaceTex_ads");
	local i=1;
	if(tmp:IsValid()) then
		if(not candidates[i+nOffset]) then
			tmp.background="Texture/whitedot.png;0 0 0 0";
			tmp.tooltip = "";
			tmp.visible = false;
		else
			local filepath = string.gsub(folder..candidates[i+nOffset], "\\", "/");
			tmp.tooltip = filepath;
			tmp.background = filepath;
			tmp.visible = true;
		end	
	end
end

-- @param index: 0 stands for kidsui_mid_model_replaceTex_ads, 1-3 stands for kidsui_mid_model_replaceTex_candidate1-3
-- the texture is read from the tooltip attribute
function CommonCtrl.CKidMiddleContainer.OnClickRandomReplaceTexture(index)
	local controlname = "";
	if(index == 0) then
		controlname = "kidsui_mid_model_replaceTex_ads"
	else
		controlname = "kidsui_mid_model_replaceTex_candidate"..index;
	end
	local ctl = ParaUI.GetUIObject(controlname);
	if(ctl:IsValid()) then
		CommonCtrl.CKidMiddleContainer.OnOpenFileForModelTexture_imp(nil, ctl.tooltip);
	end	
end

function CommonCtrl.CKidMiddleContainer.OnOpenFileForModelTexture()
	local obj = ObjEditor.GetCurrentObj();
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		return
	end
	local initialFileName;
	if(not obj:GetDefaultReplaceableTexture(1):equals(curBG)) then
		initialFileName = curBG:GetKeyName();
	else	
		initialFileName = "";
	end
	
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-250,
		width = 512,
		height = 380,
		parent = nil,
		FileName = initialFileName,
		FileNamePassFilter = "http://.*", -- allow http texture, is it too dangerous here?
		fileextensions = L:GetTable("open file dialog: texture file extensions"),
		folderlinks = {
			{path = ParaWorld.GetWorldDirectory().."texture/", text = L"My work"},
			{path = L"Shared Media Folder", text = L"Media lib"},
			{path = L"Advertisement Folder", text = L"Advertisement"},
			{path = L"Internet Folder", text = L"Internet"},
		},
		onopen = CommonCtrl.CKidMiddleContainer.OnOpenFileForModelTexture_imp,
	};
	ctl:Show(true);
end

function CommonCtrl.CKidMiddleContainer.OnOpenFileForModelTexture_imp(sCtrlName, filename)
	local obj = ObjEditor.GetCurrentObj();
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		return
	end
	
	if(filename == "") then
		-- reset texture
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(not defaultBG:equals(curBG)) then
			obj:SetReplaceableTexture(1, defaultBG);
			CKidMiddleContainer.OnUpdateModelPropertyUI(obj);
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
		end
	else
		-- apply the texture
		local Texture = ParaAsset.LoadTexture("",filename,1);
		if(Texture:IsValid() and not Texture:equals(curBG)) then
			obj:SetReplaceableTexture(1, Texture);
			CKidMiddleContainer.OnUpdateModelPropertyUI(obj);
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
		end
	end
end

function CommonCtrl.CKidMiddleContainer.IsMovieControlVisible()
	local self = CommonCtrl.GetControl("kidmiddlecontainer");
	if(self.state=="property")then
		if(self.currentCharType == 3)then
			return true;
		end
	end
	return false;
end

-- called when player type is changed.
function CommonCtrl.CKidMiddleContainer.OnChangeCharacterType(nIndex)
	local self = CommonCtrl.GetControl("kidmiddlecontainer");
	if(self == nil or self.currentCharType == nIndex) then
		return 
	end
	
	local player = ObjEditor.GetCurrentObj();
	if(player==nil or player:IsCharacter() == false) then
		_guihelper.MessageBox(L"only character can be given a type");
		return;
	end
	local typeItem = CommonCtrl.CKidMiddleContainer.char_type[nIndex];
	
	local playerChar = player:ToCharacter();
	
	local LastIndex = table.getn(CommonCtrl.CKidMiddleContainer.char_type);
	if(nIndex < LastIndex) then
		headon_speech.Speek(player.name,L"I become a "..typeItem.text, 2);
		local att = player:GetAttributeObject();
		att:SetField("GroupID", typeItem.GroupID);
		att:SetField("SentientField", typeItem.SentientField);
		if(nIndex == 1) then --player
			player:MakeGlobal(true);
			--player:SetPersistent(false);
			playerChar:AssignAIController("face", "false");
			playerChar:AssignAIController("follow", "false");
			playerChar:AssignAIController("movie", "false");
			playerChar:AssignAIController("sequence", "false");
			att:SetField("OnLoadScript", "");
			att:SetField("On_Perception", "");
			att:SetField("On_FrameMove", "");
			att:SetField("On_EnterSentientArea", "");
			att:SetField("On_LeaveSentientArea", "");
			att:SetField("On_Click", "");			
		elseif(nIndex == 2) then --NPC
			player:MakeGlobal(true);
			--player:SetPersistent(true);
			
		elseif(nIndex == 3) then --actor
			player:MakeGlobal(true);
			--player:SetPersistent(true);
			playerChar:AssignAIController("movie", "false");
			att:SetField("OnLoadScript", "");
			att:SetField("On_Perception", "");
			att:SetField("On_FrameMove", "");
			att:SetField("On_EnterSentientArea", "");
			att:SetField("On_LeaveSentientArea", "");
			att:SetField("On_Click", "");
		
		elseif(nIndex == 4) then --static
			if(ParaScene.GetPlayer():equals(player)==false ) then
				player:MakeGlobal(false);
			else
				_guihelper.MessageBox(L"I can not be changed to a dummy completely, since you are controlling me now.");
			end
			
			--player:SetPersistent(true);
			playerChar:AssignAIController("follow", "false");
			playerChar:AssignAIController("movie", "false");
			playerChar:AssignAIController("sequence", "false");
			att:SetField("OnLoadScript", "");
			att:SetField("On_Perception", "");
			att:SetField("On_FrameMove", "");
			att:SetField("On_EnterSentientArea", "");
			att:SetField("On_LeaveSentientArea", "");
			att:SetField("On_Click", "");
		end
	elseif(nIndex == LastIndex) then
		headon_speech.Speek(player.name, L"Custom character is not available now.", 2);	
	end
	CommonCtrl.CKidMiddleContainer.OnUpdateCharacterTypeUI();
end

-- update the player type UI according to the current type of the character. 
function CommonCtrl.CKidMiddleContainer.OnUpdateCharacterTypeUI()
	local player = ObjEditor.GetCurrentObj();
	if(player~=nil and player:IsCharacter() == true) then
		local self = CommonCtrl.GetControl("kidmiddlecontainer");
		if(self==nil)then
			log("err getting control kidmiddlecontainer\r\n");
			return;
		end
		
		local att = player:GetAttributeObject();
		local GroupID = att:GetField("GroupID", 0);
		local SentientField = att:GetField("SentientField", 0);
		--log(GroupID..", "..SentientField.."--my type\r\n" );
		local char_type = CommonCtrl.CKidMiddleContainer.char_type;
		local i;
		local selectedID = table.getn(char_type);
		for i=1, table.getn(char_type) do
			local item = char_type[i];
			--log(i..": "..item.GroupID..", "..item.SentientField.."--my type\r\n" );
			if(item.GroupID == GroupID and item.SentientField == SentientField) then
				selectedID = i;
				break;
			end
		end
		self.currentCharType = selectedID;
		
		_guihelper.CheckRadioButtons(CommonCtrl.CKidMiddleContainer.char_type_buttons, CommonCtrl.CKidMiddleContainer.char_type_buttons[selectedID], "255 0 0");
		
		-- only make the given behavior container visible.
		local SelectedItem = char_type[selectedID];
		for i=1, table.getn(CommonCtrl.CKidMiddleContainer.behaviorContList) do
			local item = CommonCtrl.CKidMiddleContainer.behaviorContList[i];
			local temp = ParaUI.GetUIObject(item);
			if(temp:IsValid()==true) then
				if(SelectedItem.container == item) then
					temp.visible = true;
				else
					temp.visible = false;
				end
			end	
		end
	end	
end

-- called when one of the AI buttons is clicked. 
function CommonCtrl.CKidMiddleContainer.OnAssignAIClick(nIndex)
	ParaAudio.PlayUISound("Btn4");
	local player = ObjEditor.GetCurrentObj();
	if(player==nil or player:IsCharacter() == false) then
		_guihelper.MessageBox(L"Only character can have behaviors.");
		return;
	end
	local playerChar = player:ToCharacter();
	local att = player:GetAttributeObject();
	if(nIndex == 1) then
		--local sText = headon_speech.GetLastSpeechOfChar(player.name); -- using the last spoken text
		--_AI.DoPlayerTextCommand(player, sText);
		NPL.load("(gl)script/kids/Ui/SimpleNPCTalkEditor.lua");
		SimpleNPCTalkEditor.Show(true);
	elseif(nIndex == 2) then
		headon_speech.Speek(player.name, L"Let me wander near here.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", "");
		att:SetField("On_FrameMove", [[;NPL.load("(gl)script/AI/templates/RandomWalker.lua");_AI_templates.RandomWalker.On_FrameMove();]]);
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");
	elseif(nIndex == 3) then
		headon_speech.Speek(player.name, L"I am a piggy now.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", [[;NPL.load("(gl)script/AI/templates/SimpleFollow.lua");_AI_templates.SimpleFollow.On_Perception();]]);
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");
	elseif(nIndex == 4) then
		headon_speech.Speek(player.name, L"I am a shopkeeper", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/ShopKeeper.lua");_AI_templates.ShopKeeper.On_Load();]]);
		att:SetField("On_Perception", [[;NPL.load("(gl)script/AI/templates/ShopKeeper.lua");_AI_templates.ShopKeeper.On_Perception();]]);
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", [[;NPL.load("(gl)script/AI/templates/ShopKeeper.lua");_AI_templates.ShopKeeper.On_Click();]]);
	elseif(nIndex == 5) then
		headon_speech.Speek(player.name, L"I want to sell.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/GreenGrocer.lua");_AI_templates.GreenGrocer.On_Load();]]);
		att:SetField("On_Perception", [[;NPL.load("(gl)script/AI/templates/GreenGrocer.lua");_AI_templates.GreenGrocer.On_Perception();]]);
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", [[;NPL.load("(gl)script/AI/templates/GreenGrocer.lua");_AI_templates.GreenGrocer.On_Click();]]);
	elseif(nIndex == 6) then
		headon_speech.Speek(player.name, L"Ah, I am a dummy now.", 2);
		playerChar:Stop();
		playerChar:AssignAIController("face", "false");
		playerChar:AssignAIController("follow", "false");
		playerChar:AssignAIController("movie", "false");
		playerChar:AssignAIController("sequence", "false");
		att:SetField("OnLoadScript", "");
		att:SetField("On_Perception", "");
		att:SetField("On_FrameMove", "");
		att:SetField("On_EnterSentientArea", "");
		att:SetField("On_LeaveSentientArea", "");
		att:SetField("On_Click", "");
	--elseif(nIndex == 7) then
		--headon_speech.Speek(player.name, "我来给大家讲笑话...", 2);
		--playerChar:Stop();
		--att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/JokeTeller.lua");_AI_templates.JokeTeller.On_Load();]]);
		--att:SetField("On_EnterSentientArea", [[;NPL.load("(gl)script/AI/templates/JokeTeller.lua");_AI_templates.JokeTeller.On_EnterSentientArea();]]);
		--att:SetField("On_LeaveSentientArea", [[;NPL.load("(gl)script/AI/templates/JokeTeller.lua");_AI_templates.JokeTeller.On_LeaveSentientArea();]]);
	--elseif(nIndex == 8) then
		--headon_speech.Speek(player.name, "我来给大家讲鬼故事...", 2);
		--playerChar:Stop();
		--att:SetField("OnLoadScript", [[;NPL.load("(gl)script/AI/templates/GhostStoryTeller.lua");_AI_templates.GhostStoryTeller.On_Load();]]);
		--att:SetField("On_EnterSentientArea", [[;NPL.load("(gl)script/AI/templates/GhostStoryTeller.lua");_AI_templates.GhostStoryTeller.On_EnterSentientArea();]]);
		--att:SetField("On_LeaveSentientArea", [[;NPL.load("(gl)script/AI/templates/GhostStoryTeller.lua");_AI_templates.GhostStoryTeller.On_LeaveSentientArea();]]);
	end
	
end

-- Event handler: on object translation
function CKidMiddleContainer.OnTranslationClick()
	ParaAudio.PlayUISound("Btn5");
	if(not kids_db.User.CheckRight("Edit")) then return end
	
	local temp = ParaUI.GetUIObject(sensor_name);
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		--_guihelper.MessageBox("clicked "..x..","..y.."\r\n");
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-16)^2+(y-36)^2; --1
		dist2 = (x-14)^2+(y-90)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-64)^2+(y-114)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-113)^2+(y-91)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-113)^2+(y-35)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-64)^2+(y-14)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		
		local pos = {x=0,y=0,z=0};
		if(nSel==1) then
			pos.x = -0.1732;
			pos.z = 0.1;
			--ObjEditor.MoveCurrentObj(-0.2,0,0); -- 左移
			--ObjEditor.MoveCurrentObj(-0.1732,0,0.1); -- 左移
		elseif(nSel==2) then
			pos.x = -0.1732;
			pos.z = -0.1;
			--ObjEditor.MoveCurrentObj(0,0,-0.2); -- 移近
			--ObjEditor.MoveCurrentObj(-0.1732,0,-0.1); -- 移近
		elseif(nSel==3) then
			pos.y = -0.2;
			--ObjEditor.MoveCurrentObj(0,-0.2,0); -- 下移
		elseif(nSel==4) then
			pos.x = 0.1732;
			pos.z = -0.1;
			--ObjEditor.MoveCurrentObj(0.2,0,0); -- 右移
			--ObjEditor.MoveCurrentObj(0.1732,0,-0.1); -- 右移
		elseif(nSel==5) then
			pos.x = 0.1732;
			pos.z = 0.1;
			--ObjEditor.MoveCurrentObj(0,0,0.2); -- 移远
			--ObjEditor.MoveCurrentObj(0.1732,0,0.1); -- 移远
		elseif(nSel==6) then
			pos.y = 0.2;
			--ObjEditor.MoveCurrentObj(0,0.2,0); -- 上移
		end
		
		local obj = ObjEditor.GetCurrentObj();
		if(obj==nil or obj:IsValid()==false) then 
			return
		end
		
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0) then
			-- this is a standalone computer
			ObjEditor.MoveCurrentObj(pos.x,pos.y,pos.z);
		elseif(nServerState == 1) then
			-- this is a server. 
			local x,y,z = obj:GetPosition();
			pos.x, pos.y, pos.z = ObjEditor.CameraToWorldSpace(pos.x, pos.y, pos.z);
			pos.x = pos.x + x;
			pos.y = pos.y + y;
			pos.z = pos.z + z;
			server.BroadcastObjectModification(obj, pos, nil, nil);
		elseif(nServerState == 2) then
			-- this is a client. 
			local x,y,z = obj:GetPosition();
			pos.x, pos.y, pos.z = ObjEditor.CameraToWorldSpace(pos.x, pos.y, pos.z);
			pos.x = pos.x + x;
			pos.y = pos.y + y;
			pos.z = pos.z + z;
			client.RequestObjectModification(obj, pos, nil, nil);
		end	
	end
	
end

-- Event handler: on object rotation
function CKidMiddleContainer.OnRotationClick()
	ParaAudio.PlayUISound("Btn5");
	if(not kids_db.User.CheckRight("Edit")) then return end
	
	local temp = ParaUI.GetUIObject(sensor_name);
	if(temp:IsValid()==true) then 
		local x,y = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		-- _guihelper.MessageBox("clicked "..x..","..y.."\r\n");
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-28)^2+(y-21)^2; --1
		dist2 = (x-12)^2+(y-79)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-30)^2+(y-112)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-69)^2+(y-110)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-112)^2+(y-54)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-94)^2+(y-17)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		local angledelta = 0.104719753
		local rot = {x=0,y=0,z=0};
		if(nSel==1) then
			rot.z=angledelta; -- z pos
		elseif(nSel==2) then
			rot.y = angledelta; -- Y pos
		elseif(nSel==3) then
			rot.x = -angledelta; -- x neg
		elseif(nSel==4) then
			rot.z = -angledelta; -- z neg
		elseif(nSel==5) then
			rot.y = -angledelta; -- Y neg
		elseif(nSel==6) then
			rot.x = angledelta; -- x pos
		end

		local obj = ObjEditor.GetCurrentObj();
		if(obj==nil or obj:IsValid()==false) then 
			return
		end
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0 or obj:IsCharacter()==true) then
			-- this is a standalone computer
			ObjEditor.RotateCurrentObj(rot.x,rot.y,rot.z);	
		elseif(nServerState == 1) then
			-- this is a server. 
			local oldquat = obj:GetRotation({});
			obj:Rotate(rot.x,rot.y,rot.z);
			local quat = obj:GetRotation({});
			obj:SetRotation(oldquat);
			server.BroadcastObjectModification(obj, nil, nil, quat);
		elseif(nServerState == 2) then
			-- this is a client. 
			local oldquat = obj:GetRotation({});
			obj:Rotate(rot.x,rot.y,rot.z);
			local quat = obj:GetRotation({});
			obj:SetRotation(oldquat);
			client.RequestObjectModification(obj, nil, nil, quat);
		end		
	end
end

function CKidMiddleContainer.OnMinifyClick()
	ParaAudio.PlayUISound("Btn5");
	if(not kids_db.User.CheckRight("Edit")) then return end
	
	local obj = ObjEditor.GetCurrentObj();
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0 or obj:IsCharacter()==true) then
		-- this is a standalone computer
		ObjEditor.ScaleCurrentObj(0.9);
	elseif(nServerState == 1) then
		-- this is a server. 
		local s = obj:GetScale();
		server.BroadcastObjectModification(obj, nil, s*0.9, nil);
	elseif(nServerState == 2) then
		-- this is a client. 
		local s = obj:GetScale();
		client.RequestObjectModification(obj, nil, s*0.9, nil);
	end
end

function CKidMiddleContainer.OnMagnifyClick()
	ParaAudio.PlayUISound("Btn5");
	if(not kids_db.User.CheckRight("Edit")) then return end
	local obj = ObjEditor.GetCurrentObj();
	if(obj==nil or obj:IsValid()==false) then 
		return
	end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0 or obj:IsCharacter()==true) then
		-- this is a standalone computer
		ObjEditor.ScaleCurrentObj(1.1);
	elseif(nServerState == 1) then
		-- this is a server. 
		local s = obj:GetScale();
		server.BroadcastObjectModification(obj, nil, s*1.1, nil);
	elseif(nServerState == 2) then
		-- this is a client. 
		local s = obj:GetScale();
		client.RequestObjectModification(obj, nil, s*1.1, nil);
	end
end

function CKidMiddleContainer.OnResetClick()
	ParaAudio.PlayUISound("Btn5");
	if(not kids_db.User.CheckRight("Edit")) then return end
	
	local obj = ObjEditor.GetCurrentObj();
	if(obj==nil or obj:IsValid()==false) then 
		return
	end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0 or obj:IsCharacter()==true) then
		-- this is a standalone computer
		ObjEditor.ResetCurrentObj();
	elseif(nServerState == 1) then
		-- this is a server. 
		server.BroadcastObjectModification(obj, nil, 1.0, {x=0, y=0,z=0,w=1});
	elseif(nServerState == 2) then
		-- this is a client. 
		client.RequestObjectModification(obj, nil, 1.0, {x=0, y=0,z=0,w=1});
	end
end

function CKidMiddleContainer.OnMoveHereClick()
	ParaAudio.PlayUISound("Btn5");
	if(not kids_db.User.CheckRight("Edit")) then return end
	local obj = ObjEditor.GetCurrentObj();
	if(obj==nil or obj:IsValid()==false) then 
		return
	end
	if(obj~=nil) then
		local x,y,z = obj:GetPosition();
		local player = ParaScene.GetObject("<player>");
		local px,py,pz = player:GetPosition();
		if(player:IsValid()==true) then
			local nServerState = ParaWorld.GetServerState();
			if(nServerState == 0 or obj:IsCharacter()==true) then
				-- this is a standalone computer
				ObjEditor.OffsetObj(obj, px-x,py-y,pz-z);
			elseif(nServerState == 1) then
				-- this is a server. 
				server.BroadcastObjectModification(obj, {x=px, y=py, z=pz}, nil,nil);
			elseif(nServerState == 2) then
				-- this is a client. 
				client.RequestObjectModification(obj, {x=px, y=py, z=pz}, nil,nil);
			end
		end
	end
end


--[[ user specified brush size]]
function CKidMiddleContainer.OnSetCustomTextureBrushSize()
	local tmp = ParaUI.GetUIObject("kidui_t_tex_range_editbox");
	if(tmp:IsValid()==true) then
		local nSize = tonumber(tmp.text);
		if(nSize~=nil and nSize>0.1 and nSize<100) then
			TerrainEditorUI.brush.radius = nSize;
		else
			_guihelper.MessageBox(L"the terrain brush size can only be within (0.1, 100)");
		end
	end
end

-- set the current terrain texture brush size and update the UI
-- @param nSize: if this is nil, the current brush size is used, if not the current brush size will be set accordingly
function CKidMiddleContainer.OnSetTextureBrushSize(nSize)
	ParaAudio.PlayUISound("Btn3");
	-- texture brush radius
	if(nSize~=nil) then
		TerrainEditorUI.brush.radius = nSize;
	else
		nSize = TerrainEditorUI.brush.radius;
	end
	
	radiobuttons = {"kidui_t_tex_range1_btn","kidui_t_tex_range2_btn","kidui_t_tex_range3_btn"};
	if(nSize<=1) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_tex_range1_btn", "255 0 0");
	elseif(nSize<=2) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_tex_range2_btn", "255 0 0");
	elseif(nSize>=3) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_tex_range3_btn", "255 0 0");
	end
	_guihelper.SafeSetText("kidui_t_tex_range_editbox", tostring(nSize));
end

--[[ called to paint textures on to the terrain surface]]
function CKidMiddleContainer.OnTerrainTexturePaint(nIndex)
	if(not kids_db.User.CheckRight("TerrainTexture")) then return end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0) then
		-- this is a standalone computer
		ParaAudio.PlayUISound("Btn1");
		TerrainEditorUI.Paint(nIndex);
	elseif(nServerState == 1) then
		-- this is a server. 
		server.BroadcastTerrainTexModify(TerrainEditorUI.PaintParam(nIndex));
	elseif(nServerState == 2) then
		-- this is a client. 
		client.RequestTerrainTexModify(TerrainEditorUI.PaintParam(nIndex));
	end
end

--[[ user specified brush size]]
function CKidMiddleContainer.OnSetCustomTerrainBrushSize()
	local tmp = ParaUI.GetUIObject("kidui_t_range_editbox");
	if(tmp:IsValid()==true) then
		local nSize = tonumber(tmp.text);
		if(nSize~=nil and nSize>=5 and nSize<=250) then
			TerrainEditorUI.elevModifier.radius = nSize;
		else
			_guihelper.MessageBox(L"the height field brush size can only be within (5, 250)");
		end
	end
end

function CKidMiddleContainer.Reset_TerrainMod()
	CommonCtrl.CKidMiddleContainer.OnSetTerrainBrushSize(20);
	CommonCtrl.CKidMiddleContainer.OnSetTextureBrushSize(2);
end

-- set the current terrain brush size and update the UI
-- @param nSize: if this is nil, the current brush size is used, if not the current brush size will be set accordingly
function CKidMiddleContainer.OnSetTerrainBrushSize(nSize)
	ParaAudio.PlayUISound("Btn3");
	-- texture brush radius
	if(nSize~=nil) then
		TerrainEditorUI.elevModifier.radius = nSize;
	else
		nSize = TerrainEditorUI.elevModifier.radius;
	end
	
	radiobuttons = {"kidui_t_range1_btn","kidui_t_range2_btn","kidui_t_range3_btn"};
	if(nSize<=15) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_range1_btn", "255 0 0");
	elseif(nSize<=25) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_range2_btn", "255 0 0");
	elseif(nSize>25) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_range3_btn", "255 0 0");
	end
	_guihelper.SafeSetText("kidui_t_range_editbox", tostring(nSize));
end

function CKidMiddleContainer.OnTextChange()
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		ParaAudio.PlayUISound("Btn4");
		CKidMiddleContainer.OnTextInput();
	end
end
-- called when user input some text
function CKidMiddleContainer.OnTextInput()
	local player = ParaScene.GetPlayer();
	if((player:IsGlobal() ==true) and (player:IsCharacter() == true)) then
		local tmp = ParaUI.GetUIObject("kidui_text_text");
		tmp:LostFocus();
		if(tmp:IsValid()==true) then
			if(tmp.text == "") then
				headon_speech.Speek(player.name, "...", 2);
			else
				local nServerState = ParaWorld.GetServerState();
				if(nServerState == 0) then
					-- standalone mode
					if(not ReleaseBuild) then
						-- if the input begins with >, the rest will be executed as a command.
						local nFrom,nTo,str = string.find(tmp.text,"^>(.*)$");
						if(str~=nil) then
							NPL.DoString(str);
							headon_speech.Speek(player.name, "executed code:\n"..str, 5,nil,nil,true); -- write to log 
							return
						end
					end	
					headon_speech.Speek(player.name, tmp.text, 5,nil,nil,true); -- write to log 
				elseif(nServerState == 1) then
					-- this is a server. 
					headon_speech.Speek(player.name, tmp.text, 5);
					server.BroadcastMessage(tmp.text,1);
				elseif(nServerState == 2) then
					-- this is a client. 
					client.SendChatMessage(tmp.text,1);
				end
			end
		end
	end
end

-- when user clicked the action button
function CKidMiddleContainer.OnTextAction()
	NPL.activate("(gl)script/demo/film/add_action.lua");
end

function CKidMiddleContainer.CMD_ShiftToClosestPlayer()
	ParaAudio.PlayUISound("Btn4");
	virtual_key = Event_Mapping.EM_KEY_LSHIFT
	KidsUI_OnKeyDownEvent()
end

function CKidMiddleContainer.CMD_TogglePlayer()
	ParaAudio.PlayUISound("Btn4");
	ParaScene.TogglePlayer();
end

function CKidMiddleContainer.CMD_LeaveMe()
end

function CKidMiddleContainer.CMD_FollowMe()
end

-- lead the player home, currently it only runs 30 meters and stop. 
function CKidMiddleContainer.CMD_WayHome()
	local player = ParaScene.GetPlayer();
	if((player:IsGlobal() ==true) and (player.name == kids_db.player.name)) then
		local px,py,pz = player:GetPosition();
		-- get last player location
		local db = ParaWorld.GetAttributeProvider();
		db:SetTableName("WorldInfo");
		local x,y,z;
		x = db:GetAttribute("PlayerX", px);
		y = db:GetAttribute("PlayerY", py);
		z = db:GetAttribute("PlayerZ", pz);
		
		x = x-px;
		z = z-pz;
		local length = math.sqrt(x*x+z*z);
		local radius = 30;
		if(length > radius) then
			--currently it only runs 30 meters and stop. 
			x = x/length*radius;
			z = z/length*radius;
			local s = player:ToCharacter():GetSeqController();
			s:RunTo(x,0,z);
			headon_speech.Speek(player.name, L"I will go home now.", 2);
		else
			headon_speech.Speek(player.name, L"I am already near my home.", 2);
		end
	else
		headon_speech.Speek(player.name, L"My home is right here.", 2);
	end
end

-- switch to the main player
function CKidMiddleContainer.CMD_SwithToPlayer()
	local player = ParaScene.GetPlayer();
	local MainPlayer = ParaScene.GetObject(kids_db.player.name);
	if(player:equals(MainPlayer) == true) then
		headon_speech.Speek(player.name, L"Donot you see me? I am here!", 2);
	else
		if(MainPlayer:IsValid()==true) then
			ParaCamera.FollowObject(MainPlayer);
		end
	end
end

-- change to the next skin
function CKidMiddleContainer.OnChangeCharacterSkin()
	local player = ObjEditor.GetCurrentObj();
	if((player~=nil) and (player:IsGlobal() ==true) and (player:IsCharacter() == true)) then
		local playerchar = player:ToCharacter();
		local LastSkin = playerchar:GetSkin();
		playerchar:SetSkin(LastSkin+1);
		if(playerchar:GetSkin() == LastSkin) then
			if(LastSkin ==0) then
				_guihelper.MessageBox(L"I can not change skin");
			else
				playerchar:SetSkin(0);--cycle to the first one. 
				if(playerchar:GetSkin() ~= 0) then
					playerchar:SetSkin(1); -- some character does not begin with index 0, try index 1 anyway.
				end
			end
		end
	end
end

-- called when the sky box need to be changed
function CKidMiddleContainer.OnChangeSkybox(nIndex)
	ParaAudio.PlayUISound("Btn4");
	if(not kids_db.User.CheckRight("Sky")) then return end
	local item = CKidMiddleContainer.skyboxes[nIndex];
	if(item ~= nil) then
		ParaScene.CreateSkyBox (item.name, ParaAsset.LoadStaticMesh ("", item.file), 160,160,160, 0);
	end
end

-- whenever the user pressed the change name button
function CKidMiddleContainer.OnChangeCharacterName()
	if(not kids_db.User.CheckRight("Save")) then return end
	local player = ObjEditor.GetCurrentObj();
	if(player~=nil)then
		local tmp = ParaUI.GetUIObject("kidui_property_charname");
		if(tmp:IsValid()==true) then
			if(player.name ~= tmp.text)then
				player.name = tmp.text;
				
				if(tmp.text ~= player.name) then
					tmp.text = player.name;
					_guihelper.MessageBox(L"rename failed: you can only change the name of a character, when you are not controlling it, and that the name should be identical.");
				end	
			end	
		end
	end	
end


function CKidMiddleContainer.OnSaveCharacterProperty()
	if(not kids_db.User.CheckRight("Save")) then return end
	local player = ObjEditor.GetCurrentObj();
	if((player~=nil) and (player:IsCharacter() == true))then
		if(player:IsPersistent()==true )then
			player:GetAttributeObject():CallField("Save");
			_guihelper.MessageBox(L"character has been saved");
		else
			_guihelper.MessageBox(L"I am not an NPC in this world, so I can not be saved.");
		end
	end
end

-- called when the sky color changes
function CKidMiddleContainer.OnSkyColorChanged()
	local ctl = CommonCtrl.GetControl("KidUI_s_skycolor");
	if(ctl~=nil) then
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0) then
			-- this is a standalone computer
			local att = ParaScene.GetAttributeObjectSky();
			if(att~=nil) then
				att:SetField("SkyColor", {ctl.r/255, ctl.g/255, ctl.b/255});
			end
		elseif(nServerState == 1) then
			-- this is a server. 
			--TODO: server.BroadcastOceanModify(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		elseif(nServerState == 2) then
			-- this is a client. 
			--TODO: client.RequestOceanModify(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		end
	end
end
-- update sky color UI based on the current ocean color
function CKidMiddleContainer.UpdateSkyColorUI()
	local ctl = CommonCtrl.GetControl("KidUI_s_skycolor");
	if(ctl~=nil) then
		local att = ParaScene.GetAttributeObjectSky();
		if(att~=nil) then
			local color = att:GetField("SkyColor", {1, 1, 1});
			ctl:SetRGB(color[1]*255, color[2]*255, color[3]*255);
		end
	end
end
-- called when the fog color changes
function CKidMiddleContainer.OnFogColorChanged()
	local ctl = CommonCtrl.GetControl("KidUI_s_fogcolor");
	if(ctl~=nil) then
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0) then
			-- this is a standalone computer
			local att = ParaScene.GetAttributeObject();
			if(att~=nil) then
				att:SetField("FogColor", {ctl.r/255, ctl.g/255, ctl.b/255});
			end
		elseif(nServerState == 1) then
			-- this is a server. 
			--TODO: server.BroadcastOceanModify(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		elseif(nServerState == 2) then
			-- this is a client. 
			--TODO: client.RequestOceanModify(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		end
	end
end
-- update fog color UI based on the current ocean color
function CKidMiddleContainer.UpdateFogColorUI()
	local ctl = CommonCtrl.GetControl("KidUI_s_fogcolor");
	if(ctl~=nil) then
		local att = ParaScene.GetAttributeObject();
		if(att~=nil) then
			local color = att:GetField("FogColor", {1, 1, 1});
			ctl:SetRGB(color[1]*255, color[2]*255, color[3]*255);
		end
	end
end

-- called when the ocean color changes
function CKidMiddleContainer.OnOceanColorChanged()
	local ctl = CommonCtrl.GetControl("KidUI_w_color");
	if(ctl~=nil) then
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0) then
			-- this is a standalone computer
			TerrainEditorUI.UpdateOcean(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		elseif(nServerState == 1) then
			-- this is a server. 
			server.BroadcastOceanModify(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		elseif(nServerState == 2) then
			-- this is a client. 
			client.RequestOceanModify(nil,nil,ctl.r/255, ctl.g/255, ctl.b/255);
		end
	end
end
-- update ocean color UI based on the current ocean color
function CKidMiddleContainer.UpdateOceanColorUI()
	local ctl = CommonCtrl.GetControl("KidUI_w_color");
	if(ctl~=nil) then
		local att = ParaScene.GetAttributeObjectOcean();
		if(att~=nil) then
			local color = att:GetField("OceanColor", {1, 1, 1});
			ctl:SetRGB(color[1]*255, color[2]*255, color[3]*255);
		end
	end
end

function CKidMiddleContainer.OnOceanLevelSliderBegin()
	local tmp = ParaUI.GetUIObject("kidui_w_level_slider");
	if(tmp:IsValid()==true) then
		CommonCtrl.CKidMiddleContainer.LastOceanSliderValue = tmp.value;
	end
end

function CKidMiddleContainer.OnOceanLevelSliderEnd()
	local tmp = ParaUI.GetUIObject("kidui_w_level_slider");
	if(tmp:IsValid()==true) then
		CommonCtrl.CKidMiddleContainer.LastOceanSliderValue = 50;
		tmp.value = 50;
	end
end

function CKidMiddleContainer.OnOceanLevelChanged()
	local tmp = ParaUI.GetUIObject("kidui_w_level_slider");
	if(tmp:IsValid()==true) then
		local delta = (tmp.value-CommonCtrl.CKidMiddleContainer.LastOceanSliderValue)*0.04; -- 2 centimeters per slider
		if(delta~=0) then
			-- this will allow the ocean level to increase faster when at the ends of the slider bar. 
			delta = delta*(math.abs(tmp.value-50)*0.3+1);
			TerrainEditorUI.WaterLevel(delta, true);
			CommonCtrl.CKidMiddleContainer.LastOceanSliderValue = tmp.value;
		end	
	end
end

function CKidMiddleContainer.GaussianHill(height)
	if(not kids_db.User.CheckRight("TerrainHeightmap")) then return end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0) then
		-- this is a standalone computer
		ParaAudio.PlayUISound("Btn5");
		TerrainEditorUI.GaussianHill(height);
	elseif(nServerState == 1) then
		-- this is a server. 
		TerrainEditorUI.GaussianHill(height);
		local x,y,z = TerrainEditorUI.GetPosition();
		if(not x)then return end
		server.BroadcastTerrainModify(x,y,z, TerrainEditorUI.elevModifier.radius);
	elseif(nServerState == 2) then
		-- this is a client. 
		local x,y,z = TerrainEditorUI.GetPosition();
		if(not x)then return end
		client.RequestTerrainModify(0, x,y,z,TerrainEditorUI.elevModifier.radius, height);
	end
end

function CKidMiddleContainer.Flatten()
	if(not kids_db.User.CheckRight("TerrainHeightmap")) then return end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0) then
		-- this is a standalone computer
		ParaAudio.PlayUISound("Btn5");
		TerrainEditorUI.Flatten();
	elseif(nServerState == 1) then
		-- this is a server. 
		TerrainEditorUI.Flatten();
		local x,y,z = TerrainEditorUI.GetPosition();
		if(not x)then return end
		server.BroadcastTerrainModify(x,y,z, TerrainEditorUI.elevModifier.radius);
	elseif(nServerState == 2) then
		-- this is a client. 
		local x,y,z = TerrainEditorUI.GetPosition();
		if(not x)then return end
		client.RequestTerrainModify(1, x,y,z,TerrainEditorUI.elevModifier.radius);
	end
end

function CKidMiddleContainer.Roughen_Smooth(bRoughen)	
	if(not kids_db.User.CheckRight("TerrainHeightmap")) then return end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0) then
		-- this is a standalone computer
		ParaAudio.PlayUISound("Btn5");
		TerrainEditorUI.Roughen_Smooth(bRoughen);
	elseif(nServerState == 1) then
		-- this is a server. 
		TerrainEditorUI.Roughen_Smooth(bRoughen);
		local x,y,z = TerrainEditorUI.GetPosition();
		if(not x)then return end
		server.BroadcastTerrainModify(x,y,z, TerrainEditorUI.elevModifier.radius);
	elseif(nServerState == 2) then
		-- this is a client. 
		local x,y,z = TerrainEditorUI.GetPosition();
		if(not x)then return end
		local cmd = 4;
		if(bRoughen == true) then
			cmd = 5;
		end
		client.RequestTerrainModify(cmd, x,y,z,TerrainEditorUI.elevModifier.radius);
	end
end

-- called whenever the model property must reflect a given model object
-- @param obj: the model object
function CKidMiddleContainer.OnUpdateModelPropertyUI(obj)
	if(obj:IsCharacter() == true) then
		return
	end
	local painter = ParaUI.GetUIObject("kidui_p_m_painter");
	if(painter:IsValid()==false) then
		return
	end
	-- get replaceable texture at ID=1
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		ParaUI.GetUIObject("kidui_property_model_Texture_replace").visible=false;
		painter.background="Texture/whitedot.png;0 0 0 0";
	else
		ParaUI.GetUIObject("kidui_property_model_Texture_replace").visible=true;
		local bg = curBG:GetKeyName();
		painter.background=bg;
		--painter.tooltip=bg;
	end
end

-- force using the default replaceable texture for the given model.
function CKidMiddleContainer.OnUndoModelTexture()
	local obj = ObjEditor.GetCurrentObj();
	if(obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(not defaultBG:equals(curBG)) then
			obj:SetReplaceableTexture(1, defaultBG);
			CKidMiddleContainer.OnUpdateModelPropertyUI(obj);
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
			-- TODO: delete unused textures.
			--_guihelper.MessageBox(string.format(L"Do you want to delete old drawing at \n%s?", curBG:GetKeyName()), string.format([[ParaIO.DeleteFile("%s");]], curBG:GetKeyName()));
		end
	end
end

function CKidMiddleContainer.OnEditModelTexture()
	local obj = ObjEditor.GetCurrentObj();
	if(obj:IsCharacter() == true) then
		return
	end
	-- this is just a quick way to use external editor for replaceable textures
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local ext = ParaIO.GetFileExtension(curBG:GetKeyName());
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(defaultBG:equals(curBG) or (ext~="jpg" and  ext~="dds" and ext~="png")) then
			CKidMiddleContainer.InvokeTextureEditor(defaultBG:GetKeyName(), obj, 1);
		else
			-- invoke editor
			CKidMiddleContainer.InvokeTextureEditor(curBG:GetKeyName(), obj, 1);
		end
	end
end

CommonCtrl.CKidMiddleContainer.CurrentPainterObject = nil;
function CKidMiddleContainer.InvokeTextureEditor(texturename, obj, nReplaceableTexID)
	KidsPainter.painter_width = 320;
	KidsPainter.imagesize = 256;
	KidsPainter.ShowPainter(true);
	KidsPainter.LoadFromTexture(texturename);
	
	CommonCtrl.CKidMiddleContainer.CurrentPainterObject = obj;
	KidsPainter.nReplaceableTexID = nReplaceableTexID;
	KidsPainter.OnCloseCallBack = CommonCtrl.CKidMiddleContainer.OnEndEditingTexture;
	KidsPainter.OnSaveCallBack = CommonCtrl.CKidMiddleContainer.OnSaveUserDrawing;
	
	if(not nReplaceableTexID) then nReplaceableTexID = 1 end
	if(obj~=nil and obj:IsValid()) then
		local rendertarget = KidsPainter.GetRenderTarget();
		if(rendertarget~=nil) then
			obj:SetReplaceableTexture(1, rendertarget);
		end
	end	
end

-- when the user saves an owner draw image
function CKidMiddleContainer.OnEndEditingTexture()
	local obj = CommonCtrl.CKidMiddleContainer.CurrentPainterObject;
	if(obj==nil or obj:IsCharacter() == true) then
		return
	end
	local nReplaceableTexID = KidsPainter.nReplaceableTexID;
	if(not nReplaceableTexID) then nReplaceableTexID = 1 end
	if(obj~=nil and obj:IsValid()) then
		local diskTexture = KidsPainter.GetDiskTexture();
		if(diskTexture~=nil) then
			obj:SetReplaceableTexture(1, diskTexture);
		end
	end	
	CommonCtrl.CKidMiddleContainer.CurrentPainterObject = nil;
end

-- when the user saves an owner draw image
function CommonCtrl.CKidMiddleContainer.OnSaveUserDrawing()
	local obj = CommonCtrl.CKidMiddleContainer.CurrentPainterObject;
	if(obj==nil or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local PainterImageFileName = KidsPainter.GetDiskTextureFileName();
		local ext = ParaIO.GetFileExtension(PainterImageFileName);
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		
		-- if the current image is not inside the world texture file directory or the current image is not a 
		if(ParaIO.GetParentDirectoryFromPath(PainterImageFileName, 0) ~= ParaIO.GetParentDirectoryFromPath(ParaWorld.GetWorldDirectory().."texture/",0) or (ext~="jpg" and  ext~="dds" and ext~="png")) then
			-- create a new texture at the [worlddir]/texture/[default_texture_name]_[unique_number].dds
			-- add a random name
			local nameTmp = ParaIO.GetFileName(defaultBG:GetKeyName());
			local len = string.len(nameTmp);
			local newTexName = ParaWorld.GetWorldDirectory().."texture/"..string.sub(nameTmp, 1, len-4)..ParaGlobal.GenerateUniqueID()..string.sub(nameTmp, len-3, -1);
			if(ParaIO.CreateDirectory(newTexName)) then
				-- save the new texture to file
				KidsPainter.SaveAs(newTexName);
				local tex = ParaAsset.LoadTexture("", newTexName, 1);
				if(tex:IsValid()) then
					obj:SetReplaceableTexture(1, tex);
					CKidMiddleContainer.OnUpdateModelPropertyUI(obj);
					local x,y,z = obj:GetPosition();
					ParaTerrain.SetContentModified(x,z, true);
				end	
			end
		else
			-- the old file is under the world texture directory, hence we will just overwrite.
			local newTexName = PainterImageFileName;
			KidsPainter.SaveAs(newTexName );
		end
	end		
end
