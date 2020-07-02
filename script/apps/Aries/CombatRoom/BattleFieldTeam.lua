--[[
Title: World Team Quest
Author(s): LiXizhi
Date: 2013/6/7
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/BattleFieldTeam.lua");
local BattleFieldTeam = commonlib.gettable("MyCompany.Aries.CombatRoom.BattleFieldTeam");
BattleFieldTeam.ShowPage();

------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

local BattleFieldTeam = commonlib.gettable("MyCompany.Aries.CombatRoom.BattleFieldTeam");


local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local ItemManager = commonlib.gettable("System.Item.ItemManager");

local hasGSItem = ItemManager.IfOwnGSItem;

local page;

function BattleFieldTeam.OnInit()
	page = document:GetPageCtrl();
end

function BattleFieldTeam.ShowPage()
	local params = {
		url = "script/apps/Aries/CombatRoom/BattleFieldTeam.html", 
		name = "BattleFieldTeam.ShowPage", 
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
			y = -480/2,
			width = 720,
			height = 480,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	--BattleFieldTeam.ReSelected();
end

function BattleFieldTeam.CloseWindow()
	page:CloseWindow();
end

function BattleFieldTeam.CanJoin()
	local time = Scene.GetElapsedSecondsSince0000()
	
	local day_of_week;
	local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day = string.match(serverDate, "^(%d+)%-(%d+)%-(%d+)$");
	if(year and month and day) then
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);
		
		day_of_week = commonlib.timehelp.get_day_of_week(year, month, day)
	end



	if(time) then
		if(day_of_week == 5 or day_of_week == 6 or day_of_week == 7) then
			if(time < 10 * 60 * 60 or time > (22 * 60 * 60)) then
			--if(time < 14 * 60 * 60 or time > (18 * 60 * 60)) then
				_guihelper.MessageBox("英雄谷只在周五和周末的10:00~22:00开启。")
				return;
			else
				local beHas,_,_,copies = hasGSItem(50417);
				if(beHas and copies >= 10) then
					_guihelper.MessageBox("英雄谷每天只能玩10次，明天再来玩吧")
					return;	
				else
					return true;	
				end
				
			end
			-- open every holiday
		else
			_guihelper.MessageBox("英雄谷只在周五和周末的10:00~22:00开启。")
		--else
			--if(time < 20 * 60 * 60 or time > (22 * 60 * 60)) then
				--_guihelper.MessageBox("英雄谷周一到周五只在20:00~22:00开启。")
				--return;
			--else
				--local beHas,_,_,copies = hasGSItem(50417);
				--if(beHas and copies >= 10) then
					--_guihelper.MessageBox("英雄谷每天只能玩10次，明天再来玩吧")
					--return;	
				--else
					--return true;	
				--end
			--end
		end
	end
	
end

function BattleFieldTeam.DoJoin()
	

	local level = Combat.GetMyCombatLevel();
	if(level < 40) then
		_guihelper.MessageBox("只有40级上的玩家才能加入英雄谷哦，快去升级吧");
		return;
	end
	
	if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
		_guihelper.MessageBox("英雄谷不能组队进入，请先离开队伍");
		return;
	end

	if(not (hasGSItem(12034) or hasGSItem(12035))) then
		_guihelper.MessageBox("你没有英雄谷门票，不能进入，马上用仙豆购买门票？",function(result)
			if(result == _guihelper.DialogResult.Yes) then
				BattleFieldTeam.BuyLuckEgg(12035,1988)
			end
		end,_guihelper.MessageBoxButtons.YesNo);
		return;
	end

	local worldname = "BattleField_ChampionsValley_Master";

	if(page) then
		BattleFieldTeam.CloseWindow();
	end

	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
	local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
	GathererBarPage.Start({ duration = 1000, title = "准备进入英雄谷", disable_shortkey = true, align="_ct", x=-100, y=-100,},nil,function()
		System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
			name = worldname,
			combat_is_started = "true",
			on_finish = function()
						
			end,
		});
	end);

end

function BattleFieldTeam.DoCreate()

	local level = Combat.GetMyCombatLevel();
	if(level < 48) then
		_guihelper.MessageBox("只有48级上的玩家才能加入英雄谷哦，快去升级吧");
		return;
	end
	

	if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
		_guihelper.MessageBox("英雄谷不能组队进入，请先离开队伍");
		return;
	end

	if(not (hasGSItem(12034) or hasGSItem(12035))) then
		_guihelper.MessageBox("你没有英雄谷门票，不能进入，马上用仙豆购买门票？",function(result)
			if(result == _guihelper.DialogResult.Yes) then
				BattleFieldTeam.BuyLuckEgg(12035,1988)
			end
		end,_guihelper.MessageBoxButtons.YesNo);
		return;
	end

	local worldname = "BattleField_ChampionsValley_Master";
	
	if(page) then
		BattleFieldTeam.CloseWindow();
	end
	

	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
	local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
	GathererBarPage.Start({ duration = 1000, title = "准备进入英雄谷", disable_shortkey = true, align="_ct", x=-100, y=-100,},nil,function()
		System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
			name = worldname,
			on_finish = function()
						
			end,
		});
	end);
	
end

function BattleFieldTeam.ShowHelperPage()
	local params = {
		url = "script/apps/Aries/CombatRoom/BattleFieldTeamHelperPage.html", 
		name = "BattleFieldTeam.ShowHelperPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		-- zorder = 0,
		directPosition = true,
			align = "_ct",
			x = -512/2,
			y = -512/2,
			width = 512,
			height = 512,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	--BattleFieldTeam.ReSelected();
end

function BattleFieldTeam.BuyLuckEgg(gsid,exid)

local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
if(command) then
	command:Call({gsid = gsid, exid = exid, npc_shop = true, callback = function(params, msg)
		--if(msg and msg.issuccess) then
			--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
		--end
	end });
end

end