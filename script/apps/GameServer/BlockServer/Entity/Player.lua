--[[
Title: Player
Author(s): LiXizhi
Date: 2013/8/29
Desc: a player on server side
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BlockServer/Entity/Player.lua");
local Player = commonlib.gettable("Map3DSystem.GSL.BlockServer.Player");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/BlockServer/GSL_BlockClient.lua");
NPL.load("(gl)script/ide/math/bit.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/World/Section.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/UniversalCoords.lua");
local UniversalCoords = commonlib.gettable("Map3DSystem.GSL.BlockServer.Util.UniversalCoords");

local tostring = tostring;
local format = format;
local type = type;
local Player = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.BlockServer.Entity.Player"))

Player.EyeHeight = 1.67;

local GameMode = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.BlockServer.GameMode"))
GameMode.Normal = 0;
GameMode.Creative = 1;
GameMode.Adventure = 2;

function Player:ctor()
end

function Player:Init(server, nid)
	self.Server = server;
	self.nid = nid;

	self.Permissions = nil;
	self.LoginPosition = nil;
	self.Experience = nil;
	self.Health = nil;
	self.Inventory= nil;
	self.Ready = false;
	self.GameMode = false;

	self:InitializePosition();
end

function Player:InitializePosition()
    self.World = self.Server:GetDefaultWorld();
	local Spawn = self.World.Spawn;
	if(Spawn) then
		self.Position = UniversalCoords:new():FromWorld(
			Spawn.WorldX,
			Spawn.WorldY,
			Spawn.WorldZ);
	end
end
