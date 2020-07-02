--[[ a character that loads a movie sequence at start up. 
author: LiXizhi
date: 2007.11.12
desc: 
usage:
==On_Load==
-- load and play relative
;NPL.load("(gl)script/AI/templates/AIMoviePlayer.lua");_AI_templates.AIMoviePlayer.On_Load("mymovie.txt");
-- load and paused
;NPL.load("(gl)script/AI/templates/AIMoviePlayer.lua");_AI_templates.AIMoviePlayer.On_Load("mymovie.txt", 2);
]]

if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.AIMoviePlayer) then _AI_templates.AIMoviePlayer={}; end

_AI_templates.AIMoviePlayer.LastRadius = 2;
_AI_templates.AIMoviePlayer.LastWaitlength = 1.57;

--[[
@param moviefile: the movie file to load
@param playmode: nil or 0, replay relative immediately, 1 replay absolute, 2 for paused
@param defaultAnimID: if nil, it will be the first animation range. 
]]
function _AI_templates.AIMoviePlayer.On_Load(moviefile, playmode, defaultAnimID)
	if(moviefile == nil or moviefile=="") then return end
	
	local self = _AI_templates.AIMoviePlayer;
	local player = ParaScene.GetObject(sensor_name);
	
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		
		local afterloadmsgtype = Map3DSystem.msg.MOVIE_ACTOR_Pause;
		if(playmode == nil or playmode==0) then
			afterloadmsgtype = Map3DSystem.msg.MOVIE_ACTOR_ReplayRelative;
		elseif(playmode==1) then
			afterloadmsgtype = Map3DSystem.msg.MOVIE_ACTOR_Replay;
		end
		Map3DSystem.SendMessage_movie({type = Map3DSystem.msg.MOVIE_ACTOR_Load, obj=player, obj_params={name=player.name, IsCharacter=true,}, filename=moviefile, afterloadmsgtype = afterloadmsgtype})
	end
end
