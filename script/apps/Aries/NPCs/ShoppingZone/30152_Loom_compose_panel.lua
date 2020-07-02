--[[
Title: Loom_compose_panel
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30152_Loom_compose_panel.lua");
MyCompany.Aries.Quest.NPCs.Loom_compose_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_panel.lua");
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_compose_frame.lua");
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30347_CastSkillHitBoard.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "Loom_compose_panel";
local Loom_compose_panel = {
	selected_index = nil,
	page_state = 0,
	selected_items = nil,
	
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Loom_compose_panel", Loom_compose_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function Loom_compose_panel.DS_Func_Loom_compose_panel(index)
	local self = Loom_compose_panel;
	if(not self.selected_items)then return 0 end
	if(index == nil) then
		return #(self.selected_items);
	else
		return self.selected_items[index];
	end
end
function Loom_compose_panel.OnInit()
	local self = Loom_compose_panel; 
	self.page = document:GetPageCtrl();
end
function Loom_compose_panel.DoClick(index)
	local self = Loom_compose_panel; 
	self.selected_index = index;
	self.BindFramePage()
	self.RefreshPage();
end
function Loom_compose_panel.ShowPage()
	local self = Loom_compose_panel;
	self.Reset();
	self.BindFramePage();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/ShoppingZone/30152_Loom_compose_panel.html", 
			name = "Loom_compose_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -686/2,
				y = -507/2,
				width = 686,
				height = 507,
		});
end
function Loom_compose_panel.Reset()
	local self = Loom_compose_panel;
	self.page_state = 0;
	self.selected_index = 1;
	self.selected_items = MyCompany.Aries.Quest.NPCs.CastMachine_panel.Items[101];
end
function Loom_compose_panel.ClosePage()
	local self = Loom_compose_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function Loom_compose_panel.RefreshPage()
	local self = Loom_compose_panel;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
--刷新frame
function Loom_compose_panel.BindFramePage()
	local self = Loom_compose_panel;
	--local msg = {
		--exID = 271,
		--gsids = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
		--exchanged_gsids = { { key=30065, value=1 }, },
		--cast_level = 0,
		--odds = 50,
	--}
	if(self.selected_items)then
		local item = self.selected_items[self.selected_index];
		if(item)then
			local exID = item.exID;
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exID);
			if(exTemplate)then
				--设置级别
				MyCompany.Aries.Quest.NPCs.CastMachine_panel.SetPageState(self.selected_index - 1)
				local cast_level = MyCompany.Aries.Quest.NPCs.CastMachine_panel.GetCastLevel();
				local odds = MyCompany.Aries.Quest.NPCs.CastMachine_panel.GetOdds(cast_level);
				
				local cast_next_level;
				local odds_next_level;
				if(cast_level)then
					cast_next_level = cast_level + 1
					odds_next_level = MyCompany.Aries.Quest.NPCs.CastMachine_panel.GetOdds(cast_next_level);
				end
				local msg = {
					exID = exID,
					gsids = exTemplate.froms,
					exchanged_gsids = exTemplate.tos,
					cast_level = cast_level,
					odds = odds,
					cast_next_level = cast_next_level,
					odds_next_level = odds_next_level,
					state = "all",
				}
				MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Bind(msg);
			end
			
		end
	end
	
end
--开始建造
function Loom_compose_panel.DoBuild()
	local self = Loom_compose_panel;
	local canBuild = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.CanBuild()
	--缺少物品
	if(not canBuild)then
		local s = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Error_NeedItems();
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	local exchanged_item_gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	if(not exchanged_item_gsid)then return end
	local __,__,__,copies = hasGSItem(exchanged_item_gsid);
	copies = copies or 0;
	--超过最大数
	if(copies >= 100)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>别再做这个啦，你家仓库都放不下了！先去送点给别人再来做吧！</div>";
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
function Loom_compose_panel.__DoBuild()
	local self = Loom_compose_panel;
	local item = self.selected_items[self.selected_index];
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
			if(msg and msg.issuccess)then
				if(msg.obtains)then
					self.__DoBuild__(msg.obtains)
				end
			else
			
			end
		end);
	end
end
function Loom_compose_panel.__DoBuild__(obtains)
	local self = Loom_compose_panel;
	local gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	--失败
	if(not obtains[gsid])then
		local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>很遗憾，本次%s建造失败了；你可以多试几次，或先把抱抱龙建造技能提升后再来建造！ </div>",
						title);
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	local ex_str = "";
	local t = "";
	local ex_num = 0;
	if(obtains[-4])then
		t = "力量值";
		ex_num = obtains[-4];
	elseif(obtains[-6])then
		t = "智慧值";
		ex_num = obtains[-6];
	end
	if(ex_num > 0)then
		ex_str = string.format("并且获得%d点%s。",ex_num,t);
	end
	local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
	local skill = obtains[-7];
	local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s建造成功！抱抱龙提升了%d点建造熟练度；%s建造出的%s是让莫卡帮你出售，还是放回自己背包呢？</div>",
								title,skill,ex_str,title);
		_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					self.DoSell();
				else
					--默认已经放回仓库
				end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Sell_btn_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/BackToBag_btn_32bits.png; 0 0 153 49"});
end
--出售
function Loom_compose_panel.DoSell()
	local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
	local gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	local __,guid,__,__ = hasGSItem(gsid,nil,10001);
	if(not guid)then return end
	commonlib.echo("=====before sell item");
	commonlib.echo(guid);
	ItemManager.SellItem(guid, 1, function(msg) end,function(msg)
		commonlib.echo("=====after sell item");
		commonlib.echo(guid);
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			local price = msg.deltaemoney or 0;
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'> 莫卡已经成功帮你把%s出售啦，当前市场价为%d奇豆！</div>",
							title,price);
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		end
	end)
	
end

