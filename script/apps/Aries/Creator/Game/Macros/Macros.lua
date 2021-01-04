--[[
Title: all Macros 
Author(s): LiXizhi
Date: 2021/1/2
Desc: namespace for all macros

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/Macros.lua");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")
if(GameLogic.Macros:IsRecording()) then
	GameLogic.Macros:AddMacro("PlayerMove", x, y, z);
end
-------------------------------------------------------
]]
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

local lastPlayerPos = {pos = {x=0, y=0, z=0}, facing=0, recorded=false};
local lastCameraPos = {camobjDist=10, LiftupAngle=0, CameraRotY=0, recorded = false};
local startTime = 0;
local idleStartTime = 0;

local isInited;
function Macros:Init()
	if(isInited) then
		return true;
	end
	isInited = true;
	NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroIdle.lua");
	NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayerMove.lua");
	NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayerMoveTrigger.lua");
	-- TODO: add more here
end

function Macros:IsRecording()
	return self.isRecording;
end

function Macros:GetElapsedTime()
	return commonlib.TimerManager.GetCurrentTime() - startTime;
end

function Macros:BeginRecord()
	self:Init()
	self.isRecording = true;
	self.macros = {};
	startTime = commonlib.TimerManager.GetCurrentTime();
	idleStartTime = startTime;

	local player = EntityManager.GetPlayer();
	if(player) then
		local x, y, z = player:GetBlockPos();
		lastPlayerPos.pos = {x=x, y=y, z=z}
		lastPlayerPos.facing = player:GetFacing();
		lastPlayerPos.recorded = false;
	end
	lastCameraPos.camobjDist, lastCameraPos.LiftupAngle, lastCameraPos.CameraRotY = ParaCamera.GetEyePos();
	lastCameraPos.recorded = false;

	self.tickTimer = self.tickTimer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer();
	end})
	self.tickTimer:Change(500, 500);
	GameLogic.GetFilters():apply_filters("Macro_BeginRecord");
end


-- @param text: macro command text or just macro function name
-- @param ...: additional input parameters to macro function name
function Macros:AddMacro(text, ...)
	local args = {...}
	if(#args > 0) then
		local params;
		for _, param in ipairs(args) do
			if(params) then
				params = params..","..commonlib.serialize_compact(param);
			else
				params = commonlib.serialize_compact(param);
			end
		end
		text = format("%s(%s)", text, params or "");
	else
		if(not text:match("%(")) then
			text = text.."()";
		end
	end
	local idleTime = commonlib.TimerManager.GetCurrentTime() - idleStartTime;
	if(idleTime > 100) then
		idleStartTime = commonlib.TimerManager.GetCurrentTime();
		self:AddMacro("Idle", idleTime);
	end
	self.macros[#self.macros + 1] = text;
end

function Macros:EndRecord()
	if(not self.isRecording) then
		return;
	end
	self.isRecording = false;
	if(self.tickTimer) then
		self.tickTimer:Change();
	end
	if(self.macros) then
		local text = table.concat(self.macros, "\n");
		ParaMisc.CopyTextToClipboard(text);
		GameLogic.AddBBS(nil, format("%d macros are copied to clipboard", #(self.macros)), 5000, "0 255 0")
	end
	GameLogic.GetFilters():apply_filters("Macro_EndRecord");
end

function Macros:IsPlaying()
	return self.isPlaying;
end


-- @param text: text lines of macros.
-- @return array of Macro objects
function Macros:LoadMacrosFromText(text)
	if(not text) then
		return
	end
	NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/Macro.lua");
	local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");

	local macros = {};
	for line in text:gmatch("[^\r\n]+") do
		line = line:gsub("^%s+", "")
		local m = Macro:new():Init(line);
		if(m:IsValid()) then
			macros[#macros+1] = m;
		end
	end
	return macros;
end

-- @param text: text lines of macros. if nil, it will play from clipboard
function Macros:Play(text)
	text = text or ParaMisc.GetTextFromClipboard() or "";
	local macros = self:LoadMacrosFromText(text)
	self:PlayMacros(macros);
end

-- @param fromLine: optional
function Macros:PlayMacros(macros, fromLine)
	fromLine = fromLine or 1
	if(fromLine == 1) then
		self:EndRecord()
		self:Init();
		self.isPlaying = true;
	end

	while(true) do
		local m = macros[fromLine];
		if(m) then
			self.isPlaying = true;

			local isAsync = nil;
			m:Run(function()
				if(isAsync) then
					self:PlayMacros(macros, fromLine+1)
				else
					isAsync = false;
				end
			end)
			if(isAsync == false) then
				fromLine = fromLine + 1;
			else
				isAsync = true;
				break;
			end
		else
			self.isPlaying = false;
			break;
		end
	end
end


function Macros:Stop()
	if(self:IsRecording()) then
		self:EndRecord()
	elseif(self:IsPlaying()) then
		self.isPlaying = false;
	end
end

-- only record when the user has moved and been still for at least 500 ms. 
function Macros:Tick_RecordPlayerMove()
	local player = EntityManager.GetPlayer();
	if(player and EntityManager.GetFocus() == player) then
		-- for scene camera. 
		local camobjDist, LiftupAngle, CameraRotY = ParaCamera.GetEyePos();
		local diff = math.abs(lastCameraPos.camobjDist - camobjDist) + math.abs(lastCameraPos.LiftupAngle - LiftupAngle) + math.abs(lastCameraPos.CameraRotY - CameraRotY);
		if(diff ~= 0) then
			lastCameraPos.recorded = false;
			lastCameraPos.camobjDist, lastCameraPos.LiftupAngle, lastCameraPos.CameraRotY = camobjDist, LiftupAngle, CameraRotY
		elseif(diff == 0 and not lastCameraPos.recorded) then
			lastCameraPos.recorded = true;
			self:AddMacro("CameraMove", camobjDist, LiftupAngle, CameraRotY);
		end

		-- for player position changes
		local x, y, z = player:GetBlockPos();	
		local diff = math.abs(lastPlayerPos.pos.x - x) + math.abs(lastPlayerPos.pos.y - y) + math.abs(lastPlayerPos.pos.z - z);
		if(diff ~= 0) then
			lastPlayerPos.recorded = false;
			lastPlayerPos.pos.x, lastPlayerPos.pos.y, lastPlayerPos.pos.z = x, y, z
		elseif(diff == 0 and not lastPlayerPos.recorded) then
			lastPlayerPos.recorded = true;
			local facing = player:GetFacing();
			self:AddMacro("PlayerMove", x, y, z, facing);
		end
	end
end



function Macros:OnTimer()
	if(self:IsRecording() and not self.isPlaying) then
		self:Tick_RecordPlayerMove()
	end
end