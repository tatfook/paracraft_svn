--[[
Title: Quest complete window
Author(s): WangTian
Date: 2008/12/13
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Quest/Quest_CompleteWnd.lua");
MyCompany.Aquarius.Quest_CompleteWnd.OnDetails(obj)
------------------------------------------------------------
]]

-- create class
local libName = "Quest_CompleteWnd";
local Quest_CompleteWnd = {};
commonlib.setfield("MyCompany.Aquarius.Quest_CompleteWnd", Quest_CompleteWnd);

local Quest = MyCompany.Aquarius.Quest;

-- on receive quest offer rewards
-- @param NPC_id: NPC id
-- @param gossiptext: gossip text
-- @param questlist: quest list
function Quest_CompleteWnd.OnOfferReward(NPC_id, quest_id, Title, OfferRewardText, Rewards)
	
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
	
	ParaUI.Destroy("Quest_CompleteWnd");
	
	-- secretly destroy the Quest_DetailsWnd window, 
	-- this is useful when user directly answer the CReq from the window it will make a switch to the offer window without saying "Hi" to NPC
	ParaUI.Destroy("Quest_DetailsWnd");
	
	
	--local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_CompleteWnd", "_lt", 50, 150, 300, 400);
	--_DialogWnd.background = nil;
	--_DialogWnd:AttachToRoot();
	
	local _DialogWnd = ParaUI.CreateUIObject("container", "Quest_CompleteWnd", "_fi", 0, 0, 0, 0);
	_DialogWnd.background = nil;
	_client:AddChild(_DialogWnd);
	
	
	local _details = ParaUI.CreateUIObject("container", "Details", "_lt", 0, 0, 300, 350);
	--_details.background = "";
	_DialogWnd:AddChild(_details);
	
	Quest_CompleteWnd.CompletePage(_details, NPC_id, quest_id, Title, OfferRewardText, Rewards);
	
	
	
	--
	--CReqiresText = CReqiresText.."RewOrReqMoney: "..RewOrReqMoney.."\n";
	--local _creqires = ParaUI.CreateUIObject("text", "CReqiresText", "_lt", 20, 230, 260, 150);
	--_creqires.text = CReqiresText;
	--_DialogWnd:AddChild(_creqires);
	
	-- accept quest
	local _left = ParaUI.CreateUIObject("button", "Left", "_lb", 20, -42, 64, 32);
	_left.onclick = ";MyCompany.Aquarius.Quest_CompleteWnd.GetReward("..quest_id..");System.Quest.Client.QuestgiverCompleteQuest("..NPC_id..", "..quest_id..");ParaUI.Destroy(\"Quest_CompleteWnd\");";
	_left.text = "完成";
	_DialogWnd:AddChild(_left);
	
	local _right = ParaUI.CreateUIObject("button", "Right", "_rb", -84, -42, 64, 32);
	_right.onclick = ";System.Quest.Client.QuestgiverBye("..NPC_id..");";
	_right.text = "再见";
	_DialogWnd:AddChild(_right);
	
	frame:SetText(Quest.GetCharNameFromID(NPC_id));
	
	frame:Show2(true);
end

function Quest_CompleteWnd.GetReward(quest_id)
	-- skip the quest system to get local rewards
	-- TODO: get item from quest server and item system
	
	local quest = System.Quest.Client.Log[quest_id];
	if(quest == nil) then
		return;
	end
	
	local RewItems = quest.RewItems;
	if(RewItems[1].item_id == 0) then
		return;
	end
	
	MyCompany.Aquarius.Desktop.Dock.ShowNotification(function (_parent)
		if(_parent == nil or _parent:IsValid() == false) then
			return;
		end
		
		local _notify = ParaUI.CreateUIObject("container", "items", "_lt", 0, 0, 200, 128);
		_notify.background = "";
		_parent:AddChild(_notify);
		
		local _text = ParaUI.CreateUIObject("button", "text", "_ctt", 0, 30, 180, 20);
		_text.background = "";
		_text.text = "你学会了创造:";
		_text.enabled = false;
		_notify:AddChild(_text);
		
		local _items = ParaUI.CreateUIObject("container", "items", "_ctt", 0, 60, 0, 32);
		_items.background = "";
		_notify:AddChild(_items);
		
		if(RewItems[1].item_id ~= 0) then
			local id = RewItems[1].item_id;
			MyCompany.Aquarius.Quest.UnlockItem(id);
			local _item = ParaUI.CreateUIObject("container", "item", "_lt", 8, 0, 32, 32);
			_item.background = MyCompany.Aquarius.Quest.GetItemBackground(id);
			_items:AddChild(_item);
			_items.width = 8 + 32 + 8;
		end
		if(RewItems[2].item_id ~= 0) then
			local id = RewItems[2].item_id;
			MyCompany.Aquarius.Quest.UnlockItem(id);
			local _item = ParaUI.CreateUIObject("container", "item", "_lt", 8 + 32 + 8, 0, 32, 32);
			_item.background = MyCompany.Aquarius.Quest.GetItemBackground(id);
			_items:AddChild(_item);
			_items.width = 8 + 32 + 8 + 32 + 8;
		end
		if(RewItems[3].item_id ~= 0) then
			local id = RewItems[3].item_id;
			MyCompany.Aquarius.Quest.UnlockItem(id);
			local _item = ParaUI.CreateUIObject("container", "item", "_lt", 8 + 32 + 8 + 32 + 8, 0, 32, 32);
			_item.background = MyCompany.Aquarius.Quest.GetItemBackground(id);
			_items:AddChild(_item);
			_items.width = 8 + 32 + 8 + 32 + 8 + 32 + 8;
		end
		if(RewItems[4].item_id ~= 0) then
			local id = RewItems[4].item_id;
			MyCompany.Aquarius.Quest.UnlockItem(id);
			local _item = ParaUI.CreateUIObject("container", "item", "_lt", 8 + 32 + 8 + 32 + 8 + 32 + 8, 0, 32, 32);
			_item.background = MyCompany.Aquarius.Quest.GetItemBackground(id);
			_items:AddChild(_item);
			_items.width = 8 + 32 + 8 + 32 + 8 + 32 + 8 + 32 + 8;
		end
	end);
end


function Quest_CompleteWnd.CompletePage(_parent, NPC_id, quest_id, Title, OfferRewardText, Rewards)
	if(_parent:IsValid() == true) then
		CommonCtrl.DeleteControl("Quest_Complete"..quest_id);
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Quest_Complete"..quest_id);
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Quest_Complete"..quest_id,
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
					
					local _offerRewardText = ParaUI.CreateUIObject("text", "Details", "_lt", 10, 35, 260, 20);
					_offerRewardText.text = OfferRewardText;
					_parent:AddChild(_offerRewardText);
					_offerRewardText:DoAutoSize()
					local detailsHeight = _offerRewardText.height;
					
					local hasReward = false;
					local i, reward;
					for i, reward in ipairs(Rewards.RewItems) do
						if(reward.item_id ~= 0) then
							hasReward = true;
							break;
						end
					end
					
					if(hasReward == true) then
						local _t = ParaUI.CreateUIObject("text", "text", "_lt", 10, 35 + detailsHeight + 10, 260, 20);
						_t.text = "奖励";
						_t.font = System.DefaultLargeBoldFontString;
						_parent:AddChild(_t);
						
						local _t = ParaUI.CreateUIObject("text", "text", "_lt", 10, 35 + detailsHeight + 35, 260, 20);
						_t.text = "你将可以创建:";
						_parent:AddChild(_t);
						
						--local CRequiresText = "";
						--local i, require;
						--for i, require in ipairs(Requires) do
							--
							--CRequiresText = CRequiresText..require.id.."\n"..require.app_key.."\n"..require.commandname.."\n"..require.questiondata.."\n\n";
						--end
						
						local i, reward;
						for i, reward in ipairs(Rewards.RewItems) do
							if(reward.item_id ~= 0) then
								local bg = MyCompany.Aquarius.Quest.GetItemBackground(reward.item_id);
								
								local _icon = ParaUI.CreateUIObject("button", "item", "_lt", 56*(i-1) + 16, 35 + detailsHeight + 55, 48, 48);
								_icon.background = bg;
								_parent:AddChild(_icon);
							end
						end
						treeNode.NodeHeight = 35 + detailsHeight + 55 + 64;
					else
						treeNode.NodeHeight = 35 + detailsHeight + 15;
					end
				end,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
	end
end