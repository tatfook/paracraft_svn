--[[
Title: Common functions for wisp client behavior
Author(s): Gosling, refactored by LiXizhi on 2011.5.29
Date: 2010/6/11
Desc: 
<wisp_scenes>
	<wisp_scene update_interval="180000">
		<key name="wisp_scene_name_haqi"/>
		<instances copies="2" positions="{{20193.215,3.949,20012.939,},{20194.357,4.07,20018.508,}}"/>
	</wisp_scene>
</wisp_scenes>
| *attribute name* | *description* |
| update_interval | how many milliseconds to respawn all wisps in the scene |
| isntances.copies | total number of wisps in the scene |
| isntances.positions | wisp positions. please note that wisp positions are only used on client. The server does not care about it. |

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Combat/30397_Wisp.lua");
------------------------------------------------------------
]]

-- create class
local libName = "Wisp";
local Wisp = commonlib.gettable("MyCompany.Aries.Quest.NPCs.Wisp");


local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local Quest = commonlib.gettable("MyCompany.Aries.Quest");
local GameObject = commonlib.gettable("MyCompany.Aries.Quest.GameObject");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local UIAnimManager = commonlib.gettable("UIAnimManager");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = commonlib.gettable("ItemManager.IfOwnGSItem");
local equipGSItem = commonlib.gettable("ItemManager.IfEquipGSItem");

local pi = math.pi;


-- mapping from wisp config file name to wisp config data. 
-- we will cache all wisp files 
local wisp_templates = {};

-- static function: loading wisp configuration template file from config_file
-- calling this function with same config_file will return cached data
function Wisp.GetWispTemplateFromConfigFile(config_file)
	if(not config_file or config_file == "") then
		return;
	end
	local wisp_template = wisp_templates[config_file];
	if(not wisp_template) then
		-- load the template if not loaded before.
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		if(not xmlRoot) then
			LOG.std(nil, "warn","wisp","failed loading wisp_scene config file: %s\n", config_file);
			wisp_templates[config_file] = empty_wisp_template;
			return empty_wisp_template;
		end
		
		wisp_template = {all_wisp_count=0};
		local wisp_scenes = {};
		wisp_template.wisp_scenes = wisp_scenes;
		
		-- load all wisp scene
		local i = 1;
		local all_copies=0;
		local each_wisp_scene,instances;
		for each_wisp_scene in commonlib.XPath.eachNode(xmlRoot, "/wisp_scenes/wisp_scene") do
			local wisp_begin = 0;
			local wisp_end = 0;
			local update_count = tonumber(each_wisp_scene.attr.update_count);
			local update_interval = tonumber(each_wisp_scene.attr.update_interval);
			local clear_afterupdate = tonumber(each_wisp_scene.attr.clear_afterupdate);
			
			if(update_count and update_interval and clear_afterupdate) then
				wisp_scenes[i] = {};
				wisp_scenes[i].update_count = update_count;
				wisp_scenes[i].update_interval = update_interval;
				wisp_scenes[i].clear_afterupdate = clear_afterupdate;
				for instances in commonlib.XPath.eachNode(each_wisp_scene, "/instances") do
					local copies = tonumber(instances.attr.copies);
					wisp_begin = all_copies + 1;
					wisp_end =  all_copies + copies;
					wisp_scenes[i].range = {wisp_begin,wisp_end};
					all_copies = wisp_end;

					if(instances.attr.positions) then
						local positions = NPL.LoadTableFromString(instances.attr.positions);
						if(positions) then
							wisp_scenes[i].positions = positions;
						end
					end
				end
			end		
			i = i + 1;
		end
		wisp_template.all_wisp_count = all_copies;
		if(all_copies > 0) then
			wisp_templates[config_file] = wisp_template;
		else
			-- if no wisps in the scene
			wisp_templates[config_file] = empty_wisp_template;
		end
		LOG.std(nil, "system","wisp","loaded wisp config file %s. %d wisps in %d wisp scenes",config_file, all_copies, #wisp_scenes);
	end
	return wisp_templates[config_file];
end

-- load wisp file according to current world info
-- this function is called on every world load
function Wisp.InitScene()
	local self = Wisp;
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local world_info = WorldManager:GetCurrentWorld()
	
	local config_file = world_info.wisp_scene;
	if(not config_file) then
		LOG.std(nil, "debug","wisp","wisp_scene config file is nil for current world");
		return;
	end

	-- load from config file. 
	self.instances = {};
	self.wisp_scenes = {};
	self.wispscene_count = 0;
	self.all_wisp_count = 0;
	-- mapping from wisp_id to their positions {x, y, z}
	self.positions = {};
	-- clear wisp memory upon reload
	local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
	NPCAIMemory.GetMemory(30397);
	Wisp.last_wisp_id = nil;

	local wisp_template = Wisp.GetWispTemplateFromConfigFile(config_file);

	if(wisp_template) then
		local i;
		for i = 1, #(wisp_template.wisp_scenes) do
			local wisp_scene = commonlib.deepcopy(wisp_template.wisp_scenes[i]);
			self.wisp_scenes[#(self.wisp_scenes)+1] = wisp_scene;
			local positions = wisp_scene.positions;
			if(positions) then
				local wisp_begin = wisp_scene.range[1];
				local index;
				for index = 1, #positions do
					self.positions[wisp_begin+index-1] = positions[index];
				end
			end
		end
		self.all_wisp_count = self.all_wisp_count + wisp_template.all_wisp_count;
	end
	self.wispscene_count = #(self.wisp_scenes);
	local i;
	for i = 1, self.all_wisp_count do
		self.instances[i] = 0;
	end
end

-- called when NPC is loaded. 
function Wisp.main()
end

-- convert wisp id to npc id
function Wisp.ToNPCid(index)
	return 30397000 + index;
end

-- convert NPC id to wisp id
function Wisp.ToWispId(index)
	return index - 30397000;
end

-- get wisp position by wisp id. 
function Wisp:GetWispPositionByInstID(wisp_id)
	local position = self.positions[wisp_id];
	if(not position) then
		return;
	else 
		return position[1], position[2], position[3];
	end
end

-- get the index range of a given scene
function Wisp:GetScene(wispscene_index)
	return self.wisp_scenes[wispscene_index];
end

-- get the total number of scenes. usually there is only one wisp scene per world.
function Wisp:GetSceneCount()
	return self.wispscene_count or 0;
end

function Wisp.CreateWisp(index, offsety, serverobject_id)
	if(Wisp.IsWispVisualized(index)) then
		return;
	end
	Wisp.instances[index] = 1;

	local npcid = Wisp.ToNPCid(index);
	if(NPC.GetNpcCharacterFromIDAndInstance(npcid)) then
		return;
	end
	
	local x,y,z = Wisp:GetWispPositionByInstID(index);
	if(not x) then
		return;
	end
	y = y + (offsety or 0.3);
	

	local assetfile = "character/v5/09effect/Wisp/Wisp.x";
	local params = {
		name = "",
		isalwaysshowheadontext = false,
		position = {x,y,z},
		assetfile_char = assetfile,
		facing = 0,
		scaling = 0.5,
		main_script = "script/apps/Aries/NPCs/Combat/30397_Wisp.lua",
		PerceptiveRadius = 2,
		SentientRadius = 2,
		AI_script = "script/apps/Aries/NPCs/Combat/30397_Wisp_AI.lua",
		FrameMoveInterval = 300,
		On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.Wisp_AI.On_FrameMove();",
		talkdist = 2,
		predialog_function = "MyCompany.Aries.Quest.NPCs.Wisp.Wisp_PreDialog",
		EnablePhysics = false,
		cursor = "Texture/Aries/Cursor/Pick.tga",
	};
	local box, boxModel = NPC.CreateNPCCharacter(npcid, params);
end

-- destroy wisp
function Wisp.DestroyWisp(index)
	if(Wisp.instances[index] == 1) then
		Wisp.instances[index] = 0;
		local npcid = Wisp.ToNPCid(index);
		NPC.DeleteNPCCharacter(npcid);
	end
end

-- check if wisp visualized in scene
function Wisp.IsWispVisualized(index)
	return (Wisp.instances[index] == 1);
end

-- Wisp timer
function Wisp.On_Timer()
	--commonlib.applog(string.format("Wisp.On_Timer: start"));
end

function Wisp.PreDialog()
	return true;
end

-- pick the wisp by id. Call this function as frequent as one like. 
-- internally it will avoid picking the same wisp twice. 
function Wisp.TryPick(wisp_id)
	if(Wisp.last_wisp_id ~= wisp_id) then
		-- this will avoid picking the wisp twice. 
		-- a more accurate way is to check the time diff. But for simplicity we just check the id. 
		if(not MsgHandler.IsFullHealth()) then
			Wisp.last_wisp_id = wisp_id;

			Map3DSystem.GSL_client:SendRealtimeMessage("s30397", {type="try_pick", wisp_id=wisp_id});
			
			-- fix a bug that picking the same pips twice will fail
			-- clear last wisp id after 6 seconds. 
			Wisp.mytimer = Wisp.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
				Wisp.last_wisp_id = nil;
			end})
			Wisp.mytimer:Change(6000, nil);
		end
	end
end

function Wisp.Wisp_PreDialog(targetNPC_id)
	if(targetNPC_id) then
		local instance_id = Wisp.ToWispId(targetNPC_id);
		Wisp.TryPick(instance_id);
	end
	return false;
end

local heal_audio_file = "Audio/Haqi/Combat/Heal.ogg"

-- Wisp timer
function Wisp.OnRecvWisp(index)
	if(MsgHandler) then
		local result = MsgHandler.HealByWisp(1, true);
		if(result) then
			--MyCompany.Aries.Scene.PlayGameSound("Audio/Haqi/Combat/Casting02.wav");
			
			local audio_src = AudioEngine.CreateGet(heal_audio_file);
			if(audio_src.file ~= heal_audio_file) then
				-- load plain audio. 
				audio_src.file = heal_audio_file;
				audio_src.inmemory = true;
			end
			audio_src:play();
			Wisp.PickEffect(index);
		end
	end
end

function Wisp.GetAngle(x,z)
	local r = math.sqrt(x*x + z*z);
	local angle = math.asin(z/r);
	if(x < 0) then
		angle = pi - angle;
	end
	return angle;
end

-- Wisp 
function Wisp.PickEffect(index)
	local duration_time = 3000;
	local last_elapsedTime = 0;
	local wisp_name = "wisp_name_"..index;
	
	local StartAngle;
	local StartRadius;
	local NewRadius;
	local AngleMutiple;
	local AngleMutiple2;
	local StartAngleSpeed;
	local MidSpeed = 0;
	local stepMutiple = 1;
	local MidTime = 0;
	local MidAngle = 0;
	local Acc1;
	local Acc2;
	local isHitEffect = false;

	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		if(elapsedTime == 0) then
			---- begin animation, create new effect object
			--commonlib.applog(string.format("Wisp.PickEffect: time:%u,%u",elapsedTime,duration_time));
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(wisp_name);
				--assetfile =  "character/v5/06quest/Bubbles/Bubbles_a.x";
				assetfile =  "character/v5/09effect/Wisp/Wisp.x"
				local asset = ParaAsset.LoadParaX("", assetfile);
				local obj = ParaScene.CreateCharacter(wisp_name, asset , "", true, 1.0, 0, 1.0);
				if(obj and obj:IsValid() == true) then
					local npcid = Wisp.ToNPCid(index);
					local myWisp = NPC.GetNpcCharacterFromIDAndInstance(npcid);
					if(myWisp) then
						--obj:SetScale(5);
						obj:SetPosition(myWisp:GetPosition());
						effectGraph:AddChild(obj);
					end
				end
			end
		elseif(elapsedTime ~= duration_time) then
			--commonlib.applog(string.format("Wisp.PickEffect: time:%u,%u",elapsedTime,duration_time));
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				local obj = effectGraph:GetObject(wisp_name);
				
				if(obj and obj:IsValid() == true) then					
					--local npcid = Wisp.ToNPCid(index);
					--local myWisp = NPC.GetNpcCharacterFromIDAndInstance(npcid);
					local player = ParaScene.GetPlayer();
					--if(myWisp and myWisp:IsValid() == true) then
						local wx, wy, wz = obj:GetPosition();
						local px, py, pz = player:GetPosition();
						if(StartAngle == nil or StartRadius == nil) then
							StartAngle = Wisp.GetAngle(wx-px, wz-pz);
							StartRadius = math.sqrt((wx-px)*(wx-px) + (wz-pz)*(wz-pz));
							NewRadius = StartRadius;
							if(StartRadius > 2*(12/11)) then							
								--angle to zip pi/2
								local AngleTo90 = 2*3*pi*(1-2/StartRadius);
								if((1-2/StartRadius) > 0.5) then
									AngleTo90 = 0.5*2*3*pi;
									stepMutiple = (1-2/StartRadius)/0.5;
								end
								local AngleOther = 2*3*pi - AngleTo90;
								AngleMutiple = (pi/2)/AngleTo90;
								AngleMutiple2 = (11*pi/2)/AngleOther;
								--mid can not set,go to 2*AngleMutiple first
								if(AngleMutiple2 > 2 * AngleMutiple) then
									MidSpeed = 2 * AngleMutiple;								
								else
									MidSpeed = (AngleMutiple+AngleMutiple2)/2;
								end
								StartAngleSpeed = ((2*AngleMutiple)-MidSpeed)/2;
								Acc1 = (MidSpeed - StartAngleSpeed)/(StartRadius-2);
								Acc2 = (AngleMutiple2 - MidSpeed)/2;
							end
							-- commonlib.applog(string.format("Wisp.PickEffect: StartAngle:%f,StartRadius:%f",StartAngle,StartRadius));
						end
						local step_time = elapsedTime - last_elapsedTime;
						local step = step_time/(duration_time - last_elapsedTime);
						--local npx,npy,npz = wx+(px-wx)*step, wy+(py-wy)*step, wz+(pz-wz)*step
						--local angle = StartAngle - ((elapsedTime/duration_time)*2*pi*3);
						--NewRadius = ((duration_time-last_elapsedTime)/duration_time) * StartRadius;
						--if(NewRadius > 2) then
							--NewRadius = NewRadius - (StartRadius - 2) * 3 * 4 * step;
						--else
							--NewRadius = NewRadius - step * NewRadius;
						--end

						if(AngleMutiple) then
							if(NewRadius>2) then
								--angle = StartAngle - ((elapsedTime/duration_time)*2*pi*3)*(AngleMutiple);
								angle = StartAngle - ((elapsedTime/duration_time)*2*pi*3)*(StartAngleSpeed+Acc1*(StartRadius-2));
								MidTime = elapsedTime;
								MidAngle = StartAngle- angle;
								NewRadius = NewRadius - step * (StartRadius -2 ) * stepMutiple;
								if(NewRadius < 2) then
									NewRadius = 2;
								end
							else
								angle = StartAngle - MidAngle - (((elapsedTime-MidTime)/duration_time)*2*pi*3)*(AngleMutiple2);
								--angle = StartAngle - pi/2 - (((elapsedTime-MidTime)/duration_time)*2*pi*3)*(MidSpeed);								
								if(NewRadius > 1) then
									NewRadius = NewRadius - step * NewRadius;
								end
							end
						else				
							angle = StartAngle - ((elapsedTime/duration_time)*2*pi*3);
							if(NewRadius > 1) then
								NewRadius = NewRadius - step * NewRadius;
							end
						end
						

						local diff_x = NewRadius * math.cos(angle);
						local diff_z = NewRadius * math.sin(angle);
						local npx,npy,npz = px+diff_x, wy+(py-wy)*step, pz+diff_z;
						--local npx,npy,npz = wx+(px-wx)*step, wy+(py-wy)*step, wz+(pz-wz)*step;
						last_elapsedTime = elapsedTime;
						-- commonlib.applog(string.format("Wisp.PickEffect: time:%u,%u,NewRadius:%f,angle:%f,diff_x,y:%f,%f. new position:%f,%f,%f",elapsedTime,duration_time,NewRadius,(StartAngle-angle)*180/pi,diff_x,diff_z,npx,npy,npz));
						obj:SetPosition(npx,npy,npz);
					--else
					--	commonlib.applog(string.format("Wisp.PickEffect warning : myWisp is nil"));
					--end
				else
					--commonlib.applog(string.format("Wisp.PickEffect warning: obj is nil"));
				end
			end
		elseif(elapsedTime == duration_time) then
			 --end animation, destroy effect object
			-- commonlib.applog(string.format("Wisp.PickEffect: time:%u,%u",elapsedTime,duration_time));
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(wisp_name);
			end
		end

		if((elapsedTime >= duration_time - 100) and isHitEffect == false ) then
			---- hit effect
			local player = ParaScene.GetPlayer();
			local px, py, pz = player:GetPosition();
			local params = {
				asset_file = "character/v5/09effect/Wisp/Wisp_hit.x",
				--binding_obj_name = wisp_name,
				binding_obj_name = player.name,
				start_position = {px, py, pz},
				duration_time = 500,
				force_name = nil,
				begin_callback = function() end,
				end_callback = nil,
				stage1_time = nil,
				stage1_callback = nil,
				stage2_time = nil,
				stage2_callback = nil,
			};
			EffectManager.CreateEffect(params);
			isHitEffect = true;
		end
	end, wisp_name);

end

