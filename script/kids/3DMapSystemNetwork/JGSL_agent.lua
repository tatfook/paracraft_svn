--[[
Title: agent in a server or client
Author(s): LiXizhi
Date: 2007/11/6, refined with no sim 2008.8.6
Desc: agent can be serialized to and from compact streams to be sent via network. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_agent.lua");
local agent = Map3DSystem.JGSL.agent:new()
agent:UpdateFromPlayer(ParaScene.GetPlayer(), 2);
agent:print_history();
print(agent:GenerateUpdateStream(0))
agent:UpdateFromPlayer(ParaScene.GetPlayer(), 3);
agent:print_history();
print(agent:GenerateUpdateStream(2))
print(agent:GenerateUpdateStream(3))

log("changing history...")
agent:UpdateFromStream("4:36.72,3:20091.00,6:7f,2:character/v4/Can/can01/can01.x,5:20086.00", 0)
agent:print_history();

------------------------------------------------------------
]]
if(not Map3DSystem.JGSL) then Map3DSystem.JGSL = {};end;

NPL.load("(gl)script/kids/3DMapSystemNetwork/ValueTracker.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MsgProc_game.lua");

NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_opcode.lua");
local opcodes = Map3DSystem.JGSL.opcodes;

local JGSL_server = Map3DSystem.JGSL_server;
local JGSL = Map3DSystem.JGSL;
local GetOpcodeParser = Map3DSystem.JGSL.GetOpcodeParser;


---------------------------------
-- agent template and functions
---------------------------------
JGSL.agent = {
	-- nil for unknown, 1 for agent, 2 for observer, 3 for logged out. 
	state = nil,
	-- a send frame count, denoting how many times that it has sent its stream to other computers. 
	send_count = 0,
	-- a receive frame count, denoting how many times that it has received its update stream from other computer. 
	rec_count = 0,
	-- jid, the nid can be derived from it. 
	jid = nil,
	-- current position. After compressing, it has 2 decimal
	x=nil,y=nil,z=nil,
	-- grid x and gridz position. if they are not nil. the x=gx+rx,z=gz+rz
	gx=nil,gz=nil,
	-- relative position. 
	rx=nil,ry=nil,rz=nil,
	-- the nick name to be displayed on head of character 
	nickname=nil,
	-- id or string of the main asset file of the agent
	AssetFile=nil,
	-- customizable character string,
	ccs=nil,
	-- scaling.After compressing, it has 2 decimal
	scaling=nil,
	-- anim id or string
	anim=nil,
	-- character facing. After compressing, it is [0,6.28/256)
	facing=nil,
	-- whether this is a dummy. if nil, it is not. if 1 it is . default to nil. 
	dummy = nil,
	-- this is a mapping from key name to their ValueTracker object. 
	-- currently, values in trackers are compressed data. 
	history = nil,
	-- last time the agent is updated by the server or client depending on it use
	LastActiveTime = nil,
	-- if an agent is not active in 20 seconds, we will make it inactive user and remove from active user list. 
	TimeOut = 20000,
}
function JGSL.agent:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- convert full JID to JID, removing the trailing resource string /paraengine
	if(o.jid~=nil) then
		o.jid = string.gsub(o.jid, "/.*$", "");
	end
	-- for data keeping. 
	o.group2 = {};
	-- for tracking history of update 
	o.history = {};
	return o
end

-- for debugging only. dump to log
function JGSL.agent:Dump()
	commonlib.log("   agent dump(%s), LastActiveTime: %s, AssetFile: %s\n", tostring(self.jid), tostring(self.LastActiveTime), tostring(self.AssetFile));
end	

-- Check if agent has not been inactive for some time. 
-- @param curTime: it should be current time returned by ParaGlobal.GetGameTime()
-- @param TimeOut: how many millisecond that a agent is time out. 
-- return true if the agent is timed out, the caller may need to remove the agent from the client agent list. 
function JGSL.agent:CheckTimeOut(curTime, TimeOut)
	curTime = curTime or ParaGlobal.GetGameTime();
	TimeOut = TimeOut or self.TimeOut;
	if(self.LastActiveTime~=nil and (curTime-self.LastActiveTime)>TimeOut) then
		return true;
	end
end

function JGSL.agent:tickReceive()
	self.rec_count = self.rec_count + 1;
end

function JGSL.agent:tickSend()
	self.send_count = self.send_count + 1;
end

-- set the agent LastActiveTiem to be curTime
-- @param curTime: it should be current time returned by ParaGlobal.GetGameTime(). If nil,ParaGlobal.GetGameTime() is used
-- @param updateAvatar: if true, it will set the dynamic attribute of the avater in the scene for the last active time. 
-- since a avater may be updated or timed out by multiple grid node proxy. this dynamic attribute helps to prevent incorrect timeout, in case the agent
-- on one proxy is timed out while not on the other one. 
-- @return return true if agent avatar is not found in the scene and need to be updated.
function JGSL.agent:tick(curTime, updateAvatar)
	self.LastActiveTime = curTime or ParaGlobal.GetGameTime();
	
	if(updateAvatar) then
		local player = ParaScene.GetObject(self.jid);
		if(player:IsValid()) then
			player:GetAttributeObject():SetDynamicField("LastActiveTime", self.LastActiveTime);
		else
			return true;	
		end
	end	
end

-- whether this agent is currently intact, meaning it has enough information like appearance(AssetFile) and position. 
-- if an agent is not intact, we will ask the host to recover it. Please see JGSL recovery rules for more information.
-- @return true if successful. 
function JGSL.agent:IsIntact()
	return self.AssetFile and self.x and self.y and self.z;
end

-- clean up the agent state and delete its avatar from the scene if timed out
-- @bNoSim: if true no simulation on the server is done. if true, we do not care about the avatar in the scene
-- @return true if avatar is timed out as well.
function JGSL.agent:cleanup(bNoSim)
	self.group2 = {};
	if(not bNoSim) then
		local player = ParaScene.GetObject(self.jid);
		if(player:IsValid()) then
			local LastActiveTime = player:GetAttributeObject():GetDynamicField("LastActiveTime", 0);
			if(LastActiveTime <= (self.LastActiveTime or 0)) then
				-- we shall delete it from the scene, only if LastActive of the agent and the avatar matches.
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, 
					silentmode = true,
					obj_params = {
						name = self.jid,
						IsCharacter = true,
					},
				})
				--commonlib.log(self.jid.." is cleaned up\n");
				return true;	
			end	
			commonlib.log("%d is cleaned up avartertime %d, self time %d\n", self.jid, LastActiveTime,self.LastActiveTime or 0);
		end	
	end	
end

-- update a agent's 3D avatar according to information in the agent structure. 
-- if the 3d avatar is not created before, it will be created. If agent structure 
-- does not get enough information to create, it will ignore updating until the server 
-- has got enough information from the client. 
function JGSL.agent:update(curTime)
	local player = ParaScene.GetObject(self.jid);
	if(player:IsValid() == false) then
		
		-- if player does not exist
		if(self.x and self.y and self.z) then
			-- create if we have gathered enough information
			local assetfile = self.AssetFile or JGSL.DefaultAvatarFile;
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
				silentmode = true,
				obj_params = {
					name = self.jid,
					AssetFile = assetfile,
					CCSInfoStr = self.ccs or JGSL.DefaultAvatarCCSStrings[assetfile],
					x = self.x,
					y = self.y,
					z = self.z,
					IsCharacter = true,
					IsPersistent = false, -- do not save an GSL agent when saving scene
				},
			})
			
			-- make the newly created object special. 
			player = ParaScene.GetObject(self.jid);
			if(player:IsValid()) then
				local att = player:GetAttributeObject();
				-- this prevents user switch to GSL agent
				att:SetDynamicField("IsOPC", true);
				
				-- this will make MoveTo commands on the OPC working even it has been outside sentient area of the current player. 
				att:SetField("AlwaysSentient", true);
				-- make opc senses nobody 
				att:SetField("SentientField", 0);
				att:SetField("Sentient", true);
				
				-- NOTE by Andy 2009/6/18: Group special for Aries project
				if(commonlib.getfield("MyCompany.Aries.SentientGroupIDs")) then
					player:SetGroupID(MyCompany.Aries.SentientGroupIDs["OPC"]);
					log("+++++++++++++++++++player:SetGroupID(MyCompany.Aries.SentientGroupIDs[OPC]);+++++++++++++++++\n")
				end

				-- prevent head on text to be removed. 
				att:SetDynamicField("AlwaysShowHeadOnText", true);
				-- make it OPC movement style
				att:SetField("MovementStyle", 4)
				
				-- for head on text
				local displayname = string.gsub(self.jid, "@.*$", "");
				--log(Map3DSystem.JGSL.GetJID().." set name "..displayname.."\n");
				--att:SetDynamicField("name", displayname);
				att:SetDynamicField("JID", self.jid);
				
				local id = player:GetID();
				Map3DSystem.App.profiles.ProfileManager.GetUserInfo(displayname, "JGSL_agent_"..displayname, function(msg)
					if(msg and msg.users and msg.users[1]) then
						local user = msg.users[1];
						local nickname = user.nickname;
						local player = ParaScene.GetObject(id);
						if(player:IsValid() == true and displayname ~= nickname) then
							player:GetAttributeObject():SetDynamicField("name", nickname);
							-- show head on text
							Map3DSystem.ShowHeadOnDisplay(true, player, Map3DSystem.GetHeadOnText(player));
						end
					end
				end);
				
				if(player:GetAttributeObject():GetDynamicField("name", "") == "") then
					-- show head on text
					att:SetDynamicField("name", displayname);
					Map3DSystem.ShowHeadOnDisplay(true, player, Map3DSystem.GetHeadOnText(player));
				end
				
			end
		end
	else
		
		-- just normal update
		local x,y,z = player:GetPosition();
		local att = player:GetAttributeObject();
		
		if( att:GetDynamicField("IsAgent", false)) then
			-- it is summon mode agent, we will remove the agent and use the real avatar. 
			att:SetDynamicField("IsAgent", false);
			local playerChar = player:ToCharacter();
			playerChar:Stop();
			playerChar:AssignAIController("face", "false");
			playerChar:AssignAIController("follow", "false");
			playerChar:AssignAIController("movie", "false");
			playerChar:AssignAIController("sequence", "false");
			att:SetField("OnLoadScript", "");
			att:SetField("On_Perception", "");
			att:SetField("On_FrameMove", "");
			att:SetField("On_EnterSentientArea", "");
			att:SetField("On_LeaveSentientArea", "");
			att:SetField("On_Click", "");
		end
		
		if(self.x and self.y and self.z) then
			local deltaXZ = math.abs(x-self.x) + math.abs(z-self.z);
			local deltaY = math.abs(y-self.y);
		
			if(deltaXZ>0.1 and not (type(self.anim) == "string" and self.anim~="")) then
				if(self.facing) then
					-- encode facing in MoveTo command. 
					player:ToCharacter():MoveAndTurn(self.x-x, self.y-y, self.z-z, self.facing);
				else
					player:ToCharacter():MoveTo(self.x-x, self.y-y, self.z-z);
				end	
			else
				-- if we are almost there, just set at precise location and facing
				-- TODO: if agents are not in the same world (different terrain heights), we may allow the self.y to be player.y. 
				player:SetPosition(self.x, self.y, self.z);
				player:UpdateTileContainer();
				
				if(self.facing~=nil) then
					if(math.abs(player:GetFacing()-self.facing)>0.01) then
						player:SetFacing(self.facing);
					end	
				end		
			end	
		end	
		
		-------------------------------
		-- update group 2 if any
		-------------------------------
		local GTwo; -- whether needs to update group 2
		local mod_msg = {
			type = Map3DSystem.msg.OBJ_ModifyObject, 
			silentmode = true, 
			forcelocal = true,
			-- this will update regardless of the access right. 
			obj_params = {
				name = self.jid,
				IsCharacter = true,
			},
		}
		-- set scaling if any 
		if(self.scaling~=nil) then
			if(math.abs(player:GetScale()-self.scaling)>0.01) then
				mod_msg.scale = self.scaling;
				GTwo = true;
			end
		end
		
		-- change appearance if any
		if(self.AssetFile~=nil) then
			if(self.AssetFile ~= player:GetPrimaryAsset():GetKeyName()) then
				mod_msg.asset_file = self.AssetFile;
				GTwo = true;
				--log("ccs asset file changed to "..tostring(self.AssetFile).."\n")
			end
		end
		
		if(GTwo) then
			Map3DSystem.SendMessage_obj(mod_msg);
		end	
		
		-- ccs appearance		
		if(self.ccs~=nil) then
			local ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player)
			if(self.ccs~=ccs) then
				--log("ccs.ccs_info changed from \n"..tostring(ccs).."\n");
				--log("to \n"..tostring(self.ccs).."\n");
				Map3DSystem.UI.CCS.ApplyCCSInfoString(player, self.ccs);
				self.GTwo = true;
				
				-- TODO:  sometimes, it may fail to set ccs of a player. the following line ensures that we try only once. 
				-- self.ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player)
			end
		end
	end
	
	if(player:IsValid()) then
		-- set animation filename
		if(type(self.anim) == "string") then
			local curAnim = commonlib.Encoding.DefaultToUtf8(player:ToCharacter():GetAnimFileName());
			if(self.anim ~= curAnim) then
				-- play an animation. 
				action_table.PlayAnimationFile(commonlib.Encoding.Utf8ToDefault(self.anim), player);
			end
		end
	end	
end

-- insert creation related data to agent streams.
function JGSL.agent:GenerateCreationStream(agentStream)
	if(not agentStream) then return end
	if(Map3DSystem.options.IsEditorMode) then
		-- skip creation stream when in editor mode. 
		return
	end
	---------------------------
	-- object message: creation, modification, deletion
	---------------------------
	local history = Map3DSystem.obj.GetHistory();
	local time = history.creations:GetLastTime();
	--commonlib.log("we are here %s, %s\n", tostring(self.LastCreationHistoryTime), tostring(time));
	
	if(time~=nil) then
		self.LastCreationHistoryTime = self.LastCreationHistoryTime or 0;
		if(time > self.LastCreationHistoryTime) then
			local t;
			for t=self.LastCreationHistoryTime+1, time do
				local msg = history.creations:getValue(1, t);
				if(msg~=nil and msg.author == ParaScene.GetPlayer().name) then
					if(agentStream.creations == nil) then
						agentStream.creations = {};
					end
					-- secretly change the name of the operation to the client JID
					local new_msg = {author = self.jid}
					commonlib.partialcopy(new_msg, msg);
					agentStream.creations[table.getn(agentStream.creations)+1] = new_msg;
					
					commonlib.log("creation stream is generated at time %d\n", t);
					commonlib.echo(new_msg)
				end
			end
			self.LastCreationHistoryTime = time;
		end	
	end
	
	---------------------------
	-- env message: ocean, terrain paint, heightmap, etc. 
	---------------------------
	local history = Map3DSystem.Env.GetHistory();
	local time = history.env:GetLastTime();
	if(time~=nil) then
		self.LastEnvHistoryTime = self.LastEnvHistoryTime or 0;
		if(time > self.LastEnvHistoryTime) then
			local t;
			for t=self.LastEnvHistoryTime+1, time do
				local msg = history.env:getValue(1, t);
				if(msg~=nil and msg.author == ParaScene.GetPlayer().name) then
					if(agentStream.env == nil) then
						agentStream.env = {};
					end
					-- secretly change the name of the operation to the client JID
					local new_msg = {author = self.jid}
					commonlib.partialcopy(new_msg, msg);
					agentStream.env[table.getn(agentStream.env)+1] = new_msg;
				end
			end
			self.LastEnvHistoryTime = time;
			-- compress to reduce redundencies 
			JGSL.CompressEnvs(agentStream.env);
		end	
	end
end

-- update this agent data from a player. 
-- @param player: if this is nil, the current player is used
-- @timeid: time to write to history. if nil, it will write to each field history (time, value) pairs. 
function JGSL.agent:UpdateFromPlayer(player, timeid)
	player = player or ParaScene.GetPlayer();
	if(player:IsValid()) then
		---------------------------------
		-- data sent in each packet: current position, facing, animation, etc
		---------------------------------
		self.x,self.y,self.z = player:GetPosition();
		self.facing = player:GetFacing();
		-- get current animation.
		local anim = player:ToCharacter():GetAnimID();
		if(anim>=2000) then
			self.anim = commonlib.Encoding.DefaultToUtf8(player:ToCharacter():GetAnimFileName());
		else
			self.anim = "";
		end

		---------------------------------
		-- group 2 sent on demand or changed: appearance, scaling, etc
		---------------------------------
		-- whether group 2 infor is chaged. It is usually for character appearance. We only send group 2 on demand or changed. 
		-- TODO: this Logics of self.change is wrong. Instead a time value in each client agent should be used to decide whether it has missed any appearance updates. 		
		self.GTwo = false;
		
		if(self.AssetFile ~= player:GetPrimaryAsset():GetKeyName()) then
			self.AssetFile = player:GetPrimaryAsset():GetKeyName();
			self.GTwo = true;
		end
		
		if(self.scaling==nil or math.abs(self.scaling -player:GetScale())>0.01) then
			self.scaling  = player:GetScale();
			self.GTwo = true;
		end
		
		local ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player)
		if(self.ccs == nil or self.ccs~=ccs) then
			self.ccs=ccs;
			self.GTwo = true;
		end
		
		-------------------------
		-- save to history
		-------------------------
		self:UpdateFromSelf(timeid)
	end	
end

-- for debugging
function JGSL.agent:print_history()
	if(self.history) then
		timeid = timeid or 0
		local fieldname, tracker;
		for fieldname, tracker in pairs(self.history) do
			local opcode_parser = GetOpcodeParser(fieldname);
			if(opcode_parser) then
				local time = tracker:GetTime();
				local value = tracker:GetValue();
				commonlib.log("name %s time %s, value %s \n", fieldname, tostring(time), tostring(value));
			end	
		end
	end
end

-- save current agent.* changes to track history
function JGSL.agent:UpdateFromSelf(timeid)
	-- get relative position. 
	if(self.gx and self.x) then
		self.rx = self.x-self.gx
	else
		self.rx = self.x
	end
	if(self.gz and self.z) then
		self.rz = self.z-self.gz
	else
		self.rz = self.z
	end
	
	-- save only changed data field from agent to agent history
	timeid = timeid or 0;
	local index, opcode_parser
	for index, opcode_parser in pairs(opcodes) do
		if(type(index)=="number" and type(opcode_parser)=="table") then
			local value = opcode_parser:write(self[opcode_parser.name]);
			if(value~=nil) then
				local tracker = self.history[opcode_parser.name];
				if(not tracker) then
					tracker = JGSL.ValueTracker:new();
					tracker:SetSize(opcode_parser.historycount);
					self.history[opcode_parser.name] = tracker;
				end
				tracker:CheckPush(timeid, value);
			end
		end
	end
end

-- Update this agent data (also saves changes to history) from an opcode encoded text stream. It does not call update() to update the actual avartar. One needs to call it manually. 
-- agent data structure can be synchronized incrementally via streams. 
-- @stream: opcode encoded text stream that is usually generated by another agent's GenerateUpdateStream() from a remote computer.
-- @timeid: time to write to history.
function JGSL.agent:UpdateFromStream(stream, timeid)
	if(type(stream) == "string") then
		timeid = timeid or 0;
		local opcode, data
		for opcode, data in string.gmatch(stream, "(%d+):([^,]+)") do
			opcode = tonumber(opcode);
			local opcode_parser = opcodes[opcode];
			if(opcode_parser) then
				if(data~=nil) then
					local tracker = self.history[opcode_parser.name];
					if(not tracker) then
						tracker = JGSL.ValueTracker:new();
						tracker:SetSize(opcode_parser.historycount);
						self.history[opcode_parser.name] = tracker;
					end
					if(tracker:CheckPush(timeid, data)) then
						local value = opcode_parser:read(data);
						if(value) then
							self[opcode_parser.name] = value;
						end	
					end	
				end
			end
		end
		-- set relative position. 
		if(self.rx) then
			self.x = self.rx+(self.gx or 0)
		end	
		if(self.rz) then
			self.z = self.rz+(self.gz or 0)
		end	
	end	
end

-- Generate stream from this agent data
-- @timeid: only generate stream field that has changed after this time. if nil, all fields are streamed. 
-- @return: a text data string that can be sent over the network to update the agent.  It will return nil, if no stream needs to be sent
function JGSL.agent:GenerateUpdateStream(timeid)
	local stream;
	if(self.history) then
		timeid = timeid or 0
		local fieldname, tracker;
		for fieldname, tracker in pairs(self.history) do
			local opcode_parser = GetOpcodeParser(fieldname);
			if(opcode_parser) then
				local value = tracker:GetValue();
				--commonlib.log("name %s value %s \n", fieldname, tostring(value))
				if(value~=nil and tracker:IsUpdated(timeid)) then
					if(stream) then
						stream = string.format("%s,%d:%s", stream, opcode_parser.opcode, value);
					else
						stream = string.format("%d:%s", opcode_parser.opcode, value);
					end
				end
			end	
		end
	end
	return stream
end