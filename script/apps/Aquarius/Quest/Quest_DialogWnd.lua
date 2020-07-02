--[[
Title: Quest Dialog window
Author(s): WangTian
Date: 2008/12/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Quest/Quest_DialogWnd.lua");
MyCompany.Aquarius.Quest_DialogWnd.OnDialog(obj)
------------------------------------------------------------
]]

-- create class
local libName = "Quest_DialogWnd";
local Quest_DialogWnd = {};
commonlib.setfield("MyCompany.Aquarius.Quest_DialogWnd", Quest_DialogWnd);

local Quest = MyCompany.Aquarius.Quest;

-- called when the user trigger the ondialog command to talk to specific NPC
-- @param obj: the dialog target object 
function Quest_DialogWnd.OnDialog(obj)
	-- close quest list window first
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("QuestList");
	if(_wnd ~= nil) then
		_wnd:SendMessage(nil, {type = CommonCtrl.os.MSGTYPE.WM_CLOSE});
	end
	if(obj ~= nil and obj:IsCharacter()) then
		-- say hi to NPC
		local ID = Quest.GetIDFromCharName(obj.name);
		System.Quest.Client.QuestgiverHello(ID);
	end
end

-- @param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Quest_DialogWnd.Show(bShow)
	
end

-- on receive quest list of NPC
-- @param NPC_id: NPC id
-- @param gossiptext: gossip text
-- @param questlist: quest list
function Quest_DialogWnd.OnRecvQuestList(NPC_id, Title, MenuItems)
	-- hard code the PR logics here
	local FSM;
	
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
	
	ParaUI.Destroy("Quest_DialogWnd");
	
	--local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_DialogWnd", "_lt", 50, 150, 300, 400);
	--_DialogWnd.background = nil;
	--_DialogWnd:AttachToRoot();
	
	local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_DialogWnd", "_fi", 0, 0, 0, 0);
	_DialogWnd.background = "";
	_client:AddChild(_DialogWnd);
	
	local FSM = MyCompany.Aquarius.Quest_NPCStatus.FSMs[NPC_id];
	if(FSM ~= nil) then
		-- run the state machine
		FSM:Run();
	end
	if(_DialogWnd:IsValid() == true) then
		CommonCtrl.DeleteControl("Quest_Dialog"..NPC_id);
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Quest_Dialog"..NPC_id);
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Quest_Dialog"..NPC_id,
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				parent = _DialogWnd,
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
					
					local height = 20;
					
					local _title = ParaUI.CreateUIObject("text", "Title", "_lt", 20, height, 260, 30);
					_title.text = Title;
					_parent:AddChild(_title);
					_title:DoAutoSize();
					height = height + _title.height + 20;
					--local titleHeight = _title.height;
					
					if(FSM ~= nil) then
						
						local inputs = FSM:GetAcceptInputs();
						if(inputs == nil) then
							
						else
							local i, input;
							for i, input in pairs(inputs) do
								if(FSM.Inputs[input] ~= nil) then
									local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", 20, height, 260, 24);
									_btn.onclick = ";MyCompany.Aquarius.Quest_DialogWnd.FSM_Input("..NPC_id..", "..input..");";
									_parent:AddChild(_btn);
									local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 30, height, 24, 24);
									_icon.background = "Texture/Aquarius/Quest/Talk_32bits.png; 0 0 24 24";
									_btn.onclick = ";MyCompany.Aquarius.Quest_DialogWnd.FSM_Input("..NPC_id..", "..input..");";
									_parent:AddChild(_icon);
									local _questtitle = ParaUI.CreateUIObject("text", "Title", "_lt", 75, 5 + height, 200, 24);
									_questtitle.text = FSM.Inputs[input];
									_questtitle.enabled = false;
									_parent:AddChild(_questtitle);
									_questtitle:DoAutoSize();
									_btn.height = _questtitle.height + 4;
									height = height + _questtitle.height + 12;
								end
							end
						end
					end
					
					height = height + 12;
					
					-- TODO:
					local MenuItemCount;
					if(MenuItemCount == 1) then
						-- single quest, auto launch quest
						-- TODO: send quest items if DIALOG_STATUS_INCOMPLETE or DIALOG_STATUS_REWARD_REP
						-- TODO: send prepared quest details is quest avaiable and not explored
					else
						-- multiple quest
						-- TODO: send prepared quest list
					end
					
					local i, item;
					for i, item in ipairs(MenuItems) do
						--local height = 20 + titleHeight + 20 + 32*(i-1);
						if(item.status == 3) then
							-- QUEST_STATUS_INCOMPLETE  Quest is active in quest log but incomplete  
							local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", 20, height, 260, 24);
							_btn.onclick = ";System.Quest.Client.QuestgiverQueryQuest("..NPC_id..", "..item.quest_id..");ParaUI.Destroy(\"Quest_DialogWnd\");";
							_parent:AddChild(_btn);
							local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 30, height, 24, 24);
							_icon.background = "Texture/Aquarius/Quest/Question_Mark_Grey_32bits.png; 0 0 24 24";
							_icon.onclick = ";System.Quest.Client.QuestgiverQueryQuest("..NPC_id..", "..item.quest_id..");ParaUI.Destroy(\"Quest_DialogWnd\");";
							_parent:AddChild(_icon);
							local _questtitle = ParaUI.CreateUIObject("text", "Title", "_lt", 75, 5 + height, 200, 24);
							_questtitle.text = item.title;
							_questtitle.enabled = false;
							_parent:AddChild(_questtitle);
						elseif(item.status == 1) then
							-- QUEST_STATUS_COMPLETE  Quest objectives are completed, player waiting for reward
							local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", 20, height, 260, 24);
							_btn.onclick = ";System.Quest.Client.QuestgiverQueryQuest("..NPC_id..", "..item.quest_id..");ParaUI.Destroy(\"Quest_DialogWnd\");";
							_parent:AddChild(_btn);
							local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 30, height, 24, 24);
							_icon.background = "Texture/Aquarius/Quest/Question_Mark_32bits.png; 0 0 24 24";
							_icon.onclick = ";System.Quest.Client.QuestgiverQueryQuest("..NPC_id..", "..item.quest_id..");ParaUI.Destroy(\"Quest_DialogWnd\");";
							_parent:AddChild(_icon);
							local _questtitle = ParaUI.CreateUIObject("text", "Title", "_lt", 75, 5 + height, 200, 24);
							_questtitle.text = item.title;
							_questtitle.enabled = false;
							_parent:AddChild(_questtitle);
						elseif(item.status == 4) then
							-- QUEST_STATUS_AVAILABLE  Quest is available to be taken by character
							local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", 20, height, 260, 24);
							_btn.onclick = ";System.Quest.Client.QuestgiverQueryQuest("..NPC_id..", "..item.quest_id..");ParaUI.Destroy(\"Quest_DialogWnd\");";
							_parent:AddChild(_btn);
							local _icon = ParaUI.CreateUIObject("button", "title", "_lt", 30, height, 24, 24);
							_icon.background = "Texture/Aquarius/Quest/Excalmatory_Mark_32bits.png; 0 0 24 24";
							_icon.onclick = ";System.Quest.Client.QuestgiverQueryQuest("..NPC_id..", "..item.quest_id..");ParaUI.Destroy(\"Quest_DialogWnd\");";
							_parent:AddChild(_icon);
							local _questtitle = ParaUI.CreateUIObject("text", "Title", "_lt", 75, 5 + height, 200, 24);
							_questtitle.text = item.title;
							_questtitle.enabled = false;
							_parent:AddChild(_questtitle);
						end
						height = height + 32;
					end
					
					treeNode.NodeHeight = height + 12;
				end,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
	end
	
	---- accept quest
	--local _left = ParaUI.CreateUIObject("button", "Left", "_lb", 20, -52, 64, 32);
	--_left.onclick = "";
	--_left.text = "Accept";
	--_DialogWnd:AddChild(_left);
	
	local _right = ParaUI.CreateUIObject("button", "Right", "_rb", -84, -52, 64, 32);
	_right.onclick = ";System.Quest.Client.QuestgiverBye("..NPC_id..");";
	_right.text = "再见";
	_DialogWnd:AddChild(_right);
	
	frame:SetText(Quest.GetCharNameFromID(NPC_id));
	
	frame:Show2(true);
end

-- on quest complete
-- @param questentry: questentry
function Quest_DialogWnd.OnQuestComplete(quest_id, XP, RewOrReqMoney, RewItems)
	log("OnQuestComplete(): "..quest_id.."\n");
end


-- on show quest detail
-- @param questentry: questentry
function Quest_DialogWnd.OnShowQuestDetail(questentry)
	log("OnShowQuestDetail(): "..questentry.."\n");
	
end

-- on accept quest
-- @param questentry: questentry
function Quest_DialogWnd.OnAcceptQuest(questentry)
	log("OnAcceptQuest(): "..questentry.."\n");
end

-- accept the input according to the deterministic finite state machine
function Quest_DialogWnd.FSM_Input(NPC_id, input)
	--commonlib.echo({NPC_id, input});
	local FSM = MyCompany.Aquarius.Quest_NPCStatus.FSMs[NPC_id];
	if(FSM ~= nil) then
		FSM:Input(input);
	end
end

-- show the deterministic finite state machine dialog
-- currently we only shows the dialog locally and we need further implementation to store the dialog session and states on server
-- client side only implement the visualization of the dialog text and status
function Quest_DialogWnd.ShowFSMDialog(NPC_id, state)
	local FSM = MyCompany.Aquarius.Quest_NPCStatus.FSMs[NPC_id];
	if(FSM == nil) then
		return;
	end
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
	
	ParaUI.Destroy("Quest_DialogWnd");
	
	local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_DialogWnd", "_fi", 0, 0, 0, 0);
	_DialogWnd.background = "";
	_client:AddChild(_DialogWnd);
	
	
	if(_DialogWnd:IsValid() == true) then
		CommonCtrl.DeleteControl("Quest_Dialog_FSM");
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Quest_Dialog_FSM");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Quest_Dialog_FSM",
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				parent = _DialogWnd,
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
					
					local height = 20;
					
					local _title = ParaUI.CreateUIObject("text", "Title", "_lt", 20, height, 260, 30);
					_title.text = FSM.States[state].desc;
					_parent:AddChild(_title);
					_title:DoAutoSize();
					height = height + _title.height + 20;
					--local titleHeight = _title.height;
					
					if(FSM ~= nil) then
						
						local inputs = FSM:GetAcceptInputs(state);
						if(inputs == nil) then
							
						else
							local i, input;
							for i, input in pairs(inputs) do
								local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", 20, height, 260, 24);
								_btn.onclick = ";MyCompany.Aquarius.Quest_DialogWnd.FSM_Input("..NPC_id..", "..input..");";
								_parent:AddChild(_btn);
								local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 30, height, 24, 24);
								_icon.background = "Texture/Aquarius/Quest/Talk_32bits.png; 0 0 24 24";
								_btn.onclick = ";MyCompany.Aquarius.Quest_DialogWnd.FSM_Input("..NPC_id..", "..input..");";
								_parent:AddChild(_icon);
								local _questtitle = ParaUI.CreateUIObject("text", "Title", "_lt", 75, 5 + height, 200, 24);
								_questtitle.text = FSM.Inputs[input];
								_questtitle.enabled = false;
								_parent:AddChild(_questtitle);
								_questtitle:DoAutoSize();
								_btn.height = _questtitle.height + 4;
								height = height + _questtitle.height + 12;
							end
						end
					end
					
					treeNode.NodeHeight = height + 12;
				end,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
	end
	
	local _right = ParaUI.CreateUIObject("button", "Right", "_rb", -84, -52, 64, 32);
	_right.onclick = ";System.Quest.Client.QuestgiverBye("..NPC_id..");";
	_right.text = "再见";
	_DialogWnd:AddChild(_right);
	
	frame:SetText(Quest.GetCharNameFromID(NPC_id));
	
	frame:Show2(true);
end

function Quest_DialogWnd.CloseFSMDialog()
end

