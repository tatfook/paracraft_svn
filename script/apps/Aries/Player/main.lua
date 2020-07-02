--[[
Title: player main
Author(s): WangTian
Date: 2009/9/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
-- per user data by LiXizhi, 2009.12.22
MyCompany.Aries.Player.SaveLocalData("TestApp.StringField", "hello")
MyCompany.Aries.Player.SaveLocalData("TestApp.TableField", {field1="value1"})
commonlib.echo(MyCompany.Aries.Player.LoadLocalData("TestApp.StringField", "default_value"))
commonlib.echo(MyCompany.Aries.Player.LoadLocalData("TestApp.TableField", "default_value"))
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/OPC.lua");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GameMemoryProtector.lua");
local GameMemoryProtector = commonlib.gettable("MyCompany.Aries.Desktop.GameMemoryProtector");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local UIAnimManager = commonlib.gettable("UIAnimManager");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
local OPC = commonlib.gettable("MyCompany.Aries.OPC");
local LOG = LOG;
local tostring = tostring
local tonumber = tonumber;
local type = type;
local type = type
local ParaScene_GetObject = ParaScene.GetObject;
-- create class
local Player = commonlib.gettable("MyCompany.Aries.Player");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local CombatHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local Friends = commonlib.gettable("MyCompany.Aries.Friends");

local CombatCollectableSubPage = commonlib.gettable("MyCompany.Aries.Desktop.CombatCollectableSubPage");
local CombatInventorySubPage = commonlib.gettable("MyCompany.Aries.Desktop.CombatInventorySubPage");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

-- make the player density below 1.0 (that of water)
Player.NormalDensity = 0.6;
Player.DiveDensity = 1.2;

-- playername of the user
Player.RealPlayerName = Player.RealPlayerName or "";

-- NOTE: head on offset is set through ccs info, if equiped with hat or overhat, different offset is applied
Player.HeadOnOffset = {y=0.6}
Player.HeadOnDisplayColor = "250 186 254";
Player.HeadOnDisplayColor_TownChiefRodd = "159 0 45";
Player.HeadOnDisplayColor_Friend = "64 249 66";
Player.FamilyDisplayColor = "200 200 0";

-- 50054_WishLevel8_TalkedWithBlueDragonTotem
Player.HasItem_50054 = false;

-- the player will be transformed to whatever the gsid item's asset file is. 
Player.asset_gsid = nil;

local cur_player = {};
-- invoked at MyCompany.Aries.OnActivateDesktop()
function Player.Init()
	local world_info = WorldManager:GetCurrentWorld();
	-- check the getanimation in timer to toggle back to land mode if dragon is back to ground
	Player.bFlying = false;
	Player.MyAvatarAssetFileID = nil;

	cur_player.name =  tostring(System.User.nid);
	cur_player.follow_pet_name =  cur_player.name.."+follow";
	cur_player.driver_name =  cur_player.name.."+driver";
	
	OPC.Init();

	Player.check_fly_timer = Player.check_fly_timer or commonlib.Timer:new({callbackFunc = Player.CheckFlyingStatus});
	Player.check_fly_timer:Change(0, 100);
	
	Player.unfreeze_timer = Player.unfreeze_timer or commonlib.Timer:new({callbackFunc = Player.CheckFreezeStatus});
	Player.unfreeze_timer:Change(0, 1000);
	
	--Player.recordposition_timer = Player.recordposition_timer or commonlib.Timer:new({callbackFunc = Player.RecordLastPosition});
	--Player.recordposition_timer:Change(0, 10000);
	
	Player.transform_timer = Player.transform_timer or commonlib.Timer:new({callbackFunc = Player.CheckTransform});
	Player.transform_timer:Change(0, 10000);
	
	Player.updateavatarspeed_timer = Player.updateavatarspeed_timer or commonlib.Timer:new({callbackFunc = Player.CheckAndUpdateAvatarSpeed});
	Player.updateavatarspeed_timer:Change(0, 20000);
	
	Player.updatecheckexpire_timer = Player.updatecheckexpire_timer or commonlib.Timer:new({callbackFunc = ItemManager.OnUpdateCheckExpireTimer});
	Player.updatecheckexpire_timer:Change(0, 5000);


	local ItemManager = System.Item.ItemManager;
	Player.HasItem_50054 = ItemManager.IfOwnGSItem(50054);
	
	-- hook into user name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "UserNameChanged") then
				if(msg.changed_name) then
					System.User.NickName = msg.changed_name;
					Player.GetPlayer():SetDynamicField("name", msg.changed_name);
					Player.ShowHeadonTextForNID();
				end
			end
		end, 
		hookName = "UserNameChangeForPlayerNameUpdate", appName = "Aries", wndName = "main"});
		
	-- hook into OnUserInfoFetched
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnUserInfoFetched") then
				if(msg.nid) then
					local user_char = Pet.GetUserCharacterObj(msg.nid)
					local isEquipHat = false;
					-- hard code the if equip with hat
					if(user_char and user_char:IsValid() == true) then
						local hat_id = user_char:ToCharacter():GetCharacterSlotItemID(0);
						if(hat_id > 0) then
							isEquipHat = true;
						end
					end
					local name = Pet.GetUserCharacterName(msg.nid);
					local obj = ParaScene.GetCharacter(name);
					if(obj and obj:IsValid() == true) then
						user_char = obj;
					end
					local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(msg.nid);
					if(userinfo and user_char and user_char:IsValid() == true) then
						-- set name and family
						user_char:SetDynamicField("name", userinfo.nickname);
						user_char:SetDynamicField("family", userinfo.family or "");
						Player.ShowHeadonTextForNID(msg.nid);
						---- rise the headon display if equip hat
						--local HeadOnDisplayColor = Player.HeadOnDisplayColor;
						--local isGM = MyCompany.Aries.Scene.IsGMAccount(msg.nid);
						--if(isGM) then
							--HeadOnDisplayColor = Player.HeadOnDisplayColor_TownChiefRodd;
						--end
						--if(isEquipHat) then
							--System.ShowHeadOnDisplay(true, user_char, headon_text, HeadOnDisplayColor, high_headon_pos);
						--else
							--System.ShowHeadOnDisplay(true, user_char, headon_text, HeadOnDisplayColor, low_headon_pos);
						--end
					end
				end
			end
		end, 
		hookName = "OnUserInfoFetchedForUserNameUpdate", appName = "Aries", wndName = "main"});
		
	-- keep real player name
	local player = Player.GetPlayer();
	MyCompany.Aries.Player.RealPlayerName = player.name;
	local ProfileManager = System.App.profiles.ProfileManager;
	local myinfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
	if(myinfo) then
		player:SetDynamicField("name", myinfo.nickname);
		player:SetDynamicField("family", myinfo.family or "");
		Player.ShowHeadonTextForNID();
		--local headon_text = MyCompany.Aries.Player.GetHeadonTextString(player);
		--System.ShowHeadOnDisplay(true, player, headon_text, Player.HeadOnDisplayColor);
	end
	
	-- random init spawn position
	if(player and player:IsValid() == true) then
		local x, y, z = player:GetPosition();
		x = x + math.random(-3, 3);
		z = z + math.random(-3, 3);
		
		--[[
		local last_pos = Player.LoadLocalData("LastPosition", nil);

		local lastWorldPath = MyCompany.Aries.app:ReadConfig("LastUserWorldPath_"..System.App.profiles.ProfileManager.GetNID());
		if(lastWorldPath == world_info.worldpath) then
			local lastPosition = MyCompany.Aries.app:ReadConfig("LastUserPosition_"..System.App.profiles.ProfileManager.GetNID());
			if(lastPosition) then
				local last_x, last_y, last_z = string.match(lastPosition, "(.+)%s(.+)%s(.+)");
				if(last_x and last_y and last_z) then
					local last_x = tonumber(last_x);
					local last_y = tonumber(last_y);
					local last_z = tonumber(last_z);
					if(last_x and last_x > 1000 and last_z and last_z > 1000) then
						x = last_x;
						y = last_y;
						z = last_z;
					end
				end
			end
		end]]
		
		player:SetPosition(x, y, z);
		
		---- 50042_DoneMouseTutorial
		--local ItemManager = System.Item.ItemManager;
		--local hasGSItem = ItemManager.IfOwnGSItem;
		--if(hasGSItem(50042)) then
			--player:SetFacing(player:GetFacing() + 3.14);
		--end
	end
	
	--model/07effect/v5/Snow/snow_all.x
	--model/07effect/v5/Snow/snow.x
	
	local isSnowing = false;
	if(MyCompany.Aries.Scene.GetWeather() == "snow") then
		isSnowing = true;
	end
	
	NPL.load("(gl)script/apps/Aries/Creator/Game/Effects/WeatherEffect.lua");
	local WeatherEffect = commonlib.gettable("MyCompany.Aries.Game.Effects.WeatherEffect");
	WeatherEffect:Clear();
	if(Player.weatherTimer) then
		Player.weatherTimer:Change();
	end

	if(isSnowing) then
		local worlds_withsnow = {
			["worlds/MyWorlds/61HaqiTown/"] = true,
			["worlds/MyWorlds/1211_homeland/"] = false,
			["worlds/MyWorlds/FrostRoarIsland/"] = true,
			["worlds/MyWorlds/FrostRoarIsland_teen/"] = true,
			["worlds/Instances/HaqiTown_YYsDream_S2/"] = true,
			["worlds/Instances/FrostRoarIsland_StormEye/"] = true,
		};
		local current_worlddir = ParaWorld.GetWorldDirectory()
		-- skip the worlds that don't need snow
		if(worlds_withsnow[current_worlddir]) then
			-- set the sky box if snowing
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = "model/skybox/skybox7/skybox7.x",  skybox_name = "skybox7"})

			Player.weatherTimer = Player.weatherTimer or commonlib.Timer:new({callbackFunc = function(timer)
				local player = Player.GetPlayer();
				if(player and player:IsValid()) then
					local x, y, z = player:GetPosition();
					-- skip indoor snow
					if(y > 1000) then
						if(WeatherEffect:IsRainOrSnow()) then
							WeatherEffect:SetStrength(2, 0);
						end
					else
						if(not WeatherEffect:IsRainOrSnow()) then
							WeatherEffect:SetStrength(2, math.random(3,10));
						end
					end
				end
			end})
			Player.weatherTimer:Change(200, 200);
			
			
			--[[
			-- snow flick effect
			local last_player_position;
			local last_player_worlddir;
			NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
			local params = {
				asset_file = "model/07effect/v5/Snow/snow.x",
				ismodel = true,
				offset_y = 0,
				start_position = {0, 0, 0},
				duration_time = nil,
				period = 200,
				force_name = "g_snowflicks",
				elapsedtime_callback = function(elapsedtime, obj)
					local player = Player.GetPlayer();
					if(player and player:IsValid() == true and obj and obj:IsValid() == true) then
						local x, y, z = player:GetPosition();
						-- skip indoor snow
						if(y > 1000) then
							y = 1000;
						end
						obj:SetPosition(x, y, z);
						if(not last_player_position) then
							last_player_position = {0, 0, 0};
						end
						if(not last_player_worlddir) then
							last_player_worlddir = current_worlddir;
						end
						-- if over 1 meter offset falling or teleport
						if( math.abs(last_player_position[1] - x) > 1 or 
							math.abs(last_player_position[2] - y) > 1 or 
							math.abs(last_player_position[3] - z) > 1 or 
							last_player_worlddir ~= current_worlddir) then
							-- place nearby space with snow flicks
							local params = {
								asset_file = "model/07effect/v5/Snow/snow_all.x",
								ismodel = true,
								binding_obj_name = nil,
								start_position = {x, y, z},
								duration_time = 1000,
							};
							
							EffectManager.CreateEffect(params);
						end
						last_player_position[1] = x;
						last_player_position[2] = y;
						last_player_position[3] = z;
						last_player_worlddir = current_worlddir;
					end
				end,
			};
			EffectManager.CreateEffect(params);
			]]
		end
	end	
	
	local isCloudy = false;
	if(MyCompany.Aries.Scene.GetWeather() == "cloudy") then
		isCloudy = true;
	end
	if(isCloudy) then
		if(world_info.share_global_weather) then
			-- cloudy weather, set the sky box if cloudy
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = "model/skybox/skybox7/skybox7.x",  skybox_name = "skybox7"})
		end
	end
	
	Player.env_timer = Player.env_timer or commonlib.Timer:new({callbackFunc = Player.EnvTimerFunction});
	if(System.options.is_mcworld) then
		Player.env_timer:Change();
	else
		Player.env_timer:Change(0, 2000);
	end

	-- init the PillGSIDFromTransformMarkerGSID mapping
	Player.GetPillGSIDFromTransformMarkerGSID(1000)
end

-- get player level
function Player.GetLevel()
	local bean = Pet.GetBean();
	if(bean) then
		return bean.combatlel or 0;
	else
		return Combat.GetMyCombatLevel();
	end
	return 0;
end

-- get the player school
-- @return "ice", "fire", "storm", "death", "life"
function Player.GetSchool()
	return Combat.GetSchool();
end

-- is real name player. if so, we will disable anti-indulgence settings. 
function Player.IsRealName()
	if(System.options.locale == "zhCN") then
		if(System.User.IsRealname) then
			return true;
		end
		return false;	
	end
	return true;
end

-- is Adult player. if so, we will disable anti-indulgence settings. 
-- return 1: Adult, 0: not realname, 2:realname but young
function Player.IsAdult()
	if(System.options.locale == "zhCN") then
		if (System.options.is18_SDK) then
			return 1;
		else
			return System.User.IsAdult;	
		end
	end
	return 1;
end

-- get the partner nid. it may return nil if nid is not found. 
-- @param nid: if nil it means the current user
function Player.GetPartnerNID(nid)
	local item;
	if(not nid or nid == Map3DSystem.App.profiles.ProfileManager.GetNID()) then
		item = ItemManager.GetItemByBagAndPosition(0, 72);
	else
		item = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 72);
	end
	if(item and item.GetServerData) then
		local svrdata = item:GetServerData();
		if(svrdata and svrdata.nid) then
			return svrdata.nid;
		end
	end
end

function Player.GetPartnerNIDSignText(nid)
	local item;
	if(not nid or nid == Map3DSystem.App.profiles.ProfileManager.GetNID()) then
		item = ItemManager.GetItemByBagAndPosition(0, 72);
	else
		item = ItemManager.GetOPCItemByBagAndPosition(nid, bag, position);
	end
	if(item and item.GetServerData) then
		local svrdata = item:GetServerData();
		if(svrdata and svrdata.sign_text) then
			return svrdata.sign_text;
		end
	end
end

-- get the mount pet dragon level. 
function Player.GetDragonLevel()
	-- get self level. 
	local bean = Pet.GetBean();
	if(bean and bean.level and bean.level>=0) then
		return bean.level;
	end
	return 0;
end

local stamina_vip_boost = {
	[1] = 0,
	[2] = 0,
	[3] = 50,
	[4] = 50,
	[5] = 50,
	[6] = 70,
	[7] = 70,
	[8] = 70,
	[9] = 90,
	[10] = 100,
};

-- stanima gsid is -19
-- @return current_stamina, max_stamina
function Player.GetStamina()
	if(System.options.version == "teen") then
		stamina_vip_boost = {
			[1] = 20,
			[2] = 30,
			[3] = 40,
			[4] = 50,
			[5] = 60,
			[6] = 70,
			[7] = 80,
			[8] = 90,
			[9] = 100,
			[10] = 110,
		};
		local bean = Pet.GetBean();
		if(bean) then
			return bean.stamina or 100, (stamina_vip_boost[bean.mlel or 1] or 0) + 100;
		end
	else
		local bean = Pet.GetBean();
		if(bean) then
			local stamina = bean.stamina or 100;
			local energy = bean.energy or 0;
			local mlel = bean.mlel or 0;
			local m = bean.m or 0;
			local max_stamina = 100;
			if(energy == 0)then
				max_stamina = 100;
			elseif(energy > 0)then
				if(mlel <= 1)then
					max_stamina = 100 + 10;	
				else
					max_stamina = 100 + 10 * mlel;	
				end
			end
			return stamina, max_stamina;
		end
	end
	return 100, 100;
end

-- stanima gsid is -20
-- @return current_stamina, max_stamina
function Player.GetStamina2()
	local bean = Pet.GetBean();
	if(bean) then
		return bean.stamina2 or 100, 100;
	end
	return 100, 100;
end

function Player.GetVipLevel()
	local bean = Pet.GetBean();
	if(bean) then
		return bean.mlel or 0;
	end
	return 0;
end

-- stanima2 gsid is -20
-- stanima2 for building system. 
function Player.GetStamina2()
	local bean = Pet.GetBean();
	if(bean) then
		return bean.stamina2 or 100, 100; --20*(bean.combatlel or 0) + 100;
	end
	return 100, 100;
end

-- total number of pay count. unit in modou. 
function Player.GetTotalPayCount()
	local bean = Pet.GetBean();
	if(bean) then
		return bean.accummodou or 0;
	end
	return 0;
end

-- get player gender
-- @param nid: if nil user himself
-- @return: female or male or nil if kids version
function Player.GetGender(nid)
	if(System.options.version == "kids") then
		return nil;
	else
		if(nid and nid ~= System.App.profiles.ProfileManager.GetNID()) then
			local item = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 25);
			if(item and item.guid ~= 0) then
				if(item.gsid == 982) then
					return "female";
				else -- if(item.gsid == 983) then
					return "male";
				end
			end
		else
			local item = ItemManager.GetItemByBagAndPosition(0, 25);
			if(item and item.guid ~= 0) then
				if(item.gsid == 982) then
					return "female";
				else -- if(item.gsid == 983) then
					return "male";
				end
			end
		end
		return "female";
	end
end

-- whether the given object name is the current player or its pet or its mount pet. 
-- @param target_name: with which name to compare
function Player.IsSelfObjectName(target_name)
	return (target_name == cur_player.name) or  (target_name == cur_player.follow_pet_name) or (target_name == cur_player.driver_name);
end

-- get the distance square of the current player to a given opc_nid
-- @return nil or distance square;
function Player.DistanceSqToGSLAgent(opc_nid)
	opc_nid = tostring(opc_nid);
	local agent = System.GSL_client:FindAgent(opc_nid);
	if(agent and agent.x and agent.z) then
		local agent_me = System.GSL_client:FindAgent();
		if(agent_me and agent_me.x and agent_me.z) then
			return (agent_me.x-agent.x)*(agent_me.x-agent.x) + (agent_me.z-agent.z)*(agent_me.z-agent.z)
		end
	end
end


-- get the player scene object 
function Player.GetPlayer()
	if(System.User.nid == "localuser") then
		local entity = GameLogic.EntityManager.GetPlayer()
		return entity and entity:GetInnerObject()
	else
		return ParaScene_GetObject(tostring(System.User.nid) or "<player>");
	end
end

-- get player asset file
-- @param id: 982 means TeenElfFemale, 983 means TeenElfMale. if kids version it is always ElfFemale
-- if nil in teen version, it is defaults to TeenElfFemale.  it can also be "male" or "female" string. 
function Player.GetAvaterAssetFileByID(id)
	if(System.options.isKid) then
		return "character/v3/Elf/Female/ElfFemale.xml";
	end
	if(id == 983 or id == "male") then
		return "character/v3/TeenElf/Male/TeenElfMale.xml";
	else -- if(id == 982) then
		return "character/v3/TeenElf/Female/TeenElfFemale.xml";
	end
end

-- whether the user has auto combat pills. 
function Player.CanAutoCombat()
	local hasGSItem = ItemManager.IfOwnGSItem;
	if(hasGSItem(12007)) then
		return true;
	end
end

-- whether the player is in auto combat mode. 
function Player.IsAutoCombatMode()
	return CombatHandler.GetIsAutoAIMode();
end

-- 982_TeenElfFemale
-- 983_TeenElfMale
-- get player asset file
-- @return: assetfile id, 0 for elffemale, 982 for TeenElfFemale, 983 for TeenElfMale
function Player.GetMyAvatarAssetFileID()
	if(Player.MyAvatarAssetFileID) then
		return Player.MyAvatarAssetFileID;
	end
	if(System.options.version == "kids") then
		Player.MyAvatarAssetFileID = 0;
	else
		local item = ItemManager.GetItemByBagAndPosition(0, 25);
		if(item and item.guid ~= 0) then
			if(item.gsid == 982) then
				Player.MyAvatarAssetFileID = 982;
			else -- if(item.gsid == 983) then
				Player.MyAvatarAssetFileID = 983;
			end
		else
			return 982;
		end
	end
	return Player.MyAvatarAssetFileID;
end

-- get my avatar assetfile
function Player.GetMyAvatarAssetFile()
	return Player.GetAvaterAssetFileByID(Player.GetMyAvatarAssetFileID());
end

-- get ring effect id
-- @return: ring effect id
function Player.GetMyRingEffectID()
	if(System.options.version == "kids") then
		local IfEquipGSItem = ItemManager.IfEquipGSItem;
		local bHas, guid = IfEquipGSItem(2110);
		if(bHas) then
			-- 2110_FallInLoveRing_Man
			-- 12886_2110_FallInLoveRing_Man.anim.x
			return 12886;
		end
		local bHas, guid = IfEquipGSItem(2111);
		if(bHas) then
			-- 2111_FallInLoveRing_Girl
			-- 12887_2111_FallInLoveRing_Girl.anim.x
			return 12887;
		end
		local bHas, guid = IfEquipGSItem(2393);
		if(bHas) then
			-- 2393_ValentinesDayRing_Man
			-- 12888_2393_FallInLoveRing_Man.anim.x
			return 12888;
		end
		local bHas, guid = IfEquipGSItem(2394);
		if(bHas) then
			-- 2394_ValentinesDayRing_Girl
			-- 12889_2394_FallInLoveRing_Girl.anim.x
			return 12889;
		end
		local bHas, guid = IfEquipGSItem(2420);
		if(bHas) then
			-- 2420_TheValentinesDayRing_Man
			-- 2420_TheValentinesDayRing_Man.anim.x
			return 12890;
		end
		local bHas, guid = IfEquipGSItem(2421);
		if(bHas) then
			-- 2421_TheValentinesDayRing_Woman
			-- 2421_TheValentinesDayRing_Woman.anim.x
			return 12891;
		end
	end
	return 0;
end

-- get gem effect id
-- @return: gem effect id
function Player.GetMyGemEffectID()
	if(System.options.version == "kids") then
		local min_addon_level = 9999;
		local itemlist = ItemManager.GetItemsInBagInMemory(0);
		local _, guid;
		for _, guid in pairs(itemlist or {}) do
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				if(item.GetAddonLevel and item.GetMaxAddonLevel) then
					local level_max = item:GetMaxAddonLevel();
					local level = item:GetAddonLevel();
					if(level_max and level_max > 0) then
						if(level < min_addon_level) then
							min_addon_level = level;
						end
					end
				end
			end
		end
		if(min_addon_level ~= 9999) then
			local base;
			local offset;
			--if(min_addon_level >= 11) then
				--base = 12825;
			--elseif(min_addon_level >= 9) then
			if(min_addon_level >= 9) then
				base = 12820;
			elseif(min_addon_level >= 7) then
				base = 12815;
			elseif(min_addon_level >= 3) then
				base = 12810;
			end
			local school = Combat.GetSchool();
			if(school == "fire") then
				offset = 1;
			elseif(school == "ice") then
				offset = 2;
			elseif(school == "storm") then
				offset = 3;
			elseif(school == "life") then
				offset = 4;
			elseif(school == "death") then
				offset = 5;
			end
			if(base and offset) then
				return base + offset;
			end
		end
		return 0;
	elseif(System.options.version == "teen") then
		-- calculate gem score
		local gem_score = 0;
		local itemlist = ItemManager.GetItemsInBagInMemory(0);
		local _, guid;
		for _, guid in pairs(itemlist or {}) do
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
				if(gsItem) then
					-- item with gem sockets
					if(item.PrepareSocketedGemsIfNot and item.GetSocketedGems) then
						item:PrepareSocketedGemsIfNot();
						local gems = item:GetSocketedGems();
						if(gems) then
							local _, gsid;
							for _, gsid in pairs(gems) do
								-- check all gems
								local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
								if(gsItem) then
									local stats = gsItem.template.stats;
									-- 41 Gem_Level(CS)
									gem_score = gem_score + stats[41];
								end
							end
						end
					end
				end
			end
		end
		-- gem level as gem score
		if(gem_score < 200) then
			return 0;
		elseif(gem_score >= 200) then
			return 12881;
		--elseif(gem_score < 20) then
			--return 12882;
		--elseif(gem_score < 40) then
			--return 12883;
		--elseif(gem_score < 80) then
			--return 12884;
		--elseif(gem_score < 160) then
			--return 12885;
		end
		return 0;
	else
		return 0;
	end
end

function Player.GetHeadonTextString(objornid)
	local obj;
	if(type(objornid) == "number") then
		local name = Pet.GetUserCharacterName(objornid);
		obj = ParaScene.GetCharacter(name);
		if(not obj or obj:IsValid() == false) then
			return "";
		end
	elseif(type(objornid) == "userdata") then
		obj = objornid;
	end
	if(obj) then
		local name = obj:GetDynamicField("name", "");
		
		if(not System.options.hide_family_name) then
			local family = obj:GetDynamicField("family", "");
			--if(family and family ~= "" and System.options.version == "kids") then
				--local statusInFamily = Friends.MyStatusInFamily;
				--if(statusInFamily == 0) then
					--statusInFamily = "族长";
				--elseif(statusInFamily == 1) then
					--statusInFamily = "副族长";
				--elseif(statusInFamily == 2) then
					--statusInFamily = "成员";
				--end
				--family = family.."-"..statusInFamily;
			--end
			return format("{%s}+{%s}", family, name);
		else
			return name;
		end
	else
		return "";
	end
end

local low_headon_pos = {y = 0.2}
local high_headon_pos = {y = 0.7}

-- hide headon text for nid
function Player.HideHeadonTextForNID(nid, _player)
	if(not _player) then
		local name = Pet.GetUserCharacterName(nid);
		_player = ParaScene_GetObject(name);
	end
	if(_player:IsValid()) then
		System.ShowHeadOnDisplay(false, _player, "", Player.HeadOnDisplayColor, low_headon_pos);
	end
end

-- default headon text color. 
local function default_HeadonTextColorFunction(nid)
	if(Friends.IsFriendInMemory(nid)) then
		return Player.HeadOnDisplayColor_Friend;
	else
		--if(MyCompany.Aries.Scene.IsGMAccount and MyCompany.Aries.Scene.IsGMAccount(nid)) then
			--return Player.HeadOnDisplayColor_TownChiefRodd;
		--end
		return Player.HeadOnDisplayColor;
	end
end

local current_headon_text_func = default_HeadonTextColorFunction;

-- change the headon text function. 
-- @param funcCallback: nil to use the default one or a function(nid) return  end
function Player.SetHeadonTextColorFunction(funcCallback)
	current_headon_text_func = funcCallback or default_HeadonTextColorFunction;
end

-- show headon text for nid player
-- @param nid: player nid
-- @param _player: the player object whose name is nid. if nil, we will get it by nid. 
function Player.ShowHeadonTextForNID(nid, _player)
	if(nid) then
		if(not _player) then
			local name = Pet.GetUserCharacterName(nid);
			_player = ParaScene_GetObject(name);
		end
		if(_player:IsValid()) then
			local IsHiddenDisplayName = _player:GetDynamicField("IsHiddenDisplayName", false);
			if(IsHiddenDisplayName) then
				headon_text = "";
				System.ShowHeadOnDisplay(false, _player, "", Player.HeadOnDisplayColor, low_headon_pos);
				return;
			end

			local headon_text = Player.GetHeadonTextString(_player or nid) or "";
			local _haqi = Pet.GetUserCharacterObj(nid);
			if(_haqi and _haqi:IsValid()) then
				local isEquipHat = false;
				if(_haqi:ToCharacter():GetCharacterSlotItemID(0) > 0) then
					isEquipHat = true;
				end
				local HeadOnDisplayColor = current_headon_text_func(nid);
				
				if(isEquipHat == true) then
					System.ShowHeadOnDisplay(true, _player, headon_text, HeadOnDisplayColor, high_headon_pos, Player.FamilyDisplayColor);
				else
					System.ShowHeadOnDisplay(true, _player, headon_text, HeadOnDisplayColor, low_headon_pos, Player.FamilyDisplayColor);
				end
			end
		end
	end
end

-- get head on text color
function Player.GetHeadonTextColor(objornid)
	local nid;
	if(type(objornid) == "number") then
		nid = objornid;
	elseif(type(objornid) == "string") then
		nid = tonumber(objornid);
	elseif(type(objornid) == "userdata") then
		nid = tonumber(objornid.name);
	end
	local color = Player.HeadOnDisplayColor;
	local isGM = MyCompany.Aries.Scene.IsGMAccount(nid);
	if(isGM) then
		color = Player.HeadOnDisplayColor_TownChiefRodd;
	end
	return color;
end

-- hard code the AddMoney here, move to the game server in the next release candidate
-- @(optional)bSkipNotification: skip the joy bean notification
function Player.AddMoney(emoney, callbackFunc, bSkipNotification)
	if(type(emoney) == "number") then
		--if(emoney <= 0) then
			--log("error: got 0 or negetive money in AddMoney\n")
			--return;
		--end
		local msg = {
			emoney = emoney,
		};
		paraworld.users.AddMoney(msg, "Player.AddMoney", function(msg)
			if(type(callbackFunc) == "function") then
				callbackFunc(msg);
			end
			-- get the user info in local server
			System.App.profiles.ProfileManager.GetUserInfo(nil, nil, nil, "access plus 1 minute");
			-- show obtain joybean notification
			if(msg.issuccess == true and bSkipNotification ~= true) then
				MyCompany.Aries.Desktop.Dock.OnJoybeanNotification(emoney);
			end
		end);
	end
end

-- hard code the AddMoney here, move to the game server in the next release candidate
-- @(optional)bSkipNotification: skip the joy bean notification
function Player.AddExp(exp, callbackFunc, bSkipNotification)
	if(type(exp) == "number") then
		if(exp <= 0) then
			log("error: got 0 or negetive exp in AddExp\n");
			return;
		end
	
		local ItemManager = System.Item.ItemManager;
		local pet_item = ItemManager.GetMyMountPetItem();
		if(pet_item and pet_item.guid > 0) then
			
			local msg = {
				nid = System.App.profiles.ProfileManager.GetNID(),
				petid = pet_item.guid,
				addexp = exp,
			};
			paraworld.homeland.petevolved.AddCombatExp(msg, "Player.AddExp", function(msg)
				if(type(callbackFunc) == "function") then
					callbackFunc(msg);
				end

				System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="ForceUpdateUserAndDragonInfo"});

				-- refresh my pet.get info
				Pet.GetRemoteValue(nil, function() end, "access plus 1 minute");

				-- refresh magic stone bag
				ItemManager.GetItemsInBag(24, "UpdateBagAfterAddExp", function(msg)
					-- update all page controls containing the pe:slot tag
					-- TODO: update only the PageCtrl with the same bag
					Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
				end, "access plus 1 minute");

				-- show obtain joybean notification
				if(msg.issuccess == true and bSkipNotification ~= true) then
					MyCompany.Aries.Desktop.Dock.OnExpNotification(exp);
				end
			end);
		end
	end
end

-- get my joybean count in memory, the count is synced with local server data
-- @return: joy bean count
function Player.GetMyJoybeanCount()
	local count = 0;
	local nid = System.App.profiles.ProfileManager.GetNID();
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid);
	if(userinfo and userinfo.emoney) then
		count = userinfo.emoney;
	end
	return count;
end

function Player.CheckFlyingStatus()
	local world_info = WorldManager:GetCurrentWorld();
	if (world_info.min_fly_height and world_info.lowest_land_height and Player.CanFly()) then
		local player = Player.GetPlayer()
		local x, y, z = player:GetPosition();
		local terrain_y = ParaTerrain.GetElevation(x,z);

		if(world_info.lowest_land_height < terrain_y) then
			if(BasicArena.IsImmortal()) then
				if(Player.IsFlying()) then
					--LOG.std(nil, "debug", "nav fly mode", "cancel fly mode")
					Player.ToggleFly(false);
				end
			end
			return;
		elseif( y < world_info.min_fly_height ) then
			if(not Player.IsFlying()) then
				Player.ToggleFly(true);
				--LOG.std(nil, "debug", "nav fly mode", "set fly mode")
			end
							
			if(y < world_info.min_fly_height) then
				local dy;
				if( (world_info.min_fly_height - y) >3) then
					player:SetPosition(x,world_info.min_fly_height,z);
				else
					Player.Jump_imp();
				end
			end
			return;
		else
			-- when player is high in the sky. 
		end
	end

	-- pass 1: check the player land process
	local player = Player.GetPlayer();
	if(Player.IsFlying() == true and not BasicArena.IsImmortal()) then
		local animID = player:GetAnimation();
		-- 4 WALK 
		-- 5 RUN 
		-- 13 WALKBACKWARDS 
		if(Player.CanFly()) then
			if(animID == 4 or animID == 5 or animID == 13) then
				Player.ToggleFly();
				return;
			end
		else
			Player.ToggleFly(false)
			return
		end
	end

	if(System.options.version == "teen") then
		if(player:GetAnimation() == 5 or player:GetAnimation() == 4) then
			if(not EffectManager.IsBinding("g_walk_dust")) then
				local params = {
					asset_file = "character/v5/09effect/Common/HuiCheng.x",
					binding_obj_name = player.name,
					force_name = "g_walk_dust",
					--start_position = {player:GetPosition()},
					scale = 1,
					duration_time = 9999999,
				};
				EffectManager.CreateEffect(params);
			end
		else
			EffectManager.StopBinding("g_walk_dust");
			EffectManager.DestroyEffect("g_walk_dust");
		end
	end
end

function Player.IsFlying()
	return Player.bFlying;
end

-- if player is now standing(i.e. no speed)
function Player.IsStanding()
	if(not Player.IsFlying()) then
		local player = Player.GetPlayer();
		if(player) then
			return player:IsStanding();
		end
	end
end

function Player.CanFly()
	if(Player.force_can_fly) then
		return true;
	end
	local worldpath = ParaWorld.GetWorldDirectory();
	if(string.find(string.lower(worldpath), "instance")) then
		return false;
	end
	if(System.options.version == "teen") then
		local isCanFly = false;
		
		-- 33 Transformation Marker 
		local item = ItemManager.GetItemByBagAndPosition(0, 33);
		if(item and item.guid > 0) then
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				-- 61 mountpet_canfly(CG) 青年版的可飞行坐骑标记 marker一定要加 
				isCanFly = gsItem.template.stats[61];
			end
		end
		
		if(isCanFly) then
			local isMount = false;
			local item = ItemManager.GetMyMountPetItem();
			if(item and item.guid > 0) then
				if(item.clientdata == "mount") then
					local _player = Pet.GetUserCharacterObj();
					if(_player and _player:IsValid() == true and Player.GetPlayer():equals(_player) ~= true) then
						isMount = true;
					end
				end
			end

			if(not isMount) then
				return false;
			end
		end
		return isCanFly;
	else
		-- kids version. 
		local isCanFly = false;
		local isMount = false;
		local ItemManager = System.Item.ItemManager;
		local item = ItemManager.GetMyMountPetItem();
		if(item and item.guid > 0) then
			if(item.clientdata == "mount") then
				local _player = Pet.GetUserCharacterObj();
				if(_player and _player:IsValid() == true and Player.GetPlayer():equals(_player) ~= true) then
					isMount = true;
				end
			end
		end
		local bean = Pet.GetBean();
		if(bean) then
			if(isMount == true and VIP.IsVIPAndActivated()) then
				isCanFly = true;
			elseif(bean.level >= 8 and isMount == true) then
				if(Player.HasItem_50054 == false) then
					Player.HasItem_50054 = ItemManager.IfOwnGSItem(50054);
				end
				isCanFly = Player.HasItem_50054;
			end
		end

		local player = Player.GetPlayer();
		local x, y, z = player:GetPosition();
		if(y > 9000) then
			-- over height indoor or cave or instance stage
			isCanFly = false;
		end
	
		return isCanFly;
	end
end

function Player.IsInAir()
	-- we use the FSM of the character animation states to check the player jumping status
	local player = Player.GetPlayer();
	local animID = player:GetAnimation();
	-- 37  JUMPSTART
	-- 38  JUMP
	-- 39  JUMPEND
	if(animID == 37 or animID == 38) then
		return true;
	elseif(Player.asset_gsid)then
		local speed = math.abs(player:GetField("VerticalSpeed", -1000));
		if(speed > 0.01) then
			return true;
		end
	end
	return false;
end

function Player.IsInWater()
	-- we use the FSM of the character animation states to check the player swimming status
	local player = Player.GetPlayer();
	local animID = player:GetAnimation();
	--41  SWIMIDLE
	--42  SWIM
	--43  SWIMLEFT
	--44  SWIMRIGHT
	--45  SWIMBACKWARDS
	if(animID == 41 or animID == 42 or animID == 43 or animID == 44 or animID == 45) then
		return true;
	end
	return false;
end

local isFreezeJump = false;

-- enter freeze move mode, not allowing any movement
function Player.EnterFreezeMoveMode()
	-- clear the mouse over effect, text and cursor
	local HandleMouse = commonlib.getfield("MyCompany.Aries.HandleMouse")
	if(HandleMouse) then
		HandleMouse.ShowCursorText("");
	end
	System.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = "main"})
	-- clear mouse over group
	ParaSelection.ClearGroup(2);
	-- block camera and scene input
	-- commented by LiXizhi 2011.9.22 (Enter Key should be received in object manager)
	-- ParaScene.GetAttributeObject():SetField("BlockInput", true); 
	System.KeyBoard.SetKeyPassFilter(System.KeyBoard.enter_key_filter);
	System.Mouse.SetMousePassFilter(System.Mouse.disable_filter);
	ParaCamera.GetAttributeObject():SetField("BlockInput", true);
end

-- leave freeze move mode, not allowing any movement
function Player.LeaveFreezeMoveMode()
	-- restore camera and scene input
	System.KeyBoard.SetKeyPassFilter(nil);
	System.Mouse.SetMousePassFilter(nil);
	ParaScene.GetAttributeObject():SetField("BlockInput", false);
	ParaCamera.GetAttributeObject():SetField("BlockInput", false);
end

-- enter hide follow pet mode
-- @params nid: nid of the user to hide the follow pet
function Player.EnterHideFollowPetMode(nid)
	local name = Pet.GetUserFollowPetName(nid);
	local followpet = ParaScene_GetObject(name);
	if(followpet and followpet:IsValid() == true) then
		followpet:SetVisible(false);
	end
end

-- leave hide follow pet mode
-- @params nid: nid of the user to hide the follow pet
function Player.LeaveHideFollowPetMode(nid)
	local name = Pet.GetUserFollowPetName(nid);
	local followpet = ParaScene_GetObject(name);
	if(followpet and followpet:IsValid() == true) then
		followpet:SetVisible(true);
	end
end

-- enter freeze jump mode, not allowing any jump operation
function Player.EnterFreezeJumpMode()
	isFreezeJump = true;
end

-- leave freeze jump mode, not allowing any jump operation
function Player.LeaveFreezeJumpMode()
	isFreezeJump = false;
end

-- whether jumping is allowed at the moment. 
function Player.IsAllowJump()
	if(isFreezeJump) then
		return;
	end
	
	local worldinfo = WorldManager:GetCurrentWorld();
	if(not worldinfo.can_jump) then
		return
	end
	return true;
end
-- player jump action. 
-- @return true if jumped up. otherwise nil. 
function Player.Jump()

	if(not Player.IsAllowJump()) then
		return;
	end

	local is_can_fly = Player.CanFly()
	if(not is_can_fly and Player.IsInAir()) then
		return;
	end
	if(is_can_fly and not Player.IsFlying()) then
		if(System.options.version == "teen") then
			-- only teen version can enter fly mode automatically. 
			Player.ToggleFly();
		end
	end
	--if(Player.IsInWater()) then
		--return;
	--end

	-- call hook for OnJump
	local hook_msg = { aries_type = "OnJump", gsid = gsid, count = count, wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

	local world_info = WorldManager:GetCurrentWorld();
	if (not world_info.min_fly_height or not world_info.lowest_land_height) then
		-- limit the max height 
		local player = Player.GetPlayer();
		local x, y, z = player:GetPosition();
		local elev_plus_150 = ParaTerrain.GetElevation(x, z) + 150;
		if(y and y > 19000 and y < 21000) then
			if(Player.IsInAir()) then
				return;
			end
		elseif(y and y > elev_plus_150) then
			return;
		end
	end
	-- space key to jump
	return Player.Jump_imp();
end

function Player.Jump_imp()
	-- space key to jump
	local char = Player.GetPlayer():ToCharacter();
	if(char:IsValid())then
		if(System.options.version == "teen") then
			local speed = Player.GetPlayer():GetField("CurrentSpeed", 5)
			if(speed < 0) then
				speed = - speed;
			end
			char:AddAction(action_table.ActionSymbols.S_JUMP_START, math.max(speed*0.6, 5));
		else
			char:AddAction(action_table.ActionSymbols.S_JUMP_START);
		end
		return true;
	end
end

-- press "F" to toggle the fly mode
-- @param bFly: nil to toggle. otherise force fly or not. 
-- @return is_flying
function Player.ToggleFly(bFly)
	
	local player = Player.GetPlayer();
	if(bFly == nil) then
		local isCanFly = Player.CanFly();
		if(not Player.IsFlying()) then
			if(isCanFly) then
				bFly = true;
			end
		elseif(Player.IsFlying() == true) then
			if(isCanFly) then
				bFly = false;
			end
		end
	end
	if(bFly) then
		-- make it light to fly
		player:SetDensity(0);
		-- jump up a little
		if(System.options.version == "teen") then
			local speed = player:GetField("CurrentSpeed", 5)
			if(speed < 0) then
				speed = - speed;
			end
			player:ToCharacter():AddAction(action_table.ActionSymbols.S_JUMP_START, math.max(speed, 4));
		else
			player:ToCharacter():AddAction(action_table.ActionSymbols.S_JUMP_START);
		end

		Player.bFlying = true;
		
		if(System.options.version == "kids") then
			if(not Player.force_can_fly ) then
				local asset = ParaAsset.LoadParaX("", "character/v5/09effect/Fly/fly.x");
				player:ToCharacter():AddAttachment(asset, 4, 1); -- slot id 1 for flying aura attachment
			end
		end
		
	    -- call hook for start flying
		local hook_msg = { aries_type = "OnStartFlying", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
		
		player:SetField("CanFly",true);
		if(System.options.mc) then
			player:SetField("AlwaysFlying",true);
		end
		BroadcastHelper.PushLabel({id="fly_tip", label = "进入飞行模式：按住鼠标右键控制方向, W键前进", max_duration=5000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});

	elseif(bFly == false) then
		-- restore to original density
		player:SetDensity(Player.GetNewDensity());
		Player.bFlying = false;
		-- destroy flying effect
		--EffectManager.DestroyEffect("flying_effect");
			
		player:ToCharacter():RemoveAttachment(4, 1); -- slot id 1 for flying aura attachment
			
	    -- call hook for end flying
		local hook_msg = { aries_type = "OnEndFlying", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

		player:SetField("CanFly",false);
		if(System.options.mc) then
			player:SetField("AlwaysFlying",false);
		end
		BroadcastHelper.PushLabel({id="fly_tip", label = "退出飞行模式", max_duration=1500, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
	end
	return Player.bFlying;
end

-- hit by firecracker invoked at ThrowBall:DoResponse_PlayAnim
function Player.HitByFireCracker()
	if(Player.IsFlying() == true) then
		Player.ToggleFly();
	end
	local player = Player.GetPlayer();
	player:ToCharacter():FallDown();
end

local unfreeze_countdown = nil;
Player.isFreezed = false;
function Player.HitBySnowBall(attacker_nid)
	Player.isFreezed = true;
	unfreeze_countdown = 30;
	
	---- NOTE 2010/2/24: remove the snowball fighting logics
	--
	--if(not attacker_nid) then
		--return;
	--end
	--
	--local attacker_char = Pet.GetUserCharacterObj(attacker_nid);
	--if(attacker_char and attacker_char:IsValid() == true) then
		---- attacker is in triumph square
		--local x, y, z = attacker_char:GetPosition();
		--NPL.load("(gl)script/kids/3DMapSystemApp/worlds/RegionRadar.lua");
		--local args = System.App.worlds.Global_RegionRadar.WhereIsXZ(x, z);
		--if(args and args.key == "Region_TriumphSquare") then
			---- i am in triumph square
			--local x, y, z = Player.GetPlayer():GetPosition();
			--local args = System.App.worlds.Global_RegionRadar.WhereIsXZ(x, z);
			--if(args and args.key == "Region_TriumphSquare") then
				--NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30321_OneHundredHitBoard_page.lua");
				--MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.OnHitByOther();
			--end
		--end
	--end
end
function Player.HitByJelly()
	Player.isFreezed = false;
end
function Player.SetFreezed(bFreezed)
	Player.isFreezed = bFreezed;
end
function Player.GetFreezed()
	return Player.isFreezed;
end

function Player.HitOtherWithSnowBall(nid, obj_char)
	
	---- NOTE 2010/2/24: remove the snowball fighting logics
	--
	--if(obj_char and obj_char:IsValid() == true) then
		---- target is in triumph square
		--local x, y, z = obj_char:GetPosition();
		--NPL.load("(gl)script/kids/3DMapSystemApp/worlds/RegionRadar.lua");
		--local args = System.App.worlds.Global_RegionRadar.WhereIsXZ(x, z);
		--if(args and args.key == "Region_TriumphSquare") then
			---- i am in triumph square
			--local x, y, z = Player.GetPlayer():GetPosition();
			--local args = System.App.worlds.Global_RegionRadar.WhereIsXZ(x, z);
			--if(args and args.key == "Region_TriumphSquare") then
				--NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30321_OneHundredHitBoard_page.lua");
				--MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.OnHitOther();
			--end
		--end
	--end
end

function Player.CheckFreezeStatus()
	if(Player.isFreezed and unfreeze_countdown) then
		unfreeze_countdown = unfreeze_countdown - 1;
		if(unfreeze_countdown == 0) then
			Player.SetFreezed(false);
			local ItemManager = System.Item.ItemManager;
			ItemManager.RefreshMyself();
		end
	end
end

function Player.CheckAndUpdateAvatarSpeed()
	-- update avatar speed
	Pet.UpdateAvatarSpeed();
	
	if(System.options.version == "teen") then
		if(not CombatHandler.IsInCombat()) then
			local is_bag_too_heavy = Combat.IsOverWeight();
			if(is_bag_too_heavy) then
				BroadcastHelper.PushLabel({
					id="bagtooheavy", 
					label = "背包物品太多, 战斗力减半！快整理下背包吧", 
					max_duration=10000, color = "255 0 0", 
					scaling=1.1, bold=true, shadow=true,
				});
				-- 启动小精灵主动提醒
				NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
				local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
				local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
				if (not system_looptip.bagfull)then
					system_looptip.bagfull=true;
					AutoTips.CheckShowPage("bagfull");
				end
			end
		end
	end
end

-- record the user position every timer period
function Player.RecordLastPosition(bForceFlush)
	WorldManager:RecordLastPosition(bForceFlush)
end

-- dragon transform gsid
Player.transform_gsid = nil;

function Player.SetTransformGSID(gsid)
	if(Player.transform_gsid ~= gsid) then
		Player.transform_gsid = gsid;
		GameMemoryProtector.CheckPoint("MyCompany.Aries.Player.transform_gsid", gsid);
	end
end

-- get transform follow pet gsid, could be nil if not tranformed or followpet not available
function Player.GetTransformFollowPetGSID()
	if(Player.transform_gsid) then
		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(Player.transform_gsid);
		if(gsItem) then
			local related_animal_gsid = gsItem.template.stats[29];
			if(related_animal_gsid) then
				return related_animal_gsid;
			end
		end
		local pill_gsid = ItemManager.GetTransformPill_from_Marker(Player.transform_gsid);
		if(pill_gsid)then
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(pill_gsid);
			if(gsItem) then
				local related_animal_gsid = gsItem.template.stats[29];
				if(related_animal_gsid) then
					return related_animal_gsid;
				end
			end
		end
	end
end

-- set new gsid transform
-- this is usually called from Item_PetTransform:OnClick(mouse_button)
function Player.SetTransformGSIDFromItem(gsid, daysfrom_1900_1_1, seconds_from_0000)
	local clientdata_table = {
		transform_gsid = gsid,
		daysfrom_1900_1_1 = daysfrom_1900_1_1,
		seconds_from_0000 = seconds_from_0000,
	};
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(50334);
	if(bHas) then
		ItemManager.SetClientData(guid, commonlib.serialize_compact(clientdata_table), function() end);
	end
	-- set the transform gsid and refresh avatar apperance
	Player.SetTransformGSID(gsid);
	System.Item.ItemManager.RefreshMyself();

	-- force check transform
	Player.CheckTransform();

	--local Player = MyCompany.Aries.Player;
	--Player.SaveLocalData("Item_PetTransform.CurrentTransform_gsid", gsid);
	--local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	--Player.SaveLocalData("Item_PetTransform.CurrentTransform_date", serverdate);
	--local elapsedseconds = MyCompany.Aries.Scene.GetElapsedSecondsSince0000() or 0;
	--Player.SaveLocalData("Item_PetTransform.CurrentTransform_time", elapsedseconds);
end

if(not Player.transform_remaining_days) then
	Player.transform_remaining_days = nil;
end

local TransformMarkerGSID_to_PillGSID = nil;

function Player.GetPillGSIDFromTransformMarkerGSID(gsid)
	if(not TransformMarkerGSID_to_PillGSID) then
		TransformMarkerGSID_to_PillGSID = {};
		local ExtendedCostTemplates = ItemManager.GetAllExtendedCostTemplateInMemory();
		local exid, template;
		for exid, template in pairs(ExtendedCostTemplates) do
			local from_gsid = nil;
			local to_gsid = nil;
			local _, pair;
			for _, pair in pairs(template.tos) do
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(pair.key);
				if(gsItem) then
					if(gsItem.category == "TransformMarkerCombat") then
						to_gsid = pair.key;
					end
				end
			end
			if(to_gsid) then
				local _, pair;
				for _, pair in pairs(template.froms) do
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(pair.key);
					if(gsItem) then
						if(gsItem.category == "MountPetTransform") then
							from_gsid = pair.key;
						end
					end
				end
			end
			if(from_gsid and to_gsid) then
				TransformMarkerGSID_to_PillGSID[to_gsid] = from_gsid;
			end
		end
	end
	return TransformMarkerGSID_to_PillGSID[gsid];
end

-- check transform
function Player.CheckTransform()
	Player.transform_remaining_days = nil;
	local serverdate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day = string.match(serverdate, "^(.+)%-(.+)%-(.+)$");
	local daysfrom_1900_1_1 = 0;
	local serverseconds = Scene.GetLastAuthServerTimeSince0000();
	if(year and month and day) then
		year = tonumber(year)
		month = tonumber(month)
		day = tonumber(day)
		daysfrom_1900_1_1 = commonlib.GetDaysFrom_1900_1_1(year, month, day);
	end

	local old_transform_gsid = Player.transform_gsid;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(50334);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid)
		if(item and item.guid > 0 and item.clientdata and item.clientdata ~= "") then
			local clientdata_table = commonlib.LoadTableFromString(item.clientdata);
			if(not clientdata_table or not clientdata_table.transform_gsid) then
				if(Player.transform_gsid) then
					-- remove the transform gsid and refresh avatar apperance
					Player.SetTransformGSID(nil);
				end
			else
				local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(clientdata_table.transform_gsid);
				if(gsItem) then
					-- 46 MountPet? _Transform_Duration_Days(C) 变身药丸的坐骑维持时间 
					-- 180 vip_items(C)VIP专属物品 
					if(gsItem.template.stats[46]) then
						if(not gsItem.template.stats[180] or (gsItem.template.stats[180] and VIP.IsVIP())) then
							local clientdata_daysfrom_1900_1_1 = clientdata_table.daysfrom_1900_1_1;
							if((clientdata_daysfrom_1900_1_1 + gsItem.template.stats[46] - 1) >= daysfrom_1900_1_1) then
								if(not Player.transform_gsid) then
									-- set the transform gsid and refresh avatar apperance
									Player.SetTransformGSID(clientdata_table.transform_gsid);
									Player.transform_remaining_days = clientdata_daysfrom_1900_1_1 + gsItem.template.stats[46] - daysfrom_1900_1_1;
								else
									Player.transform_remaining_days = clientdata_daysfrom_1900_1_1 + gsItem.template.stats[46] - daysfrom_1900_1_1;
								end
							else
								if(Player.transform_gsid) then
									-- remove the transform gsid and refresh avatar apperance
									Player.SetTransformGSID(nil);
								end
							end
						else
							-- not vip
							if(Player.transform_gsid) then
								-- remove the transform gsid and refresh avatar apperance
								Player.SetTransformGSID(nil);
							end
						end
					else
						local clientdata_daysfrom_1900_1_1 = clientdata_table.daysfrom_1900_1_1;
						local clientdata_seconds_from_0000 = clientdata_table.seconds_from_0000;
						if(clientdata_daysfrom_1900_1_1 ~= daysfrom_1900_1_1) then
							if(Player.transform_gsid) then
								-- remove the transform gsid and refresh avatar apperance
								Player.SetTransformGSID(nil);
							end
						else
							if((MyCompany.Aries.Scene.GetElapsedSecondsSince0000() or 0) > (clientdata_seconds_from_0000 + 3600)) then
								if(Player.transform_gsid) then
									-- remove the transform gsid and refresh avatar apperance
									Player.SetTransformGSID(nil);
								end
							else
								if(not Player.transform_gsid) then
									-- set the transform gsid and refresh avatar apperance
									Player.SetTransformGSID(clientdata_table.transform_gsid);
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- OVERWRITE with transform marker config
	-- 33 Transformation Marker 
	local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 33);
	if(item and item.guid > 0) then
		Player.SetTransformGSID(item.gsid);

		---- NOTE 2012/6/9: try to fix bug: mount pet transform marker auto delete after use
		--
		--local daysfrom_1900_1_1_transform_marker = 0;
		--local year, month, day = string.match(item.obtaintime, "^(%d-)%-(%d-)%-(%d-)%s.+$");
		--if(year and month and day) then
			--year = tonumber(year)
			--month = tonumber(month)
			--day = tonumber(day)
			--local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			--if(gsItem) then
				---- 46 MountPet? _Transform_Duration_Days(C) 变身药丸的坐骑维持时间 
				--daysfrom_1900_1_1_transform_marker = commonlib.GetDaysFrom_1900_1_1(year, month, day);
				--Player.transform_remaining_days = daysfrom_1900_1_1_transform_marker + gsItem.template.expiretime - daysfrom_1900_1_1;
			--end
		--end
		--if(Player.transform_gsid and Player.transform_remaining_days and Player.transform_remaining_days<0) then
			--LOG.std(nil, "system", "Pet", "your mount pet guid(%d) is expired, we will unmount it.", item.guid);
			---- this will force refresh
			--System.Item.ItemManager.DestroyItem(item.guid, 1, function() 
				--if(Player.transform_gsid~=nil) then
					--Player.SetTransformGSID(nil);
					--System.Item.ItemManager.RefreshMyself();
				--end
			--end);
		--end
	else
		if(Player.transform_gsid) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(Player.transform_gsid);
			if(gsItem) then
				-- 51 MountPet? _Transform_Duration_Marker_ExtendedCost_ID (CS) 
				local exid = gsItem.template.stats[51];
				if(exid) then
					-- transform pill with extendedcost
					-- reset the transform_gsid
					Player.SetTransformGSID(nil);
					Player.transform_remaining_days = nil;
					
					-- 50334_MountPetTransform
					local bHas, guid = hasGSItem(50334);
					if(bHas) then
						local item = ItemManager.GetItemByGUID(guid)
						if(item and item.guid > 0) then
							-- clear transform marker clientdata
							ItemManager.SetClientData(item.guid, "", function() end);
						end
					end
				end
			end
		end
		Player.SetTransformGSID(nil);
		Player.transform_remaining_days = nil;
	end

	-- since kids and teen version are mixed, we will only refresh if transform gsid changed.
	if(Player.transform_gsid ~= old_transform_gsid) then
		System.Item.ItemManager.RefreshMyself();
	end
end

-- 19:59 is evening time and take 30 minutes to progress
local evening_time = 3600 * 19 + 60 * 59;
--local evening_time = 3600 * 9 + 60 * 59;
local evening_process_time = 60 * 30;

local isEnvEditing = false;

function Player.SetEveningParams(time, progress)
	evening_time = time;
	evening_process_time = progress;
end

function Player.EnterEnvEditMode(bEditing)
	if(bEditing ~= nil) then
		isEnvEditing = bEditing;
	else
		isEnvEditing = true;
	end
end

function Player.LeaveEnvEditMode()
	isEnvEditing = false
end

function Player.ForceActivateEnvTimerFunction()
	Player.EnvTimerFunction()
end

local worldnames_with_default_env = {
	["NewUserIsland"] = true,
	["DarkForestIsland"] = true,
	["CloudFortressIsland"] = true,
	["HaqiTown_CampfireChallenge"] = true,
	["DarkForestIsland_PirateSeamaster"] = true,
	["DarkForestIsland_DemonNest_Spider"] = true,
	["DarkForestIsland_DemonNest_Bat"] = true,
	["DarkForestIsland_DemonNest_Crocodile"] = true,
	["DarkForestIsland_DemonNest_Wolf"] = true,
	["HaqiTown_HarshDesert"] = true,
	["DarkForestIsland_DeathHeadQuarter"] = true,
	["CloudFortressIsland_MoltenCore"] = true,
	["CloudFortressIsland_DragonLair"] = true,
	["CloudFortressIsland_BearChieftain"] = true,
	["CloudFortressIsland_HauntedValley"] = true,
	["CloudFortressIsland_QueensBattleship"] = true,
	["CloudFortressIsland_FrighteningSoul"] = true,
	["Global_CatTreasureHouse_Basic"] = true,
	["Global_CatTreasureHouse_Adv"] = true,
	["CrazyTower_1_to_5"] = true,
	["CrazyTower_6_to_10"] = true,
	["CrazyTower_11_to_15"] = true,
	["CrazyTower_16_to_20"] = true,
	["CrazyTower_21_to_25"] = true,
	["CrazyTower_26_to_30"] = true,
	["CrazyTower_31_to_35"] = true,
	["CrazyTower_36_to_40"] = true,
	["CrazyTower_41_to_45"] = true,
	["CrazyTower_46_to_50"] = true,
	["HaqiTown_YYsDream_S4"] = true,
	
	["AncientEgyptIsland_LostTemple_H"] = true,
	["AncientEgyptIsland_SunkenRelic_H"] = true,
	["CloudFortressIsland_BearChieftain_H"] = true,
	["CloudFortressIsland_DragonLair_H"] = true,
	["CloudFortressIsland_FrighteningSoul_H"] = true,
	["CloudFortressIsland_MoltenCore_H"] = true,
	["CloudFortressIsland_QueensBattleship_H"] = true,
	["DarkForestIsland_DeathDungeon_H"] = true,
	["DarkForestIsland_DeathHeadQuarter_H"] = true,
	["DarkForestIsland_LegionGrainDepot_H"] = true,
	["FlamingPhoenixIsland_TheGreatTree_H"] = true,
	["FrostRoarIsland_StormEye_H"] = true,
	["HaqiTown_FireCavern_H"] = true,
	["HaqiTown_YYsDream_S2_H"] = true,

	["HaqiTown_Christmas_Colorful_World"] = true,
	["FrostRoarIsland_HeroStormEye"] = true,
};

local homeland_env_params = {
	["worlds/MyWorlds/100409_CandyHomeland"] = {
		fog_color = {r = 255, g = 150, b = 180},
		ocean_color = {r = 255, g = 230, b = 0},
		skybox = "model/skybox/skybox9/skybox9.x",
		skybox_name = "skybox9",
		fog = {fog_start = 150, fog_end = 300, far_plane = 350,},
	},
	["worlds/MyWorlds/100611_EnvironmentHomeland"] = {
		fog_color = {r = 168, g = 255, b = 255},
		ocean_color = {r = 0, g = 255, b = 255},
		skybox = "model/skybox/skybox15/skybox15.x",
		skybox_name = "skybox15",
		fog = {fog_start = 114, fog_end = 300, far_plane = 355,},
	},
};

local prior_worldname_env_params = {
	["BattleField_ChampionsValley"] = {
		day = {
			ambient = {r = 175, g = 175, b = 175},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -1.0, _end = 0.0, _density = 0.9},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.442, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 120, fog_range = 150, far_plane = 800, },
		},
		night = {
			ambient = {r = 175, g = 175, b = 175},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -1.0, _end = 0.0, _density = 0.9},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.442, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 120, fog_range = 150, far_plane = 800, },
		},
	},
	["HaqiTown_RedMushroomArena_4v4"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox15/skybox15.x",
			skybox_cloudy_name = "skybox15",
			fog = {fog_start = 80, fog_range = 42, far_plane = 420, },
		},
		night = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox15/skybox15.x",
			skybox_cloudy_name = "skybox15",
			fog = {fog_start = 80, fog_range = 42, far_plane = 420, },
		},
	},
	["FlamingPhoenixIsland_TheGreatTree_Hero"] = {
		day = {
			ambient = {r = 76, g = 0, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.6, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox15/skybox15.x",
			skybox_cloudy_name = "skybox15",
			fog = {fog_start = 80, fog_range = 42, far_plane = 420, },
		},
		night = {
			ambient = {r = 76, g = 0, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.6, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox15/skybox15.x",
			skybox_cloudy_name = "skybox15",
			fog = {fog_start = 80, fog_range = 42, far_plane = 420, },
		},
	},
	["HaqiTown_FireCavern"] = {
		day = {
			ambient = {r = 255, g = 51, b = 51},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 0, b = 0},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 60, fog_range = 350, far_plane = 1500, },
		},
		night = {
			ambient = {r = 255, g = 51, b = 51},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 0, b = 0},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 60, fog_range = 350, far_plane = 1500, },
		},
		bExplicitFog = true,
	},
	["Tutorial"] = {
		params = {
			TimeOfDaySTD = -0.2,
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_51_to_55"] = {
		params = {
			ambient = {r = 255, g = 30, b = 30},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_56_to_60"] = {
		params = {
			ambient = {r = 255, g = 30, b = 30},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_61_to_65"] = {
		params = {
			ambient = {r = 23, g = 80, b = 69},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_66_to_70"] = {
		params = {
			ambient = {r = 23, g = 80, b = 69},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_71_to_75"] = {
		params = {
			ambient = {r = 191, g = 170, b = 51},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_76_to_80"] = {
		params = {
			ambient = {r = 191, g = 170, b = 51},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_81_to_85"] = {
		params = {
			ambient = {r = 96, g = 96, b = 96},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 117, g = 136, b = 142},
			fog_volume = {_start = -0.510, _end = 0.179, _density = 1.000},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_86_to_90"] = {
		params = {
			ambient = {r = 96, g = 96, b = 96},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 117, g = 136, b = 142},
			fog_volume = {_start = -0.510, _end = 0.179, _density = 1.000},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_91_to_95"] = {
		params = {
			ambient = {r = 117, g = 46, b = 117},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["CrazyTower_96_to_100"] = {
		params = {
			ambient = {r = 117, g = 46, b = 117},
			TimeOfDaySTD = 0.6, 
		},
		bPortion = true,
		bExplicitFog = true,
	},
	["worlds/MyWorlds/61HaqiTown_teen_incombat"] = {
		day = {
			ambient = {r = 80, g = 90, b = 90},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 124, g = 115, b = 138},
			fog_volume = {_start = -0.471, _end = 0.090, _density = 0.770},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.65, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 60, fog_range = 90, far_plane = 420, },
		},
		night = {
			ambient = {r = 80, g = 90, b = 90},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 124, g = 115, b = 138},
			fog_volume = {_start = -0.471, _end = 0.090, _density = 0.770},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.65, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 60, fog_range = 90, far_plane = 420, },
		},
	},
	["worlds/MyWorlds/AriesTutorialTeen_incombat"] = {
		day = {
			ambient = {r = 80, g = 80, b = 80},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 161, g = 161, b = 186},
			fog_volume = {_start = -0.059, _end = 0.345, _density = 0.550},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.665, 
			skybox_sunny = "model/skybox/skybox26/skybox26.x",
			skybox_sunny_name = "skybox26",
			skybox_cloudy = "model/skybox/skybox26/skybox26.x",
			skybox_cloudy_name = "skybox26",
			fog = {fog_start = 90, fog_range = 100, far_plane = 420, },
		},
		night = {
			ambient = {r = 80, g = 80, b = 80},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 161, g = 161, b = 186},
			fog_volume = {_start = -0.059, _end = 0.345, _density = 0.550},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.665, 
			skybox_sunny = "model/skybox/skybox26/skybox26.x",
			skybox_sunny_name = "skybox26",
			skybox_cloudy = "model/skybox/skybox26/skybox26.x",
			skybox_cloudy_name = "skybox26",
			fog = {fog_start = 90, fog_range = 100, far_plane = 420, },
		},
	},
};

local public_worlds_env_params = {
	["worlds/MyWorlds/61HaqiTown"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.12, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox7/skybox7.x",
			skybox_cloudy_name = "skybox7",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
		night = {
			ambient = {r = 60, g = 147, b = 255},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 255, g = 0, b = 255},
			fog_volume = {_start = 0.010, _end = 0.523, _density = 0.214},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 80, fog_range = 80, far_plane = 600, },
		},
	},
	["worlds/MyWorlds/61HaqiTown_teen"] = {
		day = {
			ambient = {r = 175, g = 175, b = 175},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -0.12, _end = 0.2, _density = 0.9},
			ocean_color = {r = 43, g = 117, b = 43},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
		night = {
			ambient = {r = 191, g = 101, b = 131},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 255, g = 107, b = 75},
			fog_volume = {_start = -0.176, _end = 0.000, _density = 0.724},
			ocean_color = {r = 255, g = 161, b = 121},
			TimeOfDaySTD = 0.7, 
			skybox_sunny = "model/skybox/skybox56/skybox56.x",
			skybox_sunny_name = "skybox56",
			skybox_cloudy = "model/skybox/skybox56/skybox56.x",
			skybox_cloudy_name = "skybox56",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
	},
	["worlds/MyWorlds/FlamingPhoenixIsland"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 179, g = 44, b = 0},
			fog_volume = {_start = -0.071, _end = 0.323, _density = 0.381},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.347, 
			skybox_sunny = "model/skybox/skybox10/skybox10.x",
			skybox_sunny_name = "skybox10",
			skybox_cloudy = "model/skybox/skybox10/skybox10.x",
			skybox_cloudy_name = "skybox10",
			fog = {fog_start = 110, fog_range = 40, far_plane = 900, },
		},
		night = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 154, g = 94, b = 207},
			fog_volume = {_start = 0.051, _end = 0.508, _density = 0.095},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 110, fog_range = 40, far_plane = 900, },
		},
	},
	["worlds/MyWorlds/FlamingPhoenixIsland_teen"] = {
		day = {
			ambient = {r = 170, g = 100, b = 100},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 179, g = 43, b = 0},
			fog_volume = {_start = -0.04, _end = 0.374, _density = 0.380},
			ocean_color = {r = 117, g = 33, b = 56},
			TimeOfDaySTD = 0.6, 
			skybox_sunny = "model/skybox/skybox23/skybox23.x",
			skybox_sunny_name = "skybox23",
			skybox_cloudy = "model/skybox/skybox23/skybox23.x",
			skybox_cloudy_name = "skybox23",
			fog = {fog_start = 70, fog_range = 60, far_plane = 420, },
		},
		night = {
			ambient = {r = 170, g = 100, b = 100},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 179, g = 43, b = 0},
			fog_volume = {_start = -0.04, _end = 0.374, _density = 0.380},
			ocean_color = {r = 117, g = 33, b = 56},
			TimeOfDaySTD = 0.6, 
			skybox_sunny = "model/skybox/skybox23/skybox23.x",
			skybox_sunny_name = "skybox23",
			skybox_cloudy = "model/skybox/skybox23/skybox23.x",
			skybox_cloudy_name = "skybox23",
			fog = {fog_start = 70, fog_range = 60, far_plane = 420, },
		},
	},
	["worlds/MyWorlds/FrostRoarIsland"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 115, g = 193, b = 255},
			fog_volume = {_start = -0.071, _end = 0.6, _density = 0.476},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.347, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 100, fog_range = 40, far_plane = 420, },
		},
		night = {
			ambient = {r = 60, g = 90, b = 140},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 18, g = 41, b = 255},
			fog_volume = {_start = 0.100, _end = 0.400, _density = 0.150},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 100, fog_range = 42, far_plane = 420, },
		},
	},
	["worlds/MyWorlds/FrostRoarIsland_teen"] = {
		day = {
			ambient = {r = 100, g = 131, b = 131},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 114, g = 193, b = 255},
			fog_volume = {_start = -0.8, _end = 1.3, _density = 0.5},
			ocean_color = {r = 0, g = 191, b = 255},
			TimeOfDaySTD = 0.522, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 40, fog_range = 80, far_plane = 420, },
		},
		night = {
			ambient = {r = 100, g = 131, b = 131},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 114, g = 193, b = 255},
			fog_volume = {_start = -0.8, _end = 1.3, _density = 0.5},
			ocean_color = {r = 0, g = 191, b = 255},
			TimeOfDaySTD = 0.522, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 40, fog_range = 80, far_plane = 420, },
		},
	},
	["worlds/MyWorlds/AncientEgyptIsland"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 0},
			fog_color = {r = 172, g = 106, b = 110},
			fog_volume = {_start = -0.414, _end = 0.123, _density = 0.619},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.496, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 168, fog_range = 43, far_plane = 423, },
		},
		night = {
			ambient = {r = 0, g = 131, b = 255},
			diffuse = {r = 255, g = 255, b = 0},
			fog_color = {r = 0, g = 0, b = 255},
			fog_volume = {_start = -0.140, _end = 0.450, _density = 0.167},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.6, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 169, fog_range = 42, far_plane = 423, },
		},
	},
	["worlds/MyWorlds/AncientEgyptIsland_teen"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 0},
			fog_color = {r = 172, g = 106, b = 110},
			fog_volume = {_start = -0.414, _end = 0.123, _density = 0.619},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.496, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 168, fog_range = 43, far_plane = 423, },
		},
		night = {
			ambient = {r = 0, g = 131, b = 255},
			diffuse = {r = 255, g = 255, b = 0},
			fog_color = {r = 0, g = 0, b = 255},
			fog_volume = {_start = -0.140, _end = 0.450, _density = 0.167},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.6, 
			skybox_sunny = "model/skybox/skybox57/skybox57.x",
			skybox_sunny_name = "skybox57",
			skybox_cloudy = "model/skybox/skybox57/skybox57.x",
			skybox_cloudy_name = "skybox57",
			fog = {fog_start = 169, fog_range = 42, far_plane = 423, },
		},
	},
	["worlds/MyWorlds/AriesTutorial"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 186, g = 230, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.35, 
			skybox_sunny = "model/skybox/skybox15/skybox15.x",
			skybox_sunny_name = "skybox15",
			skybox_cloudy = "model/skybox/skybox7/skybox7.x",
			skybox_cloudy_name = "skybox7",
			fog = {fog_start = 80, fog_range = 42, far_plane = 420, },
		},
		night = {
			ambient = {r = 60, g = 147, b = 255},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 255, g = 0, b = 255},
			fog_volume = {_start = 0.010, _end = 0.523, _density = 0.214},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 80, fog_range = 80, far_plane = 600, },
		},
	},
	["worlds/Instances/HaqiTown_RedMushroomArena"] = {
		day = {
			ambient = {r = 156, g = 156, b = 156},
			diffuse = {r = 130, g = 130, b = 130},
			fog_color = {r = 255, g = 170, b = 54},
			fog_volume = {_start = -0.45, _end = 1.3, _density = 0.7},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox7/skybox7.x",
			skybox_sunny_name = "skybox7",
			skybox_cloudy = "model/skybox/skybox7/skybox7.x",
			skybox_cloudy_name = "skybox7",
			fog = {fog_start = 160, fog_range = 40, far_plane = 400, },
		},
		night = {
			ambient = {r = 51, g = 110, b = 101},
			diffuse = {r = 130, g = 130, b = 130},
			fog_color = {r = 255, g = 193, b = 0},
			fog_volume = {_start = -0.45, _end = 0.927, _density = 0.655},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 160, fog_range = 40, far_plane = 400, },
		},
	},
	["worlds/Instances/AncientEgyptIsland_LostTemple"] = {
		day = {
			ambient = {r = 191, g = 101, b = 131},
			diffuse = {r = 130, g = 130, b = 130},
			fog_color = {r = 255, g = 108, b = 74},
			fog_volume = {_start = -0.471, _end = 0.164, _density = 0.724},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 107, fog_range = 42, far_plane = 420, },
		},
		night = {
			ambient = {r = 191, g = 101, b = 131},
			diffuse = {r = 130, g = 130, b = 130},
			fog_color = {r = 255, g = 108, b = 74},
			fog_volume = {_start = -0.471, _end = 0.164, _density = 0.724},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 107, fog_range = 42, far_plane = 420, },
		},
	},
	["worlds/Instances/FlamingPhoenixIsland_TheGreatTree"] = {
		day = {
			ambient = {r = 69, g = 69, b = 69},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 106, g = 101, b = 30},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 0, fog_range = 130, far_plane = 420, },
		},
		night = {
			ambient = {r = 69, g = 69, b = 69},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 106, g = 101, b = 30},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 0, fog_range = 130, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/FlamingPhoenixIsland_GoldenOgreTreasureHouse"] = {
		day = {
			ambient = {r = 255, g = 48, b = 48},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 0, b = 0},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1500, },
		},
		night = {
			ambient = {r = 255, g = 48, b = 48},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 0, b = 0},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1500, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/FlamingPhoenixIsland_GoldenOgreTreasureHouse_teen"] = {
		day = {
			ambient = {r = 255, g = 48, b = 48},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 0, b = 0},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1500, },
		},
		night = {
			ambient = {r = 255, g = 48, b = 48},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 0, b = 0},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1500, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/FrostRoarIsland_StormEye"] = {
		day = {
			ambient = {r = 131, g = 131, b = 131},
			diffuse = {r = 284, g = 284, b = 284},
			fog_color = {r = 137, g = 147, b = 181},
			fog_volume = {_start = -1.000, _end = 1.15, _density = 0.667},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 125, fog_range = 42, far_plane = 420, },
		},
		night = {
			ambient = {r = 131, g = 131, b = 131},
			diffuse = {r = 284, g = 284, b = 284},
			fog_color = {r = 137, g = 147, b = 181},
			fog_volume = {_start = -1.000, _end = 1.15, _density = 0.667},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 125, fog_range = 42, far_plane = 420, },
		},
	},
	["worlds/Instances/HaqiTown_YYsDream_S1"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 179, g = 44, b = 0},
			fog_volume = {_start = -0.071, _end = 0.323, _density = 0.381},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.347, 
			skybox_sunny = "model/skybox/skybox10/skybox10.x",
			skybox_sunny_name = "skybox10",
			skybox_cloudy = "model/skybox/skybox10/skybox10.x",
			skybox_cloudy_name = "skybox10",
			fog = {fog_start = 110, fog_range = 40, far_plane = 900, },
		},
		night = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 154, g = 94, b = 207},
			fog_volume = {_start = 0.051, _end = 0.508, _density = 0.095},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.5, 
			skybox_sunny = "model/skybox/skybox6/skybox6.x",
			skybox_sunny_name = "skybox6",
			skybox_cloudy = "model/skybox/skybox6/skybox6.x",
			skybox_cloudy_name = "skybox6",
			fog = {fog_start = 110, fog_range = 40, far_plane = 900, },
		},
	},
	["worlds/Instances/HaqiTown_YYsDream_S3"] = {
		day = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 250, g = 250, b = 250},
			fog_color = {r = 137, g = 147, b = 181},
			fog_volume = {_start = -1.000, _end = 1.15, _density = 0.667},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 44, fog_range = 42, far_plane = 420, },
		},
		night = {
			ambient = {r = 149, g = 149, b = 149},
			diffuse = {r = 250, g = 250, b = 250},
			fog_color = {r = 137, g = 147, b = 181},
			fog_volume = {_start = -1.000, _end = 1.15, _density = 0.667},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.45, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 44, fog_range = 42, far_plane = 420, },
		},
	},
	["worlds/Instances/Global_TreasureHouse"] = {
		day = {
			ambient = {r = 41, g = 60, b = 71},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 117, g = 44, b = 60},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 0, fog_range = 130, far_plane = 420, },
		},
		night = {
			ambient = {r = 41, g = 60, b = 71},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 117, g = 44, b = 60},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 0, fog_range = 130, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/FrostRoarIsland_IceKingCave"] = {
		day = {
			ambient = {r = 115, g = 255, b = 255},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 0, g = 255, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 140, fog_range = 200, far_plane = 1500, },
		},
		night = {
			ambient = {r = 115, g = 255, b = 255},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 0, g = 255, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 140, fog_range = 200, far_plane = 1500, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_LightHouse"] = {
		day = {
			ambient = {r = 37, g = 92, b = 113},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 90, g = 101, b = 101},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 41, fog_range = 130, far_plane = 420, },
		},
		night = {
			ambient = {r = 37, g = 92, b = 113},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 90, g = 101, b = 101},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 41, fog_range = 130, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_LightHouse_Hero"] = {
		day = {
			ambient = {r = 140, g = 80, b = 131},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 131, b = 0},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 70, fog_range = 150, far_plane = 420, },
		},
		night = {
			ambient = {r = 140, g = 80, b = 131},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 131, b = 0},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 70, fog_range = 150, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_TrialOfChampions"] = {
		day = {
			ambient = {r = 37, g = 92, b = 113},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 0, g = 103, b = 103},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 41, fog_range = 130, far_plane = 420, },
		},
		night = {
			ambient = {r = 37, g = 92, b = 113},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 0, g = 103, b = 103},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 41, fog_range = 130, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_TrialOfChampions_Amateur"] = {
		day = {
			ambient = {r = 21, g = 51, b = 0},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 71, g = 101, b = 71},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 41, fog_range = 130, far_plane = 420, },
		},
		night = {
			ambient = {r = 21, g = 51, b = 0},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 71, g = 101, b = 71},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 41, fog_range = 130, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_TrialOfChampions_Intermediate"] = {
		day = {
			ambient = {r = 30, g = 60, b = 101},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 50, fog_range = 130, far_plane = 420, },
		},
		night = {
			ambient = {r = 30, g = 60, b = 101},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 50, fog_range = 130, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_TrialOfChampions_Master"] = {
		day = {
			ambient = {r = 140, g = 80, b = 131},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 131, b = 0},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 70, fog_range = 150, far_plane = 420, },
		},
		night = {
			ambient = {r = 140, g = 80, b = 131},
			diffuse = {r = 247, g = 247, b = 247},
			fog_color = {r = 255, g = 131, b = 0},
			fog_volume = {_start = -0.03, _end = 0.2, _density = 1.0},
			ocean_color = {r = 0, g = 255, b = 255},
			TimeOfDaySTD = 0.4, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 70, fog_range = 150, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/AncientEgyptIsland_PharaohFortress"] = {
		day = {
			ambient = {r = 0, g = 136, b = 136},
			diffuse = {r = 275, g = 275, b = 275},
			fog_color = {r = 255, g = 200, b = 121},
			fog_volume = {_start = -0.451, _end = 0.449, _density = 0.529},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 1.5, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 60, fog_range = 60, far_plane = 420, },
		},
		night = {
			ambient = {r = 0, g = 136, b = 136},
			diffuse = {r = 275, g = 275, b = 275},
			fog_color = {r = 255, g = 200, b = 121},
			fog_volume = {_start = -0.451, _end = 0.449, _density = 0.529},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 1.5, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 60, fog_range = 60, far_plane = 420, },
		},
	},
	["worlds/Instances/Global_TreasureHouse_teen_1"] = {
		day = {
			ambient = {r = 150, g = 150, b = 150},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 77, g = 119, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.3, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 13, fog_range = 783, far_plane = 863, },
		},
		night = {
			ambient = {r = 150, g = 150, b = 150},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 77, g = 119, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.3, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 13, fog_range = 783, far_plane = 863, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/Global_TreasureHouse_teen_2"] = {
		day = {
			ambient = {r = 150, g = 150, b = 150},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 77, g = 119, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.3, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 13, fog_range = 783, far_plane = 863, },
		},
		night = {
			ambient = {r = 150, g = 150, b = 150},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 77, g = 119, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.3, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 13, fog_range = 783, far_plane = 863, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/DarkForestIsland_DeathDungeon"] = {
		day = {
			ambient = {r = 107, g = 110, b = 124},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 22, g = 51, b = 33},
			fog_volume = {_start = -1.0, _end = 0.12, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.529, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1000, },
		},
		night = {
			ambient = {r = 107, g = 110, b = 124},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 22, g = 51, b = 33},
			fog_volume = {_start = -1.0, _end = 0.12, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.529, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1000, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/DarkForestIsland_LegionGrainDepot"] = {
		day = {
			ambient = {r = 107, g = 110, b = 124},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 22, g = 51, b = 33},
			fog_volume = {_start = -1.0, _end = 0.12, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.529, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1000, },
		},
		night = {
			ambient = {r = 107, g = 110, b = 124},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 22, g = 51, b = 33},
			fog_volume = {_start = -1.0, _end = 0.12, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.529, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 150, fog_range = 200, far_plane = 1000, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/DarkForestIsland_PirateNest"] = {
		day = {
			ambient = {r = 89, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 189, g = 230, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.025, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 180, fog_range = 150, far_plane = 420, },
		},
		night = {
			ambient = {r = 89, g = 149, b = 149},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 189, g = 230, b = 255},
			fog_volume = {_start = -1.0, _end = 0.2, _density = 1.0},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.025, 
			skybox_sunny = "model/skybox/skybox19/skybox19.x",
			skybox_sunny_name = "skybox19",
			skybox_cloudy = "model/skybox/skybox19/skybox19.x",
			skybox_cloudy_name = "skybox19",
			fog = {fog_start = 180, fog_range = 150, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/AncientEgyptIsland_LostTemple_DeathLandEntrance"] = {
		day = {
			ambient = {r = 0, g = 110, b = 255},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 0, g = 137, b = 68},
			fog_volume = {_start = -0.471, _end = 0.164, _density = 0.724},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.612, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 60, fog_range = 80, far_plane = 420, },
		},
		night = {
			ambient = {r = 0, g = 110, b = 255},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 0, g = 137, b = 68},
			fog_volume = {_start = -0.471, _end = 0.164, _density = 0.724},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.612, 
			skybox_sunny = "model/skybox/skybox16/skybox16.x",
			skybox_sunny_name = "skybox16",
			skybox_cloudy = "model/skybox/skybox16/skybox16.x",
			skybox_cloudy_name = "skybox16",
			fog = {fog_start = 60, fog_range = 80, far_plane = 420, },
		},
		bExplicitFog = true,
	},
	["worlds/Instances/HaqiTown_GraduateExam_54_55"] = {
		day = {
			ambient = {r = 175, g = 175, b = 175},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -0.333, _end = 0.000, _density = 0.9},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.36, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
		night = {
			ambient = {r = 175, g = 175, b = 175},
			diffuse = {r = 255, g = 255, b = 255},
			fog_color = {r = 175, g = 255, b = 255},
			fog_volume = {_start = -0.333, _end = 0.000, _density = 0.9},
			--ocean_color = {r = 156, g = 241, b = 159},
			TimeOfDaySTD = 0.36, 
			skybox_sunny = "model/skybox/skybox58/skybox58.x",
			skybox_sunny_name = "skybox58",
			skybox_cloudy = "model/skybox/skybox58/skybox58.x",
			skybox_cloudy_name = "skybox58",
			fog = {fog_start = 100, fog_range = 150, far_plane = 420, },
		},
	},
};

-- not used in paracraft. 
function Player.EnvTimerFunction()
	if(System.options.is_mcworld) then
		return;
	end

	local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
	
	local world_info = WorldManager:GetCurrentWorld()
	local current_worlddir = world_info.worldpath;
	if(not world_info.apply_env_effect) then
		return
	end
	
	local scene_attr = ParaScene.GetAttributeObject();
	if(world_info and world_info.is_underwater) then
		scene_attr:SetField("UseScreenWaveEffect", true);
	else
		scene_attr:SetField("UseScreenWaveEffect", false);
	end

	if(type(HomeLandGateway.IsInHomeland) ~= "function") then
		return
	end
	if(HomeLandGateway.IsInHomeland()) then
		local env_param = homeland_env_params[current_worlddir];
		if(env_param) then
			-- set the homeland enviroment from the env_template
			if(env_param.ocean_color) then
				ParaScene.GetAttributeObjectOcean():SetField("OceanColor", {env_param.ocean_color.r/255, env_param.ocean_color.g/255, env_param.ocean_color.b/255});
			end
			if(env_param.fog_color) then
				scene_attr:SetField("FogColor", {env_param.fog_color.r/255, env_param.fog_color.g/255, env_param.fog_color.b/255});
			end
			if(env_param.skybox and env_param.skybox_name) then
				Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_param.skybox, skybox_name = env_param.skybox_name});
			end
			--if(env_param.fog) then
				--local att = ParaEngine.GetAttributeObject();
				--att:SetField("FogStart", env_param.fog.fog_start);
				--att:SetField("FogEnd", env_param.fog.fog_end);
				--att:SetField("FarPlane", env_param.fog.far_plane);
			--end
			-- slow down the timer
			if(Player.env_timer) then
				Player.env_timer:Change(10000, 10000);
			end
			return;
		end
	end
	
	if(isEnvEditing == true) then
		return;
	end

	local bExplicitFog = false;

	-- disable fog for high
	local x, y, z = Player.GetPlayer():GetPosition();
	if(y > 4000) then
		scene_attr:SetField("EnableFog", false)
	else
		scene_attr:SetField("EnableFog", true)
	end


	local isSnowing = false;
	if(MyCompany.Aries.Scene.GetWeather() == "snow") then
		isSnowing = true;
	end
	local isCloudy = false;
	if(MyCompany.Aries.Scene.GetWeather() == "cloudy") then
		isCloudy = true;
	end
	
	local env_config = public_worlds_env_params[current_worlddir] or public_worlds_env_params["worlds/MyWorlds/61HaqiTown"];

	local world_info = WorldManager:GetCurrentWorld();
	if(world_info) then
		if(prior_worldname_env_params[world_info.name]) then
			env_config = prior_worldname_env_params[world_info.name];
		end
		-- commonlib.echo(world_info.worldpath)
		if(Player.IsInCombat() and world_info.worldpath and prior_worldname_env_params[world_info.worldpath.."_incombat"]) then
			env_config = prior_worldname_env_params[world_info.worldpath.."_incombat"];
		end
		if(world_info.worldpath == "worlds/MyWorlds/AriesTutorialTeen") then
			-- NOTE:diapath when play motion file in AriesTutorialTeen world
			NPL.load("(gl)script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.lua");
			local PickSchoolOfSpell = commonlib.gettable("MyCompany.Aries.Tutorial.PickSchoolOfSpell");
			if(PickSchoolOfSpell.is_play_motion) then
				env_config = prior_worldname_env_params["worlds/MyWorlds/AriesTutorialTeen_incombat"];
			end
		elseif(world_info.worldpath == "worlds/MyWorlds/AriesTutorial") then
			-- NOTE:diapath when play motion file in AriesTutorialTeen world
			NPL.load("(gl)script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.lua");
			local PickSchoolOfSpell = commonlib.gettable("MyCompany.Aries.Tutorial.PickSchoolOfSpell");
			if(PickSchoolOfSpell.is_play_motion) then
				env_config = prior_worldname_env_params["worlds/MyWorlds/AriesTutorialTeen_incombat"];
			end
		end

		if(System.options.version == "teen") then
			if(world_info.name == "61HaqiTown_teen") then
				scene_attr:SetField("FullScreenGlow", true);
				scene_attr:SetField("GlowIntensity", 0.8)
				scene_attr:SetField("GlowFactor", 1.5)
				scene_attr:SetField("Glowness", {0.5, 1, 1, 1.1})
			elseif(world_info.name == "FrostRoarIsland") then
				scene_attr:SetField("FullScreenGlow", true);
				scene_attr:SetField("GlowIntensity", 0.2)
				scene_attr:SetField("GlowFactor", 1.0)
				scene_attr:SetField("Glowness", {0.5, 0.7, 0.7, 1.0})
			elseif(world_info.name == "AncientEgyptIsland") then
				scene_attr:SetField("FullScreenGlow", true);
				scene_attr:SetField("GlowIntensity", 0.3)
				scene_attr:SetField("GlowFactor", 0.5)
				scene_attr:SetField("Glowness", {0.5, 0.5, 0.7, 1.0})
			elseif(world_info.name == "DarkForestIsland") then
				scene_attr:SetField("FullScreenGlow", true);
				scene_attr:SetField("GlowIntensity", 0.2)
				scene_attr:SetField("GlowFactor", 0.1)
				scene_attr:SetField("Glowness", {0.5, 0.5, 0.7, 1.0})
			elseif(world_info.name == "DarkForestIsland_DeathDungeon") then
				scene_attr:SetField("FullScreenGlow", true);
				scene_attr:SetField("GlowIntensity", 0.2)
				scene_attr:SetField("GlowFactor", 1.0)
				scene_attr:SetField("Glowness", {0.35, 0.5, 0.7, 1.0})
			elseif(world_info.name == "CloudFortressIsland") then
				scene_attr:SetField("FullScreenGlow", true);
				scene_attr:SetField("GlowIntensity", 0.6)
				scene_attr:SetField("GlowFactor", 1.0)
				scene_attr:SetField("Glowness", {0.8, 1.0, 1.0, 1.1})
			else
				scene_attr:SetField("FullScreenGlow", false);
			end
		end

		bExplicitFog = env_config.bExplicitFog;
	end

	if(worldnames_with_default_env[world_info.name]) then
		return;
	end

	if(bExplicitFog == true) then
		scene_attr:SetField("EnableFog", true)
	end

	if(System.options.version == "teen") then
		local att = ParaScene.GetAttributeObjectOcean();
		att:SetField("EnableTerrainReflection", false);
		att:SetField("EnableMeshReflection", false);
		att:SetField("EnablePlayerReflection", true);
		att:SetField("EnableCharacterReflection", false);
	end

	-- only apply portion of the env config
	if(env_config and env_config.bPortion and env_config.params) then
		local params = env_config.params;
		-- set the sunlight
		local ambient = params.ambient;
		local diffuse = params.diffuse;
		local TimeOfDaySTD = params.TimeOfDaySTD;
		local att = ParaScene.GetAttributeObjectSunLight();
		if(ambient) then
			att:SetField("Ambient", {ambient.r/255, ambient.g/255, ambient.b/255});
		end
		if(diffuse) then
			att:SetField("Diffuse", {diffuse.r/255, diffuse.g/255, diffuse.b/255});
		end
		if(TimeOfDaySTD) then
			att:SetField("TimeOfDaySTD", TimeOfDaySTD);
		end
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color = params.fog_color;
		if(fog_color) then
			att:SetField("FogColor", {fog_color.r/255, fog_color.g/255, fog_color.b/255});
		end
		local fog = params.fog;
		if(fog and not System.options.IsMobilePlatform) then
			att:SetField("FogStart", fog.fog_start);
			att:SetField("FogEnd", fog.fog_start + fog.fog_range);
			att:SetField("FogRange", fog.fog_range);
			ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			if((fog.fog_start + fog.fog_range) > fog.far_plane) then
				fog.far_plane = fog.fog_start + fog.fog_range;
				ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			end
		end
		local fog_volume = params.fog_volume;
		if(fog_volume) then
			att:SetField("FogDensity", fog_volume._density);
			local att = ParaScene.GetAttributeObjectSky();
			att:SetField("SkyFogAngleFrom", fog_volume._start);
			att:SetField("SkyFogAngleTo", fog_volume._end);
			att:SetField("SkyColor", {255/255, 255/255, 255/255});
		end
		local ocean_color = params.ocean_color;
		if(ocean_color) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, r = ocean_color.r / 255, g = ocean_color.g / 255, b = ocean_color.b / 255,})
		end
		-- set the sky box if daytime
		if(isSnowing and params.skybox_cloudy and params.skybox_cloudy_name) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = params.skybox_cloudy,  skybox_name = params.skybox_cloudy_name})
		elseif(isCloudy and params.skybox_cloudy and params.skybox_cloudy_name) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = params.skybox_cloudy,  skybox_name = params.skybox_cloudy_name})
		elseif(params.skybox_sunny and params.skybox_sunny_name) then
			-- NOTE: default sunny skybox
			-- previous NOTE: no default sky box, some env config like 61HaqiTown_teen_incombat, skybox is not included
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = params.skybox_sunny,  skybox_name = params.skybox_sunny_name})
		end
		-- slow down the timer
		if(Player.env_timer) then
			Player.env_timer:Change(10000, 10000);
		end
		-- create rainbow if not for teen version
		if(System.options.version == "teen") then
			Player.CreateRainBowIfNot();
		end

		return;
	end

	local seconds_since0000 = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	if(seconds_since0000 < (evening_time - evening_process_time)) then
		-- set the sunlight
		local ambient = env_config.day.ambient;
		local diffuse = env_config.day.diffuse;
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("Ambient", {ambient.r/255, ambient.g/255, ambient.b/255});
		att:SetField("Diffuse", {diffuse.r/255, diffuse.g/255, diffuse.b/255});
		att:SetField("TimeOfDaySTD", env_config.day.TimeOfDaySTD);
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color = env_config.day.fog_color;
		att:SetField("FogColor", {fog_color.r/255, fog_color.g/255, fog_color.b/255});
		local fog = env_config.day.fog;
		if(not System.options.IsMobilePlatform) then
			att:SetField("FogStart", fog.fog_start);
			att:SetField("FogEnd", fog.fog_start + fog.fog_range);
			att:SetField("FogRange", fog.fog_range);
			ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			if((fog.fog_start + fog.fog_range) > fog.far_plane) then
				fog.far_plane = fog.fog_start + fog.fog_range;
				ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			end
		end
		local fog_volume = env_config.day.fog_volume;
		att:SetField("FogDensity", fog_volume._density);
		local att = ParaScene.GetAttributeObjectSky();
		att:SetField("SkyFogAngleFrom", fog_volume._start);
		att:SetField("SkyFogAngleTo", fog_volume._end);
		att:SetField("SkyColor", {255/255, 255/255, 255/255});
		local ocean_color = env_config.day.ocean_color;
		if(ocean_color) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, r = ocean_color.r / 255, g = ocean_color.g / 255, b = ocean_color.b / 255,})
		end
		-- set the sky box if daytime
		if(isSnowing) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		elseif(isCloudy) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		else
			-- NOTE: default sunny skybox
			-- previous NOTE: no default sky box, some env config like 61HaqiTown_teen_incombat, skybox is not included
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_sunny,  skybox_name = env_config.day.skybox_sunny_name})
		end
		-- slow down the timer
		if(Player.env_timer) then
			Player.env_timer:Change(10000, 10000);
		end
		-- create rainbow if not for teen version
		if(System.options.version == "teen") then
			Player.CreateRainBowIfNot();
		end
	elseif(seconds_since0000 < evening_time) then
		local ratio = (seconds_since0000 - (evening_time - evening_process_time)) / evening_process_time;
		local R = math.floor(187 + -187 * ratio);
		local G = math.floor(230 + -191 * ratio);
		local B = math.floor(255 + -155 * ratio);
		local start = math.floor(80 + 20 * ratio);
		local range = math.floor(42 + 8 * ratio);
		-- set the sunlight
		local ambient_day = env_config.day.ambient;
		local ambient_night = env_config.night.ambient;
		local diffuse_day = env_config.day.diffuse;
		local diffuse_night = env_config.night.diffuse;
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("Ambient", {
			((ambient_night.r - ambient_day.r) * ratio + ambient_day.r)/255, 
			((ambient_night.g - ambient_day.g) * ratio + ambient_day.g)/255, 
			((ambient_night.b - ambient_day.b) * ratio + ambient_day.b)/255, 
		});
		att:SetField("Diffuse", {
			((diffuse_night.r - diffuse_day.r) * ratio + diffuse_day.r)/255, 
			((diffuse_night.g - diffuse_day.g) * ratio + diffuse_day.g)/255, 
			((diffuse_night.b - diffuse_day.b) * ratio + diffuse_day.b)/255, 
		});
		att:SetField("TimeOfDaySTD", ((env_config.night.TimeOfDaySTD - env_config.day.TimeOfDaySTD) * ratio + env_config.day.TimeOfDaySTD));
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color_day = env_config.day.fog_color;
		local fog_color_night = env_config.night.fog_color;
		att:SetField("FogColor", {
			((fog_color_night.r - fog_color_day.r) * ratio + fog_color_day.r)/255, 
			((fog_color_night.g - fog_color_day.g) * ratio + fog_color_day.g)/255, 
			((fog_color_night.b - fog_color_day.b) * ratio + fog_color_day.b)/255, 
		});
		local fog = env_config.day.fog;
		if(not System.options.IsMobilePlatform) then
			att:SetField("FogStart", fog.fog_start);
			att:SetField("FogEnd", fog.fog_start + fog.fog_range);
			att:SetField("FogRange", fog.fog_range);
			ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			if((fog.fog_start + fog.fog_range) > fog.far_plane) then
				fog.far_plane = fog.fog_start + fog.fog_range;
				ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			end
		end
		local fog_volume_day = env_config.day.fog_volume;
		local fog_volume_night = env_config.night.fog_volume;
		att:SetField("FogDensity", ((fog_volume_night._density - fog_volume_day._density) * ratio + fog_volume_day._density));
		local att = ParaScene.GetAttributeObjectSky();
		att:SetField("SkyFogAngleFrom", ((fog_volume_night._start - fog_volume_day._start) * ratio + fog_volume_day._start));
		att:SetField("SkyFogAngleTo", ((fog_volume_night._end - fog_volume_day._end) * ratio + fog_volume_day._end));
		att:SetField("SkyColor", {
			((fog_color_night.r - 255) * ratio + 255)/255, 
			((fog_color_night.g - 255) * ratio + 255)/255, 
			((fog_color_night.b - 255) * ratio + 255)/255, 
		});
		local ocean_color = env_config.day.ocean_color;
		if(ocean_color) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, r = ocean_color.r / 255, g = ocean_color.g / 255, b = ocean_color.b / 255,})
		end
		-- set the sky box if nighttime
		if(isSnowing) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		elseif(isCloudy) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_cloudy,  skybox_name = env_config.day.skybox_cloudy_name})
		else
			-- NOTE: default sunny skybox
			-- previous NOTE: no default sky box, some env config like 61HaqiTown_teen_incombat, skybox is not included
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.day.skybox_sunny,  skybox_name = env_config.day.skybox_sunny_name})
		end
		-- fast up the timer
		if(Player.env_timer) then
			Player.env_timer:Change(2000, 2000);
		end
		-- remove rainbow if not for teen version
		if(System.options.version == "teen") then
			Player.CreateRainBowIfNot();
		end
	else
		-- set the sunlight
		local ambient = env_config.night.ambient;
		local diffuse = env_config.night.diffuse;
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("Ambient", {ambient.r/255, ambient.g/255, ambient.b/255});
		att:SetField("Diffuse", {diffuse.r/255, diffuse.g/255, diffuse.b/255});
		att:SetField("TimeOfDaySTD", env_config.night.TimeOfDaySTD);
		-- set the fog parameters
		local att = ParaScene.GetAttributeObject();
		local fog_color = env_config.night.fog_color;
		att:SetField("FogColor", {fog_color.r/255, fog_color.g/255, fog_color.b/255});
		local fog = env_config.night.fog;
		if(not System.options.IsMobilePlatform) then
			att:SetField("FogStart", fog.fog_start);
			att:SetField("FogEnd", fog.fog_start + fog.fog_range);
			att:SetField("FogRange", fog.fog_range);
			ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			if((fog.fog_start + fog.fog_range) > fog.far_plane) then
				fog.far_plane = fog.fog_start + fog.fog_range;
				ParaCamera.GetAttributeObject():SetField("FarPlane", fog.far_plane);
			end
		end
		local fog_volume = env_config.night.fog_volume;
		att:SetField("FogDensity", fog_volume._density);
		local att = ParaScene.GetAttributeObjectSky();
		att:SetField("SkyFogAngleFrom", fog_volume._start);
		att:SetField("SkyFogAngleTo", fog_volume._end);
		att:SetField("SkyColor", {255/255, 255/255, 255/255});
		local ocean_color = env_config.night.ocean_color;
		if(ocean_color) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, r = ocean_color.r / 255, g = ocean_color.g / 255, b = ocean_color.b / 255,})
		end
		-- set the sky box if nighttime
		if(isSnowing) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.night.skybox_cloudy,  skybox_name = env_config.night.skybox_cloudy_name})
		elseif(isCloudy) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.night.skybox_cloudy,  skybox_name = env_config.night.skybox_cloudy_name})
		else
			-- NOTE: default sunny skybox
			-- previous NOTE: no default sky box, some env config like 61HaqiTown_teen_incombat, skybox is not included
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = env_config.night.skybox_sunny,  skybox_name = env_config.night.skybox_sunny_name})
		end
		-- slow down the timer
		if(Player.env_timer) then
			Player.env_timer:Change(10000, 10000);
		end
		-- remove rainbow if not for teen version
		if(System.options.version == "teen") then
			Player.RemoveRainBowIfNot();
		end
	end
end

function Player.CreateRainBowIfNot()
	local world_info = WorldManager:GetCurrentWorld();
	if(world_info and world_info.name == "61HaqiTown_teen") then
		local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(309012);
		if(not npcChar) then
			local params = {
				name = "",
				position = { 19835.79688, 19.42912, 19082.42383 },
				assetfile_char = "character/common/dummy/elf_size/elf_size.x",
				assetfile_model = "model/06props/v6/03quest/Rainbow/Rainbow.x",
				facing = 0.14711,
				scaling = 1,
				scale_char = 0.00001,
				scaling_model = 1.07811,
				isBigStaticMesh = true,
				talk_dist = 0.06,
				main_script = "script/apps/Aries/Instance/main.lua",
				main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			local _, npcModel = NPC.CreateNPCCharacter(309012, params);
			if(npcModel and npcModel:IsValid() == true) then
				npcModel:SetField("ShadowCaster", false);
			end
		end
	end
end

function Player.RemoveRainBowIfNot()
	local npcChar, npcModel = NPC.GetNpcCharacterFromIDAndInstance(309012);
	if(npcChar) then
		NPC.DeleteNPCCharacter(309012);
	end
end

-- get the skin color index in clientdata of #999 item
function Player.GetAvailableSkinColorIndex()
	return {0, 1, 2, 3, 4, 5};
end

-- get the skin color index in clientdata of #999 item
function Player.GetMySkinColorIndex()
	local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 21);
	if(item and item.guid > 0) then
		local section1, section2, _, section3 = string.match(item.clientdata, "^(%d+)#1#([^@]*)@(%d+)#F#0#0#0#0#(.+)@$");
		if(section1) then
			section1 = tonumber(section1);
			return section1;
		end
	end
end

-- get the skin color index in clientdata of #999 item
-- @param index: index of the skin color
-- @param bFreshMyself: auto refresh avatar by ccs info, default true
-- @return: true if successfully set, false if no skin color available
function Player.SetMySkinColorIndex(index, bFreshMyself)
	local ItemManager = System.Item.ItemManager;
	local item = ItemManager.GetItemByBagAndPosition(0, 21);
	if(item and item.guid > 0) then
		--local section1, section2, _, section3 = string.match(item.clientdata, "^(%d+)#1#([^@]*)@(%d+)#F#0#0#0#0#(.+)@$");
		local section1, __, ___, ____, _, section3 = string.match(item.clientdata, "^(%d+)#1#(%d+)#(%d+)#([^#]+)#@(%d+)#F#0#0#0#0#(.+)@$");
		local section2 = __.."#"..___.."#F#";
		
		if(section1 and section2 and section3) then
			local clientdata_toset = string.format("%d#1#%s@%d#F#0#0#0#0#%s@", index, section2, index, section3);
		
			if(clientdata_toset) then
				ItemManager.SetClientData(item.guid, clientdata_toset, function() 
					if(bFreshMyself ~= false) then
						ItemManager.RefreshMyself();
					end
				end, 0); -- 0 for bag
			end
			return true;
		end
	end
	return false;
end

-- play animation from nid and value
-- @param nid: nid of the user, nid for loggedinuser
-- @param value: string of the gsid, if negitive it is a predefined animation table
function Player.PlayAnimationFromValue(nid, value)
	local gsid, x, y, z;
	if(type(value) == "number") then
		gsid = value;
	elseif(type(value) == "string") then
		gsid, x, y, z = string.match(value, "(%d+):([%-%.%d]+)%s([%-%.%d]+)%s([%-%.%d]+)");
		if(gsid and x and y and z) then
			gsid = tonumber(gsid);
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
		elseif(tonumber(value)) then
			gsid = tonumber(value);
		else
			return;
		end
	end
	if(gsid and gsid > 0) then
		-- positive gsid stands for gloabl store item
		local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local animfile = gsItem.assetfile;
			local class = gsItem.template.class;
			local subclass = gsItem.template.subclass;
			local effectfile = gsItem.descfile;
			local duration = gsItem.template.stats[15];
			--local animfile = commonlib.Encoding.Utf8ToDefault(anims[tonumber(index)].animfile)
			if(class == 15 and subclass == 1) then
				-- character animation
				local headonmodel;
				local headonchar;
				
				NPL.load("(gl)script/apps/Aries/Pet/main.lua");
				local player = Pet.GetUserCharacterObj(nid);
				if(player and player:IsValid() == true) then
					if(x and y and z) then
						player:ToCharacter():Stop();
						player:SetPosition(x, y, z);
					end
					-- directly play animation
					System.Animation.PlayAnimationFile(animfile, player);
					---- change headonmodel or headonchar
					--if(headonmodel or headonchar) then
						--player:ToCharacter():RemoveAttachment(11);
						--local asset;
						--if(headonmodel) then 
							--asset = ParaAsset.LoadStaticMesh("", headonmodel);
						--elseif(headonchar) then 
							--asset = ParaAsset.LoadParaX("", headonchar);
						--end	
						--if(asset~=nil and asset:IsValid()) then
							--player:ToCharacter():AddAttachment(asset, 11);
						--end
					--else
						--player:ToCharacter():RemoveAttachment(11);
					--end
				end
				
			elseif(class == 15 and subclass == 2) then
				-- mount pet animation
				local headonmodel = effectfile;
				local headonchar;
				
				local mountPet = Pet.GetUserMountObj(nid);
				if(mountPet and mountPet:IsValid() == true) then
					if(duration == 0) then
						if(x and y and z) then
							mountPet:ToCharacter():Stop();
							mountPet:SetPosition(x, y, z);
						end
						-- loop animation
						if(animfile) then
							System.Animation.PlayAnimationFile(animfile, mountPet);
						end
					elseif(type(duration) == "number") then
						local function play()
							local mountPet = Pet.GetUserMountObj(nid);
							if(mountPet and mountPet:IsValid() == true) then
								if(animfile) then
									System.Animation.PlayAnimationFile(animfile, mountPet);
								end	
								-- change headonmodel or headonchar
								if(headonmodel or headonchar) then
									mountPet:ToCharacter():RemoveAttachment(19);
									local asset;
									if(headonmodel) then 
										asset = ParaAsset.LoadStaticMesh("", headonmodel);
									elseif(headonchar) then 
										asset = ParaAsset.LoadParaX("", headonchar);
									end	
									if(asset~=nil and asset:IsValid()) then
										mountPet:ToCharacter():AddAttachment(asset, 19);
									end
								end
							end
						end
						local function stop()
							local mountPet = Pet.GetUserMountObj(nid);
							if(mountPet and mountPet:IsValid() == true) then
								mountPet:ToCharacter():RemoveAttachment(19);
								System.Animation.PlayAnimationFile(0, mountPet);
							end
						end
						
						if(x and y and z) then
							mountPet:ToCharacter():Stop();
							mountPet:SetPosition(x, y, z);
						end
						UIAnimManager.PlayCustomAnimation(duration * 100, function(elapsedTime)
							if(elapsedTime == 0) then
								stop();
								play();
							elseif(elapsedTime == duration * 100) then
								stop();
							end
						end);
					end
					
					--NPL.load("(gl)script/ide/Transitions/TweenLite.lua");
					--local self = MyCompany.Aries;
					--if(not self.tween)then
						--local tween=CommonCtrl.TweenLite:new{
							--duration = 4000,-- millisecond
							--OnStartFunc = function(self)
								--stop();
								--play();
							--end,
							--OnUpdateFunc = function(self)
								--
							--end,
							--OnEndFunc = function(self)
								--stop();
							--end,
						--}
						--self.tween = tween;
					--end
					--self.tween:Start();
				end
			end
		end
	elseif(gsid and gsid < 0) then
		-- negitive gsid stands for predefined animations
		if(gsid == -1 or gsid == -2 or gsid == -3) then
			-- -1: normal mount dragon level up
			-- -2: mount dragon level up from egg to minor
			-- -3: mount dragon level up from minor to major
			local mountPet = Pet.GetUserMountObj(nid);
			if(mountPet and mountPet:IsValid() == true) then
				local mountPet_name = mountPet.name;
				-- play sound for levelup
				if(nid == nil or nid == System.App.profiles.ProfileManager.GetNID()) then
					--local dx, dy, dz = mountPet:GetPosition();
					--ParaAudio.PlayStatic3DSound("MissionComplete", "LevelUp_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
					local name = "Audio/Haqi/MissionComplete.wav";
					MyCompany.Aries.Scene.PlayGameSound(name);
				end
				local skincolor_id;
				local params = {
					asset_file = "character/v5/09effect/Upgrade/Upgrade.x",
					binding_obj_name = mountPet_name,
					duration_time = 1600,
					end_callback = function()
							local mountPet = Pet.GetUserMountObj(nid);
							if(mountPet and mountPet:IsValid() == true) then
								if(gsid == -2 or gsid == -3) then
									if(nid == nil or nid == System.App.profiles.ProfileManager.GetNID()) then
										-- myself reset the mount pet asset file
										System.Item.ItemManager.RefreshMyself();
									else
										local ItemManager = System.Item.ItemManager;
										local assetfile;
										if(gsid == -2) then
											assetfile = ItemManager.GetAssetFileFromGSIDAndIndex(10001, 2);
										elseif(gsid == -3) then
											assetfile = ItemManager.GetAssetFileFromGSIDAndIndex(10001, 3);
										end
										
										local asset = ParaAsset.LoadParaX("", assetfile);
										local mountPetChar = mountPet:ToCharacter();
										mountPetChar:ResetBaseModel(asset);
										
										if(gsid == -2) then
											local replaceable_tex;
											if(skincolor_id == 1) then
												replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor01.dds";
											elseif(skincolor_id == 2) then
												replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor02.dds";
											elseif(skincolor_id == 3) then
												replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor03.dds";
											elseif(skincolor_id == 4) then
												replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor04.dds";
											elseif(skincolor_id == 5) then
												replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor05.dds";
											elseif(skincolor_id == 6) then
												replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor06.dds";
											end
											if(replaceable_tex) then
												mountPet:SetReplaceableTexture(1, ParaAsset.LoadTexture("", replaceable_tex, 1));
											end
										elseif(gsid == -3) then
											if(skincolor_id == 1) then
												mountPet:ToCharacter():SetBodyParams(1, -1, -1, -1, -1);
											elseif(skincolor_id == 2) then
												mountPet:ToCharacter():SetBodyParams(2, -1, -1, -1, -1);
											elseif(skincolor_id == 3) then
												mountPet:ToCharacter():SetBodyParams(3, -1, -1, -1, -1);
											elseif(skincolor_id == 4) then
												mountPet:ToCharacter():SetBodyParams(4, -1, -1, -1, -1);
											elseif(skincolor_id == 5) then
												mountPet:ToCharacter():SetBodyParams(5, -1, -1, -1, -1);
											elseif(skincolor_id == 6) then
												mountPet:ToCharacter():SetBodyParams(6, -1, -1, -1, -1);
											end
										end
									end
								end -- if(gsid == -2 or gsid == -3) then
								--if(preLevel ~= level) then
									----改变坐骑的资源文件
									--Map3DSystem.Item.ItemManager.RefreshMyself();
								--end
							end -- if(mountPet and mountPet:IsValid() == true) then
						end,
				};
				
				-- change of dragon stage will force the dragon asset change
				-- when the next ccsinfo arrived, it will be refreshed with the new ccsinfo
				if(gsid == -2 or gsid == -3) then -- change of dragon stage
					local texture_name = mountPet:GetReplaceableTexture(1):GetFileName();
					if(texture_name == "character/v3/PurpleDragonEgg/SkinColor01.dds") then
						skincolor_id = 1;
					elseif(texture_name == "character/v3/PurpleDragonEgg/SkinColor02.dds") then
						skincolor_id = 2;
					elseif(texture_name == "character/v3/PurpleDragonEgg/SkinColor03.dds") then
						skincolor_id = 3;
					elseif(texture_name == "character/v3/PurpleDragonEgg/SkinColor04.dds") then
						skincolor_id = 4;
					elseif(texture_name == "character/v3/PurpleDragonEgg/SkinColor05.dds") then
						skincolor_id = 5;
					elseif(texture_name == "character/v3/PurpleDragonEgg/SkinColor06.dds") then
						skincolor_id = 6;
					elseif(texture_name == "character/v3/PurpleDragonMinor/SkinColor01.dds") then
						skincolor_id = 1;
					elseif(texture_name == "character/v3/PurpleDragonMinor/SkinColor02.dds") then
						skincolor_id = 2;
					elseif(texture_name == "character/v3/PurpleDragonMinor/SkinColor03.dds") then
						skincolor_id = 3;
					elseif(texture_name == "character/v3/PurpleDragonMinor/SkinColor04.dds") then
						skincolor_id = 4;
					elseif(texture_name == "character/v3/PurpleDragonMinor/SkinColor05.dds") then
						skincolor_id = 5;
					elseif(texture_name == "character/v3/PurpleDragonMinor/SkinColor06.dds") then
						skincolor_id = 6;
					end
					if(not skincolor_id) then
						if(mountPet:ToCharacter():IsCustomModel()) then
							skincolor_id = mountPet:ToCharacter():GetBodyParams(0);
						end
					end
					
					local ItemManager = System.Item.ItemManager;
					local assetfile;
					if(gsid == -2) then
						assetfile = ItemManager.GetAssetFileFromGSIDAndIndex(10001, 1);
					elseif(gsid == -3) then
						assetfile = ItemManager.GetAssetFileFromGSIDAndIndex(10001, 2);
					end
					-- just in case the ccsinfo arrives first
					if(assetfile and assetfile ~=  mountPet:GetPrimaryAsset():GetKeyName()) then
						local asset = ParaAsset.LoadParaX("", assetfile);
						local mountPetChar = mountPet:ToCharacter();
						mountPetChar:ResetBaseModel(asset);
						
						local replaceable_tex;
						if(gsid == -2) then
							if(skincolor_id == 1) then
								--replaceable_tex = "character/v3/PurpleDragonEgg/SkinColor01.dds";
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor01.dds";
							elseif(skincolor_id == 2) then
								--replaceable_tex = "character/v3/PurpleDragonEgg/SkinColor02.dds";
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor02.dds";
							elseif(skincolor_id == 3) then
								--replaceable_tex = "character/v3/PurpleDragonEgg/SkinColor03.dds";
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor03.dds";
							elseif(skincolor_id == 4) then
								--replaceable_tex = "character/v3/PurpleDragonEgg/SkinColor04.dds";
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor04.dds";
							elseif(skincolor_id == 5) then
								--replaceable_tex = "character/v3/PurpleDragonEgg/SkinColor05.dds";
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor05.dds";
							elseif(skincolor_id == 6) then
								--replaceable_tex = "character/v3/PurpleDragonEgg/SkinColor06.dds";
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor06.dds";
							end
						elseif(gsid == -3) then
							if(skincolor_id == 1) then
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor01.dds";
							elseif(skincolor_id == 2) then
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor02.dds";
							elseif(skincolor_id == 3) then
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor03.dds";
							elseif(skincolor_id == 4) then
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor04.dds";
							elseif(skincolor_id == 5) then
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor05.dds";
							elseif(skincolor_id == 6) then
								replaceable_tex = "character/v3/PurpleDragonMinor/SkinColor06.dds";
							end
						end
						if(replaceable_tex) then
							mountPet:SetReplaceableTexture(1, ParaAsset.LoadTexture("", replaceable_tex, 1));
						end
					end
				end
				
				EffectManager.CreateEffect(params);
			end
		elseif(gsid == -4 or gsid == -5 or gsid == -6) then
			-- -4: born from purple egg
			-- -5: born from orange egg
			-- -6: born from green egg
			
			--if(nid ~= System.App.profiles.ProfileManager.GetNID()) then
			--end
			--NPL.load("(gl)script/apps/Aries/Pet/main.lua");
			--local mountPet = Pet.GetUserMountObj(nid);
			--if(mountPet and mountPet:IsValid() == true) then
				--
			--else
				--
			--end
		elseif(gsid == -7) then
			-- -7 for combat level up effect
			if(System.options.version == "kids") then
				local playerChar = Pet.GetUserCharacterObj(nid);
				if(playerChar and playerChar:IsValid() == true) then
					local playerChar_name = playerChar.name;
					local params = {
						asset_file = "character/v5/temp/Effect/Ice_Precast_Uber_Base.x",
						binding_obj_name = playerChar_name,
						scale = 1.5,
						duration_time = 1600,
						stage1_time = 1000,
						stage1_callback = function()
							local playerChar = Pet.GetUserCharacterObj(nid);
							if(playerChar and playerChar:IsValid() == true) then
								local playerChar_name = playerChar.name;
								local params = {
									asset_file = "character/v5/09effect/Upgrade/Upgrade.x",
									binding_obj_name = playerChar_name,
									duration_time = 1600,
								};
								EffectManager.CreateEffect(params);
							end
						end,
					};
					EffectManager.CreateEffect(params);
				end
			elseif(System.options.version == "teen") then
				-- play level up effect
				NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
				local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
				local spell_file = "config/Aries/Spells/Action_OnLevelUp_teen.xml";
				local current_playing_id = ParaGlobal.GenerateUniqueID();
				local playerChar = Pet.GetUserCharacterObj(nid);
				if(playerChar and playerChar:IsValid() == true) then
					SpellCast.EntitySpellCast(0, playerChar, 1, playerChar, 1, spell_file, nil, nil, nil, nil, nil, function()
					end, nil, true, current_playing_id, true);
				end
			end
		elseif(gsid and gsid <= -1000 and gsid >= -1999) then
			-- sunshine station tanned effect
			local skincolorindex = math.mod(math.abs(gsid), 1000);
			if(skincolorindex >= 0) then
				local userChar = Pet.GetUserCharacterObj(nid);
				if(userChar and userChar:IsValid() == true) then
					if(nid == nil or nid == System.App.profiles.ProfileManager.GetNID()) then
						-- the effect is played in 30141_SunshineStation_dialog.html
					else
						local params = {
							asset_file = "character/v5/09effect/ChangeColor/ChangeColor.x",
							binding_obj_name = userChar.name,
							duration_time = 2600,
							end_callback = function()
								end,
							stage1_time = 2000,
							stage1_callback = function()
								local userChar = Pet.GetUserCharacterObj(nid);
								if(userChar and userChar:IsValid() == true) then
									-- directly set the cartoonface and skin color index
									-- the CCS info will be updated in the next GSL normal update
									userChar:ToCharacter():SetBodyParams(skincolorindex, -1, -1, -1, -1);
									userChar:ToCharacter():SetCartoonFaceComponent(0, 0, skincolorindex);
								end
							end,
						};
						EffectManager.CreateEffect(params);
					end
				end
			end
		end
	end
end

-- return true if player is currently involved in combat. we may not allow certain actions when player in combat. 
function Player.IsInCombat() 
	return CombatHandler.IsInCombat();
end

-- get max HP
function Player.GetMaxHP()
	return HPMyPlayerArea.max_value or 100;
end

-- get current HP
function Player.GetCurrentHP()
	return HPMyPlayerArea.cur_value or 0;
end

-- get the max bag size in slot count. defaults to 120. 
function Player.GetMaxBagSize()
	if(System.options.version == "teen") then
		if(CharacterBagPage.GetBagSize) then
			return CharacterBagPage.GetBagSize();
		end
	else
		if(VIP.IsVIP()) then
			return 300;
		else
			return 150;
		end
	end
	return 64;
end

-- whether the bag has exceed limit.
-- @return true if bag is too heavy. 
function Player.IsBagTooHeavy()
	if(System.options.version == "teen") then
		if(CharacterBagPage.IsBagTooHeavy) then
			return CharacterBagPage.IsBagTooHeavy();
		end
	else
		if(CombatInventorySubPage.GetBagSize) then
			if(CombatInventorySubPage.GetBagSize() > Player.GetMaxBagSize()) then
				return true;
			end
		end
		if(CombatCollectableSubPage.GetBagSize) then
			if(CombatCollectableSubPage.GetBagSize() > Player.GetMaxBagSize()) then
				return true;
			end
		end
	end
end

-- get the nearest npc around the current player position. 
-- the npc.name must begin with "NPC:" and the its displayname must be non-empty.
-- @param radius: we will search for all npcs within this radius. if nil, it is 6 meters
-- @return npc_object, npc_id, instance: nil may be returned if not found. 
function Player.GetNearestNPC(radius)
	radius = radius or 6;
	-- search for any objects within 6 meters from the current player. 
	local player = Player.GetPlayer()
	local fromX, fromY, fromZ = player:GetPosition()

	local objlist = {};
	local nCount = ParaScene.GetObjectsBySphere(objlist, fromX, fromY, fromZ, radius, "biped");
	local k = 1;
	local closest = nil;
	local min_dist = 100000;
	local npc_id, instance;
	for k = 1, nCount do
		local obj = objlist[k];
		if(NPC.IsNPC(obj) and obj:GetDynamicField("DisplayName", "") ~= "") then
			local dist = obj:DistanceTo(player);
			if( dist < min_dist) then
				closest = obj;
				min_dist = dist;
			end
		end
	end
	if(closest) then
		npc_id, instance = NPC.GetNpcIDAndInstanceFromCharacter(closest);
		if(npc_id) then
			return closest, npc_id, instance			
		end
	end
end

-- save a name, value pair to local disk file per user in config/userdata.db
-- please note that if user changes computer, data is not preserved. 
-- This function is IO heavy, do not call it very frequently. 
-- @param name: this is a name (url) such as "AppName.FieldName". This function ensures that user nid is automatically encoded to name when saving to disk. 
-- @param value: it can be string, number or table. 
-- @param bIsGlobal: if true, we will save to database without appending current nid to the key. One can set this to true for data that is global to all users on the local computer. 
-- @param bDeferSave: if true, we will defer flushing to database. default to nil, where changes will be flushed to disk. 
-- @return true if succeed
function Player.SaveLocalData(name, value, bIsGlobal, bDeferSave)
	local ls = System.localserver.CreateStore(nil, 3, if_else(System.options.version == "teen", "userdata.teen", "userdata"));
	if(not ls) then
		return;
	end
	-- make url
	local url;
	if(not bIsGlobal) then
		url = NPL.EncodeURLQuery(name, {"nid", Map3DSystem.User.nid})
	else
		url = name;
	end
	
	-- make entry
	local item = {
		entry = System.localserver.WebCacheDB.EntryInfo:new({
			url = url,
		}),
		payload = System.localserver.WebCacheDB.PayloadInfo:new({
			status_code = System.localserver.HttpConstants.HTTP_OK,
			data = {value = value},
		}),
	}
	-- save to database entry
	local res = ls:PutItem(item, not bDeferSave);
	if(res) then 
		LOG.std("", "debug","Player", "Local user data %s is saved to local server", tostring(url));
		return true;
	else	
		LOG.std("", "warn","Player", "failed saving local user data %s to local server", tostring(url))
	end
end

function Player.FlushLocalData()
	local ls = System.localserver.CreateStore(nil, 3, if_else(System.options.version == "teen", "userdata.teen", "userdata"));
	if(ls) then
		return ls:Flush();
	end
end

-- load a given value from local disk file. 
-- @param name: the key to retrieve the data
-- @param default_value: the default value if no value is stored
-- @return the value
function Player.LoadLocalData(name, default_value, bIsGlobal)
	local ls = System.localserver.CreateStore(nil, 3, if_else(System.options.version == "teen", "userdata.teen", "userdata"));
	if(not ls) then
		LOG.std(nil, "warn", "Player", "Player.LoadLocalData %s failed because userdata db is not valid", name)
		return default_value;
	end
	local url;
	-- make url
	if(not bIsGlobal) then
		url = NPL.EncodeURLQuery(name, {"nid", Map3DSystem.User.nid})
	else
		url = name;
	end
	
	local item = ls:GetItem(url)
			
	if(item and item.entry and item.payload) then
		local output_msg = commonlib.LoadTableFromString(item.payload.data);
		if(output_msg) then
			return output_msg.value;
		end
	end
	return default_value;
end


--ref luck value(0:大凶(-8%)；1:凶(-4%)；2:正常(0%)；3:小吉(4%)；4:吉(8%))
function Player.GetTimeLucky()
	local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
	local userinfo = ProfileManager.GetUserInfoInMemory();
	local luckyValue = userinfo.luck;

	if(luckyValue == 0) then
		return -8,luckyValue,"大凶";
	elseif(luckyValue == 1) then
		return -4,luckyValue,"凶";
	elseif(luckyValue == 2) then
		return 0,luckyValue,"正常";
	elseif(luckyValue == 3) then
		return 4,luckyValue,"小吉";
	elseif(luckyValue == 4) then
		return 8,luckyValue,"吉";
	else
		return 0,0;
	end
end

-- mount pet asset name to mount animation file name. 
local default_mount_anim_map_teen = {
	["character/v6/02animals/MagicBesom/MagicBesom.x"] = "character/Animation/v5/MagicBesom_teen.x",
	["character/common/teen_default_combat_pose_mount/teen_default_combat_pose_mount.x"] = "character/Animation/v6/teen_default_combat_pose.x",
	["character/v6/02animals/HuLangMoTuo/HuLangMoTuo.x"] = "character/Animation/v6/TeenElfMale_Car1.x",
};
local default_mount_anim_map_kids = {
	["character/v5/02animals/ChiBang01/ChiBang01.x"] = "character/Animation/v5/ElfFemale_chibang.x",
	["character/v5/02animals/ChiBang02/ChiBang02.x"] = "character/Animation/v5/ElfFemale_chibang.x",
	["character/v5/02animals/Jinglingyuyi/Jinglingyuyi01.x"] = "character/Animation/v5/ElfFemale_chibang.x",
	["character/v5/02animals/Jinglingyuyi/Jinglingyuyi02.x"] = "character/Animation/v5/ElfFemale_chibang.x",
	["character/v5/02animals/Jinglingyuyi/Jinglingyuyi03.x"] = "character/Animation/v5/ElfFemale_chibang.x",
};

-- mount pet asset name to mount animation file name. 
local default_mount_anim_map_teen_with_sex = {
	["character/v6/02animals/huoyanzhiyi/huoyanzhiyi.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/TianShiZhiYi/TianShiZhiYi.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/XueDiChe/XueDiChe.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_Car.x",
		["female"] = "character/Animation/v6/TeenElfMale_Car.x",
	},
	
	["character/v6/02animals/TianShiZhiYi_Fire/TianShiZhiYi_Fire.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/TianShiZhiYi_Ice/TianShiZhiYi_Ice.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/TianShiZhiYi_Storm/TianShiZhiYi_Storm.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/TianShiZhiYi_Life/TianShiZhiYi_Life.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/TianShiZhiYi_Death/TianShiZhiYi_Death.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
};

-- mapping from driver's asset to their default mount position.
local default_mount_anim_map_driver = {
	["character/v3/Elf/Female/ElfFemale.xml"] = "character/Animation/v5/DefaultMount.x",
	["character/v6/01human/ChristmasGrandpa/ChristmasGrandpa.x"] = "character/Animation/v5/DefaultMount_teen.x",
};

function Player.GetMountAnimation(driver_asset)
	return default_mount_anim_map_driver[driver_asset];
end

-- get mount aniamtion file according to driver and target asset key
function Player.GetMountAnimationFile(driver, target)
	if(driver and target and driver:IsValid() and target:IsValid()) then
		local target_assetkey = target:GetPrimaryAsset():GetKeyName();
		local driver_assetkey = driver:GetPrimaryAsset():GetKeyName();
		if(driver_assetkey == "character/v3/Elf/Female/ElfFemale.xml") then
			return default_mount_anim_map_kids[target_assetkey] or "character/Animation/v5/DefaultMount.x";

		elseif(driver_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml" or 
			driver_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
			if(target_assetkey == "character/common/teen_default_combat_pose_mount/teen_default_combat_pose_mount.x" or target_assetkey == "character/v6/02animals/WhiteCloud/WhiteCloud.x") then
				if(driver_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
					return "character/Animation/v6/teen_default_combat_pose_female.x";
				elseif(driver_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
					return "character/Animation/v6/teen_default_combat_pose_male.x";
				end
			--elseif(target_assetkey == "character/v6/02animals/WhiteCloud/WhiteCloud.x") then 
				--if(driver_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
					--return "character/Animation/v6/teen_Mount_FlyingCloud_female.x";
				--elseif(driver_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
					--return "character/Animation/v6/teen_Mount_FlyingCloud_male.x";
				--end
			end
			if(default_mount_anim_map_teen_with_sex[target_assetkey]) then
				local male_anim = default_mount_anim_map_teen_with_sex[target_assetkey]["male"];
				local female_anim = default_mount_anim_map_teen_with_sex[target_assetkey]["female"];
				if(female_anim and driver_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
					return female_anim;
				elseif(male_anim and driver_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
					return male_anim;
				end
			end
			return default_mount_anim_map_teen[target_assetkey] or "character/Animation/v5/DefaultMount_teen.x"
		else
			return default_mount_anim_map_driver[driver_assetkey];
		end
	end
end

-- one needs to test if returned paraobject is valid
function Player.GetPlayerObject()
	if(System.options.mc) then
		local entity = GameLogic.EntityManager.GetPlayer();
		return entity and entity:GetInnerObject()
	else
		return ParaScene.GetObject(Player.RealPlayerName);
	end
end

-- one needs to test if returned paraobject is valid
function Player.GetDriverObject()
	return ParaScene.GetObject(Player.RealPlayerName.."+driver");
end

-- return true if player is mounted. 
function Player.IsMounted()
	local item_marker = ItemManager.GetItemByBagAndPosition(0, 33);
	if(item_marker and item_marker.guid > 0) then
		return true
	end
end
			

-- mount the a character on a target. the target may be a character or mesh with at least one attachment point
-- if there are multiple attachment point, it will mount to the closest one to player. 
-- @param player: the character to mount on target. 
-- @param target: the target object to mount on
-- @param bForcePlayMountAnim: force to play mount animation if player is already mounted on the target
-- if current player is not mounted , it will mount on it. Thus it allows toggling between vehicle and driver. 
function Player.MountPlayerOnChar(player, target, bForcePlayMountAnim)
	if(player==nil or not player:IsCharacter() or target==nil) then return end
	local char = player:ToCharacter();

	-- there is no need to check target:HasAttachmentPoint(0), since asset may be async loaded. 
	if(not char:IsMounted()) then
		-- only mount if target has attachment points and the current player is not attached before.
		-- force the char to face up front.
		player:GetAttributeObject():SetField("HeadTurningAngle", 0);
		char:MountOn(target, 0);
		bForcePlayMountAnim = true;
	end	
	if(bForcePlayMountAnim) then
		local anim_file = Player.GetMountAnimationFile(player, target)
		if(anim_file) then
			Map3DSystem.Animation.PlayAnimationFile(anim_file, player);
		end
	end
end

-- positions that items may have density attached. 
local density_positions = {	72, 18, 19, 70, 71, 33}

-- recompute density according to current player's equipment
function Player.GetNewDensity()
	local density = 0;
	local _, position;
	for _, position in ipairs(density_positions) do
		local item = ItemManager.GetItemByBagAndPosition(0, position);
		if(item) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem and gsItem.template.stats[525]) then
				density = density + gsItem.template.stats[525];
			end
		end
	end
	
	if(Player.asset_gsid) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(Player.asset_gsid);
		if(gsItem and gsItem.template and gsItem.template.stats[525]) then
			density = density + gsItem.template.stats[525];
		end
	end

	if(density>=100) then
		return Player.DiveDensity;
	else
		local world = WorldManager:GetCurrentWorld();
		if(world and world.can_dive) then
			return Player.DiveDensity;
		else
			return Player.NormalDensity;
		end
	end
end

function Player.GetPetID()
    local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        return item.gsid;
	end
end

function Player.IsPetFollow()
    local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        return true;
	end
end

function Player.SendCurrentPetToHome()
    local gsid = Player.GetPetID();
    if(Player.IsPetFollow())then
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
		local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
		CombatFollowPetPane.DoToggleHome(gsid);
	end
end

function Player.RefreshDensity()
	
	Player.set_density_timer = Player.set_density_timer or commonlib.Timer:new({callbackFunc = function(timer)
		Player.GetPlayer():SetDensity(Player.GetNewDensity());
		timer:Change();
	end})

	Player.set_density_timer:Change(1000,nil);
end

-- get gear score. 
function Player.GetGearScore(nid)
	local gs;
	if(not nid or nid == System.App.profiles.ProfileManager.GetNID()) then
		local _,_,_,copies = ItemManager.IfOwnGSItem(965);
		gs = copies or MyCompany.Aries.Combat.GetGearScoreV2();
	else
		local _,_,_,copies =ItemManager.IfOPCOwnGSItem(nid, 965)
		gs = copies or 0;
	end
	--local _,_,_,copies = ItemManager.IfOwnGSItem(965);
	--return math.max(copies or 0, MyCompany.Aries.Combat.GetGearScoreV2());
	return gs;
end

-- get the actual ranking score
function Player.GetRankingScore(stage)
	local rank_pt = Combat.GetMyPvPStats(stage or "1v1", "rating");
	return rank_pt or 1000;
end

-- get gear score on client side. 
-- @param stage: 1v1 or 2v2
function Player.GetVirtualRankingScore(stage)
	local gs_score = Player.GetGearScore();
	local rank_pt = Combat.GetMyPvPStats(stage or "1v1", "rating");
	if(System.options.version == "kids") then
		local score = if_else(rank_pt > 1800, rank_pt, 1800);
		return score;
	end
	if(rank_pt) then
		local floor_score = 1000 + math.floor(gs_score/100)*100;
		if(rank_pt > floor_score) then
			return rank_pt;
		else
			return floor_score;
		end
	else
		-- initial score
		return 1000 + math.floor(gs_score/100)*100;
	end
end