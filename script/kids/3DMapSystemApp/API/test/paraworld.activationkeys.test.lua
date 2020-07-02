--[[
Title: test activationkeys
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.activationkeys.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");



-- %TESTCASE{"activationkeys.Test_GetActivationKeys", func = "paraworld.activationkeys.Test_GetActivationKeys", input = {}}%
function paraworld.activationkeys.Test_GetActivationKeys(input)
	local msg = {
		nid = tostring(Map3DSystem.User.nid),
	};
	paraworld.activationkeys.GetActivationKeys(msg, "test", function(msg)
		log("==============paraworld.activationkeys.GetActivationKeys return:\n")
		commonlib.echo(msg);
	end);
end

-- %TESTCASE{"activationkeys.Test_IAmInvitedBy", func = "paraworld.activationkeys.Test_IAmInvitedBy", input = {nid=""}}%
function paraworld.activationkeys.Test_IAmInvitedBy(input)
	local msg = {
		nid = input.nid,
	};
	paraworld.activationkeys.IAmInvitedBy(msg, "test", function(msg)
		log("==============paraworld.activationkeys.Test_IAmInvitedBy return:\n")
		commonlib.echo(msg);
	end);
end
