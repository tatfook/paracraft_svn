--[[
Title: MQL test
Author(s): LiXizhi
Date: 2008/5/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.MQL.test.lua");
paraworld.MQL.Test_Query()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.users.Test()
end

-- %TESTCASE{"MQL.query", func = "paraworld.MQL.Test_Query", input ={appkey="", query="select uid,createDate from users order by createDate desc", cachepolicy="access plus 10 seconds"}}%
function paraworld.MQL.Test_Query(input)
	local msg = {
		query = "select uid,createDate from users order by createDate desc",
		-- do not use cache result
		cache_policy = System.localserver.CachePolicies["never"],
	};
	if(input.cachepolicy) then
		msg.cache_policy = System.localserver.CachePolicy:new(input.cachepolicy)
	end
	
	if(input and input.query) then
		msg.query = input.query
	end
	
	paraworld.MQL.query(msg, "test", function(msg)
		commonlib.log(msg);
	end);
end



-- passed 2008.12.6 
-- %TESTCASE{"paraworld.MQL.Query_Rest", func = "paraworld.MQL.Query_Rest", input={query = "select page(1,3,order by createDate desc) uid,uname,createdate from users where createdate > '2008-1-1'", format = "1"}}%
function paraworld.MQL.Query_Rest(input)
	local url = "http://api.test.pala5.cn/MQL/Query.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end