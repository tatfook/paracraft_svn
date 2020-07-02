--[[
Title: RainbowFlowerGame
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30085_RainbowFlowerGame.lua
------------------------------------------------------------
]]

-- create class
local libName = "RainbowFlowerGame";
local RainbowFlowerGame = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RainbowFlowerGame", RainbowFlowerGame);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

RainbowFlowerGame.time_limit = 240;

-- RainbowFlowerGame.main
function RainbowFlowerGame.main()
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldClosing") then
				-- first unhook the world closing
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_RainbowFlowerGame", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				-- then reset the game on world close
				RainbowFlowerGame.End();
			end
		end, 
		hookName = "WorldClosing_RainbowFlowerGame", appName = "Aries", wndName = "main"});
end

--local slow_timer = 0;
function RainbowFlowerGame.On_Timer()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	if(not memory.DuringGame) then
		return;
	end
	local pre_seconds = memory.countdownseconds;
	memory.countdownseconds = RainbowFlowerGame.time_limit - math.floor((ParaGlobal.GetGameTime() - memory.startgametime) / 1000);
	
	if(memory.countdownseconds <= 0) then
		RainbowFlowerGame.End();
		_guihelper.MessageBox("这里散落着七色花的七个花瓣，可是你没有在4分钟内将它们捡起，它们已经枯萎了。你再重新寻找七色花瓣吧。");
	end
	
	--if(slow_timer < 3) then
		--slow_timer = slow_timer + 1;
		--return
	--else
		--slow_timer = 0;
	--end
	if(pre_seconds ~= memory.countdownseconds) then
		RainbowFlowerGame.RefreshCount();
	end
	
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	local dist_sq = (x - 19859) * (x - 19859) + (z - 19997) * (z - 19997);
	if(dist_sq > 1100) then
		RainbowFlowerGame.End();
		_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你跑远啦，七色花寻找失败；花瓣只藏在园子里，重新点木牌开始找吧！]]);
	end
end

function RainbowFlowerGame.PreDialog()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	if(memory.DuringGame == true) then
		_guihelper.MessageBox("你还没找齐七个花瓣呢，赶紧找去呀！");
		return;
	end
	_guihelper.MessageBox("七色丛林里散落着七色花瓣，如果你在4分钟内捡到这七个花瓣，你就可以获得一朵七色花了，现在就开始找吗？", function(result) 
			if(_guihelper.DialogResult.OK == result) then
				RainbowFlowerGame.Start();
			elseif(_guihelper.DialogResult.Cancel == result) then
			end
		end, _guihelper.MessageBoxButtons.OKCancel);
	return false;
end

RainbowFlowerGame.Petal_models = {
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_red.x",
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_carnation.x",
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_yellow.x",
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_yellowliang.x",
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_green.x",
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_bluegreen.x",
	"model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_blue.x",
};

RainbowFlowerGame.SpawnPositions = {
	{19879.0625, 3.3440728187561, 20008.962890625},
	{19862.8828125, 3.6406161785126, 20004.666015625},
	{19853.19140625, 3.9932737350464, 20000.619140625},
	{19846.4609375, 4.6687927246094, 20000.85546875},
	{19839.58203125, 5.0785884857178, 19997.630859375},
	{19834.318359375, 5.1893405914307, 19995.330078125},
	{19838.51171875, 3.9668536186218, 19986.19140625},
	{19846.923828125, 3.8435876369476, 19991.84375},
	{19855.310546875, 2.5675168037415, 19990.74609375},
	{19867.87890625, 1.2299238443375, 19988.1875},
	{19883.43359375, 0.63858544826508, 19987.716796875},
};

-- start the game
function RainbowFlowerGame.Start()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	memory.DuringGame = true;
	memory.CountPetal = 0;
	RainbowFlowerGame.SpawnPetal();
	memory.startgametime = ParaGlobal.GetGameTime();
	memory.countdownseconds = RainbowFlowerGame.time_limit;
	RainbowFlowerGame.RefreshCount();
	
	---- stop game music
	--MyCompany.Aries.Scene.StopRegionBGMusic();
end

-- end the game
function RainbowFlowerGame.End()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	memory.DuringGame = false;
	memory.CountPetal = nil;
	memory.startgametime = nil;
	memory.countdownseconds = nil;
	RainbowFlowerGame.RefreshCount();
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(300851);
	
	---- resume game music
	--MyCompany.Aries.Scene.StopGameBGMusic();
	--MyCompany.Aries.Scene.ResumeRegionBGMusic();
end

-- spawn the petal
function RainbowFlowerGame.SpawnPetal()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	local index = 1;
	if(memory.DuringGame and memory.CountPetal) then
		index = memory.CountPetal + 1;
	else
		log("error: rainbow flower game respawn with nil countpetal or not duringgame")
		return;
	end
	local pos = RainbowFlowerGame.SpawnPositions[math.random(1, #(RainbowFlowerGame.SpawnPositions))];
	pos[2] = pos[2] + 0.2;
	local params = {
		name = "",
		position = pos,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = RainbowFlowerGame.Petal_models[index],
		facing = 0.91666221618652,
		scaling = 8.0,
		scaling_char = 0.8,
		main_script = "",
		main_function = "",
		main_script = "script/apps/Aries/NPCs/Doctor/30085_RainbowFlowerGame.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.RainbowFlowerGame.main_petal();",
		AI_script = "script/apps/Aries/NPCs/Doctor/30085_RainbowFlowerGame.lua",
		On_FrameMove = ";MyCompany.Aries.Quest.NPCs.RainbowFlowerGame.On_Petal_FrameMove();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.RainbowFlowerGame.PreDialog_petal",
		EnablePhysics = false,
		cursor = "Texture/Aries/Cursor/Pick.tga",
		--gameobj_type = "FreeItem",
		--isdeleteafterpick = true,
		--pick_count = 1,
		--EnablePhysics = false,
	};
	local NPC = MyCompany.Aries.Quest.NPC;
	local petal, petalModel = NPC.CreateNPCCharacter(300851, params);
	if(petal and petal:IsValid() == true) then
		headon_speech.Speek(petal.name, "", 0);
	end
	local npcChar, _model = NPC.GetNpcCharModelFromIDAndInstance(300851);
	if(npcChar and npcChar:IsValid())then
		npcChar:SnapToTerrainSurface(0);
		if(_model and _model:IsValid())then
			local x,y,z = npcChar:GetPosition();
			_model:SetPosition(x,y,z);
		end
	end	
end

function RainbowFlowerGame.main_petal()
end

local count = 0;
function RainbowFlowerGame.On_Petal_FrameMove()
	-- call the on framemove function at 1/10 rate
	if(count < 10) then
		count = count + 1;
		return;
	else
		count = 0;
	end
	
	local petal = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(petal:IsValid() == true and player:IsValid() == true) then
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(petal);
		local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(NPC_id, instance);
		
		local dist = petal:DistanceTo(player);
		if(dist <= 3) then
			-- flashing when enter 5 meter range
			if(npcModel and npcModel:IsValid() == true) then
				local render_tech = npcModel:GetField("render_tech", nil);
				if(render_tech == 3) then
					npcModel:SetField("render_tech", 10); -- TECH_SIMPLE_MESH_NORMAL_SELECTED
				end
			end
		elseif(dist > 3) then
			if(npcModel and npcModel:IsValid() == true) then
				local render_tech = npcModel:GetField("render_tech", nil);
				if(render_tech == 10) then
					npcModel:SetField("render_tech", 3); -- TECH_SIMPLE_MESH_NORMAL
				end
			end
		end
	end
end

function RainbowFlowerGame.PreDialog_petal()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	memory.CountPetal = memory.CountPetal + 1;
	RainbowFlowerGame.RefreshCount();
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(300851);
	if(memory.CountPetal == 7) then
		-- call hook for OnRainbowFlowerGameFinish
		local hook_msg = { aries_type = "OnRainbowFlowerGameFinish", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

		local hook_msg = { aries_type = "onRainbowFlowerGameFinish_MPD", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

		-- gain RainbowFlower
		_guihelper.MessageBox("你真厉害，找到了七色花散落的七个花瓣，因此你获得了一朵七色花，已经放在你的背包了，快去看看吧。");
		local ItemManager = System.Item.ItemManager;
		ItemManager.PurchaseItem(17005, 1, function(msg)
			if(msg) then
				log("+++++++Purchase 17005_RainbowFlower return: +++++++\n")
				commonlib.echo(msg);
			end
		end);
		RainbowFlowerGame.End();
	else
		RainbowFlowerGame.SpawnPetal();
	end
	return false;
end

-- refresh the bottom petal count
function RainbowFlowerGame.RefreshCount()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	if(memory.CountPetal == nil) then
		if(RainbowFlowerGame.statusPage) then
			RainbowFlowerGame.statusPage:Close();
			RainbowFlowerGame.statusPage = nil;
		end
	elseif(memory.CountPetal) then
		if(RainbowFlowerGame.statusPage) then
			RainbowFlowerGame.statusPage:Refresh(0.01);
		else
			RainbowFlowerGame.statusPage = System.mcml.PageCtrl:new({url = "script/apps/Aries/NPCs/Doctor/30085_RainbowFlowerGame_status.html"});
			RainbowFlowerGame.statusPage:Create("RainbowFlowerGame_status", nil, "_rt", -260, 100, 250, 150, true);
		end
	end
	
	do return end
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30085);
	if(memory.CountPetal == nil) then
		-- destroy
		ParaUI.Destroy("30085_RainbowFlowerPetal_1");
		ParaUI.Destroy("30085_RainbowFlowerPetal_2");
		ParaUI.Destroy("30085_RainbowFlowerPetal_3");
		ParaUI.Destroy("30085_RainbowFlowerPetal_4");
		ParaUI.Destroy("30085_RainbowFlowerPetal_5");
		ParaUI.Destroy("30085_RainbowFlowerPetal_6");
		ParaUI.Destroy("30085_RainbowFlowerPetal_7");
	elseif(memory.CountPetal <= 7) then
		-- create if not exist
		local _petal_1 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_1");
		if(_petal_1:IsValid() == false) then
			_petal_1 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_1", "_ctb", -300, -100, 64, 64);
			_petal_1:AttachToRoot();
		end
		local _petal_2 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_2");
		if(_petal_2:IsValid() == false) then
			_petal_2 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_2", "_ctb", -200, -100, 64, 64);
			_petal_2:AttachToRoot();
		end
		local _petal_3 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_3");
		if(_petal_3:IsValid() == false) then
			_petal_3 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_3", "_ctb", -100, -100, 64, 64);
			_petal_3:AttachToRoot();
		end
		local _petal_4 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_4");
		if(_petal_4:IsValid() == false) then
			_petal_4 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_4", "_ctb", 0, -100, 64, 64);
			_petal_4:AttachToRoot();
		end
		local _petal_5 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_5");
		if(_petal_5:IsValid() == false) then
			_petal_5 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_5", "_ctb", 100, -100, 64, 64);
			_petal_5:AttachToRoot();
		end
		local _petal_6 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_6");
		if(_petal_6:IsValid() == false) then
			_petal_6 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_6", "_ctb", 200, -100, 64, 64);
			_petal_6:AttachToRoot();
		end
		local _petal_7 = ParaUI.GetUIObject("30085_RainbowFlowerPetal_7");
		if(_petal_7:IsValid() == false) then
			_petal_7 = ParaUI.CreateUIObject("container", "30085_RainbowFlowerPetal_7", "_ctb", 300, -100, 64, 64);
			_petal_7.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
			_petal_7:AttachToRoot();
		end
		
		if(memory.CountPetal < 7) then
			_petal_7.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_7.background = RainbowFlowerGame.Petal_models[7]..".png";
		end
		if(memory.CountPetal < 6) then
			_petal_6.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_6.background = RainbowFlowerGame.Petal_models[6]..".png";
		end
		if(memory.CountPetal < 5) then
			_petal_5.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_5.background = RainbowFlowerGame.Petal_models[5]..".png";
		end
		if(memory.CountPetal < 4) then
			_petal_4.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_4.background = RainbowFlowerGame.Petal_models[4]..".png";
		end
		if(memory.CountPetal < 3) then
			_petal_3.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_3.background = RainbowFlowerGame.Petal_models[3]..".png";
		end
		if(memory.CountPetal < 2) then
			_petal_2.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_2.background = RainbowFlowerGame.Petal_models[2]..".png";
		end
		if(memory.CountPetal < 1) then
			_petal_1.background = "model/06props/v5/03quest/ColorfulFlower/ColorfulFlower_empty.png";
		else
			_petal_1.background = RainbowFlowerGame.Petal_models[1]..".png";
		end
	end
end