--[[
Title: VideoRecorder
Author(s): LiXizhi
Date: 2010/8/4
Desc: The video recorder. This class is independent of any apps, so it can run in any app enabled applications. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Movie/VideoRecorder.lua");
MyCompany.Aries.Movie.VideoRecorder.Show();
------------------------------------------------------------
--]]
local VideoRecorder = commonlib.gettable("MyCompany.Aries.Movie.VideoRecorder");

local page;
function VideoRecorder.OnInit()
	page = document:GetPageCtrl();
end

function VideoRecorder.OnReset()
	page:SetValue("ParamsSet", "custom")
	VideoRecorder.OnSelectParamsSet(nil, "default");
end

function VideoRecorder.OnSelectParamsSet(name, value)
	if(value == "default") then
		page:SetValue("VideoResolution", "480*280")
		page:SetValue("Codec", "0")
		page:SetValue("IsIncludeUI", false)
		page:SetValue("IsIncludeHeadonText", false)
		page:SetValue("StereoMode", "0")
		page:SetValue("separationDist", 0.30)
		page:SetValue("FPS", "20")
	elseif(value == "Stereo720*480") then
		page:SetValue("VideoResolution", "720*480")
		page:SetValue("Codec", "0")
		page:SetValue("IsIncludeUI", false)
		page:SetValue("IsIncludeHeadonText", false)
		page:SetValue("StereoMode", "2")
		page:SetValue("separationDist", 0.30)
		page:SetValue("FPS", "29")
	end
end

-- show the window 
function VideoRecorder.Show(bShow)
	System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Movie/VideoRecorder.html", 
        name = "Movie.ShowVideoRecoder", 
        isShowTitleBar = false,
        DestroyOnClose = false,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 2,
		bShow = bShow;
        allowDrag = true,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -480/2,
            y = -400/2,
            width = 480,
            height = 400,
    });
end

VideoRecorder.EyeSeperationMaxvalue = 0.3;
VideoRecorder.EyeSeperationMinvalue = 0;

function VideoRecorder.OnPauseCapture()
	ParaMovie.PauseCapture();
end

function VideoRecorder.OnResumeCapture()
	ParaMovie.ResumeCapture();
end

function VideoRecorder.OnEndCapture()
	ParaMovie.EndCapture();
	VideoRecorder.ShowRecorderBar(false);
	local filename = ParaMovie.GetMovieFileName();
	local msg = string.format("<b>==录制结束==</b><br/>视频文件在: %s", filename);
	LOG.info(ParaMovie.GetMovieFileName().." is recorded\r\n");
	_guihelper.MessageBox(msg, function()
		Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath=string.gsub(filename, "[^/\\]*$", ""), silentmode=true});
	end);
end

function VideoRecorder.ShowRecorderBar(bShow)
	System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Movie/VideoRecorderBar.html", 
        name = "Movie.ShowVideoRecoderBar", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 2,
		bShow = bShow,
        allowDrag = true,
        directPosition = true,
            align = "_ctt",
            x = 0,
            y = 0,
            width = 160,
            height = 40,
    });
end

function VideoRecorder.OnCancel()
	page:CloseWindow();
end

function VideoRecorder.OnOK(name, values)
	local VideoResolution = values.VideoResolution;
	if(VideoResolution == "current") then
		local _root = ParaUI.GetUIObject("root");
		local _, __, width, height = _root:GetAbsPosition();
		if(width~=nil and height~=nil) then
			ParaMovie.SetMovieScreenSize(width, height);
		end
	else
		-- get the width and height from string, the format is width*height
		local from, to, width, height = string.find(VideoResolution, "(%d+)%D+(%d+)");
		if(width~=nil and height~=nil) then
			--log("video recoder resolution changed: "..width.." "..height.."\n");	
			ParaMovie.SetMovieScreenSize(tonumber(width), tonumber(height));
		end
	end

	local Codec = tonumber(values.Codec);
	if(Codec) then
		ParaMovie.SetEncodeMethod(Codec);
	end

	if(values.IsIncludeUI) then
		ParaMovie.SetCaptureGUI(values.IsIncludeUI);
	end

	local StereoMode = tonumber(values.StereoMode);
	if(StereoMode) then
		ParaMovie.SetStereoCaptureMode(StereoMode);
	end

	local FPS = tonumber(values.FPS);
	if(FPS) then
		ParaMovie.SetRecordingFPS(FPS);
	end

	local separationDist = tonumber(values.separationDist);
	if(separationDist) then
		ParaMovie.SetStereoEyeSeparation(separationDist);
	end

	-- finally begin capture
	VideoRecorder.OnBeginCapture();
end

function VideoRecorder.OnBeginCapture()
	VideoRecorder.ShowRecorderBar(true);
	
	ParaMovie.BeginCapture("");
	VideoRecorder.OnPauseCapture();
	
	-- close dialog
	VideoRecorder.Show(false);
	
	local codecname="自定义";
	local x,y = ParaMovie.GetMovieScreenSize();
	
	local captureGUI;
	if(ParaMovie.CaptureGUI() == true) then
		captureGUI = "No";
	else
		captureGUI = "Yes";
	end
	
	local EnableStereo;
	if(ParaMovie.GetStereoCaptureMode() == 0) then
		EnableStereo = "No";
	else
		EnableStereo = "Yes";
	end
	
	local msg = string.format("<div style='width:900px'>==成功进入录像模式==<br/>点击左上角圆圈按钮后开始录像<br/>录像分辨率= %d X %d 解码器:%s 隐藏2D图形界面:%s<br/>视频文件:%s<br/>帧率:%d使用立体视频输出:%s立体分离度:%.3f</div>", 
		x, y,codecname, captureGUI, ParaMovie.GetMovieFileName(),
		ParaMovie.GetRecordingFPS(), EnableStereo, ParaMovie.GetStereoEyeSeparation());
	_guihelper.MessageBox(msg);
end