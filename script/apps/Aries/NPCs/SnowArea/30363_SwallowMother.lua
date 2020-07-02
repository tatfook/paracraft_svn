--[[
Title: SwallowMother
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30363_SwallowMother.lua
------------------------------------------------------------
]]

-- create class
local libName = "SwallowMother";
local SwallowMother = commonlib.gettable("MyCompany.Aries.Quest.NPCs.SwallowMother");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- SwallowMother.main
function SwallowMother.main()
	local self = SwallowMother; 
	self.DeleteNPC();
end

function SwallowMother.PreDialog(npc_id, instance)
	local self = SwallowMother; 
end

function SwallowMother.HasBug()
	local self = SwallowMother;
	return hasGSItem(17009); 
end

function SwallowMother.FeedBug()
	local self = SwallowMother;
	if(not self.HasBug())then return end
	commonlib.echo("=========before extend in SwallowMother");
	ItemManager.ExtendedCost(351, nil, nil, function(msg)end, function(msg) 
	commonlib.echo("=========after extend in SwallowMother");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			--鸟窝和鸟蛋在场景中出现 燕子妈妈消失
			self.DeleteNPC();
			self.CreateSwallowBaby();
		end
	end);
end

function SwallowMother.DeleteNPC()
	local self = SwallowMother;
	if(hasGSItem(50286))then
		NPC.DeleteNPCCharacter(30363);
	end
end

function SwallowMother.CreateSwallowBaby()
	local params = commonlib.deepcopy(MyCompany.Aries.Quest.NPCList.NPCs[30364]);
	MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30364, params);
end