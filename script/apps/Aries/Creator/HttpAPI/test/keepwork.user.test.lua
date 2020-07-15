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
test.getinfo();
--]]
NPL.load("(gl)script/ide/System/Encoding/base64.lua");
NPL.load("(gl)script/ide/Json.lua");
local Encoding = commonlib.gettable("System.Encoding");
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

function test.getinfo(cache_policy)
    local username = "zhangleio"
    local id = "kp" .. Encoding.base64(commonlib.Json.Encode({username=username}));
    -- this request is by router path
    keepwork.user.getinfo({
        router_params = {
            id = id,
        }
    },function(err, msg, data)
        commonlib.echo("==========getinfo");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
