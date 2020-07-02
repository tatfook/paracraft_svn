--[[
Title: CommandSelect
Author(s): LiXizhi
Date: 2014/7/5
Desc: selection related command
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandSelect.lua");
-------------------------------------------------------
]]
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local block = commonlib.gettable("MyCompany.Aries.Game.block")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");


Commands["select"] = {
	name="select", 
	quick_ref="/select [-add|clear|below|all|pivot|origin|move] x y z [(dx dy dz)]", 
	desc=[[select blocks in a region.
-- select all blocks in AABB region
/select x y z [(dx dy dz)]
-- select all block below the current player's feet
/select -below [radius] [height]
-- add a single block to current selection. one needs to make a selection first. 
/select -add x y z
-- clear selection
/select -clear
-- select all blocks connected with current selection but not below current selection. 
/select -all x y z [(dx dy dz)]
-- set pivot point, similar to origin, but also set position
/select -pivot x y z
-- origin is used in exporting
/select -origin x y z
-- move to a new position
/select -move x y z

]] , 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local options;
		options, cmd_text = CmdParser.ParseOptions(cmd_text);
		
		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/SelectBlocksTask.lua");
		local SelectBlocks = commonlib.gettable("MyCompany.Aries.Game.Tasks.SelectBlocks");

		if(options.below) then
			local radius, height = cmd_text:match("%s*(%d*)%s*(%d*)$");

			-- remove all terrain where the player stand
			radius = tonumber(radius) or 10;
			height = tonumber(height) or 50;

			local cx, cy, cz = ParaScene.GetPlayer():GetPosition();
			local bx, by, bz = BlockEngine:block(cx,cy+0.1,cz);

			local task = SelectBlocks:new({blockX = bx-radius,blockY = by-1, blockZ = bz-radius})
			task:Run();
			task.ExtendAABB(bx+radius, by-1-height, bz+radius);
		elseif(options.clear) then
			SelectBlocks.CancelSelection();
		elseif(options.pivot or options.origin) then
			local x, y, z;
			x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
			if(x and y and z) then
				local instance = SelectBlocks.GetCurrentInstance();
				if(instance) then
					instance:SetPivotPoint({x,y,z});
					if(not options.origin) then
						instance:SetPosition({x,y,z});
					end
				end
			end
		elseif(options.move) then
			local x, y, z;
			x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
			if(x and y and z) then
				local instance = SelectBlocks.GetCurrentInstance();
				if(instance) then
					instance:SetPosition({x,y,z});
				end
			end
		else
			local x, y, z, dx, dy, dz;
			x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
			if(x) then
				dx, dy, dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);
				
				if(options.add) then
					SelectBlocks.ToggleBlockSelection(x, y, z);
				else
					-- new selection
					local task = SelectBlocks:new({blockX = x,blockY = y, blockZ = z})
					task:Run();
					if(dx and dy and dz) then
						task.ExtendAABB(x+dx, y+dy, z+dz, true);
					else
						task:RefreshImediately();
					end
					if(options.all) then
						task.SelectAll(true);
					end
				end
			elseif(options.all) then
				-- select all blocks connected with current selection but not below current selection. 
				SelectBlocks.SelectAll(true);
			end
		end
	end,
};


Commands["selectobj"] = {
	name="selectobj", 
	quick_ref="/selectobj @category{entity_selectors}", 
	desc=[[select entities by parameters. 
/selectobj		: if no parameters, it will select all objects in current viewport.
/selectobj @e{r=5, type="Railcar"}    :select all railcar entities within 5 meters from the triggering entity
/selectobj @e{r=5, type="Railcar", count=1}    :select the closet one railcar within 5 meters from the triggering entity
/selectobj @e{r=5, name="abc"}    :select entity whose name is abc
/selectobj @e{r=5, nontype="Player"}    :select entities that is not a player within 5 meters from the triggering entity
/selectobj @p{r=5, }    :select all players within 5 meters from the triggering entity
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/ObjectSelectPage.lua");
		local ObjectSelectPage = commonlib.gettable("MyCompany.Aries.Game.GUI.ObjectSelectPage");
			
		if(cmd_text == "") then
			ObjectSelectPage.SelectByScreenRect();
		else
			local entities;
			entities, cmd_text = CmdParser.ParseEntities(cmd_text, fromEntity);
			if(entities and #entities>0) then
				ObjectSelectPage.SelectEntities(entities);	
			end
		end
	end,
};
