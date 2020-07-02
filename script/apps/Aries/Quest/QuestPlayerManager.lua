--[[
Title: Quest Player Manager
Author(s): 
Date: 2010/8/21
Desc: Keeps all currently connected QuestPlayer on the quest server. 
When a user connect or disconnect QuestPlayerManager should init/release player data to minimize memory usage. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestPlayerManager.lua");
------------------------------------------------------------
]]

-- create class
local QuestPlayerManager = commonlib.gettable("MyCompany.Aries.Quest.QuestPlayerManager");
