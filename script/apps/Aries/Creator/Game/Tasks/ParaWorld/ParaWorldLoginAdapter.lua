--[[
Title: 
Author(s): leio
Date: 2020/9/1
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldLoginAdapter.lua");
local ParaWorldLoginAdapter = commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.ParaWorldLoginAdapter");
ParaWorldLoginAdapter:EnterWorld();

NOTE: 
How to config cmd line:
seeing script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua 
-------------------------------------------------------
]]
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
local ParaWorldLoginAdapter = commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.ParaWorldLoginAdapter");


ParaWorldLoginAdapter.ids = {
    ONLINE = { 
        18355, -- 默认世界 知识岛
        --18626, --希望空间 
    },
    STAGE = { 1192, },
    RELEASE = { 
        1192, -- 默认世界 知识岛
        --1236, --希望空间 
    },
    LOCAL = {},
}
function ParaWorldLoginAdapter.GetDefaultWorldID()
    local httpwrapper_version = HttpWrapper.GetDevVersion();
    local ids = ParaWorldLoginAdapter.ids[httpwrapper_version];
    if(ids)then
        local len = #ids;
        local index = math.random(len);
        local id = ids[index];
        return id;
    end
end
-- search a world id to login
function ParaWorldLoginAdapter:SearchWorldID(callback)
    --[[
        {
          {
            commitId="31d04",
            createdAt="2020-09-02T17:00:00.000Z",
            favorite=0,
            id=1,
            lastFavorite=0,
            lastStar=0,
            name="甯屾湜绌洪棿",
            objectId=272928,
            objectType="school",
            projectId=1236,
            regionId=1894,
            settleCount=0,
            star=0,
            status="audited",
            updatedAt="2020-09-02T17:00:00.000Z" 
          } 
        }
    ]]
    keepwork.world.mylist({
    },function(err, msg, data)
        commonlib.echo("==========world.mylist");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
        local world_id = ParaWorldLoginAdapter.GetDefaultWorldID();
        if(err == 200)then
            -- the first item is right world
            if(data and data[1])then
                local world_info = data[1];
                if(world_info.projectId)then
                    world_id =  world_info.projectId;
                end
            end
        end
        if(callback)then
            callback(world_id);
        end
    end)
    
end
-- enter offline world
function ParaWorldLoginAdapter:EnterOfflineWorld()
    NPL.load("(gl)script/apps/Aries/Creator/Game/Login/InternetLoadWorld.lua");
	local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld");
	InternetLoadWorld.ShowPage();
end
function ParaWorldLoginAdapter:EnterWorld()
    if(System.options.loginmode == "offline")then
        ParaWorldLoginAdapter:EnterOfflineWorld();
        return
    end

    ParaWorldLoginAdapter:SearchWorldID(function(world_id)
	    LOG.std(nil, "info", "ParaWorldLoginAdapter", " found world_id:%s", tostring(world_id));
        if(not world_id)then
            ParaWorldLoginAdapter:EnterOfflineWorld();
            return
        end
        local UserConsole = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/Main.lua")
	    UserConsole:HandleWorldId(world_id, "force");
    end)
    
end
