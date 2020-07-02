--[[
Title: For time rewinding shader effect
Author(s): LiXizhi
Date: 2010/1/9
Desc: It is based on light scattering effect. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Movie/TimeEffect.lua");
MyCompany.Aries.Movie.TimeEffect:StartEffect();
MyCompany.Aries.Movie.TimeEffect:StopEffect();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/PostProcessor.lua");

local TimeEffect = commonlib.gettable("MyCompany.Aries.Movie.TimeEffect")

-- start the effect. 
function TimeEffect:StartEffect()
	local ps_version = MyCompany.Aries.GetShaderVersion();
	if(ps_version >= 2) then
		-- pixel shader version 
		self.effect = self.effect or ParaAsset.LoadEffectFile("LightScattering","script/apps/Aries/Movie/TimeEffect.fxo");
		commonlib.ps.EnablePostProcessing(true, function(ps_scene)
			TimeEffect:DoPostProccesing(ps_scene);
		end);
	end
end

-- stop the effect if any. 
function TimeEffect:StopEffect()
	local ps_version = MyCompany.Aries.GetShaderVersion();
	if(ps_version >= 2) then
		commonlib.ps.EnablePostProcessing(false);
	end	
end

-- this function is called every frame move if post processing is enabled. 
function TimeEffect:DoPostProccesing(ps_scene)
	local effect = self.effect;
	
	if(effect:Begin()) then
		-- 0 stands for S0_POS_TEX0,  all data in stream 0: position and tex0
		ParaEngine.SetVertexDeclaration(0); 
	
		-- save the current render target
		local old_rt = ParaEngine.GetRenderTarget();
		
		-- create/get a temp render target. 
		local _downSampleRT = ParaAsset.LoadTexture("_downSampleRT", "_downSampleRT", 0); 
		_downSampleRT:SetSize(512, 512);
		
		-- create/get a temp render target. 
		local _lumRT = ParaAsset.LoadTexture("_lumRT", "_lumRT", 0); 
		_lumRT:SetSize(512, 512);
		
		----------------------- down sample pass ----------------
		-- copy content from one surface to another
		ParaEngine.StretchRect(old_rt, _downSampleRT);
		
		----------------------- create lum texture-----------------------
		-- set a new render target
		ParaEngine.SetRenderTarget(_lumRT);
		local params = effect:GetParamBlock();
		
		effect:BeginPass(0);
			params:SetTextureObj(0, _downSampleRT);
			effect:CommitChanges();
			ParaEngine.DrawQuad();
		effect:EndPass();
		
		-----------------------compose lum texture with original texture --------------
		ParaEngine.SetRenderTarget(old_rt);
		effect:BeginPass(1);
			params:SetTextureObj(1, _lumRT);
			effect:CommitChanges();
			ParaEngine.DrawQuad();
		effect:EndPass();
		
		effect:End();
	end
end