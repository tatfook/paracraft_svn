--[[
Title: FriendManager
Author(s): 
Date: 2020/9/7
Desc:  
Use Lib:
-------------------------------------------------------
local FriendManager = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendManager.lua");
FriendManager:LoadAllUnReadMsgs();
local userId = 763;
local conn = FriendManager:Connect(userId,function()
    FriendManager:SendMessage(userId,{ words = "hello world" })
end)
--]]
local FriendConnection = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendConnection.lua");

local FriendManager = NPL.export();

FriendManager.connections = {};
FriendManager.unread_msgs = {};
FriendManager.unread_msgs_loaded = false;
--[[
{
  data={
    {
      createdAt="2020-09-07T06:03:56.000Z",
      id=15,
      latestMsg={
        content="hello world",
        createdAt="2020-09-07T06:03:59.000Z",
        id=13,
        msgKey="474ca760-4c10-48dc-b13e-21bd9cb619ae",
        roomId=8,
        senderId=776,
        updatedAt="2020-09-07T06:03:59.000Z" 
      },
      latestMsgId=13,
      room={
        createdAt="2020-09-07T06:03:56.000Z",
        id=8,
        name="__chat_763_776__",
        updatedAt="2020-09-07T06:03:56.000Z" 
      },
      roomId=8,
      unReadCnt=2,
      updatedAt="2020-09-07T06:03:59.000Z",
      userId=763 
    },
    {
      createdAt="2020-09-07T02:51:17.000Z",
      id=2,
      latestMsg={
        content="hello world",
        createdAt="2020-09-07T05:51:54.000Z",
        id=11,
        msgKey="a15a301e-4790-4f93-a1fe-e08169ab7a27",
        roomId=1,
        senderId=760,
        updatedAt="2020-09-07T05:51:54.000Z" 
      },
      latestMsgId=11,
      room={
        createdAt="2020-09-07T02:51:17.000Z",
        id=1,
        name="__chat_760_763__",
        updatedAt="2020-09-07T05:56:11.000Z" 
      },
      roomId=1,
      unReadCnt=11,
      updatedAt="2020-09-07T05:56:11.000Z",
      userId=763 
    } 
  },
  message="请求成功" 
}
--]]
function FriendManager:LoadAllUnReadMsgs(callback)
    if(FriendManager.unread_msgs_loaded)then
        if(callback)then
            callback();
        end
        return
    end
    FriendManager.unread_msgs = {};
    keepwork.friends.getUnReadMsgCnt({
        },function(err, msg, data)
            commonlib.echo("==========LoadAllUnReadMsgs");
            commonlib.echo(err);
            commonlib.echo(msg);
            commonlib.echo(data,true);
            if(err ~= 200)then
                return
            end
            FriendManager.unread_msgs = data or {};
            FriendManager.unread_msgs_loaded = true;
            if(callback)then
                callback();
            end
        end)
end
function FriendManager:Connect(userId,callback)
    local conn = FriendManager:CreateOrGetConnection(userId);
    conn:Connect(callback);
end
function FriendManager:CreateOrGetConnection(userId)
    if(not userId)then
        return
    end
    local conn = self.connections[userId];
    if(not conn)then
        conn = FriendConnection:new():OnInit(userId);
        self.connections[userId] = conn;
    end
    return conn;
end

--[[
----------------------payload

 {
  ChannelIndex=25,
  content="hello world",
  id=776,
  msgKey="2b051a59-a4b1-47da-95c2-5bb57688eb07",
  nickname="zhangleio5",
  orgAdmin=0,
  student=0,
  tLevel=0,
  toid=763,
  type=4,
  username="zhangleio5",
  vip=0,
  worldId=1192 
}

----------------------full_msg
 {
  body={
    "app/msg",
    {
      action="msg",
      meta={
        client="ZogAvQYR0eRYM7ScAAA3",
        target="__chat_760_763__",
        timestamp="2020-09-07 13:51" 
      },
      payload={
        ChannelIndex=25,
        content="hello world",
        id=760,
        msgKey="a15a301e-4790-4f93-a1fe-e08169ab7a27",
        nickname="zhangleio2",
        orgAdmin=0,
        student=0,
        tLevel=0,
        toid=763,
        type=4,
        username="zhangleio2",
        vip=1,
        worldId=1192 
      },
      userInfo={
        iat=1599457901,
        machineCode="712f8436-5320-4e87-931f-f0a6ae09cf8e-4C4C4544-0036-3910-8051-C6C04F384D32",
        platform="PC",
        userId=760,
        username="zhangleio2" 
      } 
    } 
  },
  eio_pkt_name="message",
  path="/",
  raw_body="[\"app/msg\",{\"meta\":{\"timestamp\":\"2020-09-07 13:51\",\"target\":\"__chat_760_763__\",\"client\":\"ZogAvQYR0eRYM7ScAAA3\"},\"action\":\"msg\",\"payload\":{\"orgAdmin\":0,\"nickname\":\"zhangleio2\",\"worldId\":1192,\"student\":0,\"tLevel\":0,\"content\":\"hello world\",\"vip\":1,\"id\":760,\"type\":4,\"username\":\"zhangleio2\",\"toid\":763,\"ChannelIndex\":25,\"msgKey\":\"a15a301e-4790-4f93-a1fe-e08169ab7a27\"},\"userInfo\":{\"userId\":760,\"username\":\"zhangleio2\",\"platform\":\"PC\",\"machineCode\":\"712f8436-5320-4e87-931f-f0a6ae09cf8e-4C4C4544-0036-3910-8051-C6C04F384D32\",\"iat\":1599457901}}]",
  sio_pkt_name="event" 
}
--]]
function FriendManager:OnMsg(payload, full_msg)
    commonlib.echo("=============FriendManager:OnMsg payload");
    commonlib.echo(payload,true);
    commonlib.echo("=============FriendManager:OnMsg full_msg");
    commonlib.echo(full_msg,true);
end
-- send a message to user
-- @param {number} userId
-- @param {table} msg
-- @param {string} msg.words
function FriendManager:SendMessage(userId,msg)
    local conn = FriendManager:CreateOrGetConnection(userId)
    conn:SendMessage(msg);
end
