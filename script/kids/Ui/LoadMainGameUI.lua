--[[
Title: Main In-game UI for KidsMovie application.
Author(s): LiXizhi
Date: 2006/7/7
Desc: Show the main game UI
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/ui/LoadMainGameUI.lua");
------------------------------------------------------------
]]
-- load library
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/kids/ui/left_container.lua");
NPL.load("(gl)script/kids/ui/right_container.lua");
NPL.load("(gl)script/kids/ui/middle_container.lua");
NPL.load("(gl)script/kids/ui/itembar_container.lua");
NPL.load("(gl)script/kids/ui/Help.lua");
NPL.load("(gl)script/movie/ClipMovieCtrl.lua");
NPL.load("(gl)script/ide/chat_display.lua");
NPL.load("(gl)script/kids/event_handlers.lua");
NPL.load("(gl)script/kids/Ui/autotips.lua");

local L = CommonCtrl.Locale("KidsUI");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end


local function activate()
	local __this,__parent,__font,__texture;

	-- create the demo bar at the left top corner for non-release mode build.
	if(not ReleaseBuild) then
		NPL.activate("(gl)script/demo/main_window.lua","");
	end	
		
	CommonCtrl.CKidLeftContainer.Initialize();
	CommonCtrl.CKidRightContainer.Initialize();
	CommonCtrl.CKidMiddleContainer.Initialize();
	CommonCtrl.CKidItemsContainer.Initialize();
	--create toolbar
	KidsUI_ShowToolBar();

	-- handlers
	KidsUI.ReBindEventHandlers();
	
	-- enable the 3D canvas for selection group 0
	ParaScene.Enable3DCanvas(0,true);
	
	-- init movie lib
	if(_movie~=nil) then
		_movie.Init();
	end	
	
	local L = CommonCtrl.Locale("IDE");
	KidsUI.HeadArrowAsset = ParaAsset.LoadParaX("", L"asset_headarrow");
end
NPL.this(activate);

function KidsUI_ShowChatWindow(bShow)
	local tmp = ParaUI.GetUIObject("chat_display1");
	local ctl = CommonCtrl.GetControl("chat_display1");
	
	if(tmp:IsValid()==false and bShow == true) then
		ctl = CommonCtrl.chat_display:new{
			name = "chat_display1",
			alignment = "_lb",
			left=10, top=-300,
			width = 300,height = 70,
			max_lines = 5,
			parent = nil,
		};
	end	
	if(ctl~=nil) then
		ctl:Show(bShow);
	end	
end

-- a few floating buttons displayed at the left bottom of the screen.
function KidsUI_ShowToolBar()
	local _parent;
	_parent=ParaUI.GetUIObject("KidsUI_ToolBar");
	if(_parent:IsValid() == false)then
		_parent=ParaUI.CreateUIObject("container","KidsUI_ToolBar","_lb",13,-190,160,32);
		_parent.background="Texture/whitedot.png;0 0 0 0";
		_parent:AttachToRoot();
		local left, top, width, height = 0,0, 32, 32;
		
		_this=ParaUI.CreateUIObject("button","btnShowMovieBox", "_lt", left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/common/movie.png";
		_this.tooltip = L"Open or close movie box";
		_this.onclick=";KidsUI.ShowMovieBox();";
		_this.animstyle = 12;
		left = left + 55;
		
		_this=ParaUI.CreateUIObject("button","btnUploadUserWork", "_lt", left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/common/uploadpackage.png";
		_this.tooltip = L"Upload your work";
		_this.onclick=";KidsUI.OnClickUpload();";
		_this.animstyle = 12;
		left = left+55;
		
		_this=ParaUI.CreateUIObject("button","btnShowAutoText", "_lt", left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/main/autotips.png";
		_this.tooltip = L"Show or hide auto tips";
		_this.onclick=[[;KidsUI.ShowAutoText();]];
		autotips.Show(true);
		_this.animstyle = 12;
	else
		_parent.visible = not _parent.visible;
	end
end

-- show tips
function KidsUI.ShowAutoText()
	local tmp = ParaUI.GetUIObject("chat_display1");
	if(tmp:IsValid()) then
		if(not KidsUI.ShowAutoTextStyle) then
			KidsUI.ShowAutoTextStyle = 0;
		end
		KidsUI.ShowAutoTextStyle = math.mod(KidsUI.ShowAutoTextStyle+1,4);
		if(KidsUI.ShowAutoTextStyle == 0) then
			autotips.Show();
		elseif(KidsUI.ShowAutoTextStyle == 1) then
			KidsUI_ShowChatWindow();
		elseif(KidsUI.ShowAutoTextStyle == 2) then	
			autotips.Show();
			KidsUI_ShowChatWindow();
		elseif(KidsUI.ShowAutoTextStyle == 3) then		
			KidsUI_ShowChatWindow();
		end
	else
		autotips.Show();
	end
end

-- when the user clicked the upload button
function KidsUI.OnClickUpload()
	NPL.load("(gl)script/network/UploadArtwork.lua");
	UploadArtwork.Show();	
end

-- show/hide the movie box.
function KidsUI.ShowMovieBox(bShow)
	
	local _parent;
	_parent=ParaUI.GetUIObject("KidsUI_MovieBox");
	if(_parent:IsValid() == false)then
		if(bShow == false) then return	end
		
		local width, height = 310,250;
		_parent=ParaUI.CreateUIObject("container","KidsUI_MovieBox","_lb",5,-450,width, height);
		_parent:AttachToRoot();
		_parent.background="Texture/whitedot1.png;0 0 310 250";
		
		-- the close button
		_this=ParaUI.CreateUIObject("button","btn", "_lt",width-32, 0,32, 32);
		_this.background="Texture/player/close.png";
		_parent:AddChild(_this);
		_this.onclick=";KidsUI.ShowMovieBox(false);";
		
		local ctl = CommonCtrl.ClipMovieCtrl:new{
			-- normal window size
			alignment = "_lt",
			left = 6,
			top = 50,
			width = 300,
			height = 200,
			-- parent UI object, nil will attach to root.
			parent = _parent,
			-- the top level control name
			name = "ClipMovieCtrl1",
		}
		ctl:Show();
	else
		if(bShow == nil) then
			_parent.visible = not _parent.visible;
		else
			_parent.visible = bShow;
		end	
		if(_parent.visible == true) then
			local ctl = CommonCtrl.GetControl("ClipMovieCtrl1");
			if(ctl~=nil) then
				ctl:Update();
			end
		end	
	end
end

