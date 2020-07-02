--[[
Title: Modify in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/17
Desc: Show the Modify panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Modify.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/mathlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Predefined.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main.lua");

commonlib.echo("warning: Map3DSystem.UI.Modify is obsoleted. but in use. ")
commonlib.set("Map3DSystem.UI.Modify", {})

function Map3DSystem.UI.Modify.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("ModifyWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("ModifyWnd recv MSG WM_SIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("ModifyWnd recv MSG WM_HIDE.\n");
		Map3DSystem.UI.Modify.CloseUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("ModifyWnd recv MSG WM_SHOW.\n");
		Map3DSystem.UI.Modify.ShowUI();
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_Modify_Show) then
		-- show or hide the modify panel, nil to toggle current setting
		Map3DSystem.UI.Modify.Show(msg.bShow);
	end
end

function Map3DSystem.UI.Modify.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Modify.WndObject = app:RegisterWindow(
		"ModifyWnd", mainWndName, Map3DSystem.UI.Modify.MSGProc);
	
	-- !TODO: unhook the status change hook
	
	-- hook into the "mouse_move" window in "input" application, and detect the mouse to 
	-- translate the object icon position
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
		callback = function(nCode, appName, msg)
			-- return the nCode to be passed to the next hook procedure in the hook chain. 
			-- in most cases, if nCode is nil, the hook procedure should do nothing. 
			if(nCode == nil) then return end
			-- TODO: do your code here
			if(msg.status ~= nil) then
				--_guihelper.MessageBox("change to status: "..msg.status.."\n");
				local _item = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Modify");
				
				if(_item == nil) then
					return;
				end
				if(msg.status == "BCSXRef" or msg.status == "none") then
					_item.enabled = false;
					Map3DSystem.UI.MainPanel.ShowPanel(3, false);
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = false;
					end
				elseif(msg.status == "character" or msg.status == "model") then
					_item.enabled = true;
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = true;
					end
				end
			end
			return nCode;
		end, 
		hookName = "ModifyPanelChangeStatusHook", appName = "MainBar", wndName = "MainBarWnd"});
end

-- send a message to MainPanel:ModifyWnd window handler
-- e.g. Map3DSystem.UI.Modify.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_Modify_Show, bShow = true})
function Map3DSystem.UI.Modify.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.Modify.WndObject.name;
	Map3DSystem.UI.MainPanel.App:SendMessage(msg);
end

-- show or hide the modify panel, bShow == nil, toggle current setting
function Map3DSystem.UI.Modify.Show(bShow)
	Map3DSystem.UI.MainPanel.ShowPanel(3, bShow);
end

function Map3DSystem.UI.Modify.ShowUI()

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	if(_panel:IsValid() == false) then
		log("MainBar panel container is not yet initialized.\r\n");
		return;
	end
	
	local _obj = Map3DSystem.obj.GetObject("selection");
	if(_obj == nil or _obj:IsValid() == false) then
		return;
	end	
	
	--local _icon = ParaUI.GetUIObject("MainBar_icons_3"); --  the main bar modify icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Modify");
	local x, y, width, height = _icon:GetAbsPosition();
	
	Map3DSystem.UI.MainPanel.SendMeMessage(
			{type = Map3DSystem.msg.MAINPANEL_SetPosX,
			posX = x});
	
	if(_obj:IsCharacter() == false) then
	
		Map3DSystem.Animation.SendMeMessage({
				type = Map3DSystem.msg.ANIMATION_Character,
				obj_params = nil, --  <player>
				animationName = "ModifyObject",
				});
			
		local _sub_panel = _panel:GetChild("_sub_panel_modify_model");
		if(_sub_panel:IsValid() == false) then
			-- Modify sub panel for the first run
			local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_modify_model", "_lt",
				Map3DSystem.UI.MainPanel.SubPanelOffsetX + 50, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
				Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
			_sub_panel.background = "";
			_panel:AddChild(_sub_panel);
			
			---- test button
			--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
			--_temp.text = "modify";
			--_sub_panel:AddChild(_temp);
			
			left=15-255;
			top=16-160/2;
			-- translate object
			_this=ParaUI.CreateUIObject("button","map3dsystem_m_translate_btn","_ct",left,top,128,128);
			_sub_panel:AddChild(_this);
			_this.background="Texture/3DMapSystem/modify/object_move.png";
			_this.onclick = ";Map3DSystem.UI.Modify.OnTranslationClick();"
			
			left=left+128+30;
			-- rotate object
			_this=ParaUI.CreateUIObject("button","map3dsystem_m_rotate_btn","_ct",left,top,128,128);
			_sub_panel:AddChild(_this);
			_this.background="Texture/3DMapSystem/modify/object_rotate.png";
			_this.onclick = ";Map3DSystem.UI.Modify.OnRotationClick();"
				
			left=left+128+30;
			-- magnify object
			_this=ParaUI.CreateUIObject("button","map3dsystem_m_magnify_btn","_ct",left,top,64,64);
			_sub_panel:AddChild(_this);
			_this.background="Texture/3DMapSystem/modify/magnify.png";
			_this.onclick=";Map3DSystem.UI.Modify.OnMagnifyClick();";
			
			-- minify object
			_this=ParaUI.CreateUIObject("button","map3dsystem_m_minify_btn","_ct",left,top+66,64,64);
			_sub_panel:AddChild(_this);
			_this.background="Texture/3DMapSystem/modify/minify.png";
			_this.onclick=";Map3DSystem.UI.Modify.OnMinifyClick();";
			left=left+95;
			
			-- translate to here	
			_this=ParaUI.CreateUIObject("button","map3dsystem_m_here_btn","_ct",left,top,64,64);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/modify/btn_here.png";
			_this.onclick=";Map3DSystem.UI.Modify.OnMoveHereClick();";
			
			-- reset button
			_this=ParaUI.CreateUIObject("button","map3dsystem_m_reset_btn","_ct",left,top+70,64,64);
			_sub_panel:AddChild(_this);
			_this.background = "Texture/3DMapSystem/modify/btn_reset.png";
			_this.onclick=";Map3DSystem.UI.Modify.OnResetClick();";
		else
			-- show Modify sub panel
			_sub_panel.visible = true;
		end --if(_sub_panel:IsValid() == false) then
		
	else -- if(_obj:IsCharacter() == false) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_modify_character");
		if(_sub_panel:IsValid() == false) then
			-- Modify sub panel for the first run
			local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_modify_character", "_fi", 
				Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 0, 0);
				--Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
			_sub_panel.background = "";
			_panel:AddChild(_sub_panel);
			
			---- test button
			--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
			--_temp.text = "modify";
			--_sub_panel:AddChild(_temp);
			
			
			ToLeft = 200;
			ToBottom = 5;
			ToRight = 560; -- 560
			MidHeight = 170;
			
			local _CCSMainMenu = ParaUI.CreateUIObject("container","map3dsystem_ccs_container", "_fi", 0, 0, 0, 0);
			_sub_panel:AddChild(_CCSMainMenu);
			_CCSMainMenu.background="Texture/whitedot.png;0 0 0 0";
			
			Map3DSystem.UI.CCS.ToLeft = ToLeft;
			Map3DSystem.UI.CCS.ToBottom = ToBottom;
			Map3DSystem.UI.CCS.ToRight = ToRight;
			Map3DSystem.UI.CCS.MidHeight = MidHeight;

			_this = ParaUI.CreateUIObject("container","map3dsystem_ccs_level0_container", "_fi", 0, 0, 0, 0);
			_this.background = "";
			_CCSMainMenu:AddChild(_this);

			local _parent = _this;

			_this = ParaUI.CreateUIObject("button", "btnMain1", "_lt", 0, 6, 48, 48)
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_Toggle_FaceType.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			--_this.text = "C";
			_this.animstyle = 11;
			_this.onclick = ";Map3DSystem.UI.Modify.ToggleFace();";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain2", "_lt", 48, 6, 48, 48)
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_FaceType_Icon.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			_this.onclick = ";Map3DSystem.UI.Modify.FaceClick();";
			--_this.onclick = ";Map3DSystem.UI.Modify.ShowCCSMenu(\"CartoonFace\");";
			--_this.text = "I";
			_this.animstyle = 11;
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain3", "_lt", 96, 6, 48, 48)
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_Inventory_Icon.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			--_this.text = "FaceType";
			_this.animstyle = 11;
			_this.onclick = ";Map3DSystem.UI.Modify.ShowCCSMenu(\"Inventory\");";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain4", "_lt", 0, 54, 48, 48)
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_HairStyle_Icon.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			--_this.text = "HairStyle";
			_this.animstyle = 11;
			_this.onclick = ";Map3DSystem.UI.Modify.NextHairStyle();";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain5", "_lt", 48, 54, 48, 48)
			_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_HairColor_Icon.png", 
				"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			--_this.text = "HairColor";
			_this.animstyle = 11;
			_this.onclick = ";Map3DSystem.UI.Modify.NextHairColor();";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain6", "_lt", 96, 54, 48, 48)
			--_this.text = "6";
			_this.background="Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain7", "_lt", 0, 102, 48, 48)
			--_this.text = "7";
			--_this.animstyle = 11;
			--_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_Height_Up.png", 
				--"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			_this.onclick=";Map3DSystem.UI.Modify.OnMagnifyClick();";
			_this.background="Texture/3DMapSystem/CCS/btn_CCS_Height_Up.png";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain8", "_lt", 48, 102, 48, 48)
			--_this.text = "8";
			--_this.animstyle = 11;
			--_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_Height_Down.png", 
				--"Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png");
			_this.onclick=";Map3DSystem.UI.Modify.OnMinifyClick();";
			_this.background="Texture/3DMapSystem/CCS/btn_CCS_Height_Down.png";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnMain9", "_lt", 96, 102, 48, 48)
			--_this.text = "9";
			_this.background="Texture/3DMapSystem/CCS/btn_CCS_EmptySlot_Icon.png";
			_parent:AddChild(_this);


			-- Icon Matrix
			local iconMatrixLeft = 170;
			local iconMatrixTop = 20;
			local iconMatrixGap = 1;
			local iconMatrixX = 6;
			local iconMatrixY = 2;
			local iconMatrixIconSize = 48;
			local iconMatrixIconOffset = 3;
			local iconMatrixBGSize = 57;
			local iconMatrixGap = 5;
			local index;
			
			for y=0, iconMatrixY - 1 do
				for x=0, iconMatrixX - 1 do
					_this = ParaUI.CreateUIObject("container", "CCS_modify_BG_matrix_"..x..y, "_lt", 
						iconMatrixLeft + (iconMatrixBGSize + iconMatrixGap) * x, 
						iconMatrixTop + (iconMatrixBGSize + iconMatrixGap) * y, 
						iconMatrixBGSize, iconMatrixBGSize);
					-- TODO : change the background
					_this.background="Texture/3DMapSystem/CCS/btn_BCS_Icon_Slot.png";
					_parent:AddChild(_this);
					
					local _BG = _this;
					
					_this = ParaUI.CreateUIObject("button", "CCS_modify_matrix_"..x..y, "_lt", 
						iconMatrixIconOffset, 
						iconMatrixIconOffset, 
						iconMatrixIconSize, iconMatrixIconSize);
						
					index = x + y * iconMatrixX;
					_this.animstyle = 11;
					_this.onclick = ";Map3DSystem.UI.Modify.OnCCSModifyClick("..index..");";
					_BG:AddChild(_this);
				end
			end
			
			local _nCount_ccs_original = table.getn(Map3DSystem.DB.Items["CCS_01original"]);
			local _nCount_ccs_test = table.getn(Map3DSystem.DB.Items["CCS_02test"]);
			
			for y=0, iconMatrixY - 1 do
				for x=0, iconMatrixX - 1 do
					index = x + y * iconMatrixX;
					_this = ParaUI.GetUIObject("CCS_modify_matrix_"..x..y);
					if(index < _nCount_ccs_original) then
						_this.background = Map3DSystem.DB.Items["CCS_01original"][index + 1].IconFilePath;
					elseif(index < (_nCount_ccs_original + _nCount_ccs_test) and index >= _nCount_ccs_original) then
						_this.background = Map3DSystem.DB.Items["CCS_02test"][index - _nCount_ccs_original + 1].IconFilePath;
					elseif(index >= (_nCount_ccs_original + _nCount_ccs_test)) then
						_this.background = "";
					end
				end
			end

			--
			--_this = ParaUI.CreateUIObject("text", "labelRace", "_lt", 165, 23, 88, 16)
			--_this.text = "种族:";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("text", "labelGender", "_lt", 165, 77, 104, 16)
			--_this.text = "性别:";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("text", "labelHeight", "_lt", 165, 115, 104, 16)
			--_this.text = "身高:";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnRaceHuman", "_lt", 222, 8, 48, 48)
			----_this.text = "H";
			--_this.background="Texture/kidui/CCS/btn_CCS_Race_Human.png";
			--_this.onclick=";CCS_main.UpdateCharacterInfo(\"HumanClick\");";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnRaceChild", "_lt", 284, 8, 48, 48)
			----_this.text = "C";
			--_this.background="Texture/kidui/CCS/btn_CCS_Race_Child.png;";
			--_this.onclick=";CCS_main.UpdateCharacterInfo(\"ChildClick\");";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "buttonMale", "_lt", 238, 68, 32, 32)
			----_this.text = "M";
			--_this.background="Texture/kidui/CCS/btn_CCS_Gender_Male.png";
			--_this.onclick = ";CCS_main.UpdateCharacterInfo(\"MaleClick\");";
			----Map3DSystem.UI.CCS.Predefined.ResetBaseModel(\"character/v3/Child/\", \"Male\"); 
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "buttonFemale", "_lt", 284, 68, 32, 32)
			----_this.text = "F";
			--_this.background="Texture/kidui/CCS/btn_CCS_Gender_Female.png";
			--_this.onclick = ";CCS_main.UpdateCharacterInfo(\"FemaleClick\");";
			----Map3DSystem.UI.CCS.Predefined.ResetBaseModel(\"character/v3/Child/\", \"Female\"); 
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnCharZoomIn", "_lt", 238, 106, 32, 32)
			----_this.text = "+";
			--_this.background="Texture/kidui/CCS/btn_CCS_Height_Up.png";
			--_this.onclick=";Map3DSystem.UI.Modify.OnMagnifyClick();";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnCharZoomOut", "_lt", 284, 106, 32, 32)
			----_this.text = "-";
			--_this.background="Texture/kidui/CCS/btn_CCS_Height_Down.png";
			--_this.onclick=";Map3DSystem.UI.Modify.OnMinifyClick();";
			--_parent:AddChild(_this);
			--
			---- DEBUG PURPOSE
			--_this = ParaUI.CreateUIObject("button", "btnTest", "_lt", 350, 40, 40, 40)
			--_this.text = "Angel F";
			--_this.onclick=";Map3DSystem.UI.Modify.TestCharacter(1);";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnTest", "_lt", 350, 80, 40, 40)
			--_this.text = "Angel M";
			--_this.onclick=";Map3DSystem.UI.Modify.TestCharacter(2);";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnTest", "_lt", 400, 40, 40, 40)
			--_this.text = "Momo F";
			--_this.enable = false;
			--_this.onclick=";Map3DSystem.UI.Modify.TestCharacter(3);";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnTest", "_lt", 400, 80, 40, 40)
			--_this.text = "Momo M";
			--_this.onclick=";Map3DSystem.UI.Modify.TestCharacter(4);";
			--_parent:AddChild(_this);
			--
			--
			--_this = ParaUI.CreateUIObject("button", "btnTest", "_lt", 450, 40, 40, 40)
			--_this.text = "Horse F";
			--_this.onclick=";Map3DSystem.UI.Modify.TestCharacter(5);";
			--_parent:AddChild(_this);
			--
			--_this = ParaUI.CreateUIObject("button", "btnTest", "_lt", 450, 80, 40, 40)
			--_this.text = "Horse M";
			--_this.enable = false;
			--_this.onclick=";Map3DSystem.UI.Modify.TestCharacter(6);";
			--_parent:AddChild(_this);
			
		else
			-- show Modify sub panel
			_sub_panel.visible = true;
		end --if(_sub_panel:IsValid() == false) then
	end

end

function Map3DSystem.UI.Modify.OnCCSModifyClick(index)

	local _nCount_ccs_original = table.getn(Map3DSystem.DB.Items["CCS_01original"]);
	local _nCount_ccs_test = table.getn(Map3DSystem.DB.Items["CCS_02test"]);
	
	local _modelFilePath;
	
	if(index < _nCount_ccs_original) then
		_modelFilePath = Map3DSystem.DB.Items["CCS_01original"][index + 1].ModelFilePath;
	elseif(index < (_nCount_ccs_original + _nCount_ccs_test) and index >= _nCount_ccs_original) then
		_modelFilePath = Map3DSystem.DB.Items["CCS_02test"][index - _nCount_ccs_original + 1].ModelFilePath;
	elseif(index >= (_nCount_ccs_original + _nCount_ccs_test)) then
		return;
	end
	
	local _path;
	
	local _dir = string.find(_modelFilePath, "character/v3/")
	if(_dir ~= nil) then
		local _full = string.sub(_modelFilePath, 14);
		local _slash1 = string.find(_full, '/');
		if(_slash1 ~= nil) then
			local _slash2 = string.find(_full, '/', _slash1 + 1);
			if(_slash2 ~= nil) then
				_path = string.sub(_full, 1, _slash2 - 1);
			end
		end
	end
	if(_path == nil) then
		return;
	end
	
	if(_path) then
		local index = string.find(_path, "/");
		if(index~=nil) then
			local _race = string.sub(_path, 1, index - 1);
			local _gender = string.sub(_path, index + 1);
			Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/".._race.."/", _gender);
			
			-- play "CharacterBorn" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = Map3DSystem.obj.GetObject("selection"),
					--animationName = "CharacterBorn",
					animationName = "CharacterBorn",
					});
		else
			log("warning: no / found in path. see Map3DSystem.UI.Modify.OnCCSModifyClick \n")
		end			
	end
end

--function Map3DSystem.UI.Modify.TestCharacter(i)
	--if(i == 1) then
		--Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/Angel/", "Female");
	--elseif(i == 2) then
		--Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/Angel/", "Male");
	--elseif(i == 3) then
		----Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/Momo/", "Female");
	--elseif(i == 4) then
		--Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/Momo/", "Male");
	--elseif(i == 5) then
		--Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/Horse/", "Female");
	--elseif(i == 6) then
		----Map3DSystem.UI.CCS.Predefined.ResetBaseModel("character/v3/Horse/", "Male");
	--end
--end

function Map3DSystem.UI.Modify.ShowCCSMenu(name)
	--CommonCtrl.CKidMiddleContainer.ShowCCSMenu(name);
	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid() == true) then
		if(obj:IsCharacter() == true and obj:ToCharacter():IsCustomModel() == true) then
			if(name == "CartoonFace") then
				Map3DSystem.UI.CCS.ShowCartoonFace(true);
			elseif(name == "Inventory") then
				Map3DSystem.UI.CCS.ShowInventory(true);
			end
			return;
		end
	end
end

function Map3DSystem.UI.Modify.NextHairStyle()
	Map3DSystem.UI.CCS.Predefined.NextHairStyle();
end

function Map3DSystem.UI.Modify.NextHairColor()
	Map3DSystem.UI.CCS.Predefined.NextHairColor();
end

--function Map3DSystem.UI.Modify.OnMagnifyClick()
	--Map3DSystem.UI.CCS.Predefined.OnMagnifyClick();
--end
--
--function Map3DSystem.UI.Modify.OnMinifyClick()
	--Map3DSystem.UI.CCS.Predefined.OnMinifyClick();
--end

function Map3DSystem.UI.Modify.CloseUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_modify_model");
		if(_sub_panel:IsValid() == false) then
			log("Model modify panel container is not yet initialized.\r\n");
		else
			-- show Modify sub panel
			_sub_panel.visible = false;
		end
		
		_sub_panel = _panel:GetChild("_sub_panel_modify_character");
		if(_sub_panel:IsValid() == false) then
			log("Character modify panel container is not yet initialized.\r\n");
		else
			-- show Modify sub panel
			_sub_panel.visible = false;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

function Map3DSystem.UI.Modify.FaceClick()
	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			if(Map3DSystem.UI.CCS.Predefined.CurrentFaceType == "CartoonFace") then
				Map3DSystem.UI.Modify.ShowCCSMenu("CartoonFace");
			elseif(Map3DSystem.UI.CCS.Predefined.CurrentFaceType == "CharacterFace") then
				Map3DSystem.UI.CCS.Predefined.NextFaceType();
			end
			return;
		end
	end
	
	--CCS_main.PleaseSelectRaceOrGender();
end

function Map3DSystem.UI.Modify.ToggleFace()
	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			Map3DSystem.UI.CCS.Predefined.ToggleFace();
			local button1 = ParaUI.GetUIObject("btnMain1");
			local button2 = ParaUI.GetUIObject("btnMain2");
			if(Map3DSystem.UI.CCS.Predefined.CurrentFaceType == "CartoonFace") then
				button1.background = "Texture/3DMapSystem/CCS/btn_Toggle_CartoonFace.png";
				button2.background = "Texture/3DMapSystem/CCS/btn_CCS_CartoonFace_Icon.png";
			elseif(Map3DSystem.UI.CCS.Predefined.CurrentFaceType == "CharacterFace") then
				button1.background = "Texture/3DMapSystem/CCS/btn_Toggle_FaceType.png";
				button2.background = "Texture/3DMapSystem/CCS/btn_CCS_FaceType_Icon.png";
				
			end
			return;
		end
	end
	
	--CCS_main.PleaseSelectRaceOrGender();
end


-- Event handler: on object translation
function Map3DSystem.UI.Modify.OnTranslationClick()
	ParaAudio.PlayUISound("Btn5");
	
	local temp = ParaUI.GetUIObject("map3dsystem_m_translate_btn");
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-16)^2+(y-36)^2; --1
		dist2 = (x-14)^2+(y-90)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-64)^2+(y-114)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-113)^2+(y-91)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-113)^2+(y-35)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-64)^2+(y-14)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		
		local pos = {x=0,y=0,z=0};
		if(nSel==1) then
			pos.x = -0.1732;
			pos.z = 0.1;
			-- 左移
		elseif(nSel==2) then
			pos.x = -0.1732;
			pos.z = -0.1;
			-- 移近
		elseif(nSel==3) then
			pos.y = -0.2;
			-- 下移
		elseif(nSel==4) then
			pos.x = 0.1732;
			pos.z = -0.1;
			-- 右移
		elseif(nSel==5) then
			pos.x = 0.1732;
			pos.z = 0.1;
			-- 移远
		elseif(nSel==6) then
			pos.y = 0.2;
			-- 上移
		end
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), pos_delta_camera={dx=pos.x,dy=pos.y,dz=pos.z}})
	end
	
end

-- Event handler: on object rotation
function Map3DSystem.UI.Modify.OnRotationClick()
	ParaAudio.PlayUISound("Btn5");
	
	local temp = ParaUI.GetUIObject("map3dsystem_m_rotate_btn");
	if(temp:IsValid()==true) then 
		local x,y = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		-- _guihelper.MessageBox("clicked "..x..","..y.."\r\n");
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-28)^2+(y-21)^2; --1
		dist2 = (x-12)^2+(y-79)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-30)^2+(y-112)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-69)^2+(y-110)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-112)^2+(y-54)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-94)^2+(y-17)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		local angledelta = 0.104719753
		local rot = {x=0,y=0,z=0};
		if(nSel==1) then
			rot.z=angledelta; -- z pos
		elseif(nSel==2) then
			rot.y = angledelta; -- Y pos
		elseif(nSel==3) then
			rot.x = -angledelta; -- x neg
		elseif(nSel==4) then
			rot.z = -angledelta; -- z neg
		elseif(nSel==5) then
			rot.y = -angledelta; -- Y neg
		elseif(nSel==6) then
			rot.x = angledelta; -- x pos
		end

		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), rot_delta={dx=rot.x,dy=rot.y,dz=rot.z}})
	end
end

function Map3DSystem.UI.Modify.OnMinifyClick()
	ParaAudio.PlayUISound("Btn5");
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), scale_delta=0.9})
end

function Map3DSystem.UI.Modify.OnMagnifyClick()
	ParaAudio.PlayUISound("Btn5");
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), scale_delta=1.1})
end

function Map3DSystem.UI.Modify.OnResetClick()
	ParaAudio.PlayUISound("Btn5");
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), reset=true})
end

function Map3DSystem.UI.Modify.OnMoveHereClick()
	ParaAudio.PlayUISound("Btn5");
	local player = ParaScene.GetObject("<player>");
	local px,py,pz = player:GetPosition();
	if(player:IsValid()==true) then
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams("selection"), pos={x=px,y=py,z=pz}})
	end
end

---------------------------------------------------
-- show a top level popup window for a mouse cursor 3D mesh object
---------------------------------------------------

Map3DSystem.UI.Modify.PopupEditorName = "ShowPopupEdit";
-- function(bIsCancel) or string, -- function to call when edit window closes.
Map3DSystem.UI.Modify.PopupEditor_onclose = nil;
-- @param obj_params: a valid object params
function Map3DSystem.UI.Modify.ShowPopupEdit(obj_params, x, y, onclose)
	if(not obj_params) then
		return
	end
	
	Map3DSystem.UI.Modify.popupedit_obj_params = obj_params;
	Map3DSystem.UI.Modify.PopupEditor_onclose = onclose;
	x = x or mouse_x or 100;
	y = y or mouse_y or 100;
	
	local name = Map3DSystem.UI.Modify.PopupEditorName;
	local _this=ParaUI.GetUIObject(name);
	if(_this:IsValid() == false) then
		_this = ParaUI.CreateUIObject("container", name, "_lt", x, y, 227, 197)
		_this:AttachToRoot();
		_this.onmouseup=";Map3DSystem.UI.Modify.OnMouseUpShowPopupEdit();";
		_parent = _this;

		NPL.load("(gl)script/ide/SliderBar.lua");
		
		_this = ParaUI.CreateUIObject("text", name.."rotY_T", "_mt", 20, 20, 32, 32);
		_this.text = "Y";
		_this.font = "helvetica;24;bold;true";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", name.."rotY_BG", "_mt", 50, 20, 85, 32);
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background.png: 8 14 8 14";
		_this.enable = false;
		_parent:AddChild(_this);
		
		local ctl = CommonCtrl.SliderBar:new{
			name = name.."rotY",
			alignment = "_mt",
			left = 50,
			top = 20,
			width = 85,
			height = 32,
			parent = _parent,
			background = "",
			button_bg = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_big.png",
			value = 0,
			min = -3.1415926,
			max = 3.1415926,
			min_step = 3.1415926/18,
			onchange = Map3DSystem.UI.Modify.OnPopupEditRotationChange,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", name.."rotX_T", "_mt", 20, 68, 32, 32);
		_this.text = "X";
		_this.font = "helvetica;24;bold;true";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", name.."rotX_BG", "_mt", 50, 68, 85, 32);
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background.png: 8 14 8 14";
		_this.enable = false;
		_parent:AddChild(_this);
		
		local ctl = CommonCtrl.SliderBar:new{
			name = name.."rotX",
			alignment = "_mt",
			left = 50,
			top = 68,
			width = 85,
			height = 32,
			parent = _parent,
			background = "",
			button_bg = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_big.png",
			value = 0,
			min = -3.1415926,
			max = 3.1415926,
			min_step = 3.1415926/18,
			onchange = Map3DSystem.UI.Modify.OnPopupEditRotationChange,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", name.."rotZ_T", "_mt", 20, 111, 32, 32);
		_this.text = "Z";
		_this.font = "helvetica;24;bold;true";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", name.."rotZ_BG", "_mt", 50, 111, 85, 32);
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background.png: 8 14 8 14";
		_this.enable = false;
		_parent:AddChild(_this);
		
		local ctl = CommonCtrl.SliderBar:new{
			name = name.."rotZ",
			alignment = "_mt",
			left = 50,
			top = 111,
			width = 85,
			height = 32,
			parent = _parent,
			background = "",
			button_bg = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_big.png",
			value = 0,
			min = -3.1415926,
			max = 3.1415926,
			min_step = 3.1415926/18,
			onchange = Map3DSystem.UI.Modify.OnPopupEditRotationChange,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", name.."scale_big", "_rt", -30, 10, 32, 32);
		_this.text = "+";
		_this.scalingx = 1.5;
		_this.scalingy = 1.5;
		_this.font = "helvetica;24;bold;true";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", name.."scale_small", "_rt", -20, 130, 32, 32);
		_this.text = "-";
		_this.scalingx = 2.0;
		_this.scalingy = 1.5;
		_this.font = "helvetica;24;bold;true";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", name.."scale_BG", "_rt", -65, 20, 32, 133);
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_vertical.png: 14 8 14 8";
		_this.enable = false;
		_parent:AddChild(_this);

		local ctl = CommonCtrl.SliderBar:new{
			name = name.."scale",
			alignment = "_rt",
			left = -65,
			top = 20,
			width = 32,
			height = 133,
			parent = _parent,
			background = "",
			button_bg = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_big.png",
			value = 0,
			min = -10,
			max = 10,
			min_step = 1,
			onchange = Map3DSystem.UI.Modify.OnPopupEditScaleChange,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "b", "_lb", 23, -38, 52, 23)
		_this.text = "重置";
		_this.onclick = ";Map3DSystem.UI.Modify.OnPopupEditReset()"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "b", "_lb", 90, -38, 52, 23)
		_this.text = "确定";
		_this.onclick = ";Map3DSystem.UI.Modify.OnClosePopupEdit();"
		_parent:AddChild(_this);
		
		_this = _parent;
	else
		_this.x = x;
		_this.y = y;
	end
	
	-- Update Value
	if(obj_params.rotation~=nil) then
		local heading, attitude, bank = mathlib.QuatToEuler(obj_params.rotation);
		
		local ctl = CommonCtrl.GetControl(name.."rotY");
		if(ctl~=nil)then
			ctl.value = heading;
			ctl:UpdateUI();
		end
		local ctl = CommonCtrl.GetControl(name.."rotX");
		if(ctl~=nil)then
			ctl.value = attitude;
			ctl:UpdateUI();
		end
		local ctl = CommonCtrl.GetControl(name.."rotZ");
		if(ctl~=nil)then
			ctl.value = bank;
			ctl:UpdateUI();
		end
	end	
	
	_this.visible = true;
	_this:SetTopLevel(true);
end


function Map3DSystem.UI.Modify.OnPopupEditReset()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_MoveCursorObject, reset = true});
	local name = Map3DSystem.UI.Modify.PopupEditorName;
	local ctl = CommonCtrl.GetControl(name.."rotY");
	if(ctl~=nil)then
		ctl.value = 0;
		ctl:UpdateUI();
	end
	local ctl = CommonCtrl.GetControl(name.."rotX");
	if(ctl~=nil)then
		ctl.value = 0;
		ctl:UpdateUI();
	end
	local ctl = CommonCtrl.GetControl(name.."rotZ");
	if(ctl~=nil)then
		ctl.value = 0;
		ctl:UpdateUI();
	end
	
	local ctl = CommonCtrl.GetControl(name.."scale");
	if(ctl~=nil)then
		ctl.value = 1;
		ctl:UpdateUI();
	end
end

function Map3DSystem.UI.Modify.OnPopupEditRotationChange(value)
	local heading, attitude, bank = 0,0,0;
	local name = Map3DSystem.UI.Modify.PopupEditorName;
	local ctl = CommonCtrl.GetControl(name.."rotY");
	if(ctl~=nil)then
		heading = ctl.value;
	end
	local ctl = CommonCtrl.GetControl(name.."rotX");
	if(ctl~=nil)then
		attitude = ctl.value;
	end
	local ctl = CommonCtrl.GetControl(name.."rotZ");
	if(ctl~=nil)then
		bank = ctl.value;
	end
	
	local x,y,z,w = mathlib.EulerToQuat(heading, attitude, bank);
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_MoveCursorObject, quat={x=x, y=y, z=z, w=w}});
end

function Map3DSystem.UI.Modify.OnPopupEditScaleChange(value)
	local name = Map3DSystem.UI.Modify.PopupEditorName;
	local ctl = CommonCtrl.GetControl(name.."scale");
	if(ctl~=nil)then
		local scale = math.pow(0.9, value);
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_MoveCursorObject, scale=scale});
	end
end

function Map3DSystem.UI.Modify.HidePopupEdit()
	_this=ParaUI.GetUIObject("ShowPopupEdit");
	if(_this:IsValid()) then
		_this.visible = false;
	end
end

function Map3DSystem.UI.Modify.OnClosePopupEdit()
	Map3DSystem.UI.Modify.HidePopupEdit()
	if(type(Map3DSystem.UI.Modify.PopupEditor_onclose)=="function") then
		Map3DSystem.UI.Modify.PopupEditor_onclose(false);
	end
end

function Map3DSystem.UI.Modify.OnMouseUpShowPopupEdit()
	Map3DSystem.UI.Modify.HidePopupEdit()
	if(type(Map3DSystem.UI.Modify.PopupEditor_onclose)=="function") then
		Map3DSystem.UI.Modify.PopupEditor_onclose(true);
	end
end

function Map3DSystem.UI.Modify.OnMouseEnter()
end

function Map3DSystem.UI.Modify.OnMouseLeave()
end