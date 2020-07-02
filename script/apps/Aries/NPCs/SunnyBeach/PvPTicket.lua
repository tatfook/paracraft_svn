--[[
Title: 
Author(s): Leio
Date: 2011/06/14
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SunnyBeach/PvPTicket.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
local PvPTicket_NPC = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvPTicket_NPC");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local Instance = commonlib.gettable("MyCompany.Aries.Instance");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
function PvPTicket_NPC.Free_NotGetToday()
	-- 12003_FreePvPTicket
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(12003);
	if(gsObtain and gsObtain.inday == 0) then
        return true;
    end

    return false;
end
function PvPTicket_NPC.Free_GetTicket()
	if(PvPTicket_NPC.Free_NotGetToday())then
		-- 12003_FreePvPTicket
		-- purchase today's tickets
		local nDailyCount = 10;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(12003);
		if(gsItem) then
			nDailyCount = gsItem.maxdailycount;
		end
		ItemManager.PurchaseItem(12003, nDailyCount, function() end, function(msg) 
			if(msg.issuccess == true) then
				LOG.std("", "system","Item", "+++++++ 30421_FreePvPTicketAmbassador purchase 12003 x %d return:", nDailyCount);
			end
		end);
	else
		_guihelper.Custom_MessageBox("今天已经领取过免费PK入场券了, 明天再来领取吧.",function(result)
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end

function PvPTicket_NPC.FreeArena_JoinRedmushroomArena()
    local Instance = commonlib.gettable("MyCompany.Aries.Instance");
    Instance.EnterInstance_PreDialog(301138)
end
function PvPTicket_NPC.FreeArena_NotGetToday()
	-- 12005_ArenaFreeTicket
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(12005);
	if(gsObtain and gsObtain.inday == 0) then
        return true;
    end

    return false;
end

function PvPTicket_NPC.CheckGetFreeTicket()
	if(PvPTicket_NPC.FreeArena_NotGetToday())then
		-- 12005_ArenaFreeTicket
		-- purchase today's tickets
		local nDailyCount = 5;
		if(CommonClientService.IsTeenVersion())then
			nDailyCount = 10;
			return;
		end
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(12005);
		if(gsItem) then
			nDailyCount = gsItem.maxdailycount;
		end
		ItemManager.PurchaseItem(12005, nDailyCount, function() end, function(msg) 
			if(msg.issuccess == true) then
				LOG.std("", "system","Item", "+++++++ 30423_FreeArenaPvPTicketAmbassador_dialog purchase 12005 x %d return: +++++++", nDailyCount);
			end
		end);
	else
		return "already_get";
	end
end

function PvPTicket_NPC.FreeArena_GetTicket()
	if(PvPTicket_NPC.CheckGetFreeTicket() == "already_get") then
		_guihelper.Custom_MessageBox("今天已经领取过免费赛场门票了, 明天再来领取吧.",function(result)
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end

function PvPTicket_NPC.Join_HaqiTown_Practice_PVP_1V1()
	NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
	local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

	if(not TeamClientLogics:IsInTeam())then
		NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
		local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
		LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_Practice_PVP_1V1", "PvE");
	else
		_guihelper.MessageBox("你在组队中, 请先离开现在的队伍");
	end
end
function PvPTicket_NPC.Join1v1()
	NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
	local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

	if(not TeamClientLogics:IsInTeam())then
		--NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
		--local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
		--LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_1v1", "PvP");

		PvPTicket_NPC.CheckGetFreeTicket();

		NPL.load("(gl)script/apps/Aries/CombatRoom/PvPSessionPage.lua");
		local PvPSessionPage = commonlib.gettable("MyCompany.Aries.CombatRoom.PvPSessionPage");
		PvPSessionPage.ShowPage("1v1");
	else
		_guihelper.MessageBox("你在组队中, 请先离开现在的队伍");
	end
end

function PvPTicket_NPC.Join2v2()
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
	local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

	PvPTicket_NPC.CheckGetFreeTicket();

	if(not TeamClientLogics:IsInTeam())then
		_guihelper.MessageBox("你还没有组队. <br/>确定需要系统帮你安排队友吗？", function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				NPL.load("(gl)script/apps/Aries/CombatRoom/PvPSessionPage.lua");
				local PvPSessionPage = commonlib.gettable("MyCompany.Aries.CombatRoom.PvPSessionPage");
				PvPSessionPage.ShowPage("2v2");
				-- LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_2v2", "PvP");
			end
		end, _guihelper.MessageBoxButtons.YesNo)
	else
		LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_2v2", "PvP", true);
	end
end