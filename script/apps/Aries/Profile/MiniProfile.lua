--[[
Title: code behind for page MiniProfile.html
Author(s): WangTian
Date: 2009/6/4
Desc:  script/apps/Aries/Profile/MiniProfile.html?nid=123
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local MiniProfilePage = {};
commonlib.setfield("MyCompany.Aries.MiniProfilePage", MiniProfilePage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function MiniProfilePage.OnInit(nid)
	local page = document:GetPageCtrl();
	-- use nid to fetch all profile data
	log("use nid:"..nid.." to fetch all profile data\n");
end

function MiniProfilePage.OnClose()
	document:GetPageCtrl():CloseWindow();
end

-- functional other user operation from left to right
function MiniProfilePage.OnSeeFullProfile(nid)
end

function MiniProfilePage.OnAddAsFriend(nid)
end

function MiniProfilePage.OnVisitHome(nid)
end

function MiniProfilePage.OnAddToBlacklist(nid)
end

function MiniProfilePage.OnReportAnnoy(nid)
end

function MiniProfilePage.OnRemote1(uid)
end

function MiniProfilePage.OnRemote2(uid)
end

function MiniProfilePage.OnRemote3(uid)
end
