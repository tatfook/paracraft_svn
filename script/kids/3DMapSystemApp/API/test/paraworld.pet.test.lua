--[[
Title: 
Author(s): Spring
Date: 2010/03/09
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.pet.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

local pets = commonlib.gettable("paraworld.pets");

-- %TESTCASE{"paraworld.plants.Test_Pet_Get", func = "paraworld.pets.Test_Pet_Get", input={nid=0,id=0}}%
function paraworld.pets.Test_Pet_Get(input)
	paraworld.Pet.Get(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

-- %TESTCASE{"paraworld.pets.Test_Pet_RetrieveAdoptedDragon", func = "paraworld.pets.Test_Pet_RetrieveAdoptedDragon", input={petid=0}}%
function paraworld.pets.Test_Pet_RetrieveAdoptedDragon(input)
	paraworld.Pet.RetrieveAdoptedDragon(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

-- %TESTCASE{"paraworld.pets.Test_Pet_Fosterage", func = "paraworld.pets.Test_Pet_Fosterage", input={}}%
function paraworld.pets.Test_Pet_Fosterage(input)
	paraworld.Pet.Fosterage(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end
