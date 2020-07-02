--[[
Title: The Kids Movie Database
Author(s): LiXizhi
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/kids_db.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/db_tipsofday.lua");
NPL.load("(gl)script/kids/db_quickhelp.lua");
NPL.load("(gl)script/ide/commonlib.lua");
local L = CommonCtrl.Locale("KidsUI");

-- Kids_db: 
if(not kids_db) then kids_db={}; end

kids_db.CommunitySite = L("http://www.kids3dmovie.com");

log("\nkids_db loaded\n\n")
-------------------------------------------------
-- kids_db.User
-- kids_db.User.userinfo
-------------------------------------------------
kids_db.User = {
	Name = L"unnamed",
	Password = "",
	ChatDomain="paraweb3d.com",
	Domain="minixyz.com",
	IsAuthenticated = false,
	Role = "guest",
	Roles = {
		["guest"] = {chat=true, screenshot=true,},
		["administrator"] = {
			Create=true, 
			Edit=true, 
			Delete=true, 
			Save=true, 
			Sky=true, 
			Ocean=true, 
			TerrainHeightmap=true, 
			TerrainTexture=true, 
			TimeOfDay=true, 
			Chat=true, 
			ScreenShot=true, 
		},
		-- can do everything as an administrator, except save world
		["poweruser"] = {
			Create=true, 
			Edit=true, 
			Delete=true, 
			--Save=true, 
			Sky=true, 
			Ocean=true, 
			TerrainHeightmap=true, 
			TerrainTexture=true, 
			TimeOfDay=true, 
			Chat=true, 
			ScreenShot=true,
		},
		-- usually for friends on networked worlds, it disables terrain heightfield modification.
		["friend"] = {
			Create=true, 
			Edit=true, 
			Delete=true, 
			Sky=true, 
			TerrainTexture=true, 
			TimeOfDay=true, 
			Chat=true, 
			ScreenShot=true, 
		},
	},
	-- the following are user info about the user activity
	userinfo ={
		-- whether the product is registered: this means that product has been activated locally and registered online
		IsProductRegistered = nil, 
		-- whether the user has successfully logged in to the community site at least once in the past
		IsCommunityMember = nil, 
		-- whether the user has taken screen shot and uploaded to our community at least once in the past.
		HasUploadedUserWork = nil, 
		-- whether to display a speical welcome window in any 3d world.
		HideWelcomeWorldWindow = nil, 
		-- whether to display a speical welcome window when the application start up.
		HideStartupWelcomeWindow = nil, 
	},
	-- players owned by this user. It stores all the player name and appearances as well as the currently selected player.
	-- in networked world, the user will login using the default player appearance in this table. This table is synchronized with the remote central server
	players = {
	},
	-- the current selected player index
	SelectedPlayerIndex = 1,
};

-- return true if user has right to a given action called name, otherwise return nil.
-- @param name: it may be "Create", "Edit", "Save", etc. More information see kids_db.User.Roles.
function kids_db.User.HasRight(name)
	return kids_db.User.Roles[kids_db.User.Role][name]
end

-- return true if user has rights, otherwise return nil and display a messagebox telling the user why.
-- @param name: it may be "Create", "Edit", "Save", etc. More information see kids_db.User.Roles.
function kids_db.User.CheckRight(name)
	if(kids_db.User.HasRight(name)) then
		return true;
	else
		_guihelper.MessageBox(L"You do not have permission to do this action in this world\n");
	end
end

-- set an existing role for the current user. it returns nil if failed. true if succeeded.
-- @param name: some predefined roles are "guest", "administrator", "friend", "poweruser"
function kids_db.User.SetRole(name)
	local res;
	if(kids_db.User.Roles[name]~=nil) then
		kids_db.User.Role = name;
		res = true;
	end
	return res;
end

function kids_db.User.ReadUserInfo()
	local userinfo = commonlib.LoadTableFromFile("config/userinfo.txt")
	if(userinfo~=nil) then
		kids_db.User.userinfo = userinfo;
	end
end

-- read user info when the application loads
kids_db.User.ReadUserInfo();

function kids_db.User.SaveUserInfo()
	commonlib.SaveTableToFile(kids_db.User.userinfo, "config/userinfo.txt")
end

-- save username and password to local file
function kids_db.User.SaveCredential(username, password)
	-- write credential to file
	local file = ParaIO.open("config/npl_credential.txt", "w");
	file:WriteString(ParaMisc.SimpleEncode(username).."\r\n");
	file:WriteString(ParaMisc.SimpleEncode(password).."\r\n");
	file:close();
end

-- return username and password from the local file
function kids_db.User.LoadCredential()
	-- read credential from file
	local file = ParaIO.open("config/npl_credential.txt", "r");
	local username, password = L"unnamed", "";
	if(file:IsValid()) then
		username = ParaMisc.SimpleDecode(tostring(file:readline()));
		password = ParaMisc.SimpleDecode(tostring(file:readline()));
		file:close();
	end	
	return username, password;
end

-- use user name from saved credential file
kids_db.User.Name, kids_db.User.Password = kids_db.User.LoadCredential();

-------------------------------------------------
-- user profile
-------------------------------------------------
kids_db.profile = {
	IsAnonymous= true,
};

-------------------------------------------------
-- world settings
-------------------------------------------------
if(not kids_db.world) then kids_db.world = {}; end
kids_db.dbfile = "database/Kids.db";
kids_db.defaultskymesh = CommonCtrl.Locale("IDE")("asset_defaultSkyboxModel");--the snow sky box
kids_db.worlddir = "worlds/";
kids_db.items = {};
kids_db.world.worldzipfile = nil; -- if the world is a zip file, it will be the local file name
kids_db.world.name = "_noname";
kids_db.world.shortname = "_noname";
kids_db.world.sConfigFile = "";
kids_db.world.sNpcDbFile = "";
kids_db.world.sAttributeDbFile = "";
kids_db.world.sBaseWorldCfgFile = "_emptyworld/_emptyworld.worldconfig.txt";
kids_db.world.sBaseWorldAttFile = "_emptyworld/_emptyworld.attribute.db"
kids_db.world.sBaseWorldNPCFile = "_emptyworld/_emptyworld.NPC.db"
kids_db.world.createtime = "2006-1-26";
kids_db.world.author = "ParaEngine";
kids_db.world.desc = L"create world description";
kids_db.world.terrain = {type=0, basetex=0, commontex=0};
kids_db.world.env_set = 0;
kids_db.world.sky = 0;
kids_db.world.readonly = nil;
-- the default player position if the player has never been here before.
kids_db.world.defaultPos = {x=255,y=255};--{x=130,y=95};
if(not kids_db.world) then kids_db.world = {}; end

-- player settings
if(not kids_db.player) then kids_db.player = {}; end
-- read user name from credential file
kids_db.player.name = kids_db.User.Name;
kids_db.player.level = 0;

-- this function is called when kids_db is loaded. 
-- one can load asset either from DB or File. 
function kids_db.LoadAsset()
	
	-----------------------
	-- uncomment the following line if one wants to output database assets to its equivalent files
	-----------------------
	--kids_db.LoadAssetFromDB();
	--kids_db.SaveAssetToFile("script/kids/db_assets.lua");
	
	kids_db.LoadAssetFromFile("script/kids/db_assets.lua");
	--if(ParaEngine.IsProductActivated()==true) then
	--	kids_db.LoadAssetFromFile("script/kids/db_assets.lua")
	--else
	--	kids_db.LoadAssetFromFile("script/kids/db_assets_demo.lua")
	--end
end

function kids_db.LoadKidsAssetCategory()
	ObjEditor.assets ={
	 {name="建筑", rootpath = "model/01建筑/", icon="", text = "", tooltip = ""},
	 {name="家具", rootpath = "model/02家具/", icon="", text = "", tooltip = ""},
	 {name="生活", rootpath = "model/03生活/", icon="", text = "", tooltip = ""},
	 {name="装饰", rootpath = "model/04装饰/", icon="", text = "", tooltip = ""},
	 
	 {name="花草", rootpath = "model/05植物/", icon="", text = "", tooltip = ""},
	 {name="杂物", rootpath = "model/pops/", icon="", text = "", tooltip = ""}, 
	 {name="人物", rootpath = "character/", icon="", text = "", tooltip = ""},
	 {name="树木", rootpath = "model/05植物/", icon="", text = "", tooltip = ""},
	 
	 {name="矿石", rootpath = "model/06矿石/", icon="", text = "", tooltip = ""},
	 {name="测试", rootpath = "model/test/", icon="", text = "", tooltip = ""},
	 {name="地形", rootpath = "model/others/terrain/", icon="", text = "", tooltip = ""},
	 {name="灯光", rootpath = "model/others/light/", icon="", text = "", tooltip = ""},
	 
	 {name="脚本", rootpath = "model/others/script/", icon="", text = "", tooltip = ""},
	 {name="test", rootpath = "model/test/", icon="", text = "", tooltip = ""}, 
	 {name="pops", rootpath = "model/pops/", icon="", text = "", tooltip = ""}, 
	};
	log("Kids asset category loaded\r\n");
end

--[[ populate kids_db.world struct from database 
if (name,password)==(_init_, paraengine), then the default world settings will be loaded from database.
we can also reserve some other world settings accounts.
]]
function kids_db.LoadWorldFromDB(name, password)

	-- use default sky and fog
	ParaScene.CreateSkyBox ("MySkyBox", ParaAsset.LoadStaticMesh ("", kids_db.defaultskymesh), 160,160,160, 0);
	ParaScene.SetFog(true, "0.7 0.7 1.0", 40.0, 120.0, 0.7);
	
	-- load last player location
	local db = ParaWorld.GetAttributeProvider();
	db:SetTableName("WorldInfo");
	local x,y,z;
	x = db:GetAttribute("PlayerX", kids_db.world.defaultPos.x);
	y = db:GetAttribute("PlayerY", 0);
	z = db:GetAttribute("PlayerZ", kids_db.world.defaultPos.y);
	
	-- ocean level
	local OceanEnabled = db:GetAttribute("OceanEnabled", false);
	local OceanLevel = db:GetAttribute("OceanLevel", 0);
	ParaScene.SetGlobalWater(OceanEnabled, OceanLevel);
	att = ParaScene.GetAttributeObjectOcean();
	att:SetField("OceanColor", {db:GetAttribute("OceanColor_R", 0.2), db:GetAttribute("OceanColor_G", 0.3), db:GetAttribute("OceanColor_B", 0.3)});
	
	-- load sky
	att = ParaScene.GetAttributeObjectSky();
	att:SetField("SkyMeshFile", db:GetAttribute("SkyMeshFile", kids_db.defaultskymesh));
	att:SetField("SkyColor", {db:GetAttribute("SkyColor_R", 1), db:GetAttribute("SkyColor_G", 1), db:GetAttribute("SkyColor_B", 1)});
	att:SetField("SkyFogAngleFrom", db:GetAttribute("SkyFogAngleFrom", -0.05));
	att:SetField("SkyFogAngleTo", db:GetAttribute("SkyFogAngleTo", 0.6));
	
	-- load fog 
	att = ParaScene.GetAttributeObject();
	att:SetField("FogEnd", db:GetAttribute("FogEnd", 120));
	att:SetField("FogStart", db:GetAttribute("FogStart", 40));
	att:SetField("FogDensity", db:GetAttribute("FogDensity", 0.69));
	att:SetField("FogColor", {db:GetAttribute("FogColor_R", 1), db:GetAttribute("FogColor_G", 1), db:GetAttribute("FogColor_B", 1)});
	
	-- load camera settings
	att = ParaCamera.GetAttributeObject();
	att:SetField("FarPlane", db:GetAttribute("CameraFarPlane", 120));
	att:SetField("NearPlane", db:GetAttribute("CameraNearPlane", 0.5));
	att:SetField("FieldOfView", db:GetAttribute("FieldOfView", 1.0472));
	
	-- create the default player
	local PlayerAsset = db:GetAttribute("PlayerAsset", CommonCtrl.Locale("IDE")("asset_defaultPlayerModel"));
	local asset = ParaAsset.LoadParaX("", PlayerAsset);
	
	local player;
	local playerChar;
	kids_db.player.name = kids_db.User.Name;
	player = ParaScene.CreateCharacter (kids_db.player.name, asset, "", true, 0.35, 3.9, 1.0);
	player:SetPosition(x, y, z);
	player:SnapToTerrainSurface(0);
	player:GetAttributeObject():SetField("SentientField", 65535);--senses everybody including its own kind.
	-- set movable region: it will apply to all characters in this concise version.
	-- player:SetMovableRegion(16000,0,16000, 16000,16000,16000);
	ParaScene.Attach(player);
	playerChar = player:ToCharacter();
	playerChar:LoadStoredModel(213);
	playerChar:SetFocus();
	ParaCamera.FirstPerson(0, 5,0.4);
end

function kids_db.SaveWorldToDB(name, password)
	local att, color;
	
	-- save last player location
	local db = ParaWorld.GetAttributeProvider();
	db:SetTableName("WorldInfo");
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	db:UpdateAttribute("PlayerAsset", ParaScene.GetPlayer():GetPrimaryAsset():GetKeyName());
	db:UpdateAttribute("PlayerX", x);
	db:UpdateAttribute("PlayerY", y);
	db:UpdateAttribute("PlayerZ", z);
	--save ocean level.
	db:UpdateAttribute("OceanEnabled", ParaScene.IsGlobalWaterEnabled());
	db:UpdateAttribute("OceanLevel", ParaScene.GetGlobalWaterLevel());
	att = ParaScene.GetAttributeObjectOcean();
	color = att:GetField("OceanColor", {1, 1, 1});
	db:UpdateAttribute("OceanColor_R", color[1]);
	db:UpdateAttribute("OceanColor_G", color[2]);
	db:UpdateAttribute("OceanColor_B", color[3]);
	
	-- save sky
	att = ParaScene.GetAttributeObjectSky();
	local str = att:GetField("SkyMeshFile", kids_db.defaultskymesh);
	db:UpdateAttribute("SkyMeshFile", str);
	color = att:GetField("SkyColor", {1, 1, 1});
	db:UpdateAttribute("SkyColor_R", color[1]);
	db:UpdateAttribute("SkyColor_G", color[2]);
	db:UpdateAttribute("SkyColor_B", color[3]);
	db:UpdateAttribute("SkyFogAngleFrom", att:GetField("SkyFogAngleFrom", -0.05));
	db:UpdateAttribute("SkyFogAngleTo", att:GetField("SkyFogAngleTo", 0.6));
	
	-- save fog 
	att = ParaScene.GetAttributeObject();
	db:UpdateAttribute("FogEnd", att:GetField("FogEnd", 120));
	db:UpdateAttribute("FogStart", att:GetField("FogStart", 40));
	db:UpdateAttribute("FogDensity", att:GetField("FogDensity", 0.69));
	color = att:GetField("FogColor", {1, 1, 1});
	db:UpdateAttribute("FogColor_R", color[1]);
	db:UpdateAttribute("FogColor_G", color[2]);
	db:UpdateAttribute("FogColor_B", color[3]);
	
	-- save camera settings
	att = ParaCamera.GetAttributeObject();
	db:UpdateAttribute("CameraFarPlane", att:GetField("FarPlane", 120));
	db:UpdateAttribute("CameraNearPlane", att:GetField("NearPlane", 0.5));
	db:UpdateAttribute("FieldOfView", att:GetField("FieldOfView", 1.0472));
end

-- populate kids_db.player struct from database 
-- we may need to save player position in each world it visits.
function kids_db.LoadPlayerFromDB(name, password)
	--TODO
end

--[[set the world name from which a new world is derived
@param name: a world name or "". if "" the "_emptyworld" is used and will be created if not exists.
@return : true if succeeded, nil if not.]]
function kids_db.SetBaseWorldName(name)
	if(name == nil or name == "") then
		name = "_emptyworld";
		-- if the empty world does not exist, the empty world will be created and used as the base world
		kids_db.world.sBaseWorldCfgFile = ParaWorld.NewEmptyWorld("_emptyworld", 533.3333, 64);
		log(kids_db.world.sBaseWorldCfgFile.."\n does not exist. _emptyworld is created and used as the base world to create the new world;\n");
	end
	local sWorldConfigName = kids_db.GetDefaultWorldConfigName(name);
	local sWorldAttName = kids_db.GetDefaultAttributeDatabaseName(name);
	local sWorldNPCFile = kids_db.GetDefaultNPCDatabaseName(name);
	
	if(ParaIO.DoesFileExist(sWorldAttName, true)) then	
		kids_db.world.sBaseWorldAttFile = sWorldAttName;
	else	
		kids_db.world.sBaseWorldAttFile = nil;
	end
	
	if(ParaIO.DoesFileExist(sWorldNPCFile, true)) then	
		kids_db.world.sBaseWorldNPCFile = sWorldNPCFile;
	else	
		kids_db.world.sBaseWorldNPCFile = nil;
	end
	
	if(ParaIO.DoesFileExist(sWorldConfigName, true) == true) then	
		kids_db.world.sBaseWorldCfgFile = sWorldConfigName;
		return true;
	end
end

function kids_db.SetDefaultFileMapping(name)
	if(not name)then
		name = kids_db.world.name;
	end
	kids_db.world.sConfigFile = kids_db.GetDefaultWorldConfigName(name);
	kids_db.world.sNpcDbFile = kids_db.GetDefaultNPCDatabaseName(name);
	kids_db.world.sAttributeDbFile = kids_db.GetDefaultAttributeDatabaseName(name);
end

-- use default world config name, npc db and attribute db.
function kids_db.UseDefaultFileMapping()
	kids_db.UseDefaultWorldConfigName();
	kids_db.UseDefaultNPCDatabase();
	kids_db.UseDefaultAttributeDatabase();
end

-- update world config file name from the world name
function kids_db.UseDefaultWorldConfigName()
	if(kids_db.world.name == "") then
		kids_db.world.sConfigFile = "";
	else
		local name = kids_db.world.name;
		kids_db.world.sConfigFile = name.."/"..ParaIO.GetFileName(name)..".worldconfig.txt";
	end
end

--@param name: world directory name. such as "world/demo"
function kids_db.GetDefaultWorldConfigName(name)
	return name.."/"..ParaIO.GetFileName(name)..".worldconfig.txt";
end

-- update npc database file name from the world name
function kids_db.UseDefaultNPCDatabase()
	if(kids_db.world.name == "") then
		kids_db.world.sNpcDbFile = "";
	else
		local name = kids_db.world.name;
		kids_db.world.sNpcDbFile = name.."/"..ParaIO.GetFileName(name)..".NPC.db";
		ParaWorld.SetNpcDB(kids_db.world.sNpcDbFile);
	end
end

--@param name: world directory name. such as "world/demo"
function kids_db.GetDefaultNPCDatabaseName(name)
	return name.."/"..ParaIO.GetFileName(name)..".NPC.db";
end
-- update attribute database file name from the world name
function kids_db.UseDefaultAttributeDatabase()
	if(kids_db.world.name == "") then
		kids_db.world.sAttributeDbFile = "";
	else
		local name = kids_db.world.name;
		kids_db.world.sAttributeDbFile = name.."/"..ParaIO.GetFileName(name)..".attribute.db";
		ParaWorld.SetAttributeProvider(kids_db.world.sAttributeDbFile);
	end
end

--@param name: world directory name. such as "world/demo"
function kids_db.GetDefaultAttributeDatabaseName(name)
	return name.."/"..ParaIO.GetFileName(name)..".attribute.db";
end

-- (re)load items into kids_db.items table. This function is usually called once at the beginning of the application.
function kids_db.LoadAssetFromDB()
	-- load asset 
	kids_db.LoadKidsAssetCategory()
	
	-- load items
	NPL.load("(gl)script/sqlite/sqlite3.lua");
	kids_db.items = {};
	local db = sqlite3.open(kids_db.dbfile);
	local row;
	for row in db:rows("SELECT IconAssetName, ItemType, ModelFilePath, IconFilePath, Reserved1,Reserved2,Reserved3,Reserved4  FROM Item_DB") do
		--print(row.ItemType, row.IconAssetName, row.ModelFilePath, row.IconFilePath);
		local item = {};
		local ItemGroup = kids_db.items[row.ItemType];
		if(ItemGroup == nil) then
			ItemGroup = {};
			kids_db.items[row.ItemType] = ItemGroup;
		end
		item["ModelFilePath"] = tostring(row.ModelFilePath);
		item["IconFilePath"] = tostring(row.IconFilePath);
		item["IconAssetName"] = tostring(row.IconAssetName);
		item["Reserved1"] = tostring(row.Reserved1);
		item["Reserved2"] = tostring(row.Reserved2);
		item["Reserved3"] = tostring(row.Reserved3);
		item["Reserved4"] = tostring(row.Reserved4);
		table.insert(kids_db.items[row.ItemType], item);
	end
	db:close();
end

-- load asset from file.
function kids_db.LoadAssetFromFile(filename)
	-- just reload and execute the file
	if(filename==nil) then
		filename = "script/kids/db_assets.lua"
	end
	NPL.load("(gl)"..filename, true);
end


--[[ save current asset set to file. Internally, it will print the ObjEditor.assets and kids_db.items table to file.
use this function to preserve custom asset either by user or a update program at runtime.
one can call kids_db.LoadAssetFromFile to recover from a previous file.
one can also call following in pairs to convert a database asset table to its equivalent script file. 
	kids_db.LoadAssetFromDB();
	kids_db.SaveAssetToFile("script/kids/db_assets.lua");
]]
function kids_db.SaveAssetToFile(filename)
	if(filename==nil) then
		filename = "script/kids/db_assets.lua"
	end
	
	-- print the asset to file
	log("printing kids_db.items to "..filename.."\r\n")
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		file:WriteString("--[[\r\n");
		file:WriteString(string.format([[Title: The kidsmovie database table for assets
use the lib:
------------------------------------------------------------
NPL.load("(gl)%s");
------------------------------------------------------------
]], filename));
		file:WriteString("]]\r\n");
		file:WriteString([[
if(not ObjEditor) then ObjEditor={}; end
if(not kids_db) then kids_db={}; end
]]);


		file:WriteString("-- asset database\r\nObjEditor.assets = \r\n");
		commonlib.serializeToFile(file, ObjEditor.assets)
		
		file:WriteString("\r\n-- item database\r\nkids_db.items = \r\n");
		commonlib.serializeToFile(file, kids_db.items)
		file:close();
	end
end

-- get the url for a given user
-- @param username: if nil, the current user is used 
function kids_db.GetURLforUser(username)
	if(not username)then
		username = kids_db.User.Name;
	end
	return string.format("%s/cn/%s/default.aspx", kids_db.CommunitySite, username);
end

-- load user players from central server.
function kids_db.DownloadUserPlayersFromWeb()
	-- TODO:
end

-- update user players from central server.
function kids_db.UploadUserPlayersFromWeb()
	-- TODO:
end

-- @param player: ParaObject which must be a character
-- @return: the returned table contains all player (appearance) information
function kids_db.SerializePlayerToTable(player)
	-- Note: currently we will serialize all the player appearance information
	if( player:IsCharacter() == true ) then
		local info = {};
		--info.SpeedScale = player:GetSpeedScale();
		--info.SizeScale = player:GetSizeScale();
		--info.WalkOrRun = player:WalkingOrRunning();
		--info.SkinID = player:GetSkin();
		--info.IsMounted = player:IsMounted();
		--info.IsShowUnderwear = player:GetDisplayOptions(0);
		--info.IsShowEars = player:GetDisplayOptions(1);
		--info.IsShowHair = player:GetDisplayOptions(2);
		
		info.ModelName = nil;
		
		if( playerChar:IsCustomModel()==true ) then
			info.IsCustomModel = true;
		else
			info.IsCustomModel = false;
		end
		
		if( playerChar:IsSupportCartoonFace()==true ) then
			info.IsSupportCartoonFace = true;
		else
			info.IsSupportCartoonFace = false;
		end
		
	else
		return nil;
	end
end

-- @param player: ParaObject which must be a character
-- @table: the player (appearance) information is loaded from the table.
function kids_db.DeserializePlayerFromTable(player, table)
	-- Note: currently we will deserialize all the player appearance information
	if( player:IsCharacter() == true ) then
	else
		return nil;
	end
end

-- @param filename: file name or nil
function kids_db.LoadUserPlayersFromFile(filename)
	local t = commonlib.LoadTableFromFile(filename or "config/userplayers.txt")
	if(t~=nil) then
		kids_db.User.players = t;
	end
end

-- @param filename: file name or nil
function kids_db.SaveUserPlayersToFile(filename)
	commonlib.SaveTableToFile(kids_db.User.players, filename or "config/userplayers.txt");
end

-- get the currently selected user player in a table. It may return nil, if the user has never created a player before. 
function kids_db.GetCurrentUserPlayerInfo()
	return kids_db.User.players[SelectedPlayerIndex];
end

-- loaded when application starts
kids_db.LoadAsset();