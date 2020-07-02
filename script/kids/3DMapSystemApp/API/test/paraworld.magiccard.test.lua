--[[
Title: 
Author(s): Spring
Date: 2010/02/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.MagicCard.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

--test passed
local magicCards = commonlib.gettable("paraworld.magicCards");

-- %TESTCASE{"paraworld.magicCards.Test_MagicCard_Get", func = "paraworld.magicCards.Test_MagicCard_Get", input={card=""}}%
function paraworld.magicCards.Test_MagicCard_Get(input)
	paraworld.MagicCard.Get(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.magicCards.Test_MagicCard_Consume", func = "paraworld.magicCards.Test_MagicCard_Consume", input={card="6611602085242475",ip="119.145.5.36"}}%
function paraworld.magicCards.Test_MagicCard_Consume(input)
	paraworld.MagicCard.Consume(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end