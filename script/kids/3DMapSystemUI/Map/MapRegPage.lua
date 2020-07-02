--[[
Title: Map registration page
Author(s): LiXizhi
Date: 2008/3/21
Desc: Ask the user to pick a home land. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapRegPage.lua");
Map3DSystem.App.Map.MapRegPage:Create("Map.MapRegPage", parent, "_fi", 0,0,0,0);
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppDataPvd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/BuyRadomTile.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/mapProfile.lua");

-- create class
local MapRegPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemUI/Map/MapRegPage.html"});
Map3DSystem.App.Map.MapRegPage = MapRegPage;

-- function to be called when user completed or skipped all app registration steps. 
-- callback function to call after the registration page finish or skip
MapRegPage.OnFinishedFunc = nil;
MapRegPage.selectCity = nil;

-- called when user select to live in a city
function MapRegPage.OnSelect(btnName, values, bindingContext)
	local self = document:GetPageCtrl();
	local cityNode = self:GetNode(btnName);
	if(cityNode) then
		self:SetUIValue("map", cityNode:GetAttribute("value"))
		--TODO:get real city position
		if(btnName == "SocialZone")then
			self:CallMethod("map", "ZoomToXY", 0.5849609375, 0.5928955078125, "2D",0.94);
		elseif(btnName == "UniversityZone")then
			self:CallMethod("map", "ZoomToXY", 0.5947265625, 0.61181640625, "2D",0.92);
		elseif(btnName == "ComicZone")then
			self:CallMethod("map", "ZoomToXY", 0.625244140625, 0.60205078125, "2D",0.94);
		elseif(btnName == "MovieZone")then
			self:CallMethod("map", "ZoomToXY", 0.6153564453125, 0.6246337890625, "2D",0.96);
		end
		MapRegPage.selectCity = btnName;
	end	
end


-- Skip the registration page
function MapRegPage.OnSkip(btnName, values, bindingContext)
	MapRegPage.Leave();
end

-- Accept the current 
function MapRegPage.OnAccept(btnName, values, bindingContext)
	NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.map.test.lua");
	
	local page = document:GetPageCtrl();
	local ctl;

	--show buy land status
	ctl = page:FindControl("buyLandStatus")
	if(ctl)then
		ctl.text = "土地申购中,请稍等....";
	end
	
	--disable buy land button
	ctl = page:FindControl("Accept");
	if(ctl)then
		ctl.enabled = false;
	end

	--create buy land command
	local buyTileCmd = Map3DApp.BuyRandomTileCmd:new{
		id = "test",
		sessionkey = Map3DSystem.User.sessionkey,
		centerX = 0.13995361328125,
		centerY = 0.108978271484375,
		terrainType = 1,
		texture = "test",
		subscriber = page,
		onBuyTileDoneCallback = MapRegPage.OnBuyTileSucceed,
	};
	buyTileCmd:Execute();
end

function MapRegPage.OnBuyTileSucceed(page,tileID,issuccess)
	if(issuccess and tileID)then
		Map3DApp.Profile.AddTile(tileID);
		local ctl = page:FindControl("buyLandStatus");
		if(ctl)then
			ctl.text = "恭喜你,土地购买成功！可以在世界地图中查看，编辑你购买的土地，并在领地中创建独一无二的个人世界！";
		end
	else
		local ctl = page:FindControl("buyLandStatus");
		if(ctl)then
			ctl.text = "本次申请被抵抗, 请重新购买或者稍后再试 -_-#...";
		end
		
		ctl = page:FindControl("Accept");
		if(ctl)then
			ctl.enabled = true;
		end
	end
end

-- close this step. 
function MapRegPage.Leave()
	-- call the registration page callback function to return to the login process
	if(MapRegPage.OnFinishedFunc) then
		MapRegPage.OnFinishedFunc();
		MapRegPage.OnFinishedFunc = nil;
	end
	local map = CommonCtrl.GetControl("mb_map");
	if(map)then
		map:Show(false);
	end
	MapRegPage:Close();
end