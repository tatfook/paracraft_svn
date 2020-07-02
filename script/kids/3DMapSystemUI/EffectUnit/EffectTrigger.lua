--[[
Title: EffectTrigger
Author(s): Leio Zhang
Date: 2009/3/25
Desc: 
它是一个效果发射器，管理所有的效果播放，它是基于链条性质的，同一种效果(Effect)默认有5个实例(instance),循环触发
比如：
	第一次点击，触发第一个实例
	第二次点击，触发第二个实例
	。。。
	第六次点击，触发第一个实例
	第七次点击，触发第二个实例
	。。。
发射器有三种类型：	
单发型：同一种效果，一次只能触发一次，在播放当中，不能继续触发，直到播放结束
记忆单发型：EffectTrigger自动记录触发的次数，自动依次触发
即时单发型：每一次点击，触发一个instance
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectTrigger.lua");
Map3DSystem.EffectUnit.EffectTrigger.InitLibs();
Map3DSystem.EffectUnit.EffectTrigger.PlayEffect("Raining.effect")
------------------------------------------------------------
--]]
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectManager.lua");
local EffectTrigger = {
	CacheMemoryNum = 5,
	DefaultChainNum_immediate = 5,
	DefaultChainNum = 1,
	DefaultTriggerType = "single",-- "single" or "memory_single" or "immediate_single"
	effects = {}
}
EffectTrigger.Maps = 
{
	["Raining.effect"] = {path = "script/kids/3DMapSystemUI/EffectUnit/OneToNil/Raining.effect.xml"},
	["Test.effect"] = {triggerType = "memory_single", path = "script/kids/3DMapSystemUI/EffectUnit/OneToNil/Test.effect.xml"},
	["Light.effect"] = {triggerType = "immediate_single", chainNum = 2, path = "script/kids/3DMapSystemUI/EffectUnit/OneToNil/Light.effect.xml"},
}
commonlib.setfield("Map3DSystem.EffectUnit.EffectTrigger",EffectTrigger); 
--@param path:一个effect.xml文件
--@param triigerType:触发器的类型，默认为"single"
--@param chainNum:在链条上初始化instance的数量，"immediate_single"默认为5 ,"single" or "memory_single" 为常量：1
function EffectTrigger.PushEffect(path,triggerType,chainNum)
	if(not path)then return end
	triggerType = triggerType or EffectTrigger.DefaultTriggerType;
	if(triggerType == "immediate_single")then
		chainNum = chainNum or EffectTrigger.DefaultChainNum_immediate;
	else
		chainNum = EffectTrigger.DefaultChainNum;
	end	
	local pool = {};
	pool["triggerType"] = triggerType;
	pool["playIndex"] = 0;
	pool["chainNum"] = chainNum;
	pool["memory"] = 0;
	pool["children"] = {};
	local k;
	for k=1,chainNum do
		local name = path.."_"..k
		local effectInstance = Map3DSystem.EffectUnit.EffectManager.CreateEffect(name,path);
		effectInstance.OnStop = Map3DSystem.EffectUnit.EffectTrigger.EffectInstance_Stop;
		pool["children"][k] = effectInstance;
	end
	EffectTrigger.effects[path] = pool;
end

function EffectTrigger.PlayEffect(name)
	local effect_pool = EffectTrigger.effects[name] or EffectTrigger.effects[EffectTrigger.Maps[name]["path"]];
	if(not effect_pool)then return end
	
	local triggerType = effect_pool["triggerType"];
	local playIndex = effect_pool["playIndex"];
	local chainNum = effect_pool["chainNum"];
	local memory = effect_pool["memory"];
	local children = effect_pool["children"];
	local effectInstance = children[1];
	if(triggerType == "single")then
		if(not effectInstance:IsPlaying())then
			effectInstance:Play();
		end
	elseif(triggerType == "memory_single")then
		if(memory < EffectTrigger.CacheMemoryNum)then			
			memory = memory + 1;
		end	
		if(memory == 1)then
			effectInstance:Play();		
		end
		effect_pool["memory"] = memory;
	elseif(triggerType == "immediate_single")then
		if(playIndex >= chainNum)then
			playIndex = 1;			
		else	
			playIndex = playIndex + 1;		
		end
		effectInstance = children[playIndex];
		effect_pool["playIndex"] = playIndex;
		effectInstance:Play();
	end
end
function EffectTrigger.EffectInstance_Stop(effectInstance)
	if(not effectInstance)then return end
	local path = effectInstance:GetPath();
	local effect_pool = EffectTrigger.effects[path];
	if(not effect_pool)then return end
	 
	local triggerType = effect_pool["triggerType"];
	local playIndex = effect_pool["playIndex"];
	local chainNum = effect_pool["chainNum"];
	local memory = effect_pool["memory"];
	local children = effect_pool["children"];
	
	if(triggerType == "memory_single")then
		memory = memory - 1;
		if(memory < 1)then
			memory = 0;
		else						
			effectInstance:Play();
		end
		effect_pool["memory"] = memory;
	end	
end

function EffectTrigger.InitLibs()
	local k,v;
	for k,v in pairs(EffectTrigger.Maps) do
		local path = v.path;
		local triggerType = v.triggerType;
		local chainNum = v.chainNum;
		EffectTrigger.PushEffect(path,triggerType,chainNum);
	end
end