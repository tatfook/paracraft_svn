--[[
Title: global store test
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.globalstore.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");




function paraworld.globalstore.test_create()
	
end

-- %TESTCASE{"globalstore.test_read", func = "paraworld.globalstore.test_read", input = {gsids="11"}}%
function paraworld.globalstore.test_read(input)

	local msg = {
		gsids = input.gsids,
		cache_policy = "access plus 0 day",
	};
	paraworld.globalstore.read(msg, "test", function(msg)
		log("+++++paraworld.globalstore.test_read+++++++\n");
		commonlib.echo(msg);
	end);
end

function paraworld.globalstore.test_delete()

	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		GSID = 3,
		Type = 5,
	};
	paraworld.globalstore.delete(msg, "test", function(msg)
		commonlib.echo(msg);
	end);
end

-- %TESTCASE{"globalstore.test_GetGSObtainCntInTimeSpan", func = "paraworld.globalstore.test_GetGSObtainCntInTimeSpan", input = {gsid="1001"}}%
function paraworld.globalstore.test_GetGSObtainCntInTimeSpan(input)

	local msg = {
		nid = Map3DSystem.User.nid,
		gsid = tonumber(input.gsid),
	};
	paraworld.globalstore.GetGSObtainCntInTimeSpan(msg, "test", function(msg)
		log("+++++paraworld.globalstore.test_GetGSObtainCntInTimeSpan+++++++\n");
		commonlib.echo(msg);
	end);
end

function paraworld.globalstore.test_item_GetAllCates()
	
	paraworld.globalstore.GetAllCates({cateid=0}, "test", function(msg)
		--[[
		]]
		commonlib.echo(msg);
		_guihelper.MessageBox(msg)
	end, "access plus 1 day");
end

function paraworld.globalstore.test_item_GetByCate()
	
	paraworld.globalstore.GetByCate({cateid=1, cache_policy="access plus 0 day"}, "test", function(msg)
		--[[
		]]
		commonlib.echo(msg);
		_guihelper.MessageBox(msg)
	end);
end