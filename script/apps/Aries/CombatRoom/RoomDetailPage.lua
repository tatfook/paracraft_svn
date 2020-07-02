--[[
Title: 
Author(s): Leio
Date: 2011/04/01

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/RoomDetailPage.lua");
local RoomDetailPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomDetailPage");
RoomDetailPage.RefreshPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

local RoomDetailPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomDetailPage");
RoomDetailPage.player_list = nil;
RoomDetailPage.game_info = {};
function RoomDetailPage.OnInit()
	local self = RoomDetailPage;
	self.page = document:GetPageCtrl();
end
function RoomDetailPage.AutoChangeMode()
	local self = RoomDetailPage;
	if(self.game_info)then
		if(self.game_info.game_type == "PvE")then
			local cur_mode = self.game_info.mode;
			local nid = tostring(System.User.nid);
			local owner_nid = self.game_info.owner_nid or "";
			local keyname = self.game_info.keyname;
			local mode_list = LobbyClientServicePage.LoadModeList(keyname) or {};
			local len = #mode_list;
			if(nid == owner_nid and len > 1)then
				local mode = 1;
				local player_count = self.game_info.player_count or 0;
				local max_players = 4;
				if(player_count == 1)then
					mode = 1;
				elseif(player_count > 1 and player_count < max_players)then
					mode = 2;
				elseif(player_count >= max_players)then
					mode = 3;
				end
				if(cur_mode ~= mode)then
					 local game = {
						id = self.game_info.id,
						mode = mode,
					}
					LobbyClientServicePage.DoResetGameMode(game)
				end
			end
		end
	end
end


function RoomDetailPage.IsFull_RecommendPlayers()
	local self = RoomDetailPage;
	if(self.game_info)then
		local modelist = LobbyClientServicePage.LoadModeList(self.game_info.keyname);
		local node = LobbyClient:GetModeNode(modelist,self.game_info.mode);
		if(node)then
			local max_players = node.recommend_players or self.game_info.max_players or 4;
			local player_count = self.game_info.player_count or 0;
			if(player_count >= max_players)then
				return true;
			end
		end
		
	end
end
--人数已满
function RoomDetailPage.IsFull()
	local self = RoomDetailPage;
	if(self.game_info)then
		local max_players = self.game_info.max_players or 4;
		local player_count = self.game_info.player_count or 0;
		if(player_count >= max_players)then
			return true;
		end
	end
end
function RoomDetailPage.GetPlayerList()
	local self = RoomDetailPage;
	if(self.game_info and self.game_info.players)then
		local nid = tostring(System.User.nid);
		self.player_list = {};
		local k,v;
		for k,v in pairs(self.game_info.players) do
			if(v.nid == self.game_info.owner_nid)then
				v.p = 1
			else
				v.p = 0;
			end
			table.insert(self.player_list,v);
		end
		local pagesize = 4;
		local len = #self.player_list;
		local n = math.mod(len,pagesize);
		if(n ~= 0)then
			local k;
			for k = len + 1, len + (pagesize - n) do
				self.player_list[k] = {nid = -1,};
			end
		end
		table.sort(self.player_list,function(a,b)
			if(a.p and b.p)then
				return a.p  >  b.p;
			elseif(a.p or b.p)then
				return a.p ~= nil;
			end
		end)
		return self.player_list;
	end
end
function RoomDetailPage.HookHandler(nCode, appName, msg, value)
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		RoomDetailPage.RefreshPage()
	end
	return nCode;
end
--从缓存获取数据
function RoomDetailPage.RefreshPage()
	local self = RoomDetailPage;
	local login_room_id = LobbyClientServicePage.GetRoomID();
	if(not login_room_id)then
		RoomDetailPage.ClosePage();
		return
	end
	if(self.page)then
	
		LobbyClient:GetGameDetail(login_room_id, true, function(result)
				if(result and result.formated_data) then
					local game_info = result.formated_data;
					self.game_info = game_info;
					LobbyClientServicePage.game_info = self.game_info;
					RoomDetailPage.selected_mode_loots_menu = game_info.mode;
					self.loots_list = LobbyClientServicePage.BuildLootsList(game_info.keyname,game_info.mode);
					if(game_info and game_info.players)then
						local nid = tostring(System.User.nid);
						local has_player = game_info.players[nid];
						local mode = game_info.mode;
						local keyname = game_info.keyname;

						NPL.load("(gl)script/apps/Aries/Login/WorldAssetPreloader.lua");
						local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")
						WorldAssetPreloader.StartWorldPreload(game_info.worldname)

						self.mode_list = LobbyClientServicePage.LoadModeList(keyname) or {};
						local k,v;
						for k,v in ipairs(self.mode_list) do
							if(v.mode== mode)then
								v.is_checked = true;
							else
								v.is_checked = false;
							end
						end
						--如果已经在一个房间里面，刷新房间
						if(has_player)then
							self.GetPlayerList();
							--self.AutoChangeMode();
							if(self.page)then
								self.page:Refresh(0.1);
							end
						else
							self.ClosePage();
							RoomDetailPage.ResetRoom();
						end
					else
						self.ClosePage();
						RoomDetailPage.ResetRoom();
					end
				else
					self.ClosePage();
					RoomDetailPage.ResetRoom();
				end
		end,true)
	end
end
function RoomDetailPage.ResetRoom()
	LobbyClientServicePage.SetRoomID(nil);
	EXPBuffArea.Update_LobbyBtn();
end
--更改分类
function RoomDetailPage.UpdateLootsList()
	if(RoomDetailPage.game_info)then
		RoomDetailPage.loots_list = LobbyClientServicePage.BuildLootsList(RoomDetailPage.game_info.keyname,RoomDetailPage.selected_mode_loots_menu);
	end
end
function RoomDetailPage.ClosePage()
	local self = RoomDetailPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end	
	self.game_info = {};
	self.player_list = nil;
end

-- leave the current room and close the page if any. 
function RoomDetailPage.LeaveAndClose(game_id)
	if(not game_id) then
		if(RoomDetailPage.game_info) then
			game_id = RoomDetailPage.game_info.id;
		end
		game_id = game_id or LobbyClientServicePage.GetRoomID();
	end
	if(game_id) then
		LobbyClientServicePage.DoLeaveGame(game_id)
		RoomDetailPage.ClosePage();
	end
end

function RoomDetailPage.DS_Func(index)
	local self = RoomDetailPage;
	if(not self.player_list)then return 0 end
	if(index == nil) then
		return #(self.player_list);
	else
		return self.player_list[index];
	end
end
function RoomDetailPage.ShowPage()
	local self = RoomDetailPage;
	local login_room_id = LobbyClientServicePage.GetRoomID();
	if(not login_room_id)then return end
	local url = "script/apps/Aries/CombatRoom/RoomDetailPage.html";
	local width = 880;
	local height = 575;

	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/CombatRoom/Teen/RoomDetailPage.v2.teen.html";
		width = 950;
		height = 550;
	end
	RoomDetailPage.temp_tip_mode = nil;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "RoomDetailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 0,
			isTopLevel = false,
			allowDrag = false,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -width/2,
				y = -height/2,
				width = width,
				height = height,
		});
	self.RefreshPage();
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = RoomDetailPage.HookHandler, 
		hookName = "Hook_RoomDetailPage", appName = "Aries", wndName = "main"});
end
function RoomDetailPage.DoMenu(node)
	local self = RoomDetailPage;
	if(not node or not node.state or not node.nid)then return end
	local state = node.state;
	local nid = node.nid;
	if(state == "chat")then
    System.App.Commands.Call("Profile.Aries.ChatWithFriendImmediate", {nid = nid});
	elseif(state == "friend")then
		MyCompany.Aries.Friends.AddFriendByNIDWithUI(nid);
	elseif(state == "info")then
		System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
	elseif(state == "comehere")then
		System.App.Commands.Call("Profile.Aries.ComeHere", { nids = {nid}});
	end
end

function RoomDetailPage.isPvE()
	local game_info = RoomDetailPage.game_info or {};
    if(game_info.game_type == "PvE")then
        return true;
    end
end
function RoomDetailPage.isPvP()
	local game_info = RoomDetailPage.game_info or {};
    if(game_info.game_type == "PvP")then
        return true;
    end
end

function RoomDetailPage.doStartGame()
	local game_info = RoomDetailPage.game_info or {};
    
    local s;

	local match_method;
	local template = LobbyClientServicePage.GetGameTemplateByKeyName(game_info.keyname);
	if(template)then
		match_method = template.match_method;
	end

    if(RoomDetailPage.isPvE())then
		if(RoomDetailPage.IsFull_RecommendPlayers())then
			--s = "确认要全体出发吗？";
			LobbyClientServicePage.DoStartGame(game_info.id,game_info.game_type,function()
                RoomDetailPage.ClosePage();
            end)
			return
		else
			s = [[<div><span style="color:#ff0000">人数不够</span>，挑战难度较大，你确认要出发吗？</div>]];
		end
    elseif(RoomDetailPage.isPvP())then
        if(match_method == "simple")then
            s = "排队时系统会为你随机找对手<br/>可能需要1-10分钟！";
        else
            s = "排队时系统会为你找积分和等级最接近的对手，可能需要1-10分钟！";
        end
    end

	NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
    _guihelper.Custom_MessageBox(s,function(result)
	    if(result == _guihelper.DialogResult.Yes)then
		   LobbyClientServicePage.DoStartGame(game_info.id,game_info.game_type,function()
                RoomDetailPage.ClosePage();
            end)
	    end
    end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
    
end