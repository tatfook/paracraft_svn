--[[
Title: code behind for page TabMountOthers.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabMountOthers.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/TabMountOthers.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local TabMountOthersPage = {
	nid = nil,
	panelState = false,
	pet_dragon = nil,--坐骑实例
};
commonlib.setfield("MyCompany.Aries.Inventory.TabMountOthersPage", TabMountOthersPage);
function TabMountOthersPage.OnInit()
	TabMountOthersPage.page = document:GetPageCtrl();
end
-- The data source for items
function TabMountOthersPage.DS_Func_Items(dsTable, index, pageCtrl)      
	-- get the class of the 
	local class = "mount";
	local subclass = "feed";
	
    if(not dsTable.status) then
        -- use a default cache
        TabMountOthersPage.GetItems(class, subclass, pageCtrl, "access plus 0", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end
function TabMountOthersPage.ShowPage(nid)
	local self = TabMountOthersPage;
	if(not nid)then return end
		self.nid = nid;
		
		-- hide the item panel
		TabMountOthersPage.SetPanelState(false);
		
		local Pet = MyCompany.Aries.Pet;
		Pet.InitOPCDragonPet(nid, function(msg)
			---- check if other player dragon fetched
			--if(not Pet.IsOPCDragonFetchedFromSophie(nid)) then
				--_guihelper.MessageBox("他还没有领回自己的抱抱龙呢！");
				--return;
			--end
			
			System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/Inventory/TabMountOthers.html", 
					name = "TabMountOthersPage.ShowPage", 
					app_key = MyCompany.Aries.app.app_key, 
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
		end)
		--local ItemManager = Map3DSystem.Item.ItemManager;
		--ItemManager.GetItemsInOPCBag(nid, 0, "TabMountOthersPage"..nid, function(msg)
				--local item = ItemManager.GetOPCMountPetItem(nid);
				--
				----获取坐骑item的描述
				--local pet_item = ItemManager.GetOPCMountPetItem(nid);
				--if(pet_item)then
					--local petid = pet_item.guid;
					--self.pet_dragon = MyCompany.Aries.Pet.DragonPet:new{
						--nid = nid,
						--petid = petid,
					--}
					--self.pet_dragon:GetRemoteValue(function(msg)
						--
						--self.pet_dragon:ChangeState("home");
						--self.pet_dragon:InitPetState();
					--
						--System.App.Commands.Call("File.MCMLWindowFrame", {
							--url = "script/apps/Aries/Inventory/TabMountOthers.html", 
							--name = "TabMountOthersPage.ShowPage", 
							--app_key = MyCompany.Aries.app.app_key, 
							--isShowTitleBar = false,
							--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
							--style = CommonCtrl.WindowFrame.ContainerStyle,
							--zorder = 1,
							--isTopLevel = true,
							--allowDrag = false,
							--directPosition = true,
								--align = "_ct",
								--x = -320,
								--y = -250,
								--width = 720,
								--height = 480,
						--});
					--end)
				--end
		--end, "access plus 5 minutes");
end

function TabMountOthersPage.SetPanelState(v)
	local self = TabMountOthersPage;
	self.panelState = v;
end

function TabMountOthersPage.GetPanelState()
	local self = TabMountOthersPage;
	return self.panelState;
end
function TabMountOthersPage.RefreshPage()
	local self = TabMountOthersPage;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
function TabMountOthersPage.ClosePage()
	local self = TabMountOthersPage;
	--ParaUI.Destroy("TabMountOthersPage");
	self.nid = nil;
	self.pet_dragon = nil;
    TabMountOthersPage.SetPanelState(false);
	
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="TabMountOthersPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.UnregisterHook();	
	
	TabMountOthersPage.language = nil;
	if(TabMountOthersPage.speak_timer)then
		TabMountOthersPage.speak_timer:Change();
	end
end
function TabMountOthersPage.OnClickItem(guid)
	if(not guid)then return end;
	local self = TabMountOthersPage;
	local item = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
	--commonlib.echo("OnClickItem后：");
	--commonlib.echo(guid);
	--commonlib.echo(item);
	if(item)then
		self.DoAction(item.bag,item.guid,item.gsid);
	end
end
function TabMountOthersPage.DoAction(bag,guid,gsid)
	local self = TabMountOthersPage;
	if(not self.nid)then 
		_guihelper.MessageBox("nid is nil!");
		return
	end
	local nid = self.nid;
	if(not bag or not guid or not gsid)then return end
		local ItemManager = Map3DSystem.Item.ItemManager;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
		if(gsItem) then
			--commonlib.echo("喂食的gsItem");
			--commonlib.echo(gsItem);
			local class = tonumber(gsItem.template.class);
			local subclass = tonumber(gsItem.template.subclass);
			local item = {
					guid = guid,
					bag = bag,
				}
			local bagfamily = gsItem.template.bagfamily;
			local bag = bag;
			if(class == 2 and subclass == 1) then
				-- this is a food 吃
				--NOTE: friendlyness inc is NOT valid for other user dragon
				if(gsItem.template and gsItem.template.stats and gsItem.template.stats[7]) then
					_guihelper.MessageBox(string.format([[<div style="margin-left:30px;margin-top:30px;">%s只能喂给自己的抱抱龙。</div>]], gsItem.template.name));
					return;
				end
				commonlib.echo("=========begin do feed:");
				MyCompany.Aries.Pet.DoFeed(nid,item,function(msg)
					self.RefreshPage();
					commonlib.echo("=========do feed:");
					commonlib.echo(item);
					commonlib.echo(msg);
					if(msg.issuccess)then
						self.UpdateBag(bagfamily,bag);
						MyCompany.Aries.Pet.DoRefreshPetsInHomeland();
						-- call hook for pet feed
						local msg = { aries_type = "PetFeedOther", nid = nid, gsid = gsid, wndName = "main"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
					else
						self.ShowError(msg.error);
					end
				end);
			elseif(class == 2 and subclass == 2) then
				-- this is a body lotion 洗澡
				commonlib.echo("=========begin do bath:");
				MyCompany.Aries.Pet.DoBath(nid,item,function(msg)
					self.RefreshPage();
					commonlib.echo("=========do bath:");
					commonlib.echo(item);
					commonlib.echo(msg);
					if(msg.issuccess)then
						self.UpdateBag(bagfamily,bag);
						MyCompany.Aries.Pet.DoRefreshPetsInHomeland();
						-- call hook for pet feed
						local msg = { aries_type = "PetBathOther", nid = nid, gsid = gsid, wndName = "main"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
					else
						self.ShowError(msg.error);
					end
				end);
			elseif(class == 2 and subclass == 3) then
				-- this is a toy 玩具
				commonlib.echo("=========begin do play toy:");
				MyCompany.Aries.Pet.DoPlayToy(nid,item,function(msg)
					self.RefreshPage();
					commonlib.echo("=========do play toy:");
					commonlib.echo(item);
					commonlib.echo(msg);
					if(msg.issuccess)then
						self.UpdateBag(bagfamily,bag);
						MyCompany.Aries.Pet.DoRefreshPetsInHomeland();
						-- call hook for pet feed
						local msg = { aries_type = "PetPlayToyOther", nid = nid, gsid = gsid, wndName = "main"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
					else
						self.ShowError(msg.error);
					end
				end);
			elseif(class == 2 and subclass == 4) then
				-- this is a medichine 药 或者复活
				if(gsItem.template.stat_type_1 == 8)then
					commonlib.echo("=========begin do medicine:");
					MyCompany.Aries.Pet.DoMedicine(nid,item,function(msg)
						self.RefreshPage();
						commonlib.echo("=========do medicine:");
						commonlib.echo(item);
						commonlib.echo(msg);
						if(msg.issuccess)then
							self.UpdateBag(bagfamily,bag);
							MyCompany.Aries.Pet.DoRefreshPetsInHomeland();
							-- call hook for pet feed
							local msg = { aries_type = "PetMedicineOther", nid = nid, gsid = gsid, wndName = "main"};
							CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
						else
							self.ShowError(msg.error);
						end
					end);
				elseif(gsItem.template.stat_type_1 == 9)then
					commonlib.echo("=========begin do relive:");
					MyCompany.Aries.Pet.DoRelive(nid,item,function(msg)
						self.RefreshPage();
						commonlib.echo("=========do relive:");
						commonlib.echo(item);
						commonlib.echo(msg);
						if(msg.issuccess)then
							self.UpdateBag(bagfamily,bag)
							
							MyCompany.Aries.Pet.DoRefreshPetsInHomeland();
						else
							self.ShowError(msg.error);
						end
					end);
				end
				
			end
		else
			log("error: invalid use of item for pet food guid:"..guid.."\n");
			return;
		end
end
function TabMountOthersPage.GetItems(class, subclass, pageCtrl, cachepolicy, output)
	-- find the right bag for inventory items
	local bag;
	if(class == "character" and subclass == "makeup") then
		bag = 1;
	elseif(class == "character" and subclass == "consumable") then
		bag = 81;
	elseif(class == "character" and subclass == "collect") then
		bag = 12;
	elseif(class == "character" and subclass == "reading") then
		bag = 10001;
	elseif(class == "mount" and subclass == "makeup") then
		bag = 21;
	elseif(class == "mount" and subclass == "feed") then
		bag = 22;
	end
	if(bag == nil) then
		-- return empty datasource table, if no bag id is specified
		output.Count = 0;
		commonlib.resize(output, output.Count)
		return;
	end
	-- fetching inventory items
	output.status = 1;
	local ItemManager = System.Item.ItemManager;
	ItemManager.GetItemsInBag(bag, "ariesitems", function(msg)
		if(msg and msg.items) then
			local count = ItemManager.GetItemCountInBag(bag);
			commonlib.echo(count);
			if(count == 0) then
				count = 1;
			end
			-- fill the 12 tiles per page
			count = math.ceil(count/12) * 12;
			local i;
			for i = 1, count do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item ~= nil) then
					output[i] = {guid = item.guid};
				else
					output[i] = {guid = 0};
				end
			end
			output.Count = count;
			commonlib.resize(output, output.Count);
			-- fetched inventory items
			output.status = 2;
			pageCtrl:Refresh();
		else
			output.Count = 0;
			commonlib.resize(output, output.Count);
			-- fetched inventory items
			output.status = 2;
			pageCtrl:Refresh();
		end
	end, cachepolicy);
end
function TabMountOthersPage.ShowError(error)
	local info = Map3DSystem.App.HomeLand.HomeLandError[error];
	if(info)then
			info = info.error;
	end
	commonlib.echo({error,info});
end
function TabMountOthersPage.UpdateBag(bagfamily, bag)
	-- we don't need to update the bag aggressively with "access plus 0 day"
	-- item system has destoryed the used item silently in local server
	if(bagfamily) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(bagfamily, "", function(msg3)
			Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
		end, "access plus 3 minute");
	end
	if(bag and bag ~= bagfamily) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(bag, "", function(msg)
			Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
		end, "access plus 3 minute");
	end
end
function TabMountOthersPage.RegisterHook()
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = MyCompany.Aries.Inventory.TabMountOthersPage.HookHandler, 
		hookName = "TabMountOthersPage_PetAction", appName = "Aries", wndName = "main"});
end


function TabMountOthersPage.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TabMountOthersPage_PetAction", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end
function TabMountOthersPage.HookHandler(nCode, appName, msg, value)
	if(msg.pet_action_type == "pet_action_feeding")then
		TabMountOthersPage.language = msg.language;
		
		--在GetMountPetIFrame_URL里面由此刷新
		
		--说话周期
		NPL.load("(gl)script/ide/timer.lua");
		if(TabMountOthersPage.speak_timer)then
			TabMountOthersPage.speak_timer:Change();
		else
			TabMountOthersPage.speak_timer = commonlib.Timer:new({callbackFunc = function(timer)
				--清空语言
				TabMountOthersPage.language = nil;
				if(TabMountOthersPage.page)then
					TabMountOthersPage.page:Refresh(0.1);
				end
			end})
		end
		--5000 millisecond 后结束
		TabMountOthersPage.speak_timer:Change(5000, nil)
	end
	return nCode;
end