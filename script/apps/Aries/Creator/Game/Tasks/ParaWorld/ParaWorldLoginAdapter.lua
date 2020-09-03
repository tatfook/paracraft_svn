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
NPL.load("(gl)script/apps/Aries/Creator/Game/GameDesktop.lua");
local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
local UserInfo = NPL.load("(gl)Mod/WorldShare/cellar/Login/UserInfo.lua")
local MainLogin = commonlib.gettable("MyCompany.Aries.Game.MainLogin");
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
local ParaWorldLoginAdapter = commonlib.gettable("MyCompany.Aries.Game.Tasks.ParaWorld.ParaWorldLoginAdapter");

ParaWorldLoginAdapter.MainWorldId = nil;

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
	local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")
	local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")
	if not KeepworkService:IsSignedIn() and KeepworkServiceSession:GetCurrentUserToken() then
		UserInfo:LoginWithToken(function()
			ParaWorldLoginAdapter:EnterWorld();
		end);
		return;
	end
    if(System.options.loginmode == "offline" and not KeepworkService:IsSignedIn())then
        ParaWorldLoginAdapter:EnterOfflineWorld();
        return
    end

    ParaWorldLoginAdapter:SearchWorldID(function(world_id)
	    LOG.std(nil, "info", "ParaWorldLoginAdapter", " found world_id:%s", tostring(world_id));
        if(not world_id)then
            ParaWorldLoginAdapter:EnterOfflineWorld();
            return
        end
		ParaWorldLoginAdapter.MainWorldId = world_id;
        local UserConsole = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/Main.lua")
	    UserConsole:HandleWorldId(world_id, "force");
    end)
    
end

function ParaWorldLoginAdapter.ShowExitWorld(restart)
	_guihelper.MessageBox("是否离开当前世界，返回登录界面？", function(res)
		if(res and res == _guihelper.DialogResult.Yes)then
			Desktop.is_exiting = true;
			local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")
			KeepworkServiceSession:Logout(nil, function()
				GameLogic.GetFilters():apply_filters("OnKeepWorkLogout", true);
			end);
			Desktop.ForceExit(restart);
		end
	end, _guihelper.MessageBoxButtons.YesNo);
end
