--[[
Title: movie tracks
Author(s): Leio Zhang
Date: 2008/9/2
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTracks.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Storyboard.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/CameraTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/LandTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/OceanTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/SkyTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/CaptionTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/ActorTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/SoundTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/BuildingTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/PlantTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/EffectTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/ControlTarget.lua");
----------------------------------------------------------------------
-- mcml_controls
----------------------------------------------------------------------
local mcml_controls = {
}
commonlib.setfield("Map3DSystem.Movie.mcml_controls",mcml_controls);
-----------------------------------
-- Movieclip control
-----------------------------------
local pe_movieclip = {};
Map3DSystem.Movie.mcml_controls.pe_movieclip = pe_movieclip;
function pe_movieclip.create(mcmlNode)
	local mc = CommonCtrl.Animation.Motion.MovieClip:new();
	local childnode;
	for childnode in mcmlNode:next() do		
		local layer = Map3DSystem.Movie.mcml_controls.create(childnode)
		mc:AddLayer(layer);
	end
	mc:UpdateDuration();
	return mc;
end
-----------------------------------
-- Layer control
-----------------------------------
local pe_layer = {};
Map3DSystem.Movie.mcml_controls.pe_layer = pe_layer;
function pe_layer.create(mcmlNode)
	local layer = CommonCtrl.Animation.Motion.LayerManager:new();
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = Map3DSystem.Movie.mcml_controls.create(childnode)
		layer:AddChild(child);	
	end
	return layer;
end
----------------------------------------------------------------------
-- pe:doubleAnimationUsingKeyFrames control
----------------------------------------------------------------------
local pe_doubleAnimationUsingKeyFrames = {};
Map3DSystem.Movie.mcml_controls.pe_doubleAnimationUsingKeyFrames = pe_doubleAnimationUsingKeyFrames;

function pe_doubleAnimationUsingKeyFrames.create(mcmlNode)
	local keyFrames;	
	local TargetName = mcmlNode:GetAttribute("TargetName")
	local TargetProperty =  mcmlNode:GetAttribute("TargetProperty");
	local Duration =  mcmlNode:GetAttribute("Duration");	
	if(TargetName and TargetProperty) then
		local doubleAnimationUsingKeyFrames = CommonCtrl.Animation.DoubleAnimationUsingKeyFrames:new{
						TargetName = TargetName,
						TargetProperty = TargetProperty,
						Duration = Duration,
					};
		local childnode;
		for childnode in mcmlNode:next() do		
			local keyframe = Map3DSystem.Movie.mcml_controls.create(childnode)
			if(type(keyframe) == "table") then
				doubleAnimationUsingKeyFrames:addKeyframe(keyframe)
			end	
		end
		keyFrames = doubleAnimationUsingKeyFrames;
	end	
	return keyFrames;
end
-----------------------------------
-- pe:linearDoubleKeyFrame control
-----------------------------------
local pe_linearDoubleKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_linearDoubleKeyFrame = pe_linearDoubleKeyFrame;
function pe_linearDoubleKeyFrame.create(mcmlNode)
	local linearDoubleKeyFrame;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	local SimpleEase =  mcmlNode:GetAttribute("SimpleEase");
	Value = tonumber(Value);
	SimpleEase = tonumber(SimpleEase);
	if(KeyTime and Value) then
		-- create a LinearDoubleKeyFrame
		linearDoubleKeyFrame = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
			KeyTime = KeyTime,
			Value = Value,
			SimpleEase = SimpleEase,
		};
	end	
	return linearDoubleKeyFrame;
end
-----------------------------------
-- pe:discreteDoubleKeyFrame control
-----------------------------------
local pe_discreteDoubleKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_discreteDoubleKeyFrame = pe_discreteDoubleKeyFrame;
function pe_discreteDoubleKeyFrame.create(mcmlNode)
	local discreteDoubleKeyFrame;
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	Value = tonumber(Value);
	if(KeyTime and Value) then
		-- create a DiscreteDoubleKeyFrame
		discreteDoubleKeyFrame = CommonCtrl.Animation.DiscreteDoubleKeyFrame:new{
			KeyTime = KeyTime,
			Value = Value,
		};
	end	
	return discreteDoubleKeyFrame;
end
----------------------------------------------------------------------
-- pe:stringAnimationUsingKeyFrames control
----------------------------------------------------------------------
local pe_stringAnimationUsingKeyFrames = {};
Map3DSystem.Movie.mcml_controls.pe_stringAnimationUsingKeyFrames = pe_stringAnimationUsingKeyFrames;
function pe_stringAnimationUsingKeyFrames.create(mcmlNode)
	local keyFrames;	
	local TargetName = mcmlNode:GetAttribute("TargetName")
	local TargetProperty =  mcmlNode:GetAttribute("TargetProperty");
	local Duration =  mcmlNode:GetAttribute("Duration");
	if(TargetName and TargetProperty) then
		local stringAnimationUsingKeyFrames = CommonCtrl.Animation.StringAnimationUsingKeyFrames:new{
						TargetName = TargetName,
						TargetProperty = TargetProperty,
						Duration = Duration,
					};
		if(mcmlNode[1] and mcmlNode[1]["name"] =="pe:stringAnimationUsingKeyFrames_Value")then
			local temp_Value = mcmlNode[1][1]
			stringAnimationUsingKeyFrames = CommonCtrl.Animation.Reverse.LrcToMcml(temp_Value,stringAnimationUsingKeyFrames)
		else	
			local childnode;
			for childnode in mcmlNode:next() do	
				local keyframe = Map3DSystem.Movie.mcml_controls.create(childnode)
				if(type(keyframe) == "table") then
					stringAnimationUsingKeyFrames:addKeyframe(keyframe)
				end	
			end
		end
		keyFrames = stringAnimationUsingKeyFrames;
	end	
	return keyFrames;
end
-----------------------------------
-- pe:discreteStringKeyFrame control
-----------------------------------
local pe_discreteStringKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_discreteStringKeyFrame = pe_discreteStringKeyFrame;
function pe_discreteStringKeyFrame.create(mcmlNode)
	local discreteStringKeyFrame;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	if(KeyTime and Value) then
		-- create a LinearDoubleKeyFrame
		discreteStringKeyFrame = CommonCtrl.Animation.DiscreteStringKeyFrame:new{
			KeyTime = KeyTime,
			Value = Value,
		};
	end	
	return discreteStringKeyFrame;
end
----------------------------------------------------------------------
-- pe:point3DAnimationUsingKeyFrames control
----------------------------------------------------------------------
local pe_point3DAnimationUsingKeyFrames = {};
Map3DSystem.Movie.mcml_controls.pe_point3DAnimationUsingKeyFrames = pe_point3DAnimationUsingKeyFrames;
function pe_point3DAnimationUsingKeyFrames.create(mcmlNode)
	local keyFrames = {};	
	local TargetName = mcmlNode:GetAttribute("TargetName")
	local TargetProperty =  mcmlNode:GetAttribute("TargetProperty");
	local Duration =  mcmlNode:GetAttribute("Duration");	
	if(TargetName and TargetProperty) then
		local point3DAnimationUsingKeyFrames = CommonCtrl.Animation.Point3DAnimationUsingKeyFrames:new{
						TargetName = TargetName,
						TargetProperty = TargetProperty,
						Duration = Duration,
					};
					local childnode;
					for childnode in mcmlNode:next() do
						
						local keyframe = Map3DSystem.Movie.mcml_controls.create(childnode)
						if(type(keyframe) == "table") then
							point3DAnimationUsingKeyFrames:addKeyframe(keyframe)
						end	
					end
		keyFrames = point3DAnimationUsingKeyFrames;
	end	
	return keyFrames;
end
-----------------------------------
-- pe:linearPoint3DKeyFrame control
-----------------------------------
local pe_linearPoint3DKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_linearPoint3DKeyFrame = pe_linearPoint3DKeyFrame;
function pe_linearPoint3DKeyFrame.create(mcmlNode)
	local linearPoint3DKeyFrame;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	local SimpleEase =  mcmlNode:GetAttribute("SimpleEase");
	SimpleEase = tonumber(SimpleEase);
	if(KeyTime and Value) then
		-- create a LinearPoint3DKeyFrame
		linearPoint3DKeyFrame = CommonCtrl.Animation.LinearPoint3DKeyFrame:new{
			KeyTime = KeyTime,
			SimpleEase = SimpleEase,
		};
		linearPoint3DKeyFrame:SetValue(Value);
	end	
	return linearPoint3DKeyFrame;
end
-----------------------------------
-- pe:discretePoint3DKeyFrame control
-----------------------------------
local pe_discretePoint3DKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_discretePoint3DKeyFrame = pe_discretePoint3DKeyFrame;
function pe_discretePoint3DKeyFrame.create(mcmlNode)
	local discretePoint3DKeyFrame;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	if(KeyTime and Value) then
		-- create a LinearPoint3DKeyFrame
		discretePoint3DKeyFrame = CommonCtrl.Animation.DiscretePoint3DKeyFrame:new{
			KeyTime = KeyTime,
		};
		discretePoint3DKeyFrame:SetValue(Value);
	end	
	return discretePoint3DKeyFrame;
end
----------------------------------------------------------------------
-- pe:objectAnimationUsingKeyFrames control
----------------------------------------------------------------------
local pe_objectAnimationUsingKeyFrames = {};
Map3DSystem.Movie.mcml_controls.pe_objectAnimationUsingKeyFrames = pe_objectAnimationUsingKeyFrames;
function pe_objectAnimationUsingKeyFrames.create(mcmlNode)
	local keyFrames;	
	local TargetName = mcmlNode:GetAttribute("TargetName")
	local TargetProperty =  mcmlNode:GetAttribute("TargetProperty");
	local Duration =  mcmlNode:GetAttribute("Duration");	
	if(TargetName and TargetProperty) then
		local objectAnimationUsingKeyFrames = CommonCtrl.Animation.ObjectAnimationUsingKeyFrames:new{
						TargetName = TargetName,
						TargetProperty = TargetProperty,
						Duration = Duration,
					};
					local childnode;
					for childnode in mcmlNode:next() do
						
						local keyframe = Map3DSystem.Movie.mcml_controls.create(childnode)
						if(type(keyframe) == "table") then
							-- add child node
							objectAnimationUsingKeyFrames:addKeyframe(keyframe)
						end	
					end
		keyFrames = objectAnimationUsingKeyFrames;
	end	
	return keyFrames;
end
-----------------------------------
-- pe:discreteObjectKeyFrame control
-----------------------------------
local pe_discreteObjectKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_discreteObjectKeyFrame = pe_discreteObjectKeyFrame;
function pe_discreteObjectKeyFrame.create(mcmlNode)
	local discreteObjectKeyFrame;
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	if(not Value)then
		Value = mcmlNode[1];
	end
	if(Value)then
		-- because the type of value if table
		NPL.DoString("CommonCtrl.Animation.Util.value = "..Value);
	end
	Value = CommonCtrl.Animation.Util.value;
	CommonCtrl.Animation.Util.value = nil;
	if(KeyTime and Value) then
		-- create a LinearDoubleKeyFrame
		discreteObjectKeyFrame = CommonCtrl.Animation.DiscreteObjectKeyFrame:new{
			KeyTime = KeyTime,
			Value = Value,
		};
	end	
	return discreteObjectKeyFrame;
end
----------------------------------------------------------------------
-- pe:point3DAnimationUsingPath control
----------------------------------------------------------------------
local pe_point3DAnimationUsingPath = {};
Map3DSystem.Movie.mcml_controls.pe_point3DAnimationUsingPath = pe_point3DAnimationUsingPath;
function pe_point3DAnimationUsingPath.create(mcmlNode)
	local keyFrames = {};	
	local TargetName = mcmlNode:GetAttribute("TargetName")
	local TargetProperty =  mcmlNode:GetAttribute("TargetProperty");
	local Duration =  mcmlNode:GetAttribute("Duration");	
	if(TargetName and TargetProperty) then
		local Point3DAnimationUsingPath = CommonCtrl.Animation.Point3DAnimationUsingPath:new{
						TargetName = TargetName,
						TargetProperty = TargetProperty,
						Duration = Duration,
					};
					local childnode;
					for childnode in mcmlNode:next() do
						
						local keyframe = Map3DSystem.Movie.mcml_controls.create(childnode)
						if(type(keyframe) == "table") then
							-- add child node
							Point3DAnimationUsingPath:addKeyframe(keyframe)
						end	
					end
		keyFrames = Point3DAnimationUsingPath;
	end	
	return keyFrames;
end
-----------------------------------
-- pe:discretePoint3DUsingPath control
-----------------------------------
local pe_discretePoint3DUsingPath = {};
Map3DSystem.Movie.mcml_controls.pe_discretePoint3DUsingPath = pe_discretePoint3DUsingPath;
function pe_discretePoint3DUsingPath.create(mcmlNode)
	local discretePoint3DUsingPath;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  mcmlNode:GetAttribute("Value");
	if(KeyTime) then
		-- create a discretePoint3DUsingPath
		discretePoint3DUsingPath = CommonCtrl.Animation.DiscretePoint3DUsingPath:new{
			KeyTime = KeyTime,
		};
		discretePoint3DUsingPath:SetValue(Value);
	end	
	
	return discretePoint3DUsingPath;
end
----------------------------------------------------------------------
-- pe:targetAnimationUsingKeyFrames control
----------------------------------------------------------------------
local pe_targetAnimationUsingKeyFrames = {};
Map3DSystem.Movie.mcml_controls.pe_targetAnimationUsingKeyFrames = pe_targetAnimationUsingKeyFrames;
function pe_targetAnimationUsingKeyFrames.create(mcmlNode)
	local keyFrames;	
	local TargetName = mcmlNode:GetAttribute("TargetName")
	local TargetProperty =  mcmlNode:GetAttribute("TargetProperty");
	if(TargetName or TargetProperty) then
		local targetAnimationUsingKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{
						TargetName = TargetName,
						TargetProperty = TargetProperty,
					};
					local childnode;
					for childnode in mcmlNode:next() do
						local keyframe = Map3DSystem.Movie.mcml_controls.create(childnode)
						
						if(type(keyframe) == "table") then
							-- add child node
							targetAnimationUsingKeyFrames:addKeyframe(keyframe)
						end	
					end
		keyFrames = targetAnimationUsingKeyFrames;
	end	
	return keyFrames;
end
-----------------------------------
-- pe:linearTargetKeyFrame control
-----------------------------------
local pe_linearTargetKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_linearTargetKeyFrame = pe_linearTargetKeyFrame;


function pe_linearTargetKeyFrame.create(mcmlNode)
	local linearTargetKeyFrame;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	
	local Value =  Map3DSystem.Movie.mcml_controls.create(mcmlNode[1]);
	local SimpleEase =  mcmlNode:GetNumber("SimpleEase");
	if(KeyTime and Value) then
		local target = Value;
		--local targetType = target.Property;
		--if(targetType == "BuildingTarget" or targetType == "PlantTarget" or targetType == "ActorTarget")then
			--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/LinearMovieKeyFrame.lua");
			--local params = target:GetMsgParams()
			--linearTargetKeyFrame = Map3DSystem.App.Inventor.LinearMovieKeyFrame:new{
				--SimpleEase = SimpleEase,
				--KeyTime = KeyTime,
			--};
			--linearTargetKeyFrame:__Initialization(params)
			--linearTargetKeyFrame:InitKeyFrame();
			--linearTargetKeyFrame:SetKeyTime(KeyTime);
		--else
			---- create a LinearTargetKeyFrame
			--linearTargetKeyFrame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{
				--SimpleEase = SimpleEase,
				--KeyTime = KeyTime,
			--};
		--end	
		-- create a LinearTargetKeyFrame
			linearTargetKeyFrame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{
				SimpleEase = SimpleEase,
				KeyTime = KeyTime,
			};
		linearTargetKeyFrame:SetValue(Value);
	end	
	return linearTargetKeyFrame;
end
-----------------------------------
-- pe:discreteTargetKeyFrame control
-----------------------------------
local pe_discreteTargetKeyFrame = {};
Map3DSystem.Movie.mcml_controls.pe_discreteTargetKeyFrame = pe_discreteTargetKeyFrame;


function pe_discreteTargetKeyFrame.create(mcmlNode)
	local discreteTargetKeyFrame;
	
	local KeyTime = mcmlNode:GetAttribute("KeyTime")
	local Value =  Map3DSystem.Movie.mcml_controls.create(mcmlNode[1]);
	if(KeyTime and Value) then
		-- create a LinearTargetKeyFrame
		discreteTargetKeyFrame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{
			KeyTime = KeyTime,
		};
		discreteTargetKeyFrame:SetValue(Value);
	end	
	return discreteTargetKeyFrame;
end
-----------------------------------
-- CameraTarget control
-----------------------------------
local CameraTarget = {};
Map3DSystem.Movie.mcml_controls.CameraTarget = CameraTarget;
function CameraTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local X = mcmlNode:GetNumber("X");
	local Y = mcmlNode:GetNumber("Y");
	local Z = mcmlNode:GetNumber("Z");
	local Dist =mcmlNode:GetNumber("Dist");
	local Angle = mcmlNode:GetNumber("Angle");
	local RotY = mcmlNode:GetNumber("RotY");
	
	local CameraTarget = CommonCtrl.Animation.Motion.CameraTarget:new{
		ID = ID,
		X = X,
		Y = Y,
		Z = Z,
		Dist = Dist,
		Angle = Angle,
		RotY = RotY,
	}
	return CameraTarget;
end
-----------------------------------
-- OceanTarget control
-----------------------------------
local OceanTarget = {};
Map3DSystem.Movie.mcml_controls.OceanTarget = OceanTarget;
function OceanTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local WaterLevel = mcmlNode:GetNumber("WaterLevel");
	local R = mcmlNode:GetNumber("R");
	local G = mcmlNode:GetNumber("G");
	local B =mcmlNode:GetNumber("B");

	local OceanTarget = CommonCtrl.Animation.Motion.OceanTarget:new{
		ID = ID,
		WaterLevel = WaterLevel,
		R = R,
		G = G,
		B = B,
	}
	return OceanTarget;
end
-----------------------------------
-- LandTarget control
-----------------------------------
local LandTarget = {};
Map3DSystem.Movie.mcml_controls.LandTarget = LandTarget;
function LandTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local TerrainBrushSize = mcmlNode:GetNumber("TerrainBrushSize");
	local TerrainType = mcmlNode:GetString("TerrainType");
	local X = mcmlNode:GetNumber("X");
	local Y = mcmlNode:GetNumber("Y");
	local Z =mcmlNode:GetNumber("Z");
	local HeightScale =mcmlNode:GetNumber("HeightScale");
	local bRoughen =mcmlNode:GetBool("bRoughen");
	
	local TextureBrushSize = mcmlNode:GetNumber("TextureBrushSize");
	local BrushIndex = mcmlNode:GetNumber("BrushIndex");

	local LandTarget = CommonCtrl.Animation.Motion.LandTarget:new{
		ID = ID,
		TerrainBrushSize = TerrainBrushSize,
		TerrainType = TerrainType,
		X = X,
		Y = Y,
		Z = Z,
		HeightScale = HeightScale,
		bRoughen = bRoughen,
		
		TextureBrushSize = TextureBrushSize,
		BrushIndex = BrushIndex,
	}
	return LandTarget;
end
-----------------------------------
-- SkyTarget control
-----------------------------------
local SkyTarget = {};
Map3DSystem.Movie.mcml_controls.SkyTarget = SkyTarget;
function SkyTarget.create(mcmlNode)

	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local SkyBoxFile = mcmlNode:GetString("SkyBoxFile");
	local SkyBoxName = mcmlNode:GetString("SkyBoxName");
	local SkyColor_R = mcmlNode:GetNumber("SkyColor_R");
	local SkyColor_G = mcmlNode:GetNumber("SkyColor_G");
	local SkyColor_B =mcmlNode:GetNumber("SkyColor_B");
	local Timeofday =mcmlNode:GetNumber("Timeofday");
	local FogColor_R =mcmlNode:GetNumber("FogColor_R");	
	local FogColor_G = mcmlNode:GetNumber("FogColor_G");
	local FogColor_B = mcmlNode:GetNumber("FogColor_B");
	local UseSimulatedSky = mcmlNode:GetBool("UseSimulatedSky");
	local SkyTarget = CommonCtrl.Animation.Motion.SkyTarget:new{
		ID = ID,
		SkyBoxFile = SkyBoxFile,
		SkyBoxName = SkyBoxName,
		SkyColor_R =SkyColor_R,
		SkyColor_G = SkyColor_G,
		SkyColor_B = SkyColor_B,
		Timeofday = Timeofday,		
		FogColor_R = FogColor_R,
		FogColor_G = FogColor_G,
		FogColor_B = FogColor_B,
		UseSimulatedSky = UseSimulatedSky,
	}
	return SkyTarget;
end
-----------------------------------
-- CaptionTarget control
-----------------------------------
local CaptionTarget = {};
Map3DSystem.Movie.mcml_controls.CaptionTarget = CaptionTarget;
function CaptionTarget.create(mcmlNode)

	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local Text = mcmlNode:GetString("Text") or mcmlNode[1];
	
	local CaptionTarget = CommonCtrl.Animation.Motion.CaptionTarget:new{
		ID = ID,
		Text = Text,
	}
	return CaptionTarget;
end
-----------------------------------
-- ActorTarget control
-----------------------------------
local ActorTarget = {};
Map3DSystem.Movie.mcml_controls.ActorTarget = ActorTarget;
function ActorTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local AssetFile = mcmlNode:GetString("AssetFile");
	local IsCharacter = mcmlNode:GetBool("IsCharacter");
	local Name = mcmlNode:GetString("Name");
	local X = mcmlNode:GetNumber("X");
	local Y =mcmlNode:GetNumber("Y");
	local Z =mcmlNode:GetNumber("Z");
	local Animation =mcmlNode:GetString("Animation");	
	local Dialog = mcmlNode:GetString("Dialog") or mcmlNode[1];
	local Facing = mcmlNode:GetNumber("Facing");
	local RunTo_X = mcmlNode:GetNumber("RunTo_X");
	local RunTo_Y = mcmlNode:GetNumber("RunTo_Y");
	local RunTo_Z = mcmlNode:GetNumber("RunTo_Z");
	local Rot_X = mcmlNode:GetNumber("Rot_X");
	local Rot_Y = mcmlNode:GetNumber("Rot_Y");
	local Rot_Z = mcmlNode:GetNumber("Rot_Z");
	local Scaling = mcmlNode:GetNumber("Scaling");
	local IsRunTo = mcmlNode:GetBool("IsRunTo") or false;
	local Visible = mcmlNode:GetBool("Visible");
	local ActorTarget = CommonCtrl.Animation.Motion.ActorTarget:new{
		ID = ID,
		AssetFile = AssetFile,
		IsCharacter = IsCharacter,
		Facing = Facing,
		Name = Name,
		X = X,
		Y = Y,
		Z = Z,
		Animation = Animation,
		Dialog = Dialog,
		RunTo_X = RunTo_X,
		RunTo_Y = RunTo_Y,
		RunTo_Z = RunTo_Z,
		Rot_X = Rot_X,
		Rot_Y = Rot_Y,
		Rot_Z = Rot_Z,
		Scaling = Scaling,
		IsRunTo = IsRunTo,
		Visible = Visible,
	}
	return ActorTarget;
end
-----------------------------------
-- BuildingTarget control
-----------------------------------
local BuildingTarget = {};
Map3DSystem.Movie.mcml_controls.BuildingTarget = BuildingTarget;
function BuildingTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local AssetFile = mcmlNode:GetString("AssetFile");
	local EnablePhysics = mcmlNode:GetBool("EnablePhysics");
	local IsCharacter = mcmlNode:GetBool("IsCharacter");
	local Name = mcmlNode:GetString("Name");
	local X = mcmlNode:GetNumber("X");
	local Y =mcmlNode:GetNumber("Y");
	local Z =mcmlNode:GetNumber("Z");
	local Obb_X = mcmlNode:GetNumber("Obb_X");
	local Obb_Y = mcmlNode:GetNumber("Obb_Y");
	local Obb_Z = mcmlNode:GetNumber("Obb_Z");
	local Pos_X = mcmlNode:GetNumber("Pos_X");
	local Pos_Y = mcmlNode:GetNumber("Pos_Y");
	local Pos_Z = mcmlNode:GetNumber("Pos_Z");
	local Rot_W = mcmlNode:GetNumber("Rot_W");
	local Rot_X = mcmlNode:GetNumber("Rot_X");
	local Rot_Y = mcmlNode:GetNumber("Rot_Y");
	local Rot_Z = mcmlNode:GetNumber("Rot_Z");
	local Scaling = mcmlNode:GetNumber("Scaling");
	local Visible = mcmlNode:GetBool("Visible");
	local BuildingTarget = CommonCtrl.Animation.Motion.BuildingTarget:new{
		ID = ID,
		AssetFile = AssetFile,
		EnablePhysics = EnablePhysics,
		IsCharacter = IsCharacter,
		Name = Name,
		X = X,
		Y = Y,
		Z = Z,
		Obb_X = Obb_X,
		Obb_Y = Obb_Y,
		Obb_Z = Obb_Z,
		Pos_X = Pos_X,
		Pos_Y = Pos_Y,
		Pos_Z = Pos_Z,
		Rot_W = Rot_W,
		Rot_X = Rot_X,
		Rot_Y = Rot_Y,
		Rot_Z = Rot_Z,
		Scaling = Scaling,
		Visible = Visible,
	}
	return BuildingTarget;
end
-----------------------------------
-- PlantTarget control
-----------------------------------
local PlantTarget = {};
Map3DSystem.Movie.mcml_controls.PlantTarget = PlantTarget;
function PlantTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local AssetFile = mcmlNode:GetString("AssetFile");
	local EnablePhysics = mcmlNode:GetBool("EnablePhysics");
	local IsCharacter = mcmlNode:GetBool("IsCharacter");
	local Name = mcmlNode:GetString("Name");
	local X = mcmlNode:GetNumber("X");
	local Y =mcmlNode:GetNumber("Y");
	local Z =mcmlNode:GetNumber("Z");
	local Obb_X = mcmlNode:GetNumber("Obb_X");
	local Obb_Y = mcmlNode:GetNumber("Obb_Y");
	local Obb_Z = mcmlNode:GetNumber("Obb_Z");
	local Pos_X = mcmlNode:GetNumber("Pos_X");
	local Pos_Y = mcmlNode:GetNumber("Pos_Y");
	local Pos_Z = mcmlNode:GetNumber("Pos_Z");
	local Rot_W = mcmlNode:GetNumber("Rot_W");
	local Rot_X = mcmlNode:GetNumber("Rot_X");
	local Rot_Y = mcmlNode:GetNumber("Rot_Y");
	local Rot_Z = mcmlNode:GetNumber("Rot_Z");
	local Scaling = mcmlNode:GetNumber("Scaling");
	local Visible = mcmlNode:GetBool("Visible");
	local PlantTarget = CommonCtrl.Animation.Motion.PlantTarget:new{
		ID = ID,
		AssetFile = AssetFile,
		EnablePhysics = EnablePhysics,
		IsCharacter = IsCharacter,
		Name = Name,
		X = X,
		Y = Y,
		Z = Z,
		Obb_X = Obb_X,
		Obb_Y = Obb_Y,
		Obb_Z = Obb_Z,
		Pos_X = Pos_X,
		Pos_Y = Pos_Y,
		Pos_Z = Pos_Z,
		Rot_W = Rot_W,
		Rot_X = Rot_X,
		Rot_Y = Rot_Y,
		Rot_Z = Rot_Z,
		Scaling = Scaling,
		Visible = Visible,
	}
	return PlantTarget;
end
-----------------------------------
-- SoundTarget control
-----------------------------------
local SoundTarget = {};
Map3DSystem.Movie.mcml_controls.SoundTarget = SoundTarget;
function SoundTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local Path = mcmlNode:GetString("Path") or "";
	Path = string.gsub(Path, "\r\n", "");	
	local SoundTarget = CommonCtrl.Animation.Motion.SoundTarget:new{
		ID = ID,
		Path = Path,	
	}
	return SoundTarget;
end
-----------------------------------
-- EffectTarget control
-----------------------------------
local EffectTarget = {};
Map3DSystem.Movie.mcml_controls.EffectTarget = EffectTarget;
function EffectTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local Path = mcmlNode:GetString("Path") or "";
	Path = string.gsub(Path, "\r\n", "");	
	local EffectTarget = CommonCtrl.Animation.Motion.EffectTarget:new{
		ID = ID,
		Path = Path,	
	}
	return EffectTarget;
end
-----------------------------------
-- ControlTarget control
-----------------------------------
local ControlTarget = {};
Map3DSystem.Movie.mcml_controls.ControlTarget = ControlTarget;
function ControlTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local ID = mcmlNode:GetNumber("ID");
	local Name = mcmlNode:GetString("Name");
	local Type = mcmlNode:GetString("Type");
	local Alignment = mcmlNode:GetString("Alignment");
	local X = mcmlNode:GetNumber("X");
	local Y =mcmlNode:GetNumber("Y");
	local Width =mcmlNode:GetNumber("Width");
	local Height =mcmlNode:GetNumber("Height");
	local Rot =mcmlNode:GetNumber("Rot");
	local ScaleX =mcmlNode:GetNumber("ScaleX");
	local ScaleY =mcmlNode:GetNumber("ScaleY");
	local Alpha =mcmlNode:GetNumber("Alpha");
	local Visible = mcmlNode:GetBool("Visible");
	local Bg = mcmlNode:GetString("Bg");
	local Text = mcmlNode:GetString("Text");
	local ControlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{
		ID = ID,
		Name = Name,
		Type = Type,
		Alignment = Alignment,
		X = X,
		Y = Y,
		Width = Width,
		Height = Height,
		Rot = Rot,
		ScaleX = ScaleX,
		ScaleY = ScaleY,
		Alpha = Alpha,
		Visible = Visible,
		Bg = Bg,
		Text = Text,
	}
	return ControlTarget;
end
-----------------------------------
-- Sprite3DTarget control
-----------------------------------
local Sprite3DTarget = {};
Map3DSystem.Movie.mcml_controls.Sprite3DTarget = Sprite3DTarget;
function Sprite3DTarget.create(mcmlNode)
	if(not mcmlNode)then return; end
	local X = mcmlNode:GetNumber("X");
	local Y =mcmlNode:GetNumber("Y");
	local Z =mcmlNode:GetNumber("Z");
	local Alpha =mcmlNode:GetNumber("Alpha");
	local Facing =mcmlNode:GetNumber("Facing");
	local Scaling =mcmlNode:GetNumber("Scaling");
	local Visible = mcmlNode:GetBool("Visible");
	local Animation = mcmlNode:GetString("Animation");
	local Dialog = mcmlNode:GetString("Dialog");
	local target = CommonCtrl.Animation.Motion.Sprite3DTarget:new{
		X = X,
		Y = Y,
		Z = Z,
		Facing = Facing,
		Scaling = Scaling,
		Alpha = Alpha,
		Visible = Visible,
		Animation = Animation,
		Dialog = Dialog,
	}
	return target;
end
------------------------------------------------------------
-- Map3DSystem.Movie.mcml_controls.control_mapping
------------------------------------------------------------
Map3DSystem.Movie.mcml_controls.control_mapping = {
	-- storyboard tags	
	["pe:storyboards"] = mcml_controls.pe_storyboards,
		["pe:storyboard"] = mcml_controls.pe_storyboard,
					["pe:doubleAnimationUsingKeyFrames"] = mcml_controls.pe_doubleAnimationUsingKeyFrames,
						["pe:linearDoubleKeyFrame"] = mcml_controls.pe_linearDoubleKeyFrame,
						["pe:discreteDoubleKeyFrame"] = mcml_controls.pe_discreteDoubleKeyFrame,
					["pe:stringAnimationUsingKeyFrames"] = mcml_controls.pe_stringAnimationUsingKeyFrames,
						["pe:discreteStringKeyFrame"] = mcml_controls.pe_discreteStringKeyFrame,
					["pe:point3DAnimationUsingKeyFrames"] = mcml_controls.pe_point3DAnimationUsingKeyFrames,
						["pe:linearPoint3DKeyFrame"] = mcml_controls.pe_linearPoint3DKeyFrame,
						["pe:discretePoint3DKeyFrame"] = mcml_controls.pe_discretePoint3DKeyFrame,
					["pe:objectAnimationUsingKeyFrames"] = mcml_controls.pe_objectAnimationUsingKeyFrames,
						["pe:discreteObjectKeyFrame"] = mcml_controls.pe_discreteObjectKeyFrame,
					["pe:point3DAnimationUsingPath"] = mcml_controls.pe_point3DAnimationUsingPath,
						["pe:discretePoint3DUsingPath"] = mcml_controls.pe_discretePoint3DUsingPath,
					["pe:targetAnimationUsingKeyFrames"] = mcml_controls.pe_targetAnimationUsingKeyFrames,
						["pe:linearTargetKeyFrame"] = mcml_controls.pe_linearTargetKeyFrame,
						["pe:discreteTargetKeyFrame"] = mcml_controls.pe_discreteTargetKeyFrame,
	["CameraTarget"] = mcml_controls.CameraTarget,
	["OceanTarget"] = mcml_controls.OceanTarget,
	["LandTarget"] = mcml_controls.LandTarget,
	["SkyTarget"] = mcml_controls.SkyTarget,
	["CaptionTarget"] = mcml_controls.CaptionTarget,
	["ActorTarget"] = mcml_controls.ActorTarget,
	["BuildingTarget"] = mcml_controls.BuildingTarget,
	["PlantTarget"] = mcml_controls.PlantTarget,
	["SoundTarget"] = mcml_controls.SoundTarget,
	["EffectTarget"] = mcml_controls.EffectTarget,
	["ControlTarget"] = mcml_controls.ControlTarget,
	["Sprite3DTarget"] = mcml_controls.Sprite3DTarget,
	["Movieclip"] = mcml_controls.pe_movieclip,
	["Layer"] = mcml_controls.pe_layer,
	}
function Map3DSystem.Movie.mcml_controls.create(mcmlNode) 
	if(not mcmlNode)then return; end
	local ctl = Map3DSystem.Movie.mcml_controls.control_mapping[mcmlNode.name];
	if (ctl and ctl.create) then
		-- if there is a known control_mapping, use it and return
		return ctl.create(mcmlNode);
	else
		-- if no control mapping found, create each child node. 
		local childnode;
		for childnode in mcmlNode:next() do
			mcml_controls.create(childnode);
		end
	end
end