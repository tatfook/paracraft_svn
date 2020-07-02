 --[[
Title: 
Author(s): zrf
Date: 2011/1/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileCombat.lua");
------------------------------------------------------------
]]
local Player = commonlib.gettable("MyCompany.Aries.Player");
local NewProfileCombat = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfileCombat");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function NewProfileCombat.Init()
	NewProfileCombat.page = document:GetPageCtrl();
	--NewProfileCombat.nid = 191822478;
	--NewProfileCombat.lastnid = 
		
	--NewProfileCombat.GetInfo(NewProfileCombat.nid);
end

function NewProfileCombat.GetStats(school,type)
	if(NewProfileCombat.ready == true)then
		--commonlib.echo("!!!:GetStats");
		--commonlib.echo(Combat.GetStats(school,type,NewProfileCombat.nid));
		local nid = NewProfileCombat.nid;
		if(nid==System.App.profiles.ProfileManager.GetNID())then
			return tostring(Combat.GetStats(school,type));
		else
			return tostring(Combat.GetStats(school,type,nid));
		end
	else 
		return "";
	end
end

function NewProfileCombat.GetInfo(nid)
	NewProfileCombat.ready = true;
	NewProfileCombat.nid = nid;
	
	--ItemManager.GetItemsInOPCBag(nid, 24, "FullProfilePage_OPCMedal_0", function(msg)
		--local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
		--local bhas,_,__,count = hasGSItem0(NewProfileCombat.nid,22000);
		--NewProfileCombat.xunliandian= count or 0;
		--NewProfileCombat.ready = true;
		--if(NewProfileCombat.page)then
			--NewProfileCombat.page:Refresh(0.01);
		--end
	--end, "access plus 1 minutes");
end

function NewProfileCombat.GetPowerPipChance()
	local nid = NewProfileCombat.nid;
	if(nid==System.App.profiles.ProfileManager.GetNID())then
		return Combat.GetPowerPipChance(nil,nil);
	else
		return Combat.GetPowerPipChance(nil,NewProfileCombat.nid);
	end
end

function NewProfileCombat.GetSpellPenetrationChance()
	local nid = NewProfileCombat.nid;
	if(nid==System.App.profiles.ProfileManager.GetNID())then
		return Combat.GetSpellPenetrationChance(nil);
	else
		return Combat.GetSpellPenetrationChance(NewProfileCombat.nid);
	end
end

function NewProfileCombat.GetXunLianDian()
    local ItemManager = System.Item.ItemManager;
    local hasGSItem = ItemManager.IfOwnGSItem;
    local _,_,_,magicstone_copies=hasGSItem(22000);
    magicstone_copies = magicstone_copies or 0;
    return string.format("%d",magicstone_copies);
end

function NewProfileCombat.GetGearScore()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return string.format("%d",Player.GetGearScore());
	else
		local _,_,_,copies =ItemManager.IfOPCOwnGSItem(NewProfileCombat.nid, 965)
		return string.format("%d",copies or 0);
	end
end

function NewProfileCombat.GetOutputHealBoost()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return MyCompany.Aries.Combat.GetOutputHealBoost();
	else
		return MyCompany.Aries.Combat.GetOutputHealBoost(NewProfileCombat.nid);		
	end
end

function NewProfileCombat.GetInputHealBoost()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return MyCompany.Aries.Combat.GetInputHealBoost();
	else
		return MyCompany.Aries.Combat.GetInputHealBoost(NewProfileCombat.nid);		
	end
end

function NewProfileCombat.GetCriticalStrikeChance()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return MyCompany.Aries.Combat.GetCriticalStrikeChance();
	else
		return MyCompany.Aries.Combat.GetCriticalStrikeChance(NewProfileCombat.nid);		
	end
end

function NewProfileCombat.GetResilienceChance()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return MyCompany.Aries.Combat.GetResilienceChance();
	else
		return MyCompany.Aries.Combat.GetResilienceChance(NewProfileCombat.nid);		
	end
end

function NewProfileCombat.ShowXunLian()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return true;
	else
		return false;
	end
end

function NewProfileCombat.GetDamageAbsoluteBaseChance()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return MyCompany.Aries.Combat.GetDamageAbsoluteBaseChance();
	else
		return MyCompany.Aries.Combat.GetDamageAbsoluteBaseChance(NewProfileCombat.nid);		
	end
end

function NewProfileCombat.GetResistAbsoluteBaseChance()
	if(NewProfileCombat.nid == System.App.profiles.ProfileManager.GetNID())then
		return MyCompany.Aries.Combat.GetResistAbsoluteBaseChance();
	else
		return MyCompany.Aries.Combat.GetResistAbsoluteBaseChance(NewProfileCombat.nid);		
	end
end