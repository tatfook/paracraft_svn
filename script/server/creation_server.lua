--[[
Title: object creation on server side
Author(s): LiXizhi
Date: 2006/11/1
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/ClientServerIncludes.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/terrain_editor.lua");

if(not server) then server={}; end

server.LastRequest = {	
	type = 0,
	name = "",
	filepath = "",
	x=0, y=0, z=0,
}
--[[ send a creation request to all its clients. ]]
function server.BroadcastObjectCreation(ObjName, FilePath, pos,sCategoryName)
	local msg = {
		type = KMNetMsg.SC_BroadcastObjectCreation,
		name = ObjName,
		sCategoryName = sCategoryName,
		filepath = FilePath,
		x=pos[1], y=pos[2], z=pos[3],
	};
	if (ObjEditor.AutoCreateObject(ObjName, FilePath, pos, sCategoryName) ~= nil) then
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	end
end

--[[ broadcast a object modification request to all clients. 
@param obj: if nil, the current object is used. 
@param pos: nil or {x=0,y=0,z=0} which is global position.
@param scale: nil or double which is absolute scale.
@param quat: nil or {x=0,y=0,z=0,w=1} which is rotational quaternion.
]]
function server.BroadcastObjectModification(obj, pos, scale, quat)
	local msg = {
		type = KMNetMsg.SC_BroadcastObjectModification, -- modification ID
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
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	end	
end

--[[ broadcast a deletion request to server. ]]
function server.BroadcastObjectDelete(obj)
	local msg = {
		type = KMNetMsg.SC_BroadcastObjectDelete, -- deletion 
	};
	if(obj==nil or obj:IsValid() == false) then
		obj = ObjEditor.GetCurrentObj();
		if(obj == nil or obj:IsValid()==false) then
			return
		end
	end
	msg.viewbox = obj:GetViewBox({});
	if(ObjEditor.DelObject(obj) == true) then
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	end	
end

--[[ send a creation request to all its clients. ]]
function server.BroadcastTerrainModify(x,y,z,radius)
	-- make the radius a little larger. 
	ParaWorld.SendTerrainUpdate("all@local",x, y, z, radius+5, 1);
end

-- Update texture texture, parameter is same as ParaTerrain.Paint()
function server.BroadcastTerrainTexModify(TexFile,x,y,z,brushsize, bErase)
	TerrainEditorUI.Paint(TexFile,x,y,z,brushsize, bErase);
	local msg = {
		type = KMNetMsg.SC_BroadcastTerrainTexModify, -- terrain texture
		TexFile = TexFile,
		x = x,
		y = y,
		z = z,
		brushsize = brushsize,
		bErase = bErase,
	};
	NPL.activate("all@local:script/client/creation_client.lua",msg);
end

-- request modify part of the ocean
function server.BroadcastOceanModify(height,bEnable, r,g,b)
	TerrainEditorUI.UpdateOcean(height, bEnable, r,g,b);
	local msg = {
		type = KMNetMsg.SC_BroadcastOceanModify, -- ocean 
		height = height,
		bEnable = bEnable,
		r = r,
		g = g,
		b = b,
	};
	NPL.activate("all@local:script/client/creation_client.lua",msg);
end

-- request changing sky
function server.BroadcastSkyModify(skybox, r,g,b)
	TerrainEditorUI.UpdateSky(skybox, r,g,b);
	local msg = {
		type = KMNetMsg.SC_BroadcastSkyModify, -- sky
		skybox = skybox, -- mesh file name
		r = r,
		g = g,
		b = b,
	};
	NPL.activate("all@local:script/client/creation_client.lua",msg);
end

-- request changing day time
function server.BroadcastTimeModify(timeofday)
	ParaScene.SetTimeOfDaySTD(timeofday);
	local msg = {
		type = KMNetMsg.SC_BroadcastTimeModify, -- time of day
		timeofday = timeofday, 
	};
	NPL.activate("all@local:script/client/creation_client.lua",msg);
end

-- hander messages from the clients
local function activate()
	if(msg.type==KMNetMsg.CS_RequestObjectCreation and msg.filepath~=nil) then
		--process creation request
		if(server.LastRequest.x == msg.x and server.LastRequest.x == msg.x and server.LastRequest.x == msg.x ) then
			-- can not create on the same location twice. 
			-- TODO: check for other things, before granting permission to the client to create object on this land.
		else
			-- create the client's request in the server world
			if (ObjEditor.AutoCreateObject(msg.name, msg.filepath, {msg.x, msg.y, msg.z},msg.sCategoryName, true) ~= nil) then
				local username = NPL.GetSrcUserName();
				msg.sender = username;
				server.LastRequest = msg;
				-- ensures that all clients get the update.
				NPL.activate("all@local:script/client/creation_client.lua",msg);
				
				-- When the server has broadcasted this number of objects, the server will be automatically restarted; this is usually the setting for testing public server.
				server.statistics.NumObjectCreated = server.statistics.NumObjectCreated+1;
				if(server.RestartOnCreateNum~=nil and server.RestartOnCreateNum~=0 and server.statistics.NumObjectCreated>=server.RestartOnCreateNum) then
					server.statistics.NumObjectCreated = 0;
					server.RestartGameServer();
				end
			end
		end
	elseif(msg.type==KMNetMsg.CS_RequestObjectModification and msg.viewbox~=nil)then
		--process modification request
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
			NPL.activate("all@local:script/client/creation_client.lua",msg);
		end	
	elseif(msg.type==KMNetMsg.CS_RequestObjectDelete and msg.viewbox~=nil)then
		-- delete an existing object
		local obj = ParaScene.GetObjectByViewBox(msg.viewbox);
		if(obj:IsValid() ==true) then
			if(ObjEditor.DelObject(obj)==true) then
				NPL.activate("all@local:script/client/creation_client.lua",msg);
			end	
		end
	elseif(msg.type==KMNetMsg.CS_RequestTerrainModify)	then
		-- further validation for user right to modify the terrain on this server.
		if(msg.cmd == 0 and msg.radius > 0 and msg.radius<90) then
			local oldvalue = TerrainEditorUI.elevModifier.radius;
			TerrainEditorUI.elevModifier.radius = msg.radius;
			TerrainEditorUI.GaussianHill(msg.height, msg.x, msg.y, msg.z);
			TerrainEditorUI.elevModifier.radius = oldvalue;
		elseif(msg.cmd == 1 and msg.radius > 0 and msg.radius<90) then
			local oldvalue = TerrainEditorUI.elevModifier.radius;
			TerrainEditorUI.elevModifier.radius = msg.radius;
			TerrainEditorUI.Flatten(msg.x, msg.y, msg.z);
			TerrainEditorUI.elevModifier.radius = oldvalue;
		elseif(msg.cmd == 4 and msg.radius > 0 and msg.radius<90) then
			local oldvalue = TerrainEditorUI.elevModifier.radius;
			TerrainEditorUI.elevModifier.radius = msg.radius;
			TerrainEditorUI.Roughen_Smooth(false);
			TerrainEditorUI.elevModifier.radius = oldvalue;
		elseif(msg.cmd == 5 and msg.radius > 0 and msg.radius<90) then
			local oldvalue = TerrainEditorUI.elevModifier.radius;
			TerrainEditorUI.elevModifier.radius = msg.radius;
			TerrainEditorUI.Roughen_Smooth(false);
			TerrainEditorUI.elevModifier.radius = oldvalue;
		end
		-- broadcast terrain data to client. 
		-- make the raduis a little larger. 
		ParaWorld.SendTerrainUpdate("all@local",msg.x, msg.y, msg.z, msg.radius+5, 1);
	elseif(msg.type==KMNetMsg.CS_RequestTerrainTexModify)	then
		-- terrain texture
		TerrainEditorUI.Paint(msg.TexFile,msg.x,msg.y,msg.z,msg.brushsize,msg.bErase);
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	elseif(msg.type==KMNetMsg.CS_RequestOceanModify)	then
		-- ocean 
		TerrainEditorUI.UpdateOcean(msg.height, msg.bEnable, msg.r,msg.g,msg.b);
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	elseif(msg.type==KMNetMsg.CS_RequestSkyModify)	then
		-- sky	
		TerrainEditorUI.UpdateSky(msg.skybox, msg.r,msg.g,msg.b);
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	elseif(msg.type==KMNetMsg.CS_RequestTimeModify and msg.timeofday~=nil)	then
		-- time
		ParaScene.SetTimeOfDaySTD(msg.timeofday);
		NPL.activate("all@local:script/client/creation_client.lua",msg);
	end
end

NPL.this(activate);