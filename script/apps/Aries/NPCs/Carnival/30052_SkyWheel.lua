--[[
Title: SkyWheel
Company: ParaEnging Co. & Taomee Inc.
Author(s): WangTian
Date: 2010/2/2

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Carnival/30052_SkyWheel.lua
------------------------------------------------------------
]]

-- create class
local libName = "SkyWheel";
local SkyWheel = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SkyWheel", SkyWheel);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local CurrentTime = nil;
local UpdateGameTime = nil;

local slots = {};
local i;
for i = 1, 12 do
	slots[i] = 0;
end

local animation_offset_slots = 0;
local slot_id_mount_id_offset = 19;

local position_after_unmount = {x = 20380.6875, y = 0.58130121231079, z = 19840.0859375};

NPL.load("(gl)script/apps/Aries/Player/BaseChar.lua");

-- SkyWheel.main()
function SkyWheel.main()
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldClosing") then
				-- first unhook the world closing
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_SkyWheel", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				-- reset current time and game time
				CurrentTime = nil;
				UpdateGameTime = nil;
				-- reset slots
				slots = {};
				local i;
				for i = 1, 12 do
					slots[i] = 0;
				end
			end
		end, 
		hookName = "WorldClosing_SkyWheel", appName = "Aries", wndName = "main"});
end

function SkyWheel.main_ticket()
end

-- SkyWheel.RefreshStatus()
function SkyWheel.RefreshStatus()
end

-- SkyWheel.PreDialog()
function SkyWheel.PreDialog()
	local slot_id = SkyWheel.GetBottomSlotID();
	if(slot_id) then
		_guihelper.MessageBox([[<div style="margin-left:40px;margin-top:30px;">你现在就想坐上摩天轮吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				SkyWheel.TryMount(slot_id);
			end	
		end, _guihelper.MessageBoxButtons.YesNo);
	end
	return false;
end

-- refresh empty slot of the sky wheel
function SkyWheel.RefreshEmptySlot(slot_id)
	if(slots[slot_id] ~= 0) then
		MyCompany.Aries.BaseChar.UnMount({
			nid = slots[slot_id],
			position = position_after_unmount,
		});
		MyCompany.Aries.Pet.LeaveIndoorMode(slots[slot_id]);
	end
	
	slots[slot_id] = 0;
	
	--local slot_str = "";
	--local i;
	--for i = 1, 12 do
		--slot_str = slot_str..slots[i]..",";
	--end
	--commonlib.ShowDebugString("skywheel_slots", slot_str);
end
-- refresh mounted slot of the sky wheel
function SkyWheel.RefreshMountedSlot(nid, slot_id)
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
	
	local npcModel = NPC.GetNpcModelFromIDAndInstance(30052);
	if(npcModel) then
		local att = npcModel:GetAttributeObject();
		--att:SetField("UseGlobalTime", true);
		--att:SetField("AnimFrame", 0);
		--att:SetField("AnimID", 0);
		--ParaScene.GetPlayer():ToCharacter():MountOn(npcModel, slot_id_mount_id_offset + slot_id)
		MyCompany.Aries.Pet.EnterIndoorMode(nid);
		MyCompany.Aries.BaseChar.MountOn({nid = nid, model = npcModel, slot_index = (slot_id_mount_id_offset + slot_id)});
	end
	
	--local slot_str = "";
	--local i;
	--for i = 1, 12 do
		--slot_str = slot_str..slots[i]..",";
	--end
	--commonlib.ShowDebugString("skywheel_slots", slot_str);
end

-- CreateFeather
function SkyWheel.CreateFeather()
	local positions = {
		{ 20406.31640625, 28.764162063599, 19831.16015625 },
		{ 20389.25390625, 45.235656738281, 19818.099609375 },
		{ 20373.029296875, 20.937219619751, 19808.53125 },
	};
	
	local position = positions[math.ceil(math.random(#positions * 100) / 100)];
	
	local params = {
		name = "feather",
		position = position,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",
		assetfile_model = "model/06props/v5/03quest/Feather/Feather.x",
		facing = 0,
		scaling = 0.9,
		scale_char = 3,
		pickdist = 5,
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		isalwaysshowheadontext = false,
		pick_count = 1,
		gsid = 17075, -- 17075_LightFeather
	};
	GameObject.CreateGameObjectCharacter(300521, params);
end

function SkyWheel.DeleteFeather()
	Quest.GameObject.DeleteGameObjectCharacter(300521);
end

-- try mount on sky wheel slot
function SkyWheel.TryMount(slot_id)
	System.GSL_client:SendRealtimeMessage("s30052", {body="[Aries][ServerObject30052]TryMount:"..slot_id});
end
-------- possible return messages ----------------
function SkyWheel.OnRecvStartMount(slot_id)
	local npcModel = NPC.GetNpcModelFromIDAndInstance(30052);
	if(npcModel) then
		-- enter jump freeze mode
		MyCompany.Aries.Player.EnterFreezeJumpMode();
		-- enter freeze reverse mode, (left shift)
		MyCompany.Aries.EnterFreezeReverseMode();
		-- enter idle mode
		MyCompany.Aries.Desktop.Dock.EnterIdleMode();
		-- enter indoor mode
		MyCompany.Aries.Pet.EnterIndoorMode(System.App.profiles.ProfileManager.GetNID());
		MyCompany.Aries.BaseChar.MountOn({
			nid = System.App.profiles.ProfileManager.GetNID(), 
			model = npcModel, 
			slot_index = (slot_id_mount_id_offset + slot_id),
		});
		-- create feather for pick
		SkyWheel.CreateFeather();
		--ParaScene.GetPlayer():ToCharacter():MountOn(npcModel, slot_id)
		UIAnimManager.PlayCustomAnimation(100, function(elapsedTime)
			if(elapsedTime == 100) then
				System.Animation.PlayAnimationFile({0}, ParaScene.GetPlayer());
			end
		end);
	end
	--_guihelper.MessageBox("SkyWheel.OnRecvStartMount with slot_id:"..slot_id);
end
function SkyWheel.OnRecvAlreadyMounted()
	log("SkyWheel.OnRecvAlreadyMounted\n")
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">这个房间已经有哈奇先进去啦，请耐心等候下一个! </div>]])
end

-- try unmount from sky wheel slot
function SkyWheel.CancelMount()
	System.GSL_client:SendRealtimeMessage("s30052", {body="[Aries][ServerObject30052]CancelMount"});
end
-------- possible return messages ----------------
function SkyWheel.OnRecvUnMount(slot_id)
	--_guihelper.MessageBox("SkyWheel.OnRecvUnMount with slot_id:"..slot_id);
	MyCompany.Aries.BaseChar.UnMount({nid = System.App.profiles.ProfileManager.GetNID()});
	MyCompany.Aries.Pet.LeaveIndoorMode(System.App.profiles.ProfileManager.GetNID());
	-- leave jump freeze mode
	MyCompany.Aries.Player.LeaveFreezeJumpMode();
	-- leave freeze reverse mode, (left shift)
	MyCompany.Aries.LeaveFreezeReverseMode();
	-- leave idle mode
	MyCompany.Aries.Desktop.Dock.LeaveIdleMode();
	-- delete feather
	SkyWheel.DeleteFeather();
end

-- on sky wheel finish a full round
function SkyWheel.OnRecvUnMountAndRecvReward(slot_id)
	log("SkyWheel.OnRecvUnMountAndRecvReward with slot_id:"..slot_id.."\n");
	MyCompany.Aries.BaseChar.UnMount({
		nid = System.App.profiles.ProfileManager.GetNID(), 
		position = position_after_unmount,
	});
	MyCompany.Aries.Pet.LeaveIndoorMode(System.App.profiles.ProfileManager.GetNID());
	--_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">本趟摩天轮已到站，你已安全下车。</div>]])
	MyCompany.Aries.Scene.ShowRegionLabel("本趟摩天轮已到站，你已安全下车。", "240 226 43");
	-- leave jump freeze mode
	MyCompany.Aries.Player.LeaveFreezeJumpMode();
	-- leave freeze reverse mode, (left shift)
	MyCompany.Aries.LeaveFreezeReverseMode();
	-- leave idle mode
	MyCompany.Aries.Desktop.Dock.LeaveIdleMode();
	-- delete feather
	SkyWheel.DeleteFeather();
end

-- on update remaining
function SkyWheel.OnUpdateRemaining(remaining)
	--commonlib.ShowDebugString("sky_remaining", remaining);
end

local slot_count = 12;

local single_duration = 3333;
local full_duration = single_duration * slot_count;

-- on update CurrentTime
function SkyWheel.OnUpdateCurrentTime(time)
	CurrentTime = time;
	UpdateGameTime = ParaGlobal.timeGetTime();
	--commonlib.ShowDebugString("sky_CurrentTime", time);
	
	SkyWheel.GetBottomSlotID()
	
	SkyWheel.OnUpdateAnimFrame();
end

-- update anim frame
function SkyWheel.OnUpdateAnimFrame()
	local npcModel = NPC.GetNpcModelFromIDAndInstance(30052);
	if(npcModel) then
		local att = npcModel:GetAttributeObject();
		local CurrentTime = SkyWheel.GetCorrectedCurrentTime();
		if(CurrentTime) then
			local remaining = (CurrentTime - math.floor(CurrentTime / full_duration) * full_duration);
			--local nAnimFrame = att:GetField("AnimFrame", 0);
			--commonlib.ShowDebugString("current_AnimFrame", nAnimFrame);
			att:SetField("AnimFrame", remaining);
			--commonlib.ShowDebugString("sky_AnimFrame", remaining);
		end
	end
end
-- corrected time with game time offset from the last set current sky wheel time
function SkyWheel.GetCorrectedCurrentTime()
	if(not CurrentTime or not UpdateGameTime) then
		return;
	end
	return (ParaGlobal.timeGetTime() - UpdateGameTime) + CurrentTime;
end


-- get current bottom slot
-- @return: slot id [1, 12]
function SkyWheel.GetBottomSlotID()
	local correctedCurrentTime = SkyWheel.GetCorrectedCurrentTime();
	if(not correctedCurrentTime) then
		return;
	end
	
	local index = math.floor((correctedCurrentTime - math.floor(correctedCurrentTime / full_duration) * full_duration) / single_duration) + 1;
	
	--index = (index + animation_offset_slots - 1) % slot_count + 1;
	
	return index;
end