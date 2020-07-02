--[[
Title: agent in a server or client
Author(s): LiXizhi
Date: 2009.7.30 
Desc: agent can be serialized to and from compact streams to be sent via network. 
==Special field==:
| *name*  | *desc* |
| is_mounted | if agent.is_mounted is true, we shall not animate the agent's position changes, since agent position are controlled by the mount target. |
| is_local | if agent.is_local is true, we shall not animate the agent's position changes, since agent position are controlled by local logic./
			TODO: position shall not be broadcasted too |
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_agent.lua");
local agent = Map3DSystem.GSL.agent:new()
agent:UpdateFromPlayer(ParaScene.GetPlayer(), 2);
agent:print_history();
print(agent:GenerateUpdateStream(0))
agent:UpdateFromPlayer(ParaScene.GetPlayer(), 3);
agent:print_history();
print(agent:GenerateUpdateStream(2))
print(agent:GenerateUpdateStream(3))

log("changing history...")
agent:UpdateFromStream("4:36.72\n3:20091.00\n6:7f\n2:character/v4/Can/can01/can01.x\n5:20086.00", 0)
agent:print_history();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/common/ValueTracker.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MsgProc_game.lua");
NPL.load("(gl)script/apps/GameServer/GSL_opcode.lua");
local opcodes = commonlib.gettable("Map3DSystem.GSL.opcodes");
local rt_opcodes = commonlib.gettable("Map3DSystem.GSL.rt_opcodes");
local opcode_names = commonlib.gettable("Map3DSystem.GSL.opcode_names");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local GSL_server = commonlib.gettable("Map3DSystem.GSL_server");
local GSL_proxy = commonlib.gettable("Map3DSystem.GSL.GSL_proxy");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GetOpcodeParser = commonlib.gettable("Map3DSystem.GSL.GetOpcodeParser");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
local ParaScene_GetObject = ParaScene.GetObject;
local Map3DSystem = commonlib.gettable("Map3DSystem")
local LOG = LOG;
-- external applications can override sentient group ids afterwards. 
local SentientGroupIDs = commonlib.gettable("Map3DSystem.GSL.SentientGroupIDs");
SentientGroupIDs.Player = SentientGroupIDs.Player or 0;
SentientGroupIDs.OPC = SentientGroupIDs.OPC or 4;

local math_abs = math.abs;
local type = type;
local tonumber = tonumber;
local tostring = tostring;
local string_format = string.format;
local format = format;
local string_gmatch = string.gmatch;

local IGNORE_ASSETFILE_UPDATE = true;

-- TODO: the avatar to be displayed when the appearance is not synchronized in GSL. Use something simple, such as a stick or a nude avatar. 
local DefaultAvatarFile = "character/v3/Elf/Female/ElfFemale.xml";
-- agent is sentient to player within 60 meters
local agent_sentient_radius = 60;
-- all cached agents
local all_agents = {};

-- DefaultAvatarFile will be used as key to find the default ccsstring for a given model. 
local DefaultAvatarCCSStrings = {
	["character/v3/Elf/Female/ElfFemale.x"] = "0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#1#11010#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#",
	["character/v3/Elf/Female/ElfFemale.xml"] = "0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#1#11010#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#",
	["character/v3/dummy/dummy.x"] = "",
};

local agentstate = commonlib.gettable("Map3DSystem.GSL.agentstate");
agentstate.agent = 1;
agentstate.observer = 2;
agentstate.loggedout = 3;

---------------------------------
-- agent template and functions
---------------------------------
GSL.agent = {
	-- type of agentstate: nil for unknown, 1 for agent, 2 for observer, 3 for logged out. 
	state = nil,
	-- a send frame count, denoting how many times that it has sent its stream to other computers. 
	send_count = 0,
	-- a receive frame count, denoting how many times that it has received its update stream from other computer. 
	rec_count = 0,
	-- the nid of this agent. 
	nid = nil,
	-- the cell object that the agent is currently in. See GSL_cells. It is nil, if no cells are used in the grid node
	cell = nil,
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
	-- if agent.is_mounted is true, we shall not animate the agent's position changes, since agent position are controlled by the mount target.
	is_mounted = nil,
	-- if agent.is_local is true, we shall not animate the agent's position changes, since agent position are controlled by local logic.
	is_local = nil,
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

-- whether this is aries agent. 
local IsAriesAgent;

function GSL.agent:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- o.nid = tostring(o.nid);
	
	-- for tracking history of update 
	o.history = {};
	-- for tracking data in a request/response fashion.  mapping from name to value. 
	o.blog = {};
	return o
end

-- for debugging only. dump to log
function GSL.agent:Dump()
	commonlib.log("   agent dump(%s), LastActiveTime: %s, AssetFile: %s\n", tostring(self.nid), tostring(self.LastActiveTime), tostring(self.AssetFile));
end	

-- set item name, value pair. This allows user to upload arbitrary temporary data to server that any other users can access. 
-- but data updated in this mode will not be broadcasted to the client automatically. instead other user fetch it on demand. 
-- @param name: string key 
-- @param value: string or number value. 
function GSL.agent:SetItem(name, value)
	local value_type = type(value);
	if(value_type == "string") then
		-- we may need some security check to prevent the user from uploading too much info to our server.
		if(#value > 10000) then
			LOG.std(nil, "warn", "GSL", "user %s is uploading too much info to %s", self.nid, name);
			return;
		end
	elseif(value_type == "table") then
		-- table is forbidden now. 
		LOG.std(nil, "warn", "GSL", "user %s is uploading unsupported table to %s", self.nid, name);
		return;
	end
	self.blog[name] = value;
end

-- get item value by key name
-- @param name: string key name
-- @return string or number value. it may be nil. 
function GSL.agent:GetItem(name)
	return self.blog[name];
end

-- Check if agent has not been inactive for some time. 
-- @param curTime: it should be current time returned by ParaGlobal.timeGetTime()
-- @param TimeOut: how many millisecond that a agent is time out. 
-- return true if the agent is timed out, the caller may need to remove the agent from the client agent list. 
function GSL.agent:CheckTimeOut(curTime, TimeOut)
	curTime = curTime or ParaGlobal.timeGetTime();
	TimeOut = TimeOut or self.TimeOut;
	if(self.LastActiveTime~=nil and (curTime-self.LastActiveTime)>TimeOut) then
		--commonlib.echo({"agent time out", self.nid, name=__rts__:GetName(), LastActiveTime = self.LastActiveTime,  curTime=curTime, TimeOut = TimeOut})
		return true;
	end
end

function GSL.agent:tickReceive()
	self.rec_count = self.rec_count + 1;
end

function GSL.agent:tickSend()
	self.send_count = self.send_count + 1;
end

-- set the agent LastActiveTiem to be curTime
-- @param curTime: it should be current time returned by ParaGlobal.timeGetTime(). If nil,ParaGlobal.timeGetTime() is used
-- @return return true if agent avatar is not found in the scene and need to be updated.
function GSL.agent:tick(curTime)
	self.LastActiveTime = curTime or ParaGlobal.timeGetTime();
end

-- whether this agent is currently intact, meaning it has enough information like appearance(AssetFile) and position. 
-- if an agent is not intact, we will ask the host to recover it. Please see GSL recovery rules for more information.
-- @return true if successful. 
function GSL.agent:IsIntact()
	return (IGNORE_ASSETFILE_UPDATE or self.AssetFile) and self.x and self.y and self.z;
end

-- whether we will ignore asset file update. 
function GSL.SetIgnoreAssetFileUpdate(bIgnore)
	IGNORE_ASSETFILE_UPDATE = bIgnore;
end

-- virtual: remove player if any. 
function GSL.agent.OnRemovePlayer(self, player)
	-- we shall delete it from the scene, only if LastActive of the agent and the avatar matches.
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, 
		silentmode = true,
		obj_params = {
			name = self.nid,
			IsCharacter = true,
		},
	})
end

-- clean up the agent state and delete its avatar from the scene
-- @bNoSim: if true no simulation on the server is done. if true, we do not care about the avatar in the scene
-- @return true if avatar is timed out as well.
function GSL.agent:cleanup(bNoSim)
	if(not bNoSim) then
		local player = ParaScene_GetObject(self.nid);
		all_agents[tostring(self.nid)] = nil;
		self.last_ccs = nil;
		self.is_cleanedup = true;

		if(player:IsValid()) then
			GSL.agent.OnRemovePlayer(self, player);
			LOG.std("", "debug", "GSL", self.nid.." is cleaned up");
		end	
		return true;
	end	
end


local AgentEnterSentientCallback;
-- set a function to be called whenever an agent enters into sentient field
-- @param callbackFunc: function (agent) end, if return true the GSL will not further process the default behavior. 
function GSL.SetAgentEnterSentientCallback(callbackFunc)
	AgentEnterSentientCallback = callbackFunc;
end

local AgentLeaveSentientCallback;
-- set a function to be called whenever an agent leaves sentient field
-- @param callbackFunc: function (agent) end, if return true the GSL will not further process the default behavior. 
function GSL.SetAgentLeaveSentientCallback(callbackFunc)
	AgentLeaveSentientCallback = callbackFunc;
end

-- when a GSL agent becomes sentient, according to the new logics, we will only update the character appearance, etc when they are sentient. 
-- otherwise we will only update position. So it saves us lots of CPU time when there are many agents in the scene where most are not in visible range. 
function GSL.OnAgentEnterSentient()
	local agent_ = all_agents[sensor_name];
	if(agent_) then
		agent_:update_from_viewcache();
		if(AgentEnterSentientCallback) then
			AgentEnterSentientCallback(agent_);
		end
	end
end

function GSL.OnAgentLeaveSentient()
	local agent_ = all_agents[sensor_name];
	if(AgentLeaveSentientCallback and agent_) then
		AgentLeaveSentientCallback(agent_);
	end
end

-- headon display color for other players
local headon_color = "250 186 254";
-- NOTE: head on offset is set through ccs info, if equiped with hat or overhat, different offset is applied
local HeadOnOffset = {y=0.5}
-- the default function to be called when GSL avatar is created. this function can be replaced by SetDefaultAttribute
-- @param nid: 
-- @param player: this is always a valid ParaObject. 
local on_avatar_created = function(nid, player)
	local headon_text = Map3DSystem.GetHeadOnText(player);
	Map3DSystem.ShowHeadOnDisplay(true, player, headon_text, headon_color);
end
-- call whenever the chat message is received. this function can be replaced by SetDefaultAttribute
local on_receive_chat_msg = function(nid, value)
	LOG.std("", "user", "GSL", "%s says: %s", nid, value);
	-- when received a message just call
	_guihelper.MessageBox(format("%s says: %s", nid, value));
end

-- @param name: the following are supported on_avatar_created, on_receive_chat_msg, headon_color, HeadOnOffset, OnCreateAgent
function GSL.agent.SetDefaultAttribute(name, value)
	if(name == "headon_color") then
		headon_color = value;
	elseif(name == "HeadOnOffset") then
		HeadOnOffset = value;
	elseif(name == "on_avatar_created") then
		on_avatar_created = value;
	elseif(name == "on_receive_chat_msg") then
		on_receive_chat_msg = value;
	elseif(name == "IsAriesAgent") then
		IsAriesAgent = value;
	else
		GSL.agent[name] = value;
	end
end

-- assign attributes and related settings for newly created character
function GSL.agent.SetAttributeForAgent(nid_name)
	local player = ParaScene_GetObject(nid_name);
	if(player:IsValid()) then
		-- 2010/6/28: all dynamic attributes are copied to the newly created character
		local att = player:GetAttributeObject();
		-- this prevents user switch to GSL agent
		att:SetDynamicField("IsOPC", true);
				
		-- Disable sentient fields.
		att:SetField("AlwaysSentient", false);
		-- make opc senses nobody 
		att:SetField("SentientField", 0);
		att:SetField("Sentient", false);
				
		-- NOTE by Andy 2009/6/18: Group special for Aries project
		
		player:SetGroupID(SentientGroupIDs["OPC"]);
		player:SetSentientField(SentientGroupIDs["Player"], true);
		att:SetField("Sentient Radius", agent_sentient_radius or 40);
		att:SetField("On_EnterSentientArea", [[;Map3DSystem.GSL.OnAgentEnterSentient();]]);
		att:SetField("On_LeaveSentientArea", [[;Map3DSystem.GSL.OnAgentLeaveSentient();]]);
		
		-- prevent head on text to be removed. 
		att:SetDynamicField("AlwaysShowHeadOnText", true);
		-- make it OPC movement style
		att:SetField("MovementStyle", 4)
				
		-- set nid field.
		att:SetDynamicField("nid", nid_name);
		att:SetDynamicField("JID", nid_name);
				
				
		-- for head on text
		local id = player:GetID();
		Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid_name, "GSL_agent_"..nid_name, function(msg)
			if(msg and msg.users and msg.users[1]) then
				local user = msg.users[1];
				local nickname = user.nickname;
				local family = user.family;
				local player = ParaScene_GetObject(id);
				if(player:IsValid()) then
					player:SetDynamicField("name", nickname);
					player:SetDynamicField("family", family or "");
					-- show head on text
					on_avatar_created(nid_name, player);
				end
			end
		end);
				
		--if(player:GetAttributeObject():GetDynamicField("name", "") == "") then
			---- show head on text
			--att:SetDynamicField("name", nid_name);
			----Map3DSystem.ShowHeadOnDisplay(true, player, Map3DSystem.GetHeadOnText(player), headon_color, HeadOnOffset);
			--Map3DSystem.ShowHeadOnDisplay(true, player, Map3DSystem.GetHeadOnText(player), headon_color);
		--end
	end
end

-- update the player's 3d view according to self. 
-- when the GSL receives agent view update, it will save them to the view cache and postpone the actual update(c++ part) until the character is sentient (already in view range). 
-- For already sentient characters, it will do the actual update immediately. 
-- this saves us lots of CPU time for out of range characters. 
-- @param player: if not nil, it will use it as a target to update the view. otherwise we get one from the nid. 
function GSL.agent:update_from_viewcache(player)
	local nid_name = tostring(self.nid);
	if(not player) then
		player = ParaScene_GetObject(nid_name);
		if(player:IsValid() == false) then
			return;
		end
	end
	
	-------------------------------
	-- update group 2 if any
	-------------------------------
	-- change appearance if any
	if(not IGNORE_ASSETFILE_UPDATE or self.AssetFile ~= nil) then
		if(self.AssetFile ~= player:GetPrimaryAsset():GetKeyName()) then
			local mod_msg = {
				type = Map3DSystem.msg.OBJ_ModifyObject, 
				silentmode = true, 
				forcelocal = true,
				asset_file = self.AssetFile,
				-- this will update regardless of the access right. 
				obj_params = {
					name = nid_name,
					IsCharacter = true,
				},
			}
			Map3DSystem.SendMessage_obj(mod_msg);
		end
	end
		
	-- ccs appearance		
	if(self.ccs~=nil) then
		-- local ccs = CCS.GetCCSInfoString(player)
		if(self.ccs~=self.last_ccs) then
			--log("ccs.ccs_info changed from \n"..tostring(ccs).."\n");
			--log("to \n"..tostring(self.ccs).."\n");
			CCS.ApplyCCSInfoString(player, self.ccs);
			self.last_ccs = self.ccs;
			self.GTwo = true;
		end
	end

	-- uncomment following to support play animations from web. 
	-- set animation filename
	--if(type(self.anim) == "string") then
		--local curAnim = commonlib.Encoding.DefaultToUtf8(player:ToCharacter():GetAnimFileName());
		--if(self.anim ~= curAnim) then
			---- play an animation. 
			--action_table.PlayAnimationFile(commonlib.Encoding.Utf8ToDefault(self.anim), player);
		--end
	--end
end

-- only update the position when the avatar is already updated by normal update and is currently sentient. 
-- this function is called by the client when it received real time update between normal updates, 
-- so that we can more precisely animate player position for currently visible object.
function GSL.agent:update_position(curTime)
	if(not self.is_local) then
		local nid_name = tostring(self.nid);
	
		local player = ParaScene_GetObject(nid_name);
		-- only animate sentient object
		if(player:IsSentient() and self.y) then
			local x,y,z = player:GetPosition();
			if(self.x~=x or self.y~=y or self.z~=z) then
				player:ToCharacter():MoveTo(self.x-x, self.y-y, self.z-z);
			end
		end
	end
end

-- if there is avatar in the scene. 
function GSL.agent:has_avatar()
	return not self.is_cleanedup;
end

-- virtual: call this function when agent is first created. 
-- @param self: the agent structure.
function GSL.agent.OnCreateAgent(self, nid_name)
	if(self.x and self.y and self.z) then
		LOG.std("", "debug", "GSL", "GSL_agent %s is created in the scene.", nid_name);

		-- create only a dummy character, we will only create a full CCS character when the character is in view range.
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
			silentmode = true,
			SkipHistory = true,
			obj_params = {
				name = nid_name,
				AssetFile = "", 
				x = self.x,
				y = self.y,
				z = self.z,
				IsCharacter = true,
				IsPersistent = false, -- do not save an GSL agent when saving scene
			},
		})
		-- make the newly created object special. 
		-- assign attributes and related settings for newly created character
		GSL.agent.SetAttributeForAgent(nid_name);
	end
end

-- called when update the appearance 
function GSL.agent.OnUpdateAgent(self, player)
	local is_sentient = player:IsSentient();
	if(self.x and self.y and self.z) then
		-- NOTE by andy 2009/11/3: refresh the OPC movement style in case of MovementStyle turn off
		--		firecracker object will turn off the OPC movement style to normal to apply FallDown physics on hit
		--		the player movement rely on this refresh logic to turn back to OPC movement style
		local att = player:GetAttributeObject();
		-- make it OPC movement style
		att:SetField("MovementStyle", 4)
			
		-- we shall only animate character position if the current agent is not mounted. 
		if((not self.is_mounted or not player:ToCharacter():IsMounted()) and not self.is_local) then
			-- just normal update
			local x,y,z = player:GetPosition();
			
			local deltaXZ = math_abs(x-self.x) + math_abs(z-self.z);
			local deltaY = math_abs(y-self.y);
			
			if(not is_sentient or deltaXZ > 70 or deltaY > 1000 and IsAriesAgent) then
				-- in Aries project on different user height, CCS info string will be applied in different behaviors
				-- apply the css info string: self.ccs
				if(not player:ToCharacter():IsMounted()) then
					player:SetPosition(self.x, self.y, self.z);
					player:UpdateTileContainer();
					if(self.facing ~= nil) then
						if(math_abs(player:GetFacing() - self.facing)>0.01) then
							player:SetFacing(self.facing);
						end	
					end
				end
			elseif(deltaXZ > 0.1 and not (type(self.anim) == "string" and self.anim~="")) then
				-- only if agent is sentient will we move with animation
				if(not player:ToCharacter():IsMounted()) then
					if(self.facing) then
						-- encode facing in MoveTo command. 
						player:ToCharacter():MoveAndTurn(self.x-x, self.y-y, self.z-z, self.facing);
					else
						player:ToCharacter():MoveTo(self.x-x, self.y-y, self.z-z);
					end
				end
			else
				-- original implementation
				-- if we are almost there, just set at precise location and facing
				-- TODO: if agents are not in the same world (different terrain heights), we may allow the self.y to be player.y. 
				if(not player:ToCharacter():IsMounted()) then
					player:SetPosition(self.x, self.y, self.z);
					player:UpdateTileContainer();
					
					if(self.facing~=nil) then
						if(math_abs(player:GetFacing()-self.facing)>0.01) then
							player:SetFacing(self.facing);
						end	
					end
				end
			end	
		end	
	end
	if(is_sentient) then
		-- only update if agent is sentient (within view range). 
		self:update_from_viewcache(player);
	end
end

-- update a agent's 3D avatar according to information in the agent structure. 
-- if the 3d avatar is not created before, it will be created. If agent structure 
-- does not get enough information to create, it will ignore updating until the server 
-- has got enough information from the client. 
function GSL.agent:update(curTime)
	local nid_name = tostring(self.nid);
	
	local player = ParaScene_GetObject(nid_name);

	self.is_cleanedup = nil;

	if(player:IsValid() == false) then
		all_agents[nid_name] = self;
		self.last_ccs = nil;
		self.OnCreateAgent(self, nid_name);
	else
		self.OnUpdateAgent(self, player);
	end
end

-- insert creation related data to agent streams.
function GSL.agent:GenerateCreationStream(agentStream)
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
	--LOG.debug("we are here %s, %s", tostring(self.LastCreationHistoryTime), tostring(time));
	
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
					-- secretly change the name of the operation to the client nid
					local new_msg = {author = self.nid}
					commonlib.partialcopy(new_msg, msg);
					agentStream.creations[table.getn(agentStream.creations)+1] = new_msg;
					
					LOG.std("", "debug","GSL", "creation stream is generated at time %d", t);
					LOG.std("", "debug","GSL", new_msg);
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
					-- secretly change the name of the operation to the client nid
					local new_msg = {author = self.nid}
					commonlib.partialcopy(new_msg, msg);
					agentStream.env[table.getn(agentStream.env)+1] = new_msg;
				end
			end
			self.LastEnvHistoryTime = time;
			-- compress to reduce redundencies 
			GSL.CompressEnvs(agentStream.env);
		end	
	end
end

-- if suspend update, GSL agent will skip self update, ex. prevent camera lookat position as the player
local suspend_self_update = false;
local hide_self_from_scene = false;

-- set suspend_self_update
function GSL.SuspendSelfUpdate(bSuspend)
	suspend_self_update = bSuspend;
end

-- set suspend_self_update
function GSL.HideSelfFromScene(bHide)
	hide_self_from_scene = bHide;
end

-- update this agent data from a player. 
-- @param player: if this is nil, the current player is used
-- @timeid: time to write to history. if nil, it will write to each field history (time, value) pairs. 
function GSL.agent:UpdateFromPlayer(player, timeid)

	if(suspend_self_update) then
		self.GTwo = false;
		local ccs = CCS.GetCCSInfoString_for_GSL_agent()
		if(self.ccs == nil or self.ccs~=ccs) then
			self.ccs=ccs;
			self.GTwo = true;
		end
		self:UpdateFromSelf(timeid)
		return;
	end

	player = player or ParaScene.GetPlayer();

	if(player:IsValid()) then
		---------------------------------
		-- data sent in each packet: current position, facing, animation, etc
		---------------------------------
		self.x,self.y,self.z = player:GetPosition();

		if(hide_self_from_scene) then
			self.x = self.x + 5000;
			self.y = -12345;
		end

		self.facing = player:GetFacing();

		-- Uncomment following to boardcast all anim with id >2000
		-- get current animation.
		--local anim = player:ToCharacter():GetAnimID();
		--if(anim>=2000) then
			--self.anim = commonlib.Encoding.DefaultToUtf8(player:ToCharacter():GetAnimFileName());
		--else
			--self.anim = "";
		--end

		---------------------------------
		-- group 2 sent on demand or changed: appearance, scaling, etc
		---------------------------------
		-- whether group 2 infor is changed. It is usually for character appearance. We only send group 2 on demand or changed. 
		-- TODO: this Logics of self.change is wrong. Instead a time value in each client agent should be used to decide whether it has missed any appearance updates. 		
		self.GTwo = false;
		
		if(not IGNORE_ASSETFILE_UPDATE or self.AssetFile ~= player:GetPrimaryAsset():GetKeyName()) then
			self.AssetFile = player:GetPrimaryAsset():GetKeyName();
			self.GTwo = true;
		end
		
		--if(self.scaling==nil or math_abs(self.scaling -player:GetScale())>0.01) then
			--self.scaling  = player:GetScale();
			--self.GTwo = true;
		--end
		
		local ccs = CCS.GetCCSInfoString_for_GSL_agent(player)
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
function GSL.agent:print_history()
	if(self.history) then
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

-- update player position with the input.  
-- @param delta
-- return rx,ry,rz. they may be nl if not changed or the change is smaller then delta. 
function GSL.agent:UpdatePosition(x,y,z, delta)
	local rx, ry, rz;
	if(self.x ~= x) then
		if(self.gx and x) then
			self.rx = x-self.gx
		else
			self.rx = x
		end
		if(not delta or (not self.x or not x or math_abs(self.x-x)>delta)) then
			rx = self.rx;
		end
		self.x = x;
	end

	if(self.z ~= z) then
		if(self.gz and z) then
			self.rz = z-self.gz
		else
			self.rz = z
		end
		if(not delta or (not self.z or not z or math_abs(self.z-z)>delta)) then
			rz = self.rz;
		end
		self.z = z;
	end

	if(self.y ~= y) then
		if(not delta or (not self.y or not y or math_abs(self.y-y)>delta)) then
			ry = y;
		end
		self.y = y;
	end

	return rx, ry, rz;
end

-- save current agent.* changes to track history
function GSL.agent:UpdateFromSelf(timeid)
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
					tracker = GSL.ValueTracker:new();
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
function GSL.agent:UpdateFromStream(stream, timeid)
	if(type(stream) == "string") then
		timeid = timeid or 0;
		local opcode, data
		for opcode, data in string_gmatch(stream, "(%d+):([^\n]+)") do
			opcode = tonumber(opcode);
			local opcode_parser = opcodes[opcode];
			if(opcode_parser) then
				if(data~=nil) then
					local tracker = self.history[opcode_parser.name];
					if(not tracker) then
						tracker = GSL.ValueTracker:new();
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
function GSL.agent:GenerateUpdateStream(timeid)
	local stream;
	if(self.history) then
		timeid = timeid or 0
		local fieldname, tracker;
		for fieldname, tracker in pairs(self.history) do
			local opcode_parser = GetOpcodeParser(fieldname);
			if(opcode_parser) then
				local value = tracker:GetValue();
				--LOG.debug("name %s value %s \n", fieldname, tostring(value))
				if(value~=nil and tracker:IsUpdated(timeid)) then
					if(stream) then
						stream = format("%s\n%d:%s", stream, opcode_parser.opcode, value);
					else
						stream = format("%d:%s", opcode_parser.opcode, value);
					end
				end
			end	
		end
	end
	return stream
end

local ccs_equip_positions = {34, 31, 32, 33, 40, 41, 42, 43, 44, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 35, 30, 51, 52};

-- the gsl module calls this function is validate ccs info for the server agent. 
function GSL.agent:ServerValidate(timeid)
	local tracker = self:GetDataTracker("ccs");
	if(tracker) then
		local ccs, time = tracker:GetValue(), tracker:GetTime();
		if(time == timeid and ccs and PowerItemManager.IfOwnGSItem) then
			local equip_string = string.match(ccs, "[^@]+@[^@]+@([^@]+)");

			if(equip_string) then
				local i = 0;
				local value_str;
				local is_syncing;
				
				for value_str in string.gmatch(equip_string, "([^#]+)") do
					i = i + 1;
					local gsid;
					local position = ccs_equip_positions[i];
					if(position == 31 or position == 32) then	
						-- 31 mount pet, 32 follow pet
						gsid = tonumber(value_str);
					elseif(position == 51) then	
						-- transform gsid, must be bigger than 10.
						gsid = tonumber(value_str);
					end
					if(gsid and gsid>10) then
						local gsids_ = self.gsids_;

						-- we will remember objects that is once owned by this agent. 
						if(not gsids_) then
							gsids_ = {};
							self.gsids_ = gsids_;
						end
						
						local gsid_state = gsids_[gsid];
						if(gsid_state ~= true) then
							if(gsid_state == false) then
								-- the user is cheating us, so we remember it and avoid checking the user again and again. 
								tracker:Rollback();
							elseif(self.sync_item_ == "pending") then
								-- we are still verifying the data
								if(PowerItemManager.IfOwnGSItem(self.nid, gsid)) then
									gsids_[gsid] = true;
								else
									gsids_[gsid] = "pending";
									if(not is_syncing) then
										is_syncing = true;
										tracker:Rollback();
									end
								end
							else
								if(not PowerItemManager.IfOwnGSItem(self.nid, gsid)) then
									gsids_[gsid] = "pending";
									
									if(not is_syncing) then
										is_syncing = true;
										tracker:Rollback();
										
										local last_time, last_value = tracker:GetTime(-1), tracker:GetTime(-1);
										-- force update the character bag 0 for fast validation. 
										PowerItemManager.SyncUserItems(tonumber(self.nid), {0}, function(msg) 
											local gsid_, state_, need_rollback;
											for gsid_, state_ in pairs(gsids_) do
												if(state_ == "pending") then
													if(not PowerItemManager.IfOwnGSItem(self.nid, gsid)) then
														gsids_[gsid] = false;
														LOG.std(nil, "warn", "servercheck", "rolling back ccs info for nid %s, because gsid %s is not owned by it. ", self.nid, gsid)
														need_rollback = true;
													else
														gsids_[gsid] = true;
													end
												end
											end
											
											if(need_rollback) then
												-- TODO: shall we kick the user out of the game?
											else
												-- update the mount pet
												local time_now = tracker:GetTime()
												if( not time_now ) then
													tracker:CheckPush(time, ccs);	
												elseif(time_now <= time) then
													tracker:Update(time, ccs);	
												end
											end
										end, function() 
											-- timed out
											self.sync_item_ = nil;
										end);
									end
								else
									gsids_[gsid] = true;
								end
							end
						end
					end
				end
			end
		end
	end
	return true;
end

function GSL.agent:GetDataTracker(fieldname)
	if(self.history) then
		local tracker = self.history[fieldname];
		if(tracker) then
			return tracker;
		end
	end
end

-- sign out this agent and remove it from its container cell.
-- @param bInformUser: TODO: true to inform the user. 
function GSL.agent:SignOut(bInformUser)
	self.state = 3;
	if(self.cell) then
		self.cell:RemoveAgent(self);
	end
end

-- sign in this agent.
-- @param state: the initial agent state. -- type of agentstate: nil for unknown, 1 for agent, 2 for observer
function GSL.agent:SignIn(state)
	self.state = state;
end

-- force this agent to renew itself. This function is called by the GSL_client before sending an agent to its timeout pool for later reuse. 
-- self.history, self.LastActiveTime and avatar position, etc are reset. 
function GSL.agent:Renew()
	self.history = {};
	self.LastActiveTime = nil;
end

-- send a message to this agent. 
-- @param filename: the file name on the agent's computer. 
-- @param msg: the message to send. 
-- @param proxy: this is ususlly nil. or it can be a table like {addr="(w1)server1"}, in which case messages are send to the nid via a given proxy server. 
--  please note, the proxy server must has an authenticated connection to nid in advance in order for the message to be sent successfully.
--  currently, chained proxies are not supported yet. we may support it in future. 
-- @return 0 if succeed, otherwise it is -1(for not signed in) or some NPL.activate errorcode. 
function GSL.agent:SendMessage(filename, msg, proxy)
	if(self.state ~= 3) then
		-- forward cid
		msg.cid = self.cid; 
		
		-- if not logged out
		if(not proxy) then
			local res;
			if(self.nid == "localuser") then
				msg.nid = "localuser";
				res = NPL.activate(filename, msg);
			else
				res = NPL.activate(self.nid..":"..filename, msg);
			end
			if(res==0) then
				self:tickSend();
			else
				self:SignOut();
			end
			return res;
		else
			GSL_proxy:SendMessage({addr=proxy.addr, dest={addr=self.nid} }, filename, msg)
		end	
	end	
	return -1;
end

-- add a real time message to the rt_queue.
-- It will be sent almost at real time to the server. 
-- The server will forward it to other connected player almost at real time too. 
-- the most common use of real time message is BBS chat room. 
-- e.g. agent:AddToRealtimeQueue({name="chat", value="hello world"})
-- @param msg: it is a table of {name, value}, name and value should be encoded with opcodes during transmission. 
-- for supported item.name, please see GSL_opcodes.lua and Map3DSystem.GSL.rt_opcodes
function GSL.agent:AddToRealtimeQueue(msg)
	self.rt_queue = self.rt_queue or {};
	msg.time = msg.time or ParaGlobal.timeGetTime();
	self.rt_queue[#(self.rt_queue) + 1] = msg;
end

-- add a real time message to the data_queue.
-- this function is similar to AddRealtimeMessage except that it will be sent via agentStream.data instead of agentStream.rt.
-- The server will update its agent struct according to agentStream.data.
function GSL.agent:AddToDataQueue(msg)
	self.data_queue = self.data_queue or {};
	msg.time = msg.time or ParaGlobal.timeGetTime();
	self.data_queue[#(self.data_queue) + 1] = msg;
end

-- insert any queued realtime commands to agent streams.
-- This function is called by client at fixed interval for real time messages (such as Chat, position, etc). 
-- It should generate agent streams for any queued real time commands since the last call.
-- @param agentStream: It is a table to be send via network. we should append any realtime stream to agentStream.rt
-- @return true if some items are added to agentStream. 
function GSL.agent:GenerateRealtimeStream(agentStream)
	local res;
	res = self:SerializeQueueToStream(agentStream, "rt");
	res = self:SerializeQueueToStream(agentStream, "data") or res;
	return res;
end

-- this function is called by the client to serialize a given queue table to string
-- @param agentStream: It is a table to be send via network. we should append any realtime stream to agentStream[name]
-- @param name: queue name. currently only "rt" and "data" queue are supported. i.e. rt_queue,  data_queue tables.
function GSL.agent:SerializeQueueToStream(agentStream, name)
	local stream;
	local queue_name = name.."_queue";
	if(self[queue_name]) then
		local curTime = ParaGlobal.timeGetTime();
		local _, item 
		for _, item in pairs(self[queue_name]) do
			-- if there is stream on the item, just append it, otherwise encode using a parser. 
			-- we will ignore any message that is over 3000ms old. 
			--if(item.time or (curTime - item.time) < 3000) then
				if(item.stream) then
					if(stream) then
						stream = format("%s\n%s", stream, item.stream);
					else
						stream = item.stream;
					end
				elseif(item.name) then
					local opcode_parser = GetOpcodeParser(item.name);
					if(opcode_parser) then
						local value = opcode_parser:write(item.value);
						if(value~=nil) then
							if(stream) then
								stream = format("%s\n%d:%s", stream, opcode_parser.opcode, value);
							else
								stream = format("%d:%s", opcode_parser.opcode, value);
							end
						end	
					end	
				end
			--end
		end
		self[queue_name] = nil;
	end
	if(stream) then
		if(agentStream[name]) then
			agentStream[name] = format("%s\n%s", agentStream[name], stream);
		else
			agentStream[name] = stream;
		end
		return true;
	end
end

-- default opcode handler
local function default_opcode_handler(nid, opcode, value)
	if(opcode == opcode_names.chat) then
		-- handle chat messages
		if(on_receive_chat_msg) then
			on_receive_chat_msg(nid, value);
		end
	elseif(opcode == opcode_names.action) then
		-- 	handle chat messages
		--LOG.debug("%s acts: %s\n", nid, value)
		NPL.load("(gl)script/apps/Aries/Player/ThrowBall.lua");
		CommonCtrl.ThrowBall.HandleMessage(value)
		-- TODO: 
	elseif(opcode == opcode_names.sig) then
		-- TODO: one time signal message
		if(value == "jump") then
			local player = ParaScene_GetObject(tostring(nid));
			if(player:IsValid() and ParaScene_GetObject("<player>"):DistanceTo(player)<100) then
				local char = player:ToCharacter();
				if(char:IsValid())then
					char:AddAction(action_table.ActionSymbols.S_JUMP_START);
				end
			end
		end
	elseif(opcode == opcode_names.anim) then
		-- 	handle animation messages
		LOG.std("", "user", "GSL", "%s play animation: %s", nid, value);
		local command = System.App.Commands.GetCommand("Profile.Aries.PlayAnimationFromValue");
		command:Call({nid = nid, value = value,});
	else
		-- TODO: add other real time handlers here. 	
	end
end

-- this function is called when it receive some real time message from the server
-- this is something similar to self:UpdateFromStream
-- @param stream: the opcode encoded string
-- @param opcode_handler: it can be nil where the default handler is used. or it can be function(nid, opcode, value)  end
-- @return true if there is normal update in the stream. or nil if there is only real time update.
--  usually the client needs to update the agent's avatar position when this function returns true.
function GSL.agent:OnNetReceive(stream, opcode_handler)
	opcode_handler = opcode_handler or default_opcode_handler;
	
	if(type(stream) == "string") then
		local bHasNormalUpdate;
		timeid = timeid or 0;
		local opcode, data
		for opcode, data in string_gmatch(stream, "(%d+):([^\n]+)") do
			opcode = tonumber(opcode);
			local opcode_parser = rt_opcodes[opcode];
			if(opcode_parser and data~=nil) then
				local value = opcode_parser:read(data);
				opcode_handler(self.nid, opcode, value);
			else
				opcode_parser = opcodes[opcode];
				if(opcode_parser) then
					bHasNormalUpdate = true;
					local value = opcode_parser:read(data);
					self[opcode_parser.name] = value;

					if(opcode == opcode_names.rx) then
						self.x = self.rx+(self.gx or 0)
					elseif(opcode == opcode_names.rz) then
						self.z = self.rz+(self.gz or 0)
					end
				end
			end
		end
		return bHasNormalUpdate;
	end
end