--[[
Title: code behind for page FamilyMemberList.html
Author(s): WangTian
Date: 2009/5/3
Desc:  script/apps/Aries/Chat/FamilyMemberList.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]

local FamilyMemberListPage = commonlib.gettable("MyCompany.Aries.Chat.FamilyMemberListPage");

FamilyMemberListPage.isAllowAddFriend = true;

function FamilyMemberListPage.OnInit(page)
end

-- The data source function. 
function FamilyMemberListPage.DS_Func_Members(dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        FamilyMemberListPage.GetMembers(pageCtrl, "access plus 10 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			if(pageCtrl) then
				pageCtrl:SetUIValue("onlinecount", "("..(dsTable.OnlineCount or 0).."/"..(dsTable.RealCount or 0)..")");
			end
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end

-- get friends web service call. it will refresh page once finished. 
function FamilyMemberListPage.GetMembers(pageCtrl, cachepolicy, output)
	-- fetching
	output.status = 1;
	local Friends = MyCompany.Aries.Friends;
	Friends.GetMyFamilyInfo(function(msg)
		-- msg if no friends:
		-- echo:return { pagecnt=0, nids="" }
		
        -- my family members
		output.RealCount = Friends.GetMyFamilyMemberCountInMemory();
		output.OnlineCount = 0;
	    output.Count = Friends.GetMyFamilyMemberCountInMemory();
	    local i;
	    for i = 1, output.Count do
			local nid = Friends.GetMyFamilyMemberNIDByIndexInMemory(i);
			local priority = i;
			NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
			if(MyCompany.Aries.Chat.FamilyChatWnd.IsFamilyMemberOnline(nid)) then
				-- add the online contact priority by 10000
				priority = 10000 + priority;
				output.OnlineCount = output.OnlineCount + 1;
			end
			
			local identity = "member";
			if(Friends.IsMyFamilyDeputyInMemory(nid)) then
				priority = 3000 + priority;
				identity = "deputy";
			end
			if(Friends.IsMyFamilyAdminInMemory(nid)) then
				priority = 7000 + priority;
				identity = "admin";
			end
			
			output[i] = {
				bshow = true, 
				nid = nid, 
				priority = priority, 
				identity = identity,
			};
	    end
	    -- sort the table according to priority
	    table.sort(output, function(a, b)
			return (a.priority > b.priority);
	    end);
        -- fill at least 30 rows of friends
		if(output.Count < 12) then
			output.Count = 12;
			local j;
			for j = (output.RealCount + 1), output.Count do
				output[j] = {
					bshow = false,
				};
			end
		end
		
		commonlib.resize(output, output.Count)
		output.status = 2;
		pageCtrl:Refresh(0.1);
	end, "access plus 10 minutes");
end
