--[[
Title: code behind for page FamilyProfile.html
Author(s): WangTian
Date: 2009/6/4
Desc:  script/apps/Aries/Profile/FamilyProfile.html?nid=123
Use Lib:
NPL.load("(gl)script/apps/Aries/Profile/FamilyProfile.lua");
local FamilyProfilePage = commonlib.gettable("MyCompany.Aries.FamilyProfilePage");
FamilyProfilePage.ShowFamilyInfoOfNID(nid)
-------------------------------------------------------
-------------------------------------------------------
]]
local FamilyProfilePage = commonlib.gettable("MyCompany.Aries.FamilyProfilePage");
---------------------------------
-- page event handlers
---------------------------------

-- the profile page must be manually closed
FamilyProfilePage.isEditing = false;

-- init
function FamilyProfilePage.OnInit(nid)
end

function FamilyProfilePage.OnClose()
	document:GetPageCtrl():CloseWindow();
end
function FamilyProfilePage.DoJoin()
	if(System.options.version=="kids")then
		NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30342_HaqiGroupJoin.lua");
		local familyid = MyCompany.Aries.FamilyProfilePage.familyid;
		MyCompany.Aries.Quest.NPCs.HaqiGroupJoin.DoJoinGroup(familyid)
	else
		NPL.load("(gl)script/apps/Aries/Family/FamilyHelper.lua");
		local FamilyHelper = commonlib.gettable("Map3DSystem.App.Family.FamilyHelper");
		local familyid = MyCompany.Aries.FamilyProfilePage.familyid;
		FamilyHelper.DoRequest(familyid);
		FamilyProfilePage.OnClose();
	end
end
function FamilyProfilePage.ShowFamilyInfoOfNID(nid)
	if(not nid)then
		return
	end
	local ProfileManager = System.App.profiles.ProfileManager;
	ProfileManager.GetUserInfo(nid, "FamilyProfile_userinfo", function(msg)
		local userinfo = ProfileManager.GetUserInfoInMemory(nid);
		if(userinfo) then
			if(userinfo.family ~= "") then
				local Friends = MyCompany.Aries.Friends;
				Friends.GetFamilyInfo(userinfo.family, function(msg)
					if(msg and not msg.errorcode) then	
						local role = "member";
						local nid_deputy;
						for nid_deputy in string.gfind(msg.deputy, "([^,]+)") do 
							nid_deputy = tonumber(nid_deputy);
							if(nid_deputy == nid) then
								role = "deputy";
								break;
							end
						end
						if(nid == tonumber(msg.admin)) then
							role = "admin";
						end
						local createtime = "今天";
						local year, month, day, hour, minute, second = string.match(msg.createdate, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)");
						if(month and day and year and hour and minute and second) then
							year = tonumber(year);
							month = tonumber(month);
							day = tonumber(day);
							createtime = year.."年"..month.."月"..day.."日";
						end
						
						-- show the family info
						local url;
						if(System.options.version=="kids")then
							url = string.format("script/apps/Aries/Profile/FamilyProfile.html?nid=%s",tostring(nid));
						else
							url = string.format("script/apps/Aries/Profile/FamilyProfile.teen.html?nid=%s",tostring(nid));
						end
						FamilyProfilePage.familyname = msg.name;
						FamilyProfilePage.familyid = string.format("%05d", msg.id);
						FamilyProfilePage.familydesc = msg.desc;
						FamilyProfilePage.familyrole = role;
						FamilyProfilePage.createtime = createtime;
						
						commonlib.echo(msg);
						
						local contribute = 0;
						local i;
						for i = 1, #(msg.members) do
							local member = msg.members[i];
							if(member.nid == nid) then
								contribute = member.contribute;
								break;
							end
						end
						
						FamilyProfilePage.familylevel = msg.level;
						FamilyProfilePage.membercount = #(msg.members);
						FamilyProfilePage.contribution = contribute;
						
						local width,height;
						if(System.options.version=="kids")then
							width,height = 402,478;
						else
							width,height = 330,470;
						end
						System.App.Commands.Call("File.MCMLWindowFrame", {
							url = url, 
							app_key = MyCompany.Aries.app.app_key, 
							name = "FamilyProfile", 
							isShowTitleBar = false,
							DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
							style = CommonCtrl.WindowFrame.ContainerStyle,
							zorder = 2,
							allowDrag = true,
							enable_esc_key = true,
							directPosition = true,
								align = "_ct",
									x = -width/2,
									y = -height/2,
									width = width,
									height = height,
						});
					end
				end, "access plus 10 minutes");
			else
				NPL.load("(gl)script/ide/XPath.lua");
				local nickname = userinfo.nickname;
				nickname = commonlib.XPath.XMLEncodeString(nickname);
				_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:24px;">%s（%s）还未加入任何家族呢。</div>]], nickname or "", MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)));
			end
		end
	end);
end