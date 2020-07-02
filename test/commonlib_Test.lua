--[[
Author: Li,Xizhi
Date: 2007-6
Desc: testing commonlib functions.
-----------------------------------------------
NPL.load("(gl)test/commonlib_Test.lua");
TestSerializeTable()
-----------------------------------------------
]]
log("commonlib_Test begins...\r\n");

-- tested on 2007.6.15, LiXizhi
function TestSerializeTable()
	ParaIO.DeleteFile("temp/t.txt");
	-- test empty file
	local t = commonlib.LoadTableFromFile("temp/t.txt")
	if(t~=nil) then 
		log("empty file test failed\n");
	else	
		log("empty file test succeeded\n");
	end	
	
	-- test commonlib.SaveTableToFile
	t = {
		data1 =1 ,
		data2 = "aaa",
		subtable = {
			line1 = "aaa"
		}
	}
	if(commonlib.SaveTableToFile(t, "temp/t.txt")) then
		log("commonlib.SaveTableToFile succeed\n");
	else
		log("commonlib.SaveTableToFile failed\n");
	end
	
	-- test commonlib.LoadTableFromFile
	t = commonlib.LoadTableFromFile("temp/t.txt")
	if(t~=nil) then 
		log("commonlib.LoadTableFromFile test succeeded\n");
		log(commonlib.serialize(t).."\n");
	else	
		log("commonlib.LoadTableFromFile test failed\n");
	end	
end



log("commonlib_Test complete...\r\n");
