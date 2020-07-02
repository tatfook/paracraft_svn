--[[
Title: Aquarius quest main entry
Author(s): WangTian
Date: 2008/12/10

Login to quest server and init the world scene status

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Quest/main.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");

-- create class
local libName = "Quest";
local Quest = {};
commonlib.setfield("MyCompany.Aquarius.Quest", Quest);

function Quest.RegisterDoPlayerMoveTimer()
	NPL.SetTimer(4329, 0.2, ";MyCompany.Aquarius.Quest.DoPlayerMoveTimer();");
end

function Quest.DoPlayerMoveTimer()
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	System.Quest.Client.BroadcastMyPosition(x, y, z);
end

-- init the quest system
function Quest.Init()
	-- refetch database data
	System.Quest.DB.GetAllNPCs();
	System.Quest.DB.GetAllQuests();
	System.Quest.DB.GetAllGossip();
	System.Quest.DB.GetAllNPC_Quest_Start_Relations();
	System.Quest.DB.GetAllNPC_Quest_Finish_Relations();
	System.Quest.DB.GetAllCharacter_QuestStatus();
	System.Quest.DB.GetAllCReq_Goals();
	
	-- TODO: login server
	local SID = "blablabla...";
	Map3DSystem.Quest.Client.LoginServer(SID);
	-- register the player move timer
	Quest.RegisterDoPlayerMoveTimer()
	
	NPL.load("(gl)script/apps/Aquarius/Quest/Quest_ListWnd.lua");
	MyCompany.Aquarius.Quest_ListWnd.Init();
	
	-- init window object
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("NPCQuestDialog") or _app:RegisterWindow("NPCQuestDialog", nil, Quest.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 300, -- initial width of the window client area
		initialHeight = 400, -- initial height of the window client area
		
		initialPosX = 50,
		initialPosY = 150,
		
		isPinned = true,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = function () do return end end,
	};
	
	--local text, icon, shortText = self:GetTextAndIcon();
	--sampleWindowsParam.text = text;
	----sampleWindowsParam.icon = icon;
	
	local frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	--frame:Show2(true, nil, true);
	
	-- TODO: use BCS as creator object lock testing
	-- 201: BCS base
	--System.UI.Creator.SetGroupLock(true, 201);
	
	local locks = MyCompany.Aquarius.app:ReadConfig("Locks", nil);
	if(locks == nil) then
		MyCompany.Aquarius.app:WriteConfig("Locks", {
			[201001] = true,
			[201002] = true,
			[201003] = true,
			[201004] = true,
			[201005] = true,
			[201006] = true,
			[201007] = true,
			[201008] = true,
			[201009] = true,
			[201010] = true,
		});
	end
	locks = MyCompany.Aquarius.app:ReadConfig("Locks", nil);
	local k, v;
	for k, v in pairs(locks) do
		if(v == true) then
			Quest.LockItem(k);
		elseif(v == false) then
			Quest.UnlockItem(k);
		end
	end
end

function Quest.GetItemBackground(id)
	if(id == nil) then
		return
	end
	local ID = math.floor(id/1000);
	local itemID = math.mod(id, 1000);
	
	return System.UI.Creator.GetItemBackground(ID, itemID);
end

function Quest.LockItem(id)
	if(id == nil) then
		return
	end
	local ID = math.floor(id/1000);
	local itemID = math.mod(id, 1000);
	System.UI.Creator.SetItemLock(true, ID, itemID);
end
function Quest.UnlockItem(id)
	if(id == nil) then
		return
	end
	local ID = math.floor(id/1000);
	local itemID = math.mod(id, 1000);
	System.UI.Creator.SetItemLock(false, ID, itemID);
	
	-- directly write back
	local locks = MyCompany.Aquarius.app:ReadConfig("Locks", {});
	locks[id] = false;
	MyCompany.Aquarius.app:WriteConfig("Locks", nil);
	MyCompany.Aquarius.app:WriteConfig("Locks", locks);
end

function Quest.OnQuestGiver_Bye(NPC_id)
	ParaUI.Destroy("Quest_DialogWnd");
	ParaUI.Destroy("Quest_DetailsWnd");
	ParaUI.Destroy("Quest_CompleteWnd");
	
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("NPCQuestDialog");
	if(_wnd ~= nil) then
		_wnd:ShowWindowFrame(false);
	end
end

-- quest dialog window message processor
function Quest.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		System.Quest.Client.QuestgiverBye();
	end
end


-- Quest ID and quest mapping
Quest.NPC_ID_Quest_Mapping = {};
-- Quest ID and queststatus mapping
Quest.NPC_QuestID_Status_Mapping = {};

-- NPC ID and name mapping
Quest.NPC_ID_Name_Mapping = {};
-- NPC name and ID mapping
Quest.NPC_Name_ID_Mapping = {};

function Quest.GetIDFromCharName(CharName)
	local Name = string.sub(CharName, 5);
	return Quest.NPC_Name_ID_Mapping[Name];
end

function Quest.GetCharNameFromID(NPC_id)
	return Quest.NPC_ID_Name_Mapping[NPC_id];
end


NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGHandler_Client.lua");
local Quest_MSGHandler_Client = Map3DSystem.Quest.Client.MSGHandler;

-- SMSG_QUESTGIVER_BYE
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_BYE(Quest.OnQuestGiver_Bye);


NPL.load("(gl)script/apps/Aquarius/Quest/Quest_NPCStatus.lua");

-- SMSG_QUESTGIVER_STATUS
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_STATUS(MyCompany.Aquarius.Quest_NPCStatus.OnQuestgiver_Status);
-- SMSG_NEARBY_NPCS
Quest_MSGHandler_Client.RegisterHandler_SMSG_NEARBY_NPCS(MyCompany.Aquarius.Quest_NPCStatus.OnReceiveNearbyNPC);




NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DialogWnd.lua");

-- SMSG_QUESTGIVER_QUEST_LIST
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_LIST(MyCompany.Aquarius.Quest_DialogWnd.OnRecvQuestList)


-- SMSG_QUESTGIVER_QUEST_COMPLETE
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_COMPLETE(MyCompany.Aquarius.Quest_DialogWnd.OnQuestComplete);




NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DetailsWnd.lua");

-- SMSG_QUESTGIVER_QUEST_DETAILS
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_DETAILS(MyCompany.Aquarius.Quest_DetailsWnd.OnRecvDetails)
-- SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM(MyCompany.Aquarius.Quest_DetailsWnd.OnAcceptQuestResponse)




NPL.load("(gl)script/apps/Aquarius/Quest/Quest_CompleteWnd.lua");
-- SMSG_QUESTGIVER_OFFER_REWARD
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_OFFER_REWARD(MyCompany.Aquarius.Quest_CompleteWnd.OnOfferReward)






-- SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER(function(id, count, CurrentDialog_NPC_id) 
		--_guihelper.MessageBox("SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER: goal_id: "..id.."\n");
		log("SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER: goal_id: "..id.."\n");
		
		--local name = Quest.GetCharNameFromID(CurrentDialog_NPC_id);
		--if(name) then
			--headon_speech.Speek("NPC:"..name, "恭喜你答对咯\n", 3);
		--end
	end);

-- SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER(function(id, CurrentDialog_NPC_id) 
		--_guihelper.MessageBox("SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER: goal_id: "..id.."\n");
		log("SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER: goal_id: "..id.."\n");
		
		--local name = Quest.GetCharNameFromID(CurrentDialog_NPC_id);
		--if(name) then
			--headon_speech.Speek("NPC:"..name, "这么简单都答错\n", 3);
		--end
	end);