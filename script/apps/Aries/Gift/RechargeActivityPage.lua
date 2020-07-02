--[[
Title: 
Author(s): 
Date: 2013/8/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Gift/RechargeActivityPage.lua");
local RechargeActivityPage = commonlib.gettable("MyCompany.Aries.Gift.RechargeActivityPage");
RechargeActivityPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local RechargeActivityPage = commonlib.gettable("MyCompany.Aries.Gift.RechargeActivityPage");

RechargeActivityPage.FirstRechargeGift={ exid = 30081, check_gsid = 50353,};

function RechargeActivityPage.OnInit()
	RechargeActivityPage.page = document:GetPageCtrl();
end
function RechargeActivityPage.RefreshPage()
	if(RechargeActivityPage.page)then
		RechargeActivityPage.page:Refresh(0);
	end
end

function RechargeActivityPage.GetItemsCnt()
	local result = 0;
	RechargeActivityPage.Load()
	if(RechargeActivityPage.gifts)then
		local k,v;		
		for k,v in ipairs(RechargeActivityPage.gifts) do
			local chkgsid = v.mark_gsid;
			local _has = hasGSItem(chkgsid)
			if (not _has) then
				result = result + 1;
			end
		end
		return result;		
	end
	return 0;
end

function RechargeActivityPage.Load(callbackFunc)
	if (RechargeActivityPage.gifts) then
		if(callbackFunc)then
			callbackFunc()
		end
		return
	end
	local config_file="config/Aries/others/rechargegift.teen.xml";
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading rechargegift config file: %s\n", config_file);
		return;
	end
		
	local xmlnode = "/gift/condi";
	
	local _item = nil;
	RechargeActivityPage.gifts = {}
	for _item in commonlib.XPath.eachNode(xmlRoot, xmlnode) do	
		local _sub = {};
		_sub.pre_gsid = _item.attr.pre_gsid;
		_sub.pre_cnt = tonumber(_item.attr.pre_cnt);
		_sub.mark_gsid = tonumber(_item.attr.mark_gsid);
		_sub.exid = _item.attr.exid;
		_sub.ico = _item.attr.ico;
		_sub.gift_value = tonumber(_item.attr.gift_value);
		_sub.sum_rewards = "";
		if (_sub.exid) then
			_sub.exid = tonumber(_sub.exid);
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(_sub.exid);
			local k,v;	
			local _result = "";
			if (exTemplate) then
				for k,v in ipairs(exTemplate.tos) do
					local gsid = v.key;
					if(_sub.mark_gsid and _sub.mark_gsid ~= gsid)then
						if (_result == "") then
							_result = string.format("%d,%d",gsid,v.value);
						else
							_result = string.format("%s;%d,%d",_result,gsid,v.value);
						end
					end
				end
				_sub.sum_rewards = _result;
			end
		end
		table.insert(RechargeActivityPage.gifts,_sub);
	end

	if(callbackFunc)then
		callbackFunc()
	end
end

function RechargeActivityPage.ShowPage(index)
	index = index or 1;
	RechargeActivityPage.Load(function()
		local params = {
			url = "script/apps/Aries/Gift/RechargeActivityPage.teen.html", 
			name = "RechargeActivityPage.ShowPage", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			-- zorder = 0,
			directPosition = true,
				align = "_ct",
				x = -690/2,
				y = -400/2,
				width = 690,
				height = 400,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	

		RechargeActivityPage.DoSelected(index);
	end)
end

function RechargeActivityPage.GetSelectedNode()
	if(RechargeActivityPage.selected_index and RechargeActivityPage.gifts)then
		return RechargeActivityPage.gifts[RechargeActivityPage.selected_index];
	end
end

function RechargeActivityPage.DoSelected(index)
	RechargeActivityPage.selected_index = index or 1;
	RechargeActivityPage.RefreshPage()
end

function RechargeActivityPage.DS_Func_gifts(index)
	if(not RechargeActivityPage.gifts)then return 0 end
	if(index == nil) then
		return #(RechargeActivityPage.gifts);
	else
		return RechargeActivityPage.gifts[index];
	end
end

function RechargeActivityPage.ShowPage_FirstRecharge()
		local params = {
			url = "script/apps/Aries/Gift/FirstRechargePage.teen.html", 
			name = "FirstRechargePage.ShowPage", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			-- zorder = 0,
			directPosition = true,
				align = "_ct",
				x = -650/2,
				y = -400/2,
				width = 650,
				height = 400,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	
end