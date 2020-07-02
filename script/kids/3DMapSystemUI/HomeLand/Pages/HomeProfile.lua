--[[
Title: code behind for page HomeProfile.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/HomeProfile.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/HomeProfile.lua");
-------------------------------------------------------
]]
local HomeProfilePage = commonlib.gettable("MyCompany.Aries.Inventory.HomeProfilePage");
HomeProfilePage.show = false;
HomeProfilePage.visitcnt = 0;
HomeProfilePage.giftcnt = 0;
HomeProfilePage.boxcnt = 0;

function HomeProfilePage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local self = HomeProfilePage;
	self.DestroyPage();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/HomeProfile.html", 
			name = "HomeProfilePage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			directPosition = true,
				align = "_rt",
				x = -80,
				y = 80,
				width = 128,
				height = 365,
		});
		
	self.AwayButton_Build();
end
function HomeProfilePage.DestroyPage()
	local self = HomeProfilePage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="HomeProfilePage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
	self.AwayButton_Destroy();
end
function HomeProfilePage.ClosePage()
	local self = HomeProfilePage;
	self.DestroyPage();
	self.Clear();
end
function HomeProfilePage.AwayButton_Destroy()
	local name = "HomeProfilePage_AwayButton";
	local _this = ParaUI.GetUIObject(name)
	if(_this and _this:IsValid())then
		ParaUI.Destroy(name);
	end
end
function HomeProfilePage.AwayButton_Build()
	--local self = HomeProfilePage;
	--local name = "HomeProfilePage_AwayButton";
	--self.AwayButton_Destroy()
	--NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	--local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos_AwayBtn;
	--local _this = ParaUI.CreateUIObject("button",name, pos.align, pos.left,pos.top,pos.width,pos.height);
	--_this.tooltip = "离开";
	--_this.background = "Texture/Aries/Homeland/away.png";
	--_this.onclick = ";Map3DSystem.App.HomeLand.HomeLandGateway.Away();"
	--
	--_this.zorder = 0;
	--_this:AttachToRoot();
end
function HomeProfilePage.DoClick(name)
	local self = HomeProfilePage;
	if(name == "visitors")then
		Map3DSystem.App.HomeLand.HomeLandGateway.ShowHomeInfo();
	elseif(name == "gifts")then
		Map3DSystem.App.HomeLand.HomeLandGateway.ShowGiftInfo();
	elseif(name == "petmanager")then
		local nid = Map3DSystem.App.HomeLand.HomeLandGateway.nid;
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPage.lua");
		local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
		CombatPetPage.ShowPage(nid);

		--System.App.Commands.Call("File.MCMLWindowFrame", {
			--url = "script/kids/3DMapSystemUI/HomeLand/Pages/FollowPetManager.html?nid="..nid, 
			--name = "FollowPetManager", 
			--app_key = MyCompany.Aries.app.app_key, 
			--isShowTitleBar = false,
			----DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			--zorder = 2,
			--allowDrag = false,
			--isTopLevel = true,
			--directPosition = true,
				--align = "_ct",
				--x = -632/2,
				--y = -550/2,
				--width = 632,
				--height = 486,
			--DestroyOnClose = true,
		--});
	elseif(name == "shop")then
		--commonlib.echo("NOTE by Andy: Leio, i turn off the PEBook page to use MCML page for purchase example");
		--System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Aries/Inventory/SampleShopView.html",});
		
		local url = "script/apps/Aries/Books/HomeDecoMagazine.html";
		self.ShowBook(url)
		
	elseif(name == "shop_inside")then
		local url = "script/apps/Aries/Books/HomeIndoorMagazine.html";
		self.ShowBook(url)
	elseif(name == "edit")then
		NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
		local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
		local can_pass = DealDefend.CanPass();
		if(not can_pass)then
			return
		end
		Map3DSystem.App.HomeLand.HomeLandGateway.EditHouse();
		local hook_msg = { aries_type = "OnOpenWareHouse", wndName = "homeland"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	elseif(name == "save")then
		Map3DSystem.App.HomeLand.HomeLandGateway.SaveHouse();
		local hook_msg = { aries_type = "OnHomelandSaved", wndName = "homeland"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
end
function HomeProfilePage.ShowBook(url)
	if(not url)then return end
	NPL.load("(gl)script/apps/Aries/Books/BookPreloadAssets.lua");
	local download_list = MyCompany.Aries.Books.BookPreloadAssets.GetAssetList(url);

	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");

	commonlib.echo("=============before HomeDecoMagazine");
	Map3DSystem.App.MiniGames.PreLoaderDialog.StartDownload({download_list = download_list,txt = {"正在打开图书，请稍等......"}},function(msg)
		commonlib.echo("=============after HomeDecoMagazine");
		commonlib.echo(msg);
		if(msg and msg.state == "finished")then
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = url, 
				name = "GameObjectMCMLBrowser", 
				isShowTitleBar = false,
				allowDrag = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				isTopLevel = true,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
						x = -848/2,
						y = -260,
						width = 848,
						height = 620,
			});
		end
	end);
		
end
function HomeProfilePage.Clear()
	local self = HomeProfilePage;
	self.show = false;
	self.page = nil;
	self.curState = nil;
	self.placeState = nil;
	self.visitcnt = 0;
	self.giftcnt = 0;
	self.boxcnt = 0;
end
function HomeProfilePage.ChangeState(combinedState)
	local self = HomeProfilePage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end	
	if(combinedState == "master_outside_true" or combinedState == "master_outside_false")then
		self.placeState = "outside";	
	elseif(combinedState == "master_inside_true" or combinedState == "master_inside_false")then
		self.placeState = "inside";
	end
end
function HomeProfilePage.UpdateVisitors(visitcnt)
	local self = HomeProfilePage;
	self.visitcnt = visitcnt;
	self.ShowPage();
end
function HomeProfilePage.UpdateGiftNum(giftcnt,boxcnt)
	local self = HomeProfilePage;
	self.giftcnt = giftcnt;
	self.boxcnt = boxcnt;
	self.ShowPage();
end