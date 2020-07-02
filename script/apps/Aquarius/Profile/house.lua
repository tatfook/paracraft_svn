--[[
Title: code behind for page house.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/house.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local housePage = {};
commonlib.setfield("MyCompany.Aquarius.housePage", housePage)

---------------------------------
-- page event handlers
---------------------------------

-- template db table
housePage.dsHouses = {
	{name="大冲村", type="居民楼", size="66 m^2", price="E 500,000", location="公共世界住宅A区", rareness="1", preview="model/01building/V3/01house/bieshu/bieshu01.x.png" },
	{name="科技园小区", type="公寓", size="128 m^2", price="E 200,000", location="公共世界住宅A区", rareness="2", preview="model/01building/V3/01house/bieshu01/bieshu2.x.png" },
	{name="高新区", type="商务会所", size="200 m^2", price="E 5,000,000", location="公共世界住宅D区", rareness="3", preview="model/01building/V3/01house/bieshu/bieshu01.x.png" },
	{name="英伦名苑", type="豪宅", size="500 m^2", price="E 10,000,000", location="公共世界住宅B区", rareness="3", preview="model/01building/V3/01house/bieshu/bieshu01.x.png" },
	{name="城市山谷", type="别墅", size="1000 m^2", price="E 25,000,000", location="公共世界住宅C区", rareness="5", preview="model/01building/V3/01house/bieshu01/bieshu2.x.png" },
};

-- datasource function for pe:gridview
function housePage.DS_Func(index)
	if(index == nil) then
		return #(housePage.dsHouses);
	else
		return housePage.dsHouses[index];
	end
end

-- init
function housePage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end
function housePage.OnVisitHomeZone(uid)
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneView.lua");
	Map3DSystem.App.HomeZoneView.Start(uid)
end
function housePage.OnEditHomeZone()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneEditor.lua");
	Map3DSystem.App.HomeZoneEditor.Start()
	Map3DSystem.App.HomeZoneEditor.Load()
end
