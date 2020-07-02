--[[
Title: RodMaster
Author(s): Leio
Date: 2010/09/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30525_RodMaster.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
-- create class
local libName = "RodMaster";
local RodMaster = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RodMaster", RodMaster);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
function RodMaster.CanShow()
	return false;
end
-- RodMaster.main
function RodMaster.main()
	local self = RodMaster;
	if(not self.timer)then
		self.timer = commonlib.Timer:new();
	end
	self.timer.callbackFunc = function()
		local txts = {
			"年纪大了呀，脚使不上力气，不能跟你们一起去冒险了啊！",
			"这个黑暗魔王真是让我头疼透了，侵略小镇不说，还跑去火鸟岛撒野了！",
			"哎哟，我这副老骨头真想活动活动啊！来抖抖手抖抖脚吧！",
		};
	
		local len = #txts;
		local index = math.random(len);
		local info = txts[index];
		local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30525, nil);

		if(npcChar)then
			headon_speech.Speak(npcChar.name,info,3);
		end
	end
	self.timer:Change(0,60000);
end
function RodMaster.PreDialog(npc_id, instance)
	local self = RodMaster;
end
function RodMaster.ShowPage()
	local self = RodMaster;
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(1);
end
function RodMaster.ShowPage_Combat()
	local self = RodMaster;
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
    Map3DSystem.App.PENote.LiteMailPage.ShowPage(500);
end