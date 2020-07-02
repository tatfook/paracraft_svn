--[[
Title: code behind for page 30153_BuildingWorkshop_panel.html
Author(s): Leio
Date: 2009/11/30
Desc:  script/apps/Aries/NPCs/ShoppingZone/30153_BuildingWorkshop_panel.html

Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local BuildingWorkshop_panel = {
	items = nil,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BuildingWorkshop_panel", BuildingWorkshop_panel);
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function BuildingWorkshop_panel.OnInit()
	local self = BuildingWorkshop_panel;
	self.pageCtrl =  document:GetPageCtrl();
	
end
function BuildingWorkshop_panel.ShowPage()
	local self = BuildingWorkshop_panel;
	self.items = MyCompany.Aries.Quest.NPCs.CastMachine_panel.Items[100];
	self.index  = 1;
	self.BindFramePage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/ShoppingZone/30153_BuildingWorkshop_panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30153_BuildingWorkshop_panel", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -475/2,
            y = -542/2,
            width = 475,
            height = 542,
    });
end
function BuildingWorkshop_panel.ClosePage()
	local self = BuildingWorkshop_panel;
	self.index = 1;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
--刷新frame
function BuildingWorkshop_panel.BindFramePage()
	local self = BuildingWorkshop_panel;
	--local msg = {
		--exID = 271,
		--gsids = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
		--exchanged_gsids = { { key=30065, value=1 }, },
		--cast_level = 0,
		--odds = 50,
	--}
	if(self.items)then
		local item = self.items[self.index];
		if(item)then
			local exID = item.exID;
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exID);
			if(exTemplate)then
				local cast_level = MyCompany.Aries.Quest.NPCs.CastMachine_panel.GetCastLevel();
				local odds = MyCompany.Aries.Quest.NPCs.CastMachine_panel.GetOdds(cast_level);
				
				local cast_next_level;
				local odds_next_level;
				if(cast_level)then
					cast_next_level = cast_level + 1
					odds_next_level = MyCompany.Aries.Quest.NPCs.CastMachine_panel.GetOdds(cast_next_level);
				end
				commonlib.echo("============exTemplate");
				commonlib.echo(exTemplate);
				local msg = {
					exID = exID,
					gsids = exTemplate.froms,
					exchanged_gsids = exTemplate.tos,
					pres = exTemplate.pres,
					cast_level = cast_level,
					odds = odds,
					cast_next_level = cast_next_level,
					odds_next_level = odds_next_level,
					state = "normal",
				}
				MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Bind(msg);
				
			end
			
		end
	end
	
end
function BuildingWorkshop_panel.OnCompose()
	local self = BuildingWorkshop_panel;
	local canBuild = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.CanBuild()
	--缺少物品
	if(not canBuild)then
		local s = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Error_NeedItems();
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	local exchanged_item_gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	local name = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
	if(not exchanged_item_gsid)then return end
	local __,__,__,copies = hasGSItem(exchanged_item_gsid);
	copies = copies or 0;
	--超过最大数
	if(copies >= 1)then
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s只能拥有一个！</div>",
			name);
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	--TODO 合成物品
	--local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
	--local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s建造成功！ </div>",
						--title);
		--_guihelper.Custom_MessageBox(s,function(result)
			--
		--end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	self.__DoBuild()
end
function BuildingWorkshop_panel.__DoBuild()
	local self = BuildingWorkshop_panel;
	local item = self.items[self.index];
	if(item)then
		local exID = item.exID;
		if(not exID or exID == "")then return end
		commonlib.echo("=========start build");
		commonlib.echo(item);
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			commonlib.echo("=========after build");
			commonlib.echo(msg);
			--obtains={ [17034]=1 , [-4] = 2},
			--gsid  -1:P币；0:E币；-2:亲密度；-3:爱心值；-4:力量值；-5:敏捷值；-6:智慧值；-7:建筑熟练度
			self.ClosePage();
		end);
	end
end
