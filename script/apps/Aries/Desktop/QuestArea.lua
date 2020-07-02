--[[
Title: quest helper and status buttons
Author(s): WangTian
Date: 2009/4/7
Desc: See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Such as ranking, task list, lobby, mijiuhulu, lobby count down, toggle camera mode, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
MyCompany.Aries.Desktop.QuestArea.Init();
------------------------------------------------------------
]]
-- create class
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");

local libName = "AriesDesktopQuestArea";
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
local LOG = LOG;
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
-- data keeping: kids version only
QuestArea.QuestRootNode = CommonCtrl.TreeNode:new({Name = "QuestRootNode",});

-- invoked at Desktop.InitDesktop()
function QuestArea.Init()
	-- load implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/QuestArea/QuestArea.kids.lua");
		if(System.options.theme == "v2") then
			QuestArea.CreateV2();
		else
			QuestArea.Create();
		end
	else
		NPL.load("(gl)script/apps/Aries/Desktop/QuestArea/QuestArea.teen.lua");
		QuestArea.Create();
	end
	
	QuestArea.is_inited = true;
end

-- virtual function: create UI
function QuestArea.Create()
end

-- public function: show or hide the quest area, toggle the visibility if bShow is nil
function QuestArea.Show(bShow)
	local _questArea = ParaUI.GetUIObject("AriesQuestArea");
	if(_questArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _questArea.visible;
		end
		bShow = bShow and not QuestArea.is_diable_ui
		_questArea.visible = bShow;
		QuestTrackerPane.Show(bShow);
	end
end

-- public function: show or hide the quest area,
function QuestArea.Show3DTracker(bShow)
	-- the kids version do not have a 3d tracker. 
end

local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");
-- virtual function: Desktop window handler
function QuestArea.MSGProc(msg)
	if(msg.type == MSGTYPE.ON_LEVELUP ) then
		local level = msg.level;
		-- TODO: 
	end
end

-- virtual function: fresh the quest area
function QuestArea.Refresh()
end


-- virtual function: 
function QuestArea.ShowQuestListPage()
	QuestClientLogics.ShowQuestListPage()
	if(QuestClientLogics.HasBounced())then
		QuestArea.Bounce_Static_Icon("QuestList","stop")
		QuestClientLogics.has_bounced = false;
	end

	if(not QuestTrackerPane.is_expanded) then
		QuestTrackerPane.DoExpanded(true);
	end
end

-- virtual function: called by the mijiuhulu module to turn on its visibility
function QuestArea.ShowMijiuhulu(show)
end

-- virtual function: called by the mijiuhulu module
function QuestArea.SetMiJiuHuLuTips(tips)
end

-- virtual function: called by the mijiuhulu module
function QuestArea.FlashMiJiuHuLu(bbounce)
end

-- virtual function: 
-- @param name: "MiJiuHuLu", "QuestList", etc
-- @param bounce_or_stop: "stop", "bounce"
function QuestArea.Bounce_Static_Icon(name,bounce_or_stop)
end

----------------------------------------
-- following is kids version only API and can be ignore by teen version. 
---------------------------------------

-- append a feed
-- @param node: feed data node
function QuestArea.AppendFeed(node)
	QuestArea.QuestRootNode:AddChild(CommonCtrl.TreeNode:new(node));
	-- automatically refresh the feed icon count
	QuestArea.RefreshFeedCount();
end

-- refresh request count on every server proxy response
function QuestArea.RefreshFeedCount()
	local countUnread = 0;
	local count = QuestArea.QuestRootNode:GetChildCount();
	local i;
	for i = 1, count do
		local node = QuestArea.QuestRootNode:GetChild(i);
		if(node.bShown ~= true) then
			countUnread = countUnread + 1;
		end
	end
end

-- Kids version only API and obsoleted function
function QuestArea.ShowHeroDragonPage()
end

-- Kids version only API
function QuestArea.ShowDragonCount(count)
end

-- Kids version only API and obsoleted function
function QuestArea.ShowQuestNode(node)
end

-- Kids version only API: if the quest notification shown
function QuestArea.IsNotificationVisible()
	return false;
end

-- Kids version only API: show the medal quest status window
function QuestArea.ShowQuestMedalStatus()
end

-- Kids version only API: show the dragon quest status window
function QuestArea.ShowQuestDragonStatus()
end

-- Kids version only API: show the dragon quest status window
function QuestArea.ShowQuestDragonStatusByUrl(url)
end

-- Kids version only API:
function QuestArea.AppendQuestStatus(page_url, type, icon, title, gsid, priority, position, onclick_callback)
end

-- Kids version only API:
function QuestArea.DeleteQuestStatus(page_url)
end

-- Kids version only API:
function QuestArea.CleanupQuestStatus(type)
end

-- Kids version only API:
function QuestArea.Refresh_QuestCnt(cnt)
end

-- Kids version only API:
function QuestArea.BounceNormalQuestIcon(quest_page_url, bounce_or_stop)
end

-- Kids version only API:
function QuestArea.GetUnreadDragonNotificationCount()
	return 0;
end
-- Kids version only API:
function QuestArea.ShowNormalQuestStatus(page_url)
end

-- Kids version only API:
function QuestArea.FlashQuestNormalIcon(url)
end

-- Kids version only API:
function QuestArea.FlashQuestMedalIcon()
end

-- Kids version only API:
function QuestArea.FlashQuestDragonIcon()
end