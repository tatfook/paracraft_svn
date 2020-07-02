--[[
Title: tracks editor
Author(s): Leio Zhang
Date: 2008/9/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/TracksEditor.lua");
local tracksEditor = Map3DSystem.Movie.TracksEditor:new()
tracksEditor:Show(true);
tracksEditor:Update();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/StoryBoardPlayer.lua");
local TracksEditor = {
	name = "TracksEditor_instance",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	parent = nil,
	container_bg = nil, -- the background of container
	hasRecorded = false,
	lastCharacterName = nil,
	
	frameName = nil,
	canEditCamera = false,
	canEditEvent = false,
	canEditSound = false,
	canEditCaption = false,
	
	player = nil,
	playState = nil, -- nil or playing or pause 
	controlState = "record", -- play or record
	staticTimeLength = "00:05:00",
	staticTimeLength_2 = "00:00:05",
	defaultTimeLength = nil, 
	forceStop = false,
}
commonlib.setfield("Map3DSystem.Movie.TracksEditor", TracksEditor)
function TracksEditor:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o.name = ParaGlobal.GenerateUniqueID();	
	CommonCtrl.AddControl(o.name,o)
	
	o.defaultTimeLength = o.staticTimeLength or "00:05:00";
	return o
end
function TracksEditor:Show(bShow) 
	local _this = ParaUI.GetUIObject(self.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", self.name, self.alignment, self.left, self.top, self.width, self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		else
			_this.background="";
		end
		local _parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		local left_const = 32
		local top_const = 20
		--playState_text
		_this = ParaUI.CreateUIObject("text", self.name.."playState_text", "_lt", 5,5+top_const,100,20)
		_this.text="播放状态：";
		_parent:AddChild(_this);
		--time_text
		_this = ParaUI.CreateUIObject("text", self.name.."time_text",  "_rt", -125,5+top_const,60,20)
		_this.text="00:00:00";
		_parent:AddChild(_this);	
		--totalTime_text
		_this = ParaUI.CreateUIObject("text", self.name.."totalTime_text", "_rt", -60,5+top_const,60,20)
		_this.text="00:00:00";
		_parent:AddChild(_this);
	
		-- sliderbar
		NPL.load("(gl)script/ide/SliderBar.lua");
		local ctl = CommonCtrl.SliderBar:new{
			name = self.name.."SliderBar",
			alignment = "_lt",
			left = 0,
			top = 20+top_const,
			width = self.width,
			height = 20,
			parent = _parent,
			value = 0, -- current value
			min = 0,
			max = 100,
			canDrag = false,
			onchange = Map3DSystem.Movie.TracksEditor.OnSliderBarChanged,
		};
		ctl:Show(true);
		
		--OnPause btn
		_this = ParaUI.CreateUIObject("button", self.name.."pause_btn", "_lt", 10,45+top_const,32,32)
		_this.text="";
		--_this.tooltip = "暂停预览"
		_this.background = "Texture/player/pause.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnPause(%q);", self.name);
		_parent:AddChild(_this);
		--OnPlay btn
		_this = ParaUI.CreateUIObject("button", self.name.."play_btn", "_lt", 10,45+top_const,32,32)
		_this.text="";
		--_this.tooltip = "预览"
		_this.background = "Texture/player/play.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnPlay(%q);", self.name);
		_parent:AddChild(_this);
				
		--OnStop btn 
		_this = ParaUI.CreateUIObject("button", self.name.."stop_btn", "_lt", 42,45+top_const,32,32)
		_this.text="";
		--_this.tooltip = "停止预览"
		_this.background = "Texture/player/stop.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnStop(%q);", self.name);
		_parent:AddChild(_this);
		
		--OnPause record btn
		_this = ParaUI.CreateUIObject("button", self.name.."pause_btn_record", "_lt", 10,45+top_const,32,32)
		_this.text="";
		--_this.tooltip = "暂停录制"
		_this.background = "Texture/player/pause.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnPause_record(%q);", self.name);
		_parent:AddChild(_this);
		--OnPlay record btn
		_this = ParaUI.CreateUIObject("button", self.name.."play_btn_record","_lt", 10,45+top_const,32,32)
		_this.text="";
		--_this.tooltip = "开始录制"
		_this.background = "Texture/player/rec.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnPlay_record(%q);", self.name);
		_parent:AddChild(_this);
				
		--OnStop record btn
		_this = ParaUI.CreateUIObject("button", self.name.."stop_btn_record",  "_lt", 42,45+top_const,32,32)
		_this.text="";
		--_this.tooltip = "结束录制"
		_this.background ="Texture/player/stop.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnStop_record(%q);", self.name);
		_parent:AddChild(_this);
		--OnClose btn
		_this = ParaUI.CreateUIObject("button", self.name.."save_btn", "_rt", -42-left_const,45+top_const,32,32)
		_this.text="";
		_this.tooltip = "取消录制"
		_this.background = "Texture/3DMapSystem/common/IconSet/Delete_3.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnClose(%q);", self.name);
		_parent:AddChild(_this);
		--OnSave btn
		_this = ParaUI.CreateUIObject("button", self.name.."save_btn", "_rt", -42-2*left_const,45+top_const,32,32)
		_this.text="";
		_this.tooltip = "保存"
		_this.background = "Texture/3DMapSystem/common/png-0057.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnSave(%q);", self.name);
		_parent:AddChild(_this);
		--OnClear btn
		_this = ParaUI.CreateUIObject("button", self.name.."clear_btn", "_rt", -42-3*left_const,45+top_const,32,32)
		_this.text="";
		_this.tooltip = "从新开始录制"
		_this.background = "Texture/3DMapSystem/common/reset.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnClear(%q);", self.name);
		_parent:AddChild(_this);
		--OnSet btn
		_this = ParaUI.CreateUIObject("button", self.name.."set_btn", "_rt", -42-4*left_const,45+top_const,32,32)
		_this.text="";
		_this.tooltip = "设置时间"
		_this.background = "Texture/3DMapSystem/common/png-0571.png";
		_this.onclick = string.format(";Map3DSystem.Movie.TracksEditor.OnSet(%q);", self.name);
		_parent:AddChild(_this);
		
		if(self.canEditSound or self.canEditEvent or self.canEditCaption)then
		NPL.load("(gl)script/ide/TabControl.lua");
		local _this = ParaUI.CreateUIObject("container", self.name.."container_Editor_TabControl", "_lb", 0,-30,self.width,30)
		_this.background = ""
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/TreeView.lua");
	local tabPagesNode_Editor = CommonCtrl.TreeNode:new({Name = "tabPagesNode_Editor"});
	if(self.canEditEvent)then
		tabPagesNode_Editor:AddChild(CommonCtrl.TreeNode:new({Text = "人物",type = "actor"}));
	end
	if(self.canEditSound)then
		tabPagesNode_Editor:AddChild(CommonCtrl.TreeNode:new({Text = "声音",type = "sound"}));
	end
	if(self.canEditCaption)then
		tabPagesNode_Editor:AddChild(CommonCtrl.TreeNode:new({Text = "对话",type = "caption"}));
	end

	local ctl = CommonCtrl.TabControl:new{
			name = self.name.."Editor_TabControl",
			parent = _this,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TracksEditor = self,
			
			TabAlignment = "Top", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_Editor, -- CommonCtrl.TreeNode object, collection of tab pages
			TabHeadOwnerDraw = function(_parent, tabControl) 
						local _head = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
						_head.background = "";
						_head.enabled = false;
						_parent:AddChild(_head);
					end, --function(_parent, tabControl) end, -- area between top/left border and the first item
				TabTailOwnerDraw = function(_parent, tabControl) 
						local _tail = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
						_tail.background = "";
						_tail.enabled = false;
						_parent:AddChild(_tail);
					end, --function(_parent, tabControl) end, -- area between the last item and buttom/right border
				TabStartOffset = 16, -- start of the tabs from the border
				TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) 
						local _item = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
						if(bSelected == true) then
							_item.background = "Texture/3DMapSystem/Chat/message_bg.png;0 0 16 8:7 7 7 0";
						else
							_item.background = "";
						end
						local node = tabControl.TabPages:GetChild(index);
						_item.text = node.Text;
						_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", tabControl.name, index);
						_parent:AddChild(_item);
					end,
				TabItemWidth = 64, -- width of each tab item
				TabItemHeight = 32, -- height of each tab item
				MaxTabNum = 10, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex, tabControl)		
				local node = tabControl.TabPages:GetChild(toIndex);
				if(not node)then return; end
				local self = tabControl.TracksEditor;
				if(not self)then return; end
				local type = node.type;				
				if(type == "actor")then
					Map3DSystem.App.Commands.Call("Creation.NormalCharacter");
					Map3DSystem.Movie.CaptionTrackRecorder.CloseWindow()
				elseif(type == "sound")then
					self.OnAddSound(self.name)
					Map3DSystem.App.Commands.Call("Creation.NormalCharacter",{bShow=false});
					Map3DSystem.Movie.CaptionTrackRecorder.CloseWindow()
				elseif(type == "caption")then
					--self.OnAddCaptionTxt(self.name)	
					Map3DSystem.Movie.CaptionTrackRecorder.OpenWindow()
					--Map3DSystem.App.Commands.Call("Creation.NormalCharacter",{bShow=false});
				end
			end,
		};
	ctl:Show(true);
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	 
	end
	self:Init()
end
function TracksEditor:Init()
	if(not self.player)then
		local player = CommonCtrl.Animation.StoryBoardPlayer:new();
		player.OnMotionStart = TracksEditor.OnMotionStart;
		player.OnMotionPause = TracksEditor.OnMotionPause;
		player.OnMotionResume = TracksEditor.OnMotionResume;	
		--player.OnMotionStop = TracksEditor.OnMotionStop;
		player.OnMotionEnd = TracksEditor.OnMotionEnd;
		player.OnTimeChange =TracksEditor.OnTimeChange;
		player.TracksEditor = self;
		self.player = player;
		self:Update()
	end
	local player = ParaScene.GetPlayer()
	if(player:IsValid() == true) then 		
		local username = ParaScene.GetPlayer().name	
		self.lastCharacterName = username;
	end
end
function TracksEditor.OnPlay(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self or not self.player) then return; end
	if(self.playState == nil)then
		self.playState = "playing";
		self.player:doPlay();
	elseif(self.playState == "pause")then
		self.playState = "playing";
		self.player:doResume();
	end
	if(self.controlState == "record")then
		self.hasRecorded = true;
		self:EnabledTrackRecorder()
	end
end
function TracksEditor.OnStop(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self or not self.player) then return; end
	if(self.playState == "playing" or self.playState == "pause")then
		-- stop current palyer
		self.player:_doPause();
		if(self.controlState == "record")then	
			self.forceStop = true;	
			self:RecorderDoEnd()
		end		
		self:OnMotionStop()							
	end
end
function TracksEditor.OnPause(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self or not self.player) then return; end
	if(self.playState == "playing")then
		self.playState = "pause";
		self.player:doPause();		
	end
end
function TracksEditor.OnPlay_record(sControlName)
	TracksEditor.OnPlay(sControlName)
end
function TracksEditor.OnPause_record(sControlName)
	TracksEditor.OnPause(sControlName)
end
function TracksEditor.OnStop_record(sControlName)
	TracksEditor.OnStop(sControlName)
end
-- clear all tracks which had been recorded by recorder player
function TracksEditor.OnClear(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self)then return end;
	self.defaultTimeLength = self.staticTimeLength;
	self:DoReset()
end
function TracksEditor.OnMotionStart(ctl,frame)
	if(not ctl or not ctl.TracksEditor)then return; end
	local self = ctl.TracksEditor;

	self:UpdateControlUI()
	if(self.preLoader)then
		self.preLoader:PlayerStart();
	end	
end
function TracksEditor:OnMotionStop()
	self.playState = nil;
	self:SetAllControlVisible();
	self:UpdateControlUI()
	
	self:SetSliderBar(0);
	self:FindPrimitive()
	if(self.preLoader)then
		self.preLoader:PlayerEnd();
	end
	CommonCtrl.Animation.MovieCaption.show(false);
	CommonCtrl.Animation.MovieCaption.setText("")
end
function TracksEditor.OnMotionResume(ctl)
	if(not ctl or not ctl.TracksEditor)then return; end
	local self = ctl.TracksEditor;
	self:UpdateControlUI()
end
-- the recorder player will be auto stop at the last of time when record tracks if user do nothing
-- so after doEnd (self:RecorderDoEnd()), the recorder player will change state to "paly"(self.controlState = "play") and stop at first time.
-- self.forceStop means user forcible stop the recorder player when self.controlState = "record"
function TracksEditor.OnMotionEnd(ctl,frame)
	if(not ctl or not ctl.TracksEditor)then return; end
	local self = ctl.TracksEditor;	
	if(not self.player) then return; end
	
	if(self.controlState == "record" and not self.forceStop)then
		self:RecorderDoEnd()	
		_guihelper.MessageBox("录制完毕！");
	end
	self:OnMotionStop()	
end
function TracksEditor.OnMotionPause(ctl)
	if(not ctl or not ctl.TracksEditor)then return; end
	local self = ctl.TracksEditor;
	self:UpdateControlUI()
end
-- if self.controlState is "record", this function will be touched by all player events except "OnMotionStop".
-- if self.controlState is "play", this function will be touched by all player events.
function TracksEditor.OnTimeChange(ctl,frame)
	if(not ctl or not ctl.TracksEditor)then return; end
	local self = ctl.TracksEditor;
	if(self.controlState == "record")then
		self:SetCurRecorderFrame(frame);
		self.UpdateTime(ctl.TracksEditor,frame)
	else
		self:SetCurPlayFrame(frame);
	end
	local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);
	if(not time)then
		time = "wrong time";
	end      
	self:SetTimeTxt()   
	 
	local percent = 0;
	if(self.totalFrame == 0) then
		percent = 0;
	else
		percent = 100*frame/self.totalFrame;
	end	
	self:SetSliderBar(percent);
end
function TracksEditor.UpdateTime(tracksEditor,frame)
	if(tracksEditor and tracksEditor.canEditCamera)then
		Map3DSystem.Movie.CameraTrackRecorder.UpdateTime(tracksEditor,frame)
	end
	if(tracksEditor and tracksEditor.canEditCaption)then
		Map3DSystem.Movie.CaptionTrackRecorder.UpdateTime(tracksEditor,frame)
	end
end
-- when recorder is stopped
function TracksEditor:RecorderDoEnd()
	local totalFrame = self:GetCurRecorderFrame();
	self:SetTotalFrame(totalFrame)
			
	if(self.canEditCamera)then
		Map3DSystem.Movie.CameraTrackRecorder.DoEnd(totalFrame)
	end
	self:DisEnabledTrackRecorder()
	self.controlState = "play";
	-- create a new storyboard
	self:CreateNewStoryBoard();
	if(self.preLoader)then
		self.preLoader:PlayerEnd();
	end
end
function TracksEditor:LoadFile(filename,autoPlay) 
	if(not self.player or not filename) then return; end	
	self.player:Load(filename);
	self.preLoader = CommonCtrl.Animation.PreLoader:new(self.player);
	if(autoPlay)then
		self:onPlay()
	end
end
function TracksEditor:LoadStr(str,autoPlay) 
	if(not self.player or not str) then return; end	
	str = ParaMisc.EncodingConvert("", "utf-8", str)
	self.player:Parse(str);	
	self.preLoader = CommonCtrl.Animation.PreLoader:new(self.player);
	if(autoPlay)then
		self:onPlay()
	end
end
function TracksEditor:CreateNewStoryBoard()
	local str = self:GetStoryBoardKeyFrames();
	self:LoadStr(str,false)
end
-- 
function TracksEditor:UpdateControlUI()
	self:SetStateTxt();
	self:SetTimeTxt();
	self:SetTotalTimeTxt();
	self:SetCurPlayControlVisible();
end
function TracksEditor:Update()
	if(self.player) then
		self.player:_doPause();
	end
	self:SetTotalTime(self.defaultTimeLength);
	self:SetCurRecorderFrame(0)
	self:SetCurPlayFrame(0)
	self.controlState = "record";
	self.playState = nil;
	self.preLoader = nil;
	self.forceStop = false;
	self.hasRecorded = false;
	self:SetAllControlVisible()
	
	self:UpdateControlUI()	
	self:SetSliderBar(0);
	self:FindPrimitive();
	
	self:ClearTempValues();
	self:ClearTrackRecorder()
	
	-- create a new storyboard
	self:CreateNewStoryBoard();	
	if(self.preLoader)then
		self.preLoader:PlayerEnd();
	end
end
function TracksEditor:SetConfig()
	self.defaultTimeLength = self.staticTimeLength_2;
	self:DoReset()
end
function TracksEditor:DoReset()
	self:Update();
	self:SetEditCamera(self.cameraParent,self.moviescript,self.cameraTrack,self.cameraUpdateType)
	self:SetEditSound(self.soundParent,self.moviescript)
	self:SetEditEvent(self.eventParent,self.moviescript)
	self:SetEditCaption(self.eventParent,self.moviescript)
end
function TracksEditor:SetCurPlayFrame(v)
	if(not v)then return; end
	self.curPlayFrame = v;
end
-- return the current play frame
function TracksEditor:GetCurPlayFrame()
	return self.curPlayFrame;
end
-- return the current play time
function TracksEditor:GetCurPlayTime()
	local frame = self.curPlayFrame;
	if(not frame)then return ""; end
	local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);
	return time;
end
function TracksEditor:SetCurRecorderFrame(v)
	if(not v)then return; end
	self.curRecorderFrame = v;
end
-- return the current record frame
function TracksEditor:GetCurRecorderFrame()
	return self.curRecorderFrame;
end
-- return the current record time
function TracksEditor:GetCurRecorderTime()
	local frame = self.curRecorderFrame;
	if(not frame)then return ""; end
	local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);
	return time;
end
function TracksEditor:SetTotalTime(v)
	if(not v)then return; end
	local frame = CommonCtrl.Animation.TimeSpan.GetFrames(v);
	self:SetTotalFrame(frame)
end
function TracksEditor:SetTotalFrame(v)
	if(not v)then return; end
	self.totalFrame = v;
end
function TracksEditor:GetTotalFrame()
	return self.totalFrame;
end
function TracksEditor:GetTotalTime()
	local frame = self.totalFrame;
	if(not frame)then return ""; end
	local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);
	return time;
end
function TracksEditor:SetSliderBar(v)
	if(not v)then v = 0; end
	local ctl = CommonCtrl.GetControl(self.name.."SliderBar");
	if(ctl ~= nil)then
		ctl:SetValue(v)
	end
end
-- set the playing time
function TracksEditor:SetTimeTxt()
	local txt = "";
	if(self.controlState == "record")then
		txt = self:GetCurRecorderTime();
	else
		txt = self:GetCurPlayTime();
	end	
	local _this = ParaUI.GetUIObject(self.name.."time_text");
	if(_this:IsValid())then
		_this.text = txt;
	end
end
-- set the total time
function TracksEditor:SetTotalTimeTxt()
	local time = self:GetTotalTime()
	local _this = ParaUI.GetUIObject(self.name.."totalTime_text");
	if(_this:IsValid())then
		_this.text = time;
	end
end
function TracksEditor:SetStateTxt()
	local txt = self:GetStateTxt();
	local _this = ParaUI.GetUIObject(self.name.."playState_text");
	if(_this:IsValid())then
		_this.text = txt;
	end
end
function TracksEditor:GetStateTxt()
	local txt = ""
	if(self.controlState == "record")then
		if(self.playState == "playing")then
			txt = "记录当中";
		elseif(self.playState == "pause")then
			txt = "暂停记录";
		else
			txt = "";
		end
	else
		if(self.playState == "playing")then
			txt = "预览当中";
		elseif(self.playState == "pause")then
			txt = "暂停预览";
		else
			txt = "";
		end
	end
	return txt;
end
function TracksEditor:SetCurPlayControlVisible()
	if(self.controlState == "record")then
		local play_btn = ParaUI.GetUIObject(self.name.."play_btn_record");
		local pause_btn = ParaUI.GetUIObject(self.name.."pause_btn_record");
		local save_btn = ParaUI.GetUIObject(self.name.."save_btn");
		if(play_btn:IsValid() and pause_btn:IsValid())then
			if(self.playState == "playing")then
				play_btn.visible = false;
				pause_btn.visible = true;
				--save_btn.visible = false;
			else
				play_btn.visible = true;
				pause_btn.visible = false;
				--save_btn.visible = true;
			end
		end
	else
		local play_btn = ParaUI.GetUIObject(self.name.."play_btn");
		local pause_btn = ParaUI.GetUIObject(self.name.."pause_btn");
		local save_btn = ParaUI.GetUIObject(self.name.."save_btn");
		if(play_btn:IsValid() and pause_btn:IsValid())then
			if(self.playState == "playing")then
				play_btn.visible = false;
				pause_btn.visible = true;
				--save_btn.visible = false;
			else
				play_btn.visible = true;
				pause_btn.visible = false;
				--save_btn.visible = true;
			end
		end
		
		
	end
end
function TracksEditor:SetAllControlVisible()
	if(self.controlState == "record")then
		local _btn = ParaUI.GetUIObject(self.name.."play_btn");
		if(_btn:IsValid())then _btn.visible = false; end
		_btn = ParaUI.GetUIObject(self.name.."pause_btn");
		if(_btn:IsValid())then _btn.visible = false; end
		_btn = ParaUI.GetUIObject(self.name.."stop_btn");
		if(_btn:IsValid())then _btn.visible = false; end
		
		_btn = ParaUI.GetUIObject(self.name.."play_btn_record");
		if(_btn:IsValid())then _btn.visible = true; end
		_btn = ParaUI.GetUIObject(self.name.."pause_btn_record");
		if(_btn:IsValid())then _btn.visible = true; end
		_btn = ParaUI.GetUIObject(self.name.."stop_btn_record");
		if(_btn:IsValid())then _btn.visible = true; end
	else
		local _btn = ParaUI.GetUIObject(self.name.."play_btn");
		if(_btn:IsValid())then _btn.visible = true; end
		_btn = ParaUI.GetUIObject(self.name.."pause_btn");
		if(_btn:IsValid())then _btn.visible = true; end
		_btn = ParaUI.GetUIObject(self.name.."stop_btn");
		if(_btn:IsValid())then _btn.visible = true; end
		
		_btn = ParaUI.GetUIObject(self.name.."play_btn_record");
		if(_btn:IsValid())then _btn.visible = false; end
		_btn = ParaUI.GetUIObject(self.name.."pause_btn_record");
		if(_btn:IsValid())then _btn.visible = false; end
		_btn = ParaUI.GetUIObject(self.name.."stop_btn_record");
		if(_btn:IsValid())then _btn.visible = false; end
	end
end
function TracksEditor.OnSave(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self)then return; end
	if(self.hasRecorded)then
		self.OnStop(self.name);
		self:UpdateTrackMcmlNode();
		
		local movieManager = Map3DSystem.Movie.MovieListPage.SelectedMovieManager;
		if(movieManager)then
			local moviescript = movieManager.moviescript;
			movieManager:__DataBind(nil,moviescript);
			movieManager:DataBind(moviescript);
		end
	end
	self.OnClose(sControlName)
end
function TracksEditor.OnClose(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self)then return; end
	self:Update();
	self:OnClickCloseRecorder();
	
end
function TracksEditor:ClearTempValues()
	if(self.canEditEvent)then
		Map3DSystem.Movie.EventTrackRecorder.ClearTempValues()
	end
end
-- set the length of record time
function TracksEditor.OnSet(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self)then return; end
	self:SetConfig();
end
-- which track recorder can be used
function TracksEditor:EnabledTrackRecorder()
	if(self.canEditCamera)then
		Map3DSystem.Movie.CameraTrackRecorder.Enabled()
	end
	if(self.canEditSound)then
		Map3DSystem.Movie.SoundTrackRecorder.Enabled()
	end
	if(self.canEditEvent)then
		Map3DSystem.Movie.EventTrackRecorder.Enabled()
	end
	if(self.canEditCaption)then
		Map3DSystem.Movie.CaptionTrackRecorder.Enabled()
	end
end
-- which track recorder can not be used
function TracksEditor:DisEnabledTrackRecorder()
	if(self.canEditCamera)then
		Map3DSystem.Movie.CameraTrackRecorder.DisEnabled()
	end
	if(self.canEditSound)then
		Map3DSystem.Movie.SoundTrackRecorder.DisEnabled()
	end
	if(self.canEditEvent)then
		Map3DSystem.Movie.EventTrackRecorder.DisEnabled()
	end
	if(self.canEditCaption)then
		Map3DSystem.Movie.CaptionTrackRecorder.DisEnabled()
	end
end
function TracksEditor:UpdateTrackMcmlNode()
	if(self.canEditCamera)then
		Map3DSystem.Movie.CameraTrackRecorder.UpdateTrackMcmlNode()
	end
	if(self.canEditSound)then
		Map3DSystem.Movie.SoundTrackRecorder.UpdateTrackMcmlNode()
	end
	if(self.canEditEvent)then
		Map3DSystem.Movie.EventTrackRecorder.UpdateTrackMcmlNode()
	end
	if(self.canEditCaption)then
		Map3DSystem.Movie.CaptionTrackRecorder.UpdateTrackMcmlNode()
	end
	self:UpdateClipCallback()
end
function TracksEditor:ClearTrackRecorder()
	if(self.canEditCamera)then
		Map3DSystem.Movie.CameraTrackRecorder.Clear()
	end
	if(self.canEditSound)then
		Map3DSystem.Movie.SoundTrackRecorder.Clear()
	end
	if(self.canEditEvent)then
		Map3DSystem.Movie.EventTrackRecorder.Clear()
	end
	if(self.canEditCaption)then
		Map3DSystem.Movie.CaptionTrackRecorder.Clear()
	end
end
function TracksEditor:SetClipCallback(clipCallback,clip)
	self.clipCallback = clipCallback;
	self.clipCallback_clip = clip;
end
function TracksEditor:UpdateClipCallback()
	if(self.clipCallback and self.clipCallback_clip)then
		self.clipCallback(self.clipCallback_clip);
	end
end
-- track is <pe:movie-camera-track id="11" text="">
function TracksEditor:SetEditCamera(parent,moviescript,track,updateType)
	if(not self.canEditCamera or not parent or not moviescript)then return; end
	self.cameraParent = parent;
	self.cameraTrack = track;
	self.cameraUpdateType = updateType;
	if(not self.moviescript)then
		self.moviescript = moviescript;
	end
	
	Map3DSystem.Movie.CameraTrackRecorder.SetTracksEditor(parent,moviescript,self,track,updateType);	
end
-- param@ parent: it's value maybe is nil
-- param@ eventClass:it's value maybe is nil, <pe:movie-event text="111" id="1" type="1" starttime="0" endtime="30"  isLooping="false" >
function TracksEditor:SetEditEvent(parent,moviescript,eventClass,updateType)
	if(not self.canEditEvent or not moviescript)then return; end
	self.eventParent = parent;
	if(not self.moviescript)then
		self.moviescript = moviescript;
	end
	Map3DSystem.Movie.EventTrackRecorder.SetTracksEditor(parent,moviescript,self,eventClass,updateType);	
end

function TracksEditor:SetEditSound(parent,moviescript)
	if(not self.canEditSound or not parent or not moviescript)then return; end
	self.soundParent = parent;
	if(not self.moviescript)then
		self.moviescript = moviescript;
	end
	Map3DSystem.Movie.SoundTrackRecorder.SetTracksEditor(parent,moviescript,self);	
end
function TracksEditor:SetEditCaption(parent,moviescript)
	if(not self.canEditCaption or not parent or not moviescript)then return; end
	self.captionParent = parent;
	if(not self.moviescript)then
		self.moviescript = moviescript;
	end
	Map3DSystem.Movie.CaptionTrackRecorder.SetTracksEditor(parent,moviescript,self);	
end
function TracksEditor:GetStoryBoardKeyFrames()
	local frames = "";
	if(self.controlState == "record")then
		frames = frames .. self:GetKeyFrames_inherent().."\r\n";
	else
		frames = frames .. self:GetKeyFrames_pure().."\r\n";
	end
	local result =string.format([[
<pe:storyboards xmlns:pe="www.paraengine.com/pe">
<pe:storyboard>
%s
</pe:storyboard>
</pe:storyboards>
	]]
	,frames);
	return result;
end
function TracksEditor:GetKeyFrames_pure()
	local result = "";
	if(self.canEditCamera)then
		local v = Map3DSystem.Movie.CameraTrackRecorder.GetKeyFrames_pure();
		if(v)then
			result = result ..v.."\r\n";
		end
	end
	if(self.canEditSound)then
		local v = Map3DSystem.Movie.SoundTrackRecorder.GetKeyFrames_pure();
		if(v)then
			result = result ..v.."\r\n";
		end
	end
	if(self.canEditEvent)then
		local v = Map3DSystem.Movie.EventTrackRecorder.GetKeyFrames_pure();
		if(v)then
			result = result ..v.."\r\n";
		end
	end
	if(self.canEditCaption)then
		local v = Map3DSystem.Movie.CaptionTrackRecorder.GetKeyFrames_pure();
		if(v)then
			result = result ..v.."\r\n";
		end
	end
	return result;
end
function TracksEditor:GetKeyFrames_inherent()
	local result = "";
	local firstTime = "00:00:00";
	local lastTime = self:GetTotalTime();
	result = string.format([[
	 <pe:stringAnimationUsingKeyFrames TargetName="__object_editor__" TargetProperty="text">
          <pe:discreteStringKeyFrame KeyTime="%s" Value="" />
          <pe:discreteStringKeyFrame KeyTime="%s" Value="" />
        </pe:stringAnimationUsingKeyFrames>
        ]]
        ,firstTime,lastTime)
    result = result .."\r\n";
    return result;
end
function TracksEditor:FindPrimitive()
	if(not self.lastCharacterName)then return; end
	local obj = ParaScene.GetCharacter(self.lastCharacterName);
	if(obj:IsValid()) then
		obj:ToCharacter():SetFocus();
	end
end
function TracksEditor:OnClickCloseRecorder()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", 
	{
	name=self.frameName,
	app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
	bShow = false,
	bDestroy = true,
	});
	
	self:Destroy();
end
function TracksEditor:Destroy()
	if(self.preLoader)then
		self.preLoader:PlayerDestroy();
	end	
	self:FindPrimitive();
end

function TracksEditor.OnAddSound(sControlName)
	local self =  CommonCtrl.GetControl(sControlName)
	if(not self or not self.canEditSound)then return; end
	Map3DSystem.Movie.SoundTrackRecorder.AddSound();
end
function TracksEditor.OnAddEvent(sControlName)
	local self =  CommonCtrl.GetControl(sControlName)
	if(not self or not self.canEditEvent)then return; end
	Map3DSystem.Movie.EventTrackRecorder.AddEvent();
end
-----------------------------------------------------
-- CameraTrackRecorder
-----------------------------------------------------
local CameraTrackRecorder = {
	lookAtPos_value = "",
	eyePos_value = "",
	tracksEditor = nil,
	enabled = false,
	firstTime = "00:00:00",
	lastTime = "00:00:00",
	parent = nil,
	moviescript = nil,
}
commonlib.setfield("Map3DSystem.Movie.CameraTrackRecorder", CameraTrackRecorder)
function CameraTrackRecorder.Clear()
	local self = CameraTrackRecorder;
	self.lookAtPos_value = "";
	self.eyePos_value = "";
	self.tracksEditor = nil;
	self.enabled = false;
	self.firstTime = "00:00:00";
	self.lastTime = "00:00:00";
	self.parent = nil;
	self.moviescript = nil;
	self.trackMcmlNode = nil;
	self.updateType = nil;
end
-- parent is <pe:movie-camera text="from Door to window" id="1" starttime="0" endtime="30"  isLooping="false" >
-- track is  <pe:movie-camera-track id="11" text="">
-- updateType is "new" or "update"
function CameraTrackRecorder.SetTracksEditor(parent,moviescript,tracksEditor,track,updateType)
	if(not parent or not moviescript or not tracksEditor or not track)then return; end
	local self = CameraTrackRecorder;
	self.tracksEditor = tracksEditor;
	self.parent = parent;
	self.moviescript = moviescript;
	self.lastTime = tracksEditor:GetTotalTime();
	self.trackMcmlNode = track;
	self.updateType = updateType;
end
function CameraTrackRecorder.UpdateTrackMcmlNode()
	local self = CameraTrackRecorder;
	if(not self.parent or not self.moviescript or not self.trackMcmlNode)then return; end
	if(self.updateType=="new")then
		self.moviescript:AddCameraTrack(self.trackMcmlNode);
		self.moviescript:AddCamera(self.parent);
	end
	local frames = self.GetKeyFrames()
	local frames = ParaXML.LuaXML_ParseString(frames);
	if(frames)then
		local len = self.trackMcmlNode:GetChildCount();
		if(len>0)then
			self.trackMcmlNode:ClearAllChildren();
		end	
		
		frames = Map3DSystem.mcml.buildclass(frames);
		local node;
		for __,node in ipairs(frames) do
			self.trackMcmlNode:AddChild(node);	
		end
	end	
end
function CameraTrackRecorder.UpdateTime(tracksEditor,frame)
	local self = CameraTrackRecorder;	
	if(not self.enabled)then return; end
	local px,py,pz = ParaCamera.GetLookAtPos()
	
	px = string.format("%.2f",px);
	py = string.format("%.2f",py);
	pz = string.format("%.2f",pz);
	self.lookAtPos_value = self.lookAtPos_value..string.format("%s %s %s,",px,py,pz);
	
	px,py,pz = ParaCamera.GetEyePos()
	px = string.format("%.2f",px);
	py = string.format("%.2f",py);
	pz = string.format("%.2f",pz);
	self.eyePos_value = self.eyePos_value..string.format("%s %s %s,",px,py,pz);
	
end
function CameraTrackRecorder.DoEnd(frame)
	local self = CameraTrackRecorder;
	local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);	
	self.lastTime = time;
end
function CameraTrackRecorder.Enabled()
	local self = CameraTrackRecorder;
	if(self.enabled == false)then
		self.enabled = true;
	end
end
function CameraTrackRecorder.DisEnabled()
	local self = CameraTrackRecorder;
	if(self.enabled == true)then
		self.enabled = false;
	end
end
function CameraTrackRecorder.GetKeyFrames()
	local self = CameraTrackRecorder;
	local result = "";
	if(not self.tracksEditor)then return result end;
	local firstTime = self.firstTime;
	local lookAtPos_value = self.lookAtPos_value;
	local lastTime = self.lastTime;
	local ParaCamera_SetLookAtPos = string.format([[
	 <pe:point3DAnimationUsingPath TargetName="object_editor" TargetProperty="ParaCamera_SetLookAtPos">
          <pe:discretePoint3DUsingPath KeyTime="%s" Value="%s" />
          <pe:discretePoint3DUsingPath KeyTime="%s" Value="" />
        </pe:point3DAnimationUsingPath>
        ]]
        ,firstTime,lookAtPos_value,lastTime)
    result = result .. ParaCamera_SetLookAtPos.."\r\n";
    
    local eyePos_value = self.eyePos_value;
	local ParaCamera_SetEyePos = string.format([[
	 <pe:point3DAnimationUsingPath TargetName="object_editor" TargetProperty="ParaCamera_SetEyePos">
          <pe:discretePoint3DUsingPath KeyTime="%s" Value="%s" />
          <pe:discretePoint3DUsingPath KeyTime="%s" Value="" />
        </pe:point3DAnimationUsingPath>
        ]]
        ,firstTime,eyePos_value,lastTime)
    result = result .. ParaCamera_SetEyePos
    return result;
end
function CameraTrackRecorder.GetKeyFrames_pure()
	local self = CameraTrackRecorder;
	return self.GetKeyFrames()
end

-----------------------------------------------------
-- SoundTrackRecorder
-----------------------------------------------------
local SoundTrackRecorder = {

}
local SoundTrackRecorder = {
	soundPool = {},
	tracksEditor = nil,
	enabled = false,
	moviescript = nil,
	parent = nil,
}
commonlib.setfield("Map3DSystem.Movie.SoundTrackRecorder", SoundTrackRecorder)
function SoundTrackRecorder.Clear()
	local self = SoundTrackRecorder;
	self.soundPool ={};
	self.tracksEditor = nil;
	self.enabled = false;
	self.moviescript = nil;
	self.parent = nil;
	self.updateType = nil;
end
-- parent is  <pe:movie-camera-shot id ="1" enabled="true">
function SoundTrackRecorder.SetTracksEditor(parent,moviescript,tracksEditor,updateType)
	if(not parent or not moviescript or not tracksEditor)then return; end
	local self = SoundTrackRecorder;
	self.tracksEditor = tracksEditor;
	self.parent = parent;
	self.moviescript = moviescript;
	self.updateType = updateType;
end
function SoundTrackRecorder.AddSound()
	local self = SoundTrackRecorder;
	if(not self.enabled or not self.moviescript or not self.parent or not self.tracksEditor)then return; end
	local soundClass = self.moviescript:NewSound();
	local __,__,track = self.moviescript:CreateSound(self.parent,soundClass)
	local time = self.tracksEditor:GetCurRecorderTime();
	table.insert(self.soundPool,{soundClass = soundClass,track = track,time = time,src = ""})
end
function SoundTrackRecorder.UpdateTrackMcmlNode()
	local self = SoundTrackRecorder;
	if(not self.moviescript)then return; end
	local k,value;
	for k,value in ipairs(self.soundPool) do
		local soundClass = value["soundClass"];
		local track = value["track"];
		if(soundClass and track)then
			local frames = self.GetKeyFrames(value)
			local frames = ParaXML.LuaXML_ParseString(frames);
			if(frames)then
				local len = track:GetChildCount();
				if(len>0)then
					track:ClearAllChildren();
				end	
				frames = Map3DSystem.mcml.buildclass(frames);
				frames = frames[1];
				track:AddChild(frames);	
				
				self.moviescript:AddSoundTrack(track)
				self.moviescript:AddSound(soundClass)
			end	
		end
	end
end
function SoundTrackRecorder.GetKeyFrames(value)
	if(not value)then return; end
	local self = SoundTrackRecorder;
	local result = "";
	local time = value["time"];
	local src = value["src"];
	local s = string.format([[<pe:discreteStringKeyFrame KeyTime="%s" Value="%s" />]],time,src);
	result = result..s;
	local f = string.format([[<pe:stringAnimationUsingKeyFrames TargetName="object_editor" TargetProperty="sound">%s</pe:stringAnimationUsingKeyFrames>]],result);
    return f;
end
function SoundTrackRecorder.GetKeyFrames_pure()
	local self = SoundTrackRecorder;
	if(not self.moviescript)then return; end
	local k,value;
	local result = "";
	for k,value in ipairs(self.soundPool) do
		local soundClass = value["soundClass"];
		local track = value["track"];
		if(soundClass and track)then
			local frames = self.GetKeyFrames(value)
			result =  result .. frames .."\r\n";
		end
	end
	return result;
end
function SoundTrackRecorder.Enabled()
	local self = SoundTrackRecorder;
	if(self.enabled == false)then
		self.enabled = true;
	end
end
function SoundTrackRecorder.DisEnabled()
	local self = SoundTrackRecorder;
	if(self.enabled == true)then
		self.enabled = false;
	end
end
-----------------------------------------------------
-- EventTrackRecorder
-----------------------------------------------------
local EventTrackRecorder = {
	actorsPool = {},
	eventClass = nil,
	tracksEditor = nil,
	enabled = false,
	moviescript = nil,
	parent = nil,
}
commonlib.setfield("Map3DSystem.Movie.EventTrackRecorder", EventTrackRecorder)
function EventTrackRecorder.Clear()
	local self = EventTrackRecorder;
	self.actorsPool ={};
	self.eventClass = nil;
	self.tracksEditor = nil;
	self.enabled = false;
	self.moviescript = nil;
	self.parent = nil;
	self.updateType = nil;
	self.SetHook(self.enabled)
end
-- parent is  <pe:movie-camera-shot id ="1" enabled="true">
function EventTrackRecorder.SetTracksEditor(parent,moviescript,tracksEditor,eventClass,updateType)
	if(not moviescript or not tracksEditor)then return; end
	local self = EventTrackRecorder;
	self.tracksEditor = tracksEditor;
	self.parent = parent;
	self.moviescript = moviescript;
	self.eventClass = eventClass;
	self.updateType = updateType;
end
function EventTrackRecorder.SetHook(bool)
	if(bool == true)then
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = EventTrackRecorder.Hook_SceneObject, 
		hookName = "EventTrackRecorder_Hook", appName = "scene", wndName = "object"});
	else
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "EventTrackRecorder_Hook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
	end
end
function EventTrackRecorder.Hook_SceneObject(nCode, appName, msg)
	local self = EventTrackRecorder;
	local obj_params = msg.obj_params;
	if(msg.type == Map3DSystem.msg.OBJ_ModifyObject) then
	elseif(msg.type == Map3DSystem.msg.OBJ_CreateObject) then
		self.AddEvent(obj_params)
	elseif(msg.type == Map3DSystem.msg.OBJ_DeleteObject) then
		
	end
	return nCode
end
-- EventTrackRecorder can only create one event,if a event is created at first time then will auto create a new actor as soon as
function EventTrackRecorder.AddEvent(obj_params)
	if(not obj_params)then return; end
	local self = EventTrackRecorder;
	if(not self.enabled or not self.moviescript or not self.tracksEditor)then return; end
	local keyTime = self.tracksEditor:GetCurRecorderTime();
	local new_actor;
	if(not self.eventClass)then
		self.eventClass = self.moviescript:NewEvent();
		local __,__,__actor = self.moviescript:CreateEvent(self.parent,self.eventClass)
		new_actor = __actor;
		new_actor:SetActorname(obj_params.name);
	else
		local actor = self.moviescript:NewActor();
		if(actor and actor.movieActor)then
			self.eventClass:AddChild(actor.movieActor);
			new_actor = actor;
			new_actor:SetActorname(obj_params.name);
		end
		
	end
	if(new_actor)then 
		table.insert(self.actorsPool,{actor = new_actor,keyTime = keyTime,obj_params = obj_params,type = "actionEntry"})
	end
	
end
function EventTrackRecorder.UpdateTrackMcmlNode()
	local self = EventTrackRecorder;
	if(not self.moviescript or not self.eventClass)then return; end
	local k,value;
	for k,value in ipairs(self.actorsPool) do
		local actor,keyTime,obj_params,type =value["actor"],value["keyTime"],value["obj_params"],value["type"]
		if(actor and keyTime and obj_params)then
			if(type == "actionEntry")then
				local frame = actor:AddActionEntryFrame(keyTime,obj_params,true)
				actor:PushActionEntryTrack(frame)
			end
		end
	end
	if(self.updateType == "new")then
		self.moviescript:AddEvent(self.eventClass);
	end
end
function EventTrackRecorder.GetKeyFrames_pure()
	local self = EventTrackRecorder;
	if(not self.moviescript)then return; end
	local k,value;
	local actionEntry_frames = "";
	for k,value in ipairs(self.actorsPool) do
		local actor,keyTime,obj_params,type =value["actor"],value["keyTime"],value["obj_params"],value["type"]
		if(actor and keyTime and obj_params)then
			if(type == "actionEntry")then
				local frame = actor:GetActionEntryFrame_pure(keyTime,obj_params)
				actionEntry_frames = actionEntry_frames .. frame.."\r\n";
			end		
		end
	end
	
	local allFrames = "";
	local result = string.format([[<pe:objectAnimationUsingKeyFrames TargetName="object_editor" TargetProperty="CreateMeshPhysicsObject">%s</pe:objectAnimationUsingKeyFrames>]],actionEntry_frames);
	allFrames = allFrames .. result .. "\r\n";
	return allFrames;
end
function EventTrackRecorder.ClearTempValues()
	local self = EventTrackRecorder;
	local k,value;
	for k,value in ipairs(self.actorsPool) do
		local obj_params = value["obj_params"];
		if(obj_params)then
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=obj_params});
		end
	end
end
function EventTrackRecorder.Enabled()
	local self = EventTrackRecorder;
	if(self.enabled == false)then
		self.enabled = true;	
		self.SetHook(self.enabled)
	end
end
function EventTrackRecorder.DisEnabled()
	local self = EventTrackRecorder;
	if(self.enabled == true)then
		self.enabled = false;
		self.SetHook(self.enabled)
	end
end
-----------------------------------------------------
-- CaptionTrackRecorder
-----------------------------------------------------
local CaptionTrackRecorder = {
	tracksEditor = nil,
	enabled = false,
	parent = nil,
	moviescript = nil,
	txtKeyFrames = nil,
	curKeyFrame = nil,
	CaptionTracksEditorPage = nil,
}
commonlib.setfield("Map3DSystem.Movie.CaptionTrackRecorder", CaptionTrackRecorder)
function CaptionTrackRecorder.Clear()
	local self = CaptionTrackRecorder;
	self.tracksEditor = nil;
	self.enabled = false;
	self.parent = nil;
	self.moviescript = nil;
	self.trackMcmlNode = nil;
	self.txtKeyFrames = nil;
	self.curKeyFrame = nil;
	self.CaptionTracksEditorPage = nil;
	self.CloseWindow(true)
end
-- parent is  <pe:movie-clip id ="1" text="clip name: 00" desc="clip description:00" captionid="" musicid="">
function CaptionTrackRecorder.SetTracksEditor(parent,moviescript,tracksEditor)
	if(not parent or not moviescript or not tracksEditor)then return; end
	local self = CaptionTrackRecorder;
	self.tracksEditor = tracksEditor;
	self.parent = parent;
	self.moviescript = moviescript;
end
function CaptionTrackRecorder.OpenWindow()
	local self = CaptionTrackRecorder;
	if(not self.enabled)then return; end
	if(not self.CaptionTracksEditorPage)then
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/Movie/CaptionTracksEditorPage.html", name="CaptionTracksEditorPage", 
				app_key=MyCompany.Apps.VideoRecorder.app.app_key,
				text = "编辑字幕",
				isShowTitleBar = true, 
				isShowToolboxBar = false, 
				isShowStatusBar = false, 
				isShowMinimizeBox = false,
				isShowCloseBox = false,
				allowResize = false,
				initialPosX =  screenWidth-500,
				initialPosY = 200,
				initialWidth = 500,
				initialHeight = 360,
				DestroyOnClose = true,
			});
		self.CaptionTracksEditorPage = true;
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/Movie/CaptionTracksEditorPage.html", name="CaptionTracksEditorPage", 
				app_key=MyCompany.Apps.VideoRecorder.app.app_key,
				bShow = true,
				});
	end
	Map3DSystem.Movie.CaptionTracksEditorPage.DataBind(self)
end
function CaptionTrackRecorder.CloseWindow(bDestroy)
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/Movie/CaptionTracksEditorPage.html", name="CaptionTracksEditorPage", 
				app_key=MyCompany.Apps.VideoRecorder.app.app_key,
				bShow = false,
				bDestroy = bDestroy,
				});
end
function CaptionTrackRecorder.UpdateTime(tracksEditor,frame)
	local self = CaptionTrackRecorder;	
	if(not self.enabled)then return; end
	self.curKeyFrame = frame;
	Map3DSystem.Movie.CaptionTracksEditorPage.SetKeyFrame(frame)
end
--function CaptionTrackRecorder.AddText(txt,keyTime)
	--local self = CaptionTrackRecorder;
	--if(not self.enabled or not self.moviescript or not self.parent or not self.tracksEditor)then return; end
	--if(not keyTime)then
		--keyTime = self.tracksEditor:GetCurRecorderTime();
	--end
	----txt = "字幕测试:"..keyTime;	
	--table.insert(self.txtPool,{txt = txt,keyTime = keyTime})
--end
function CaptionTrackRecorder.UpdateTrackMcmlNode()
	local self = CaptionTrackRecorder;
	if(not self.parent or not self.moviescript)then return; end
	self.trackMcmlNode = self.moviescript:NewCaptionTrack();
	self.moviescript:AddCaptionTrack(self.trackMcmlNode);
	local id = self.trackMcmlNode:GetString("id");
	self.parent:SetAttribute("captionid",id);
	
	local frames = self.GetKeyFrames_pure()
	frames = ParaMisc.EncodingConvert("", "utf-8", frames);
	local frames = ParaXML.LuaXML_ParseString(frames);
	if(frames)then
		local len = self.trackMcmlNode:GetChildCount();
		if(len>0)then
			self.trackMcmlNode:ClearAllChildren();
		end	
		frames = Map3DSystem.mcml.buildclass(frames);
		frames = frames[1];
		self.trackMcmlNode:AddChild(frames);	
	end	
end
function CaptionTrackRecorder.Enabled()
	local self = CaptionTrackRecorder;
	if(self.enabled == false)then
		self.enabled = true;
	end
end
function CaptionTrackRecorder.DisEnabled()
	local self = CaptionTrackRecorder;
	if(self.enabled == true)then
		self.enabled = false;
	end
end
--function CaptionTrackRecorder.GetKeyFrames(value)
	--if(not value)then return; end
	--local self = CaptionTrackRecorder;
	--local time = value["keyTime"];
	--local txt = value["txt"];
	--if(not time)then return "" end;
	--local s = string.format([[<pe:discreteStringKeyFrame KeyTime="%s" Value="%s" />]],time,txt);
    --return s;
--end
function CaptionTrackRecorder.GetKeyFrames_pure()
	local self = CaptionTrackRecorder;
	local s = "";
	if(not self.txtKeyFrames)then return s; end
	s = self.txtKeyFrames:ReverseToMcml();
	return s;
end
function CaptionTrackRecorder.Enabled()
	local self = CaptionTrackRecorder;
	if(self.enabled == false)then
		self.enabled = true;
	end
end
function CaptionTrackRecorder.DisEnabled()
	local self = CaptionTrackRecorder;
	if(self.enabled == true)then
		self.enabled = false;
	end
end