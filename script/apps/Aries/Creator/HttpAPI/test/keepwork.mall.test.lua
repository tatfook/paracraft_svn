--[[
Title: keepwork.mall.test
Author(s): leio
Date: 2020/7/14
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.mall.test.lua");
test.menus_get("access plus 0");
test.goods_get("access plus 0");
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.menus_get(cache_policy, callback)
    keepwork.mall.menus.get({
        cache_policy,
        platform =  1,
    },function(err, msg, data)
        commonlib.echo("==========menus_get");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
        if callback then
            callback(data)
        end
    end)
end
function test.goods_get(cache_policy, callback)
    keepwork.mall.goods.get({
        cache_policy =  cache_policy,
        classifyId = nil,
        tags = nil,
        keyword = nil,
        platform = 1,
        headers = {
            ["x-per-page"] = 1000,
            ["x-page"] = 1,
        }
    },function(err, msg, data)
        commonlib.echo("==========goods_get");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        if callback then
            callback(data)
        end
    end)
end
