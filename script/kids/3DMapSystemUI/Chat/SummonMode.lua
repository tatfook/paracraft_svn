--[[
Title: Summon mode
Author(s): LiXizhi
Date: 2008/7/16
Desc: The idea of summon mode is to select a few from online people. and display their avatars' agent near the current player avatar. 
In this case, the current user can communicate with agents face to face without compromising other people. The communication, however, is limited to 
chat and animation. The agent movement is usually AI based such as facing to the speaking character near it. 

The procedure is as below
- start the summon effects on the current player
- make remote requests to selects a given number of uids from a given pool (such as online users and recently BBS speaking users)
- find their JIDs from their uids. 
- for each candidate{
		if(avater with JID does not exist) then
			if(filter(IsFriend or JustSpeaked)) then
				retrieve its avatar ccs info
					Create a character using its JID, make it non-persistent. 
					create the agent avatar as agent OPC in the scene. 
					mark the agent with agent head on display 
					Assign agent AI module to the agent OPC. (more info, please see SummonedAgent.lua)
			end	
		end	
		move the player to a location near the current character.
		play summon effects and animation on the agent for 2 seconds. 
  }

the context menu for agent includes
- teleport to avater of the agent. 
- private chat. 
- see profile of its user.
- recast as local character.
- delete (ban) this candiate

Whenever the user receives or sends a BBS message in public or world channels. it will search in OPC and main player and display head on text for some seconds. 

---++ Additional agent functions
Instead of avatars, one can also summon pets from other offline/online players and adopt them in their world. One can right click on an agent and recast(rename) it as a local character.

---++ blocking an agent 
call Map3DSystem.App.Chat.SummonMode.BlockAgent(JID)

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/SummonMode.lua");
Map3DSystem.App.Chat.SummonMode.Activate()
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/ide/headon_speech.lua");

-- create class
local SummonMode = {};
commonlib.setfield("Map3DSystem.App.Chat.SummonMode", SummonMode);

-- max summon spawning radius
SummonMode.spawn_radius = 6;

-- private: current summon candidates, mapping from uid to candidate table.
local candidates = {}

-- summon mode page init
function SummonMode.OnInit()
	-- local self = document:GetPageCtrl();
end

-- fire the summon effect at a given position. It is just a particle effect that moves slowly at above head position.
-- where fromX, fromY, fromZ is position at feet height. 
function SummonMode.CallSummonEffect(fromX, fromY, fromZ)
	fromY = fromY + 1.7;
	toX, toY, toZ = fromX, fromY+0.3, fromZ
	-- fire for 6 seconds
	ParaScene.FireMissile(3, (toY-fromY)/6, fromX, fromY, fromZ, toX, toY, toZ);
end

-- activate the summon mode immediately. 
function SummonMode.Activate()
	autotips.AddMessageTips("正在召唤周围的用户替身到你的身边");
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		local fromX, fromY, fromZ = player:GetPosition();
		SummonMode.CallSummonEffect(fromX, fromY, fromZ)
		Map3DSystem.Animation.SendMeMessage({type = Map3DSystem.msg.ANIMATION_Character,animationName = "Summon"});
		SummonMode.SelectCandidates();
	end	
end

-- make remote requests to selects a given number of uids from a given pool (such as online users and recently BBS speaking users)
function SummonMode.SelectCandidates()
	local MyJID = Map3DSystem.JGSL.GetJID()
	if(MyJID == nil or MyJID=="") then
		autotips.AddMessageTips("您没有登录到JGSL服务器, 无法使用召唤");
		return;
	end
	local chatdomain = string.match(MyJID, "@([%w%.]+)")
	local msg ={
		query = "select uid,uname,createDate from users where isOnline = 1",
		cache_policy = "access plus 30 seconds",
	}
	local bFetching = paraworld.MQL.query(msg, "paraworld", function(msg)
		if(msg) then
			local n, v;
			local dsTable;
			for n, v in pairs(msg) do
				if(type(v)=="table") then
					-- use the first found table as response table
					dsTable = v;
					break;
				end
			end
			if(dsTable) then
				Map3DSystem.Animation.SendMeMessage({type = Map3DSystem.msg.ANIMATION_Character,animationName = "Summon"});
				
				local index, userInfo
				-- for each candidate 
				for index, userInfo in ipairs(dsTable) do
					local JID = string.format("%s@%s", string.lower(userInfo.uname), chatdomain);
					if(JID~=MyJID) then
						local candidate = candidates[JID];
						if(not candidate) then
							candidate = {
								JID = JID,
								createDate = userInfo.createDate,
								uid = userInfo.uid,
							}
							candidates[JID] = candidate;
						end
						
						if(candidate.JID and not candidate.blocked) then
							-- TODO: if(filter(IsFriend or JustSpeaked)) then
							SummonMode.InitAgent(candidate)
						end	
					end	
				end
			end
		end
	end);
end


-- initialize the agent, it will try to fetch its appearance first if not fetched before. 
function SummonMode.InitAgent(candidate)
	if(not candidate or not candidate.JID or not candidate.uid) then return end
	local player = ParaScene.GetObject(candidate.JID);
	if((player:IsValid() == false) and not candidate.AssetFile) then
		candidate.bFetching = Map3DSystem.App.CCS.app:GetMCML(candidate.uid, function(uid, app_key, bSucceed)
			local profile;
			if(bSucceed) then
				profile = Map3DSystem.App.CCS.app:GetMCMLInMemory(uid);
				
				if(profile and profile.CharParams and profile.CharParams.AssetFile) then
					-- modify the appearance of the current player according to CCS profile box data. 
					candidate.AssetFile = profile.CharParams.AssetFile;
					candidate.CCSInfoStr = profile.CharParams.CCSInfoStr;
					if(candidate.AssetFile) then
						SummonMode.CreateAgent(candidate)
					end
				end
			else
				commonlib.log("warning: error fetching ccs from candidate %s\n", candidate.JID);
			end
		end, System.localserver.CachePolicies["1 day"])
	else
		SummonMode.CreateAgent(candidate);
	end
end


-- we will prevent the given JID from being added as an agent. 
function SummonMode.BlockAgent(JID, bUnblock)
	candidates[JID] = candidates[JID] or {};
	candidates[JID].blocked = not bUnblock;
end

-- create a given agent avatar if it has not created before. It will fire the summon effect.
-- @param candidate: a table of {JID, uid, CCSInfoStr[optional]}
function SummonMode.CreateAgent(candidate)
	if(not candidate or not candidate.JID or not candidate.uid) then return end
	local player = ParaScene.GetObject(candidate.JID);
	if(player:IsValid() == false) then
		-- create if we have gathered enough information
		local assetfile = candidate.AssetFile or Map3DSystem.JGSL.DefaultAvatarFile;
		
		-- pick a random position. 
		candidate.x, candidate.y, candidate.z = ParaScene.GetPlayer():GetPosition();
		local radius = SummonMode.spawn_radius;
		candidate.x = (math.random()*2-1)*radius + candidate.x;
		candidate.z = (math.random()*2-1)*radius + candidate.z;
		
		SummonMode.CallSummonEffect(candidate.x, candidate.y, candidate.z);
		
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
			silentmode = true,
			obj_params = {
				name = candidate.JID,
				AssetFile = assetfile,
				CCSInfoStr = candidate.CCSInfoStr or Map3DSystem.JGSL.DefaultAvatarCCSStrings[assetfile],
				x = candidate.x,
				y = candidate.y,
				z = candidate.z,
				facing = math.random()*6.28,
				IsCharacter = true,
				IsPersistent = false, -- do not save an GSL agent when saving scene
			},
		})
		
		player = ParaScene.GetObject(candidate.JID);
		if(player:IsValid()) then
			player:SnapToTerrainSurface(0);
			local att = player:GetAttributeObject();
			-- this prevents user switch to GSL agent
			att:SetDynamicField("IsOPC", true);
			att:SetDynamicField("IsAgent", true);
			att:SetDynamicField("uid", candidate.uid);
			-- prevent head on text to be removed. 
			att:SetDynamicField("AlwaysShowHeadOnText", true);
			
			-- for head on text
			local displayname = string.gsub(candidate.JID, "@.*$", "");
			att:SetDynamicField("name", displayname);
			att:SetDynamicField("JID", candidate.JID);
			-- show head on text
			Map3DSystem.ShowHeadOnDisplay(true, player, Map3DSystem.GetHeadOnText(player));
			
			-- change head on model to a ring. 
			headon_speech.ChangeHeadMark(candidate.JID, "ring_head");
			
			-- TODO: Assign some summon mode AI module
			local px,py,pz = player:GetPosition();
			local radius = math.random()*10+1;
			att:SetField("On_FrameMove", string.format([[;NPL.load("(gl)script/AI/templates/SummonedAgent.lua");_AI_templates.SummonedAgent.On_FrameMove(%d, %.1f, %.1f);]], radius, px,pz));
		end
	else
		-- TODO: update the agent such as AssetFile or CCSInfoStr
		
		if(player:GetAttributeObject():GetDynamicField("IsAgent", false)) then
			local x, y, z = player:GetPosition();
			-- if the agent is too far from the current player, correct its position. 
			local px, py, pz = ParaScene.GetPlayer():GetPosition();
			if((math.abs(px-x) + math.abs(pz-z))>SummonMode.spawn_radius*2) then
				x = (math.random()*2-1)*SummonMode.spawn_radius + px;
				z = (math.random()*2-1)*SummonMode.spawn_radius + pz;
				player:SetPosition(x, py, z);
				player:SnapToTerrainSurface(0);
				x, y, z = player:GetPosition();
				
				
				-- TODO: Reassign some summon mode AI module: this code needs to be refactored to prevent duplication
				local radius = math.random()*10+1;
				att:SetField("On_FrameMove", string.format([[;NPL.load("(gl)script/AI/templates/SummonedAgent.lua");_AI_templates.SummonedAgent.On_FrameMove(%d, %.1f, %.1f);]], radius, x,z));
			end
			SummonMode.CallSummonEffect(x, y, z);
		end	
	end
end

function SummonMode.UpdateAgent(candidate)
end