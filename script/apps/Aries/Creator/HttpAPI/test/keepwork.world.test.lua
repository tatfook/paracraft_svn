--[[
Title: keepwork.world.test
Author(s): leio
Date: 2020/8/31
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.world.test.lua");
test.world_joined_list();
-- mini world
test.miniworld_upload();
test.miniworld_list();
test.miniworld_like();
test.miniworld_unlike();
test.miniworld_is_liked();

-- world
test.world_mylist();
test.world_list();
test.world_get();
test.world_like();
test.world_unlike();
test.world_is_liked();
test.world_take_seat();
test.world_leave_seat();
test.world_apply();
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.world_joined_list()
    keepwork.world.joined_list({
    },function(err, msg, data)
        commonlib.echo("==========world_joined_list");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.miniworld_upload()
    keepwork.miniworld.upload({
        projectId = 1409,
        name = "迷你世界1",
        type = "main",
        commitId = "9b70b41ef0504bf1b53a1011f30e578229ae4056", -- 获取自己创建的以及参与的世界列表 http://yapi.kp-para.cn/project/32/interface/api/1217
    },function(err, msg, data)
        commonlib.echo("==========miniworld_upload");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.miniworld_list()
    keepwork.miniworld.list({
    },function(err, msg, data)
        commonlib.echo("==========miniworld_list");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
function test.miniworld_like()
    keepwork.miniworld.like({
        paraMiniId = 1,
    },function(err, msg, data)
        commonlib.echo("==========miniworld_like");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.miniworld_unlike()
    keepwork.miniworld.unlike({
        -- using router_params
        router_params = {
            paraMiniId = 1,
        }
    },function(err, msg, data)
        commonlib.echo("==========miniworld_unlike");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
function test.miniworld_is_liked()
    keepwork.miniworld.is_liked({
        paraMiniIds = { 1 },
    },function(err, msg, data)
        commonlib.echo("==========miniworld_is_liked");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end


function test.world_mylist()
    keepwork.world.mylist({
    },function(err, msg, data)
        commonlib.echo("==========world_mylist");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
function test.world_list()
    keepwork.world.list({
    },function(err, msg, data)
        commonlib.echo("==========world_list");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.world_get()
    keepwork.world.get({
     -- using router_params
        router_params = {
            id = 4,
        }
    },function(err, msg, data)
        commonlib.echo("==========world_get");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.world_like()
    keepwork.world.like({
        paraWorldId = 4,
    },function(err, msg, data)
        commonlib.echo("==========world_like");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
function test.world_unlike()
    keepwork.world.unlike({
     -- using router_params
        router_params = {
            paraWorldId = 4,
        }
    },function(err, msg, data)
        commonlib.echo("==========world_unlike");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
function test.world_is_liked()
    keepwork.world.is_liked({
        paraWorldIds = { 4 },
    },function(err, msg, data)
        commonlib.echo("==========world_is_liked");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
-- 占座
function test.world_take_seat()
    keepwork.world.take_seat({
        paraMiniId = 1,
        paraWorldId = 4,
        sn = 16,
    },function(err, msg, data)
        commonlib.echo("==========world_take_seat");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

-- 离座
function test.world_leave_seat()
    keepwork.world.leave_seat({
        paraMiniId = 1,
        paraWorldId = 4,
        sn = 16,
    },function(err, msg, data)
        commonlib.echo("==========world_leave_seat");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

-- 锁座 
-- 这个是有权限管理大世界的人进行的操作，锁座后这个位置就不能入驻mini了
function test.world_lock_seat()
    keepwork.world.lock_seat({
        paraWorldId = 8,
        sn = 16,
    },function(err, msg, data)
        commonlib.echo("==========world_lock_seat");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

-- 解锁座
function test.world_unlock_seat()
    keepwork.world.unlock_seat({
        paraWorldId = 8,
        sn = 16,
    },function(err, msg, data)
        commonlib.echo("==========world_unlock_seat");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

-- 提交paraWorld申请
function test.world_apply()
    keepwork.world.apply({
        name = "并行世界测试1",
        projectId = 1410,
        objectId = 281195,
        objectType = "school",
        cover = "",
        commitId = "5ac07a3984dd514a4cde5fb327e2f3b47ef11551",
        regionId = 279,
    },function(err, msg, data)
        commonlib.echo("==========world_apply");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end