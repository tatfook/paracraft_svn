--[[
Title: CCS modify panel
Author(s): WangTian
Date: 2008/6/5
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Modify.lua");
Map3DSystem.UI.CCS.Modify.ShowMainWnd(true);
Map3DSystem.UI.CCS.Modify.UpdatePanelUI();
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

if(not Map3DSystem.UI.CCS) then Map3DSystem.UI.CCS = {}; end
if(not Map3DSystem.UI.CCS.Modify) then Map3DSystem.UI.CCS.Modify = {}; end

-- Show the Sky main window
function Map3DSystem.UI.CCS.Modify.ShowMainWnd(bShow)
	local _app = Map3DSystem.App.CCS.app._app;
	local _wnd = _app:FindWindow("ModifyWnd") or _app:RegisterWindow("ModifyWnd", nil, Map3DSystem.UI.CCS.Modify.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		frame:Show2(bShow);
	else
		local sampleWindowsParam = {
			wnd = _wnd, -- a CommonCtrl.os.window object
			
			isShowTitleBar = false, -- default show title bar
			isShowToolboxBar = false, -- default hide title bar
			isShowStatusBar = false, -- default show status bar
			
			initialWidth = 512, -- initial width of the window client area
			initialHeight = 80, -- initial height of the window client area
			
			initialPosX = 204, -- initial width of the window client area
			
			style = CommonCtrl.WindowFrame.DefaultPanel,
			
			alignment = "LeftBottom", -- Free|Left|Right|Bottom
			
			ShowUICallback = Map3DSystem.UI.CCS.Modify.Show,
		};
		
		frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
		frame:Show2(bShow);
	end
	
	if(bShow ~= false) then
		Map3DSystem.UI.CCS.Modify.UpdatePanelUI();
	end
end

-- Message Processor of CCS main control
-- On receive WM_SIZE message it will update the CreationTabGrid control
function Map3DSystem.UI.CCS.Modify.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		log("WM_SIZE not handled in Map3DSystem.UI.CCS.Modify.MSGProc()\n");
	end
end

-- show the CCS in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
function Map3DSystem.UI.CCS.Modify.Show(bShow, _parent, parentWindow)
	
	Map3DSystem.UI.CCS.Modify.parentWindow = parentWindow;
	
	local _this;
	_this = ParaUI.GetUIObject("CCS_Modify_Main");
	
	if(_this:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "CCS_Modify_Main", "_lt", 0, 50, 300, 500);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "CCS_Modify_Main", "_fi", 0, 0, 0, 0);
			_this.background = "";
			_parent:AddChild(_this);
		end
		
		local _panel = _this;
		
		local SubPanelOffsetX = 0;
		local SubPanelOffsetY = 8;
		local SubPanelWidth = 512;
		local SubPanelHeight = 64;
		
		local _sub_panel = _panel:GetChild("_CCS_sub_panel_modify");
		if(_sub_panel:IsValid() == false) then
			-- Modify sub panel for the first run
			local _sub_panel = ParaUI.CreateUIObject("container", "_CCS_sub_panel_modify", "_lt", 
				SubPanelOffsetX, SubPanelOffsetY, SubPanelWidth, SubPanelHeight);
			_sub_panel.background = "";
			_panel:AddChild(_sub_panel);
			
			local left, top = 16, 4;
			
			-- switch character
			_this = ParaUI.CreateUIObject("button", "CCS_Switch_Character", "_lt", left, top, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/MainBarIcon/Possession.png; 0 0 48 48";
			_this.onclick = ";Map3DSystem.UI.CCS.Modify.OnSwitchToObject();"
			
			local obj = Map3DSystem.obj.GetObjectParams("selection");
			if(obj ~= nil and obj.IsCharacter) then
				_this.enabled = true;
			else
				_this.enabled = false;
			end
			
			left = left + 48 + 8;
			-- toggle normal face and cartoon face
			_this = ParaUI.CreateUIObject("button", "Toggle_Face", "_lt", left, top, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/CCS/btn_Toggle_FaceType.png";
			_this.onclick = ";Map3DSystem.UI.CCS.Modify.OnToggleFaceClick();"
			
			left = left + 48 + 8;
			-- Hair style
			_this = ParaUI.CreateUIObject("button", "Hair_Style", "_lt", left, top, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/CCS/btn_CCS_HairStyle_Icon.png";
			_this.onclick = ";Map3DSystem.UI.CCS.Modify.OnHairStyleClick();";
			
			left = left + 48 + 8;
			-- Hair color
			_this = ParaUI.CreateUIObject("button", "Hair_Color", "_lt", left, top, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/CCS/btn_CCS_HairColor_Icon.png";
			_this.onclick = ";Map3DSystem.UI.CCS.Modify.OnHairColorClick();";
			
			left = left + 48 + 8;
			-- magnify object
			_this = ParaUI.CreateUIObject("button", "Magnify_Character", "_lt", left, top, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/modify/magnify.png";
			_this.onclick = ";Map3DSystem.UI.CCS.Modify.OnMagnifyClick();";
			
			left = left + 48 + 8;
			-- minify object
			_this = ParaUI.CreateUIObject("button", "Minify_Character", "_lt", left, top, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/modify/minify.png";
			_this.onclick = ";Map3DSystem.UI.CCS.Modify.OnMinifyClick();";
			
			
			
			-- Save CCS infomation button
			_this = ParaUI.CreateUIObject("button", "Save_CCS_Info", "_rt", -64, 4, 48, 48);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/MainBarIcon/Save_2.png";
			_this.onclick=";Map3DSystem.UI.Creator.Modify.OnSaveClick();";
			
		else
			-- show Modify sub panel
			_sub_panel.visible = true;
		end --if(_sub_panel:IsValid() == false) then
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- update the toggle face hair style and color magnify and minify
function Map3DSystem.UI.CCS.Modify.UpdatePanelUI()
	
	local _sub_panel = ParaUI.GetUIObject("_CCS_sub_panel_modify");
	
	local _toggleFace = _sub_panel:GetChild("Toggle_Face");
	local _hairStyle = _sub_panel:GetChild("Hair_Style");
	local _hairColor = _sub_panel:GetChild("Hair_Color");
	local _magnify = _sub_panel:GetChild("Magnify_Character");
	local _minify = _sub_panel:GetChild("Minify_Character");
	local _save = _sub_panel:GetChild("Save_CCS_Info");
	
	-- update according to the selected object
	local _switch = ParaUI.GetUIObject("CCS_Switch_Character");
	local obj = Map3DSystem.obj.GetObjectParams("selection");
	if(obj ~= nil and obj.IsCharacter) then
		_switch.enabled = true;
	else
		_switch.enabled = false;
	end
	
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
	
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	
	-- TODO: camera mode free camera will ruin the default focus on the current character
	if(playerChar:IsCustomModel() == true) then
		if(playerChar:IsSupportCartoonFace() == true) then
		
			local charFaceType = playerChar:GetBodyParams(1);
			local cartoonFaceType = playerChar:GetBodyParams(4);
			
			if(charFaceType >= 0 and cartoonFaceType == 0) then
				-- normal face
				Map3DSystem.UI.CCS.Modify.CurrentFaceType = "NormalFace";
				_toggleFace.background = "Texture/3DMapSystem/CCS/btn_Toggle_FaceType.png";
				Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(false);
				-- TODO: disable the cartoon face panel
			elseif(charFaceType >= 0 and cartoonFaceType == 1) then
				-- cartoon face
				Map3DSystem.UI.CCS.Modify.CurrentFaceType = "CartoonFace";
				_toggleFace.background = "Texture/3DMapSystem/CCS/btn_Toggle_CartoonFace.png";
				Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(true);
			end
			
			_toggleFace.enabled = true;
			_hairStyle.enabled = true;
			_hairColor.enabled = true;
			_magnify.enabled = true;
			_minify.enabled = true;
			_save.enabled = true;
			Map3DSystem.UI.CCS.Main2.SetEnabledInventoryPanel(true);
		else
			-- not support cartoon face
			_toggleFace.enabled = false;
			_hairStyle.enabled = true;
			_hairColor.enabled = true;
			_magnify.enabled = true;
			_minify.enabled = true;
			_save.enabled = true;
			Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(false);
			Map3DSystem.UI.CCS.Main2.SetEnabledInventoryPanel(true);
		end
	else
		-- TODO: disable the inventory panel
		-- not customizable model
		_toggleFace.enabled = false;
		_hairStyle.enabled = false;
		_hairColor.enabled = false;
		_magnify.enabled = true;
		_minify.enabled = true;
		_save.enabled = true;
		Map3DSystem.UI.CCS.Main2.SetEnabledFacialPanel(false);
		Map3DSystem.UI.CCS.Main2.SetEnabledInventoryPanel(false);
	end
	
	-- update the object canvas with selected object
	local ctl = CommonCtrl.GetControl("Map3dsystem_Modify_Obj_Canvas3D");
	if(ctl ~= nil) then
		if(obj == nil) then
			ctl:ShowModel();
		else
			local setBackName = obj.name;
			obj.name = nil;
			ctl:ShowModel(obj);
			obj.name = setBackName;
		end
	end
end

-- Take control of the currently selected character.
function Map3DSystem.UI.CCS.Modify.OnSwitchToObject()
	local player = ObjEditor.GetCurrentObj();
	if(player:IsCharacter() == true) then
		if((player:IsGlobal() ==true) and (player:IsCharacter() == true) and (player:IsOPC()==false)) then
			ParaCamera.FollowObject(player);
			Map3DSystem.UI.CCS.Modify.UpdatePanelUI();
		else
			_guihelper.MessageBox("你不能切换到这个人物\n");
		end
	else
		_guihelper.MessageBox("请选中一个人物完成切换\n");
	end
	
	-- update CCS side window UI
end

function Map3DSystem.UI.CCS.Modify.OnToggleFaceClick()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
	local playerChar = ParaScene.GetPlayer():ToCharacter();
	if(Map3DSystem.UI.CCS.Modify.CurrentFaceType == "CartoonFace") then
		-- set to character face
		Map3DSystem.UI.CCS.Modify.CurrentFaceType = "NormalFace";
		playerChar:SetBodyParams(-1, 1, -1, -1, 0);
	elseif(Map3DSystem.UI.CCS.Modify.CurrentFaceType == "NormalFace") then
		-- set to cartoon face
		Map3DSystem.UI.CCS.Modify.CurrentFaceType = "CartoonFace";
		playerChar:SetBodyParams(-1, -1, -1, -1, 1);
	end
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
end

function Map3DSystem.UI.CCS.Modify.OnHairStyleClick()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
	Map3DSystem.UI.CCS.Predefined.NextHairStyle();
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
end

function Map3DSystem.UI.CCS.Modify.OnHairColorClick()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
	Map3DSystem.UI.CCS.Predefined.NextHairColor();
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
end

function Map3DSystem.UI.CCS.Modify.OnMagnifyClick()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), scale_delta=1.1});
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
end

function Map3DSystem.UI.CCS.Modify.OnMinifyClick()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), scale_delta=0.9});
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
end