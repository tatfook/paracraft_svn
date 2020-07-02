--[[
Title: 
Author(s): Leio
Date: 2012/02/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClientLogics.lua");
local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");
GathererClientLogics.OnInit();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererCommon.lua");
local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
-- create class
local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");
local sID = "gatherer";
local LOG = LOG;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
GathererClientLogics.template_map = nil;
GathererClientLogics.quest_used_list = nil;
GathererClientLogics.quest_used_map = nil;
GathererClientLogics.borned_map = {};
GathererClientLogics.quest_map = {
	--[questid] = questid,
};
function GathererClientLogics.OnInit()
	local self = GathererClientLogics;
	if(self.is_init)then
		return
	end
	self.is_init = true;
	if(not self.template_map)then
		self.template_map,self.quest_used_list,self.quest_used_map = GathererCommon.LoadTemplate();
	end
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, callback = GathererClientLogics.HookHandler, 
			hookName = "Hook_GathererClientLogics", appName = "Aries", wndName = "main"});
end
function GathererClientLogics.Call_Server()
	local self = GathererClientLogics;
	local world_info = WorldManager:GetCurrentWorld();
	local worldname = world_info.name;
	local msg = {
		worldname = worldname,
	};
	LOG.std("","info","GathererClientLogics.Call_Server", msg);
	self.CallServer("ServerObjects.GathererServer.GetWorldData",msg);
end
--初始化已经诞生的物体
--@param borned_list:{"id_index","id_index","id_index",};
function GathererClientLogics.LoadItemFromServer(borned_list)
	local self = GathererClientLogics;
	self.borned_map = GathererCommon.ListToMap(borned_list);
	self.Refresh();
end
--创建新增的物体
--@param added_list:{"id_index","id_index","id_index",};
function GathererClientLogics.AddItemFromServer(added_list)
	local self = GathererClientLogics;
	if(not added_list)then return end
	local template_map = self.template_map;
	self.borned_map = self.borned_map or {};
	local added_map = GathererCommon.ListToMap(added_list);
	local key,v;
	for key,v in pairs(added_map) do
		local node = template_map[key];
		self.borned_map[key] = true;
		local worldname = node.worldname or "";
		local world_info = WorldManager:GetCurrentWorld();
		if(world_info.name == worldname)then
			self.CreateEntity(node);
		end
	end
end
function GathererClientLogics.Refresh()
	local self = GathererClientLogics;
	local template_map = self.template_map;
	if(not template_map)then return end
	self.borned_map = self.borned_map or {};
	self.UpdateLinkedQuest();
	local key,node;
	for key,node in pairs(template_map) do
		local id = node.id;
		local index = node.index;
		NPC.DeleteNPCCharacter(id,index);
		local worldname = node.worldname or "";
		local world_info = WorldManager:GetCurrentWorld();
		if(world_info.name == worldname and self.borned_map[key])then
			self.CreateEntity(node);
		end
	end
end
function GathererClientLogics.CreateEntity(node)
	local self = GathererClientLogics;
	if(not node)then return end
	local id = node.id;
	local gsid = node.gsid;
	local index = node.index;
	local level = node.level or 0;
	local quality = node.quality or 0;
	local snap = node.snap;

	local key = string.format("%d_%d",id,index);
	local can_flash = false;
	local enabled_native_quest = node.enabled_native_quest;--是否对任务系统有效 默认true
	local enabled_gather = node.enabled_gather;--是否对采集系统有效 默认true
	if(self.borned_map and self.borned_map[key])then
		if(enabled_native_quest and self.quest_about_map and self.quest_about_map[id])then
			can_flash = true;
		end
		if(enabled_gather)then
			can_flash = true;
		end	
	end
	local _params = { 
		name = node.label,
		instance = index,
		position = node.position,
		facing = node.facing,
		scaling = node.scale,
		scale_char = node.scale_char,
		isalwaysshowheadontext = true,
		cursor = "Texture/Aries/Cursor/Pick_teen.tga",
		assetfile_char = "character/v5/09effect/Common/Star02_Shangsheng_Yellow.x",
		assetfile_model = node.assetfile,
		predialog_function = "MyCompany.Aries.ServerObjects.GathererClientLogics.TryPick",
		isdummy = true,
		autofacing = false,
		talkdist = node.talkdist,
	};
	if(not can_flash)then
		_params.isalwaysshowheadontext = false;
		_params.predialog_function = nil;
		_params.assetfile_char = "character/common/dummy/cube_size/cube_size.x";
	end	
	--if(enabled_gather and not enabled_native_quest)then
		--local stamina2 = Player.GetStamina2();
		--local skill_school_gsid = GathererCommon.quality_map[quality];
		----品质
		--if(skill_school_gsid)then
			--local bHas,__,__,copies = hasGSItem(skill_school_gsid);
			--local skill_school_level = copies or 0;
			----技能已经学习 技能等级相符
			--if(skill_school_level < level or stamina2 <= 0)then
				--_params.HeadOnDisplayColor="140 140 140";
				--if(quality == 0)then
					--_params.cursor_text = string.format("%s\r\n(需要采药学%d点)",node.label,level);
				--else
					--_params.cursor_text = string.format("%s\r\n(需要采矿学%d点)",node.label,level);
				--end
			--end
		--end
	--end
	NPC.DeleteNPCCharacter(id,index);
	if(can_flash)then
		NPC.CreateNPCCharacter(id, _params)
		local npcChar, _model = NPC.GetNpcCharModelFromIDAndInstance(id,index);
		if(snap and npcChar and npcChar:IsValid())then
			npcChar:SnapToTerrainSurface(0);
			if(_model and _model:IsValid())then
				local x,y,z = npcChar:GetPosition();
				_model:SetPosition(x,y,z);
			end
		end	
	end
end

-- try pick a item in world
function GathererClientLogics.TryPick(id,index)
	local self = GathererClientLogics;
	if(not id or not index)then return end
	local key = string.format("%d_%d",id,index);
	local node = self.template_map[key];
	if(not node)then return end

	local gsid = node.gsid;
	local level = node.level or 0;
	local quality = node.quality or 0;

	local enabled_native_quest = node.enabled_native_quest;--是否对任务系统有效 默认true
	local enabled_gather = node.enabled_gather;--是否对采集系统有效 默认true

	if(enabled_gather and not enabled_native_quest)then
		local stamina2 = Player.GetStamina2();
		if(stamina2 <= 0)then
			_guihelper.MessageBox("你没有体力值了，不能采集！");
			return;
		end
		--local skill_school_gsid = GathererCommon.quality_map[quality];
		----品质
		--if(skill_school_gsid)then
			--local bHas,__,__,copies = hasGSItem(skill_school_gsid);
			--local skill_school_level = copies or 0;
			--if(skill_school_level == 0)then
				--local s;
				--if(quality == 0)then
					--s = string.format("你还没有学习采药学，不能采集！<br/>（场景中灰色名字的矿物或药材，表示你不能采集。）");
				--else
					--s = string.format("你还没有学习采矿学，不能采集！<br/>（场景中灰色名字的矿物或药材，表示你不能采集。）");
				--end
				--_guihelper.MessageBox(s);
				--return;
			--end
			----技能已经学习 技能等级相符
			--if(skill_school_level < level)then
				--if(quality == 0)then
					--_guihelper.MessageBox(string.format("采药学熟练度不够，需要熟练度%d才能采集，你的熟练度是%d！<br/>（场景中灰色名字的矿物或药材，表示你不能采集。）",level,skill_school_level));
				--else
					--_guihelper.MessageBox(string.format("采矿学熟练度不够，需要熟练度%d级才能采集，你的熟练度是%d！<br/>（场景中灰色名字的矿物或药材，表示你不能采集。）",level,skill_school_level));
				--end
				--return
			--end
		--end
	end
	-- play user avatar animation
	local user_char = ParaScene.GetPlayer();
	if(user_char and user_char:IsValid()) then
		local driver_assetkey = user_char:GetPrimaryAsset():GetKeyName();
		if(driver_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
			System.Animation.PlayAnimationFile("character/Animation/v6/teen_Production_female.x", user_char);
		elseif(driver_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
			System.Animation.PlayAnimationFile("character/Animation/v6/teen_Production_male.x", user_char);
		end
	end
	--start a time line
	GathererBarPage.Start(nil,nil,function()
		-- return to standing pose
		ParaScene.GetPlayer():ToCharacter():PlayAnimation(0);
		-- pick handler
		local msg = {
			id = id,
			index = index,
		}
		self.CallServer("ServerObjects.GathererServer.TryPick_Handle",msg);
	end)
end
-- delete a item 
function GathererClientLogics.DeleteItem_Handle(msg)
	local self = GathererClientLogics;
	if(not msg)then return end
	local id = msg.id
	local index = msg.index;
	local pick_nid = msg.pick_nid;
	local got_pt = msg.got_pt;
	if(id and index)then
		local key = string.format("%d_%d",id,index);
		local node = self.template_map[key];
		if(not node)then return end;
		self.borned_map[key] = nil;
		NPC.DeleteNPCCharacter(id,index);
		self.CreateEntity(node);
		if(pick_nid and pick_nid == Map3DSystem.User.nid)then
			local gsid = node.gsid;
			local enabled_native_quest = node.enabled_native_quest;--是否对任务系统有效 默认true
			local enabled_gather = node.enabled_gather;--是否对采集系统有效 默认true
			local name = "";
			--只对采集系统提示有效
			if(gsid and enabled_gather)then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem)then		
					name = gsItem.template.name;	
				end 
				local label = string.format("获得1个【%s】",name or "");
				if(got_pt)then
					label = string.format("获得1个【%s】,并获得了1点熟练度",name or "");
				end
				BroadcastHelper.PushLabel({
									label = label,
									shadow = true,
									bold = true,
									font_size = 14,
									scaling = 1.2,
									color="255 255 0",
									background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
								});
				local hook_msg = { aries_type = "OnNortifyItems", items = {adds = {{gsid=gsid, cnt=1}} }, wndName = "items"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
				System.App.profiles.ProfileManager.GetUserInfo(nil, "userinfo_update", function()end, "access plus 0 day");
				MyCompany.Aries.Pet.GetRemoteValue(nil, function() end, "access plus 0 day");

			end
			if(gsid)then
				-- TODO: for leio: can we update automatically here?
				ItemManager.GetItemsInBag(12, "", function(msg)
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { action_type = "post_pe_slot_PageRefresh", wndName = "main",});
				end, "access plus 0 minutes");
			end
			if(got_pt)then
				ItemManager.GetItemsInBag(0, "", function(msg)end, "access plus 0 minutes");
			end
		end
	end
	
end

function GathererClientLogics.CallServer(func,msg)
	local self = GathererClientLogics;
	if(not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std("","error","GathererClientLogics", "the type of msg must be table!");
		return
	end
	msg = commonlib.serialize_compact(msg);
	local body = string.format("[Aries][Gatherer][%s][%s]",func,msg);
	
	Map3DSystem.GSL_client:SendRealtimeMessage(sID, {body = body});
end
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { action_type = "gatherer_skill_learned", wndName = "main",});
--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { action_type = "gatherer_skill_lost", wndName = "main",});
function GathererClientLogics.HookHandler(nCode, appName, msg, value)
	local self = GathererClientLogics;
	if(msg.action_type == "gatherer_skill_learned")then
		GathererClientLogics.Refresh();
	elseif(msg.action_type == "gatherer_skill_lost")then
		GathererClientLogics.Refresh();
	end
	return nCode;
end
--quest---------------------------------------------
--任务目标是否在当前世界
function GathererClientLogics.QuestGoalItemHasLinkedCurWorld(questid)
	local self = GathererClientLogics;
	if(not questid)then return end
	local list_all,map_all,list,map = self.GetItemIDs(questid);
	if(map_all)then
		local k,id;
		for k,id in pairs(map_all) do
			local node = self.quest_used_map[id];
			if(node)then
				local worldname = node.worldname or "";
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info.name == worldname)then
					return true;
				end
			end
		end
	end
end
function GathererClientLogics.DetachQuest(questid)
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	local self = GathererClientLogics;
	if(not questid)then return end
	if(self.quest_map[questid])then
		self.quest_map[questid] = nil;
		if(self.QuestGoalItemHasLinkedCurWorld(questid))then
			self.Refresh();
		end
	end
end
--关联任务
function GathererClientLogics.LinkQuest(questid)
	local self = GathererClientLogics;
	self.quest_map[questid] = questid;
end
--激活任务物品
--@param questid:任务id
function GathererClientLogics.AttachQuest(questid)
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	local self = GathererClientLogics;
	if(not questid)then return end
	if(not self.quest_map[questid])then
		self.quest_map[questid] = questid;
		self.UpdateLinkedQuest();

		if(self.QuestGoalItemHasLinkedCurWorld(questid))then
			self.Refresh();
		end
	end
end
--[[返回可以收集的物品id {id1,id2,id3}
	list_all, 忽略进度
	map_all,
	list,
	map
--]]
function GathererClientLogics.GetItemIDs(questid)
	local self = GathererClientLogics;
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
	local template;
	if(templates)then
		template = templates[questid];
	end
	if(not template)then return end
	--只接受收集任务
	local ClientGoalItem = template.ClientGoalItem;
	if(ClientGoalItem)then
		local len = #ClientGoalItem;
		if(len > 0)then
			local my_template = QuestHelp.BuildQuestShowInfo(questid,true);
			if(my_template.ClientGoalItem)then
				local k,v;
				local list_all = {};
				local list = {};
				local map_all = {};
				local map = {};
				for k,v in ipairs(my_template.ClientGoalItem) do
					local id = v.id;
					local value = v.value;
					local max_value = v.max_value;
					if(id and value and max_value)then
						if(value < max_value)then
							table.insert(list,id);
							map[id] = id;
						end
						table.insert(list_all,id);
						map_all[id] = id;
					end
				end
				return list_all,map_all,list,map;
			end
		end
	end
end
--所有任务可以激活的物品
function GathererClientLogics.UpdateLinkedQuest()
	local self = GathererClientLogics;
	--所有任务激活的物品
	local id_map = {};
	local questid,__;
	for questid,__ in pairs(self.quest_map) do
		local list_all,map_all,list,map = self.GetItemIDs(questid);
		if(list)then
			local k,id;
			for k,id in ipairs(list) do
				id_map[id] = id;
			end
		end
	end
	self.quest_about_map = id_map;
end
