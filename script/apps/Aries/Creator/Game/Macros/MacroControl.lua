--[[
Title: Macro Control Commands
Author(s): LiXizhi
Date: 2021/1/7
Desc: 

Use Lib:
-------------------------------------------------------
GameLogic.Macros.SetPlaySpeed(1.25)
GameLogic.Macros.SetHelpLevel(1)
GameLogic.Macros.SetAutoPlay(true)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")


local playSpeed = 1;


function Macros.GetPlaySpeed()
	return playSpeed
end

-- set the current play back speed.
-- @param speed: like 0.5, 1, 1.5, 2;
function Macros.SetPlaySpeed(speed)
	playSpeed = speed or 1
end

local nHelpLevel = 1;

-- @param nLevel: 1 (default) to show all tips
-- 1 (default) to show all possible tips
-- -1 to display key and mouse tips
-- 0 to disable mouse tips
function Macros.SetHelpLevel(nLevel)
	nHelpLevel = nLevel
end

-- @return default to 1
function Macros.GetHelpLevel()
	return nHelpLevel
end

function Macros.IsShowButtonTip()
	return nHelpLevel >= 1
end

function Macros.IsShowKeyButtonTip()
	return nHelpLevel >= 0
end

local isAutoPlay = false;

-- whether triggers are played automatically
function Macros.IsAutoPlay()
	return isAutoPlay;
end


-- whether triggers are played automatically
function Macros.SetAutoPlay(bAutoPlay)
	isAutoPlay = bAutoPlay
end

local blockOrigin = {0,0,0};

function Macros.SetMacroOrigin(x, y, z)
	blockOrigin[1], blockOrigin[2], blockOrigin[3] = x, y, z;
end

-- this is usually the player location when macro starts recording. 
function Macros.GetMacroOrigin()
	return blockOrigin[1], blockOrigin[2], blockOrigin[3]
end

-- whether to generate triggers during recording. 
function Macros.SetInteractiveMode(isInteractive)
	Macros.isInteractive = isInteractive == true;
end

function Macros.IsInteractiveMode()
	return Macros.isInteractive;
end
