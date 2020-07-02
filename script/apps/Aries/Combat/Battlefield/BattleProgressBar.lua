--[[
Title: code behind for page for BattleProgressBar.html
Author(s): LiXizhi
Date: 2012/12/20
Desc: script/apps/Aries/Combat/Battlefield/BattleProgressBar.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattleProgressBar.lua");
local BattleProgressBar = commonlib.gettable("MyCompany.Aries.Battle.BattleProgressBar");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattleMiniMap.lua");
local BattleProgressBar = commonlib.gettable("MyCompany.Aries.Battle.BattleProgressBar");
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
local BattleMiniMap = commonlib.gettable("MyCompany.Aries.Battle.BattleMiniMap");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

local page
function BattleProgressBar.OnInit()
	page = document:GetPageCtrl();
	BattleProgressBar.page = page;
end

local function GetTowerFlagTextByOwner(rp, my_side)
	if(rp.owner == nil) then
		return format("%s: 争夺中%d%%", rp.text or "资源点", ((rp.cursor_percentage or 0)*if_else(my_side == 0, -1, 1)+100)*0.5), "148 148 148";
	elseif(rp.owner == my_side) then
		return format("%s: 我方占领中", rp.text or "资源点"), "0 255 0";
	else
		return format("%s: 对方占领中", rp.text or "资源点"), "255 0 0";
	end
end		

function BattleProgressBar.OnRefreshData(bf, raw_bf, closest_rp)
	if(not page) then
		return;
	end
	
	local nid = tostring(System.User.nid);
	local player = bf:get_player(nid);
	local my_side = bf:get_player_side(nid)

	echo("=========BattleProgressBar.OnRefreshData=========");
	echo({my_side = my_side, bf = raw_bf})
	
	if(bf.is_started) then
		--local towerProgress = page:FindControl("towerProgress");
		--if(towerProgress) then
			--if(closest_rp) then
				--towerProgress:SetValue( (closest_rp.cursor_percentage or 0)*if_else(my_side == 0, 1, -1));
			--end
		--end
		local i
		for i = 1, 5 do
			local rp = bf:get_resource_point(i);
			if(rp and rp.arena_id and rp.text) then
				local text, color = GetTowerFlagTextByOwner(rp, my_side);
				if(rp.display_text_ ~= text) then
					rp.display_text_ = text;
					local towerProgress = page:FindControl("rp"..i);
					if(towerProgress) then
						towerProgress.text = text;
						_guihelper.SetFontColor(towerProgress, color);
					end
					BattleProgressBar.UpdateResourcePoint(i, rp, my_side)
				end
			end
		end

		local use_attack = false;
		local our_score = page:FindControl("our_score");
		if(our_score) then
			our_score.Maximum = bf.winning_score or 10000;
			local score;
			if(use_attack) then
				score = our_score.Maximum - (if_else(my_side == 0, bf.score_side1, bf.score_side0) or 0);
			else
				score = if_else(my_side == 0, bf.score_side0, bf.score_side1) or 0;
			end
			our_score:SetValue(score);
			page:SetUIValue("our_score_text", format("%d/%d", score, our_score.Maximum))
			page:SetUIValue("our_tower_count", format("%d", if_else(my_side == 0, bf.side0_resouce_point_count, bf.side1_resouce_point_count)))
		end

		local other_score = page:FindControl("other_score");
		if(other_score) then
			other_score.Maximum = bf.winning_score or 10000;
			local score
			if(use_attack) then
				score = other_score.Maximum - (if_else(my_side == 0, bf.score_side0, bf.score_side1) or 0);
			else
				score = if_else(my_side == 0, bf.score_side1, bf.score_side0) or 0;
			end
			other_score:SetValue(score);
			page:SetUIValue("other_score_text", format("%d/%d", score, other_score.Maximum))
			page:SetUIValue("other_tower_count", format("%d", if_else(my_side == 0, bf.side1_resouce_point_count, bf.side0_resouce_point_count)))
		end

		if(bf.is_finished) then
			local our_score = if_else(my_side == 0, bf.score_side0, bf.score_side1)
			local other_score = if_else(my_side == 0, bf.score_side1, bf.score_side0)
			if(our_score > other_score) then
				page:SetUIValue("result", "我方胜！请离开战场")
			else
				page:SetUIValue("result", "对方胜！请离开战场")
			end
		else
			page:SetUIValue("result", "比赛进行中")
		end
	elseif(my_side) then
		page:SetUIValue("result", "请等待比赛开始")
	else
		page:SetUIValue("result", "正在排队中...")
	end
end

-- show help page
function BattleProgressBar.ShowHelpPage()
	if(System.options.version == "kids") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			-- Add uid to url
			url = "script/apps/Aries/Combat/Battlefield/BattlefieldHelpPage.html", 
			name = "Aries.BattlefieldHelpPage",
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 200,
			allowDrag = false,
			enable_esc_key = true,
			click_through = true,
			directPosition = true,
				align = "_ct",
				x = -200,
				y = -150,
				width = 400,
				height = 300,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			-- Add uid to url
			url = "script/apps/Aries/Combat/Battlefield/BattlefieldHelpPage.teen.html", 
			name = "Aries.BattlefieldHelpPage",
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 200,
			allowDrag = false,
			enable_esc_key = true,
			click_through = true,
			directPosition = true,
				align = "_ct",
				x = -200,
				y = -150,
				width = 400,
				height = 300,
		});
	end
end

function BattleProgressBar.ShowStatPage()
	if(System.options.version == "kids") then
		-- the combat UI for statistics information only show players which have same combat school
		-- 战斗统计面板是否只显示相同战斗系别的玩家
		BattleProgressBar.only_show_same_combat_shcool = BattleProgressBar.only_show_same_combat_shcool or false;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			-- Add uid to url
			url = "script/apps/Aries/Combat/Battlefield/BattlefieldStatPanel.html", 
			name = "Aries.BattlefieldStatPanel",
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 200,
			allowDrag = false,
			enable_esc_key = true,
			click_through = true,
			directPosition = true,
				align = "_ct",
				x = -240,
				y = -180,
				width = 480,
				height = 360,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			-- Add uid to url
			url = "script/apps/Aries/Combat/Battlefield/BattlefieldStatPanel.teen.html", 
			name = "Aries.BattlefieldStatPanel",
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 200,
			allowDrag = false,
			enable_esc_key = true,
			click_through = true,
			directPosition = true,
				align = "_ct",
				x = -220,
				y = -180,
				width = 440,
				height = 360,
		});
	end
end

function BattleProgressBar.ToggleMiniMapPage()
	BattleProgressBar.ShowMiniMapPage(nil, true);
end

-- update resource point. 
local occupied_by_us_bg = "Texture/Aries/Andy/Green_32bits.png";
local occupied_by_others_bg = "Texture/Aries/Andy/Red_32bits.png";

local rp_points = {
	[1] = {x=0,y=0, width=20;height=20,zorder=1, background=nil, },
	[2] = {x=0,y=0, width=20;height=20,zorder=1, background=nil, },
	[3] = {x=0,y=0, width=20;height=20,zorder=1, background=nil, },
	[4] = {x=0,y=0, width=20;height=20,zorder=1, background=nil, },
	[5] = {x=0,y=0, width=20;height=20,zorder=1, background=nil, },
}


-- update resource point location on the map.
function BattleProgressBar.UpdateResourcePoint(index, rp, my_side)
	local pt = rp_points[index];
	local arena_data_map = MsgHandler.Get_arena_meta_data();

	if(my_side and page and pt and arena_data_map) then
		if(rp.owner == nil) then
			page:CallMethod("battlefield_mini_map", "ShowPoint", "rp"..index, nil)
		else
			local arena;
			if(rp.arena_id) then
				arena = arena_data_map[rp.arena_id];
			end
			if(arena and arena.p_x) then
				pt.x = arena.p_x;
				pt.y = arena.p_z;
				if(rp.owner == my_side) then
					pt.background = occupied_by_us_bg;
					pt.tooltip = "我方占领中";
				else
					pt.background = occupied_by_others_bg;
					pt.tooltip = "对方占领中";
				end
				if(System.options.version == "kids") then
					-- kids version
					BattleMiniMap.ShowPoint("rp"..index, pt);
				else
					-- teen version
					MapArea.ShowPoint("rp"..index, pt)
				end
			end
		end
	end
end

function BattleProgressBar.ShowMiniMapPage(bShow, bToggleShowHide)
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- Add uid to url
		url = "script/apps/Aries/Combat/Battlefield/BattleMiniMap.html", 
		name = "Aries.BattleMiniMap",
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, 
		style = CommonCtrl.WindowFrame.ContainerStyle,
		--zorder = 200,
		allowDrag = true,
		bShow = bShow,
		bToggleShowHide = bToggleShowHide,
		-- enable_esc_key = true,
		-- click_through = true,
		directPosition = true,
			align = "_rt",
			x = -250,
			y = 310,
			width = 160,
			height = 160,
	});
end