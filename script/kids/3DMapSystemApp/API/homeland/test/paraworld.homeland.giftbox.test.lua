--[[
Title: 
Author(s): Leio
Date: 2008/6/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/test/paraworld.homeland.giftbox.test.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.giftbox.lua");

-- %TESTCASE{"AcceptGift", func = "paraworld.homeland.home.AcceptGift_Test", input ={uid = "71d6a011-69da-4a4a-bcea-750d2ac954cd"}}%
function paraworld.homeland.home.GetHomeInfo_Test(input)
	local msg = {
		uid = input.uid,
	}
	paraworld.homeland.home.AcceptGift(msg,"Giftinfo",function(msg)	
		log(commonlib.serialize(msg));
	end);
end


-- %TESTCASE{"giftbox.Test_Get", func = "paraworld.homeland.giftbox.Test_Get", input = {nid=""}}%
function paraworld.homeland.giftbox.Test_Get(input)
	local msg = {
		nid = tostring(Map3DSystem.User.nid),
	};
	paraworld.homeland.giftbox.Get(msg, "giftbox.Test_Get", function(msg)
		log("==============paraworld.homeland.giftbox.Test_Get return:\n")
		commonlib.echo(msg);
	end);
end

-- %TESTCASE{"giftbox.Test_GetHortation", func = "paraworld.homeland.giftbox.Test_GetHortation", input = {nid=""}}%
function paraworld.homeland.giftbox.Test_GetHortation(input)
	local msg = {
		nid = tostring(Map3DSystem.User.nid),
	};
	paraworld.homeland.giftbox.GetHortation(msg, "test", function(msg)
		log("==============paraworld.homeland.giftbox.Test_GetHortation return:\n")
		commonlib.echo(msg);
	end);
end
