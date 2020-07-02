--[[
Title: Control for recording and playing actor sequence.
Only one instance of this class can be present in the scene.
Author(s): LiXizhi
Date: 2005/10
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/movie/ActorMovieCtrl.lua");
local ctl = CommonCtrl.ActorMovieCtrl:new{
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 200,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "ActorMovieCtrl1",
}
ctl:Show();
-------------------------------------------------------
]]
-- required by the movie dialog UI
NPL.load("(gl)script/movie/movielib.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/common_control.lua");

local L = CommonCtrl.Locale("IDE");
--[[ movie UI event handlers
UI control lists: 
- "record_pause": Button: Pause the actor
- "record_record": Button: begin recording the actor
- "record_stop": Button: stop recording, same as "record_pause".
- "record_play": Button: Play the recorded movie from the specified time.
- "record_save": Button: save the current recorded character to disk.
- "record_load": Button: load movie for the character.
- "record_timeInput": EditBox: the time of the recorded movie to be set
- "record_setTime": Button: Set time as the one in the "record_timeInput" window.
- "record_dialoginput": IMEBox: dialog input for a given movie
- "record_adddialog": Button: add dialog to the movie
]]

ActorMovieCtrl = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 200,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "ActorMovieCtrl",
	recordbuttons = {"record_pause", "record_record", "record_play", "record_stop"},
	MaxSliderRange = 100,--100 seconds by default
};

CommonCtrl.ActorMovieCtrl = ActorMovieCtrl;

-- constructor
function ActorMovieCtrl:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function ActorMovieCtrl:Destroy()
	ParaUI.Destroy(self.name);
end

-- return the actor, or nil if it is invalid or does not exist.
function ActorMovieCtrl.GetCurrentActor()
	local player = ObjEditor.GetCurrentObj();
	if(player==nil or player:IsCharacter() == false) then
		return nil;
	end
	return player;
end

-- update the UI
function ActorMovieCtrl:Update()
	-- update recording time
	temp = ParaUI.GetUIObject("record_time");
	if(temp:IsValid()==true) then 
		local sTime;
		local player = ObjEditor.GetCurrentObj();
		if(player ~= nil)then 
			sTime = player:ToCharacter():GetMovieController():GetTime("%H:%M:%S"); 
			if(sTime ~= temp.text) then
				temp.text=sTime;
			end
		end
	end
end

function ActorMovieCtrl:Show()
	local _this,_parent
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		
		_this.background="Texture/whitedot.png;0 0 0 0";
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		_parent=_this;
		
		local left, top, width, height = 0,0, 80, 22;
		_this=ParaUI.CreateUIObject("text","text1", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Current Time";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("text","record_time", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text="00:00:00";
		left = left+width;
		
		width = 200;
		_this=ParaUI.CreateUIObject("slider","record_time_slider","_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/middle/sky/slider_bg.png";
		_this.button="Texture/kidui/middle/sky/slider_btn.png";
		_this.value = 0;--[0,100]
		_this.onchange=";ActorMovieCtrl.OnTimerSliderChange();";
		left = left+width;
		
		width = 50;
		_this=ParaUI.CreateUIObject("editbox","record_timeInput", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text = "0";
		_this.background="Texture/box.png;";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","record_setTime", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Goto";
		_this.tooltip=L"Unit(s)";
		_this.onclick=";ActorMovieCtrl.record_setTime();";
		
		-- second row
		left = 0;
		top = top + height+3;
		width, height =30,30;
		_this=ParaUI.CreateUIObject("button","record_pause", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/pause.png;";
		_this.onclick=";ActorMovieCtrl.record_pause();";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","record_play", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/play.png;";
		_this.onclick=";ActorMovieCtrl.record_play();";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","record_stop", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/stop.png;";
		_this.onclick=";ActorMovieCtrl.record_stop();";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","record_record", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/rec.png;";
		_this.onclick=";ActorMovieCtrl.record_record();";
		left = left+width+30;
		
		width=60;
		_this=ParaUI.CreateUIObject("button","record_save", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"save";
		_this.onclick=";ActorMovieCtrl.record_save();";
		left = left+width+3;
		
		_this=ParaUI.CreateUIObject("button","record_load", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"load";
		_this.onclick=";ActorMovieCtrl.record_load();";
		
		-- third row
		left = 0;
		top = top + height+3;
		
		width, height = 40, 30;
		_this=ParaUI.CreateUIObject("text","text1", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"add";
		left = left+width+3;
		
		width, height = 210, 30;
		_this=ParaUI.CreateUIObject("imeeditbox","record_dialoginput", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text="";
		_this.background="Texture/player/filenamebox.png;";
		left = left+width+3;
		
		width = 60;
		_this=ParaUI.CreateUIObject("button","record_adddialog", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"dialog";
		_this.onclick=";ActorMovieCtrl.record_adddialog();";
		left = left+width+3;
		
		_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"action";
		_this.onclick="(gl)script/demo/film/add_action.lua";
		left = left+width+3;
		
		--[[ this function is disabled for the current release. 2006/12/6 by LiXizhi
		_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"effect";
		_this.onclick="(gl)script/demo/film/add_spell.lua";
		left = left+width+3;]]
		
		_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"loop";
		_this.onclick=";ActorMovieCtrl.record_addloopkey();";
	end
end

function ActorMovieCtrl.OnTimerSliderChange()
	-- update the go to time
	temp = ParaUI.GetUIObject("record_time_slider");
	if(temp:IsValid()==true) then 
		local nTime = temp.value/100*ActorMovieCtrl.MaxSliderRange;
		temp = ParaUI.GetUIObject("record_timeInput");
		if(temp:IsValid()==true) then 
			temp.text = string.format("%d", nTime);
		end
	end
end

function ActorMovieCtrl.record_pause()
	_movie.pause();
	_guihelper.CheckRadioButtons( ActorMovieCtrl.recordbuttons, "record_pause", "255 0 0");
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player:IsValid() == true)then
		player:ToCharacter():GetMovieController():Suspend();
	end
end

function ActorMovieCtrl.record_stop()
	_movie.SetMovieTime(0);
	_movie.pause();
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then
		player:ToCharacter():GetMovieController():SetTime(0);
		player:ToCharacter():GetMovieController():Suspend();
		
		_guihelper.CheckRadioButtons( ActorMovieCtrl.recordbuttons, "record_stop", "255 0 0");
	end
end

function ActorMovieCtrl.record_record()
	_movie.play();
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then
		player:ToCharacter():GetMovieController():Record();
		player:ToCharacter():GetMovieController():Resume();
		
		_guihelper.CheckRadioButtons( ActorMovieCtrl.recordbuttons, "record_record", "255 0 0");
		
		if(not _movie.actors[player.name]) then
			-- automatically add the actor to the current movie once it is being recorded.
			_movie.NewActor(player.name);
		end
	end
end
function ActorMovieCtrl.record_addloopkey()
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then
		if(player:ToCharacter():GetMovieController():RecordNewAction("_loopkey", 0) == true) then
			_guihelper.MessageBox(L"loop frame has been inserted.To remove looping, just start record before the loop frame.");
		end
		-- pause the recorder
		ActorMovieCtrl.record_pause();
	end
end
function ActorMovieCtrl.record_play()
	_movie.play();
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then
		player:ToCharacter():GetMovieController():Play();
		player:ToCharacter():GetMovieController():Resume();
		
		_guihelper.CheckRadioButtons( ActorMovieCtrl.recordbuttons, "record_play", "255 0 0");
	end
end
function ActorMovieCtrl.record_setTime()
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then
		local record_time;
		local temp = ParaUI.GetUIObject("record_timeInput");
		if(temp:IsValid()==true) then record_time = tonumber(temp.text); end
		if(record_time==nil) then 
			_guihelper.MessageBox(L"input must be numbers (in seconds)");
			record_time=0; 
			return;
		end
		_movie.SetMovieTime(record_time);
		_movie.pause();
		player:ToCharacter():GetMovieController():SetTime(record_time);
		
		-- pause the recorder
		ActorMovieCtrl.record_pause();
	end
end
function ActorMovieCtrl.record_save()
	-- pause the recorder
	ActorMovieCtrl.record_pause();
		
	-- extract the file.
	local actorName, actorMovieFile;
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then 
		actorName = player:GetName(); 
		local temp = ParaUI.GetUIObject("actorMovieFile");
		if(temp:IsValid()==true) then actorMovieFile = temp.text; end
		if(actorName~=nil) then
			-- If actorMovieFile is nil, it will be "[WorldDirectory]/movie/actor/%actorName%.rec.txt"
			if(actorMovieFile==nil or actorMovieFile=="") then 
				actorMovieFile = ParaWorld.GetWorldDirectory().."movie/actor/"..actorName..".rec.txt";
			end
			player:ToCharacter():GetMovieController():SaveMovie(actorMovieFile);
			_movie.CreateActorScript(actorName,actorMovieFile, nil);
			_guihelper.MessageBox(L"actor movie file has been saved to: \n"..actorMovieFile); 
		end
	end
end
function ActorMovieCtrl.record_load()
	-- stop the recorder
	ActorMovieCtrl.record_stop();
	
	-- extract the file.
	local actorName, actorMovieFile;
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then 
		actorName = player:GetName(); 
		local temp = ParaUI.GetUIObject("actorMovieFile");
		if(temp:IsValid()==true) then actorMovieFile = temp.text; end
		if(actorName~=nil) then
			-- If actorMovieFile is nil, it will be "[WorldDirectory]/movie/actor/%actorName%.rec.txt"
			if(actorMovieFile==nil or actorMovieFile=="") then 
				actorMovieFile = ParaWorld.GetWorldDirectory().."movie/actor/"..actorName..".rec.txt";
			end
			player:ToCharacter():GetMovieController():LoadMovie(actorMovieFile);
			_guihelper.MessageBox(L"actor movie file has been loaded: \n"..actorMovieFile); 
		end
	end
end

function ActorMovieCtrl.record_adddialog()
	local player = ActorMovieCtrl.GetCurrentActor();
	if(player ~= nil)then
		-- pause the recorder
		local temp = ParaUI.GetUIObject("record_dialoginput");
		if(temp:IsValid()==true) then 
			local sDialogText = temp.text;
			headon_speech.Speek(player.name, sDialogText, 4);
			player:ToCharacter():GetMovieController():RecordNewDialog(sDialogText); 
		end
	end
end
