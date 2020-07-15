--[[
Title: keepwork.item.test
Author(s): leio
Date: 2020/4/23
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.item.test.lua");
test.globalstore()
test.extendedcost()
test.bags()
test.items(763, "1")
test.exchange(18);
test.checkExchange(18)
test.setClientData(30102)
test.getClientData(30102)
--]]
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()
function test.globalstore()
    keepwork.globalstore.get({},function(err, msg, data)
        commonlib.echo("==========globalstore");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        commonlib.echo(#(data.data.rows));
    end)
end
function test.extendedcost()
    keepwork.extendedcost.get({},function(err, msg, data)
        commonlib.echo("==========extendedcost");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        commonlib.echo(#(data.data.rows));
    end)
end
function test.bags()
    keepwork.bags.get({},function(err, msg, data)
        commonlib.echo("==========bags");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        commonlib.echo(#(data.data.rows));
    end)
end
function test.items(userId, bagNos)
    keepwork.items.get({
        userId = userId,
        bagNos = bagNos,
    },function(err, msg, data)
        commonlib.echo("==========items");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        commonlib.echo(#(data.data));
    end)
end
--[[
{   
    data =
        {
            gainList=
                {
                    {   
                        amount=1,
                        goodsInfo={stackable=true,id=9,gsId=10001,destoryAfterUse=false,canHandsel=false,deleted=false,dayMax=1,canUse=false,icon="none",coins=0,weekMax=7,updatedAt="2020-05-13T08:04:18.000Z",typeId=3,price=0,desc="记录签到的天数",expiredRules=1,bagId=1,createdAt="2020-05-13T08:00:16.000Z",expiredSeconds=0,canTrade=false,name="签到天数",max=99999999,},
                    },

                    {   
                        amount=1,
                        goodsInfo={stackable=true,id=10,gsId=10002,destoryAfterUse=true,canHandsel=false,deleted=false,dayMax=99999999,canUse=true,icon="Texture/Aries/Item/998_EngergyStone.png",coins=99999999,weekMax=7,updatedAt="2020-05-13T08:40:44.000Z",typeId=3,price=99999999,desc="积分",expiredRules=1,bagId=1,createdAt="2020-05-13T08:08:33.000Z",expiredSeconds=0,canTrade=false,name="积分",max=99999999,},
                    },
                },
            costList={},
        },
    message="请求成功",
}
--]]
function test.exchange(exid)
    keepwork.items.exchange({
        userId = 572, -- zhangleio's id
        exId = exid,
    },function(err, msg, data)
        commonlib.echo("==========exchange");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
function test.setClientData(gsid)
    gsid = gsid or 30102;
    local bOwn, guid = KeepWorkItemManager.HasGSItem(gsid)
    if(not bOwn)then
        commonlib.echo("==========setClientData faild");
        return
    end
    commonlib.echo("==========guid");
    commonlib.echo(guid);
    keepwork.items.setClientData({
        userGoodsId = guid,
        clientData = {
            a = 1,
            b = "key2",
            c = true,
        }
    },function(err, msg, data)
        commonlib.echo("==========setClientData");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
-- echo:{data={input={b="key2",a=1,c=true,},cache_policy="access plus 0",},message="请求成功",}
function test.getClientData(gsid)
    gsid = gsid or 30102;
    local bOwn, guid = KeepWorkItemManager.HasGSItem(gsid)
    if(not bOwn)then
        commonlib.echo("==========getClientData faild");
        return
    end
    commonlib.echo("==========guid");
    commonlib.echo(guid);
    keepwork.items.getClientData({
        userGoodsId = guid,
    },function(err, msg, data)
        commonlib.echo("==========getClientData");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
    end)
end
