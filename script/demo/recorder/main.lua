--[[
Title: recorder window
Author(s): LiXizhi
Date: 2006/4
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/recorder/main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");

local L = CommonCtrl.Locale("IDE");

if(not RecorderUI) then RecorderUI={}; end


function RecorderUI.OnScreenSizeChanged(width, height)
	ParaMovie.SetMovieScreenSize(width, height);
	RecorderUI.UpdateUIStates();
end

function RecorderUI.OnSelectCodec(nCodec)
	ParaMovie.SetEncodeMethod(nCodec);
	RecorderUI.UpdateUIStates();
end

function RecorderUI.OnBeginCapture()
	RecorderUI.ShowRecorderBar();
	
	ParaMovie.BeginCapture("");
	RecorderUI.OnPauseCapture();
	
	-- close dialog
	ParaUI.Destroy("recorder_dialog");
	
	--[[
	local nCodec = ParaMovie.GetEncodeMethod();
	local codecname=L"Custom";
	if(nCodec == 0) then
		codecname="xvid";
	elseif(nCodec == 1) then
		codecname="wmv";
	end]]
	local codecname=L"Custom";
	local x,y = ParaMovie.GetMovieScreenSize();
	
	local captureGUI;
	if(ParaMovie.CaptureGUI() == true) then
		captureGUI = L"No";
	else
		captureGUI = L"Yes";
	end
	
	local EnableStereo;
	if(ParaMovie.GetStereoCaptureMode() == 0) then
		StereoMode = L"No";
	else
		StereoMode = L"Yes";
	end
	
	local msg = string.format(L"==Successfully in recording mode==", 
		x, y,codecname, captureGUI, ParaMovie.GetMovieFileName(),
		ParaMovie.GetRecordingFPS(), EnableStereo, ParaMovie.GetStereoEyeSeparation());
	_guihelper.MessageBox(msg);
end

function RecorderUI.OnPauseCapture()
	ParaMovie.PauseCapture();
end

function RecorderUI.OnResumeCapture()
	ParaMovie.ResumeCapture();
end

function RecorderUI.OnEndCapture()
	ParaMovie.EndCapture();
	ParaUI.Destroy("recorder_bar");
	local msg = string.format(L"==exited recording mode==\nOutput video file: %s", ParaMovie.GetMovieFileName());
	_guihelper.MessageBox(msg);
	log(ParaMovie.GetMovieFileName().." is recorded\r\n");
end

function RecorderUI.OnToggleCaptureGUI()
	if(ParaMovie.CaptureGUI()==true) then
		ParaMovie.SetCaptureGUI(false);
	else
		ParaMovie.SetCaptureGUI(true);
	end
	RecorderUI.UpdateUIStates();
end

function RecorderUI.UpdateUIStates()
	local temp = ParaUI.GetUIObject("btn_toggle_hide_GUI");
	local BtnColor = "255 255 255";
	if(ParaMovie.CaptureGUI()==false) then
		BtnColor = "255 0 0";
	end
	_guihelper.SetUIColor(temp, BtnColor);
	
	local nCodec = ParaMovie.GetEncodeMethod();
	
	if(nCodec == 0) then
		_guihelper.SetUIColor(ParaUI.GetUIObject("btn_codec_last"), "255 0 0");
		_guihelper.SetUIColor(ParaUI.GetUIObject("btn_codec_userdefined"), "255 255 255");
	else
		_guihelper.SetUIColor(ParaUI.GetUIObject("btn_codec_last"), "255 255 255");
		_guihelper.SetUIColor(ParaUI.GetUIObject("btn_codec_userdefined"), "255 0 0");
	end
	
	local width, height = ParaMovie.GetMovieScreenSize();
	local res = {"recording_res_400_300", "recording_res_640_480","recording_res_800_600"};
	if(width==400 and height==300) then
		_guihelper.CheckRadioButtons(res, "recording_res_400_300", "255 0 0");
	elseif(width==640 and height==480) then
		_guihelper.CheckRadioButtons(res, "recording_res_640_480", "255 0 0");
	elseif(width==800 and height==600) then
		_guihelper.CheckRadioButtons(res, "recording_res_800_600", "255 0 0");
	end
end

function RecorderUI.ShowRecorderBar(bIsRecording, bHide)
	local _this,_parent,__font,__texture;
	
	local temp = ParaUI.GetUIObject("recorder_bar");
	if (temp:IsValid() == true) then
		temp.visible = not bHide;
	else

	_this=ParaUI.CreateUIObject("container","recorder_bar", "_lt",0,0,100,40);
	_this:AttachToRoot();
	_this.scrollable=false;
	_this.background="";
	_this.candrag=true;
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",0,0,30,30);
	_parent=ParaUI.GetUIObject("recorder_bar");_parent:AddChild(_this);
	_this.text="";
	_this.background="Texture/player/stop.png;";
	_this.onclick=";RecorderUI.OnEndCapture();";
	
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",30,0,30,30);
	_parent=ParaUI.GetUIObject("recorder_bar");_parent:AddChild(_this);
	_this.text="";
	_this.background="Texture/player/pause.png;";
	_this.onclick=";RecorderUI.OnPauseCapture();";
	
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",60,0,30,30);
	_parent=ParaUI.GetUIObject("recorder_bar");_parent:AddChild(_this);
	_this.text="";
	_this.background="Texture/player/rec.png;";
	_this.onclick=";RecorderUI.OnResumeCapture();";
	
	end
end


local function activate()
	local _this,_parent;
	
	local temp = ParaUI.GetUIObject("recorder_dialog");
	if (temp:IsValid() == true) then
		temp.visible = not temp.visible;
	else

	local width,height = 400, 300
	_this=ParaUI.CreateUIObject("container","recorder_dialog", "_ct",-width/2,-height/2,width,height);
	_this:AttachToRoot();
	_this.scrollable=false;
	_this.background="Texture/cr_zoo.png";
	_this.candrag=true;
	
	_this=ParaUI.CreateUIObject("text","static", "_lt",25,40,382,38);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"save to";
	_this.autosize=true;
	
	
	_this=ParaUI.CreateUIObject("imeeditbox","cp_name", "_lt",150,35,140,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text="screenshot/";
	_this.background="Texture/box.png";
	
	_this.readonly=false;
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",290,35,60,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"file";
	_this.background="Texture/b_up.png;";
	_this.onclick="";
	
	
	_this=ParaUI.CreateUIObject("text","static", "_lt",25,85,382,38);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"resolution";
	_this.autosize=true;
	
	
	_this=ParaUI.CreateUIObject("button","recording_res_400_300", "_lt",150,80,60,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text="400X300";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnScreenSizeChanged(400, 300);";
	
	
	_this=ParaUI.CreateUIObject("button","recording_res_640_480", "_lt",215,80,60,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text="640X480";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnScreenSizeChanged(640, 480);";
	
	_this=ParaUI.CreateUIObject("button","recording_res_800_600", "_lt",280,80,60,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text="800X600";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnScreenSizeChanged(800, 600);";
	
	_this=ParaUI.CreateUIObject("text","static", "_lt",25,130,382,38);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"codec";
	_this.autosize=true;
	
	
	_this=ParaUI.CreateUIObject("button","btn_codec_last", "_lt",150,125,100,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"current codec";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnSelectCodec(0);";
	
	--[[
	_this=ParaUI.CreateUIObject("button","btn_codec_wmv", "_lt",215,125,60,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text="wmv";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnSelectCodec(1);";
	]]
	
	_this=ParaUI.CreateUIObject("button","btn_codec_userdefined", "_lt",260,125,100,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"select another";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnSelectCodec(-1);";
	
	
	_this=ParaUI.CreateUIObject("button","btn_toggle_hide_GUI", "_lt",150,160,100,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"hide UI";
	_this.tooltip=L"whether to include user interface in the video";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnToggleCaptureGUI();";
	

	_this=ParaUI.CreateUIObject("button","static", "_lt",30,220,80,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"Take screenshot";
	_this.background="Texture/b_up.png;";
	_this.onclick=";ParaMovie.TakeScreenShot(\"\");";
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",150,220,90,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"Begin recording";
	_this.background="Texture/b_up.png;";
	_this.onclick=";RecorderUI.OnBeginCapture();";
	
	_this=ParaUI.CreateUIObject("button","close", "_lt",260,220,60,30);
	_parent=ParaUI.GetUIObject("recorder_dialog");_parent:AddChild(_this);
	_this.text=L"Cancel";
	_this.background="Texture/b_up.png;";
	_this.onclick=";ParaUI.Destroy(\"recorder_dialog\");";
	
	end
	RecorderUI.UpdateUIStates();
end
NPL.this(activate);
