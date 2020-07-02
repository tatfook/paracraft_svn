
--NPL.load("(gl)script/kids/3DMapSystemUI/Map/mapProfile.lua");


Map3DApp.Profile = {};

function Map3DApp.Profile.AddTile(tileID)
	if(tonumber(tileID) == nil)then
		return;
	end
	
	--get profile
	local profile = Map3DSystem.App.Map.app:GetMCMLInMemory() or {};
	if(type(profile) ~= "table")then
		profile = {};
	end

	profile.UserTiles = profile.UserTiles or {};
	--add tileID
	if(profile.UserTiles.tiles)then
		--check if user already have this tile
		local id = tostring(tileID)
		for tile in string.gfind(profile.UserTiles.tiles,"%d+") do
			if(tile == id)then
				return;
			end
		end

		profile.UserTiles.tiles = profile.UserTiles.tiles..tileID..",";
	else
		profile.UserTiles.tiles = tileID..",";
	end
	
	Map3DSystem.App.Map.app:SetMCML(nil,profile,nil);
end

function Map3DApp.Profile.GetTiles()
	local profile = Map3DSystem.App.Map.app:GetMCMLInMemory();
	if(profile == nil)then
		return;
	end
	
	if(profile.UserTiles.tiles)then
		local tiles = {};
		local tileCount = 0;
		for tile in string.gfind(profile.UserTiles.tiles,"%d+")do
			tileCount = tileCount + 1;
			tiles[tileCount] = tonumber(tile);
		end
		return tiles,tileCount;
	end	
end