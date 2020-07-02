--[[
Title: 
Author(s): Leio
Date: 2011/03/31

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/CreateRoomPage.lua");
local CreateRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.CreateRoomPage");
CreateRoomPage.ShowPage();

NPL.load("(gl)script/apps/Aries/CombatRoom/CreateRoomPage.lua");
local CreateRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.CreateRoomPage");
CreateRoomPage.ShowPage(nil,4)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");

local CreateRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.CreateRoomPage");
CreateRoomPage.templates_list = nil;
CreateRoomPage.templates_list_view = nil;
CreateRoomPage.selected_template = nil;
CreateRoomPage.titles_xml_isloaded = nil;
CreateRoomPage.files_path = "config/Aries/LobbyService/aries.lobby_titles.xml";
CreateRoomPage.titles = { pve = {}, pvp = {}, };
CreateRoomPage.selected_game_type = "PvE";

function CreateRoomPage.GetMenuNode()
	if(CreateRoomPage.world_mode_menu)then
		return CreateRoomPage.world_mode_menu;
	end
	if(System.options.isAB_SDK)then
		CreateRoomPage.world_mode_menu = {
			--{label = "单人模式", mode = 1, },
			{label = "双人挑战", mode = 2, },
			{label = "多人挑战", mode = 3, },
			{label = "英雄挑战", mode = 4, },
			---{label = "炼狱模式", mode = 5, },
		}
	else
		CreateRoomPage.world_mode_menu = {
			--{label = "单人模式", mode = 1, },
			{label = "双人挑战", mode = 2, },
			{label = "多人挑战", mode = 3, },
			--{label = "英雄模式", mode = 4, },
			---{label = "炼狱模式", mode = 5, },
		}
	end
	return CreateRoomPage.world_mode_menu;
end
function CreateRoomPage.GetSelecedMenuNode()
	local world_mode_menu = CreateRoomPage.GetMenuNode();
	local k,v;
	for k,v in ipairs(world_mode_menu) do
		if(v.selected)then
			return v;
		end
	end
end
function CreateRoomPage.GetMenuNodeByMode(mode)
	local world_mode_menu = CreateRoomPage.GetMenuNode();
	local k,v;
	for k,v in ipairs(world_mode_menu) do
		if(v.mode == mode)then
			return k,v;
		end
	end
end
function CreateRoomPage.DoSelecedIndex(index)
	local world_mode_menu = CreateRoomPage.GetMenuNode();
	index = index or 1;
	local k,v;
	for k,v in ipairs(world_mode_menu) do
		if(k == index)then
			v.selected = true;
		else
			v.selected = false;
		end
	end
end
function CreateRoomPage.OnInit()
	local self = CreateRoomPage;
	self.page = document:GetPageCtrl();
end
function CreateRoomPage.DS_Func(index)
	local self = CreateRoomPage;
	if(not self.templates_list_view)then return nil end
	if(index == nil) then
		return #(self.templates_list_view);
	else
		return self.templates_list_view[index];
	end
end
function CreateRoomPage.ClosePage()
	local self = CreateRoomPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
		self.templates_list = nil;
		self.selected_template = nil;
		self.selected_game_type = "PvE";
	end	
end
function CreateRoomPage.OnSelectGame(index)
	local self = CreateRoomPage;
	if(not index or not self.templates_list_view)then return end
	local template = self.templates_list_view[index];
	self.selected_template = template;
	self.selected_index = index;
	self.loots_list = nil;
	if(template)then
		local menu_node = CreateRoomPage.GetSelecedMenuNode();
		if(menu_node)then
			CreateRoomPage.selected_mode_loots_menu = menu_node.mode or 1;
		end
		self.loots_list = LobbyClientServicePage.BuildLootsList(template.keyname,CreateRoomPage.selected_mode_loots_menu);
		local k,v;
		for k,v in ipairs(self.templates_list_view) do
			v.is_selected = nil;
		end
		template.is_selected = true;
		if(self.page)then
			local title = self.page:GetValue("title");
			local leader_text= self.page:GetValue("leader_text");
			local password= self.page:GetValue("password");
			local storm = self.page:GetValue("storm");
			local fire = self.page:GetValue("fire");
			local life = self.page:GetValue("life");
			local death = self.page:GetValue("death");
			local ice = self.page:GetValue("ice");
			
			self.page:Refresh(0);
			self.page:SetValue("title",title);
			self.page:SetValue("leader_text",leader_text);
			self.page:SetValue("password",password);
			self.page:SetValue("storm",storm);
			self.page:SetValue("fire",fire);
			self.page:SetValue("life",life);
			self.page:SetValue("death",death);
			self.page:SetValue("ice",ice);
		end
	else
		self.page:Refresh(0);
	end
end
--更改分类
function CreateRoomPage.UpdateLootsList()
	CreateRoomPage.loots_list = LobbyClientServicePage.BuildLootsList(CreateRoomPage.selected_template.keyname,CreateRoomPage.selected_mode_loots_menu);
end
function CreateRoomPage.GetRandomTitle()
	local self = CreateRoomPage;
	local game_type = self.selected_game_type or "PvE";
	if(not self.titles_xml_isloaded)then
		self.titles_xml_isloaded = true;
		local xmlRoot = ParaXML.LuaXML_ParseFile(self.files_path);
		if(not xmlRoot) then
			LOG.std(nil, "info", "CreateRoomPage.GetRandomTitle", "failed loading config file %s", self.files_path);
		else
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "//items/pvp/item") do
				local label = node.attr.label;
				table.insert(self.titles.pvp,label);
			end
			for node in commonlib.XPath.eachNode(xmlRoot, "//items/pve/item") do
				local label = node.attr.label;
				table.insert(self.titles.pve,label);
			end
		end	
	end
	local t = self.titles.pve;
	if(game_type == "PvP")then
		t = self.titles.pvp;
	end
	local len = #t;
	if(len > 0)then
		local index = math.random(len);
		return t[index];
	end
end

function CreateRoomPage.IncludeMode(mode_list,mode)
	if(mode_list and mode)then
		local k,v;
		for k,v in ipairs(mode_list) do
			if(v.mode == mode)then
				return true;
			end
		end
	end
end
function CreateRoomPage.DoFilterByMode()
	if(CreateRoomPage.templates_list)then
		local menu_node = CreateRoomPage.GetSelecedMenuNode();
		if(menu_node)then
			local mode = menu_node.mode;
			local result = {};
			local k,v;
			for k,v in ipairs(CreateRoomPage.templates_list) do
				local mode_list = LobbyClient:LoadModeList(v.keyname);
				if(CreateRoomPage.IncludeMode(mode_list,mode))then
					table.insert(result,v);
				end
			end
			CreateRoomPage.templates_list_view = result;
		end
	end
end
function CreateRoomPage.DumpWorldName()
	CreateRoomPage.LoadTemplates();
	if(CreateRoomPage.templates_list)then
		local str = "";
		local k,v;
		for k,v in ipairs(CreateRoomPage.templates_list) do
			if(k == 1)then
				str = string.format("%d %s %s %d-%d",k,v.name or "",v.worldname or "",v.min_level or 0,v.max_level or 0);
			else
				str = string.format("%s\r\n%d %s %s %d-%d",str,k,v.name or "",v.worldname or "",v.min_level or 0,v.max_level or 0);
			end
		end
		local file_name = "worldname.txt";
		local file = ParaIO.open(file_name, "w");
		if(file:IsValid()) then
			file:WriteString(str);
			file:close();
		end
	end
end
function CreateRoomPage.LoadTemplates()
	local self = CreateRoomPage;
	local game_type = self.selected_game_type or "PvE";
	local combat_level = LobbyClient:GetMyCombatLevel()
	local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, game_type, true);
	local game_templates = LobbyClient:GetGameTemplates();
	if(game_key_array and game_templates)then
		self.templates_list = {};
		local k,v; 
		for k,v in pairs(game_templates) do
			local __,keyname;
			for __,keyname in ipairs(game_key_array) do
				local hide_from_createpage = v.hide_from_createpage;
				--是否在客户端隐藏
				if(not hide_from_createpage)then
					if(v.keyname == keyname)then
						table.insert(self.templates_list,v);
					end
				end
			end
		end
		table.sort(self.templates_list,function(a,b)
			if(a.min_level and b.min_level and a.min_level < b.min_level)then
				return true;
			end
		end);
	end
end
function CreateRoomPage.ShowPage(game_type,mode)
	local self = CreateRoomPage;
	--if(AntiIndulgenceArea.IsAntiSystemIsEnabled()) then
		--game_type = "PvP";
	--end
	self.selected_game_type = game_type or "PvE";
	self.LoadTemplates();
	if(CommonClientService.IsTeenVersion())then
		if(mode)then
			local index = CreateRoomPage.GetMenuNodeByMode(mode) or 1;
			CreateRoomPage.DoSelecedIndex(index);
		else
			CreateRoomPage.DoSelecedIndex(1);
		end
		CreateRoomPage.DoFilterByMode();
	else
		CreateRoomPage.templates_list_view = CreateRoomPage.templates_list;
	end
	local url = "script/apps/Aries/CombatRoom/CreateRoomPage.html";
	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/CombatRoom/Teen/CreateRoomPage.v2.teen.html";
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "CreateRoomPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -950/2,
				y = -550/2,
				width = 950,
				height = 550,
		});
	local title = self.GetRandomTitle();
	if(self.page)then
		self.page:SetValue("title",title);
	end
	self.OnSelectGame(1);
end
function CreateRoomPage.ShowPage_Mode(keyname)
	local self = CreateRoomPage;
	self.mode_list = LobbyClientServicePage.LoadModeList(keyname);
	local url;
	if(not CommonClientService.IsTeenVersion())then
		url = string.format("script/apps/Aries/CombatRoom/PvEModeSelectPage.html?keyname=%s",keyname);
	else
		url = string.format("script/apps/Aries/CombatRoom/Teen/PvEModeSelectPage.teen.html?keyname=%s",keyname);
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "CreateRoomPage.ShowPage_Mode", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -400/2,
				y = -300/2,
				width = 400,
				height = 300,
		});
end
--更改副本难度
function CreateRoomPage.ShowPage_ResetMode(gameid,mode,game_type,keyname)
	local self = CreateRoomPage;
	self.mode_list = LobbyClientServicePage.LoadModeList(keyname) or {};
	gameid = gameid or -1;
	mode = mode or 1;
	game_type = game_type or "PvE";
	local k,v;
    for k,v in ipairs(self.mode_list) do
        if(v.mode == mode)then
            v.is_checked = true;
        else
            v.is_checked = false;
        end
    end
	local url;
	if(not CommonClientService.IsTeenVersion())then
		url = string.format("script/apps/Aries/CombatRoom/PvEModeSelectPage.html?pagestate=reset&gameid=%d&mode=%d&game_type=%s&keyname=%s",gameid,mode,game_type,keyname);
	else
		url = string.format("script/apps/Aries/CombatRoom/Teen/PvEModeSelectPage.teen.html?pagestate=reset&gameid=%d&mode=%d&game_type=%s&keyname=%s",gameid,mode,game_type,keyname);
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "CreateRoomPage.ShowPage_ResetMode", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = false,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -400/2,
				y = -300/2,
				width = 400,
				height = 300,
		});
end
function CreateRoomPage.Refresh_ResetModePage(sec)
	local self = CreateRoomPage;
	self.temp_sec = sec or 0;
	if(self.reset_mode_page)then
		self.reset_mode_page:Refresh(0);
	end
end
function CreateRoomPage.Close_ResetModePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "CreateRoomPage.ShowPage_ResetMode", app_key=MyCompany.Aries.app.app_key, bShow = false,bDestroy = true,});
end
function CreateRoomPage.OnInit_ResetModePage()
	local self = CreateRoomPage;
	self.reset_mode_page = document:GetPageCtrl();
end
