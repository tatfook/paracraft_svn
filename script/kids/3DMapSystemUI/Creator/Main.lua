--[[
Title: creator application main window
Author(s): WangTian
Date: 2008/5/26
Desc: Creator application window is upgraded to the new aura look, including:
		show the window on the side instead of bottom to utilize more screen space 
		show the items in grid view form
		fit to window size automaticly
		categories are arranged on the top and left(/right) side of the grid view
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

if(not Map3DSystem.UI.Creator) then Map3DSystem.UI.Creator = {}; end

-- Show the creator main window
function Map3DSystem.UI.Creator.ShowMainWnd3(bShow)
	local _app = Map3DSystem.App.Creator.app._app;
	local _wnd = _app:FindWindow("MainWnd") or _app:RegisterWindow("MainWnd", nil, Map3DSystem.UI.Creator.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	
	if(frame ~= nil) then
		frame:Show2(bShow);
		return;
	end
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialPosX = 720, 
		initialPosY = 10, 
		initialWidth = 300, -- initial width of the window client area
		initialHeight = 600, -- initial height of the window client area
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		isFastRender = true,
		
		ShowUICallback = Map3DSystem.UI.Creator.Show,
	};
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow);
end

-- Show the creator main window
function Map3DSystem.UI.Creator.ShowMainWnd(bShow)
	local _app = Map3DSystem.App.Creator.app._app;
	local _wnd = _app:FindWindow("MainWnd") or _app:RegisterWindow("MainWnd", nil, Map3DSystem.UI.Creator.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	
	if(frame ~= nil) then
		frame:Show2(bShow);
		return;
	end
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		isShowTitleBar = false, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialPosX = 700, 
		initialPosY = 175, 
		initialWidth = 320, -- initial width of the window client area
		initialHeight = 440, -- initial height of the window client area
		
		directPosition = true,
			align = "_rb",
			x = -320,
			y = -520,
			width = 320,
			height = 440,
			
		-- allowDrag = false,
		opacity = 90,
		
		style = {
			window_bg = "Texture/3DMapSystem/Creator/window_bg.png:16 16 16 16",
			borderLeft = 0,
			borderRight = 0,
			resizerSize = 24,
			resizer_bg = "",
		},
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		isFastRender = true,
		
		ShowUICallback = Map3DSystem.UI.Creator.Show2,
	};
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow);
end

-- destory the main window, usually called when the world is closed
function Map3DSystem.UI.Creator.DestroyMainWnd()
	local _app = Map3DSystem.App.Creator.app._app;
	local _wnd = _app:FindWindow("MainWnd");
	
	if(_wnd ~= nil) then
		NPL.load("(gl)script/ide/WindowFrame.lua");
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:Destroy();
		end
		CommonCtrl.DeleteControl("CreationTabGrid");
	end
end

-- change the main window size, usually called on resolution change
function Map3DSystem.UI.Creator.OnSize(width, height)
	local ctl = CommonCtrl.GetControl("CreationTabGrid");
	if(ctl ~= nil) then
		ctl:OnSize(width, height);
	end
end

-- Message Processor of Creator main control
-- On receive WM_SIZE message it will update the CreationTabGrid control
function Map3DSystem.UI.Creator.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		Map3DSystem.UI.Creator.OnSize(msg.width, msg.height);
	
	elseif(msg.type == Map3DSystem.msg.CREATOR_RECV_ANYTHING) then
		Map3DSystem.UI.Creator.CreateAnythingOnX = msg.posX;
		Map3DSystem.UI.Creator.CreateAnythingOnY = msg.posY;
		Map3DSystem.UI.Creator.CreateAnythingOnZ = msg.posZ;
		Map3DSystem.UI.Creator.CreateAnythingOnFacing = msg.facing;
		Map3DSystem.UI.Creator.CreateAnythingOnLocalMatrix = msg.localMatrix;
		local player = ParaScene.GetPlayer();
		local asset = ParaAsset.LoadParaX("", "character/common/headarrow/headarrow.x");
		if(asset ~= nil and asset:IsValid() == true) then
			player:ToCharacter():RemoveAttachment(11);
			player:ToCharacter():AddAttachment(asset, 11);
		end
		
		local obj = ParaScene.GetObject("CreateAnythingMarker");
		if(obj:IsValid() == true) then
			obj:SetPosition(msg.posX, msg.posY, msg.posZ);
			obj:SetScale(1.0);
			return;
		end
		
		local obj = ParaScene.CreateCharacter("CreateAnythingMarker", Map3DSystem.Assets["BCSSelectMarker"], "", true, 0.35, 0, 1);
		obj:SetPosition(msg.posX, msg.posY, msg.posZ);
		obj:SetScale(1.0);
		ParaScene.Attach(obj);
			
		autotips.AddMessageTips("下一个创造的任何物体将在刚刚点击的XRef创建");
	elseif(msg.type == Map3DSystem.msg.CREATOR_RECV_BCSMSG) then
		-- moved from creation.lua by LXZ 2008.7.8
		-- 
		-- In BCS Xref script, we usually call below
		-- local app = Map3DSystem.App.AppManager.GetApp("Creator_GUID")
		-- if(app) then
		--		msg.type = Map3DSystem.msg.CREATOR_RECV_BCSMSG;
		--		msg.XRefType = "window";
		--		app:SendMessage(msg, "MainWnd")
		-- end
		--
		local ctl = CommonCtrl.GetControl("CreationTabGrid");
		if(ctl == nil) then
			return;
		end
		Map3DSystem.UI.Creator.isBCSActive = true;
		
		Map3DSystem.Animation.SendMeMessage({
			type = Map3DSystem.msg.ANIMATION_Character,
			obj_params = nil, --  <player>
			animationName = "SelectObject",
			facingTarget = {x=msg.posX, y=msg.posY, z=msg.posZ}, -- by LXZ 2008.7.9
		});
		local BCSMarkerGraph = ParaScene.GetMiniSceneGraph("BCSMarker");
		BCSMarkerGraph:SetName("BCSMarker");
		local obj = BCSMarkerGraph:GetObject("Marker");
		if(obj:IsValid() == false) then
			obj = ParaScene.CreateCharacter("Marker", 
				Map3DSystem.Assets["BCSSelectMarker"], "", true, 0.35, 0, 1);
			BCSMarkerGraph:AddChild(obj);
			if(obj:IsValid() == true) then
				obj:SetPosition(msg.posX, msg.posY + 0.05, msg.posZ);
				obj:SetScale(1.0);
			end
		else
			obj:SetPosition(msg.posX, msg.posY, msg.posZ);
		end
		
		Map3DSystem.UI.Creator.CurrentMarkerPosX = msg.posX;
		Map3DSystem.UI.Creator.CurrentMarkerPosY = msg.posY;
		Map3DSystem.UI.Creator.CurrentMarkerPosZ = msg.posZ;
		Map3DSystem.UI.Creator.CurrentMarkerFacing = msg.facing;
		Map3DSystem.UI.Creator.CurrentMarkerLocalMatrix = msg.localMatrix;
		
		local ctl2 = CommonCtrl.GetControl("Creator_TabControl_BCS");
		if(ctl2 == nil) then
			log("nil Creator_TabControl_BCS control\n");
		end
		
		if(msg.XRefType == "free") then
			ctl:SetLevelIndex(2, 9);
			ctl2:SetSelectedIndex(9);
		elseif(msg.XRefType == "wall") then
			ctl:SetLevelIndex(2, 9);
			ctl2:SetSelectedIndex(9);
		elseif(msg.XRefType == "blocktop") then
			ctl:SetLevelIndex(2, 4);
			ctl2:SetSelectedIndex(4);
		elseif(msg.XRefType == "ground") then
			ctl:SetLevelIndex(2, 1);
			ctl2:SetSelectedIndex(1);
		elseif(msg.XRefType == "window") then
			ctl:SetLevelIndex(2, 7);
			ctl2:SetSelectedIndex(7);
		elseif(msg.XRefType == "door") then
			ctl:SetLevelIndex(2, 6);
			ctl2:SetSelectedIndex(6);
		elseif(msg.XRefType == "groundfloor") then
			ctl:SetLevelIndex(2, 2); -- groundfloor added to differ ground block and above
			ctl2:SetSelectedIndex(2);
		elseif(msg.XRefType == "block") then
			ctl:SetLevelIndex(2, 3);
			ctl2:SetSelectedIndex(3);
		elseif(msg.XRefType == "base") then
			ctl:SetLevelIndex(2, 1);
			ctl2:SetSelectedIndex(1);
		elseif(msg.XRefType == "stairs") then
			ctl:SetLevelIndex(2, 5);
			ctl2:SetSelectedIndex(5);
		elseif(msg.XRefType == "chimney") then
			ctl:SetLevelIndex(2, 8);
			ctl2:SetSelectedIndex(8);
		elseif(msg.XRefType == "frametop") then
			ctl:SetLevelIndex(2, 9);
			ctl2:SetSelectedIndex(9);
		end
		
	end
end

function Map3DSystem.UI.Creator.Hook_ObjectSelection(nCode, appName, msg)
	if(msg.type== Map3DSystem.msg.OBJ_DeselectObject) then
		Map3DSystem.UI.Creator.OnDeactivate();
		Map3DSystem.UI.Creator.CreateAnythingOnX = nil;
		Map3DSystem.UI.Creator.CreateAnythingOnY = nil;
		Map3DSystem.UI.Creator.CreateAnythingOnZ = nil;
		Map3DSystem.UI.Creator.CreateAnythingOnLocalMatrix = nil;
		
		local obj = ParaScene.GetObject("CreateAnythingMarker")
		if(obj:IsValid() == true) then
			ParaScene.Delete(obj);
		end
		local player = ParaScene.GetPlayer();
		player:ToCharacter():RemoveAttachment(11);
	end
end

-- exit BCS mode and clear miniscenegraph
-- this function is also called when creator desktop is switched off. -- lxz 2008.6.15
function Map3DSystem.UI.Creator.OnDeactivate()
	-- clear the XRef
	Map3DSystem.UI.Creator.isBCSActive = false;
	local BCSMarkerGraph = ParaScene.GetMiniSceneGraph("BCSMarker");
	BCSMarkerGraph:Reset();
end

-- @param index: 1 normal model
--				 2 BCS
--				 3 normal character
function Map3DSystem.UI.Creator.SwitchCategory(index)
	local _nm = ParaUI.GetUIObject("Tab_NM");
	local _bcs = ParaUI.GetUIObject("Tab_BCS");
	local _nc = ParaUI.GetUIObject("Tab_NC");
	if(_nm:IsValid() == true and _bcs:IsValid() == true and _nc:IsValid() == true) then
		if(index == 1) then
			_nm.visible = true;
			_bcs.visible = false;
			_nc.visible = false;
			local _icon = ParaUI.GetUIObject("Creator_Lvl1_Icon");
			_icon.background = "Texture/3DMapSystem/Creator/Level1_NM.png";
			local _text = ParaUI.GetUIObject("Creator_Lvl1_Text");
			_text.text = "模型\n左键点击图标确认选择;\n右键点击图标预览";
		elseif(index == 2) then
			_nm.visible = false;
			_bcs.visible = true;
			_nc.visible = false;
			local _icon = ParaUI.GetUIObject("Creator_Lvl1_Icon");
			_icon.background = "Texture/3DMapSystem/Creator/Level1_BCS.png";
			local _text = ParaUI.GetUIObject("Creator_Lvl1_Text");
			_text.text = "建筑部件\n左键点击图标确认选择;\n右键点击图标预览";
		elseif(index == 3) then
			_nm.visible = false;
			_bcs.visible = false;
			_nc.visible = true;
			local _icon = ParaUI.GetUIObject("Creator_Lvl1_Icon");
			_icon.background = "Texture/3DMapSystem/Creator/Level1_NC.png";
			local _text = ParaUI.GetUIObject("Creator_Lvl1_Text");
			_text.text = "人物\n左键点击图标创建人物;\n右键点击图标预览";
		end
	end
end

function Map3DSystem.UI.Creator.Close()
	local _app = Map3DSystem.App.Creator.app._app;
	local _wnd = _app:FindWindow("MainWnd") or _app:RegisterWindow("MainWnd", nil, Map3DSystem.UI.Creator.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	
	if(frame ~= nil) then
		frame:Show2(false);
	end
end
local level1Nodes = {};

function Map3DSystem.UI.Creator.Show2(bShow, _parent, parentWindow)
	-- left top category icon, indicating the current main category of the creator
	local _bg = ParaUI.CreateUIObject("container", "Creator_BG", "_lt", 16, 16, 40, 40);
	_bg.background = "Texture/3DMapSystem/Creator/icon_bg.png";
	_bg.enabled = false;
	_parent:AddChild(_bg);
	
	local _icon = ParaUI.CreateUIObject("container", "Creator_Lvl1_Icon", "_lt", 20, 20, 32, 32);
	_icon.enabled = false;
	_parent:AddChild(_icon);
	
	local _this = ParaUI.CreateUIObject("text", "Creator_Lvl1_Text", "_lt", 64, 16, 200, 40);
	_this.text = "模型：\n Line1\n Line2";
	_guihelper.SetFontColor(_this, "#FFFFFF");
	_parent:AddChild(_this);
	
	local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -36, 4, 32, 32);
	_close.background = "Texture/3DMapSystem/Creator/close.png";
	_close.onclick = ";Map3DSystem.UI.Creator.Close();";
	_parent:AddChild(_close);
	
	NPL.load("(gl)script/ide/TreeView.lua");
	local tabPagesNode_NM = CommonCtrl.TreeNode:new({Name = "Creator_TabControlRootNode_NM"});
	local tabPagesNode_BCS = CommonCtrl.TreeNode:new({Name = "Creator_TabControlRootNode_BCS"});
	local tabPagesNode_NC = CommonCtrl.TreeNode:new({Name = "Creator_TabControlRootNode_NC"});
	
	local k, v;
	for k, v in ipairs(Map3DSystem.DB.Groups) do
		if(v.parent == "Normal Model") then
			tabPagesNode_NM:AddChild(CommonCtrl.TreeNode:new({name=v.name, tooltip = v.tooltip, icon = v.icon}));
		elseif(v.parent == "BCS") then
			tabPagesNode_BCS:AddChild(CommonCtrl.TreeNode:new({name=v.name, tooltip = v.tooltip, icon = v.icon}));
		elseif(v.parent == "Normal Character") then
			tabPagesNode_NC:AddChild(CommonCtrl.TreeNode:new({name=v.name, tooltip = v.tooltip, icon = v.icon}));
		end
	end
	
	-- Bug fixed by LiXizhi: 2008.11.03, the current implementation reply on the DB.Groups order. However, the order is arbitrary. 
	-- we need to sort after inserting. 
	tabPagesNode_NM:SortChildren(CommonCtrl.TreeNode.GenerateLessCFByField("name"));
	tabPagesNode_BCS:SortChildren(CommonCtrl.TreeNode.GenerateLessCFByField("name"));
	tabPagesNode_NC:SortChildren(CommonCtrl.TreeNode.GenerateLessCFByField("name"));
	level1Nodes[1] = tabPagesNode_NM;
	level1Nodes[2] = tabPagesNode_BCS;
	level1Nodes[3] = tabPagesNode_NC;
	
	local _tab_NM = ParaUI.CreateUIObject("container", "Tab_NM", "_mr", 16, 70, 60, 16);
	_tab_NM.background = "";
	_parent:AddChild(_tab_NM);
	local _tab_BCS = ParaUI.CreateUIObject("container", "Tab_BCS", "_mr", 16, 70, 60, 16);
	_tab_BCS.background = "";
	_parent:AddChild(_tab_BCS);
	local _tab_NC = ParaUI.CreateUIObject("container", "Tab_NC", "_mr", 16, 70, 60, 16);
	_tab_NC.background = "";
	_parent:AddChild(_tab_NC);
	
	local _creatorSelector = ParaUI.CreateUIObject("container", "CreatorSelector", "_fi", 16, 70, 76, 16);
	_creatorSelector.background = "";
	_parent:AddChild(_creatorSelector);
	
	
	NPL.load("(gl)script/ide/TabControl.lua");
	local ctl = CommonCtrl.TabControl:new{
			name = "Creator_TabControl_NM",
			parent = _tab_NM,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TabAlignment = "Right", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_NM, -- CommonCtrl.TreeNode object, collection of tab pages
			TabHeadOwnerDraw = function(_parent, tabControl) 
					local _head = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_head.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 0 32 14:20 13 11 0";
					_head.enabled = false;
					_parent:AddChild(_head);
					local _head = ParaUI.CreateUIObject("button", "Item", "_lb", 20, -40, 32, 32);
					_head.background = "Texture/3DMapSystem/Creator/PageUp.png";
					_head.onclick = ";CommonCtrl.TabControl.PageBackward(\""..tabControl.name.."\");";
					_parent:AddChild(_head);
				end, --function(_parent, tabControl) end, -- area between top/left border and the first item
			TabTailOwnerDraw = function(_parent, tabControl) 
					local _tail = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_tail.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 52 32 12:20 0 11 11";
					_tail.enabled = false;
					_parent:AddChild(_tail);
					local _tail = ParaUI.CreateUIObject("button", "Item", "_lt", 20, 8, 32, 32);
					_tail.background = "Texture/3DMapSystem/Creator/PageDown.png";
					_tail.onclick = ";CommonCtrl.TabControl.PageForward(\""..tabControl.name.."\");";
					_parent:AddChild(_tail);
				end, --function(_parent, tabControl) end, -- area between the last item and buttom/right border
			TabStartOffset = 60, -- start of the tabs from the border
			TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) 
					if(bSelected == true) then
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 14 32 37:17 16 14 16";
						_item.enabled = false;
						_parent:AddChild(_item);
					else
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 11 32 3:20 1 11 1";
						_item.enabled = false;
						_parent:AddChild(_item);
					end
					local node = tabControl.TabPages:GetChild(index);
					local _item = ParaUI.CreateUIObject("button", "Item", "_lt", 22, 8, 32, 32);
					_item.background = node.icon;
					_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", tabControl.name, index);
					_parent:AddChild(_item);
				end, --function(_parent, index, bSelected, tabControl) end, -- owner draw item
			TabItemWidth = 60, -- width of each tab item
			TabItemHeight = 48, -- height of each tab item
			MaxTabNum = 5, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex)
				local ctl = CommonCtrl.GetControl("CreationTabGrid");
				if(ctl ~= nil) then
					ctl:SetLevelIndex(1, toIndex);
				end
			end,
		};
	ctl:Show(true);
	
	local ctl = CommonCtrl.TabControl:new{
			name = "Creator_TabControl_BCS",
			parent = _tab_BCS,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TabAlignment = "Right", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_BCS, -- CommonCtrl.TreeNode object, collection of tab pages
			TabHeadOwnerDraw = function(_parent, tabControl) 
					local _head = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_head.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 0 32 14:20 13 11 0";
					_head.enabled = false;
					_parent:AddChild(_head);
					local _head = ParaUI.CreateUIObject("button", "Item", "_lb", 20, -40, 32, 32);
					_head.background = "Texture/3DMapSystem/Creator/PageUp.png";
					_head.onclick = ";CommonCtrl.TabControl.PageBackward(\""..tabControl.name.."\");";
					_parent:AddChild(_head);
				end, --function(_parent, tabControl) end, -- area between top/left border and the first item
			TabTailOwnerDraw = function(_parent, tabControl) 
					local _tail = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_tail.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 52 32 12:20 0 11 11";
					_tail.enabled = false;
					_parent:AddChild(_tail);
					local _tail = ParaUI.CreateUIObject("button", "Item", "_lt", 20, 8, 32, 32);
					_tail.background = "Texture/3DMapSystem/Creator/PageDown.png";
					_tail.onclick = ";CommonCtrl.TabControl.PageForward(\""..tabControl.name.."\");";
					_parent:AddChild(_tail);
				end, --function(_parent, tabControl) end, -- area between the last item and buttom/right border
			TabStartOffset = 60, -- start of the tabs from the border
			TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) 
					if(bSelected == true) then
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 14 32 37:17 16 14 16";
						_item.enabled = false;
						_parent:AddChild(_item);
					else
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 11 32 3:20 1 11 1";
						_item.enabled = false;
						_parent:AddChild(_item);
					end
					local node = tabControl.TabPages:GetChild(index);
					local _item = ParaUI.CreateUIObject("button", "Item", "_lt", 22, 8, 32, 32);
					_item.background = node.icon;
					_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", tabControl.name, index);
					_parent:AddChild(_item);
				end, --function(_parent, index, bSelected, tabControl) end, -- owner draw item
			TabItemWidth = 60, -- width of each tab item
			TabItemHeight = 48, -- height of each tab item
			MaxTabNum = 5, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex)
				local ctl = CommonCtrl.GetControl("CreationTabGrid");
				if(ctl ~= nil) then
					ctl:SetLevelIndex(2, toIndex);
				end
			end,
		};
	ctl:Show(true);
	
	local ctl = CommonCtrl.TabControl:new{
			name = "Creator_TabControl_NC",
			parent = _tab_NC,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TabAlignment = "Right", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_NC, -- CommonCtrl.TreeNode object, collection of tab pages
			TabHeadOwnerDraw = function(_parent, tabControl) 
					local _head = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_head.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 0 32 14:20 13 11 0";
					_head.enabled = false;
					_parent:AddChild(_head);
					local _head = ParaUI.CreateUIObject("button", "Item", "_lb", 20, -40, 32, 32);
					_head.background = "Texture/3DMapSystem/Creator/PageUp.png";
					_head.onclick = ";CommonCtrl.TabControl.PageBackward(\""..tabControl.name.."\");";
					_parent:AddChild(_head);
				end, --function(_parent, tabControl) end, -- area between top/left border and the first item
			TabTailOwnerDraw = function(_parent, tabControl) 
					local _tail = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_tail.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 52 32 12:20 0 11 11";
					_tail.enabled = false;
					_parent:AddChild(_tail);
					local _tail = ParaUI.CreateUIObject("button", "Item", "_lt", 20, 8, 32, 32);
					_tail.background = "Texture/3DMapSystem/Creator/PageDown.png";
					_tail.onclick = ";CommonCtrl.TabControl.PageForward(\""..tabControl.name.."\");";
					_parent:AddChild(_tail);
				end, --function(_parent, tabControl) end, -- area between the last item and buttom/right border
			TabStartOffset = 60, -- start of the tabs from the border
			TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) 
					if(bSelected == true) then
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 14 32 37:17 16 14 16";
						_item.enabled = false;
						_parent:AddChild(_item);
					else
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;32 11 32 3:20 1 11 1";
						_item.enabled = false;
						_parent:AddChild(_item);
					end
					local node = tabControl.TabPages:GetChild(index);
					local _item = ParaUI.CreateUIObject("button", "Item", "_lt", 22, 8, 32, 32);
					_item.background = node.icon;
					_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", tabControl.name, index);
					_parent:AddChild(_item);
				end, --function(_parent, index, bSelected, tabControl) end, -- owner draw item
			TabItemWidth = 60, -- width of each tab item
			TabItemHeight = 48, -- height of each tab item
			MaxTabNum = 5, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex)
				local ctl = CommonCtrl.GetControl("CreationTabGrid");
				if(ctl ~= nil) then
					ctl:SetLevelIndex(3, toIndex);
				end
			end,
		};
	ctl:Show(true);
	
	
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
	
	local ctl = CommonCtrl.GetControl("CreationTabGrid");
	if(ctl == nil) then
		local param = {
			name = "CreationTabGrid",
			parent = _creatorSelector,
			background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;0 0 32 64:16 16 1 16",
			wnd = wnd,
			
			----------- CATEGORY REGION -----------
			Level1 = "Top",
			Level1BG = "",
			Level1HeadBG = "",
			Level1TailBG = "",
			Level1Offset = 10,
			Level1ItemWidth = 90,
			Level1ItemHeight = 0, -- 0 height to hide level1 selector
			--Level1ItemGap = 32,
			--Level1ItemVistaStyle = 4;
			
			Level1ItemOwnerDraw = function (_parent, level1index, bSelected, tabGrid)
				-- background
				if(bSelected) then
					local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
					_back.background = tabGrid.GetLevel1ItemSelectedBackImage(level1index);
					_parent:AddChild(_back);
				else
					local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
					_back.background = tabGrid.GetLevel1ItemUnselectedBackImage(level1index);
					_parent:AddChild(_back);
				end
				
				-- icon
				local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 14, 8, 32, 32);
				if(bSelected) then
					_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
				else
					_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
				end
				_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
						tabGrid.name, level1index);
				_parent:AddChild(_btn);
				
				-- text
				local _text = ParaUI.CreateUIObject("button", "text"..level1index, "_lt", 0, 0, 124, 48);
				_text.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
						tabGrid.name, level1index);
				_text.background = "";
				if(level1index == 1) then
					_text.text = "模型";
				elseif(level1index == 2) then
					_text.text = "部件";
				elseif(level1index == 3) then
					_text.text = "人物";
				end
				if(bSelected) then
					_guihelper.SetFontColor(_text, "0 0 0");
				else
					_guihelper.SetFontColor(_text, "255 255 255");
				end
				_parent:AddChild(_text);
			end,
			
			Level2 = "Right",
			Level2BG = "",
			Level2HeadBG = "",
			Level2TailBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGBottom.png; 0 0 50 64: 1 0 1 56",
			Level2Offset = 50,
			Level2ItemWidth = 0,
			Level2ItemHeight = 50,
			--Level2ItemGap = 8,
			
			Level2ItemOwnerDraw = function (_parent, level2index, bSelected, tabGrid)
				-- background
				if(bSelected) then
					local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
					_back.background = tabGrid.GetLevel2ItemSelectedBackImage(level2index);
					_parent:AddChild(_back);
				else
					local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
					_back.background = tabGrid.GetLevel2ItemUnselectedBackImage(level2index);
					_parent:AddChild(_back);
				end
				
				-- icon
				local _btn = ParaUI.CreateUIObject("button", "btn"..level2index, "_lt", 11, 9, 32, 32);
				if(bSelected) then
					_btn.background = tabGrid.GetLevel2ItemSelectedForeImage(tabGrid.CurrentFocusLevel1ItemIndex, level2index);
				else
					_btn.background = tabGrid.GetLevel2ItemUnselectedForeImage(tabGrid.CurrentFocusLevel1ItemIndex, level2index);
				end
				_btn.tooltip = tabGrid.GetLevel2ItemTooltip(tabGrid.CurrentFocusLevel1ItemIndex, level2index);
				_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", nil, %d);]], 
						tabGrid.name, level2index);
				_parent:AddChild(_btn);
			end,
			
			----------- GRID REGION -----------
			nGridBorderLeft = 0,
			nGridBorderTop = 16,
			nGridBorderRight = 0,
			nGridBorderBottom = -12,
			
			nGridCellWidth = 48,
			nGridCellHeight = 48,
			nGridCellGap = 8, -- gridview gap between cells
			
			----------- PAGE REGION -----------
			pageRegionHeight = 72,
			pageNumberWidth = 40,
			pageDefaultMargin = 16,
			pageNumberColor = "255 255 255",
			
			pageLeftImage = "Texture/3DMapSystem/Desktop/RightPanel/PreviousPage32.png",
			pageLeftWidth = 24,
			pageLeftHeight = 24,
			
			pageRightImage = "Texture/3DMapSystem/Desktop/RightPanel/NextPage32.png",
			pageRightWidth = 24,
			pageRightHeight = 24,
			
			isAlwaysShowPager = true,
			
			----------- FUNCTION REGION -----------
			GetLevel1ItemCount = function() return 3; end,
			GetLevel1ItemSelectedForeImage = function(index)
					if(index == 1) then return "Texture/3DMapSystem/Creator/Level1_NM_HL.png";
					elseif(index == 2) then return "Texture/3DMapSystem/Creator/Level1_BCS_HL.png";
					elseif(index == 3) then return "Texture/3DMapSystem/Creator/Level1_NC_HL.png";
					end
				end,
			GetLevel1ItemSelectedBackImage = function(index)
				--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 4 4 4 4";
				return "Texture/3DMapSystem/Desktop/RightPanel/TopTabItem.png; 0 0 64 48: 31 24 31 24";
				end,
			GetLevel1ItemUnselectedForeImage = function(index)
					--if(index == 1) then return "Texture/3DMapSystem/MainBarIcon/Delete_6.png";
					--elseif(index == 2) then return "Texture/3DMapSystem/MainBarIcon/Tips_2.png";
					--elseif(index == 3) then return "Texture/3DMapSystem/MainBarIcon/Delete_2.png";
					--end
					if(index == 1) then return "Texture/3DMapSystem/Creator/Level1_NM.png";
					elseif(index == 2) then return "Texture/3DMapSystem/Creator/Level1_BCS.png";
					elseif(index == 3) then return "Texture/3DMapSystem/Creator/Level1_NC.png";
					end
				end,
			GetLevel1ItemUnselectedBackImage = function(index)
				--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 4 4 4 4";
				return "Texture/3DMapSystem/Desktop/RightPanel/TopTabItemUnSelected.png; 0 0 64 48: 31 24 31 24";
				end,
			
			
			
			GetLevel2ItemCount = function(level1index)
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
						end
					end
					return nCount;
				end,
			GetLevel2ItemSelectedForeImage = function(level1index, level2index)
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
						end
						
						if(nCount == level2index) then
							return v.icon;
						end
					end
				end,
			GetLevel2ItemSelectedBackImage = function(level1index, level2index)
					--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 4 4 4 4";
					--return "Texture/3DMapSystem/HeadonPanel/Test2_Btn.png";
					return "Texture/3DMapSystem/Desktop/RightPanel/TabSelected.png; 0 0 50 64: 24 16 12 12";
				end,
			GetLevel2ItemUnselectedForeImage = function(level1index, level2index)
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
							if(nCount == level2index) then
								return v.icon;
							end
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
							if(nCount == level2index) then
								return v.icon;
							end
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
							if(nCount == level2index) then
								return v.icon;
							end
						end
					end
				end,
			GetLevel2ItemUnselectedBackImage = function(level1index, level2index)
					--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 4 4 4 4";
					return "Texture/3DMapSystem/Desktop/RightPanel/TabUnSelected.png; 0 0 50 64";
				end,
			GetLevel2ItemTooltip = function(level1index, level2index) 
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
							if(nCount == level2index) then
								return v.text;
							end
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
							if(nCount == level2index) then
								return v.text;
							end
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
							if(nCount == level2index) then
								return v.text;
							end
						end
					end
				end,
				
				
			
			GetGridItemCount = function(level1index, level2index)
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
						end
						
						if(level2index == nCount) then
							_guihelper.PrintTableStructure(Map3DSystem.DB.Items[v.name], "TestTable/items.ini");
							return table.getn(Map3DSystem.DB.Items[v.name]);
						end
					end
				end,
			GetGridItemEnabled = function(level1index, level2index, itemindex)
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
						end
						
						if(level2index == nCount) then
							local item = Map3DSystem.DB.Items[v.name][itemindex];
							if(item ~= nil) then
								if(item.isLocked == nil) then
									return true;
								else
									return not item.isLocked;
								end
							end
						end
					end
					return true;
				end,
			GetGridItemForeImage = function(level1index, level2index, itemindex)
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
						end
						
						if(level2index == nCount) then
							local item = Map3DSystem.DB.Items[v.name][itemindex];
							if(item ~= nil) then
								return item.IconFilePath;
							end
						end
					end
				end,
			GetGridItemBackImage = function(level1index, level2index, itemindex)
					--return "Texture/3DMapSystem/common/ThemeLightBlue/menuitem_over.png: 4 4 4 4";
					--return "Texture/3DMapSystem/Creator/ItemBG.png";
					return "";
				end,
			
			GridDrawCellHandler = function(_parent, gridcell, tabgrid)
					if(_parent == nil or gridcell == nil) then
						return;
					end
					
					if(gridcell ~= nil) then
						
						local _this = ParaUI.CreateUIObject("container", "BG", "_lt", 0, 0, gridcell.btnWidth, gridcell.btnHeight);
						_this.background = gridcell.BackImage;
						_this.scalingx = 1.2;
						_this.scalingy = 1.2;
						_this.enabled = false;
						_parent:AddChild(_this);
						
						local _this = ParaUI.CreateUIObject("button", gridcell.text, "_lt", 0, 0, gridcell.btnWidth, gridcell.btnHeight);
						if(tabgrid.CurrentFocusLevel1ItemIndex == nil) then
							_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", nil, %d, %d);]], 
									tabgrid.name, tabgrid.CurrentFocusLevel2ItemIndex, gridcell.index);
						elseif(tabgrid.CurrentFocusLevel2ItemIndex == nil) then
							_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", %d, nil, %d);]], 
									tabgrid.name, tabgrid.CurrentFocusLevel1ItemIndex, gridcell.index);
						elseif(tabgrid.CurrentFocusLevel1ItemIndex == nil and self.CurrentFocusLevel2ItemIndex == nil) then
							_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", nil, nil, %d);]], 
									tabgrid.name, gridcell.index);
						else
							_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", %d, %d, %d);]], 
									tabgrid.name, tabgrid.CurrentFocusLevel1ItemIndex, tabgrid.CurrentFocusLevel2ItemIndex, gridcell.index);
						end
						_this.background = gridcell.ForeImage;
						_this.enabled = gridcell.enabled;
						--_guihelper.SetVistaStyleButton2(_this, gridcell.ForeImage, gridcell.BackImage);
						_this.animstyle = 12;
						_parent:AddChild(_this);
					end
				end,
			
			OnClickItem = function(level1index, level2index, itemindex)
					--commonlib.log("OnClickItem: ");
					--commonlib.log(level1index);
					--commonlib.log(" ");
					--commonlib.log(level2index);
					--commonlib.log(" ");
					--commonlib.log(itemindex);
					--commonlib.log("\n");
					
					local nCount, k, v = 0;
					for k, v in ipairs(Map3DSystem.DB.Groups) do
						if(level1index == 1 and v.parent == "Normal Model") then
							nCount = nCount + 1;
						elseif(level1index == 2 and v.parent == "BCS") then
							nCount = nCount + 1;
						elseif(level1index == 3 and v.parent == "Normal Character") then
							nCount = nCount + 1;
						end
						
						if(level2index == nCount) then
							Map3DSystem.UI.Creator.OnGridItemClick(level1index, level2index, itemindex);
							--local backup = Map3DSystem.UI.Creation.CategoryGroup;
							--Map3DSystem.UI.Creation.CategoryGroup = v.name;
							--Map3DSystem.UI.Creation.OnIconClick(itemindex - 1);
							--Map3DSystem.UI.Creation.CategoryGroup = backup;
							return;
						end
					end
				end,
		};
		ctl = Map3DSystem.UI.TabGrid:new(param);
	end
	
	ctl:Show(true);
end

function Map3DSystem.UI.Creator.GetItemBackground(ID, itemindex)
	local k, group;
	for k, group in pairs(Map3DSystem.DB.Groups) do
		if(group.ID == ID) then
			local kk, item;
			for kk, item in pairs(Map3DSystem.DB.Items[group.name]) do
				if(kk == itemindex) then
					return item.IconFilePath;
				end
			end
		end
	end
end

function Map3DSystem.UI.Creator.SetItemLock(bLock, ID, itemindex)
--Map3DSystem.DB.Items[group.name] = items;
--Map3DSystem.DB.Groups
	local k, group;
	for k, group in pairs(Map3DSystem.DB.Groups) do
		if(group.ID == ID) then
			local kk, item;
			for kk, item in pairs(Map3DSystem.DB.Items[group.name]) do
				if(kk == itemindex) then
					item.isLocked = bLock;
					local ctl = CommonCtrl.GetControl("CreationTabGrid");
					if(ctl ~= nil) then
						ctl:Update();
					end
					return;
				end
			end
		end
	end
end

function Map3DSystem.UI.Creator.SetGroupLock(bLock, ID)
--Map3DSystem.DB.Items[group.name] = items;
--Map3DSystem.DB.Groups
	local k, group;
	for k, group in pairs(Map3DSystem.DB.Groups) do
		if(group.ID == ID) then
			local kk, item;
			for kk, item in pairs(Map3DSystem.DB.Items[group.name]) do
				item.isLocked = bLock;
			end
			local ctl = CommonCtrl.GetControl("CreationTabGrid");
			if(ctl ~= nil) then
				ctl:Update();
			end
			return;
		end
	end
end

function Map3DSystem.UI.Creator.ShowPreview(param)
	-- create a preview box
	local x, y = ParaUI.GetMousePosition();
	local temp = ParaUI.GetUIObjectAtPoint(x, y);
	if(temp:IsValid() == true) then
		while(temp.parent.name ~= "__root") do
			temp = temp.parent;
		end
		local abs_x, abs_y, abs_width, abs_height = temp:GetAbsPosition();
		
		local _fullBtn = ParaUI.GetUIObject("Creator_Preview");
		if(_fullBtn:IsValid() == false) then
			_fullBtn = ParaUI.CreateUIObject("container", "Creator_Preview", "_fi", 0, 0, 0, 0);
			_fullBtn.background = "";
			_fullBtn.zorder = 3; -- set above creator main window
			_fullBtn:AttachToRoot();
			local _ = ParaUI.CreateUIObject("button", "btn", "_fi", 0, 0, 0, 0);
			_.background = "";
			_.onclick = ";ParaUI.GetUIObject(\"Creator_Preview\").visible = false;";
			_fullBtn:AddChild(_);
			local _preview = ParaUI.CreateUIObject("container", "_preview_cont", "_lt", abs_x - 144, y - 70, 140, 140);
			_preview.background = "Texture/3DMapSystem/Chat/message_bg.png:7 7 7 7";
			_fullBtn:AddChild(_preview);
			
			CommonCtrl.DeleteControl("Canvas3D_Creator_Preview");
			NPL.load("(gl)script/ide/Canvas3D.lua");
			ctl = CommonCtrl.Canvas3D:new{
				name = "Canvas3D_Creator_Preview",
				alignment = "_lt",
				left=6, top=6,
				width = 128,
				height = 128,
				parent = _preview,
				autoRotateSpeed = 0.12,
				IsActiveRendering = true,
				miniscenegraphname = "CreatorPreview",
			};
			ctl:Show(true);
		end
		
		_fullBtn.visible = true;
		
		local _preview = _fullBtn:GetChild("_preview_cont");
		_preview.x = abs_x - 144;
		_preview.y = y - 70;
		
		local ctl = CommonCtrl.GetControl("Canvas3D_Creator_Preview");
		if(type(param) == "table") then
			ctl:ShowModel(param);
		elseif(type(param) == "string") then
			ctl:ShowImage(param);
		end
	end
end


-- user clicks an icon in the creation panel. 
function Map3DSystem.UI.Creator.OnGridItemClick(level1index, level2index, itemindex)

	--local totalPage = Map3DSystem.UI.Creation.TotalPage;
	--local totalItem = Map3DSystem.UI.Creation.TotalItem;
	--local currentPage = Map3DSystem.UI.Creation.CurrentPage;
	----local categoryIndex = Map3DSystem.UI.Creation.CategoryIndex;
	--
	--local iconMatrixX = Map3DSystem.UI.Creation.IconMatrixX;
	--local iconMatrixY = Map3DSystem.UI.Creation.IconMatrixY;
	--
	----_guihelper.MessageBox("index:"..index.."\r\ntotalPage: "..totalPage.."\r\ntotalItem:"..totalItem
		----.."\r\ncurrentPage:"..currentPage.."\r\ncategoryIndex:"..categoryIndex);
	--
	-------------- copy from itembar_container.lua ------------
	--ParaAudio.PlayUISound("Btn2");
	----if(not kids_db.User.CheckRight("Create")) then return end
	--
	--local i = currentPage * iconMatrixX * iconMatrixY + index + 1;
	---- TODO: directly access kids_db
	----local item = kids_db.items[Map3DSystem.UI.Creation.CategoryIndex][i];
	
	local groupName = nil;
	-- fixed 2008.11.3 lixizhi. order bug.
	local tabNode = level1Nodes[level1index];
	if(tabNode) then
		local node = tabNode:GetChild(level2index);
		if(node) then
			groupName = node.name;
		end
	end
	if(not groupName) then return end
	
	local item = Map3DSystem.DB.Items[groupName][itemindex];
	
	local obj_params = Map3DSystem.UI.Creator.GetObjParamsFromAsset(groupName, item);
	
	if(obj_params ~= nil) then
		if(mouse_button == "right") then
			Map3DSystem.UI.Creator.ShowPreview(obj_params);
		elseif(mouse_button == "left") then
			-- create the item according to the params
			local isRandomFacing = false;
			local isRandomSize = false;
			
			local minSize = 1;
			local maxSize = 1;
			
			local ctl = CommonCtrl.GetControl("CheckRandomFacing");
			if(ctl ~= nil) then
				isRandomFacing = ctl:GetCheck();
			end
			ctl = CommonCtrl.GetControl("CheckRandomSize");
			if(ctl ~= nil) then
				isRandomSize = ctl:GetCheck();
				local _max = ParaUI.GetUIObject("AdvancedCreationOptions.Max");
				local _min = ParaUI.GetUIObject("AdvancedCreationOptions.Min");
				minSize = tonumber(_min.text) or 1;
				maxSize = tonumber(_max.text) or 1;
			end
			
			-- apply random facing
			if(isRandomFacing == true) then
				local lastFacing = Map3DSystem.App.Creator.LastRandomFacing or 0;
				local thisFacing = ParaGlobal.random() * 6.28;
				
				while math.abs(lastFacing - thisFacing) < 1.57 or math.abs(lastFacing - thisFacing) > 4.71 do
					thisFacing = ParaGlobal.random() * 6.28;
				end
				obj_params.facing = thisFacing;
				Map3DSystem.App.Creator.LastRandomFacing = thisFacing;
			end
			
			-- apply random size
			if(isRandomSize == true) then
				if((maxSize - minSize) < 0.05) then
					-- min and max values are so close
					obj_params.scaling = minSize + ParaGlobal.random() * (maxSize - minSize);
				else
					local lastScaling = Map3DSystem.App.Creator.LastRandomScaling or 0;
					local thisScaling = minSize + ParaGlobal.random() * (maxSize - minSize);
					
					while math.abs(lastScaling - thisScaling) < ((maxSize - minSize)*0.3) do
						thisScaling = minSize + ParaGlobal.random() * (maxSize - minSize);
					end
					
					obj_params.scaling = thisScaling;
					Map3DSystem.App.Creator.LastRandomScaling = thisScaling;
				end
			end
			
			
			if(obj_params~=nil and not obj_params.IsCharacter) then
				if(Map3DSystem.UI.Creator.isBCSActive == true) then
					-- BCS components
					Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params});
				else
					if(Map3DSystem.UI.Creator.CreateAnythingOnX ~= nil) then
						-- added on 2008.12.29: for ZhangYu to create any object on "anything" XRef reference point
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params});
					else
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CopyObject, obj_params = obj_params});
					end
				end
			elseif(obj_params~=nil and obj_params.IsCharacter == true) then
				-- create object by sending a message
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params});
			end
			
			
			
			
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
		end
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
function Map3DSystem.UI.Creator.GetObjParamsFromAsset(category, item)
	if(item == nil or not item.ModelFilePath) then return end
	if(not category) then
		-- if no category is provided, let the file name decides it. see if it begins with "character"
		if(string.find(item.ModelFilePath, "%.anim%.x$")) then
			category = "NC_NormalCharacter"
		else	
			if(string.find(item.ModelFilePath, "^[cC]haracter")) then
				category = "NC_NormalCharacter"
				if(string.find(string.lower(item.ModelFilePath), "character/v3/item/objectcomponents")) then
					-- show object components as model object not character
					category = "NM_NormalModel";
				end
			else
				category = "NM_NormalModel"
			end	
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
	if(Map3DSystem.UI.Creator.isBCSActive == true and indexBCS == 1) then
		-- this is a BCS object and BCS point is active
		obj_params.x = Map3DSystem.UI.Creator.CurrentMarkerPosX;
		obj_params.y = Map3DSystem.UI.Creator.CurrentMarkerPosY;
		obj_params.z = Map3DSystem.UI.Creator.CurrentMarkerPosZ;
		obj_params.AssetFile = item.ModelFilePath;
		obj_params.name = item.IconAssetName; -- added by Xizhi 2008.1.17.  give it a better name for blueprint app's bom view. 
		obj_params.localMatrix = Map3DSystem.UI.Creator.CurrentMarkerLocalMatrix;
		-- TODO: temporary used
		--obj_params.facing = Map3DSystem.UI.Creator.CurrentMarkerFacing;
		local obj = ParaScene.GetObject(obj_params.x, obj_params.y, obj_params.z, 0.005);
		if(obj:IsValid() == true) then
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = obj});
		end
	else
		-- set creator position and asset name
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
	return obj_params;
end