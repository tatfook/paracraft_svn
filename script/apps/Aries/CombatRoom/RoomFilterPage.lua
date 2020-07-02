--[[
Title: 
Author(s): Leio
Date: 2011/04/04

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/RoomFilterPage.lua");
local RoomFilterPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomFilterPage");
RoomFilterPage.ShowPage();
commonlib.echo(RoomFilterPage.rooms_list);

NPL.load("(gl)script/apps/Aries/CombatRoom/RoomFilterPage.lua");
local RoomFilterPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomFilterPage");
local array = RoomFilterPage.LoadLocalData()
commonlib.echo(array);

NPL.load("(gl)script/apps/Aries/CombatRoom/RoomFilterPage.lua");
local RoomFilterPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomFilterPage");
RoomFilterPage.SaveLocalData("PvE",nil)
RoomFilterPage.SaveLocalData("PvP",nil)


------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
local RoomFilterPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomFilterPage");
RoomFilterPage.rooms_list = nil;
RoomFilterPage.unchecked_list = nil;
RoomFilterPage.game_type = nil;
function RoomFilterPage.OnInit()
	local self = RoomFilterPage;
	self.page = document:GetPageCtrl();
end
function RoomFilterPage.DS_Func_Items(index)
	local self = RoomFilterPage;
	if(not self.rooms_list)then return 0 end
	if(index == nil) then
		return #(self.rooms_list);
	else
		return self.rooms_list[index];
	end
end
function RoomFilterPage.ClearData()
	local self = RoomFilterPage;
	self.unchecked_list = nil;
end
function RoomFilterPage.ClosePage()
	local self = RoomFilterPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end	
end
function RoomFilterPage.ShowPage(game_type,x,y)
	local self = RoomFilterPage;
	game_type = game_type or "PvE";
	self.game_type = game_type;
	local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, game_type, true);
	local game_templates = LobbyClient:GetGameTemplates();
	local unchecked_list = RoomFilterPage.GetUncheckedArray(game_type);
	if(game_key_array and game_templates)then
		self.rooms_list = {};
		local k,v; 
		for k,v in pairs(game_templates) do
			local __,keyname;
			for __,keyname in ipairs(game_key_array) do
				if(v.keyname == keyname)then
					local checked = true;
					if(unchecked_list and unchecked_list[v.keyname])then
						checked = false;
					end
					v.checked = checked;
					table.insert(self.rooms_list,v);
				end
			end
		end
		table.sort(self.rooms_list,function(a,b)
			local a_level = a.min_level;
			local b_level = b.min_level;
			--if(a.worldname == "Wild_Boss_World")then
				--a_level = 1000;
			--end
			--if(b.worldname == "Wild_Boss_World")then
				--b_level = 1000;
			--end
			if(a_level and b_level and a_level < b_level)then
				return true;
			end
		end);
	end
	local url = "script/apps/Aries/CombatRoom/RoomFilterPage.html";
	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/CombatRoom/Teen/RoomFilterPage.teen.html";
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "RoomFilterPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			is_click_to_close = true,
			allowDrag = false,
			directPosition = true,
				align = "_lt",
				x = x or 0,
				y = y or 0,
				width = 240,
				height = 370,
		});
end
--是否选择全部
function RoomFilterPage.DoCheckAll(bCheckAll)
	local self = RoomFilterPage;
	local unchecked_list = self.GetUncheckedArray(game_type) or {};
	self.unchecked_list = self.unchecked_list or {};
	if(self.rooms_list)then
		local k,template;
		for k,template in ipairs(self.rooms_list) do
			if(bCheckAll)then
				template.checked = true;
				unchecked_list[template.keyname] = nil;
			else
				template.checked = nil;
				unchecked_list[template.keyname] = true;
			end
			
		end
		self.SaveLocalData(self.game_type,unchecked_list);
		if(self.page)then
			self.page:Refresh(0);
		end
		LobbyClientServicePage.RefreshPage();
	end
end
function RoomFilterPage.DoCheck(index)
	local self = RoomFilterPage;
	index = tonumber(index);
	local unchecked_list = self.GetUncheckedArray(game_type) or {};
	self.unchecked_list = self.unchecked_list or {};
	if(index and self.rooms_list and self.rooms_list[index] and self.page)then
		local template = self.rooms_list[index];
		if(template.checked)then
			template.checked = nil;
			unchecked_list[template.keyname] = true;
		else
			template.checked = true;
			unchecked_list[template.keyname] = nil;
		end
		self.SaveLocalData(self.game_type,unchecked_list);
		self.page:Refresh(0);
		LobbyClientServicePage.RefreshPage();
	end
end
function RoomFilterPage.LoadLocalData(game_type)
	local self = RoomFilterPage;
	local nid = tostring(Map3DSystem.User.nid);
	local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local game_type = game_type or "PvE";
	local key = string.format("RoomFilterPage.LoadLocalData_%s_s_%s",nid,date,game_type);
	local v = MyCompany.Aries.Player.LoadLocalData(key, { is_none = true, });
	return v;
end
function RoomFilterPage.SaveLocalData(game_type,v)
	local self = RoomFilterPage;
	local nid = tostring(Map3DSystem.User.nid);
	local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local game_type = game_type or "PvE";
	local key = string.format("RoomFilterPage.LoadLocalData_%s_s_%s",nid,date,game_type);
	if(v)then
		v.is_none = nil;
	end
	MyCompany.Aries.Player.SaveLocalData(key, v or { is_none = true, });
end
function RoomFilterPage.SetUncheckedArray(game_type,v)
	local self = RoomFilterPage;
	self.SaveLocalData(game_type,v);
end
function RoomFilterPage.GetUncheckedArray(game_type,pve_include_max_level)
	local self = RoomFilterPage;
	local v = self.LoadLocalData(game_type);
	if(v.is_none)then
		local combat_level = LobbyClient:GetMyCombatLevel()
		local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, game_type, true);
		local right_game_key_array = LobbyClient:GetGameKeysByUserLevel(combat_level, game_type, true,pve_include_max_level);
		local game_templates = LobbyClient:GetGameTemplates();
		--获取当天filter list
		local unchecked_list = {};
		local k,v;
		for k,v in ipairs(game_key_array) do
			local kk,vv;
			unchecked_list[v] = true;
			for kk,vv in ipairs(right_game_key_array) do
				if(v == vv)then
					unchecked_list[v] = false;
					break;
				end
			end
		end
		return unchecked_list;
	else
		return v;
	end
end