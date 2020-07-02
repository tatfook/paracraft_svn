--[[
Title: Chat area for teen
Author(s): LiXizhi
Date: 2010/7/20
Desc: chat log and chat input
use the lib:
------------------------------------------------------------
MyCompany.Aries.Combat.UI.BattleChatArea.Show()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatWindow.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatEdit.lua");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local BattleChatArea = commonlib.gettable("MyCompany.Aries.Combat.UI.BattleChatArea");
local ChatWindow = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatWindow");
local ChatEdit = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatEdit");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

local DefaultPos = {
	--RestoreBtn = {alignment = "_lt", left = 0, top = 202, width = 16, height = 20, background = "Texture/Aries/Common/Teen/chat/open_32bits.png;0 0 16 20"},
	RestoreBtn = {alignment = "_lb", left = 0, top = -223+90, width = 16, height = 20, background = "Texture/Aries/Common/Teen/chat/open_32bits.png;0 0 16 20"},
	LogWnd = {alignment = "_fi", left = 0, top = 0, width = 0, height = 25},
	EditWnd = {alignment = "_lb", left = 0, top = -27, width = 320, height = 30},
	ParentWnd = {alignment = "_lb", left = 0, top = -400+90-25, width = 320, height = 200+25+25},
	dragger_top = 49, -- margin top of dragger to the outer parent window
}

-- call this once
function BattleChatArea.DoInit()
	if(BattleChatArea.is_inited) then
		return;
	end
	BattleChatArea.is_inited = true;
	-- the default show positions.
	ChatWindow.DefaultPos = DefaultPos;

	-- init chat system
	ChatWindow.InitSystem();
end

-- this function is called when UI needs to be recreated. 
function BattleChatArea.Create(bDelayCreateUI)
	BattleChatArea.DoInit();
	if(bDelayCreateUI) then
		return;
	end
	
	-- show the chat window
	local is_start_minimized = false;
	if(is_start_minimized) then
		ChatWindow.OnClickWndMinimize(); 
	else
		ChatWindow.Show(true);
	end
end

-- show/hide 
-- virtual function: show/hide the battle area
function BattleChatArea.Show(bShow)
	if(bShow or bShow==nil) then
		ChatWindow.Show();
	else
		ChatWindow.HideAll();
	end
end

-- virtual funciton: Set the UI mode of the battle area, so that it has different display for different mode.
-- @param mode: "tutorial", "combat", "normal", "home"
function BattleChatArea.SetMode(mode)
	local mode_changed;
	if(BattleChatArea.mode ~= mode) then
		BattleChatArea.mode = mode;
		mode_changed = true;
	end
	
	if(mode == "combat") then
		if(mode_changed) then
			local _parentwnd = ChatWindow.CreateGetParentWnd();
			if(_parentwnd.x == 0) then
				local params = ChatWindow.DefaultPos.ParentWnd;
				_parentwnd:Reposition(params.alignment, params.left, params.top-60, params.width, params.height);
			end
			if(TeamClientLogics:IsInTeam()) then
				if(TeamMembersPage.IsExpanded()) then
					TeamMembersPage.ChangeShowState();
				end
			end
		end
		MsgHandler.ShowAutoAIModeBtn(true);
	else
		if(mode_changed) then
			local _parentwnd = ChatWindow.CreateGetParentWnd();
			if(_parentwnd.x == 0) then
				local params = ChatWindow.DefaultPos.ParentWnd;
				_parentwnd:Reposition(params.alignment, params.left, params.top, params.width, params.height);
			end
			if(TeamClientLogics:IsInTeam()) then
				if(not TeamMembersPage.IsExpanded()) then
					TeamMembersPage:ChangeShowState();
				end
			end
		end
		MsgHandler.ShowAutoAIModeBtn(false);
	end
end
