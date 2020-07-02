--[[ Tutorial used by ../SimpleTutorial.lua
author: LiXizhi
date: 2006.9.8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/AI/templates/TutorialText/BasicTutorial_part5.lua");
local s = _AI_tutorials["intro"]; -- s is an array of text
------------------------------------------------------------
]]

if(not _AI_tutorials) then _AI_tutorials={}; end

local s;
-- intro
s={
	"你好小朋友",
	"去和其他的人说话,他们会告诉你一些小技巧",
	"再见",
};
_AI_tutorials["part5"] = s;

-- plane
s={
	"你好小朋友",
	"你可以驾驶我旁边的直升机",
	"走近后，按右边的shift键",
	"按字母O键驾驶飞机",
	"再按字母O键切换到人物",
	"再按空格键离开飞机",
	"祝你好运，再见！",
	"我已经告诉过你如何驾驶飞机了。还想听一遍？",
};
_AI_tutorials["part5 part5"] = s;