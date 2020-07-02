--[[
Title: Aries quest NPC characters
Author(s): WangTian
Date: 2009/7/21
	params.timer_period is added. 
use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Quest/main.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPCBagManager.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Headon_NPC.lua");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local Headon_NPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_NPC");
local CCS = commonlib.gettable("System.UI.CCS");
local System = commonlib.gettable("System");
local tostring = tostring
local tonumber = tonumber
local type = type

local string_match = string.match;
local LOG = LOG;

-- create class
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
-- mapping from npc_id to their timer object
NPC.timers = {};
-- set of global timer npc ids
NPC.globaltimer_npcids = {};

-- create class
-- NOTE: NPCs for NPC instances, e.x. MysteryAcinusTree
local NPCs = commonlib.gettable("MyCompany.Aries.Quest.NPCs");

NPC.HeadOnDisplayColor = NPC.HeadOnDisplayColor or "12 245 5"; -- "255 253 97";

---- local optimizations
--local string_match = string_match;
--local tonumber = tonumber
--local type = type
-- local ParaObject_IsValid = commonlib.getfield("ParaScene.ParaObject.IsValid");
local ParaScene_GetCharacter = commonlib.getfield("ParaScene.GetCharacter");
local ParaScene_GetObject = commonlib.getfield("ParaScene.GetObject");

NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

-- check if the object is NPC character
-- @return true if is NPC, otherwise false
function NPC.IsNPC(obj)
	if(obj and obj:IsValid()) then
		if(string_match(obj.name, "^NPC:")) then
			return true;
		end
	end
	return false;
end
local IsNPC = NPC.IsNPC;

-- world closing to reset stop all NPC timers
function NPC.OnWorldClosing()
	local npc_id, timer;
	for npc_id, timer in pairs(NPC.timers) do
		if(NPC.globaltimer_npcids[npc_id] ~= true) then
			-- kill non global timers
			NPC.timers[npc_id]:Change();
		end
	end
end

-- check if the NPC dialog is visible
function NPC.IsNPCDialogVisible()
	local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
	if(_app and _app._app) then
		_app = _app._app;
		local _wnd = _app:FindWindow("NPC_Dialog");
		if(_wnd) then
			return _wnd:IsVisible();
		end
	end
	return false;
end


-- check if the object is NPC character
-- @param obj: npc character object
-- @return NPC_id, instance: if is NPC, otherwise nil, if instance order, otherwise nil
function NPC.GetNpcIDAndInstanceFromCharacter(obj)
	if(IsNPC(obj) == true) then
		--NPC:122
		--NPC:122(543)
		local NPC_id, instance = string_match(obj.name, "^NPC:(%d+)[%(]?(%d*)[%)]?");
		if(NPC_id and instance and instance ~= "") then
			return tonumber(NPC_id), tonumber(instance);
		elseif(NPC_id) then
			return tonumber(NPC_id);
		end
	end
end
-- get the npc character and model object from npc_id
-- @param npc_id: npc id
-- @param instance(optional): instance of the npc character, starts from 1
-- @return valid NPC character,  NPC model, otherwise nil
function NPC.GetNpcCharModelFromIDAndInstance(npc_id, instance)
	local npc_char_name = "NPC:"..npc_id;
	if(instance) then
		npc_char_name = npc_char_name.."("..instance..")";
	end
	
	local player = ParaScene_GetCharacter(npc_char_name);
	if(player and player:IsValid() == true) then
		local npc_model_name = "g_"..npc_char_name.."_model";
		local npcModel = ParaScene_GetObject(npc_model_name);
		if(npcModel:IsValid() == true) then
			return player, npcModel;
		else
			return player;
		end
	end
end

-- get the npc char object from npc_id
-- @param npc_id: npc id
-- @param instance(optional): instance of the npc character, starts from 1
-- @return valid NPC char, otherwise nil
function NPC.GetNpcCharacterFromIDAndInstance(npc_id, instance)
	local npc_char_name = "NPC:"..npc_id;
	if(instance) then
		npc_char_name = npc_char_name.."("..instance..")";
	end
	
	local player = ParaScene_GetCharacter(npc_char_name);
	if(player and player:IsValid() == true) then
		return player;
	end
end
local GetNpcCharacterFromIDAndInstance = NPC.GetNpcCharacterFromIDAndInstance;

-- get the npc model object from npc_id
-- @param npc_id: npc id
-- @param instance(optional): instance of the npc character, starts from 1
-- @return valid NPC model, otherwise nil
function NPC.GetNpcModelFromIDAndInstance(npc_id, instance)
	local npc_model_name = "NPC:"..npc_id;
	if(instance) then
		npc_model_name = npc_model_name.."("..instance..")";
	end
	npc_model_name = "g_"..npc_model_name.."_model";
	local player = ParaScene_GetObject(npc_model_name);
	if(player and player:IsValid() == true) then
		return player;
	end
end

-- get the npc character display name from npc_id
-- NOTE: the NPC character must be visualized
-- @param npc_id: npc id
-- @return display name, tooltip:  otherwise nil
function NPC.GetNpcDisplayNameFromID(npc_id, instance)
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance);
	local displayName, cursor_text;
	if(npcChar) then
		displayName = npcChar:GetDynamicField("DisplayName", "");
		if(displayName == "") then
			displayName = nil;
			-- if the display name is not available, try the first instance
			-- NOTE: we assume that all instances share the same display name
			npcChar = GetNpcCharacterFromIDAndInstance(npc_id, 1);
			if(npcChar) then
				displayName = npcChar:GetDynamicField("DisplayName", "");
				if(displayName == "") then
					displayName = nil;
				end
			end
		end
		if(displayName) then
			if(npcChar) then
				cursor_text = npcChar:GetDynamicField("cursor_text", "");
				if(cursor_text == "") then
					cursor_text = nil;
				end
			end
		end
	end
	return displayName, cursor_text;
end

-- get the selected page URL
-- @param npc_id: npc id
-- @param instance: npc instance, can be nil
-- @param baseURL: the default base url
-- @return: url of the NPC selected MCML page
function NPC.GetNPCSelectedPageURL(npc_id, instance, baseURL)
	baseURL = baseURL or "script/apps/Aries/Desktop/SelectionResponse/CommonNPC.html";
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance);
	if(npcChar and npcChar:IsValid() == true) then
		baseURL = npcChar:GetDynamicField("params_selected_page", nil) or baseURL;
	end
	--local params = MyCompany.Aries.Quest.NPCList.NPCs[npc_id];
	--if(params and params.selected_page) then
		--baseURL = params.selected_page;
	--end
	
	if(npc_id and instance) then
		return baseURL.."?npc_id="..npc_id.."&instance="..instance;
	elseif(npc_id and not instance) then
		return baseURL.."?npc_id="..npc_id;
	end
end

-- get the selected page URL
-- @param npc_id: npc id
-- @param instance: npc instance, can be nil
-- @return: url of the NPC dialog MCML page, otherwise nil
function NPC.GetNPCDialogPageURL(npc_id, instance)
	--local params = MyCompany.Aries.Quest.NPCList.NPCs[npc_id];
	--if(params.dialog_page) then
		--if(npc_id and instance) then
			--return params.dialog_page.."?npc_id="..npc_id.."&instance="..instance;
		--elseif(npc_id and not instance) then
			--return params.dialog_page.."?npc_id="..npc_id;
		--end
	--end
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance);
	local baseURL;
	if(npcChar and npcChar:IsValid() == true) then
		baseURL = npcChar:GetDynamicField("params_dialog_page", nil);
	end
	if(baseURL) then
		if(npc_id and instance) then			
			return baseURL.."?npc_id="..npc_id.."&instance="..instance;
		elseif(npc_id and not instance) then
			return baseURL.."?npc_id="..npc_id;
		end
	end
end

-- get the pre-show dialog page function
-- @param npc_id: npc id
-- @param instance: npc instance, can be nil
-- @return: function string, if nil continue with dialog
function NPC.GetPreDialogFunction(npc_id, instance)
	--local params = MyCompany.Aries.Quest.NPCList.NPCs[npc_id];
	--if(params.predialog_function) then
		--return params.predialog_function;
	--end
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance);
	local baseURL;
	if(npcChar and npcChar:IsValid() == true) then
		return npcChar:GetDynamicField("params_predialog_function", nil);
	end
end

-- mapping from npc character name to their last parameter when NPC.CreateNPCCharacter() is called. 
local npc_params_map = {};
local headon_offset_two_lines = {x=0, y=0.6, z=0}
-- create NPC by npc_id and params
-- @npc_id: NPC id
-- @params: NPC params including:
--		name = "",
--		position = {x, y, z},
--		assetfile_char = "", -- NPC always uses a character to invoke the AI script or quest logic
--		(optional)friend_npcs = "", comma-separated npc ids, friend NPC bags are also fetched before talking to NPC
--		(optional)facing = 0,
--		(optional)scaling = 1,
--		(optional)instance = 1, -- order of the NPC that have multiple character instance, starts from 1, sharing the same npc_id, script and item bag
--		(optional)ccsinfo = {}, -- currently this field is not required, all NPCs are non-customizable characters
--				ccsinfo includes: cartoonface_info = "", facial_info = "", equips = {};
--		(optional)assetfile_model = "", -- some NPCs are solid physics object, the model object share the same facing and scaling params as character
--		(optional)replaceabletextures_model = {}, -- some model contains replaceable texture to show multimedia content besides texture, such as flv, wmv
--		(optional)isalwaysshowheadontext = true, -- always show the head on text, especially useful for hiden game object, default true
--		main_script = "script/apps/Aries/NPCs/Police/30004_MysteryAcinusTree.lua", -- main script for the NPC
--		(optional)dialog_page = "script/apps/Aries/NPCs/Police/30004_MysteryAcinusTree_dialog.html", -- dialog MCML page
--		(optional)predialog_function = "", -- function called before dialog is shown, if function return false, the dialog page is skipped
--		(optional)selected_page = "script/apps/Aries/NPCs/Police/30004_MysteryAcinusTree_selected.html", -- target area selected MCML page
--		(optional)AI_script = "script/apps/Aries/NPCs/Police/30004_MysteryAcinusTree_AI.lua", -- AI script
--		(optional)timer_period = 100,  -- on_timer period in milliseconds,
--		(optional)on_timer = ";MyCompany.Aries.Quest.NPCs.AquaHorse.On_Timer();"
-- @return npcChar, npcModel: NPC character object if success
--		model/05plants/03shrub/1-xianrenzhang.x
--		model/05plants/04other/largemushrooms1.x
--		model/05plants/04other/largemushrooms2.x
-- Sample: 
--local params = {
	--name = "Metagron",
	--position = { 20065.27734375, 0.49730199575424, 19818.572265625 },
	----assetfile_char = "character/v1/01human/baru/baru.x",
	--assetfile_char = "character/v3/Elf/Female/ElfFemale.xml",
	--facing = 2,
	--scaling = 1.1,
	--instance = 3,
	--ccsinfo = {
		--facial_info = "0#1#0#1#1#";
		--cartoonface_info = "0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#";
		--equips = {
			--[16] = 1008,
			--[17] = 1009,
			--[19] = 1010,
			--[0] = 1011,
		--},
	--},
	--assetfile_model = "model/04deco/v3/1-gongyuangonggaolan.x",
	--replaceabletextures_model = {
		--[1] = "Texture/3DMapSystem/TEMP/Startup/paraworldCG_320_240.flv",
		--[2] = "Texture/productcover_exit.png",
	--},
	--isalwaysshowheadontext = false,
--};
--NPC.CreateNPCCharacter(43123, params);
function NPC.CreateNPCCharacter(npc_id, params)
	
	if(not npc_id or type(params) ~= "table") then
		LOG.std("", "error","NPC", "create NPC got nil npc_id or params")
		return;
	end
	
	-- download the following files if not exist
	--params.main_script
	--params.dialog_page
	--params.selected_page
	--params.AI_script
	
	local npc_char_name = "NPC:"..npc_id;
	if(params.instance) then
		npc_char_name = "NPC:"..npc_id.."("..params.instance..")";
	end
	
	local last_params;
	local npcModel;

	-- create each NPC character
	local npcChar = ParaScene_GetCharacter(npc_char_name);
	if(npcChar:IsValid() == false) then
		-- if the character does not exist, create and set all supported parameters
		if(params.main_script) then
			NPL.load(params.main_script);
		end
	
		if(params.AI_script) then
			NPL.load(params.AI_script);
		end

		-- LOG.std("", "debug","NPC", "NPC %s(%s) is created", npc_id, tostring(params.name));

		local obj_params = {};
		obj_params.name = npc_char_name;
		obj_params.x = params.position[1];
		obj_params.y = params.position[2];
		obj_params.z = params.position[3];
		obj_params.AssetFile = params.assetfile_char;
		obj_params.IsCharacter = true;
		-- skip saving to history for recording or undo.
		System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true, silentmode = true,});
		npcChar = ParaScene_GetCharacter(npc_char_name);

		-- if character exists, update the position and rotation
		npcChar:SetPosition(params.position[1], params.position[2], params.position[3]);
		npcChar:SetFacing(params.facing or 0);
		-- NOTE: special scaling for Aries project to scale the avatar to 1.6105, including avatars, dragons, follow pets, NPCs, GameObjects

		-- by default we will scale character by 1.6105
		-- npcChar:SetScale((params.directscaling and params.scaling) or ((params.scale_char or 1.6105) * (params.scaling_char or params.scaling or 1)));
		npcChar:SetScale((params.scaling or 1)* (params.scale_char or 1));
		
		if(System.options.is_mcworld) then
			npcChar:SetAttribute(128, true);
		end

		if(params.headonmark) then
			NPC.ChangeHeadonMarkByObj(npcChar, params.headonmark)
		end

		-- weather the object is interactive. 
		local is_interactive;

		local att = npcChar:GetAttributeObject();
		if(params.dialog_page) then
			att:SetDynamicField("params_dialog_page", params.dialog_page);
			is_interactive = true;
		end
		if(params.selected_page) then
			att:SetDynamicField("params_selected_page", params.selected_page);
			is_interactive = true;
		end
		if(params.predialog_function) then
			att:SetDynamicField("params_predialog_function", params.predialog_function);
			is_interactive = true;
		end
		-- levarage the npc's render importance, so that it will be rendered and picked first
		if(is_interactive) then
			npcChar:SetField("RenderImportance", 1);
		end

		if(params.friend_npcs) then
			att:SetDynamicField("friend_npcs", params.friend_npcs);
		end
		if(params.autowalk) then
			att:SetDynamicField("AutoWalk", params.autowalk);
		end
		if(params.talkdist or params.talk_dist) then
			att:SetDynamicField("TalkDist", params.talkdist or params.talk_dist);
		end
		if(params.cursor) then
			att:SetDynamicField("cursor", params.cursor);
		end
		if(params.cursor_text) then
			att:SetDynamicField("cursor_text", params.cursor_text);
		elseif(params.name2 and params.name2 ~= "") then
			att:SetDynamicField("cursor_text", format("%s\n%s", params.name or "", params.name2));
		end
		if(params.skiprender_char) then
			att:SetField("SkipRender", true);
		end
		if(params.renderdistance) then
			att:SetField("RenderDistance", params.render_distance);
		end
		if(params.movementstyle) then
			att:SetField("MovementStyle", params.movementstyle);
		end
		
		if(params.isalwaysshowheadontext == false) then
			att:SetDynamicField("AlwaysShowHeadOnText", false);
			att:SetDynamicField("DisplayName", "");
		else
			att:SetDynamicField("AlwaysShowHeadOnText", true);
			att:SetDynamicField("DisplayName", params.name);
			if(params.HeadOnDisplayColor) then
				att:SetDynamicField("HeadOnDisplayColor", params.HeadOnDisplayColor);
				if(params.name2 and params.name2~="") then
					System.ShowHeadOnDisplay(true, npcChar, format("{%s}+{%s}",params.name, params.name2), params.HeadOnDisplayColor);
				else
					System.ShowHeadOnDisplay(true, npcChar, params.name, params.HeadOnDisplayColor);
				end

			else
				if(params.name2 and params.name2~="") then
					System.ShowHeadOnDisplay(true, npcChar, format("{%s}+{%s}",params.name, params.name2), NPC.HeadOnDisplayColor);
					--System.ShowHeadOnDisplay(true, npcChar, params.name.."\n"..params.name2, NPC.HeadOnDisplayColor, headon_offset_two_lines);
				else
					System.ShowHeadOnDisplay(true, npcChar, params.name, NPC.HeadOnDisplayColor);
				end
			end
		end
		local SentientGroupIDs = MyCompany.Aries.SentientGroupIDs;
		local npcCharChar = npcChar:ToCharacter();
		if(not params.isdummy) then
			if(params.autofacing) then
				npcCharChar:AssignAIController("face", "true");
			end	
			npcChar:SetGroupID(SentientGroupIDs["NPC"]);
			npcChar:SetSentientField(SentientGroupIDs["Player"], true);
			--npcChar:SetSentientField(SentientGroupIDs["OPC"], true);
		
			att:SetField("PerceptiveRadius", params.PerceptiveRadius or 40);
			att:SetField("Sentient Radius", params.SentientRadius or 40);
		end
		if(params.skippicking) then
			att:SetField("SkipPicking", true);
		end
	
		if(params.ccsinfo and type(params.ccsinfo.equips) == "table" and npcCharChar:IsCustomModel()) then
			CCS.DB.ApplyCartoonfaceInfoString(npcChar, params.ccsinfo.cartoonface_info);
			CCS.Predefined.ApplyFacialInfoString(npcChar, params.ccsinfo.facial_info);
			local i;
			for i = 0, 45 do
				npcCharChar:SetCharacterSlot(i, params.ccsinfo.equips[i] or 0);
			end
		end

		if(params.ccsinfo_teen and type(params.ccsinfo_teen) == "table" and npcCharChar:IsCustomModel()) then
			local bFemale = false;
			if(params.assetfile_char == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
				bFemale = true;
			elseif(params.assetfile_char == "character/v3/TeenElf/Male/TeenElfMale.xml") then
				bFemale = false;
			end
			-- hair
			npcCharChar:SetBodyParams(-1, -1, -1, params.ccsinfo_teen.hairstyle or 1, -1);
			npcCharChar:SetBodyParams(-1, -1, 0, -1, -1);
			-- skin color
			local color = params.ccsinfo_teen.skincolor or 1;
			npcCharChar:SetBodyParams(color - 1, -1, -1, -1, -1);
			npcCharChar:SetBodyParams(-1, -1, -1, -1, 1);
			npcCharChar:SetCartoonFaceComponent(0, 0, if_else(bFemale, color - 1 + 100, color - 1 + 200));
			npcCharChar:SetCartoonFaceComponent(1, 0, -1);
			npcCharChar:SetCartoonFaceComponent(2, 0, -1);
			npcCharChar:SetCartoonFaceComponent(3, 0, -1);
			npcCharChar:SetCartoonFaceComponent(4, 0, -1);
			npcCharChar:SetCartoonFaceComponent(5, 0, -1);
			-- face
			local face = params.ccsinfo_teen.facestyle or 1;
			npcCharChar:SetBodyParams(-1, -1, -1, -1, 1);
			npcCharChar:SetCartoonFaceComponent(6, 0, if_else(bFemale, face - 1 + 100, face - 1 + 200));
			-- equips
			local key, gsid;
			for key, gsid in pairs(params.ccsinfo_teen) do
				if(string.find(key, "equip")) then
					if(gsid == 0 or not gsid) then
						params.ccsinfo_teen[key] = 0;
					else
						if(params.ccsinfo_teen[key] < 10000) then
							local bUniSex = false;
							local gsTemplate = ItemManager.GetGlobalStoreItemInMemory(gsid);
							if(gsTemplate) then
								if(gsTemplate.template.stats[187] == 1) then
									bUniSex = true;
								end
							end
							if(bUniSex == true) then
								params.ccsinfo_teen[key] = gsid + 30000;
							else
								params.ccsinfo_teen[key] = if_else(bFemale, gsid + 40000, gsid + 30000);
							end
						end
					end
				end
			end
			if(params.ccsinfo_teen.equip_hat ~= 0) then
				npcCharChar:SetBodyParams(-1, -1, -1, 0, -1);
			end
			npcCharChar:SetCharacterSlot(0, params.ccsinfo_teen.equip_hat or 0);
			npcCharChar:SetCharacterSlot(28, params.ccsinfo_teen.equip_suit or 0);
			npcCharChar:SetCharacterSlot(19, params.ccsinfo_teen.equip_boot or 0);
			npcCharChar:SetCharacterSlot(21, params.ccsinfo_teen.equip_back or 0);
			npcCharChar:SetCharacterSlot(11, params.ccsinfo_teen.equip_lefthand or 0);
			npcCharChar:SetCharacterSlot(10, params.ccsinfo_teen.equip_righthand or 0);
			npcCharChar:SetCharacterSlot(26, params.ccsinfo_teen.equip_wing or 0);
		end
	
		if(params.assetfile_model) then
		
			-- remove all space character
			params.assetfile_model = string.gsub(params.assetfile_model, "%s", "");
		
			local npc_model_name = "g_"..npc_char_name.."_model";
			npcModel = ParaScene_GetObject(npc_model_name);
			if(npcModel:IsValid() == false) then
				local obj_params = {};
				obj_params.name = npc_model_name;
				obj_params.x = params.position[1];
				obj_params.y = params.position[2];
				obj_params.z = params.position[3];
				obj_params.rotation = params.rotation;
				obj_params.AssetFile = params.assetfile_model;
				obj_params.IsCharacter = false;
				obj_params.facing = params.facing or 0;
				obj_params.scaling = (params.scaling_model or 1) * (params.scaling or 1);
				obj_params.EnablePhysics = params.EnablePhysics;
				if(params.isBigStaticMesh) then
					obj_params.PhysicsRadius = 100;
				end

				-- skip saving to history for recording or undo.
				System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
					obj_params = obj_params, 
					SkipHistory = true, 
					silentmode = true,
				});
			
				npcModel = ParaScene_GetObject(npc_model_name);
				if(params.skiprender_mesh) then
					npcModel:SetField("SkipRender", true);
				end
				npcModel:SetField("progress", 1);

				if(params.isBigStaticMesh) then
					npcModel:SetAttribute(8192, true); -- 8192 stands for big static mesh
				end
				if(System.options.is_mcworld) then
					npcModel:SetAttribute(128, true);
				end
				if(params.physics_group and params.physics_group>0) then
					npcModel:SetPhysicsGroup(params.physics_group);
				end
				if(params.renderdistance) then
					npcModel:SetField("RenderDistance", params.render_distance);
				end
			else
				npcModel:SetFacing(params.facing or 0);
				npcModel:SetPosition(params.position[1], params.position[2] + (params.offset_model_y or 0), params.position[3]);
				npcModel:SetScale((params.scaling_model or 1) * (params.scaling or 1));
			end
		
			if(params.replaceabletextures_model and npcModel:GetNumReplaceableTextures()>0) then
				local i;
				for i = 1, npcModel:GetNumReplaceableTextures() do
					local filename = params.replaceabletextures_model[i];
					if(filename and filename ~= "") then
						npcModel:SetReplaceableTexture(i-1, ParaAsset.LoadTexture("", filename, 1));
					end	
				end
			end
		end

		-- set the timer if the on_timer field is valid
		if(params.on_timer) then
			NPC.CreateTimer(npc_id, params.on_timer, params.timer_period, params.isglobaltimer);
		end

		-- set the AI scripts if the AI_script is valid
		if(params.On_FrameMove) then
			npcChar:SetField("On_FrameMove", params.On_FrameMove or "");
		end
		if(params.On_Perception) then
			npcChar:SetField("On_Perception", params.On_Perception or "");
		end
		if(params.FrameMoveInterval) then
			-- LOG.std("", "debug","NPC", "NPC: %s FrameMoveInterval is %d", params.name or "", params.FrameMoveInterval);
			npcChar:SetField("FrameMoveInterval", params.FrameMoveInterval);
		end
		
		-- TODO: main function called on NPC create if required, usually some status refresh or hook registration
		-- NOTE: main_function must be executed after main_script is loaded and can only be implemented in main_script
		-- NOTE: main_function is invoked on each world load
		if(params.main_function) then
			-- dirty code to get bag items prior to every main function
			local func = commonlib.getfield(params.main_function);
			if(func) then
				MyCompany.Aries.Quest.NPCBagManager.GetNPCBag(npc_id, function(msg)
					-- func parameter added by LiXizhi. 2011.6.1
					func(npc_char_name, npc_id, params);
				end);
			end
		end
	else
		LOG.std("", "debug","NPC", "NPC %s(%s) is updated", npc_id, tostring(params.name));
		-- if the character already exist, we will only update fields that support late updating. 
		last_params = npc_params_map[npc_char_name];
		if(last_params) then
			if(last_params.position[1] ~= params.position[1] or last_params.position[3] ~= params.position[3] or last_params.position[2] ~= params.position[2]) then
				npcChar:SetPosition(params.position[1], params.position[2], params.position[3]);
			end

			if(params.facing and last_params.facing~= params.facing) then
				npcChar:SetFacing(params.facing);
			end
			
			if(params.ccsinfo and type(params.ccsinfo.equips) == "table" and 
				last_params.ccsinfo ~= params.ccsinfo and last_params.ccsinfo.equips ~= params.ccsinfo.equips and 
				npcChar:ToCharacter():IsCustomModel()) then

				CCS.DB.ApplyCartoonfaceInfoString(npcChar, params.ccsinfo.cartoonface_info);
				CCS.Predefined.ApplyFacialInfoString(npcChar, params.ccsinfo.facial_info);
				local npcCharChar = npcChar:ToCharacter();
				local i;
				for i = 0, 45 do
					npcCharChar:SetCharacterSlot(i, params.ccsinfo.equips[i] or 0);
				end
			end
		end
	end
	npc_params_map[npc_char_name] = params;

	return npcChar, npcModel;
end


-- Create timer, this function is used to create NPC timer, it can also be used externally. 
-- @param npc_id: timer id
-- @param timer_func_name: function or string of timer function full path. 
function NPC.CreateTimer(npc_id, timer_func_name, timer_period, isglobaltimer)
	if(not NPC.timers[npc_id]) then
		local callbackFunc = nil;
		if(type(timer_func_name) == "string") then
			callbackFunc = commonlib.getfield(timer_func_name);
		else
			callbackFunc = timer_func_name;
		end
		
		if(type(callbackFunc) == "function") then
			NPC.timers[npc_id] = commonlib.Timer:new({callbackFunc = callbackFunc});
			LOG.std("", "debug","NPC", "NPC timer created period(%d): %s: %s", timer_period or 100, tostring(npc_id), timer_func_name)
		end	
	end
	if(NPC.timers[npc_id]) then
		-- reset timer
		NPC.timers[npc_id]:Change(timer_period or 100, timer_period or 100);
	end
	if(isglobaltimer) then
		NPC.globaltimer_npcids[npc_id] = true;
	end
end

-- delete the NPC character in the scene
-- @param npc_id: NPC id
-- @param instance(optional): instance of the npc character, starts from 1
-- @param bSkipCloseDialog: skip the close dialog process
function NPC.DeleteNPCCharacter(npc_id, instance, bSkipCloseDialog)
	-- auto deselect the charcter if selected
	local TargetArea = TargetArea;
	if(TargetArea.TargetNPC_id == npc_id and TargetArea.TargetNPC_instance == instance) then
		-- deselect object
		System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, bSkipCloseDialog = bSkipCloseDialog, obj = nil});
	end
	
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance)
	local npc_char_name;
	if(npcChar and npcChar:IsValid() == true) then
		npc_char_name = npcChar.name;
		ParaScene.Delete(npcChar);
	end
	if(npc_char_name) then
		local npc_model_name = "g_"..npc_char_name.."_model";
		local npcModel = ParaScene_GetCharacter(npc_model_name);
		if(npcModel:IsValid() == true) then
			ParaScene.Delete(npcModel);
		end
	end
end

function NPC.GetHeadOnUITemplateName(npc_id, instance)
	if(not npc_id)then
		return
	end
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance)
	if(npcChar) then
		return npcChar:GetHeadOnUITemplateName(1);
	end
end
-- change the headon mark UI
-- @param npcChar: the ParaObject of the character or model
-- @param sTemplateName: if nil or "", it will hide the mark. otherwise it can be 
--  "accept", "pending",  "finish","unfinshed","portal", etc. more info see Headon_NPC.lua
function NPC.ChangeHeadonMarkByID(npc_id, instance, sTemplateName)
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance)
	if(npcChar) then
		Headon_NPC.ChangeHeadonMark(npcChar,sTemplateName);
	end
end

-- change the headon mark UI
-- @param npcChar: the ParaObject of the character or model
-- @param sTemplateName: if nil or "", it will hide the mark. otherwise it can be 
--  "accept", "pending",  "finish","unfinshed","portal", etc. more info see Headon_NPC.lua
function NPC.ChangeHeadonMarkByObj(npcChar, sTemplateName)
	Headon_NPC.ChangeHeadonMark(npcChar,sTemplateName);
end

function NPC.ChangeHeadonText(npc_id, instance, text)
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance)
	if(npcChar) then
		local att = npcChar:GetAttributeObject();
		att:SetDynamicField("AlwaysShowHeadOnText", true);
		att:SetDynamicField("DisplayName", text);
		
		local HeadOnDisplayColor = att:GetDynamicField("HeadOnDisplayColor", NPC.HeadOnDisplayColor);
		System.ShowHeadOnDisplay(true, npcChar, text, HeadOnDisplayColor);
	end
end

function NPC.ChangeModelAsset(npc_id, instance, asset_file)
	local npcModel = NPC.GetNpcModelFromIDAndInstance(npc_id, instance);
	if(npcModel) then
		commonlib.ResetModelAsset(npcModel, asset_file);
	end
end

function NPC.ChangeCharacterAsset(npc_id, instance, asset_file)
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(npc_id, instance);
	if(npcChar) then
		if(npcChar:GetPrimaryAsset():GetKeyName() ~= asset_file) then
			-- change treasurebox asset if needed
			local asset = ParaAsset.LoadParaX("", asset_file);
			npcChar:ToCharacter():ResetBaseModel(asset);
		end
	end
end

-- talk to NPC
-- NOTE: talk to NPC will first fetch the NPC bag item first
-- @param npc_id: NPC id
-- @parma instance(optional): instance of the npc character, starts from 1
function NPC.TalkToNPC(npc_id, instance)
	local npcChar = GetNpcCharacterFromIDAndInstance(npc_id, instance);
	if(npcChar) then
		local friend_npcs = npcChar:GetDynamicField("friend_npcs", nil);
		if(friend_npcs == nil) then
			MyCompany.Aries.Quest.NPCBagManager.GetNPCBag(npc_id, function(msg)
				LOG.std("", "debug","NPC", "++++++++ NPCBagManager.GetNPCBag: %s returns ++++++++", npc_id);
				LOG.std("", "debug","NPC", msg)
				LOG.std("", "debug","NPC", "Profile.Aries.ShowNPCDialog called for npc_id, instance:")
				LOG.std("", "debug","NPC", {npc_id, instance});
				System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
					{npc_id = npc_id, instance = instance,}
				);
			end);
		else
			local npcs = {};
			table.insert(npcs, npc_id);
			local npc_friend;
			for npc_friend in string.gfind(friend_npcs, "([^,]+)") do
				npc_friend = tonumber(npc_friend);
				if(npc_friend) then
					table.insert(npcs, npc_friend);
				end
			end
			local isReturneds = {};
			local i, bag;
			for i, bag in ipairs(npcs) do
				isReturneds[bag] = false;
			end
			local i, bag;
			for i, bag in ipairs(npcs) do
				MyCompany.Aries.Quest.NPCBagManager.GetNPCBag(bag, function(msg)
					LOG.std("", "debug","NPC", "++++++++ NPCBagManager.GetNPCBag: %s returns ++++++++\n", bag)
					LOG.std("", "debug","NPC", msg);
					
					isReturneds[bag] = true;
					local k, v;
					local bAllReturned = true;
					for k, v in pairs(isReturneds) do
						if(v == false) then
							bAllReturned = false;
							break;
						end
					end
					if(bAllReturned == true) then
						LOG.std("", "debug","NPC", "Profile.Aries.ShowNPCDialog called for npc_id, instance:")
						LOG.std("", "debug","NPC", {npc_id, instance});
						System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
							{npc_id = npc_id, instance = instance,}
						);
					end
				end);
			end
		end
	end
end