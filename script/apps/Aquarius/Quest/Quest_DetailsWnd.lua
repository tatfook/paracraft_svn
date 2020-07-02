--[[
Title: Quest details window
Author(s): WangTian
Date: 2008/12/13
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DetailsWnd.lua");
MyCompany.Aquarius.Quest_DetailsWnd.OnDetails(obj)
------------------------------------------------------------
]]

-- create class
local libName = "Quest_DetailsWnd";
local Quest_DetailsWnd = {};
commonlib.setfield("MyCompany.Aquarius.Quest_DetailsWnd", Quest_DetailsWnd);

local Quest = MyCompany.Aquarius.Quest;

-- on receive quest details
-- @param NPC_id: NPC id
-- @param gossiptext: gossip text
-- @param questlist: quest list
function Quest_DetailsWnd.OnRecvDetails(NPC_id, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney)
	
	local _client;
	local frame;
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("NPCQuestDialog");
	if(_wnd ~= nil) then
		frame = _wnd:GetWindowFrame();
		if(frame ~= nil) then
			_client = frame:GetWindowClientUIObject();
			if(_client == nil or _client:IsValid() == false) then
				-- silent init the frame object and get the client again
				frame:Show2(true, nil, true);
				_client = frame:GetWindowClientUIObject();
			end
		end
	end
	if(_client == nil or _client:IsValid() == false) then
		log("error getting client ui object in Quest_DetailsWnd.OnRecvDetails\n");
		return;
	end
	
	ParaUI.Destroy("Quest_DetailsWnd");
	
	
	--local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_DetailsWnd", "_lt", 50, 150, 300, 400);
	--_DialogWnd.background = nil;
	--_DialogWnd:AttachToRoot();
	
	local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_DetailsWnd", "_fi", 0, 0, 0, 0);
	_DialogWnd.background = nil;
	_client:AddChild(_DialogWnd);
	
	
	if(Objectives == nil and Requires == nil and RewOrReqMoney == nil) then
		-- QUEST_STATUS_INCOMPLETE  Quest is active in quest log but incomplete  
		local _details = ParaUI.CreateUIObject("container", "Details", "_lt", 0, 0, 300, 350);
		--_details.background = "";
		_DialogWnd:AddChild(_details);
		
		Quest_DetailsWnd.IncompletePage(_details, NPC_id, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney);
		
		--local _secret = ParaUI.CreateUIObject("button", "Secret", "_rb", -84, -100, 32, 32);
		--_secret.onclick = ";System.Quest.Client.QuestUpdateCRequire("..Requires[1].id..", ".."\"123ABC\""..");ParaUI.Destroy(\"Quest_DetailsWnd\");";
		--_secret.text = "R";
		--_DialogWnd:AddChild(_secret);
		--
		--local _secret = ParaUI.CreateUIObject("button", "Secret", "_rb", -52, -100, 32, 32);
		--_secret.onclick = ";System.Quest.Client.QuestUpdateCRequire("..Requires[1].id..", ".."\"123\""..");ParaUI.Destroy(\"Quest_DetailsWnd\");";
		--_secret.text = "W";
		--_DialogWnd:AddChild(_secret);
		
		-- back to dialog window
		local _left = ParaUI.CreateUIObject("button", "Left", "_lb", 20, -42, 64, 32);
		_left.onclick = ";ParaUI.Destroy(\"Quest_DetailsWnd\");System.Quest.Client.QuestgiverHello("..NPC_id..");";
		_left.text = "返回";
		_DialogWnd:AddChild(_left);
		
		local _right = ParaUI.CreateUIObject("button", "Right", "_rb", -84, -42, 64, 32);
		_right.onclick = ";System.Quest.Client.QuestgiverBye("..NPC_id..");";
		_right.text = "再见";
		_DialogWnd:AddChild(_right);
	else
		-- QUEST_STATUS_AVAILABLE  Quest is available to be taken by character
		
		local _details = ParaUI.CreateUIObject("container", "Details", "_lt", 0, 0, 300, 350);
		--_details.background = "";
		_DialogWnd:AddChild(_details);
		
		Quest_DetailsWnd.DetailPage(_details, NPC_id, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney);
		
		
		--local RewItemsText = RewItems[1].item_id .." ".. RewItems[1].item_count.."\n"..
							--RewItems[2].item_id .." ".. RewItems[2].item_count.."\n"..
							--RewItems[3].item_id .." ".. RewItems[3].item_count.."\n"..
							--RewItems[4].item_id .." ".. RewItems[4].item_count.."\n";
		--local _rewItems = ParaUI.CreateUIObject("text", "RewItemsText", "_lt", 20, 150, 260, 150);
		--_rewItems.text = RewItemsText;
		--_DialogWnd:AddChild(_rewItems);
		--
		--CRequiresText = CRequiresText.."RewOrReqMoney: "..RewOrReqMoney.."\n";
		--local _creqires = ParaUI.CreateUIObject("text", "RequiresText", "_lt", 20, 230, 260, 150);
		--_creqires.text = CRequiresText;
		--_DialogWnd:AddChild(_creqires);
		
		-- accept quest
		local _left = ParaUI.CreateUIObject("button", "Left", "_lb", 20, -42, 64, 32);
		_left.onclick = ";System.Quest.Client.QuestgiverAcceptQuest("..NPC_id..", "..quest_id..");ParaUI.Destroy(\"Quest_DetailsWnd\");";
		_left.text = "接受";
		_DialogWnd:AddChild(_left);
		
		local _right = ParaUI.CreateUIObject("button", "Right", "_rb", -84, -42, 64, 32);
		_right.onclick = ";System.Quest.Client.QuestgiverBye("..NPC_id..");";
		_right.text = "再见";
		_DialogWnd:AddChild(_right);
	end
	
	frame:SetText(Quest.GetCharNameFromID(NPC_id));
	
	frame:Show2(true);
end

function Quest_DetailsWnd.IncompletePage(_parent, NPC_id, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney)
	-- incomplete page have all parameters but the Objectives and Requires and RewOrReqMoney are all nil
	if(_parent:IsValid() == true) then
		CommonCtrl.DeleteControl("Quest_Incomplete"..quest_id);
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Quest_Incomplete"..quest_id);
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Quest_Incomplete"..quest_id,
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				parent = _parent,
				--container_bg = "",
				DefaultIndentation = 0,
				DefaultNodeHeight = 24,
				VerticalScrollBarStep = 24,
				VerticalScrollBarPageSize = 24 * 6,
				-- lxz: this prevent clipping text and renders faster
				NoClipping = false,
				HideVerticalScrollBar = false,
				DrawNodeHandler = function (_parent, treeNode)
					if(_parent == nil or treeNode == nil) then
						return;
					end
					
					local _title = ParaUI.CreateUIObject("text", "Title", "_lt", 10, 10, 260, 30);
					_title.text = Title;
					_title.font = System.DefaultLargeBoldFontString;
					_parent:AddChild(_title);
					
					local _details = ParaUI.CreateUIObject("text", "Details", "_lt", 10, 35, 260, 20);
					_details.text = Details;
					_parent:AddChild(_details);
					_details:DoAutoSize()
					local detailsHeight = _details.height;
					
					local Quest_Log = System.Quest.Client.Log;
					local Requires = Quest_Log[quest_id].Requires;
					
					local height = 35 + detailsHeight + 10;
					
					if(Requires[1].commandname == "Quest.Aquarius.Quiz") then
						--local questiondata = {["question"] = "1 + 1 = ?",
							 --["choices"] = {
							 --[1] = "1",
							 --[2] = "2",
							 --[3] = "0",
							 --[4] = "二",
							 --}
						--};
						--{["question"] = "1 + 1 = ?", ["choices"] = {[1] = "1",[2] = "2",[3] = "0",[4] = "二",}}
						
						local questiondata = commonlib.LoadTableFromString(Requires[1].questiondata);
						local question = questiondata;
						local _question = ParaUI.CreateUIObject("text", "Question", "_lt", 10, height, 260, 150);
						_question.text = question.question;
						_parent:AddChild(_question);
						_question:DoAutoSize()
						local questionHeight = _question.height;
						
						height = height + questionHeight + 10;
						local i, choice;
						for i, choice in pairs(question.choices) do
							local _btn = ParaUI.CreateUIObject("button", "Choice"..i, "_lt", 20, height, 260, 20);
							_btn.onclick = ";System.Quest.Client.QuestUpdateCRequire("..Requires[1].id..", ".."\""..choice.."\""..");";
							_parent:AddChild(_btn);
							local _choice = ParaUI.CreateUIObject("text", "text", "_lt", 30, height + 4, 240, 20);
							_choice.text = choice;
							_choice.enabled = false;
							_parent:AddChild(_choice);
							_choice:DoAutoSize();
							local choiceHeight = _choice.height;
							_btn.height = 4 + choiceHeight + 1;
							height = height + 4 + choiceHeight + 1;
						end
					elseif(Requires[1].commandname == "Quest.Aquarius.ChooseBestJoker") then
						--{["question"] = "你心目中的最好笑奖项是...?",
							 --["choices"] = {
							 --[1] = "选项1：报厅的吴伯",
							 --[2] = "选项2：义工阿旺",
							 --[3] = "选项3：巡逻警维德",
							 --[4] = "选项4：家具城的阿楠",
							 --}
						--}
						
						local questiondata = commonlib.LoadTableFromString(Requires[1].questiondata);
						local question = questiondata;
						local _question = ParaUI.CreateUIObject("text", "Question", "_lt", 10, height, 260, 150);
						_question.text = question.question;
						_parent:AddChild(_question);
						_question:DoAutoSize()
						local questionHeight = _question.height;
						
						height = height + questionHeight + 10;
						local i, choice;
						for i, choice in pairs(question.choices) do
							local _btn = ParaUI.CreateUIObject("button", "Choice"..i, "_lt", 20, height, 260, 20);
							_btn.onclick = ";System.Quest.Client.QuestUpdateCRequire("..Requires[1].id..", ".."\"MyBestJoker\""..");";
							_parent:AddChild(_btn);
							local _choice = ParaUI.CreateUIObject("text", "text", "_lt", 30, height + 4, 240, 20);
							_choice.text = choice;
							_choice.enabled = false;
							_parent:AddChild(_choice);
							_choice:DoAutoSize();
							local choiceHeight = _choice.height;
							_btn.height = 4 + choiceHeight + 1;
							height = height + 4 + choiceHeight + 1;
						end
					end
					
					treeNode.NodeHeight = height + 16;
				end,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
	end
end

function Quest_DetailsWnd.DetailPage(_parent, NPC_id, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney)
	if(_parent:IsValid() == true) then
		CommonCtrl.DeleteControl("Quest_Details"..quest_id);
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Quest_Details"..quest_id);
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Quest_Details"..quest_id,
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				parent = _parent,
				--container_bg = "",
				DefaultIndentation = 0,
				DefaultNodeHeight = 24,
				VerticalScrollBarStep = 24,
				VerticalScrollBarPageSize = 24 * 6,
				-- lxz: this prevent clipping text and renders faster
				NoClipping = false,
				HideVerticalScrollBar = false,
				DrawNodeHandler = function (_parent, treeNode)
					if(_parent == nil or treeNode == nil) then
						return;
					end
					local _title = ParaUI.CreateUIObject("text", "Title", "_lt", 10, 10, 260, 30);
					_title.text = Title;
					_title.font = System.DefaultLargeBoldFontString;
					_parent:AddChild(_title);
					
					local _details = ParaUI.CreateUIObject("text", "Details", "_lt", 10, 35, 260, 20);
					_details.text = Details;
					_parent:AddChild(_details);
					_details:DoAutoSize()
					local detailsHeight = _details.height;
					
					local _t = ParaUI.CreateUIObject("text", "text", "_lt", 10, 35 + detailsHeight + 10, 260, 20);
					_t.text = "任务目标";
					_t.font = System.DefaultLargeBoldFontString;
					_parent:AddChild(_t);
					
					local _objectives = ParaUI.CreateUIObject("text", "Objectives", "_lt", 10, 35 + detailsHeight + 35, 260, 20);
					_objectives.text = Objectives;
					_parent:AddChild(_objectives);
					_details:DoAutoSize()
					objectivesHeight = _objectives.height;
					
					local hasReward = false;
					local i, reward;
					for i, reward in ipairs(RewItems) do
						if(reward.item_id ~= 0) then
							hasReward = true;
							break;
						end
					end
					
					if(hasReward == true) then
						local _t = ParaUI.CreateUIObject("text", "text", "_lt", 10, 35 + detailsHeight + 35 + objectivesHeight + 10, 260, 20);
						_t.text = "奖励";
						_t.font = System.DefaultLargeBoldFontString;
						_parent:AddChild(_t);
						
						local _t = ParaUI.CreateUIObject("text", "text", "_lt", 10, 35 + detailsHeight + 35 + objectivesHeight + 35, 260, 20);
						_t.text = "你将可以创建:";
						_parent:AddChild(_t);
						
						--local CRequiresText = "";
						--local i, require;
						--for i, require in ipairs(Requires) do
							--
							--CRequiresText = CRequiresText..require.id.."\n"..require.app_key.."\n"..require.commandname.."\n"..require.questiondata.."\n\n";
						--end
						
						local i, reward;
						for i, reward in ipairs(RewItems) do
							if(reward.item_id ~= 0) then
								local bg = MyCompany.Aquarius.Quest.GetItemBackground(reward.item_id);
								local _icon = ParaUI.CreateUIObject("button", "item", "_lt", 56*(i-1) + 16, 35 + detailsHeight + 35 + objectivesHeight + 55, 48, 48);
								_icon.background = bg;
								_parent:AddChild(_icon);
							end
						end
						
						treeNode.NodeHeight = 35 + detailsHeight + 35 + objectivesHeight + 55 + 64;
					else
						treeNode.NodeHeight = 35 + detailsHeight + 35 + objectivesHeight + 15;
					end
				end,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
	end
end

-- on accept quest detail response
-- @param NPC_id: 
-- @param quest_id: 
function Quest_DetailsWnd.OnAcceptQuestResponse(NPC_id, quest_id)
	log("OnAcceptQuestResponse: NPC: "..NPC_id.." quest_id: "..quest_id.."\n");
end