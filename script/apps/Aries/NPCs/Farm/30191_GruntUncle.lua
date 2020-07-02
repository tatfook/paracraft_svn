--[[
Title: GruntUncle
Author(s): WangTian, LiXizhi
Date: 2009/12/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Farm/30191_GruntUncle.lua");
------------------------------------------------------------
]]

-- create class
local libName = "GruntUncle";
local GruntUncle = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GruntUncle", GruntUncle);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function GruntUncle.main()
end

function GruntUncle.On_Timer()
end

function GruntUncle.PreDialog()
	return true;
end
---return true if the quest of find seawater was opened 
function GruntUncle.QuestIsOpened_Seawater()
	return hasGSItem(50294);
end
---return true if user has 5 melon
function GruntUncle.HasMelon()
	local __,__,__,copies = hasGSItem(17033);
	copies = copies or 0;
	if(copies >= 5)then
		return true;
	end
end
---return true if user has seawater in his bag
function GruntUncle.HasSeawater()
	return hasGSItem(17088);
end

---show flash cartoon
function GruntUncle.ShowFlash()
	if(GruntUncle.QuestIsOpened_Seawater() and GruntUncle.HasSeawater())then
		System.App.Commands.Call("MiniGames.MelonSeedTest");
	end
end
---use 5 melon to exchange a seawater
function GruntUncle.GiveMelon()
		commonlib.echo("=========before GruntUncle.GiveMelon");
		ItemManager.ExtendedCost(365, nil, nil, function(msg)end, function(msg) 
			commonlib.echo("=========GruntUncle.GiveMelon");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				
			end
		end,"none");
end