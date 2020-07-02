_movie.name = "default";
-- below are all actors in the movie
_movie.AddActor("script/movie/actor/a.lua");
_movie.AddActor("script/movie/actor/b.lua");

-- set the camera focus on an actor
_movie.SetFocus("a");