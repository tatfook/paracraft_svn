--[[
Title: various string map for encoding string to int
Author(s): LiXizhi
Date: 2008/12/28
Desc: Only append new strings to make it back compatible. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_stringmap.lua");
local AssetFile = Map3DSystem.JGSL.stringmap.AssetFile;
print(AssetFile(1))  --> "character/v3/Human/Female/HumanFemale.x"
print(AssetFile("character/v3/Human/Female/HumanFemale.xml"))  --> 2
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/stringmap.lua");

commonlib.setfield("Map3DSystem.JGSL.stringmap", {})

-- for AssetFile encoding of agent streams. 
Map3DSystem.JGSL.stringmap.AssetFile = commonlib.stringmap:new({
	"character/v3/Human/Female/HumanFemale.x",
	"character/v3/Human/Female/HumanFemale.xml",
	"character/v3/Human/Male/HumanMale.x",
	"character/v3/Human/Male/HumanMale.xml",
	"character/v3/dummy/dummy.x",
});

-- for commonly used ccs string, such as known NPC, initial character, etc. 
Map3DSystem.JGSL.stringmap.ccs = commonlib.stringmap:new({
	-- default human races
	"0#0#6#4#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#235#0#114#170#0#0#0#0#0#0#0#",
	"0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#10#12#0#0#0#0#0#0#0#",
	
	-- for CharSelectionPage.lua
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
Map3DSystem.JGSL.stringmap.anim = commonlib.stringmap:new({
	"",
	"character/Animation/v3/凳子.x",
	"character/Animation/v3/沙发.x",
	"character/Animation/v3/躺椅.x",
	"character/Animation/v3/椅子.x",
	"character/Animation/v3/座位.x",
	
	"character/Animation/v3/欢呼.x",
	"character/Animation/v3/很兴奋的点头.x",
	"character/Animation/v3/鼓掌.x",
	"character/Animation/v3/欢迎.x",
	"character/Animation/v3/偷笑.x",
	"character/Animation/v3/再见.x",
	
	
	"character/Animation/v3/出拳.x",
	"character/Animation/v3/哭泣.x",
	"character/Animation/v3/俯卧撑.x",
	"character/Animation/v3/跳舞一.x",
	"character/Animation/v3/讨论.x",
	"character/Animation/v3/飞吻.x",
	"character/Animation/v3/不可一世.x",
	"character/Animation/v3/垂头丧气.x",
	
	"character/Animation/v3/跳舞二.x",
	"character/Animation/v3/弹钢琴.x",
	"character/Animation/v3/睡觉.x",
	"character/Animation/v3/紧张.x",
	"character/Animation/v3/修改大自然.x",
	"character/Animation/v3/人物诞生.x",
	"character/Animation/v3/修改物体.x",
});