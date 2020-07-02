--[[
Title: 
Author(s): Gosling
Date: 2010/01/11
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.family.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.petevolved.lua");

local family = commonlib.gettable("paraworld.family");

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_GainTroubleTree", func = "paraworld.family.Test_Family_GainTroubleTree", input={}}%
function paraworld.family.Test_Family_GainTroubleTree(input)
	paraworld.Family.GainTroubleTree(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_Create", func = "paraworld.family.Test_Family_Create", input={name="Super",desc="We are biggest!"}}%
function paraworld.family.Test_Family_Create(input)
	paraworld.Family.Create(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_Invite", func = "paraworld.family.Test_Family_Invite", input={familyid=1,tonid=12345}}%
function paraworld.family.Test_Family_Invite(input)
	paraworld.Family.Invite(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_AcceptInvite", func = "paraworld.family.Test_Family_AcceptInvite", input={familyid=1}}%
function paraworld.family.Test_Family_AcceptInvite (input)
	paraworld.Family.AcceptInvite(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_Request", func = "paraworld.family.Test_Family_Request", input={familyid=1}}%
function paraworld.family.Test_Family_Request(input)
	paraworld.Family.Request(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_AcceptRequest", func = "paraworld.family.Test_Family_AcceptRequest", input={requestnid=12345,familyid=1,}}%
function paraworld.family.Test_Family_AcceptRequest(input)
	paraworld.Family.AcceptRequest(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_SetDeputy", func = "paraworld.family.Test_Family_SetDeputy", input={familyid=1,newdeputynid=12345,}}%
function paraworld.family.Test_Family_SetDeputy(input)
	paraworld.Family.SetDeputy(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end


--test passed
-- %TESTCASE{"paraworld.family.Test_Family_SetAdmin", func = "paraworld.family.Test_Family_SetAdmin", input={familyid=1,newadmin=12345,}}%
function paraworld.family.Test_Family_SetAdmin(input)
	paraworld.Family.SetAdmin(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_UpdateDesc", func = "paraworld.family.Test_Family_UpdateDesc", input={familyid=1,desc="This is new",}}%
function paraworld.family.Test_Family_UpdateDesc(input)
	paraworld.Family.UpdateDesc(input, "test", function (msg)
		commonlib.echo(msg);
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_Get", func = "paraworld.family.Test_Family_Get", input={idorname="1",}}%
function paraworld.family.Test_Family_Get(input)
	paraworld.Family.Get(input, "test", function (msg)
		commonlib.log("value returns!\n");
		commonlib.echo(msg);
		commonlib.log("end!\n");
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_RemoveMember", func = "paraworld.family.Test_Family_RemoveMember", input={familyid=1,removenid=12345,}}%
function paraworld.family.Test_Family_RemoveMember(input)
	paraworld.Family.RemoveMember(input, "test", function (msg)
		commonlib.log("value returns!\n");
		commonlib.echo(msg);
		commonlib.log("end!\n");
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_Quit", func = "paraworld.family.Test_Family_Quit", input={familyid=1}}%
function paraworld.family.Test_Family_Quit(input)
	paraworld.Family.Quit(input, "test", function (msg)
		commonlib.log("value returns!\n");
		commonlib.echo(msg);
		commonlib.log("end!\n");
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_Family_GetNewest", func = "paraworld.family.Test_Family_GetNewest", input={}}%
function paraworld.family.Test_Family_GetNewest(input)
	paraworld.Family.GetNewest(input, "test", function (msg)
		commonlib.log("value returns!\n");
		commonlib.echo(msg);
		commonlib.log("end!\n");
	end)
end

-- %TESTCASE{"paraworld.family.Test_Family_Delete", func = "paraworld.family.Test_Family_Delete", input={familyid=1}}%
function paraworld.family.Test_Family_Delete(input)
	paraworld.Family.Delete(input, "test", function (msg)
		commonlib.log("value returns!\n");
		commonlib.echo(msg);
		commonlib.log("end!\n");
	end)
end

--test passed
-- %TESTCASE{"paraworld.family.Test_UseItem", func = "paraworld.family.Test_UseItem", input={nid=78975924,petid=15,itemguid=60,bag=1}}%
function paraworld.family.Test_UseItem(input)
	paraworld.homeland.petevolved.UseItem(input, "test", function (msg)
		commonlib.log("value returns!\n");
		commonlib.echo(msg);
		commonlib.log("end!\n");
	end)
end
