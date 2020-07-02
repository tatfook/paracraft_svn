--[[ 
Title: various string map for encoding string to int
Author(s): LiXizhi
Date: 2009/7/29
Desc: Only append new strings to make it backward compatible. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_stringmap.lua");
local AssetFile = stringmap.AssetFile;
print(AssetFile(1))  --> "character/v3/Elf/Female/ElfFemale.x"
print(AssetFile("character/v3/Elf/Female/ElfFemale.xml"))  --> 2
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/stringmap.lua");

local stringmap = commonlib.gettable("Map3DSystem.GSL.stringmap");

-- for AssetFile encoding of agent streams. 
stringmap.AssetFile = commonlib.stringmap:new({
	"character/v3/Elf/Female/ElfFemale.x",
	"character/v3/Elf/Female/ElfFemale.xml",
	"character/v3/dummy/dummy.x",
	"character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml",
	"character/v3/PurpleDragonMinor/PurpleDragonMinor.xml",
	-- TODO: for well known NPCs
});

-- for commonly used ccs string, such as known NPC, initial character, etc. 
stringmap.ccs = commonlib.stringmap:new({
	-- default elf races
	"0#0#6#4#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#235#0#114#170#0#0#0#0#0#0#0#",
	"0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#10#12#0#0#0#0#0#0#0#",

	-- for default avatars
	"0#0#4#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#214#0#135#163#0#0#0#0#0#0#0#",
	"0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#216#0#113#155#0#0#0#0#0#0#0#",
	"0#0#1#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#231#0#122#177#0#0#0#0#0#0#0#",
	"0#0#6#4#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#235#0#114#170#0#0#0#0#0#0#0#",
	"0#0#2#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#217#0#119#169#0#0#0#0#0#0#0#",
	"0#0#2#3#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#229#0#115#166#0#0#0#0#0#0#0#",
	"0#0#2#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#252#0#148#178#0#0#0#0#0#0#0#",
	"0#0#3#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#227#0#118#168#0#0#0#0#0#0#0#",

	-- TODO: for well known NPCs
});
	
-- for animation encoding. 
stringmap.anim = nil;

-- for BBS chat
stringmap.chat = nil;

-- for player action actions
stringmap.action = commonlib.stringmap:new({
	-- TODO: add commonly used animation and actions
});


-- for player action actions
stringmap.proxy_files = commonlib.stringmap:new({
	-- commonly used proxy files. 
	"script/apps/GameServer/GSL_proxy.lua",
	"script/apps/GameServer/GSL_client.lua",
	"script/apps/GameServer/GSL_homegrid.lua",
});

-- for player signal actions like jump
stringmap.sig = commonlib.stringmap:new({
	-- signals
	"jump",
});