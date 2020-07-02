--[[
Title: The 3D Map System MainBar Data
Author(s): WangTian
Date: 2007/9/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemData/MainBarData.lua");
------------------------------------------------------------

]]

NPL.load("(gl)script/kids/3DMapSystemData/TableDef.lua");

commonlib.echo("\nMainBarData obsoleted code run\n\n")

NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Creation.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Modify.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Property.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Sky.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Water.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Terrain.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Possession.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Delete.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/NavMode.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Chat.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Map.lua");
-- TODO: remove KidsMovieOriginal completely
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/KidsMovieOriginal.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Profile.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Hints.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Status.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Setting.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Exit.lua");

---- main bar UI information
Map3DSystem.UI.MainBar.IconSize = 48;
Map3DSystem.UI.MainBar.IconHeightOffset = 16;
Map3DSystem.UI.MainBar.BarBGHeight = 64; -- IconSize + IconHeightOffset
Map3DSystem.UI.MainBar.BarBGWidthAdditional = 32;
--Map3DSystem.UI.MainBar.PanelBGWidthAdditional = 32;
--Map3DSystem.UI.MainBar.BarSideBGWidth = 64;
--Map3DSystem.UI.MainBar.PanelSideBGWidth = 128;

Map3DSystem.UI.MainBar.SeparatorWidth = 8;
Map3DSystem.UI.MainBar.SeparatorBG = "Texture/3DMapSystem/Separator.png";

Map3DSystem.UI.MainBar.SubIconSize = 48;
Map3DSystem.UI.MainBar.SubIconNameHeight = 24;
Map3DSystem.UI.MainBar.SubIconNameSideWidth = 2;
Map3DSystem.UI.MainBar.SubIconNameWidthToSubIcon = 2;
Map3DSystem.UI.MainBar.SubIconNameBG = "Texture/3DMapSystem/SubIconTextBG.png";

-- TODO: at least *** icons
	

Map3DSystem.UI.MainBar.Status = "none";

Map3DSystem.UI.Chat.IsShow = false;
Map3DSystem.UI.Map.IsShow = false;
Map3DSystem.UI.KidsMovieOriginal.IsShow = false;
Map3DSystem.UI.Profile.IsShow = false;
Map3DSystem.UI.Hints.IsShow = true;
Map3DSystem.UI.Status.IsShow = false;
Map3DSystem.UI.Setting.IsShow = false;
Map3DSystem.UI.Exit.IsShow = false;

Map3DSystem.UI.NavMode.CurrentMode = "object";

Map3DSystem.UI.MainBar.AnimatableUIObjects = {
	BarLeft = nil,
	BarMiddle = nil,
	BarRight = nil,
	IconSet = {
		[1] = nil,
		[2] = nil,
		[3] = nil,
		[4] = nil, -- sample
		},
	};

Map3DSystem.UI.MainBar.AnimationBarSequence =
	{
		IsReady = false,
		FrameNum = 8,
		CurrentFrame = 1,
		[1] = 
			{
			["left"] = 
				{
				x = 10, -- sample
				y = 10, -- sample
				width = 10, -- sample
				height = 10, -- sample
				alpha = 10, -- sample
				visible = true, -- sample
				enabled = true, -- sample
				},
			["middle"] = {},
			["right"] = {},
			},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
	};
Map3DSystem.UI.MainBar.AnimationIconSetSequence = 
	{
		["IconSet1"] = 
			{
			IsReady = false,
			FrameNum = 8,
			CurrentFrame = 1,
			[1] = {
				x = 10, -- sample
				y = 10, -- sample
				width = 10, -- sample
				height = 10, -- sample
				alpha = 10, -- sample
				visible = true, -- sample
				enabled = true, -- sample
				},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {},
			},
		--["IconSet2"] = {}, -- ...
		--["IconSet3"] = {}, -- ...
	};

Map3DSystem.UI.MainBar.IconSet[1] = 
	{
		name = "Creator";
		group = "Applications";
		ShowIcon = true;
		ToolTip = L"Creation";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Creation.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Creation_3.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/creation_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/creation_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Creation.ShowUI;
		CloseUICallback = Map3DSystem.UI.Creation.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Creation.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Creation.OnMouseLeave;
		--SubIconSet = {
			--[1] = {
				--Name = "Normal object";
				--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Creation_5.png";
				--ClickCallback = Map3DSystem.UI.Creation.OnClickSubIconSet;
				--},
			--[2] = {
				--Name = "Normal character";
				--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Profile_1.png";
				--ClickCallback = Map3DSystem.UI.Creation.OnClickSubIconSet;
				--},
			--[3] = {
				--Name = "BCS";
				--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Creation_4.png";
				--ClickCallback = Map3DSystem.UI.Creation.OnClickSubIconSet;
				--},
			--[4] = {
				--Name = "CCS";
				--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Wishlist_1.png";
				--ClickCallback = Map3DSystem.UI.Creation.OnClickSubIconSet;
				--},
			--[5] = {
				--Name = "Favorite";
				--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Favorite_8.png";
				--ClickCallback = Map3DSystem.UI.Creation.OnClickSubIconSet;
				--},
			--[6] = {
				--Name = "Wishlist";
				--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Wishlist_2.png";
				--ClickCallback = Map3DSystem.UI.Creation.OnClickSubIconSet;
				--},
			--}
	};
Map3DSystem.UI.MainBar.IconSet[2] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[3] = 
	{
		ShowIcon = true;
		ToolTip = L"Modify";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Modify.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Modify_4.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/modify_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/modify_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Modify.ShowUI;
		CloseUICallback = Map3DSystem.UI.Modify.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Modify.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Modify.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[4] = 
	{
		ShowIcon = true;
		ToolTip = L"Delete";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Delete.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Delete_6.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/delete_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/delete_d.png";
		Type = "Button";
		ClickCallback = Map3DSystem.UI.Delete.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Delete.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Delete.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[5] = 
	{
		ShowIcon = true;
		ToolTip = L"Property";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Property.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Property_2.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/property_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/property_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Property.ShowUI;
		CloseUICallback = Map3DSystem.UI.Property.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Property.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Property.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[6] = 
	{
		ShowIcon = true;
		ToolTip = L"Possession";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Possession.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Possession_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/possession_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/possession_d.png";
		Type = "Button";
		ClickCallback = Map3DSystem.UI.Possession.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Possession.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Possession.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[7] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[8] = 
	{
		ShowIcon = true;
		ToolTip = L"Sky";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Sky.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Sky_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/sky_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/sky_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Sky.ShowUI;
		CloseUICallback = Map3DSystem.UI.Sky.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Sky.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Sky.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[9] = 
	{
		ShowIcon = true;
		ToolTip = L"Water";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Water.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Water_2.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/water_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/water_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Water.ShowUI;
		CloseUICallback = Map3DSystem.UI.Water.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Water.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Water.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[10] = 
	{
		ShowIcon = true;
		ToolTip = L"Terrain";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Terrain.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Terrain_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/terrain_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/terrain_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Terrain.ShowUI;
		CloseUICallback = Map3DSystem.UI.Terrain.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Terrain.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Terrain.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[11] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[12] = 
	{
		ShowIcon = true;
		ToolTip = L"Navigation Mode";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/NavModeOn.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Object_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/object_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/object_d.png";
		Type = "Button";
		ClickCallback = Map3DSystem.UI.NavMode.OnClick;
		MouseEnterCallback = Map3DSystem.UI.NavMode.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.NavMode.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[13] = 
	{
		ShowIcon = true;
		ToolTip = L"Chat";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Chat.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Chat_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/chat_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/chat_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Chat.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Chat.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Chat.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Chat.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Chat.CloseWnd;
	};
Map3DSystem.UI.MainBar.IconSet[14] = 
	{
		ShowIcon = true;
		ToolTip = L"Map";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Map.png; 0 0 48 48";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/map_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/map_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Map.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Map.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Map.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Map.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Map.CloseWnd;
	};
--Map3DSystem.UI.MainBar.IconSet[12] = 
	--{
		--ToolTip = L"Message Board";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovieOriginal_n.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovieOriginal_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovieOriginal_d.png";
		--Type = "Window";
		--ClickCallback = Map3DSystem.UI.KidsMovieOriginal.OnClick;
		----ShowWndCallback = Map3DSystem.UI.KidsMovieOriginal.ShowWnd;
		----CloseWndCallback = Map3DSystem.UI.KidsMovieOriginal.CloseWnd;
	--};
Map3DSystem.UI.MainBar.IconSet[15] = 
	{
		ShowIcon = true;
		ToolTip = L"Profile";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Profile.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Profile_2.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/profile_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/profile_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Profile.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Profile.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Profile.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Profile.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Profile.CloseWnd;
	};
Map3DSystem.UI.MainBar.IconSet[16] = 
	{
		ShowIcon = true;
		ToolTip = L"Hints"; -- TODO: Tips
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/TipsOn.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Tips_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/hints_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/hints_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Hints.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Hints.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Hints.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Hints.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Hints.CloseWnd;
	};
--Map3DSystem.UI.MainBar.IconSet[15] = 
	--{
		--ToolTip = L"Status";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/status_n.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/status_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/status_d.png";
		--Type = "Window";
		--ClickCallback = Map3DSystem.UI.Status.OnClick;
		----ShowWndCallback = Map3DSystem.UI.Status.ShowWnd;
		----CloseWndCallback = Map3DSystem.UI.Status.CloseWnd;
	--};
--Map3DSystem.UI.MainBar.IconSet[16] = 
	--{
		--ToolTip = L"Setting";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/setting_n.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/setting_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/setting_d.png";
		--Type = "Window";
		--ClickCallback = Map3DSystem.UI.Setting.OnClick;
		----ShowWndCallback = Map3DSystem.UI.Setting.ShowWnd;
		----CloseWndCallback = Map3DSystem.UI.Setting.CloseWnd;
	--};
Map3DSystem.UI.MainBar.IconSet[17] = 
	{
		ShowIcon = true;
		ToolTip = "原Kids Movie的功能"; -- TODO: "Kids Movie"
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovie_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/setting_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/setting_d.png";
		Type = "Window";
		
		ClickCallback = Map3DSystem.UI.KidsMovieOriginal.OnClick;
		MouseEnterCallback = Map3DSystem.UI.KidsMovieOriginal.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.KidsMovieOriginal.OnMouseLeave;
		
		
		
	};
Map3DSystem.UI.MainBar.IconSet[18] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[19] = 
	{
		ShowIcon = true;
		ToolTip = L"Exit";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Exit.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Menu_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/exit_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/exit_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Exit.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Exit.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Exit.OnMouseLeave;
	};
	
	
	
-----------------------------------------DEPRECATED-----------------------------------------
---- NOTE: groups+icons+stackitems doc refer to notebook 2008.1.9
--
---- Main bar is consists of serveral groups. Groups are separated by separators
---- each group has an index to tell the sequence displaying on the mainbar
---- e.x.: Map3DSystem.UI.MainBar.groups[1] = {
----		index = 1,
----		name = "apps",
----		index = ,
---- }
--if(not Map3DSystem.UI.MainBar.groups) then Map3DSystem.UI.MainBar.groups = {}; end
-----------------------------------------DEPRECATED-----------------------------------------


-- Each group has a sequence of icons for clicking. Icon is a kind of integration point for applications in ParaWorld.
-- Each icon provides tooltip, iconpath, onclick, onmouseenter, onmouseleave .etc
if(not Map3DSystem.UI.MainBar.icons) then Map3DSystem.UI.MainBar.icons = {}; end

-- Icons inside a stack-typed icon
if(not Map3DSystem.UI.MainBar.stackitems) then Map3DSystem.UI.MainBar.stackitems = {}; end


-----------------------------------------DEPRECATED-----------------------------------------
------------------------------------
---- orinigal group organization
------------------------------------
--
--Map3DSystem.UI.MainBar.groups[1] = 
	--{
		--name = "apps";
		--maxFirstLevelIcons = 5;
		--index = 1;
		--iconRangeStart = 1;
		--iconRangeEnd = 1;
	--};
--Map3DSystem.UI.MainBar.groups[2] = 
	--{
		--name = "stacks";
		--maxFirstLevelIcons = nil;
		--index = 2;
		--iconRangeStart = nil;
		--iconRangeEnd = nil;
	--};
--Map3DSystem.UI.MainBar.groups[3] = 
	--{
		--name = "feed";
		--maxFirstLevelIcons = nil;
		--index = 3;
		--iconRangeStart = 100;
		--iconRangeEnd = 100;
	--};
-----------------------------------------DEPRECATED-----------------------------------------


----------------------------------
-- orinigal icon organization
----------------------------------

Map3DSystem.UI.MainBar.icons[1] = 
	{
		name = "Creator";
		type = "app";
		tooltip = "Creator";
		stackitemRangeStart = 1;
		stackitemRangeEnd = 7;
		--normalIcon = "Texture/3DMapSystem/MainBarIcon/Creation.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/Creator.png; 0 0 48 48";
		ClickCallback = Map3DSystem.UI.Creation.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Creation.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Creation.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.icons[2] = 
	{
		name = "Chat";
		type = "app";
		tooltip = "Chat";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		--normalIcon = "Texture/3DMapSystem/MainBarIcon/Chat.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/Chat.png; 0 0 48 48";
		ClickCallback = Map3DSystem.UI.Map.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Map.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Map.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.icons[3] = 
	{
		name = "Map";
		type = "app";
		tooltip = "Map";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		--normalIcon = "Texture/3DMapSystem/MainBarIcon/Map.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/Map.png; 0 0 48 48";
		ClickCallback = Map3DSystem.UI.Map.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Map.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Map.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.icons[4] = 
	{
		name = "Pet";
		type = "app";
		tooltip = "Pet";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		--normalIcon = "Texture/3DMapSystem/MainBarIcon/Pet.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/Pet.png; 0 0 48 48";
		--ClickCallback = Map3DSystem.UI.Pet.OnClick;
		--MouseEnterCallback = Map3DSystem.UI.Pet.OnMouseEnter;
		--MouseLeaveCallback = Map3DSystem.UI.Pet.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.icons[5] = 
	{
		name = "Inventory";
		type = "app";
		tooltip = "Inventory";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		--normalIcon = "Texture/3DMapSystem/MainBarIcon/Inventory.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/Inventory.png; 0 0 48 48";
		--ClickCallback = Map3DSystem.UI.Inventory.OnClick;
		--MouseEnterCallback = Map3DSystem.UI.Inventory.OnMouseEnter;
		--MouseLeaveCallback = Map3DSystem.UI.Inventory.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.icons[6] = 
	{
		name = "More";
		type = "stack";
		tooltip = "More Application";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		--normalIcon = "Texture/Themes/Original/OfficialAppIcon/MoreApp.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/Reflection/MoreApp.png; 0 0 48 48";
	};
	
	
Map3DSystem.UI.MainBar.icons[100] = 
	{
		name = "ChatTest";
		type = "doc";
		tooltip = "Conversation with ChatTest";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/ChatDoc.png";
	};
	
	
Map3DSystem.UI.MainBar.icons[200] = 
	{
		name = "FeedRed";
		type = "test";
		tooltip = "FeedRed";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/FeedRed.png";
	};
Map3DSystem.UI.MainBar.icons[201] = 
	{
		name = "FeedGreen";
		type = "test";
		tooltip = "FeedGreen";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/FeedGreen.png";
	};
Map3DSystem.UI.MainBar.icons[202] = 
	{
		name = "FeedBlue";
		type = "test";
		tooltip = "FeedBlue";
		stackitemRangeStart = nil;
		stackitemRangeEnd = nil;
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/FeedBlue.png";
	};



--
------------------------------------
---- orinigal stackitem organization
------------------------------------
--
--Map3DSystem.UI.MainBar.icons[1] = 
	--{
		--name = "Modify";
		--index = 1;
		--ToolTip = "Modify";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Exit.png; 0 0 48 48";
		--ClickCallback = ;
		--MouseEnterCallback = ;
		--MouseLeaveCallback = ;
	--};
--Map3DSystem.UI.MainBar.icons[2] = 
	--{
		--name = "Delete";
		--index = 2;
		--ToolTip = "Delete";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Exit.png; 0 0 48 48";
		--ClickCallback = ;
		--MouseEnterCallback = ;
		--MouseLeaveCallback = ;
	--};
--Map3DSystem.UI.MainBar.icons[3] = 
	--{
		--name = "Property";
		--index = 3;
		--ClickCallback = ;
		--MouseEnterCallback = ;
		--MouseLeaveCallback = ;
	--};
--Map3DSystem.UI.MainBar.icons[4] = 
	--{
		--name = "Possession";
		--index = 4;
		--ClickCallback = ;
		--MouseEnterCallback = ;
		--MouseLeaveCallback = ;
	--};
--Map3DSystem.UI.MainBar.icons[5] = 
	--{
		--name = "Inventory";
		--index = 5;
		--stackitemRangeStart = nil;
		--stackitemRangeEnd = nil;
	--};
--Map3DSystem.UI.MainBar.icons[6] = 
	--{
		--name = "More";
		--index = 6;
		--stackitemRangeStart = nil;
		--stackitemRangeEnd = nil;
	--};


Map3DSystem.UI.MainBar.IconSet[1] = 
	{
		name = "Creator";
		type = "app";
		tooltip = "Creator";
		stackitemRangeStart = 1;
		stackitemRangeEnd = 7;
		--normalIcon = "Texture/3DMapSystem/MainBarIcon/Creation.png; 0 0 48 48";
		normalIcon = "Texture/Themes/Original/OfficialAppIcon/Creator.png; 0 0 48 48";
		ClickCallback = Map3DSystem.UI.Creation.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Creation.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Creation.OnMouseLeave;
		
		
		name = "Creator";
		group = "Applications";
		ShowIcon = true;
		ToolTip = L"Creation";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Creation.png; 0 0 48 48";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Creation.ShowUI;
		CloseUICallback = Map3DSystem.UI.Creation.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Creation.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Creation.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[2] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[3] = 
	{
		ShowIcon = true;
		ToolTip = L"Modify";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Modify.png; 0 0 48 48";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Modify.ShowUI;
		CloseUICallback = Map3DSystem.UI.Modify.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Modify.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Modify.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[4] = 
	{
		ShowIcon = true;
		ToolTip = L"Delete";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Delete.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Delete_6.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/delete_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/delete_d.png";
		Type = "Button";
		ClickCallback = Map3DSystem.UI.Delete.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Delete.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Delete.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[5] = 
	{
		ShowIcon = true;
		ToolTip = L"Property";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Property.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Property_2.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/property_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/property_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Property.ShowUI;
		CloseUICallback = Map3DSystem.UI.Property.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Property.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Property.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[6] = 
	{
		ShowIcon = true;
		ToolTip = L"Possession";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Possession.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Possession_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/possession_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/possession_d.png";
		Type = "Button";
		ClickCallback = Map3DSystem.UI.Possession.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Possession.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Possession.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[7] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[8] = 
	{
		ShowIcon = true;
		ToolTip = L"Sky";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Sky.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Sky_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/sky_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/sky_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Sky.ShowUI;
		CloseUICallback = Map3DSystem.UI.Sky.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Sky.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Sky.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[9] = 
	{
		ShowIcon = true;
		ToolTip = L"Water";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Water.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Water_2.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/water_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/water_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Water.ShowUI;
		CloseUICallback = Map3DSystem.UI.Water.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Water.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Water.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[10] = 
	{
		ShowIcon = true;
		ToolTip = L"Terrain";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Terrain.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Terrain_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/terrain_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/terrain_d.png";
		Type = "Panel";
		ShowUICallback = Map3DSystem.UI.Terrain.ShowUI;
		CloseUICallback = Map3DSystem.UI.Terrain.CloseUI;
		MouseEnterCallback = Map3DSystem.UI.Terrain.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Terrain.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[11] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[12] = 
	{
		ShowIcon = true;
		ToolTip = L"Navigation Mode";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/NavModeOn.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Object_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/object_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/object_d.png";
		Type = "Button";
		ClickCallback = Map3DSystem.UI.NavMode.OnClick;
		MouseEnterCallback = Map3DSystem.UI.NavMode.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.NavMode.OnMouseLeave;
	};
Map3DSystem.UI.MainBar.IconSet[13] = 
	{
		ShowIcon = true;
		ToolTip = L"Chat";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Chat.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Chat_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/chat_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/chat_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Chat.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Chat.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Chat.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Chat.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Chat.CloseWnd;
	};
Map3DSystem.UI.MainBar.IconSet[14] = 
	{
		ShowIcon = true;
		ToolTip = L"Map";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Map.png; 0 0 48 48";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/map_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/map_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Map.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Map.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Map.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Map.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Map.CloseWnd;
	};
--Map3DSystem.UI.MainBar.IconSet[12] = 
	--{
		--ToolTip = L"Message Board";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovieOriginal_n.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovieOriginal_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovieOriginal_d.png";
		--Type = "Window";
		--ClickCallback = Map3DSystem.UI.KidsMovieOriginal.OnClick;
		----ShowWndCallback = Map3DSystem.UI.KidsMovieOriginal.ShowWnd;
		----CloseWndCallback = Map3DSystem.UI.KidsMovieOriginal.CloseWnd;
	--};
Map3DSystem.UI.MainBar.IconSet[15] = 
	{
		ShowIcon = true;
		ToolTip = L"Profile";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Profile.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Profile_2.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/profile_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/profile_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Profile.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Profile.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Profile.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Profile.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Profile.CloseWnd;
	};
Map3DSystem.UI.MainBar.IconSet[16] = 
	{
		ShowIcon = true;
		ToolTip = L"Hints"; -- TODO: Tips
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/TipsOn.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Tips_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/hints_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/hints_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Hints.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Hints.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Hints.OnMouseLeave;
		--ShowWndCallback = Map3DSystem.UI.Hints.ShowWnd;
		--CloseWndCallback = Map3DSystem.UI.Hints.CloseWnd;
	};
--Map3DSystem.UI.MainBar.IconSet[15] = 
	--{
		--ToolTip = L"Status";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/status_n.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/status_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/status_d.png";
		--Type = "Window";
		--ClickCallback = Map3DSystem.UI.Status.OnClick;
		----ShowWndCallback = Map3DSystem.UI.Status.ShowWnd;
		----CloseWndCallback = Map3DSystem.UI.Status.CloseWnd;
	--};
--Map3DSystem.UI.MainBar.IconSet[16] = 
	--{
		--ToolTip = L"Setting";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/setting_n.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/setting_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/setting_d.png";
		--Type = "Window";
		--ClickCallback = Map3DSystem.UI.Setting.OnClick;
		----ShowWndCallback = Map3DSystem.UI.Setting.ShowWnd;
		----CloseWndCallback = Map3DSystem.UI.Setting.CloseWnd;
	--};
Map3DSystem.UI.MainBar.IconSet[17] = 
	{
		ShowIcon = true;
		ToolTip = "原Kids Movie的功能"; -- TODO: "Kids Movie"
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/KidsMovie_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/setting_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/setting_d.png";
		Type = "Window";
		
		ClickCallback = Map3DSystem.UI.KidsMovieOriginal.OnClick;
		MouseEnterCallback = Map3DSystem.UI.KidsMovieOriginal.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.KidsMovieOriginal.OnMouseLeave;
		
		
		
	};
Map3DSystem.UI.MainBar.IconSet[18] = 
	{
		ShowIcon = true;
		Type = "Separator";
	};
Map3DSystem.UI.MainBar.IconSet[19] = 
	{
		ShowIcon = true;
		ToolTip = L"Exit";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Exit.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Menu_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/exit_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/exit_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Exit.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Exit.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Exit.OnMouseLeave;
	};