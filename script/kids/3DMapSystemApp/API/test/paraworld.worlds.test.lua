--[[
Title: 
Author(s): LiXizhi
Date: 2009/10/15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.worlds.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

local worlds = commonlib.gettable("paraworld.worlds");

-- test passed 2009.10.15
-- %TESTCASE{"paraworld.worlds.Test_WorldWorlds_Get", func = "paraworld.worlds.Test_WorldWorlds_Get", input={pageIndex = 0, pageSize = 20,}, output="temp/paraworld.worlds.Get.test"}%
function paraworld.worlds.Test_WorldWorlds_Get(input,output)
	paraworld.WorldServers.Get(input, "test", function (msg)
		commonlib.echo("==paraworld.worlds.Get.test Result Begin===")
		commonlib.echo(msg);
		commonlib.echo("==paraworld.worlds.Get.test Result End==="..output)
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end
	end)
end


-- test passed 2009.10.15
-- %TESTCASE{"paraworld.worlds.Test_WorldWorlds_GetRecommend", func = "paraworld.worlds.Test_WorldWorlds_GetRecommend", input={nid=50333182,}, output="temp/paraworld.worlds.GetRecommend.test"}%
function paraworld.worlds.Test_WorldWorlds_GetRecommend(input,output)
	paraworld.WorldServers.GetRecommend(input, "test", function (msg)
		commonlib.echo("==paraworld.worlds.GetRecommend.test Result Begin===")
		commonlib.echo(msg);
		commonlib.echo("==paraworld.worlds.GetRecommend.test Result End===")
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end		
	end)
end

-- test passed 2009.10.15
-- %TESTCASE{"paraworld.worlds.Test_WorldWorlds_GetByIDs", func = "paraworld.worlds.Test_WorldWorlds_GetByIDs", input={ids="(1)1001,(2)1001,"}, output="temp/paraworld.worlds.GetByIDs.test"}%
function paraworld.worlds.Test_WorldWorlds_GetByIDs(input,output)
	paraworld.WorldServers.GetByIDs(input, "test", function (msg)
		commonlib.echo("==paraworld.worlds.GetByIDs.test Result Begin===")
		commonlib.echo(msg);
		commonlib.echo("==paraworld.worlds.GetByIDs.test Result End===")
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end		
	end)
end

-- test passed 2009.12.10
-- %TESTCASE{"paraworld.worlds.Test_WorldWorlds_GetServerObject", func = "paraworld.worlds.Test_WorldWorlds_GetServerObject", input={keys="weather,sky"}, output="temp/paraworld.worlds.GetServerObject.test"}%
function paraworld.worlds.Test_WorldWorlds_GetServerObject(input,output)
	paraworld.WorldServers.GetServerObject(input, "test", function (msg)
		commonlib.echo("==paraworld.worlds.GetServerObject.test Result Begin===")
		commonlib.echo(msg);
		commonlib.echo("==paraworld.worlds.GetServerObject.test Result End===")
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end		
	end)
end
