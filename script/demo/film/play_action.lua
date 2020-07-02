--[[ 
Title: play an action of the current character
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/film/play_action.lua", "cast_action_=\"EmoteYes\"");
------------------------------------------------------------
]]
-- global state
-- name of the action to animated for the current character.
-- cast_action_ = "";
local function activate()
	if(cast_action_~=nil) then
		local player = ParaScene.GetObject("<player>");
		player:ToCharacter():PlayAnimation(cast_action_);
	end
end
NPL.this(activate);
 