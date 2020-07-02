--[[
Title: 
Author(s): Leio
Date: 2008/4/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/test/paraworld.homeland.plantevolved.test.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.plantevolved.lua");

-- GetAllDescriptors
-- %TESTCASE{"GetAllDescriptors", func = "paraworld.homeland.plantevolved.GetAllDescriptors_Test", input ={ids = "1",}}%
function paraworld.homeland.plantevolved.GetAllDescriptors_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		ids = tostring(input.ids),
	}
	paraworld.homeland.plantevolved.GetAllDescriptors(msg,"plantevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- Water
-- %TESTCASE{"Water", func = "paraworld.homeland.plantevolved.Water_Test", input ={id = 1,}}%
function paraworld.homeland.plantevolved.Water_Test(input)
	local msg = {
		id = input.id,
	}
	paraworld.homeland.plantevolved.Water(msg,"plantevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- Debug
-- %TESTCASE{"Debug", func = "paraworld.homeland.plantevolved.Debug_Test", input ={id = 1,}}%
function paraworld.homeland.plantevolved.Debug_Test(input)
	local msg = {
		id = input.id,
	}
	paraworld.homeland.plantevolved.Debug(msg,"plantevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- GainFeeds
-- %TESTCASE{"GainFeeds", func = "paraworld.homeland.plantevolved.GainFeeds_Test", input ={id = 1,}}%
function paraworld.homeland.plantevolved.GainFeeds_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		id = input.id,
	}
	paraworld.homeland.plantevolved.GainFruits(msg,"plantevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- Delete
-- %TESTCASE{"Delete", func = "paraworld.homeland.plantevolved.Delete_Test", input ={id = 1,}}%
function paraworld.homeland.plantevolved.Delete_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		id = input.id,
	}
	paraworld.homeland.plantevolved.Delete(msg,"plantevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end



