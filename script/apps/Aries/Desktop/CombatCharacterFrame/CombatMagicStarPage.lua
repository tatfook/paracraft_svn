--[[
Title: code behind for page CombatMagicStarPage.html
Author(s): zrf
Date: 2010/9/15
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/CombatMagicStarPage.lua
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");

local CombatMagicStarPage = commonlib.gettable("MyCompany.Aries.Desktop.CombatMagicStarPage");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 魔法星特有法杖交换ID列表
CombatMagicStarPage.ExList = 
{
	[1290] = 599,
	[1291] = 600,
	[1292] = 601,
	[1296] = 602,
	[1297] = 603,

};

CombatMagicStarPage.NeedInfo = 
{
{ mlevel="魔法星有能量",},
{ mlevel="魔法星有能量",level="21级以上"},
{ mlevel="魔法星有能量",level="31级以上"},
{ mlevel="魔法星6级以上",},
{ mlevel="魔法星10级",},
};

CombatMagicStarPage.SpecialList = {
{ level=0,HP="5",attack="5",guard="4",cure="2",becured="2",hit="2",exp="150", stamina="0", weekly_money="300", daily_money="120", friends="0"},
{ level=1,HP="5",attack="5",guard="5",cure="3",becured="3",hit="2",exp="155", stamina="10", weekly_money="360", daily_money="120", friends="10"},
{ level=2,HP="5",attack="6",guard="6",cure="4",becured="3",hit="3",exp="160", stamina="20", weekly_money="480", daily_money="160", friends="20"},
{ level=3,HP="6",attack="7",guard="6",cure="4",becured="3",hit="3",exp="165", stamina="30", weekly_money="600", daily_money="200", friends="30"},
{ level=4,HP="6",attack="8",guard="7",cure="4",becured="5",hit="4",exp="170", stamina="40", weekly_money="720", daily_money="240", friends="40"},
{ level=5,HP="6",attack="9",guard="7",cure="5",becured="5",hit="4",exp="175", stamina="50", weekly_money="840", daily_money="280", friends="50"},
{ level=6,HP="7",attack="10",guard="7",cure="5",becured="6",hit="4",exp="180", stamina="60", weekly_money="960", daily_money="320", friends="60"},
{ level=7,HP="7",attack="12",guard="8",cure="6",becured="6",hit="5",exp="185", stamina="70", weekly_money="1020", daily_money="340", friends="70"},
{ level=8,HP="7",attack="14",guard="8",cure="6",becured="7",hit="5",exp="190", stamina="80", weekly_money="1080", daily_money="360", friends="80"},
{ level=9,HP="8",attack="17",guard="8",cure="6",becured="7",hit="5",exp="195", stamina="90", weekly_money="1140", daily_money="380", friends="90"},
{ level=10,HP="10",attack="20",guard="9",cure="8",becured="8",hit="6",exp="200", stamina="100", weekly_money="1200", daily_money="400", friends="100"},
};

CombatMagicStarPage.Teen_SpecialList = {
{ speed="10",exp="20",hp="20", vipright="优先进入满员服务器，每天领取银币",gsid=16098,giftnum="1",taggsid=50349,exid=601},
{ speed="10",exp="25",hp="30", vipright="",gsid=1770,giftnum="1",taggsid=50347,exid=599},
{ speed="15",exp="30",hp="40", vipright="装备无损耐久度",gsid=12046,giftnum="5",taggsid=50350,exid=602},
{ speed="15",exp="35",hp="50", vipright="获取升级神卡：奥能冲击",gsid=42418,giftnum="1",taggsid=50348,exid=600},
{ speed="20",exp="40",hp="60", vipright="获取神宠：梦幻大牙怪",gsid=10139,giftnum="1",taggsid=50355,exid=603},
{ speed="20",exp="50",hp="70", vipright="魔晶宝石",gsid=26126,giftnum="1",taggsid=50356,exid=30720},
{ speed="25",exp="60",hp="80", vipright="获取神宠：奥术蟠龙",gsid=10136,giftnum="1",taggsid=50357,exid=30721},
{ speed="25",exp="70",hp="90", vipright="获取永久装备：天使之翼",gsid=16104,giftnum="1",taggsid=50375,exid=30777},
{ speed="30",exp="80",hp="100", vipright="平衡攻击卡",gsid=43447,giftnum="1",taggsid=12159,exid=20201},
{ speed="30",exp="90",hp="110", vipright="双人传奇坐骑：灵狐苍雪",gsid=16297,giftnum="1",taggsid=12160,exid=20202},
};


-- get special value by name
function CombatMagicStarPage.GetSpecialValueKids(name, level)
	if(not level) then
		level = VIP.GetMagicStarLevel();
	end
	local list = CombatMagicStarPage.SpecialList[(level or 0)+1]
	if(list) then
		return list[name];
	end
end



CombatMagicStarPage.EnergyStones = CombatMagicStarPage.EnergyStones or {};
CombatMagicStarPage.CurTab = 1;
function CombatMagicStarPage.Init()
	CombatMagicStarPage.page = document:GetPageCtrl();

	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	CombatMagicStarPage.IsVIP = MyCompany.Aries.VIP.IsVIPAndActivated();
	CombatMagicStarPage.GetShouZhang();
	if( CombatMagicStarPage.bean.energy <= 0)then
		CombatMagicStarPage.energyflag = true;
	elseif(CombatMagicStarPage.energyflag==true)then
		CombatMagicStarPage.energyflag = false;
		CombatMagicStarPage.OnClickEquip();
	end
	--commonlib.echo("!!!!!!!!!!!!!!!!!:Init");
	--commonlib.echo(CombatMagicStarPage.bean);
end

function CombatMagicStarPage.GetTooltip(gsid)
    gsid = tonumber(gsid);
    if(not gsid)then return end
	local str = string.format("page://script/apps/Aries/Desktop/ApparelTooltip.html?gsid=%d",gsid);
	--commonlib.echo("!!!!!!!!!:GetTooltip");
	--commonlib.echo(str);
    return str;
end

function CombatMagicStarPage.ShowEquipBtn()
	if( MyCompany.Aries.VIP.IsMagicStarEquipped() )then
		return false;
	else
		return true;
	end
end


function CombatMagicStarPage.OnClickEquip()
	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	if( CombatMagicStarPage.bean.energy <= 0)then
		_guihelper.Custom_MessageBox("您的魔法星能量值为0，所有神奇功能都消失了,无法携带。快用能量石为魔法星补充能量吧！",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				
			else
				CombatMagicStarPage.OnClickGetMagicStone();
			end
		--end,_guihelper.MessageBoxButtons.OK);
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/getstone_btn_32bits.png; 0 0 153 49"});
	else
		MyCompany.Aries.VIP.EquipMagicStar();
		CombatMagicStarPage.page:Refresh(0.1);
	end
end

function CombatMagicStarPage.OnClickUnEquip()
	MyCompany.Aries.VIP.UnequipMagicStar();
	CombatMagicStarPage.page:Refresh(0.1);
end

function CombatMagicStarPage.ShowHPAdd()
	--commonlib.echo("!!!!!!!!!!!:ShowHPAdd0");

	if( not CombatMagicStarPage.bean)then return; end

	local lvl = tonumber(CombatMagicStarPage.bean.mlel);
	local info = CombatMagicStarPage.SpecialList[lvl + 1];
	--commonlib.echo("!!!!!!!!!!!:ShowHPAdd");
	--commonlib.echo(info.hit);
	if(CombatMagicStarPage.IsVIP and CombatMagicStarPage.bean.energy > 0 )then
		return "最大HP: +" .. info.HP .. "%";
	else
		return "最大HP: +0%";
	end
end

function CombatMagicStarPage.ShowAttackAdd()
	if( not CombatMagicStarPage.bean)then return; end

	local lvl = tonumber(CombatMagicStarPage.bean.mlel);
	local info = CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatMagicStarPage.IsVIP and CombatMagicStarPage.bean.energy > 0 )then
		return "攻击力: +" .. info.attack .. "%";
	else
		return "攻击力: +0%";
	end
end

function CombatMagicStarPage.ShowExpAdd()
	if( not CombatMagicStarPage.bean)then return; end

	local lvl = tonumber(CombatMagicStarPage.bean.mlel);
	local info = CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatMagicStarPage.IsVIP and CombatMagicStarPage.bean.energy > 0 )then
		return "战斗经验:+ " .. info.exp .. "%";
	else
		return "战斗经验:+0%";
	end
end

function CombatMagicStarPage.ShowGuardAdd()
	if( not CombatMagicStarPage.bean)then return; end

	local lvl = tonumber(CombatMagicStarPage.bean.mlel);
	local info = CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatMagicStarPage.IsVIP and CombatMagicStarPage.bean.energy > 0 )then
		return "防御力: +" .. info.guard .. "%";
	else
		return "防御力: +0%";
	end
end

function CombatMagicStarPage.ShowHitAdd()
	if( not CombatMagicStarPage.bean)then return; end

	local lvl = tonumber(CombatMagicStarPage.bean.mlel);
	local info = CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatMagicStarPage.IsVIP and CombatMagicStarPage.bean.energy > 0 )then
		return "命中率: +" .. info.hit .. "%";
	else
		return "命中率: +0%";
	end
end

function CombatMagicStarPage.GetShouZhang()
	local i;
	
	if(not CombatMagicStarPage.ShouZhang)then
		local tmp = MyCompany.Aries.VIP.GetAvailableVIPLeftHandItemGSIDs();
		--commonlib.echo("!!!!!!!!!!!!!:GetShouZhang1");
		--commonlib.echo(tmp);
		CombatMagicStarPage.ShouZhang = {};
		for i = 1, #tmp do
			table.insert( CombatMagicStarPage.ShouZhang, {gsid = tonumber(tmp[i]),} );
		end
	end

	for i = 1, #CombatMagicStarPage.ShouZhang do
		if( hasGSItem(CombatMagicStarPage.ShouZhang[i].gsid) )then
			CombatMagicStarPage.ShouZhang[i].has = true;
		else
			CombatMagicStarPage.ShouZhang[i].has = false;
		end
	end
end

function CombatMagicStarPage.GetItems()
	local bags = { 0, };

	--CombatMagicStarPage.EnergyStones.status = 1;
	bags.ReturnCount = 0;

	local _,bag;
	for _,bag in ipairs(bags) do
		ItemManager.GetItemsInBag( bag, "" .. bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			--commonlib.echo("!!!!!!!!!!!!!!!:GetItems");
			if( bags.ReturnCount >= #bags )then
				local count = 0;
				local __,bag;

				for __, bag in ipairs(bags) do
					local i;
					local tmpcount = 0;

					for i = 1, ItemManager.GetItemCountInBag(bag) do
						local item = ItemManager.GetItemByBagAndOrder( bag, i );
						--commonlib.echo(item);
						--commonlib.echo(item.gsid);
						if((item ~= nil) and (item.gsid == 998))then
							CombatMagicStarPage.EnergyStones[count + tmpcount + 1] = { guid = item.guid, gsid = item.gsid, is_shard = false, is_shard2 = false};
							tmpcount = tmpcount + 1;
						elseif((item ~= nil) and (item.gsid == 977))then
							CombatMagicStarPage.EnergyStones[count + tmpcount + 1] = { guid = item.guid, gsid = item.gsid, is_shard = true, is_shard2 = false};
							tmpcount = tmpcount + 1;
						elseif((item ~= nil) and (item.gsid == 967))then
							CombatMagicStarPage.EnergyStones[count + tmpcount + 1] = { guid = item.guid, gsid = item.gsid, is_shard = false, is_shard2 = true};
							tmpcount = tmpcount + 1;
						end
					end

					count = count + tmpcount;
				end

				if(CombatMagicStarPage.page)then
					CombatMagicStarPage.page:Refresh(0.01);
				end
			end
		end, "access plus 5 minutes");
	end
end

function CombatMagicStarPage.OnClickEnergyStone()
	local lastlevel = CombatMagicStarPage.bean.mlel;
	--commonlib.echo("!!!!!!!!!!!!!!!!!!!!:OnClickEnergyStone");
	ItemManager.UseEnergyStone( function(msg)
		System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "UpdateUserInfo", function(msg)
            --commonlib.echo("===========.OnClickEnergyStone")
            --commonlib.echo(msg)                                    
            CombatMagicStarPage.bean = msg.users[1];
		    if( lastlevel < tonumber(CombatMagicStarPage.bean.mlel) )then
                --commonlib.echo("=============add mlel")  
				_guihelper.MessageBox([[<div style="float:left;color:#000000">哇，真是好棒啊，这颗能量石让你的魔法星增加了：<div style="float:left;color:#ff0000;">能量值：31点   M值：100点</div>你的魔法星升到]]..CombatMagicStarPage.bean.mlel..[[级啦！</div>]]);
            else
                --commonlib.echo("==========add energy")  
				_guihelper.MessageBox([[<div style="float:left;color:#000000">太棒了，你使用了一颗能量石，为你的魔法星增加了: <div style="float:left;color:#ff0000;">能量值：31点   M值：100点</div></div>]]);	
		    end
		end, "access plus 0 day");
	end, function()
		--commonlib.echo("!!!!!!!!!!!!!!!!!!!!:OnClickEnergyStone1");
		CombatMagicStarPage.GetItems();
		MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI(true);
	end);
end

function CombatMagicStarPage.OnClickEnergyStoneShard()
	local lastlevel = CombatMagicStarPage.bean.mlel;
	--commonlib.echo("!!!!!!!!!!!!!!!!!!!!:OnClickEnergyStoneShard");
	ItemManager.UseEnergyStoneShard( function(msg)
		System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "UpdateUserInfo", function(msg)
            --commonlib.echo("===========.OnClickEnergyStoneShard")
            --commonlib.echo(msg)                                    
            CombatMagicStarPage.bean = msg.users[1];
		    if( lastlevel < tonumber(CombatMagicStarPage.bean.mlel) )then
				_guihelper.MessageBox([[<div style="float:left;color:#000000">哇，真是好棒啊，这颗能量石碎片让你的魔法星增加了：<div style="float:left;color:#ff0000;">能量值：3点   M值：5点</div>你的魔法星升到</div>]] .. CombatMagicStarPage.bean.mlel .. "级啦！");	
			else
				_guihelper.MessageBox([[<div style="float:left;color:#000000">太棒了，你使用了一颗能量石碎片，为你的魔法星增加了: <div style="float:left;color:#ff0000;">能量值：3点   M值：5点</div></div>]]);	
		    end
		end, "access plus 0 day");
	end, function()
		--commonlib.echo("!!!!!!!!!!!!!!!!!!!!:OnClickEnergyStoneShard1");
		CombatMagicStarPage.GetItems();
	end);
end

function CombatMagicStarPage.OnClickEnergyStoneShard2()
	local lastlevel = CombatMagicStarPage.bean.mlel;
	--commonlib.echo("!!!!!!!!!!!!!!!!!!!!:OnClickEnergyStoneShard");
	ItemManager.UseEnergyStoneShard2( function(msg)
		System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "UpdateUserInfo", function(msg)
            --commonlib.echo("===========.OnClickEnergyStoneShard")
            --commonlib.echo(msg)                                    
            CombatMagicStarPage.bean = msg.users[1];
		    if( lastlevel < tonumber(CombatMagicStarPage.bean.mlel) )then
				_guihelper.MessageBox([[<div style="float:left;color:#000000">哇，真是好棒啊，这颗能量石碎片让你的魔法星增加了：<div style="float:left;color:#ff0000;">能量值：1点   M值：2点</div>你的魔法星升到</div>]] .. CombatMagicStarPage.bean.mlel .. "级啦！");	
			else
				_guihelper.MessageBox([[<div style="float:left;color:#000000">太棒了，你使用了一颗能量石碎片，为你的魔法星增加了: <div style="float:left;color:#ff0000;">能量值：1点   M值：2点</div></div>]]);	
		    end
		end, "access plus 0 day");
	end, function()
		--commonlib.echo("!!!!!!!!!!!!!!!!!!!!:OnClickEnergyStoneShard1");
		CombatMagicStarPage.GetItems();
	end);
end

function CombatMagicStarPage.GetM()
	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	if(CombatMagicStarPage.bean)then
		return "M值: " .. CombatMagicStarPage.bean.m .. "/" .. CombatMagicStarPage.bean.nextlelm;
	end
end

function CombatMagicStarPage.ShowMLine()
	--CombatMagicStarPage.bean = MyCompany.Aries.Pet.GetBean();
	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
    local str = [[<div style="position:relative;margin-left:-13px;margin-top:-2px;width:%dpx;height:21px;background:url(Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/pro_32bits.png#0 0 20 21: 7 6 7 6 )"></div>]];
	if( CombatMagicStarPage.bean.m > 0 )then
		local tmp = CombatMagicStarPage.bean.m / CombatMagicStarPage.bean.nextlelm;
		tmp = tmp * 148;

		if(tmp > 148)then
			tmp = 148;
		elseif( tmp < 14)then
			tmp = 14;
		end
		str = string.format( str, tmp );
	
		return str;
	else
		return "";
	end
end

function CombatMagicStarPage.ShowMLineTeen(maxlen)
	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
    local str = [[<div zorder="1" style="position:relative;margin-left:-11px;margin-top:0px;width:%dpx;height:16px;background:url(Texture/Aries/Common/ThemeTeen/barbg_32bits.png#0 0 32 19: 7 8 7 8 )"></div>]];
	if( CombatMagicStarPage.bean.m > 0 )then
		local tmp = CombatMagicStarPage.bean.m / CombatMagicStarPage.bean.nextlelm;
		tmp = tmp * maxlen;

		if(tmp > maxlen)then
			tmp = maxlen;
		elseif( tmp < 14)then
			tmp = 14;
		end

		local mlvl = MyCompany.Aries.Player.GetVipLevel();
		if (mlvl==#(CombatMagicStarPage.Teen_SpecialList)) then
			tmp = maxlen
		end
		str = string.format( str, tmp );
	
		return str;
	else
		return "";
	end
end

function CombatMagicStarPage.GetMLevel()
	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	if(CombatMagicStarPage.bean)then
		return CombatMagicStarPage.bean.mlel;
	end
end

function CombatMagicStarPage.GetEnergy()
	CombatMagicStarPage.bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	if(CombatMagicStarPage.bean)then
		return CombatMagicStarPage.bean.energy;
	end
end

function CombatMagicStarPage.DS_TAB1(index)
	index = tonumber(index);
	if(index==nil)then
		return #CombatMagicStarPage.SpecialList;
	else
		return CombatMagicStarPage.SpecialList[index];
	end
end

function CombatMagicStarPage.DS_Func(index)
	if(not CombatMagicStarPage.EnergyStones)then return; end
	--commonlib.echo("!!!!!!!!!!!!!!:DS_Func");
	--commonlib.echo(CombatMagicStarPage.EnergyStones);
	index = tonumber(index);
	local size = 0;
	local self = CombatMagicStarPage
	if(self.EnergyStones)then
		size = #self.EnergyStones;
	end
	local displaycount = math.ceil(size / 4) * 4;
	if(displaycount == 0)then
		displaycount = 4;
	end

	local i;
	for i = size + 1,displaycount do
		if(i == 1) then
			self.EnergyStones[i] = { gsid = 998, is_shard = false,guid = 0, is_pe_item=true};
		else
			self.EnergyStones[i] = { is_shard = false,guid = 0, };
		end
	end
	
	if(index==nil)then
		return #self.EnergyStones;
	else
		return self.EnergyStones[index];
	end
end

function CombatMagicStarPage.DS_Func2(index)
	if(not CombatMagicStarPage.ShouZhang)then return; end

	index = tonumber(index);
	if( index == nil )then
		return #CombatMagicStarPage.ShouZhang;
	else
		return CombatMagicStarPage.ShouZhang[index];
	end
end

function CombatMagicStarPage.OnClickGetFaZhang(index)
	if(not CombatMagicStarPage.ShouZhang or not index )then return; end
	--commonlib.echo("!!!!!!!!!!:OnClickGetFaZhang");
	--commonlib.echo(index);
	index = tonumber(index);
	local gsid = CombatMagicStarPage.ShouZhang[index].gsid;
	local exid = CombatMagicStarPage.ExList[gsid];
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	ItemManager.ExtendedCost(exid, nil, nil, function(msg)
		--commonlib.echo("!!!!!!!!!!:OnClickGetFaZhang2");
		--commonlib.echo(msg);
		if(msg.issuccess == true)then
			_guihelper.Custom_MessageBox("恭喜你成功领取了" .. gsItem.template.name .. "，记得打开背包装备上去哦！",function(result)
				CombatMagicStarPage.page:Refresh(0.01);
			end,_guihelper.MessageBoxButtons.OK);
		else
			_guihelper.Custom_MessageBox("很遗憾，你还不符合领取条件呢，仔细看看条件哦！",function(result)
			end,_guihelper.MessageBoxButtons.OK);			
		end
	end);
end

function CombatMagicStarPage.OnClickGetMagicStone()
    local gsid=998;
    Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);	
	-- PurchaseEnergyStone.Show();
	if(CombatMagicStarPage.page)then
		CombatMagicStarPage.page:Refresh(0.01);
	end
end

function CombatMagicStarPage.OnClickHad(index)
	index = tonumber(index);
	local gsid = CombatMagicStarPage.ShouZhang[index].gsid;
	local exid = CombatMagicStarPage.ExList[gsid];
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	--commonlib.echo("!!!!!!!!!!:OnClickHad");
	--commonlib.echo(gsItem);

	_guihelper.Custom_MessageBox("你已经领取了" .. gsItem.template.name .. "，不能重复领取哦!",function(result)
		end,_guihelper.MessageBoxButtons.OK);	
end

function CombatMagicStarPage.GetNeedTooltip(index)
	index = tonumber(index);
	local info = CombatMagicStarPage.NeedInfo[index];

	if(info.level == nil)then
		return "领取条件:\r\n" .. info.mlevel;
	else
		return "领取条件:\r\n" .. info.mlevel .. "\r\n战斗等级: " .. info.level;
	end
end

function CombatMagicStarPage.GetLogo()
	if( not CombatMagicStarPage.bean)then return; end

	if(CombatMagicStarPage.bean.energy > 0 )then
		return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/magicstar2_32bits.png;0 0 81 84";
	else
		return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/magicstar1_32bits.png; 0 0 81 84";
	end
end

function CombatMagicStarPage.EnergyStoneTooltip()
	--return "能量石\r\n为魔法星补充能量\r\n\r\nM值: +100\r\n能量: +31\r\n\r\n鼠标点击使用";
	return "page://script/apps/Aries/Desktop/ApparelTooltip.html?gsid=998";
end

function CombatMagicStarPage.EnergyStoneShardTooltip()
	--return "能量石\r\n为魔法星补充能量\r\n\r\nM值: +5\r\n能量: +3\r\n\r\n鼠标点击使用";
	return "page://script/apps/Aries/Desktop/ApparelTooltip.html?gsid=977";
end

function CombatMagicStarPage.GetState()
	if( not CombatMagicStarPage.bean)then return; end

	if(CombatMagicStarPage.bean.energy > 0 )then
		return CombatMagicStarPage.bean.mlel .. "级魔法星";
	else
		return "石化-需要能量激活";
	end
end