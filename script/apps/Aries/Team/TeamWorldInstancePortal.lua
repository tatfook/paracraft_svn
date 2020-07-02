--[[
Title: 
Author(s): Leio
Date: 2011/01/04
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
TeamWorldInstancePortal.Preload("HaqiTown_FireCavern");

NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
TeamWorldInstancePortal.Preload("HaqiTown_LightHouse_S1");

NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
TeamWorldInstancePortal.Preload("FlamingPhoenixIsland_TheGreatTree");

local fromX,fromY,fromZ = ParaScene.GetPlayer():GetPosition();
local radius = 20;
local objlist = {};
if(fromX and fromY and fromZ and radius)then
	commonlib.echo("=======find");
	local nCount = ParaScene.GetObjectsBySphere(objlist, fromX,fromY,fromZ, radius, "anyobject");
	if(nCount > 0)then
		local k = 1;
		for k = 1,nCount do
			local obj = objlist[k];
			if(obj and obj:IsValid())then
				local name = obj.name;
				commonlib.echo("=======name");
				commonlib.echo(name);
			end
		end
	end
end
-------------------------------------------------------
]]
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");

NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
local MapHelp = commonlib.gettable("MyCompany.Aries.Help.MapHelp");

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");


NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");

NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
TeamWorldInstancePortal.cur_world_instance = nil;
TeamWorldInstancePortal.cur_enter_callback = nil;
TeamWorldInstancePortal.cur_delay_msec = nil;
TeamWorldInstancePortal.radius = 20;
TeamWorldInstancePortal.file_maps = {};


function TeamWorldInstancePortal.DestroyItemFromKey(gsid)
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
    -- 17152_CopperKey
    -- 17153_SliverKey
    -- 17154_GoldenKey
    local bHas, guid = hasGSItem(gsid);
    if(bHas) then
	    ItemManager.DestroyItem(guid, 1, function(msg) 
            if(msg.issuccess == true) then
            end
        end, function(msg) end);
    end
end

function TeamWorldInstancePortal.GoTo()
	local self = TeamWorldInstancePortal;
	if(not self.cur_world_instance)then return end
	local list = TeamWorldInstancePortal.GetTeam();

	local isleader = self.IsTeamLeader();
	if(isleader)then
		local delay_msec = TeamWorldInstancePortal.cur_delay_msec;
		if(delay_msec) then
			UIAnimManager.PlayCustomAnimation(delay_msec, function(elapsedTime)
				if(elapsedTime == delay_msec) then
					local params = { name = self.cur_world_instance};
					TeamClientLogics:PrepareTeamWorld(params)
				end
			end);
		else
			local params = { name = self.cur_world_instance};
			TeamClientLogics:PrepareTeamWorld(params)
		end
		if(TeamWorldInstancePortal.cur_enter_callback) then
			TeamWorldInstancePortal.cur_enter_callback();
		end
	else
		local instance_name = self.cur_world_instance;
		NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
		local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
		AutoCameraController:SaveCamera();
		System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
			name = instance_name,
			-- instance = world_name,
			-- uncomment if one wants to use local instance
			-- is_local_instance = true, nid = ProfileManager.GetNID()..tostring(math.random(10000, 99999)), 
			on_finish = function()
				-- hard code the instance key consuming
				if(instance_name == "HaqiTown_LightHouse_S2") then
					TeamWorldInstancePortal.DestroyItemFromKey(17152);
				elseif(instance_name == "HaqiTown_LightHouse_S3") then
					TeamWorldInstancePortal.DestroyItemFromKey(17153);
				elseif(instance_name == "HaqiTown_LightHouse_S4") then
					TeamWorldInstancePortal.DestroyItemFromKey(17154);
				end
				if(TeamWorldInstancePortal.cur_enter_callback) then
					TeamWorldInstancePortal.cur_enter_callback();
				end
				local world = WorldManager:GetWorldInfo(instance_name);
				if(world and world.motion_file)then
					CombatSceneMotionHelper.PlayCombatMotion_LoginWorld(world.motion_file);
				end
			end,
		});
	end

end
-----------------------------------------------------------------------
function TeamWorldInstancePortal.IsInTeam()
	if(TeamClientLogics.GetJC)then
		local isinteam = TeamClientLogics:GetJC():IsInTeam();
		return isinteam;
	end
end
function TeamWorldInstancePortal.IsTeamLeader()
	if(TeamClientLogics.GetJC)then
		local isleader = TeamClientLogics:GetJC():IsTeamLeader();
		return isleader;
	end
end
function TeamWorldInstancePortal.GetTeam()
	if(TeamClientLogics.GetJC)then
		local jc = TeamClientLogics:GetJC();
		if(jc) then
			return jc:GetTeam();
		end
	end
end
-----------------------------------------------------------------------
--function TeamWorldInstancePortal.IsInTeam()
	--return true;
--end
--function TeamWorldInstancePortal.IsTeamLeader()
	--if(Map3DSystem.User.nid == 168511580)then
		--return true;
	--end
--end
--function TeamWorldInstancePortal.GetTeam()
	--local list = commonlib.List:new();
	--list:add({nid  = 168511580})
	--list:add({nid = 171766254})
	--list:add({nid = 171766254})
	--list:add({nid = 171766254})
	--return list;
--end
-----------------------------------------------------------------------
function TeamWorldInstancePortal.GetTeamTable()
	local self = TeamWorldInstancePortal;
	local list = self.GetTeam();
	local result = {};
	if(list)then
		local item = list:first();
		while (item) do
			if(item.nid)then
				local cur_hp = 0;
				local hp = 0;
				if(item.nid == Map3DSystem.User.nid)then
					cur_hp = MsgHandler.GetCurrentHP();
					hp = MsgHandler.GetMaxHP();
				else
					--cur_hp,hp = MsgHandler.GetPlayerCurrentHPOnMyArena(item.nid)
					hp = item.hp or 1000;
					cur_hp = item.cur_hp or hp;
				end
				table.insert(result,{nid  = item.nid, cur_hp = cur_hp, hp = hp,});
			end
			item = list:next(item)
		end
	end		
	return result;
end
function TeamWorldInstancePortal.Preload(key, enter_callback, delay_msec)
	if(not key)then return end
	local self = TeamWorldInstancePortal;
	self.cur_world_instance = key;
	self.cur_enter_callback = enter_callback;
	self.cur_delay_msec = delay_msec;
	if(not self.IsInTeam())then
		local world = WorldManager:GetWorldInfo(key);
		if(world and world.team_mode == "multiple")then
			_guihelper.Custom_MessageBox("这个是多人副本，你需要先加入队伍才能进去哦！",function(result)
				if(result == _guihelper.DialogResult.OK)then
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
		--进副本
		self.GoTo();
	else
		local world = WorldManager:GetWorldInfo(key);
		if(world)then
			if(world.team_mode == "single")then
				_guihelper.Custom_MessageBox("这个是单人副本，你需要先离开队伍才能进去哦！",function(result)
					if(result == _guihelper.DialogResult.OK)then
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			elseif(world.team_mode == "random_pvp")then
				_guihelper.Custom_MessageBox("这个是随机PvP副本，你需要先离开队伍才能进去哦！",function(result)
					if(result == _guihelper.DialogResult.OK)then
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			elseif(world.team_mode == "battlefield")then
				_guihelper.Custom_MessageBox("团队多人副本不能组队进入",function(result)
					if(result == _guihelper.DialogResult.OK)then
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			end
		end
		local isLeader = self.IsTeamLeader();
		if(not isLeader)then
			_guihelper.Custom_MessageBox("很抱歉，有队伍的哈奇需要队长才能带大家进去！现在需要找队长过来或者离开这个队伍才能进入！",function(result)
				if(result == _guihelper.DialogResult.OK)then
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		else
			--进副本
			self.GoTo();
			--local isAllInhere,nids,include_member,world_num = self.IsAllInHere();
			--local not_include_member = {};
			--local k,nid;
			--for k,nid in pairs(nids) do
				--if(not include_member[nid])then
					--not_include_member[nid] = nid;
				--end
			--end
			--if(not isAllInhere)then
				--local k,nid;
				--local str = "";
				--for k,nid in pairs(not_include_member) do
					--s = string.format([[<pe:name nid='%d' linked="false" />]],nid);
					--if(str == "")then
						--str = s;
					--else
						--str = str ..","..s; 
					--end
				--end
				--str = string.format("你的队伍里%s没有到达开启区域，快跟他们取得联系后再来开启吧。",str);
				--_guihelper.Custom_MessageBox(str,function(result)
					--if(result == _guihelper.DialogResult.OK)then
					--end
				--end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
--
				----_guihelper.Custom_MessageBox("你的队员还没来齐，系统已经对他们发出了召集令，人齐了才能一起进去！",function(result)
				----if(result == _guihelper.DialogResult.Yes)then
					----local members = self.GetTeam();
					----if(members)then
					----local item = members:first();
						----while (item) do
							----local nid = item.nid;
							------发送传送邀请
							----if(nid and nid ~= Map3DSystem.User.nid)then
								----Map3DSystem.App.profiles.ProfileManager.GetJID(nid, function(jid)
									----if(jid)then
										----MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
											----msg_type = "team_invite_comehere",
											----nid = Map3DSystem.User.nid,
											----world_num = world_num,
											----world_key = key,
										----},jid);
									----end
								----end)
							----end
							----item = members:next(item);
						----end
					----end
				----else
					----
				----end
				----end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/InviteToComeHere_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			--else
				----进副本
				--self.GoTo();
			--end
		end
	end
end
--队员是否都在副本附近，包括队长
function TeamWorldInstancePortal.IsAllInHere()
	local self = TeamWorldInstancePortal;
	local members = self.GetTeam();
	local all_member = {};
	local include_member = {};
	local World;
	if(members)then
		local item = members:first();
		local size = members:size();
		local map = {};
		local cnt = 0;

		while (item) do
			local nid = item.nid;
			map[nid] = false;
			all_member[nid] = nid;
			local objlist = {};
			local radius = self.radius;
			local fromX,fromY,fromZ,_World = self.GetWorldInstancePos();
			World = _World;
			if(fromX and fromY and fromZ and radius)then
				local nCount = ParaScene.GetObjectsBySphere(objlist, fromX,fromY,fromZ, radius, "anyobject");
				if(nCount > 0)then
					local k = 1;
					for k = 1,nCount do
						local obj = objlist[k];
						if(obj and obj:IsValid())then
							local name = obj.name;
							name = tonumber(name);
							if(name and nid == name)then
								--在范围之内
								cnt = cnt + 1
								include_member[nid] = nid;
							end
						end
					end
				end
			end
			item = members:next(item)
		end
		if(cnt == size and cnt > 0)then
			return true,all_member,include_member;
		end
	end
	return false,all_member,include_member,World;
end
--[[
根据
alienbrain://PARA2/KidsMovie:595/ParaEngineSDK/config/Aries/Quests/worlds_list.xml
<worldinstance_map_file>config/Aries/MapGuides/FindWorldInstance.xml</worldinstance_map_file> 
获取副本推荐坐标
一个世界中存在多个副本

2010/1/26: return the player position if the player is team leader and trying to enter a random generated instance entry
--]]
function TeamWorldInstancePortal.GetWorldInstancePos()
	local self = TeamWorldInstancePortal;
	local result,result_map_id,result_map_desc = QuestHelp.GetWorldList();
	--当前世界路径
	local cur_world_path = ParaWorld.GetWorldDirectory();
	if(result_map_desc)then
		cur_world_path = string.lower(cur_world_path);
		local world_node = result_map_desc[cur_world_path];
		if(world_node)then
			local file = tostring(world_node.worldinstance_map_file);
			if(file)then
				if(not self.file_maps[file])then
					local __,maps = MapHelp.ParseXMLFile(file);
					self.file_maps[file] = maps;
				end
				local maps = self.file_maps[file];
				if(maps)then
					local cur_world_instance = string.lower(self.cur_world_instance);
					local item = maps[cur_world_instance];
					
					if(item)then
						local Position = item.Position;
						local World = item.World;
						if(Position == "player") then
							local x, y, z = ParaScene.GetPlayer():GetPosition();
							return x, y, z, World;
						elseif(Position) then
							return Position[1],Position[2],Position[3],World;
						end
					end
				end
			end
		end
	end
end