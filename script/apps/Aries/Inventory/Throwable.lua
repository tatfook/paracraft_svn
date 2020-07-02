--[[
Title: code behind for page Throwable.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/Throwable.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/Throwable.lua");
local ThrowablePage = commonlib.gettable("MyCompany.Aries.Inventory.ThrowablePage");
ThrowablePage.BroadcastAction({nid=116200443,throwerLevel=2,playerName="116200443",endPoint={y=0.58725,x=20055.64258,z=19702.36914,},startPoint={y=1.59126,x=20049.47461,z=19699.32032,},hitObjNameList={},throwerState="follow",throwItem={hitstyle="model/07effect/v5/WaterBalloon/WaterBalloon1.x",style="model/07effect/v5/WaterBalloon/WaterBalloon.x",showpic="Texture/Aries/Smiley/animated/face10_32bits_fps10_a005.png",gsid=9501,},})
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = System.Item.ItemManager;
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
local ThrowablePage = commonlib.createtable("MyCompany.Aries.Inventory.ThrowablePage", {
	show = false,
	
	OnPlay =  nil,
	OnEnd = nil,
	OnUpdate = nil,
	OnHit = nil,
	curBallTable = nil,
	
	isOpenedByCommand = false,--是否是被快捷键打开的
});

ThrowablePage.rightMenu = {
	[1] = {
		menuName = "ThrowableWaterMenu",
		{gsid = 9501,name = "waterball",text = "水球",},
		{gsid = 9506,name = "waterballLV2",text = "超大水球",},
		{gsid = 9507,name = "waterballLV3",text = "魔力水球",},
		},
	[2] = {
		menuName = "ThrowableJellyMenu",
		{gsid = 9502,name = "jelly",text = "果冻",},
		{gsid = 9508,name = "jellyLV2",text = "超大果冻",},
		{gsid = 9509,name = "jellyLV3",text = "魔力果冻",},
	}
}

ThrowablePage.ballList = {
	[9501] = {buyIfNoHas = false,prioInThrowUI = 1,menuInfo = {posInMenu = 1,selected = true,},};
	[9502] = {buyIfNoHas = false,prioInThrowUI = 2,menuInfo = {posInMenu = 1,selected = true,},};
	[9503] = {buyIfNoHas = false,prioInThrowUI = 3,};
	[9504] = {buyIfNoHas = false,prioInThrowUI = 4,};
	[9505] = {buyIfNoHas = false,prioInThrowUI = 5,};
	[9506] = {buyIfNoHas = true ,prioInThrowUI = 1,buyInNpcshop = true ,menuInfo = {posInMenu = 2,selected = false,},basedBallID = 9501,},
	[9507] = {buyIfNoHas = true ,prioInThrowUI = 1,buyInNpcshop = false,menuInfo = {posInMenu = 3,selected = false,},basedBallID = 9501,},
	[9508] = {buyIfNoHas = true ,prioInThrowUI = 2,buyInNpcshop = true ,menuInfo = {posInMenu = 2,selected = false,},basedBallID = 9502,},
	[9509] = {buyIfNoHas = true ,prioInThrowUI = 2,buyInNpcshop = false,menuInfo = {posInMenu = 3,selected = false,},basedBallID = 9502,},
};

MyCompany.Aries.Inventory.ThrowablePage.OnPlay = function(msg)
	--commonlib.echo("投掷开始");
	--commonlib.echo(msg);
end
MyCompany.Aries.Inventory.ThrowablePage.OnEnd = function(msg)
	--commonlib.echo("投掷结束");
	--commonlib.echo(msg);
end
MyCompany.Aries.Inventory.ThrowablePage.OnUpdate = function(frame)
	--commonlib.echo("投掷过程");
	--commonlib.echo(frame);
end
MyCompany.Aries.Inventory.ThrowablePage.OnHit= function(msg)
	-- call hook for OnPurchaseItem
	local msg = { aries_type = "OnThrowableHit", msg = msg, wndName = "throw"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	--commonlib.echo("投掷击中");
	--commonlib.echo(msg);
end

function ThrowablePage.init()
	if(not ThrowablePage.inited) then
		ThrowablePage.inited = true;
		local node,subNode;
		for _,node in ipairs(ThrowablePage.rightMenu) do
			for _,subNode in ipairs(node) do
				local gsid = subNode.gsid;
				local tooltip = ThrowablePage.GetThrowItemTooltip(gsid) or "";
				local behas,guid = ItemManager.IfOwnGSItem(gsid); 
				if(behas) then
					subNode.guid = guid;
					subNode.tooltip = tooltip;
				end
			end 
		end
		--local count = 0;
		--local k,v;
		--for k,v ipairs(ThrowablePage.ballList) do
			--local gsid = k;	
			--local beHas,guid = ItemManager.IfOwnGSItem(gsid); 
			--if(beHas) then
				--if((not v.menuInfo) or (v.menuInfo and v.menuInfo.selected)) then
					--local tooltip = ThrowablePage.GetThrowItemTooltip(gsid) or "";
					--local priority = v.prioInThrowUI;
					--ThrowablePage.curBallTable[i] = {guid = guid, priority = priority, tooltip = tooltip,};		
				--end	
			--end
			--count = count + 1;
		--end
		--if(count < 12) then
			--local i;
			--for i = count + 1, 12 do
				--ThrowablePage.curBallTable[i] = {guid = 0, priority = 1000,};
			--end
		--else
			--local rowNum = math.ceil(count/3);
			--for i = count + 1, rowNum*3 do
				--ThrowablePage.curBallTable[i] = {guid = 0, priority = 1000,};
			--end
		--end
		--table.sort(ThrowablePage.curBallTable, function(a, b)
			--return (a.priority < b.priority);
		--end)
	end
	ThrowablePage.curBallTable = {};

	local count = 0;
	local k,v;
	for k,v in pairs(ThrowablePage.ballList) do
		local gsid = k;	
		local beHas,guid = ItemManager.IfOwnGSItem(gsid); 
		if(beHas) then
			if((not v.menuInfo) or (v.menuInfo and v.menuInfo.selected)) then
				local tooltip = ThrowablePage.GetThrowItemTooltip(gsid) or "";
				local priority = v.prioInThrowUI;
				count = count + 1;
				ThrowablePage.curBallTable[count] = {guid = guid, priority = priority, gsid = gsid, tooltip = tooltip,};		
			end	
		end
		--count = count + 1;
	end
	if(count < 12) then
		local i;
		for i = count + 1, 12 do
			ThrowablePage.curBallTable[i] = {guid = 0, priority = 1000,};
		end
	else
		local rowNum = math.ceil(count/3);
		for i = count + 1, rowNum*3 do
			ThrowablePage.curBallTable[i] = {guid = 0, priority = 1000,};
		end
	end
	table.sort(ThrowablePage.curBallTable, function(a, b)
		return (a.priority < b.priority);
	end)


--
	--ThrowablePage.ballList = {
		--[9501] = {buyIfNoHas = false,prioInThrowUI = 1,menuInfo = {posInMenu = 1,Selected = true,},};
		--[9502] = {buyIfNoHas = false,prioInThrowUI = 2,menuInfo = {posInMenu = 1,Selected = true,},};
		--[9503] = {buyIfNoHas = false,prioInThrowUI = 3,};
		--[9504] = {buyIfNoHas = false,prioInThrowUI = 4,};
		--[9505] = {buyIfNoHas = false,prioInThrowUI = 5,};
		--[9506] = {buyIfNoHas = true ,prioInThrowUI = 1,buyInNpcshop = true ,menuInfo = {posInMenu = 2,Selected = true,},},
		--[9507] = {buyIfNoHas = true ,prioInThrowUI = 1,buyInNpcshop = false,menuInfo = {posInMenu = 3,Selected = true,},},
		--[9508] = {buyIfNoHas = true ,prioInThrowUI = 2,buyInNpcshop = true ,menuInfo = {posInMenu = 2,Selected = true,},},
		--[9509] = {buyIfNoHas = true ,prioInThrowUI = 2,buyInNpcshop = false,menuInfo = {posInMenu = 3,Selected = true,},},
	--};
	--ThrowablePage.inited = true;
	--ThrowablePage.curBallTable = {};
--
	--local bAsyn;
	--ItemManager.GetItemsInBag(72, nil, function(msg)
		--if(msg and msg.items) then
			--local count = ItemManager.GetItemCountInBag(bag);
			--if(count == 0) then
				--count = 1;
			--end
			---- fill the 15 tiles per page
			--count = math.ceil(count/15) * 15;
			--local i;
			--for i = 1, count do
				--local item = msg.items[i];
				--
				--if(item ~= nil and item.gsid ~= 9506 and item.gsid ~= 9507 and item.gsid ~= 9508 and item.gsid ~= 9509 ) then
					----echo(item.gsid);
					--local tooltip = ThrowablePage.GetThrowItemTooltip(item.gsid) or "";
					--ThrowablePage.curBallTable[i] = {guid = item.guid, gsid = item.gsid, tooltip = tooltip};
				--else
					--ThrowablePage.curBallTable[i] = {guid = 0, gsid = 100000};
				--end
			--end
			--ThrowablePage.curBallTable.Count = count;
			--commonlib.resize(ThrowablePage.curBallTable, ThrowablePage.curBallTable.Count);
			--table.sort(ThrowablePage.curBallTable, function(a, b)
				--return (a.gsid < b.gsid);
			--end)
			--
			--if(bAsyn) then
				--ThrowablePage.pageCtrl:Refresh();
			--end
		----else
			----output.Count = 0;
			----commonlib.resize(output, output.Count);
		--end
	--end);
	--bAsyn = true;
	--
	--local node,subNode;
	--for _,node in ipairs(ThrowablePage.rightMenu) do
		--for _,subNode in ipairs(node) do
			--local gsid = subNode.gsid;
			--local tooltip = ThrowablePage.GetThrowItemTooltip(gsid) or "";
			--local behas,guid = ItemManager.IfOwnGSItem(gsid); 
			--if(behas) then
				--subNode.guid = guid;
				--subNode.tooltip = tooltip;
			--end
		--end 
	--end
	--echo(ThrowablePage.ballList);
	--echo(ThrowablePage.curBallTable);
end

-- The data source for items
function ThrowablePage.DS_Func_Items(index)      
	
	if(CommonClientService.IsTeenVersion()) then
		dsTable.status = 2;
        if(index == nil) then
			return 15;
        elseif(index == 1) then
			local tooltip = ThrowablePage.GetThrowItemTooltip(9501) or "";
			return {gsid = 9501, tooltip = tooltip};
		else
			return {guid = 0, gsid = 100000, tooltip = tooltip};
        end
		return;
	end
	
	if(index == nil) then
		--return ThrowablePage.curBallTable.Count;
		return #ThrowablePage.curBallTable;
    else
		return ThrowablePage.curBallTable[index];
    end


	-- get the class of the 
	--local bagFamily = 72;
    --if(not dsTable.status) then
        ---- use a default cache
        --ThrowablePage.GetItems(bagFamily, pageCtrl, "access plus 20 minutes", dsTable)
    --elseif(dsTable.status == 2) then    
        --if(index == nil) then
			--return dsTable.Count;
        --else
			--return dsTable[index];
        --end
    --end 
end
function ThrowablePage.Show()
	local self = ThrowablePage;
	local _wnd = MyCompany.Aries.app._app:FindWindow("ThrowablePage.ShowPage");
	if(_wnd and _wnd:IsVisible())then
		self.ClosePage();
	else
		self.ShowPage();
	end
end
function ThrowablePage.ShowPage()
	local self = ThrowablePage;
	local x, y, width, height = _guihelper.GetLastUIObjectPos();
	local url;
	if(CommonClientService.IsTeenVersion()) then
		url = "script/apps/Aries/Inventory/Throwable.teen.html";
	else
		url = "script/apps/Aries/Inventory/Throwable.html";
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "ThrowablePage.ShowPage", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			enable_esc_key = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			directPosition = true,
				align = "_lt",
				x = x-50+width/2,
				y = y - 265 - 5,
				width = 184,
				height = 265,
		});
	self.show = true;
	ThrowablePage.ShowCountDown = 30;
	
	--NPL.load("(gl)script/ide/timer.lua");
	--ThrowablePage.timer = ThrowablePage.timer or commonlib.Timer:new({callbackFunc = ThrowablePage.PageShowCountDown});
	--ThrowablePage.timer:Change(0, 100);
end

function ThrowablePage.ClosePage()
	local self = ThrowablePage;
	self.show = false;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ThrowablePage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,});
end

function ThrowablePage.PageShowCountDown()
	if(ThrowablePage.ShowCountDown) then
		ThrowablePage.ShowCountDown = ThrowablePage.ShowCountDown - 1;
		if(ThrowablePage.ShowCountDown == 0) then
			ThrowablePage.ShowCountDown = nil;
			ThrowablePage.ClosePage()
		end
	end
end

function ThrowablePage.OnClickItem(guid,index)
	if(mouse_button == "left" or CommonClientService.IsTeenVersion()) then
		if(not guid)then return end;
		local self = ThrowablePage;
		local item = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
		--echo("1111");
		--echo(guid);
		--echo(ItemManager.GetItemByGUID(guid));
		if(item)then
			--echo(item);
			--self.DoAction(item.bag,item.guid,item.gsid);
			self.DoAction(item.bag,item.gsid);
		
			-- call hook for OnThrowableItemSelected
			local hook_msg = { aries_type = "OnThrowableItemSelected", gsid = item.gsid, guid = item.guid, wndName = "main"};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
		else
			ThrowablePage.PreThrowBall(index);
		end
	else
		--_guihelper.MessageBox(index);
		local menuNode = ThrowablePage.rightMenu[index]
		if(not menuNode) then
			return
		end
		local menuName = menuNode.menuName;
		local ctl = CommonCtrl.GetControl(menuName);
		if(ctl == nil)then
			ctl = CommonCtrl.ContextMenu:new{
				name = menuName,
				width = 75,
				height = 150,
				DefaultNodeHeight = 24,
				style = if_else(System.options.version=="teen", nil, {
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 1,
				borderRight = 1,
				
				fillLeft = 0,
				fillTop = 0,
				fillWidth = 0,
				fillHeight = 0,
				
				titlecolor = "#283546",
				level1itemcolor = "#283546",
				level2itemcolor = "#3e7320",
				
				iconsize_x = 24,
				iconsize_y = 21,
				
				menu_bg = "Texture/Aries/Creator/border_bg_32bits.png:3 3 3 3",
				menu_lvl2_bg = "Texture/Aries/Creator/border_bg_32bits.png:3 3 3 3",
				shadow_bg = nil,
				separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
				item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
				expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
				expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
				menuitemHeight = 24,
				separatorHeight = 2,
				titleHeight = 24,
				
				titleFont = "System;12;bold";
			}),
			};
			local node = ctl.RootNode;
			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "group", Name = "group", Type = "Group", NodeHeight = 0 });
			local n = table.getn(menuNode);
			local i;
			for i = 1,n do
				--echo("11111");
				local name = menuNode[i].name;
				--local gsItem = ItemManager.GetGlobalStoreItemInMemory(menuNode[i].gsid);
				local text = menuNode[i].text;
				node:AddChild(CommonCtrl.TreeNode:new({text = text, Name = name, Type = "Menuitem", onclick = function(name)
					ThrowablePage.OnMenuItem(index, i)
				end,}));
			end	
		end
		ctl:Show();
	end
	
end

function ThrowablePage.OnMenuItem(menuID,submenuID)
	local gsid = ThrowablePage.rightMenu[menuID][submenuID].gsid;
	local bHas = ItemManager.IfOwnGSItem(gsid);
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);

	--if(gsid == 9507 or gsid == 9509) then
		--_guihelper.MessageBox(string.format("%s博士还在研发中，请小哈奇耐心等待哦",gsItem.template.name));
		--return;
	--elseif(not bHas) then
	if(not bHas) then
		local exid;
		if(gsid == 9506) then
			exid = 1919;
		elseif(gsid == 9508) then
			exid = 1920;
		end
		_guihelper.MessageBox(string.format("你还没有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>，是否现在购买？",gsid),function(result)
			if(result == _guihelper.DialogResult.Yes)then
				local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
				if(command) then
					if(gsid == 9507 or gsid == 9509) then
						command:Call({gsid = gsid});
					else
						command:Call({gsid = gsid, exid = exid, npc_shop = true, nil });
					end
					
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		return;
	end

	local k,v;
	for k,v in ipairs(ThrowablePage.rightMenu[menuID]) do
		if(ThrowablePage.ballList[v.gsid].menuInfo) then
			if(v.gsid == gsid) then
				ThrowablePage.ballList[v.gsid].menuInfo.selected = true;
			else
				ThrowablePage.ballList[v.gsid].menuInfo.selected = false;
			end
		end
	end
	--echo("2222");
	--echo(ThrowablePage.ballList);
	--local tooltip = ThrowablePage.GetThrowItemTooltip(gsid) or "";
	--local behas,guid,_,copies = ItemManager.IfOwnGSItem(gsid);
	--local priority = ThrowablePage.ballList[gsid].prioInThrowUI; 
	--ThrowablePage.curBallTable[menuID] = {guid = guid , gsid = gsid , priority = priority , tooltip = tooltip , };
	ThrowablePage.pageCtrl:Refresh(0.5);
end

function ThrowablePage.OnClickItemGSID(gsid)
	if(not gsid) then
		return;
	end
	ThrowablePage.DoAction(72, gsid);
end

--[[
	水球={
		bag = 72,
		guid = 17,
		gsid = 9501,
	}
	果冻={
		bag = 72,
		guid = 18,
		gsid = 9502,
	}
	鞭炮={
		bag = 72,
		guid = 62,
		gsid = 9503,
	}
]]
function ThrowablePage.DoAction(bag,gsid)
	local self = ThrowablePage;
	if(not bag or not gsid)then return end
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			commonlib.echo("==================ThrowablePage.DoAction");
			--commonlib.echo(gsItem);
			local class = tonumber(gsItem.template.class);
			local subclass = tonumber(gsItem.template.subclass);
			local bagfamily = gsItem.template.bagfamily;
			local t = Map3DSystem.App.HomeLand.HomeLandConfig.ParseThrowBall(gsItem.descfile);
			local style = "model/06props/shared/pops/barrels.x"--默认投掷的模型
			local hitstyle = "model/07effect/v5/WaterBalloon/WaterBalloon1.x";--默认炸中显示的模型
			local showpic = "Texture/Aries/Smiley/face15_32bits.png";--默认炸中显示的图片
			local effect_time;
			if(t)then
				hitstyle = t.hitstyle or hitstyle;
				showpic = t.showpic or showpic;
				effect_time = t.effect_time;
			end
			
			local item = {
				style = gsItem.assetfile or style, 
				hitstyle = hitstyle,
				gsid = gsid,
				item_guid = gsItem.guid,
				showpic = showpic,
				effect_time = effect_time,--爆炸持续时间
			}
			--如果是糖豆豆 随机选取一种样式
			if(gsid == 9505)then
				item.style = ThrowablePage.GetCandyBallStyle();
				item.hitstyle = ThrowablePage.GetCandyBallOnHitStyle(item.style);
			end
			commonlib.echo(item);
			
			self.OnNodeClickItem(item);
			
			self.UpdateBag(bagfamily, bag)
		else
			log("error: invalid use of item for throwable guid:"..guid.."\n");
			return;
		end
end
function ThrowablePage.GetThrowItemTooltip(gsid)
	if(not gsid)then return end
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		local tooltip = gsItem.template.name;
		if(CommonClientService.IsTeenVersion()) then
			return tooltip;
		end

		if(gsid == 9501 or gsid == 9506 or gsid == 9507)then
			tooltip = tooltip .. "\n快捷键：1"
		elseif(gsid == 9502 or gsid == 9508 or gsid == 9509)then
			tooltip = tooltip .. "\n快捷键：2"
		elseif(gsid == 9503)then
			tooltip = tooltip .. "\n快捷键：3"
		elseif(gsid == 9504)then
			tooltip = tooltip .. "\n快捷键：4"
		elseif(gsid == 9505)then
			tooltip = tooltip .. "\n快捷键：5"
		end
		return tooltip;
	end
end
function ThrowablePage.GetItems(bag, pageCtrl, cachepolicy, output)
	-- find the right bag for inventory items
	if(bag == nil) then
		-- return empty datasource table, if no bag id is specified
		output.Count = 0;
		commonlib.resize(output, output.Count)
		return;
	end
	-- fetching inventory items
	output.status = 1;
	ItemManager.GetItemsInBag(bag, "ariesitems", function(msg)
		if(msg and msg.items) then
			local count = ItemManager.GetItemCountInBag(bag);
			if(count == 0) then
				count = 1;
			end
			-- fill the 15 tiles per page
			count = math.ceil(count/15) * 15;
			local i;
			for i = 1, count do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item ~= nil) then
					local tooltip = ThrowablePage.GetThrowItemTooltip(item.gsid) or "";
					
					output[i] = {guid = item.guid, gsid = item.gsid, tooltip = tooltip};
				else
					output[i] = {guid = 0, gsid = 100000};
				end
			end
			output.Count = count;
			commonlib.resize(output, output.Count);
			table.sort(output, function(a, b)
				return (a.gsid < b.gsid);
			end)
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
function ThrowablePage.UpdateBag(bagfamily, bag)
	if(bagfamily) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(bagfamily, "", function(msg3)
			---- NOTE andy: item system will automatically update all MCML pages with pe:slot tag
			--Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
		end, "access plus 30 minutes");
	end
	if(bag and bag ~= bagfamily) then
		Map3DSystem.Item.ItemManager.GetItemsInBag(bag, "", function(msg)
			
		end, "access plus 30 minutes");
	end
end

function ThrowablePage.OnNodeClickItem(item)
	local self = ThrowablePage;
	if(not item)then return end
	NPL.load("(gl)script/apps/Aries/Player/ThrowBall.lua");
	local throwBalll;

	--设置 投掷者的状态，是骑在龙身上，还是没有"ride" or 其他
	local state = MyCompany.Aries.Pet.GetState();
	--如果人骑在龙上，需要知道龙的等级，是小龙还是大龙，2小龙 3 大龙
	local level = MyCompany.Aries.Pet.GetLevel();
	local name,nid = ParaScene.GetPlayer().name,Map3DSystem.User.nid;
	
	throwBall = CommonCtrl.ThrowBall.RegHook(name,nid,item,state,level);
	if(throwBall)then
		commonlib.echo("=============self.throwBall");
		throwBall.OnPlay = function(ball)
			if(self.OnPlay and type(self.OnPlay) == "function")then
				if(ball and ball.GetThrowMsg)then
					local msg = ball:GetThrowMsg();
					--self.BroadcastAction(msg);
					-- destroy the item if throwed
					-- to Leio: i manually destroy one copy of the item if it is the firecracker gsid:9503
					local destroyAfterUsedList = {
						[9503] =  true,
						[9505] =  true,
						[9506] =  true,
						[9508] =  true,
					}
					-- needDestroy  表示扔了后需要销毁一个对应的物品
					-- posInThrowUI 表示物品在弹出的UI界面中的位置
					-- posInMenu    表示物品在弹出的右键菜单中的位置
					local gsid = msg.throwItem.gsid;
					if(msg and msg.throwItem and destroyAfterUsedList[gsid]) then

						local bHas, guid ,_ ,copies = ItemManager.IfOwnGSItem(gsid);
						if(bHas == true) then
							ItemManager.DestroyItem(guid, 1, function(msg)
								log("========== Destroy gsid:"..gsid.." item with guid:"..guid.." returns: ==========\n")
								commonlib.echo(msg);
							end);
						end
					end
					--MyCompany.Aries.Scene.PlayGameSound("Audio/Haqi/Throw.wav");
					self.OnPlay(msg);
					self.OnPlay(msg);
				end
			end
		end
		throwBall.OnUpdate = function(ball,frame)
			if(self.OnUpdate and type(self.OnUpdate) == "function")then
				self.OnUpdate(frame);
			end
		end
		throwBall.OnEnd = function(ball)
			--TODO:恢复2D面板
			if(self.OnEnd and type(self.OnEnd) == "function")then
				if(ball and ball.GetThrowMsg)then
					local msg = ball:GetThrowMsg();
					self.OnEnd(msg);
					self.isOpenedByCommand = false;
				end
			end
		end
		throwBall.OnHit = function(ball)
			if(self.OnHit and type(self.OnHit) == "function")then
				if(ball and ball.GetThrowMsg)then
					local msg = ball:GetThrowMsg();
					if(msg)then
						local attackedName = ball:GetWillbeAttackedObject(msg.endPoint);
						msg.attackedName = attackedName;
						

						if(attackedName)then
							--投掷 增加任务进度
							NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
							local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
							local player = ParaScene.GetObject(attackedName);
							local info = TargetArea.GetSelectedObjectInfo(player);
							if(info and info.nid and (info.nid ~=Map3DSystem.User.nid) )then
								NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
								local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
								QuestHelp.Quest_ThrowBall(msg.throwItem.gsid);
							end
						end
					end
					self.BroadcastAction(msg);
					self.OnHit(msg);
					self.isOpenedByCommand = false;
				end
			end
		end
		--如果投掷无效的话
		throwBall.OnDisabled = function(ball)
			self.isOpenedByCommand = false;
		end
		self.ClosePage();
	end
end
function ThrowablePage.BroadcastAction(msg)
	if(not msg)then return end
	local msg = CommonCtrl.ThrowBall.msg_encoder(msg)
	if(msg)then
		msg = commonlib.serialize_compact(msg);
		if(msg and msg ~= "")then
			Map3DSystem.GSL_client:AddRealtimeMessage({name="action", value= msg})
		end
	end
end
--[[
--通过快捷键触发投掷
commandName == "MiniGames.Throw_ShuiQiu"
commandName == "MiniGames.Throw_GuoDong"
commandName == "MiniGames.Throw_BianPao"
	水球={
		bag = 72,
		guid = 17,
		gsid = 9501,
	}
	果冻={
		bag = 72,
		guid = 18,
		gsid = 9502,
	}
	鞭炮={
		bag = 72,
		guid = 62,
		gsid = 9503,
	}
]]
function ThrowablePage.OpenedByCommand(index)
	local self = ThrowablePage;
	if(not self.inited) then
		self.init();
	end
	--self.init();
	if(self.isOpenedByCommand == true)then return end

	local bag,gsid = 72,9501;
	--if(index == 1)then
		--gsid = 9501;
	--elseif(index == 2)then
		--gsid = 9502;
	--elseif(index == 3)then
		--gsid = 9503;
	--elseif(index == 4)then
		--gsid = 9504;
	--elseif(index == 5)then
		--gsid = 9505;
	--end
	if(tonumber(index)) then
		if(index == 1)then
			local list = {9501,9506,9507};
			local _,ballGSID;
			for _,ballGSID in ipairs(list) do
				if(ThrowablePage.ballList[ballGSID].menuInfo.selected) then
					gsid = ballGSID;
				end
			end
			--gsid = 9501;
		elseif(index == 2)then
			local list = {9502,9508,9509};
			local _,ballGSID;
			for _,ballGSID in ipairs(list) do
				if(ThrowablePage.ballList[ballGSID].menuInfo.selected) then
					gsid = ballGSID;
				end
			end
		elseif(index == 3)then
			gsid = 9503;
		elseif(index == 4)then
			gsid = 9504;
		elseif(index == 5)then
			gsid = 9505;
		end
		--gsid = ThrowablePage.curBallTable[index].gsid;
	end

	--if(index == 1)then
		--gsid = 9506;
	--elseif(index == 2)then
		--gsid = 9507;
	--elseif(index == 3)then
		--gsid = 9508;
	--elseif(index == 4)then
		--gsid = 9504;
	--elseif(index == 5)then
		--gsid = 9509;
	--end
	
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;

	local count = 0;
	local bHas, guid = hasGSItem(gsid);
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			count = item.copies;
		end
	end
	commonlib.echo("===============OpenedByCommand");
	commonlib.echo({gsid,bHas,count});
	if(bHas and count > 0)then
		self.isOpenedByCommand = true;
		self.DoAction(bag,gsid);
	else
		ThrowablePage.PreThrowBall(index);
	end
end
--投掷 糖豆豆 随机产生一种样式
function ThrowablePage.GetCandyBallStyle()
	local models = {
		"model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_blue.x",
		"model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_green.x",
		"model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_purple.x",
		"model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_red.x",
	}
	local len = #models;
	local r = math.random(len);
	return models[r];
end
function ThrowablePage.GetCandyBallOnHitStyle(key)
	if(not key)then return end
	local models = {
		["model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_blue.x"] = "model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon1_blue.x",
		["model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_green.x"] = "model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon1_green.x",
		["model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_purple.x"] = "model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon1_purple.x",
		["model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon_red.x"] = "model/07effect/v5/CandyBeanBalloon/CandyBeanBalloon1_red.x",
	}
	return models[key];
end

function ThrowablePage.PreThrowBall(index)
	--local ballList = {
		--[9501] = {buyIfNoHas = false,prioInThrowUI = 1,menuInfo = {posInMenu = 1,Selected = true,},};
		--[9502] = {buyIfNoHas = false,prioInThrowUI = 2,menuInfo = {posInMenu = 1,Selected = true,},};
		--[9503] = {buyIfNoHas = false,prioInThrowUI = 3,};
		--[9504] = {buyIfNoHas = false,prioInThrowUI = 4,};
		--[9505] = {buyIfNoHas = false,prioInThrowUI = 5,};
		--[9506] = {buyIfNoHas = true ,prioInThrowUI = 1,buyInNpcshop = true ,menuInfo = {posInMenu = 2,Selected = true,},},
		--[9507] = {buyIfNoHas = true ,prioInThrowUI = 1,buyInNpcshop = false,menuInfo = {posInMenu = 3,Selected = true,},},
		--[9508] = {buyIfNoHas = true ,prioInThrowUI = 2,buyInNpcshop = true ,menuInfo = {posInMenu = 2,Selected = true,},},
		--[9509] = {buyIfNoHas = true ,prioInThrowUI = 2,buyInNpcshop = false,menuInfo = {posInMenu = 3,Selected = true,},},
	--};
	--local liist = ThrowablePage.ballList;
	local gsid = ThrowablePage.curBallTable[index].gsid;
	local bHas, guid ,_ ,copies = ItemManager.IfOwnGSItem(gsid);
	if(not bHas and gsid and ThrowablePage.ballList[gsid] and ThrowablePage.ballList[gsid]["buyIfNoHas"]) then
		_guihelper.MessageBox(string.format("你的<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>已经消耗完了，是否现在购买？",gsid),function(result)
			if(result == _guihelper.DialogResult.Yes)then
				local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
				if(command) then
					if(ThrowablePage.ballList[gsid]["buyInNpcshop"]) then
						command:Call({gsid = gsid, exid = 1919, npc_shop = true, nil });
					else
						command:Call({gsid = gsid,});
					end
				end
			end
			if(result == _guihelper.DialogResult.No) then
				--ThrowablePage.curBallTable[index] = ThrowablePage.rightMenu[index][1];
				if(ThrowablePage.ballList[gsid].menuInfo) then
					local baseGSID = ThrowablePage.ballList[gsid].basedBallID;
					ThrowablePage.ballList[gsid].menuInfo.selected = false;
					ThrowablePage.ballList[baseGSID].menuInfo.selected = true;
					ThrowablePage.init();
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end
end