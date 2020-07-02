--[[
Title: Test file API
Author(s): LiXizhi
Date: 2010/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.file.test.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");


--passed: 上传文件 by Blocks
-- %TESTCASE{"file.UploadFileEx", func = "paraworld.file.UploadFileEx_Test", input ={src = "Screen Shots/auto.jpg", ispic=true, filepath = "LogicalPath/test.jpg"}}%
function paraworld.file.UploadFileEx_Test(input)

	local msg = {
		src = "Screen Shots/auto.jpg",
		overwrite = 1,
		ispic = 0,
		filepath = "upload/UploadFileEx_test.txt",
	};

	if(input and input.src) then	
		msg.src = input.src;
		msg.ispic = input.ispic;
		msg.filepath = input.filepath or msg.filepath;
	end

	paraworld.file.UploadFileEx(msg, "test", function(msg)
		commonlib.echo(msg);
	end)

	-- test another
	--local msg = {
		--ispic = true,
		--src = "temp/myphoto.jpg",
		--overwrite = 1,
		--filepath = "profiles/myphoto1.jpg",
	--};

	--paraworld.file.UploadFileEx(msg, "test1", function(msg)
		--commonlib.echo(msg);
	--end)
end