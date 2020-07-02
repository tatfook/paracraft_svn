--[[
Title: SnowHeap
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30343_SnowHeap.lua
------------------------------------------------------------
]]

-- create class
local libName = "SnowHeap";
local SnowHeap = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SnowHeap", SnowHeap);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local explode_interval = 600000;
local remove_gift_interval = 180000;

-- SnowHeap.main
function SnowHeap.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30343);
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					commonlib.echo(msg);
					-- on hit snow heap with firecracker
					if(msg.throwItem.gsid == 9503) then
						local i;
						for i = 1, 10 do
							local snowHeap = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30343, i);
							if(snowHeap and snowHeap:IsValid() == true) then
								local _, name;
								for _, name in pairs(msg.hitObjNameList or {}) do
									if(name == snowHeap.name) then
										-- hit on self
										SnowHeap.On_Hit(i);
									end
								end
							end
						end
					end
				end
			end
		end, 
	hookName = "OnThrowableHit_30343_SnowHeap", appName = "Aries", wndName = "throw"});
	
	--local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30343);
	--if(giftTree and giftTree:IsValid() == true) then
		--if(memory.isClean == true) then
			--giftTree.SetStage(5);
		--else
			--giftTree.SetStage(1);
		--end
	--end
	
	-- force execute ontimer function
	SnowHeap.On_Timer();
end

-- SnowHeap.On_Timer
function SnowHeap.On_Timer()
	local i;
	for i = 1, 10 do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30343);
		memory[i] = memory[i] or {};
		memory = memory[i];
		if(memory.lastExplodeTime) then
			-- hide snow heap
			SnowHeap.HideSnowHeap(i);
			if((ParaGlobal.GetGameTime() - memory.lastExplodeTime) > explode_interval) then
				-- create snow heap if not exist
				memory.lastExplodeTime = nil;
				SnowHeap.ShowSnowHeap(i);
			elseif((ParaGlobal.GetGameTime() - memory.lastExplodeTime) > remove_gift_interval) then
				-- remove the gift if available
				SnowHeap.DeleteGift(i);
			end
		end
	end
end

function SnowHeap.PreDialog()
	return true;
end

function SnowHeap.On_Hit(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30343);
	memory[instance] = memory[instance] or {};
	memory = memory[instance];
	if(memory) then
		memory.isHit = true;
		-- create gift
		SnowHeap.CreateGiftAndHideSnowHeap(instance)
		---- automatically show the dialog page
		--System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			--{npc_id = 30343, instance = instance}
		--);
	end
end

function SnowHeap.ShowSnowHeap(instance)
	local params = MyCompany.Aries.Quest.NPCList.NPCs[30343];
	local position = params.positions[instance];
	local facing = params.facings[instance];
	local scaling = params.scaling;
	if(params.scalings) then
		scaling = params.scalings[instance];
	end
	local params = commonlib.deepcopy(params);
	params.copies = nil;
	params.positions = nil;
	params.facings = nil;
	params.scalings = nil;
	params.position = position;
	params.facing = facing;
	params.scaling = scaling;
	params.instance = instance;
	local snowheap = NPC.CreateNPCCharacter(30343, params);
	if(snowheap and snowheap:IsValid() == true) then
		headon_speech.Speek(snowheap.name, "", 0);
	end
end

function SnowHeap.HideSnowHeap(instance)
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30343, instance);
end

-- create gift
function SnowHeap.CreateGiftAndHideSnowHeap(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30343);
	memory[instance] = memory[instance] or {};
	memory = memory[instance];
	-- 17048_LilyFlower
	-- 17049_PearlFruit
	-- 17029_CrystalRock
	-- 30096_OutdoorPlantPlum
	local ran = math.random(0, 400);
	local worldpath = ParaWorld.GetWorldDirectory();
	local isshownifown = nil;
	if(string.find(string.lower(worldpath), "haqitown")) then
		memory.giftgsid = 17048;
		memory.giftname = "百合";
		if(ran < 100) then
			memory.giftgsid = 17048;
			memory.giftname = "百合";
		elseif(ran < 200) then
			memory.giftgsid = 17049;
			memory.giftname = "珍珠果";
		elseif(ran < 300) then
			memory.giftgsid = 17029;
			memory.giftname = "晶晶石";
		elseif(ran < 400) then
			memory.giftgsid = 30096;
			memory.giftname = "西梅种子";
		end
	elseif(string.find(string.lower(worldpath), "frostroarisland")) then
		memory.giftgsid = 17142;
		memory.giftname = "亡灵猴的骸骨";
		isshownifown = false;
	end
	
	local snowheap = NPC.GetNpcCharacterFromIDAndInstance(30343, instance);
	if(snowheap and snowheap:IsValid() == true) then
		local gift = GameObject.GetGameObjectCharacterFromIDAndInstance(303430 + instance);
		if(gift and gift:IsValid() == true) then
			-- gift is already created on ground
		else
			local assetfile_char = "character/common/dummy/cube_size/cube_size.x";
			local assetfile_model;
			if(memory.giftgsid == 17048) then
				assetfile_model = "model/05plants/v5/06flower/WhiteLily/WhiteLily.x";
			elseif(memory.giftgsid == 17049) then
				assetfile_model = "model/05plants/v5/05fruit/PearlFruit/PearlFruit.x";
			elseif(memory.giftgsid == 17029) then
				assetfile_model = "model/06props/v5/03quest/CrystalRock/CrystalRock.x";
			elseif(memory.giftgsid == 30096) then
				assetfile_model = "model/05plants/v5/08homelandPlant/Plum/PlumStage0.x";
			elseif(memory.giftgsid == 17142) then
				assetfile_model = "model/02furniture/v5/IceIsand/DeadMonkeyBones/DeadMonkeyBones02.x";
			end
			local params = {
				name = "",
				position = { snowheap:GetPosition() },
				assetfile_char = assetfile_char,
				assetfile_model = assetfile_model,
				facing = 0.91666221618652,
				scaling = 1.0,
				scaling_char = 0.7,
				scaling_model = 1.0,
				gameobj_type = "FreeItem",
				isdeleteafterpick = true,
				isshownifown = isshownifown,
				gsid = memory.giftgsid,
				pick_count = 1,
				dialogstyle_antiindulgence = true,
				onpick_msg = "这是被深埋在这雪堆里的"..memory.giftname.."，被你炸出来了，快把它捡走吧。",
			};
			local GameObject = MyCompany.Aries.Quest.GameObject;
			local gift, giftModel = GameObject.CreateGameObjectCharacter(303430 + instance, params);
			
			-- TODO: play falling animation
			
			--UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
				--if(elapsedTime == 500) then
					--ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
					--ParaGlobal.ExitApp();
				--end
			--end);
		end
		-- explode the snow heap
		SnowHeap.PlayExplodeEffect(instance);
		-- delete the snow heap object
		SnowHeap.HideSnowHeap(instance);
		-- set last explode time
		memory.lastExplodeTime = ParaGlobal.GetGameTime();
	end
end

function SnowHeap.PlayExplodeEffect(instance)
	local snowheap = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30343, instance);
	if(snowheap and snowheap:IsValid() == true) then
		local att = ParaCamera.GetAttributeObject();
		local rotY = att:GetField("CameraRotY", CameraRotY);
		-- create effect
		local params = {
			asset_file = "model/07effect/v5/SnowBlast/SnowBlast.x",
			ismodel = true,
			scale = 1.6,
			facing = rotY + 1.57,
			start_position = {snowheap:GetPosition()},
			duration_time = 800,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end

function SnowHeap.PreDialog(npc_id, instance)
	return true;
end

function SnowHeap.DeleteGift(instance)
	MyCompany.Aries.Quest.GameObject.DeleteGameObjectCharacter(303430 + instance);
end


function SnowHeap.PreDialog_17034()
	SnowHeap.GetGift(17034)
end
function SnowHeap.PreDialog_17035()
	SnowHeap.GetGift(17035)
end
function SnowHeap.PreDialog_17036()
	SnowHeap.GetGift(17036)
end
function SnowHeap.PreDialog_17037()
	SnowHeap.GetGift(17037)
end
function SnowHeap.PreDialog_17033()
	SnowHeap.GetGift(17033)
end
function SnowHeap.PreDialog_0()
    local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
    if(AddMoneyFunc) then
        AddMoneyFunc(100, function(msg)
			log("============ SnowHeap get gift Joybean returns: ============");
			commonlib.echo(msg);
			--if(msg.issuccess) then
				--SnowHeap.DeleteGift();
			--end
        end);
    end
end

function SnowHeap.GetGift(gsid)
    ItemManager.PurchaseItem(gsid, 1, function(msg)
	    if(msg) then
		    log("+++++++SnowHeap.GetGift "..gsid.." return: +++++++\n")
		    commonlib.echo(msg);
		    --if(msg.issuccess == true) then
		        --SnowHeap.DeleteGift()
		    --end
	    end
    end);
end

function SnowHeap.TryExchange()
end