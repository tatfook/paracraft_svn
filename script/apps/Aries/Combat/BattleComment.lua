--[[
Title: combat system battle comment for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/BattleComment.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");

-- create class
local BattleComment = commonlib.gettable("MyCompany.Aries.Combat.BattleComment");
local UIAnimManager = commonlib.gettable("UIAnimManager");

-- this is a debug purpose only comment
function BattleComment.AppendStackingComment(comment_string)
	local _label = ParaUI.GetUIObject("Aries_StackingBattleComment");
	if(_label:IsValid() == false) then
		_label = ParaUI.CreateUIObject("button", "Aries_StackingBattleComment", "_ctt", 0, 120, 400, 32);
		_label.background = "";
		_label.shadow = true;
		_label.enabled = false;
		_label.scalingx = 1.3;
		_label.scalingy = 1.3;
		_label.font = "System;18;bold";
		_label.spacing = 4;
		_label:GetFont("text").format = 1+256; -- center and no clip
		_label:AttachToRoot();
	end
	
	local color = "218 45 45";
	_label.text = comment_string;
	_guihelper.SetFontColor(_label, color.." 255");
	
	-- id: 48309 for in scene battle comment notification
	UIAnimManager.StopCustomAnimation(48309);
	UIAnimManager.PlayCustomAnimation(4000, function(elapsedTime)
		local _label = ParaUI.GetUIObject("Aries_StackingBattleComment");
		if(_label:IsValid() == true) then
			if(elapsedTime < 2500) then
				_label.visible = true;
				--_label.color = "255 255 255 255";
				_guihelper.SetFontColor(_label, color.." 255")
			elseif(elapsedTime >= 2500 and elapsedTime <= 4000) then
				_label.visible = true;
				local alpha = math.floor((4000 - elapsedTime) / 1500 * 255);
				--_label.color = "255 255 255 "..alpha;
				_guihelper.SetFontColor(_label, color.." "..alpha);
			end
			if(elapsedTime == 4000) then
				_label.visible = false;
			end
		end
	end, 48309);
end

-- this is a debug purpose only comment
function BattleComment.UpdateCountDownTimer(milliseconds, count_to_zero_callback)
	local _label = ParaUI.GetUIObject("Aries_UpdateCountDownTimer");
	if(_label:IsValid() == false) then
		if(System.options.version == "teen") then
			_label = ParaUI.CreateUIObject("container", "Aries_UpdateCountDownTimer", "_ct", -40, -200, 40, 32);
		else
			_label = ParaUI.CreateUIObject("container", "Aries_UpdateCountDownTimer", "_ct", -20, -160, 40, 32);
		end
		_label.background = "";
		_label.enabled = false;
		_label.zorder = -1;
		_label:AttachToRoot();
		BattleComment.count_down_page = BattleComment.count_down_page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Combat/UI/TurnCountDownPage.html"});
		BattleComment.count_down_page:Create("Aries_UpdateCountDownTimer", _label, "_fi", 0, 0, 0, 0);
	end
	
	-- id: 89034 for in scene battle comment notification
	UIAnimManager.StopCustomAnimation(89034);
	if(not milliseconds or milliseconds == 0) then
		local _label = ParaUI.GetUIObject("Aries_UpdateCountDownTimer");
		if(_label:IsValid() == true) then
			_label.visible = false;
		end
		return;
	end
	UIAnimManager.PlayCustomAnimation(milliseconds, function(elapsedTime)
		local _label = ParaUI.GetUIObject("Aries_UpdateCountDownTimer");
		if(_label:IsValid() == true) then
			if(elapsedTime ~= milliseconds) then
				local seconds = math.ceil((milliseconds - elapsedTime) / 1000);
				-- here we will secrete, remove 2 seconds, just to ensure that network latency is already. 
				seconds = math.max(seconds - 2, 0);
				local txtSprite = BattleComment.count_down_page:FindControl("text");
				if(txtSprite) then
					if(seconds <= 10) then
						txtSprite.color = "#ff0000";
					else
						txtSprite.color = "#ffff00";
					end
					txtSprite:SetText(tostring(seconds));
				end
				_label.visible = true;
			elseif(elapsedTime == milliseconds) then
				_label.visible = false;
				if(count_to_zero_callback) then
					count_to_zero_callback();
				end
			end
		end
	end, 89034);
end

-- cache the xml root in memory to improve frequent spell play IO latency
local BattleComment_File_XMLRoots = {};

-- cancel comment play if caster is far away from the player
local cancel_commentplay_distance_sq = 2500;

function BattleComment.PlayCommentOnCaster(obj, comment_config_file, bAbove3D)
	if(not obj) then
		-- nil target object
		return;
	end
	if(obj:IsValid() ~= true) then
		-- invalid obj
		return;
	end
	local dist = obj:DistanceToPlayerSq();
	if(dist > cancel_commentplay_distance_sq) then
		-- if user in too far away from the combat the battle comment is cancelled
		return;
	end
	-- spell cast config 
	local filename = comment_config_file;
	local xmlRoot = BattleComment_File_XMLRoots[filename];
	-- for taurus force read the spell file
	if(not xmlRoot or System.SystemInfo.GetField("name") == "Taurus") then
		xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(not xmlRoot) then
			commonlib.log("error: failed loading battle comment config file: %s\n", filename);
			return;
		end
		BattleComment_File_XMLRoots[filename] = xmlRoot;
	end

	-- create damage part of the spell
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/battlecomment/caster_title") do
		if(node.attr and node.attr.starttime and node.attr.title) then
			local starttime = tonumber(node.attr.starttime);
			local title = node.attr.title;
			local color = node.attr.color or "da2d2d";
			
			-- create effect function 
			local func_play_effect = function()
				local mcml_str = string.format([[<div style="margin-left:0px;width:300px;height:32;color:#%s;text-align:center;base-font-size:18;font-weight:bold;text-shadow:true" >%s</div>]], color, title)
				local sCtrlName = headon_speech.Speek(obj.name, mcml_str, 1, bAbove3D, true, nil, -3);
				if(sCtrlName) then
					UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
						local parent = ParaUI.GetUIObject(sCtrlName);
						if(parent:IsValid()) then
							parent.translationy = 44 - elapsedTime * 10 / 1000;
							parent.scalingx = 1.8;
							parent.scalingy = 1.8;
							parent:ApplyAnim();
						end
					end);
				end
			end
			-- play the effect immediately or after start time
			if(starttime >= 50) then
				UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
					if(elapsedTime == starttime) then
						func_play_effect();
					end
				end);
			else
				func_play_effect();
			end
		end
	end
end

-- this is a debug purpose only comment
-- NOTE: if the obj is too far away from the player, comment play is cancelled, update_hp_callback function is also cancelled
function BattleComment.PlayCommentOnTarget(obj, comment_config_file, damage_or_heal_point, bAbove3D, update_hp_callback, isCritical)
	
	isCritical = true;

	if(not obj) then
		-- nil target object
		return;
	end
	if(obj:IsValid() ~= true) then
		-- invalid obj
		return;
	end
	local dist = obj:DistanceToPlayerSq();
	if(dist > cancel_commentplay_distance_sq) then
		-- if user in too far away from the combat the battle comment is cancelled
		return;
	end
	-- spell cast config 
	local filename = comment_config_file;
	local xmlRoot = BattleComment_File_XMLRoots[filename];
	-- for taurus force read the spell file
	if(not xmlRoot or System.SystemInfo.GetField("name") == "Taurus") then
		xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(not xmlRoot) then
			commonlib.log("error: failed loading battle comment config file: %s\n", filename);
			return;
		end
		BattleComment_File_XMLRoots[filename] = xmlRoot;
	end

	-- create damage part of the spell
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/battlecomment/damage") do
		if(node.attr and node.attr.starttime) then
			local starttime = tonumber(node.attr.starttime);
			
			-- create effect function 
			local func_play_effect = function()
				local mcml_str = string.format([[<div style="margin-left:0px;width:300px;height:32;color:#da2d2d;text-align:center;base-font-size:18;font-weight:bold;text-shadow:true" >-%d</div>]], damage_or_heal_point)
				local sCtrlName = headon_speech.Speek(obj.name, mcml_str, 2, bAbove3D, true, nil, -3);
				if(sCtrlName) then
					UIAnimManager.PlayCustomAnimation(2500, function(elapsedTime)
						local parent = ParaUI.GetUIObject(sCtrlName);
						if(parent:IsValid()) then
							parent.translationy = 44 - elapsedTime * 10 / 1000;
							if(isCritical and elapsedTime < 200) then
								parent.scalingx = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
								parent.scalingy = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
							else
								parent.scalingx = 1.8;
								parent.scalingy = 1.8;
							end
							parent:ApplyAnim();
						end
					end);
				end
				if(type(update_hp_callback) == "function") then
					update_hp_callback(obj.name, -damage_or_heal_point);
				end
			end
			-- play the effect immediately or after start time
			if(starttime >= 50) then
				UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
					if(elapsedTime == starttime) then
						func_play_effect();
					end
				end);
			else
				func_play_effect();
			end
		end
	end
	-- create heal part of the spell
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/battlecomment/heal") do
		if(node.attr and node.attr.starttime) then
			local starttime = tonumber(node.attr.starttime);
			
			-- create effect function 
			local func_play_effect = function()
				local mcml_str = string.format([[<div style="margin-left:0px;width:300px;height:32;color:#63d13e;text-align:center;base-font-size:18;font-weight:bold;text-shadow:true" >+%d</div>]], damage_or_heal_point)
				local sCtrlName = headon_speech.Speek(obj.name, mcml_str, 2, bAbove3D, true, nil, -3);
				if(sCtrlName) then
					UIAnimManager.PlayCustomAnimation(2500, function(elapsedTime)
						local parent = ParaUI.GetUIObject(sCtrlName);
						if(parent:IsValid()) then
							parent.translationy = 44 - elapsedTime * 10 / 1000;
							if(isCritical and elapsedTime < 200) then
								parent.scalingx = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
								parent.scalingy = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
							else
								parent.scalingx = 1.8;
								parent.scalingy = 1.8;
							end
							parent:ApplyAnim();
						end
					end);
				end
				if(type(update_hp_callback) == "function") then
					update_hp_callback(obj.name, damage_or_heal_point);
				end
			end
			-- play the effect immediately or after start time
			if(starttime >= 50) then
				UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
					if(elapsedTime == starttime) then
						func_play_effect();
					end
				end);
			else
				func_play_effect();
			end
		end
	end
end
