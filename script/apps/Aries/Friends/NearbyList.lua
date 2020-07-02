--[[
Title: code behind for page NearbyList.html
Author(s): WangTian
Date: 2009/5/3
Desc:  script/apps/Aries/Friends/NearbyList.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local NearbyListPage = commonlib.gettable("MyCompany.Aries.Friends.NearbyListPage");
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

local dsTable = {};
-- data source for items
function NearbyListPage.DS_Func_NearbyList(index, pageCtrl)
	
	if(index ~= nil) then
		return dsTable[index];
	elseif(index == nil) then
		-- clear the existing data
		dsTable = {};
		local world_info = WorldManager:GetCurrentWorld()
		if(world_info.team_mode == "random_pvp") then
			-- hide random pvp nearby players
			dsTable.count = 0;
			return dsTable.count;
		end

		--for all bipeds, get OPC status
		local player = ParaScene.GetObject("<player>");
		local playerCur = player;
		local count = 0;
		while(playerCur:IsValid() == true) do
			-- get next object
			playerCur = ParaScene.GetNextObject(playerCur);
			-- currently get all scene objects
			if(playerCur:IsValid() and playerCur:IsCharacter()) then
				local att = playerCur:GetAttributeObject();
				local isOPC = att:GetDynamicField("IsOPC", false);
				if(isOPC == true) then
					count = count + 1;
					local nid = string.gsub(playerCur.name, "@.*$", "");
					local name = att:GetDynamicField("name", "");
					nid = tonumber(nid);
					local priority = count;
					local isvip = false;
					local userinfo = ProfileManager.GetUserInfoInMemory(nid);
					if(userinfo and userinfo.energy and userinfo.energy > 0 and userinfo.mlel) then
						-- add the VIP contact priority by 10000 and sorted by m level
						priority = 10000 + priority + userinfo.mlel * 500;
						isvip = true;
					end
					dsTable[count] = {
						bshow = true, nid = nid, name = name, priority = priority, isvip = isvip,
						icon = "Texture/Aries/Friends/FriendsWnd_BuddyIcon_Online_32bits.png;0 0 32 26"
					};
				end
			end
			-- if cycled to the player character
			if(playerCur:equals(player) == true) then
				break;
			end
		end
		-- sort the table according to priority
		table.sort(dsTable, function(a, b)
			return (a.priority > b.priority);
		end);
		-- nearby OPC count
		dsTable.count = count;
		
		if(dsTable.count < 10) then
			dsTable.count = 10;
			local j;
			for j = (count+1), dsTable.count do
				dsTable[j] = {bshow = false};
			end
		end
		
		pageCtrl:SetUIValue("nearbycount", "("..count..")");
		
		return dsTable.count;
	end
end