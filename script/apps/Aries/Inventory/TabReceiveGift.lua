--[[
Title: code behind for page TabReceiveGift.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabReceiveGift.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/TabReceiveGift.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Inventory/TabReceiveGift_Detail.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local TabReceiveGiftPage = {
	nid = nil,
	selectedItem = nil,
	page = nil,
	items = nil,
	gift_state = "overview", -- "overview" or "detail"
	item_tooltip = nil,
	store_place = nil,--"背包" or "仓库"   bagfamily>=40 <=60:仓库
};
commonlib.setfield("MyCompany.Aries.Inventory.TabReceiveGiftPage", TabReceiveGiftPage);

-- data source for items
function TabReceiveGiftPage.DS_Func_Items(index)
	local self = TabReceiveGiftPage;
	commonlib.echo("=================self.items");
	commonlib.echo(self.items);
	commonlib.echo(index);
	if(not self.items)then return 0 end;
	if(index ~= nil) then
		if(index <= #self.items) then
			return self.items[index];
		else
			return {id = 0};
		end
	elseif(index == nil) then
		local count = #self.items;
		if(count == 0) then
			count = 1;
		end
		-- fill the 12 tiles per page
		count = math.ceil(count/12) * 12;
		return count;
	end
end
function TabReceiveGiftPage.OnInit()
	local self = TabReceiveGiftPage;
	self.page = document:GetPageCtrl();
	
end

function TabReceiveGiftPage.OnClickItem(guid)
	if(not guid)then return end;
	local self = TabReceiveGiftPage;
	self.selectedItem = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
	self.UpdateUI();
end
--选择每一个item后，更新UI
function TabReceiveGiftPage.UpdateUI()
	local self = TabReceiveGiftPage;
	local item = self.selectedItem;
	local item_detail = self.GetGiftInfo(item.guid)
	if(not item or not item_detail)then return end;
	local gsid = item.gsid;
	Map3DSystem.Item.ItemManager.GetGlobalStoreItem(gsid, "pe:slot_"..tostring(gsid), function(msg)
			if(msg and msg.globalstoreitems and msg.globalstoreitems[1]) then
				local gsItem = msg.globalstoreitems[1];
				local gsItemIcon = gsItem.icon;
				local gsItemName = gsItem.template.name;
				local bagfamily = gsItem.template.bagfamily;
				if(bagfamily >=40 and bagfamily <=60)then
					TabReceiveGiftPage.store_place = "仓库";
				else
					TabReceiveGiftPage.store_place = "背包";
				end
				if(gsItemIcon == nil or gsItemIcon == "") then
					-- if no nickname is provided, use a question mark instead
					gsItemIcon = "Texture/Aries/Quest/Question_Mark_32bits.png";
				end
				TabReceiveGiftPage.giftfromnid = tonumber(item_detail.from);
				TabReceiveGiftPage.isgiftfromnid = true;
				
				local adddate = item_detail.adddate;
				local msg = item_detail.msg;
				if(not msg or msg == "")then
					msg = "没有留言";
				end
				local send_info = string.format("%s\r\n赠送时间：%s",msg,adddate or "");
				self.page:SetValue("send_info",send_info);
				self.page:SetValue("icon",gsItemIcon);
				self.item_tooltip = gsItemName or "";
				--self.gift_state = "detail";
				--self.page:Refresh(0);
				
				
				MyCompany.Aries.Inventory.TabReceiveGift_DetailPage.Bind(self.giftfromnid,self.selectedItem,send_info,gsItemIcon,self.item_tooltip,self.items_mapping,self.items);
				MyCompany.Aries.Inventory.TabReceiveGift_DetailPage.ShowPage();
			end	
		end);
end
function TabReceiveGiftPage.SetNID(nid)
	local self = TabReceiveGiftPage;
	self.nid = nid;
end
function TabReceiveGiftPage.GetNID()
	local self = TabReceiveGiftPage;
	return self.nid;
end
function TabReceiveGiftPage.BindBean(bean)
	local self = TabReceiveGiftPage;
	self.bean = bean;
end
function TabReceiveGiftPage.DoAccept()
	local self = TabReceiveGiftPage;
	local item = self.selectedItem;
	local item_detail = self.GetGiftInfo(item.guid)
	if(item and item_detail)then
		--名称信息
		local item_name = self.item_tooltip or "";
		local user_name = "";
		local msg = {
				nids = item_detail.from,
				--cache_policy = "access plus 0 day",
			};
		paraworld.users.getInfo(msg, "TabReceiveGiftPage.GetUserInfo", function(msg)
				if(msg and msg.users)then
					user_name = msg.users[1].nickname;
					
					---------------
					local msg = {
						sessionkey = Map3DSystem.User.sessionkey,
						guid = item.guid,
					}
					commonlib.echo("before receive gift:");
					commonlib.echo(msg);
					paraworld.homeland.giftbox.AcceptGift(msg,"Giftinfo",function(msg)	
						commonlib.echo("after receive gift");
						commonlib.echo(msg);
						if(msg and msg.issuccess)then
						
								_guihelper.MessageBox(string.format("%s(%d)送给你的%s已经放入你的%s中了！",user_name or "",item_detail.from or 0,item_name or "",TabReceiveGiftPage.store_place or "背包"),function(res)
								if(res and res == _guihelper.DialogResult.OK) then
									NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
									Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftInfo();
									Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftDetail();
									self.RemoveItem(item.guid);
									local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid);
									if(gsItem) then
										local bagfamily = gsItem.template.bagfamily;
										self.DoRefreshBag(bagfamily);
									end
									--self.ClosePage_Detail()
								end
							end, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
						else
							if(msg and msg.errorcode == 424)then
								local s = string.format("你拥有%s的数量太多了，清理下你的背包吧！",item_name or "");
								_guihelper.MessageBox(s);
							else
								_guihelper.MessageBox("收取失败！");
							end
						end
					end);
				end
		end);
	end
end
function TabReceiveGiftPage.ShowUserPanel(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
function TabReceiveGiftPage.DoRefuse()
	local self = TabReceiveGiftPage;

	local item = self.selectedItem;
	if(not item)then return end
	local item_detail = self.GetGiftInfo(item.guid)
	if(item_detail)then
		--名称信息
		local item_name = self.item_tooltip or "";
		local user_name = "";
		local msg = {
				nids = item_detail.from,
				--cache_policy = "access plus 0 day",
			};
		paraworld.users.getInfo(msg, "TabReceiveGiftPage.GetUserInfo", function(msg)
				if(msg and msg.users)then
					user_name = msg.users[1].nickname;
					
						_guihelper.MessageBox(string.format("你确定要把%s(%d)送给你的%s丢掉吗?",user_name or "",item_detail.from or 0,item_name or ""),function(res)
							if(res and res == _guihelper.DialogResult.Yes) then
										local msg = {
											sessionkey = Map3DSystem.User.sessionkey,
											guid = item.guid,
										}
										commonlib.echo("before refuse gift:");
										commonlib.echo(msg);
										paraworld.homeland.giftbox.ChuckGift(msg,"Giftinfo",function(msg)	
											commonlib.echo("after refuse gift:");
											commonlib.echo(msg);
											if(msg and msg.issuccess)then
													NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
													Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftInfo();
													Map3DSystem.App.HomeLand.HomeLandGateway.ReloadGiftDetail();
													self.RemoveItem(item.guid);
													local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid);
													if(gsItem) then
														local bagfamily = gsItem.template.bagfamily;
														self.DoRefreshBag(bagfamily);
													end
													--self.ClosePage_Detail()
											else
												_guihelper.MessageBox("丢弃失败");
											end
										end);
							else
								 --self.ClosePage_Detail()
							end
						end,_guihelper.MessageBoxButtons.YesNo);
		
				end
		end);
		
	
	end
end
function TabReceiveGiftPage.RemoveItem(id)
	local self = TabReceiveGiftPage;
	if(self.items and id)then
		local k,item;
		for k,item in ipairs(self.items) do
			if(item.id == id)then
				table.remove(self.items,k);
				if(self.items_mapping)then
					self.items_mapping[id] = nil;
				end
				return
			end
		end
	end
end
function TabReceiveGiftPage.DoClose()
	local self = TabReceiveGiftPage;
	self.selectedItem = nil;
	TabReceiveGiftPage.store_place = nil;
	self.ClosePage();
end
function TabReceiveGiftPage.ShowPage(giftinfo_detail)
	local self = TabReceiveGiftPage;
	if(System.options.version=="kids") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Inventory/TabReceiveGift.kids.html", 
			name = "TabReceiveGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -190,
				y = -250,
				width = 380,
				height = 480,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Inventory/TabReceiveGift.teen.html", 
			name = "TabReceiveGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -190,
				y = -250,
				width = 380,
				height = 480,
		});
	end
		
	local config = Map3DSystem.App.HomeLand.HomeLandConfig;
	local Bag_Gift = config.Bag_Gift or 20001;
	commonlib.echo("===================before load bag in TabReceiveGiftPage");
	Map3DSystem.Item.ItemManager.GetItemsInBag(Bag_Gift, "ReceiveGift", function(msg)
			
		self.items = nil;
		self.selectedItem = nil;
		--[[
		/// 返回值：
		///     gifts[list]
		///         id
		///         from
		///         gsid
		///         msg
		///         adddate
		--]]
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
		local __,items = Map3DSystem.App.HomeLand.HomeLandGateway.GetGiftDetail();
		commonlib.echo("===================after load bag in TabReceiveGiftPage");
		commonlib.echo(items);
		self.items = items or {};
		if(giftinfo_detail)then
			self.items = giftinfo_detail;
		end
		self.items_mapping = {};
		local k,item;
		for k,item in ipairs(self.items) do
			self.items_mapping[item.id] = item;
		end
		if(self.page)then
			self.page:Refresh(0.01);
		end
	end, "access plus 0 day");
end
function TabReceiveGiftPage.ClosePage_Detail()
	local self = TabReceiveGiftPage;
	self.gift_state = "overview";
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
function TabReceiveGiftPage.ClosePage()
	local self = TabReceiveGiftPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="TabReceiveGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.gift_state = "overview";
end
function TabReceiveGiftPage.GetGiftInfo(id)
	local self = TabReceiveGiftPage;
	return self.items_mapping[id];
end
function TabReceiveGiftPage.DoRefreshBag(bagfamily)
	if(not bagfamily)then return end
	local self = TabReceiveGiftPage;
	local config = Map3DSystem.App.HomeLand.HomeLandConfig;
	local Bag_Gift = config.Bag_Gift or 20001;
	
	Map3DSystem.Item.ItemManager.GetItemsInBag(bagfamily, "ReceiveGift_bagfamily", function(msg)
			self.ClosePage_Detail();
		end, "access plus 0 day");
	if(bagfamily ~= Bag_Gift) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(Bag_Gift, "ReceiveGift", function(msg)
			end, "access plus 0 day");
	end
end