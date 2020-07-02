--[[
Title: code behind page for MoviePlayerPage.html
Author(s): LiXizhi
Date: 2008/8/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MoviePlayerPage.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/PreLoader.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/IdleWatcher.lua");
local MoviePlayerPage = {
	name = "MoviePlayerPage_instance",
	player = nil,
	preLoader = nil,
	totalFrame = 0,
	playState = nil,
	lastCharacterName = nil,
	playState = "stop", -- stop or playing or pause
	AutoPlay = false,
	ForceStop = false,
	
	skinAutoHide = true,
};
commonlib.setfield("Map3DSystem.Movie.MoviePlayerPage", MoviePlayerPage)
---------------------------------
-- page event handlers
---------------------------------

-- load default values.
function MoviePlayerPage.OnInit()
	local self = document:GetPageCtrl();
	local player = ParaScene.GetPlayer()
	if(player:IsValid() == true) then 		
		local username = ParaScene.GetPlayer().name	
		MoviePlayerPage.lastCharacterName = username;
	end
	Map3DSystem.Movie.IdleWatcher.idleInterrupted = MoviePlayerPage.idleInterrupted;
	Map3DSystem.Movie.IdleWatcher.idleTimeout = MoviePlayerPage.idleTimeout;
end
-- event of idle watcher
function MoviePlayerPage.idleInterrupted()
	local _this = ParaUI.GetUIObject(MoviePlayerPage.name);
	if(_this:IsValid())then
		_this.visible = true;
	end
end
function MoviePlayerPage.idleTimeout()
	local _this = ParaUI.GetUIObject(MoviePlayerPage.name);
	if(_this:IsValid())then
		_this.visible = false;
	end
end
function MoviePlayerPage.IdleWatcher_Start()
	MoviePlayerPage.RegHook()
	Map3DSystem.Movie.IdleWatcher.start();
end
function MoviePlayerPage.IdleWatcher_Stop()
	MoviePlayerPage.UnHook()
	Map3DSystem.Movie.IdleWatcher.stop();
	MoviePlayerPage.idleInterrupted();
end
function MoviePlayerPage.setupSkinAutoHide()
	if(MoviePlayerPage.skinAutoHide)then
		MoviePlayerPage.IdleWatcher_Start()	
	else
		MoviePlayerPage.IdleWatcher_Stop()	
	end
end
function MoviePlayerPage.RegHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "MoviePlayerPage_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = MoviePlayerPage.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "MoviePlayerPage_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = MoviePlayerPage.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "MoviePlayerPage_key_down_hook", appName = "input", wndName = "key_down"}
			o.callback = MoviePlayerPage.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
end
function MoviePlayerPage.UnHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MoviePlayerPage_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MoviePlayerPage_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MoviePlayerPage_key_down_hook", hookType = hookType});
end
function MoviePlayerPage.OnMouseMove(nCode, appName, msg)
	Map3DSystem.Movie.IdleWatcher.interuptIdle();
	return nCode;
end
-----------------------------------------------------------
function MoviePlayerPage.PlayerClose()

end
function MoviePlayerPage.GetMcPlayer()
	local self = MoviePlayerPage;
	if(not self.mcPlayer)then
		self.mcPlayer = CommonCtrl.Animation.Motion.McPlayer:new();
	end
	return self.mcPlayer;
end
function MoviePlayerPage.ShowPlayerView(params) 
	local self = MoviePlayerPage;
	local _this = ParaUI.GetUIObject(MoviePlayerPage.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", MoviePlayerPage.name, params.alignment, params.left, params.top, params.width, params.height);
		_this.background="Texture/3DMapSystem/movie/playbar/bg.png"
		params.parent:AddChild(_this);	
		local left,top,width,height=0,5,60,20;
		
		local _parent = _this;


		-- sliderbar
		NPL.load("(gl)script/ide/SliderBar.lua");
		local ctl = CommonCtrl.SliderBar:new{
			name = MoviePlayerPage.name.."SliderBar",
			alignment = "_lt",
			left = 0,
			top = 2,
			width = params.width,
			height = 8,
			parent = _parent,
			value = 0, -- current value
			min = 0,
			max = 100,
			background = "Texture/3DMapSystem/movie/playbar/slider_background.png: 1 1 1 1",
			button_bg = "Texture/3DMapSystem/movie/playbar/slider.png",
			button_width = 19,
			button_height = 10,
			onchange = Map3DSystem.Movie.MoviePlayerPage.OnSliderBarChanged,
			onMouseDownEvent = Map3DSystem.Movie.MoviePlayerPage.OnMouseDownEvent,
			onMouseUpEvent = Map3DSystem.Movie.MoviePlayerPage.OnMouseUpEvent,
		};
		ctl:Show();
		--onPause_bg 
		_this = ParaUI.CreateUIObject("container", "onPause_bg", "_lt", 10,16,75,43)
		_this.background =  "Texture/3DMapSystem/movie/playbar/playBtn_bg.png";
		_parent:AddChild(_this);
		
		--onPause btn
		_this = ParaUI.CreateUIObject("button", "pause_btn", "_lt", 14,21,36,36)
		_this.text="";
		_this.background =  "Texture/3DMapSystem/movie/playbar/pause.png";
		_this.onclick=";Map3DSystem.Movie.MoviePlayerPage.DoPause();";
		_parent:AddChild(_this);
		--onPlay btn
		_this = ParaUI.CreateUIObject("button", "play_btn", "_lt", 14,21,36,36)
		_this.text="";
		_this.background = "Texture/3DMapSystem/movie/playbar/play.png";
		_this.onclick=";Map3DSystem.Movie.MoviePlayerPage.DoPlay();";
		_parent:AddChild(_this);
				
		--onStop btn
		_this = ParaUI.CreateUIObject("button", "stop_btn", "_lt", 54,25,28,28)
		_this.text="";
		_this.background = "Texture/3DMapSystem/movie/playbar/stop.png";
		_this.onclick=";Map3DSystem.Movie.MoviePlayerPage.DoStop();";
		_parent:AddChild(_this);
		
		--onAuto btn
		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = self.name.."CheckBox",
			alignment = "_lt",
			left = 88,
			top = 28,
			width = 323,
			height = 20,
			parent = _parent,
			isChecked = self.AutoPlay,
			text = "循环播放",
			oncheck = Map3DSystem.Movie.MoviePlayerPage.OnAutoPlay
		};
		ctl.MoviePlayerPage = self;
		ctl:Show();
		CommonCtrl.AddControl(self.name.."CheckBox",ctl)
		
		--onClose_bg 
		_this = ParaUI.CreateUIObject("button", "onClose_bg", "_rb", -38,-40,30,28)
		_this.text="";
		_this.background =  "Texture/3DMapSystem/movie/playbar/quitBtn_bg.png";
		_parent:AddChild(_this);
		
		--onClose btn
		_this = ParaUI.CreateUIObject("button", "close_btn", "_rb", -35,-37,22,22)
		_this.text="";
		_this.tooltip="关闭";
		_this.background = "Texture/3DMapSystem/movie/playbar/quit.png";
		_this.onclick=";Map3DSystem.Movie.MoviePlayerPage.DoClose();";
		_parent:AddChild(_this);
		
		local color = "0 102 204"
		--playState_text
		_this = ParaUI.CreateUIObject("text", "playState_text", "_rb", -280,-35,60,22)
		_this.text="播放状态：";
		_guihelper.SetFontColor(_this, color);
		_parent:AddChild(_this);
		--time_text
		_this = ParaUI.CreateUIObject("text", "time_text",  "_rb", -155,-35,60,22)
		_this.text="00:00:00";
		_guihelper.SetFontColor(_this, color);
		_parent:AddChild(_this);	
		--totalTime_text
		_this = ParaUI.CreateUIObject("text", "totalTime_text", "_rb", -90,-35,60,22)
		_this.text="00:00:00";
		_guihelper.SetFontColor(_this, color);
		_parent:AddChild(_this);
	end	
	MoviePlayerPage.setupSkinAutoHide()
end
function MoviePlayerPage.DataBind(clip)
	local self = MoviePlayerPage;
	if(not clip)then return; end
	self.clip = clip;
	if(clip)then
		self.mcPlayer = self.GetMcPlayer()
		self.mcPlayer:SetClip(clip);
		clip.MC_MotionStart = self.MC_MotionStart;
		clip.MC_MotionPause = self.MC_MotionPause;
		clip.MC_MotionResume = self.MC_MotionResume;
		clip.MC_MotionStop = self.MC_MotionStop;
		clip.MC_MotionEnd = self.MC_MotionEnd;
		clip.MC_MotionTimeChange = self.MC_MotionTimeChange;
		self.DoStop()
		self.UpdateState()
		self.UpdateTimingText(clip);
		self.UpdateTotalText(clip);
	end
end
function MoviePlayerPage.MC_MotionStart(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;
	self.UpdateState();
	self.UpdateTimingText(mc)
end
function MoviePlayerPage.MC_MotionPause(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;	
	self.UpdateState();
	self.UpdateTimingText(mc)
end
function MoviePlayerPage.MC_MotionResume(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;
	self.UpdateState();
	self.UpdateTimingText(mc)
end
function MoviePlayerPage.MC_MotionStop(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;
	self.UpdateState();
	self.UpdateTimingText(mc)
	self.UpdateSliderBar(mc)
end
function MoviePlayerPage.MC_MotionEnd(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;
	self.__DoStop();
end
function MoviePlayerPage.MC_MotionTimeChange(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;
	self.UpdateSliderBar(mc)
end
function MoviePlayerPage.UpdateSliderBar(mc)
	if(not mc)then return; end
	local self = MoviePlayerPage;
	local frame = mc:GetFrame();
	local duration = mc:GetDuration();	
	if(duration == 0) then return; end
	local ctl = CommonCtrl.GetControl(MoviePlayerPage.name.."SliderBar");
	if(ctl ~= nil)then
		local percent = 100*frame/duration;
		ctl:SetValue(percent)
	end
	self.UpdateTimingText(mc)
end
function MoviePlayerPage.UpdateState()
	local self = MoviePlayerPage;
	local state_text = "";
	local show_play_btn = false;
	local show_pause_btn = false;
	if(self.playState == "stop")then
		state_text = "";
		show_play_btn = true;
		show_pause_btn = false;
	elseif(self.playState == "playing")then
		state_text = "正在播放";
		show_play_btn = false;
		show_pause_btn = true;
	elseif(self.playState == "pause")then
		state_text = "暂停";
		show_play_btn = true;
		show_pause_btn = false;
	end
	-- update state text
	local _this = ParaUI.GetUIObject("playState_text");
	if(_this:IsValid())then
		_this.text = state_text;
	end
	-- update play btn
	local play_btn = ParaUI.GetUIObject("play_btn");
	local pause_btn = ParaUI.GetUIObject("pause_btn");
	if(play_btn:IsValid() and pause_btn:IsValid())then
		play_btn.visible = show_play_btn;
		pause_btn.visible = show_pause_btn;
	end
end
function MoviePlayerPage.UpdateTimingText(mc)
	if(not mc)then return; end
	local frame = mc:GetFrame();
	local time = CommonCtrl.Animation.Motion.TimeSpan.GetTime(frame);
	local _this = ParaUI.GetUIObject("time_text");
	if(_this:IsValid())then
		_this.text = time;
	end
end
function MoviePlayerPage.UpdateTotalText(mc)
	if(not mc)then return; end
	local frame = mc:GetDuration();
	local time = CommonCtrl.Animation.Motion.TimeSpan.GetTime(frame);
	local _this = ParaUI.GetUIObject("totalTime_text");
	if(_this:IsValid())then
		_this.text = time;
	end
end
function MoviePlayerPage.OnMouseDownEvent()
	local self = MoviePlayerPage;
	local mcPlayer = self.mcPlayer;
	if(mcPlayer)then
		mcPlayer:Pause();
	end
end
function MoviePlayerPage.OnMouseUpEvent()
	local self = MoviePlayerPage;
	if(self.playState == "playing" or self.playState == "stop")then
		self.DoResume();
	end
end
function MoviePlayerPage.OnSliderBarChanged(value)
	if(not value)then return; end
	local self = MoviePlayerPage;
	local mc = self.clip;
	local mcPlayer = self.mcPlayer;
	if(mc and mcPlayer)then
		local frame = mc:GetDuration() * value/100;
		frame = math.floor(frame);
		mcPlayer:GotoAndStop(frame)
	end
	
end
function MoviePlayerPage.OnAutoPlay(sControlName,value)
	local checkbox = CommonCtrl.GetControl(sControlName);
	if(checkbox)then
		local self = checkbox.MoviePlayerPage;
		if(self)then
			self.AutoPlay = value;
		end
	end
end
function MoviePlayerPage.DoPlay()
	local self = MoviePlayerPage;
	if(self.mcPlayer)then
		-- NOTE: force don't highlight the closest character
		-- NOTE by Andy: this is only a quick fix to the blue partial circle when movie is playing
		--   it set g_force_donot_highlight to true and false when movie is stopped
		Map3DSystem.ForceDonotHighlight();
		self.ForceStop = false;
		CommonCtrl.Animation.MovieCaption.setText("");
		CommonCtrl.Animation.MovieCaption.show(true)
		if(self.playState == "stop")then
			self.playState = "playing";
			self.mcPlayer:Play();	
		else
			self.DoResume()
		end
	end
end
function MoviePlayerPage.DoResume()
	local self = MoviePlayerPage;
	if(self.mcPlayer)then
		self.playState = "playing";
		self.mcPlayer:Resume();
	end
end
function MoviePlayerPage.DoPause()
	local self = MoviePlayerPage;
	if(self.mcPlayer)then
		self.playState = "pause";
		self.mcPlayer:Pause();
		CommonCtrl.Animation.Motion.PreLoader.StopAllObjects();
	end
end
function MoviePlayerPage.DoStop()
	local self = MoviePlayerPage;
	if(self.mcPlayer)then	
		-- NOTE: cancel force don't highlight the closest character
		Map3DSystem.CancelForceDonotHighlight();
		self.ForceStop = true;
		self.__DoStop()
	end
end
function MoviePlayerPage.__DoStop()
	local self = MoviePlayerPage;
	if(self.mcPlayer)then	
		CommonCtrl.Animation.MovieCaption.setText("");
		CommonCtrl.Animation.MovieCaption.show(false)
		self.playState = "stop";
		self.mcPlayer:Stop();
		CommonCtrl.Animation.Motion.PreLoader.StopAllObjects();	
		if(self.ForceStop == false)then
			if(self.AutoPlay)then
				self.DoPlay()
			end	
		end
	end
end
function MoviePlayerPage.GotoAndStop(frame)
	local self = MoviePlayerPage;
	if(self.mcPlayer)then
		self.mcPlayer:GotoAndStop(frame);
		CommonCtrl.Animation.Motion.PreLoader.StopAllObjects();
	end
end
function MoviePlayerPage.DoClose()
	local self = MoviePlayerPage;
	self.AutoPlay = false;
	self.DoStop()
	self.DoCloseWindow()
	--CommonCtrl.Animation.Motion.PreLoader.DestoryAllObjects();
	Map3DSystem.App.Commands.Call("File.GetPlayerFocus");
	
	MoviePlayerPage.IdleWatcher_Stop()	
	MoviePlayerPage.PlayerClose();
end
function MoviePlayerPage.DoOpenWindow()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
		url="script/kids/3DMapSystemUI/Movie/MoviePlayerPage.html", name="MoviePlayerPage_instance", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
		text = "预览电影",
		isShowTitleBar = false, 
		directPosition = true,
			align = "_mb",
			x = 0,
			y = -66,
			width = 0,
			height = 66,
		bToggleShowHide = false,
		style = {
			name = "MoviePlayback",
			
			window_bg = "",
			fillBGLeft = 0,
			fillBGTop = 0,
			fillBGWidth = 0,
			fillBGHeight = 0,
			
			shadow_bg = "",
			fillShadowLeft = -10,
			fillShadowTop = -6,
			fillShadowWidth = -10,
			fillShadowHeight = -15,
			
			titleBarHeight = 0,
			toolboxBarHeight = 48,
			statusBarHeight = 32,
			borderLeft = 0,
			borderRight = 0,
			borderBottom = 0, -- added by LXZ, 2008.9.14
			
			textfont = "System;12;bold";
			textcolor = "255 255 255",
			
			iconSize = 16,
			iconTextDistance = 16, -- distance between icon and text on the title bar
			
			IconBox = {alignment = "_lt",
						x = 8, y = 4, size = 16,},
			TextBox = {alignment = "_lt",
						x = 32, y = 6, height = 16,},
						
			CloseBox = {alignment = "_rt",
						x = -24, y = 2, size = 20,
						icon = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
						icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
						icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
						},
			MinBox = {alignment = "_rt",
						x = -68, y = 2, size = 20,
						icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
						icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
						icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
						},
			MaxBox = {alignment = "_rt",
						x = -46, y = 2, size = 20,
						icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
						icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
						icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
						},
			PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
						x = 2, y = 2, size = 20,
						icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
						icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
			
			resizerSize = 24,
			resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
		},
		bShow = true,
		zorder = 1002,
		DestroyOnClose = true,
	});
	Map3DSystem.App.Commands.Call("File.SetPlayerFocus");
end
function MoviePlayerPage.DoCloseWindow()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	name="MoviePlayerPage_instance", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 	
		bShow = false,bDestroy = true,
	});
end


	