--[[
Title: ChristmasGiftTree
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30319_ChristmasGiftTree.lua
------------------------------------------------------------
]]

-- create class
local libName = "ChristmasGiftTree";
local ChristmasGiftTree = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ChristmasGiftTree", ChristmasGiftTree);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 39101_SnowHomelandTemplate

local shake_interval = 120000;
local remove_gift_interval = 60000;

-- ChristmasTree.main
function ChristmasGiftTree.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30319);
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					commonlib.echo(msg);
					-- on hit dirty elk with snow ball
					if(msg.throwItem.gsid == 9504) then
						local i;
						for i = 1, 2 do
							local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30319, i);
							if(giftTree) then
								local _, name;
								for _, name in pairs(msg.hitObjNameList or {}) do
									if(name == giftTree.name) then
										-- hit on self
										ChristmasGiftTree.On_Hit(i);
									end
								end
							end
						end
					end
				end
			end
		end, 
	hookName = "OnThrowableHit_30319_ChristmasGiftTree", appName = "Aries", wndName = "throw"});
	
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
		end
	});
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/05plants/v5/01tree/ChristmasTree/ChristmasGiftTree_tremble.x"));
	loader:AddAssets(ParaAsset.LoadTexture("", "model/05plants/v5/01tree/ChristmasTree/ChristmasGiftTree.dds", 1));
	
	--local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30319);
	--if(giftTree) then
		--if(memory.isClean == true) then
			--giftTree.SetStage(5);
		--else
			--giftTree.SetStage(1);
		--end
	--end
end

-- ChristmasGiftTree.On_Timer
function ChristmasGiftTree.On_Timer()
	local i;
	for i = 1, 2 do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30319);
		memory[i] = memory[i] or {};
		memory = memory[i];
		if(memory.lastShakeTime) then
			if((ParaGlobal.GetGameTime() - memory.lastShakeTime) > shake_interval) then
				memory.lastShakeTime = nil;
				memory.isEmpty = false;
			elseif((ParaGlobal.GetGameTime() - memory.lastShakeTime) > remove_gift_interval) then
				--ChristmasGiftTree.DeleteGift()
			else
				-- gift tree is empty
				memory.isEmpty = true;
			end
		end
	end
end

function ChristmasGiftTree.PreDialog()
	return true;
end

function ChristmasGiftTree.On_Hit(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30319);
	memory[instance] = memory[instance] or {};
	memory = memory[instance];
	if(memory) then
		memory.isHit = true;
		-- automatically show the dialog page
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			{npc_id = 30319, instance = instance}
		);
	end
end

-- create gift
function ChristmasGiftTree.CreateGift(gsid)
	local gift = NPC.GetNpcCharacterFromIDAndInstance(303191);
	if(gift) then
		-- gift is already created on ground
		return;
	else
		local assetfile_char = "character/common/dummy/cube_size/cube_size.x";
		local assetfile_model;
		if(gsid == 17034) then
			assetfile_model = "model/06props/v5/03quest/YarnBall/RedYarnBall.x";
		elseif(gsid == 17035) then
			assetfile_model = "model/06props/v5/03quest/YarnBall/YellowYarnBall.x";
		elseif(gsid == 17036) then
			assetfile_model = "model/06props/v5/03quest/YarnBall/GreenYarnBall.x";
		elseif(gsid == 17037) then
			assetfile_model = "model/06props/v5/03quest/YarnBall/WhiteYarnBall.x";
		elseif(gsid == 17033) then
			assetfile_model = "model/06props/v5/05other/Watermelon/Watermelon.x";
		elseif(gsid == 0) then
			assetfile_model = "model/06props/v5/JoyBean/JoyBean.x";
		end
		local params = {
			name = "",
			--gsid = 17008,
			position = { 20172.919921875, 3.499470949173, 19723.16796875 },
			assetfile_char = assetfile_char,
			assetfile_model = assetfile_model,
			facing = 0.91666221618652,
			scaling = 1.0,
			scaling_char = 0.7,
			scaling_model = 1.0,
			main_script = "",
			main_function = "",
			predialog_function = "MyCompany.Aries.Quest.NPCs.ChristmasGiftTree.PreDialog_"..gsid,
			EnablePhysics = false,
			cursor = "Texture/Aries/Cursor/Pick.tga",
		};
		local NPC = MyCompany.Aries.Quest.NPC;
		local gift, giftModel = NPC.CreateNPCCharacter(303191, params);
		
		-- TODO: play falling animation
		
		--UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			--if(elapsedTime == 500) then
				--ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
				--ParaGlobal.ExitApp();
			--end
		--end);
		
	end
end

function ChristmasGiftTree.DoShake(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30319);
	memory[instance] = memory[instance] or {};
	memory = memory[instance];
	if(memory) then
		local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30319, instance);
		if(giftTree) then
			giftTree:SetVisible(false);
			
			-- create effect
			local params = {
				asset_file = "model/05plants/v5/01tree/ChristmasTree/ChristmasGiftTree_tremble.x",
				ismodel = true,
				scale = 1.5 * 1.3,
				start_position = {giftTree:GetPosition()},
				duration_time = 2000,
				end_callback = function()
					local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30319, instance);
					if(giftTree) then
						giftTree:SetVisible(true);
					end
				end,
			};
			local EffectManager = MyCompany.Aries.EffectManager;
			EffectManager.CreateEffect(params);
		end
	end
end

function ChristmasGiftTree.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30319);
	memory[instance] = memory[instance] or {};
	memory = memory[instance];
	if(memory) then
		if(memory.lastShakeTime) then
			-- during the shake time, gift tree is empty
			memory.dialog_state = 2;
		else
			if(memory.isHit ~= true) then
				memory.dialog_state = 1;
			else
				-- reset the hit tag
				memory.isHit = nil;
				-- set last shake gift tree time
				memory.lastShakeTime = ParaGlobal.GetGameTime();
				-- shake christmas gift tree
				ChristmasGiftTree.DoShake(instance);
				-- gift available
				local ran = math.random(0, 100);
				if(ran <= 10) then
					-- play the snow explode effect
					memory.dialog_state = 3;
				elseif(ran <= 85) then
					-- four yarn balls
					memory.dialog_state = 4;
					local ran = math.random(0, 400);
					local gsid = 17034;
					memory.giftname = "红毛线";
					memory.giftgsid = 17034;
					if(ran <= 100) then
						-- 17034_YarnBall_Red
						gsid = 17034;
						memory.giftname = "红毛线";
						memory.giftgsid = 17034;
					elseif(ran <= 200) then
						-- 17035_YarnBall_Yellow
						gsid = 17035;
						memory.giftname = "黄毛线";
						memory.giftgsid = 17035;
					elseif(ran <= 300) then
						-- 17036_YarnBall_Green
						gsid = 17036;
						memory.giftname = "绿毛线";
						memory.giftgsid = 17036;
					elseif(ran <= 400) then
						-- 17037_YarnBall_White
						gsid = 17037;
						memory.giftname = "白毛线";
						memory.giftgsid = 17037;
					end
					--ChristmasGiftTree.CreateGift(gsid);
				elseif(ran <= 90) then
					memory.dialog_state = 5;
					memory.giftname = "西瓜";
					memory.giftgsid = 17033;
					--ChristmasGiftTree.CreateGift(17033);
				elseif(ran <= 100) then
					memory.dialog_state = 6;
					memory.giftname = "奇豆";
					--ChristmasGiftTree.CreateGift(0);
					memory.giftgsid = 0;
				end
			end
		end
	end
	return true;
end

function ChristmasGiftTree.PreDialog_17034()
	ChristmasGiftTree.GetGift(17034)
end
function ChristmasGiftTree.PreDialog_17035()
	ChristmasGiftTree.GetGift(17035)
end
function ChristmasGiftTree.PreDialog_17036()
	ChristmasGiftTree.GetGift(17036)
end
function ChristmasGiftTree.PreDialog_17037()
	ChristmasGiftTree.GetGift(17037)
end
function ChristmasGiftTree.PreDialog_17033()
	ChristmasGiftTree.GetGift(17033)
end
function ChristmasGiftTree.PreDialog_0()
    local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
    if(AddMoneyFunc) then
        AddMoneyFunc(100, function(msg)
			log("============ ChristmasGiftTree get gift Joybean returns: ============");
			commonlib.echo(msg);
			--if(msg.issuccess) then
				--ChristmasGiftTree.DeleteGift();
			--end
        end);
    end
end

function ChristmasGiftTree.DeleteGift(instance)
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(303191, instance);
end

function ChristmasGiftTree.GetGift(gsid)
    ItemManager.PurchaseItem(gsid, 1, function(msg)
	    if(msg) then
		    log("+++++++ChristmasGiftTree.GetGift "..gsid.." return: +++++++\n")
		    commonlib.echo(msg);
		    --if(msg.issuccess == true) then
		        --ChristmasGiftTree.DeleteGift()
		    --end
	    end
    end);
end

function ChristmasGiftTree.TryExchange()
end