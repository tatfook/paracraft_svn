--[[
Title: keepwork.project.test
Author(s): leio
Date: 2020/8/31
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.project.test.lua");
test.project_list();
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.project_list()
    keepwork.project.list({
    },function(err, msg, data)
        commonlib.echo("==========project_list");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
