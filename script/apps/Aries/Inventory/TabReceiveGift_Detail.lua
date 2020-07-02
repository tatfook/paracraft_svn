--[[
Title: code behind for page TabReceiveGift_Detail.html
Author(s): Leio
Date: 2009/12/2
Desc:  script/apps/Aries/Inventory/TabReceiveGift_Detail.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/TabReceiveGift_Detail.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local TabReceiveGift_DetailPage = {
	selectedItem = nil,
	
};
commonlib.setfield("MyCompany.Aries.Inventory.TabReceiveGift_DetailPage", TabReceiveGift_DetailPage);


function TabReceiveGift_DetailPage.OnInit()
	local self = TabReceiveGift_DetailPage;
	self.page = document:GetPageCtrl();
	
	if(self.page)then
		if(System.options.version=="kids") then
			self.page:SetValue("send_info",self.send_info or "");
			self.page:SetValue("icon",self.gsItemIcon or "");
		else
			self.page:SetValue("send_info_teen",self.send_info or "");
			self.page:SetValue("icon_teen",self.gsItemIcon or "");
		end
	end
end
--items 记录当前礼物的数量
function TabReceiveGift_DetailPage.Bind(nid,selectedItem,send_info,gsItemIcon,item_tooltip,items_mapping,items)
	local self = TabReceiveGift_DetailPage;
	self.nid = nid;
	self.selectedItem = selectedItem;
	self.send_info = send_info;
	self.gsItemIcon = gsItemIcon;
	self.item_tooltip = item_tooltip;
	self.items_mapping = items_mapping;
	self.items = items;
end

function TabReceiveGift_DetailPage.DoAccept()
	local self = TabReceiveGift_DetailPage;
	local item = self.selectedItem;
	local item_detail = self.GetGiftInfo(item.guid)
	commonlib.echo("============gift detail");
	commonlib.echo(item_detail);
	if(item and item_detail)then
		--名称信息
		local item_name = self.item_tooltip or "";
		local user_name = "";
		local msg = {
				nids = tostring(item_detail.from),
				--cache_policy = "access plus 0 day",
			};
		commonlib.echo("==========before get user info in TabReceiveGift_DetailPage");
		commonlib.echo(msg);
		paraworld.users.getInfo(msg, "TabReceiveGift_DetailPage.GetUserInfo", function(msg)
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
						
								local from_nid = item_detail.from;
								paraworld.PostLog({action = "get_gift_homeland", from_nid = from_nid, gsid = item.gsid,}, 
										"get_gift_homeland_log", function(msg)
								end);

								_guihelper.MessageBox(string.format("%s(%d)送给你的%s已经放入你的%s中了！",user_name or "",item_detail.from or 0,item_name or "",TabReceiveGift_DetailPage.store_place or "背包"),function(res)
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
									self.ClosePage()
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

function TabReceiveGift_DetailPage.DoRefuse()
	local self = TabReceiveGift_DetailPage;

	local item = self.selectedItem;
	if(not item)then return end
	local item_detail = self.GetGiftInfo(item.guid)
	if(item_detail)then
		--名称信息
		local item_name = self.item_tooltip or "";
		local user_name = "";
		local msg = {
				nids = tostring(item_detail.from),
				--cache_policy = "access plus 0 day",
			};
			commonlib.echo("==========before get user info in TabReceiveGift_DetailPage");
		commonlib.echo(msg);
		paraworld.users.getInfo(msg, "TabReceiveGift_DetailPage.GetUserInfo", function(msg)
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
													self.ClosePage()
											else
												_guihelper.MessageBox("丢弃失败");
											end
										end);
							else
								 --self.ClosePage()
							end
						end,_guihelper.MessageBoxButtons.YesNo);
		
				end
		end);
		
	
	end
end
function TabReceiveGift_DetailPage.RemoveItem(id)
	local self = TabReceiveGift_DetailPage;
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
function TabReceiveGift_DetailPage.ShowPage()
		local self = TabReceiveGift_DetailPage;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Inventory/TabReceiveGift_Detail.html", 
			name = "TabReceiveGift_DetailPage.ShowPage", 
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

function TabReceiveGift_DetailPage.ClosePage()
	local self = TabReceiveGift_DetailPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="TabReceiveGift_DetailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.nid = nil;
	self.selectedItem = nil;
	self.send_info = nil;
	self.gsItemIcon = nil;
	self.item_tooltip = nil;
	self.items_mapping = nil;
	self.items = nil;
	
	NPL.load("(gl)script/apps/Aries/Inventory/TabReceiveGift.lua");
	MyCompany.Aries.Inventory.TabReceiveGiftPage.ClosePage_Detail();
end
function TabReceiveGift_DetailPage.GetGiftInfo(id)
	local self = TabReceiveGift_DetailPage;
	return self.items_mapping[id];
end
function TabReceiveGift_DetailPage.DoRefreshBag(bagfamily)
	commonlib.echo("===================do1");
	if(not bagfamily)then return end
	local self = TabReceiveGift_DetailPage;
	local config = Map3DSystem.App.HomeLand.HomeLandConfig;
	local Bag_Gift = config.Bag_Gift or 20001;
	Map3DSystem.Item.ItemManager.GetItemsInBag(Bag_Gift, "ReceiveGift", function(msg)
		end, "access plus 0 day");
	if(bagfamily ~= Bag_Gift) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(bagfamily, "ReceiveGift_bagfamily", function(msg)
			end, "access plus 0 day");
	end
end