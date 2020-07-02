--[[
Title: farst
Author(s): zrf
Date: 2010/9/16

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30500_Farst.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local Farst = commonlib.gettable("MyCompany.Aries.Quest.NPCs.Farst");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


function Farst.main()

end

--function Farst.Init()
	--Farst.pagectrl = document:GetPageCtrl();
	--Farst.itemmanager = System.Item.ItemManager;
	--Farst.nid = Farst.nid or System.App.profiles.ProfileManager.GetNID();
	--Farst.nid = tonumber(Farst.nid);
	--local bean = MyCompany.Aries.Pet.GetBean();
	--if(bean)then
		--Farst.combatlevel = bean.combatlel or 0;
	--end
	--Farst.money = MyCompany.Aries.Player.GetMyJoybeanCount();
--end
--
--function Farst.HuoNiaoCheck()
	--Farst.IslandName = "火鸟岛";
	--Farst.cost = 10;
	--Farst.needlevel = 10; 
	--Farst.id = "FlamingPhoenixIsland"; 
	--local gsid = 20901;
--
	--if( Farst.money < Farst.cost )then
		--return 1;
	--elseif( Farst.combatlevel < Farst.needlevel )then
		--return 2;
	--elseif(not hasGSItem(gsid))then
		--return 20;
	--end
--
	--return 0;
--end
--
--function Farst.BingHuoCheck()
	--Farst.IslandName = "冰火岛";
	--Farst.cost = 20;
	--Farst.needlevel = 10; 
	--Farst.id = "FrostRoarIsland"; 
	--if( Farst.money < Farst.cost )then
		--return 1;
	--elseif( Farst.combatlevel < Farst.needlevel )then
		--return 2;
	--end
--
	--return 0;
--end
--
--function Farst.GetIslandName()
	--return Farst.IslandName or "";
--end
--
--function Farst.GetNeedLevel()
	--return Farst.needlevel or 0;
--end
--
--function Farst.GetCost()
	--return Farst.cost or 0;
--end
--
--function Farst.Goto()
	--MyCompany.Aries.Player.AddMoney(-Farst.cost, function(msg)
		--System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {name=Farst.id});
	--end, true);
--end
function Farst.CanShow_Teen_61HaqiTown_teen()
	return Farst.CanShow_Teen("61HaqiTown_teen")
end
function Farst.CanShow_Teen_FlamingPhoenixIsland()
	return Farst.CanShow_Teen("FlamingPhoenixIsland")
end
function Farst.CanShow_Teen_FrostRoarIsland()
	return Farst.CanShow_Teen("FrostRoarIsland")
end
function Farst.CanShow_Teen_AncientEgyptIsland()
	return Farst.CanShow_Teen("AncientEgyptIsland")
end
function Farst.CanShow_Teen(worldname)
	local world_info = WorldManager:GetCurrentWorld()
	if(world_info and worldname)then
		if(world_info.name == worldname)then
			return false;
		end
	end
	return true;
end
function Farst.GoToWorld_Teen(worldname)
	if(not worldname)then return end
	System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {name = worldname});
	
end
function Farst.OpenWorldMap_Teen()
	NPL.load("(gl)script/apps/Aquarius/Desktop/LocalMap.lua");
	local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
	System.App.Commands.Call("Profile.Aries.LocalMap", {tab_name="all_worlds"});
end
function Farst.OpenWorldMap()
	NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
	local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
	MyCompany.Aries.Desktop.LocalMap.ShowWorldMap();
end
function Farst.GetDarkForestIslandMap()
	if(hasGSItem(20904)) then
		_guihelper.MessageBox("你已经开启过幽暗岛地图，快前去冒险吧");
		return;
	end
	local wandsGSID = {2343,2344,2345,2346,2347,2348,2349,2350,2351,2352,2353,2354,2355,2356,2357,2358,2359,2360,2361,2362,2363,2364,2365,2366,2367,2368,2369,2370,2371,2372,2373,2374,2375,2376,2377,2378,2379,2380,2381,2382,2383,2384,2385,2386,2387,2119,2120,2121,2122,2123,2202,2203,2204,2205,2206,2234,2235,2236,2237,2238,2239,2240,2241,2242,2243,2244,2245,2246,2247,2248,2249,2250,2251,2252,2253,2254,2255,2256,2257,2258,2259,2260,2261,2262,2263,2264,2265,2266,2267,2268,2269,2276,2283,2290,2297,2304,2305,2306,2307,2308}; --- 5把潘多拉法杖、5个潘多拉盾、5个新主手，5系S4和VipS4装备
    local k,v;
	local canGet = false;
    for k,v in ipairs(wandsGSID) do
        if(hasGSItem(v)) then 
           canGet = true;
		   break;
        end
    end
	----- 检查有没有s4装备
	--if(not canGet) then
		--local i;
		--for i = 2234,2268 do
			--if(hasGSItem(i)) then 
			   --canGet = true;
			--end
		--end	
	--end
	----- 检查有没有vip_s4装备
	--if(not canGet) then
		--local i;
		--for i = 2343,2387 do
			--if(hasGSItem(i)) then 
			   --canGet = true;
			--end
		--end	
	--end
	if(canGet) then
		--ItemManager.ExtendedCost(1901, nil, nil, function(msg) 
			--commonlib.echo("==========Get_20904_WorldMap_DarknessIsland ExtendedCost");
			--commonlib.echo(msg);
			--if(msg and msg.issuccess)then
				--_guihelper.MessageBox("你已经成功开启幽暗地图。<br/>幽暗岛充满危机和挑战，请小心应对。");       
			--end
		--end);

		System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid="DarkLandMap"}});
	else
		_guihelper.MessageBox("你至少需要1件S4装备来证明你的实力，才能获得前往幽暗岛的资格");
	end
end