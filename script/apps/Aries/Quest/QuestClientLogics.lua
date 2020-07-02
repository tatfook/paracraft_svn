--[[
Title: Client side logics for quest service
Author(s): Leio
Date: 2010/8/24
Desc: 
use the lib:
------------------------------------------------------------
任务对话里面显示玩家的名字：#name#
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
QuestClientLogics.provider:Debug();

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
QuestClientLogics.SaveToDgml("HaqiQuestTools/quest_template_parsed.dgml");

NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");
QuestListPage.ShowPage();

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local nid = System.User.nid;
local path = string.format("HaqiQuestTools/%d_quest.dgml",nid);
QuestClientLogics.OutPutDgml(path);

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local r = QuestClientLogics.LoadConfig_QuestTypes("config/Aries/Quests/quest_types.xml");
commonlib.echo(r);

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
QuestClientLogics.UpdateNpcShowState()

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
QuestClientLogics.Call_DoUserDisconnect()

System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {name="FlamingPhoenixIsland"});

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local b = QuestClientLogics.CanDoAction("state",0,0);
if(b)then
	_guihelper.MessageBox("aaaa");
end
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local msg = {nid = System.User.nid,id = 60005};
QuestClientLogics.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryAccept_Handler",msg)

QuestClientLogics.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryFinished_Handler",msg)

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
QuestClientLogics.CallServer("MyCompany.Aries.Quest.QuestServerLogics.CheckDate_FollowPet",{pet_gsid = 10154,})
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClientLogics.lua");
local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");

NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Quest/QuestHook.lua");
local QuestHook = commonlib.gettable("MyCompany.Aries.Quest.QuestHook");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

NPL.load("(gl)script/apps/Aries/Quest/HaqiQuestHooks.lua");
local HaqiQuestHooks = commonlib.gettable("MyCompany.Aries.Quest.HaqiQuestHooks");	

NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");

local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");

NPL.load("(gl)script/apps/Aries/Quest/QuestDialogPage.lua");
local QuestDialogPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDialogPage");
NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
-- create class
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/ide/TooltipHelper.lua");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local sID = "quest10000";
local LOG = LOG;

local hasGSItem = ItemManager.IfOwnGSItem;
QuestClientLogics.provider = nil;
QuestClientLogics.npc_state_map = {};
QuestClientLogics.quest_action_map = {};
--call this function on each world login
function QuestClientLogics.Reset()
	LOG.std("", "info","QuestClientLogics.Reset()");
	local self = QuestClientLogics;
	if(self.provider)then
		self.provider.local_is_init = false;
		self.npc_state_map = {};
	end
end
function QuestClientLogics.SaveToDgml(path)
	local self = QuestClientLogics;
	if(self.provider)then
		local graph = self.provider.template_graph;
		QuestHelp.SaveToDgml(graph,path);
	end
end
function QuestClientLogics.Test_Kill(mode)
	local self = QuestClientLogics;
	local msg = {
		mode = mode,
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.Test_Handler",msg)
end
--从客户端发起的增加数据
--[[
	local increment = {
		{ id = 0, value = 0,},
		{ id = 1, value = 0,},
	}
]]
function QuestClientLogics.DoAddValue_FromClient(increment)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.DoAddValue_FromClient",increment);
	if(not increment)then return end
	local provider = self.provider;
	if(provider)then
		local result = {};
		local k,v;
		for k,v in ipairs(increment) do
			if(provider:IsIncludeGoal_AllAccepted(v.id))then
				table.insert(result,v);
			else
				LOG.std("", "warning","QuestClientLogics.DoAddValue_FromClient this goal is not't allowed",v);
			end
		end
		if(#result == 0)then
			return
		end
		local msg = {
			nid = System.User.nid,
			increment = increment,
		}
		self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoAddValue_FromClient",msg)
	end
end
--同步client 捡取物品的数据，并且同步server
function QuestClientLogics.DoSync_Client_ClientGoalItem()
	local self = QuestClientLogics;
	local provider = self.provider;
	--青年版忽略
	if(CommonClientService.IsTeenVersion())then
		return
	end
	if(provider)then
		local sync_quest_item_map,bHas = provider:DoSync_Client_ClientGoalItem();
		--提醒任务可以交付
		local templates = provider:GetTemplateQuests();
		local id,q_item;
		for id,q_item in pairs(sync_quest_item_map) do
			local can_finished = provider:CanFinished(id);
			if(can_finished)then
				local template;
				if(templates and templates[id])then
					template = templates[id];
					local label = string.format("任务【%s】可交付",template.Title or "");
					BroadcastHelper.PushLabel({
										label = label,
										shadow = true,
										bold = true,
										font_size = 14,
										scaling = 1.2,
										color="255 255 0",
										background = "Texture/Aries/Common/gradient_white_32bits.png",
										background_color = "#1f3243",
									});
				end
			end
		end
		LOG.std("", "info","QuestServerLogics.DoSync_Client_ClientGoalItem",sync_quest_item_map);
		if(sync_quest_item_map and bHas)then
			local msg = {
				nid = System.User.nid,
				sync_quest_item_map = sync_quest_item_map,
			}
			self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoSync_Server_ClientGoalItem",msg)
			self.UpdateUI(true);
		end
	end
end
function QuestClientLogics.HasInit()
	local self = QuestClientLogics;
	local provider = self.provider;
	if(provider)then
		return provider.local_is_init
	end
end

-- @param on_init_callback: callback function(bSucceed) end
function QuestClientLogics.CallInit(on_init_callback)
	local self = QuestClientLogics;
	if(self.HasInit())then
		--return
	end
	self.on_init_callback = on_init_callback;

	local msg = {
		nid = System.User.nid
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.CallInit_Handler",msg)

	NPL.load("(gl)script/apps/Aries/Friends/BestFriendList.lua");
	local BestFriendListPage = commonlib.gettable("MyCompany.Aries.Friends.BestFriendListPage");
	BestFriendListPage.LoadData();

	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClientLogics.lua");
	local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");
	GathererClientLogics.Call_Server();

	NPL.load("(gl)script/apps/Aries/Scene/EventTriggerManager.lua");
	local EventTriggerManager = commonlib.gettable("MyCompany.Aries.EventTriggerManager");
	EventTriggerManager:SwitchWorld();
	
	ItemManager.GetItemsInBag(1002, "HomelandPetShowState", function(msg)
	end)


end

function QuestClientLogics.SetHook()
	local self = QuestClientLogics;
	local hook = CommonCtrl.os.hook.SetWindowsHook({hookType=CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = self.HookHandler, 
		hookName = "QuestClientLogics_Hook", appName="Aries", wndName = "quest"});
end
function QuestClientLogics.HookHandler(nCode, appName, msg)
	local self = QuestClientLogics;
	--加经验
	if(msg.aries_type == "QuestClientLogics_SetCombatExp")then
		if(self.provider)then
			local level = msg.combat_level;
			LOG.std("", "info","QuestClientLogics.HookHandler combat_level",level);
			if(level) then
				self.provider:SetLocalCombatLevel(level);
				if(self.last_level ~= level)then
					--升级
					self.provider:NotifyChanged(); -- added by LXZ 2012.10.12
					self.last_level = level;
					QuestTrackerPane.NeedReload();
					--刷新npc接任务状态
					self.UpdateUI(true);
				end
			end
		end
	end
	return nCode;
end
function QuestClientLogics.OnInit()
	local self = QuestClientLogics;
	QuestHelp.GetTemplates();
	if(not self.provider)then
		local load_version;
		if(QuestHelp.IsKidsVersion())then
			load_version = "kids";
		else
			load_version = "teen";
		end
		self.provider = QuestProvider:new{
			nid = System.User.nid,
			load_version = load_version,
		};
		self.provider:OnInit();

		QuestHelp.LoadAllXmlFiles(load_version);
	end
	--hook
	self.SetHook();
	-- install special hooks. 
	HaqiQuestHooks.InstallHooks();
	QuestHook.SetHook();
end
function QuestClientLogics.HasBounced()
	local self = QuestClientLogics;
	return self.has_bounced;
end

function QuestClientLogics.DoInitRemoteQuest_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.DoInitRemoteQuest_Handler",msg);
	if(not msg or type(msg) ~= "table")then
		return
	end	
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
	local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
	DockTip.GetInstance():ChangeWorld();
	self.OnInit()

	if(msg.issuccess)then
		--if(not self.provider.local_is_init)then
			self.provider.local_is_init = true;
			self.provider.quests_list = msg.quests_list or {};
			--当然有效的日常任务 nil无限制
			self.provider.weekly_valid_maps = msg.weekly_valid_maps;
			self.provider:ResetQuestMap();
			self.provider:NotifyChanged();
			--激活可以收集的物品
			local need_refresh;
			local k,v;
			for k,v in ipairs(msg.quests_list) do
				local id = v.id;
				local has_accept = self.provider:HasAccept(id);
				local can_finished = self.provider:CanFinished(id);
				if(has_accept and not can_finished)then
					local is_ClientGoalItem = QuestHelp.IsQuest_ClientGoalItem(id);
					if(is_ClientGoalItem)then
						need_refresh = true;
						GathererClientLogics.LinkQuest(id)
					end
				end
			end
			if(need_refresh)then
				GathererClientLogics.Refresh();
			end
			self.UpdateUI(true);
			-- call init hook
			QuestHook.Invoke("quest_oninit", -1);

			if(self.on_init_callback) then
				self.on_init_callback(msg.issuccess);
			end
		--end
	else
		_guihelper.MessageBox("任务初始化失败！");
		self.UpdateUI();
		if(self.on_init_callback) then
			self.on_init_callback(msg.issuccess);
		end
	end
	
end
function QuestClientLogics.DoReset_Handler(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then
		return
	end
	self.provider:OnInit();	
	QuestTrackerPane.Tracked_Clear();
	QuestTrackerPane.NeedReload();
	self.UpdateUI();
	_guihelper.MessageBox("重置成功！");
end

function QuestClientLogics.UpdateUI(bCheckBounce,state)
	local self = QuestClientLogics;
	self.UpdateNpcShowState();
	if(bCheckBounce)then
		if(not state)then
			self.DoBounce();
		elseif(state == "check_can_finished")then
			if(self.has_can_finished)then
				self.DoBounce();
			end
		end
	end
	QuestTrackerPane.ReloadPage();
end
--TODO:区分世界
function QuestClientLogics.UpdateNpcShowState()
	local self = QuestClientLogics;
	local npc_list, npc_map = QuestHelp.GetNpcList();
	if(npc_list and self.HasInit())then
		self.has_progressing = false;
		self.has_can_accept = false;
		self.has_can_finished = false;
		local activedCnt = 0;
		local temp_has_insert = {};
		local dialoged_npc_in_progressing = {};
		local has_npc_headon = {};
		local function push_npcid(type,list)
			if(not list)then return end
			for kk,vv in ipairs(list) do
				local quest_npc_id = tonumber(vv.id);
				if(type == "Cur_ClientExchangeItem")then
					quest_npc_id = 30345;
				end
				local value = tonumber(vv.value) or 0;
				local max_value = tonumber(vv.max_value) or 0;
				if(quest_npc_id and value < max_value and not dialoged_npc_in_progressing[quest_npc_id])then
					dialoged_npc_in_progressing[quest_npc_id] = quest_npc_id
				end
			end
		end

		local npc_state_map = self.npc_state_map;
		local function UpdateNPCHeadon(npcid, sTemplateName)
			local last_state = npc_state_map[npcid];
			if(last_state ~= sTemplateName)then
				npc_state_map[npcid] = sTemplateName;
				NPC.ChangeHeadonMarkByID(npcid,nil,sTemplateName);
			end
			if(sTemplateName) then
				has_npc_headon[npcid] = true;
			end
		end
		local function callbackCanFinished(npc_id, quest_id, EndDialog)
			UpdateNPCHeadon(npc_id, "can_finished");
			self.has_can_finished = true;
		end
		local function callbackCanAccept(npc_id, quest_id, StartDialog)
			UpdateNPCHeadon(npc_id, "can_accept");
			self.has_can_accept = true;
		end
		local function callbackInProgress(npc_id, quest_id, state)
			UpdateNPCHeadon(npc_id, "accepted");
			self.has_progressing = true;
			if(not temp_has_insert[quest_id])then
				temp_has_insert[quest_id] = true
				activedCnt = activedCnt + 1;
			end
			local q_item = self.provider:GetQuest(quest_id);
			if(q_item)then
				push_npcid("Cur_ClientExchangeItem",q_item.Cur_ClientExchangeItem);
				--TODO:flash game npcid need bind flash_game_list.xml
				--push_npcid(nil,q_item.Cur_FlashGame);
				push_npcid(nil,q_item.Cur_ClientDialogNPC);
			end
		end
		-- Xizhi: in the past, it takes 4-10 seconds on android phone 2015.3.30
		-- the following optimized version takes just: 0.2-0.4 seconds
		self.provider:FindQuestsByNPCMap(npc_map, callbackCanFinished, callbackCanAccept, callbackInProgress);
		
		--对话类型任务中 显示需要对话的NPC
		for k,id in pairs(dialoged_npc_in_progressing) do
			UpdateNPCHeadon(id, "can_dialoged");
		end
		-- make the remaining empty
		for npcid, _ in pairs(npc_map) do
			if(not has_npc_headon[npcid]) then
				UpdateNPCHeadon(npcid, nil);
			end
		end
		-- takes 0.1 seconds on android phone 2015.3.30
		QuestArea.Refresh_QuestCnt(activedCnt)
	end
end
function QuestClientLogics.CanBounce()
	local self = QuestClientLogics;
	if(self.has_can_accept or self.has_can_finished)then
		return true;
	end
end
function QuestClientLogics.DoBounce()
	local self = QuestClientLogics;
	if(self.CanBounce())then
		if(not self.has_bounced)then
			self.has_bounced = true;
			QuestArea.Bounce_Static_Icon("QuestList","bounce")

			if(not self.bounce_timer)then
				self.bounce_timer = commonlib.Timer:new();
			end
			self.bounce_timer.callbackFunc = function(timer)
				QuestArea.Bounce_Static_Icon("QuestList","stop")
			end
			self.bounce_timer:Change(10000, nil)
		end
	end
end
function QuestClientLogics.HasDropped(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	return self.provider:HasDropped(msg.id);
end
function QuestClientLogics.HasAccept(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	return self.provider:HasAccept(msg.id);
end
function QuestClientLogics.HasFinished(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	return self.provider:HasFinished(msg.id);
end
function QuestClientLogics.CanAccept(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	return self.provider:CanAccept(msg.id);
end
function QuestClientLogics.CanFinished(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	return self.provider:CanFinished(msg.id);
end
function QuestClientLogics.CanDelete(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	return self.provider:CanDelete(msg.id);
end
function QuestClientLogics.DoReset(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoReset_Handler",msg)
end


function QuestClientLogics.TryAccept(msg, callbackFunc)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	local bCanDoAction = self.CanDoAction("TryAccept",msg.nid,msg.id);
	if(not bCanDoAction)then
		LOG.std("", "info","QuestClientLogics.TryAccept so fast",msg);
		return
	end
	
	---------------------
	QuestClientLogics.accept_callbackFunc = {callbackFunc = callbackFunc, quest_id=msg.id};
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryAccept_Handler",msg)

	--60289任务弹出 撮合面板
	if(msg.id and msg.id == 60289)then
		QuestHelp.ShowHelp_60289();
	end
end
function QuestClientLogics.TryAccept_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.TryAccept_Handler",msg);
	if(not msg or type(msg) ~= "table")then return end
	if(msg.issuccess and msg.item)then
		local item = msg.item;
		local id = msg.id;
		self.provider:AddQuest(item);
		self.provider:NotifyChanged();
		self.ShowInfo(id,"doaccepted");
		self.DoSync_Client_ClientGoalItem();

		
		local questid = id;
		local templates = self.provider:GetTemplateQuests();
		local template = templates[questid];					
		if(template and template.RequestQuest)then
			local RequestQuest = template.RequestQuest;
			local k,v;
			for k,v in ipairs(RequestQuest) do
				--如果前置任务已经完成，自动追踪此任务
				if(self.provider:HasFinished(v.id))then
					local goalid = QuestHelp.GetFirstGoalID(questid);
					local item_info = QuestHelp.GetItemInfoByID(goalid);

					if(item_info and item_info.x and item_info.y and item_info.z)then
						QuestTrackerPane.FindPath_Active(questid,goalid)
					else
						QuestTrackerPane.FindPath_TopGoal_ByIndex();
					end
					break;
				end
			end

			local goalid = QuestHelp.GetFirstGoalID(questid);
			if(goalid) then
				-- automatically track the goal once accepted. 
				QuestTrackerPane.TrackCurrentGoal(goalid);
			end
		end

		QuestTrackerPane.NeedReload();
		self.UpdateUI();
		---------------------play a effect after finished a quest
		NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
		local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
		local spell_file;
		if(CommonClientService.IsTeenVersion())then
			spell_file = "config/Aries/Spells/Action_QuestAcquire_teen.xml";
		else
			spell_file = "config/Aries/Spells/Action_QuestAcquire.xml";
		end
		local current_playing_id = ParaGlobal.GenerateUniqueID();
		SpellCast.EntitySpellCast(0, ParaScene.GetPlayer(), 1, ParaScene.GetPlayer(), 1, spell_file, nil, nil, nil, nil, nil, function()
		end, nil, true, current_playing_id, true);

		if(System.options.version=="kids") then
			-- 第一个任务，提示使用传送门
			if (tonumber(id)>=60001 and tonumber(id)<=60005) then
				NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
				local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
				AutoTips.FirstQuestTeleDoor();
			end
		end
		QuestHook.Invoke("quest_accept", id);
		paraworld.PostLog({action = "quest_accepted_successful", id = id}, 
							"quest_accepted_successful_log", function(msg)
						end);
		-- try to invoke hook
		HaqiQuestHooks.Invoke("OnQuestAccepted", id);

		GathererClientLogics.AttachQuest(id,true);

		NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		AutoTips.ShowPage("quest_"..id);

		NPL.load("(gl)script/apps/Aries/Quest/QuestLinksViewPage.lua");
		local QuestLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestLinksViewPage");
		if(QuestLinksViewPage.HasInclude_QuestIds(id))then
			NPL.load("(gl)script/apps/Aries/Quest/QuestLinksViewPage.lua");
			local QuestLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestLinksViewPage");
			QuestLinksViewPage.ShowPage(id);
		end
		if(QuestClientLogics.accept_callbackFunc and QuestClientLogics.accept_callbackFunc.quest_id == questid) then
			if(QuestClientLogics.accept_callbackFunc.callbackFunc) then
				QuestClientLogics.accept_callbackFunc.callbackFunc(msg);
			end
		end
	else
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>怪物阻挠通信，任务接受失败！重新登陆就可以了，该死的怪物！</div>");
	end
	
end
function QuestClientLogics.TryFinished(msg, callbackFunc)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;

	local loot_scale = 1;
	--青年版有效
	if(CommonClientService.IsTeenVersion())then
		loot_scale = AntiIndulgenceArea.GetLootScale();
		if(loot_scale <= 0)then
			_guihelper.MessageBox("你已进入防沉迷时间，因此不能交付任务。");
			return;
		end
	end
	LOG.std("", "info","QuestClientLogics.TryFinished loot_scale",loot_scale);
	QuestClientLogics.finish_callbackFunc = {callbackFunc = callbackFunc, quest_id=msg.id};
	
	local bCanDoAction = self.CanDoAction("TryFinished",msg.nid,msg.id);
	if(not bCanDoAction)then
		LOG.std("", "info","QuestClientLogics.TryFinished so fast",msg);
		return
	end
	
	---------------------
	--防沉迷 奖励惩罚0-1
	msg.loot_scale = loot_scale;
	--当前跟随宠物
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
	if(item)then
		msg.pet_guid= item.guid;
		msg.pet_gsid= item.pet_gsid;
	end
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryFinished_Handler",msg)
end
function QuestClientLogics.DestroyItem_ClientItem(id)
	local self = QuestClientLogics;
	if(not id)then return end
	--青年版收集任务 都是虚拟物品
	if(CommonClientService.IsTeenVersion())then
		return
	end
	local templates = self.provider:GetTemplateQuests();
	local template = templates[id];
	if(template)then
		local ClientGoalItem = template.ClientGoalItem;
		if(ClientGoalItem)then
			local k,v;
			for k,v in ipairs(ClientGoalItem) do
				local gsid = v.id;
				local value = v.value;
				if(gsid and value and value > 0)then
					local bHas,guid,__,copies = ItemManager.IfOwnGSItem(gsid);
					if(bHas)then
						value = math.min(value,copies);
						ItemManager.DestroyItem(guid,value);
					end
				end
			end
		end
	end
end
function QuestClientLogics.TryFinished_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.TryFinished_Handler",msg);
	if(not msg or type(msg) ~= "table")then return end
	if(msg.issuccess and msg.id)then
		local id = msg.id;
		local pet_exp = msg.pet_exp;
		local reward_list = msg.reward_list;
		local templates = self.provider:GetTemplateQuests();
		local template = templates[id];
		if(template)then
			local q_item = self.provider:GetQuest(id);
			if(q_item)then
				--准备删除可以收集的物品
				GathererClientLogics.DetachQuest(id)
				local QuestRepeat = tonumber(template.QuestRepeat) or 0;
				if(QuestRepeat == 0)then
					q_item.QuestState = 1;
				else
					--可以重复接
					self.provider:RemoveQuest(id);
				end	
				self.CheckIsAutoActive(id);
				self.ShowInfo(id,"dofinished");
				--如果是收集物品 销毁任务要求的数量
				self.DestroyItem_ClientItem(id);
				self.provider:NotifyChanged();
				QuestTrackerPane.NeedReload();
				self.UpdateUI(true);
				QuestHook.Invoke("quest_finish", id);
				-- try to invoke hook
				HaqiQuestHooks.Invoke("OnQuestFinished", id);

				paraworld.PostLog({action = "quest_finished_successful", id = id}, 
								"quest_finished_successful_log", function(msg)
							end);
				
				local questid = id;
				local loot_scale = 1;
				--青年版有效
				if(CommonClientService.IsTeenVersion())then
					loot_scale = AntiIndulgenceArea.GetLootScale();
				end
				if(reward_list)then
					local notification_msg = {};
					notification_msg.adds = {};
					notification_msg.updates = {};
					notification_msg.stats = {};
					local k,v;
					for k,v in ipairs(reward_list) do
						local id = tonumber(v.id);
						local value = tonumber(v.value);
						if(id == 113)then
							--发送经验奖励的log
							local exp = value * loot_scale;
							paraworld.PostLog({action = "user_gain_exp", exp_pt = exp, questid = questid, reason = "rewardByQuest"},
									"user_gain_exp_log",function(msg)
								end);
							table.insert(notification_msg.stats, {gsid = -13, cnt = exp});
							if(pet_exp and pet_exp > 0)then
								if(CommonClientService.IsTeenVersion())then
									table.insert(notification_msg.adds, {gsid = 966, cnt = pet_exp});
								else
									table.insert(notification_msg.stats, {gsid = -113, cnt = pet_exp});
								end
							end
						else
							--在任务奖励里面 奇豆编号为100,实际是0
							if(id == 100)then
								table.insert(notification_msg.stats, {gsid = 0, cnt = value * loot_scale});
							elseif(id >= 1001) then
								--最低1个
								if(value > 1 and loot_scale < 1)then
									value = value * loot_scale;
									value = math.ceil(value);
									value = math.max(value,1);
								end
								table.insert(notification_msg.adds, {gsid = id, cnt = value});
							elseif(id == 977 or id == 998 or id == 984) then
								table.insert(notification_msg.adds, {gsid = id, cnt = value * loot_scale});
							else
								if(id ~= 103 or id ~= 104 or id ~= 105 or id ~= 106 or id ~= 107)then
									table.insert(notification_msg.adds, {gsid = id, cnt = value* loot_scale});
								end
							end
						end
					end
					--客户端奖励提醒
					Dock.OnExtendedCostNotification(notification_msg);
					local k,v;
					for k,v in ipairs(notification_msg.adds) do
						-- call hook for OnObtainItem
						local hook_msg = { aries_type = "OnObtainItem", gsid = v.gsid, count = v.cnt, wndName = "items"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
					end
				end
				NPL.load("(gl)script/apps/Aries/Quest/QuestWeeklyLinksViewPage.lua");
				local QuestWeeklyLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestWeeklyLinksViewPage");
				if(QuestWeeklyLinksViewPage.HasInclude_QuestIds(questid))then
					QuestWeeklyLinksViewPage.LoadPage();
				end
				---------------------play a effect after finished a quest
				NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
				local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
				local spell_file;
				if(CommonClientService.IsTeenVersion())then
					spell_file = "config/Aries/Spells/Action_QuestFinish_teen.xml";
				else
					spell_file = "config/Aries/Spells/Action_QuestFinish.xml";
				end
				local current_playing_id = ParaGlobal.GenerateUniqueID();
				SpellCast.EntitySpellCast(0, ParaScene.GetPlayer(), 1, ParaScene.GetPlayer(), 1, spell_file, nil, nil, nil, nil, nil, function()
				end, nil, true, current_playing_id, true);

				if(QuestClientLogics.finish_callbackFunc and QuestClientLogics.finish_callbackFunc.quest_id == msg.id) then
					if(QuestClientLogics.finish_callbackFunc.callbackFunc) then
						QuestClientLogics.finish_callbackFunc.callbackFunc(msg);
					end
				end
			else
				_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>天呐，怪物利用空间漏洞，毁掉了这个任务！！！这个任务只能放弃后重新领取了！或者关掉游戏重新登录！</div>");
			end
		else
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>天呐，怪物利用空间漏洞，毁掉了这个任务！！！这个任务只能放弃后重新领取了！或者关掉游戏重新登录！</div>");
		end
		
	else
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>天呐，怪物利用空间漏洞，毁掉了这个任务！！！这个任务只能放弃后重新领取了！或者关掉游戏重新登录！</div>");
	end
end
function QuestClientLogics.CheckIsAutoActive(id)
	local self = QuestClientLogics;
	if(not id)then return end
	local graph = self.provider.template_graph;
	local gnodes_map = self.provider.template_graph_nodes_map;
	if(graph and gnodes_map)then
		local gnode = gnodes_map[id];
		local templates = self.provider:GetTemplateQuests();
		local template = templates[id];
		if(gnode)then
			local arc;
			for arc in gnode:NextArc() do
				local node = arc:GetNode();
				local arc_tag = arc:GetTag();--弧的额外信息
				local is_mirror;
				if(arc_tag)then
					is_mirror = arc_tag.is_mirror;
				end
				if(node)then
					local data = node:GetData();
					if(data and data.templateData)then
						local templateData = data.templateData;
						local id = templateData.Id;
						local b = templateData.AutoShowStartDialog;
						local start_npc_id = templateData.StartNPC;
						NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
						local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
						--直接刷新面板
						if(WorldTeamQuest.HasInclude(id))then
							WorldTeamQuest.ReSelected();
							return
						end
						if(b and b == 1 and is_mirror and start_npc_id)then
							--直接显示下一个任务的对话
							QuestDialogPage.BeforeShowPage(start_npc_id, nil, templateData)
							QuestDialogPage.ShowPage(true);
							return;
						end
					end
				end
			end
		end
	end
end
function QuestClientLogics.TryDelete(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;
	local bCanDoAction = self.CanDoAction("TryDelete",msg.nid,msg.id);
	if(not bCanDoAction)then
		LOG.std("", "info","QuestClientLogics.TryDelete so fast",msg);
		return
	end

	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryDelete_Handler",msg)
end
function QuestClientLogics.TryDelete_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.TryDelete_Handler",msg);
	if(not msg or type(msg) ~= "table")then return end
	if(msg.issuccess and msg.id)then
		local id = msg.id;
		--准备删除可以收集的物品
		GathererClientLogics.DetachQuest(id)
		self.provider:RemoveQuest(id);
		self.provider:NotifyChanged();

		self.ShowInfo(id,"dodelete");
		QuestTrackerPane.NeedReload();
		self.UpdateUI();
	else
		_guihelper.MessageBox("TryDelete_Handler失败");
	end
end
function QuestClientLogics.TryDrop(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;

	local bCanDoAction = self.CanDoAction("TryDrop",msg.nid,msg.id);
	if(not bCanDoAction)then
		LOG.std("", "info","QuestClientLogics.TryDrop so fast",msg);
		return
	end

	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryDrop_Handler",msg)
end
function QuestClientLogics.TryDrop_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.TryDrop_Handler",msg);
	if(not msg or type(msg) ~= "table")then return end
	if(msg.issuccess and msg.id)then
		local id = msg.id;
		local q_item = self.provider:GetQuest(id);
		if(q_item)then
			q_item.QuestState = 5;
			self.provider:NotifyChanged();

			self.ShowInfo(id,"dodrop");

			QuestTrackerPane.NeedReload();
			self.UpdateUI();
			paraworld.PostLog({action = "quest_declined_successful", id = id}, 
								"quest_declined_successful_log", function(msg)
							end);
		else
			_guihelper.MessageBox("TryDrop_Handler失败");
		end
		
	else
		_guihelper.MessageBox("TryDrop_Handler失败");
	end
end
function QuestClientLogics.TryReAccept(msg)
	local self = QuestClientLogics;
	if(not msg or type(msg) ~= "table")then return end
	msg.nid = msg.nid or System.User.nid;

	local bCanDoAction = self.CanDoAction("TryReAccept",msg.nid,msg.id);
	if(not bCanDoAction)then
		LOG.std("", "info","QuestClientLogics.TryReAccept so fast",msg);
		return
	end
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.TryReAccept_Handler",msg)
end
function QuestClientLogics.TryReAccept_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.TryReAccept_Handler",msg);
	if(not msg or type(msg) ~= "table")then return end
	if(msg.issuccess and msg.id)then
		local id = msg.id;
		self.provider:RemoveQuest(id);
		self.provider:NotifyChanged();

		QuestTrackerPane.NeedReload();
		self.UpdateUI();

		self.ShowInfo(id,"doreaccept");


		paraworld.PostLog({action = "quest_reaccepted_successful", id = id}, 
								"quest_reaccepted_successful_log", function(msg)
							end);
	else
		_guihelper.MessageBox("TryReAccept_Handler失败");
	end
end
function QuestClientLogics.DoAddValue_Handler(msg)
	local self = QuestClientLogics;
	LOG.std("", "info","QuestClientLogics.DoAddValue_Handler",msg);
	if(not msg or type(msg) ~= "table")then return end
	local added_quest_map = msg.added_quest_map;
	if(added_quest_map)then
		local old_quest_map = self.provider:ResetQuestByMap(added_quest_map);
		self.provider:NotifyChanged();
		QuestTrackerPane.NeedReload();
		self.UpdateUI(true,"check_can_finished");
		self.ShowInfo_Killed(added_quest_map,old_quest_map);
		--提醒任务可以交付
		local templates = self.provider:GetTemplateQuests();
		local id,q_item;
		for id,q_item in pairs(added_quest_map) do
			local can_finished = self.provider:CanFinished(id);
			if(can_finished)then
				local template;
				if(templates and templates[id])then
					template = templates[id];
					local label = string.format("任务【%s】可交付",template.Title or "");
					BroadcastHelper.PushLabel({
										label = label,
										shadow = true,
										bold = true,
										font_size = 14,
										scaling = 1.2,
										color="255 255 0",
										background = "Texture/Aries/Common/gradient_white_32bits.png",
										background_color = "#1f3243",
									});
				end
				if(GathererClientLogics.QuestGoalItemHasLinkedCurWorld(id))then
					GathererClientLogics.Refresh();
				end
			end
		end
		
	end
end
function QuestClientLogics.CallServer(func,msg)
	local self = QuestClientLogics;
	if(not func)then return end
	msg = msg or {};
	if(type(msg) ~= "table")then
		LOG.std("","error","QuestClientLogics", "the type of msg must be table!");
		return
	end
	msg = commonlib.serialize_compact(msg);
	local body = string.format("[Aries][Quest][%s][%s]",func,msg);
	
	Map3DSystem.GSL_client:SendRealtimeMessage(sID, {body = body});
end
function QuestClientLogics.ShowQuestListPage()
	local self = QuestClientLogics;
	QuestListPage.ShowPage()
end
function QuestClientLogics.GetProvider()
	local self = QuestClientLogics;
	return self.provider;
end
function QuestClientLogics.OutPutDgml(path)
	local self = QuestClientLogics;
	local provider = self.provider;
	QuestHelp.SaveToDgml(provider.template_graph,path,false,provider)
end
function QuestClientLogics.ShowInfo_Killed(added_quest_map,old_quest_map)
	local self = QuestClientLogics;
	local label = "";
	local color = "255 0 0";
	if(added_quest_map and old_quest_map)then
		local id,q_item;
		local str =  "";
		for id,q_item in pairs(added_quest_map) do
			local Cur_Goal = q_item.Cur_Goal;
			local Cur_GoalItem = q_item.Cur_GoalItem;
			local Cur_ClientGoalItem = q_item.Cur_ClientGoalItem;
			local Cur_ClientExchangeItem = q_item.Cur_ClientExchangeItem;
			local Cur_FlashGame = q_item.Cur_FlashGame;
			local Cur_ClientDialogNPC = q_item.Cur_ClientDialogNPC;
			local Cur_CustomGoal = q_item.Cur_CustomGoal;

			local old_q_item = old_quest_map[id];
			local old_Cur_Goal;
			local old_Cur_GoalItem;
			local old_Cur_ClientGoalItem;
			local old_Cur_ClientExchangeItem;
			local old_Cur_FlashGame;
			local old_Cur_ClientDialogNPC;
			local old_Cur_CustomGoal;

			if(old_q_item)then
				old_Cur_Goal = old_q_item.Cur_Goal;
				old_Cur_GoalItem = old_q_item.Cur_GoalItem;
				old_Cur_ClientGoalItem = old_q_item.Cur_ClientGoalItem;
				old_Cur_ClientExchangeItem = old_q_item.Cur_ClientExchangeItem;
				old_Cur_FlashGame = old_q_item.Cur_FlashGame;
				old_Cur_ClientDialogNPC = old_q_item.Cur_ClientDialogNPC;
				old_Cur_CustomGoal = old_q_item.Cur_CustomGoal;
			end
			function getinfo(type,list,old_list)
				if(not list or not old_list)then return end
				local all_str_list = {};

				local k,v;
				for k,v in ipairs(list) do
					local id = tonumber(v.id);
					local cur_value = v.value or 0;
					local max_value = v.max_value or 0;
					local old_k,old_v;
					for old_k,old_v in ipairs(old_list) do
						local old_id = tonumber(old_v.id);
						local old_cur_value = old_v.value or 0;
						local old_max_value = old_v.max_value or 0;
						if(id == old_id and old_cur_value < cur_value and cur_value <= max_value and cur_value > 0)then
							local s;
							if(type == "Goal")then
								local __,map = QuestHelp.GetGoalList()
								local item = map[id];
								local label = "";
								if(item)then
									label = item.label;
								end
								s = string.format("消灭【%s】(%d/%d)",label,cur_value,max_value);
							elseif(type == "GoalItem")then
								local __,map = QuestHelp.GetQuestItemList();
								local item = map[id];
								local label = "";
								if(item)then
									label = item.label;
								end
								s = string.format("找到【%s】%d个(%d/%d)",label,cur_value,cur_value,max_value);
							elseif(type == "ClientGoalItem")then
								local __,map = QuestHelp.GetClientItemList();
								local item = map[id];
								local label = "";
								if(item)then
									label = item.label;
								end
								s = string.format("获得%s%d个(%d/%d)",label,cur_value,cur_value,max_value);
							elseif(type == "ClientExchangeItem")then
								local __,map = QuestHelp.GetClientExchangeItemList();
								local item = map[id];
								local label = "";
								if(item)then
									label = item.label;
								end
								s = string.format("合成【%s】%d次(%d/%d)",label,cur_value,cur_value,max_value);
							elseif(type == "FlashGame")then
								local __,map = QuestHelp.GetFlashGameList();
								local item = map[id];
								local label = "";
								if(item)then
									label = item.label;
								end
								s = string.format("玩小游戏【%s】%d次(%d/%d)",label,cur_value,cur_value,max_value);
							elseif(type == "ClientDialogNPC")then
								local __,map = QuestHelp.GetNpcList();
								local item = map[id];
								local label = "";
								if(item)then
									label = item.label;
								end
								s = string.format("对话【%s】%d次(%d/%d)",label,cur_value,cur_value,max_value);
							elseif(type == "CustomGoal")then
								local __,map = QuestHelp.GetCustomGoalList();
								local item = map[id];
								local label = "";
								local customlabel;
								if(item)then
									label = item.label;
									customlabel = item.customlabel;
								end
								if(customlabel)then
									customlabel = string.format(customlabel,cur_value);
									s = string.format("%s(%d/%d)",customlabel,cur_value,max_value);
								else
									s = string.format("完成【%s】%d次(%d/%d)",label,cur_value,cur_value,max_value);
								end
							end
							table.insert(all_str_list,s);
							
						end
					end
				end
				return all_str_list;
			end
			function show_info(list)
				if(not list)then return end
					local k,v;
					for k,v in ipairs(list) do 
						BroadcastHelper.PushLabel({
									label = v,
									shadow = true,
									bold = true,
									font_size = 14,
									scaling = 1.2,
									background = "Texture/Aries/Common/gradient_white_32bits.png",
									background_color = "#1f3243",
								});
					end
			end
			local s = getinfo("Goal",Cur_Goal,old_Cur_Goal);
			show_info(s);

			local s = getinfo("GoalItem",Cur_GoalItem,old_Cur_GoalItem);
			show_info(s);

			local s = getinfo("ClientGoalItem",Cur_ClientGoalItem,old_Cur_ClientGoalItem);
			show_info(s);

			local s = getinfo("ClientExchangeItem",Cur_ClientExchangeItem,old_Cur_ClientExchangeItem);
			show_info(s);

			local s = getinfo("FlashGame",Cur_FlashGame,old_Cur_FlashGame);
			show_info(s);

			local s = getinfo("ClientDialogNPC",Cur_ClientDialogNPC,old_Cur_ClientDialogNPC);
			show_info(s);
			local s = getinfo("CustomGoal",Cur_CustomGoal,old_Cur_CustomGoal);
			show_info(s);
		end
	end	
end
function QuestClientLogics.ShowInfo(id,type,msg)
	local self = QuestClientLogics;
	if(not id)then return end
	local templates = self.provider:GetTemplateQuests();
	local template = templates[id];
	if(not template)then
		return;
	end
	local label = "";
	local color = "255 0 0";
	if(type == "doaccepted")then
		label = string.format("接受任务:%s",template.Title or  "");
		Scene.ShowRegionLabel(label, color);
	elseif(type == "dofinished")then
		label = string.format("完成任务:%s",template.Title or  "");
		Scene.ShowRegionLabel(label, color);
	elseif(type == "dodrop")then
		label = string.format("放弃任务:%s",template.Title or  "");
		Scene.ShowRegionLabel(label, color);
	elseif(type == "doreaccept")then
		label = string.format("恢复任务:%s",template.Title or  "");
		Scene.ShowRegionLabel(label, color);
	elseif(type == "dodelete")then
		label = string.format("放弃任务:%s",template.Title or  "");
		Scene.ShowRegionLabel(label, color);
	end
end
function QuestClientLogics.Call_DoUserDisconnect()
	local self = QuestClientLogics;
	local msg = {
			nid = System.User.nid,
		}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoUserDisconnect",msg)
end
--限定在一个周期内只能发一次请求
function QuestClientLogics.CanDoAction(state,nid,questid)
	local self = QuestClientLogics;
	local limit_times = 5000;
	if(state and nid and questid)then
		local key = string.format("%s_%d_%d",state,nid,questid);
		local old_times = self.quest_action_map[key] or 0;
		local cur_time = commonlib.TimerManager.GetCurrentTime();
		if((old_times + limit_times) < cur_time)then
			self.quest_action_map[key] = cur_time;
			return true;
		end
	end
end
--关闭人物资料面板的时候，刷新任务追踪面板
function QuestClientLogics.NeedRefresh_DynamicAttr_Quest()
	local self = QuestClientLogics;
	if(not CommonClientService.IsTeenVersion() and self.provider)then
		local ids = {60305,60306,60307,60308,60309,};
		local k,id;
		for k,id in ipairs(ids) do
			if(self.provider:HasAccept(id))then
				QuestTrackerPane.ReloadPage();
				break;
			end
		end

	end
end
----------------------
--宠物喂养
----------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
--宠物镶嵌宝石
function QuestClientLogics.AttachGem(pet_gsid,gem_gsid)
	local self = QuestClientLogics;
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	if(self.dofeed_followpet_time and (cur_time - self.dofeed_followpet_time) < 1000) then
		return
	end
	self.dofeed_followpet_time = commonlib.TimerManager.GetCurrentTime();
	if(not pet_gsid or not gem_gsid)then return end
	
	local msg = {
		pet_gsid = pet_gsid,
		gem_gsid = gem_gsid,
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.AttachGem",msg)
end
--剥离宝石
function QuestClientLogics.UnAttachGem(pet_gsid)
	local self = QuestClientLogics;
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	if(self.dofeed_followpet_time and (cur_time - self.dofeed_followpet_time) < 1000) then
		return
	end
	self.dofeed_followpet_time = commonlib.TimerManager.GetCurrentTime();
	if(not pet_gsid)then return end
	
	local msg = {
		pet_gsid = pet_gsid,
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.UnAttachGem",msg)
end
function QuestClientLogics.DoChangeName_FollowPet(pet_gsid,pet_name)
	local self = QuestClientLogics;
	local self = QuestClientLogics;
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	if(self.dofeed_followpet_time and (cur_time - self.dofeed_followpet_time) < 1000) then
		return
	end
	self.dofeed_followpet_time = commonlib.TimerManager.GetCurrentTime();
	if(not pet_gsid or not pet_name)then return end
	local msg = {
		pet_gsid = pet_gsid,
		pet_name = pet_name,
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoChangeName_FollowPet",msg)
end
function QuestClientLogics.DoFeed_FollowPet_ExpCnt(pet_gsid,add_exp)
	local self = QuestClientLogics;
	if(not pet_gsid or not add_exp or add_exp <= 0)then
		return
	end
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	if(self.dofeed_followpet_time and (cur_time - self.dofeed_followpet_time) < 1000) then
		--_guihelper.MessageBox("你喂食的太快了！");
		return
	end
	self.dofeed_followpet_time = commonlib.TimerManager.GetCurrentTime();
	local msg = {
		pet_gsid = pet_gsid,
		add_exp = add_exp,
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoFeed_FollowPet",msg)
end
function QuestClientLogics.DoFeed_FollowPet(pet_gsid,food_gsid)
	local self = QuestClientLogics;
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	if(self.dofeed_followpet_time and (cur_time - self.dofeed_followpet_time) < 1000) then
		--_guihelper.MessageBox("你喂食的太快了！");
		return
	end
	self.dofeed_followpet_time = commonlib.TimerManager.GetCurrentTime();
	if(not pet_gsid or not food_gsid)then return end
	
	local msg = {
		pet_gsid = pet_gsid,
		food_gsid = food_gsid,
	}
	self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoFeed_FollowPet",msg)
end
--检查战宠的喂食日期，如果不是今天，重新生成今天的数据
function QuestClientLogics.Do_CheckDate_FollowPet(pet_gsid)
	local self = QuestClientLogics;
	if(not pet_gsid)then return end
	local hasItem,pet_guid = hasGSItem(pet_gsid);
	local provider = CombatPetHelper.GetClientProvider();
	if(provider)then
		--是否是战宠
		local is_combat_pet = provider:IsCombatPet(pet_gsid)
		if(not is_combat_pet)then
			return
		end
		--战宠
		local item = ItemManager.GetItemByGUID(pet_guid);
		if(item and item.GetServerData)then
			local data = item:GetServerData();
			if(type(data) ~= "table")then
				return
			end
			local serverdate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local cur_feed_date = data.cur_feed_date;
			--如果不是今天 重新生成数据
			if(cur_feed_date and cur_feed_date ~= serverdate)then
				self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.CheckDate_FollowPet",{pet_gsid = pet_gsid,})
			end
		end
	end
end
-------------------------------
--经验强化药丸 假日努力药丸
-------------------------------
function QuestClientLogics.CanUseItem_AddExpPercent(item_gsid)
	local self = QuestClientLogics;
	if(item_gsid == 12001 or item_gsid == 12002)then
		local bHas = hasGSItem(item_gsid);
		if(bHas)then
			local gsid;
			if(item_gsid == 12001)then
				gsid = 40001;
			elseif(item_gsid == 12002)then
				gsid = 40003;
			elseif(item_gsid == 12046)then
				gsid = 40006;
			end
			local __,__,__,copies = hasGSItem(gsid);
			copies = copies or 0;
			if(copies < 20)then
				return true;
			end
		end
	end
end
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local item_gsid = 12001;
QuestClientLogics.DoUseItem_AddExpPercent(item_gsid);
--]]
function QuestClientLogics.DoUseItem_AddExpPercent(item_gsid)
	local self = QuestClientLogics;
	LOG.std("","info","QuestClientLogics.DoUseItem_AddExpPercent 1", {item_gsid = item_gsid, });
	if(not item_gsid)then
		return
	end

	local hasItem,item_guid = hasGSItem(item_gsid);
	LOG.std("","info","QuestClientLogics.DoUseItem_AddExpPercent 2", {hasItem = hasItem, item_guid = item_guid});
	if(hasItem)then
		NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
		local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
		if(item_gsid == 12002 and not AntiIndulgenceArea.IsInHoliday())then
			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			_guihelper.Custom_MessageBox("你今天不能使用假日努力药丸哦！",function(result)
				if(result == _guihelper.DialogResult.OK)then
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
		self.CallServer("MyCompany.Aries.Quest.QuestServerLogics.DoUseItem_AddExpPercent",{item_gsid = item_gsid,})
	end
end