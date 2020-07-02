--[[ CrownSnake AI
Author: WangTian
Date: 2009/8/25
Desc: CrownSnake AI

script/apps/Aries/NPCs/FollowPets/30203_CrownSnake_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "CrownSnake_AI";
local CrownSnake_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.CrownSnake_AI");
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
local FleePosSequence = {
		{ 20071.41015625, -0.29926007986069, 20022.16015625 },
		{ 20068.4375, -2.4218561649323, 20013.5390625 },
		{ 20078.583984375, -1.0234016180038, 20008.857421875 },
		{ 20079.20703125, -1.2362689971924, 20003.875 },
		{ 20077.37890625, -1.8751327991486, 19997.88671875 },
		{ 20080.8203125, -2.3309619426727, 19990.54296875 },
		{ 20084.8359375, -3.508837223053, 19986.32421875 },
		{ 20085.1328125, -1.3127452135086, 19996.78125 },
		{ 20091.25390625, -1.2095713615417, 19994.18359375 },
		{ 20098.69140625, -1.2708088159561, 19990.90234375 },
		{ 20095.76953125, -2.2732348442078, 19986.0859375 },
		{ 20109.00390625, -2.3164446353912, 19984.44921875 },
		{ 20107.2734375, -0.28544536232948, 19991.12109375 },
		{ 20100.64453125, -0.68715769052505, 19992.8671875 },
		{ 20098.72265625, 1.0187302827835, 20001.00390625 },
		{ 20089.5859375, -0.35399404168129, 20003.1953125 },
		{ 20092.31640625, 0.85527223348618, 20008.1015625 },
		{ 20087.453125, 0.2943380177021, 20011.4140625 },
		{ 20082.3671875, -0.78790616989136, 20006.96484375 },
		{ 20077.77734375, -1.0384353399277, 20010.08203125 },
		{ 20087.734375, 1.891032576561, 20022.265625 },
		{ 20094.078125, 2.7885053157806, 20013.33203125 },
		{ 20086.59375, 0.21808791160583, 20011.9609375 },
		{ 20082.47265625, 0.056161224842072, 20016.46875 },
		{ 20071.375, -0.48133173584938, 20019.55078125 },
		{ 20066.4296875, -2.913920879364, 20017.615234375 },
	};

-- CrownSnake_AI framemove
function CrownSnake_AI.On_FrameMove()
	local memory = NPCAIMemory.GetMemory(30203);
	
	local snake = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	snake:SetDynamicField("cursor", "Texture/Aries/Cursor/Hammer_32bits.png");
	
	if(snake:IsValid() == true and player:IsValid() == true) then
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(snake);
		if(instance == 2) then
			snake:SetDynamicField("cursor", "Texture/Aries/Cursor/Hammer_32bits.png");
			local snake1 = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
			if(snake1 and snake1:IsValid() == true) then
				local sx, sy, sz = snake1:GetPosition();
				if(memory.isFlee == true) then
					snake:SetPosition(sx, sy, sz);
					snake:SetScale(4);
				else
					if(memory.isStunned == true) then
						local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
						local stun = effectGraph:GetObject("30203_CrownSnake_Stun");
						if(not stun or stun:IsValid() == false) then
							local asset = ParaAsset.LoadParaX("", "character/v5/09effect/Dizzy/Dizzy.x");
							stun = ParaScene.CreateCharacter("30203_CrownSnake_Stun", asset , "", true, 1.0, 0, 1.0);
							if(stun and stun:IsValid() == true) then
								effectGraph:AddChild(stun);
							end
						end
						local sx, sy, sz = snake1:GetPosition();
						stun:SetPosition(sx, sy + 1.0, sz);
						snake:SetPosition(sx, sy - 10000, sz);
					else
						local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
						effectGraph:DestroyObject("30203_CrownSnake_Stun");
						snake:SetPosition(sx, sy - 10000, sz);
					end
				end
			else
				local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
				effectGraph:DestroyObject("30203_CrownSnake_Stun");
				snake:SetPosition(0, -10000, 0);
			end
			return;
		elseif(instance == 1) then
			-- super high snake to step over everything ahead
			snake:SetPhysicsHeight(100);
		end
		-- call the on framemove function at 1/10 rate
		memory.count = memory.count or 0;
		if(memory.count < 10) then
			memory.count = memory.count + 1;
			return;
		else
			memory.count = 0;
		end
		
		local dx, dy, dz = snake:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = snake:DistanceTo(player);
		if(memory.dist and memory.dist > 3 and dist <= 3) then
			-- say some gossip when enter 3 meter range
			if(memory.isStunned == true) then
				headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("哎呀，我好晕啊~~ "), 3, true);
			else
				headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("我是皇冠蛇，你想捉住我吗，我的皮滑溜着呢。"), 3, true);
			end
			if(memory.isFlee == nil and memory.isStunned ~= true) then
				---- start flee
				--MyCompany.Aries.Quest.NPCs.CrownSnake.BeginFlee();
			end
		elseif(memory.dist and memory.dist > 30) then
			-- reset the snake
			MyCompany.Aries.Quest.NPCs.CrownSnake.EndFlee();
		end
		memory.dist = dist;
		
		--local x, y, z;
		--local pt = ParaScene.MousePick(70, "point");
		--if(pt:IsValid())then
			--x, y, z = pt:GetPosition();
		--end
		--if(y == nil and x ~= nil and z ~= nil) then
			--y = ParaTerrain.GetElevation(x, z);
		--end
		--
		--local distToCursorSquare = 10000;
		--if(x ~= nil and y ~= nil and z ~= nil) then
			--distToCursorSquare = (x - dx)*(x - dx) + (y - dy)*(y - dy) + (z - dz)*(z - dz);
		--end
		--if(distToCursorSquare < 10) then
			--snake:SetDynamicField("cursor", "Texture/Aries/Cursor/Hammer_32bits.png");
		--else
			--snake:SetDynamicField("cursor", nil);
		--end
		
		-- snake is been deleted from the scene, saying the last word
		if(memory.leaving == true) then
			return;
		end
		
		if(memory.isFlee == true) then
			
			local PosCount = #(FleePosSequence);
			
			local snakeChar = snake:ToCharacter();
			local nTime = ParaGlobal.GetGameTime();
			
			if(memory.TargetFleePosIndex == nil) then
				memory.TargetFleePosIndex = 1;
				local s = snakeChar:GetSeqController();
				local x, z;
				x = FleePosSequence[memory.TargetFleePosIndex][1] - dx;
				z = FleePosSequence[memory.TargetFleePosIndex][3] - dz;
				--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
				snakeChar:Stop();
				s:WalkTo(x, 0, z);
			end
			
			-- changes direction at the end of every move
			if(math.abs(dx - FleePosSequence[memory.TargetFleePosIndex][1]) < 0.01 
				and math.abs(dz - FleePosSequence[memory.TargetFleePosIndex][3]) < 0.01) then
				-- select the next position is the sequence
				memory.TargetFleePosIndex = memory.TargetFleePosIndex + 1;
				commonlib.echo(memory.TargetFleePosIndex)
				if(memory.TargetFleePosIndex > PosCount) then
					memory.TargetFleePosIndex = 1;
				end
				local s = snakeChar:GetSeqController();
				local x, z;
				x = FleePosSequence[memory.TargetFleePosIndex][1] - dx;
				z = FleePosSequence[memory.TargetFleePosIndex][3] - dz;
				--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
				snakeChar:Stop();
				s:WalkTo(x, 0, z);
			else
				-- backup function that could walk to the next position to eliminate the still snake bug
				if(memory.lastFleePosition and math.abs(memory.lastFleePosition[1] - dx) < 0.01 and math.abs(memory.lastFleePosition[3] - dz) < 0.01 ) then
					if(true) then
						log("ERROR: enter backup flee function, dump memory:\n")
						commonlib.echo({dx, FleePosSequence[memory.TargetFleePosIndex][1]});
						commonlib.echo({dz, FleePosSequence[memory.TargetFleePosIndex][3]});
						commonlib.echo(memory)
					end
					local s = snakeChar:GetSeqController();
					local x, z;
					x = FleePosSequence[memory.TargetFleePosIndex][1] - dx;
					z = FleePosSequence[memory.TargetFleePosIndex][3] - dz;
					snakeChar:Stop();
					s:WalkTo(x, 0, z);
				end
			end
			-- record the last flee position
			memory.lastFleePosition = {dx, dy, dz};
		else
			-- normal random walk
			local radius = 5;
			
			if(memory.bornPos == nil) then
				memory.bornPos = {dx, dy, dz};
			end
			
			if(memory.LastWalkTime == nil) then
				memory.LastWalkTime = 0;
			end
			
			local snakeChar = snake:ToCharacter();
			local nTime = ParaGlobal.GetGameTime();
			
			-- changes direction every [3, 5] seconds.
			if((nTime - memory.LastWalkTime) > 1000 * math.random(3, 5)) then
				-- select a new target randomly
				local s = snakeChar:GetSeqController();
				x = (math.random()*2-1)*radius + memory.bornPos[1] - dx;
				z = (math.random()*2-1)*radius + memory.bornPos[3] - dz;
				--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
				snakeChar:Stop();
				s:WalkTo(x, 0, z);
				-- save to memory
				memory.LastWalkTime = nTime;
			end
		end
	end
end