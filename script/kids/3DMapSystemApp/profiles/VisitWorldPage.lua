--[[
Title: code behind page for VisitWorldPage.html
Author(s): LiXizhi
Date: 2008/6/16
Desc: 
visit world page displays information about a given user's world. 
This is usually used when we meat a stranger and wants to visit the virtual worlds created by him.
Hence, we display both its homeworlds and dreamworlds in a tabbed page. The default homeworld is selected and displayed in full detail, 
with a one button click to download/join the world. 

<verbatim>
	script/kids/3DMapSystemApp/profiles/VisitWorldPage.html?uid=For_whom_the_worlds_are_shown
</verbatim>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/VisitWorldPage.lua");
-------------------------------------------------------
]]

local VisitWorldPage = {};
commonlib.setfield("Map3DSystem.App.profiles.VisitWorldPage", VisitWorldPage)

local function world_order_by_date_cmpfct(a,b)
	if(a.createDate and type(a.createDate) == type(b.createDate)) then
		return a.createDate > b.createDate;
	else
		return true;	
	end
end
  
-- The data source function. 
function VisitWorldPage.DataSourceFunc(index, dsTable, uid, pageCtrl)
	if(not dsTable.status) then
        -- finding all files in the worlds directory of the given uid. 
        if(uid == "loggedinuser") then
			uid = nil
        end
        local msg = {
			ownerUID = uid,
			filepath = "worlds/*.zip",
		};
		paraworld.file.FindFile(msg, "paraworld", function(msg)
			if(msg and (msg.errorcode==0 or errorcode==nil)) then
				if(msg.files) then
					local i, file
					for i, file in ipairs(msg.files) do 
						file.worldname = string.match(file.filepath, "worlds/([^/\\%.]+)") or "unknown"
						--file.savepath = "worlds/downloads/"..file.worldname.."_"..(string.match(file.fileURL, "([^/\\]+)$") or "");
						file.savepath = string.format("worlds/downloads/%s_%s.zip", file.worldname, tostring(file.id));
						dsTable[i] = file;
					end
					dsTable.Count = #msg.files;
				else
					dsTable.Count = 0;
				end
			else
				log("warning: error fetching worlds\n")    
				dsTable.Count = 0;
			end
			commonlib.resize(dsTable, dsTable.Count)
			if(dsTable.Count>=2) then
				-- sort world by date
				table.sort(dsTable, world_order_by_date_cmpfct);
			end	
			dsTable.status = 2;
			pageCtrl:Refresh();
		end)
		
    elseif(dsTable.status==2) then    
        if(index==nil) then
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end


---------------------------------
-- page event handlers
---------------------------------

-- there 4 fetching stages: 
-- (1) fetch the tile ids from map profiles for the given uid 
-- (2) fetch tileInfo for the homeworld tileID  
-- (3) fetch the worldInfo from the tileInfo.worldInfo 
-- (4) user clicks to download and join the world 
function VisitWorldPage.OnInit()
	local self = document:GetPageCtrl();
	
	local uid = self:GetRequestParam("uid");
	if(uid == nil or uid=="" or uid == "loggedinuser") then
		-- get current user ID as the uid
		uid = Map3DSystem.App.profiles.ProfileManager.GetUserID();
	end
	local node = self:GetNode("homeworld");
	
	if(uid) then
		local HomeWorldTileID = self:GetNodeValue("HomeWorldTileID");
		local HomeWorldWorldID = self:GetNodeValue("HomeWorldWorldID");
		local HomeWorldWorldInfo = self:GetNodeValue("HomeWorldWorldInfo");
		
		--
		-- fetch the tile ids from map profiles for the given uid 
		-- 
		if(not HomeWorldTileID and not node:GetAttribute("fetching")) then
			self:SetNodeValue("result", "正在读取土地信息, 请稍后...");
			node:SetAttribute("fetching", true);
			self:GetNode("NoHomeWorld"):SetAttribute("display","none");
			self:GetNode("RemoteWorld"):SetAttribute("display","none");
			-- we will retrieve tile ID from uid. 
			
			local bFetching = Map3DSystem.App.Map.app:GetMCML(uid, function(uid, app_key, bSucceed)
				local profile;
				if(bSucceed) then
					profile = Map3DSystem.App.Map.app:GetMCMLInMemory(uid);
					if(profile~=nil) then
						if(profile.UserTiles and type(profile.UserTiles.tiles)=="string") then
							-- get the first tileID as the homeworld tile id. 
							HomeWorldTileID = tonumber(string.match(profile.UserTiles.tiles, "%d+"));
						end	
					end
				else
					self:SetNodeValue("result", "无法读取土地信息.");
					log("warning: error fetching map mcml\n")
				end
				HomeWorldTileID = HomeWorldTileID or -1;
				self:SetNodeValue("HomeWorldTileID", HomeWorldTileID)
				
				node:SetAttribute("fetching", false);
				self:Refresh();
			end, System.localserver.CachePolicies["1 day"])
		end
		if(HomeWorldTileID and HomeWorldTileID<0) then
			self:SetNodeValue("result", "尚没有被主人建设过");
			self:GetNode("NoHomeWorld"):SetAttribute("display",nil);
			self:GetNode("RemoteWorld"):SetAttribute("display","none");
		end
		
		--
		-- fetch tileInfo.worldid and tileInfo for the homeworld tile ID  
		-- 
		if(not HomeWorldWorldID and HomeWorldTileID and HomeWorldTileID>0 and not node:GetAttribute("fetching")) then
			self:SetNodeValue("result", string.format("正在读取家园描述数据(tileid=%d)...", HomeWorldTileID));
			node:SetAttribute("fetching", true);
			-- get land info
			local bFetching = Map3DSystem.App.Map.GetTileByID(HomeWorldTileID, function(tileInfo)
				if(tileInfo) then
					local node,value;
		
					--update node values
					self:SetNodeValue("landName", tileInfo.name or "未命名土地")
					self:SetNodeValue("city", tileInfo.cityName or "")
					self:SetNodeValue("owner", tileInfo.ownerUserName or "")
					self:SetNodeValue("user", tileInfo.username or "")
					self:SetNodeValue("price", tostring(tileInfo.price or 0))
					self:SetNodeValue("rank", tostring(tileInfo.rank or 1))
					self:SetNodeValue("landState", Map3DApp.DataPvd.TranslateTileState(tileInfo.tileState))
					self:SetNodeValue("landID", tostring(tileInfo.id or 0))
					
					HomeWorldWorldID = tileInfo.worldid;
				else
					self:SetNodeValue("result", string.format("无法读取家园描述数据(tileid=%d)", HomeWorldTileID));
				end	
				HomeWorldWorldID = HomeWorldWorldID or -1;
				self:SetNodeValue("HomeWorldWorldID", HomeWorldWorldID)
				node:SetAttribute("fetching", false);
				self:Refresh();
			end);
		end
		
		--
		-- fetch the worldInfo from the tileInfo.worldInfo 
		-- 
		if(not HomeWorldWorldInfo and HomeWorldWorldID and not node:GetAttribute("fetching")) then
			if(HomeWorldWorldID<=0 ) then
				self:SetNodeValue("result", "尚没有被主人建设过");
				self:GetNode("NoHomeWorld"):SetAttribute("display",nil);
				self:GetNode("RemoteWorld"):SetAttribute("display","none");
			else
				self:SetNodeValue("result", string.format("正在读取世界数据(worldid=%d)...", HomeWorldWorldID));
				node:SetAttribute("fetching", true);
				local bFetching = Map3DSystem.App.Map.GetWorldByID(HomeWorldWorldID, function(worldInfo)
					if(worldInfo) then
						HomeWorldWorldInfo = worldInfo;
						self:GetNode("NoHomeWorld"):SetAttribute("display","none");
						local node = self:GetNode("RemoteWorld");
						node:SetAttribute("display", nil);
						
						-- TODO: set pe:downloader src, dest and pe:world worldpath attributes
					else
						self:SetNodeValue("result", string.format("无法读取世界描述数据(worldid=%d)", HomeWorldWorldID));
					end	
					HomeWorldWorldInfo = HomeWorldWorldInfo or "nil";
					self:SetNodeValue("HomeWorldWorldInfo", HomeWorldWorldInfo)
					node:SetAttribute("fetching", false);
					self:Refresh();
				end);
			end
		end
	else
		self:SetNodeValue("result", "没有指定用户");
		self:GetNode("NoHomeWorld"):SetAttribute("display","none");
		self:GetNode("RemoteWorld"):SetAttribute("display","none");
	end	
end

