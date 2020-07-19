--[[
Title: keepwork.rawfile.test
Author(s): leio
Date: 2020/7/16
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.rawfile.test.lua");
test.get();
test.get2();
test.nplcad3_asset_get_1();
test.nplcad3_asset_get_2();
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.get(cache_policy)
    keepwork.rawfile.get({
        cache_policy =  cache_policy,
        router_params = {
            repoPath = "zhanglei%%2Fempty",
            filePath = "zhanglei%%2Fempty%%2Ftest.md",
        }
    },function(err, msg, data)
        commonlib.echo("==========get");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end

function test.get2(cache_policy)
    keepwork.rawfile.get({
        cache_policy =  cache_policy,
        router_params = {
            repoPath = "zhanglei%%2Fnplcadtip",
            filePath = "zhanglei%%2Fnplcadtip%%2Fmenus.md",
        }
    },function(err, msg, data)
        commonlib.echo("==========get2");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
function test.nplcad3_asset_get_1(cache_policy)
    nplcad3.asset.get({
        cache_policy =  cache_policy,
        router_params = {
            filepath = "assetList.json",
        }
    },function(err, msg, data)
        commonlib.echo("==========nplcad3_asset_get_1");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
function test.nplcad3_asset_get_2(cache_policy)
    nplcad3.asset.get({
        cache_policy =  cache_policy,
        router_params = {
            filepath = "sprite/examples/ak47/ak47.json",
        }
    },function(err, msg, data)
        commonlib.echo("==========nplcad3_asset_get_2");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end

