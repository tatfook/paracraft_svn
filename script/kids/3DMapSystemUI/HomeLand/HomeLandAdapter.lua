--[[
Title: HomeLandAdapter
Author(s): Leio
Date: 2010/04/19
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandAdapter.lua");
------------------------------------------------------------
]]
local HomeLandAdapter = {
	
}
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandAdapter",HomeLandAdapter);
--����һ����������� �����ض�����Դ�ļ�
function HomeLandAdapter.GetCandyPlantAssetFile(bean)
	if(not bean)then return end
	local maps = {
		{}
	}
	local id = bean.id or 0;
	local r = math.mod(id,4);
	
end