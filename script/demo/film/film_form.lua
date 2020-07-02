--[[
Title: event handlers for movie UI controls 
Author(s): Code: LiXizhi UI: LiYu
Date: 2005/10
]]
-- required by the movie dialog UI
NPL.load("(gl)script/movie/movielib.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- MovieUI library file.
--[[ movie UI event handlers
UI control lists: 
(defined in film_form.lua)
- "actorName": EditBox: name of the current selected actor
- "actorMovieFile": EditBox: actor movie file name
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
- "actorMovieFileText": Text: the content of actor Movie File

(defined in player_form.lua)
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

if(not MovieUI) then MovieUI = {}; end

MovieUI.recordbuttons = {"record_pause", "record_record", "record_play", "record_stop"};
function MovieUI.record_pause()
	_movie.pause();
	_guihelper.CheckRadioButtons( MovieUI.recordbuttons, "record_pause", "255 0 0");
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid() == true)then
		player:ToCharacter():GetMovieController():Suspend();
	end
end

function MovieUI.record_stop()
	_movie.SetMovieTime(0);
	_movie.pause();
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then
		player:ToCharacter():GetMovieController():SetTime(0);
		player:ToCharacter():GetMovieController():Suspend();
		
		_guihelper.CheckRadioButtons( MovieUI.recordbuttons, "record_stop", "255 0 0");
	end
end

function MovieUI.record_record()
	_movie.play();
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then
		player:ToCharacter():GetMovieController():Record();
		player:ToCharacter():GetMovieController():Resume();
		
		_guihelper.CheckRadioButtons( MovieUI.recordbuttons, "record_record", "255 0 0");
		
		if(not _movie.actors[player.name]) then
			-- automatically add the actor to the current movie once it is being recorded.
			_movie.NewActor(player.name);
		end
	end
end
function MovieUI.record_addloopkey()
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then
		if(player:ToCharacter():GetMovieController():RecordNewAction("_loopkey", 0) == true) then
			_guihelper.MessageBox("循环贞已被插入.如要删除循环,只需从前面的时刻开始录像.");
		end
		-- pause the recorder
		MovieUI.record_pause();
	end
end
function MovieUI.record_play()
	_movie.play();
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then
		player:ToCharacter():GetMovieController():Play();
		player:ToCharacter():GetMovieController():Resume();
		
		_guihelper.CheckRadioButtons( MovieUI.recordbuttons, "record_play", "255 0 0");
	end
end
function MovieUI.record_setTime()
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then
		local record_time;
		local temp = ParaUI.GetUIObject("record_timeInput");
		if(temp:IsValid()==true) then record_time = tonumber(temp.text); end
		if(record_time==nil) then record_time=0; end
		_movie.SetMovieTime(record_time);
		_movie.pause();
		player:ToCharacter():GetMovieController():SetTime(record_time);
		
		-- pause the recorder
		MovieUI.record_pause();
	end
end
function MovieUI.record_save()
	-- pause the recorder
	MovieUI.record_pause();
		
	-- extract the file.
	local actorName, actorMovieFile;
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then 
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
			_guihelper.MessageBox("角色电影文件存盘到: \n"..actorMovieFile); 
		end
	end
end
function MovieUI.record_load()
	-- stop the recorder
	MovieUI.record_stop();
	
	-- extract the file.
	local actorName, actorMovieFile;
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then 
		actorName = player:GetName(); 
		local temp = ParaUI.GetUIObject("actorMovieFile");
		if(temp:IsValid()==true) then actorMovieFile = temp.text; end
		if(actorName~=nil) then
			-- If actorMovieFile is nil, it will be "[WorldDirectory]/movie/actor/%actorName%.rec.txt"
			if(actorMovieFile==nil or actorMovieFile=="") then 
				actorMovieFile = ParaWorld.GetWorldDirectory().."movie/actor/"..actorName..".rec.txt";
			end
			player:ToCharacter():GetMovieController():LoadMovie(actorMovieFile);
			_guihelper.MessageBox("角色电影文件被载入: \n"..actorMovieFile); 
		end
	end
end

function MovieUI.record_adddialog()
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true)then
		-- pause the recorder
		local temp = ParaUI.GetUIObject("record_dialoginput");
		if(temp:IsValid()==true) then 
			local sDialogText = temp.text;
			headon_speech.Speek(player.name, sDialogText, 4);
			player:ToCharacter():GetMovieController():RecordNewDialog(sDialogText); 
		end
	end
end

local function activate()
	_guihelper.CheckRadioButtons( _demo_film_pages, "film_record", "255 0 0");
			
	local __this,__parent,__font,__texture;
	__this = ParaUI.GetUIObject("player_container");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end
	__this = ParaUI.GetUIObject("list_container");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end

	__this = ParaUI.GetUIObject("film_container");
	if(__this:IsValid() == true) then
		__this.visible=true;
	else
		__this=ParaUI.CreateUIObject("container","film_container", "_lt",30,60,299,390);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.scrollable=false;
		__this.background="Texture/item.png;";
		__this.candrag=false;
		texture=__this:GetTexture("background");
		texture.transparency=0;--[0-255]
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,25,100,22);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="角色名称：";
		__this.autosize=true;
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("imeeditbox","actorName", "_lt",105,20,105,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/box.png;";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("button","change_button", "_lt",220,20,60,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="修改";
		__this.background="Texture/b_up.png;";
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,60,105,22);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="电影文件：";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("imeeditbox","actorMovieFile", "_lt",105,55,175,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/filenamebox.png;";
		__this.candrag=false;
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,95,105,22);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="当前时间：";
		__this.autosize=true;
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("text","record_time", "_lt",105,95,105,22);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="00:00:00";
		__this.autosize=true;
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,135,100,22);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="时间轴：";
		__this.autosize=true;
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("editbox","record_timeInput", "_lt",105,130,105,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/box.png;";
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("button","record_setTime", "_lt",220,130,60,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="修改";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.record_setTime();";
		
		__this=ParaUI.CreateUIObject("button","record_pause", "_lt",10,170,30,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/pause.png;";
		__this.onclick=";MovieUI.record_pause();";
		
		__this=ParaUI.CreateUIObject("button","record_play", "_lt",45,170,30,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/play.png;";
		__this.onclick=";MovieUI.record_play();";
		
		__this=ParaUI.CreateUIObject("button","record_stop", "_lt",80,170,30,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/stop.png;";
		__this.onclick=";MovieUI.record_stop();";
		
		__this=ParaUI.CreateUIObject("button","record_record", "_lt",115,170,30,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/rec.png;";
		__this.onclick=";MovieUI.record_record();";
		
		__this=ParaUI.CreateUIObject("button","record_save", "_lt",150,170,60,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="存盘";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.record_save();";
		
		__this=ParaUI.CreateUIObject("button","record_load", "_lt",220,170,60,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="载入";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.record_load();";
		
		__this=ParaUI.CreateUIObject("button","record_load", "_lt",10,210,80,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="添加动作";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/demo/film/add_action.lua";
		
		__this=ParaUI.CreateUIObject("button","record_load", "_lt",100,210,80,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="添加特效";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/demo/film/add_spell.lua";
		__this.candrag=false;
		texture=__this:GetTexture("background");
		texture.transparency=255;--[0-255]
		
		__this=ParaUI.CreateUIObject("button","record_load", "_lt",190,210,80,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="添加循环";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.record_addloopkey();";
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,245,100,22);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="添加对话：";
		__this.autosize=true;
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("imeeditbox","record_dialoginput", "_lt",10,265,210,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/filenamebox.png;";
		__this.candrag=false;
		__this.readonly=false;
		
		
		__this=ParaUI.CreateUIObject("button","record_adddialog", "_lt",220,265,60,30);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.text="添加";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.record_adddialog();";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("container","actorMovieFileContainer", "_lt",10,295,270,105);
		__parent=ParaUI.GetUIObject("film_container");__parent:AddChild(__this);
		__this.scrollable=true;
		__this.background="Texture/player/outputbox.png;";
		
		__this=ParaUI.CreateUIObject("text","actorMovieFileText", "_lt",10,7,250,20);
		__parent=ParaUI.GetUIObject("actorMovieFileContainer");__parent:AddChild(__this);
		__this.text="";
		__this.autosize=true;
	end
end
NPL.this(activate);
