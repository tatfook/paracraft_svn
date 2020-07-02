--[[
Title: Base character class for both the main Player and OPC. 
Author(s): LiXizhi
Date: 2010/1/31
Desc: common functions for character objects in the scene. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Player/BaseChar.lua");
MyCompany.Aries.BaseChar.MountOn({nid=src_nid, model})
MyCompany.Aries.BaseChar.UnMount({nid})
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/GameServer/GSL.lua");
-- create class
local BaseChar = commonlib.gettable("MyCompany.Aries.BaseChar");

local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");

-- Mount a given character to another object or player
-- @param params: a table of {nid, model, slot_index,}
function BaseChar.MountOn(params)
	local nid = params.nid;
	local agent = GSL_client:FindAgent(tostring(nid));
	if(agent) then
		agent.is_mounted = true;
	else
		return
	end
	
	if(params.model and params.model:IsValid() == true) then
		local player = ParaScene.GetObject(tostring(nid));
		if(player:IsValid()) then
			player:ToCharacter():MountOn(params.model, params.slot_index);
		end
		-- TODO: mount the character to model
	end
end

-- @param params: a table of {nid}
function BaseChar.UnMount(params)
	local nid = params.nid;
	local agent = GSL_client:FindAgent(tostring(nid));
	if(agent) then
		agent.is_mounted = false;
	else
		return;
	end

	local player = ParaScene.GetObject(tostring(nid));
	if(player:IsValid()) then	
		local char = player:ToCharacter()
		if(char:IsMounted()) then
			char:UnMount();
			if(agent.x and agent.y and agent.z) then
				player:SetPosition(agent.x, agent.y, agent.z);
				player:ToCharacter():PlayAnimation(0);
				-- TODO: shall we play some standing animation when player is unmounted from something. 
			end
			if(params.position) then
				player:SetPosition(params.position.x, params.position.y, params.position.z);
				player:ToCharacter():PlayAnimation(0);
			end
		end	
	end
end

function BaseChar.SetLocal(nid)
	local agent = GSL_client:FindAgent(tostring(nid));
	if(agent) then
		agent.is_local = true;
	end
end

function BaseChar.SetUnLocal(nid)
	local agent = GSL_client:FindAgent(tostring(nid));
	if(agent) then
		agent.is_local = false;
	end
end

-- set animation and anim frame of a given character or model 
-- @param obj: the object itself or object name. 
-- @param AnimID: 
-- @param AnimFrame: 
function BaseChar.SetAnimationDetail(obj, AnimID, AnimFrame)
	if(type(obj) == "string") then
		obj = ParaScene.GetObject(obj);
	end
	local att = obj:GetAttributeObject();
	att:SetField("UseGlobalTime", true);
	att:SetField("AnimID", AnimID);
	att:SetField("AnimFrame", AnimFrame);
end

