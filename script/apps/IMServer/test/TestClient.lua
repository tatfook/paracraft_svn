--[[
Author: Gosling
Date: 2010-05-19
Desc: testing Client->GameServer->IMServer
-----------------------------------------------
NPL.load("(gl)script/apps/IMServer/test/TestClient.lua");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");

main_state = nil;

-- %TESTCASE{"FirstTest", func = "FirstTest", input={action="setroster", game_nid=1002,g_rts=1,data_table={user_nid=14431795,signature="1@1002-14431795",roster_list="1234,224,12345671,123026,",last_online_time=1273511111,group_id=1},}}%
local function FirstTest()

end

local function activate()
end
NPL.this(activate);

