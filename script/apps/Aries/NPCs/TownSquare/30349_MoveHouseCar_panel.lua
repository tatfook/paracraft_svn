--[[
Title: MoveHouseCar_panel
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar_panel.lua");
MyCompany.Aries.Quest.NPCs.MoveHouseCar_panel.ShowPage();
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar_panel.lua");
MyCompany.Aries.Quest.NPCs.MoveHouseCar_panel.__DoBuild_396666();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar_frame.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "MoveHouseCar_panel";
local MoveHouseCar_panel = {
	selected_index = nil,
	page_state = 0,
	selected_items = nil,
	cur_exID = nil,
	cur_name = nil,
	cur_gsid = nil,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MoveHouseCar_panel", MoveHouseCar_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

MoveHouseCar_panel.Items = {
	[1] = {
		{name = "环保村",exID = 440, gsid = 39104, icon = "Texture/Aries/NPCs/MoveHouseCar/home_5.png;0 0 311 204",desc = "50枚小红花",},
		{name = "甜蜜岛屿",exID = 396, gsid = 39103, icon = "Texture/Aries/NPCs/MoveHouseCar/home_4.png;0 0 311 204",desc = "5个冰块和2个蜂蜜结晶",},
		{name = "新春之家",exID = 295, gsid = 39102, icon = "Texture/Aries/NPCs/MoveHouseCar/home_3.png;0 0 311 204",desc = "6个红枫叶",},
		{name = "冰雪之家",exID = 294, gsid = 39101, icon = "Texture/Aries/NPCs/MoveHouseCar/home_2.png;0 0 311 204",desc = "“哈”“奇”“小”“镇”“欢”“迎”“你”七种卡片各2张",},
		{name = "青青草原",exID = 293, gsid = -1, icon = "Texture/Aries/NPCs/MoveHouseCar/home_1.png;0 0 311 204",desc = "2000奇豆",},
	},
	
}
function MoveHouseCar_panel.DS_Func_MoveHouseCar_panel(index)
	local self = MoveHouseCar_panel;
	if(not self.selected_items)then return 0 end
	if(index == nil) then
		return #(self.selected_items);
	else
		return self.selected_items[index];
	end
end
function MoveHouseCar_panel.OnInit()
	local self = MoveHouseCar_panel; 
	self.page = document:GetPageCtrl();
end
function MoveHouseCar_panel.DoClick(index)
	local self = MoveHouseCar_panel; 
	self.selected_index = index;
	self.BindFramePage()
	self.RefreshPage();
end
function MoveHouseCar_panel.ShowPage()
	local self = MoveHouseCar_panel;
	self.Reset();
	self.BindFramePage();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar_panel.html", 
			name = "MoveHouseCar_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -777/2,
				y = -533/2,
				width = 777,
				height = 533,
		});
end
function MoveHouseCar_panel.Reset()
	local self = MoveHouseCar_panel;
	self.page_state = 0;
	self.selected_index = 1;
	self.selected_items = self.Items[1];
end
function MoveHouseCar_panel.ClosePage()
	local self = MoveHouseCar_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function MoveHouseCar_panel.RefreshPage()
	local self = MoveHouseCar_panel;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
--刷新frame
function MoveHouseCar_panel.BindFramePage()
	local self = MoveHouseCar_panel;
	--local msg = {
		--exID = 271,
		--gsids = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
		--exchanged_gsids = { { key=30065, value=1 }, },
		--cast_level = 0,
		--odds = 50,
	--}
	if(self.selected_items)then
		local item = self.selected_items[self.selected_index];
		commonlib.echo("=====item");
		commonlib.echo(item);
		if(item)then
			local exID = item.exID;
			local name = item.name;
			local gsid = item.gsid;
			local desc = item.desc;
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exID);
			if(exTemplate)then
				local msg = {
					exID = exID,
					gsids = exTemplate.froms,
					exchanged_gsids = exTemplate.tos,
					icon = item.icon,
					single_gsid = gsid,
				}
				commonlib.echo(msg);
				MyCompany.Aries.Quest.NPCs.MoveHouseCar_frame.Bind(msg);
			end
			self.cur_exID = exID;
			self.cur_name = name;
			self.cur_gsid = gsid;
			self.cur_desc = desc;
		end
	end
	
end


--开始建造
function MoveHouseCar_panel.DoBuild()
	local self = MoveHouseCar_panel;
	if(self.cur_exID == 293)then
		if(self.HasGreenHome())then
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你的家园现在已经是%s了，不用再搬一次了。</div>",
				self.cur_name);
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return;
		end
	else
		if(self.HasOtherHome(self.cur_gsid))then
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你的家园现在已经是%s了，不用再搬一次了。</div>",
				self.cur_name);
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return;
		end
	end
	local canBuild = MyCompany.Aries.Quest.NPCs.MoveHouseCar_frame.CanBuild()
	--缺少物品
	if(not canBuild)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你还不够搬家的条件呢，再去看看家园说明吧。</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	--搬家
	local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>搬到%s需要%s,你确定要搬去吗？</div>",
				self.cur_name,self.cur_desc);
	_guihelper.Custom_MessageBox(s,function(result)
	if(result == _guihelper.DialogResult.Yes)then
		if(self.cur_gsid == 39104)then
			self.__DoBuild_39104();
		else
			self.__DoBuild();
			self.ClosePage();
		end
	else
		commonlib.echo("no");
	end
end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
end
--是否已经是青青草原背景
function MoveHouseCar_panel.HasGreenHome()
	local self = MoveHouseCar_panel;
	--如果此位置已经装上物品，测不是青青草原
	local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 22);
	if(item and item.guid > 0)then
		return false
	end
	return true;
end
function MoveHouseCar_panel.HasOtherHome(gsid)
	local self = MoveHouseCar_panel;
	local item = System.Item.ItemManager.GetItemByBagAndPosition(0, 22);
	commonlib.echo("======t");
	commonlib.echo(item);
	if(item and item.guid > 0)then
		return item.gsid == gsid;
	end
end
function MoveHouseCar_panel.__DoBuild_39104()
	local self = MoveHouseCar_panel;
	if(self.selected_items)then
		local item = self.selected_items[self.selected_index];
		local exID = item.exID;
		local name = item.name;
		local gsid = item.gsid;
		
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>环保村可不是一般的地方，地势很特殊，你原来的家具可能有变动，需要帮你放回仓库吗？</div>";
		_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					self.ClosePage();
					
					self.__DoExchange(exID,gsid,function()
						local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>恭喜你已经成功搬到环保村了，赶紧回家看看吧！</div>"
						_guihelper.Custom_MessageBox(s,function(result)
							
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					end)
				else
					self.ClosePage();
					self.__DoExchange(exID,gsid,function()
						--把家具收回仓库
						self.ClearAllHomelandItems(function()
							local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>恭喜你已经成功搬到环保村了，家园物品也放进仓库咯，赶快回家看看吧！</div>"
							_guihelper.Custom_MessageBox(s,function(result)
								
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
						end);
					end)
				end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/NeedNot_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Need_32bits.png; 0 0 153 49"});
	end
end
function MoveHouseCar_panel.__DoExchange(exID,gsid,callbackFunc)
	if(not exID or not gsid)then return end
	ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg)
		commonlib.echo("======after ExtendedCost in MoveHouseCar_panel");
		commonlib.echo(msg);
		if(msg.issuccess) then
			local bHas, guid = hasGSItem(gsid)
			commonlib.echo("=====bHas");
			commonlib.echo(bHas);
			commonlib.echo(gsid);
			if(bHas) then
				if(not equipGSItem(gsid)) then
					local item = ItemManager.GetItemByGUID(guid);
					commonlib.echo("=====bHas2");
					commonlib.echo(item);
					if(item and item.guid > 0) then
						ItemManager.EquipItem(item.guid, function(msg) 
							if(callbackFunc)then
								callbackFunc();
							end
						end)
					end
				end
			end
		end
	end);
end
function MoveHouseCar_panel.__DoBuild()
	local self = MoveHouseCar_panel;
	if(self.selected_items)then
		local item = self.selected_items[self.selected_index];
		local exID = item.exID;
		local name = item.name;
		local gsid = item.gsid;
		commonlib.echo("======before ExtendedCost in MoveHouseCar_panel");
		commonlib.echo(exID);
		if(exID == 293)then
			
			ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg)
				commonlib.echo("======after ExtendedCost in MoveHouseCar_panel");
				commonlib.echo(msg);
				if(msg.issuccess) then
					ItemManager.UnEquipItem(22,function(msg)
						local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>恭喜你已经成功搬到%s了，赶紧回家看看去吧！</div>",
						name);
						_guihelper.Custom_MessageBox(s,function(result)
							
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					end)
				end
			end,"none")
		else
			self.__DoExchange(exID,gsid,function()
				local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>恭喜你已经成功搬到%s了，赶紧回家看看去吧！</div>",
										name);
										_guihelper.Custom_MessageBox(s,function(result)
											
										end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			end)
			
			--ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg)
				--commonlib.echo("======after ExtendedCost in MoveHouseCar_panel");
				--commonlib.echo(msg);
				--if(msg.issuccess) then
					--local bHas, guid = hasGSItem(gsid)
					--commonlib.echo("=====bHas");
					--commonlib.echo(bHas);
					--commonlib.echo(gsid);
					--if(bHas) then
						--if(not equipGSItem(gsid)) then
							--local item = ItemManager.GetItemByGUID(guid);
							--commonlib.echo("=====bHas2");
							--commonlib.echo(item);
							--if(item and item.guid > 0) then
								--ItemManager.EquipItem(item.guid, function(msg) 
								--
								--end)
							--end
						--end
					--end
				--end
			--end);
		end
	end
end
function MoveHouseCar_panel.ClearAllHomelandItems(callbackFunc)
	commonlib.echo("============== paraworld.inventory.RecycleHomelandItems called ==============\n")
	paraworld.inventory.RecycleHomelandItems({}, "RecycleHomelandItems", function(msg)
		commonlib.echo("============== paraworld.inventory.RecycleHomelandItems returns ==============\n")
		commonlib.echo(msg);
		if(msg and msg.issuccess) then
			-- delay 1 second for memory cache valid
			UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
				if(elapsedTime == 1000) then
					-- after recycle succeed, force the warehouse and homeland bag refreshed
					local warehouse_bags = {10001,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,};
					local bags = "";
					local i;
					for i = 1, #warehouse_bags do
						bags = bags..warehouse_bags[i]..",";
					end
					local msg = {
						bags = bags,
					};
					paraworld.inventory.GetItemsInBags(msg, "GetItemsInBags_AfterRecycle", function(msg) 
						if(not msg or msg.errorcode) then
							_guihelper.MessageBox([[<div style="margin-left:100px;margin-top:30px;">回收仓库失败</div>]]);
							return;
						end
						-- refresh the bag in local server cache
						local i;
						for i = 1, #warehouse_bags do
							ItemManager.GetItemsInBag(warehouse_bags[i], "RefreshBag_AfterRecycle", function(msg)
							end, "access plus 1 minutes");
						end
						ItemManager.GetItemsInBag(10001, "RefreshBag_AfterRecycle", function(msg)
							-- after homeland bag refreshed
							-- TODO: refresh the homeland object
							if(callbackFunc)then
								callbackFunc();
							end
						end, "access plus 1 minutes");
					end, nil, 10000, function() 
						_guihelper.MessageBox([[<div style="margin-left:100px;margin-top:30px;">回收仓库失败</div>]]);
					end);
				end
			end);
		end
	end);
end										
