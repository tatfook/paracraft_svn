ParaAsset.OpenArchive ("xmodels/TextureWOW.zip");
ParaAsset.OpenArchive ("xmodels/XmodelWOW.zip");
ParaAsset.OpenArchive ("xmodels/Kalimdor.zip");

-- set the global water level
-- ParaScene.SetGlobalWater(true, 43.0);

-- create a new world
ParaScene.CreateWorld("", 32000, "Kalimdor/World_Maps_Kalimdor_Kalimdor.adt.config.txt"); 

NPL.load("(gl)script/movie/movielib.lua");
_movie.EnableMovieLib(true);

--ParaScene.SetGlobalWater(true, 0);

-- create a default player and set the camera to follow him.
--local asset = ParaAsset.LoadMultiAnimation("tiny", "Units/Human/Peasant/peasant.mdx");
local asset = ParaAsset.LoadParaX("tiny", "Character/Human/Female/HumanFemale.x");
--local asset = ParaAsset.LoadParaX("tiny", "Character/Gnome/Female/GnomeFemale.m2");

local player = ParaScene.CreateCharacter ("LiXizhi", asset, "", true, 0.35, 0, 1.0);
-- player:SetPosition(20898, 0, 15420); -- bridge
-- player:SetPosition(17822, 0, 19814); -- outdoor:mountain, trees
player:SetPosition(20676, 0, 18013);ParaScene.SetGlobalWater(true, 0); -- [water enable at 0]Beautiful sea side: Great village
--player:SetPosition(20877, 5.8, 18054.7);ParaScene.SetGlobalWater(true, 0); -- [water enable at 0]Beautiful sea side: Great village
-- player:SetPosition(21608, 0, 20782); -- good castle: double floor
--player:SetPosition(20049, 0, 18431); -- many palm trees (not so good)
-- player:SetPosition(21758, 0, 16219);-- cave: ugly 8-(
--player:SetPosition(21494.427734, 74.788277, 15806.285156); -- durotar
--player:SetPosition(20778.68359375, 26.611349105835, 16750.5859375); -- some bridge in cross road
--player:AddEvent("spds 3.0;");
player:SnapToTerrainSurface(0);
ParaScene.Attach(player);

local playerChar;
playerChar = player:ToCharacter();
playerChar:LoadStoredModel(213);
--playerChar:SaveToFile("temp/charequip.txt");
--playerChar:LoadFromFile("temp/charequip.txt");
--playerChar:RefreshModel();
playerChar:SetFocus();

local PlayerX, PlayerY, PlayerZ;
PlayerX, PlayerY, PlayerZ = player:GetPosition();

local i=0;
for i=0, -1 do
	--create global character. It can walk in the entire scene
	player = ParaScene.CreateCharacter ("NPC"..i, asset, "", true, 0.35, 3.14159, 1.0);
	player:SetPosition(PlayerX-1, PlayerY, PlayerZ+i);
	player:SnapToTerrainSurface(0);
	ParaScene.Attach(player);
	playerChar = player:ToCharacter();
	playerChar:LoadStoredModel(213);
	playerChar:AssignAIController("follow", "LiXizhi 3.0 "..(i*1.57));
end

ParaGlobal.log("\nscene 2 loaded:\n");

--ParaCamera.FollowObject(player);
ParaCamera.FirstPerson(0, 3,0.4);

NPL.activate("(gl)script/demo/main_window.lua","");

-- ParaScene.SetGlobalWater(true, 0);	
-- we have built the scene, now we can enable the game
ParaGlobal.SetGameStatus("enable"); 

