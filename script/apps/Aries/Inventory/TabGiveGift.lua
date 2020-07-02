--[[
Title: code behind for page TabGiveGift.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabGiveGift.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/TabGiveGift.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = Map3DSystem.Item.ItemManager;
local TabGiveGiftPage = {
	nid = nil,
	selectedItem = nil,
	page = nil,
	items = nil,
	default_left_msg = "我想送这个礼物给你，希望你能喜欢！",
	left_msg = nil,
};
commonlib.setfield("MyCompany.Aries.Inventory.TabGiveGiftPage", TabGiveGiftPage);
--显示的物品分类0--6, 0显示所有可以赠送的物品 1-5是具体分类
TabGiveGiftPage.cur_type = 0;
-- data source for items
function TabGiveGiftPage.DS_Func_Items(index)
	local self = TabGiveGiftPage;
	if(not self.items)then return 0 end;
	if(index ~= nil) then
		return self.items[index] or {guid = 0};
	elseif(index == nil) then
		-- fill the 12 tiles per page
		local displaycount = math.ceil(#self.items/12) * 12;
		if(count == 0) then
			displaycount = 12;
		end
		return displaycount;
	end
end
function TabGiveGiftPage.OnInit()
	local self = TabGiveGiftPage;
	self.page = document:GetPageCtrl();
	
	
	--local result = ItemManager.GetAllCanGiftItemGUIDs()
	--self.items = {};
	--if(result)then
		--local k,item_guid;
		--for k,item_guid in ipairs(result) do
			--table.insert(self.items,{guid = item_guid});
		--end
	--end
	if(not self.left_msg)then
		self.left_msg = self.default_left_msg;
	end
end
function TabGiveGiftPage.OnClickItem(guid)
	if(not guid)then return end;
	local self = TabGiveGiftPage;
	self.selectedItem = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
	self.UpdateUI();
end
--选择每一个item后，更新UI
function TabGiveGiftPage.UpdateUI()
	local self = TabGiveGiftPage;
	local item = self.selectedItem;
	if(not item)then return end;
	local gsid = item.gsid;
	Map3DSystem.Item.ItemManager.GetGlobalStoreItem(gsid, "pe:slot_"..tostring(gsid), function(msg)
			if(msg and msg.globalstoreitems and msg.globalstoreitems[1]) then
				local gsItem = msg.globalstoreitems[1];
				local gsItemIcon = gsItem.icon;
				local gsItemName = gsItem.template.name;
				if(gsItemIcon == nil or gsItemIcon == "") then
					-- if no nickname is provided, use a question mark instead
					gsItemIcon = "Texture/Aries/Quest/Question_Mark_32bits.png";
				end
				if(self.page)then
					local content = self.page:GetValue("send_info");
					self.left_msg = content;
					self.page:Refresh(0.1);
					self.page:SetValue("icon",gsItemIcon);
					if(not self.left_msg or self.left_msg == "")then
						self.left_msg = self.default_left_msg;
					end
					self.page:SetValue("send_info",self.left_msg);
				end
			end	
		end);
end
--是将要送给谁的nid，不是Map3DSystem.User.nid
function TabGiveGiftPage.SetNID(nid)
	local self = TabGiveGiftPage;
	self.nid = nid;
end
function TabGiveGiftPage.GetNID()
	local self = TabGiveGiftPage;
	return self.nid;
end
function TabGiveGiftPage.BindBean(bean)
	local self = TabGiveGiftPage;
	self.bean = bean;
end
function TabGiveGiftPage.GetMasterName()
	local self = TabGiveGiftPage;
	--名称信息
	local master_name = "";
	if(self.bean and self.bean.homemaster_info)then
		local homemaster_info = self.bean.homemaster_info;
		master_name = homemaster_info.nickname or "";
	end
	return master_name;
end
function TabGiveGiftPage.DoSend()
	local self = TabGiveGiftPage;
	--名称信息
	local master_name = self.GetMasterName();
	
	local item = self.selectedItem;
	if(not item)then return end
	local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid)
	local item_name = "";
	if(gsItem and gsItem.template)then
		item_name = gsItem.template.name or "";
	end
	--
	local content = self.page:GetValue("send_info");
	local content_len = ParaMisc.GetUnicodeCharNum(content);
	if(content_len > 120)then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>留言不能超过120个字，请重新输入吧。</div>");
		return
	end
	if(not DealDefend.CanPass())then
		self.ClosePage();
		return
	end

	if(not MyCompany.Aries.ExternalUserModule:CanViewUser(self.nid)) then
		_guihelper.MessageBox("不同区之间的用户无法送礼物");
		return;
	end

	local txt = self.page:GetValue("send_info") or "";
	local content = string.format([[你确定要把%s送给<br/><pe:name nid='%s' linked=false/>吗？]],item_name,self.nid);
		_guihelper.MessageBox(content,function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
			
				if(item)then
					
					local msg = {
						sessionkey = Map3DSystem.User.sessionkey,
						guid = item.guid,
						bag = item.bag,
						tonid = tonumber(self.nid),
						msg = txt,
					}
					commonlib.echo("before give gift:");
					commonlib.echo(msg);
					paraworld.homeland.giftbox.Donate(msg,"Giftinfo",function(msg)	
						commonlib.echo("after give gift:");
						commonlib.echo(msg);
						if(msg and msg.issuccess)then
							local to_nid = self.GetNID();
							paraworld.PostLog({action = "send_gift_homeland", to_nid = to_nid, gsid = item.gsid,}, 
								"send_gift_homeland_log", function(msg)
							end);
							_guihelper.MessageBox(string.format("你已经把%s送给<pe:name nid='%s' linked=false/>了！",item_name,self.nid),nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
							
							local hook_msg = { aries_type = "OnGiveGift", to = self.nid, wndName = "main"};
							CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
							
							local hook_msg = { aries_type = "onGiveGift_MPD", to = self.nid, wndName = "main"};
							CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

							NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
							Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftInfo();
							
							self.DoRefreshBag(item.bag)
								
							Map3DSystem.App.profiles.ProfileManager.GetJID(self.nid, function(jid)
								if(jid)then
									--发短信提醒对方，已经给他送出了礼物
									NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
									MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
										msg_type = "gift_remind",
										sender = Map3DSystem.User.nid,
										mail_id = 8000,
									},jid);
								end
							end)
						else
							_guihelper.MessageBox("发送失败！");
						end
					end);
				end	
				self.DoCancel();
			end
		end, _guihelper.MessageBoxButtons.YesNo,nil,{Yes = "确定", No = "取消"});
end
function TabGiveGiftPage.DoCancel()
	local self = TabGiveGiftPage;
	self.selectedItem = nil;
	self.left_msg = nil;
	self.ClosePage();
end
function TabGiveGiftPage.ShowPage(nid)
	local self = TabGiveGiftPage;
	if(System.options.version=="kids") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Inventory/TabGiveGift.kids.html?nid="..nid, 
			name = "TabGiveGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -320,
				y = -250,
				width = 720,
				height = 480,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Inventory/TabGiveGift.teen.html?nid="..nid, 
			name = "TabGiveGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -590/2,
				y = -470/2,
				width = 590,
				height = 470,
		});
	end
	self.DoChangeType(0);
end
function TabGiveGiftPage.ClosePage()
	local self = TabGiveGiftPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="TabGiveGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end
function TabGiveGiftPage.DoRefreshBag(bag)
	if(not bag)then return end
	local config = Map3DSystem.App.HomeLand.HomeLandConfig;
	local Bag_Gift = config.Bag_Gift or 20001;
	Map3DSystem.Item.ItemManager.GetItemsInBag(bag, "GiveGift", function(msg)
			local pe_slot = commonlib.gettable("Map3DSystem.mcml_controls.pe_slot");
			pe_slot.RefreshShortcutContainingPageCtrls();
		end, "access plus 0 day");
	
	if(bag ~= Bag_Gift) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(Bag_Gift, "ReceiveGift", function(msg)
			end, "access plus 0 day");
	end
end
function TabGiveGiftPage.DoChangeType(type)
	local self = TabGiveGiftPage;
	self.cur_type = type;
	self.items = self.FindDataSource(type);
	if(self.page)then
		self.page:Refresh(0.1);
	end
end
-- find data from items can be gift
-- @param type:0 is all, 1 - 6 is detail of type
-- return a table
TabGiveGiftPage.filter_maps = {
	[1] = {25},--bag number
	[2] = {23},
	[3] = {1},
	[4] = {44,52},
	--[5] = {0,12,14}, -- use special id to filter
	[6] = {25, 23, 1, 44, 52, },
}
TabGiveGiftPage.special_maps = {
	17152,17153,17154,998,12010,12005,12006,
	17131,17132,17133,17134,17135,17136,17137,17138,17139,17140,
	17151,
	17176,
	17144,17145,17146,17147,17148,
}
function TabGiveGiftPage.FindDataSource(type)
	local self = TabGiveGiftPage;
	type = type or 0;
	local result = ItemManager.GetAllCanGiftItemGUIDs()
	if(not result)then return end
	local list = {};
	--type = 0返回所有可以赠送的物品
	if(type == 0)then
		local k,item_guid;
		for k,item_guid in ipairs(result) do
			local item = ItemManager.GetItemByGUID(item_guid);
			if(item and (not item.serverdata or item.serverdata == "")) then
				table.insert(list,{guid = item_guid});
			end
		end
		return list;
	end
	local function is_include(bags,bag)
		if(not bags)then return end
		local k,v;
		for k,v in ipairs(bags) do
			if(v == bag)then
				return true;
			end
		end
	end
	local function is_special(gsid)
		local k,v;
		for k,v in ipairs(self.special_maps) do
			if(v == gsid)then
				return true;
			end
		end
	end
	--type = 1 - 6
	local k,item_guid;
	for k,item_guid in ipairs(result) do
		local item = ItemManager.GetItemByGUID(item_guid);
		if(item and (not item.serverdata or item.serverdata == "")) then
			local gsid = item.gsid;
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem)then
				local class = gsItem.template.class;
				local subclass = gsItem.template.subclass;
				local bagfamily = gsItem.template.bagfamily;
				if( type > 0 and type < 5)then
					local bags = self.filter_maps[type];
					if(is_include(bags,bagfamily))then
						table.insert(list,{guid = item_guid});
					end
				elseif( type == 5)then
					if(is_special(gsid))then
						table.insert(list,{guid = item_guid});
					end
				else
					local bags = self.filter_maps[type];
					--除了1-5类型以外所有的物品
					if(not is_include(bags,bagfamily) and not is_special(gsid))then
						table.insert(list,{guid = item_guid});
					end
				end
			end
		end
	end
	return list;
end