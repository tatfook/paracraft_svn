--[[
Title: 
Author(s): leio
Date: 2013/5/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");
local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");
LinksAreaPage.LoadLinksNode();
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");
local page;

function LinksAreaPage.Create()
	local _parent = ParaUI.CreateUIObject("container", "LinksAreaPage", "_rt", -560, 0, 400, 150);
	_parent.background = "";
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();
	_parent.zorder= -10;
	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/LinksArea/LinksAreaPage.teen.html",click_through = true,});
	-- one can create a UI instance like this. 
	page:Create("Aries_LinksAreaPage_mcml", _parent, "_fi", 0, 0, 0, 0);
	LinksAreaPage.LoadLinksNode();
	LinksAreaPage.CheckNode_Asyn();
end

LinksAreaPage.links_view = nil;

LinksAreaPage.click_map = {

}
LinksAreaPage.ImFromInternetCafe_zhTW = false;
function LinksAreaPage.CheckNode_Asyn()
	NPL.load("(gl)script/apps/Aries/Gift/ExcitingActivityPage.lua");
	local ExcitingActivityPage = commonlib.gettable("MyCompany.Aries.Gift.ExcitingActivityPage");
	ExcitingActivityPage.Load(function()
	--	LinksAreaPage.LoadLinksNode();
	end)

	NPL.load("(gl)script/apps/Aries/Gift/RechargeActivityPage.lua");
	local RechargeActivityPage = commonlib.gettable("MyCompany.Aries.Gift.RechargeActivityPage");
	RechargeActivityPage.Load(function()
		LinksAreaPage.LoadLinksNode();
	end)
end

function LinksAreaPage.LoadLinksNode()
	LinksAreaPage.links_view = {};
	if(CommonClientService.IsTeenVersion())then
		if(System.options.locale == "zhTW")then
			LinksAreaPage.links_view = {
				
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/free_space_32bits.png", tooltip = "创意空间", keyname = "free_space",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/hero_32bits.png", goalpointer="open_herocopy", tooltip = "英雄副本", keyname = "hero",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/pvp_32bits.png", tooltip = "竞技", keyname = "pvp",},
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/world_team_32bits.png", tooltip = "悬赏告示", keyname = "world_team",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/weekly_32bits.png", tooltip = "推荐任务", keyname = "weekly",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/story_32bits.png", tooltip = "剧情战役", keyname = "story",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/activity_32bits.png", tooltip = "充值回馈", keyname = "recharge_act",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/firstrecharge_32bits.png", tooltip = "首充送豪礼", keyname = "recharge_first",},
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/timing_shop_32bits.png", tooltip = "限时特卖", keyname = "discount",},
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/code_32bits.png", tooltip = "序号兑换", keyname = "code",},
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/auction_house_sell_32bits.png", tooltip = "拍卖行", keyname = "auction_house_sell",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/fb_32bits.png", tooltip = "粉丝团", keyname = "fb",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/cafes_32bits.png", tooltip = "网咖商城", keyname = "cafe",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/activity_32bits.png", tooltip = "精彩活动", keyname = "activity",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/login_32bits.png", tooltip = "登录礼包", keyname = "login",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/online_32bits.png", tooltip = "在线礼包", keyname = "online",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/upgrade_32bits.png", tooltip = "升级礼包", keyname = "upgrade",},
			}
		else
			LinksAreaPage.links_view = {
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/free_space_32bits.png", tooltip = "创意空间", keyname = "free_space",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/hero_32bits.png", goalpointer="open_herocopy",tooltip = "副本", keyname = "hero",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/pvp_32bits.png", tooltip = "竞技", keyname = "pvp",},
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/world_team_32bits.png", tooltip = "悬赏告示", keyname = "world_team",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/weekly_32bits.png", tooltip = "推荐任务", keyname = "weekly",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/story_32bits.png", tooltip = "剧情战役", keyname = "story",},
				--{ icon = "Texture/Aries/Common/ThemeTeen/Links/auction_house_sell_32bits.png", tooltip = "拍卖行", keyname = "auction_house_sell",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/activity_32bits.png", tooltip = "精彩活动", keyname = "activity",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/space_32bits.png",tooltip = "创意空间", keyname = "paracraft",},				
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/login_32bits.png", tooltip = "登录礼包", keyname = "login",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/online_32bits.png", tooltip = "在线礼包", keyname = "online",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/upgrade_32bits.png", tooltip = "升级礼包", keyname = "upgrade",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/recharge_32bits.png", tooltip = "充值回馈", keyname = "recharge_act",},
				{ icon = "Texture/Aries/Common/ThemeTeen/Links/firstrecharge_32bits.png", tooltip = "首充送豪礼", keyname = "recharge_first",},
				{ icon = nil},
			}
		end
	end
	local len = #LinksAreaPage.links_view;
	while(len > 0) do
		local node = LinksAreaPage.links_view[len];
		if(node and node.keyname)then
			local keyname = node.keyname;
			if(keyname == "cafe" and not LinksAreaPage.ImFromInternetCafe_zhTW)then
				table.remove(LinksAreaPage.links_view,len);
			end
			--if(keyname == "activity")then
				--NPL.load("(gl)script/apps/Aries/Gift/ExcitingActivityPage.lua");
				--local ExcitingActivityPage = commonlib.gettable("MyCompany.Aries.Gift.ExcitingActivityPage");
				--if(ExcitingActivityPage.GetItemsCnt() == 0)then
					--table.remove(LinksAreaPage.links_view,len);
				--end
			--end
			if(keyname == "recharge_act")then
				NPL.load("(gl)script/apps/Aries/Gift/RechargeActivityPage.lua");
				local RechargeActivityPage = commonlib.gettable("MyCompany.Aries.Gift.RechargeActivityPage");
				if(RechargeActivityPage.GetItemsCnt() == 0) then
					table.remove(LinksAreaPage.links_view,len);
					table.insert(LinksAreaPage.links_view,len,{ icon = nil})
				end
			end
			if(keyname == "recharge_first")then
				local check_gsid = 50353;
				local ItemManager = System.Item.ItemManager;
				local hasGSItem = ItemManager.IfOwnGSItem;
				local hasCopies = hasGSItem(check_gsid);
				if(hasCopies) then
					table.remove(LinksAreaPage.links_view,len);
					table.insert(LinksAreaPage.links_view,len,{ icon = nil})
				end
			end
			--if(keyname == "discount")then
				--NPL.load("(gl)script/ide/DateTime.lua");
				--local seconds, min, hour, day, month, year = MyCompany.Aries.Scene.GetServerDateTime()
				--if(not commonlib.timehelp.datetime_range:new("(0 0 28 4)(0 3 1 5)"):is_matched(min,hour,day, month, year)) then
					--table.remove(LinksAreaPage.links_view,len);
				--end
			--end
		end
		len = len - 1;
	end
	CommonClientService.Fill_List(LinksAreaPage.links_view,12);
	LinksAreaPage.SwapTable(1,6,LinksAreaPage.links_view);
	LinksAreaPage.SwapTable(7,12,LinksAreaPage.links_view);
	if(page)then
		page:Refresh(0);
	end
end

local tmp_item_template = {is_null=true}
-- swap items in the given range. 

function LinksAreaPage.SwapTable(start_index,end_index,source)
	if(not source)then return end
	local min = start_index
	local max = end_index
	
	local k;
	local count = math.floor((max - min+1)/2+0.5)
	for k = 0,count-1 do
		local a, b = source[min+k], source[max - k]
		source[max - k], source[min+k] = if_else(a, a, tmp_item_template), if_else(b, b, tmp_item_template);
	end
end

function LinksAreaPage.Ds_Func(index)
	if(not LinksAreaPage.links_view)then return nil end
	if(index == nil) then
		return #(LinksAreaPage.links_view);
	else
		return LinksAreaPage.links_view[index];
	end
end

-- only teen version. 
function LinksAreaPage.OnClickCreativeSpace()
	local ctl = CommonCtrl.GetControl("ClickCreativeSpace_ContextMenu");
	if(ctl==nil)then
		NPL.load("(gl)script/ide/ContextMenu.lua");
		ctl = CommonCtrl.ContextMenu:new{
			name = "ClickCreativeSpace_ContextMenu",
			width = 120,
			height = 50,
			DefaultNodeHeight = 24,
		};
		local node = ctl.RootNode;
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "pe:name", Name = "pe:name", Type = "Group", NodeHeight = 0 });
		
		node:AddChild(CommonCtrl.TreeNode:new({Text = "开始创作", Name = "StartCreativeSpace", Type = "Menuitem", onclick = function()
				MyCompany.Aries.Desktop.Dock.OnGotoCreatorWorldNew();
			end, Icon = nil,}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "已发布作品", Name = "OpenPublishedSpace", Type = "Menuitem", onclick = function()
				System.App.Commands.Call("Profile.Aries.MyHomeLand");
			end, Icon = nil,}));
		
	end
	ctl.nid = nid;
	local x, y, width, height = _guihelper.GetLastUIObjectPos();
	ctl:Show(x, y + height);
end

function LinksAreaPage.Show(bShow)
	local parent = ParaUI.GetUIObject("LinksAreaPage");
	if(parent:IsValid() == true) then
		if(bShow == nil) then
			bShow = not parent.visible;
		end
		parent.visible = bShow;
	end
end

function LinksAreaPage.SetMiJiuHuLuTips(tips)
	local _hulutips = ParaUI.GetUIObject("MiJiuHuLuTips");
	if(_hulutips)then
		_hulutips.text = tips;
	end
end

function LinksAreaPage.FlashBtn(btnkey,bbounce)	
	if (btnkey) then
		local _flash;
		local u_animator = string.format("%s_animator",btnkey)
		_flash = ParaUI.GetUIObject(u_animator);
		--if(btnkey == "recharge_first")then
	        --_flash = ParaUI.GetUIObject("recharge_first_animator");
		--elseif(btnkey == "recharge_act")then            
	        --_flash = ParaUI.GetUIObject("recharge_act_animator");
		--elseif(btnkey == "activity")then            
	        --_flash = ParaUI.GetUIObject("activity_animator");
		--elseif (btnkey == "upgrade") then
			--_flash = ParaUI.GetUIObject("upgrade_animator");
		--elseif (btnkey == "online") then
			--_flash = ParaUI.GetUIObject("online_animator");
		--end

		_flash.background = if_else(bbounce,"Texture/Aries/Common/ThemeTeen/animated/btn_anim_32bits_fps10_a012.png","")
	end
end
