--[[
Title: Creation in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/17
Desc: Show the creation panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Creation.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");
-- TODO: change to Kids 3D map system localization
local LL = CommonCtrl.Locale("KidsUI");

if(not Map3DSystem.UI.Creation) then Map3DSystem.UI.Creation = {}; end

function Map3DSystem.UI.Creation.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("CreationWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("CreationWnd recv MSG WM_HIDE.\n");
		Map3DSystem.UI.Creation.CloseUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("CreationWnd recv MSG WM_SHOW.\n");
		Map3DSystem.UI.Creation.ShowUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		-- Do your code
		--_guihelper.MessageBox("CreationWnd recv MSG WM_MINIMIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MAXIMIZE) then
		-- Do your code
		--_guihelper.MessageBox("CreationWnd recv MSG WM_MAXIMIZE.\n");
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_Creation_Show) then
		-- show or hide the creation panel, nil to toggle current setting
		Map3DSystem.UI.Creation.Show(msg.bShow);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("CreationWnd recv MSG WM_SIZE. size:"..msg.param1.."\n");
		Map3DSystem.UI.Creation.RefreshIconMatrix(msg.param1);
	end
end


function Map3DSystem.UI.Creation.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Creation.WndObject = app:RegisterWindow(
		"CreationWnd", mainWndName, Map3DSystem.UI.Creation.MSGProc);
end

-- send a message to MainPanel:CreationWnd window handler
-- e.g. Map3DSystem.UI.Creation.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_Show})
function Map3DSystem.UI.Creation.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.Creation.WndObject.name;
	Map3DSystem.UI.MainPanel.App:SendMessage(msg);
end

-- initiate the creation panel UI, one time initiate
function Map3DSystem.UI.Creation.InitUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	if(_panel:IsValid() == true) then
		local _sub_panel = _panel:GetChild("_sub_panel_creation");
		if(_sub_panel:IsValid() == false) then
			-- create creation sub panel
			Map3DSystem.UI.Creation.CreateSubPanel(_panel);
		end
	end
end

-- added LXZ 2007.12.31
function Map3DSystem.UI.Creation.ShowQuickLaunchBar(bShow)

	--local _cate = ParaUI.GetUIObject("CategoryBox");
	--if(_cate:IsValid() == false) then
		---- init category box
		--Map3DSystem.UI.Creation.InitCategoryBox();
	--end
	
	local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
	if(_quickLaunch:IsValid() == false) then
		-- init quick launch bar
		Map3DSystem.UI.Creation.InitCreationQuickLaunchBar();
	else
		if(bShow == nil) then
			_quickLaunch.visible = not _quickLaunch.visible;
		else
			_quickLaunch.visible = bShow;
		end	
	end
	
	local _quickLaunchAnimation = ParaUI.GetUIObject("AnimationQuickLaunchBar");
	if(_quickLaunchAnimation:IsValid() == false) then
		-- init animation quick launch bar
		Map3DSystem.UI.Creation.InitAnimationQuickLaunchBar();
	else
		if(bShow == nil) then
			_quickLaunchAnimation.visible = not _quickLaunchAnimation.visible;
		else
			_quickLaunchAnimation.visible = bShow;
		end	
	end
end

-- show or hide the creation panel, bShow == nil, toggle current setting
function Map3DSystem.UI.Creation.Show(bShow)
	Map3DSystem.UI.MainPanel.ShowPanel(1, bShow);
end

-- onmouseenter function to mouse enter the creation icon
function Map3DSystem.UI.Creation.OnMouseEnter()

	--local _icon = ParaUI.GetUIObject("MainBar_icons_1"); --  the main bar creation icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Main");
	local x, y = _icon:GetAbsPosition();
end

function Map3DSystem.UI.Creation.OnMouseLeave()
	
	-- current active panel is creation, do nothing
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 1) then
		return;
	end
end

-- init creation quick launch bar
-- default visible is true
function Map3DSystem.UI.Creation.InitCreationQuickLaunchBar()

	local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
	if(_quickLaunch:IsValid() == true) then
		return;
	end
	
	_quickLaunch = ParaUI.CreateUIObject("container", "CreationQuickLaunchBar", "_ctl", 
			0, 0, 48, 400);
	_quickLaunch:AttachToRoot();
	
	local left = 8;
	local top = 8;
	local gap = 8;
	
	local _parent = _quickLaunch;
	
	local i;
	for i = 1, 9 do
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left, top, 32, 32);
		_this.onclick = ";Map3DSystem.UI.Creation.OnClickCreationQuickLaunchBar("..i..");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		if(i == 1) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg1.png";
			_this.tooltip = "建筑";
		elseif(i == 2) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg2.png";
			_this.tooltip = "家具";
		elseif(i == 3) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg3.png";
			_this.tooltip = "生活";
		elseif(i == 4) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg4.png";
			_this.tooltip = "装饰";
		elseif(i == 5) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg5.png";
			_this.tooltip = "花草";
		elseif(i == 6) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg6.png";
			_this.tooltip = "杂物";
		elseif(i == 7) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg8.png";
			_this.tooltip = "树木";
		elseif(i == 8) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg7.png";
			_this.tooltip = "普通人物";
		elseif(i == 9) then
			_this.background = "Texture/3DMapSystem/QuickLaunch/btn_bg7.png";
			_this.tooltip = "CCS人物";
		end
	end
	
end

function Map3DSystem.UI.Creation.OnClickCreationQuickLaunchBar(index)
	

	-- TODO: copied from mainbar.lua, rewrite the code in message-driven form
	--local _icon = ParaUI.GetUIObject("MainBar_icons_1");
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Main");
	local x, y, width, height = _icon:GetAbsPosition();
	local offset = 0;
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
	
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == nil) then
		_panel.x = x - offset;
		_panel_behind.x = x - offset;
		Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = 1;
		_panel.visible = true;
		_panel:BringToFront();
		_panel_behind.visible = true;
		-- show creation panel
		Map3DSystem.UI.MainPanel.PreShowPanelUI(1);
		Map3DSystem.UI.MainBar.IconSet[1].ShowUICallback();

	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 1) then
		
	else
		_panel.x = x - offset;
		_panel_behind.x = x - offset;
		-- unshow Map3DSystem.UI.MainPanel.CurrentActivePanelIndex panel
		Map3DSystem.UI.MainBar.IconSet[Map3DSystem.UI.MainPanel.CurrentActivePanelIndex].CloseUICallback();
		Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = 1;
		-- show creation panel
		Map3DSystem.UI.MainPanel.PreShowPanelUI(1);
		Map3DSystem.UI.MainBar.IconSet[1].ShowUICallback();
	end
	
	
	
	local ctl = CommonCtrl.GetControl("treeViewCreation");
	local _rootnode = ctl.RootNode;
	local _node = ctl.RootNode;
	local k, v;
	for k, v in pairs(Map3DSystem.DB.Groups) do
		if(v.parent == "Root") then
			-- lvl 1 node
			_node = _rootnode:GetChildByName(v.name);
			-- TODO: dirty collapse all lvl 1 node
			_node:CollapseAll();
		end
	end
	
	if(index >= 1 and index <= 7) then
		_node = _rootnode:GetChildByName("Normal Model");
		_node:Expand();
		
		if(index == 1) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_01building");
		elseif(index == 2) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_02furniture");
		elseif(index == 3) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_03tools");
		elseif(index == 4) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_04deco");
		elseif(index == 5) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_05plants");
		elseif(index == 6) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_06props");
		elseif(index == 7) then
			Map3DSystem.UI.Creation.SetCategoryGroup("NM_07trees");
		end
	elseif(index == 8) then
		_node = _rootnode:GetChildByName("Normal Character");
		_node:Expand();
		Map3DSystem.UI.Creation.SetCategoryGroup("NC_01human");
	elseif(index == 9) then
		_node = _rootnode:GetChildByName("CCS");
		_node:Expand();
		Map3DSystem.UI.Creation.SetCategoryGroup("CCS_01original");
	end
	
	ctl:Update();
end

-- init animation quick launch bar
-- default visible is true
function Map3DSystem.UI.Creation.InitAnimationQuickLaunchBar()

	local _quickLaunch = ParaUI.GetUIObject("AnimationQuickLaunchBar");
	if(_quickLaunch:IsValid() == true) then
		return;
	end
	
	--if(ARTIST_TOOLS == true) then
		--_quickLaunch = ParaUI.CreateUIObject("container", "AnimationQuickLaunchBar", "_ctl", 
				--48, 0, 48, 600);
		--_quickLaunch:AttachToRoot();
	--else
		_quickLaunch = ParaUI.CreateUIObject("container", "AnimationQuickLaunchBar", "_ctr", 
				0, 0, 48, 600);
		_quickLaunch:AttachToRoot();
	--end
	
	local left = 8;
	local top = 8;
	local gap = 8;
	
	local _parent = _quickLaunch;
	
	local i;
	for i = 1, 14 do
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left, top, 32, 32);
		_this.onclick = ";Map3DSystem.UI.Creation.OnClickAnimationQuickLaunchBar("..i..");";
		_this.background = "Texture/3DMapSystem/QuickLaunch/"..i..".png";
		_parent:AddChild(_this);
		top = top + 32 + gap;
	end
	
end

function Map3DSystem.UI.Creation.OnClickAnimationQuickLaunchBar(index)
	
	local animName;
	
	if(index == 1) then
		animName = "Sword";
	elseif(index == 2) then
		animName = "Fist";
	elseif(index == 3) then
		animName = "LayDown";
	elseif(index == 4) then
		animName = "Jitter";
	elseif(index == 5) then
		animName = "SitOnFloor";
	elseif(index == 6) then
		animName = "Club";
	elseif(index == 7) then
		animName = "Blade";
	elseif(index == 8) then
		animName = "Celebrate";
	elseif(index == 9) then
		animName = "Seed";
	elseif(index == 10) then
		animName = "Dodge";
	elseif(index == 11) then
		animName = "Shoot";
	elseif(index == 12) then
		animName = "Victory";
	elseif(index == 13) then
		animName = "Magic";
	elseif(index == 14) then
		animName = "Bow";
	end
	
	Map3DSystem.Animation.SendMeMessage({
			type = Map3DSystem.msg.ANIMATION_Character,
			obj_params = Map3DSystem.obj.GetObjectParams("selection"),
			animationName = animName,
			});
	
end

-- init all category box UI including the icons matrix and treeview
-- default visible is false
function Map3DSystem.UI.Creation.InitCategoryBox()

	--local _icon = ParaUI.GetUIObject("MainBar_icons_1"); --  the main bar creation icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Main");
	local x, y, width, height = _icon:GetAbsPosition();
	local _x, _y;
	_x = x - Map3DSystem.UI.Creation.CategoryBoxWidthOffset;
	_y = y - Map3DSystem.UI.Creation.CategoryBoxHeight;
	local _width = Map3DSystem.UI.Creation.CategoryBoxWidth;
	local _height = Map3DSystem.UI.Creation.CategoryBoxHeight;
	
	local _cate = ParaUI.GetUIObject("CategoryBox");
	if(_cate:IsValid() == true) then
		return;
	end
	
	_cate = ParaUI.CreateUIObject("container", "CategoryBox", "_lt", 
		_x, _y, _width, _height);
	_cate.onmouseleave = ";Map3DSystem.UI.Creation.OnMouseLeave();";
	_cate.background = "Texture/3DMapSystem/CategoryBox/BG.png: 4 4 4 4";
	_cate.visible = false;
	_cate:AttachToRoot();
	
	local _treeviewcont = ParaUI.CreateUIObject("container", "TreeViewContainer", "_fi", 
		10, 10, 10, 10);
	_treeviewcont.background = "";
	--_treeviewcont.visible = false;
	_cate:AddChild(_treeviewcont);

	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.TreeView:new{
		name = "treeViewCreation",
		alignment = "_fi",
		left = 0,
		top = 0,
		width = 0,
		height = 0,
		container_bg = "Texture/3DMapSystem/IM/white80opacity.png",
		parent = _treeviewcont,
		DefaultIndentation = 10,
		DefaultNodeHeight = 20,
		DrawNodeHandler = Map3DSystem.UI.Creation.DrawCategoryNodeHandler,
		onclick = Map3DSystem.UI.Creation.OnClickCategoryTreeView,
	};
	
	--Map3DSystem.DB.Items;
	--Map3DSystem.DB.Groups;
	
	local _rootnode = ctl.RootNode;
	local _node = ctl.RootNode;
	local k, v;
	for k, v in ipairs(Map3DSystem.DB.Groups) do
		if(v.parent == "Root") then
			-- lvl 1 node
			_node = _rootnode:AddChild( CommonCtrl.TreeNode:new(
				{Text = v.text, 
				Name = v.name, 
				type = "category", 
				Tag = Map3DSystem.DB.Groups[k],
				}) );
		else
			-- lvl 2/2+ node
			local parentName;
			local t = 0;
			for parentName in string.gfind(v.parent, "([^/]+)") do
				if(t == 0) then
					_node = _rootnode:GetChildByName(parentName);
					-- TODO: dirty collapse all lvl 1 node
					_node:CollapseAll();
					t = 1;
				else
					_node = _node:GetChildByName(parentName);
				end
			end
			_node:AddChild( CommonCtrl.TreeNode:new(
				{Text = v.text, 
				Name = v.name, 
				type = "group", 
				Tag = Map3DSystem.DB.Groups[k],
				}) );
		end
	end
	ctl:Show();
	
	local _mat = ParaUI.CreateUIObject("container", "CategoryBoxMatrix", "_fi", 
		10, 10, 10, 10);
	_mat.background = "Texture/3DMapSystem/CategoryBox/black80opacity.png";
	_cate:AddChild(_mat);
	
	local _matrixCornerX = 10;
	local _matrixCornerY = 10;
	local _matrixIconSize = 48;
	local _matrixIconGap = 4;
	
	local _this = ParaUI.CreateUIObject("button", "NormalObject", "_lt", 
		_matrixCornerX, _matrixCornerY, _matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/NormalModel.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(1);";
	_this.tooltip = "普通模型";
	_mat:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "NormalCharacter", "_lt", 
		_matrixCornerX + (_matrixIconSize+_matrixIconGap) * 1, _matrixCornerY, 
		_matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/NormalCharacter.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(2);";
	_this.tooltip = "普通人物";
	_mat:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "BCS", "_lt", 
		_matrixCornerX + (_matrixIconSize+_matrixIconGap) * 2, _matrixCornerY, 
		_matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/BCS.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(3);";
	_this.tooltip = "BCS";
	_mat:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "CCS", "_lt", 
		_matrixCornerX, _matrixCornerY + (_matrixIconSize+_matrixIconGap) * 1, 
		_matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/CCS.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(4);";
	_this.tooltip = "CCS";
	_mat:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "Favorite", "_lt", 
		_matrixCornerX + (_matrixIconSize+_matrixIconGap) * 1, _matrixCornerY + (_matrixIconSize+_matrixIconGap) * 1, 
		_matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/MyFavorite.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(5);";
	_this.tooltip = "我的收藏夹";
	_mat:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "Wishlist", "_lt", 
		_matrixCornerX + (_matrixIconSize+_matrixIconGap) * 2, _matrixCornerY + (_matrixIconSize+_matrixIconGap) * 1, 
		_matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/MyWishlist.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(6);";
	_this.tooltip = "我的愿望";
	_mat:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "ShowTreeView", "_lt", 
		_matrixCornerX, _matrixCornerY + (_matrixIconSize+_matrixIconGap) * 2, 
		_matrixIconSize, _matrixIconSize);
	_this.background = "Texture/3DMapSystem/MainBarIcon/SubIcon/OriginalTreeView.png; 0 0 48 48";
	_this.onclick = ";Map3DSystem.UI.Creation.ClickMatrix(7);";
	_this.tooltip = "回到原浏览页";
	_mat:AddChild(_this);
end

function Map3DSystem.UI.Creation.UpdateCategoryBoxStatus(sStatus)
	
	local _cate = ParaUI.GetUIObject("CategoryBox");
	if(_cate:IsValid() == false) then
		-- init category box
		Map3DSystem.UI.Creation.InitCategoryBox();
	end
	
	local _mat = _cate:GetChild("CategoryBoxMatrix");
	local _tView = _cate:GetChild("TreeViewContainer");
	
	if(Map3DSystem.UI.Creation.CategoryBoxStatus == "hide") then
		-- hide category box
		if(sStatus == "hide") then
			-- already hide
		elseif(sStatus == "showicons") then
			-- show icon matrix
			_cate.visible = true;
			_cate:BringToFront();
			_mat.visible = true;
			_tView.visible = false;
		elseif(sStatus == "showtreeview") then
			-- show tree view
			_cate.visible = true;
			_cate:BringToFront();
			_mat.visible = false;
			_tView.visible = true;
		end
		Map3DSystem.UI.Creation.CategoryBoxStatus = sStatus;
		
	elseif(Map3DSystem.UI.Creation.CategoryBoxStatus == "showicons") then
		-- show the category box with icons
		if(sStatus == "hide") then
			-- hide category box
			_cate.visible = false;
			_mat.visible = false;
			_tView.visible = false;
		elseif(sStatus == "showicons") then
			-- already show icon matrix
		elseif(sStatus == "showtreeview") then
			-- show tree view
			_cate.visible = true;
			_cate:BringToFront();
			_mat.visible = false;
			_tView.visible = true;
		end
		Map3DSystem.UI.Creation.CategoryBoxStatus = sStatus;
	elseif(Map3DSystem.UI.Creation.CategoryBoxStatus == "showtreeview") then
		-- show the category box with treeview
		if(sStatus == "hide") then
			-- hide category box
			_cate.visible = false;
			_mat.visible = false;
			_tView.visible = false;
		elseif(sStatus == "showicons") then
			-- show icon matrix
			_cate.visible = true;
			_cate:BringToFront();
			_mat.visible = true;
			_tView.visible = false;
		elseif(sStatus == "showtreeview") then
			-- already show tree view
		end
		Map3DSystem.UI.Creation.CategoryBoxStatus = sStatus;
	end
end

function Map3DSystem.UI.Creation.ClickMatrix(index)
	
	local categroyName;
	--Map3DSystem.UI.MainPanel.OnClickIcon(1);
	Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_ClickIcon, index = 1});
	Map3DSystem.UI.Creation.UpdateCategoryBoxStatus("showtreeview");
	if(index == 1) then
		-- normal object
		categroyName = "Normal Model";
		Map3DSystem.UI.Creation.SetCategoryGroup("NM_01building");
	elseif(index == 2) then
		-- normal character
		categroyName = "Normal Character";
		Map3DSystem.UI.Creation.SetCategoryGroup("NC_01human");
	elseif(index == 3) then
		-- BCS
		categroyName = "BCS";
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_01base");
	elseif(index == 4) then
		-- CCS
		categroyName = "CCS";
		Map3DSystem.UI.Creation.SetCategoryGroup("CCS_01original");
	elseif(index == 5) then
		-- Favorite
		categroyName = "My Favorite";
		Map3DSystem.UI.Creation.SetCategoryGroup("TestLvl2");
	elseif(index == 6) then
		-- Wishlist
		categroyName = "My Wishlist";
		Map3DSystem.UI.Creation.SetCategoryGroup("WishlistTest");
	elseif(index == 7) then
		-- Show tree view
		--Map3DSystem.UI.Creation.CategoryTreeViewShow = true;
		return;
	end
	
	local ctl = CommonCtrl.GetControl("treeViewCreation");
	local _rootnode = ctl.RootNode;
	local _node = ctl.RootNode;
	local k, v;
	for k, v in pairs(Map3DSystem.DB.Groups) do
		if(v.parent == "Root") then
			-- lvl 1 node
			_node = _rootnode:GetChildByName(v.name);
			if(v.name == categroyName) then
				_node:Expand();
			else
				_node:Collapse();
			end
		end
	end
	
	ctl:Update();
	
	--Map3DSystem.UI.Creation.CategoryTreeViewShow = true;
	
end

function Map3DSystem.UI.Creation.ShowUI(subIconIndex)

end

function Map3DSystem.UI.Creation.DrawCategoryNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return;
	end
	
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1); -- indentation of this node. 
	local top = 2;
	local width;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
						
	if(treeNode.type == "category") then
		-- render creation category TreeNode: a check box and a text button. click either to toggle the node.
		width = 24 -- check box width
		if(treeNode:GetChildCount() > 0) then
			-- category with sub-groups
			-- checkbox
			_this = ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/IM/group-arrow-down.png";
			else
				_this.background = "Texture/3DMapSystem/IM/group-arrow-right.png";
			end
			
			-- text button
			_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			
			-- set text
			_this.text = treeNode.Text;
		else
			-- no groups in this group
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/IM/group-arrow-down.png";
			else
				_this.background = "Texture/3DMapSystem/IM/group-arrow-right.png";
			end
			
			_this=ParaUI.CreateUIObject("text","b","_lt", left, 0, nodeWidth - left-1, height);
			_parent:AddChild(_this);
			_this:GetFont("text").format=36; -- single line and vertical align
			
			-- set text
			_this.text = treeNode.Text;
		end
	elseif(treeNode.type == "group") then
		-- render group TreeNode
		width = 24; -- status icon width
		-- status icon
		_this = ParaUI.CreateUIObject("button","b","_lt", left, 0, width , width );
		local _icon = _this;
		_parent:AddChild(_this);
		if(treeNode.Tag == nil) then
			_this.background = "";
		else
			_this.background = treeNode.Tag.icon;
		end
		--_this.onclick = string.format(";Map3DSystem.UI.Creation.OnClickCategoryTreeView(%q)", treeNode.Name);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q,%q)", treeNode.TreeView.name, treeNode:GetNodePath());
		left = left + width;
		
		-- text button	
		_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/3DMapSystem/IM/lightblue.png");
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q,%q)", treeNode.TreeView.name, treeNode:GetNodePath());
		
		_this.text = treeNode.Text;
	end
end

function Map3DSystem.UI.Creation.OnClickCategoryTreeView(treeNode)

	if(treeNode == nil) then 
		return 
	end
	if(treeNode.type == "category") then
		--_guihelper.MessageBox("click category:"..treeNode.Name);
	elseif(treeNode.type == "group") then
		--_guihelper.MessageBox("click group:"..treeNode.Name);
		Map3DSystem.UI.Creation.CategoryGroup = treeNode.Name;
		Map3DSystem.UI.Creation.ResetPageInfo();
		Map3DSystem.UI.Creation.RefreshIconMatrix();
	end
	--Map3DSystem.UI.Creation.isBCSActive = false;
	--if(treeNode.Tag.parent == "BCS") then
		--Map3DSystem.UI.Creation.isBCSActive = true;
	--end
end

function Map3DSystem.UI.Creation.SetCategoryGroup(name)

	if(name == nil) then 
		return;
	end
	Map3DSystem.UI.Creation.CategoryGroup = name;
	Map3DSystem.UI.Creation.ResetPageInfo();
	Map3DSystem.UI.Creation.RefreshIconMatrix();
end

function Map3DSystem.UI.Creation.CreateSubPanel(parent)
	-- creation sub panel for the first run
	local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_creation", "_lt",
		Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
		Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
	--_sub_panel.background = "";
	_sub_panel.visible = false;
	parent:AddChild(_sub_panel);
	
	local _this;
	-- Pager
	_this = ParaUI.CreateUIObject("button", "pageLeft", "_rt", -40, 20, 32, 32);
	_this.tooltip = L"Previous Page";
	_this.background = "Texture/kidui/CCS/btn_CCS_CF_Page_Left.png";
	_this.onclick = ";Map3DSystem.UI.Creation.OnPageLeftClick();";
	_sub_panel:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "pageRight", "_rt", -40, 80, 32, 32);
	_this.tooltip = L"Next Page";
	_this.background = "Texture/kidui/CCS/btn_CCS_CF_Page_Right.png";
	_this.onclick = ";Map3DSystem.UI.Creation.OnPageRightClick();";
	_sub_panel:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "pageLabel", "_rt", -40, 60, 40, 32);
	_this.text = "0/0";
	_sub_panel:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "Advanced", "_rb", -36, -30, 24, 24);
	_this.background = "Texture/3DMapSystem/common/info.png";
	_this.onclick = ";Map3DSystem.UI.Creation.OnAdvancedClick();";
	_sub_panel:AddChild(_this);
	
	-- Icon Matrix
	local iconMatrixLeft = 10;
	local iconMatrixTop = 15;
	local iconMatrixGap = 1;
	local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
	local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;
	local iconMatrixIconSize = 48;
	local iconMatrixIconOffset = 3;
	local iconMatrixBGSize = 57;
	local iconMatrixGap = 5;
	local index;
	
	for y=0, iconMatrixY - 1 do
		for x=0, iconMatrixX - 1 do
			_this = ParaUI.CreateUIObject("container", "creation_icon_BG_matrix_"..x..y, "_lt", 
				iconMatrixLeft + (iconMatrixBGSize + iconMatrixGap) * x, 
				iconMatrixTop + (iconMatrixBGSize + iconMatrixGap) * y, 
				iconMatrixBGSize, iconMatrixBGSize);
			-- TODO : change the background
			_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
			_sub_panel:AddChild(_this);
			
			local _parent = _this;
			
			_this = ParaUI.CreateUIObject("button", "creation_icon_matrix_"..x..y, "_lt", 
				iconMatrixIconOffset, 
				iconMatrixIconOffset, 
				iconMatrixIconSize, iconMatrixIconSize);
				
			index = x + y * iconMatrixX;
			_this.animstyle = 11;
			_this.onclick = ";Map3DSystem.UI.Creation.OnIconClick("..index..");";
			_parent:AddChild(_this);
		end
	end
	
	return _sub_panel;
end

Map3DSystem.UI.Creation.IsRandomFacing = false;
Map3DSystem.UI.Creation.IsRandomSize = false;
Map3DSystem.UI.Creation.RandomSizeMin = "1.0";
Map3DSystem.UI.Creation.RandomSizeMax = "1.0";
Map3DSystem.UI.Creation.BindingContextAdvancedCreationOptions = nil;

function Map3DSystem.UI.Creation.OnAdvancedClick()
	
	local x, y = ParaUI.GetMousePosition();
	local _advanced = ParaUI.GetUIObjectAtPoint(x, y);
	if(_advanced:IsValid() == true) then
		local _this = ParaUI.GetUIObject("AdvancedCreationOptions");
		if(_this:IsValid() == true) then
			local x, y, width, height = _advanced:GetAbsPosition();
			_this.x = x - 100 + width/2
			_this.y = y - 200;
			_this:BringToFront();
			_this.visible = true;
			return;
		end
		
		local x, y, width, height = _advanced:GetAbsPosition();
		local _this = ParaUI.CreateUIObject("container", "AdvancedCreationOptions", "_lt", x - 100 + width/2, y - 200, 200, 200);
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		
		local _parent = _this;
		
		CommonCtrl.DeleteControl("CheckRandomFacing");
		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "CheckRandomFacing",
			alignment = "_lt",
			left = 16,
			top = 16,
			width = 100,
			height = 20,
			parent = _parent,
			isChecked = Map3DSystem.UI.Creation.IsRandomFacing,
			text = "随机方向",
		};
		ctl:Show();
		
		CommonCtrl.DeleteControl("CheckRandomSize");
		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "CheckRandomSize",
			alignment = "_lt",
			left = 16,
			top = 48,
			width = 100,
			height = 20,
			parent = _parent,
			isChecked = Map3DSystem.UI.Creation.IsRandomSize,
			text = "随机尺寸",
		};
		ctl:Show();
		
		local _this = ParaUI.CreateUIObject("text", "Min", "_lt", 40, 80, 48, 24);
		_this.text = "最小尺寸:";
		_parent:AddChild(_this);
		
		local _this = ParaUI.CreateUIObject("editbox", "AdvancedCreationOptions.Min", "_lt", 100, 80, 32, 24);
		_this.text = "1.0";
		_parent:AddChild(_this);
		
		local _this = ParaUI.CreateUIObject("text", "Max", "_lt", 40, 110, 48, 24);
		_this.text = "最大尺寸:";
		_parent:AddChild(_this);
		
		local _this = ParaUI.CreateUIObject("editbox", "AdvancedCreationOptions.Max", "_lt", 100, 110, 32, 24);
		_this.text = "1.0";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/DataBinding.lua");
		local bindingContext = commonlib.BindingContext:new();
		bindingContext:AddBinding(Map3DSystem.UI.Creation, 
			"IsRandomFacing", "CheckRandomFacing", commonlib.Binding.ControlTypes.IDE_checkbox, "value");
		bindingContext:AddBinding(Map3DSystem.UI.Creation, 
			"IsRandomSize", "CheckRandomSize", commonlib.Binding.ControlTypes.IDE_checkbox, "value");
		bindingContext:AddBinding(Map3DSystem.UI.Creation, 
			"RandomSizeMin", "AdvancedCreationOptions.Min", commonlib.Binding.ControlTypes.ParaUI_editbox, "text");
		bindingContext:AddBinding(Map3DSystem.UI.Creation, 
			"RandomSizeMax", "AdvancedCreationOptions.Max", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
		
		bindingContext:UpdateControlsToData();
		
		Map3DSystem.UI.Creation.BindingContextAdvancedCreationOptions = bindingContext;
		
		local _this = ParaUI.CreateUIObject("button", "RandomFacing", "_lt", 20, 150, 64, 32);
		_this.text = "确定";
		_this.onclick = ";ParaUI.GetUIObject(\"AdvancedCreationOptions\").visible = false;Map3DSystem.UI.Creation.BindingContextAdvancedCreationOptions:UpdateControlsToData();";
		_parent:AddChild(_this);
	end
	
	-- create object above advanced sign
	
	-- 
end

--function Map3DSystem.UI.Creation.OnCategoryClick(category)
	--Map3DSystem.UI.Creation.ChangeToCategory(category);
	--Map3DSystem.UI.Creation.ResetPageInfo();
	--Map3DSystem.UI.Creation.RefreshIconMatrix();
--end
--
--function Map3DSystem.UI.Creation.ChangeToCategory(category)
--
	--if(category == "building") then
		--Map3DSystem.UI.Creation.CategoryIndex = 0;
	--elseif(category == "furniture") then
		--Map3DSystem.UI.Creation.CategoryIndex = 1;
	--elseif(category == "everyday") then
		--Map3DSystem.UI.Creation.CategoryIndex = 2;
	--elseif(category == "makeup") then
		--Map3DSystem.UI.Creation.CategoryIndex = 3;
	--elseif(category == "grass") then
		--Map3DSystem.UI.Creation.CategoryIndex = 4;
	--elseif(category == "props") then
		--Map3DSystem.UI.Creation.CategoryIndex = 5;
	--elseif(category == "character") then
		--Map3DSystem.UI.Creation.CategoryIndex = 6;
	--elseif(category == "trees") then
		--Map3DSystem.UI.Creation.CategoryIndex = 7;
	--end
	--
	---- TODO: directly update ObjEditor.CurrentAssetIndex
	--NPL.load("(gl)script/ide/object_editor.lua");
	--ObjEditor.CurrentAssetIndex = Map3DSystem.UI.Creation.CategoryIndex + 1;
--end

function Map3DSystem.UI.Creation.ResetPageInfo()

	-- TODO: directly access kids_db
	--local categoryTable = kids_db.items[Map3DSystem.UI.Creation.CategoryIndex];
	local categoryTable = Map3DSystem.DB.Items[Map3DSystem.UI.Creation.CategoryGroup];
	local nCount = table.getn(categoryTable);
	
	local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
	local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;

	local iconPerPage = iconMatrixX * iconMatrixY;
	
	local remain = math.mod(nCount, iconPerPage);
	if(remain == 0) then
		Map3DSystem.UI.Creation.TotalPage = nCount / iconPerPage;
	else
		Map3DSystem.UI.Creation.TotalPage = (nCount-remain) / iconPerPage + 1;
	end
	
	Map3DSystem.UI.Creation.TotalItem = nCount;
	Map3DSystem.UI.Creation.CurrentPage = 0;
end

-- NOTE: width is the panel width of resizing panel, can be nil
function Map3DSystem.UI.Creation.RefreshIconMatrix(width)
	
	if(width ~= nil) then
		local nCount = width - Map3DSystem.UI.MainPanel.SubPanelOffsetX * 2 - 60 - 10;
		
		local remain = math.mod(nCount, 60);
		local calMatrixX, calMatrixY = 0, 0;
		if(remain == 0) then
			calMatrixX = nCount / 60;
		else
			calMatrixX = (nCount-remain) / 60;
		end
		calMatrixY = 2;
		
		local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
		local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;
		
		
		if(calIconMatrixX ~= iconMatrixX) then
			
			local _panel = ParaUI.GetUIObject("MainBar_panel");
			local _sub_panel = _panel:GetChild("_sub_panel_creation");
			Map3DSystem.UI.Creation.IconMatrixX = calMatrixX;
			Map3DSystem.UI.Creation.IconMatrixY = calMatrixY;
			iconMatrixX = calMatrixX;
			iconMatrixY = calMatrixY;
			ParaUI.Destroy("_sub_panel_creation");
			_sub_panel = Map3DSystem.UI.Creation.CreateSubPanel(_panel);
			_sub_panel.width = width - Map3DSystem.UI.MainPanel.SubPanelOffsetX * 2;
			_sub_panel.visible = true;
		end
		
		Map3DSystem.UI.Creation.ResetPageInfo();
	end -- if(width ~= nil) then
	
	local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
	local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;
	
	local iconPerPage = iconMatrixX * iconMatrixY;
	local totalPage = Map3DSystem.UI.Creation.TotalPage;
	local totalItem = Map3DSystem.UI.Creation.TotalItem;
	local currentPage = Map3DSystem.UI.Creation.CurrentPage;
	
	local index = iconPerPage * currentPage + 1;

	--local categoryTable = kids_db.items[Map3DSystem.UI.Creation.CategoryIndex];
	local categoryTable = Map3DSystem.DB.Items[Map3DSystem.UI.Creation.CategoryGroup];
	
	local _this = ParaUI.GetUIObject("pageLabel");
	_this.text = ""..(currentPage + 1).."/"..(totalPage);
	
	for y=0, iconMatrixY - 1 do
		for x=0, iconMatrixX - 1 do
			
			_this = ParaUI.GetUIObject("creation_icon_matrix_"..x..y);
			
			if(_this:IsValid() == true) then
				if(index <= totalItem) then
					_this.tooltip = categoryTable[index]["IconAssetName"];
					_this.background = categoryTable[index]["IconFilePath"];
					
					--_this:SetActiveLayer("background");
					--_this.background = categoryTable[index]["IconFilePath"];
					--_this:SetActiveLayer("artwork");
					--_this.background = "";
					--_this:SetActiveLayer("background");
				else
					_this.tooltip = "";
					_this.background = "";
					
					_this:SetActiveLayer("background");
					_this.background = "";
					_this:SetActiveLayer("artwork");
					_this.background = "";
					_this:SetActiveLayer("background");
				end
			else
				log("Error refresh icon matrix\r\n");
			end
			
			index = index + 1;
		end
	end
end

function Map3DSystem.UI.Creation.OnPageLeftClick()

	local totalPage = Map3DSystem.UI.Creation.TotalPage;
	local totalItem = Map3DSystem.UI.Creation.TotalItem;
	local currentPage = Map3DSystem.UI.Creation.CurrentPage;
	
	if(currentPage <= 0) then
		-- No UI response
		-- TODO: probably some page collision sound
	else
		Map3DSystem.UI.Creation.CurrentPage = currentPage - 1;
		Map3DSystem.UI.Creation.RefreshIconMatrix();
	end
end

function Map3DSystem.UI.Creation.OnPageRightClick()

	local totalPage = Map3DSystem.UI.Creation.TotalPage;
	local totalItem = Map3DSystem.UI.Creation.TotalItem;
	local currentPage = Map3DSystem.UI.Creation.CurrentPage;
	
	if(currentPage >= totalPage - 1 ) then
		-- No UI response
		-- TODO: probably some page collision sound
	else
		Map3DSystem.UI.Creation.CurrentPage = currentPage + 1;
		Map3DSystem.UI.Creation.RefreshIconMatrix();
	end
end

function Map3DSystem.UI.Creation.OnIconMouseEnter(index)

	local totalPage = Map3DSystem.UI.Creation.TotalPage;
	local totalItem = Map3DSystem.UI.Creation.TotalItem;
	local currentPage = Map3DSystem.UI.Creation.CurrentPage;
	--local categoryIndex = Map3DSystem.UI.Creation.CategoryIndex;
	
	local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
	local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;
	
	local i = currentPage * iconMatrixX * iconMatrixY + index + 1;
	-- TODO: directly access kids_db
	--local item = kids_db.items[Map3DSystem.UI.Creation.CategoryIndex][i];
	local item = Map3DSystem.DB.Items[Map3DSystem.UI.Creation.CategoryGroup][i];
	if(item~=nil) then
		local asset = ParaAsset.LoadStaticMesh("", item.ModelFilePath);
		obj = ParaScene.CreateMeshObject("PreviewObject", asset, 1,1,1,0,false, "1,0,0,0,1,0,0,0,1,0,0,0");
		local att = obj:GetAttributeObject();
		att:SetField("progress", 1.0);
		att:SetField("render_tech", 7);
		
		local player = ParaScene.GetObject("<player>");
		local x,y,z = player:GetPosition();
		obj:SetPosition(x,y,z);
		ParaScene.Attach(obj);
		
		Map3DSystem.UI.Creation.PreviewObject = obj;
		Map3DSystem.UI.Creation.PreviewObjectScale = 1;
		Map3DSystem.UI.Creation.PreviewObjectFacing = 0;
		
		local indexNC = string.find(Map3DSystem.UI.Creation.CategoryGroup, "NC_");
		
		if(obj~=nil and obj:IsValid()==true and indexNC == 1) then
			-- this is a character
			local fNum = tonumber(item.Reserved3);
			if(fNum~=nil) then
				obj:SetScaling(fNum);
			end
			local fNum = tonumber(item.Reserved1);
			if(fNum~=nil) then
				obj:SetPhysicsRadius(fNum);
			end
			local fNum = tonumber(item.Reserved2);
			if(fNum~=nil) then
				obj:SetDensity(fNum);
			end
			---- make a newly created character NPC type. 
			--local att = obj:GetAttributeObject();
			--att:SetField("GroupID", CommonCtrl.CKidMiddleContainer.char_type[2].GroupID);
			--att:SetField("SentientField", CommonCtrl.CKidMiddleContainer.char_type[2].SentientField);
		end
		
						
		local ix = math.mod(index, iconMatrixX);
		if(ix == 0) then
			iy = index / iconMatrixX;
		else
			iy = (index - ix) / iconMatrixX;
		end
		
		--local _icon = ParaUI.GetUIObject("creation_icon_matrix_"..ix..iy);
		--Map3DSystem.UI.Creation.PreviewIconObj = _icon;
		--_icon:SetActiveLayer("artwork");
		--_icon.background = "Texture/3DMapSystem/MainPanel/CreationScaler.png";
		--_icon:SetActiveLayer("background");
	end
end

function Map3DSystem.UI.Creation.OnIconMouseLeave(index)
	local obj = Map3DSystem.UI.Creation.PreviewObject;
	if(obj ~= nil) then
		ParaScene.Delete(obj);
		Map3DSystem.UI.Creation.PreviewObject = nil;
		Map3DSystem.UI.Creation.PreviewObjectScale = 0;
		Map3DSystem.UI.Creation.PreviewObjectFacing = 0;
		
		local _icon = Map3DSystem.UI.Creation.PreviewIconObj;
		_icon:SetActiveLayer("artwork");
		_icon.background = "";
		_icon:SetActiveLayer("background");
		Map3DSystem.UI.Creation.PreviewIconObj = nil;
	end
end

function Map3DSystem.UI.Creation.OnIconMouseMove()
	local obj = Map3DSystem.UI.Creation.PreviewObject;
	if(obj ~= nil) then
		local mx, my = ParaUI.GetMousePosition();
		local _icon = Map3DSystem.UI.Creation.PreviewIconObj;
		local x, y, width, height = _icon:GetAbsPosition();
		local _scale = (mx - x)/width * 2 + 0.2;
		
		-- above 5/8 part of the icon is original size of preview
		-- below 3/8 part of the icon is a scaler preview
		if( (my - y) > height/8*3 ) then
			obj:SetScale(_scale);
		else
			obj:SetScale(1);
		end
	end
end

function Map3DSystem.UI.Creation.OnIconMouseWheel()
	local obj = Map3DSystem.UI.Creation.PreviewObject;
	if(obj) then
		local _facing = Map3DSystem.UI.Creation.PreviewObjectFacing;
		
		if(mouse_wheel == 1) then
			Map3DSystem.UI.Creation.PreviewObjectFacing = _facing + 0.2;
		elseif(mouse_wheel == -1) then
			Map3DSystem.UI.Creation.PreviewObjectFacing = _facing - 0.2;
		else
			log("large mouse_wheel: "..mouse_wheel.."\n");
		end
		
		obj:SetFacing(Map3DSystem.UI.Creation.PreviewObjectFacing);
	end
end

--[[ @Updated by LXZ 2008.2.8: this function is also used by the asset app to create preview model. 
get the objParams from an asset description table and its category.
@param category: the asset category name. such as  "BCS_buildingcomponents", "NM_normalmodel", "NC_normalcharacter", "CCS_customizablecharacter", the prefix decides the category. Known category is "BCS_", "NC_","NM_", "CCS_"
@param item: the asset description table. 
	asset = {
	  ["filename"] = "character/v1/01human/long/long.x",
	  ["Reserved1"] = "0.3",
	  ["text"] = "demo char",
	  ["Reserved3"] = "1",
	  ["Reserved2"] = "1.2",
	}
@return: objParams table is created. it may return nil. 
]]
function Map3DSystem.UI.Creation.GetObjParamsFromAsset(category, item)
	if(item == nil or not item.ModelFilePath) then return end
	if(not category) then
		-- if no category is provided, let the file name decides it. see if it begins with "character"
		if(string.find(item.ModelFilePath, "^[cC]haracter")) then
			category = "NC_NormalCharacter"
		else
			category = "NM_NormalModel"
		end	
	end
	-------------------------------
	-- Andy: see here. Xizhi 2007.10.14
	-- NOTE by Andy: update support to normal model, normal character and BCS objects
	-------------------------------
	local player = ParaScene.GetPlayer();
	local x,y,z= player:GetPosition();
	
	local obj_params = {};
	
	local indexBCS = string.find(category, "BCS_");
	if(Map3DSystem.UI.Creation.isBCSActive == true and indexBCS == 1) then
		-- this is a BCS object and BCS point is active
		obj_params.x = Map3DSystem.UI.Creation.CurrentMarkerPosX;
		obj_params.y = Map3DSystem.UI.Creation.CurrentMarkerPosY;
		obj_params.z = Map3DSystem.UI.Creation.CurrentMarkerPosZ;
		obj_params.AssetFile = item.ModelFilePath;
		obj_params.name = item.IconAssetName; -- added by Xizhi 2008.1.17.  give it a better name for blueprint app's bom view. 
		obj_params.localMatrix = Map3DSystem.UI.Creation.CurrentMarkerLocalMatrix;
		-- TODO: temporary used
		--obj_params.facing = Map3DSystem.UI.Creation.CurrentMarkerFacing;
		local obj = ParaScene.GetObject(obj_params.x, obj_params.y, obj_params.z, 0.005);
		if(obj:IsValid() == true) then
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = obj});
		end
	else
		-- set creation position and asset name
		obj_params.name = item.IconAssetName or "n";
		obj_params.AssetFile = item.ModelFilePath;
		obj_params.price = item.Price; -- additional info
		obj_params.x = x;
		obj_params.y = y;
		obj_params.z = z;
		
		local indexNC = string.find(category, "NC_");
		local indexCCS = string.find(category, "CCS_");
		if(indexNC == 1) then
			-- this is a normal character
			local player = ParaScene.GetObject("<player>");
			local playerFacing = player:GetFacing();
			obj_params.facing = playerFacing;
			obj_params.IsCharacter = true;
			obj_params.scaling = tonumber(item.Reserved3);
			obj_params.PhysicsRadius = tonumber(item.Reserved1);
			obj_params.Density = tonumber(item.Reserved2);
		elseif(indexCCS == 1) then
			-- this is a CCS character
			local player = ParaScene.GetObject("<player>");
			local playerFacing = player:GetFacing();
			obj_params.facing = playerFacing;
			obj_params.IsCharacter = true;
			obj_params.scaling = tonumber(item.Reserved3);
			obj_params.PhysicsRadius = tonumber(item.Reserved1);
			obj_params.Density = tonumber(item.Reserved2);
		end
	end
	return obj_params
end

-- user clicks an icon in the creation panel. 
function Map3DSystem.UI.Creation.OnIconClick(index)

	local totalPage = Map3DSystem.UI.Creation.TotalPage;
	local totalItem = Map3DSystem.UI.Creation.TotalItem;
	local currentPage = Map3DSystem.UI.Creation.CurrentPage;
	--local categoryIndex = Map3DSystem.UI.Creation.CategoryIndex;
	
	local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
	local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;

	--_guihelper.MessageBox("index:"..index.."\r\ntotalPage: "..totalPage.."\r\ntotalItem:"..totalItem
		--.."\r\ncurrentPage:"..currentPage.."\r\ncategoryIndex:"..categoryIndex);
	
	------------ copy from itembar_container.lua ------------
	ParaAudio.PlayUISound("Btn2");
	--if(not kids_db.User.CheckRight("Create")) then return end
	
	local i = currentPage * iconMatrixX * iconMatrixY + index + 1;
	-- TODO: directly access kids_db
	--local item = kids_db.items[Map3DSystem.UI.Creation.CategoryIndex][i];
	local item = Map3DSystem.DB.Items[Map3DSystem.UI.Creation.CategoryGroup][i];
	local obj_params = Map3DSystem.UI.Creation.GetObjParamsFromAsset(Map3DSystem.UI.Creation.CategoryGroup, item);
	
	if(obj_params ~= nil) then
		
		-- apply random facing
		if(Map3DSystem.UI.Creation.IsRandomFacing == true) then
			local lastFacing = Map3DSystem.UI.Creation.LastRandomFacing or 0;
			local thisFacing = ParaGlobal.random() * 6.28;
			
			while math.abs(lastFacing - thisFacing) < 1.57 or math.abs(lastFacing - thisFacing) > 4.71 do
				thisFacing = ParaGlobal.random() * 6.28;
			end
			obj_params.facing = thisFacing;
			Map3DSystem.UI.Creation.LastRandomFacing = thisFacing;
		end
		
		-- apply random size
		if(Map3DSystem.UI.Creation.IsRandomSize == true) then
			if((maxSize - minSize) < 0.05) then
				-- min and max values are so close
				obj_params.scaling = minSize + ParaGlobal.random() * (maxSize - minSize);
			else
				local minSize = tonumber(Map3DSystem.UI.Creation.RandomSizeMin);
				local maxSize = tonumber(Map3DSystem.UI.Creation.RandomSizeMax);
				local lastScaling = Map3DSystem.UI.Creation.LastRandomScaling or 0;
				local thisScaling = minSize + ParaGlobal.random() * (maxSize - minSize);
				
				while math.abs(lastScaling - thisScaling) < ((maxSize - minSize)*0.3) do
					thisScaling = minSize + ParaGlobal.random() * (maxSize - minSize);
				end
				
				obj_params.scaling = thisScaling;
				Map3DSystem.UI.Creation.LastRandomScaling = thisScaling;
			end
		end
		
		-- create object by sending a message
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params});
		
		
		if(obj_params.IsCharacter) then
			-- play "CreateCharacter" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "CreateCharacter",
					});
			-- play "CharacterBorn" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = Map3DSystem.obj.GetObjectParams("lastcreated"), -- newly create object
					animationName = "CharacterBorn",
					});
		else
			-- play "RaiseTerrain" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "RaiseTerrain",
					});
		end
		
		
		---- TODO: totally temporary use
		--if(Map3DSystem.UI.Creation.isBCSActive == true) then
			--log(Map3DSystem.UI.Creation.CurrentMarkerPosX.."\n");
			--local path = item.ModelFilePath;
			--local pos = {Map3DSystem.UI.Creation.CurrentMarkerPosX,
					--Map3DSystem.UI.Creation.CurrentMarkerPosY,
					--Map3DSystem.UI.Creation.CurrentMarkerPosZ};
			--local reserved = {};
			--reserved.localMatrix = Map3DSystem.UI.Creation.CurrentMarkerLocalMatrix;
			---- TODO: temporary used
			--reserved.facing = Map3DSystem.UI.Creation.CurrentMarkerFacing;
			--
			--CommonCtrl.CKidItemsContainer.CreateItem(path, pos, nil, reserved);
		--else
			---- create object by sending a message 
			--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params});
		--end
	end
	------------ copy from itembar_container.lua ------------
end

function Map3DSystem.UI.Creation.CloseUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_creation");
		if(_sub_panel:IsValid() == false) then
			log("Creation panel container is not yet initialized.\r\n");
		else
			-- show creation sub panel
			_sub_panel.visible = false;
		end
	else
		log("error: MainBar panel container is not yet initialized.\r\n");
	end
end

function Map3DSystem.UI.Creation.OnClickSubIconSet(subIconIndex)
	log("Creation SubIconIndex:"..subIconIndex.." clicked\r\n");
	--Map3DSystem.UI.MainPanel.OnClickIcon(1);
	Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_ClickIcon, index = 1});
end

-- called in XRef script
function Map3DSystem.UI.Creation.OnRecvBCSMSG(msg)
	
	Map3DSystem.Animation.SendMeMessage({
			type = Map3DSystem.msg.ANIMATION_Character,
			obj_params = nil, --  <player>
			animationName = "SelectObject",
			});
	
	local BCSMarkerGraph = ParaScene.GetMiniSceneGraph("BCSMarker");
	BCSMarkerGraph:SetName("BCSMarker");
	local obj = BCSMarkerGraph:GetObject("Marker");
	
	if(obj:IsValid() == false) then
		--obj = ParaScene.CreateMeshPhysicsObject("Marker", 
			--Map3DSystem.Assets["CharMaker"], 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
		obj = ParaScene.CreateCharacter("Marker", 
			Map3DSystem.Assets["BCSSelectMarker"], "", true, 0.35, 0, 1);
		BCSMarkerGraph:AddChild(obj);
		if(obj:IsValid() == true) then
			--obj:SetPosition(msg.posX, msg.posY, msg.posZ);
			--obj:SetScale(1.5);
			obj:SetPosition(msg.posX, msg.posY + 0.05, msg.posZ);
			obj:SetScale(1.0);
		end
	else
		obj:SetPosition(msg.posX, msg.posY, msg.posZ);
	end
	
	--Map3DSystem.UI.Creation.CurrentMarkerPosX = msg.posX;
	--Map3DSystem.UI.Creation.CurrentMarkerPosY = msg.posY;
	--Map3DSystem.UI.Creation.CurrentMarkerPosZ = msg.posZ;
	--Map3DSystem.UI.Creation.CurrentMarkerFacing = msg.facing;
	--Map3DSystem.UI.Creation.CurrentMarkerLocalMatrix = msg.localMatrix;
	
	Map3DSystem.UI.Creator.CurrentMarkerPosX = msg.posX;
	Map3DSystem.UI.Creator.CurrentMarkerPosY = msg.posY;
	Map3DSystem.UI.Creator.CurrentMarkerPosZ = msg.posZ;
	Map3DSystem.UI.Creator.CurrentMarkerFacing = msg.facing;
	Map3DSystem.UI.Creator.CurrentMarkerLocalMatrix = msg.localMatrix;
	
	--------------------------------------------------------------------------------------
	-- NOTE by Andy 2008-5-26: add creator tab grid window
	--------------------------------------------------------------------------------------
	local ctl = CommonCtrl.GetControl("CreationTabGrid");
	if(ctl ~= nil) then
		
		--Map3DSystem.UI.Creation.isBCSActive = true;
		Map3DSystem.UI.Creator.isBCSActive = true;
		
		local _app = Map3DSystem.App.Creator.app._app;
		local _wnd = _app:FindWindow("MainWnd");
		if(_wnd ~= nil) then
			_wnd:SendMessage(_wnd.name, {type = Map3DSystem.msg.CREATOR_RECV_BCSMSG, msg = msg});
		end
		
		return;
	else
		---- switch panel display
		--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_SwitchStatus, sStatus = "BCSXRef"});
		---- switch panel display
		--Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_ShowDefault});
		
		---- call hook for "deselect"
		--if(CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 0, "selection", {type = "select_BCSXRef"}) ==nil) then
			--return
		--end
		
		-- TODO: copied from mainbar.lua, rewrite the code in message-driven form
		--local _icon = ParaUI.GetUIObject("MainBar_icons_1");
		local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Main");
		local x, y, width, height = _icon:GetAbsPosition();
		local offset = 0;
		
		local _panel = ParaUI.GetUIObject("MainBar_panel");
		local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
		
		if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == nil) then
			_panel.x = x - offset;
			_panel_behind.x = x - offset;
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = 1;
			_panel.visible = true;
			_panel:BringToFront();
			_panel_behind.visible = true;
			-- show creation panel
			Map3DSystem.UI.MainPanel.PreShowPanelUI(1);
			Map3DSystem.UI.MainBar.IconSet[1].ShowUICallback();

		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 1) then
			
		else
			_panel.x = x - offset;
			_panel_behind.x = x - offset;
			-- unshow Map3DSystem.UI.MainPanel.CurrentActivePanelIndex panel
			Map3DSystem.UI.MainBar.IconSet[Map3DSystem.UI.MainPanel.CurrentActivePanelIndex].CloseUICallback();
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = 1;
			-- show creation panel
			Map3DSystem.UI.MainPanel.PreShowPanelUI(1);
			Map3DSystem.UI.MainBar.IconSet[1].ShowUICallback();
		end
	end
	
	
	
	--local ctl = CommonCtrl.GetControl("treeViewCreation");
	--local _rootnode = ctl.RootNode;
	--local _node = ctl.RootNode;
	--local k, v;
	--for k, v in pairs(Map3DSystem.DB.Groups) do
		--if(v.parent == "Root") then
			---- lvl 1 node
			--_node = _rootnode:GetChildByName(v.name);
			---- TODO: dirty collapse all lvl 1 node
			--_node:CollapseAll();
			--if(v.name == "BCS") then
				--_node:Expand();
			--end
		--end
	--end
	--
	--ctl:Update();
	
	
	--------------------------------------------------------------------------------------
	-- NOTE by Andy 2008-3-7: change default category for "free" and "base" XRef type
	--------------------------------------------------------------------------------------
	
	if(msg.XRefType == "free") then
		--Map3DSystem.UI.Creation.SetCategoryGroup("BCS_01base");
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_08deco");
	elseif(msg.XRefType == "wall") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_08deco");
	elseif(msg.XRefType == "blocktop") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_03blocktop");
	elseif(msg.XRefType == "ground") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_01base");
	elseif(msg.XRefType == "window") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_06window");
	elseif(msg.XRefType == "door") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_05door");
	elseif(msg.XRefType == "block") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_02block");
	elseif(msg.XRefType == "base") then
		--Map3DSystem.UI.Creation.SetCategoryGroup("BCS_02block");
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_01base");
	elseif(msg.XRefType == "stairs") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_04stairs");
	elseif(msg.XRefType == "chimney") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_07chimney");
	elseif(msg.XRefType == "frametop") then
		Map3DSystem.UI.Creation.SetCategoryGroup("BCS_08deco");
	end
	
	
	--BCS_01base
	--BCS_02block
	--BCS_03blocktop
	--BCS_04stairs
	--BCS_05door
	--BCS_06window
	--BCS_07chimney
	--BCS_08deco
	
	
	
	--NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	--Map3DSystem.Misc.SaveTableToFile(msg, "TestTable/BCSMSG.ini");
	
	--msg.XRefType = "ground";
	
	--local msg = {};
	--msg.posX, msg.posY, msg.posZ = toX, toY, toZ;
	--msg.scaleX, msg.scaleY, msg.scaleZ = closestObj:GetXRefScriptScaling(subIndex);
	--msg.facing = closestObj:GetXRefScriptFacing(subIndex);
	--msg.dist = min_dist;
	--msg.localMatrix = closestObj:GetXRefScriptLocalMatrix(subIndex);
end