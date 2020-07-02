--[[
Title: 
Author(s): leio
Date: 2012/08/21
use the lib:
------------------------------------------------------------

NPL.load("(gl)script/apps/Aries/UserBag/UserClientMemory.lua");
local UserClientMemory = commonlib.gettable("MyCompany.Aries.Inventory.UserClientMemory");
UserClientMemory.Load(nid,function()
	--UserClientMemory.ClearMemory(985);

	local key = "HideInHomeland";
	UserClientMemory.SetData(key,{"good"});

	local v = UserClientMemory.GetData(nil,key);
	commonlib.echo("=============");
	commonlib.echo(v);
end)
]]
NPL.load("(gl)script/apps/Aries/UserBag/UserMemoryTable.lua");
local UserMemoryTable = commonlib.gettable("MyCompany.Aries.Inventory.UserMemoryTable");
NPL.load("(gl)script/apps/Aries/UserBag/UserClientMemory.lua");
local UserClientMemory = commonlib.gettable("MyCompany.Aries.Inventory.UserClientMemory");
UserClientMemory.provider_map = {};
function UserClientMemory.Load(nid,callbackFunc)
	nid = nid or Map3DSystem.User.nid;
	local provider = UserMemoryTable:new{
		nid = nid,
	};
	provider:Reload(function()
		UserClientMemory.provider_map[nid] = provider;
		if(callbackFunc)then
			callbackFunc();
		end
	end)
end
function UserClientMemory.GetData(nid,key)
	nid = nid or Map3DSystem.User.nid;
	if(not key)then return end
	local provider = UserClientMemory.provider_map[nid];
	if(provider)then
		return provider:GetData(key);
	end
end
--NOTE:²»ÄÜ´æ´¢×Ö·û´® ~ and |
function UserClientMemory.SetData(key,value)
	nid = nid or Map3DSystem.User.nid;
	if(not key)then return end
	local provider = UserClientMemory.provider_map[nid];
	if(provider)then
		provider:SetData(key,value);
	end
end
function UserClientMemory.ClearMemory(gsid)
	nid = nid or Map3DSystem.User.nid;
	if(not key)then return end
	local provider = UserClientMemory.provider_map[nid];
	if(provider)then
		provider:ClearMemory(gsid);
	end
end