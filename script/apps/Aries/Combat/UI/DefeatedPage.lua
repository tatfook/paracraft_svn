--[[
Title: code behind for page DefeatedPage.html
Author(s): LiXizhi	
Date: 2012/3/26
Desc:  script/apps/Aries/Combat/UI/DefeatedPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/UI/DefeatedPage.lua")
MyCompany.Aries.Combat.DefeatedPage.Show();
-------------------------------------------------------
]]
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local DefeatedPage = commonlib.gettable("MyCompany.Aries.Combat.DefeatedPage");

function DefeatedPage.OnInit()
	page = document:GetPageCtrl();
end

function DefeatedPage.Show()
	local params = {
		url = if_else(System.options.version=="kids", "script/apps/Aries/Combat/UI/DefeatedPage.html", "script/apps/Aries/Combat/UI/DefeatedPage.teen.html"), 
		name = "DefeatedPage.page", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		-- zorder = 2,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	DefeatedPage.AnalyzeAndShowTips();
end

local auto_tip_series_count = 0;

-- show tips
function DefeatedPage.AnalyzeAndShowTips()
	if(System.options.version == "teen") then
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
		local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
		DefeatedPage.auto_tip_series = DefeatedPage.auto_tip_series or {
			"Death_Below_Level12_1",
			"Death_Below_Level12_2",
			"Death_Below_Level15_1",
			"Death_Below_Level15_2",
			"Death_Below_Level20_1",
			"Death_Below_Level20_2",
			"Death_Below_Level20_3",
			"Death_Below_Level20_4",
			"Death_Below_Level30_1",
			"Death_Below_Level30_2",
			"Death_Below_Level30_3",
			"Death_Below_Level40_1",
			"Death_Below_Level40_2",
			"Death_Below_Level40_3",
			"Death_Below_Level40_4",
			"Death_Below_Level49_1",
			"Death_Below_Level49_2",
			"Death_Below_Level49_3",
			"Death_Below_Level60_1",
		};
		local auto_tip_series = DefeatedPage.auto_tip_series;
		local my_combat_level = Combat.GetMyCombatLevel();
		local range_lower, range_upper = 2, 2;
		if(my_combat_level <= 12) then
			range_lower, range_upper = 1, 2;
		elseif(my_combat_level <= 15) then
			range_lower, range_upper = 3, 4;
		elseif(my_combat_level <= 20) then
			range_lower, range_upper = 5, 8;
		elseif(my_combat_level <= 30) then
			range_lower, range_upper = 9, 11;
		elseif(my_combat_level <= 40) then
			range_lower, range_upper = 12, 15;
		elseif(my_combat_level <= 49) then
			range_lower, range_upper = 16, 18;
		--elseif(my_combat_level < 100) then
			--range_lower, range_upper = 2, 8;
		elseif(my_combat_level >= 50) then
			-- don't show death tip above level 50
			return;
		end

		if(my_combat_level>=9 and my_combat_level<=20) then
			local levels_info = CombatFollowPetPane.CanCurrentPetInfo();
			if(not levels_info) then
				-- TODO: pet doesnot enter combat
				_guihelper.MessageBox("你没有携带宠物! 战斗时携带8级以上的宠物会极大的增加你的战斗力");
			elseif(levels_info.cur_level and levels_info.cur_level < 6) then
				-- TODO: pet need level up. 
				_guihelper.MessageBox("你的宠物等级太低了! 战斗时携带8级以上的宠物会极大的增加你的战斗力!");

				NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
				local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
				goal_manager.SetCurrentGoal("feedpet");
			end
		end

		local candidate_count = range_upper - range_lower + 1;

		local remaining = math.mod(auto_tip_series_count, candidate_count);
		
		local tip_index = range_lower + remaining;
		local tip_key = auto_tip_series[tip_index] or 1;
		if(tip_key) then
			NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
			local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
			AutoTips.ClosePage(); -- tricky: clear previous tips
			AutoTips.ShowPage(tip_key, nil, true);
		end
		
		auto_tip_series_count = auto_tip_series_count + 1;
	else
		-- TODO: for kids version:
	end
end