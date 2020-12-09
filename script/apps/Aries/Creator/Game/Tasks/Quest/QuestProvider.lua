--[[
Title: QuestProvider
Author(s): leio
Date: 2020/12/8
use the lib:
------------------------------------------------------------

NOTE£º
Quest Item is in UserBagNo 1005, gsid start from 60000
ExID from 40000 to 49999
------------------------------------------------------------
extra in ¶Ò»»¹æÔò
{
  "preconditions": [
    { "id": "60003_1", "title": "", "desc": "", "finished_value": 5 },
    { "id": "60003_2", "title": "", "desc": "", "finished_value": "abc" },
    { "id": "60003_3", "title": "", "desc": "", "finished_value": 5 }
  ]
}

local clientdata_list = {
    { gsId = 1, data = nil, },
    { gsId = 2, data = nil, },
    { gsId = 3, data = nil, },
    { gsId = 4, data = nil, },
}

NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");

QuestProvider:GetInstance():AddEventListener(QuestProvider.Events.OnChanged,function()
    commonlib.echo("==============GetQuestItems");
    echo(#(QuestProvider:GetInstance():GetQuestItems()))
end)

QuestProvider:GetInstance():OnInit(clientdata_list);

echo("=============QuestProvider:Dump");
echo(QuestProvider:GetInstance():Dump(),true);
echo("=============QuestProvider:DumpTemplates");
echo(QuestProvider:GetInstance():DumpTemplates(),true);


QuestProvider:GetInstance():IncreaseNumberValue("60003_1",1);
QuestProvider:GetInstance():SetValue("60003_2","ABC");
QuestProvider:GetInstance():IncreaseNumberValue("60003_3",100);

local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
KeepWorkItemManager.DoExtendedCost(10100);

local item = QuestProvider:CreateOrGetQuestItemContainer(60001);
if(item)then
    item:DoFinish();
end
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/Quest.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItem.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItemContainer.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItemTemplate.lua");
local Quest = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.Quest");
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local QuestItemContainer = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemContainer");
local QuestItem = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItem");
local QuestItemTemplate = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemTemplate");
local QuestProvider = commonlib.inherit(commonlib.gettable("commonlib.EventSystem"),commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider"))

QuestProvider.Events = {
    OnChanged = "OnChanged",
}

function QuestProvider:GetInstance()
    if(not QuestProvider.provider_instance)then
        QuestProvider.provider_instance = QuestProvider:new(); 
    end
    return QuestProvider.provider_instance;
end
function QuestProvider:OnInit(clientdata_list)
    if(self.is_init)then
        return
    end
    self.is_init = true;

    self.templates_map = {};
    self.gsid_exid_map = {};
    self.bags = { 1005 };
    self.min_exid = 40000;
    self.max_exid = 49999;
    self.questItemContainer_map = {};

    self.quest_graph = Quest:new():Init(KeepWorkItemManager.extendedcost);
    --self.quest_graph:SaveQuestToDgml("test/quest.dgml");

    self:FillTemplates();
    self:FillData(clientdata_list)
    KeepWorkItemManager.GetFilter():add_filter("LoadItems_Finished", function()
        self:Refresh();
    end);
end
--[[
local quest_nodes = {
    { exid = 40000, },
    { exid = 40001, },
    { exid = 40002, },
    { exid = 40003, },
}
-]]
function QuestProvider:GetActivedQuestNodes()
    return self.quest_graph:GetQuestNodes();
end
function QuestProvider:FillData(clientdata_list)
    if(not clientdata_list)then
        return
    end
     for k,v in ipairs(clientdata_list) do
        local gsid = v.gsId;
        local data = v.data;
        local item = self:CreateOrGetQuestItemContainer(gsid);  
        item:Parse(data);
    end
end
function QuestProvider:FillTemplates()
    for k,v in ipairs(KeepWorkItemManager.extendedcost) do
        local exid = v.exId;
        if(self:IsValidExid(exid))then
            self:FillQuestItemTemplateBy_Virtual_Condition(exid);
            self:FillQuestItemTemplateBy_Real_Condition(exid);
        end
    end
end
function QuestProvider:AddQuestItemTemplate(template)
    if(not template)then
        return
    end
    local key = template:GetUniqueKey();
    local t = self.templates_map[key];
    if(t)then
        return
    end
    self.templates_map[key] = template;
end
function QuestProvider:GetQuestItemTemplate(gsid, id)
    local key = string.format("%s_%s",tostring(gsid), tostring(id));
    return self.templates_map[key];
end
function QuestProvider:IsValidExid(exid)
    if(not exid)then
        return
    end
    if(exid >= self.min_exid and exid <= self.max_exid)then
        return true;
    end
end
function QuestProvider:IsValidBag(bagNo)
    if(not bagNo)then
        return
    end
    for k,v in ipairs(self.bags) do
        if(v == bagNo)then
            return true;
        end
    end
end
function QuestProvider:GetExtra(exid)
    local ex_template = KeepWorkItemManager.GetExtendedCostTemplate(exid);
    if(ex_template)then
        return ex_template.extra;
    end
end
function QuestProvider:SearchExidFromQuestGsid(gsid)
    if(not gsid)then
        return
    end
    return self.gsid_exid_map[gsid];
end
-- search quest item gsid from exchangeTargets
function QuestProvider:SearchQuestGsidFromExid(exid)
    local goal = KeepWorkItemManager.GetGoal(exid);
    for k,group in ipairs(goal) do
        local goods = group.goods;
        for kk,item in ipairs(goods) do
            local bagId = item.goods.bagId;
            local gsId = item.goods.gsId;
            local bagNo = KeepWorkItemManager.SearchBagNo(bagId)
            if(self:IsValidBag(bagNo))then
                -- map quest gsid and exid
                self.gsid_exid_map[gsId] = exid;
                return gsId;
            end
        end
    end
end

function QuestProvider:FillQuestItemTemplateBy_Virtual_Condition(exid)
    if(not exid)then
        return
    end
    local ex_template = KeepWorkItemManager.GetExtendedCostTemplate(exid);
    local quest_gsid = self:SearchQuestGsidFromExid(exid);
    if(ex_template and quest_gsid)then
        local extra = self:GetExtra(exid);
        if(extra and extra.preconditions)then
            local preconditions = extra.preconditions;
            for k,v in ipairs(preconditions) do
                local id = v.id;
                local quest_template = self:GetQuestItemTemplate(quest_gsid, id);
                if(not quest_template)then
                    quest_template = QuestItemTemplate:new();
                    quest_template.exid = exid;
                    quest_template.gsid = quest_gsid;
                    quest_template.id = id;
                    quest_template.type = QuestItemTemplate.Types.VIRTUAL;
                    quest_template.finished_value = v.finished_value;
                    quest_template.name = v.name;
                    quest_template.desc = v.desc;
                    self:AddQuestItemTemplate(quest_template);
                end
            end
        end
    end
end

-- parse template with preconditions
function QuestProvider:FillQuestItemTemplateBy_Real_Condition(exid)
    if(not exid)then
        return
    end
    local quest_gsid = self:SearchQuestGsidFromExid(exid);
    local preconditions = KeepWorkItemManager.GetPrecondition(exid);
    if(quest_gsid and preconditions)then
        local item_template = KeepWorkItemManager.GetItemTemplate(quest_gsid);
        if(item_template)then
            for k,v in ipairs(preconditions) do
                local goods = v.goods;
                local amount = v.amount;
                if(goods and amount)then
                    local gsid = goods.gsId;
                    local quest_template = self:GetQuestItemTemplate(quest_gsid, gsid);
                    if(not quest_template)then
                        quest_template = QuestItemTemplate:new();
                        quest_template.exid = exid;
                        quest_template.gsid = quest_gsid;
                        quest_template.id = gsid;
                        quest_template.type = QuestItemTemplate.Types.REAL;
                        quest_template.finished_value = amount;
                        quest_template.name = item_template.name;
                        quest_template.desc = item_template.desc;
                        self:AddQuestItemTemplate(quest_template);
                    end
                end
            end
        end
    end
end
-- refresh the state of valid quest node
function QuestProvider:Refresh()
    local quest_nodes = self:GetActivedQuestNodes();
    echo("==========quest_nodes");
    echo(quest_nodes);
    if(not quest_nodes)then
        return
    end
     for k,v in ipairs(quest_nodes) do
        local exid = v.exid;
        local quest_gsid = self:SearchQuestGsidFromExid(exid)
        if(quest_gsid)then
            local itemContainer = self:CreateOrGetQuestItemContainer(quest_gsid);

            -- check virtual condition
            local extra = self:GetExtra(exid);
            if(extra and extra.preconditions)then
                for kk,vv in ipairs(extra.preconditions) do
                    local id = vv.id
                    local item = itemContainer:GetChildById(id);
                    if(not item)then
                        local template = self:GetQuestItemTemplate(quest_gsid, id);
                        local quest_item = QuestItem:new():OnInit(id, nil, template);      
                        itemContainer:AddChild(quest_item);
                    end
                end
            end
             -- check real condition
            local preconditions = KeepWorkItemManager.GetPrecondition(exid);
            if(preconditions)then
                for k,v in ipairs(preconditions) do
                    local goods = v.goods;
                    if(goods)then
                        local id = goods.gsId;
                        local bagId = goods.bagId;
                        local bagNo = KeepWorkItemManager.SearchBagNo(bagId)
                        if(not self:IsValidBag(bagNo))then
                            local item = itemContainer:GetChildById(id);
                            if(not item)then
                                local template = self:GetQuestItemTemplate(quest_gsid, id);
                                local quest_item = QuestItem:new():OnInit(id, nil, template);      
                                itemContainer:AddChild(quest_item);
                            end
                        end
                        
                    end
                end
            end
            itemContainer:Refresh();
        end
    end
    self:DispatchEvent({ type = QuestProvider.Events.OnChanged, });

end
function QuestProvider:CreateOrGetQuestItemContainer(gsid,data)
    if(not gsid)then
        return
    end
    local item = self.questItemContainer_map[gsid];
    if(not item)then
        item = QuestItemContainer:new():OnInit(self, gsid, data);  

        item:AddEventListener(QuestItemContainer.Events.OnChanged,function(__,event)
            self:Refresh();
        end)
        item:AddEventListener(QuestItemContainer.Events.OnFinish,function(__,event)
            self:Refresh();
        end)

        self.questItemContainer_map[gsid] = item;
    end
    return item;
end
function QuestProvider:IncreaseNumberValue(id,value)
    for k,v in pairs(self.questItemContainer_map) do
        v:IncreaseNumberValue(id,value);
    end
end
function QuestProvider:SetValue(id,value)
    for k,v in pairs(self.questItemContainer_map) do
        v:SetValue(id,value);
    end
end
function QuestProvider:Dump()
    local result = {};
    for k,v in pairs(self.questItemContainer_map) do
        table.insert(result, {
            gsid = v.gsid,
            v:GetData()
        });
    end
    return result;
end
function QuestProvider:DumpTemplates()
    local result = {};
    for k,template in pairs(self.templates_map) do
         result[k] = template:GetData();
    end 
    return result;
end
function QuestProvider:GetQuestItems()
    local result = {};
    for k,v in pairs(self.questItemContainer_map) do
        local gsid = v.gsid;
        local exid = self:SearchExidFromQuestGsid(gsid);
        if(exid)then
            local extra = self:GetExtra(exid)
            table.insert(result,{
                gsid = gsid,
                exid = exid, 
                questItemContainer = v,
            })
        end
    end
    table.sort(result,function(a,b)
        return a.gsid < b.gsid
    end)
    return result;
end