--[[
Title: Other Player Character(OPC)
Author(s): LiXizhi
Date: 2009/12/1
Desc: the JGSL_agent agent automatically uses the following template to create OPC agent in the scene. 
It will automatically set the visibility and sensibility of opc, follow pet and mount follow pet to keep 
overall environment simulation to minimum.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Player/OPC.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Pet/FollowPet_FollowAI.lua");
NPL.load("(gl)script/apps/Aries/Pet/MountPet_FollowAI.lua");
local FollowPet_FollowAI = commonlib.gettable("MyCompany.Aries.Pet.FollowPet_FollowAI");
local MountPet_FollowAI = commonlib.gettable("MyCompany.Aries.Pet.MountPet_FollowAI");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

-- create class
local OPC = commonlib.gettable("MyCompany.Aries.OPC");

local SentientGroupIDs = commonlib.gettable("MyCompany.Aries.SentientGroupIDs");
local ParaScene_GetObject = ParaScene.GetObject;

-- OPC farther from the current player will not be sentient (and visible)
OPC.sentient_radius = 50;

-- call this function once
function OPC.Init()
	if(not OPC.is_inited) then
		OPC.is_inited = true;

		if(not System.options.mc) then
			Map3DSystem.GSL.SetAgentEnterSentientCallback(OPC.On_EnterSentientArea);
			Map3DSystem.GSL.SetAgentLeaveSentientCallback(OPC.On_LeaveSentientArea);
		end
	end
end


-- this function should be called when world is loaded. 
function OPC.OnWorldLoaded()
	if(WorldManager:IsInPublicWorld()) then
		OPC.sentient_radius = 50;
	else
		OPC.sentient_radius = 150;
	end
end


-- the default function to be called when GSL avatar is created. this function can be replaced by SetDefaultAttribute
-- @param nid: 
-- @param player: this is always a valid ParaObject. 
function OPC.on_avatar_created(nid, player)
	Player.ShowHeadonTextForNID(nid, player);
	player:SetField("Sentient Radius", OPC.sentient_radius);
end

-- whenever OPC enters sentient area, it does the following things
-- 1. make the OPC visible 
-- 2. make the mountpet visible and sentient with OPC, and then move it near the OPC. 
-- 3. make the followpet visible and sentient with OPC, and then move it near the OPC. 
function OPC.On_EnterSentientArea()
	local SentientGroupIDs = SentientGroupIDs;
	
	--commonlib.log("Enter %s\n", sensor_name)
	
	local _opc = ParaScene_GetObject(sensor_name);
	if(_opc:IsValid()) then
		_opc:SetVisible(true);
		_opc:SetField("RenderImportance", -1);
		if(_opc:IsSentient() == true) then
			Player.ShowHeadonTextForNID(tonumber(sensor_name), _opc)
		end
	end
	
	local opc_name = sensor_name;
	sensor_name = opc_name.."+mountpet-follow";
	local _mountpet_follow = ParaScene_GetObject(sensor_name);
	if(_mountpet_follow:IsValid()) then
		-- this will bring the follow pet to 
		_mountpet_follow:SetVisible(true);
		_mountpet_follow:SetSentientField(SentientGroupIDs["OPC"], true);
		_mountpet_follow:SetField("RenderImportance", -1);
		MountPet_FollowAI.On_LeaveSentientArea();
	end
	
	sensor_name = opc_name.."+followpet";
	local _followpet = ParaScene_GetObject(sensor_name);
	if(_followpet:IsValid()) then
		-- this will bring the follow pet to 
		_followpet:SetVisible(true);
		_followpet:SetSentientField(SentientGroupIDs["OPC"], true);
		_followpet:SetField("RenderImportance", -1);
		FollowPet_FollowAI.On_LeaveSentientArea();
	end

	local opc_driver = ParaScene_GetObject(opc_name.."+driver");
	if(opc_driver:IsValid()) then
		opc_driver:SetVisible(true);
		opc_driver:SetField("RenderImportance", -1);
	end
end

-- whenever OPC leaves the sentient area, it does the following things
-- 1. make the OPC invisible 
-- 2. make the mountpet invisible and unsentient with OPC, and then leave it where it is. 
-- 3. make the followpet invisible and unsentient with OPC, and then leave it where it is.
function OPC.On_LeaveSentientArea()
	local SentientGroupIDs = SentientGroupIDs;
	
	--commonlib.log("Leave %s\n", sensor_name)
	
	local _opc = ParaScene_GetObject(sensor_name);
	if(_opc and _opc:IsValid()) then
		_opc:SetVisible(false);
		-- 2011.4.26: this fixed a bug that when player is unsentient there is still a way point, so when it is sentient again, it will be drawn back.
		-- so we will remove all waypoints when OPC is not sentient. 
		_opc:ToCharacter():Stop();
	end
	
	local opc_name = sensor_name;
	sensor_name = opc_name.."+mountpet-follow";
	local _mountpet_follow = ParaScene_GetObject(sensor_name);
	if(_mountpet_follow and _mountpet_follow:IsValid()) then
		-- this will bring the follow pet to 
		_mountpet_follow:SetVisible(false);
		_mountpet_follow:SetSentientField(SentientGroupIDs["OPC"], false);
	end

	sensor_name = opc_name.."+followpet";
	local _followpet = ParaScene_GetObject(sensor_name);
	if(_followpet and _followpet:IsValid()) then
		-- this will bring the follow pet to 
		_followpet:SetVisible(false);
		_followpet:SetSentientField(SentientGroupIDs["OPC"], false);
	end

	local opc_driver = ParaScene_GetObject(opc_name.."+driver");
	if(opc_driver:IsValid()) then
		opc_driver:SetVisible(false);
	end
end

function OPC.MakePetSentient(_followpet, isSentient)
	_followpet:SetSentientField(SentientGroupIDs["OPC"], isSentient);
end

-- get school string of a nid
function OPC.GetSchool(nid, callbackFunc)
    return MyCompany.Aries.Combat.GetSchool(nid);
end

-- check if vip in memory
function OPC.IsVIP(nid, callbackFunc)
	nid = tonumber(nid);
	local bean = Pet.CreateOrGetDragonInstanceBean(nid, callbackFunc, "access plus 1 hour");
	if(bean) then
		return (bean.energy and bean.energy > 0);
	end
end

-- get combat level
function OPC.GetLevel(nid, callbackFunc)
	nid = tonumber(nid);
	local bean = Pet.CreateOrGetDragonInstanceBean(nid, callbackFunc, "access plus 1 hour");
	if(bean) then
		return bean.combatlel;
	end
end

-- mapping from nid to true or max_hp of a that nid.
local max_hp_map = {};

-- get max health point of a given nid. Internally we use a timer to query for 2 second until data is available. and we will invoke the callback
-- @param nid
-- @param callbackFunc: function (max_hp) end, 
-- Note this function is not called if data is returned immediately.
-- @return 0 or max hp
function OPC.GetMaxHP(nid, callbackFunc)
	nid = tonumber(nid);
	if(not nid) then 
		return 0 
	end
	local bForceRefresh;
	if(type(max_hp_map[nid]) == "number") then
		return max_hp_map[nid]
	elseif(type(max_hp_map[nid]) == true) then
	else
		bForceRefresh = true;
	end
	local hp, bAgentExist = Map3DSystem.GSL_client:GetAgentItem(nid, "mhp",nil, bForceRefresh);
	if(hp) then
		max_hp_map[nid] = hp;
	elseif(bForceRefresh and bAgentExist) then
		-- we use a timer to query for 2 second until data is available. and we will invoke the callback
		max_hp_map[nid] = true;
		local nTick = 0;
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			nTick = nTick + 1;
			if(nTick>10) then
				if(max_hp_map[nid] == true) then
					max_hp_map[nid] = false;
				end
				timer:Change();
			end
			local hp = Map3DSystem.GSL_client:GetAgentItem(nid, "mhp");
			if(hp) then
				max_hp_map[nid] = hp;
				timer:Change();
				if(callbackFunc) then
					callbackFunc(hp);
				end
			end
		end})
		mytimer:Change(100,200);
	end
	return hp or 100;
end