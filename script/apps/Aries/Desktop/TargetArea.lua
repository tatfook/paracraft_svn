--[[
Title: Desktop Target Area for selected object(NPC, players)
Author(s): WangTian
Date: 2009/4/7
Desc: See Also: script/apps/Aries/Desktop/AriesDesktop.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
MyCompany.Aries.Desktop.TargetArea.Init();
------------------------------------------------------------
]]

-- create class
local libName = "AriesDesktopTargetArea";
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");

local Combat = commonlib.gettable("MyCompany.Aries.Combat");

-- selection response pages, dynamicly loaded from web
local SelectionResponse = commonlib.gettable("MyCompany.Aries.Desktop.SelectionResponse");

NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");

NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");

-- selected target
TargetArea.target = nil;
-- selected target nid if the selected target is an OPC object
TargetArea.TargetNID = nil;
-- selected target npc_id and instance if the selected target is an NPC object
TargetArea.TargetNPC_id = nil;
TargetArea.TargetNPC_instance = nil;
-- selected target gameobj_id and instance if the selected target is a gameobject object
TargetArea.TargetGameObj_id = nil;
TargetArea.TargetGameObj_instance = nil;
-- selected target guid if the selected target is a pet object in homeland
TargetArea.TargetPet_guid = nil;

-- default npc talk distance
TargetArea.DefaultNpcTalkDist = 4;
-- default game object pick distance
TargetArea.DefaultGameObjectPickDist = 4;

-- whether the target area is enabled. or not. To enable it, call TargetArea.Show()
TargetArea.IsShown = false;

-- mapping from selection type to its mcml page template for display
TargetArea.SelectionResponseURL ={
	["NPC"] = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC.html",
	["Myself"] = "script/apps/Aries/Desktop/SelectionResponse/Myself.kids.html",
	["GameObject"] = "script/apps/Aries/Desktop/SelectionResponse/GameObject.html",
	["OtherPlayer"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayer.kids.html",
	["townchiefrodd"] = "script/apps/Aries/Desktop/SelectionResponse/townchiefrodd.html",
	["mountpetinhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/MountPetInHomeland.html",
	["followpetinhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/FollowPetInHomeland.html",
	["mountpetinotherhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayerMountPetInHomeland.html",
	["followpetinotherhomeland"] = "script/apps/Aries/Desktop/SelectionResponse/OtherPlayerFollowPetInHomeland.html",
};

-- invoked at Desktop.InitDesktop()
function TargetArea.Init()
	-- load implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/TargetArea/TargetArea.kids.lua");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/TargetArea/TargetArea.teen.lua");
	end
	TargetArea.Create();
	
	-- show it immediately
	TargetArea.Show(true);
	-- start a timer to track the position of the player and talk to the NPC again if the player reach the destination close enough
	NPL.load("(gl)script/ide/timer.lua");
	TargetArea.timer = TargetArea.timer or commonlib.Timer:new({callbackFunc = TargetArea.DoCheckWalkTalk});
	TargetArea.timer:Change(100,100);
end


-- virtual function: create UI
function TargetArea.Create()
end

function TargetArea.GetParentContainer()
	return ParaUI.GetUIObject("TargetArea");
end

local instance_dir_name_mapping = {
	["worlds/Instances/HaqiTown_FireCavern/"] = "火焰山洞",
	["worlds/Instances/FlamingPhoenixIsland_TheGreatTree/"] = "神木空间",
	["worlds/Instances/HaqiTown_LightHouse/"] = "试炼之塔",
};

-- show or hide the target area, toggle the visibility if bShow is nil
function TargetArea.Show(bShow)
	local _targetArea = ParaUI.GetUIObject("TargetArea");
	if(_targetArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _targetArea.visible;
		end
		_targetArea.visible = bShow;
	end
	TargetArea.IsShown = bShow;
	
	-- hook into OnTeleportPortal
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnTeleportPortal") then
				
				if(System.options.version == "teen") then
					if(msg.portal and msg.portal:IsValid()) then
						if(msg.portal.name == "teleport-portal:1") then
							NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
							local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
							local worldinfo = WorldManager:GetCurrentWorld();
							if(worldinfo.name == "CloudFortressIsland") then
								NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
								local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
								local provider = QuestClientLogics.GetProvider();
								--杨磊(杨磊) 16:51:49
								--62023 以这个任务为准就好
								--local quest_id = 62023;
								--if(not provider:HasFinished(quest_id)) then
									--local templates = provider:GetTemplateQuests();
									--local template = templates[quest_id];
									--local title = "入殿资格";
									--if(template and template.Title) then
										--title = template.Title;
									--end
									---- tip
									--NPL.load("(gl)script/ide/TooltipHelper.lua");
									--local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
									--BroadcastHelper.PushLabel({id="CannotEnterPalace_tip", label = "前置任务："..tostring(title).."，尚未完成！", 
											--max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
									--return false;
								--end
							end
						end
					end
				end

				local params = {
					asset_file = "character/v5/09effect/Move/MoveStart.x",
					binding_obj_name = ParaScene.GetPlayer().name,
					start_position = nil,
					duration_time = 400,
					force_name = nil,
					begin_callback = function() 
						end,
					end_callback = function()
							NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
							local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
							local worldinfo = WorldManager:GetCurrentWorld();
							local worldname = worldinfo.world_title;
							if(worldname) then
								-- this is an instance world
								if(msg.portal and msg.portal:IsValid()) then
									local portal_name = msg.portal.name;
									local id = string.match(portal_name, "teleport%-portal:(.+)");
									if(id) then
										id = tonumber(id);
										local level = 1;
										if(math.mod(id, 2) == 0) then
											level = id / 2;
										elseif(math.mod(id, 2) == 1) then
											level = (id + 1) / 2 + 1;
										end

										if(worldinfo.name == "FlamingPhoenixIsland_TheGreatTree_Hero") then
											level = level - 3;
											if(level < 0) then
												level = 0;
											end
										end

										if(string.find(string.lower(worldinfo.worldpath), "instance")) then
											NPL.load("(gl)script/ide/TooltipHelper.lua");
											local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
											BroadcastHelper.PushLabel({
													label = worldname.."第"..level.."层",
													color = "239 230 0",
													shadow = true,
													bold = true,
													font_size = 14,
													scaling = 1.2,
													background = "Texture/Aries/Common/gradient_white_32bits.png",
													background_color = "#1f3243",
													});
										end
									end
								end
							end
							local params = {
								asset_file = "character/v5/09effect/Move/MoveEnd.x",
								binding_obj_name = ParaScene.GetPlayer().name,
								start_position = nil,
								duration_time = 800,
								force_name = nil,
								begin_callback = function() 
										local player = ParaScene.GetPlayer();
										if(player and player:IsValid() == true) then
											player:ToCharacter():Stop();
										end
									end,
								end_callback = nil,
								stage1_time = 200,
								stage1_callback = function()
										local player = ParaScene.GetPlayer();
										if(player and player:IsValid() == true) then
											-- deselect object on indoor<-->outdoor teleport
											System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
											-- set new position
											player:SetPosition(msg.dest[1], msg.dest[2], msg.dest[3]);
											-- refresh the avatar, mount pet and follow pet
											System.Item.ItemManager.RefreshMyself();
											-- refresh all <pe:player>
											Map3DSystem.mcml_controls.GetClassByTagName("pe:player").RefreshContainingPageCtrls();

											-- force update the enviroment
											MyCompany.Aries.Player.EnvTimerFunction()

										end
									end,
								stage2_time = nil,
								stage2_callback = nil,
							};
							local EffectManager = MyCompany.Aries.EffectManager;
							EffectManager.CreateEffect(params);
						end,
				};
				local EffectManager = MyCompany.Aries.EffectManager;
				EffectManager.CreateEffect(params);
			end
		end, 
		hookName = "AriesTeleportPortal", appName = "Aries", wndName = "map"});
	-- hook and unhook into the "object" and update the scene object select
	if(bShow == true) then
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = TargetArea.Hook_SceneObjectSelected, 
			hookName = "AriesTargetSelectionHook", appName = "scene", wndName = "object"});
	elseif(bShow == false) then
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "AriesTargetSelectionHook", 
			hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	end
end

-- hook into the character selection, and change the target selection
function TargetArea.Hook_SceneObjectSelected(nCode, appName, msg)
	--if(msg.type == System.msg.OBJ_DeselectObject or msg.type == System.msg.OBJ_DeleteObject) then
	if(msg.type == System.msg.OBJ_DeselectObject) then
		-- hide the target profile box
		TargetArea.ShowTarget("", msg.bSkipCloseDialog);

	elseif(msg.type == System.msg.OBJ_SelectObject) then
		-- show the target profile box according to the selected object
		TargetArea.ShowTarget("selection");
	end
	return nCode;
end

-- show the target profile according to the param
-- @param target: 
--		if nil or "selection", show selected 
--		if "", object deselected, hide box
function TargetArea.ShowTarget(target, bSkipCloseDialog)
	-- change target. 
	TargetArea.target = target or "selection";
	local selectObj;
	if(TargetArea.target ~= "") then
		selectObj = System.obj.GetObject(TargetArea.target);
	end	
	
	local _targetArea = ParaUI.GetUIObject("TargetArea");
	if(_targetArea:IsValid() == false) then
		log("error: TargetArea not created on TargetArea.ShowTarget() call\n");
		return;
	end
	
	TargetArea.LastSelectedObjInfo = TargetArea.LastSelectedObjInfo or {type = "nothing"};
	local last_info = TargetArea.LastSelectedObjInfo;
	local info = TargetArea.GetSelectedObjectInfo(selectObj);
	TargetArea.LastSelectedObjInfo = info;
	
	if(info) then
		if(System.options.version == "kids") then
			if(TeamMembersPage.IsTeamValid())then
				local isInTeam = TeamWorldInstancePortal.IsInTeam();
				if(isInTeam)then
					_targetArea.x = 160;
				else
					_targetArea.x = 8;
				end
			end
		end

		if(info.type == "myself" or info.type == "mymount" or info.type == "myfollow") then
			-- select user avatar itself
			_targetArea.visible = true;
			TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({click_through = true,url=TargetArea.SelectionResponseURL["Myself"]});
			TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
			TargetArea.TargetNID = nil;
			TargetArea.TargetNPC_id = nil;
			TargetArea.TargetNPC_instance = nil;
			TargetArea.TargetGameObj_id = nil;
			TargetArea.TargetGameObj_instance = nil;
			TargetArea.TargetPet_guid = nil;
		elseif(info.type == "npc") then
			-- select NPC
			_targetArea.visible = true;
			if(info.npc_id) then
				local Quest = MyCompany.Aries.Quest;
				local NPCs = commonlib.getfield("MyCompany.Aries.Quest.NPCList.NPCs");
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
					url = Quest.NPC.GetNPCSelectedPageURL(info.npc_id, info.instance, TargetArea.SelectionResponseURL["NPC"])});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);

				TargetArea.TargetNID = nil;
				TargetArea.TargetNPC_id = info.npc_id;
				TargetArea.TargetNPC_instance = info.instance;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = nil;
				
				local player = ParaScene.GetPlayer();
				if(player and player:IsValid() == true and selectObj and selectObj:IsValid() == true) then
					local Quest = MyCompany.Aries.Quest;
					local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(info.npc_id, info.instance);
					if(npcChar) then
						-- check the distance with the npc
						local dist = player:DistanceTo(selectObj);
						local p_x, p_y, p_z = player:GetPosition();
						local o_x, o_y, o_z = selectObj:GetPosition();
						local dist_xz = math.sqrt((p_x - o_x) * (p_x - o_x) + (p_z - o_z) * (p_z - o_z));
						local talkdist = npcChar:GetDynamicField("TalkDist", TargetArea.DefaultNpcTalkDist);
						if(dist_xz > talkdist) then
							local isAutoWalk = npcChar:GetDynamicField("AutoWalk", true);
							if(isAutoWalk == true) then
								-- walk to the nearest point of npc talk distance
								local dest_x = (p_x - o_x) * (talkdist - 0.1) / dist_xz + o_x;
								local dest_z = (p_z - o_z) * (talkdist - 0.1) / dist_xz + o_z;
								--local dest_x = (p_x - o_x) * talkdist / (dist * 2) + o_x;
								--local dest_z = (p_z - o_z) * talkdist / (dist * 2) + o_z;
								player:ToCharacter():GetSeqController():MoveTo(dest_x - p_x, 0, dest_z - p_z);
								player:SetField("HeadTurningAngle", 0);
								
								TargetArea.WalkToNPCID = info.npc_id;
								TargetArea.WalkToNPCInstance = info.instance;
								TargetArea.Dest_X = dest_x;
								TargetArea.Dest_Z = dest_z;
							end
						elseif(dist_xz <= talkdist and dist <= 1.5 * talkdist) then
							-- talk to npc
							TargetArea.TalkToNPC(TargetArea.TargetNPC_id, TargetArea.TargetNPC_instance);
						end
					end
					
					local Quest = MyCompany.Aries.Quest;
					local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(info.npc_id, info.instance);
					if(npcChar) then
						if(npcChar:GetDynamicField("AlwaysShowHeadOnText", true)) then
							System.ShowHeadOnDisplay(true, obj);
						else
							local displayname = npcChar:GetDynamicField("DisplayName", "");
							local att = npcChar:GetAttributeObject();
							local HeadOnDisplayColor = att:GetDynamicField("HeadOnDisplayColor", Quest.NPC.HeadOnDisplayColor);
							System.ShowHeadOnDisplay(true, npcChar, displayname, HeadOnDisplayColor);
						end
					end
				end
			end
		elseif(info.type == "gameobject") then
			-- select game object
			_targetArea.visible = true;
			if(info.gameobj_id) then
				-- show the game object common game object read, purchase or pick
				local url;
				if(info.gameobj_type == "GSItem") then
					url = TargetArea.SelectionResponseURL["GameObject"].."?gameobj_id="..info.gameobj_id.."&gameobj_type="..info.gameobj_type.."&gsid="..info.gsid;
				elseif(info.gameobj_type == "FreeItem") then
					url = TargetArea.SelectionResponseURL["GameObject"].."?gameobj_id="..info.gameobj_id.."&gameobj_type="..info.gameobj_type.."&gsid="..info.gsid;
				elseif(info.gameobj_type == "MCMLPage") then
					url = TargetArea.SelectionResponseURL["GameObject"].."?gameobj_id="..info.gameobj_id.."&gameobj_type="..info.gameobj_type.."&page_url="..info.page_url;
				end
				if(url) then
					TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
						url = url,
					});
					TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
					TargetArea.TargetNID = nil;
					TargetArea.TargetNPC_id = nil;
					TargetArea.TargetNPC_instance = nil;
					TargetArea.TargetGameObj_id = info.gameobj_id;
					TargetArea.TargetGameObj_instance = info.instance;
					TargetArea.TargetPet_guid = nil;
					
					local player = ParaScene.GetPlayer();
					if(player and player:IsValid() == true and selectObj and selectObj:IsValid() == true) then
						-- check the distance with the npc
						local dist = player:DistanceTo(selectObj);
						local p_x, p_y, p_z = player:GetPosition();
						local o_x, o_y, o_z = selectObj:GetPosition();
						local dist_xz = math.sqrt((p_x - o_x) * (p_x - o_x) + (p_z - o_z) * (p_z - o_z));
						local pickdist = selectObj:GetDynamicField("PickDist", TargetArea.DefaultGameObjectPickDist);
						if(dist_xz > pickdist) then
							-- walk to the nearest point of npc talk distance
							local dest_x = (p_x - o_x) * (pickdist - 0.1) / dist_xz + o_x;
							local dest_z = (p_z - o_z) * (pickdist - 0.1) / dist_xz + o_z;
							--local dest_x = (p_x - o_x) * pickdist / (dist * 2) + o_x;
							--local dest_z = (p_z - o_z) * pickdist / (dist * 2) + o_z;
							player:ToCharacter():GetSeqController():MoveTo(dest_x - p_x, 0, dest_z - p_z);
							player:SetField("HeadTurningAngle", 0);
							
							TargetArea.WalkToGameObjID = info.gameobj_id;
							TargetArea.WalkToGameObjInstance = info.instance;
							TargetArea.WalkToGameObj_type = info.gameobj_type;
							TargetArea.WalkToGameObj_gsid = info.gsid;
							TargetArea.WalkToGameObj_page_url = info.page_url;
							TargetArea.Dest_X = dest_x;
							TargetArea.Dest_Z = dest_z;
							
						elseif(dist_xz <= pickdist and dist <= 1.5 * pickdist) then
							-- interact with game object
							if(info.gameobj_type == "GSItem") then
								TargetArea.PurchaseGameObject(info.gameobj_id, info.gsid);
							elseif(info.gameobj_type == "FreeItem") then
								TargetArea.PickGameObject(info.gameobj_id, info.instance, info.gsid);
							elseif(info.gameobj_type == "MCMLPage") then
								TargetArea.ReadGameObject(info.gameobj_id, info.page_url);
							end
						end
					end
					
					local Quest = MyCompany.Aries.Quest;
					local gameobjectChar = Quest.GameObject.GetGameObjectCharacterFromIDAndInstance(info.gameobj_id, info.instance);
					if(gameobjectChar and gameobjectChar:IsValid() == true) then
						local displayname = gameobjectChar:GetDynamicField("DisplayName", "");
						System.ShowHeadOnDisplay(true, gameobjectChar, displayname);
					end
				end
			end
		--elseif(info.type == "opc") then
			--info.nid
		--elseif(info.type == "opcmount") then
			--info.nid
		--elseif(info.type == "opcfollow") then
			--info.nid
		elseif(info.type == "opc" or info.type == "opcmount" or info.type == "opcfollow") then
			-- select OPC
			_targetArea.visible = true;
			if(info.nid) then
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({click_through = true,url=TargetArea.SelectionResponseURL["OtherPlayer"].."?nid="..info.nid});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
				TargetArea.TargetNID = info.nid;
				TargetArea.TargetNPC_id = nil;
				TargetArea.TargetNPC_instance = nil;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = nil;
			end
			
			---- turn off the high light of the last selected character
			--if(TargetArea.LastHighLightCharacterParam) then
				--local lastSelect = ObjEditor.GetObjectByParams(TargetArea.LastHighLightCharacterParam);
				--if(lastSelect:IsValid() == true) then
					--local att = lastSelect:GetAttributeObject();
					--att:SetField("render_tech", 10);
				--end
			--end
			---- high light the current selected character
			--local param = ObjEditor.GetObjectParams(selectObj);
			--TargetArea.LastHighLightCharacterParam = param;
			--local att = selectObj:GetAttributeObject();
			--att:SetField("render_tech", 9);
			
		elseif(info.type == "townchiefrodd") then
			-- select GM town chief rodd
			_targetArea.visible = true;
			if(info.nid) then
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({click_through = true,url=TargetArea.SelectionResponseURL["townchiefrodd"].."?nid="..info.nid});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
				TargetArea.TargetNID = info.nid;
				TargetArea.TargetNPC_id = nil;
				TargetArea.TargetNPC_instance = nil;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = nil;
			end
			
		elseif(info.type == "mountpetinhomeland") then
			_targetArea.visible = true;
			if(info.guid) then
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
					click_through = true,
					url = TargetArea.SelectionResponseURL["mountpetinhomeland"].."?guid="..info.guid,
				});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
				TargetArea.TargetNID = nil;
				TargetArea.TargetNPC_id = nil;
				TargetArea.TargetNPC_instance = nil;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = info.guid;
			end
			--info.guid
			--info.name
		elseif(info.type == "followpetinhomeland") then
			_targetArea.visible = true;
			if(info.guid) then
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
					click_through = true,
					url = TargetArea.SelectionResponseURL["followpetinhomeland"].."?guid="..info.guid,
				});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
				TargetArea.TargetNID = nil;
				TargetArea.TargetNPC_id = nil;
				TargetArea.TargetNPC_instance = nil;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = info.guid;
			end
			--info.guid
			--info.name
		elseif(info.type == "mountpetinotherhomeland") then
			_targetArea.visible = true;
			if(info.nid and info.guid) then
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
					click_through = true,
					url = TargetArea.SelectionResponseURL["mountpetinotherhomeland"].."?nid="..info.nid.."&guid="..info.guid,
				});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
				TargetArea.TargetNID = info.nid;
				TargetArea.TargetNPC_id = nil;
				TargetArea.TargetNPC_instance = nil;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = info.guid;
			end	
		elseif(info.type == "followpetinotherhomeland") then
			_targetArea.visible = true;
			if(info.nid and info.guid) then
				TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
					click_through = true,
					url = TargetArea.SelectionResponseURL["followpetinotherhomeland"].."?nid="..info.nid.."&guid="..info.guid,
				});
				TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
				TargetArea.TargetNID = info.nid;
				TargetArea.TargetNPC_id = nil;
				TargetArea.TargetNPC_instance = nil;
				TargetArea.TargetGameObj_id = nil;
				TargetArea.TargetGameObj_instance = nil;
				TargetArea.TargetPet_guid = info.guid;
			end
		elseif(info.type == "teleportportal-portal") then
			local player = ParaScene.GetPlayer();
			if(player and player:IsValid() == true and selectObj and selectObj:IsValid() == true) then
				-- walk to the teleportportal
				local p_x, p_y, p_z = player:GetPosition();
				local o_x, o_y, o_z = selectObj:GetPosition();
				player:ToCharacter():GetSeqController():MoveTo(o_x - p_x, 0, o_z - p_z);
			end
		elseif(info.type == "local") then
			-- local NPC 
			if(selectObj) then
				NPL.load("(gl)script/apps/Aries/Creator/AI/LocalNPC.lua");
				local LocalNPC = commonlib.gettable("MyCompany.Aries.Creator.AI.LocalNPC")
				LocalNPC:OnClickCharacter(selectObj);
			end
				
			-- TODO: shall we display something for local NPC ?
			TargetArea.TargetNID = nil;
			TargetArea.TargetNPC_id = nil;
			TargetArea.TargetNPC_instance = nil;
			TargetArea.TargetGameObj_id = nil;
			TargetArea.TargetGameObj_instance = nil;
			TargetArea.TargetPet_guid = nil;
			_targetArea.visible = false;
			
		elseif(info.type == "unknown") then
			-- unknown type
			TargetArea.TargetNID = nil;
			TargetArea.TargetNPC_id = nil;
			TargetArea.TargetNPC_instance = nil;
			TargetArea.TargetGameObj_id = nil;
			TargetArea.TargetGameObj_instance = nil;
			TargetArea.TargetPet_guid = nil;
			_targetArea.visible = false;
		elseif(info.type == "model") then
			-- model
			-- hide the target area
			TargetArea.TargetNID = nil;
			TargetArea.TargetNPC_id = nil;
			TargetArea.TargetNPC_instance = nil;
			TargetArea.TargetGameObj_id = nil;
			TargetArea.TargetGameObj_instance = nil;
			TargetArea.TargetPet_guid = nil;
			_targetArea.visible = false;
		elseif(info.type == "nothing") then
			-- select nothing
			-- hide the target area
			TargetArea.TargetNID = nil;
			TargetArea.TargetNPC_id = nil;
			TargetArea.TargetNPC_instance = nil;
			TargetArea.TargetGameObj_id = nil;
			TargetArea.TargetGameObj_instance = nil;
			TargetArea.TargetPet_guid = nil;
			_targetArea.visible = false;
			TargetArea.CloseSelectResponsePage();
		end
		if(info.type ~= "npc" and not bSkipCloseDialog) then
			-- close the npc dialog MCML page
			System.App.Commands.Call("File.MCMLWindowFrame", {
				name="NPC_Dialog", app_key = MyCompany.Aries.app.app_key, bShow = false});
		end
	end
end

-- just close the "SelectedTarget" mcml page and destroy the UI
function TargetArea.CloseSelectResponsePage()
	if(TargetArea.SelectResponsePage) then
		TargetArea.SelectResponsePage:Close();
		
		TargetArea.SelectResponsePage = nil;
		local _targetArea = ParaUI.GetUIObject("TargetArea");
		if(_targetArea:IsValid()) then
			_targetArea:GetChild("SelectedTarget"):RemoveAll();
		end
	end
end

function TargetArea.HideNPCSelectResponsePage()
	local _targetArea = ParaUI.GetUIObject("TargetArea");
	if(_targetArea:IsValid() == false) then
		log("error: TargetArea not created on TargetArea.ShowTarget() call\n");
		return;
	end
	
	_targetArea.visible = false;

	TargetArea.CloseSelectResponsePage();
end

function TargetArea.ShowNPCSelectPage(npc_id, instance)
	local _targetArea = ParaUI.GetUIObject("TargetArea");
	if(_targetArea:IsValid() == false) then
		log("error: TargetArea not created on TargetArea.ShowNPCSelectPage() call\n");
		return;
	end
	_targetArea.visible = true;
	local Quest = MyCompany.Aries.Quest;
	local NPCs = commonlib.getfield("MyCompany.Aries.Quest.NPCList.NPCs");
	TargetArea.SelectResponsePage = System.mcml.PageCtrl:new({
		url = Quest.NPC.GetNPCSelectedPageURL(npc_id, instance, TargetArea.SelectionResponseURL["NPC"])});
	TargetArea.SelectResponsePage:Create("SelectedTarget", _targetArea, "_fi", 0, 0, 0, 0);
end

function TargetArea.DoCheckWalkTalk()
	if(not TargetArea.TargetNPC_id or not TargetArea.WalkToNPCID) then
		-- do nothing
	else
		if(TargetArea.TargetNPC_id == nil) then
			TargetArea.WalkToNPCID = nil;
		end
		local player = ParaScene.GetPlayer();
		if(player and player:IsValid() == true) then
			local p_x, p_y, p_z = player:GetPosition();
			if(TargetArea.TargetNPC_id == TargetArea.WalkToNPCID and math.abs(TargetArea.Dest_X - p_x) < 0.01 and math.abs(TargetArea.Dest_Z - p_z) < 0.01) then
				player:ToCharacter():Stop();
				TargetArea.TalkToNPC(TargetArea.WalkToNPCID, TargetArea.WalkToNPCInstance);
				TargetArea.WalkToNPCID = nil;
			end
		end
	end
	
	if(not TargetArea.TargetGameObj_id or not TargetArea.WalkToGameObjID) then
		-- do nothing
	else
		if(TargetArea.TargetGameObj_id == nil) then
			TargetArea.WalkToGameObjID = nil;
		end		
		local player = ParaScene.GetPlayer();
		if(player and player:IsValid() == true) then
			local p_x, p_y, p_z = player:GetPosition();
			if(TargetArea.TargetGameObj_id == TargetArea.WalkToGameObjID and math.abs(TargetArea.Dest_X - p_x) < 0.01 and math.abs(TargetArea.Dest_Z - p_z) < 0.01) then
				if(TargetArea.WalkToGameObj_type == "GSItem") then
					TargetArea.PurchaseGameObject(TargetArea.WalkToGameObjID, TargetArea.WalkToGameObj_gsid);
				elseif(TargetArea.WalkToGameObj_type == "FreeItem") then
					TargetArea.PickGameObject(TargetArea.WalkToGameObjID, TargetArea.WalkToGameObjInstance, TargetArea.WalkToGameObj_gsid);
				elseif(TargetArea.WalkToGameObj_type == "MCMLPage") then
					TargetArea.ReadGameObject(TargetArea.WalkToGameObjID, TargetArea.WalkToGameObj_page_url);
				end
				TargetArea.WalkToGameObjID = nil;
			end
		end
	end
end

-- show the cursor from the scene object
-- @param obj: scene obj
-- @return: cursor name
function TargetArea.GetCursorFromSceneObject(obj)
	if(not obj or obj:IsValid() == false) then
		log("error: TargetArea.GetCursorFromSceneObject(obj) got nil or invalid obj\n");
		return;
	end
	local info = TargetArea.GetSelectedObjectInfo(obj);
	if(info) then
		if(info.type == "myself" or info.type == "mymount" or info.type == "myfollow") then
			-- mouse over myself
			return "aries_select";
		elseif(info.type == "npc") then
			-- mouse over NPC
			if(info.npc_id) then
				local Pet = MyCompany.Aries.Pet;
				local player = Pet.GetUserCharacterObj();
				
				if(player and player:IsValid() == true) then
					local cursorfile = obj:GetDynamicField("cursor", nil);
					local cursorname;
					if(cursorfile) then
						local file_tmp = string.match(cursorfile, "[%./]+")
						if(not file_tmp) then
							cursorname = cursorfile;
							cursorfile = nil;
						end
					end
					local dist = player:DistanceTo(obj);
					local talkdist = obj:GetDynamicField("TalkDist", TargetArea.DefaultNpcTalkDist);
					
					if(dist >= talkdist) then
						--return "talkgrey", cursorfile;
						return cursorname or "talk", cursorfile;
					else
						return cursorname or "talk", cursorfile;
					end
				end
			end
		elseif(info.type == "gameobject") then
			local GameObject = MyCompany.Aries.Quest.GameObject;
			local gameobj_char, gameobj_model = GameObject.GetGameObjectCharacterFromIDAndInstance(info.gameobj_id, info.instance);
			if(gameobj_model and gameobj_model:IsValid() == true) then
				ParaSelection.AddObject(gameobj_model, 2);
				---- set render technique
				--TargetArea.last_mousemove_gameobj_model = gameobj_model.name;
				--local render_tech = gameobj_model:GetField("render_tech", nil);
				--if(render_tech == 3) then
					--gameobj_model:SetField("render_tech", 10); -- TECH_SIMPLE_MESH_NORMAL_SELECTED
				--end
			end
			if(info.gameobj_type == "GSItem") then
				return "purchase";
			elseif(info.gameobj_type == "FreeItem") then
				return "pick";
			elseif(info.gameobj_type == "MCMLPage") then
				return "read";
				--info.gsid
				--info.page_url
			end
		elseif(info.type == "opc" or info.type == "opcmount" or info.type == "opcfollow") then
			-- mouse over OPC
			if(info.nid) then
				return "aries_select";
			end
		elseif(info.type == "unknown" or info.type == "model" or info.type == "nothing") then
			-- continue with the default cursor and process
			return "default";
		end
	end
	return "default";
end

-- show the cursor text from the scene object
-- @param obj: scene obj
-- @return: cursor text
function TargetArea.GetCursorTextFromSceneObject(obj)
	local Pet = MyCompany.Aries.Pet;
	if(not obj or obj:IsValid() == false) then
		log("error: TargetArea.GetCursorTextFromSceneObject(obj) got nil or invalid obj\n");
		return;
	end
	local info = TargetArea.GetSelectedObjectInfo(obj);
	if(info) then
		--if(info.type == "myself") then
		--elseif(info.type == "mymount") then
		--elseif(info.type == "myfollow") then
		if(info.type == "myself" or info.type == "mymount" or info.type == "myfollow") then
			-- cursor text myself
			local petCombatLevel = 1;
			local petname = "";
			local school_name = "正在获取";
			-- get pet level
			local bean = Pet.GetBean();
			if(bean) then
				petCombatLevel = bean.combatlel or 0;
				petname = bean.petname or "";
			end
			local gsid = Combat.GetSchoolGSID();
			if(gsid and gsid > 0) then
				school_name = Combat.GetSchoolNameByGSID(gsid);
			end
			if(info.type == "myself") then
				return (info.name or ""), petCombatLevel.."级 "..school_name.."系";
			elseif(info.type == "mymount") then
				return petname;
			elseif(info.type == "myfollow") then
				local followpet_mouseover_name_line1 = "";
				local followpet_mouseover_name_line2 = "";
				local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 32); -- position 32 is follow pet
				if(item and item.guid > 0 and item.GetMouseOverName) then
					followpet_mouseover_name_line1, followpet_mouseover_name_line2 = item:GetMouseOverName();
				end
				return followpet_mouseover_name_line1, followpet_mouseover_name_line2;
			end
		elseif(info.type == "npc") then
			-- cursor text NPC
			if(info.npc_id) then
				local name = info.cursor_text or info.name;
				if(name) then
					local text1, text2 = name:match("([^\n]*)[\n]?(.*)");
					if(text2 and text2== "") then
						text2 = nil;
					end
					return text1, text2;
				end
				return name or "";
			elseif(TargetArea.TargetNPC_id == info.npc_id) then
				return ;
			end
		elseif(info.type == "gameobject") then
			-- cursor text game object
			if(info.gameobj_id) then
				return info.name or "";
			end
		elseif(info.type == "local") then
			-- cursor text local character object
			return info.name or "";
			
		elseif(info.type == "opc" or info.type == "opcmount" or info.type == "opcfollow") then
			-- cursor text OPC
			if(info.nid) then
				if(info.is_minion) then
					local nickname = "正在获取";
					local ItemManager = System.Item.ItemManager;
					local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(info.nid);
					if(gsItem) then
						nickname = gsItem.template.name;
					end
					return nickname;
				end
				local nickname = "正在获取";
				local combat_level = nil;
				local combat_school = nil;
				local ProfileManager = System.App.profiles.ProfileManager;
				local Pet = MyCompany.Aries.Pet
				local ItemManager = System.Item.ItemManager;
				-- user nickname
				local userinfo = ProfileManager.GetUserInfoInMemory(info.nid);
				if(userinfo) then
					nickname = userinfo.nickname;
				else
					ProfileManager.GetUserInfo(info.nid, "GetCursorTextFromSceneObject", function(msg)
					end);
				end
				-- user level
				local otherbean = Pet.CreateOrGetDragonInstanceBean(info.nid,nil,"access plus 1 hour")
				if(otherbean) then
					combat_level = otherbean.combatlel or 0;
				end
				-- user school 
				local gsid = Combat.GetSchoolGSID(info.nid);
				if(gsid and gsid > 0) then
					combat_school = Combat.GetSchoolNameByGSID(gsid);
				else
					ItemManager.GetItemsInOPCBag(info.nid, 0, "GetCursorTextFromSceneObject_Bag0", function(msg)
						end, "access plus 1 hour");
				end
				
				local line2 = nil;
				if(combat_level and combat_school) then
					line2 = combat_level.."级 "..combat_school.."系";
				else
					line2 = "正在获取";
				end
				return (nickname or ""), line2;
			end
		elseif(info.type == "teleportportal-portal") then
			if(obj.name == "teleport-portal:1000") then
				return "离开家园";
			end
		elseif(info.type == "unknown" or info.type == "model" or info.type == "nothing") then
			-- cursor text nothing
			return "";
		end
	end
end

-- translate the object name to type, nid or pet .etc.
-- @param obj: character object
-- @return: the object info type and/or nid/npc_id
function TargetArea.GetSelectedObjectInfo(obj)
	local Pet = MyCompany.Aries.Pet;
	local Quest = MyCompany.Aries.Quest;
	local info = {};
	if(obj ~= nil and obj:IsValid()) then
		if(obj:IsCharacter()) then
			local name = obj.name;
			local nid = string.match(name, "^%d+");
			if(nid) then
				nid = tonumber(nid);
			end
			-- if name begins with number
			if(nid) then
				-- the current player
				local myself = MyCompany.Aries.Pet.GetUserCharacterObj();
				local myMount = MyCompany.Aries.Pet.GetUserMountObj();
				local myFollow = MyCompany.Aries.Pet.GetUserFollowObj();
				if(myself and obj:equals(myself)) then
					info.type = "myself";
					--NPL.load("(gl)script/apps/Aries/Player/main.lua");
					--local Player = MyCompany.Aries.Player;
					--info.name = obj:GetDynamicField("name", Player.RealPlayerName);
					info.name = System.User.NickName;
					return info;
				elseif(myMount and obj:equals(myMount)) then
					info.type = "mymount";
					local pet_name = "抱抱龙";
					local bean = MyCompany.Aries.Pet.GetBean();
					if(bean) then
						pet_name = bean.petname;
					end
					info.name = pet_name;
					return info;
				elseif(myFollow and obj:equals(myFollow)) then
					info.type = "myfollow";
					local att = obj:GetAttributeObject();
					local name = att:GetDynamicField("GlobalStoreName", "跟随宠物");
					info.name = "我的"..name;
					return info;
				end
				
				-- OPC characters
				local opc = Pet.GetUserCharacterObj(nid);
				local opcMount = Pet.GetUserMountObj(nid);
				local opcFollow = Pet.GetUserFollowObj(nid);
				if(opc and obj:equals(opc)) then
					info.type = "opc";
					info.nid = nid;
					local isGM = MyCompany.Aries.Scene.IsGMAccount(nid);
					if(isGM) then
						info.type = "townchiefrodd";
					end
					
					if(opcMount == nil) then
						-- no mount pet, opc object is the JGSL_agent updated character
						info.name = opc:GetDynamicField("name", tostring(nid));
						info.is_minion = opc:GetDynamicField("bMinion", false);
					else
						-- mount pet, opc object is driver object
						info.name = opcMount:GetDynamicField("name", tostring(nid));
						info.is_minion = opcMount:GetDynamicField("bMinion", false);
					end
					return info;
				elseif(opcMount and obj:equals(opcMount)) then
					info.type = "opcmount";
					info.nid = nid;
					if(opcMount == nil) then
						-- no mount pet, opc object is the JGSL_agent updated character
						info.name = opc:GetDynamicField("name", tostring(nid));
					else
						-- mount pet, opc object is driver object
						info.name = opcMount:GetDynamicField("name", tostring(nid));
					end
					return info;
				elseif(opcFollow and obj:equals(opcFollow)) then
					info.type = "opcfollow";
					info.nid = nid;
					local att = obj:GetAttributeObject();
					local gsName = att:GetDynamicField("GlobalStoreName", "跟随宠物");
					if(opcMount == nil) then
						-- no mount pet, opc object is the JGSL_agent updated character
						info.name = opc:GetDynamicField("name", tostring(nid)).."的"..gsName;
					else
						-- mount pet, opc object is driver object
						info.name = opcMount:GetDynamicField("name", tostring(nid)).."的"..gsName;
					end
					return info;
				end
				
				-- mount pet in other homeland
				local nid, guid = string.match(name, "^(%d+)MountPet:(%d+)$")
				if(nid and guid) then
					nid = tonumber(nid);
					guid = tonumber(guid);
					info.type = "mountpetinotherhomeland";
					info.nid = nid;
					info.guid = guid;
					return info;
				end
				
				-- follow pet in other homeland
				local nid, guid = string.match(name, "^(%d+)FollowPet:(%d+)$")
				if(nid and guid) then
					nid = tonumber(nid);
					guid = tonumber(guid);
					info.type = "followpetinotherhomeland";
					info.nid = nid;
					info.guid = guid;
					return info;
				end
			
			elseif(string.match(name, "^NPC:")) then
				-- NPC object
				local npc_id, instance = Quest.NPC.GetNpcIDAndInstanceFromCharacter(obj);
				local name, cursor_text = Quest.NPC.GetNpcDisplayNameFromID(npc_id, instance);
				info.type = "npc";
				info.name = name;
				info.cursor_text = cursor_text;
				info.npc_id = npc_id;
				info.instance = instance;
				return info;
				
			elseif(string.match(name, "^local:")) then
				-- local object
				info.type = "local";
				info.name = obj:GetDynamicField("DisplayName", "");
				return info;
				
			elseif(string.match(name, "^GameObject:")) then
				-- Game Object
				local gameobj_id, instance = Quest.GameObject.GetGameObjIDAndInstanceFromCharacter(obj);
				local name = Quest.GameObject.GetGameObjectDisplayNameFromID(gameobj_id);
				info.type = "gameobject";
				info.name = name;
				info.gameobj_id = gameobj_id;
				info.instance = instance;
				local gameobjectChar = Quest.GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id, instance);
				info.gameobj_type = gameobjectChar:GetDynamicField("gameobj_type", nil);
				info.gsid = gameobjectChar:GetDynamicField("gsid", nil);
				info.page_url = gameobjectChar:GetDynamicField("page_url", nil);
				info.download_list = gameobjectChar:GetDynamicField("download_list", nil);
				
				return info;
			
			elseif(string.match(name, "^teleport%-portal:")) then
				-- teleport portal source
				local id = string.gsub(name, "teleport%-portal:", "");
				info.type = "teleportportal-portal";
				info.id = tonumber(id);
				return info;
			elseif(string.match(name, "^teleport%-dest:")) then
				-- teleport portal destination
				local id = string.gsub(name, "teleport%-dest:", "");
				info.type = "teleportportal-dest";
				info.id = tonumber(id);
				return info;
			elseif(name == "invisible camera") then
				-- camera focus object
				info.type = "camera";
				return info;
			end
			
			-- mount pet in Homeland
			local guid = string.match(name, "^MyMountPet:(%d+)$")
			if(guid) then
				guid = tonumber(guid);
				local item = Pet.GetUserPetInMemory(guid);
				if(item) then
					info.type = "mountpetinhomeland";
					info.guid = guid;
					local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid)
					if(gsItem) then
						info.name = gsItem.template.name;
					end
					return info;
				end
			end
			
			-- follow pet in Homeland
			local guid = string.match(name, "^MyFollowPet:(%d+)$")
			if(guid) then
				guid = tonumber(guid);
				local item = Pet.GetUserPetInMemory(guid);
				if(item) then
					info.type = "followpetinhomeland";
					info.guid = guid;
					local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid)
					if(gsItem) then
						info.name = gsItem.template.name;
					end
					return info;
				end
			end
			
			info.type = "unknown";
			log("error: unknown type for character:"..name.." in TargetArea.GetSelectedObjectInfo(obj)\n");
			return info;
		else
			-- select model
			info.type = "model";
			return info;
		end
	else
		-- deselect object
		info.type = "nothing";
		return info;
	end
end

---- check if the object is OPC character
---- @return true if is OPC, otherwise false
--function TargetArea.IsOPC(obj)
	--if(obj and obj:IsValid() == true) then
		--local att = obj:GetAttributeObject();
		--local isOPC = att:GetDynamicField("IsOPC", false);
		--if(isOPC == true) then
			--return true;
		--end
	--end
	--return false;
--end

function TargetArea.ShowSelectedOPCProfile()
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = TargetArea.TargetNID});
end

function TargetArea.ShowMyselfProfile()
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = System.App.profiles.ProfileManager.GetNID()});
end

function TargetArea.ShowMountPetProfile()
	System.App.Commands.Call("Profile.Aries.ShowMountPetProfile");
end

function TargetArea.ShowCurrentFollowPetProfile()
	System.App.Commands.Call("Profile.Aries.ShowCurrentFollowPetProfile");
end

function TargetArea.ShowSelectedFollowPetInfoInHomeland()
	System.App.Commands.Call("Profile.Aries.ShowSelectedFollowPetInfoInHomeland", {guid = TargetArea.TargetPet_guid});
end

function TargetArea.ShowSelectedOPCMountPetProfile()
	-- NOTE to Leio: the remote value is not garenteed currently, because only current visited homeland pet info is valid in memory
	NPL.load("(gl)script/apps/Aries/Inventory/TabMountOthers.lua");
	MyCompany.Aries.Inventory.TabMountOthersPage.ShowPage(TargetArea.TargetNID);
end

function TargetArea.ShowSelectedOPCFollowPetProfile()
	System.App.Commands.Call("Profile.Aries.ShowSelectedFollowPetInfoInHomeland", {guid = TargetArea.TargetPet_guid, nid = TargetArea.TargetNID});
end

-- @param bAutoSelect: auto select or focus on the NPC
function TargetArea.TalkToNPC(id, instance, bAutoSelect)
	local NPC = MyCompany.Aries.Quest.NPC;
	if(bAutoSelect == true) then
		local npc_char = NPC.GetNpcCharacterFromIDAndInstance(id, instance);
		if(npc_char) then
			-- select the npc
			System.SendMessage_obj({type = System.msg.OBJ_SelectObject, obj = npc_char});
		end
	end
	
	local isAntiSystemIsEnabled = false;
	local AntiIndulgence = commonlib.getfield("System.App.MiniGames.AntiIndulgence");
	if(AntiIndulgence) then
		isAntiSystemIsEnabled = AntiIndulgence.IsAntiSystemIsEnabled();
	end
	
	-- NOTE 2010/2/3: comment the following line and return to normal antiindulgence
	--					designers requested a mode for non antiindulgence normal NPCs only mini games are antiindulgence enabled
	local NPCs = commonlib.getfield("MyCompany.Aries.Quest.NPCList.NPCs");
	if(NPCs and NPCs[id] and NPCs[id].main_script and not string.find(NPCs[id].main_script, "30161")) then
		isAntiSystemIsEnabled = false;
	end
	
	if(isAntiSystemIsEnabled) then
		if(NPCs and NPCs[id] and NPCs[id].dialogstyle_antiindulgence) then
			-- show newbiequest help dialog
			local url = "script/apps/Aries/Desktop/GUIHelper/AntiIndulgence_dialog.html";
			if(id) then
				url = url.."?npc_id="..id;
			end
			if(instance) then
				url = url.."&instance="..instance;
			end
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = url, 
				app_key = MyCompany.Aries.app.app_key, 
				name = "NPC_Dialog", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				allowDrag = false;
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				directPosition = true,
					align = "_lb",
						x = 41,					
						y = -165,
						width = 900,
						height = 130,
					--	x = 41,					
					--	y = 165,
					--	width = 204,
					--	height = 430,
			});
		else
			TargetArea.ShowAntiIndulgenceBox()
		end
	else
		NPC.TalkToNPC(id, instance);
	end
end

function TargetArea.RefreshSelectResponsePage()
	if(TargetArea.SelectResponsePage) then
		TargetArea.SelectResponsePage:Refresh(0.01);
	end
end

function TargetArea.ShowAntiIndulgenceBox()
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:24px;">你今天已经在哈奇小镇玩了太长时间，先休息一下，明天再来玩吧！</div>]]);
end

-- purchase game object 
-- @gameobj_id: game object id
-- @gsid: global store id of the game object
function TargetArea.PurchaseGameObject(gameobj_id, gsid)
	if(System.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled()) then
		TargetArea.ShowAntiIndulgenceBox()
		return;
	end
	System.mcml_controls.pe_item.OnClickGSItem(gsid);
end

-- pick game object 
-- @gameobj_id: game object id
-- @gsid: global store id of the game object
function TargetArea.PickGameObject(gameobj_id, instance, gsid)
	-- NOTE 2010/2/3: uncomment the following line and return to normal antiindulgence
	--					designers requested a mode for non antiindulgence normal NPCs only mini games are antiindulgence enabled
	--if(System.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled()) then
		--TargetArea.ShowAntiIndulgenceBox()
		--return;
	--end
	local Quest = MyCompany.Aries.Quest;
	local gameobjectChar = Quest.GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id, instance);
	if(gameobjectChar and gameobjectChar:IsValid() == true) then
		local pick_count = gameobjectChar:GetDynamicField("pick_count", 1);
		local onpick_msg = gameobjectChar:GetDynamicField("onpick_msg", "");
		local respawn_interval = gameobjectChar:GetDynamicField("respawn_interval", nil);
		local isdeleteafterpick = gameobjectChar:GetDynamicField("isdeleteafterpick", false);
		if(gsid == 0) then
	        -- hard code the AddMoney here, move to the game server in the next release candidate
	        local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
	        if(AddMoneyFunc) then
		        AddMoneyFunc(pick_count, function(msg) 
			        log("======== TargetArea.PickGameObject JoyBean:"..pick_count.." returns: ========\n")
			        commonlib.echo(msg);
					if(msg.issuccess == true) then
						TargetArea.ShowTarget("");
						if(isdeleteafterpick == true) then
							Quest.GameObject.DeleteGameObjectCharacter(gameobj_id, instance);
						end
						-- send log information
						paraworld.PostLog({action = "joybean_obtain_from_other", joybeancount = pick_count, desc = "UnKnownGameObject"}, 
							"joybean_obtain_from_other_log", function(msg)
						end);
					end
		        end);
	        end
		elseif(gsid and gsid > 0) then
			local PickItem = function()
				local ItemManager = System.Item.ItemManager;
				ItemManager.PurchaseItem(gsid, pick_count, function(msg)
					if(msg) then
						log("+++++++Purchase PickGameObject:"..tostring(gsid).." return: +++++++\n")
						commonlib.echo(msg);
						if(msg.issuccess == true) then
							TargetArea.ShowTarget("");
							if(isdeleteafterpick == true) then
								Quest.GameObject.DeleteGameObjectCharacter(gameobj_id, instance);
								if(respawn_interval) then
									Quest.GameObject.AppendRespawn(gameobj_id, instance, respawn_interval);
								end
							end
							
							-- call hook for OnGameObjectPick
							local hook_msg = { aries_type = "OnGameObjectPick", 
								gameobj_id = gameobj_id, 
								instance = instance,
								gsid = gsid, 
								count = pick_count, 
								wndName = "main",
							};
							CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
							
							--local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid)
							--local name = "";
							--if(gsItem) then
								--name = gsItem.template.name;
								--_guihelper.MessageBox(pick_count.."个["..name.."]已经放入你的背包中了。");
							--end
						end
					end
				end, function(msg) end, nil, "pick");
			end
			if(onpick_msg and onpick_msg ~= "") then
				_guihelper.MessageBox(onpick_msg, function(res)
					if(res and res == _guihelper.DialogResult.OK) then
						PickItem();
					end
				end, _guihelper.MessageBoxButtons.OK);
			else
				PickItem();
			end
		end
	else
		log("invalid GameObject object in TargetArea.PickGameObject\n")
	end
end

-- read game object url in pagectrl
-- @gameobj_id: game object id
-- @page_url: MCML page ctrl url
function TargetArea.ReadGameObject(gameobj_id, page_url)
	if(System.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled()) then
		TargetArea.ShowAntiIndulgenceBox()
		return;
	end
	--获取要下载的文件列表
	NPL.load("(gl)script/apps/Aries/Books/BookPreloadAssets.lua");
	local download_list = MyCompany.Aries.Books.BookPreloadAssets.GetAssetList(page_url);
	
	commonlib.echo({gameobj_id, page_url, download_list});
	local Quest = MyCompany.Aries.Quest;
	
	function showpage()
		local displayname = Quest.GameObject.GetGameObjectDisplayNameFromID(gameobj_id)
		TargetArea.ShowURLAsGameObjectMCMLPage(page_url);
	end
	if(download_list)then
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
		Map3DSystem.App.MiniGames.PreLoaderDialog.StartDownload({download_list = download_list,txt = {"正在打开图书，请稍等......"}},function(msg)
			commonlib.echo(msg);
			if(msg and msg.state == "finished")then
				showpage();
			end
		end)
	else
		showpage()
	end
end

function TargetArea.ShowURLAsGameObjectMCMLPage(url)
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		name = "GameObjectMCMLBrowser", 
		isShowTitleBar = false,
		allowDrag = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = style,
		zorder = 2,
        allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
				x = -848/2,
				y = -600/2 + 40,
				width = 848,
				height = 620,
	});
end

function TargetArea.ShowDialogStyleMessageBox(npc_id, instance, text)
	-- show newbiequest help dialog
	local url = "script/apps/Aries/Desktop/GUIHelper/CommonMessageBoxStyle_dialog.html";
	if(npc_id) then
		url = url.."?npc_id="..npc_id;
	end
	if(instance) then
		url = url.."&instance="..instance;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "NPC_Dialog", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		allowDrag = false;
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		directPosition = true,
		align = "_ctb",
			x = 0,
			y = 22,
			width = 900,
			height = 230,
	});
	
	-- set messagebox style dialog 
	TargetArea.Text_DialogStyleMessageBox = text;
end

function TargetArea.FollowSelectedMountPet()
	if(TargetArea.TargetPet_guid) then
		local item = System.Item.ItemManager.GetItemByGUID(TargetArea.TargetPet_guid);
		if(item and item.guid > 0 and item.FollowMe) then
			item:FollowMe(function(msg)
				-- refresh the pets in homeland
				MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
			end);
		end
	end
end

function TargetArea.EquipSelectedFollowPet()
	local bEquipFollowPet = false;
	local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 32);
	if(item and item.guid > 0) then
		-- valid item
		bEquipFollowPet = true;
	end
	local selectObj = System.obj.GetObject("selection");
	if(selectObj and selectObj:IsValid() == true) then
		if(TargetArea.TargetPet_guid) then
			local item = System.Item.ItemManager.GetItemByGUID(TargetArea.TargetPet_guid);
			if(item and item.guid > 0 and item.FollowMe) then
				item:FollowMe(function(msg) -- NOTE: this is a preemptive callback
					if(msg and msg.issuccess == true) then
						--local Pet = MyCompany.Aries.Pet;
						--if(bEquipFollowPet == true) then
							---- secretly swap the names of selected object and the follow pet
							--ParaScene.Detach(selectObj);
							--selectObj.name = Pet.GetMyPetNameInHomeland(item.guid);
							--ParaScene.Attach(selectObj);
							--local _followpet = Pet.GetUserFollowObj();
							--local x1, y1, z1 = selectObj:GetPosition();
							--local x2, y2, z2 = _followpet:GetPosition();
							--selectObj:SetPosition(x2, y2, z2);
							--_followpet:SetPosition(x1, y1, z1);
							---- TODO: swap facing too
							--
							--
							----ParaScene.Detach(selectObj);
							----selectObj.name = Pet.GetUserFollowPetName();
							----ParaScene.Attach(selectObj);
							----local _followpet = Pet.GetUserFollowObj();
							----ParaScene.Detach(_followpet);
							----_followpet:SetName(Pet.GetMyPetNameInHomeland(TargetArea.TargetPet_guid));
							----ParaScene.Attach(_followpet);
						--elseif(bEquipFollowPet == false) then
							---- secretly modify the name of selected object to the follow pet
							--ParaScene.Detach(selectObj);
							--selectObj.name = Pet.GetUserFollowPetName();
							--ParaScene.Attach(selectObj);
						--end
					
						NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
						Map3DSystem.App.HomeLand.HomeLandGateway.Before_ReloadFollowPetItems()
						-- refresh the pets in homeland
						MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
					
						-- refresh the avatar, mount pet and follow pet
						System.Item.ItemManager.RefreshMyself();
						-- refresh all <pe:player>
						Map3DSystem.mcml_controls.GetClassByTagName("pe:player").RefreshContainingPageCtrls();
					
					
						Map3DSystem.App.HomeLand.HomeLandGateway.ReloadFollowPetItems()
					end
				end);
			end
		end
	end
end

function TargetArea.HideSelectedFollowPet()
	if(TargetArea.TargetPet_guid) then
		local item = System.Item.ItemManager.GetItemByGUID(TargetArea.TargetPet_guid);
		if(item and item.guid > 0) then
			local item_gsid = item.gsid;
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid)
			if(gsItem) then
				NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
				Map3DSystem.App.HomeLand.HomeLandGateway.SetValue_PetLocalShowInfo(item_gsid, false);
			end
		end
	end
end

function TargetArea.FreeSelectedFollowPet()
	if(TargetArea.TargetPet_guid) then
		local item = System.Item.ItemManager.GetItemByGUID(TargetArea.TargetPet_guid);
		if(item and item.guid > 0) then
			local item_gsid = item.gsid;
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid)
			if(gsItem) then
				local name = gsItem.template.name;
				local guid = TargetArea.TargetPet_guid;
				_guihelper.MessageBox("你确认要把你的"..name.."放生吗？", function(result)
					if(_guihelper.DialogResult.Yes == result) then
						-- deselect object and set new position
						System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
						-- destroy pet item
						System.Item.ItemManager.DestroyItem(guid, 1, function() 
							log("+++++++ Destroy "..name.." guid:"..guid.." return: +++++++\n")
							commonlib.echo(msg);
							-- refresh myself
							System.Item.ItemManager.RefreshMyself();
							-- refresh all pets in homeland
							MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
							-- send log information
							paraworld.PostLog({action = "followpet_free", gsid = item_gsid}, 
								"followpet_free_log", function(msg)
							end);
						end);
						-- 10107_FollowPetXJBB
						local npc_id;
						if(item.gsid == 10107) then
							commonlib.echo("TODO: hardcode the message here for fleachick free procedure");
							--TODO: record the npc_id in follow pet global store template
							npc_id = 30202;
						end
						if(npc_id) then
							MyCompany.Aries.Quest.NPCBagManager.DestroyNPCBagItemsInMemory(npc_id);
						end
					elseif(_guihelper.DialogResult.No == result) then
						-- do nothing
					end
				end, _guihelper.MessageBoxButtons.YesNo);
			end
		end
	end
end

function TargetArea.AddCurrentSelectionAsFriend()
	-- TODO: get the nid from the current selected OPC
	MyCompany.Aries.Friends.AddFriendByNIDWithUI(TargetArea.TargetNID);
end

function TargetArea.GotoCurrentSelectionHome()
	System.App.profiles.ProfileManager.GetUserInfo(TargetArea.TargetNID, "TargetNID", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local uid = msg.users[1].userid;
			local nid = msg.users[1].nid;
			System.App.Commands.Call("Profile.Aries.GotoHomeLand", {uid = uid, nid = nid});
		end
	end);
end