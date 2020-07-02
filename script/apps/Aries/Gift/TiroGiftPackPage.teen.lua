--[[
Title: 
Author(s): 
Date: 2013/8/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Gift/TiroGiftPackPage.teen.lua");
local TiroGiftPackPage = commonlib.gettable("MyCompany.Aries.Gift.TiroGiftPackPage");
TiroGiftPackPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local TiroGiftPackPage = commonlib.gettable("MyCompany.Aries.Gift.TiroGiftPackPage");

function TiroGiftPackPage.OnInit()
	TiroGiftPackPage.page = document:GetPageCtrl();
end
function TiroGiftPackPage.RefreshPage()
	if(TiroGiftPackPage.page)then
		TiroGiftPackPage.page:Refresh(0);
	end
end

function TiroGiftPackPage.CanGetUpgradeGift()
	local result = false;
    local bean = MyCompany.Aries.Pet.GetBean();
	local combatlel = bean.combatlel;

	TiroGiftPackPage.Load();

	if(TiroGiftPackPage.gifts)then
		local k,v;		
		for k,v in ipairs(TiroGiftPackPage.gifts) do
			local chkgsid = v.mark_gsid;
			local _lvl = v.pre_cnt;
			local _has = hasGSItem(chkgsid)
			if (not _has and combatlel>=_lvl) then
				result = true;
			end
		end		
	end
	return result;
end

function TiroGiftPackPage.Load(callbackFunc)
	if (TiroGiftPackPage.gifts) then
		if(callbackFunc)then
			callbackFunc()
		end
		return
	end

	TiroGiftPackPage.gifts = {};
	local upgrade_gift_exid = {
		{exid=30952, mark_gsid=50407, ico="Texture/Aries/Common/Teen/gifts/giftpack1_32bits.png"},
		{exid=30953, mark_gsid=50408, ico="Texture/Aries/Common/Teen/gifts/giftpack2_32bits.png"},
		{exid=30954, mark_gsid=50409, ico="Texture/Aries/Common/Teen/gifts/giftpack3_32bits.png"},
		{exid=30955, mark_gsid=50410, ico="Texture/Aries/Common/Teen/gifts/giftpack4_32bits.png"},
		{exid=30956, mark_gsid=50411, ico="Texture/Aries/Common/Teen/gifts/giftpack5_32bits.png"},
		{exid=30957, mark_gsid=50412, ico="Texture/Aries/Common/Teen/gifts/giftpack6_32bits.png"},
	}
	local _,_item;
	for _,_item in ipairs(upgrade_gift_exid) do	
		local _exid = _item.exid;		
		if (_exid) then
			local _sub = {};
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(_exid);
			local k,v;	
			local _result = "";
			if (exTemplate) then
				_sub.exid = _exid;
				_sub.ico = _item.ico;
				for k,v in ipairs(exTemplate.tos) do
					local gsid = v.key;
					if(_item.mark_gsid and _item.mark_gsid ~= gsid)then
						if (_result == "") then
							_result = string.format("%d,%d",gsid,v.value);
						else
							_result = string.format("%s;%d,%d",_result,gsid,v.value);
						end
					end
				end
				_sub.sum_rewards = _result;
				_sub.mark_gsid = _item.mark_gsid;
				for k,v in ipairs(exTemplate.pres) do
					_sub.pre_gsid = v.key;
					_sub.pre_cnt = v.value;
				end

				table.insert(TiroGiftPackPage.gifts,_sub);
			end			
		end
		
	end

	if(callbackFunc)then
		callbackFunc()
	end
end

function TiroGiftPackPage.ShowPage(index)
	index = index or 1;
	TiroGiftPackPage.Load(function()
		local params = {
			url = "script/apps/Aries/Gift/TiroGiftPackPage.teen.html", 
			name = "TiroGiftPackPage.ShowPage", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			-- zorder = 0,
			directPosition = true,
				align = "_ct",
				x = -600/2,
				y = -400/2,
				width = 600,
				height = 400,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	

		TiroGiftPackPage.DoSelected(index);
	end)
end

function TiroGiftPackPage.GetSelectedNode()
	if(TiroGiftPackPage.selected_index and TiroGiftPackPage.gifts)then
		return TiroGiftPackPage.gifts[TiroGiftPackPage.selected_index];
	end
end

function TiroGiftPackPage.DoSelected(index)
	TiroGiftPackPage.selected_index = index or 1;
	TiroGiftPackPage.RefreshPage()
end

function TiroGiftPackPage.DS_Func_gifts(index)
	if(not TiroGiftPackPage.gifts)then return 0 end
	if(index == nil) then
		return #(TiroGiftPackPage.gifts);
	else
		return TiroGiftPackPage.gifts[index];
	end
end
