--[[
Title: object creation on client side
Author(s): LiXizhi
Date: 2006/11/1
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/ClientServerIncludes.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/commonlib.lua");

if(not client) then client={}; end

client.LastRequest = {	
	type = 0,
	name = "",
	filepath = "",
	x=0, y=0, z=0,
}
--[[ send a creation request to server. ]]
function client.RequestObjectCreation(ObjName, FilePath, pos, sCategoryName)
	local msg = {
		type = KMNetMsg.CS_RequestObjectCreation, -- creation ID
		name = ObjName,
		sCategoryName = sCategoryName,
		filepath = FilePath,
		x=pos[1], y=pos[2], z=pos[3],
	};
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

--[[ send a object modification request to server. 
@param obj: if nil, the current object is used. 
@param pos: nil or {x=0,y=0,z=0} which is global position.
@param scale: nil or double which is absolute scale.
@param quat: nil or {x=0,y=0,z=0,w=1} which is rotational quaternion.
]]
function client.RequestObjectModification(obj, pos, scale, quat)
	local msg = {
		type = KMNetMsg.CS_RequestObjectModification, -- modification ID
	};
	if(obj==nil or obj:IsValid() == false) then
		obj = ObjEditor.GetCurrentObj();
		if(obj == nil or obj:IsValid()==false) then
			return
		end
	end
	-- add other optional data fields to the packet.
	msg.viewbox = obj:GetViewBox({});
	msg.pos = pos;
	msg.scale = scale;
	msg.quat = quat;
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

--[[ send a deletion request to server. ]]
function client.RequestObjectDelete(obj)
	local msg = {
		type = KMNetMsg.CS_RequestObjectDelete, -- deletion 
	};
	if(obj==nil or obj:IsValid() == false) then
		obj = ObjEditor.GetCurrentObj();
		if(obj == nil or obj:IsValid()==false) then
			return
		end
	end
	-- add other optional data fields to the packet.
	msg.viewbox = obj:GetViewBox({});
	NPL.activate("@server:script/server/creation_server.lua",msg);
end


--[[ send a terrain update operation request to server.
@param cmd: 0 (dig or raise), 1(flatten), reset(3), smooth(4), roughen(5)
]]
function client.RequestTerrainModify(cmd,x,y,z,radius,height)
	local msg = {
		type = KMNetMsg.CS_RequestTerrainModify, -- terrain heightfield update
		cmd = cmd,
		x = x,
		y = y,
		z = z,
		radius = radius,
		height = height,
	};
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

-- Update texture texture, parameter is same as ParaTerrain.Paint()
function client.RequestTerrainTexModify(TexFile,x,y,z,brushsize, bErase)
	local msg = {
		type = KMNetMsg.CS_RequestTerrainTexModify, -- terrain texture
		TexFile = TexFile,
		x = x,
		y = y,
		z = z,
		brushsize = brushsize,
		bErase = bErase,
	};
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

-- request modify part of the ocean
function client.RequestOceanModify(height,bEnable, r,g,b)
	local msg = {
		type = KMNetMsg.CS_RequestOceanModify, -- ocean 
		height = height,
		bEnable = bEnable,
		r = r,
		g = g,
		b = b,
	};
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

-- request changing sky
function client.RequestSkyModify(skybox, r,g,b)
	local msg = {
		type = KMNetMsg.CS_RequestSkyModify, -- sky
		skybox = skybox, -- mesh file name
		r = r,
		g = g,
		b = b,
	};
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

-- request changing day time
function client.RequestTimeModify(timeofday)
	local msg = {
		type = KMNetMsg.CS_RequestTimeModify, -- time of day
		timeofday = timeofday, 
	};
	NPL.activate("@server:script/server/creation_server.lua",msg);
end

-- it just create or modify whatever it receives from the server. 
local function activate()
	--log(string.format("creation_log %s\r\n",commonlib.serialize(msg)));
	if(msg.type==KMNetMsg.SC_BroadcastObjectCreation and msg.filepath~=nil) then
		-- create a new object
		-- display some text for the creation.
		CommonCtrl.chat_display.AddText("chat_display1", "[creation]:"..msg.filepath);
		-- create it.
		local bSilentMode;
		if(msg.sender~=ParaNetwork.GetLocalNerveReceptorAccountName()) then
			bSilentMode = true;
		end
		ObjEditor.AutoCreateObject(msg.name, msg.filepath, {msg.x, msg.y, msg.z}, msg.sCategoryName, bSilentMode);
	elseif(msg.type==KMNetMsg.SC_BroadcastObjectModification and msg.viewbox~=nil)then
		-- modify an existing object
		local obj = ParaScene.GetObjectByViewBox(msg.viewbox);
		if(obj:IsValid() ==true) then
			if(msg.pos~=nil) then
				obj:SetPosition(msg.pos.x,msg.pos.y,msg.pos.z);
			end
			if(msg.scale~=nil) then
				obj:SetScale(msg.scale);
			end
			if(msg.quat~=nil) then
				obj:SetRotation(msg.quat);
			end
			ParaScene.Attach(obj);
		end
	elseif(msg.type==KMNetMsg.SC_BroadcastObjectDelete and msg.viewbox~=nil)then
		-- delete an existing object
		local obj = ParaScene.GetObjectByViewBox(msg.viewbox);
		if(obj:IsValid() ==true) then
			ObjEditor.DelObject(obj);
		end
	elseif(msg.type==KMNetMsg.SC_BroadcastTerrainTexModify)then
		-- terrain texture paint operation
		TerrainEditorUI.Paint(msg.TexFile,msg.x,msg.y,msg.z,msg.brushsize, msg.bErase);
	elseif(msg.type==KMNetMsg.SC_BroadcastOceanModify)	then
		-- ocean 
		TerrainEditorUI.UpdateOcean(msg.height,msg.bEnable, msg.r,msg.g,msg.b);
	elseif(msg.type==KMNetMsg.SC_BroadcastSkyModify)	then
		-- sky	
		TerrainEditorUI.UpdateSky(msg.skybox, msg.r,msg.g,msg.b);
	elseif(msg.type==KMNetMsg.SC_BroadcastTimeModify and msg.timeofday~=nil)	then
		-- time
		ParaScene.SetTimeOfDaySTD(msg.timeofday);
	end
end

NPL.this(activate);

-- this is for testing
--[[
local obj = ObjEditor.GetCurrentObj();
if(obj~=nil and obj:IsValid() and obj:IsCharacter() == false) then
	-- current selection is not a character.
	local quat = obj:GetRotation({});
	log(quat.x..quat.y..quat.z..quat.w);
	obj:SetRotation(quat);
	
	local viewbox = obj:GetViewBox({});
	local tmp = ParaScene.GetObjectByViewBox(viewbox);
	if(tmp:IsValid()) then
		local x,y,z = tmp:GetPosition();
		log(x..y..z);
	end
end]]
	
	
	