NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");

if(not Map3DApp.Global)then Map3DApp.Global = {};end
if(not Map3DApp.Global.Material) then Map3DApp.Global.Material = {};end

Map3DApp.Global.Material.meterials = {};

Map3DApp.Global.Material.OceanWaterTime = 0;


function Map3DApp.Global.Material.GetOceanWater()
	local effect = ParaAsset.GetEffectFile("oceanWater");
	if(effect:IsValid() == false)then
		effect = ParaAsset.LoadEffectFile("oceanWater","script/kids/3DMapSystemUI/Map/Shader/ocean_water.fx");
		effect = ParaAsset.GetEffectFile("oceanWater");

		effect:SetHandle(1002);
		local params = effect:GetParamBlock();
		params:SetVector3("sun_color", 1,1,0.3);
		params:SetVector3("sun_vec", 0,1,0.6);
		params:SetTexture(0, "model/map3D/texture/WaterBumpMap.dds");
		params:SetTexture(1, "model/map3D/texture/waterReflectMap.dds");
		params:SetFloat("time", 0);
		params:SetVector3("shallowWaterColor", 0.64,0.8,0.96);
		params:SetVector3("deepWaterColor", 0.08,0.36,0.6);
		params:SetFloat("shininess", 20);
		params:SetVector2("waveDir", 1, 0);
		params:SetVector3("texCoordOffset", 1, 0, 0);
		
		local timerID = Map3DApp.Timer.GetNewTimerID();
		NPL.SetTimer(timerID,0.01,";Map3DApp.Global.Material.OceanWaterOnTimer()");
	end
	return effect,1002;
end


function Map3DApp.Global.Material.OceanWaterOnTimer()
	Map3DApp.Global.Material.OceanWaterTime = Map3DApp.Global.Material.OceanWaterTime + 0.02;
	local effect = ParaAsset.GetEffectFile("oceanWater");
	if(effect ~= nil)then
		local params = effect:GetParamBlock();
		params:SetFloat("time",Map3DApp.Global.Material.OceanWaterTime);
	end
end


function Map3DApp.Global.Material.GetMapRoad()
	local effect = ParaAsset.GetEffectFile("mapRoad");
	if(effect:IsValid() == false)then
		effect = ParaAsset.LoadEffectFile("mapRoad","script/kids/3DMapSystemUI/Map/Shader/map_road.fx");
		effect = ParaAsset.GetEffectFile("mapRoad");
		effect:SetHandle(1003);
	end
	return effect,1003;
end


function Map3DApp.Global.Material.GetSimpleTextured()
	local effect = ParaAsset.GetEffectFile("simpleTextured");
	if(effect:IsValid() == false)then
		effect = ParaAsset.LoadEffectFile("simpleTextured","script/kids/3DMapSystemUI/Map/Shader/simple_texture.fx");
		effect = ParaAsset.GetEffectFile("simpleTextured");
		effect:SetHandle(1004);
	end
	return effect,1004;
end