--[[
Title: Per Quest function. Code behind page for QuestDetailFramePage.html
Author(s): Leio
Date: 2010/12/8
Desc: By LiXizhi: move code from html file to this code file to prevent duplicate code compile time. 
use the lib:
------------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local QuestDetailFramePage = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailFramePage");

NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

NPL.load("(gl)script/apps/Aries/Quest/QuestDetailPage.lua");
local QuestDetailPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPage");

NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");

NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");

NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");
local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");

NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
local QuestDetailPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPage");

local quest_arrowtip_str = [[<pe:arrowpointer name="quest_tip" direction="1" style="float:left;position:relative;margin-left:10px;margin-top:-45px;width:32px;height:32px;"/>]]

-- tricky By LiXizhi:
-- here we just secretly change the function environment, so that all global functions and variables defined inside 
-- this function will actually be defined in the same code scope as the calling page. 
function QuestDetailFramePage.OnInit()
-- very tricky here: after this function, we will set calling function's environment as this function's environment, 
-- so that everything defined afterwards will be as if from the calling function. 
setfenv(1, getfenv(2));
---------------------------------
-- begin page code
---------------------------------

local provider = QuestClientLogics.GetProvider();
local pageCtrl = document:GetPageCtrl();
local id = pageCtrl:GetRequestParam("id");
local isdebug = pageCtrl:GetRequestParam("debug");
local showbutton = pageCtrl:GetRequestParam("showbutton");
id = tonumber(id) or 0;
showbutton = tonumber(showbutton) or -1;--0 accept btn,1 finished btn
isdebug = tonumber(isdebug) or 0;
local nid = System.User.nid;
local templates;
local template = {};
if(provider)then
    templates = provider:GetTemplateQuests();
    if(templates)then
        template = templates[id];
    end
end
function ShowAcceptBtn()
    if(showbutton and showbutton == 0)then
        return true;
    end
end
function ShowFinishedBtn()
    if(showbutton and showbutton == 1)then
        return true;
    end
end
function ShowInQuestList()
    if(not ShowAcceptBtn() and not ShowFinishedBtn() )then
        return true;
    end
end
function ClosePage()
   QuestDetailPage.ClosePage();
    QuestListPage.ClosePage();
end
local msg = {
	nid = nid,
	id = id,
}
function canAccept()
    return QuestClientLogics.CanAccept(msg);
end
function hasAccept()
    return QuestClientLogics.HasAccept(msg);
end
function hasDropped()
    return QuestClientLogics.HasDropped(msg);
end
function canFinished()
    return QuestClientLogics.CanFinished(msg);
end
function hasFinished()
    return QuestClientLogics.HasFinished(msg);
end
function canDelete()
    return QuestClientLogics.CanDelete(msg);
end
function doAccept()
    local b = QuestClientLogics.HasAccept(msg);
    if(b)then
        _guihelper.MessageBox("已经接受"..id);
        return;
    end
    local b = QuestClientLogics.HasFinished(msg);
    if(b)then
        _guihelper.MessageBox("已经完成"..id);
        return;
    end
    local b = QuestClientLogics.CanAccept(msg);
    if(not b)then
        _guihelper.MessageBox("不能接受"..id);
        return;
    end
   QuestClientLogics.TryAccept(msg);
   ClosePage();
   return true;
end
function getRewardSelectedIndex()
    local v, values = pageCtrl:GetValue("reward_group");
    return values or {v};
end

function doDrop()
    _guihelper.Custom_MessageBox("你确认要放弃这个任务吗？",function(result)
	    if(result == _guihelper.DialogResult.Yes)then
	        local msg = {
	            nid = nid,
	            id = id,
            }
            local b = QuestClientLogics.CanDelete(msg);
            if(not b)then
                _guihelper.MessageBox("不能删除"..id);
                return;
            end
            QuestClientLogics.TryDrop(msg);
           ClosePage();
        else
	    end
    end,_guihelper.MessageBoxButtons.YesNo);
     
end
function doReAccept()
    _guihelper.Custom_MessageBox("你确认要恢复这个任务吗？",function(result)
	    if(result == _guihelper.DialogResult.Yes)then
	        local msg = {
	            nid = nid,
	            id = id,
            }
           
            QuestClientLogics.TryReAccept(msg);
           ClosePage();
        else
	    end
    end,_guihelper.MessageBoxButtons.YesNo);
     
end
function doKill()
   QuestClientLogics.Test_Kill();
end
function getID()
    return id;
end
function HasTimeStamp()
    return QuestHelp.HasTimeStamp(getID());
end
function getTimeStamp()
    return QuestHelp.GetTimeStampString(getID());
end
function getInfo(key)
    if(template and key)then
        local v = template[key];
        if(key == "Goal" or key == "GoalItem" or key == "RequestAttr" or key == "RequestQuest" or key == "Reward")then
            v = commonlib.serialize_compact(v);
            return v;
        else
            return v;
        end
    end
end
function getUserRequestAttr()
    if(provider and template)then
        local t = provider:GetUserRequestAttr(template.RequestAttr);
        t = commonlib.serialize_compact(t);
        return t;
    end
end
function getUserGoal()
    if(provider and template)then
        local q_item = provider:GetQuest(id);
        if(q_item)then
            return commonlib.serialize_compact(q_item.Cur_Goal);
        end
    end
end
function getUserGoalItem()
    if(provider and template)then
        local q_item = provider:GetQuest(id);
        if(q_item)then
            return commonlib.serialize_compact(q_item.Cur_GoalItem);
        end
    end
end
function getRequestQuest()
    local provider = QuestClientLogics.GetProvider();
    local templates = provider:GetTemplateQuests();
    if(templates)then
        local template = templates[id];
        if(template)then
            local str = "";
            --前置条件
            local str_attr = nil;
            --前置任务
            local str_quest = nil;

            local RequestAttr = template.RequestAttr;
            if(RequestAttr)then
                local len = #RequestAttr;
                
                if(len > 0)then
                 local k,v;
                    for k,v in ipairs(RequestAttr)do
                        local id = v.id;
                        local value = v.value;
                        id = tonumber(id)
                        value = tonumber(value) or 0
                        if(id == 214)then
                            --目前前置条件只判断 等级
                           if(v.topvalue)then
							local topvalue = tonumber(v.topvalue);
								str_attr = string.format("%d-%d级",value,topvalue);
							else
								str_attr = string.format("%d级",value);
							end
                            break;
                        end
                    end
                end
            end
            local RequestQuest = template.RequestQuest;
            if(RequestQuest)then
                local len = #RequestQuest;
                local __,map = QuestHelp.GetAttrList();
                if(len > 0)then
                 local k,v;
                    for k,v in ipairs(RequestQuest)do
                        local id = v.id;
                        local value = v.value;
                        id = tonumber(id)
                        value = tonumber(value) or 0

                        local pre_template = templates[id];
                        if(pre_template)then
                            --目前前置任务 只判断一个
                            str_quest = string.format("完成%s任务",pre_template.Title or "");
                            break;
                        end
                    end
                end
            end
            local state = provider:GetState(id);
            if(str_attr and str_quest)then
                str = string.format("战斗等级%s %s",str_attr,str_quest);
            elseif(str_attr)then
                str = string.format("战斗等级%s",str_attr);
            elseif(str_quest)then
                str = string.format("%s",str_quest);
            end
            if(state == 9)then
                str = string.format([[<div style="color:#ff0000;float:left">%s</div>]],str);
            end
            return str;
        end
    end
end
function isDebug()
   
    if(isdebug == 0)then
        return false;
    end
    return true;
end

function tableHasValue(key)
     if(template)then
        local v = template[key];
        if(v)then
            local len = #v;
            if(len > 0)then
                return true;
            end
        end
    end
end
function hasValidData()
    if(template)then
        local v = template["ValidDate"];
        v = tonumber(v);
        if(v and v > 0)then
            return true;
        end
    end
end
function hasReward()
     if(template)then
        local v = template["Reward"];
        if(v and v[1])then
            local len = #v[1];
            if(len > 0)then
                return true;
            end
        end
    end
end
--index:0 自动发放 1 手动选择
function hasReward_state(index)
     if(template and index)then
        index = index + 1;
        local v = template["Reward"];
        if(v and v[index])then
            local len = #v[index];
            if(len > 0)then
                return true;
            end
        end
    end
end
function getReward_0()
     if(template)then
        local __,map = QuestHelp.GetRewardList();
        local v = template["Reward"];
        if(v and v[1] and map)then
            local info = "";
            local list = v[1];
            local k,v;
            for k,v in ipairs(list) do
                local id = v.id;
                local value = v.value;
                local label = "";
                local item = map[id];
                if(item)then
                    label = item.label;
                end
                local s = string.format([[<div style="float:left">%s:%d</div>]],label,value);
                info = info .. s;
            end
            info = string.format([[<b>任务奖励：</b>%s]],info);
            return info;
        end
    end
end
--额外奖励是否 全部自动选中
function getReward_1_isAllAutoChecked()
     if(template)then
        local v = template["Reward"];
        if(v and v[2])then
            local info = "";
            local list = v[2];
            local choice = list.choice or 0;
            local k,v;
            local len = #list;
            if(choice >= len)then
                return true;
            end
        end
    end
end
function __doFinished()
    local reward_index_list;
    if(hasReward_state(1))then
        local allChecked= getReward_1_isAllAutoChecked();
        if(template)then
            local v = template["Reward"];
            if(v and v[2])then
                local list = v[2];
                local choice = list.choice or 0;
                if(allChecked)then
                    reward_index_list = {};
                    local len = #list;
                    local k;
                    for k =1 ,len do
                        table.insert(reward_index_list,k);
                    end
                else
                    reward_index_list = getRewardSelectedIndex() or {};
                    local len = #reward_index_list;
                    if(len ~= choice)then
                        _guihelper.MessageBox("请选择你的奖励！");
                        return;
                    end
                end
                    
            end
        end
    end
     local msg = {
	    nid = nid,
	    id = id,
        reward_index_list = reward_index_list,
    }
    local b = QuestClientLogics.CanFinished(msg);
    if(not b)then
        _guihelper.MessageBox("不能完成任务！");
        return;
    end
   QuestClientLogics.TryFinished(msg);
   ClosePage();
   return true;
end


function GetQuestID()
    return id;
end
function getReward_1()
     if(template)then
        local __,map = QuestHelp.GetRewardList();
        local v = template["Reward"];
        if(v and v[2] and map)then
            local info = "";
            local list = v[2];
            local choice = list.choice or 0;
            local k,v;
            local len = #list;
            local allChecked="false";
            if(choice >= len)then
                allChecked = "true";
            end
            for k,v in ipairs(list) do
                local id = v.id;
                local value = v.value;
                local label = "";
                local item = map[id];
                if(item)then
                    label = item.label;
                end
                local checked = allChecked;
                local s;
                local width = 36;
                local height = 36;
                local path;
                local gsItem = ItemManager.GetGlobalStoreItemInMemory(id);
                local img = "";
                if(gsItem) then
					local isCard = false;
					if(id >= 22101 and id <= 22999) then
						isCard = true;
					elseif(id >= 41101 and id <= 41999) then
						isCard = true;
					elseif(id >= 42101 and id <= 42999) then
						isCard = true;
					elseif(id >= 43101 and id <= 43999) then
						isCard = true;
					elseif(id >= 44101 and id <= 44999) then
						isCard = true;
					end
                    if(isCard) then
                       path = string.format("%s;0 0 45 44",gsItem.descfile);
                        img = string.format([[<pe:item gsid="%d" icon="%s" isclickable="false" showdefaulttooltip="true" style="float:left;width:%dpx;height:%dpx;"/>]],id,path,width,height);
                    else
                       path = gsItem.icon;
                       img = string.format([[<pe:item gsid="%d" isclickable="false" showdefaulttooltip="true" style="float:left;width:%dpx;height:%dpx;"/>]],id,width,height);

                    end
                end
                path = path or "Texture/alphadot.png";
                --local img = string.format([[<img src="%s" tooltip= "%s" style="float:left;width:%dpx;height:%dpx;"/>]],path,label,width,height);
                if(canFinished() and not ShowInQuestList() )then
                    if(allChecked == "true")then
                        local item_str = string.format([[<div style="float:left;">%s<div style="float:left;margin-left:2px;margin-top:15px;">x%d</div></div>]],img,value);
                        s = string.format([[<div>%s</div><br/>]],item_str);
                    else
                        local item_str = string.format([[<div style="float:left;">%s<div style="float:left;margin-left:2px;margin-top:15px;">x%d</div></div>]],img,value);
                        s = string.format([[<div>%s<input style="float:left;margin-left:2px;margin-top:15px;" type="radio" name="reward_group" max="%d" value="%d" checked="%s"/></div><br/>]],item_str,choice,k,checked);
                    end
                else
                    s = string.format([[<div style="float:left;">%s<div style="float:left;margin-left:2px;margin-top:15px;">x%d</div></div>]],img,value);
                end
                info = info .. s;
            end
            if(allChecked == "true")then
                info = string.format([[<b>你还可以得到：</b><br/>%s]],info);
            else
                info = string.format([[<b>你还可以选择其中%d项：</b><br/>%s]],choice or 0,info);
            end
            return info;
        end
    end
end

function goalProgress(key)
    if(not key)then return end
    if(template)then
        local q_item = provider:GetQuest(id);
        local req_p = template[key];
        if(req_p)then
            local cur_p;
            if(q_item  and key == "Goal")then
                cur_p = q_item.Cur_Goal;
            elseif(q_item  and key == "GoalItem")then
                cur_p = q_item.Cur_GoalItem;
              
            elseif(q_item  and key == "ClientGoalItem")then
                cur_p = q_item.Cur_ClientGoalItem;
            elseif(q_item  and key == "ClientExchangeItem")then
                cur_p = q_item.Cur_ClientExchangeItem;
            elseif(q_item  and key == "FlashGame")then
                cur_p = q_item.Cur_FlashGame;
            elseif(q_item  and key == "ClientDialogNPC")then
                cur_p = q_item.Cur_ClientDialogNPC;
              elseif(q_item  and key == "CustomGoal")then
                cur_p = q_item.Cur_CustomGoal;
            elseif(key == "RequestAttr")then
                 cur_p = provider:GetUserRequestAttr(template.RequestAttr);
            end
            local condition = req_p.condition;
            local result = { condition = condition };
            local k,v;
            for k,v in ipairs(req_p) do
                local id = v.id;
                local value = v.value;
                local producer_id = v.producer_id;
                --任务还没有接取
                if(not cur_p or q_item.QuestState == 5)then
					local cur_value = 0;
					if(id == 20046 or id == 20048)then
						cur_value = cur_value + 1000;
						value = value + 1000;
					end
                    local item = { id = id, cur_value = cur_value, req_value = value, producer_id = producer_id,};
                    table.insert(result,item);    
                else
                    local kk,vv;
                    for kk,vv in ipairs(cur_p) do
                        local cur_id = vv.id;
                        local cur_value = vv.value;
                        if(id == cur_id)then
							if(id == 20046 or id == 20048)then
								cur_value = cur_value + 1000;
								value = value + 1000;
							end
                            local item = { id = id, cur_value = cur_value, req_value = value, producer_id = producer_id,};
                            table.insert(result,item);    
                        end
                    end                
                end
            end
            return result;
        end
    end
end
function ShowInQuestList()
    if(not ShowAcceptBtn() and not ShowFinishedBtn() )then
        return true;
    end
end

local bCanShowAutoTip;
local bean = Pet.GetBean();
local has_accepted = hasAccept();
-- we will always show the autotips until user is above level 5
if(bean and bean.combatlel <= 20) then
	bCanShowAutoTip = true;
end

-- @param bIncludeUnaccepted: true to include unaccepted but acceptable task
function CanShowAutoTip(bIncludeUnaccepted)
	if(bIncludeUnaccepted) then
		return bCanShowAutoTip;
	else
		return bCanShowAutoTip and has_accepted;
	end
end

function canShowGotoBtn()
    if(ShowInQuestList())then
    --if(bean and bean.combatlel <=10 and ShowInQuestList())then
        return true;
    end
end
function do_help_func(func_str)
	if(func_str)then
		NPL.DoString(func_str);
		if(pageCtrl)then
			pageCtrl:CloseWindow();
		end
	end
	--if(func_str)then
		--local func = commonlib.getfield(func_str);
		--if(func)then
			--func();
		--end
	--end
end
function has_help_func(key,map,id)
	if(key and map and id)then
		if(key == "StartNPC" or key == "EndNPC" or key == "ClientDialogNPC" or key == "ClientExchangeItem")then
			return false;
		else
			local item = map[id];
			if(item)then
				local helpfunction = item.helpfunction;
				if(helpfunction and helpfunction ~= "")then
					return true,helpfunction;
				end
			end
		end
	end
end
function has_pos(key,map,id)
	if(key and map and id)then
		if(key == "StartNPC" or key == "EndNPC" or key == "ClientDialogNPC" or key == "ClientExchangeItem")then
			local npc, __, npc_data = NPCList.GetNPCByIDAllWorlds(id);
			local end_pos = npc.position;
			if(end_pos)then
				return true;
			end
		else
			local item = map[id];
			if(item)then
				local position = item.position;
				if(position and position ~= "")then
					return true;
				end
			end
		end
	end
end
function HasGoal()
    return QuestHelp.HasGoal(id)
end
function goalProgressInfo(key)
    if(not key)then return end
    local result = goalProgress(key);
    if(result)then
        local condition = result.condition or 0;
        local condition_info="";
        local info="";
        if(condition == 0)then
            --condition_info="同时";
            condition_info="";
        else
            --condition_info="或者";
            condition_info="";
        end
        if(key == "Goal")then
            local __,map = QuestHelp.GetGoalList()
            local k,v;
			local bHasTipHelper;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                local mobid = v.id;
                local bShow = canShowGotoBtn();
                local goto_str = "";
				local has_pos = has_pos(key,map,v.id);
				local b_has_help_func,func_str = has_help_func(key,map,v.id);
                if(bShow and has_pos)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_mob" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
					if( CanShowAutoTip() and not bHasTipHelper and (v.cur_value or 0) < (v.req_value or 0)) then
						-- added by Xizhi: to display a helper indicator. 
						bHasTipHelper = true;
						goto_str = goto_str..quest_arrowtip_str;
					end
                elseif(bShow and b_has_help_func)then
					goto_str = string.format([[<input type="button" name="%s" onclick="do_help_func" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],func_str or "");
                end

				local s = string.format([[<div>消灭【%s】(%d/%d)%s</div>]],label,v.cur_value or 0,v.req_value or 0,goto_str);
				info = info .. s;
            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
        elseif(key == "GoalItem")then
            local __,map = QuestHelp.GetQuestItemList();
            local k,v;
			local bHasTipHelper;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                local mobid = v.producer_id or 0;
                local bShow = canShowGotoBtn();
                local goto_str = "";
				local __,temp_map = QuestHelp.GetGoalList();
				local has_pos = has_pos(key,temp_map,mobid);
				local b_has_help_func,func_str = has_help_func(key,temp_map,mobid);
                if(bShow and has_pos)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_mob" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
					if( CanShowAutoTip() and not bHasTipHelper and (v.cur_value or 0) < (v.req_value or 0)) then
						-- added by Xizhi: to display a helper indicator. 
						bHasTipHelper = true;
						goto_str = goto_str..quest_arrowtip_str;
					end
                elseif(bShow and b_has_help_func)then
					goto_str = string.format([[<input type="button" name="%s" onclick="do_help_func" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],func_str or "");
                end
				
				local s = string.format([[<div>找回【%s】(%d/%d)%s</div>]],label,v.cur_value or 0,v.req_value or 0,goto_str);
                --local s = string.format([[<div>找回%d个【%s】(%d/%d)%s</div>]],v.req_value or 0,label,v.cur_value or 0,v.req_value or 0,goto_str);
                info = info .. s;
            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
        elseif(key == "ClientGoalItem")then
            local __,map = QuestHelp.GetClientItemList();
            local k,v;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                --local s = string.format([[<div>收集%d个【%s】(%d/%d)</div><br/>]],v.req_value or 0,label,v.cur_value or 0,v.req_value or 0);
                --info = info .. s;
				local mobid = v.id;
                local bShow = canShowGotoBtn();
                local goto_str = "";
				local has_pos = has_pos(key,map,v.id);
				local b_has_help_func,func_str = has_help_func(key,map,v.id);
                if(bShow and has_pos)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_client_goal_item" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
					if( CanShowAutoTip() and not bHasTipHelper and (v.cur_value or 0) < (v.req_value or 0)) then
						-- added by Xizhi: to display a helper indicator. 
						bHasTipHelper = true;
						goto_str = goto_str..quest_arrowtip_str;
					end
                elseif(bShow and b_has_help_func)then
					goto_str = string.format([[<input type="button" name="%s" onclick="do_help_func" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],func_str or "");
                end
				local s = string.format([[<div>收集【%s】%d个(%d/%d)%s</div><br/>]],label,v.req_value or 0,v.cur_value or 0,v.req_value or 0,goto_str);
                info = info .. s;

            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
        elseif(key == "ClientExchangeItem")then
            local __,map = QuestHelp.GetClientExchangeItemList();
            local k,v;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                local mobid = 30345;
                local bShow = canShowGotoBtn();
                local goto_str = "";
                if(bShow)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_exchangeitem" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
                end
                local s = string.format([[<div>合成【%s】%d次(%d/%d)%s</div><br/>]],label,v.req_value or 0,v.cur_value or 0,v.req_value or 0,goto_str);
                info = info .. s;
            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
         elseif(key == "FlashGame")then
            local __,map = QuestHelp.GetFlashGameList();
            local k,v;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                local mobid = v.id;
                local bShow = canShowGotoBtn();
                local goto_str = "";
                if(bShow)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_flash" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
                end
                local s = string.format([[<div>玩小游戏【%s】%d次(%d/%d)%s</div><br/>]],label,v.req_value or 0,v.cur_value or 0,v.req_value or 0,goto_str);
                info = info .. s;
            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
         elseif(key == "ClientDialogNPC")then
			local bHasTipHelper;
            local __,map = QuestHelp.GetNpcList();
            local k,v;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                local mobid = v.id;
                local bShow = canShowGotoBtn();
                local goto_str = "";
                if(bShow)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_npc" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
					if( CanShowAutoTip() and not bHasTipHelper and (v.cur_value or 0) < (v.req_value or 0)) then
						-- added by Xizhi: to display a helper indicator. 
						bHasTipHelper = true;
						goto_str = goto_str..quest_arrowtip_str;
					end
                end

                local s = string.format([[<div>对话【%s】%d次(%d/%d)%s</div><br/>]],label,v.req_value or 0,v.cur_value or 0,v.req_value or 0,goto_str);
                info = info .. s;
            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
         elseif(key == "CustomGoal")then
            local __,map = QuestHelp.GetCustomGoalList();
            local k,v;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
				local customlabel;
                if(item)then
                    label = item.label;
                    customlabel = item.customlabel;
                end
				local mobid = v.id;
                local bShow = canShowGotoBtn();
                local goto_str = "";
				local has_pos = has_pos(key,map,v.id);
				local b_has_help_func,func_str = has_help_func(key,map,v.id);
                if(bShow and has_pos)then
                    goto_str = string.format([[<input type="button" name="%d" onclick="goto_custom_goal" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],mobid,mobid);
					if( CanShowAutoTip() and not bHasTipHelper and (v.cur_value or 0) < (v.req_value or 0)) then
						-- added by Xizhi: to display a helper indicator. 
						bHasTipHelper = true;
						goto_str = goto_str..quest_arrowtip_str;
					end
                elseif(bShow and b_has_help_func)then
					goto_str = string.format([[<input type="button" name="%s" onclick="do_help_func" tooltip="立即过去" style="width:25px;height:21px;margin-top:-4px;background:url(Texture/Aries/Quest/QuestList/jumparrow_32bits.png#0 0 25 21)"/>]],func_str or "");
                end
				local s;
				if(customlabel)then
					customlabel = string.format(customlabel,v.req_value or 0);
					s = string.format([[<div>%s(%d/%d)%s</div><br/>]],customlabel,v.cur_value or 0,v.req_value or 0,goto_str);
				else
					s = string.format([[<div>获得【%s】%d个(%d/%d)%s</div><br/>]],label,v.req_value or 0,v.cur_value or 0,v.req_value or 0,goto_str);
				end
                info = info .. s;
            end
            info = string.format([[<div><b>%s</b></div><br/><div>%s</div>]],condition_info,info)
         elseif(key == "RequestAttr")then
            local __,map = QuestHelp.GetAttrList();
            local k,v;
            for k,v in ipairs(result)do
                local item = map[v.id]
                local label = "";
                if(item)then
                    label = item.label;
                end
                local s = string.format("<div>%s:%d</div><br/>",label,v.req_value or 0);
                info = info .. s;
            end
            info = string.format([[<div><b>前提条件：%s</b></div><br/><div>%s</div>]],condition_info,info)
        end
        return info;
    end
end
function getNpcInfo(key)
    local __,map = QuestHelp.GetNpcList();
    if(template and key and map)then
        local v = template[key];
        if(v)then
            local item = map[v];
            return item;
        end
    end
end

function getNpcID(key)
   local info = getNpcInfo(key);
   if(info)then
        return info.id or "";
   end
end
function getNpcPlace(key)
   local info = getNpcInfo(key);
   if(info)then
        return info.place or "";
   end
end
function getNpcTooltip(key)
   local id = getNpcID(key);
   local place = getNpcPlace(key) or "";
   if(id and place)then
        local npc, worldname, npc_data = NPCList.GetNPCByIDAllWorlds(id);
		local world_info = WorldManager:GetWorldInfo(worldname);
		local label =  world_info.world_title or "";
		if(place == "")then
			return label;
		else
			if(QuestHelp.InSameWorldByKey(worldname))then
				return string.format("%s",place);
			else
				return string.format("%s,%s",label,place);
			end
		end
   end
end
function getNpcLabel(key)
   local info = getNpcInfo(key);
   local tooltip = getNpcTooltip(key) or "";
   
   if(info)then
        local label = info.label or "";
        label = string.format("%s(%s)",label,tooltip);
        return label
   end
end
--自己是否在 副本世界
function checkIsInInstanceWorld()
	local canpass = WorldManager:CanTeleport_CurrentWorld();
	if(not canpass)then
        _guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>你还在副本世界中，不能追踪目标！先离开副本世界吧。</div>");
	end
    return canpass;
end
--目标世界是否是 同一个世界
function checkWorld(arg1,arg2)
    local canpass = true;
	local worldname;
    if(arg1 == "byname")then
		worldname = arg2;
    else
		worldname = QuestHelp.WorldNumToWorldName(arg2);
    end
	local cur_world_info = WorldManager:GetCurrentWorld();
	if(cur_world_info.name ~= worldname)then
		canpass = false;
	end
    if(not canpass)then
		WorldManager:TeleportTo_CurrentWorld_Captain_PreDialog(worldname,function()
			ClosePage();
		end);
    end
    return canpass;
end
--目标世界是否 是副本世界
function checkInstanceWorld(arg1,arg2)
    local canpass = true;
	local worldname;
    if(arg1 == "byname")then
		worldname = arg2;
    else
        worldname = QuestHelp.WorldNumToWorldName(arg2);
    end
	local is_instance = WorldManager:IsInstanceWorld(worldname);
	if(is_instance)then
		canpass = false;
	end
	local chkEntry = WorldManager:GetWorldInstanceEntry(worldname);
	if(chkEntry and chkEntry.island_name and chkEntry.island_name == worldname) then
		_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>该目标在本岛的副本世界中，只能传送到副本门口，是否马上过去？</div>",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				facing = 0;
				local radius = 5;
				local end_pos = chkEntry.entry_pos;
				if(end_pos)then
					local  x,y,z = end_pos[1],end_pos[2],end_pos[3];
					x = x + radius * math.sin(facing);
					z = z + radius * math.cos(facing);
					if(x and y and z)then
						local Position = {x,y,z, facing+1.57};
						local CameraPosition = { 15, 0.27, facing + 1.57 - 1};
						local msg = { aries_type = "OnMapTeleport", 
									position = Position, 
									camera = CameraPosition, 
									bCheckBagWeight = true,
									wndName = "map", 
								};
							CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);

						ClosePage()
					end
				end
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
	end
    return canpass;
end
--目标世界是否是vip世界
function checkVipWorld(arg1,arg2)
	return true;
end
--直接跳转
function goto_npc(sID)
    sID = tonumber(sID);
	-- 各岛船长ID，有新岛需要添加
	-- local captainID={["61haqitown"]=30502,["flamingphoenixisland"]=30514,["frostroarisland"]=30608,["ancientegyptisland"]=30701};

    if(sID)then
        local npc, worldname, npc_data = NPCList.GetNPCByIDAllWorlds(sID);
        local canpass = checkIsInInstanceWorld();
        if(not canpass)then
            --自己是否在副本世界中
            return;
        end
        canpass = checkInstanceWorld("byname",worldname);
        if(not canpass)then
            --副本不能跳转
            return;
        end
        canpass = checkWorld("byname",worldname);
        if(not canpass)then
            --不在同一个世界
            return;
        end
        canpass = checkVipWorld("byname",worldname);
        if(not canpass)then
            --vip世界只有vip可以跳转
            return;
        end
        
        if(npc)then
            local facing = npc.facing or 0;
            facing = facing + 1.57
            local radius = 5;
            local end_pos = npc.position;
            if(end_pos)then
                local  x,y,z = end_pos[1],end_pos[2],end_pos[3];
                x = x + radius * math.sin(facing);
			    z = z + radius * math.cos(facing);
                if(x and y and z)then

                    local Position = {x,y,z, facing+1.57};
			        local CameraPosition = { 15, 0.27, facing + 1.57 - 1};
                    local msg = { aries_type = "OnMapTeleport", 
							    position = Position, 
							    camera = CameraPosition, 
								bCheckBagWeight = true,
							    wndName = "map", 
								end_callback = function()
									-- automatically open dialog when talking to npc. added by Xizhi to simplify user actions.
									local npc_id = tonumber(npc.npc_id);
									if(npc_id) then
										local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
										TargetArea.TalkToNPC(npc_id, nil, false);
									end	
								end
						    };
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
                    ClosePage();
                end
            end
        end
    end
end
function goto_exchangeitem(id)
    id = tonumber(id);
    if(id)then
        local npc, worldname, npc_data = NPCList.GetNPCByIDAllWorlds(id);
        local canpass = checkIsInInstanceWorld();
        if(not canpass)then
            --自己是否在副本世界中
            return;
        end
        canpass = checkInstanceWorld("byname",worldname);
        if(not canpass)then
            --副本不能跳转
            return;
        end
        canpass = checkWorld("byname",worldname);
        if(not canpass)then
            --不在同一个世界
            return;
        end
        canpass = checkVipWorld("byname",worldname);
        if(not canpass)then
            --vip世界只有vip可以跳转
            return;
        end
        if(npc)then
            local Position = { 19975.367188, 0.454175, 19705.109375,};
			local CameraPosition = { 8.70, 0.27, 3};
            local msg = { aries_type = "OnMapTeleport", 
						position = Position, 
						camera = CameraPosition, 
						bCheckBagWeight = true,
						wndName = "map", 
					};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);

            ClosePage()
        end
    end
end
function goto_flash(id)
    goto_pos(id,"FlashGame")
end
function goto_mob(id)
     goto_pos(id,"Goal")
end
function goto_custom_goal(id)
     goto_pos(id,"CustomGoal")
end
function goto_client_goal_item(id)
     goto_pos(id,"ClientGoalItem")
end
function goto_pos(id,key)
    id = tonumber(id);
    if(not id or not key)then return end
	if(not QuestHelp.Jump_Enabled_Kids(GetQuestID(),true))then
		return;
	end
	NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
	local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
	QuestTrackerPane.DoJump(GetQuestID(),id,key);
    ClosePage();
	if(true)then
		return;
	end
    local list,map;
    local world,position;
	local worldname;
    if(key == "Goal" or key == "GoalItem")then
        list,map = QuestHelp.GetGoalList();
    elseif(key == "ClientGoalItem")then
		list,map = QuestHelp.GetClientItemList();
	elseif(key == "FlashGame")then
		list,map = QuestHelp.GetFlashGameList();
	elseif(key == "CustomGoal")then
		list,map = QuestHelp.GetCustomGoalList();
    end
    if(map)then
        local item = map[id];
        if(item)then
            world = tonumber(item.world) or 0;
            position = item.position;
			worldname = item.worldname;
        end
    end
    if(world and position)then
        local canpass = checkIsInInstanceWorld();
        if(not canpass)then
            --自己是否在副本世界中
            return;
        end
		if(worldname)then
	        canpass = checkInstanceWorld("byname",worldname);
		else
		    canpass = checkInstanceWorld("bynum",world);
		end
        if(not canpass)then
            --副本不能跳转
            return;
        end
		if(worldname)then
	        canpass = checkWorld("byname",worldname);
		else
		    canpass = checkWorld("bynum",world);
		end
        if(not canpass)then
            --不在同一个世界
            return;
        end
		if(worldname)then
	        canpass = checkVipWorld("byname",worldname);
		else
		    canpass = checkVipWorld("bynum",world);
		end
        if(not canpass)then
            --vip世界只有vip可以跳转
            return;
        end
        if(position)then
            local x,y,z,camera_x,camera_y,camera_z;
			local all_info = QuestHelp.GetPosAndCameraFromString(position);
			if(all_info)then
				local len = #all_info;
				if(len > 0)then
					local index = math.random(len);
					local info = all_info[index];
					if(info)then
						local pos_info = info.pos;
						if(pos_info)then
							x,y,z = pos_info[1],pos_info[2],pos_info[3];
						end
						local camera_info = info.camera;
						if(camera_info)then
							camera_x,camera_y,camera_z = camera_info[1],camera_info[2],camera_info[3];
						end
					end
				end
			end
            if(x and y and z and camera_x and camera_y and camera_z )then
                local Position = {x,y,z};
			    local CameraPosition = {camera_x,camera_y,camera_z};
                local msg = { aries_type = "OnMapTeleport", 
							position = Position, 
							camera = CameraPosition, 
							bCheckBagWeight = true,
							wndName = "map", 
						};
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
            end
            ClosePage();
        end
    end
end
function isActivedState()
    local provider = QuestClientLogics.GetProvider();
    --local q_item = provider:GetQuest(id);
    --if(q_item and provider:IsActivedState(q_item))then
        --return true;
    --end
	if(provider:CanAccept(id) or provider:HasAccept(id))then
		return true;
	end
end
function isTracked()
	return QuestTrackerPane.Has_Tracked(id)
end
function doTracker()
	if(not QuestTrackerPane.Has_Tracked(id))then
        QuestTrackerPane.Enable_Track(id);
        pageCtrl:Refresh(0);
    end
end
function unTracker()
	if(QuestTrackerPane.Has_Tracked(id))then
        QuestTrackerPane.Disable_Track(id);
        pageCtrl:Refresh(0);
    end
end
local extra_reward_list,req_num,need_select = QuestPane.GetExtraReword(id);
if(ShowFinishedBtn())then
	extra_reward_list,req_num,need_select = QuestDetailPage.GetExtraReword(id);
end
function GetExtraReword()
	return extra_reward_list,req_num,need_select;
end
function NeedSelect()
	return need_select;
end
function GetExtraRewardListLen()
    if(extra_reward_list)then
        return #extra_reward_list;
    end
    return 0;
end
function extra_reward_func(index)
	if(not extra_reward_list)then return 0 end
	if(index == nil) then
		return #(extra_reward_list);
	else
		return extra_reward_list[index];
	end
end
function Has_Extra_Reward()
    if(extra_reward_list)then
        local len = #extra_reward_list;
        if(len > 0)then
            return true;
        end
    end
end
function Get_Extra_Reward_Title()
    if(extra_reward_list)then
        local len = #extra_reward_list;
        if(len > 0)then
            local s;
            if(req_num >= len)then
                s = string.format("你还可以得到:");
            else
                s = string.format("你还可以选择其中%d项:",req_num);
            end
            return s;
        end
    end
end
function Get_Extra_Reward_Num(num)
    num = tonumber(num)
    if(num and num > 1)then
        return num;
    end
end
function HasGsid(gsid)
    if(gsid and gsid > 0)then
        return true;
    end
end
function IsRightSchool(gsid)
    if(HasGsid(gsid))then
        return CommonClientService.IsRightSchool(gsid);
    end    
end
function GetTooltip(gsid)
    if(HasGsid(gsid))then
        local s = string.format("script/apps/Aries/Desktop/ApparelTooltip.html?gsid=%d",gsid);
        return s;
    end
end
--获取选择的长度
function GetSelectedList()
    local extra_reward_list,req_num,need_select = GetExtraReword();
    local list = extra_reward_list;
    if(list)then
        local selected_list = {};
        local k,v;
        for k,v in ipairs(list) do
            if(v.checked and v.index)then
                table.insert(selected_list,v.index);
            end
        end
        return selected_list;
    end
end
--选择奖励
function DoClick_Extra_Reward(gsid)
    if(not ShowFinishedBtn())then
        return;
    end
    local extra_reward_list,req_num,need_select = GetExtraReword();
    if(not need_select)then
        return;
    end
    local selected_list = GetSelectedList();
    local n = 0;
    if(selected_list)then
        n = #selected_list;
    end
    if(gsid and extra_reward_list)then
        local k,v;
        for k,v in ipairs(extra_reward_list) do
            if(v.gsid == gsid)then
                if(v.checked)then
                    v.checked = false;
                else
                    if(n >= req_num)then
                        --return
                    end
                    v.checked = true;
                end
            end
        end
        pageCtrl:Refresh(0);
    end
end
--检查是否有需要选择的奖励
function Check_CanFinished()
    local extra_reward_list,req_num = GetExtraReword();
    if(extra_reward_list)then
        local len = #extra_reward_list;
        if(len == 0)then
            return true;
        end
        local selected_list = GetSelectedList();
        local n = 0;
        if(selected_list)then
            n = #selected_list;
        end
        if(n < req_num)then
            _guihelper.MessageBox("请选择你的奖励！");
            return false;
        elseif(n > req_num)then
            _guihelper.MessageBox("你选择的奖励太多了！");
            return false;
        end
    end
    return true;
end
--完成任务
function doFinished()
    local can_pass = Check_CanFinished();
    if(not can_pass)then return end
    local questid = id;
    questid = tonumber(questid);
    local reward_index_list = GetSelectedList();
    
     local msg = {
	            nid = nid,
	            id = questid,
                reward_index_list = reward_index_list,
            }
    QuestClientLogics.TryFinished(msg);
    ClosePage();
end
--是否有额外奖励
function HasExtraReward()
    local extra_reward_list,req_num = GetExtraReword();
	if(extra_reward_list)then
		local len = #extra_reward_list;
		if(len > 0)then
			return true;
		end
	end	
end
---------------------------------
-- end page code
---------------------------------
end