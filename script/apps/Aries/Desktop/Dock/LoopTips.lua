--[[
Title: LoopTips
Author(s): spring, refactored by LiXizhi
Date: 2011/08/03
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
LoopTips.GetTip(true)

NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
LoopTips.DoStartDefault()
------------------------------------------------------------
]]

-- create class
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local looptips={};
local pageCtrl;
local tips={};

LoopTips.duration = 15000;
LoopTips.cur_play_node = nil;
LoopTips.is_expanded = true;

-- the first looped tip index to display on app start
local loop_tip_index; --  = math.ceil(ParaGlobal.random()*10);

function LoopTips.OnInit()
	local self = LoopTips; 
	if(self.IsInited) then
		return 
	end
	self.IsInited = true;

	local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
	-- loop_tip_index = (tonumber(system_looptip.loop_tip_index) or 0);    
	-- loop_tip_index = (tonumber(Player.LoadLocalData("loop_tip_index", 0, false)) or 0);
	LOG.std(nil, "debug", "LoopTips", "loop_tip_index %d is loaded.",  loop_tip_index)

	local config_file;
	if(System.options.IsMobilePlatform and System.options.mc) then
		config_file="config/Aries/creator/LoopWords.mobile.xml";
	elseif(System.options.mc) then
		config_file="config/Aries/creator/LoopWords.mc.xml";
	else
		if(System.options.version=="kids") then
			config_file="config/Aries/Tips/LoopWords.kids.xml";
		else
			config_file="config/Aries/Tips/LoopWords.teen.xml";
		end
	end
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading loopwords config file: %s\n", config_file);
		return;
	end
		
	local xmlnode="/tipwords/tipword";
	
	looptips={}; -- 初始化 looptips 
	
	local each_tip;		
	local i=1;
	for each_tip in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		looptips[i]={
			minlevel = tonumber(each_tip.attr.minlevel),
			maxlevel = tonumber(each_tip.attr.maxlevel),
			tip = L(each_tip.attr.tip);
		};	
		i=i+1;
	end	
end


-- get tips at index. it will automatically increase the loop_tip_index by one internally if bShowNextTip is true. 
-- @param bShowNextTip: if true, it will show next tip. otherwise it will show current tips. 
-- @return tip
function LoopTips.GetTip(bShowNextTip)
	local self = LoopTips; 
	if(not self.IsInited) then
		LoopTips.OnInit();
	end

	local bean = MyCompany.Aries.Pet.GetBean();
	local myCombatLevel = 0;

	if(bean) then
		myCombatLevel = bean.combatlel or 0;
	end

	if(not loop_tip_index) then
		local my_tips = {};
		local nSize = #(looptips);
		for i=1, nSize do
			local tip = looptips[i];
			if (myCombatLevel >= tip.minlevel and myCombatLevel <= tip.maxlevel) then
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


	local nSize = #(looptips);
	for i=1, nSize do
		if (loop_tip_index>nSize) then
			loop_tip_index = 1;
		end
		local tip = looptips[loop_tip_index];
		if (tip and myCombatLevel >= tip.minlevel and myCombatLevel <= tip.maxlevel) then
			--LOG.std(nil, "debug", "LoopTips", "loop_tip_index %d is saved.",  loop_tip_index)
			--LOG.std(nil, "debug", "LoopTips", "tip is %s",  tip.tip);
			local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
			system_looptip.loop_tip_index = loop_tip_index;
			-- Player.SaveLocalData("loop_tip_index", loop_tip_index);
			return tip.tip;
		end
		loop_tip_index = loop_tip_index + 1;
	end
end

------------------

function LoopTips.DoStartDefault()
	local self = LoopTips;
	self.DoStart(true);
end

--active a tooltip
-- @param bShowNextTip: if true, it will show next tip. otherwise it will show current tips. 
function LoopTips.DoStart(bShowNextTip)
	local self = LoopTips;
	--only support teen version, not use looptips words 2012.11.5,only keep vote button
	if(true or not CommonClientService.IsTeenVersion())then
		return
	end
	self.cur_play_node=LoopTips.GetTip(bShowNextTip)

	if(not self.timer)then
		self.timer = commonlib.Timer:new();
	end
	self.timer.callbackFunc = self.TimerCallback;
	self.timer:Change(10,self.duration);

	if(not self.expand_timer)then
		self.expand_timer = commonlib.Timer:new();
	end
	self.expand_timer.callbackFunc = self.expand_TimerCallback;
	self.expand_timer:Change(200, 200);
	--if(not self.IsShown())then
		--commonlib.echo("++++++++++++++ LoopTip2 ++++++++++++");
		self.ShowPage(true);
	--end
end

-- enable or disable expand
function LoopTips.OnCheckExpandBtn(bChecked)
	local self = LoopTips;
	self.is_expanded = bChecked;

	-- not display loopwords, only keep vote button, 2012.11.5
	--if(not self.is_expanded)then
        --self.timer:Change();
		--self.expand_timer:Change();
    --else
        --self.timer:Change(10,self.duration);
		--self.expand_timer:Change(200, 200);
    --end
    MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.LoopTipsExpanded", self.is_expanded);

	if(self.page) then
		self.page:Refresh(0);
		if(self.is_expanded)then
			LoopTips.FadeIn()
		else
			LoopTips.FadeOut()
		end
	end
end

-- use clicked the button. 
function LoopTips.OnClickExpandBtn()
	LoopTips.OnCheckExpandBtn(not LoopTips.is_expanded);
end

function LoopTips.GetCurTip()
	local self = LoopTips;
	local tip0 = self.cur_play_node;
	return tip0;
end

--timer callback function
function LoopTips.TimerCallback(timer)
	local self = LoopTips;
	if(self.cur_play_node)then

		self.cur_play_node=LoopTips.GetTip(true)
		self.RefreshPage();
	end
end

function LoopTips.expand_TimerCallback(timer)
	local self = LoopTips;
	if(self.ExpandHasFocus()) then
		self.FadeIn();
	else
		self.FadeOut();
	end
end

function LoopTips.FadeIn()
	if(LoopTips.is_fade_out and LoopTips.page) then
		LoopTips.is_fade_out = false;
		local _parent = LoopTips.page:FindControl("canvas");
		UIAnimManager.ChangeAlpha("Aries.LoopTips", _parent, 255, 512)
		local _parent = LoopTips.page:FindControl("canvas_content");
		UIAnimManager.ChangeAlpha("Aries.LoopTips.content", _parent, 255, 512, nil, false)
	end
end

function LoopTips.FadeOut()
	if(not LoopTips.is_fade_out and LoopTips.page) then
		LoopTips.is_fade_out = true;
		local _parent = LoopTips.page:FindControl("canvas");
		local target_content_alpha = if_else(System.options.version == "teen", 0, 0);
		UIAnimManager.ChangeAlpha("Aries.LoopTips", _parent, 90, 64, 2000)
		local _parent = LoopTips.page:FindControl("canvas_content");
		UIAnimManager.ChangeAlpha("Aries.LoopTips.content", _parent, target_content_alpha, 64, 2000, false)
	end
end

function LoopTips.ExpandHasFocus()
	if(LoopTips.IsShown()) then
		if(LoopTips.is_expanded and not LoopTips.IsEmpty()) then
			local _parent = LoopTips.page:FindControl("canvas_content");
			if(_parent and _parent:IsValid()) then
				local x, y, width, height = _parent:GetAbsPosition();
				local mouseX, mouseY = ParaUI.GetMousePosition();
				if(x<=mouseX and mouseX <= (x+width) and (y-22)<=mouseY and mouseY<(y+height)) then
					return true;
				end
			end
		else
			local _parent = LoopTips.page:FindControl("canvas");
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

--init page ctrl
function LoopTips.OnInit_Teen()
	local self = LoopTips;
	self.page = document:GetPageCtrl();
	LoopTips.OnInit();
	LoopTips.is_expanded = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.LoopTipsExpanded",true)
	-- self.page = pageCtrl;
end

--show tooltip page
function LoopTips.ShowPage(bShow)

	if(not QuestArea.is_inited) then
		return;
	end
	local self = LoopTips;
	--only support teen version

	if(not CommonClientService.IsTeenVersion())then
		return
	end

	if(bShow)then
		local is_combat = Player.IsInCombat();
		if(is_combat)then
			return
		end
		local Player = commonlib.gettable("MyCompany.Aries.Player");
		local key = string.format("MyCardsManager.rightbottomtips_%s",System.User.nid);

		local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
		if (not system_looptip.rightbottom_tip) then
			system_looptip.rightbottom_tip = Player.LoadLocalData(key, false) or false;
		end

		if (system_looptip.rightbottom_tip) then
			return
		end

		System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/Desktop/Dock/LoopTips.teen.html", 
					name = "LoopTips.ShowPage", 
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
						align = "_rb",
						x = -310,
						y = -120,
						width = 310,
						height = 100,
				});
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "LoopTips.ShowPage", app_key=MyCompany.Aries.app.app_key, bShow = false});
	end
end

function LoopTips.IsShown()
	local self = LoopTips;
	if(self.page) then
		return self.page:IsVisible();
	end
end

function LoopTips.RefreshPage()
	local self = LoopTips;
	local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");

	if(self.page)then
		if (not system_looptip.rightbottom_tip) then
			--LOG.std(nil, "debug", "LoopTips", "GetCurTip is %s",  self.GetCurTip());
			self.page:Refresh(0)
			--self.page:SetUIValue("text", self.GetCurTip() or "");
		end
	end
end

function LoopTips.ClosePage()
	local self = LoopTips;
	if(self.page)then
		self.page:CloseWindow();	
	end
end

function LoopTips.IsEmpty()
	local self = LoopTips;
	if(not LoopTips.GetCurTip())then
		return true;
	else
		return false;
	end	
end

function LoopTips.Bounce_Static_Icon(name,page,bounce_or_stop)
	local _icon;
	if(page) then
		_icon = page:FindControl(name);
	end
	if(_icon and _icon:IsValid()) then
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

function LoopTips.BounceLower_Static_Icon(name,page,bounce_or_stop)
	local _icon;
	if(page) then
		_icon = page:FindControl(name);
	end
	if(_icon and _icon:IsValid()) then
		if(bounce_or_stop == "bouncelower") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "BounceLower", true);
		elseif(bounce_or_stop == "stop") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "BounceLower");
		end
	end
end