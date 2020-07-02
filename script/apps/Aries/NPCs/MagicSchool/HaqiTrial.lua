--[[
Title: HaqiTrial
Author(s): zrf
Date: 2010/08/10

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/HaqiTrial.lua");
------------------------------------------------------------
]]
local HaqiTrial = {

};

commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiTrial", HaqiTrial);
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function HaqiTrial.Init()
	HaqiTrial.page = document:GetPageCtrl();
end

function HaqiTrial.Finish()
	ItemManager.PurchaseItem(50314, 1, function(msg) end, function(msg)
		if(msg) then
			MyCompany.Aries.Quest.NPCs.HaqiTrial.page:CloseWindow();

			if(System.options.version=="kids") then
				local s = "恭喜你通过哈奇勇士的考验，奖励给你2000个奇豆，你现在是一名正式的勇士了，快去保卫小镇吧！";
				_guihelper.Custom_MessageBox(s,function(result)
						MyCompany.Aries.Player.AddMoney(2000,function(msg) 
							MyCompany.Aries.Quest.NPCs.CombatSkillLearn.ContinueLearnSkill(MyCompany.Aries.Quest.NPCs.HaqiTrial.exID);
						end);

				end,_guihelper.MessageBoxButtons.OK);
			else

				local s = "恭喜你通过哈奇勇士的考验，你现在是一名正式的勇士了，快去保卫小镇吧！";
				_guihelper.Custom_MessageBox(s,function(result)
						MyCompany.Aries.Quest.NPCs.CombatSkillLearn.ContinueLearnSkill(MyCompany.Aries.Quest.NPCs.HaqiTrial.exID);
				end,_guihelper.MessageBoxButtons.OK);

			end
		end
	end);
end

function HaqiTrial.Show(exID)
	if(not hasGSItem(50314)) then
		local select=select;
		HaqiTrial.exID = exID;
		btnenable=false;

		if(System.options.version=="kids") then
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/MagicSchool/HaqiTrial.html", 
				name = "HaqiTrial", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
						x = -750/2,
						y = -512/2,
						width = 750,
						height = 512,
			});
		else
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/MagicSchool/HaqiTrial.teen.html", 
				name = "HaqiTrial", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
						x = -470/2,
						y = -470/2,
						width = 470,
						height = 470,
			});
		end
	else
		MyCompany.Aries.Quest.NPCs.CombatSkillLearn.ContinueLearnSkill(exID);
	end
end