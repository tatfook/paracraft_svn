--[[
Title: 
Author(s): Leio
Date: 2010/10/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPage.lua");
local QuestTrackerPage = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPage");
QuestTrackerPage.Refresh(true)

NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPage.lua");
local QuestTrackerPage = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPage");
local id = 60005;
QuestTrackerPage.PushQuest(id)
local id = 60083;
QuestTrackerPage.PushQuest(id)
local id = 60022;
QuestTrackerPage.PushQuest(id)
QuestTrackerPage.Refresh()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestTrackerPage = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPage");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");

local LOG = LOG;
QuestTrackerPage.list = {};
QuestTrackerPage.max_size = 3;
QuestTrackerPage.page = nil;
QuestTrackerPage.is_expanded = true;
--任务追踪 切换世界后没有立即获取到mob坐标 用timer刷新 直至找到位置
--如果切换追踪 取消追踪 清空
local pending_mob_track_timer = nil;
local try_find_num = 0;
local bg_timer;

function QuestTrackerPage.Enable_PendingMobTrack(bEnable)
	--青年版有效
	if(not CommonClientService.IsTeenVersion())then
		return
	end	
	local self = QuestTrackerPage;
	if(not pending_mob_track_timer)then
		pending_mob_track_timer = commonlib.Timer:new({callbackFunc = QuestTrackerPage.PendingMobTrackCallback})
	end
	if(bEnable) then
		--只执行一次
		pending_mob_track_timer:Change(5000,nil);
	else
		pending_mob_track_timer:Change(nil);
	end
end
function QuestTrackerPage.PendingMobTrackCallback(timer)
	local self = QuestTrackerPage;
	local questid = self.find_path_questid;
	local goalid = self.find_path_goalid;
	if(not pending_mob_track_timer)then
		return
	end
	try_find_num = try_find_num + 1;
	if(try_find_num > 3)then
		pending_mob_track_timer:Change(nil);
		try_find_num = 0;
		return;
	end
	if(questid and goalid)then
		QuestTrackerPage.FindPath_Active(questid,goalid)
	else
		pending_mob_track_timer:Change(nil);
	end
end
function QuestTrackerPage.OnInit()
	local self = QuestTrackerPage;
	self.page = document:GetPageCtrl();
end

-- only used for debugging ui
function QuestTrackerPage.RebuildPage()
	if(QuestTrackerPage.page) then
		QuestTrackerPage.page:Rebuild();
	end
end

function QuestTrackerPage.LoadState()
	local self = QuestTrackerPage;
	local key = string.format("QuestTrackerPage.LoadState_%d",System.User.nid or 0);
	local b = MyCompany.Aries.Player.LoadLocalData(key, true);
	self.is_expanded = b;
end
function QuestTrackerPage.SaveState()
	local self = QuestTrackerPage;
	local key = string.format("QuestTrackerPage.LoadState_%d",System.User.nid or 0);
	local b = self.is_expanded;
	MyCompany.Aries.Player.SaveLocalData(key,b);
end

function QuestTrackerPage.IsShown()
	if(QuestTrackerPage.page and QuestTrackerPage.is_shown == true) then
		return true;
	else
		return false;
	end
end

-- tricky: this is not same as not  IsShown(). if the page is not created, it is not hidden. 
function QuestTrackerPage.IsHidden()
	if(QuestTrackerPage.page and not QuestTrackerPage.is_shown ) then
		return true;
	end
end

-- toggle show/hide the page
function QuestTrackerPage.Show(bShow)
	bShow = false;
	if(not QuestArea.is_inited or (QuestTrackerPage.is_disabled and bShow)) then
		return;
	end
	local self = QuestTrackerPage;
	if(bShow)then
		self.ShowPage();
		self.is_shown = true;
		QuestTrackerPage.EnableTimer(true);
	else
		self.ClosePage();
	end
end

function QuestTrackerPage.ShowPage()
	local self = QuestTrackerPage;
	QuestTrackerPage.LoadState();
	if(System.options.version == "kids") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Quest/QuestTrackerPage.html", 
				name = "QuestTrackerPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = -1, -- avoid interaction with other normal user interface
				click_through = true, -- allow clicking through
				allowDrag = false,
				bShow = true,
				isPinned = true,
				directPosition = true,
					align = "_rt",
					x = -222,
					y = 100,
					width = 222,
					height = 320,
			});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Quest/QuestTrackerPage.teen.html", 
				name = "QuestTrackerPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = -1, -- avoid interaction with other normal user interface
				click_through = true, -- allow clicking through
				bShow = true,
				allowDrag = false,
				isPinned = true,
				cancelShowAnimation = true,
				directPosition = true,
					align = "_rt",
					x = -250,
					y = 190,
					width = 250,
					height = 320,
			});
		self.ShowHelpTooltip_Jump();
	end
end

function QuestTrackerPage.OnCanvasCreated()
	QuestTrackerPage.is_fade_out = nil;
end

function QuestTrackerPage.FadeIn()
	if(QuestTrackerPage.is_fade_out and QuestTrackerPage.page) then
		QuestTrackerPage.is_fade_out = false;
		local _parent = QuestTrackerPage.page:FindControl("canvas");
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPage", _parent, 255, 512)
		local _parent = QuestTrackerPage.page:FindControl("canvas_content");
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPage.content", _parent, 255, 512, nil, false)
	end
end

function QuestTrackerPage.FadeOut()
	if(not QuestTrackerPage.is_fade_out and QuestTrackerPage.page) then
		QuestTrackerPage.is_fade_out = true;
		local _parent = QuestTrackerPage.page:FindControl("canvas");
		local target_content_alpha = if_else(System.options.version == "teen", 0, 0);
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPage", _parent, 90, 64, 2000)
		local _parent = QuestTrackerPage.page:FindControl("canvas_content");
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPage.content", _parent, target_content_alpha, 64, 2000, false)
	end
end

function QuestTrackerPage.HasFocus()
	if(QuestTrackerPage.IsShown()) then
		if(QuestTrackerPage.is_expanded and not QuestTrackerPage.IsEmpty()) then
			local _parent = QuestTrackerPage.page:FindControl("canvas_content");
			if(_parent and _parent:IsValid()) then
				local x, y, width, height = _parent:GetAbsPosition();
				local mouseX, mouseY = ParaUI.GetMousePosition();
				if(x<=mouseX and mouseX <= (x+width) and (y-22)<=mouseY and mouseY<(y+height)) then
					return true;
				end
			end
		else
			local _parent = QuestTrackerPage.page:FindControl("canvas");
			if(_parent and _parent:IsValid()) then
				local x, y, width, height = _parent:GetAbsPosition();
				local mouseX, mouseY = ParaUI.GetMousePosition();
				if(x<=mouseX and mouseX <= (x+width) and y<=mouseY and mouseY<(y+height)) then
					return true;
				end
			end
		end
	end
end

-- timer is enabled whenever chat edit window is shown
function QuestTrackerPage.EnableTimer(bEnabled)
	--if(System.options.version == "teen") then
		if(not bg_timer) then
			bg_timer = commonlib.Timer:new({callbackFunc = QuestTrackerPage.OnTimer})
		end
		if(bEnabled) then
			bg_timer:Change(200, 200);
		else
			bg_timer:Change(200, nil);
		end
	--end
end

-- this is a slow timer to highlight the chat area 
-- if the mouse cursor is within the chat area, we will highlight the background. 
-- otherwise we will not show the display background.
function QuestTrackerPage.OnTimer(timer)
	if(QuestTrackerPage.HasFocus()) then
		QuestTrackerPage.FadeIn();
	else
		QuestTrackerPage.FadeOut();
	end
end


function QuestTrackerPage.IsFull()
	local self = QuestTrackerPage;
	if(self.list)then
		local len = #self.list;
		if(len >= self.max_size)then 
			return true
		end
	end
end
function QuestTrackerPage.IsEmpty()
	local self = QuestTrackerPage;
	if(not self.list)then
		return true;
	end
	if(self.list)then
		local len = #self.list;
		if(len == 0)then 
			return true
		end
	end
end
function QuestTrackerPage.ClosePage()
	local self = QuestTrackerPage;
	if(self.page)then
		self.page:CloseWindow();
		self.is_shown = false;
		QuestTrackerPage.EnableTimer(false);
		QuestTrackerPage.is_fade_out = nil;
	end
end
--追踪同一个任务，目标会变：1开始npc 2任务目标1，任务目标2 3结束npc
function QuestTrackerPage.ResetGoalID()
	local self = QuestTrackerPage;
	if(self.find_path_questid)then
		local goalid = QuestHelp.GetFirstGoalID(self.find_path_questid);
		if(self.find_path_goalid and goalid and self.find_path_goalid ~= goalid)then
			QuestTrackerPage.FindPath_Active(self.find_path_questid,goalid);
		end
	end
end
function QuestTrackerPage.Refresh(find_path_active)
	local self = QuestTrackerPage;
	if(System.options.version == "kids")then
		if(self.page)then
			self.page:Refresh(0.1);
		end
	else
		self.BuildSortList();
		self.ResetGoalID();
		if(find_path_active and not self.FindPath_HasTracked())then
			self.FindPath_ActiveFirstGoal();
		end
		self.FindPath_ReActive();
		if(self.page)then
			self.page:Refresh(0.1);
		end
		self.ShowHelpTooltip_Jump();
	end
end

function QuestTrackerPage.CanPushQuest(id)
	local self = QuestTrackerPage;
	if(not id)then return end
	if(self.HasQuest(id) or self.IsFull())then
		return;
	end
	return true;
end

function QuestTrackerPage.PushQuest(id)
	local self = QuestTrackerPage;
	if(not self.CanPushQuest(id))then return end
	table.insert(self.list,id);
	QuestTrackerPage.SaveData();
end
function QuestTrackerPage.DeleteQuest(id)
	local self = QuestTrackerPage;
	if(not id)then return end
	self.FindPath_ClearByQuestID(id);
	local k,v;
	for k,v in ipairs(self.list) do
		if(id == v)then
			table.remove(self.list,k);
			QuestTrackerPage.SaveData();
			return;
		end
	end
end
function QuestTrackerPage.HasQuest(id)
	local self = QuestTrackerPage;
	if(not id)then return end
	local k,v;
	for k,v in ipairs(self.list) do
		if(id == v)then
			return true;
		end
	end
end
--检查已经追踪的任务是否已经完成
--把完成的任务 从记录中清除
function QuestTrackerPage.CheckQuest(provider)
	local self = QuestTrackerPage;
	if(not provider)then return end
	local templates = QuestHelp.GetTemplates();
	if(self.list)then
		local k,id;
		local len = #self.list;
		for k = 1,len do
			local index = len - k + 1;
			local id = self.list[index];
			if(id)then
				local bCanAccept = provider:CanAccept(id);
				local bHasAccept = provider:HasAccept(id);
				local canDelete = true;
				if(bCanAccept or bHasAccept)then
					canDelete = false;
				end
				if(templates)then
					local has_id= templates[id];
					if(not has_id)then
						canDelete = true;
					end
				end
				if(canDelete)then
					table.remove(self.list,index);
				end
			end
		end
	end
end
--如果任务追踪里面没有记录
--自动推荐可以接的任务
function QuestTrackerPage.AutoPushQuestIfEmpty(provider)
	local self = QuestTrackerPage;
	if(not provider or not self.IsEmpty())then return end
	local q_list = provider:FindQuests();
	if(q_list)then
		local k,v;
		for k,v in ipairs(q_list) do
			local state = v.state;
			local questid = v.questid;
			local bCanPush = self.CanPushQuest(questid);
			if(state == 2 and bCanPush)then
				table.insert(self.list,questid);
			end
		end
	end
	self.SaveData();
end
function QuestTrackerPage.LoadData(provider,callbackFunc)
	local self = QuestTrackerPage;
		local gsid = 985;
		local bagFamily = 1002;
		ItemManager.GetItemsInBag(bagFamily, "985_QuestProgressTag", function(msg)
				local hasGSItem = ItemManager.IfOwnGSItem;
				local hasItem,guid = hasGSItem(gsid);
				if(hasItem)then
					local item = ItemManager.GetItemByGUID(guid);
					if(item)then
						local clientdata = item.clientdata;
						LOG.std("", "system", "QuestTrackerPage", clientdata);
						if(clientdata == "")then
							clientdata = "{}"
						end
						LOG.std("", "system", "QuestTrackerPage", "==========before commonlib.LoadTableFromString(clientdata) in 985_QuestProgressTag");
						clientdata = commonlib.LoadTableFromString(clientdata);
						LOG.std("", "system", "QuestTrackerPage", "==========after commonlib.LoadTableFromString(clientdata) in 985_QuestProgressTag");
						LOG.std("", "system", "QuestTrackerPage", clientdata);

						if(clientdata and type(clientdata) == "table")then
							self.list = clientdata;
							--检查是否有出错的记录
							self.CheckQuest(provider);
							self.AutoPushQuestIfEmpty(provider);
							if(callbackFunc and type(callbackFunc) == "function")then
								callbackFunc({
								});
							end
						end
					
					end
				end
			end, "access plus 10 minutes");
end
--clientdata is a table
function QuestTrackerPage.SaveData(callbackFunc)
	local self = QuestTrackerPage;
	local gsid = 985;
	local bagFamily = 1002;
	LOG.std("", "system", "QuestTrackerPage", "=========before save 985_QuestProgressTag");
	ItemManager.GetItemsInBag(bagFamily, "985_QuestProgressTag", function(msg)
		local hasGSItem = ItemManager.IfOwnGSItem;
		local hasItem,guid = hasGSItem(gsid)
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				--序列化
				local list = self.list;
				local clientdata = commonlib.serialize_compact2(list);
					LOG.std("", "system", "QuestTrackerPage", "============after save 985_QuestProgressTag");
					LOG.std("", "system", "QuestTrackerPage", clientdata);
				ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
					LOG.std("", "system", "QuestTrackerPage", "============after save 985_QuestProgressTag");
					LOG.std("", "system", "QuestTrackerPage", msg_setclientdata);
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({
								
						});
					end
				end);
			end
		end
	end, "access plus 10 minutes");
end
function QuestTrackerPage.ClearData()
	local self = QuestTrackerPage;
	self.list = {};
	self.SaveData();
end
function QuestTrackerPage.FindPath_ClearByQuestID(questid)
	local self = QuestTrackerPage;
	if(questid and self.find_path_questid and questid == self.find_path_questid)then
		self.find_path_questid = nil;
		self.find_path_goalid = nil;
		QuestPathfinderNavUI.SetTargetQuest(false);
	end
end
--重新激活一次追踪的目标
function QuestTrackerPage.FindPath_ReActive()
	local self = QuestTrackerPage;
	if(self.find_path_questid and self.find_path_goalid)then
		self.FindPath_Active(self.find_path_questid,self.find_path_goalid);
	end
end
--任务追踪
--return item_info
function QuestTrackerPage.FindPath_Active(questid,goalid)
	local self = QuestTrackerPage;
	self.find_path_questid = questid;
	self.find_path_goalid = goalid;
	if(questid == nil and goalid == nil)then
		QuestPathfinderNavUI.SetTargetQuest(false)
	end
	QuestHelp.ActiveAreaTip(false);
	-- this ensures the pending.
	self.Enable_PendingMobTrack(false);

	if(WorldManager:IsInInstanceWorld())then
		QuestPathfinderNavUI.SetTargetQuest(false)
		return
	end
	--find a nearest distance between user position and jump position which in jump list
	local function get_nearest_pos(item_info)
		local min_x,min_y,min_z = item_info.x,item_info.y,item_info.z;
		local multi_jump_position = item_info.multi_jump_position;
		local player = ParaScene.GetPlayer();
		if(multi_jump_position and player)then
			local min_dist = 0;
			--player position
			local  _x,_y,_z = player:GetPosition();
			local k,v;
			for k,v in ipairs(multi_jump_position) do
				local pos = v.pos;
				if(pos and pos[1] and pos[2] and pos[3])then
					local dx = pos[1] - _x;
					local dy = 0;--ignore coordinate of y
					local dz = pos[3] - _z;
					local dist = dx*dx + dy*dy + dz*dz;
					if(dist < min_dist)then
						min_dist = dist;
						min_x,min_y,min_z = pos[1],pos[2],pos[3];
					end
				end
			end
		end
		return min_x,min_y,min_z;
	end
	if(questid and goalid)then
		local current_world = WorldManager:GetCurrentWorld();
		local item_info = QuestHelp.GetItemInfoByID(goalid,true);
		if(item_info)then
			local radius;
			local facing = 0;
			local is_npc = item_info.is_npc;
			local worldname = item_info.worldname;
			if(is_npc)then
				radius = 1;
				facing = item_info.facing;
			else
				radius = 5;
			end
			local camPos;
			if(item_info.camera_x and item_info.camera_y and item_info.camera_z)then
				camPos = {camera_x,camera_y,camera_z};
			end
			local state = item_info.state;
			--追踪坐标
			--local x,y,z = get_nearest_pos(item_info);
			local x,y,z = item_info.x,item_info.y,item_info.z;
			--跳转坐标
			local jump_pos = { x,y,z };
			if(state == "mob" and current_world.name == worldname)then
				local n_x,n_y,n_z = QuestHelp.GetClosetArenaPosByMobID(goalid);
				--如果有最近法阵坐标
				if(n_x and n_y and n_z)then
					x = n_x;
					y = n_y;
					z = n_z;
					self.Enable_PendingMobTrack(false)
				else
					self.Enable_PendingMobTrack(true)
				end
			else
				self.Enable_PendingMobTrack(false)
			end
			local same_world = false;
			if(current_world.name == worldname)then
				same_world = true;
			end
			local params = {
				x = x,
				y = y,
				z = z,
				jump_pos = jump_pos,--跳转坐标
				camPos = camPos,--跳转后摄影机坐标
				worldInfo = item_info.worldInfo,
				radius = radius,
				targetName = item_info.label,
				find_path_questid = questid,
				find_path_goalid = goalid,
				is_npc = is_npc,
				facing = facing,
				is_area_tip = (state == "mob"),  -- this will show up area tip
				same_world = same_world,
			}
			item_info.x = jump_pos[1];
			item_info.y = jump_pos[2];
			item_info.z = jump_pos[3];
			QuestPathfinderNavUI.SetTargetQuest(params)
			QuestPathfinderNavUI.RefreshPage(true);
			return item_info;
		end
	end
end
--是否已经有追踪目标
function QuestTrackerPage.FindPath_HasTracked()
	local self = QuestTrackerPage;
	if(self.find_path_questid and self.find_path_goalid)then
		return true;
	end	
end
function QuestTrackerPage.FindPath_IsActive(questid,goalid)
	local self = QuestTrackerPage;
	local target = QuestPathfinderNavUI.GetTargetQuest();
	if(self.find_path_questid == questid and self.find_path_goalid == goalid)then
		-- added by LiXizhi 2011.10: in case the path finder is tracking other target outside the quest system. 
		local target = QuestPathfinderNavUI.GetTargetQuest();
		if(target and target.find_path_questid == questid and target.find_path_goalid == goalid) then
			return true;
		end
	end
end

--激活第一个目标
function QuestTrackerPage.FindPath_ActiveFirstGoal()
	if(System.options.version == "kids")then
		--不支持儿童版
		return
	end
	local self = QuestTrackerPage;
	--选择第一条记录
	if(self.sort_list and self.sort_list[1])then
		local questid = self.sort_list[1].questid;
		local goalid = QuestHelp.GetFirstGoalID(questid);
		QuestTrackerPage.FindPath_Active(questid,goalid)
	end
end
function QuestTrackerPage.BuildSortList()
	local self = QuestTrackerPage;
	local list = {
	}
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();

	local k,v;
	for k,v in ipairs(QuestTrackerPage.list) do
		local questid = v;
		local template = templates[questid];
		if(template)then
			local TrackLevel = template.TrackLevel or 0;
			local state = provider:GetState(v) or 0;
			table.insert(list,{
				questid = v;
				state = state,
				TrackLevel = TrackLevel,
			})
		end
		
	end
	table.sort(list,function(a,b)
		return (a.state < b.state) or (a.state == b.state and a.TrackLevel > b.TrackLevel);
		--return a.state < b.state;
	end)
	
	self.sort_list = list;
end
function QuestTrackerPage.ShowHelpTooltip_Jump()
	local self = QuestTrackerPage;
	self.HideHelpTooltip_Jump();
	if(not CommonClientService.IsTeenVersion() or QuestTrackerPage.IsEmpty())then
		return
	end
    local provider = QuestClientLogics.GetProvider();
	if(provider:HasAccept(61010) and not provider:HasFinished(61010))then
		if(self.page)then
			self.page:SetValue("TooltipsPPT", "howtouse")
		end
	end
	
end
function QuestTrackerPage.HideHelpTooltip_Jump()
	local self = QuestTrackerPage;
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	if(self.page)then
		self.page:SetValue("TooltipsPPT", nil)
	end
end
