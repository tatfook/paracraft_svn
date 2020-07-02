--[[
Title: FarmlandShopPanel
Author(s): Leio
Date: 2010/03/08

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Farm/30367_FarmlandShopPanel.lua
------------------------------------------------------------
]]

-- create class
local libName = "FarmlandShopPanel";
local FarmlandShopPanel = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FarmlandShopPanel", FarmlandShopPanel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FarmlandShopPanel.main
function FarmlandShopPanel.main()
	local self = FarmlandShopPanel; 
end

function FarmlandShopPanel.PreDialog(npc_id, instance)
	local self = FarmlandShopPanel; 
	self.seeds = self.DataAdapter(MyCompany.Aries.Quest.NPCs.FarmlandShop.seeds);
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/Farm/30367_FarmlandShopPanel_panel.html", 
			name = "FarmlandShopPanel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -853/2,
				y = -512/2,
				width = 853,
				height = 512,
		});
	return false;
end
function FarmlandShopPanel.DataAdapter(seeds)
	local self = FarmlandShopPanel;
	if(not seeds)then return end
	local k,v;
	local result = {};
	for k,v in ipairs(seeds) do
		local gsid = v.gsid;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
		if(gsItem and gsItem.descfile)then
			local name = gsItem.template.name;
			local description = gsItem.template.description;
			local config =  Map3DSystem.App.HomeLand.HomeLandConfig.ParsePlantE(gsItem.descfile);
			if(config and config["assets_normal"])then
				--[[
				assets_normal = {
					"model/05plants/v5/01tree/CherryTree/CherryTreeStage0.x",
					"model/05plants/v5/01tree/CherryTree/CherryTreeStage1.x",
					"model/05plants/v5/01tree/CherryTree/CherryTreeStage2.x",
					"model/05plants/v5/01tree/CherryTree/CherryTreeStage3.x",
					"model/05plants/v5/01tree/CherryTree/CherryTreeStage4.x",
				},	
				--]]
				config = config["assets_normal"];
				local stage = #config;
				local item = {
					gsid = gsid,
					name = name,
					description = description,
					config = config,
					stage = stage,
				}
				commonlib.echo("==========insert item in FarmlandShopPanel.DataAdapter");
				commonlib.echo(item);
				table.insert(result,item);
			end
		end
	end
	return result;
end
function FarmlandShopPanel.DS_Func(index)
	local self = FarmlandShopPanel;
	if(not self.seeds)then return 0 end
	if(index == nil) then
		return #(self.seeds);
	else
		return self.seeds[index];
	end
end