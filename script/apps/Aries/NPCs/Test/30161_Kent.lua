--[[
Title: Kent
Author(s): WangTian
Date: 2009/8/13

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Test/30161_Kent.lua
------------------------------------------------------------
]]

-- create class
local libName = "Kent";
local Kent = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Kent", Kent);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- Kent.main
function Kent.main()
end

function Kent.PreDialog()
	System.App.Commands.Call("MiniGames.FarmClip");
	return false;
end

function Kent.PreDialog_HitShrew()
	System.App.Commands.Call("MiniGames.HitShrew");
	return false;
end

function Kent.PreDialog_ChuanYun()
	System.App.Commands.Call("MiniGames.ChuanYun");
	return false;
end

function Kent.PreDialog_PaoPaoLong()
	System.App.Commands.Call("MiniGames.PaoPaoLong");
	return false;
end

function Kent.PreDialog_SnowBall()
	System.App.Commands.Call("MiniGames.SnowBall");
	return false;
end

function Kent.PreDialog_SuperDancer()
	System.App.Commands.Call("MiniGames.SuperDancer");
	return false;
end

function Kent.PreDialog_JumpFloor()
	System.App.Commands.Call("MiniGames.JumpFloor");
	return false;
end

function Kent.PreDialog_Zuma()
	System.App.Commands.Call("MiniGames.Zuma");
	return false;
end


function Kent.PreDialog_CrazySpots()
	System.App.Commands.Call("MiniGames.CrazySpots");
	return false;
end

function Kent.PreDialog_LuckyDial()
	System.App.Commands.Call("MiniGames.LuckyDial");
	return false;
end

function Kent.PreDialog_CropDefend()
	System.App.Commands.Call("MiniGames.CropDefend");
	return false;
end

function Kent.PreDialog_DeliciousCake()
	System.App.Commands.Call("MiniGames.DeliciousCake");
	return false;
end

function Kent.PreDialog_FireFly()
	System.App.Commands.Call("MiniGames.FireFly");
	return false;
end
function Kent.PreDialog_RecycleBin()
	System.App.Commands.Call("MiniGames.RecycleBin");
	return false;
end
function Kent.PreDialog_Watering()
	System.App.Commands.Call("MiniGames.Watering");
	return false;
end
function Kent.PreDialog_TownMayorMailBox()
    NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(1);
	return false;
end

function Kent.PreDialog_TestArena_EnterCombat(arena_id)
	--NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
	--MyCompany.Aries.Combat.MsgHandler.OnEnterCombat(arena_id - 10000)
	return false;
end