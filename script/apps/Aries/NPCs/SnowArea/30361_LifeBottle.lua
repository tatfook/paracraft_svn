--[[
Title: LifeBottle
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30361_LifeBottle.lua
------------------------------------------------------------
]]

-- create class
local libName = "LifeBottle";
local LifeBottle = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.LifeBottle", LifeBottle);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- LifeBottle.main
function LifeBottle.main()
	local self = LifeBottle; 
	--self.RefreshStatusState();
end

function LifeBottle.PreDialog(npc_id, instance)
	local self = LifeBottle; 
	
end
--if accepted this quest
function LifeBottle.IsAccepted()
	local self = LifeBottle; 
	return hasGSItem(50283);
end
--if finished this quest
function LifeBottle.IsFinished()
	local self = LifeBottle; 
	return hasGSItem(50284);
end
function LifeBottle.FoundAllItems()
	local self = LifeBottle; 
	return hasGSItem(17086) and hasGSItem(17087);
end
function LifeBottle.OpenQuest()
	local self = LifeBottle; 
	if(self.IsAccepted())then return end
	ItemManager.PurchaseItem(50283, 1, function(msg) end, function(msg)
		if(msg and msg.issuccess)then
			self.RefreshStatusState();
		end
	end,nil,"none");
end
function LifeBottle.DoFinished()
	local self = LifeBottle; 
	if(self.IsFinished() or not self.IsAccepted())then return end
	commonlib.echo("=========before LifeBottle.DoFinished");
	ItemManager.ExtendedCost(349, nil, nil, function(msg)end, function(msg) 
		commonlib.echo("=========after LifeBottle.DoFinished");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			self.RefreshStatusState();
		end
	end);
end
function LifeBottle.RefreshStatusState()
	local self = LifeBottle; 
	if(not self.IsFinished() and self.IsAccepted()) then
		local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/SnowArea/30361_LifeBottle_status.html", 
			"normal", "Texture/Aries/Quest/Props/bottle_32bits.png;0 0 160 150", "寻找春天的气息", nil, 50, nil);
	else
		local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/SnowArea/30361_LifeBottle_status.html");
	end
end