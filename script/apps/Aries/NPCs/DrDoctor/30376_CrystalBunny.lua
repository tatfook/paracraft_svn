--[[
Title: CrystalBunny
Author(s): Leio
Date: 2009/12/20
Desc:
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/DrDoctor/30376_CrystalBunny.lua
local NPC = MyCompany.Aries.Quest.NPC;
local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30376);
if(npcChar and npcChar:IsValid())then
	commonlib.echo("================");
	System.Animation.PlayAnimationFile("character/v3/Pet/SJTZ/cyrstalbunny_tremble.x", npcChar);
end
------------------------------------------------------------
]]
-- create class
local CrystalBunny = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CrystalBunny");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function CrystalBunny.main()
	local self = CrystalBunny;
	self.UpdateQuest();
end

function CrystalBunny.Predialog(npc_id, instance)
	
end

function CrystalBunny.DoOpenQuest()
	local self = CrystalBunny;
	if(not self.IsOpened())then
		commonlib.echo("=========before open quest in CrystalBunny.DoOpenQuest()");
		ItemManager.PurchaseItem(50303, 1, function(msg) end, function(msg)
			commonlib.echo("=========after open quest in CrystalBunny.DoOpenQuest()");
			commonlib.echo(msg);
			self.UpdateQuest();
		end);
	end
end
function CrystalBunny.GiveBunny()
	local self = CrystalBunny;
	if(self.HasBunny() or not self.ExchangeFinishedFromDrDoctor())then return end
	commonlib.echo("=========before Make_10132_CrystalBunny in CrystalBunny.GiveBunny()");
	ItemManager.ExtendedCost(406, nil, nil, function(msg)end, function(msg) 
		commonlib.echo("=========after Make_10132_CrystalBunny in CrystalBunny.GiveBunny()");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			self.UpdateQuest();
		end
	end);
end
function CrystalBunny.CanShow2()
	local self = CrystalBunny;
	if(not self.HasBunny())then
		return true;	
	end
end
function CrystalBunny.CanShow()
	local self = CrystalBunny;
	if(not self.HasBunny() and self.IsOpened())then
		return true;	
	end
end
function CrystalBunny.ShowStatus()
	local self = CrystalBunny;
	NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
	MyCompany.Aries.Desktop.QuestArea.ShowNormalQuestStatus("script/apps/Aries/NPCs/DrDoctor/30376_CrystalBunny_status.html");

end
function CrystalBunny.UpdateQuest()
	local self = CrystalBunny;
	--if(self.HasBunny())then
		----删除NPC
		--NPC.DeleteNPCCharacter(30376);
		----关闭任务面板
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/DrDoctor/30376_CrystalBunny_status.html");
	--else
		--if(self.IsOpened())then
			----激活任务面板
			--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
			--QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/DrDoctor/30376_CrystalBunny_status.html", 
				--"normal", "Texture/Aries/Quest/Props/CrystalBunny_32bits.png;0 0 80 75", "水晶兔", nil, 40, nil);
		--end
	--end
end
--是否已经和博士兑换过物品
function CrystalBunny.ExchangeFinishedFromDrDoctor()
	return hasGSItem(50304);
end
--任务是否开启
function CrystalBunny.IsOpened()
	return hasGSItem(50303);
end
--是否具备和博士兑换的物品
function CrystalBunny.HasBunnyRequiredItems()
	return hasGSItem(17052) and  hasGSItem(17055) and  hasGSItem(17056) and  hasGSItem(17057) and  hasGSItem(17059) and  hasGSItem(17010);
end
--和博士兑换
function CrystalBunny.ExchangeBunnyItems()
	local self = CrystalBunny;
	if(not self.HasBunnyRequiredItems() or self.HasBunny())then return end
	commonlib.echo("=========before Qualify_10132_CrystalBunny in CrystalBunny.ExchangeBunnyItems()");
	ItemManager.ExtendedCost(405, nil, nil, function(msg)end, function(msg) 
		commonlib.echo("=========after Qualify_10132_CrystalBunny in CrystalBunny.ExchangeBunnyItems()");
		commonlib.echo(msg);
	end);
end
function CrystalBunny.HasBunny()
	return hasGSItem(10132);
end