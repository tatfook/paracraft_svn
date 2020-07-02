--[[
Title: data provider for the movie lib
Author(s): LiXizhi
Date: 2007/11/11
Desc: 
use the lib:
It keeps a list of actors, cameras, etc. 
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/movie_db.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");


if(not Map3DSystem.Movie.movie_db) then Map3DSystem.Movie.movie_db={}; end

Map3DSystem.Movie.movie_db = {
	-- name of the movie
	name = "clip1",
	-- all actors in the movie, may be modified externally
	actors = {},
	-- cameras
	camera = "TODO",
	-- the current movie time
	time = 0,
	-- whether the movie is paused
	IsPaused = true,
	
	-- movie timer ID is 51. this timer ID should be reserved for movie lib
	timerID = 51,
	-- interval in seconds, when the movie state is updated.
	timerInterval = 1.0,
};


--[[ enable Movie lib. it will start a timer once enabled. 
@param bEnable: true to start the lib, false to disable it.
]]
function Map3DSystem.Movie.movie_db.EnableTimer(bEnable)
	local self = Map3DSystem.Movie.movie_db;
	if(bEnable) then
		NPL.SetTimer(self.timerID, self.timerInterval, ";Map3DSystem.Movie.movie_db.OnMovieTimer();");
	else
		NPL.KillTimer(self.timerID);
	end
end

function Map3DSystem.Movie.movie_db.OnMovieTimer()
end

