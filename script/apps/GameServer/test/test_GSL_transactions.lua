--[[
Title: test GSL transaction
Author(s): LiXizhi
Date: 2011.2.28
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/test/test_GSL_transactions.lua");
local test_GSL_transaction = commonlib.gettable("MyCompany.Aries.test_GSL_transaction")
test_GSL_transaction:TestFunction()


-------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_transactions.lua");
local test_GSL_transaction = commonlib.gettable("MyCompany.Aries.test_GSL_transaction")


-- test function 
function test_GSL_transaction:TestFunction()
	--[[ the output is 
	2011-03-01 13:00:58|main|debug|GSL_trans|begin transaction (nid 123):test0_async 
	test0_async is called
	2011-03-01 13:00:59|main|debug|GSL_trans|end transaction (nid 123):test0_async
	2011-03-01 13:00:59|main|debug|GSL_trans|begin transaction (nid 123):test1 
	test1 is called
	2011-03-01 13:00:59|main|debug|GSL_trans|end transaction (nid 123):test1
	2011-03-01 13:00:59|main|debug|GSL_trans|begin transaction (nid 123):test2 
	test2 is called param1param2
	2011-03-01 13:00:59|main|debug|GSL_trans|end transaction (nid 123):test2
	2011-03-01 13:00:59|main|debug|GSL_trans|begin transaction (nid 123):test0_async_nested_async 
	test0_async_nested_async is called
	2011-03-01 13:01:00|main|debug|GSL_trans|end transaction (nid 123):test0_async_nested_async
	2011-03-01 13:01:00|main|debug|GSL_trans|begin transaction (nid 123):test1_nested 
	test1_nested is called
	2011-03-01 13:01:00|main|debug|GSL_trans|end transaction (nid 123):test1_nested
	]]
	NPL.load("(gl)script/apps/GameServer/GSL_transactions.lua");
	local GSL_transaction = commonlib.gettable("Map3DSystem.GSL.GSL_transaction");
	GSL_transaction:enable_log(true);

	local nid = "123";
	GSL_transaction:create_queue(nid);

	-- test case 0: async trans with nested async trans
	GSL_transaction:begin_trans(nid, "test0_async",nil, function()
		-- do your logics here
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			log("test0_async is called\n")

			-- nested transaction
			GSL_transaction:begin_trans(nid, "test0_async_nested_async", nil, function()
					local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
						-- do your logics here
						log("test0_async_nested_async is called\n")
						-- if logics is asynchrounous, end_trans() should be called in the callback.
						GSL_transaction:end_trans(nid)
					end});
					mytimer:Change(1000, nil);
				end)
			-- if logics is asynchrounous, end_trans() should be called in the callback.
			GSL_transaction:end_trans(nid)
		end})
		mytimer:Change(1000, nil)
	end)

	-- test case 1: trans with nested trans
	GSL_transaction:begin_trans(nid, "test1", nil, function()
		-- do your logics here
		log("test1 is called\n")

		-- tested transaction
		GSL_transaction:begin_trans(nid, "test1_nested", nil, function()
				-- do your logics here
				log("test1_nested is called\n")
				-- if logics is asynchrounous, end_trans() should be called in the callback.
				GSL_transaction:end_trans(nid)
			end)
		-- if logics is asynchrounous, end_trans() should be called in the callback.
		GSL_transaction:end_trans(nid)
	end)

	-- test case 2: transaction function that takes parameters. 
	local function some_transaction_function(param1, param2)
		-- do your logics here
		log("test2 is called "..param1..param2.."\n")
		-- if logics is asynchrounous, end_trans() should be called in the callback.
		GSL_transaction:end_trans(nid)
	end
	GSL_transaction:begin_trans(nid, "test2", nil, some_transaction_function, "param1", "param2")
end

function test_GSL_transaction:TestStress()
	NPL.load("(gl)script/apps/GameServer/GSL_transactions.lua");
	local GSL_transaction = commonlib.gettable("Map3DSystem.GSL.GSL_transaction");
	GSL_transaction:enable_log(true);

	local nid = "123";
	GSL_transaction:create_queue(nid);

	local i;
	for i=1,100 do
		GSL_transaction:begin_trans(nid, i.."test2", nil, function()
			log(i.." called\n")
			-- GSL_transaction:end_trans(nid)
		end)
	end
	GSL_transaction:end_trans(nid)
	GSL_transaction:end_trans(nid)
	GSL_transaction:end_trans(nid)
end