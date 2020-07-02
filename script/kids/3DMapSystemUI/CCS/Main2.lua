--[[
Title: CCS main window
Author(s): WangTian
Date: 2008/5/26
Desc: CCS application main window is upgraded to the new aura look, including:
		show the window on the side instead of bottom to utilize more screen space 
		show the items in grid view form
		fit to window size automaticly
		categories are arranged on the top and left(/right) side of the grid view
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

if(not Map3DSystem.UI.CCS.Main2) then Map3DSystem.UI.CCS.Main2 = {}; end

-- Show the CCS main window
function Map3DSystem.UI.CCS.Main2.ShowMainWnd(bShow)
	local _app = Map3DSystem.App.CCS.app._app;
	local _wnd = _app:FindWindow("MainWnd") or _app:RegisterWindow("MainWnd", nil, Map3DSystem.UI.CCS.Main2.MSGProc);
	
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
		
		ShowUICallback = Map3DSystem.UI.CCS.Main2.Show,
	};
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow);
	
	Map3DSystem.UI.CCS.Main2.UpdatePanelUIEnabled();
end

-- destory the main window, usually called when the world is closed
function Map3DSystem.UI.CCS.Main2.DestroyMainWnd()
	local _app = Map3DSystem.App.CCS.app._app;
	local _wnd = _app:FindWindow("MainWnd");
	
	if(_wnd ~= nil) then
		NPL.load("(gl)script/ide/WindowFrame.lua");
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:Destroy();
		end
		
		ParaUI.Destroy("CCS2_Main");
		
		CommonCtrl.DeleteControl("CCSPanelTabGrid");
		CommonCtrl.DeleteControl("NormalFaceGridView");
		
		-- NOTE by Andy 2009/1/8: delete the tabcontrol object as well
		CommonCtrl.DeleteControl("CCS_TabControl_CartoonFace");
		CommonCtrl.DeleteControl("CCS_TabControl_Inventory");
		
		CommonCtrl.DeleteControl("CartoonFaceTabGrid");
		CommonCtrl.DeleteControl("InventoryTabGrid");
		CommonCtrl.DeleteControl("HairStyleGridView");
		CommonCtrl.DeleteControl("HairColorGridView");
	end
end

-- change the main window size, usually called on resolution change
function Map3DSystem.UI.CCS.Main2.OnSize(width, height)
	local ctl = CommonCtrl.GetControl("CartoonFaceTabGrid");
	if(ctl ~= nil) then
		ctl:OnSize(width, height);
	end
	local ctl = CommonCtrl.GetControl("InventoryTabGrid");
	if(ctl ~= nil) then
		ctl:OnSize(width, height);
	end
	--Map3DSystem.UI.CCS.Modify.UpdatePanelUI();
end

-- Message Processor of CCS main control
-- On receive WM_SIZE message it will update the CartoonFaceTabGrid and InventoryTabGrid control
function Map3DSystem.UI.CCS.Main2.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.CCS.Main2.Close();
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		--log("WM_SIZE not handled in Map3DSystem.UI.CCS.Main2.MSGProc()\n");
		Map3DSystem.UI.CCS.Main2.OnSize(msg.width, msg.height);
	end
end

function Map3DSystem.UI.CCS.Main2.Close()
	Map3DSystem.UI.CCS.Main2.ShowMainWnd(false);
end

-- show CCS in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
function Map3DSystem.UI.CCS.Main2.Show(bShow, _parent, parentWindow)
	
	local _this;
	_this = ParaUI.GetUIObject("CCS2_Main");
	
	if(_this:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "CCS2_Main", "_lt", 0, 50, 300, 500);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "CCS2_Main", "_fi", 0, 0, 0, 0);
			_this.background = "";
			_parent:AddChild(_this);
		end
		
		local _main = _this;
		
		local _facialPanel = ParaUI.CreateUIObject("container", "CCS.FacialPanel", "_fi", 0, 0, 0, 0);
		_facialPanel.background = "";
		_main:AddChild(_facialPanel);
		
		local _cartoonfacePanel = ParaUI.CreateUIObject("container", "CCS.CartoonFacePanel", "_fi", 0, 0, 0, 0);
		_cartoonfacePanel.background = "";
		_main:AddChild(_cartoonfacePanel);
		
		local _inventoryPanel = ParaUI.CreateUIObject("container", "CCS.InventoryPanel", "_fi", 0, 0, 0, 0);
		_inventoryPanel.background = "";
		_main:AddChild(_inventoryPanel);
		
		local _hairPanel = ParaUI.CreateUIObject("container", "CCS.HairPanel", "_fi", 0, 0, 0, 0);
		_hairPanel.background = "";
		_main:AddChild(_hairPanel);
		
		local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -36, 4, 32, 32);
		_close.background = "Texture/3DMapSystem/Creator/close.png";
		_close.onclick = ";Map3DSystem.UI.CCS.Main2.Close();";
		_parent:AddChild(_close);
		
		-- init the facial and inventory panel
		-- uncommented by LXZ. 2008.9.15. use lazy loading to maximize loading speed.
		--Map3DSystem.UI.CCS.Main2.InitFacialPanel(_facialPanel);
		--Map3DSystem.UI.CCS.Main2.InitCartoonFacePanel(_cartoonfacePanel);
		--Map3DSystem.UI.CCS.Main2.InitInventoryPanel(_inventoryPanel);
		--Map3DSystem.UI.CCS.Main2.InitHairPanel(_hairPanel);
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- on change the tabgrid
-- NOTE by andy: don't SetLevelIndex() in this funcition, stack may overflow
function Map3DSystem.UI.CCS.Main2.OnChangeCCSTab(i)
	
	local _facialPanel = ParaUI.GetUIObject("CCS.FacialPanel");
	local _cartoonfacePanel = ParaUI.GetUIObject("CCS.CartoonFacePanel");
	local _inventoryPanel = ParaUI.GetUIObject("CCS.InventoryPanel");
	local _hairPanel = ParaUI.GetUIObject("CCS.HairPanel");
	_facialPanel.visible = false;
	_cartoonfacePanel.visible = false;
	_inventoryPanel.visible = false;
	_hairPanel.visible = false;
	
	if(i == 1) then
		_facialPanel.visible = true;
		Map3DSystem.UI.CCS.Main2.InitFacialPanel(_facialPanel);
		Map3DSystem.UI.CCS.Main2.SetFaceType(false);
		autotips.AddMessageTips("您已经切换到普通面部编辑\n", 2);
	elseif(i == 2) then
		_cartoonfacePanel.visible = true;
		Map3DSystem.UI.CCS.Main2.InitCartoonFacePanel(_cartoonfacePanel);
		Map3DSystem.UI.CCS.Main2.SetFaceType(true);
		autotips.AddMessageTips("您已经切换到卡通脸编辑\n", 2);
	elseif(i == 3) then
		_inventoryPanel.visible = true;
		Map3DSystem.UI.CCS.Main2.InitInventoryPanel(_inventoryPanel);
		_inventoryPanel.visible = true;
	elseif(i == 4) then
		_hairPanel.visible = true;
		Map3DSystem.UI.CCS.Main2.InitHairPanel(_hairPanel);
	end
end

-- set the current player face type
-- @param bCartoonFace: true to cartoon face, false to normal face
function Map3DSystem.UI.CCS.Main2.SetFaceType(bCartoonFace)
	local playerChar = ParaScene.GetPlayer():ToCharacter();
	if(playerChar:IsSupportCartoonFace()) then
		---- TODO: get and save the information for toggle
		--local charFaceType = playerChar:GetBodyParams(1);
		--local cartoonFaceType = playerChar:GetBodyParams(4);
		
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
		
		if(bCartoonFace) then
			-- set to cartoon face
			playerChar:SetBodyParams(-1, -1, -1, -1, 1);
		else
			-- set to character face
			local type = playerChar:GetBodyParams(4);
			if(type == 1) then
				playerChar:SetBodyParams(-1, 1, -1, -1, 0);
			end
		end
		
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	end
end

-- change to the target panel according to the index
function Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(i)
	
	-- switch the facial and inventory panel
	Map3DSystem.UI.CCS.Main2.OnChangeCCSTab(i);
	
	local ctl = CommonCtrl.GetControl("CCSPanelTabGrid");
	if(ctl ~= nil) then
		-- set level index
		if(i == 1) then
			ctl:SetLevelIndex(1, -1);
		elseif(i == 2) then
			ctl:SetLevelIndex(2, -1);
		elseif(i == 3) then
			ctl:SetLevelIndex(3, -1);
		elseif(i == 4) then
			ctl:SetLevelIndex(4, -1);
		end
	end
end

function Map3DSystem.UI.CCS.Main2.UpdatePanelUIEnabled()
	local player = ParaScene.GetPlayer();
	if(player:IsCharacter()) then
		local playerChar = player:ToCharacter();
		if(playerChar:IsCustomModel() == true) then
			Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(true);
			Map3DSystem.UI.CCS.Main2.SetEnabledInventoryPanel(true);
			Map3DSystem.UI.CCS.Main2.SetEnabledHairPanel(true);
			if(playerChar:IsSupportCartoonFace()) then
				Map3DSystem.UI.CCS.Main2.SetEnabledCartoonFacePanel(true);
			else
				Map3DSystem.UI.CCS.Main2.SetEnabledCartoonFacePanel(false);
			end
		else
			Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(false);
			Map3DSystem.UI.CCS.Main2.SetEnabledCartoonFacePanel(false);
			Map3DSystem.UI.CCS.Main2.SetEnabledInventoryPanel(false);
			Map3DSystem.UI.CCS.Main2.SetEnabledHairPanel(false);
			autotips.AddMessageTips("您当前的人物不支持个性人物编辑\n", 2);
		end
	end
end

function Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(bEnabled)
	local _facialPanel = ParaUI.GetUIObject("CCS.FacialPanel");
	_guihelper.SetContainerEnabled(_facialPanel, bEnabled)
end

function Map3DSystem.UI.CCS.Main2.SetEnabledCartoonFacePanel(bEnabled)
	local _cartoonFacePanel = ParaUI.GetUIObject("CCS.CartoonFacePanel");
	_guihelper.SetContainerEnabled(_cartoonFacePanel, bEnabled)
end

function Map3DSystem.UI.CCS.Main2.SetEnabledInventoryPanel(bEnabled)
	local _inventoryPanel = ParaUI.GetUIObject("CCS.InventoryPanel");
	_guihelper.SetContainerEnabled(_inventoryPanel, bEnabled)
end

function Map3DSystem.UI.CCS.Main2.SetEnabledHairPanel(bEnabled)
	local _hairPanel = ParaUI.GetUIObject("CCS.HairPanel");
	_guihelper.SetContainerEnabled(_hairPanel, bEnabled)
end

function Map3DSystem.UI.CCS.Main2.UpdateFacialPanel()
	local player = ParaScene.GetPlayer();
	if(player:IsCharacter()) then
		local playerChar = player:ToCharacter();
		if(playerChar:IsCustomModel() == true) then
			local race = playerChar:GetRaceID();
			local gender = playerChar:GetGender();
			if(race == 6 and gender == 1) then
				NPL.load("(gl)script/ide/GridView.lua");
				local ctl = CommonCtrl.GetControl("NormalFaceGridView");
				if(ctl ~= nil) then
					ctl:ClearAllCells();
					for i = 1, 15 do
						local column = i - math.floor((i-1)/3)*3;
						local row = math.floor((i-1)/3) + 1;
						local cell = CommonCtrl.GridCell:new{
							GridView = nil,
							name = "NormalFace"..(i-1),
							icon = nil,
							index = i,
							icon = "character/v3/Human/faceshots/face_human_female_0"..(row - 1).."_0"..(column - 1)..".png",
							column = column,
							row = row,
							};
						ctl:InsertCell(cell, "Right");
					end
					ctl:Update();
				end
			elseif(race == 6 and gender == 0) then
				NPL.load("(gl)script/ide/GridView.lua");
				local ctl = CommonCtrl.GetControl("NormalFaceGridView");
				if(ctl ~= nil) then
					ctl:ClearAllCells();
					for i = 1, 15 do
						local column = i - math.floor((i-1)/3)*3;
						local row = math.floor((i-1)/3) + 1;
						local cell = CommonCtrl.GridCell:new{
							GridView = nil,
							name = "NormalFace"..(i-1),
							icon = nil,
							index = i,
							icon = "character/v3/Human/faceshots/face_human_male_0"..(row - 1).."_0"..(column - 1)..".png",
							column = column,
							row = row,
							};
						ctl:InsertCell(cell, "Right");
					end
					ctl:Update();
				end
			end
		end
	end
end

function Map3DSystem.UI.CCS.Main2.InitFacialPanel(_parent)
	if(_parent:GetChildCount() > 0) then
		return
	end
	--local _facialSelector = ParaUI.CreateUIObject("container", "Selector", "_fi", 0, 0, 0, 72);
	--_facialSelector.background = nil;
	--_parent:AddChild(_facialSelector);
	
	local _bg = ParaUI.CreateUIObject("container", "_", "_lt", 16, 16, 40, 40);
	_bg.background = "Texture/3DMapSystem/Creator/icon_bg.png";
	_bg.enabled = false;
	_parent:AddChild(_bg);
	
	local _icon = ParaUI.CreateUIObject("container", "_", "_lt", 20, 20, 32, 32);
	_icon.background = "Texture/3DMapSystem/CCS/Level1_Facial.png";
	_icon.enabled = false;
	_parent:AddChild(_icon);
	
	local _ = ParaUI.CreateUIObject("text", "_", "_lt", 64, 16, 200, 40);
	_.text = "面部和皮肤面板\n点击图标选择肤色和面部";
	_guihelper.SetFontColor(_, "#FFFFFF");
	_parent:AddChild(_);
	
	--local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -36, 4, 32, 32);
	--_close.background = "Texture/3DMapSystem/Creator/close.png";
	--_close.onclick = ";Map3DSystem.UI.CCS.Main2.Close();";
	--_parent:AddChild(_close);
	
	local function OwnerDrawGridCellHandler(_parent, gridcell)
		if(_parent == nil or gridcell == nil) then
			return;
		end
		
		if(gridcell ~= nil) then
			local _this = ParaUI.CreateUIObject("button", gridcell.name, "_fi", 15, 10, 5, 10);
			--_this.text = "NF"..gridcell.index;
			_this.background = gridcell.icon;
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetNormalFace("..gridcell.index..");";
			_parent:AddChild(_this);
		end
	end
	
	NPL.load("(gl)script/ide/GridView.lua");
	local ctl = CommonCtrl.GetControl("NormalFaceGridView");
	if(ctl == nil) then
		ctl = CommonCtrl.GridView:new{
			name = "NormalFaceGridView",
			alignment = "_fi",
			container_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
			left = 24, top = 70,
			width = 24,
			height = 24,
			cellWidth = 84,
			cellHeight = 84,
			parent = _parent,
			columns = 3,
			rows = 6,
			DrawCellHandler = OwnerDrawGridCellHandler,
		};
		
		for i = 1, 15 do
			local column = i - math.floor((i-1)/3)*3;
			local row = math.floor((i-1)/3) + 1;
			local cell = CommonCtrl.GridCell:new{
				GridView = nil,
				name = "NormalFace"..(i-1),
				icon = nil,
				index = i,
				icon = "character/v3/Human/faceshots/face_human_female_0"..(row - 1).."_0"..(column - 1)..".png",
				column = column,
				row = row,
				};
			ctl:InsertCell(cell, "Right");
		end
	end

	ctl:Show();
	
	--local _useMyPhoto = ParaUI.CreateUIObject("button", "UseMyPhoto", "_lb", 48, 0, 32, 32);
	--_useMyPhoto.background = "";
	--_parent:AddChild(_useMyPhoto);
	--
	--local _useMyPhoto = ParaUI.CreateUIObject("button", "UseMyPhotoText", "_lb", 90, 0, 200, 32);
	--_useMyPhoto.text = "用我的照片(制作中...)";
	--_parent:AddChild(_useMyPhoto);
end

function Map3DSystem.UI.CCS.Main2.SetNormalFace(index)
	--log(index.." normal face \n");
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	
	playerChar:SetBodyParams(math.ceil(index/3)-1, -1, -1, -1, -1);
	
	playerChar:SetBodyParams(-1, index-1, -1, -1, -1);
end

function Map3DSystem.UI.CCS.Main2.InitCartoonFacePanel(_parent)
	if(_parent:GetChildCount() > 0) then
		return
	end
	
	local _bg = ParaUI.CreateUIObject("container", "_", "_lt", 16, 16, 40, 40);
	_bg.background = "Texture/3DMapSystem/Creator/icon_bg.png";
	_bg.enabled = false;
	_parent:AddChild(_bg);
	
	local _icon = ParaUI.CreateUIObject("container", "_", "_lt", 20, 20, 32, 32);
	_icon.background = "Texture/3DMapSystem/CCS/Level1_CartoonFace.png";
	_icon.enabled = false;
	_parent:AddChild(_icon);
	
	local _ = ParaUI.CreateUIObject("text", "_", "_lt", 64, 16, 250, 40);
	_.text = "卡通脸编辑面板\n上面板可点击选择不同的卡通脸样式\n下面板可以编辑各部分的位置、旋转、颜色等";
	_guihelper.SetFontColor(_, "#FFFFFF");
	_parent:AddChild(_);
	
	--local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -36, 4, 32, 32);
	--_close.background = "Texture/3DMapSystem/Creator/close.png";
	--_close.onclick = ";Map3DSystem.UI.CCS.Main2.Close();";
	--_parent:AddChild(_close);
	
	
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
	
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DB.lua");
	
	--Map3DSystem.UI.CCS.DB.CFS_FACE = 0;
	--Map3DSystem.UI.CCS.DB.CFS_WRINKLE = 1;
	--Map3DSystem.UI.CCS.DB.CFS_EYE = 2;
	--Map3DSystem.UI.CCS.DB.CFS_EYEBROW = 3;
	--Map3DSystem.UI.CCS.DB.CFS_MOUTH = 4;
	--Map3DSystem.UI.CCS.DB.CFS_NOSE = 5;
	--Map3DSystem.UI.CCS.DB.CFS_MARKS = 6;
	
	local i;
	for i = 0, 6 do
		Map3DSystem.UI.CCS.DB.GetFaceComponentStyleList(i);
		Map3DSystem.UI.CCS.DB.GetFaceComponentIconList(i);
	end
	
	
	--local _faceSwitch = ParaUI.CreateUIObject("container", "CCS.FaceSwitch", "_mt", 0, 0, 0, 48);
	--_faceSwitch.background = "";
	--_parent:AddChild(_faceSwitch);
	--
		--local _cartoonFace = ParaUI.CreateUIObject("button", "CartoonFace", "_lt", 64, 0, 96, 48);
		----_cartoonFace.background = "Texture/3DMapSystem/CCS/RightPanel/CartoonFaceTab.png";
		--_cartoonFace.onclick = ";Map3DSystem.UI.CCS.Main2.ChangeToFaceTab(1);";
		--_faceSwitch:AddChild(_cartoonFace);
		--
		--local _normalFace = ParaUI.CreateUIObject("button", "NormalFace", "_lt", 192, 0, 96, 48);
		----_normalFace.background = "Texture/3DMapSystem/CCS/RightPanel/NormalFaceTab.png";
		--_normalFace.onclick = ";Map3DSystem.UI.CCS.Main2.ChangeToFaceTab(2);";
		--_faceSwitch:AddChild(_normalFace);
		--
		---- change to the target panel according to the index
		--function Map3DSystem.UI.CCS.Main2.ChangeToFaceTab(index)
			--local tabCartoonFaceSelected = "Texture/3DMapSystem/CCS/RightPanel/CartoonFaceTabSelected.png";
			--local tabCartoonFaceUnSelected = "Texture/3DMapSystem/CCS/RightPanel/CartoonFaceTabUnSelected.png";
			--local tabNormalFaceSelected = "Texture/3DMapSystem/CCS/RightPanel/NormalFaceTabSelected.png";
			--local tabNormalFaceUnSelected = "Texture/3DMapSystem/CCS/RightPanel/NormalFaceTabUnSelected.png";
			--if(index == 1) then
				---- change to cartoon face
				--local _cartoonFace = ParaUI.GetUIObject("CCS.FaceSwitch"):GetChild("CartoonFace");
				--local _normalFace = ParaUI.GetUIObject("CCS.FaceSwitch"):GetChild("NormalFace");
				--_cartoonFace.background = tabCartoonFaceSelected;
				--_normalFace.background = tabNormalFaceUnSelected;
				--
				--local _curtain = ParaUI.GetUIObject("CCS.CartoonFacePanel.Curtain");
				--_curtain.visible = false;
			--elseif(index == 2) then
				---- change to normal face
				--local _cartoonFace = ParaUI.GetUIObject("CCS.FaceSwitch"):GetChild("CartoonFace");
				--local _normalFace = ParaUI.GetUIObject("CCS.FaceSwitch"):GetChild("NormalFace");
				--_cartoonFace.background = tabCartoonFaceUnSelected;
				--_normalFace.background = tabNormalFaceSelected;
				--
				--local _curtain = ParaUI.GetUIObject("CCS.CartoonFacePanel.Curtain");
				--_curtain.visible = true;
			--end
		--end
		--
		---- manually set the tab to cartoon face panel
		--Map3DSystem.UI.CCS.Main2.ChangeToFaceTab(1);
			
	--local _cartoonFacePanel = ParaUI.CreateUIObject("container", "CCS.CartoonFacePanel.Panel", "_fi", 0, 8, 0, 0);
	--_cartoonFacePanel.background = "";
	--_parent:AddChild(_cartoonFacePanel);
	--
	--local _cartoonFacePanel_Curtain = ParaUI.CreateUIObject("container", "CCS.CartoonFacePanel.Curtain", "_fi", 0, 8, 0, 0);
	--_cartoonFacePanel_Curtain.background = nil;
	--_cartoonFacePanel_Curtain.color = "255 255 255 200";
	--_cartoonFacePanel_Curtain.visible = false;
	--_parent:AddChild(_cartoonFacePanel_Curtain);
	
	_cartoonFacePanel = _parent;
	
		----local _sideBar = ParaUI.CreateUIObject("container", "SideBar", "_mr", 0, 0, 36, 86);
		----_sideBar.background = "Texture/3DMapSystem/CCS/RightPanel/SideTabBG.png; 0 0 36 128: 17 48 17 48";
		--local _sideBar = ParaUI.CreateUIObject("container", "SideBar", "_mr", 0, 0, 48, 86);
		--_sideBar.background = "Texture/3DMapSystem/CCS/RightPanel/SideTabBG2.png: 18 18 18 18";
		--_sideBar.enabled = false;
		--_cartoonFacePanel:AddChild(_sideBar);
		
		
		
		local _modifyPanel = ParaUI.CreateUIObject("container", "Modify", "_mb", 16, 12, 8, 80);
		_modifyPanel.background = "Texture/3DMapSystem/Creator/container.png:7 7 7 7";
		_cartoonFacePanel:AddChild(_modifyPanel);
			
			local left, top = 10, 8;
			
			local _this = ParaUI.CreateUIObject("button", "btnMoveUp", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftY_Up.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "向上平移";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Y, -2);";
			_modifyPanel:AddChild(_this);
			
			left = left + 38;
			local _this = ParaUI.CreateUIObject("button", "btnMoveDown", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftY_Down.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "向下平移";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Y, 2);";
			_modifyPanel:AddChild(_this);
			
			left = left + 38;
			local _this = ParaUI.CreateUIObject("button", "btnZomeIn", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ZoomIn.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "放大";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Scale, 0.1);";
			_modifyPanel:AddChild(_this);
			
			left = left + 38;
			local _this = ParaUI.CreateUIObject("button", "btnZoomOut", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ZoomOut.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "缩小";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Scale, -0.1);";
			_modifyPanel:AddChild(_this);
			
			
			left, top = left - 38 * 3, top + 38;
			local _this = ParaUI.CreateUIObject("button", "btnRotateClockwise", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Rotate_Clockwise.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "顺时针旋转";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Rotation, 0.1);";
			_modifyPanel:AddChild(_this);
			
			left = left + 38;
			local _this = ParaUI.CreateUIObject("button", "btnRotateAntiClockwise", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Rotate_AntiClockwise.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "逆时针旋转";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Rotation, -0.1);";
			_modifyPanel:AddChild(_this);
			
			left = left + 38;
			local _this = ParaUI.CreateUIObject("button", "btnMoveLeft", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftX_Left.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "左移/靠近";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_X, -1);";
			_modifyPanel:AddChild(_this);
			
			left = left + 38;
			local _this = ParaUI.CreateUIObject("button", "btnMoveRight", "_lt", left, top, 32, 32);
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftX_Right.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
			_this.animstyle = 11;
			_this.tooltip = "右移/分开";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_X, 1);";
			_modifyPanel:AddChild(_this);
			
			---- Color Palette
			--local _this = ParaUI.CreateUIObject("button", "btnColorPalette", "_rt", -138, 11, 96, 64);
			--_guihelper.SetVistaStyleButtonBright(_this, "Texture/3DMapSystem/CCS/btn_CCS_ColorPalette.png");
			--_this.tooltip = "调色板";
			----_this.onclick = ";Map3DSystem.UI.CCS.OnClickColorPalette();";
			--_modifyPanel:AddChild(_this);
			
			
			
			NPL.load("(gl)script/ide/colorpicker.lua");
			local ctl = CommonCtrl.ColorPicker:new{
				name = "CCS_CartoonFace_ColorPicker",
				alignment = "_rt",
				left = -138,
				top = 11,
				background = nil,
				width = 96,
				height = 64,
				parent = _modifyPanel,
			};
			ctl:SetValue("255 255 255", true);
			
			ctl.onchange = function (sCtrlName, R,G,B)
				Map3DSystem.UI.CCS.Main2.SetFaceComponent(Map3DSystem.UI.CCS.DB.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(R,G,B));
			end
			
			ctl:Show(true);
			
			
			
			local _this = ParaUI.CreateUIObject("button", "btnReset", "_rt", -38, 8, 32, 32);
			_this.background = "Texture/3DMapSystem/common/reset.png";
			_this.animstyle = 11;
			_this.tooltip = "重置";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.ResetFaceComponent();";
			_modifyPanel:AddChild(_this);
			
			local _this = ParaUI.CreateUIObject("button", "btnReset", "_rt", -38, 46, 32, 32);
			_this.background = "Texture/3DMapSystem/CCS/btn_CCS_CF_Random.png";
			_this.animstyle = 11;
			_this.tooltip = "随机生成卡通脸";
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.RandomCartoonFace();"
			_modifyPanel:AddChild(_this);
			
			NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CartoonFaceComponent.lua");
			Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Eyebrow");
			
			function Map3DSystem.UI.CCS.Main2.SetFaceComponent(SubType, value, donot_refresh)
				
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
									
				Map3DSystem.UI.CCS.DB.SetFaceComponent(Map3DSystem.UI.CCS.CartoonFaceComponent.Component, SubType, value, donot_refresh);
				
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
			end
			
			function Map3DSystem.UI.CCS.Main2.ResetFaceComponent()
				Map3DSystem.UI.CCS.Main2.SetFaceComponent(nil);
			end
			
			function Map3DSystem.UI.CCS.Main2.RandomCartoonFace()
				
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
				
				local i = 0;
				for i = 1, 6 do
					if((i == 1 or i == 6) and math.random() > 0.3) then -- wrinkle or marks
						Map3DSystem.UI.CCS.DB.SetFaceComponent(i, 0, 0);
					else
						local ran = math.random(1, table.getn(Map3DSystem.UI.CCS.DB.FaceStyleLists[3]));
						Map3DSystem.UI.CCS.DB.SetFaceComponent(i, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[i][ran]);
					end
				end
				
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
			end
			
			
	
	--local _hairPanel = ParaUI.CreateUIObject("container", "CCS.HairPanel", "_mb", 0, 0, 0, 88);
	--_hairPanel.background = "";
	--_parent:AddChild(_hairPanel);
	--
	--local left, top = 48, 4;
	--local _this = ParaUI.CreateUIObject("button", "HairType", "_lt", left, top, 64, 32);
	--_this.enabled = false;
	--_this.text = "HairType";
	--_hairPanel:AddChild(_this);
	--
	--left = left + 80;
	--local _this = ParaUI.CreateUIObject("button", "Left", "_lt", left, top, 32, 32);
	--_this.color = "255 255 255 60";
	--_this.text = "<";
	--left = left + 64;
	--_hairPanel:AddChild(_this);
	--local _this = ParaUI.CreateUIObject("button", "Right", "_lt", left, top, 32, 32);
	--_this.color = "255 255 255 60";
	--_this.text = ">";
	--_hairPanel:AddChild(_this);
	--
	--
	--local left, top = 48, 44;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 64, 32);
	--_this.enabled = false;
	--_this.text = "HairColor";
	--_hairPanel:AddChild(_this);
	--
	--left = left + 80;
	--local _this = ParaUI.CreateUIObject("button", "Left", "_lt", left, top, 32, 32);
	--_this.color = "255 255 255 60";
	--_this.text = "<";
	--_hairPanel:AddChild(_this);
	--left = left + 64;
	--local _this = ParaUI.CreateUIObject("button", "Right", "_lt", left, top, 32, 32);
	--_this.color = "255 255 255 60";
	--_this.text = ">";
	--_hairPanel:AddChild(_this);
	--
	--local _this = ParaUI.CreateUIObject("button", "Save", "_rb", -80, -80, 64, 64);
	--_this.text = "SAVE";
	--_hairPanel:AddChild(_this);
	
	
	local _tab_CF = ParaUI.CreateUIObject("container", "Tab_CF", "_mr", 16, 70, 60, 100);
	_tab_CF.background = "";
	_cartoonFacePanel:AddChild(_tab_CF);
	
	local _cartoonFaceSelector = ParaUI.CreateUIObject("container", "Selector", "_fi", 16, 70, 76, 100);
	_cartoonFaceSelector.background = "";
	_cartoonFacePanel:AddChild(_cartoonFaceSelector);
	
	NPL.load("(gl)script/ide/TreeView.lua");
	local tabPagesNode_CF = CommonCtrl.TreeNode:new({Name = "CCS_TabControlRootNode_CF"});
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "眉毛", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Eyebrow.png"}));
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "眼睛", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Eye.png"}));
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "鼻子", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Nose.png"}));
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "嘴", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Mouth.png"}));
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "皱纹", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Wrinkle.png"}));
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "标记", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Marks.png"}));
	tabPagesNode_CF:AddChild(CommonCtrl.TreeNode:new({tooltip = "脸", icon = "Texture/3DMapSystem/CCS/RightPanel/CF_Face.png"}));
	
	NPL.load("(gl)script/ide/TabControl.lua");
	local ctl = CommonCtrl.TabControl:new{
			name = "CCS_TabControl_CartoonFace",
			parent = _tab_CF,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TabAlignment = "Right", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_CF, -- CommonCtrl.TreeNode object, collection of tab pages
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
			TabStartOffset = 40, -- start of the tabs from the border
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
			MaxTabNum = 4, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex)
				local ctl = CommonCtrl.GetControl("CartoonFaceTabGrid");
				if(ctl ~= nil) then
					ctl:SetLevelIndex(toIndex);
				end
			end,
		};
	ctl:Show(true);
	
	local ctl = CommonCtrl.GetControl("CartoonFaceTabGrid");
	if(ctl == nil) then
		local param = {
			name = "CartoonFaceTabGrid",
			parent = _cartoonFaceSelector,
			background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;0 0 32 64:16 16 1 16",
			wnd = wnd,
			
			----------- CATEGORY REGION -----------
			Level1 = "Right",
			Level1BG = "",
			Level1HeadBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGTop.png; 0 0 50 24",
			Level1TailBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGBottom.png; 0 0 50 64: 1 0 1 63",
			Level1Offset = 24,
			Level1ItemWidth = 0,
			Level1ItemHeight = 50,
			--Level1ItemGap = 8,
			
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
				local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 11, 9, 32, 32);
				if(bSelected) then
					_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
				else
					_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
				end
				_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
						tabGrid.name, level1index);
				_parent:AddChild(_btn);
			end,
			
			--Level2 = "Top",
			--Level2Offset = 48,
			--Level2ItemWidth = 32,
			--Level2ItemHeight = 48,
			--Level2ItemGap = 0,
			
			----------- GRID REGION -----------
			nGridBorderLeft = 8,
			nGridBorderTop = 0,
			nGridBorderRight = 0,
			nGridBorderBottom = 0,
			
			nGridCellWidth = 48,
			nGridCellHeight = 48,
			nGridCellGap = 8, -- gridview gap between cells
			
			----------- PAGE REGION -----------
			pageRegionHeight = 48,
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
			GetLevel1ItemCount = function() return 7; end,
			GetLevel1ItemSelectedForeImage = function(index)
					--if(index == 1) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Eyebrow.png";
					--elseif(index == 2) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Eye.png";
					--elseif(index == 3) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Nose.png";
					--elseif(index == 4) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Mouth.png";
					--elseif(index == 5) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Wrinkle.png";
					--elseif(index == 6) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Marks.png";
					--elseif(index == 7) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Face.png";
					--end
					
					if(index == 1) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Eyebrow.png";
					elseif(index == 2) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Eye.png";
					elseif(index == 3) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Nose.png";
					elseif(index == 4) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Mouth.png";
					elseif(index == 5) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Wrinkle.png";
					elseif(index == 6) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Marks.png";
					elseif(index == 7) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Face.png";
					end
				end,
			GetLevel1ItemSelectedBackImage = function(index)
					--return "Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png";
					
					--return "Texture/3DMapSystem/CCS/RightPanel/CCS_CF_Highlight.png";
					
					return "Texture/3DMapSystem/Desktop/RightPanel/TabSelected.png; 0 0 50 64: 24 16 12 12";
				end,
			GetLevel1ItemUnselectedForeImage = function(index)
					--if(index == 1) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Eyebrow.png";
					--elseif(index == 2) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Eye.png";
					--elseif(index == 3) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Nose.png";
					--elseif(index == 4) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Mouth.png";
					--elseif(index == 5) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Wrinkle.png";
					--elseif(index == 6) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Marks.png";
					--elseif(index == 7) then return "Texture/3DMapSystem/CCS/btn_CCS_CF_Face.png";
					--end
					
					if(index == 1) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Eyebrow.png";
					elseif(index == 2) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Eye.png";
					elseif(index == 3) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Nose.png";
					elseif(index == 4) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Mouth.png";
					elseif(index == 5) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Wrinkle.png";
					elseif(index == 6) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Marks.png";
					elseif(index == 7) then return "Texture/3DMapSystem/CCS/RightPanel/CF_Face.png";
					end
				end,
			GetLevel1ItemUnselectedBackImage = function(index)
					--return "Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png";
					return "Texture/3DMapSystem/Desktop/RightPanel/TabUnSelected.png; 0 0 50 64";
				end,
				
			--OnChangeLevelIndex = function(level1Index, level2Index)
				--
				--commonlib.echo("OnChangeLevelIndex ")
				--commonlib.echo(level1Index);
				--
				--local ctl = CommonCtrl.GetControl("CCS_CartoonFace_ColorPicker");
				--if(ctl ~= nil) then
					--local player = ParaScene.GetPlayer();
					--local playerChar = player:ToCharacter();
					--
					--if(playerChar:IsSupportCartoonFace() == true) then
						--local r, g, b = 255, 255, 255;
						--local w;
						--if(level1Index == 1) then
							----eyebrow
							--w = playerChar:GetCartoonFaceComponent(3, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--elseif(level1Index == 2) then
							----eye
							--w = playerChar:GetCartoonFaceComponent(2, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--elseif(level1Index == 3) then
							----nose
							--w = playerChar:GetCartoonFaceComponent(5, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--elseif(level1Index == 4) then
							----mouse
							--w = playerChar:GetCartoonFaceComponent(4, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--elseif(level1Index == 5) then
							----wrinkle
							--w = playerChar:GetCartoonFaceComponent(1, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--elseif(level1Index == 6) then
							----mark
							--w = playerChar:GetCartoonFaceComponent(6, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--elseif(level1Index == 7) then
							----face
							--w = playerChar:GetCartoonFaceComponent(0, 1);
							--r, g, b = _guihelper.DWORD_TO_RGBA(w);
						--end
						--
						--commonlib.echo(w);
						--commonlib.echo(string.format("%s %s %s", r, g, b));
						--
						--ctl:SetValue(string.format("%s %s %s", r, g, b));
					--else
						--ctl:SetValue("255 255 255", true);
					--end
				--end
				--
			--end,
			
			
			
			GetGridItemEnabled = function()
					return true;
				end,
			
			GetGridItemCount = function(level1index, level2index)
					if(level1index == 1) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[3]);
					elseif(level1index == 2) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[2]);
					elseif(level1index == 3) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[5]);
					elseif(level1index == 4) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[4]);
					elseif(level1index == 5) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[1]);
					elseif(level1index == 6) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[6]);
					elseif(level1index == 7) then return table.getn(Map3DSystem.UI.CCS.DB.FaceIconLists[0]);
					end
				end,
			GetGridItemForeImage = function(level1index, level2index, itemindex)
					if(level1index == 1) then return "character/v3/CartoonFace/eyebrow/"..Map3DSystem.UI.CCS.DB.FaceIconLists[3][itemindex];
					elseif(level1index == 2) then return "character/v3/CartoonFace/eye/"..Map3DSystem.UI.CCS.DB.FaceIconLists[2][itemindex];
					elseif(level1index == 3) then return "character/v3/CartoonFace/nose/"..Map3DSystem.UI.CCS.DB.FaceIconLists[5][itemindex];
					elseif(level1index == 4) then return "character/v3/CartoonFace/mouth/"..Map3DSystem.UI.CCS.DB.FaceIconLists[4][itemindex];
					elseif(level1index == 5) then return "character/v3/CartoonFace/facedeco/"..Map3DSystem.UI.CCS.DB.FaceIconLists[1][itemindex];
					elseif(level1index == 6) then return "character/v3/CartoonFace/mark/"..Map3DSystem.UI.CCS.DB.FaceIconLists[6][itemindex];
					elseif(level1index == 7) then return "character/v3/CartoonFace/face/"..Map3DSystem.UI.CCS.DB.FaceIconLists[0][itemindex];
					end
				end,
			GetGridItemBackImage = function(level1index, level2index, itemindex)
					--return "Texture/3DMapSystem/common/ThemeLightBlue/menuitem_over.png: 4 4 4 4";
					--return "Texture/3DMapSystem/Window/RightPanel/ItemBG.png: 8 8 8 8";
					--return "Texture/3DMapSystem/Window/RightPanel/ItemBG.png: 8 8 8 8";
					return "";
				end,
			
			OnClickItem = function(level1index, level2index, itemindex)
					if(mouse_button == "right") then
						local icon;
						if(level1index == 1) then icon = "character/v3/CartoonFace/eyebrow/"..Map3DSystem.UI.CCS.DB.FaceIconLists[3][itemindex];
						elseif(level1index == 2) then icon = "character/v3/CartoonFace/eye/"..Map3DSystem.UI.CCS.DB.FaceIconLists[2][itemindex];
						elseif(level1index == 3) then icon = "character/v3/CartoonFace/nose/"..Map3DSystem.UI.CCS.DB.FaceIconLists[5][itemindex];
						elseif(level1index == 4) then icon = "character/v3/CartoonFace/mouth/"..Map3DSystem.UI.CCS.DB.FaceIconLists[4][itemindex];
						elseif(level1index == 5) then icon = "character/v3/CartoonFace/facedeco/"..Map3DSystem.UI.CCS.DB.FaceIconLists[1][itemindex];
						elseif(level1index == 6) then icon = "character/v3/CartoonFace/mark/"..Map3DSystem.UI.CCS.DB.FaceIconLists[6][itemindex];
						elseif(level1index == 7) then icon = "character/v3/CartoonFace/face/"..Map3DSystem.UI.CCS.DB.FaceIconLists[0][itemindex];
						end
						Map3DSystem.UI.Creator.ShowPreview(icon);
					elseif(mouse_button == "left") then
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
						
						if(level1index == 1) then
							Map3DSystem.UI.CCS.DB.SetFaceComponent(3, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[3][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Eyebrow");
						elseif(level1index == 2) then 
							Map3DSystem.UI.CCS.DB.SetFaceComponent(2, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[2][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Eye");
						elseif(level1index == 3) then 
							Map3DSystem.UI.CCS.DB.SetFaceComponent(5, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[5][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Nose");
						elseif(level1index == 4) then 
							Map3DSystem.UI.CCS.DB.SetFaceComponent(4, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[4][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Mouth");
						elseif(level1index == 5) then 
							Map3DSystem.UI.CCS.DB.SetFaceComponent(1, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[1][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Wrinkle");
						elseif(level1index == 6) then 
							Map3DSystem.UI.CCS.DB.SetFaceComponent(6, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[6][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Marks");
						elseif(level1index == 7) then 
							Map3DSystem.UI.CCS.DB.SetFaceComponent(0, 0, Map3DSystem.UI.CCS.DB.FaceStyleLists[0][itemindex]);
							Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceSection("Face");
						end
						
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
					end
				end,
		};
		ctl = Map3DSystem.UI.TabGrid:new(param);
	end
	
	ctl:Show(true);
end

function Map3DSystem.UI.CCS.Main2.InitInventoryPanel(_parent)

	if(_parent:GetChildCount() > 0) then
		return
	end
	
	local _bg = ParaUI.CreateUIObject("container", "_", "_lt", 16, 16, 40, 40);
	_bg.background = "Texture/3DMapSystem/Creator/icon_bg.png";
	_bg.enabled = false;
	_parent:AddChild(_bg);
	
	local _icon = ParaUI.CreateUIObject("container", "_", "_lt", 20, 20, 32, 32);
	_icon.background = "Texture/3DMapSystem/CCS/Level1_Inventory.png";
	_icon.enabled = false;
	_parent:AddChild(_icon);
	
	local _ = ParaUI.CreateUIObject("text", "_", "_lt", 64, 16, 250, 40);
	_.text = "装备编辑面板\n点击右侧选择各装备类型\n点击装备图标可为角色穿着装备";
	_guihelper.SetFontColor(_, "#FFFFFF");
	_parent:AddChild(_);
	
	--local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -36, 4, 32, 32);
	--_close.background = "Texture/3DMapSystem/Creator/close.png";
	--_close.onclick = ";Map3DSystem.UI.CCS.Main2.Close();";
	--_parent:AddChild(_close);
	
	
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
	
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DB.lua");
	
	---- update the inventory info
	--Map3DSystem.UI.CCS.DB.GetInventoryDB2();
	
	----local _sideBar = ParaUI.CreateUIObject("container", "SideBar", "_mr", 0, 0, 36, 0);
	----_sideBar.background = "Texture/3DMapSystem/CCS/RightPanel/SideTabBG.png; 0 0 36 128: 17 48 17 48";
	--local _sideBar = ParaUI.CreateUIObject("container", "SideBar", "_mr", 0, 0, 48, 20);
	--_sideBar.background = "Texture/3DMapSystem/CCS/RightPanel/SideTabBG2.png: 18 18 18 18";
	--_sideBar.enabled = false;
	--_parent:AddChild(_sideBar);
	
	
	local _tab_INV = ParaUI.CreateUIObject("container", "Tab_INV", "_mr", 16, 70, 60, 85);
	_tab_INV.background = "";
	_parent:AddChild(_tab_INV);
	
	local _inventorySelector = ParaUI.CreateUIObject("container", "Selector", "_fi", 16, 70, 76, 85);
	_inventorySelector.background = "";
	_parent:AddChild(_inventorySelector);
	
	
	NPL.load("(gl)script/ide/TreeView.lua");
	local tabPagesNode_INV = CommonCtrl.TreeNode:new({Name = "CCS_TabControlRootNode_INV"});
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "帽子", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Head.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "肩膀", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Shoulder.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "上衣", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Chest.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "手套", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Gloves.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "裤子", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Pants.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "靴子", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Boots.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "左手", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_HandLeft.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "右手", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_HandRight.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "披风", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Cape.png"}));
	
	NPL.load("(gl)script/ide/TabControl.lua");
		
	local ctl = CommonCtrl.TabControl:new{
			name = "CCS_TabControl_Inventory",
			parent = _tab_INV,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TabAlignment = "Right", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_INV, -- CommonCtrl.TreeNode object, collection of tab pages
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
			TabStartOffset = 40, -- start of the tabs from the border
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
			MaxTabNum = 4, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex)
				local ctl = CommonCtrl.GetControl("InventoryTabGrid");
				if(ctl ~= nil) then
					ctl:SetLevelIndex(toIndex);
				end
			end,
		};
	ctl:Show(true);
	
	-- default to shirt
	ctl:SetSelectedIndex(3);
	
	-- unmount the item according to current character slot on the current character
	function Map3DSystem.UI.CCS.Main2.OnClickUnmountCurrentCharacterSlot()
		
		local ctl = CommonCtrl.GetControl("InventoryTabGrid");
		if(ctl ~= nil) then
			local level1index, _ = ctl:GetLevelIndex();
			local component;
			if(level1index == 1) then
				component = Map3DSystem.UI.CCS.DB.CS_HEAD;
			elseif(level1index == 2) then
				component = Map3DSystem.UI.CCS.DB.CS_SHOULDER;
			elseif(level1index == 3) then
				component = Map3DSystem.UI.CCS.DB.CS_SHIRT;
			elseif(level1index == 4) then
				component = Map3DSystem.UI.CCS.DB.CS_GLOVES;
			elseif(level1index == 5) then
				component = Map3DSystem.UI.CCS.DB.CS_PANTS;
			elseif(level1index == 6) then
				component = Map3DSystem.UI.CCS.DB.CS_BOOTS;
			elseif(level1index == 7) then
				component = Map3DSystem.UI.CCS.DB.CS_HAND_LEFT;
			elseif(level1index == 8) then
				component = Map3DSystem.UI.CCS.DB.CS_HAND_RIGHT;
			elseif(level1index == 9) then
				component = Map3DSystem.UI.CCS.DB.CS_CAPE;
			end
			
			
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
			
			-- temporarily directly mount the item on the selected character
			local player, playerChar = Map3DSystem.UI.CCS.DB.GetPlayerChar();
			if(playerChar~=nil) then
				playerChar:SetCharacterSlot(component, 0);
			end
			
			-- TODO: general implementation
			-- mount the default shirt or pant for human female and male
			local player = ParaScene.GetPlayer();
			local assetName = player:GetPrimaryAsset():GetKeyName();
			
			if(string.find(assetName, "HumanFemale.x") ~= nil) then
				if(component == Map3DSystem.UI.CCS.DB.CS_SHIRT) then
					playerChar:SetCharacterSlot(component, 10);
				elseif(component == Map3DSystem.UI.CCS.DB.CS_PANTS) then
					playerChar:SetCharacterSlot(component, 12);
				end
			end
			
			if(string.find(assetName, "HumanMale.x") ~= nil) then
				if(component == Map3DSystem.UI.CCS.DB.CS_SHIRT) then
					playerChar:SetCharacterSlot(component, 11);
				elseif(component == Map3DSystem.UI.CCS.DB.CS_PANTS) then
					playerChar:SetCharacterSlot(component, 13);
				end
			end
			
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
		end
	end
	
	local ctl = CommonCtrl.GetControl("InventoryTabGrid");
	if(ctl == nil) then
		local param = {
			name = "InventoryTabGrid",
			parent = _inventorySelector,
			background = "Texture/3DMapSystem/Creator/tabcontrol_bg.png;0 0 32 64:16 16 1 16",
			wnd = wnd,
			
			----------- CATEGORY REGION -----------
			Level1 = "Right",
			Level1BG = "",
			Level1HeadBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGTop.png; 0 0 50 24",
			Level1TailBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGBottom.png; 0 0 50 64: 1 0 1 63",
			Level1Offset = 24,
			Level1ItemWidth = 0,
			Level1ItemHeight = 50,
			--Level1ItemGap = 8,
			
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
				local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 11, 9, 32, 32);
				if(bSelected) then
					_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
				else
					_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
				end
				_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
						tabGrid.name, level1index);
				_parent:AddChild(_btn);
			end,
			
			--Level2 = "Top",
			--Level2Offset = 48,
			--Level2ItemWidth = 32,
			--Level2ItemHeight = 48,
			--Level2ItemGap = 0,
			
			----------- GRID REGION -----------
			nGridBorderLeft = 0,
			nGridBorderTop = 8,
			nGridBorderRight = 0,
			nGridBorderBottom = 0,
			
			nGridCellWidth = 48,
			nGridCellHeight = 48,
			nGridCellGap = 8, -- gridview gap between cells
			
			----------- PAGE REGION -----------
			pageRegionHeight = 48,
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
			
			isGridView3D = true, -- show 3D grid
			
			----------- FUNCTION REGION -----------
			GetLevel1ItemCount = function() return 9; end,
			GetLevel1ItemSelectedForeImage = function(index)
					--if(index == 1) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Head.png";
					--elseif(index == 2) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Shoulder.png";
					--elseif(index == 3) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Chest.png";
					--elseif(index == 4) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Gloves.png";
					--elseif(index == 5) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Pants.png";
					--elseif(index == 6) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Boots.png";
					--elseif(index == 7) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_HandLeft.png";
					--elseif(index == 8) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_HandRight.png";
					--elseif(index == 9) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Cape.png";
					--end
					
					if(index == 1) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Head.png";
					elseif(index == 2) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Shoulder.png";
					elseif(index == 3) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Chest.png";
					elseif(index == 4) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Gloves.png";
					elseif(index == 5) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Pants.png";
					elseif(index == 6) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Boots.png";
					elseif(index == 7) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandLeft.png";
					elseif(index == 8) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandRight.png";
					elseif(index == 9) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Cape.png";
					end
				end,
			GetLevel1ItemSelectedBackImage = function(index)
					--return "Texture/3DMapSystem/HeadonPanel/Test2_Btn.png";
					--return "Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png";
					return "Texture/3DMapSystem/Desktop/RightPanel/TabSelected.png; 0 0 50 64: 24 16 12 12";
				end,
			GetLevel1ItemUnselectedForeImage = function(index)
					--if(index == 1) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Head_Fade.png";
					--elseif(index == 2) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Shoulder_Fade.png";
					--elseif(index == 3) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Chest_Fade.png";
					--elseif(index == 4) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Gloves_Fade.png";
					--elseif(index == 5) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Pants_Fade.png";
					--elseif(index == 6) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Boots_Fade.png";
					--elseif(index == 7) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_HandLeft_Fade.png";
					--elseif(index == 8) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_HandRight_Fade.png";
					--elseif(index == 9) then return "Texture/3DMapSystem/CCS/btn_CCS_IT_Cape_Fade.png";
					--end
					
					if(index == 1) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Head.png";
					elseif(index == 2) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Shoulder.png";
					elseif(index == 3) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Chest.png";
					elseif(index == 4) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Gloves.png";
					elseif(index == 5) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Pants.png";
					elseif(index == 6) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Boots.png";
					elseif(index == 7) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandLeft.png";
					elseif(index == 8) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandRight.png";
					elseif(index == 9) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Cape.png";
					end
				end,
			GetLevel1ItemUnselectedBackImage = function(index)
					--return "";
					--return "Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png";
					return "Texture/3DMapSystem/Desktop/RightPanel/TabUnSelected.png; 0 0 50 64";
				end,
			
			
			GetGridItemEnabled = function()
					return true;
				end,
			
			GetGridItemCount = function(level1index, level2index)
					return table.getn(Map3DSystem.UI.CCS.DB.AuraInventoryID[level1index]);
				end,
			GetGrid3DItemModel = function(level1index, level2index, itemindex)
					return Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model;
				end,
			GetGrid3DItemSkin = function(level1index, level2index, itemindex)
					return Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin;
				end,
			
			OnClickItem = function(level1index, level2index, itemindex)
					
					if(mouse_button == "right") then
						local param = {
							AssetFile = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
							x = 0, y = 0, z = 0, 
							ReplaceableTextures = {
								[2] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
								[3] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
								[4] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
								[5] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
						};
						Map3DSystem.UI.Creator.ShowPreview(param);
					elseif(mouse_button == "left") then
						local component;
						if(level1index == 1) then
							component = Map3DSystem.UI.CCS.DB.CS_HEAD;
						elseif(level1index == 2) then
							component = Map3DSystem.UI.CCS.DB.CS_SHOULDER;
						elseif(level1index == 3) then
							component = Map3DSystem.UI.CCS.DB.CS_SHIRT;
						elseif(level1index == 4) then
							component = Map3DSystem.UI.CCS.DB.CS_GLOVES;
						elseif(level1index == 5) then
							component = Map3DSystem.UI.CCS.DB.CS_PANTS;
						elseif(level1index == 6) then
							component = Map3DSystem.UI.CCS.DB.CS_BOOTS;
						elseif(level1index == 7) then
							component = Map3DSystem.UI.CCS.DB.CS_HAND_LEFT;
						elseif(level1index == 8) then
							component = Map3DSystem.UI.CCS.DB.CS_HAND_RIGHT;
						elseif(level1index == 9) then
							component = Map3DSystem.UI.CCS.DB.CS_CAPE;
						end
						
						
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
						
						-- temporarily directly mount the item on the selected character
						local player, playerChar = Map3DSystem.UI.CCS.DB.GetPlayerChar();
						if(playerChar~=nil) then
							--playerChar:SetCharacterSlot(component, Map3DSystem.UI.CCS.DB.AuraInventoryID[level1index][itemindex]);
							Map3DSystem.UI.CCS.Inventory.SetCharacterSlot(player, component, Map3DSystem.UI.CCS.DB.AuraInventoryID[level1index][itemindex]);
						end
						
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
						
						
						-- play animation according to CCS Component
						if(component == Map3DSystem.UI.CCS.DB.CS_SHIRT) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "CCSUpper",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_SHOULDER) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "CCSShoulder",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_GLOVES) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "CCSGlove",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_PANTS) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "CCSPant",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_BOOTS) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "CCSBoot",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_HAND_LEFT) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "LeftChangeSword",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_HAND_RIGHT) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "RightChangeSword",
									});
						elseif(component == Map3DSystem.UI.CCS.DB.CS_HEAD
							or component == Map3DSystem.UI.CCS.DB.CS_CAPE) then
							Map3DSystem.Animation.SendMeMessage({
									type = Map3DSystem.msg.ANIMATION_Character,
									obj_params = nil, --  <player>
									animationName = "CCSHead",
									});
						end
					end
				end,
		};
		ctl = Map3DSystem.UI.TabGrid:new(param);
	end
	
	ctl:Show(true);
	
	-- default to shirt 
	ctl:SetLevelIndex(3);
	
	local _tools = ParaUI.CreateUIObject("container", "Tools", "_mb", 16, 12, 16, 65);
	_tools.background = "Texture/3DMapSystem/Creator/container.png:7 7 7 7";
	_parent:AddChild(_tools);
	
	-- remove item button
	local _remove = ParaUI.CreateUIObject("button", "Remove", "_lt", 32, 16, 40, 40);
	_remove.background = "Texture/3DMapSystem/common/reset.png";
	_remove.onclick = ";Map3DSystem.UI.CCS.Main2.OnClickUnmountCurrentCharacterSlot();";
	_remove.tooltip = "卸下当前装备";
	_tools:AddChild(_remove);
	
	-- purchase
	local _ = ParaUI.CreateUIObject("text", "_", "_lt", 100, 20, 100, 24);
	_guihelper.SetFontColor(_, "90 90 90");
	_.text = "您需购买当前装备";
	_tools:AddChild(_);
	
	local _ = ParaUI.CreateUIObject("text", "_", "_lt", 160, 40, 50, 24);
	_.text = "***E币";
	_guihelper.SetFontColor(_, "90 90 90");
	_tools:AddChild(_);
	
	local _buy = ParaUI.CreateUIObject("container", "Buy", "_lt", 210, 24, 24, 24);
	_buy.background = "Texture/3DMapSystem/common/Shopping.png";
	_buy.tooltip = "购买";
	_tools:AddChild(_buy);
end


function Map3DSystem.UI.CCS.Main2.InitHairPanel(_parent)
	
	if(_parent:GetChildCount() > 0) then
		return
	end
	local _bg = ParaUI.CreateUIObject("container", "_", "_lt", 16, 16, 40, 40);
	_bg.background = "Texture/3DMapSystem/Creator/icon_bg.png";
	_bg.enabled = false;
	_parent:AddChild(_bg);
	
	local _icon = ParaUI.CreateUIObject("container", "_", "_lt", 20, 20, 32, 32);
	_icon.background = "Texture/3DMapSystem/CCS/Level1_Hair.png";
	_icon.enabled = false;
	_parent:AddChild(_icon);
	
	local _ = ParaUI.CreateUIObject("text", "_", "_lt", 64, 16, 200, 40);
	_.text = "发型发色编辑面板\n上面板可以选择头发样式\n下面板可以选择头发的颜色";
	_guihelper.SetFontColor(_, "#FFFFFF");
	_parent:AddChild(_);
	
	--local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -36, 4, 32, 32);
	--_close.background = "Texture/3DMapSystem/Creator/close.png";
	--_close.onclick = ";Map3DSystem.UI.CCS.Main2.Close();";
	--_parent:AddChild(_close);
	
	
	--local _this = ParaUI.CreateUIObject("text", "HairStyleText", "_lt", 30, 25, 150, 32);
	--_this.text = "头发类型:";
	--_parent:AddChild(_this);
	
	
	--local left, top = 10, 10;
	--local _this = ParaUI.CreateUIObject("button", "HairStyle", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairStyle(0);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairStyle", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairStyle(1);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairStyle", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairStyle(2);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairStyle", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairStyle(3);";
	--_parent:AddChild(_this);
	--
	--left = left - 180;
	--top = top + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairStyle", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairStyle(4);";
	--_parent:AddChild(_this);
	
	
	local function OwnerDrawGridCellHandler(_parent, gridcell)
		if(_parent == nil or gridcell == nil) then
			return;
		end
		
		if(gridcell ~= nil) then
			local _this = ParaUI.CreateUIObject("button", gridcell.name, "_fi", 25, 5, 5, 5);
			--_this.text = "HairStyle"..gridcell.index;
			_this.background = gridcell.icon;
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairStyle("..gridcell.index..");";
			_parent:AddChild(_this);
		end
	end
	
	
	NPL.load("(gl)script/ide/GridView.lua");
	local ctl = CommonCtrl.GetControl("HairStyleGridView");
	if(ctl == nil) then
		ctl = CommonCtrl.GridView:new{
			name = "HairStyleGridView",
			alignment = "_lt",
			container_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
			left = 16, top = 70,
			width = 290,
			height = 148 + 8,
			cellWidth = 94,
			cellHeight = 74,
			parent = _parent,
			columns = 3,
			rows = 2,
			DrawCellHandler = OwnerDrawGridCellHandler,
		};
		
		local index = 0;
		for i = 1, 5 do
			local cell = CommonCtrl.GridCell:new{
				GridView = nil,
				name = "HairStyle"..i,
				icon = "character/v3/Human/hairshots/hairstyle_human_female_"..(i-1)..".png",
				index = i,
				column = i - math.floor((i-1)/3)*3,
				row = math.floor((i-1)/3) + 1,
				};
			ctl:InsertCell(cell, "Right");
		end
	end

	ctl:Show();
	
	function Map3DSystem.UI.CCS.Main2.SetHairStyle(index)
		--log("style"..index.."\n");
		--if(index == 0) then
			---- baldy
			--
		--elseif(index >= 1) then
			---- with hair
			--
		--end
		
		local player = ParaScene.GetPlayer();
		local playerChar = player:ToCharacter();
		
		--playerChar:SetBodyParams(math.ceil(index/2)-1, -1, -1, -1, -1);
		
		playerChar:SetBodyParams(-1, -1, -1, index-1, -1);
	end
	
	
	--local _this = ParaUI.CreateUIObject("text", "HairColorText", "_lt", 30, 250, 150, 32);
	--_this.text = "头发颜色:";
	--_parent:AddChild(_this);
	
	
	--local left, top = 10, 350;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(1);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(2);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(3);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(4);";
	--_parent:AddChild(_this);
	--
	--left = left - 180;
	--top = top + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(5);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(6);";
	--_parent:AddChild(_this);
	--
	--left = left + 60;
	--local _this = ParaUI.CreateUIObject("button", "HairColor", "_lt", left, top, 48, 48);
	--_this.background = nil;
	--_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor(7);";
	--_parent:AddChild(_this);
	
	local function OwnerDrawGridCellHandler(_parent, gridcell)
		if(_parent == nil or gridcell == nil) then
			return;
		end
		
		if(gridcell ~= nil) then
			local _this = ParaUI.CreateUIObject("button", gridcell.name, "_fi", 15,5,15,5);
			_this.background = gridcell.icon;
			_this.onclick = ";Map3DSystem.UI.CCS.Main2.SetHairColor("..gridcell.index..");";
			_parent:AddChild(_this);
		end
	end
	
	NPL.load("(gl)script/ide/GridView.lua");
	local ctl = CommonCtrl.GetControl("HairColorGridView");
	if(ctl == nil) then
		ctl = CommonCtrl.GridView:new{
			name = "HairColorGridView",
			alignment = "_lt",
			container_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
			left = 16, top = 250,
			width = 290,
			height = 160, --252,
			cellWidth = 94,
			cellHeight = 74,
			parent = _parent,
			columns = 3,
			rows = 3,
			DrawCellHandler = OwnerDrawGridCellHandler,
		};
		
		local index = 0;
		for i = 1, 7 do
			local cell = CommonCtrl.GridCell:new{
				GridView = nil,
				name = "HairColor"..i,
				icon = "character/v3/Human/hairshots/haircolor_human_female_"..i..".png",
				index = i,
				column = i - math.floor((i-1)/3)*3,
				row = math.floor((i-1)/3) + 1,
				};
			ctl:InsertCell(cell, "Right");
		end
	end

	ctl:Show();
	
	
	function Map3DSystem.UI.CCS.Main2.SetHairColor(index)
		--log(index.."color \n");
		local player = ParaScene.GetPlayer();
		local playerChar = player:ToCharacter();
		playerChar:SetBodyParams(-1, -1, index-1, -1, -1);
	end
end