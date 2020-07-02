--[[
Title: Quest NPC status
Author(s): WangTian
Date: 2008/12/10

Desc: NPC status refer to the quest status of the user on the NPC
		e.g. available quest may be shown as a yellow exclamatory mark "!"
		e.g. not available quest(maybe due to reputation or level) may be shown as a grey exclamatory mark "!"
		e.g. quest waited to complete may be shown as a grey question mark "?"
		e.g. completed quest waited for accomplish may be shown as a yellow question mark "?"

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Quest/Quest_NPCStatus.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");

-- create class
local libName = "Quest_NPCStatus";
local Quest_NPCStatus = {};
commonlib.setfield("MyCompany.Aquarius.Quest_NPCStatus", Quest_NPCStatus);

NPL.load("(gl)script/apps/Aquarius/Quest/main.lua");
local Quest = MyCompany.Aquarius.Quest;

-- head mark assets
local headmark_assets = {
	["DIALOG_STATUS_NONE"] = "",
	["DIALOG_STATUS_UNAVAILABLE"] = "",
	["DIALOG_STATUS_CHAT"] = "",
	["DIALOG_STATUS_INCOMPLETE"] = "character/common/headquest/headquest2.x",
	["DIALOG_STATUS_REWARD_REP"] = "",
	["DIALOG_STATUS_AVAILABLE_REP"] = "",
	["DIALOG_STATUS_AVAILABLE"] = "character/common/headexclaimed/headexclaimed.x",
	["DIALOG_STATUS_REWARD2"] = "", 
	["DIALOG_STATUS_REWARD"] = "character/common/headquest/headquest.x", 
}

local minimap_assets = {
	["DIALOG_STATUS_NONE"] = "",
	["DIALOG_STATUS_UNAVAILABLE"] = "",
	["DIALOG_STATUS_CHAT"] = "",
	["DIALOG_STATUS_INCOMPLETE"] = "model/test/ryb/yellow/yellow.x",
	["DIALOG_STATUS_REWARD_REP"] = "",
	["DIALOG_STATUS_AVAILABLE_REP"] = "",
	["DIALOG_STATUS_AVAILABLE"] = "model/test/ryb/yellow/yellow.x",
	["DIALOG_STATUS_REWARD2"] = "", 
	["DIALOG_STATUS_REWARD"] = "model/test/ryb/yellow/yellow.x", 
}

local texture_assets = {
	["DIALOG_STATUS_NONE"] = "",
	["DIALOG_STATUS_UNAVAILABLE"] = "",
	["DIALOG_STATUS_CHAT"] = "",
	["DIALOG_STATUS_INCOMPLETE"] = "Texture/Aquarius/Minimap/Question_Mark_Grey_32bits.png",
	["DIALOG_STATUS_REWARD_REP"] = "",
	["DIALOG_STATUS_AVAILABLE_REP"] = "",
	["DIALOG_STATUS_AVAILABLE"] = "Texture/Aquarius/Minimap/Excalmatory_Mark_32bits.png",
	["DIALOG_STATUS_REWARD2"] = "", 
	["DIALOG_STATUS_REWARD"] = "Texture/Aquarius/Minimap/Question_Mark_32bits.png", 
}

NPL.load("(gl)script/ide/StateMachine.lua");
Quest_NPCStatus.FSMs = {};

-- get all Quest NPCs from world
function Quest_NPCStatus.GetNearbyNPCs()
	System.Quest.Client.GetNearbyNPCs();
end

Quest_NPCStatus.hasCMBCreditCard = false;
Quest_NPCStatus.hasCMBBankAccount = false;
Quest_NPCStatus.isCitizen = false;

Quest_NPCStatus.isReserve189 = false;

function Quest_NPCStatus.SetCMBCreditCard(bSet)
	if(bSet == nil) then
		return;
	end
	if(Quest_NPCStatus.hasCMBCreditCard == false and bSet == true) then
		MyCompany.Aquarius.Desktop.Dock.ShowNotification("您开通了招商银行信用卡\n");
	end
	Quest_NPCStatus.hasCMBCreditCard = bSet;
end

function Quest_NPCStatus.SetCMBBankAccount(bSet)
	if(bSet == nil) then
		return;
	end
	if(Quest_NPCStatus.hasCMBBankAccount == false and bSet == true) then
		MyCompany.Aquarius.Desktop.Dock.ShowNotification("您开通了一卡通帐户\n");
	end
	Quest_NPCStatus.hasCMBBankAccount = bSet;
end

-- receive nearby NPCs
function Quest_NPCStatus.OnReceiveNearbyNPC(NPC)
	if(type(NPC) ~= "table") then
		return;
	end
	
	-- record NPC ID and name mapping
	Quest.NPC_ID_Name_Mapping[NPC.ID] = NPC.Name;
	-- record NPC name and ID mapping
	Quest.NPC_Name_ID_Mapping[NPC.Name] = NPC.ID;
	
	-- auto query status
	System.Quest.Client.QuestgiverStatusQuery(NPC.ID);
	
	-- create each NPC character
	local char = ParaScene.GetCharacter("NPC:"..NPC.Name);
	if(char:IsValid() == true) then
		-- if character exists, update the position and rotation
		char:SetPosition(NPC.posX, NPC.posY, NPC.posZ);
		char:SetFacing(NPC.Facing);
		char:SetScaling(NPC.Scaling);
		return;
	end
	local obj_params = {};
	obj_params.name = "NPC:"..NPC.Name;
	obj_params.x = NPC.posX;
	obj_params.y = NPC.posY;
	obj_params.z = NPC.posZ;
	obj_params.AssetFile = NPC.AssetName;
	obj_params.facing = NPC.Facing;
	obj_params.IsCharacter = true;
	obj_params.scaling = NPC.Scaling;
	obj_params.PhysicsRadius = NPC.Radius;
	obj_params.Density = NPC.Weight;
	obj_params.CCSInfoStr = NPC.CustomAppearance;
	-- skip saving to history for recording or undo.
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true,});
	
	local player = ParaScene.GetCharacter("NPC:"..NPC.Name);
	local playerChar = player:ToCharacter();
	playerChar:AssignAIController("face", "true");
	--------------------------------------------------------
	--player:GetAttributeObject():SetField("SentientField", 3);--senses everybody including its own kind.
	player:GetAttributeObject():SetField("Sentient Radius", System.options.CharClickDistSq); -- sense click distance characters
	--player:GetAttributeObject():SetField("GroupID", 3);
	-- player:GetAttributeObject():SetField("Sentient", true);
	--player:MakeGlobal(true);
	--------------------------------------------------------
	
	if(NPC.Name == "帕拉巫世界传送大使") then
		local player = ParaScene.GetCharacter("NPC:"..NPC.Name);
		System.UI.MiniMapManager.RegisterOPCObject(player.name, "model/test/ryb/blue/blue.x", "Texture/Aquarius/Minimap/Portal_32bits.png");
		
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "请将我传送到公共世界");
		FSM:AppendInput(2, "请将我传送到涂鸦世界");
		
		FSM:AppendState(1, "Hi, I'm the transportor. You need any transportation?")
		FSM:AppendState(2, "Enter Official World");
		FSM:AppendState(3, "Enter Doodle World");
		
		FSM:SetStateEntryAction(1, function() 
			local worldpath = ParaWorld.GetWorldDirectory();
			if(worldpath == "worlds/MyWorlds/AlphaWorld/") then
				FSM:ClearInputs();
				FSM:AppendInput(1, nil);
				FSM:AppendInput(2, "请将我传送到涂鸦世界");
			elseif(worldpath == "worlds/MyWorlds/DoodleWorld/") then
				FSM:ClearInputs();
				FSM:AppendInput(1, "请将我传送到公共世界");
				FSM:AppendInput(2, nil);
			end
		end);
		
		FSM:AppendTransition(1, 1, 2);
		FSM:AppendTransition(1, 2, 3);
		
		FSM:SetStartState(1);
		FSM:SetFinalStates({2, 3});
		
		FSM:SetFinalCallback(function(state)
			System.Quest.Client.QuestgiverBye();
			if(state == 2) then
				log("DO: Official World transport\n")
				System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/AlphaWorld", role = "guest"});
			elseif(state == 3) then
				log("DO: Doodle World transport\n")
				System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/DoodleWorld"});
			end
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
	elseif(NPC.Name == "IKEA营业员Anna") then
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "普通购物通道");
		FSM:AppendInput(2, "招行信用卡专用通道");
		FSM:AppendInput(3, "我该怎样办理招行信用卡呢？");
		FSM:AppendInput(4, "我现在不想逛了，谢谢！");
		
		FSM:AppendInput(5, "普通购物通道");
		FSM:AppendInput(6, "我该怎样办理招行信用卡呢？");
		FSM:AppendInput(7, "我现在不想逛了，谢谢！");
		
		FSM:AppendInput(8, "我还是先逛逛普通通道吧。");
		FSM:AppendInput(9, "好的，我这就去办！");
		
		FSM:AppendState(1, "欢迎来到IKEA，这里有最棒的家具哦，赶快逛逛吧，招商银行信用卡用户可以打8折哦！祝您购物愉快！")
		FSM:AppendState(2, "对不起，您还没有招商银行信用卡，不能进入这个通道，请走普通购物通道，或者先去办理招行信用卡再来吧！");
		FSM:AppendState(3, "很简单，您可以到招行营业厅去办理。招商银行的营业厅就在这里出去不远！");
		
		FSM:SetStateEntryAction(1, function() 
			if(Quest_NPCStatus.hasCMBCreditCard == false) then
				FSM:ModifyTransition(1, 2, 2); -- don't have credit
			elseif(Quest_NPCStatus.hasCMBCreditCard == true) then
				FSM:ModifyTransition(1, 2, 5); -- have credit
			end
		end);
		
		FSM:SetStateEntryAction(2, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		end);
		
		FSM:SetStateEntryAction(3, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 3);
		end);
		
		FSM:AppendState(4, "进入商品浏览界面");
		FSM:AppendState(5, "播放动画\"出示招行信用卡\"，然后进入商品浏览界面(所有物价打8折)");
		
		FSM:AppendState(6, "退出当前对话");
		
		FSM:AppendTransition(1, 1, 4);
		FSM:AppendTransition(1, 2, 5); -- have credit
		--FSM:AppendTransition(1, 2, 2); -- not credit
		FSM:AppendTransition(1, 3, 3);
		FSM:AppendTransition(1, 4, 6);
		FSM:AppendTransition(2, 5, 4);
		FSM:AppendTransition(2, 6, 3);
		FSM:AppendTransition(2, 7, 6);
		FSM:AppendTransition(3, 8, 4);
		FSM:AppendTransition(3, 9, 6);
		
		FSM:SetStartState(1);
		FSM:SetFinalStates({4, 5, 6});
		
		FSM:SetFinalCallback(function(state)
			if(state == 4) then
				System.Quest.Client.QuestgiverBye();
				log("DO: Show normal window\n")
				
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/IKEA/BrowseProduct.html", 
					name = "CMB.OpenAccount", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "IKEA普通购物通道", 
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -600/2,
						y = -530/2,
						width = 600,
						height = 500,
						bAutoSize=true,
				});	
				System.App.Commands.Call("Profile.Aquarius.ShowAssetBag", {url = "script/apps/Aquarius/Bag/MyBag.html"});
			elseif(state == 5) then
				-- show CMB credit card
				MyCompany.Aquarius.Desktop.Dock.ShowNotification(function (_parent)
					if(_parent == nil or _parent:IsValid() == false) then
						return;
					end
					
					local _notify = ParaUI.CreateUIObject("container", "items", "_lt", 0, 0, 200, 128);
					_notify.background = "Texture/Aquarius/Andy/CreditCard.png";
					_parent:AddChild(_notify);
				end);
				System.Quest.Client.QuestgiverBye();
				log("DO: Show discount window\n")
				
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/IKEA/BrowseDiscountProduct.html", 
					name = "CMB.OpenAccount", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "招行信用卡专用通道",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -600/2,
						y = -530/2,
						width = 600,
						height = 500,
						bAutoSize=true,
				});	
				System.App.Commands.Call("Profile.Aquarius.ShowAssetBag", {url = "script/apps/Aquarius/Bag/MyBagWithCreditCard.html"});
			elseif(state == 6) then
				System.Quest.Client.QuestgiverBye();
				log("DO: Leave\n")
			end
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
	elseif(NPC.Name == "招商银行营业员小丽" or NPC.Name == "招商银行营业员小月") then
		
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "我要存/取款");
		FSM:AppendInput(2, "招行信用卡最近有什么活动吗？");
		FSM:AppendInput(3, "哦不用，我要走了，谢谢！");
		
		FSM:AppendInput(4, "是的，我要开通！");
		FSM:AppendInput(5, "不，我不需要！");
		
		FSM:AppendInput(6, "刷招行信用卡，至尊租车租一天送一天！");
		FSM:AppendInput(7, "刷卡电话分期买DELL电脑，手续费率仅“1%”");
		FSM:AppendInput(8, "电话分期买笔记本，尽享招行惊喜团购价");
		
		FSM:AppendInput(9, "是的，我要申请！");
		FSM:AppendInput(10, "不，我不需要！");
		
		FSM:AppendInput(11, "怎样成为正式移民？");
		FSM:AppendInput(12, "那我待会再来吧，谢谢！");
		
		FSM:AppendInput(13, "好的，我知道了！");
		FSM:AppendInput(14, "我还想问点别的。");
		
		FSM:AppendState(1, "欢迎光临招商银行，有什么可以帮您？")
		FSM:AppendState(2, "您还没有开通银行账户，需要开通吗？");
		FSM:AppendState(3, "招商银行信用卡中心最近有这些活动，您想了解哪一项呢？");
		FSM:AppendState(4, "您还没有招行的信用卡，要申请吗？");
		FSM:AppendState(5, "对不起，您还不是正式移民，不能开通此项业务");
		FSM:AppendState(6, "您可以去\"移民总署\"找\"户籍管理员\"申请成为\"正式移民\"，移民总署就在这里的西边。");
		
		FSM:AppendState(7, "进入存取款界面");
		FSM:AppendState(8, "进入银行开户流程");
		FSM:AppendState(9, "打开活动内容介绍页面1");
		FSM:AppendState(10, "打开活动内容介绍页面2");
		FSM:AppendState(11, "打开活动内容介绍页面3");
		FSM:AppendState(12, "进入信用卡申请流程");
		FSM:AppendState(13, "退出当前对话");
		FSM:AppendState(14, "重新回到原始窗口");
		
		FSM:SetStateEntryAction(1, function()	
			if(Quest_NPCStatus.hasCMBBankAccount == false) then
				FSM:ModifyTransition(1, 1, 2); -- don't have account
			elseif(Quest_NPCStatus.hasCMBBankAccount == true) then
				FSM:ModifyTransition(1, 1, 7); -- have account
			end
			
			if(Quest_NPCStatus.hasCMBCreditCard == false) then
				FSM:ModifyTransition(1, 2, 4); -- don't have credit
			elseif(Quest_NPCStatus.hasCMBCreditCard == true) then
				FSM:ModifyTransition(1, 2, 3); -- have credit
			end
			
			if(Quest_NPCStatus.isCitizen == false) then
				FSM:ModifyTransition(2, 4, 5); -- not citizen
				FSM:ModifyTransition(4, 9, 5); -- not citizen
			elseif(Quest_NPCStatus.isCitizen == true) then
				FSM:ModifyTransition(2, 4, 8); -- citizen
				FSM:ModifyTransition(4, 9, 12); -- citizen
			end
		end);
		
		FSM:SetStateEntryAction(2, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		end);
		
		FSM:SetStateEntryAction(3, function() 
			MyCompany.Aquarius.Desktop.Dock.ShowNotification(function (_parent)
				if(_parent == nil or _parent:IsValid() == false) then
					return;
				end
				
				local _notify = ParaUI.CreateUIObject("container", "items", "_lt", 0, 0, 200, 128);
				_notify.background = "Texture/Aquarius/Andy/CreditCard.png";
				_parent:AddChild(_notify);
			end);
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 3);
		end);
		
		FSM:SetStateEntryAction(4, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 4);
		end);
		
		FSM:SetStateEntryAction(5, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 5);
		end);
		
		FSM:SetStateEntryAction(6, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 6);
		end);
		
		FSM:AppendTransition(1, 1, 7); -- have account
		--FSM:AppendTransition(1, 1, 2); -- not account
		FSM:AppendTransition(1, 2, 3); -- have credit
		--FSM:AppendTransition(1, 2, 4); -- not credit
		FSM:AppendTransition(1, 3, 13);
		FSM:AppendTransition(2, 4, 8); -- citizen
		--FSM:AppendTransition(2, 4, 5); -- not citizen
		FSM:AppendTransition(2, 5, 13);
		FSM:AppendTransition(3, 6, 9);
		FSM:AppendTransition(3, 7, 10);
		FSM:AppendTransition(3, 8, 11);
		FSM:AppendTransition(4, 9, 12); -- citizen
		--FSM:AppendTransition(4, 9, 5); -- not citizen
		FSM:AppendTransition(4, 10, 13);
		FSM:AppendTransition(5, 11, 6);
		FSM:AppendTransition(5, 12, 13);
		FSM:AppendTransition(6, 13, 13);
		FSM:AppendTransition(6, 14, 14);
		
		FSM:SetStartState(1);
		FSM:SetFinalStates({7, 8, 9, 10, 11, 12, 13, 14});
		
		FSM:SetFinalCallback(function(state)
			if(state == 7) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 进入存取款界面\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/CMB/ATM.html", 
					name = "CMB.ATM", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "招商银行ATM机",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -430/2,
						y = -550/2,
						width = 430,
						height = 510,
						bAutoSize=true,
				});	
			elseif(state == 8) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 进入银行开户流程\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/CMB/OpenAccount.html", 
					name = "CMB.OpenAccount", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "招商银行一卡通",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -600/2,
						y = -530/2,
						width = 600,
						height = 500,
						bAutoSize=true,
				});	
			elseif(state == 9) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开活动内容介绍页面1\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/CMB/Special1.html", 
					name = "CMB.Special1", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "刷招行信用卡，至尊租车租一天送一天！",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -625/2,
						y = -580/2,
						width = 625,
						height = 550,
						bAutoSize=true,
				});	
			elseif(state == 10) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开活动内容介绍页面2\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/CMB/Special2.html", 
					name = "CMB.Special2", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "刷卡电话分期买DELL电脑，手续费率仅“1%”",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -625/2,
						y = -580/2,
						width = 625,
						height = 530,
						bAutoSize=true,
				});	
			elseif(state == 11) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开活动内容介绍页面3\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/CMB/Special3.html", 
					name = "CMB.Special3", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "电话分期买笔记本，尽享招行惊喜团购价",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -625/2,
						y = -580/2,
						width = 625,
						height = 550,
						bAutoSize=true,
				});	
			elseif(state == 12) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 进入信用卡申请流程\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/CMB/ApplyCreditCard.html", 
					name = "CMB.ApplyCreditCard", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "申请招商银行信用卡",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -625/2,
						y = -580/2,
						width = 625,
						height = 550,
						bAutoSize=true,
				});	
			elseif(state == 13) then
				System.Quest.Client.QuestgiverBye();
				log("DO: Leave\n")
			elseif(state == 14) then
				System.Quest.Client.QuestgiverBye();
				log("DO: Restart\n")
				System.Quest.Client.QuestgiverHello(NPC.ID);
			end
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
		
	elseif(NPC.Name == "电信营业员小李" or NPC.Name == "电信营业员小张") then
		
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "好啊，这就参加！");
		FSM:AppendInput(2, "给我介绍点别的业务吧？");
		FSM:AppendInput(3, "不必了，谢谢！");
		
		FSM:AppendInput(4, "给我介绍点别的业务吧？");
		FSM:AppendInput(5, "那好吧，再见！");
		
		FSM:AppendInput(6, "寻宝大激奖:无线宽带免费用 上网积分拿电脑 ");
		FSM:AppendInput(7, "豪华手机大放送，手机仿真新体验");
		FSM:AppendInput(8, "“我的e家”宽带1年＝16个月");
		FSM:AppendInput(9, "谢谢，我还是待会再来吧");
		
		FSM:AppendState(1, "欢迎光临中国电信营业厅，189抢号活动正在进行中哦，参与一下吧？")
		FSM:AppendState(2, "按照规定，每位用户只能预定2个189号码了，您已经预定过2个了，所以不能再参加这个活动了哟！");
		FSM:AppendState(3, "中国电信已经正式进驻了，在这里您也可以办理很多中国电信的业务哦！");
		
		FSM:AppendState(4, "打开189抢号界面");
		FSM:AppendState(5, "打开活动内容介绍页面1");
		FSM:AppendState(6, "打开活动内容介绍页面2");
		FSM:AppendState(7, "打开活动内容介绍页面3");
		FSM:AppendState(8, "退出当前对话");
		
		FSM:SetStateEntryAction(1, function()	
			if(Quest_NPCStatus.isReserve189 == false) then
				FSM:ModifyTransition(1, 1, 4); -- don't reserve
			elseif(Quest_NPCStatus.isReserve189 == true) then
				FSM:ModifyTransition(1, 1, 2); -- reserved
			end
		end);
		
		FSM:SetStateEntryAction(2, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		end);
		
		FSM:SetStateEntryAction(3, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 3);
		end);
		
		--FSM:AppendTransition(1, 1, 4); -- don't reserve
		FSM:AppendTransition(1, 1, 2); -- reserved
		FSM:AppendTransition(1, 2, 3);
		FSM:AppendTransition(1, 3, 8);
		FSM:AppendTransition(2, 4, 3);
		FSM:AppendTransition(2, 5, 8);
		FSM:AppendTransition(3, 6, 5);
		FSM:AppendTransition(3, 7, 6);
		FSM:AppendTransition(3, 8, 7);
		FSM:AppendTransition(3, 9, 8);
		
		FSM:SetStartState(1);
		FSM:SetFinalStates({4,5,6,7,8});
		
		FSM:SetFinalCallback(function(state)
			if(state == 4) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开189抢号界面\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/Telecom/189.html", 
					name = "Telecom.189", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "“天翼”189抢号大行动开始啦！",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -820/2,
						y = -600/2,
						width = 820,
						height = 550,
						bAutoSize=true,
				});	
			elseif(state == 5) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开活动内容介绍页面1\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/Telecom/Special1.html", 
					name = "Telecom.Special1", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "豪华手机大放送，手机仿真新体验",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -780/2,
						y = -610/2,
						width = 780,
						height = 565,
						bAutoSize=true,
				});	
			elseif(state == 6) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开活动内容介绍页面2\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/Telecom/Special2.html", 
					name = "Telecom.Special1", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "“我的e家”宽带1年＝16个月",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -945/2,
						y = -580/2,
						width = 945,
						height = 560,
						bAutoSize=true,
				});	
			elseif(state == 7) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 打开活动内容介绍页面3\n")
				System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aquarius/Quest/Telecom/Special3.html", 
					name = "Telecom.Special1", 
					app_key = MyCompany.Aquarius.app.app_key, 
					text = "寻宝大激奖:无线宽带免费用 上网积分拿电脑",
					DestroyOnClose = true,
					directPosition = true,
						align = "_ct",
						x = -823/2,
						y = -580/2,
						width = 823,
						height = 550,
						bAutoSize=true,
				});	
			elseif(state == 8) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 退出当前对话\n")
			end
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
	elseif(NPC.Name == "户籍管理员清颖") then
		
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "怎样成为正式移民？");
		FSM:AppendInput(2, "申请成为正式移民");
		FSM:AppendInput(3, "不用了，谢谢！");
		
		FSM:AppendInput(4, "好的，我这就去办");
		
		FSM:AppendInput(5, "哦，我还想问点别的！");
		
		FSM:AppendInput(6, "太棒了，我还想问点别的！");
		FSM:AppendInput(7, "谢谢，再见");
		
		FSM:AppendState(1, "欢迎来到社区，我是户籍管理员清颖，请问您需要了解哪项服务？")
		FSM:AppendState(2, "你必须在“个人信息”中的“真实的我”界面完善你的真实信息，才可以申请成为正式移民！");
		FSM:AppendState(3, "你已经是正式移民了哟！");
		FSM:AppendState(4, "恭喜你已经成为这里的正式移民，并且获得了社区身份证！你的身份证信息将显示在你的“个人信息”界面中。");
		
		FSM:AppendState(5, "将用户“身份”改为“正式移民”");
		FSM:AppendState(6, "退出当前对话");
		FSM:AppendState(7, "重新回到原始窗口");
		
		FSM:SetStateEntryAction(1, function()	
			if(Quest_NPCStatus.isCitizen == false) then
				FSM:ModifyTransition(1, 2, 4); -- don't reserve
			elseif(Quest_NPCStatus.isCitizen == true) then
				FSM:ModifyTransition(1, 2, 3); -- reserved
			end
		end);
		
		FSM:SetStateEntryAction(2, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		end);
		
		FSM:SetStateEntryAction(3, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 3);
		end);
		
		FSM:SetStateEntryAction(4, function() 
			Quest_NPCStatus.isCitizen = true;
			-- notification
			MyCompany.Aquarius.Desktop.Dock.ShowNotification("您成为了Pala5的正式移民");
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 4);
		end);
		
		FSM:AppendTransition(1, 1, 2);
		FSM:AppendTransition(1, 2, 3); -- citizen
		--FSM:AppendTransition(1, 2, 4); -- not citizen, we skip the real personal information checking to accept all citizen request
		FSM:AppendTransition(1, 3, 6);
		FSM:AppendTransition(2, 4, 6);
		FSM:AppendTransition(3, 5, 7);
		FSM:AppendTransition(4, 6, 7);
		FSM:AppendTransition(4, 7, 6);
		
		FSM:SetStartState(1);
		FSM:SetFinalStates({6, 7});
		
		FSM:SetFinalCallback(function(state)
			if(state == 6) then
				System.Quest.Client.QuestgiverBye();
				log("DO: 退出当前对话\n")
			elseif(state == 7) then
				System.Quest.Client.QuestgiverBye();
				log("DO: restart\n")
				System.Quest.Client.QuestgiverHello(NPC.ID);
			end
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
	elseif(NPC.Name == "一号新手接待员甜甜" or NPC.Name == "二号新手接待员微笑" or NPC.Name == "四号新手接待员百合") then
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "在哪里完善个人资料");
		FSM:AppendInput(2, "在哪里体验商务设施");
		FSM:AppendInput(3, "在哪里可以玩休闲游戏");
		--FSM:AppendInput(4, "观看PE社区电影");
		FSM:AppendInput(5, "随便跟我聊两句");
		
		FSM:AppendState(1, "你好,欢迎来到PE社区,我是一号新手接待员甜甜,有什么可以帮到你吗?")
		FSM:AppendState(2, "在移民总署里找户籍管理员他们会帮助你。出门向西南方走，是栋很大的建筑，相信你在很远的地方就能看到它！祝您旅途愉快！再见！");
		FSM:AppendState(3, "社区商务大厦有这项服务，出门向东南方走，很快就能看到了！祝您旅途愉快！再见！");
		FSM:AppendState(4, "此项内容还没有开放");
		FSM:AppendState(5, "嗨！很高兴见到你！欢迎来到PE社区！");
		FSM:AppendState(6, "播放PE社区电影");
		FSM:AppendState(7, "退出当前对话");
		
		FSM:SetStateEntryAction(2, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		end);
		
		FSM:SetStateEntryAction(3, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 3);
		end);
		
		FSM:SetStateEntryAction(4, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 4);
		end);
		
		FSM:SetStateEntryAction(5, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 5);
		end);
		
		FSM:SetStateEntryAction(6, function() 
			System.Quest.Client.QuestgiverBye();
			MyCompany.Aquarius.Desktop.HideAllVisible();
			System.App.Commands.Call("File.PlayMovieScript", "movie_1.xml");
			
			System.Movie.MoviePlayerPage.PlayerClose = function() MyCompany.Aquarius.Desktop.RestoreAllVisible(); end;
		end);
		
		FSM:AppendTransition(1, 1, 2);
		FSM:AppendTransition(1, 2, 3);
		FSM:AppendTransition(1, 3, 4);
		FSM:AppendTransition(1, 4, 6);
		FSM:AppendTransition(1, 5, 5);
		
		FSM:SetStartState(1);
		
		FSM:SetFinalStates({7});
		
		FSM:SetFinalCallback(function(state)
			System.Quest.Client.QuestgiverBye();
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
	elseif(NPC.Name == "义工小兰" or NPC.Name == "义工阿旺" or NPC.Name == "义工菲菲" or NPC.Name == "义工小海" 
			or NPC.Name == "淘气的小孩花一路" or NPC.Name == "迷路的妹妹朵朵" or NPC.Name == "陈工程师"
			or NPC.Name == "朵朵妈" or NPC.Name == "清洁工时伯"
			or NPC.Name == "巡逻的警察维德" or NPC.Name == "巡逻的警察维尼"
			or NPC.Name == "星球管理处门卫星驰" or NPC.Name == "移民中心门卫黎明" or NPC.Name == "移民中心门卫德华") then
		local FSM = commonlib.StateMachine:new();
		
		FSM:AppendInput(1, "跟我聊聊");
		FSM:AppendInput(2, "再会");
		
		FSM:AppendState(1, "你好！我是广场义工，有什么需要帮助的?")
		FSM:AppendState(2, "呵呵，我几乎每天都会来帮会忙，这里经常会有好看的演出和活动，这很有意思。");
		FSM:AppendState(3, "退出当前对话");
		
		FSM:SetStateEntryAction(1, function() 
			if(NPC.Name == "义工小兰") then
				FSM:ModifyState(2, "呵呵，我几乎每天都会来帮会忙，这里经常会有好看的演出和活动，这很有意思。");
			elseif(NPC.Name == "义工阿旺") then
				FSM:ModifyState(2, "你好啊！你喜欢唱歌吗？我很喜欢的，在广场上经常有很多的歌舞表演，有机会可以去唱歌给大家听，很好玩哦。");
			elseif(NPC.Name == "义工菲菲") then
				FSM:ModifyState(2, "你好啊！很高兴在这里见到你！今天的天气真不错，祝你玩的愉快！");
			elseif(NPC.Name == "义工小海") then
				FSM:ModifyState(2, "哦！聊天我不是很擅长也，嗯！");
			elseif(NPC.Name == "淘气的小孩花一路") then
				FSM:ModifyState(2, "哦，我叫花一路，花是花朵的花，一是一二三的一，路是大路的路哦，怎么样？很威风吧！");
			elseif(NPC.Name == "迷路的妹妹朵朵") then
				FSM:ModifyState(2, "呜呜！妈妈不见了，我把妈妈弄丢了，我不要聊天，我要找妈妈，呜呜！");
			elseif(NPC.Name == "陈工程师") then
				FSM:ModifyState(2, "啊！怎么那么烦，都跟你说了，我很忙的，快走，快走，我没功夫理你！");
			elseif(NPC.Name == "朵朵妈") then
				FSM:ModifyState(2, "每次来都要买好多的东西，真难打理，对了，我还得去给朵朵买条新裙子，嗯，这就去！");
			elseif(NPC.Name == "清洁工时伯") then
				FSM:ModifyState(2, "每天这里都会有很多人来来回回，我的工作是很辛苦的！你也不要乱丢垃圾，要注意环境卫生哦！");
			elseif(NPC.Name == "巡逻的警察维德") then
				FSM:ModifyState(2, "很抱歉！我现在正在值勤，不方便聊天。");
			elseif(NPC.Name == "巡逻的警察维尼") then
				FSM:ModifyState(2, "很抱歉！我现在正在值勤，不方便聊天。");
			elseif(NPC.Name == "星球管理处门卫星驰") then
				FSM:ModifyState(2, "很抱歉！我现在正在值勤，不方便聊天。");
			elseif(NPC.Name == "移民中心门卫黎明") then
				FSM:ModifyState(2, "很抱歉！我现在正在值勤，不方便聊天。");
			elseif(NPC.Name == "移民中心门卫德华") then
				FSM:ModifyState(2, "很抱歉！我现在正在值勤，不方便聊天。");
			end
		end);
		
		FSM:SetStateEntryAction(2, function() 
			MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		end);
		
		FSM:AppendTransition(1, 1, 2);
		FSM:AppendTransition(1, 2, 3);
		
		FSM:SetStartState(1);
		FSM:SetFinalStates({3});
		
		FSM:SetFinalCallback(function(state)
			System.Quest.Client.QuestgiverBye();
		end);
		
		Quest_NPCStatus.FSMs[NPC.ID] = FSM;
		
	--elseif(NPC.Name == "移民中心门卫黎明" or NPC.Name == "移民中心门卫德华" or NPC.Name == "巡巡逻的警察维得"
			--or NPC.Name == "星球管理处门卫星驰" or NPC.Name == "巡逻的警察维尼") then
		--local FSM = commonlib.StateMachine:new();
		--
		--FSM:AppendInput(1, "户籍管理处");
		--FSM:AppendInput(2, "商务区");
		--FSM:AppendInput(3, "商业街");
		--FSM:AppendInput(4, "银行");
		--FSM:AppendInput(5, "中心广场");
		--FSM:AppendInput(6, "游乐场");
		--
		--FSM:AppendState(1, "你要去哪里?")
		--FSM:AppendState(2, "户籍管理处");
		--FSM:AppendState(3, "商务区");
		--FSM:AppendState(4, "商业街");
		--FSM:AppendState(5, "银行");
		--FSM:AppendState(6, "中心广场");
		--FSM:AppendState(7, "游乐场");
		--
		--FSM:SetStateEntryAction(2, function() 
			--MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 2);
		--end);
		--
		--FSM:SetStateEntryAction(3, function() 
			--MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 3);
		--end);
		--
		--FSM:SetStateEntryAction(4, function() 
			--MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 4);
		--end);
		--
		--FSM:SetStateEntryAction(5, function() 
			--MyCompany.Aquarius.Quest_DialogWnd.ShowFSMDialog(NPC.ID, 5);
		--end);
		--
		--FSM:AppendTransition(1, 1, 2);
		--FSM:AppendTransition(1, 2, 3);
		--FSM:AppendTransition(1, 3, 4);
		--FSM:AppendTransition(1, 4, 5);
		--
		--FSM:SetStartState(1);
		--FSM:SetFinalStates({2,3,4,5,6,7});
		--
		--FSM:SetFinalCallback(function(state)
			---- TODO: create different dummy non-model characters to indicate the position of each region
			--if(state == 2) then
				--log("point 户籍管理处\n");
			--elseif(state == 3) then
				--log("point 商务区\n");
			--elseif(state == 4) then
				--log("point 商业街\n");
			--elseif(state == 5) then
				--log("point 银行\n");
			--elseif(state == 6) then
				--log("point 中心广场\n");
			--elseif(state == 7) then
				--log("point 游乐场\n");
			--end
		--end);
		--
		--Quest_NPCStatus.FSMs[NPC.ID] = FSM;
	else
		Quest_NPCStatus.FSMs[NPC.ID] = nil;
	end
end

-- update all the NPC status
-- NOTE: this function is called at world load
function Quest_NPCStatus.UpdateAllNPCStatus()
	
	--for all bipeds, get NPC status
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	while(playerCur:IsValid() == true) do
		-- get next object
		playerCur = ParaScene.GetNextObject(playerCur);
		
		if(playerCur:IsValid() and playerCur:IsCharacter()) then
			-- call each NPC's UpdateStatus function
			Quest_NPCStatus.UpdateStatus(playerCur)
		end
		
		-- if cycled to the player character
		if(playerCur:equals(player) == true) then
			break;
		end
	end
	
end

-- update the status of an NPC
-- @param NPC: ParaObject
--		e.g. available quest may be shown as a yellow exclamatory mark "!"
--		e.g. not available quest(maybe due to reputation or level) may be shown as a grey exclamatory mark "!"
--		e.g. quest waited to complete may be shown as a grey question mark "?"
--		e.g. completed quest waited for accomplish may be shown as a yellow question mark "?"
-- this will call check the local/remote quest server for specific NPC status
--	when the message returns it will change the scene character HeadMark
function Quest_NPCStatus.UpdateStatus(NPC)
	if(NPC ~= nil and NPC:IsValid() and NPC:IsCharacter()) then
		local ID = Quest.NPC_Name_ID_Mapping[NPC.name];
		if(ID ~= nil) then
			System.Quest.Client.QuestgiverStatusQuery(ID);
		end
	end
end

function Quest_NPCStatus.OnQuestgiver_Status(NPC_id, status)
	-- change the character headmark	
	local function ChangeHeadMark(NPC_id, markName)
		local charName = Quest.NPC_ID_Name_Mapping[NPC_id];
		
		local player;
		if(type(charName) == "string") then
			player = ParaScene.GetCharacter("NPC:"..charName);
		else
			return;
		end
		
		if(player:IsValid() == true)then
			-- remove previous attachment
			player:ToCharacter():RemoveAttachment(11);
			
			if(headmark_assets[markName] == "") then
				if(minimap_assets[markName] == "") then
					if(player.name == "NPC:帕拉巫世界传送大使") then
						-- this is a transfer portal object
						return;
					end
					System.UI.MiniMapManager.UnregisterOPCObject(player.name);
					return;
				end
				return;
			end
			
			-- TODO: change to update logic of OPC object in minimap manager
			-- otherwise the OPC list will contains multiple copies of minimap data
			System.UI.MiniMapManager.UnregisterOPCObject(player.name);
			System.UI.MiniMapManager.RegisterOPCObject(player.name, minimap_assets[markName], texture_assets[markName]);
			
			
			local asset = ParaAsset.LoadParaX("", headmark_assets[markName]);
			if(asset ~= nil and asset:IsValid() == true) then
				player:ToCharacter():AddAttachment(asset, 11);
			end
		end
	end
	
	-- mount the head on mark from the quest dialog status
	if(status == 0) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_NONE");
	elseif(status == 1) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_UNAVAILABLE");
	elseif(status == 2) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_CHAT");
	elseif(status == 3) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_INCOMPLETE");
	elseif(status == 4) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_REWARD_REP");
	elseif(status == 5) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_AVAILABLE_REP");
	elseif(status == 6) then
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_AVAILABLE");
	elseif(status == 7) then
		-- not yellow dot on minimap
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_REWARD2");
	elseif(status == 8) then
		-- yellow dot on minimap
		ChangeHeadMark(NPC_id, "DIALOG_STATUS_REWARD");
	end
end
