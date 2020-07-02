--[[
Title: Picking a spell school.
Author(s): LiXizhi
Date: 2010/9/25
Desc:  script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.lua
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/Tutorial/PickSchoolOfSpell.lua");
-------------------------------------------------------
]]

---------------------------------
-- page event handlers
---------------------------------
-- singleton page

NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");

local page;
local PickSchoolOfSpell = commonlib.gettable("MyCompany.Aries.Tutorial.PickSchoolOfSpell");
PickSchoolOfSpell.cur_filepath = nil;
-- init
function PickSchoolOfSpell.OnInit()
	page = document:GetPageCtrl();
end
function PickSchoolOfSpell.Play()
	MotionXmlToTable.Clear();
    MotionXmlToTable.Play(PickSchoolOfSpell.cur_filepath,1,nil,PickSchoolOfSpell.Play);
end
