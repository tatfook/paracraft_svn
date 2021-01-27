--[[
Title: movie related UI sound
Author(s): LiXizhi
Date: 2014/4/17
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/MovieUISound.lua");
local MovieUISound = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieUISound");
MovieUISound.PlayAddKey();
MovieUISound.PlayRemoveKey();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/Actor.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Sound/SoundManager.lua");
local SoundManager = commonlib.gettable("MyCompany.Aries.Game.Sound.SoundManager");
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local MovieUISound = commonlib.gettable("MyCompany.Aries.Game.Movie.MovieUISound");

function MovieUISound.PlaySound(name)
	-- TODO: play different sound by name. 
	local block = block_types.get(block_types.names.MovieClip);
	if(block) then
		block:play_toggle_sound();
	end
end

local i = 1;
function MovieUISound.PlayAddKey()
	i = (i + 1) % 2;
	SoundManager:PlaySound("addkey"..i, "click");
end

function MovieUISound.PlayRemoveKey()
	MovieUISound.PlaySound("RemoveKey");
end
