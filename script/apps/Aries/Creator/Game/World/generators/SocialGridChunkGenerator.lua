--[[
Title: SocialGridChunkGenerator
Author(s): LiXizhi
Date: 2013/8/27, refactored 2015.11.17
Desc: A flat world generator with multiple layers at custom level.
-----------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/World/generators/SocialGridChunkGenerator.lua");
local SocialGridChunkGenerator = commonlib.gettable("MyCompany.Aries.Game.World.Generators.SocialGridChunkGenerator");
ChunkGenerators:Register("flat", SocialGridChunkGenerator);
-----------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/World/ChunkGenerator.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names");

local SocialGridChunkGenerator = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.World.ChunkGenerator"), commonlib.gettable("MyCompany.Aries.Game.World.Generators.SocialGridChunkGenerator"))

function SocialGridChunkGenerator:ctor()
end

-- @param world: WorldManager, if nil, it means a local generator. 
-- @param seed: a number
function SocialGridChunkGenerator:Init(world, seed)
	SocialGridChunkGenerator._super.Init(self, world, seed);
	return self;
end

function SocialGridChunkGenerator:OnExit()
	SocialGridChunkGenerator._super.OnExit(self);
end

-- get params for generating flat terrain
-- one can modify its properties before running custom chunk generator. 
function SocialGridChunkGenerator:GetFlatLayers()
	if(self.flat_layers == nil) then
		self.flat_layers = {
			{y = 0, block_id = names.Bedrock},
			{block_id = names.underground_default},
			{block_id = names.underground_default},
			{block_id = names.underground_shell},
		};
	end
	return self.flat_layers;
end

function SocialGridChunkGenerator:SetFlatLayers(layers)
	self.flat_layers = layers;
end

-- generate flat terrain
function SocialGridChunkGenerator:GenerateFlat(c, x, z)
	local layers = self:GetFlatLayers();
			
	local by = layers[1].y;
	for i = 1, #layers do
		by = by+1;
		local block_id = layers[i].block_id;

		for bx = 0, 15 do
			for bz = 0, 15 do
				c:SetType(bx, by, bz, block_id, false);
			end
		end
	end
end


-- protected virtual funtion:
-- generate chunk for the entire chunk column at x, z
function SocialGridChunkGenerator:GenerateChunkImp(chunk, x, z, external)
	self:GenerateFlat(chunk, x, z);
end

-- virtual function: this is run in worker thread. It should only use data in the provided chunk.
-- if this function returns false, we will use GenerateChunkImp() instead. 
function SocialGridChunkGenerator:GenerateChunkAsyncImp(chunk, x, z)
	return false
end

function SocialGridChunkGenerator:IsSupportAsyncMode()
	return false;
end

-- virtual function: get the class address for sending to worker thread. 
function SocialGridChunkGenerator:GetClassAddress()
	return {
		filename="script/apps/Aries/Creator/Game/World/generators/SocialGridChunkGenerator.lua", 
		classpath="MyCompany.Aries.Game.World.Generators.SocialGridChunkGenerator"
	};
end