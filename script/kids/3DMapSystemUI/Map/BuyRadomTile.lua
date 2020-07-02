
--NPL.load("(gl)script/kids/3DMapSystemUI/Map/BuyRadomTile.lua");

local BuyRandomTileCmd = {
	id = 0,
	sessionkey = nil,
	centerX = 0,
	centerY = 0,
	tryCount = 0,
	onBuyTileDoneCallback = nil,
	subscriber = nil,
}
Map3DApp.BuyRandomTileCmd = BuyRandomTileCmd;


function BuyRandomTileCmd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function BuyRandomTileCmd:Execute()
	if(self.sessionkey == nil or self.sessionkey == "")then
		self:OnCmdDone(0,false);
		return;
	end

	local radius = 0; 
	
	if(self.tryCount < 1)then
		--find tile in a 64*642 region
		radius = 0.00048828125;
	elseif(self.tryCount < 2)then
		--64*64
		radius = 0.0009765625;
	elseif(self.tryCount > 2 and self.tryCount < 6)then
		radius = 0.001953125;
	elseif(self.tryCount>5)then
		--out of try limit
		
		return;
	end
	self.tryCount = self.tryCount + 1;
		
	local x ,y = Map3DApp.DataPvd.GetRandomTilePosInRegion(self.centerX,self.centerY,radius);
	--log("get random tile pos:"..tostring(x)..","..tostring(y)..", convernt to integer:"..x/(1/32768)..","..y/(1/32768).."\n");
	Map3DApp.DataPvd.BuytTile(self.sessionkey,nil,x,y,nil,nil,self,"OnGetResult");
end

--private
function BuyRandomTileCmd.OnGetResult(self,tileID,issuccess,errorcode)
	--try several times to but a tile; 
	if(not issuccess and self.tryCount < 6)then
		self:Execute();
	else
		self:OnCmdDone(tileID,issuccess)
	end
end

--private
function BuyRandomTileCmd:OnCmdDone(tileID,issuccess)
	if(self.onBuyTileDoneCallback ~= nil)then
		self.onBuyTileDoneCallback(self.subscriber,tileID,issuccess);
	end
end








