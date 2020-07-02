--[[
Title: 
Author(s): Spring
Date: 2010/02/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.plant.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

local plants = commonlib.gettable("paraworld.plants");

-- %TESTCASE{"paraworld.plants.Test_Plant_GainFeeds", func = "paraworld.plants.Test_Plant_GainFeeds", input={id="",ids=""}}%
function paraworld.plants.Test_Plant_GainFeeds(input)
	paraworld.Plant.GainFeeds(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

-- %TESTCASE{"paraworld.plants.Test_Plant_GetByIDs", func = "paraworld.plants.Test_Plant_GetByIDs", input={nid=0,ids=""}}%
function paraworld.plants.Test_Plant_GetByIDs(input)
	paraworld.Plant.GetByIDs(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end