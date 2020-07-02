--[[
Title: AngelMedalDisplayBox
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30084_AngelMedalDisplayBox.lua
------------------------------------------------------------
]]

-- create class
local libName = "AngelMedalDisplayBox";
local AngelMedalDisplayBox = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AngelMedalDisplayBox", AngelMedalDisplayBox);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- AngelMedalDisplayBox.main
function AngelMedalDisplayBox.main()
	AngelMedalDisplayBox.RefreshStatus();
end

-- 50181_DoctorInauguralQuest_Accept
-- 50182_DoctorInauguralQuest_Complete

local monitored_aries_type = {
	["PetFeedOther"] = true,
	["PetBathOther"] = true,
	["PetPlayToyOther"] = true,
	["PetMedicineOther"] = true,
}
-- update the NPC quest status in quest area
function AngelMedalDisplayBox.RefreshStatus()
	-- this Doctor_CareDragonMonitor hook stays alive during the whole community process, which can not be unhooked
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(monitored_aries_type[msg.aries_type or ""]) then
				-- increase the heal pet counter if user is doctor
				if(hasGSItem(50182)) then
					ItemManager.PurchaseItem(50183, 1, function(msg) end, function(msg)
						if(msg) then
							log("+++++++Purchase 50183_DoctorHealOther_Counter return: +++++++\n")
							commonlib.echo(msg);
						end
					end);
				end
			end
		end, 
		hookName = "Doctor_CareDragonMonitor", appName = "Aries", wndName = "main"});
end

function AngelMedalDisplayBox.PreDialog()
	---- 20010_AmateurClassDoctorMedal
	--if(not hasGSItem(20010) and not hasGSItem(20011) and not hasGSItem(20012) and not hasGSItem(20013)) then
		--_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:18px;">恭喜你成为医生，特颁发给你一枚木医徽章，多多的行使医生的职责，你的徽章可以升级的。</div>]]);
		--
		--local name = "";
		--local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(20010)
		--if(gsItem) then
			--name = gsItem.template.name;
		--end
		---- exid 103: Get_Doctor_AmateurClassDoctorMedal
		--ItemManager.ExtendedCost(103, nil, nil, function(msg)end, function(msg)
			--log("+++++++ExtendedCost 103: Get_Doctor_AmateurClassDoctorMedal return: +++++++\n")
			--commonlib.echo(msg);
			--if(msg.issuccess == true) then
				--_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:25px">恭喜你获得%s，你可以在资料面板中看到它哦！</div>]], name));
			--end
		--end);
	--else
		local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
		style.shadow_bg = "texture/bg_black_20opacity.png";
		style.fillShadowLeft = -10000;
		style.fillShadowTop = -10000;
		style.fillShadowWidth = -10000;
		style.fillShadowHeight = -10000;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/Doctor/30084_AngelMedalDisplayBox_dialog.html", 
			name = "Doctor_AngelMedalDisplayBox", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = style,
			zorder = 2,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -655/2,
				y = -552/2,
				width = 655,
				height = 512,
			DestroyOnClose = true,
		});
	--end
	return false;
end