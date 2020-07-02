--[[
Title: 
Author(s): leio
Date: 2013/6/6
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/UI/AdditionalLootPage.lua")
local AdditionalLootPage = commonlib.gettable("MyCompany.Aries.Combat.AdditionalLootPage");
AdditionalLootPage.ShowPage({},1141);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local AdditionalLootPage = commonlib.gettable("MyCompany.Aries.Combat.AdditionalLootPage");
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
AdditionalLootPage.motion_is_played = false;
AdditionalLootPage.stamina_cost = 1;
AdditionalLootPage.box_is_pending = false;

function AdditionalLootPage.OnInit()
	AdditionalLootPage.page = document:GetPageCtrl();
end
function AdditionalLootPage.ShowPage(notification_msg,arena_id,arena_mob_file,difficulty,stamina_cost)
	echo("===========AdditionalLootPage.ShowPage");
	echo({notification_msg,arena_id,arena_mob_file,difficulty,stamina_cost});
	local url;
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/Combat/UI/AdditionalLootPage.teen.html";
	else
		url = "script/apps/Aries/Combat/UI/AdditionalLootPage.html";
	end
	AdditionalLootPage.box_is_pending = false;
	AdditionalLootPage.motion_is_played = false;
	AdditionalLootPage.arena_id = arena_id;
	AdditionalLootPage.boss_info = nil;
	AdditionalLootPage.loots_list = nil;
	AdditionalLootPage.all_loots_list = nil;
	AdditionalLootPage.stamina_cost = stamina_cost or 1;

    local bean = MyCompany.Aries.Pet.GetBean() or {};
	--echo("============bean");
	--echo(bean);
	local mlel = bean.mlel or 0;
	--local cnt = -1;
	--if(mlel <= 0)then
		--cnt = 1;
	--elseif(mlel >= 1 and mlel <= 3)then
		--cnt = 2;
	--elseif(mlel >= 4 and mlel <= 6)then
		--cnt = 3;
	--elseif(mlel >= 7 and mlel <= 9)then
		--cnt = 4;
	--else
		--cnt = 5;
	--end

	-- NOTE 2014/9/10:
	--李宇(Liyu) 09:38:19
	--调整为 vip等级+1
	--李宇(Liyu) 09:40:42
	--cnt=mlel+1
	local cnt = 0;
	if(mlel) then
		cnt = mlel + 1;
	end
	
	AdditionalLootPage.choice = cnt;
	local arena_data_map = MsgHandler.Get_arena_data_map();
	local door_locks = {};
	local _arena_id, data;
	echo("===============search arena_id");
	echo(arena_id);
	local arena_info;
	for _arena_id, data in pairs(arena_data_map) do
		if(arena_id == _arena_id and data.mobs)then
			arena_info = data;
			echo("===============search arena_id successful");
			echo(data.p_x);
			echo(data.p_y);
			echo(data.p_z);
			local k,v;
			local max_hp = 0;
			for k,v in ipairs(data.mobs) do
				if(v.max_hp >= max_hp)then
					AdditionalLootPage.boss_info = v;
					max_hp = v.max_hp;
				end
			end
			break;
		end
	end
	echo("===============AdditionalLootPage.boss_info");
	echo(AdditionalLootPage.boss_info);
	echo("===============arena_info");
	echo(arena_info);
	if(notification_msg)then
		local stats = notification_msg.stats;
		local adds = notification_msg.adds;
		local updates = notification_msg.updates;
		AdditionalLootPage.loots_list = CommonClientService.UnionList(stats,adds);
		AdditionalLootPage.loots_list = CommonClientService.UnionList(AdditionalLootPage.loots_list,updates);
		CommonClientService.Fill_List(AdditionalLootPage.loots_list,12);

		local mode = LobbyClientServicePage.ModeStrToNum(difficulty);
		local position;
		if(arena_info)then
			position = string.format("%d,%d,%d",arena_info.p_x,arena_info.p_y,arena_info.p_z);
		end
		AdditionalLootPage.all_loots_list = LobbyClientServicePage.GetLootsListByWorldName_Fullpath(arena_mob_file,mode,position);
		CommonClientService.Fill_List(AdditionalLootPage.all_loots_list,18);
	end
	
	local params = {
		url = url, 
		name = "AdditionalLootPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		--enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		-- zorder = 0,
		directPosition = true,
			align = "_ct",
			x = -650/2,
			y = -480/2,
			width = 650,
			height = 480,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	AdditionalLootPage.RefreshPage();
end
function AdditionalLootPage.DS_Func(index)
	if(not AdditionalLootPage.loots_list)then return 0 end
	if(index == nil) then
		return #(AdditionalLootPage.loots_list);
	else
		return AdditionalLootPage.loots_list[index];
	end
end
function AdditionalLootPage.RequestAdditionalLootPlain()
	if(not AdditionalLootPage.arena_id)then
		return
	end
	if(not AdditionalLootPage.CanOpen("Plain"))then
		return 
	end
	AdditionalLootPage.box_is_pending = true;
	MsgHandler.RequestAdditionalLootPlain(AdditionalLootPage.arena_id);
	AdditionalLootPage.RefreshPage();
end
function AdditionalLootPage.RequestAdditionalLootAdv()
	if(not AdditionalLootPage.arena_id)then
		return
	end
	if(not AdditionalLootPage.CanOpen("Adv"))then
		return 
	end
	AdditionalLootPage.box_is_pending = true;
	MsgHandler.RequestAdditionalLootAdv(AdditionalLootPage.arena_id);
	AdditionalLootPage.RefreshPage();
end
function AdditionalLootPage.CanOpen(type)
    local ItemManager = System.Item.ItemManager;
    local hasGSItem = ItemManager.IfOwnGSItem;
    local Pet = commonlib.gettable("MyCompany.Aries.Pet");
    local bean = Pet.GetBean();
	local stamina = bean.stamina or 0;
	local cnt = AdditionalLootPage.GetChoicCnt()
	if(cnt <= 0)then
		_guihelper.MessageBox("你已经没有开宝箱的次数了！");
		return
	end
	if(stamina < AdditionalLootPage.stamina_cost)then
		_guihelper.Custom_MessageBox("您的精力值不足，无法打开宝箱。", function(result)
					if(result == _guihelper.DialogResult.Yes)then
						local itemname = "";
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(17250);
						if(gsItem) then
							-- 17250_EnergyPills
							itemname = gsItem.template.name;
						end
						-- use item
						local hasGSItem = ItemManager.IfOwnGSItem;
						local bHas, guid = hasGSItem(17250);
						if(bHas) then
							local item = ItemManager.GetItemByGUID(guid);
							if(item and item.guid > 0) then
								item:OnClick("left");
								return;
							end
						end
						_guihelper.Custom_MessageBox(string.format("你还没有【%s】，需要立刻购买吗？", itemname), function(result)
							if(result == _guihelper.DialogResult.Yes) then
								local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
								if(command) then
									command:Call({gsid = 17250});
								end
							end
						end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "立刻购买", no = "看看再说"});
					end
				end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "使用精力药水", no = "关闭"});
        return;
    end
    if(type == "Adv")then
        if(not hasGSItem(12059))then
			_guihelper.Custom_MessageBox("您没有黄金钥匙，无法打开宝箱。", function(result)
					if(result == _guihelper.DialogResult.Yes) then
						local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
						if(command) then
							-- 12059_GoldKey
							command:Call({gsid = 12059});
						end
					end
				end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "购买黄金钥匙", no = "关闭"});
            return;
        end
    end
	return true;
end
function AdditionalLootPage.IsEnabled(type)
    return not AdditionalLootPage.box_is_pending;
end
--@param type:宝箱类型 "Plain" or "Adv"
--@param cnt:剩余可以开的次数
function AdditionalLootPage.LootsHandle(type,cnt)
	echo("==============AdditionalLootPage.LootsHandle");
	echo({type,cnt});
	if(AdditionalLootPage.box_is_pending)then
		if(type and cnt)then
			AdditionalLootPage.choice = cnt;
			AdditionalLootPage.box_is_pending = false;
			AdditionalLootPage.RefreshPage();
		end
	end
end
function AdditionalLootPage.DS_Func_all_loots(index)
	if(not AdditionalLootPage.all_loots_list)then return 0 end
	if(index == nil) then
		return #(AdditionalLootPage.all_loots_list);
	else
		return AdditionalLootPage.all_loots_list[index];
	end
end
function AdditionalLootPage.GetChoicCnt()
	return AdditionalLootPage.choice or 0;
end
function AdditionalLootPage.RefreshPage()
	if(AdditionalLootPage.page)then
		AdditionalLootPage.page:Refresh(0);
	end
end
