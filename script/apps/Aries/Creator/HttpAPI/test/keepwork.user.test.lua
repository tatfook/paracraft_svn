--[[
Title: keepwork.user.test
Author(s): leio
Date: 2020/4/23
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.user.test.lua");
test.login();
test.login("access plus 0");
test.profile();
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.login(cache_policy)
    keepwork.user.login({
        username = "zhangleio" , -- id 572
        password = "12345678",
        cache_policy =  cache_policy,
    },function(err, msg, data)
        commonlib.echo("==========login");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end

function test.profile(cache_policy)
    keepwork.user.profile({
    },function(err, msg, data)
        commonlib.echo("==========profile");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
