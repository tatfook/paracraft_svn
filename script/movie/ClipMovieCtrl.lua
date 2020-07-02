--[[
Title: control for managing actors in a clip. 
Only one instance of this class can be present in the scene.
Author(s): LiXizhi
Date: 2005/10
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/movie/ClipMovieCtrl.lua");
local ctl = CommonCtrl.ClipMovieCtrl:new{
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 200,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "ClipMovieCtrl1",
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
- "movie_loadmovie": Button: load a new movie from a file. it is actually a file that loads all actors to the movie
- "movie_filename": EditBox: movie file name it is actually a file that loads all actors to the movie
- "movie_name": EditBox: name of the movie
- "movie_actorCount": Text: number of actors in the movie
- "movie_time": Text: current play time of the movie
- "movie_play": Button: Play the movie
- "movie_pause": Button: pause the movie
- "movie_stop": Button: Stop the movie. 
- "movie_toStart": Button: Set movie time to the beginning. 
- "movie_toEnd": Button: Set movie time to the ending. 
- "movie_timeInput": EditBox: the time of the movie to be set
- "movie_setTime": Button: Set time as the one in the "movie_timeInput" window.
- "actor_list_text": text: a text box inside a container containing all actors in the current movie.
]]

ClipMovieCtrl = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 200,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "ClipMovieCtrl",
	movieplaybuttons = {"movie_pause", "movie_stop", "movie_play"},
	MaxSliderRange = 100,--100 seconds by default
};

CommonCtrl.ClipMovieCtrl = ClipMovieCtrl;

-- constructor
function ClipMovieCtrl:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function ClipMovieCtrl:Destroy()
	ParaUI.Destroy(self.name);
end

--[[ update the timer UI only 
@param nSelection: nil or 0, if nil, it will update everything. otherwise it only update the timer.
]]
function ClipMovieCtrl:Update(nSelection)
	-- update recording time
	temp = ParaUI.GetUIObject("movie_time");
	if(temp:IsValid()==true) then 
		local sTime;
		local player = _movie.GetFirstActor();
		if(player ~= nil)then 
			sTime = player:ToCharacter():GetMovieController():GetTime("%H:%M:%S"); 
			if(sTime ~= temp.text) then
				temp.text=sTime;
			end
		end
	end
	
	if(not nSelection) then
		ClipMovieCtrl.UpdateActorListUI();
	end
end

-- show and create the control
function ClipMovieCtrl:Show()
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
		_this.text=L"clip name";
		left = left+width;
		
		-- TODO: replace this editbox with a drop down list box.
		width = 105;
		_this=ParaUI.CreateUIObject("imeeditbox","movie_name", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/box.png;";
		_this.text=_movie.name;
		
		left = left+width;
		width = 55;
		_this=ParaUI.CreateUIObject("button","movie_load", "_lt", left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"load";
		_this.onclick="(gl)script/empty.lua;ClipMovieCtrl.movie_loadmovie();";
		
		left = left+width;
		_this=ParaUI.CreateUIObject("button","btn1", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"save";
		_this.onclick=";ClipMovieCtrl.SaveMovieFile()";
		
		top = top + height+3;
		left = 0;
		width = 80;
		_this=ParaUI.CreateUIObject("text","text1", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"actors";
		
		left = left+width;
		width,height = 165, 85;
		_this=ParaUI.CreateUIObject("listbox","actor_list_text", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/outputbox.png;";
		_this.onselect=";ClipMovieCtrl.OnActorListSelect();";
		_this.ondoubleclick=";ClipMovieCtrl.OnGotoActor();";
		_this.scrollable=true;
		
		top = top + height+3;
		left = 0;
		height = 22;
		width = 80;
		_this=ParaUI.CreateUIObject("imeeditbox","movie_actor_name", "_lt",left, top,width, height);
		_this.background="Texture/kidui/main/bg_266X48.png";
		_parent:AddChild(_this);
		
		left = left+width;
		width = 70;
		_this=ParaUI.CreateUIObject("button","movie_add_actor", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"add";
		_this.onclick=";ClipMovieCtrl.AddActor()";
		
		left = left+width;
		_this=ParaUI.CreateUIObject("button","movie_remove_actor", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"remove";
		_this.onclick=";ClipMovieCtrl.RemoveActor()";
		
		left = left+width;
		_this=ParaUI.CreateUIObject("button","btn1", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"refresh";
		_this.onclick=";ClipMovieCtrl.UpdateActorListUI();";
		
		
		top = top + height+3;
		left = 0;
		width = 70;
		_this=ParaUI.CreateUIObject("text","movie_time", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text="00:00:00";
		left = left+width;
		
		width = 130;
		_this=ParaUI.CreateUIObject("slider","movie_time_slider","_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/kidui/middle/sky/slider_bg.png";
		_this.button="Texture/kidui/middle/sky/slider_btn.png";
		_this.value = 0;--[0,100]
		_this.onchange=";ClipMovieCtrl.OnTimerSliderChange();";
		left = left+width;
		
		width = 43;
		_this=ParaUI.CreateUIObject("editbox","movie_timeInput", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text = "0";
		_this.background="Texture/kidui/main/bg_266X48.png";
		left = left+width;
		
		width = 50;
		_this=ParaUI.CreateUIObject("button","movie_setTime", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Goto";
		_this.tooltip=L"Unit(s)";
		_this.onclick=";ClipMovieCtrl.movie_setTime();";
		
		-- second row
		left = 0;
		top = top + height+3;
		width, height =30,30;
		_this=ParaUI.CreateUIObject("button","movie_pause", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/pause.png;";
		_this.onclick=";ClipMovieCtrl.movie_pause();";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","movie_play", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/play.png;";
		_this.onclick=";ClipMovieCtrl.movie_play();";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","movie_stop", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/stop.png;";
		_this.onclick=";ClipMovieCtrl.movie_stop();";
		left = left+width;
		
		_this=ParaUI.CreateUIObject("button","movie_record", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.background="Texture/player/rec.png;";
		_this.onclick=";ClipMovieCtrl.movie_record();";
		left = left+width+30;
		
		self:Update();
	end
end

function ClipMovieCtrl.OnTimerSliderChange()
	-- update the go to time
	temp = ParaUI.GetUIObject("movie_time_slider");
	if(temp:IsValid()==true) then 
		local nTime = temp.value/100*ClipMovieCtrl.MaxSliderRange;
		temp = ParaUI.GetUIObject("movie_timeInput");
		if(temp:IsValid()==true) then 
			temp.text = string.format("%d", nTime);
		end
	end
end


--[[ update the actor list UI with the current actors in the movie.
this function is called when loading a new movie
]]
function ClipMovieCtrl.UpdateActorListUI()
	local __texture;
	local listbox = ParaUI.GetUIObject("actor_list_text");
	if(listbox:IsValid() == true) then
		
		-- refill the list box of objects
		listbox:RemoveAll();
		
		local key, actor;
		local NumOfActors=0;
		for key, actor in pairs(_movie.actors) do
			listbox:AddTextItem(tostring(key));
			NumOfActors = NumOfActors+1;
		end
		
		-- set number of actors
		local temp = ParaUI.GetUIObject("actor_list_count");
		if(temp:IsValid()==true) then 
			temp.text=tostring(NumOfActors);
		end
	end
end


-- add a new actor
function ClipMovieCtrl.AddActor()
	local tmp =ParaUI.GetUIObject("movie_actor_name");
	if(tmp:IsValid()==false) then
		return;
	end
	local actorname = tmp.text;
	if(actorname~="") then 
		_movie.NewActor(actorname);
		ClipMovieCtrl.UpdateActorListUI();
	end
end

-- Remove an actor from the movie list, but not from the scene.
function ClipMovieCtrl.RemoveActor()
	local tmp =ParaUI.GetUIObject("movie_actor_name");
	if(tmp:IsValid()==false) then
		return;
	end
	local actorname = tmp.text;
	if(actorname~="") then 
		-- remove from movie
		_movie.DeleteActor(actorname);
		-- update the UI
		ClipMovieCtrl.UpdateActorListUI();
	end
end

function ClipMovieCtrl.movie_play()
	_movie.play();
	_guihelper.CheckRadioButtons( ClipMovieCtrl.movieplaybuttons, "movie_play", "255 0 0");
end
function ClipMovieCtrl.movie_pause()
	_movie.pause();
	_guihelper.CheckRadioButtons( ClipMovieCtrl.movieplaybuttons, "movie_pause", "255 0 0");
end
function ClipMovieCtrl.movie_stop()
	_movie.SetMovieTime(0);
	_movie.pause();
	_guihelper.CheckRadioButtons( ClipMovieCtrl.movieplaybuttons, "movie_stop", "255 0 0");
end

function ClipMovieCtrl.movie_record()
	--TODO: record all? for network OPC?
	--just bring the recording interface.
	
	-- new interface
	NPL.load("(gl)script/ide/VideoRecorder.lua");
	VideoRecorder.Show();
	
	-- old interfacce
	--NPL.activate("(gl)script/demo/recorder/main.lua");
end

function ClipMovieCtrl.movie_setTime()
	local temp = ParaUI.GetUIObject("movie_timeInput");
	if(temp:IsValid()==true) then record_time = tonumber(temp.text); end
	if(record_time==nil) then 
		_guihelper.MessageBox(L"input must be numbers (in seconds)");
		record_time=0; 
		return;
	end
	_movie.SetMovieTime(record_time);
	
	-- pause the recorder
	ClipMovieCtrl.movie_pause();
end

function ClipMovieCtrl.movie_loadmovie()
	local temp = ParaUI.GetUIObject("movie_name");
	if(temp:IsValid()==true) then 
		local sMovieFile = temp.text;
		if(sMovieFile~=nil and sMovieFile ~= "") then
			sMovieFile = ParaWorld.GetWorldDirectory().."movie/"..sMovieFile..".lua";
			_movie.LoadMovieFile(sMovieFile);
			ClipMovieCtrl.UpdateActorListUI();
		end
	end
end

--save to file
function ClipMovieCtrl.SaveMovieFile() 
	local temp = ParaUI.GetUIObject("movie_name");
	if(temp:IsValid()==true) then 
		local moviename = temp.text;
		if(moviename == "") then
			return;
		end
		_movie.name = moviename;
		_movie.SaveMovieToFile();
	end	
end

function ClipMovieCtrl.OnActorListSelect()
	local temp = ParaUI.GetUIObject("actor_list_text");
	if(temp:IsValid()==true) then 
		local actorNameCtl = ParaUI.GetUIObject("movie_actor_name");
		if(actorNameCtl:IsValid()==true) then 
			actorNameCtl.text = temp.text;
		end
	end
end

function ClipMovieCtrl.OnGotoActor()
	local temp = ParaUI.GetUIObject("actor_list_text");
	if(temp:IsValid()==true) then 
		if(temp.text ~="") then
			local player = ParaScene.GetObject(temp.text);
			if((player:IsValid() == true) and (player:IsGlobal() ==true) and (player:IsCharacter() == true)) then
				ParaCamera.FollowObject(player);
			else
				_guihelper.MessageBox(temp.text..L" does not exist");
			end	
		end	
	end
end
