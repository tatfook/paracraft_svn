--[[
Title: Movie replay dialog
Author(s): Code: LiXizhi
Date: 2005/11
]]
NPL.load("(gl)script/movie/movielib.lua");

-- MovieUI lib
if(not MovieUI) then MovieUI = {}; end

MovieUI.movieplaybuttons = {"movie_pause", "movie_stop", "movie_play"};
function MovieUI.movie_play()
	_movie.play();
	_guihelper.CheckRadioButtons( MovieUI.movieplaybuttons, "movie_play", "255 0 0");
end
function MovieUI.movie_pause()
	_movie.pause();
	_guihelper.CheckRadioButtons( MovieUI.movieplaybuttons, "movie_pause", "255 0 0");
end
function MovieUI.movie_stop()
	_movie.SetMovieTime(0);
	_movie.pause();
	_guihelper.CheckRadioButtons( MovieUI.movieplaybuttons, "movie_stop", "255 0 0");
end
function MovieUI.movie_loadmovie()
	local temp = ParaUI.GetUIObject("movie_filename");
	if(temp:IsValid()==true) then 
		local sMovieFile = temp.text;
		if(sMovieFile~=nil and sMovieFile ~= "") then
			-- load if the user has supplied a movie name
			_movie.LoadMovieFile(sMovieFile)
		else 
			local temp = ParaUI.GetUIObject("movie_name");
			if(temp:IsValid()==true) then 
				local sMovieFile = temp.text;
				if(sMovieFile~=nil and sMovieFile ~= "") then
					sMovieFile = ParaWorld.GetWorldDirectory().."movie/"..sMovieFile..".lua";
					_movie.LoadMovieFile(sMovieFile)
				end
			end
		end
	end
end

--[[update the name of the movie from the moive UI ]]
function MovieUI.UpdateMovieName()
	local tmp =ParaUI.GetUIObject("movie_name");
	if(tmp:IsValid()==false) then
		return;
	end
	local moviename = tmp.text;
	if(moviename == "") then
		return;
	end
	_movie.name = moviename;
	tmp =ParaUI.GetUIObject("movie_filename");
	if(tmp:IsValid()==true) then
		local filename = ParaWorld.GetWorldDirectory().."movie/".._movie.name..".txt";
		tmp.text = filename;
	end
end

local function activate()
	_guihelper.CheckRadioButtons( _demo_film_pages, "film_play", "255 0 0");
			
	local __this,__parent,__font,__texture;
	__this = ParaUI.GetUIObject("list_container");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end
	__this = ParaUI.GetUIObject("film_container");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end

	__this = ParaUI.GetUIObject("player_container");
	if(__this:IsValid() == true) then
		__this.visible=true;
	else
		__this=ParaUI.CreateUIObject("container","player_container", "_lt",30,60,299,390);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.scrollable=false;
		__this.background="Texture/item.png;";
		__this.candrag=false;
		__texture=__this:GetTexture("background");
		__texture.transparency=0;--[0-255]
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,55,100,22);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="电影名：";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("imeeditbox","movie_name", "_lt",105,50,120,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text=_movie.name;
		__this.background="Texture/box.png;";
		__this.candrag=false;
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("button","changename", "_lt",225,50,60,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="修改";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/empty.lua;MovieUI.UpdateMovieName();";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,105,105,22);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="文件名：";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("imeeditbox","movie_filename", "_lt",105,100,120,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/box.png;";
		__this.candrag=false;
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("button","movie_load", "_lt",225,100,60,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="载入";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/empty.lua;MovieUI.movie_loadmovie();";
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,155,105,22);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="当前时间：";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("text","movie_time", "_lt",105,155,105,22);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="00:00:00";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("button","movie_pause", "_lt",10,210,30,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/pause.png;";
		__this.onclick="(gl)script/empty.lua;MovieUI.movie_pause();";
		
		__this=ParaUI.CreateUIObject("button","movie_play", "_lt",45,210,30,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/play.png;";
		__this.onclick="(gl)script/empty.lua;MovieUI.movie_play();";
		
		__this=ParaUI.CreateUIObject("button","movie_stop", "_lt",80,210,30,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/stop.png;";
		__this.onclick="(gl)script/empty.lua;MovieUI.movie_stop();";
		
		__this=ParaUI.CreateUIObject("button","movie_toStart", "_lt",120,210,30,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/back.png;";
		__this.onclick="";
		
		__this=ParaUI.CreateUIObject("button","movie_toEnd", "_lt",155,210,30,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/player/go.png;";
		__this.onclick="";
		
		__this=ParaUI.CreateUIObject("editbox","movie_timeInput", "_lt",10,260,140,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/box.png;";
		__this.candrag=false;
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("button","movie_setTime", "_lt",160,260,80,30);
		__parent=ParaUI.GetUIObject("player_container");__parent:AddChild(__this);
		__this.text="重设时间";
		__this.background="Texture/b_up.png;";
		
	end
end
NPL.this(activate);
