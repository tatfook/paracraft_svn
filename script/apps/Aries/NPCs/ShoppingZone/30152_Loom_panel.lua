--[[
Title: Loom_panel
Author(s): Leio
Date: 2009/12/14

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30152_Loom_panel.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
local Loom_panel = {
	page = nil,
	isLocked = false,--是否处于锁定状态
	selected1_gsid = nil,
	selected2_gsid = nil,
	selected3_gsid = nil,
	
	red_guid = nil,
	green_guid = nil,
	yellow_guid = nil,
	white_guid = nil,
	
	red_selected = nil,
	green_selected = nil,
	yellow_selected = nil,
	white_selected = nil,
	
	progress = 0,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Loom_panel", Loom_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

function Loom_panel.OnInit()
	local self = Loom_panel;
	self.page = document:GetPageCtrl();
end
function Loom_panel.ClosePage()
	local self = Loom_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
	self.Reset();
end
function Loom_panel.RefreshPage()
	local self = Loom_panel;
	if(self.page)then
		
		self.page:Refresh(0.01);
	end
end
function Loom_panel.Reset()
	local self = Loom_panel;
	self.isLocked = false;
	self.selected1_gsid = nil;
	self.selected2_gsid = nil;
	self.selected3_gsid = nil;
	
	self.red_guid = nil;
	self.green_guid = nil;
	self.yellow_guid = nil;
	self.white_guid = nil;
	
	self.red_selected = nil;
	self.green_selected = nil;
	self.yellow_selected = nil;
	self.white_selected = nil;
	
	self.progress = 0;
	
	if(self.timer)then
		self.timer:Change();
	end
end

function Loom_panel.GetAllItems(callbackFunc)
	local self = Loom_panel;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	
	local bag = 12;
	ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
			
			local gsid = 17034; --red
			local bHas, guid = hasGSItem(gsid);
			self.red_guid = guid or 0;
			
			local gsid = 17036; --green
			local bHas, guid = hasGSItem(gsid);
			self.green_guid = guid or 0;
			
			local gsid = 17035; --yellow
			local bHas, guid = hasGSItem(gsid);
			self.yellow_guid = guid or 0;
			
			local gsid = 17037; --white
			local bHas, guid = hasGSItem(gsid);
			self.white_guid = guid or 0;
			
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc();
			end
			
	end, "access plus 20 minutes");
end
function Loom_panel.ResetSelectedItem()
	local self = Loom_panel;
	if(self.isLocked)then return end
	self.selected1_gsid = nil;
	self.selected2_gsid = nil;
	self.selected3_gsid = nil;
	
	
	self.red_selected = nil;
	self.green_selected = nil;
	self.yellow_selected = nil;
	self.white_selected = nil;
	
	self.isLocked = false;
	self.progress = 0;
	if(self.page)then
		self.page:SetValue("slot1", 0);
		self.page:SetValue("slot2", 0);
		self.page:SetValue("slot3", 0);
		self.page:SetValue("progressbar",0);
	end
	self.RefreshPage();
end
--合成
function Loom_panel.DoComposeYarn()
	local self = Loom_panel;
	if(not self.selected1_gsid or not self.selected2_gsid or not self.selected3_gsid) then
		_guihelper.MessageBox("要放入3种毛线才行哦，你放入的毛线不足，无法开始编织。");
		return
	end
	if(self.isLocked)then return end
	self.isLocked = true;--lock ui panel
	
	
	
	if(not self.timer)then
		self.timer = commonlib.Timer:new({callbackFunc = function(timer)
			 self.UpdateProgressBar()
		end})
	end
	self.timer:Change(0,20);
	
	
end
function Loom_panel.ExtendedCost(callbackFunc)
	local self = Loom_panel;
	--合成
	commonlib.echo("before Extended cost Loom_panel");
	local gsids = self.selected1_gsid..","..self.selected2_gsid..","..self.selected3_gsid;
	gsids = commonlib.Encoding.SortCSVString(gsids);
	
	commonlib.echo(gsids);
	if(not gsids)then return end
	
	local ItemManager = System.Item.ItemManager;
	if(gsids == "17034,17035,17037") then
		--141 Make_30061_ChristmasSocks_Red
		ItemManager.ExtendedCost(141, nil, nil, function() 
			log("+++++++ Extended cost Loom_panel Make_30061_ChristmasSocks_Red return: +++++++\n")
			commonlib.echo(msg);
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(gsids);
			end
		end, function() end, "none");
	elseif(gsids == "17035,17036,17037") then
		--142 Make_30062_ChristmasSocks_Green
		ItemManager.ExtendedCost(142, nil, nil, function() 
			log("+++++++ Extended cost Loom_panel Make_30062_ChristmasSocks_Green return: +++++++\n")
			commonlib.echo(msg);
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(gsids);
			end
		end, function() end, "none");
	elseif(gsids == "17034,17035,17036") then
		--143 Make_30063_ChristmasSocks_Yellow
		ItemManager.ExtendedCost(143, nil, nil, function() 
			log("+++++++ Extended cost Loom_panel Make_30063_ChristmasSocks_Yellow return: +++++++\n")
			commonlib.echo(msg);
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(gsids);
			end
		end, function() end, "none");
	elseif(gsids == "17034,17036,17037") then
		--144 Make_30064_ChristmasSocks_White
		ItemManager.ExtendedCost(144, nil, nil, function() 
			log("+++++++ Extended cost Loom_panel Make_30064_ChristmasSocks_White return: +++++++\n")
			commonlib.echo(msg);
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(gsids);
			end
		end, function() end, "none");
	end
end
function Loom_panel.UpdateProgressBar()
	local self = Loom_panel;
	self.progress = self.progress + 1;
	if(self.progress >= 100)then
		if(self.timer)then
			self.timer:Change();
		end
		
		--时间到
		self.ExtendedCost(function(gsids)
			local title = "";
			if(gsids == "17034,17035,17037") then
				--141 Make_30061_ChristmasSocks_Red
				title = "红";
			elseif(gsids == "17035,17036,17037") then
				--142 Make_30062_ChristmasSocks_Green
				title = "绿";
			elseif(gsids == "17034,17035,17036") then
				--143 Make_30063_ChristmasSocks_Yellow
				title = "黄";
			elseif(gsids == "17034,17036,17037") then
				--144 Make_30064_ChristmasSocks_White
				title = "白";
			end
			local s = string.format([[你织出了一只漂亮的%s色圣诞袜，已经放入你的家园仓库了！<br/>要记得<div style="float:left;color:#FF0000">把它放在家园中</div><div style="float:left;">，才能收到圣诞老</div><div>人的礼物哦！</div>]],title);
			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
					local nid = Map3DSystem.User.nid;
					Map3DSystem.App.HomeLand.HomeLandGateway.Gohome(nid);
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/GoHomeImmediately_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
							
			if(self.page)then
				self.page:SetValue("progressbar",0);
				
				self.page:SetValue("slot1", 0);
				self.page:SetValue("slot2", 0);
				self.page:SetValue("slot3", 0);
			end
			self.Reset()
			
			self.GetAllItems(function()
				self.RefreshPage();
			end)
		end)
	end
	if(self.page)then
		self.page:SetValue("progressbar",self.progress);
	end
end
--点击物品
function Loom_panel.OnClickItem(guid, mcmlNode)
	local self = Loom_panel;
	if(self.isLocked)then return end
	local ItemManager = System.Item.ItemManager;
	local item = ItemManager.GetItemByGUID(guid);
	local gsid;
	if(item and item.guid > 0) then
		gsid = item.gsid;
	end
	if(gsid) then
		if(self.selected1_gsid == nil) then
			self.selected1_gsid = gsid;
			self.WhichSelected(gsid);
		elseif(self.selected2_gsid == nil) then
			if(self.selected1_gsid ~= gsid) then
				self.selected2_gsid = gsid;
			self.WhichSelected(gsid);
			end
		elseif(self.selected3_gsid == nil) then
			if(self.selected1_gsid ~= gsid and self.selected2_gsid ~= gsid) then
				self.selected3_gsid = gsid;
			self.WhichSelected(gsid);
			end
		else
			_guihelper.MessageBox("你已经选好3种毛线，开始编织吧。");
			return
		end
		if(self.page)then
			self.page:SetValue("slot1", self.selected1_gsid);
			self.page:SetValue("slot2", self.selected2_gsid);
			self.page:SetValue("slot3", self.selected3_gsid);
			commonlib.echo("===========slot");
			commonlib.echo(self.selected1_gsid);
			commonlib.echo(self.selected2_gsid);
			commonlib.echo(self.selected3_gsid);
		end
		self.RefreshPage();
	end
end
function Loom_panel.WhichSelected(gsid)
	local self = Loom_panel;
	gsid = tonumber(gsid);
	if(not gsid)then return end
	if(gsid == 17034 and not self.red_selected)then --red
		self.red_selected = true;
	elseif(gsid == 17036 and not self.green_selected)then --green
		self.green_selected = true;
	elseif(gsid == 17035 and not self.yellow_selected)then --yellow
		self.yellow_selected = true;
	elseif(gsid == 17037 and not self.white_selected)then --white
		self.white_selected = true;
	end
end