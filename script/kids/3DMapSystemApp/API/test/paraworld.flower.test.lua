--[[
Title: 
Author(s): Leio
Date: 2008/2/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.flower.test.lua");
paraworld.users.Add_Test()
paraworld.users.Get_Test()
paraworld.users.Water_Test()
paraworld.users.Store_Test(input)
paraworld.users.Delete_Test()

["LastWater"]="2009-2-25 17:06:01",--总共获得的果实奖励数目
["Largess"]=0,
--果实的位置
["Position"]="0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19",
["UID"]="f114ae44-f5e5-4072-9e40-0d792a9cfe7a",--当前级别 结出的果实
["FuritLevel"]=4,--当前级别浇水的次数
["WaterLevel"]=23,--浇水总次数
["WaterCnt"]=33,--已经结出的果实总数
["FuritCnt"]=6,--当前级别
["FlowerLevel"]=1,--当天浇灌次数
["WaterToday"]=33,--花的类型
["flowertype"]=0,--摘的果实的总数量
["Store"]=0,--树上剩余果实
["FuritOverplus"]=6,
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.flower.lua");
-- %TESTCASE{"flower.Add", func = "paraworld.flower.Add_Test", input ={}}%
function paraworld.flower.Add_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		flowertype = 0,
		format = 1,
	}
	paraworld.flower.Add(msg,"flower",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"flower.Get", func = "paraworld.flower.Get_Test", input ={}}%
function paraworld.flower.Get_Test(input)
	local msg = {
		uid = Map3DSystem.User.userid,
		format = 1,
	}
	paraworld.flower.Get(msg,"flower",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"flower.Water", func = "paraworld.flower.Water_Test", input ={cnt=1, toUID = 0}}%
function paraworld.flower.Water_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		cnt = input.cnt,
		toUID = input.toUID,
		
	}
	paraworld.flower.Water(msg,"flower",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"flower.Store", func = "paraworld.flower.Store_Test", input ={position=0}}%
function paraworld.flower.Store_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		position = input.position,
		format = 1,
	}
	paraworld.flower.Store(msg,"flower",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"flower.Delete", func = "paraworld.flower.Delete_Test", input ={}}%
function paraworld.flower.Delete_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		format = 1,
	}
	paraworld.flower.Delete(msg,"flower",function(msg)	
		log(commonlib.serialize(msg));
	end);
end


