--[[
Title: code behind for page CombatProfile.html
Author(s): zrf
Date: 2010/10/28
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
MyCompany.Aries.Desktop.CombatProfile.ShowPage(nid);
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatMagicStarPage.lua");
local CombatProfile = commonlib.gettable("MyCompany.Aries.Desktop.CombatProfile");

local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local Pet = commonlib.gettable("MyCompany.Aries.Pet");

function CombatProfile.ShowPage(nid)
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	CombatProfile.nid = tonumber(nid);
	--commonlib.echo("!!!!!!!!!:ShowPage0");
	Pet.CreateOrGetDragonInstanceBean( CombatProfile.nid, function(msg)
		--commonlib.echo("!!!!!!!!!:ShowPage1");
		--commonlib.echo(msg);
		if(msg and msg.bean)then
			CombatProfile.bean = msg.bean;
			MyCompany.Aries.Desktop.CombatMagicStarPage.GetShouZhang();
			if(CombatProfile.page)then
				CombatProfile.page:Refresh(0.01);
			end
		end
	end,"access plus 1 minutes");

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "CombatCharacterFrame.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -410/2,
            y = -490/2,
            width = 410,
            height = 490,
    });
end

function CombatProfile.Init()
	CombatProfile.page = document:GetPageCtrl();

	--commonlib.echo("!!!!!!!!!!!!!!!:Init");
	--commonlib.echo(CombatProfile.bean);
	
end

function CombatProfile.ShowMLine()
	if(not CombatProfile.bean)then return; end
    local str = [[<div style="position:relative;margin-left:-13px;margin-top:-2px;width:%dpx;height:21px;background:url(Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/pro_32bits.png#0 0 20 21: 7 6 7 6 )"></div>]];
	if( CombatProfile.bean.m > 0)then
		local tmp = CombatProfile.bean.m / CombatProfile.bean.nextlelm;
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

function CombatProfile.GetM()
	if(CombatProfile.bean)then
		return "M值: " .. CombatProfile.bean.m .. "/" .. CombatProfile.bean.nextlelm;
	end
end

function CombatProfile.GetEnergy()
	if(CombatProfile.bean)then
		return CombatProfile.bean.energy;
	end
end

function CombatProfile.GetMLevel()
	if(CombatProfile.bean)then
		return CombatProfile.bean.mlel;
	end
end

function CombatProfile.ShowHPAdd()
	if( not CombatProfile.bean)then return; end

	local lvl = tonumber(CombatProfile.bean.mlel);
	local info = MyCompany.Aries.Desktop.CombatMagicStarPage.SpecialList[lvl + 1];
	--commonlib.echo("!!!!!!!!!!!:ShowHPAdd");
	--commonlib.echo();
	if(CombatProfile.bean.energy > 0 )then
		return "最大HP: +" .. info.HP .. "%";
	else
		return "最大HP: +0%";
	end
end

function CombatProfile.ShowAttackAdd()
	if( not CombatProfile.bean)then return; end

	local lvl = tonumber(CombatProfile.bean.mlel);
	local info = MyCompany.Aries.Desktop.CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatProfile.bean.energy > 0 )then
		return "攻击力: +" .. info.attack .. "%";
	else
		return "攻击力: +0%";
	end
end

function CombatProfile.ShowGuardAdd()
	if( not CombatProfile.bean)then return; end

	local lvl = tonumber(CombatProfile.bean.mlel);
	local info = MyCompany.Aries.Desktop.CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatProfile.bean.energy > 0 )then
		return "防御力: +" .. info.guard .. "%";
	else
		return "防御力: +0%";
	end
end

function CombatProfile.ShowHitAdd()
	if( not CombatProfile.bean)then return; end

	local lvl = tonumber(CombatProfile.bean.mlel);
	local info = MyCompany.Aries.Desktop.CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatProfile.bean.energy > 0 )then
		return "命中率: +" .. info.hit .. "%";
	else
		return "命中率: +0%";
	end
end

function CombatProfile.ShowExpAdd()
	if( not CombatProfile.bean)then return; end

	local lvl = tonumber(CombatProfile.bean.mlel);
	local info = MyCompany.Aries.Desktop.CombatMagicStarPage.SpecialList[lvl + 1];

	if(CombatProfile.bean.energy > 0 )then
		return "战斗经验加成: " .. info.exp .. "倍";
	else
		return "战斗经验加成: 无";
	end
end

function CombatProfile.GetLogo()
	if( not CombatProfile.bean)then return; end

	if(CombatProfile.bean.energy > 0 )then
		return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/magicstar2_32bits.png;0 0 81 84";
	else
		return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/magicstar1_32bits.png;0 0 81 84";
	end
end