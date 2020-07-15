--[[
Title: keepwork.mall.test
Author(s): leio
Date: 2020/7/14
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.mall.test.lua");
test.menus_get("access plus 0");
test.goods_get(cache_policy);
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.menus_get(cache_policy)
    keepwork.mall.menus.get({
        cache_policy =  cache_policy,
    },function(err, msg, data)
        commonlib.echo("==========menus_get");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
function test.goods_get(cache_policy)
    keepwork.mall.goods.get({
        cache_policy =  cache_policy,
        classifyId = "classifyId",
        tags = "tags",
        keyword = "keyword",
        headers = {
            ["x-per-page"] = 1000,
            ["x-page"] = 2,
        }
    },function(err, msg, data)
        commonlib.echo("==========goods_get");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
