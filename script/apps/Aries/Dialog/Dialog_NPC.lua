--[[
Title: displaying dialog box on NPC character
Author(s): WangTian
Date: 2009/6/24
Desc: global AI related functions.
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/Dialog_NPC.lua");
local Dialog = commonlib.gettable("MyCompany.Aries.Dialog");
Dialog.OnTalkToNearestNPC()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Quest/QuestDialogPage.lua");
local QuestDialogPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDialogPage");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
-- create class
local Dialog = commonlib.gettable("MyCompany.Aries.Dialog");

-- when user pressed the talk key, the NPC within this distance will show the dialog page. 
Dialog.MaxKeyboardTalkDistance = 6;

-- private: function
function Dialog.ShowNPCTalk(npc_id, instance, url, isfromcombopage)
	
	QuestHelp.SayHelloToNPC(npc_id);

	QuestDialogPage.BeforeShowPage(npc_id, instance, nil)
	local provider = QuestClientLogics.GetProvider()
	if(provider and provider.local_is_init and not isfromcombopage)then
		if(QuestDialogPage.HasDialog())then
			QuestDialogPage.ShowPage();
			return
		end
	end
	--local url_talk;
	--if(instance) then
		--url_talk = url.."?npc_id="..npc_id.."&instance="..instance;
	--else
		--url_talk = url.."?npc_id="..npc_id;
	--end
	if(not url or url == "")then return end
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		--url = "script/apps/Aries/Quest/CommonQuestDialog.html?npc_id="..npc_id.."&content="..url, 
		url = url, 
		name = "NPC_Dialog", 
		isShowTitleBar = false,
		--refresh = true,
		refreshEvenSameURLIfFrameExist = true,
		allowDrag = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 2,
		directPosition = true,
			align = "_ctb",
			x = 0,					
			y = 22,
			width = 900,
			height = 230,
			--	x = 41,					
			--	y = 165,
			--	width = 204,
			--	height = 430,
					
		DestroyOnClose = true,
		enable_esc_key = true,
		cancelShowAnimation = true,
	});
end

-- public function. usually called by "Profile.Aries.ShowNPCDialog" command
-- @param params: a table of {npc_id=number, }
function Dialog.ShowNPCDialog(params)
	-- Note 2011.10.7 LiXizhi: maybe we should not HideNPCSelectResponsePage() if there is no dialog to display for this NPC. 
	-- NOTE 2010/10/8: hide the selected response page with explicit function 
	MyCompany.Aries.Desktop.TargetArea.HideNPCSelectResponsePage();
		
	
	local npc_id;
	if(type(params) == "table" and params.npc_id) then	
		npc_id = params.npc_id;
		instance = params.instance;
		local Quest = MyCompany.Aries.Quest;
		local url = Quest.NPC.GetNPCDialogPageURL(npc_id, instance);
		--直接打开一个dialog页面
		if(params.dialog_url)then
			if(npc_id and instance) then	
				url = string.format("%s?npc_id=%d&instance=%d",params.dialog_url,npc_id, instance);
			elseif(npc_id and not instance) then
				url = string.format("%s?npc_id=%d",params.dialog_url,npc_id);
			end
		end
		local state = params.state;
		--NOTE by Leio:url 加了一个state参数
		state = tonumber(state);
		if(url and state)then
			url = string.format("%s&state=%d",url,state);
		end
		LOG.std("", "system", "aries", "------------ ShowNPCTalk with url: %s", url or "nil")
		local pre_func = Quest.NPC.GetPreDialogFunction(npc_id, instance);
		if(pre_func) then
			if(pre_func == "DirectShowQuestDialog")then
				System.App.Commands.Call("Profile.Aries.ShowNPCDialog_Menu",params);
			else
				local func = commonlib.getfield(pre_func);
				if(func) then
					local ret = func(npc_id, instance);
					if(ret ~= false) then
						--if(url) then
							--WaitNPCTalkURL = {url = url, npc_id = npc_id};
							MyCompany.Aries.Quest.QuestHook.Invoke("quest_showpage", npc_id);
							Dialog.ShowNPCTalk(npc_id, instance, url, params.isfromcombopage);
						--end
					end
				end
			end
		else
			if(url) then
				--WaitNPCTalkURL = {url = url, npc_id = npc_id};
				MyCompany.Aries.Quest.QuestHook.Invoke("quest_showpage", npc_id);
				Dialog.ShowNPCTalk(npc_id, instance, url, params.isfromcombopage);
			end
		end
	end
end

-- public function. usually called by "Profile.Aries.ShowNPCDialog_Teen_Native" command
function Dialog.ShowNPCDialog_Teen_Native(params)
	if(type(params) == "table") then	
		local dialog_url = params.dialog_url;
		if(not dialog_url)then return end

		local npc_id = params.npc_id or 0;
		local instance = params.instance or 0;
		local state = params.state or 0;
		local url = string.format("%s?npc_id=%d&instance=%d&state=%d",params.dialog_url,npc_id, instance,state);

		local page_params = {
			url = url, 
			name = "ShowNPCDialog_Teen_Native", 
			isShowTitleBar = false,
			--refresh = true,
			refreshEvenSameURLIfFrameExist = true,
			allowDrag = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			directPosition = true,
			align = "_mb",
			x = 0,
			y = 0,
			width = 0,
			height = 135,
			DestroyOnClose = true,
			enable_esc_key = true,
			cancelShowAnimation = true,
		};
		System.App.Commands.Call("File.MCMLWindowFrame",page_params);
		if(page_params._page) then
			MyCompany.Aries.HandleKeyboard.EnterDialogMode(Dialog.OnKeyDownProc);
			page_params._page.OnClose = function(bDestroy)
				MyCompany.Aries.HandleKeyboard.LeaveDialogMode();
			end
		end
	end
end
function Dialog.OnKeyDownProc(virtual_key,page)
	-- virtual_key == Event_Mapping.EM_KEY_SPACE or 
	if(virtual_key == Event_Mapping.EM_KEY_ENTER or virtual_key == Event_Mapping.EM_KEY_X) then
		--do nothing
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		if(page)then
			page:CloseWindow();
		end
	end
end
-- public function. usually called by "Profile.Aries.ShowNPCDialog_Menu" command
function Dialog.ShowNPCDialog_Menu(params)
	if(type(params) == "table") then	
		local npc_id = params.npc_id or 0;
		local instance = params.instance or 0;
		QuestHelp.SayHelloToNPC(npc_id);

		QuestDialogPage.BeforeShowPage(npc_id, instance, nil)
		local provider = QuestClientLogics.GetProvider()
		if(provider and provider.local_is_init)then
			if(QuestDialogPage.HasDialog())then
				MyCompany.Aries.Quest.QuestHook.Invoke("quest_showpage", npc_id);
				QuestDialogPage.ShowPage();
			end
		end
	end
end

-- this is usually called when user pressed the X key. 
function Dialog.OnTalkToNearestNPC()
	if(Player.IsInCombat()) then
		return;
	end

	local npc_object, npc_id, instance = Player.GetNearestNPC(Dialog.MaxKeyboardTalkDistance);

	if(npc_id) then
		local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
		TargetArea.TalkToNPC(npc_id, instance);
	end
end

local sub_pages = {};

-- @param url: url to show. if nil, previous page will be closed. 
-- @param name: page name. nil to use the default one
function Dialog.ShowTransparentPage(url, name)
	name = name or "Dialog.ShowTransparentPage"
	if(url) then
		local params = {
			url = url, 
			name = name, 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = false,
			allowDrag = false,
			click_through = true,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			cancelShowAnimation = true,
		};
		System.App.Commands.Call("File.MCMLWindowFrame", params);
		sub_pages[name] = true;
	else
		if(sub_pages[name]) then
			sub_pages[name] = nil;
			local params = {
				name = name, 
				app_key=MyCompany.Aries.app.app_key, 
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				bDestroy = true,
			};
			System.App.Commands.Call("File.MCMLWindowFrame", params);
		end
	end
end

-- hide all transparent pages. 
function Dialog.ShowHideAllTransparentPage(bShow)
	local _app = MyCompany.Aries.app._app;
	if(_app) then
		local name, _
		for name, _ in pairs(sub_pages) do
			local _wnd = _app:FindWindow(name);
			if(_wnd) then
				_wnd:ToggleShowHide(bShow, true);
			end
		end
	end
end