--[[
Title: BlockModel
Author(s): LiXizhi
Date: 2015/5/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/blocks/BlockModel.lua");
local block = commonlib.gettable("MyCompany.Aries.Game.blocks.BlockModel")
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Direction.lua");
local Direction = commonlib.gettable("MyCompany.Aries.Game.Common.Direction")
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local block = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.blocks.BlockEntityBase"), commonlib.gettable("MyCompany.Aries.Game.blocks.BlockModel"));

-- register
block_types.RegisterBlockClass("BlockModel", block);

function block:ctor()
end


function block:Init()
end

-- virtual: Checks to see if its valid to put this block at the specified coordinates. Args: world, x, y, z
function block:canPlaceBlockAt(x,y,z)
	return true;
end

function block:GetMetaDataFromEnv(blockX, blockY, blockZ, side, side_region, camx,camy,camz, lookat_x,lookat_y,lookat_z)
	return 0;
end

function block:RotateBlockEnityData(entityData, angle, axis)
	if(not axis or axis == "y") then
		if(entityData and entityData.attr) then
			local lastFacing = entityData.attr.facing or 0;
			if(lastFacing) then
				facing = lastFacing + angle;
				if(facing < 0) then
					facing = facing + 6.28;
				end
				facing = (math.floor(facing/1.57+0.5) % 4) * 1.57;

				entityData = commonlib.copy(entityData);
				entityData.attr.facing = facing;
			end
		end
	else
		-- TODO: other axis
	end
	
	return entityData;
end

function block:getMobilityFlag()
	return -1;
end