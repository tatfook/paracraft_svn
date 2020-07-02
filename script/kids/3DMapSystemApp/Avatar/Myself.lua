--[[
Title: logged-in user avatar manager, myself avatar
Author(s): WangTian
Date: 2008/3/16
Desc: Myself wraps all the web services about current logg-in user avatar information
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/avatar/Myself.lua");
Map3DSystem.App.Avatar.Myself.***()
-------------------------------------------------------
]]

if(not Map3DSystem.App.Avatar.Myself) then Map3DSystem.App.Avatar.Myself = {} end

function Map3DSystem.App.Avatar.Myself.IsRegistrationComplete()
end