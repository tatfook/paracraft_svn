--[[
Title: BigDipper
Author(s): WangTian
Company: ParaEnging Co. & Taomee Inc.
Date: 2010/2/1

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Carnival/30051_BigDipper.lua
------------------------------------------------------------
]]

-- create class
local libName = "BigDipper";
local BigDipper = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BigDipper", BigDipper);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local nextround_countdown = nil;

local haveTicket = false;

local slot_id_mount_id_offset = 19;

local slots = {};
local i;
for i = 1, 20 do
	slots[i] = 0;
end

local position_after_unmount = {x = 20421.369140625, y = 0.58130180835724, z = 19911.236328125};

-- BigDipper.main()
function BigDipper.main()
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldClosing") then
				-- first unhook the world closing
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_BigDipper", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				-- reset the next round countdown
				nextround_countdown = nil;
				-- reset slots
				slots = {};
				local i;
				for i = 1, 20 do
					slots[i] = 0;
				end
				-- drop ticket
				haveTicket = false;
				BigDipper.DropTicket();
			end
		end, 
		hookName = "WorldClosing_BigDipper", appName = "Aries", wndName = "main"});
	
	-- load countdown texture assets
	--NPL.load("(gl)script/ide/AssetPreloader.lua");
	--local loader = commonlib.AssetPreloader:new({ callbackFunc = function(nItemsLeft, loader)end });
	--loader:AddAssets(ParaAsset.LoadTexture("", "Texture/Aries/Desktop/CountDownHelper/countdown_1.png", 1));
	--loader:AddAssets(ParaAsset.LoadTexture("", "Texture/Aries/Desktop/CountDownHelper/countdown_2.png", 1));
	--loader:AddAssets(ParaAsset.LoadTexture("", "Texture/Aries/Desktop/CountDownHelper/countdown_3.png", 1));
	--loader:AddAssets(ParaAsset.LoadTexture("", "Texture/Aries/Desktop/CountDownHelper/countdown_4.png", 1));
	--loader:AddAssets(ParaAsset.LoadTexture("", "Texture/Aries/Desktop/CountDownHelper/countdown_5.png", 1));
	--loader:AddAssets(ParaAsset.LoadParaX("", "character/Animation/v3/RollerCoaster.x"));
	--loader:Start();
	
	--UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
		--if(elapsedTime == 500) then
			--local i = 1;
			--for i = 20, 39 do
				--local position = {ParaScene.GetPlayer():GetPosition()};
				--local facing = 0;
				--local scaling = 0.1;
				--local params = {};
				--params.copies = nil;
				--params.position = position;
				--params.facing = facing;
				--params.scaling = scaling;
				--params.assetfile_char = "character/common/dummy/cube_size/cube_size.x";
				--params.name = tostring(i);
				--local char = Quest.NPC.CreateNPCCharacter(i, params);
				--if(char and char:IsValid() == true) then
					--local npcModel = NPC.GetNpcModelFromIDAndInstance(30051);
					--if(npcModel ) then
						--char:ToCharacter():MountOn(npcModel, i);
					--end
				--end
			--end
		--end
	--end);
end

function BigDipper.main_ticket()
end

function BigDipper.On_Timer()
	local effect_name = "BigDipper_RangeMarker";
	if(haveTicket == true) then
		local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
		if(effectGraph and effectGraph:IsValid() == true) then
			local obj = effectGraph:GetObject(effect_name);
			if(obj and obj:IsValid() == true) then
			else
				local asset = ParaAsset.LoadStaticMesh("", "model/common/marker_point/marker_point.x");
				local obj = ParaScene.CreateMeshPhysicsObject(effect_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
				--local asset = ParaAsset.LoadParaX("", "character/particles/ring_head.x");
				--local obj = ParaScene.CreateCharacter(effect_name, asset , "", true, 1.0, 0, 1.0);
				obj:GetAttributeObject():SetField("progress", 1);
				if(obj and obj:IsValid() == true) then
					obj:SetPosition(20431.369140625, 0.58130151033401, 19910.501953125);
					obj:SetScale(30);
					effectGraph:AddChild(obj);
				end
			end
		end
	elseif(haveTicket == false) then
		local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
		if(effectGraph and effectGraph:IsValid() == true) then
			local obj = effectGraph:GetObject(effect_name);
			if(obj and obj:IsValid() == true) then
				effectGraph:DestroyObject(effect_name);
			end
		end
		return;
	end
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	local dist_sq = (x - 20431) * (x - 20431) + (z - 19910) * (z - 19910);
	if(dist_sq > 600) then
		haveTicket = false;
		BigDipper.DropTicket();
	end
end

-- BigDipper.RefreshStatus()
function BigDipper.RefreshStatus()
end

-- BigDipper.PreDialog()
function BigDipper.PreDialog()
	BigDipper.TryGetTicket();
	return false;
end

function BigDipper.StartOrStopBigDipper(command)
	if(command == "start") then
		-- start the big dipper
		local npcModel = NPC.GetNpcModelFromIDAndInstance(30051);
		if(npcModel) then
			local att = npcModel:GetAttributeObject();
			att:SetField("AnimID", 4);
		end
	elseif(command == "stop") then
		-- stop the big dipper
		local npcModel = NPC.GetNpcModelFromIDAndInstance(30051);
		if(npcModel) then
			local att = npcModel:GetAttributeObject();
			att:SetField("AnimID", 0);
		end
	end
end

function BigDipper.StartUp()
	-- start the big dipper
	BigDipper.StartOrStopBigDipper("start");
	-- unmount all slots
	BigDipper.UnmountAllSlots();
end

function BigDipper.UnmountAllSlots()
	-- unmount all
	local slot_id;
	for slot_id = 1, 20 do
		if(slots[slot_id] ~= 0) then
			MyCompany.Aries.BaseChar.UnMount({
				nid = slots[slot_id],
				position = position_after_unmount,
			});
			MyCompany.Aries.Pet.LeaveIndoorMode(slots[slot_id]);
		end
		slots[slot_id] = 0;
	end
end

function BigDipper.MountUserOnSlot(nid, slot_id)
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		BigDipper.PlayCountDownEffect(3);
		-- enter jump freeze mode
		MyCompany.Aries.Player.EnterFreezeJumpMode();
		-- enter freeze reverse mode, (left shift)
		MyCompany.Aries.EnterFreezeReverseMode();
		-- enter idle mode
		MyCompany.Aries.Desktop.Dock.EnterIdleMode();
	end
	
	if(slots[slot_id] ~= 0 and slots[slot_id] ~= nid) then
		MyCompany.Aries.BaseChar.UnMount({
			nid = slots[slot_id], 
			position = position_after_unmount,
		});
		MyCompany.Aries.Pet.LeaveIndoorMode(slots[slot_id]);
	elseif(slots[slot_id] == nid) then
		return;
	end
	
	slots[slot_id] = nid;
	
	local seated_animfile = "character/Animation/v3/RollerCoaster.x";
	
	local npcModel = NPC.GetNpcModelFromIDAndInstance(30051);
	if(npcModel) then
		local att = npcModel:GetAttributeObject();
		MyCompany.Aries.Pet.EnterIndoorMode(nid);
		MyCompany.Aries.BaseChar.MountOn({nid = nid, model = npcModel, slot_index = (slot_id_mount_id_offset + slot_id)});
		UIAnimManager.PlayCustomAnimation(100, function(elapsedTime)
			if(elapsedTime == 100) then
				local user = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
				if(user and user:IsValid() == true) then
					System.Animation.PlayAnimationFile(seated_animfile, user);
				end
			end
		end);
	end
end

function BigDipper.OnRecvPollResult(nids, winner)
	haveTicket = false;
	local nids_str = commonlib.serialize(nids);
	--_guihelper.MessageBox("OnRecvPollResult_"..nids_str.."_winner:"..winner)
	-- continue with winning effect
	local bExist = false;
	local i;
	for i = 1, #nids do
		if(nids[i] == System.App.profiles.ProfileManager.GetNID()) then
			bExist = true;
			break;
		end
	end
	if(bExist == true) then
		BigDipper.PlayCountDownEffect(5);
		MyCompany.Aries.Scene.ShowRegionLabel("勇气大礼包现在发放，看看谁最幸运。", "240 226 43");
	end
	BigDipper.PlayWinningEffect(nids, winner);
	UIAnimManager.PlayCustomAnimation(6000, function(elapsedTime)
		if(elapsedTime == 6000) then
			-- unmount all slots
			BigDipper.UnmountAllSlots();
			if(bExist) then
				-- leave jump freeze mode
				MyCompany.Aries.Player.LeaveFreezeJumpMode();
				-- leave freeze reverse mode, (left shift)
				MyCompany.Aries.LeaveFreezeReverseMode();
				-- leave idle mode
				MyCompany.Aries.Desktop.Dock.LeaveIdleMode();
			end
		end
	end);
	-- stop the big dipper
	BigDipper.StartOrStopBigDipper("stop");
end

function BigDipper.OnRecvEmptyPollResult()
	haveTicket = false;
	-- stop the big dipper
	BigDipper.StartOrStopBigDipper("stop");
	-- OTHERWISE during sky wheel the user will be unfreezed
	---- leave jump freeze mode
	--MyCompany.Aries.Player.LeaveFreezeJumpMode();
	---- leave freeze reverse mode, (left shift)
	--MyCompany.Aries.LeaveFreezeReverseMode();
	---- leave idle mode
	--MyCompany.Aries.Desktop.Dock.LeaveIdleMode();
	-- unmount all slots
	BigDipper.UnmountAllSlots();
end

-- countdown in millsecond
function BigDipper.OnUpdateCountdown(countdown)
	--commonlib.ShowDebugString("dipper_countdown", countdown);
	nextround_countdown = countdown;
end

function BigDipper.OnUpdateSlotValues(nids)
	local nids_str = "";
	local i;
	for i = 1, #nids do
		nids_str = nids_str..nids[i]..",";
	end
	--commonlib.ShowDebugString("dipper_slots_value", nids_str);
end

-- try queue on the big dipper
function BigDipper.TryGetTicket()
	System.GSL_client:SendRealtimeMessage("s30051", {body="[Aries][ServerObject30051]TryGetTicket"});
end
-------- possible return messages ----------------
function BigDipper.OnRecvDipperRunning()
	--_guihelper.MessageBox("BigDipper.OnRecvDipperRunning")
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">过山车在行驶中，暂停售票，请过会再来吧！</div>]]);
end
function BigDipper.OnRecvAlreadyGetTicket()
	--_guihelper.MessageBox("BigDipper.OnRecvAlreadyGetTicket")
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你已拿过车票了，请在附近耐心等候上车！</div>]]);
end
function BigDipper.OnRecvGetTicketSuccess()
	haveTicket = true;
	-- enter idle mode
	MyCompany.Aries.Desktop.Dock.EnterIdleMode();
	--_guihelper.MessageBox("BigDipper.OnRecvGetTicketSuccess")
	local minutes = nil;
	local seconds = nil;
	if(nextround_countdown) then
		seconds = math.floor(nextround_countdown / 1000);
		minutes = math.floor(seconds / 60);
		seconds = seconds - minutes * 60;
		_guihelper.MessageBox(string.format([[<div style="margin-left:16px;margin-top:20px;">你已拿到车票，距离开车时间还有%d分%d秒，请在光圈内耐心等候。</div>]], 
			minutes, seconds));
	else
		_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你已拿到车票，距离开车还有一会，请在光圈内耐心等候。</div>]]);
	end
end
function BigDipper.OnRecvDipperFull()
	--_guihelper.MessageBox("BigDipper.OnRecvDipperFull")
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">本趟过山车车票已售完，过会再来领下一趟的车票吧，过山车每5分钟就有一趟呢！</div>]]);
end


-- drop the big dipper ticket
function BigDipper.DropTicket()
	System.GSL_client:SendRealtimeMessage("s30051", {body="[Aries][ServerObject30051]DropTicket"});
end
-------- possible return messages ----------------
function BigDipper.OnRecvDropTicketSuccess()
	haveTicket = false;
	-- leave idle mode
	MyCompany.Aries.Desktop.Dock.LeaveIdleMode();
	
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你离过山车太远了，车票作废了，请在售票处重新购票。</div>]]);
end

-- play winning effect of users with nids
-- @params nids: all user nids
-- @params winner: winner nid
function BigDipper.PlayWinningEffect(nids, winner)
	if(not nids or not winner) then
		return;
	end
	local valid_nids = {};
	local _, nid;
	for _, nid in pairs(nids) do
		local player = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
		if(player and player:IsValid() == true) then
			table.insert(valid_nids, nid);
		end
	end
	-- show effect with only valid nids
	nids = valid_nids;
	-- user count
	local user_count = #nids;
	if(user_count == 0) then
		return;
	end
    -- play rolling effect
	local params = {
		asset_file = "character/v5/temp/Effect/Recklessness_Impact_Chest.x",
		binding_obj_name = nil,
		start_position = {0, 0, 0},
		--duration_time = 500 * user_count * 2,
		duration_time = 5000,
		force_name = nil,
		begin_callback = function() 
			end,
		end_callback = function() 
				local winner_player = MyCompany.Aries.Pet.GetUserCharacterObj(winner);
				if(winner_player and winner_player:IsValid() == true) then
					-- play hit effect
					local params = {
						asset_file = "character/v5/09effect/Disappear/Disappear.x",
						binding_obj_name = winner_player.name,
						start_position = nil,
						duration_time = 1500,
						force_name = nil,
						begin_callback = function() 
						end,
						end_callback = function() 
							if(winner == System.App.profiles.ProfileManager.GetNID()) then
								-- proceed with winning reward if the loggedin user is the winner
								BigDipper.ProceedReward();
							else
								local bOnDipper = false;
								local i;
								for i = 1, #nids do
									if(nids[i] == System.App.profiles.ProfileManager.GetNID()) then
										bOnDipper = true;
										break;
									end
								end
								if(bOnDipper == true) then
									-- proceed with winner reminder
									BigDipper.ProceedRemind(winner);
								end
							end
						end,
					};
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.CreateEffect(params);
				end
			end,
		elapsedtime_callback = function(elapsedTime, obj)
			local index = math.mod(math.floor(elapsedTime / 500), user_count) + 1;
			if(index) then
				local nid = nids[index];
				local player = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
				if(player and player:IsValid() == true) then
					local x, y, z = player:GetPosition();
					y = y + 0.7;
					obj:SetPosition(x, y, z);
				end
			end
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
	
    -- play rolling effect
	local params = {
		asset_file = "model/06props/v5/03quest/GiftBox/BigGiftBox.x",
		ismodel = true,
		binding_obj_name = nil,
		start_position = {0, 0, 0},
		--duration_time = 500 * user_count * 2,
		duration_time = 5000,
		force_name = nil,
		begin_callback = function() 
			end,
		end_callback = function() 
				local winner_player = MyCompany.Aries.Pet.GetUserCharacterObj(winner);
				if(winner_player and winner_player:IsValid() == true) then
					-- play hit effect
					local params = {
						asset_file = "model/06props/v5/03quest/GiftBox/BigGiftBox.x",
						ismodel = true,
						binding_obj_name = nil,
						start_position = {0, 0, 0},
						duration_time = 1000,
						force_name = nil,
						begin_callback = function() 
						end,
						end_callback = function() 
						end,
						elapsedtime_callback = function(elapsedTime, obj)
							local winner_player = MyCompany.Aries.Pet.GetUserCharacterObj(winner);
							if(winner_player and winner_player:IsValid() == true) then
								local x, y, z = winner_player:GetPosition();
								y = y + 3.5 - 1.5 * (elapsedTime / 1000);
								obj:SetPosition(x, y, z);
								local scale = 0.7 - 0.4 * (elapsedTime / 1000);
								obj:SetScale(scale);
							end
						end,
					};
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.CreateEffect(params);
				end
			end,
		elapsedtime_callback = function(elapsedTime, obj)
			local index_this = math.mod(math.floor(elapsedTime / 500), user_count) + 1;
			local index_next = math.mod(index_this, user_count) + 1;
			if(index_this) then
				local nid_this = nids[index_this];
				local nid_next = nids[index_next];
				local player_this = MyCompany.Aries.Pet.GetUserCharacterObj(nid_this);
				local player_next = MyCompany.Aries.Pet.GetUserCharacterObj(nid_next);
				if(player_this and player_this:IsValid() == true and player_next and player_next:IsValid() == true) then
					local x_this, y_this, z_this = player_this:GetPosition();
					local x_next, y_next, z_next = player_next:GetPosition();
					local ratio = math.mod(elapsedTime, 500) / 500;
					
					local x, y, z;
					x = x_this + (x_next - x_this) * ratio;
					y = y_this + (y_next - y_this) * ratio;
					z = z_this + (z_next - z_this) * ratio;
					y = y + 3.5;
					obj:SetPosition(x, y, z);
					local remaining = math.mod(elapsedTime, 500);
					local scale = 0.5 + math.abs(remaining - 250) / 250 * 0.2;
					obj:SetScale(scale);
				end
			end
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
end

function BigDipper.ProceedReward()
	local gsid = 17008;
	local count = 5;
	local exid = nil;
	--local r = math.random(0, 1000);
	--if(r <= 300) then
		---- 30065_Jackstraw
		--gsid = 30065;
		--count = 1;
		--exid = 301;
	--elseif(r <= 600) then
		---- 30098_OutdoorPlantMeiHua
		--gsid = 30098;
		--count = 2;
	--elseif(r <= 800) then
		---- 17029_CrystalRock
		--gsid = 17029;
		--count = 5;
	--elseif(r <= 1000) then
		---- 17008_HoneyCrystal
		--gsid = 17008;
		--count = 5;
	--end
	
	-- change of reward 2010/4/7
	local r = math.random(0, 1000);
	if(r <= 150) then
		-- 30131_OutdoorPlantCandyOmelette
		gsid = 30131;
		count = 2;
	elseif(r <= 300) then
		-- 30098_OutdoorPlantMeiHua
		gsid = 30098;
		count = 2;
	elseif(r <= 450) then
		-- 30132_OutdoorPlantBubbleGum
		gsid = 30132;
		count = 2;
	elseif(r <= 600) then
		-- 30133_OutdoorPlantCakeWithFilling
		gsid = 30133;
		count = 2;
	elseif(r <= 1000) then
		-- 30134_OutdoorPlantCandyBean
		gsid = 30134;
		count = 4;
	end
	
	local rewardname = "";
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		rewardname = count.."个"..gsItem.template.name;
	end
	
	_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">本趟过山车已经到站，恭喜你获得幸运勇气大礼包，里面有%s，快快收起来吧！</div>]], rewardname), function(res)
		if(res and res == _guihelper.DialogResult.OK) then
			if(exid) then
				-- get reward through extended cost
				ItemManager.ExtendedCost(exid, nil, nil, function(msg)
				end, function(msg) end);
			else
				-- get reward through purchase item
				ItemManager.PurchaseItem(gsid, count, function(msg)
				end, function(msg) end);
			end
		end
	end, _guihelper.MessageBoxButtons.OK);
end

function BigDipper.ProceedRemind(winner)
	-- get the icon in memory
	System.App.profiles.ProfileManager.GetUserInfo(winner, "UpdateChatWndIcon", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local nickname = msg.users[1].nickname;
			local minutes = 10;
			local seconds = 0;
			if(nextround_countdown) then
				seconds = math.floor(nextround_countdown / 1000);
				minutes = math.floor(seconds / 60);
				seconds = seconds - minutes * 60;
			end
			_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">本趟过山车已经到站啦，%s获得了幸运勇气大礼包，下一趟的开车时间还有%d分%d秒，到时候再来吧！</div>]], nickname, minutes, seconds));
		end
	end, "access plus 1 year");
end

function BigDipper.PlayCountDownEffect(countdownseconds)
	local _effect = ParaUI.GetUIObject("Aries_BigDipper_CountDownEffect");
	if(_effect:IsValid() == false) then
		_effect = ParaUI.CreateUIObject("container", "Aries_BigDipper_CountDownEffect", "_ctt", 0, 100, 128, 128);
		_effect.background = "";
		_effect.enabled = false;
		_effect:AttachToRoot();
	end
	_effect.visible = true;
	UIAnimManager.PlayCustomAnimation(countdownseconds * 1000, function(elapsedTime)
		local _effect = ParaUI.GetUIObject("Aries_BigDipper_CountDownEffect");
		if(_effect:IsValid() == true) then
			local index = math.floor(elapsedTime / 1000);
			local remaining = elapsedTime - index * 1000;
			if((countdownseconds - index) == 1) then
				_effect.background = "Texture/Aries/Desktop/CountDownHelper/countdown_1.png";
			elseif((countdownseconds - index) == 2) then
				_effect.background = "Texture/Aries/Desktop/CountDownHelper/countdown_2.png";
			elseif((countdownseconds - index) == 3) then
				_effect.background = "Texture/Aries/Desktop/CountDownHelper/countdown_3.png";
			elseif((countdownseconds - index) == 4) then
				_effect.background = "Texture/Aries/Desktop/CountDownHelper/countdown_4.png";
			elseif((countdownseconds - index) == 5) then
				_effect.background = "Texture/Aries/Desktop/CountDownHelper/countdown_5.png";
			end
			if(remaining <= 300) then
				local alpha = math.floor(255 * remaining / 300);
				_effect.color = "255 255 255 "..alpha;
			elseif(remaining <= 1000) then
				local alpha = math.floor(255 * (1000 - remaining) / 700);
				_effect.color = "255 255 255 "..alpha;
			end
			_effect.scalingx = 0.5 + 1 * (remaining / 1000);
			_effect.scalingy = 0.5 + 1 * (remaining / 1000);
			if(elapsedTime == countdownseconds * 1000) then
				_effect.visible = false;
			end
		end
	end);
end