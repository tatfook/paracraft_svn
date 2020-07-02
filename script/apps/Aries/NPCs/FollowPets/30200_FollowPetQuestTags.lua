--[[
Title: FollowPetQuestTags
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30200_FollowPetQuestTags.lua
------------------------------------------------------------
]]

-- create class
local libName = "FollowPetQuestTags";
local FollowPetQuestTags = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FollowPetQuestTags", FollowPetQuestTags);

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


-- FollowPetQuestTags.main
function FollowPetQuestTags.main()
end

-- FollowPetQuestTags.On_Timer
function FollowPetQuestTags.On_Timer()
end
