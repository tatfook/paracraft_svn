--[[
Title: sign_item_page
Author(s): LiXizhi
Date: 2012/9/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Items/sign_item_page.lua");
local sign_item_page = commonlib.gettable("MyCompany.Aries.Items.sign_item_page");
sign_item_page.ShowPage(item)
sign_item_page.ClosePage();
------------------------------------------------------------
]]

local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
-- create class
local sign_item_page = commonlib.gettable("MyCompany.Aries.Items.sign_item_page");

local page;

-- @param item: the Item object
function sign_item_page.ShowPage(item)
	if (System.options.version == "kids") then
		if(not item or not item.gsid or not item.guid or item.guid<=0) then
			return;
		end
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		if(not gsItem) then
			return;
		end
		sign_item_page.guid = item.guid;
		sign_item_page.item = item;

		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		
		local width, height=360, 270;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = format("script/apps/Aries/Items/sign_item_page.kids.html?guid=%d", item.guid), 
			name = "Aries.sign_item_page", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			isTopLevel = true,
			--is_click_to_close = true;
			zorder = 2,
			allowDrag = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			enable_esc_key = true,
			click_through = true,
			directPosition = true,
				align = "_ct",
				x = -width/2,
				y = -height/2,
				width = width,
				height = height,
		});

	else
		-- TODO: 
	end
end


-- load everything from file
function sign_item_page.init()
	page = document:GetPageCtrl();
end

function sign_item_page.ClosePage()
	if(page) then
		page:CloseWindow();		
	end
end

-- sign the item. 
function sign_item_page.sign_item(guid, money, sign_text, money_cost, bOverwrite)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if( not DealDefend.CanPass()) then
		return
	end

	if(sign_text and #sign_text>=50) then
		_guihelper.MessageBox("宣言的文字太长了");
		return;
	end

	local item = ItemManager.GetItemByGUID(guid);
    if(item and item.GetServerData) then
		--local svrdata = item:GetServerData();
		--if(svrdata and svrdata.money and not bOverwrite) then
			--_guihelper.MessageBox("这枚戒指已经签名了. 如果重新签名，戒指上已有的钻石会被新输入的钻石替代. 是否继续？", function(res)
				--if(res and res == _guihelper.DialogResult.Yes) then
					--sign_item_page.sign_item(guid, money, sign_text, true)
				--end
			--end, _guihelper.MessageBoxButtons.YesNo);
			--return;	
		--end
		money_cost = money_cost or money;
		if(type(money) == "number" and money>=100) then
			local bHas, _, _, copies = ItemManager.IfOwnGSItem(984);
			if(bHas and money_cost <= copies) then
				System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="SignItem", params={guid=guid, money=tonumber(money_cost), sign_text=sign_text}});
			else
				_guihelper.MessageBox("您的魔豆不足")
			end
		end
	end
end