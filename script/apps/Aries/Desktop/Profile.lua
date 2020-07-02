--[[
Title: Desktop Profile Area for Aries App
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Area: 
	---------------------------------------------------------
	| Profile										Mini Map|
	|														|
	| 													 C	|
	| 													 h	|
	| 													 a	|
	| 													 t	|
	| 													 T	|
	| 													 a	|
	| 													 b	|
	|													 s	|
	|														|
	|														|
	|														|
	|														|
	| Menu | QuickLaunch | CurrentApp | UtilBar1 | UtilBar2	|
	|©»©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥Dock©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¥©¿ |
	---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Profile.lua");
MyCompany.Aries.Desktop.Profile.InitProfile();
------------------------------------------------------------
]]

-- create class
local libName = "AriesDesktopProfile";
local Profile = commonlib.gettable("MyCompany.Aries.Desktop.Profile");

-- invoked at Desktop.InitDesktop()
function Profile.InitProfile()
end

-- view user full profile with uid
-- @param uid: user id
function Profile.ViewFullProfile(uid)
	-- TODO: ugly code
	if(string.find(uid, "-")) then
		--System.App.Commands.Call("Profile.Aries.ShowMiniProfile", {uid=uid});
		System.App.Commands.Call("Profile.Aries.ShowFullProfile", {uid=uid});
	else
		System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid=uid});
	end
end