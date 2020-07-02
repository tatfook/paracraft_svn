--[[ MysteryAcinusTree AI
Author: WangTian
Date: 2009/7/21
Desc: MysteryAcinusTree AI

script/apps/Aries/NPCs/Police/30004_MysteryAcinusTree_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "MysteryAcinusTree_AI";
local MysteryAcinusTree_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.MysteryAcinusTree_AI");

local BOLD = headon_speech.GetBoldTextMCML;

-- Mystery acinus tree AI framemove
function MysteryAcinusTree_AI.On_FrameMove()
	-- 0.3s interval

	local mysteryAcinusTree = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(mysteryAcinusTree:IsValid() == true and player:IsValid() == true) then 
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30004);
		
		local dist = mysteryAcinusTree:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			-- say some gossip when enter 5 meter range
			headon_speech.Speek(mysteryAcinusTree.name, BOLD("我是一棵神奇的浆果树，能结出各种颜色的浆果！"), 3, true);
		end
		memory.dist = dist;
		
		-- mystery acinus tree states:
		--		0: sick tree, haven't assign prefered item
		--		1: sick tree, have assign prefered item
		--		2: healthy tree
		memory.state = memory.state or 0; -- default state 0
		memory.prefereditem_gsid = memory.prefereditem_gsid or nil;
		
		local prefereditem_avaiable = {
			{gsid = 9501,
			 name = "水球"},
			{gsid = 9502,
			 name = "果冻"},
			{gsid = 9503,
			 name = "炮竹"},
		};
		
		if(memory.state == 0) then
			-- doing nothing
		elseif(memory.state == 1) then
			-- check throw items
			-- hook into the throwable item hit if not hooked before
			if(memory.throweditem) then
				local gsid = memory.throweditem;
				memory.throweditem = nil;
				-- quit if the hit point is 3 meters away
				local x_p, y_p, z_p = mysteryAcinusTree:GetPosition();
				if(memory.hitposition_x and memory.hitposition_y and memory.hitposition_z) then
					local distSquare = math.pow((x_p - memory.hitposition_x), 2) + 
									   math.pow((y_p - memory.hitposition_y), 2) + 
									   math.pow((z_p - memory.hitposition_z), 2);
					if(distSquare > 9) then
						return;
					end
				end
				if(gsid == 9501) then
					if(memory.prefereditem_gsid == 9501) then
						local i = math.random(0, 200);
						if(i <= 100) then
							headon_speech.Speek(mysteryAcinusTree.name, BOLD("我还是口渴；还想喝水!"), 3, true);
						elseif(i <= 200) then
							--headon_speech.Speek(mysteryAcinusTree.name, BOLD("我喝好了，你真是一个好心的小哈奇，我的果子送给你吧！"), 3, true);
							memory.state = 2;
							MysteryAcinusTree_AI.BecomeHealthy(mysteryAcinusTree, "我喝好了");
						end
					elseif(memory.prefereditem_gsid == 9502) then
						headon_speech.Speek(mysteryAcinusTree.name, BOLD("我现在不想喝水，我想吃果冻!"), 3, true);
					elseif(memory.prefereditem_gsid == 9503) then
						headon_speech.Speek(mysteryAcinusTree.name, BOLD("我现在不想喝水，我想玩炮竹!"), 3, true);
					end
				elseif(gsid == 9502) then
					if(memory.prefereditem_gsid == 9501) then
						headon_speech.Speek(mysteryAcinusTree.name, BOLD("我现在不想吃果冻，我想喝水!"), 3, true);
					elseif(memory.prefereditem_gsid == 9502) then
						local i = math.random(0, 200);
						if(i <= 100) then
							headon_speech.Speek(mysteryAcinusTree.name, BOLD("我还是肚子饿；还想吃果冻!"), 3, true);
						elseif(i <= 200) then
							--headon_speech.Speek(mysteryAcinusTree.name, BOLD("我吃饱了，你真是一个好心的小哈奇，我的果子送给你吧！"), 3, true);
							memory.state = 2;
							MysteryAcinusTree_AI.BecomeHealthy(mysteryAcinusTree, "我吃饱了");
						end
					elseif(memory.prefereditem_gsid == 9503) then
						headon_speech.Speek(mysteryAcinusTree.name, BOLD("我现在不想吃果冻，我想玩炮竹!"), 3, true);
					end
				elseif(gsid == 9503) then
					if(memory.prefereditem_gsid == 9501) then
						headon_speech.Speek(mysteryAcinusTree.name, BOLD("我现在不想玩炮竹，我想喝水!"), 3, true);
					elseif(memory.prefereditem_gsid == 9502) then
						headon_speech.Speek(mysteryAcinusTree.name, BOLD("我现在不想玩炮竹，我想吃果冻!"), 3, true);
					elseif(memory.prefereditem_gsid == 9503) then
						local i = math.random(0, 200);
						if(i <= 100) then
							headon_speech.Speek(mysteryAcinusTree.name, BOLD("我还是没精神；还想玩炮竹!"), 3, true);
						elseif(i <= 200) then
							--headon_speech.Speek(mysteryAcinusTree.name, BOLD("我玩够了，你真是一个好心的小哈奇，我的果子送给你吧！"), 3, true);
							memory.state = 2;
							MysteryAcinusTree_AI.BecomeHealthy(mysteryAcinusTree, "我玩够了");
						end
					end
				end
			end
		elseif(memory.state == 2) then
			-- unhook into the throwable item hit
			-- 3 minutes to respawn the MysteryAcinusTree
			if((ParaGlobal.GetGameTime() - memory.healthytime) > 180000) then
				memory.state = 0;
				MyCompany.Aries.Quest.NPCs.MysteryAcinusTree.BecomeSick();
			end
		end
	end
end

function MysteryAcinusTree_AI.BecomeHealthy(mysteryAcinusTree, pretext)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30004);
	memory.healthytime = ParaGlobal.GetGameTime();
	if(mysteryAcinusTree and mysteryAcinusTree:IsValid() == true) then
		MyCompany.Aries.Quest.NPCs.MysteryAcinusTree.BecomeHealthy(pretext);
	end
end