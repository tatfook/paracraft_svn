--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.lobby.test.lua");
paraworld.lobby.Test()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.lobby.Test()
end
--[[
paraworld.CreateRPCWrapper("paraworld.lobby.JoinRoom", "http://lobby.paraengine.com/JoinRoom.asmx");
paraworld.CreateRPCWrapper("paraworld.lobby.GetRoomList", "http://lobby.paraengine.com/GetRoomList.asmx");
]]




--passed: 创建房间
-- %TESTCASE{"lobby.CreateRoom", func = "paraworld.lobby.CreateRoom_Test", input ={sessionkey = '0a3b1121-b72f-4100-9943-bf0bacf7d045', worldid = '', worldpath = '', joinpassword = "password", description = 'This is a test room', maxclients = 300,}}%
--[[
	case 1:Passed
		Input:{["description"]="",["sessionkey"]="76b4ad8b-ad2b-4033-b0e9-7657a4358d44",["maxclients"]=300,["worldid"]='9',['worldpath']='',["joinpassword"]="",}
		_Result_:
			{
				["newroomid"]=5,
			}
	case 2:Passed（同一个用户第二次创建房间时，该用户之前创建的房间被删除，Passed）
		Input:{["description"]="",["sessionkey"]="76b4ad8b-ad2b-4033-b0e9-7657a4358d44",["maxclients"]=300,["worldid"]=100,['worldpath']='',["joinpassword"]="",}
		_Result_:
			{
				["newroomid"]=6,
			}
	case 2:Passed
		Input:{["description"]="This is a test room",["sessionkey"]="76b4ad8b-ad2b-4033-b0e9-7657a4358d44",["maxclients"]=300,["worldpath"]="http://test.cyf",["worldid"]="",["joinpassword"]="password",}
		_Result_:
			{
				["newroomid"]=10,
			}
]]
function paraworld.lobby.CreateRoom_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		worldid = input.worldid,
		worldpath = input.worldpath,
		joinpassword = input.joinpassword,
		description = input.description,
		maxclients = input.maxclients,
	};
	paraworld.lobby.CreateRoom(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: 取得指定页的房间数据
-- %TESTCASE{"lobby.GetRoomList", func = "paraworld.lobby.GetRoomList_Test", input ={pageindex = 0, pagesize = 5, worldid = '', worldpath = '', orderfield = 1, orderdirection = 1}}%
--[[
	caes 1:passed
		input:{["orderfield"]=1,["orderdirection"]=1,["pageindex"]=0,["worldpath"]="",["pagesize"]=5,["worldid"]=9,}
		_Result_:{
			["pagecount"]=1,
			["rooms"]={
				[1]={["hostuid"]="0a3b1121-b72f-4100-9943-bf0bacf7d045",["description"]="This is a test room",["maxclients"]=300,["roomid"]=3,["activityDate"]="2008-6-18 10:47:04",["createDate"]="2008-6-18 10:47:04",["worldpath"]="",["worldid"]=9,["joinpassword"]="password",},
				[2]={["hostuid"]="ed06733e-986d-4236-8fc8-9f8300456c21",["description"]="This is a test room",["maxclients"]=300,["roomid"]=4,["activityDate"]="2008-6-18 16:11:56",["createDate"]="2008-6-18 16:11:56",["worldpath"]="",["worldid"]=9,["joinpassword"]="password",},
				},
			}
	case 2:passed
		input:{["orderfield"]=2,["orderdirection"]=2,["pageindex"]=0,["worldpath"]="",["pagesize"]=5,["worldid"]=9,}
		_Result_:{
			["pagecount"]=1,
			["rooms"]={
				[1]={["hostuid"]="ed06733e-986d-4236-8fc8-9f8300456c21",["description"]="This is a test room",["maxclients"]=300,["roomid"]=4,["activityDate"]="2008-6-18 16:11:56",["createDate"]="2008-6-18 16:11:56",["worldpath"]="",["worldid"]=9,["joinpassword"]="password",},
				[2]={["hostuid"]="0a3b1121-b72f-4100-9943-bf0bacf7d045",["description"]="This is a test room",["maxclients"]=300,["roomid"]=3,["activityDate"]="2008-6-18 10:47:04",["createDate"]="2008-6-18 10:47:04",["worldpath"]="",["worldid"]=9,["joinpassword"]="password",},}
			,}
	case 3:passed
		input:{["orderfield"]=2,["orderdirection"]=2,["pageindex"]=0,["worldpath"]="http://test.cyf",["pagesize"]=5,["worldid"]="",}
		_Result_:{
			["pagecount"]=1,
			["rooms"]={
				[1]={["hostuid"]="76b4ad8b-ad2b-4033-b0e9-7657a4358d44",["description"]="This is a test room",["maxclients"]=300,["roomid"]=10,["activityDate"]="2008-6-20 20:01:21",["createDate"]="2008-6-20 20:01:21",["worldpath"]="http://test.cyf",["worldid"]=0,["joinpassword"]="password",},}
			,}
]]
function paraworld.lobby.GetRoomList_Test(input)
	local msg = {
		pageindex = input.pageindex,
		pagesize = input.pagesize,
		worldid = input.worldid,
		worldpath = input.worldpath,
		orderfield = input.orderfield,
		orderdirection = input.orderdirection,
	};
	paraworld.lobby.GetRoomList(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: 发布MCML String 到某个频道
-- %TESTCASE{"lobby.PostBBS", func = "paraworld.lobby.PostBBS_Test", input ={sessionkey = "", channel = "Channel_1", content = "Hello 111"}}%
--[[
	case 1:passed
		input:{
			["sessionkey"]="ed06733e-986d-4236-8fc8-9f8300456c21",
			["channel"]="Channel_1",
			["content"]="Hello 111",
		}
		_Result_:{
			["issuccess"]="true",
		}
]]
function paraworld.lobby.PostBBS_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		channel = input.channel,
		content = input.content,
	};
	paraworld.lobby.PostBBS(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: 取得指定页的房间数据
-- %TESTCASE{"lobby.GetBBS", func = "paraworld.lobby.GetBBS_Test", input ={sessionkey = "", channel = "Channel_1", afterDate = "2008-1-1", pageindex = 0, pagesize = 50,}}%
--[[
	case 1:passed
		input:{
			["sessionkey"]="ed06733e-986d-4236-8fc8-9f8300456c21",
			["pageindex"]=0,
			["afterDate"]="2008-1-1",
			["pagesize"]=50,
			["channel"]="Channel_1",
		}
		_Result_:{
			["msgs"]={
				[1]={
					["date"]="2008-6-23 16:03:18",
					["uid"]="ed06733e-986d-4236-8fc8-9f8300456c21",
					["content"]="Hello 111",
				},
				[2]={
					["date"]="2008-6-23 16:06:40",
					["uid"]="ed06733e-986d-4236-8fc8-9f8300456c21",
					["content"]="Hello 222",
				},
			},
			["channel"]="Channel_1",
		}
]]
function paraworld.lobby.GetBBS_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		channel = input.channel,
		afterDate = input.afterDate,
		pageindex = input.pageindex,
		pagesize = input.pagesize,
	};
	paraworld.lobby.GetBBS(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end







-- TODO: 2008.12.8 
-- %TESTCASE{"paraworld.lobby.CreateRoom_Rest", func = "paraworld.lobby.CreateRoom_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", worldpath = "worldpath", description = "This is a test room", format = "1"}}%
function paraworld.lobby.CreateRoom_Rest(input)
	local url = "http://lobby.test.pala5.cn/CreateRoom.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end



-- TODO: 2008.12.8 
-- %TESTCASE{"paraworld.lobby.GetBBS_Rest", func = "paraworld.lobby.GetBBS_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", channel = "Channel_Public", afterDate = "2008-6-1 12:00:00", format = "1"}}%
function paraworld.lobby.GetBBS_Rest(input)
	local url = "http://lobby.test.pala5.cn/GetBBS.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- TODO: 2008.12.8 
-- %TESTCASE{"paraworld.lobby.GetRoomList_Rest", func = "paraworld.lobby.GetRoomList_Rest", input={pageindex = "0", pagesize = "5", worldpath = "worldpath", format = "1"}}%
function paraworld.lobby.GetRoomList_Rest(input)
	local url = "http://lobby.test.pala5.cn/GetRoomList.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- TODO: 2008.12.8 
-- %TESTCASE{"paraworld.lobby.PostBBS_Rest", func = "paraworld.lobby.PostBBS_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", channel = "Channel_Public", content = "Hello World", format = "1"}}%
function paraworld.lobby.PostBBS_Rest(input)
	local url = "http://lobby.test.pala5.cn/PostBBS.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end