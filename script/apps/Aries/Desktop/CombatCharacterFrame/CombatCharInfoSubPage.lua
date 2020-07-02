--[[
Title: code behind for page CombatCharInfoSubPage.html
Author(s): zrf
Date: 2010/9/6
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharInfoSubPage.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]] 
NPL.load("(gl)script/apps/Aries/Help/CombatHelp/CombatHelpPage.lua");
local CombatCharInfoSubPage = commonlib.gettable("MyCompany.Aries.Desktop.CombatCharInfoSubPage");

function CombatCharInfoSubPage.GetMedals()
	if(not CombatCharInfoSubPage.Medals)then
		local bag = 10062;
		CombatCharInfoSubPage.Medals = {status=1};
		CombatCharInfoSubPage.itemmanager.GetItemsInBag( bag, "CombatCharInfoSubPage_medal", function(msg)

		CombatCharInfoSubPage.Medals = {
			{isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"},
			{isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"},
			{isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"},
			{isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"},
			{isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"},
			{isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = "魔塔奇兵徽章"},

			};
			local medal_series = {
				{20004, 20006, 20007, 20008},
				{20010, 20011, 20012, 20013},
				{20005, 20001, 20002, 20003},
				{20016, 20017, 20018, 20019},
				{20021, 20022, 20023, 20024},
				{20025, 20026, 20027, 20028},
			};
			local hasGSItem = System.Item.ItemManager.IfOwnGSItem;
			local i;
			for i = 1, #(medal_series) do
				local ii;
				for ii = 1, #(medal_series[i]) do
					local gsid = medal_series[i][ii];
					local name = "";
					local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem) then
						name = gsItem.template.name;
					end

					CombatCharInfoSubPage.Medals[i].name = CombatCharInfoSubPage.Medals[i].tooltip;

					if(hasGSItem(medal_series[i][ii])) then

						CombatCharInfoSubPage.Medals[i].isempty = false;
						CombatCharInfoSubPage.Medals[i].isnotempty = true;
						CombatCharInfoSubPage.Medals[i].gsid = gsid;
						CombatCharInfoSubPage.Medals[i].name = name;

					end
				end
			end

									--commonlib.echo("!!!!!!!!!!!!!!:GetMedals");
						--commonlib.echo(CombatCharInfoSubPage.Medals);

		end, "access plus 5 minutes" );
	end
end

function CombatCharInfoSubPage.Init()
	CombatCharInfoSubPage.curpage = CombatCharInfoSubPage.curpage or 1;
	CombatCharInfoSubPage.pagectrl = document:GetPageCtrl();
	CombatCharInfoSubPage.combat = commonlib.gettable("MyCompany.Aries.Combat");
	CombatCharInfoSubPage.itemmanager = System.Item.ItemManager;

	local tmp = tostring(CombatCharInfoSubPage.curpage);

	if(CombatCharInfoSubPage.pagectrl:GetValue("tabProfile") ~= tmp )then
		CombatCharInfoSubPage.pagectrl:SetValue("tabProfile", tmp);
	end

	CombatCharInfoSubPage.nid = CombatCharInfoSubPage.nid or System.App.profiles.ProfileManager.GetNID();
	CombatCharInfoSubPage.nid = tonumber(CombatCharInfoSubPage.nid);
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean)then
		CombatCharInfoSubPage.combatlevel = bean.combatlel or 0;
	end
	CombatCharInfoSubPage.hp, CombatCharInfoSubPage.maxhp = MyCompany.Aries.Desktop.HPMyPlayerArea.GetHP();
	CombatCharInfoSubPage.exp,CombatCharInfoSubPage.maxexp = MyCompany.Aries.Desktop.EXPArea.GetEXP();

	CombatCharInfoSubPage.GetMedals();
	CombatCharInfoSubPage.bean = MyCompany.Aries.Pet.GetBean();
end

function CombatCharInfoSubPage.OnRadioClick(value)
	--commonlib.echo("!!:OnClickTab 0");
	--commonlib.echo(value);
	--commonlib.echo(CombatCharInfoSubPage.curpage);
	--CombatCharInfoSubPage.pagectrl:SetValue("tabProfile", value);
	CombatCharInfoSubPage.curpage = tonumber(value);
	--commonlib.echo(CombatCharInfoSubPage.curpage);

	CombatCharInfoSubPage.pagectrl:Refresh(0.01);

end

function CombatCharInfoSubPage.GetNID()
	return CombatCharInfoSubPage.nid;
end

function CombatCharInfoSubPage.GetPage()
	--commonlib.echo("!!:GetPage ");
	--commonlib.echo(CombatCharInfoSubPage.curpage);
	return CombatCharInfoSubPage.curpage;
end

--function CombatCharInfoSubPage.OnClickTab(name)
	--commonlib.echo("!!:OnClickTab 0");
	--commonlib.echo(name);
	--commonlib.echo(CombatCharInfoSubPage.curpage);
	--local index = tonumber(name);
	--CombatCharInfoSubPage.pagectrl:SetValue("tabProfile", tostring(index));
	--CombatCharInfoSubPage.curpage = index;
	--CombatCharInfoSubPage.pagectrl:Refresh(0.01);
--end

function CombatCharInfoSubPage.ShowXiangxi()
	MyCompany.Aries.Help.CombatHelpPage.TabValue = "4";
	MyCompany.Aries.Help.CombatHelpPage.ShowPage_Frame(2);
end

function CombatCharInfoSubPage.GetCombatLevel()
	return CombatCharInfoSubPage.combatlevel or 0;
end

function CombatCharInfoSubPage.GetHPInfo()
	return CombatCharInfoSubPage.hp .. "/" .. CombatCharInfoSubPage.maxhp;
end

function CombatCharInfoSubPage.GetExpInfo()
	return CombatCharInfoSubPage.exp .. "/" .. CombatCharInfoSubPage.maxexp
end

function CombatCharInfoSubPage.DS_Func(index)
	if(index==nil)then
						--commonlib.echo("!!!!!!!!!!!!!!:DS_Func");
						--commonlib.echo(CombatCharInfoSubPage.Medals);
		return #CombatCharInfoSubPage.Medals;
	else
		return CombatCharInfoSubPage.Medals[index];
	end
end

function CombatCharInfoSubPage.GetSchool()
	local school = CombatCharInfoSubPage.combat.GetSchool();
	if(school=="fire")then
		return "烈火";
	elseif(school=="ice")then
		return "寒冰";
	elseif(school=="storm")then
		return "风暴";	
	elseif(school=="life")then
		return "生命";
	elseif(school=="death")then
		return "死亡";
	end
end

function CombatCharInfoSubPage.GetPowerPipChance()
	return tostring(CombatCharInfoSubPage.combat.GetPowerPipChance().."%");
end

function CombatCharInfoSubPage.GetStats(school,type)
	return tostring(CombatCharInfoSubPage.combat.GetStats(school,type));
end

function CombatCharInfoSubPage.GetMagicStone()
	--local _, _, _, copies = CombatCharInfoSubPage.itemmanager.IfOwnGSItem(22000,24) or 0;
	--return tostring(copies);
    local ItemManager = System.Item.ItemManager;
    local hasGSItem = ItemManager.IfOwnGSItem;
    local _,_,_,magicstone_copies=hasGSItem(22000);
    magicstone_copies = magicstone_copies or 0;
    return string.format("%d",magicstone_copies);
end


function CombatCharInfoSubPage.GetNameEditState()
	if(CombatCharInfoSubPage.editstate)then
		return CombatCharInfoSubPage.editstate;
	else
		return false;
	end
end

function CombatCharInfoSubPage.SetEditState(value)
	CombatCharInfoSubPage.editstate = value;
end

function CombatCharInfoSubPage.GetEnergy()
	if(CombatCharInfoSubPage.bean)then
		return CombatCharInfoSubPage.bean.energy;
	end
end	

function CombatCharInfoSubPage.GetMLevel()
	if(CombatCharInfoSubPage.bean)then
		return CombatCharInfoSubPage.bean.mlel;
	end
end