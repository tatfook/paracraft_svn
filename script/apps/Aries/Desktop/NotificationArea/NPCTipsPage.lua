--[[
Title: NPC notification
Author(s): LiXizhi
Date: 2012/9/27
Desc: stack of NPC tips with action button. the most recently added tip is shown first
The NPC is displayed as an icon on the corner of the screen. 
NPC tips are automatically selected from a candidate pool. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.lua");
local NPCTipsPage = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTipsPage");
-- put next loop tip
NPCTipsPage.TryPushTip();  
-- should be called every 1 oe 2 minutes
NPCTipsPage.OnFrameMove();  
-- One can also push a custom tip with url or npc tips at any time. url can be any mcml page with width, height
NPCTipsPage.PushTip({title="老用户大礼包", url="script/apps/Aries/Desktop/NotificationArea/NPCTips_GiftBox.kids.html", width=640, height=480, }) 
NPCTipsPage.PushTip({title="老用户大礼包", [1]="Sample tip content", npc_icon="Texture/Aries/NPCs/Portrait/Gift_GiftPackage_32bits.png"}) 
-- only for testing a given tip at the given index
NPCTipsPage.PushTip(1); 
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local NotificationArea = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local NPCTipsPage = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTipsPage");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;


local pageCtrl;
local tips={};
local all_loop_tips={};
local all_questions={};
-- mapping from nid to all shops. 
local all_shops = {};
-- mapping from npc id to shop tip node. 
local npc_map = {};

NPCTipsPage.duration = 15000;
NPCTipsPage.cur_play_node = nil;
NPCTipsPage.is_expanded = true;
NPCTipsPage.max_tip_in_stack = 5;

-- the first looped tip index to display on app start
local loop_tip_index; 
local question_tip_index; 


function NPCTipsPage.Init()
end


-- @param config_file: filename
-- @param outout: to which table to save the loaded tips. 
-- @param default_type: default to nil, or it can be "question";
function NPCTipsPage.LoadTipsFromFile(config_file, output, default_type)
	output = output or all_loop_tips;
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		LOG.std(nil, "debug", "NPCTipsPage", "failed loading npc tips page config file: %s", config_file);
		return;
	else
		LOG.std(nil, "debug", "NPCTipsPage", "loaded npc tips page config file: %s", config_file);
	end
		
	local xmlnode="/NPCTips/tip";
	
	local myCombatLevel = Player.GetLevel();
	local myCombatSchool = Player.GetSchool();
	local dayofweek = tostring(Scene.GetDayOfWeek());

	local each_tip;		
	for each_tip in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		local attr = each_tip.attr;
		each_tip.minlevel = tonumber(attr.minlevel)
		each_tip.maxlevel = tonumber(attr.maxlevel)
		each_tip.combatlevel = tonumber(attr.combatlevel)
		each_tip.type = attr.type or default_type;
		each_tip.school = attr.school;

		
		-- filtering school and level
		if( (each_tip.type=="shop" or (not each_tip.maxlevel or each_tip.maxlevel >= myCombatLevel)) and
			 (not each_tip.school or each_tip.school == myCombatSchool) and
			 (not attr.dayofweek or attr.dayofweek:match(dayofweek))) then
			each_tip.npcid = tonumber(attr.npcid)
			
			
			if(attr.npc_icon and attr.npc_icon~="") then
				each_tip.npc_icon = attr.npc_icon;
			end
			each_tip.title = attr.title;
			if(each_tip.maxlevel and each_tip.minlevel) then
				each_tip.is_looping = true;
			end
			each_tip.width = tonumber(attr.width)
			each_tip.height = tonumber(attr.height)
			each_tip.url = attr.url;

			if(each_tip.type == "tip" or not each_tip.type) then
				each_tip.has_action = false;
			else
				each_tip.has_action = true;
			end
			if(each_tip.npcid and each_tip.npc_icon) then
				npc_map[each_tip.npcid] = each_tip;
			end
			
			if(not each_tip.maxlevel or each_tip.maxlevel >= myCombatLevel) then
				output[#output+1] = each_tip;
			end
			if(each_tip.type=="shop" and each_tip.npcid) then
				all_shops[each_tip.npcid] = each_tip;
			end
		end
	end	
end

function NPCTipsPage.OnInit()
	local self = NPCTipsPage; 
	if(self.IsInited) then
		return 
	end
	self.IsInited = true;

	-- load tips
	self.tip_list = self.tip_list or commonlib.List:new();

	if(System.options.version=="kids") then
		NPCTipsPage.LoadTipsFromFile("config/Aries/Tips/NPC_tips.kids.xml", all_loop_tips);
		NPCTipsPage.LoadTipsFromFile("config/Aries/Tips/NPC_questions.kids.xml", all_questions, "question");
	else
		NPCTipsPage.LoadTipsFromFile("config/Aries/Tips/NPC_tips.teen.xml");
		-- NPCTipsPage.LoadTipsFromFile("config/Aries/Tips/NPC_questions.teen.xml");
	end
end

-- check if there is a tip, if so push to stack
-- return true if succeed. 
function NPCTipsPage.TryPushTip()
	NPCTipsPage.OnInit();
	if(NPCTipsPage.IsTipsFull()) then
		return;
	end
	local tip = NPCTipsPage.GetLoopTip(true)
	if(tip and not tip.is_shown ) then
	--if(tip)then
		return NPCTipsPage.PushTip(tip)
	end
end

function NPCTipsPage.GetContainer()
	if(System.options.version == "kids") then
		local _parent = MapArea.GetParentContainer();
		if(_parent) then
			local _this = _parent:GetChild("NPCTipsPage");
			if(not _this:IsValid()) then
				_this = ParaUI.CreateUIObject("container", "NPCTipsPage", "_lt", 0, 0, 200, 64);
				_this.background = "";
				_this.zorder = 2;
				_this:GetAttributeObject():SetField("ClickThrough", true);
				_parent:AddChild(_this);
			end
		
			if(_this.id ~= NPCTipsPage.ui_id or not NPCTipsPage.MyPage) then
				_this:RemoveAll();
				NPCTipsPage.ui_id = _this.id;
				NPCTipsPage.MyPage = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/NotificationArea/NPCTipsHeaderPage.kids.html"});
				NPCTipsPage.MyPage:Create("NPCTipsPage_", _this, "_fi", 0, 0, 0, 0);
			end
			return _this;
		end
	else
		local _parent = TargetArea.GetParentContainer();
		if(_parent) then
			local _this = _parent:GetChild("NPCTipsPage");
			if(not _this:IsValid()) then
				_this = ParaUI.CreateUIObject("container", "NPCTipsPage", "_lt", 256, 0, 200, 64);
				_this.background = "";
				_this.zorder = 2;
				_this:GetAttributeObject():SetField("ClickThrough", true);
				_parent:AddChild(_this);
			end
		
			if(_this.id ~= NPCTipsPage.ui_id or not NPCTipsPage.MyPage) then
				_this:RemoveAll();
				NPCTipsPage.ui_id = _this.id;
				NPCTipsPage.MyPage = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/NotificationArea/NPCTipsHeaderPage.teen.html"});
				NPCTipsPage.MyPage:Create("NPCTipsPage_", _this, "_fi", 0, 0, 0, 0);
			end
			return _this;
		end
	end
end

function NPCTipsPage.IsTipsFull()
	if(NPCTipsPage.tip_list:size() >= NPCTipsPage.max_tip_in_stack) then
		return true;
	end
end

function NPCTipsPage.Bounce_Static_Icon(name,bounce_or_stop)
	local _icon = ParaUI.GetUIObject(name);
	if(_icon and _icon:IsValid() == true) then
		if(bounce_or_stop == "bounce") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Bounce", true);
		elseif(bounce_or_stop == "stop") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Bounce");
		end
	end
end

-- push a given tip and display it on the ui. 
-- @param tip: {} or index of the tip. index is mostly used for testing. 
function NPCTipsPage.PushTip(tip)
	NPCTipsPage.OnInit();
	if(type(tip) == "number") then
		tip = all_loop_tips[tip];
	end
	if(not tip) then
		return;
	end

	local item = NPCTipsPage.tip_list:first();
	while (item) do
		if(item.tip == tip) then
			-- duplicated ones are ignored. or shall we swap to front?
			return;
		end
		item = NPCTipsPage.tip_list:next(item)
	end

	local _this = NPCTipsPage.GetContainer();
	if(_this) then
		NPCTipsPage.tip_list:add({tip = tip});
		NPCTipsPage.cur_tip_node = tip or {};
		NPCTipsPage.MyPage:Refresh(0);
		_this.visible = true;

		NPCTipsPage.Bounce_Static_Icon("NPCTipsHeaderPage_questicon", "bounce");
		return true;
	end
end

-- pop a tip and show the next
-- @param bShowWindow: if true it will show the tip window, when the window is closed by the user, the next tip if any will popup. 
function NPCTipsPage.PopTip(bShowWindow)
	local self = NPCTipsPage;
	local item = self.tip_list:last();
	self.tip_list:remove(item);
	local _this = NPCTipsPage.GetContainer();
	if(_this) then
		local tip = self.tip_list:last();
		if(tip) then
			NPCTipsPage.cur_tip_node = tip.tip or {};
			NPCTipsPage.MyPage:Refresh(0);
			_this.visible=true;
		else
			NPCTipsPage.Bounce_Static_Icon("NPCTipsHeaderPage_questicon", "stop");
			_this.visible=false;
		end
	end

	if(bShowWindow)then
		local tip = item.tip or {};
		NPCTipsPage.show_dialog_tip = tip;
		tip.is_shown = true;

		local width, height = tonumber(tip.width) or 420, tonumber(tip.height) or 260;
		local url = tip.url;
		if(not url) then
			if(tip.type == "question") then
				url = "script/apps/Aries/Desktop/NotificationArea/NPCQuestionsPage.kids.html"
				height = 320;
			else
				url = if_else(System.options.version == "kids", "script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.kids.html", "script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.teen.html")
			end
		end
		local params = {
			url = url, 
			name = "NPCTipsPage", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			enable_esc_key = true,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -width/2,
				y = -height/2,
				width = width,
				height = height,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);

		local _this = NPCTipsPage.GetContainer();
		if(_this) then
			NPCTipsPage.Bounce_Static_Icon("NPCTipsHeaderPage_questicon", "stop");
			_this.visible=false;
		end
		params._page.OnClose = function()
			-- display the next one if 
			local tip = self.tip_list:last();
			if(tip) then
				local _this = NPCTipsPage.GetContainer();
				if(_this and not _this.visible) then
					_this.visible = true;
				end
			end
		end
	end
end

-- get tip from npc id. return nil if not exist. 
function NPCTipsPage.GetTipByNPCID(npc_id)
	if(npc_map) then
		return npc_map[npc_id];
	end
end


-- mapping from player level to cached npc shops. 
local recommended_shops = {};

-- return an array of npc shop tips. This can be used to display nearby npc shops. 
function NPCTipsPage.GetRecommendedNPCShops()
	local myCombatLevel = Player.GetLevel();
	if(recommended_shops[myCombatLevel]) then
		return recommended_shops[myCombatLevel];
	else
		local npc_shops = {};
		recommended_shops[myCombatLevel] = npc_shops;

		NPCTipsPage.OnInit();
		
		local all_titles = {};

		local npcid, tip;
		for npcid, tip in pairs(all_shops) do
			if (tip.type=="shop" and (not tip.minlevel or myCombatLevel >= tip.minlevel)) then
				local last_index = all_titles[tip.title]
				local priority = (tip.maxlevel or 0) + (tonumber(tip.attr.priority) or 0)
				if(not last_index) then
					local index = #npc_shops+1
					all_titles[tip.title] = index;
					npc_shops[index] = {attr=tip.attr, name="tip", priority = priority };
				else
					
					local lasttip = npc_shops[last_index];
					if(lasttip.priority < priority) then
						npc_shops[last_index] = {attr=tip.attr, name="tip", priority = priority};
					end
				end
			end
		end
		table.sort(npc_shops, function(a, b)
			return (a.priority>b.priority);
		end);
		return npc_shops;
	end
end

-- get next loop tips . it will automatically increase the loop_tip_index by one internally if bShowNextTip is true. 
-- @param bShowNextTip: if true, it will show next tip. otherwise it will show current tips. 
-- @return tip table or nil.
function NPCTipsPage.GetLoopTip(bShowNextTip)
	local self = NPCTipsPage; 
	NPCTipsPage.OnInit();

	local myCombatLevel = Player.GetLevel();
	local i;
	if(not loop_tip_index) then
		local my_tips = {};
		local nSize = #(all_loop_tips);
		for i=1, nSize do
			local tip = all_loop_tips[i];
			if (tip.is_looping and myCombatLevel >= tip.minlevel and myCombatLevel <= tip.maxlevel) then
				my_tips[#my_tips+1] = i;
			end
		end
		if(#my_tips > 1)  then
			loop_tip_index = my_tips[math.random(1, #my_tips)];
		else
			loop_tip_index = 1;
		end
	end

	if(bShowNextTip) then
		loop_tip_index = loop_tip_index +1;
	end
	if (loop_tip_index<=0) then
		loop_tip_index = 1;
	end


	local nSize = #(all_loop_tips);
	for i=1, nSize do
		if (loop_tip_index>nSize) then
			loop_tip_index = 1;
		end
		local tip = all_loop_tips[loop_tip_index];
		if (tip.is_looping and myCombatLevel >= tip.minlevel and myCombatLevel <= tip.maxlevel) then
			--LOG.std(nil, "debug", "NPCTipsPage", "loop_tip_index %d is saved.",  loop_tip_index)
			-- Player.SaveLocalData("loop_tip_index", loop_tip_index);
			return tip;
		end
		loop_tip_index = loop_tip_index + 1;
	end
end

-- @param bMarkAsShown: true to mark as shown. 
function NPCTipsPage.GetQuestionTip(bMarkAsShown)
	local self = NPCTipsPage; 
	NPCTipsPage.OnInit();

	local myCombatLevel = Player.GetLevel();
	
	local nStartIndex;
	local count = 0;
	local nSize = #(all_questions);
	local i;
	for i=1, nSize do
		local tip = all_questions[i];
		if ((not tip.is_shown) and tip.is_looping and myCombatLevel >= tip.minlevel and myCombatLevel <= tip.maxlevel) then
			count = count + 1;
			if(count == 1) then
				nStartIndex = i;
			end
		end
	end

	if(count == 0 or not nStartIndex) then
		return;
	end
	local nChosenIndex = math.random(1, count);
	count = 0;
	for i=nStartIndex, nSize do
		local tip = all_questions[i];
		if ((not tip.is_shown) and tip.is_looping and myCombatLevel >= tip.minlevel and myCombatLevel <= tip.maxlevel) then
			count = count + 1;
			if(count == nChosenIndex) then
				if(bMarkAsShown) then
					tip.is_shown = true;
				end
				return tip;
			end
		end
	end
end 

-- check if there is a tip, if so push to stack
-- return true if succeed. 
function NPCTipsPage.TryPushQuestionTip()
	NPCTipsPage.OnInit();
	if(NPCTipsPage.IsTipsFull()) then
		return;
	end
	local tip = NPCTipsPage.GetQuestionTip(true);
	if(tip) then
		NPCTipsPage.PushTip(tip);
	end
end

function NPCTipsPage.GetCurLoopTip()
	return NPCTipsPage.cur_tip_node;
end

local last_time_table_index = 1;
local tip_popup_time_table = {
	--{mins=1, }, -- testing
	--{mins=2, }, -- testing

	{mins=20, },
	{mins=30, },
	{mins=40, },
	{mins=50, },
	{mins=60, },
	{mins=70, },
	{mins=80, },
	{mins=90, },
}
local default_push_interval_mins = 10;
-- call this function every 1 or 2 minutes to try to push a pip if any. 
function NPCTipsPage.OnFrameMove()
	local time_seconds = Scene.GetElapsedSecondsSinceLogin();
	local time_table = tip_popup_time_table[last_time_table_index]
	if(time_table and time_table.mins*60 < time_seconds) then
		time_table.is_passed = true;
		last_time_table_index = last_time_table_index + 1;
		tip_popup_time_table[last_time_table_index] = tip_popup_time_table[last_time_table_index] or {mins = (time_table.mins+default_push_interval_mins)}

		NPCTipsPage.TryPushTip();
		NPCTipsPage.TryPushQuestionTip();
	end
end

-- call this function when player levels up
function NPCTipsPage.OnLevelup(level)
	local self = NPCTipsPage; 
	NPCTipsPage.OnInit();
	local myCombatLevel = level or Player.GetLevel();
	local nSize = #(all_loop_tips);
	local i;
	for i=1, nSize do
		local tip = all_loop_tips[i];
		if (myCombatLevel == tip.combatlevel) then
			NPCTipsPage.PushTip(tip);
		end
	end
end

-- user clicks the action button, usually we need to teleport to the npc. 
function NPCTipsPage.OnClickActionBtn(tip)
	if(not tip) then
		return
	end
	if(tip.npcid and (tip.type=="npc" or tip.type=="shop")) then
		WorldManager:GotoNPC(tip.npcid);
	elseif(tip.type=="haqishop")then
		local category = tip.attr.category;
		if(category) then
			NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
			MyCompany.Aries.HaqiShop.ShowMainWnd(nil, category);
		end
	elseif(tip.type=="question")then
		
	elseif(tip.type=="lucky_lottery")then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemLuckyPage.lua");
		local ItemLuckyPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemLuckyPage");
		ItemLuckyPage.ShowPage();
	end
end
