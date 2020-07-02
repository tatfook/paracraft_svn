--[[
Title: 
Author(s): Leio
Date: 2009/10/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MelonSeedTestPage.lua");
local s = string.format('��Ҫ��ʼ��%s����',Map3DSystem.App.MiniGames.MelonSeedTestPage.gametitle or "");
Map3DSystem.App.MiniGames.BeginGamePage.Show(s,Map3DSystem.App.MiniGames.MelonSeedTestPage.ShowPage);
Map3DSystem.App.MiniGames.MelonSeedTestPage.ToggleShow(bShow)
--
System.App.Commands.Call("MiniGames.MelonSeedTest");
Map3DSystem.App.MiniGames.MelonSeedTestPage.ClosePage();
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/GameScorePage.lua");
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/MiniGameCommon.lua");
local MiniGameCommon = commonlib.gettable("Map3DSystem.App.MiniGames.MiniGameCommon")

-- default member attributes
local MelonSeedTestPage = {
	page = nil,
	gamename = "MelonSeedTest",
	gametitle = "�������Ӽ���",
	gift_map = {
		{ label = "������", exID = 366,},
		{ label = "����ɳ��", exID = 376,},
		{ label = "��������", exID = 374,},
		{ label = "���ϵ绰", exID = 373,},
		{ label = "���ϵ���", exID = 375,},
		{ label = "1000�涹", exID = 368,},
	}
}
commonlib.setfield("Map3DSystem.App.MiniGames.MelonSeedTestPage",MelonSeedTestPage);

function MelonSeedTestPage.OnInit()
	local self = MelonSeedTestPage;
	self.page = document:GetPageCtrl();
end
function MelonSeedTestPage.ShowPage()
	local self = MelonSeedTestPage;
	MiniGameCommon.ShowPage(self.gamename);
	self.CallFlash();
end
function MelonSeedTestPage.OnOpened()
	local self = MelonSeedTestPage;
	self.CallFlash();
end
function MelonSeedTestPage.CallFlash()
	local self = MelonSeedTestPage;
	if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			
			--�Ƿ���������
			local ItemManager = System.Item.ItemManager;
			local has = self.HasMelonPet();
			local func_args = {
						funcName = "hasMelon",
						args = {
							has,
						}
					} 
			commonlib.CallFlashFunction(index, func_args)
		end
	end
end
function MelonSeedTestPage.ClosePage()
	local self = MelonSeedTestPage;
	MiniGameCommon.ClosePage(self.gamename);
end
function MelonSeedTestPage.HasMelonPet()
	local self = MelonSeedTestPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	return hasGSItem(10105);
end
function MelonSeedTestPage.CallNPLFromAs(gift_index)
	local self = MelonSeedTestPage;
	if(not gift_index)then return end
	local item = self.gift_map[gift_index];
	commonlib.echo(gift_index);
	commonlib.echo(item);
	if(item)then
		local exID = item.exID;
		if(exID)then
			System.Item.ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
				commonlib.echo("=========ItemManager.ExtendedCost in MelonSeedTestPage");
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					
				end
			end);
		end
	end
	---- resume game music
	MyCompany.Aries.Scene.StopGameBGMusic();
	MyCompany.Aries.Scene.ResumeRegionBGMusic();
	
	commonlib.log("MelonSeedTestPage will be closed\n")
	self.ClosePage();
end