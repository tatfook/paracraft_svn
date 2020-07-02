--[[ 
Title: Movie library for ParaEngine
Author(s): LiXizhi
Date: 2005/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/movie/movielib.lua");
------------------------------------------------------------
]]
-- required by the movie dialog UI
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/ide/textdialog.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
local L = CommonCtrl.Locale("IDE");

-- the _movie global table is reserved for the movie lib
if(not _movie) then _movie = {}; end

-- set to initial states, this function should be called when a scene is loaded.
function _movie.Init()
	-- name of the movie
	_movie.name = "clip1";
	-- all actors in the movie, may be modified externally
	_movie.actors = {};
	-- cameras
	_movie.camera = "TODO";
	-- the current movie time
	_movie.time = 0;
	-- whether the movie is paused
	_movie.IsPaused = true;

	-- whether to enable UI handlers
	_movie.UIEnabled = false; 
end

-- init when file is loaded.
_movie.Init();
-- movie timer ID is 51. this timer ID should be reserved for movie lib
_movie.timerID = 51;
-- interval in seconds, when the movie state is updated.
_movie.timerInterval = 1.0;

--[[ enable Movie lib. it will start a timer once enabled. 
@param MovieEnbled: true to start the lib, false to disable it.
]]
function _movie.EnableMovieLib(MovieEnbled)
	_movie.UIEnabled = MovieEnbled;
	if(MovieEnbled==true) then
		NPL.SetTimer(_movie.timerID, _movie.timerInterval, "(gl)script/movie/movielib.lua");
	else
		NPL.KillTimer(_movie.timerID);
	end
end

--[[obsoleted: Show a movie dialog using the default UI in the lib
@param sDialogText: the dialog text ]]
function _movie.AddMovieDialog(movieDialog)
	if(movieDialog == nil or movieDialog == "") then
		_textdialog.clearall();
	else
		_textdialog.clearall();
		local value={};
		value.page={};
		value.page[1]=movieDialog;
		value.toolbar=true;
		value.obj=ParaScene.GetObject("<player>");
		_textdialog.show(value);
	end	
end

--return the first actor in the scene.
function _movie.GetFirstActor()
	local key, actor;
	for key, actor in pairs(_movie.actors) do
		return actor.obj;
	end
end

--[[ Set the current movie time. ]]
function _movie.SetMovieTime(newTime)
	local key, actor;
	for key, actor in pairs(_movie.actors) do
		if(actor.obj ~= nil) then
			local playerChar = actor.obj:ToCharacter();
			-- TODO: local actorTime = _movie.time - actor.startTime;
			playerChar:GetMovieController():SetTime(newTime);
		end
	end
end

--[[ play the current movie time. ]]
function _movie.play()
	_movie.IsPaused = false;
	local key, actor;
	for key, actor in pairs(_movie.actors) do
		if(actor.obj ~= nil) then
			local playerChar = actor.obj:ToCharacter();
			playerChar:GetMovieController():Play();
			playerChar:GetMovieController():Resume();
		end
	end
end

--[[ resume the current movie time. ]]
function _movie.resume()
	_movie.IsPaused = false;
	local key, actor;
	for key, actor in pairs(_movie.actors) do
		if(actor.obj ~= nil) then
			local playerChar = actor.obj:ToCharacter();
			playerChar:GetMovieController():Resume();
		end
	end
end

--[[pause the movie.]]
function _movie.pause()
	_movie.IsPaused = true;
	local key, actor;
	for key, actor in pairs(_movie.actors) do
		if(actor.obj ~= nil) then
			local playerChar = actor.obj:ToCharacter();
			playerChar:GetMovieController():Suspend();
		end
	end
end

--[[Set or update an actor's start up time
@param actorName: string value: actor name
@param startTime: float value: the new start up time of the actor.
]]
function _movie.SetActorStartupTime(actorName, startTime)
	local actor = _movie.actors[actorName];
	if(actor~=nil) then
		actor.startTime = startTime;
	end
end

--[[Add Actor
@param filename: string value: character movie file name
]]
function _movie.AddActor(filename)
	NPL.load(filename, true);
end

function _movie.NewActor(actorName)
	if(_movie.actors[actorName] == nil) then
		local actor={};
		actor.name=actorName;
		actor.startTime = 0;
		local player = ParaScene.GetObject(actorName);
		if(player:IsValid() == true) then
			actor.obj = player;
			_movie.actors[actorName] = actor;
			_guihelper.MessageBox(L"actor: "..actorName..L" has been added to the current movie");
		else
			-- actor not in the scene
			_guihelper.MessageBox(L"actor: "..actorName..L" is not found in the scene");
		end
	else
		_guihelper.MessageBox(L"actor: "..actorName.." 已经在当前电影的角色列表中");
	end
end

--[[Delete Actor
@param actor_name: string value: actor name
]]
function _movie.DeleteActor(actor_name)
	_movie.actors[actor_name] = nil;
end

--[[set the camera focus on a certain character]]
function _movie.SetFocus(actor_name)
	local actor = _movie.actors[actor_name];
	if(actor~=nil and actor.obj~=nil) then
		actor.obj:ToCharacter():SetFocus();
	else 
		local player = ParaScene.GetObject(actor_name);
		player:ToCharacter():SetFocus();
	end
end
--[[create the actor script for a valid actor in the scene, and save
the actor script to a specified file. It is not necessary for the actor 
to be in the actor list of the current movie.
@param actor_name: string value: actor name
@param scriptname: string value or nil: 
	filename to which the script is saved and overrided. 
	If this is nil, it will be "[world directory]/movie/actor/%actor_name%.lua"
]]
function _movie.CreateActorScript(actor_name, moviefile, scriptname)
	local player = ParaScene.GetObject(actor_name);
	if (player:IsValid() == false) then
		log("invalid actor name in CreateActorScript()\n");
		return;
	end
	if(moviefile==nil) then 
		moviefile = "";
	end
	if(scriptname==nil) then
		scriptname = ParaWorld.GetWorldDirectory().."movie/actor/"..actor_name..".lua";
	end
	if (ParaIO.CreateNewFile(scriptname) == false) then
		log("Failed creating actor movie file: "..scriptname.."\n");
		return;
	end
	log("actor movie file: "..scriptname.." created\n");
	-- Write actor movie script to file
	local movie_mode;
	if(_movie.IsPaused == true) then
		movie_mode = "Suspend";
	else
		movie_mode = "Resume";
	end
	
	local x,y,z;
	local bUpdatePosition = true;
	x,y,z=player:ToCharacter():GetMovieController():GetOffsetPosition();
	if(x==0 and y==0 and z==0) then 
		bUpdatePosition = false;
	end
	
	-- write header
	ParaIO.WriteString("-- "..actor_name.." movie script: auto generated by movielib 0.9 for ParaEngine\n");
	
	-- create the actor in the scene.
	local sScript = string.format([[
local player_ = ParaScene.GetObject("%s");
if(player_:IsValid() == false) then
%s
	player_ = player;
end
]],  actor_name,player:ToString());
	ParaIO.WriteString(sScript);

	-- write position if there is position keys
	if(bUpdatePosition == true) then
		sScript = string.format([[
-- initial position in the movie 
player_:SetPosition(%f, %f, %f);
]], x,y,z);
		ParaIO.WriteString(sScript);
	end
	-- load movie and add to actor list.
	sScript = string.format([[
playerChar = player_:ToCharacter();
playerChar:GetMovieController():LoadMovie("%s");
playerChar:GetMovieController():%s();
]], moviefile,movie_mode);
	ParaIO.WriteString(sScript);
	
	-- add actor to movie if not done so before
	sScript = string.format([[
	
if(_movie~=nil and _movie.actors["%s"] == nil) then
	local actor={};
	actor.name="%s";
	actor.startTime = _movie.time;
	actor.obj = player_;
	_movie.actors["%s"] = actor;
end
]], actor_name, actor_name,actor_name);
	ParaIO.WriteString(sScript);
	
	ParaIO.CloseFile();
	-- copy the script to the script window.
	sScript = string.format(L"actor movie file has been successfully created:"..[[
%s
	]],scriptname);
	local temp = ParaUI.GetUIObject("actorMovieFileText");
	if(temp:IsValid()==true) then 
		temp.text=sScript; 
	end
end

--[[load a new movie file
@param sMovieFile: this is the movie file name
]]
function _movie.LoadMovieFile(sMovieFile)
	NPL.load(sMovieFile, true);
	_guihelper.MessageBox(L"movie has been loaded. File: \n"..sMovieFile); 
end

--[[save the current movie to file.
@param bSaveNonActor: true to save non-actors. 
]]
function _movie.SaveMovieToFile(bSaveNonActor)
	local filename = ParaWorld.GetWorldDirectory().."movie/".._movie.name..".lua";
	if (ParaIO.CreateNewFile(filename) == false) then
		log("Failed creating movie file: "..filename.."\n");
		return;
	end
	
	-- movie name
	local sScript = string.format([[_movie.name = "%s";
]], _movie.name);
	ParaIO.WriteString(sScript);

	-- actor files
	local key, actor;
	for key, actor in pairs(_movie.actors) do
		sScript = string.format([[_movie.AddActor("%smovie/actor/%s.lua");
]], ParaWorld.GetWorldDirectory(), tostring(key));
		ParaIO.WriteString(sScript);
	end
	
	-- actor focus
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid() == true) then
		sScript = string.format([[_movie.SetFocus("%s");]], player.name);
		ParaIO.WriteString(sScript);
	end
	
	local nNumNonActors=0;
	if(bSaveNonActor == true) then
		-- print non-actor object to the current IO
		-- the number of non actor global object is stored in nNumNonActors.
		local playerCur = player;
		while(playerCur:IsValid() == true) do
			if(not _movie.actors[playerCur.name]) then
				nNumNonActors=nNumNonActors+1;
				-- if the global object is not an actor, we will add it here.
				sScript = string.format([[
	if(ParaScene.GetObject("%s"):IsValid() == false) then
		%s
	end
]], playerCur.name, playerCur:ToString());
				ParaIO.WriteString(sScript);
			end
			
			playerCur = ParaScene.GetNextObject(playerCur);
			if(playerCur:equals(player) == true) then
				break; -- cycled to the beginning again.
			end
		end
	end	
	
	ParaIO.CloseFile();
	sScript = string.format(L"movie file has been successfully saved:\r\n%s\r\nmovie contains non character objects:%d\r\n",filename, nNumNonActors);
	_guihelper.MessageBox(sScript);
	log(sScript);
end

--[[
This file is activated regularly when the movie lib is enabled.
]]
local function activate()
	-- update actor name
	local temp;
	temp = ParaUI.GetUIObject("actorName");
	if(temp:IsValid()==true) then 
		-- TODO: update name should be called on demand. Not as a timer
		local actorName;
		local player = ParaScene.GetObject("<player>");
		if(player:IsValid()==true)then actorName = player:GetName(); end
		if(actorName ~= temp.text and actorName~=nil) then
			temp.text=actorName;
		end
	end
	-- update recording time
	temp = ParaUI.GetUIObject("record_time");
	if(temp:IsValid()==true) then 
		local sTime;
		local player = ParaScene.GetObject("<player>");
		if(player:IsValid()==true)then 
			sTime = player:ToCharacter():GetMovieController():GetTime("%H:%M:%S"); 
			if(sTime ~= temp.text) then
				temp.text=sTime;
			end
			
			temp = ParaUI.GetUIObject("movie_time");
			if(temp:IsValid()==true) then 
				if(sTime ~= temp.text) then
					temp.text=sTime;
				end
			end
		end
		
	end
end
NPL.this(activate);