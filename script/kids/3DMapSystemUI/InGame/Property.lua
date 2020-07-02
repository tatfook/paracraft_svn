--[[
Title: Property in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/17
Desc: Show the Property panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Property.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("KidsUI");

function Map3DSystem.UI.Property.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("PropertyWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("PropertyWnd recv MSG WM_SIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("PropertyWnd recv MSG WM_HIDE.\n");
		Map3DSystem.UI.Property.CloseUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("PropertyWnd recv MSG WM_SHOW.\n");
		Map3DSystem.UI.Property.ShowUI();
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_Property_Show) then
		-- show or hide the property panel, nil to toggle current setting
		Map3DSystem.UI.Property.Show(msg.bShow);
	end
end

function Map3DSystem.UI.Property.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Property.WndObject = app:RegisterWindow(
		"PropertyWnd", mainWndName, Map3DSystem.UI.Property.MSGProc);
	
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
				local _item = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Property");
				
				if(_item == nil) then
					return;
				end
				if(msg.status == "BCSXRef" or msg.status == "none") then
					_item.enabled = false;
					Map3DSystem.UI.MainPanel.ShowPanel(5, false);
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = false;
					end
				elseif(msg.status == "character") then
					_item.enabled = true;
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = true;
					end
				elseif(msg.status == "model") then
					local _obj = Map3DSystem.obj.GetObject("selection");
					if(_obj == nil or _obj:IsValid() == false) then
						return;
					end
					local enable;
					local curBG = _obj:GetReplaceableTexture(1);
					if(curBG:IsValid()==false) then
						enable = false;
					else
						enable = true;
					end
					
					_item.enabled = enable;
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = enable;
					end
				end
			end
			return nCode;
		end, 
		hookName = "PropertyPanelChangeStatusHook", appName = "MainBar", wndName = "MainBarWnd"});
end

-- send a message to MainPanel:PropertyWnd window handler
-- e.g. Map3DSystem.UI.Modify.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_Property_Show, bShow = true})
function Map3DSystem.UI.Property.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.Property.WndObject.name;
	Map3DSystem.UI.MainPanel.App:SendMessage(msg);
end

-- show or hide the property panel, bShow == nil, toggle current setting
function Map3DSystem.UI.Property.Show(bShow)
	Map3DSystem.UI.MainPanel.ShowPanel(5, bShow);
end

function Map3DSystem.UI.Property.ShowUI()

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	--local _icon = ParaUI.GetUIObject("MainBar_icons_5"); --  the main bar property icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Property");
	local x, y, width, height = _icon:GetAbsPosition();
	
	Map3DSystem.UI.MainPanel.SendMeMessage(
			{type = Map3DSystem.msg.MAINPANEL_SetPosX,
			posX = x});
			
	local _obj = Map3DSystem.obj.GetObject("selection");
	if(_obj == nil or _obj:IsValid() == false) then
		return;
	end	
	
	if(_panel:IsValid() == true) then
	
		if(_obj:IsCharacter() == true) then
			-- character
			local _sub_panel = _panel:GetChild("_sub_panel_property_character");
			if(_sub_panel:IsValid() == false) then
				-- Property sub panel for the first run
				local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_property_character", "_lt",
					Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
					--Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
					Map3DSystem.UI.MainPanel.WidthSet[5].currentWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
				_sub_panel.background = "";
				_panel:AddChild(_sub_panel);
				
				---- test button
				--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
				--_temp.text = "property";
				--_sub_panel:AddChild(_temp);
				
				local char_type	= CommonCtrl.CKidMiddleContainer.char_type;
				char_type_buttons = CommonCtrl.CKidMiddleContainer.char_type_buttons;
				
				-- section1
				--left,top,width,height = 10, 0, 60, 30; 
				left,top,width,height = 10, -10, 60, 30; 
				_this=ParaUI.CreateUIObject("text","static","_lt",left,top+5,width,height);
				_sub_panel:AddChild(_this);
				_this.text="名字";
				left = left+width;
				
				width = 145;
				_this=ParaUI.CreateUIObject("imeeditbox","kidui_property_charname","_lt",left,top+3,width,height-3);
				_sub_panel:AddChild(_this);
				_this.background="Texture/kidui/main/bg_266X48.png";
				left = left+width+5;
				
				width = 100;
				_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top,width,height);
				_sub_panel:AddChild(_this);
				_this.text = "改变";
				_this.onclick=";CommonCtrl.CKidMiddleContainer.OnChangeCharacterName();";
				left = left+width+5;
				
				_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top,width,height);
				_sub_panel:AddChild(_this);
				_this.text = "外观";
				_this.tooltip = "改变外观";
				_this.onclick=";CommonCtrl.CKidMiddleContainer.OnChangeCharacterSkin();";
				left = left+width+20;
				
				width = 32;
				_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top,width,width);
				_sub_panel:AddChild(_this);
				_this.background="Texture/kidui/right/btn_save.png";
				_this.tooltip = "保存";
				_this.onclick=";CommonCtrl.CKidMiddleContainer.OnSaveCharacterProperty();";
				
				-- section2
				left,top,btn_width  = 10, 25, 80; 
				_this=ParaUI.CreateUIObject("text","static","_lt",left,top,60,25);
				_sub_panel:AddChild(_this);
				_this.text="我是";
				left = left+60;
				
				for i=1, table.getn(char_type) do
					local item = char_type[i];
					char_type_buttons[i] = "kidui_AItype_btn"..i;
					_this=ParaUI.CreateUIObject("button",char_type_buttons[i],"_lt",left,top,btn_width,height);
					_sub_panel:AddChild(_this);
					_this.text = item.text;
					_this.tooltip = item.tooltip;
					_this.background = item.bg;
					_this.onclick=string.format([[;CommonCtrl.CKidMiddleContainer.OnChangeCharacterType(%d);]], i);
					left = left+btn_width+5;
				end
					
				-- section3
				--left,top, btn_width =10,70,64;
				left,top, btn_width =10,60,64;
				
				_this=ParaUI.CreateUIObject("text","static","_lt",left,top,60,25);
				_sub_panel:AddChild(_this);
				_this.text="行为";
				left = left+60;
				
				-- create actor behavior container.
				local ctl = CommonCtrl.ActorMovieCtrl:new{
					-- normal window size
					alignment = "_mt",
					left = 70,
					top = 60,
					width = 0,
					height = 90,
					-- parent UI object, nil will attach to root.
					parent = _sub_panel,
					-- the top level control name
					name = "Actor_behavior_cont",
				}
				ctl:Show();
				
				-- create the NPC_behavior_cont
				local ai_buttons = CommonCtrl.CKidMiddleContainer.ai_buttons;
				_parent=ParaUI.CreateUIObject("container","NPC_behavior_cont","_mt",left,top,0, 80);
				_parent.background="Texture/whitedot.png;0 0 0 0";
				_sub_panel:AddChild(_parent);
				left,top = 0,0;
				
				for i=1, table.getn(ai_buttons) do
					local item = ai_buttons[i];
					_this=ParaUI.CreateUIObject("button","kidui_AI_btn"..i,"_lt",left,top,btn_width,btn_width);
					_parent:AddChild(_this);
					_this.tooltip = item.text;
					_this.background = item.bg;
					_this.onclick=string.format([[;CommonCtrl.CKidMiddleContainer.OnAssignAIClick(%d);]], i);
					left = left+btn_width+5;
				end
				
				-- register a timer for updates
				NPL.SetTimer(1001, 1.0, ";OnMap3DSystemTimer1001();");
				
				
				CommonCtrl.CKidMiddleContainer.OnChangeCharacterType(2);
		
			else
				-- show Property sub panel
				_sub_panel.visible = true;
			end
		else -- if(_obj:IsCharacter() == true) then
			
			-- model
			local _sub_panel = _panel:GetChild("_sub_panel_property_model");
			if(_sub_panel:IsValid() == false) then
				-- Property sub panel for the first run
				local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_property_model", "_lt",
					Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
					Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
				_sub_panel.background = "";
				_panel:AddChild(_sub_panel);
				
				---- test button
				--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
				--_temp.text = "property";
				--_sub_panel:AddChild(_temp);
				
				_this = ParaUI.CreateUIObject("text", "label5", "_lt", 246, 0, 130, 16)
				_this.text = "随即图片:";
				_sub_panel:AddChild(_this);
				
				_this = ParaUI.CreateUIObject("button", "map3d_model_replaceTex_candidate1", "_lt", 249, 15, 64, 64)
				_this.animstyle = 11;
				_this.onclick = ";Map3DSystem.UI.Property.OnClickRandomReplaceTexture(1);";
				_sub_panel:AddChild(_this);

				_this = ParaUI.CreateUIObject("button", "map3d_model_replaceTex_candidate2", "_lt", 320, 15, 64, 64)
				_this.animstyle = 11;
				_this.onclick = ";Map3DSystem.UI.Property.OnClickRandomReplaceTexture(2);";
				_sub_panel:AddChild(_this);

				_this = ParaUI.CreateUIObject("button", "map3d_model_replaceTex_candidate3", "_lt", 392, 15, 64, 64)
				_this.animstyle = 11;
				_this.onclick = ";Map3DSystem.UI.Property.OnClickRandomReplaceTexture(3);";
				_sub_panel:AddChild(_this);

				_this = ParaUI.CreateUIObject("button", "map3d_model_replaceTex_ads", "_lt", 249, 82, 192, 64)
				_this.onclick = ";Map3DSystem.UI.Property.OnClickRandomReplaceTexture(0);";
				_this.animstyle = 11;
				_sub_panel:AddChild(_this);

				-- display some random images
				Map3DSystem.UI.Property.UpdateRandomModelTextureList();
				
				-- Canvas
				_this = ParaUI.CreateUIObject("button", "map3d_p_m_painter", "_lt", 34, 5, 160, 140)
				_this.background="Texture/whitedot.png;0 0 0 0";
				_guihelper.SetUIColor(_this, "255 255 255");
				_sub_panel:AddChild(_this);
				
				_this = ParaUI.CreateUIObject("container", "MPP_Canvas", "_lt", 12, 0, 200, 150)
				_sub_panel:AddChild(_this);
				_this.background="Texture/kidui/middle/painter/replace_tex_bg.png";
				local _parent = _this;
				
				_this = ParaUI.CreateUIObject("button", "button10", "_lt", 162, 55, 36, 36)
				_this.tooltip = L"Reset image";
				_this.animstyle = 12;
				_this.background="Texture/kidui/middle/painter/resetreplaceTex.png";
				_this.onclick = ";Map3DSystem.UI.Property.OnUndoModelTexture();";
				_parent:AddChild(_this);

				_this = ParaUI.CreateUIObject("button", "button11", "_lt", 162, 86, 36, 36)
				_this.tooltip = L"Draw by myself";
				_this.animstyle = 12;
				_this.background="Texture/kidui/middle/painter/selfdraw.png";
				_this.onclick = ";Map3DSystem.UI.Property.OnEditModelTexture();";
				_parent:AddChild(_this);

				_this = ParaUI.CreateUIObject("button", "button17", "_lt", 162, 119, 30, 30)
				_this.tooltip = L"Open file...";
				_this.animstyle = 12;
				_this.background="Texture/kidui/middle/painter/openfile.png";
				_this.onclick = ";Map3DSystem.UI.Property.OnOpenFileForModelTexture();";
				_parent:AddChild(_this);
				
				_this = ParaUI.CreateUIObject("button", "buttonWeb", "_lt", 162, 0, 32, 32)
				_this.tooltip = "Web!";
				_this.animstyle = 12;
				_this.background="Texture/3DMapSystem/webbrowser/browserIconSmall.png";
				_this.onclick = ";Map3DSystem.UI.Property.OnClickWebBrowser();";
				_parent:AddChild(_this);
				
				Map3DSystem.UI.Property.OnUpdateModelPropertyUI(_obj);
		
			else
				-- show Property sub panel
				_sub_panel.visible = true;
				
				Map3DSystem.UI.Property.OnUpdateModelPropertyUI(_obj);
			end
		end -- if(_obj:IsCharacter() == true) then
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

-- this is timer handler for timer ID 1001
function OnMap3DSystemTimer1001()
	if(ParaScene.IsSceneEnabled()~=true) then 
		return	
	end
	local ctl = CommonCtrl.GetControl("Actor_behavior_cont");
	if(ctl ~= nil) then
		ctl:Update();
	end
		
	local temp = ParaUI.GetUIObject("KidsUI_MovieBox");
	if((temp:IsValid() == true) and (temp.visible == true)) then
		local ctl = CommonCtrl.GetControl("ClipMovieCtrl1");
		if(ctl~=nil) then
			ctl:Update(0);
		end
	end
end

function Map3DSystem.UI.Property.OnClickWebBrowser()
	
	--Map3DSystem.UI.MainPanel.OnClickIcon(5);
	Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_ClickIcon, index = 5});
	
	Map3DSystem.UI.Property.SelectBackObject = Map3DSystem.obj.GetObject("selection");
	
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	
	if(ParaUI.GetUIObject("Map3DSystem.UI.Property.WebBrowser"):IsValid() == true) then
		ParaUI.GetUIObject("Map3DSystem.UI.Property.WebBrowser").visible = true;
		ParaUI.GetUIObject("Map3DSystem.UI.Property.WebBrowser"):SetTopLevel(true);
		return;
	end
	
	local _this = ParaUI.CreateUIObject("container", "Map3DSystem.UI.Property.WebBrowser", "_ctb", 0, -64, 450, 48);
	_this:SetTopLevel(true);
	_this:AttachToRoot();
	
	local _parent = _this;
	
	local wndName = "Property";

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "Map3DSystem.UI.Property.WebBrowser.comboBoxAddress",
		alignment = "_mt",
		left = 51,
		top = 3,
		width = 200,
		height = 24,
		dropdownheight = 106,
		parent = _parent,
		text = "www.google.com",
		items = {"www.google.com", "www.yahoo.com", "www.paraengine.com"},
		onselect = string.format("Map3DSystem.UI.Property.OnClickNavTo();", wndName),
	};
	ctl:Show();

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 13, 8, 72, 16)
	_this.text = "地址:";
	_this:GetFont("text").color = "128 128 128";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "navTo", "_rt", -194, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/goto.png"
	_this.onclick = string.format(";Map3DSystem.UI.Property.OnClickNavTo();", wndName);
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "navBack", "_rt", -154, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/lastpage.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavBack(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "navForward", "_rt", -124, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/nextpage.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavForward(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "Stop", "_rt", -94, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/stop.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavStop(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "RefreshBtn", "_rt", -64, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/refresh.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavRefresh(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "homeBtn", "_rt", -34, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/homepage.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickHomePage(%q);", wndName);
	_this.onclick = ";Map3DSystem.UI.Property.OnClickBackToProperty();";
	_this.animstyle = 12;
	_parent:AddChild(_this);
		
end

function Map3DSystem.UI.Property.OnClickBackToProperty()
	ParaUI.GetUIObject("Map3DSystem.UI.Property.WebBrowser").visible = false;
	
	local obj = Map3DSystem.UI.Property.SelectBackObject;
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = obj});
	Map3DSystem.UI.Property.SelectBackObject = nil;
	
	--Map3DSystem.UI.MainPanel.OnClickIcon(5);
	Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_ClickIcon, index = 5});
end

function Map3DSystem.UI.Property.OnClickNavTo()

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.GetControl("Map3DSystem.UI.Property.WebBrowser.comboBoxAddress");
	local _text = ctl:GetText();
	
	--local obj = Map3DSystem.obj.GetObject("selection");
	local obj = Map3DSystem.UI.Property.SelectBackObject;
	
	local Texture = ParaAsset.LoadTexture("", "<html>1#".._text, 1);
	if(Texture:IsValid()) then
		obj:SetReplaceableTexture(1, Texture);
	end
end

-- @param index: 0 stands for kidsui_mid_model_replaceTex_ads, 1-3 stands for kidsui_mid_model_replaceTex_candidate1-3
-- the texture is read from the tooltip attribute
function Map3DSystem.UI.Property.OnClickRandomReplaceTexture(index)
	local controlname = "";
	if(index == 0) then
		controlname = "map3d_model_replaceTex_ads"
	else
		controlname = "map3d_model_replaceTex_candidate"..index;
	end
	local ctl = ParaUI.GetUIObject(controlname);
	if(ctl:IsValid()) then
		Map3DSystem.UI.Property.OnOpenFileForModelTexture_imp(nil, ctl.tooltip);
	end	
end

-- Open web browser on model
-- NOTE: <html>1#http://www.google.com

function Map3DSystem.UI.Property.OnOpenFileForModelTexture()
	local obj = ObjEditor.GetCurrentObj();
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		return
	end
	local initialFileName;
	if(not obj:GetDefaultReplaceableTexture(1):equals(curBG)) then
		initialFileName = curBG:GetKeyName();
	else	
		initialFileName = "";
	end
	
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-250,
		width = 512,
		height = 380,
		parent = nil,
		FileName = initialFileName,
		FileNamePassFilter = "http://.*", -- allow http texture, is it too dangerous here?
		fileextensions = L:GetTable("open file dialog: texture file extensions"),
		folderlinks = {
			{path = ParaWorld.GetWorldDirectory().."texture/", text = L"My work"},
			{path = L"Shared Media Folder", text = L"Media lib"},
			{path = L"Advertisement Folder", text = L"Advertisement"},
			{path = L"Internet Folder", text = L"Internet"},
		},
		onopen = Map3DSystem.UI.Property.OnOpenFileForModelTexture_imp,
	};
	ctl:Show(true);
end

function Map3DSystem.UI.Property.OnOpenFileForModelTexture_imp(sCtrlName, filename)
	local obj = ObjEditor.GetCurrentObj();
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		return
	end
	
	if(filename == "") then
		-- reset texture
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(not defaultBG:equals(curBG)) then
			obj:SetReplaceableTexture(1, defaultBG);
			Map3DSystem.UI.Property.OnUpdateModelPropertyUI(obj);
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
		end
	else
		-- apply the texture
		local Texture = ParaAsset.LoadTexture("",filename,1);
		if(Texture:IsValid() and not Texture:equals(curBG)) then
			obj:SetReplaceableTexture(1, Texture);
			Map3DSystem.UI.Property.OnUpdateModelPropertyUI(obj);
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
		end
	end
end

-- called whenever the model property must reflect a given model object
-- @param obj: the model object
function Map3DSystem.UI.Property.OnUpdateModelPropertyUI(obj)
	if(obj:IsCharacter() == true) then
		return
	end
	local painter = ParaUI.GetUIObject("map3d_p_m_painter");
	if(painter:IsValid()==false) then
		return
	end
	-- get replaceable texture at ID=1
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		painter.background="Texture/whitedot.png;0 0 0 0";
	else
		local bg = curBG:GetKeyName();
		painter.background=bg;
		--painter.tooltip=bg;
	end
end

-- force using the default replaceable texture for the given model.
function Map3DSystem.UI.Property.OnUndoModelTexture()
	local obj = ObjEditor.GetCurrentObj();
	if(obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(not defaultBG:equals(curBG)) then
			obj:SetReplaceableTexture(1, defaultBG);
			Map3DSystem.UI.Property.OnUpdateModelPropertyUI(obj);
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
			-- TODO: delete unused textures.
			--_guihelper.MessageBox(string.format(L"Do you want to delete old drawing at \n%s?", curBG:GetKeyName()), string.format([[ParaIO.DeleteFile("%s");]], curBG:GetKeyName()));
		end
	end
end

function Map3DSystem.UI.Property.OnEditModelTexture()
	local obj = ObjEditor.GetCurrentObj();
	if(obj:IsCharacter() == true) then
		return
	end
	-- this is just a quick way to use external editor for replaceable textures
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local ext = ParaIO.GetFileExtension(curBG:GetKeyName());
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(defaultBG:equals(curBG) or (ext~="jpg" and  ext~="dds" and ext~="png")) then
			Map3DSystem.UI.Property.InvokeTextureEditor(defaultBG:GetKeyName(), obj, 1);
		else
			-- invoke editor
			Map3DSystem.UI.Property.InvokeTextureEditor(curBG:GetKeyName(), obj, 1);
		end
	end
end

Map3DSystem.UI.Property.CurrentPainterObject = nil;
function Map3DSystem.UI.Property.InvokeTextureEditor(texturename, obj, nReplaceableTexID)
	-- LiXizhi. 2008.1.28, edited to support app painter. 
	NPL.load("(gl)script/kids/3DMapSystemUI/Painter/PainterManager.lua");
	
	Map3DSystem.UI.Property.CurrentPainterObject = obj;
	Map3DSystem.UI.PainterManager.nReplaceableTexID = nReplaceableTexID;
	
	Map3DSystem.App.Commands.Call("File.Painter", {
		imagesize = 256,
		OnCloseCallBack = Map3DSystem.UI.Property.OnEndEditingTexture,
		OnSaveCallBack = Map3DSystem.UI.Property.OnSaveUserDrawing,
		LoadFromTexture = texturename,
	});
	
	if(not nReplaceableTexID) then nReplaceableTexID = 1 end
	if(obj~=nil and obj:IsValid()) then
		local rendertarget = Map3DSystem.UI.PainterManager.GetRenderTarget();
		if(rendertarget~=nil) then
			obj:SetReplaceableTexture(1, rendertarget);
		end
	end	
end

-- when the user saves an owner draw image
function Map3DSystem.UI.Property.OnEndEditingTexture()
	local obj = Map3DSystem.UI.Property.CurrentPainterObject;
	if(obj==nil or obj:IsCharacter() == true) then
		return
	end
	local nReplaceableTexID = Map3DSystem.UI.PainterManager.nReplaceableTexID;
	if(not nReplaceableTexID) then nReplaceableTexID = 1 end
	if(obj~=nil and obj:IsValid()) then
		local diskTexture = Map3DSystem.UI.PainterManager.GetDiskTexture();
		if(diskTexture~=nil) then
			obj:SetReplaceableTexture(1, diskTexture);
		end
	end	
	Map3DSystem.UI.Property.CurrentPainterObject = nil;
end

-- when the user saves an owner draw image
function Map3DSystem.UI.Property.OnSaveUserDrawing()
	local obj = Map3DSystem.UI.Property.CurrentPainterObject;
	if(obj==nil or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local PainterImageFileName = Map3DSystem.UI.PainterManager.GetDiskTextureFileName();
		local ext = ParaIO.GetFileExtension(PainterImageFileName);
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		
		-- if the current image is not inside the world texture file directory or the current image is not a 
		if(ParaIO.GetParentDirectoryFromPath(PainterImageFileName, 0) ~= ParaIO.GetParentDirectoryFromPath(ParaWorld.GetWorldDirectory().."texture/",0) or (ext~="jpg" and  ext~="dds" and ext~="png")) then
			-- create a new texture at the [worlddir]/texture/[default_texture_name]_[unique_number].dds
			-- add a random name
			local nameTmp = ParaIO.GetFileName(defaultBG:GetKeyName());
			local len = string.len(nameTmp);
			local newTexName = ParaWorld.GetWorldDirectory().."texture/"..string.sub(nameTmp, 1, len-4)..ParaGlobal.GenerateUniqueID()..string.sub(nameTmp, len-3, -1);
			if(ParaIO.CreateDirectory(newTexName)) then
				-- save the new texture to file
				Map3DSystem.UI.PainterManager.SaveAs(newTexName);
				local tex = ParaAsset.LoadTexture("", newTexName, 1);
				if(tex:IsValid()) then
					obj:SetReplaceableTexture(1, tex);
					Map3DSystem.UI.Property.OnUpdateModelPropertyUI(obj);
					local x,y,z = obj:GetPosition();
					ParaTerrain.SetContentModified(x,z, true);
				end	
			end
		else
			-- the old file is under the world texture directory, hence we will just overwrite.
			local newTexName = PainterImageFileName;
			Map3DSystem.UI.PainterManager.SaveAs(newTexName );
		end
	end		
end


function Map3DSystem.UI.Property.UpdateRandomModelTextureList()
	local candidates = {};
	local folder = L"Shared Media Folder";
	
	commonlib.SearchFiles(candidates, ParaIO.GetCurDirectory(0)..folder, {"*.png", "*.jpg", "*.dds"}, 0, 50, true);	
	
	local nItemCount = 3; -- how many items to pick
	local count = table.getn(candidates);
	local nOffset = 0;
	if(count>nItemCount ) then
		nOffset = math.mod( math.floor(ParaGlobal.random()*count), count);
		if((nOffset+nItemCount )>count) then
			nOffset = count-nItemCount ;
		end
	end	
	
	local i;
	for i=1,nItemCount  do
		local tmp = ParaUI.GetUIObject("map3d_model_replaceTex_candidate"..i);
		if(tmp:IsValid()) then
			if(not candidates[i+nOffset]) then
				tmp.background="Texture/whitedot.png;0 0 0 0";
				tmp.tooltip = "";
				tmp.visible = false;
			else
				local filepath = string.gsub(folder..candidates[i+nOffset], "\\", "/");
				tmp.tooltip = filepath;
				tmp.background = filepath;
				tmp.visible = true;
			end	
		end
	end
	
	-- for advertisement file
	local candidates = {};
	local folder = L"Advertisement Folder";
	commonlib.SearchFiles(candidates, ParaIO.GetCurDirectory(0)..folder, {"*.png", "*.jpg", "*.dds"}, 0, 50, true);	

	local count = table.getn(candidates);
	local nOffset = math.mod( math.floor(ParaGlobal.random()*count), count);
	
	local tmp = ParaUI.GetUIObject("map3d_model_replaceTex_ads");
	local i=1;
	if(tmp:IsValid()) then
		if(not candidates[i+nOffset]) then
			tmp.background="Texture/whitedot.png;0 0 0 0";
			tmp.tooltip = "";
			tmp.visible = false;
		else
			local filepath = string.gsub(folder..candidates[i+nOffset], "\\", "/");
			tmp.tooltip = filepath;
			tmp.background = filepath;
			tmp.visible = true;
		end	
	end
end

function Map3DSystem.UI.Property.CloseUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_property_character");
		if(_sub_panel:IsValid() == false) then
			log("Property panel character container is not yet initialized.\r\n");
		else
			-- show Property sub panel
			_sub_panel.visible = false;
		end
		
		_sub_panel = _panel:GetChild("_sub_panel_property_model");
		if(_sub_panel:IsValid() == false) then
			log("Property panel model container is not yet initialized.\r\n");
		else
			-- show Property sub panel
			_sub_panel.visible = false;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end


function Map3DSystem.UI.Property.OnMouseEnter()
end

function Map3DSystem.UI.Property.OnMouseLeave()
end