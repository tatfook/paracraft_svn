--[[
Title: EffectManager
Author(s): Leio Zhang
Date: 2009/3/23
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectManager.lua");
local player = ParaScene.GetPlayer()
local x,y,z = player:GetPosition();
local origin = {x = x,y = y,z = z};
local effect = Map3DSystem.EffectUnit.EffectManager.CreateEffect("Rain.effect",
																 "script/kids/3DMapSystemUI/EffectUnit/OneToNil/Raining.effect.xml",
																 origin)
effect:Play();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClipHelper.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectInstance.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsMcmlParser.lua");
NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
NPL.load("(gl)script/ide/Storyboard/StoryboardParser.lua");
local EffectManager = {
	obj_index = 0,
	rootScene = nil,
	effectes = {},
}
commonlib.setfield("Map3DSystem.EffectUnit.EffectManager",EffectManager); 
function EffectManager.CreateScene()
	if(not EffectManager.rootScene)then
		EffectManager.rootScene = CommonCtrl.Storyboard.Storyboard.GetScene();
	end
end
-- create or get an effect
--@param name:a nickname of an effect,it must be unique
--@param path:where an effect.xml is placed
-- @param origin: 效果播放的起始位置
function EffectManager.CreateEffect(name,path,origin)
	if(not name or not path)then return end
	-- create a root scene
	EffectManager.CreateScene();
	local effect = EffectManager.effectes[name];
	if(not effect)then
		local params,assets,movieclip = EffectManager.Parse(path)
		effect = EffectManager.CreateInstance(params,assets,movieclip);
		effect:SetPath(path)
		EffectManager.effectes[name] = effect;
	end
	if(origin)then
		effect:SetParams("origin",origin);
	end
	return effect;
end
function EffectManager.GetEffect(name)
	return EffectManager.effectes[name];
end
-- create a instance of effect
function EffectManager.CreateInstance(params,assets,movieclip)
	if(not params or not assets or not movieclip)then return end
	-- it is a global value
	EffectManager.obj_index = EffectManager.obj_index + 1;
	local index = EffectManager.obj_index;
	
	NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
	local sprite3D = CommonCtrl.Display.Containers.Sprite3D:new()
	sprite3D:Init();
	local effect = Map3DSystem.EffectUnit.EffectInstance:new();
	local child;
	for __,child in ipairs(assets) do
		local uid = child:GetUID();	
		if(uid ~="sender" or uid ~= "receiver")then			
			local new_uid = uid.."_"..index;
			child:SetUID(new_uid);
			sprite3D:AddChild(child);	
			CommonCtrl.Storyboard.Storyboard.AddHookObj(new_uid,child);
			--replace target name
			movieclip:ReplaceTargetName(uid,new_uid);
			
		end
	end
	-- hide all children
	sprite3D:SetVisible(false);
	EffectManager.rootScene:AddChild(sprite3D);
	
	-- bind a motion to a effect instance
	effect:SetParams("storyboard",movieclip);
	-- put all props into a container
	effect:SetParams("rootcontainer",sprite3D);
	return effect;
end
--@param path:where an effect.xml is placed
function EffectManager.Parse(path)
	if(not path)then return end
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	local params,assets,movieclip;
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//Effect") do
			if(node)then
				params = EffectManager.Parse_Params(node:GetChild("Params"))
				-- 创建资源必须优先于Motion
				assets = EffectManager.Parse_Assets(node:GetChild("Assets"))
				movieclip = EffectManager.Parse_Motion(node:GetChild("Motion"))				
			end
			break;
		end
	end
	return params,assets,movieclip
end

--return a collection of displayobject such as "Sprite3D" "Actor3D"
function EffectManager.Parse_Assets(node)
	if(not node)then return end
	local assets = {};
	local child_node;
	for child_node in node:next() do
		local child = CommonCtrl.Display.Util.ObjectsMcmlParser.create(child_node);
		if(child)then
			table.insert(assets,child);
		end
	end
	return assets;
end
--@param node:it is a mcml node which name is "Motion"
--return a movieclip which can be play by itself
function EffectManager.Parse_Motion(node)
	if(not node)then return end
	local mc;
	local child_node;
	for child_node in node:next() do
		mc = CommonCtrl.Storyboard.StoryboardParser.create(child_node);
		break;
	end
	return mc;
end
--@param node:it is a mcml node which name is "Params"
function EffectManager.Parse_Params(node)
	return {};
end