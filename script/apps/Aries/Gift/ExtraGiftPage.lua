--[[
Title: 
Author(s): 
Date: 2012/11/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Gift/ExtraGiftPage.lua");
local ExtraGiftPage = commonlib.gettable("MyCompany.Aries.Gift.ExtraGiftPage");
ExtraGiftPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local ExtraGiftPage = commonlib.gettable("MyCompany.Aries.Gift.ExtraGiftPage");
ExtraGiftPage.code_url = "http://haqi2.61.com";
ExtraGiftPage.gift_name = nil;
ExtraGiftPage.exid_gifts = nil;

ExtraGiftPage.gifts = nil;

-- max number of gift to show in the ui at one time. 
ExtraGiftPage.max_gifts = 4;

-- we will show according to locale and region. 
function ExtraGiftPage.GetAllGift()
	if(ExtraGiftPage.gifts_all)then
		return ExtraGiftPage.gifts_all;
	end
	if(CommonClientService.IsTeenVersion())then
		if(System.options.locale == "zhTW")then
			ExtraGiftPage.gifts_all = {
--				{ label = "首次充值礼包" , name="first_pay",  icon = "Texture/Aries/Common/Teen/gifts/gift_4_32bits.png", exid = 30081, check_gsid = 50353, },
				{ label = "快乐分享包" , name="sun_gift", icon = "Texture/Aries/Common/Teen/gifts/gift_sun_32bits.png", exid = 30748, check_gsid = 50376, },
				{ label = "月亮礼包" , name="moon_gift", icon = "Texture/Aries/Common/Teen/gifts/gift_moon_32bits.png", exid = 30747, check_gsid = 50362, },
				--{ label = "连续登录礼包" , name="daily", icon = "Texture/Aries/Common/Teen/gifts/gift_1_32bits.png", show_func = function()
					--NPL.load("(gl)script/apps/Aries/Login/DailyCheckin.lua");
					--local DailyCheckin = commonlib.gettable("MyCompany.Aries.DailyCheckin");
					--DailyCheckin.ShowPage();
				--end},
			}				
		else
			ExtraGiftPage.gifts_all = {
--				{ label = "首次充值礼包" , name="first_pay",  icon = "Texture/Aries/Common/Teen/gifts/gift_4_32bits.png", exid = 30081, check_gsid = 50353, },
				{ label = "媒体礼包" , name="media", locale="zhCN", icon = "Texture/Aries/Common/Teen/gifts/gift_2_32bits.png", exid = 30080, check_gsid = 50351, },
				{ label = "微端礼包" , name="client", locale="zhCN", icon = "Texture/Aries/Common/Teen/gifts/gift_3_32bits.png", exid = 30079, check_gsid = 50352, },
				--{ label = "连续登录礼包" , name="daily", icon = "Texture/Aries/Common/Teen/gifts/gift_1_32bits.png", show_func = function()
						--NPL.load("(gl)script/apps/Aries/Login/DailyCheckin.lua");
						--local DailyCheckin = commonlib.gettable("MyCompany.Aries.DailyCheckin");
						--DailyCheckin.ShowPage();
					--end},
				-- { label = "贴吧签到2" , name="tieba", locale="zhCN", icon = "Texture/Aries/Common/Teen/gifts/gift_2_32bits.png", exid = 30188, check_gsid = 50354, },
				{ label = "贴吧签到礼包" , name="tieba", locale="zhCN", icon = "Texture/Aries/Common/Teen/gifts/gift_2_32bits.png", show_func = function()
						NPL.load("(gl)script/apps/Aries/Partners/baidu/tieba_checkin.lua");
						local tieba_checkin = commonlib.gettable("MyCompany.Aries.Partners.baidu.tieba_checkin");
						tieba_checkin.ShowPage();
					end},
			}
		end
	else
			ExtraGiftPage.gifts_all = {
				{ label = "首次充值礼包" , name="first_pay",  icon = "Texture/Aries/Common/Teen/gifts/gift_4_32bits.png", exid = 1730, check_gsid = 50398, },
				{ label = "微端礼包" , name="client", locale="zhCN", icon = "Texture/Aries/Common/Teen/gifts/gift_3_32bits.png", exid = 1731, check_gsid = 50399, },
			}
	end
	return ExtraGiftPage.gifts_all;
end
function ExtraGiftPage.GetGift(name)
	name = name or ExtraGiftPage.gift_name;
	local _, item
	for _, item in ipairs(ExtraGiftPage.gifts) do
		if(item.name == name) then
			return item;
		end
	end
end

function ExtraGiftPage.GetGifts()
	if(not ExtraGiftPage.gifts) then
		ExtraGiftPage.gifts = {};
		if(CommonClientService.IsTeenVersion())then
			local _, item
			for _, item in ipairs(ExtraGiftPage.GetAllGift()) do
				if(item.locale and item.locale~=System.options.locale) then
				else
					if(not item.check_gsid or not hasGSItem(item.check_gsid))then
						if(#(ExtraGiftPage.gifts) < ExtraGiftPage.max_gifts) then
							ExtraGiftPage.gifts[#(ExtraGiftPage.gifts)+1] = item;
						else
							break;
						end
					end
				end
			end
		else
			local _, item
			for _, item in ipairs(ExtraGiftPage.GetAllGift()) do
				table.insert(ExtraGiftPage.gifts,item);
			end
		end
	end
	return ExtraGiftPage.gifts;
end

function ExtraGiftPage.NeedShow()
	local k,v;
	for k,v in ipairs(ExtraGiftPage.GetGifts()) do
		if(v.check_gsid and not hasGSItem(v.check_gsid))then
			return true;
		end
	end
end

function ExtraGiftPage.OnInit()
	ExtraGiftPage.GetGifts();
	ExtraGiftPage.page = document:GetPageCtrl();
end

function ExtraGiftPage.ShowPage(index)
	ExtraGiftPage.GetGifts();
	index = index or 1;
	local params;
	if(CommonClientService.IsTeenVersion())then
		params = {
			url = "script/apps/Aries/Gift/ExtraGiftPage.teen.html", 
			name = "ExtraGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			-- zorder = 0,
			directPosition = true,
				align = "_ct",
				x = -760/2,
				y = -470/2,
				width = 760,
				height = 470,
		}
	else
		params = {
			url = "script/apps/Aries/Gift/ExtraGiftPage.html", 
			name = "ExtraGiftPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			-- zorder = 0,
			directPosition = true,
				align = "_ct",
				x = -720/2,
				y = -440/2,
				width = 720,
				height = 440,
		}
	end
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	ExtraGiftPage.DoSelected(index);
end
function ExtraGiftPage.DoSelected(index)
	local node = ExtraGiftPage.gifts[index];
	if(node)then
		if(node.show_func) then
			node.show_func();
		else
			ExtraGiftPage.gift_name = node.name;
			ExtraGiftPage.exid_gifts = nil;

			local exid = node.exid;
			local check_gsid = node.check_gsid;
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
			local tos = exTemplate.tos or {};
			local k,v;
			local result = {};
			for k,v in ipairs(tos) do
				local gsid = v.key;
				if(check_gsid and check_gsid ~= gsid)then
					table.insert(result,v);
				end
			end
			ExtraGiftPage.exid_gifts = result;

			if(ExtraGiftPage.page)then
				ExtraGiftPage.page:Refresh(0);
			end
		end
	end
end
function ExtraGiftPage.DS_Func_gifts(index)
	if(not ExtraGiftPage.gifts)then return 0 end
	if(index == nil) then
		return #(ExtraGiftPage.gifts);
	else
		return ExtraGiftPage.gifts[index];
	end
end
function ExtraGiftPage.DS_Func_exid_gifts(index)
	if(not ExtraGiftPage.exid_gifts)then return 0 end
	if(index == nil) then
		return #(ExtraGiftPage.exid_gifts);
	else
		return ExtraGiftPage.exid_gifts[index];
	end
end
function ExtraGiftPage.OpenURL()
	ParaGlobal.ShellExecute("open", ExtraGiftPage.code_url, "", "", 1);
end