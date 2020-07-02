--[[
Title: MysteryEncryptedBox_panel
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Library/30033_MysteryEncryptedBox_panel.lua");
MyCompany.Aries.Quest.NPCs.MysteryEncryptedBox_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "MysteryEncryptedBox_panel";
local MysteryEncryptedBox_panel = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MysteryEncryptedBox_panel", MysteryEncryptedBox_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

MysteryEncryptedBox_panel.Items = {
	{name = "白银铠甲", gsid = 1190, itemsetgsids = {1190} }, -- we use 南瓜头棉衣 1086 as the item set icon
};

local selected_item_index = 1;
local page;

function MysteryEncryptedBox_panel.OnInit()
	selected_item_index = 1;
	page = document:GetPageCtrl();
end

function MysteryEncryptedBox_panel.DS_Func_MysteryEncryptedBox_panel(index)
	if(not MysteryEncryptedBox_panel.Items) then return 0 end
	if(index == nil) then
		return #(MysteryEncryptedBox_panel.Items);
	else
		return MysteryEncryptedBox_panel.Items[index];
	end
end

function MysteryEncryptedBox_panel.DoClick(index)
	selected_item_index = index;
end

function MysteryEncryptedBox_panel.OnSubmit(code)
	if(selected_item_index) then
		local item = MysteryEncryptedBox_panel.Items[selected_item_index];
		if(item) then
			if(item.itemsetgsids) then
				local itemsetgsids = item.itemsetgsids;
				local i, gsid;
				for i, gsid in pairs(itemsetgsids) do
					if(hasGSItem(gsid)) then
						_guihelper.MessageBox(string.format([[<div style="margin-left:24px;margin-top:24px;">你不能拥有过多的【%s】，再试试别的吧。</div>]], item.name));
						return;
					end
				end
			end
			_guihelper.MessageBox(string.format([[<div style="margin-left:24px;margin-top:32px;">你确定想领取【%s】吗？</div>]], item.name), function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--_guihelper.MessageBox("exchange item:"..item.gsid..item.name.." with code:"..code);
					-- close exchange panel
					if(page) then
						page:CloseWindow();
					end
					
	                local msg = {
		                card = code,
	                };
					paraworld.MagicCard.Consume(msg, "30033_MysteryEncryptedBox_codebox", function(msg)
				        log("=========== MysteryEncryptedBox_panel ===========\n")
				        commonlib.echo(msg);
				        -- 497:兑换的物品不存在或卡号不存在  421：卡已被使用  424:拥有的物品数量超过限制  428:超过单日购买限制  429:超过周购买限制  417:该卡号正在被使用  500:其它错误
				        if(not msg.errorcode) then
							-- succeed
							-- fake stats for extendedcost notification
							msg.stats = {};
							-- show the items in notification area
							MyCompany.Aries.Desktop.Dock.OnExtendedCostNotification(msg);
							-- force update user bag 1
							System.Item.ItemManager.GetItemsInBag(1, "BagUpdate_MysteryEncryptedBox_panel", function(msg)
							end, "access plus 0 day");
						elseif(msg.errorcode == 424) then
                            _guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">你不能拥有过多的【%s】，再试试别的吧。</div>]], item.name));
						elseif(msg.errorcode) then
                            _guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">喔噢，领取【%s】失败！</div>]], item.name));
				        end
					end);
				end	
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	end
end