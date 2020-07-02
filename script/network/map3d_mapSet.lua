
--[[

*****this file is deprecated******



NPL.load("(gl)scirpt/network/map3D.lua");
local mapSet = {
	name = "mapSet",
	mapFilePath = nil,
	fileFMT = "jpg";
	files = {},
	textures = {};
	defaultTexture = "Texture/worldMap/default.jpg";
	isInited = false;
}
MapSystem.mapSet = mapSet;


function mapSet:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

--x,y is the texture index
function mapSet:GetMapPath(indexX,indexY,level)
	if(not self.files[level])then
		self.files[level] ={};
	end
	
	if(not self.files[level][indexY])then
		self.files[level][indexY] = {};
	end
	
	if(not self.files[level][indexY][indexX])then
		local filename = self.mapFilePath.."/"..level.."_"..indexY.."_"..indexX.."."..self.fileFMT;
		if( ParaIO.DoesFileExist(filename,true))then
			self.files[level][indexY][indexX] = filename;
		else
			self.files[level][indexY][indexX] = self.defaultTexture;
		end
		--local filename = self.mapFilePath.."/"..self.activeLayer.."_"..indexY.."_"..indexX.."."..self.fileFMT;
		--local i = 0;
		--local tempX = indexX;
		--local tempY = indexY;
		--while( ParaIO.DoseFileExist(filename,true))do
			--i = i+1;
			--tempX = math.floor((tempX + 1) / 2);
			--tempY = math.floor((tempY + 1)/2);
			--if( self.activeLayer - i < 0 and self.defaultTexture ~= nil)then
				--filename = self.defaultTexture;
				--break;
			--else
				--filename = nil;
				--break
			--end
			--filename = self.mapFilePath.."/"..self.activeLayer-i.."_"..tempX.."_"..tempY.."."..self.fileFMT;
		--end
		--self.files[self.activeLayer][indexY][indexX] = filename;
	end
	
	return self.files[level][indexY][indexX]; 
end

--x,y,viewRegion are in map coordinate
--all values must in [0,1]
--x,y are the top left point of the view region
--viewRegion is the width of view region
function mapSet:GetMaps(x,y,viewRegion,level)
	--log( string.format(" view para:%f,%f, %f, %f\n",x,y,viewRegion,level));
	local texWidth = 1/math.pow(2,level-1);
	local textures = {};
	local indexX,indexY;
	
	local texCount = 1;
	local dy = -math.mod(y,texWidth);
	
	while(dy < viewRegion and dy < 1)do
		local tempX = x;
		local dx = -math.mod(x,texWidth);
		while( dx < viewRegion and dx < 1)do
			indexX = math.floor( tempX / texWidth) + 1;
			indexY = math.floor( y / texWidth) + 1;
			textures[texCount] = ParaAsset.LoadTexture("",self:GetMapPath(indexX,indexY,level),1);
			tempX = tempX + texWidth;
			dx = dx + texWidth;
			texCount = texCount +  1;
			--log(string.format("index: %s,%s  dx,dy:%f,%f\n",indexX,indexY,dx,dy));
		end
		y = y + texWidth;
		dy = dy + texWidth;
	end
	
	--textures[1] = ParaAsset.LoadTexture("","Texture/worldMap/wow/2_1_1.jpg",1);
	--textures[2] = ParaAsset.LoadTexture("","Texture/worldMap/wow/2_1_2.jpg",1);
	--textures[3] = ParaAsset.LoadTexture("","Texture/worldMap/wow/2_2_1.jpg",1);
	--textures[4] = ParaAsset.LoadTexture("","Texture/worldMap/wow/2_2_2.jpg",1);
	return textures;
end
--]]