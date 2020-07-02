--[[
Title: quest hook processor for kids version
Author(s): LiXizhi
Date: 2010/12/13
Desc: we will hook some special quest id to do some client side logics upon certain quest acception or completion, etc. 
Currently, "OnQuestAccepted" and "OnQuestFinished" are accepted. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/HaqiQuestHooks.lua");
------------------------------------------------------------
]]
local HaqiQuestHooks = commonlib.gettable("MyCompany.Aries.Quest.HaqiQuestHooks");

-- needs to show some ui indicator 
function HaqiQuestHooks.OnRewardedFirstHat(quest_id)
	MyCompany.Aries.Desktop.GUIHelper.ArrowPointer.ShowArrow("InventoryUI_Arrow", 3, "_ctb", -425, -95, 32, 32);
end

-- needs to show some ui indicator 
function HaqiQuestHooks.OnRewardedFirstCard(quest_id)
	MyCompany.Aries.Desktop.GUIHelper.ArrowPointer.ShowArrow("CardUI_Arrow", 3, "_ctb", -430, -60, 32, 32);
end

-- For andy's standalone game
function HaqiQuestHooks.OnAcceptedPowerPipTask(quest_id)
	-- invoke powerpip task. 
	--_guihelper.MessageBox([[<div style="text-align:center">点击确定,进入魔力点训练场</div>]], function()
		System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {name = "CombatPipTutorial",
			on_finish = function()
				-- replace main character with dummy
				local player = ParaScene.GetPlayer();
				
				LOG.std(nil, "debug", "tutorial", "39003_CombatPipTutorial loaded");

				-- start the tutorial
				if(System.options.version == "kids") then
					NPL.load("(gl)script/apps/Aries/NPCs/Combat/39003_CombatPipTutorial.lua");
				else
					NPL.load("(gl)script/apps/Aries/Login/Tutorial/CombatPipTutorial.teen.lua");
				end
				MyCompany.Aries.Quest.NPCs.CombatPipTutorial.main(function()
            
						NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
						local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

						-- teleport back from instance world
						WorldManager:TeleportBack();
				end);
			end});
	--end, _guihelper.MessageBoxButtons.OK)
end

HaqiQuestHooks.OnQuestAccepted_handlers  = {
	---- 学习魔力点的重要性 * 5个系别; 开启副本引导
	--[60197] = HaqiQuestHooks.OnAcceptedPowerPipTask,
	--[60198] = HaqiQuestHooks.OnAcceptedPowerPipTask,
	--[60199] = HaqiQuestHooks.OnAcceptedPowerPipTask,
	--[60200] = HaqiQuestHooks.OnAcceptedPowerPipTask,
	--[60201] = HaqiQuestHooks.OnAcceptedPowerPipTask,
};

HaqiQuestHooks.OnQuestFinished_handlers  = {
	-- 呼噜大叔的西瓜 * 5个系别; 奖励了第一个卡片
	[60012] = HaqiQuestHooks.OnRewardedFirstCard,
	[60027] = HaqiQuestHooks.OnRewardedFirstCard,
	[60028] = HaqiQuestHooks.OnRewardedFirstCard,
	[60029] = HaqiQuestHooks.OnRewardedFirstCard,
	[60030] = HaqiQuestHooks.OnRewardedFirstCard,
	-- 第一次实战的考验 * 5个系别; 奖励了第一个装备（帽子）
	[60008] = HaqiQuestHooks.OnRewardedFirstHat,
	[60019] = HaqiQuestHooks.OnRewardedFirstHat,
	[60020] = HaqiQuestHooks.OnRewardedFirstHat,
	[60021] = HaqiQuestHooks.OnRewardedFirstHat,
	[60022] = HaqiQuestHooks.OnRewardedFirstHat,
};



