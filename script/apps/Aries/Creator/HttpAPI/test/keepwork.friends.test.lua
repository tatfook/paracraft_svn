--[[
Title: keepwork.friends.test
Author(s): leio
Date: 2020/4/23
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.friends.test.lua");
test.startChatToUser();
test.getUnReadMsgCnt();
test.getUnReadMsgInRoom();
--]]
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.startChatToUser(targetId)
    -- targetId 760:"zhangleio2" 763:"zhangleio3" 776:"zhangleio5"
    targetId = targetId or 763
    keepwork.friends.startChatToUser({
        targetId = targetId , 
    },function(err, msg, data)
        commonlib.echo("==========startChatToUser");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
function test.getUnReadMsgCnt()
    keepwork.friends.getUnReadMsgCnt({
    },function(err, msg, data)
        commonlib.echo("==========getUnReadMsgCnt");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.getUnReadMsgInRoom()
    keepwork.friends.getUnReadMsgInRoom({
         headers = {
            ["x-per-page"] = 1000,
            ["x-page"] = 1,
        },
        roomId = 1,
    },function(err, msg, data)
        commonlib.echo("==========getUnReadMsgInRoom");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.updateLastMsgTagInRoom()
    keepwork.friends.updateLastMsgTagInRoom({
        roomId = 1,
    },function(err, msg, data)
        commonlib.echo("==========updateLastMsgTagInRoom");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end
