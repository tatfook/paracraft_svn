--[[
Title: Quest List window
Author(s): WangTian
Date: 2008/12/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Quest/Quest_ListWnd.lua");
MyCompany.Aquarius.Quest_ListWnd.Init()
------------------------------------------------------------
]]

-- create class
local libName = "Quest_ListWnd";
local Quest_ListWnd = {};
commonlib.setfield("MyCompany.Aquarius.Quest_ListWnd", Quest_ListWnd);

local Quest = MyCompany.Aquarius.Quest;

-- init the quest list window
function Quest_ListWnd.Init()
	-- init window object
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("QuestList") or _app:RegisterWindow("QuestList", nil, Quest_ListWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 300, -- initial width of the window client area
		initialHeight = 400, -- initial height of the window client area
		
		initialPosX = 50,
		initialPosY = 150,
		
		isPinned = true,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = function () do return end end,
	};
	
	sampleWindowsParam.text = "任务列表";
	
	--local text, icon, shortText = self:GetTextAndIcon();
	--sampleWindowsParam.text = text;
	----sampleWindowsParam.icon = icon;
	
	local frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	--frame:Show2(true, nil, true);
end

function Quest_ListWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		local _app = MyCompany.Aquarius.app._app;
		local _wnd = _app:FindWindow("QuestList");
		if(_wnd ~= nil) then
			_wnd:ShowWindowFrame(false);
		end
	end
end

-- show the quest list window
-- quest list window frame object is inited in Aquarius Quest.Init(), client area includes two fields: quest list and quest details
-- quest list consists of all the quest incompleted and completed, no including the quest avaiable and rewarded
--		although the quest log will record all the quest details that the user experienced during the current login session
-- quest details will invoke MyCompany.Aquarius.Quest_DetailsWnd.DetailPage(), the quest detail shows exactly the same as the user accept the quest
function Quest_ListWnd.Show()
	-- we don't allow the quest list and quest dialog display together so we first end the current quest dialog session
	System.Quest.Client.QuestgiverBye();
	
	local _client;
	local frame;
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("QuestList");
	if(_wnd ~= nil) then
		frame = _wnd:GetWindowFrame();
		if(frame ~= nil) then
			_client = frame:GetWindowClientUIObject();
			if(_client == nil or _client:IsValid() == false) then
				-- silent init the frame object and get the client again
				frame:Show2(true, nil, true);
				_client = frame:GetWindowClientUIObject();
			end
		end
	end
	if(_client == nil or _client:IsValid() == false) then
		log("error getting client ui object in Quest_ListWnd.Show\n");
		return;
	end
	
	ParaUI.Destroy("Quest_ListWnd");
	
	-- list window
	local _listWnd = ParaUI.CreateUIObject("container", "Quest_ListWnd", "_fi", 0, 0, 0, 0);
	--_listWnd.background = "";
	_client:AddChild(_listWnd);
	
	-- quest details
	local _details = ParaUI.CreateUIObject("container", "Quest_ListWnd_Details", "_fi", 0, 24*5, 0, 0);
	--_details.background = "";
	_listWnd:AddChild(_details);
	
	-- list treeview
	if(CommonCtrl.GetControl("Quest_List") ~= nil) then
		--CommonCtrl.GetControl("Quest_List"):Destroy();
		CommonCtrl.DeleteControl("Quest_List");
	end
	
	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.GetControl("Quest_List");
	if(ctl == nil) then
		ctl = CommonCtrl.TreeView:new{
			name = "Quest_List",
			alignment = "_lt",
			left = 0,
			top = 0,
			width = 300,
			height = 24 * 5,
			parent = _listWnd,
			--container_bg = "",
			DefaultIndentation = 5,
			DefaultNodeHeight = 24,
			VerticalScrollBarStep = 24,
			VerticalScrollBarPageSize = 24 * 6,
			-- lxz: this prevent clipping text and renders faster
			NoClipping = false,
			HideVerticalScrollBar = false,
			DrawNodeHandler = function (_parent, treeNode)
				if(_parent == nil or treeNode == nil) then
					return;
				end
				
				if(Quest_ListWnd.FocusedQuest == treeNode.quest_id) then
					local _title = ParaUI.CreateUIObject("button", "Title", "_fi", 0, 0, 0, 0);
					--_title.background = "";
					_title.onclick = ";MyCompany.Aquarius.Quest_ListWnd.OnClickQuest("..treeNode.quest_id..");";
					_parent:AddChild(_title);
				elseif(Quest_ListWnd.FocusedQuest ~= treeNode.quest_id) then
					local _title = ParaUI.CreateUIObject("button", "Title", "_fi", 0, 0, 0, 0);
					_title.background = "";
					_title.onclick = ";MyCompany.Aquarius.Quest_ListWnd.OnClickQuest("..treeNode.quest_id..");";
					_parent:AddChild(_title);
				end
				
				local _text = ParaUI.CreateUIObject("text", "Title", "_lt", 16, 4, 200, 12);
				_text.text = treeNode.Title;
				_text.enabled = false;
				_parent:AddChild(_text);
				if(treeNode.status == 1) then -- QUEST_STATUS_COMPLETE
					local _text = ParaUI.CreateUIObject("text", "Title", "_rt", -40, 4, 40, 12);
					_text.text = "(完成)";
					_text.enabled = false;
					_parent:AddChild(_text);
				elseif(treeNode.status == 3) then -- QUEST_STATUS_INCOMPLETE
					
				end
			end,
		};
	end
	local i, quest;
	for i, quest in pairs(System.Quest.Client.Log) do
		-- NOTE: don't log the avaiable quest
		if(quest.status == 3 or quest.status == 1) then -- QUEST_STATUS_INCOMPLETE or QUEST_STATUS_COMPLETE
			ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({
				quest_id = quest.quest_id, 
				Title = quest.Title, 
				status = quest.status,
				focused = true,
				}));
		end
	end
	
	ctl:Show();
	Quest_ListWnd.OnClickQuest();
	ctl:Update();
	
	frame:Show2();
end

-- click quest item on questlist
-- @param quest_id: the quest_id in quest log
--		if nil it will show the first quest on the list and set the current focus quest to the first quest in the log
-- NOTE: the quest log records every quest details including the quest avaiable but the user didn't accept
--		quest list only shows the quest that is completed and imcompleted
function Quest_ListWnd.OnClickQuest(quest_id)
	-- assign quest_id, 
	-- if current focused quest_id is still in quest list, keep the current quest id
	-- if current focused quest_id is nil or already deleted from the quest log, assign the first quest id in log
	if(quest_id == nil) then
		local i, quest;
		for i, quest in pairs(System.Quest.Client.Log) do
			if(Quest_ListWnd.FocusedQuest == quest.quest_id) then
				quest_id = Quest_ListWnd.FocusedQuest;
				break;
			end
		end
		if(quest_id == nil) then
			for i, quest in pairs(System.Quest.Client.Log) do
				if(quest.status == 3 or quest.status == 1) then -- QUEST_STATUS_INCOMPLETE or QUEST_STATUS_COMPLETE
					quest_id = quest.quest_id;
					break;
				end
			end
		end
	end
	if(quest_id == nil) then
		return;
	end
	
	Quest_ListWnd.FocusedQuest = quest_id;
	local ctl = CommonCtrl.GetControl("Quest_List");
	if(ctl ~= nil) then
		ctl:Update();
	end
	local quest = System.Quest.Client.Log[quest_id];
	
	local _details = ParaUI.GetUIObject("Quest_ListWnd_Details");
	if(_details:IsValid() == false) then
		return;
	end
	if(quest == nil) then
		return;
	end
	
	-- remove all previous items
	_details:RemoveAll();
	
	MyCompany.Aquarius.Quest_DetailsWnd.DetailPage(_details, quest.NPC_id, quest.quest_id, quest.Title, 
			quest.Details, quest.Objectives, quest.Requires, quest.RewItems, quest.RewOrReqMoney)
end