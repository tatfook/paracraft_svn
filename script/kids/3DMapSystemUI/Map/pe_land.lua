--[[
Title: code behind page for pe_land.html
Author(s): Clayman
Date: 2008/6/12
Desc: show land information
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/pe_land.lua");

-- you can specify which land to show with tileID
script/kids/3DMapSystemUI/Map/pe_land.html?tileID=405

pe_land 
-------------------------------------------------------
]]



local landPage = {};
commonlib.setfield("Map3DSystem.App.Map.landPage", landPage)

function landPage.OnInit()
	local self = document:GetPageCtrl();
	
	--record tile id
	self.tileID = self:GetRequestParam("tileID");
	
	
	local node = self:GetNode("downloadPanel");
	if(node)then
		if(self.showWorldDownload)then
			node:SetAttribute("display",nil);
		else
			node:SetAttribute("display","none");
		end
	end
	
	local node = self:GetNode("normalWorld");
	if(node)then
		if(self.showWorldDownload)then
			node:SetAttribute("display","none");
		else
			node:SetAttribute("display",nil);
		end
	end
	
	if(not self:GetNodeValue("IsUpdated"))then
		if(self.tileID and self.tileID ~= "")then
			--query land info
			Map3DApp.DataPvd.GetTileByID(self.tileID,self,landPage.SetData);
		end
	end
	
	--we use this flag to avoid infinite loop when refresh page
	self:SetNodeValue("IsUpdated", false);
end


--private
--this function will be invoked when tileInfo returnd fromweb service
function landPage.SetData(pageInst,tileInfo)
	if(pageInst == nil)then
		return;
	end
	
	local node,value;
	
	--update node values
	node = pageInst:GetNode("landName");
	if(node)then
		value = tileInfo.name or "未命名土地";
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("city");
	if(node)then
		value = tileInfo.cityName or "";
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("owner");
	if(node)then
		value = tileInfo.ownerUserName or "";
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("user");
	if(node)then
		value = tileInfo.username or "";
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("price");
	if(node)then
		if(tileInfo.price)then
			value = tostring(tileInfo.price);
		else
			value = "0";
		end
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("rank");
	if(node)then
		if(tileInfo.rank)then
			value = tostring(tileInfo.rank);
		else
			value ="1";
		end
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("landState");
	if(node)then
		value = Map3DApp.DataPvd.TranslateTileState(tileInfo.tileState)
		node:SetValue(value);
	end
	
	node = pageInst:GetNode("landID");
	if(node)then
		if(tileInfo.id)then
			value = tostring(tileInfo.id);
		else
			value = "0";
		end
		node:SetValue(value);
	end

	--hide world download panel
	pageInst.showWorldDownload = false;
	
	--check if there is a world assigned to this land
	if(tileInfo.worldid == nil or tileInfo.worldid == 0)then
		value = "暂未设置家园世界";
	else
		value = tileInfo.worldName or "未命名世界";
		--query world info
		Map3DApp.DataPvd.GetWorldByID(tileInfo.worldid,pageInst,landPage.SetWorldData);
	end
	
	node = pageInst:GetNode("emptyWorld");
	if(node)then
		node:SetValue(value);
	end
	
	pageInst:SetNodeValue("IsUpdated", true);
	pageInst:Refresh(2);
	Map3DApp.TileInfo.ReleaseTileInfo(tileInfo);
end

--this fucntion will be invoked when world data returnd from web service
function landPage.SetWorldData(pageInst,worldInfo)
	if(worldInfo == nil or worldInfo.id == nil or worldInfo.id == 0)then
		return;
	end

	local src = worldInfo.spaceServer or "";
	if(src == "")then
		return;
	end

	--get source file name
	local __,__,__,fileName = string.find(src,"(.+)/(.+)");
	if(fileName == nil)then
		return;
	end
	--get dest file path
	local dest = "temp/worlds/"..fileName;
	
	--update downloader value
	node = pageInst:GetNode("downloader");
	if(node)then
		node:SetAttribute("src",src);
		node:SetAttribute("dest",dest);
	end
	
	--update world name
	local worldName = worldInfo.name or "";
	node = pageInst:GetNode("worldLable");
	if(node)then
		node:SetValue(worldName);
	end
	
	node = pageInst:GetNode("worldLink");
	if(node)then
		node:SetInnerText(worldName);
	end
	
	--show world download panel
	pageInst.showWorldDownload = true;
	--data update done
	pageInst:SetNodeValue("IsUpdated", true);
	pageInst:Refresh(0.01);
end

function landPage.OnCloseBtn(btnName, values)
	local page = document:GetPageCtrl();
	page:Close();
end