--[[
Title: MovieToolBar
Author(s): Leio Zhang
Date: 2008/10/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieToolBar.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor.lua");
local MovieToolBar = {
	GlobalHimself = nil,
	name = nil,
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	container_bg = nil,
	parent = nil,
	
	treeView = nil,
}
commonlib.setfield("Map3DSystem.Movie.MovieToolBar",MovieToolBar);
function MovieToolBar:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()	
	return o
end
function MovieToolBar:Initialization()
	--self.name = ParaGlobal.GenerateUniqueID();
end
-- param@ clipMcmlNode: <pe:movie-clip id ="1">
function MovieToolBar:DataBind(clipMcmlNode,movieEditor)
	if(not clipMcmlNode or not movieEditor)then return; end
	self.movieEditor = movieEditor;
	self.clipMcmlNode = clipMcmlNode;
end
function MovieToolBar:__AutoAddLayer(mcmlName,targetProperty,index,params)
	if(not mcmlName or not targetProperty)then return; end
	if(not self.movieEditor or not self.movieEditor.moviescript or not self.clipMcmlNode)then return; end
	local Added = self.movieEditor:GetObjectLayer(targetProperty);
	local moviescript = self.movieEditor.moviescript;
	if(not Added)then
		local nodes,__ = moviescript:GetNodesFromMcmlName(mcmlName.."s")
		if(nodes)then
			local assetNode = moviescript:ConstructNode(mcmlName,true);
			moviescript:ImportAssetToClip(assetNode,self.clipMcmlNode);
					
			local keyFrames = Map3DSystem.Movie.TargetKeyFramesFactory.BuildObject(mcmlName,params,nil,self.movieEditor)
			local valueNode = assetNode:GetChild("value");
			if(valueNode and keyFrames)then
				local __KeyFrames__Node = Map3DSystem.mcml.new(nil, {name = "__KeyFrames__Node"})
				__KeyFrames__Node["KeyFrames"] = keyFrames;
				-- like <pe:movie-actor id="121">
				keyFrames["ParentMcmlNode"] = assetNode;
				valueNode:AddChild(__KeyFrames__Node);
				-- import static asset node
				local id = assetNode:GetNumber("id");
				local staticAssetNode = moviescript:ConstructStaticAssetNode(mcmlName,id);
				if(staticAssetNode and params)then
					-- staticAssetNode[1] is a table
					staticAssetNode[1] = params;
				end
			end				
			local layer =  self.movieEditor:NewLayer()
			layer["ParentMcmlNode"] = assetNode;
			layer:AddChild(keyFrames);
			self.movieEditor:AddLayer(layer,index)
			
			Map3DSystem.Movie.MovieEditPage.UpdateMovieAssets();
		end
	end
end
function MovieToolBar:OnCamera(param)
	self:__AutoAddLayer(param,"CameraTarget",nil)
end
function MovieToolBar:OnSky(param)
	self:__AutoAddLayer(param,"SkyTarget",nil)
end
function MovieToolBar:OnLand(param)
	--self:__AutoAddLayer(param,"LandTarget",nil)
end
function MovieToolBar:OnOcean(param)
	self:__AutoAddLayer(param,"OceanTarget",nil)
end
function MovieToolBar:OnCaption(param)
	self:__AutoAddLayer(param,"CaptionTarget",nil)
end
function MovieToolBar:OnSound(param)
	self:__AutoAddLayer(param,"SoundTarget",nil)
end
function MovieToolBar:OnEffect(param)
	self:__AutoAddLayer(param,"EffectTarget",nil)
end
function MovieToolBar:OnBuilding(param)
	Map3DSystem.Movie.MovieToolBar.GlobalHimself = self;
	Map3DSystem.App.Commands.Call("Creation.NormalModel");
	self:RegHook(param);
end
function MovieToolBar:OnPlant(param)
	Map3DSystem.Movie.MovieToolBar.GlobalHimself = self;
	Map3DSystem.App.Commands.Call("Creation.NormalModel");
	self:RegHook(param);
end
function MovieToolBar:BuildPic(param)
	local name = ParaGlobal.GenerateUniqueID();
	local Alignment,X,Y,Width,Height = "_lt",0,0,256,128;
	local bg = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	local c = ParaUI.CreateUIObject("container",name,Alignment,X,Y,Width,Height);
	c.background= bg;
	local root = ParaUI.GetUIObject("root");
	if(root:IsValid())then
		root:AddChild(c);
		local temp = {
			Type = "container", 
			name = name,
			Alignment = Alignment,
			X = 0,
			Y = 0,
			Width = Width,
			Height = Height,
			Alpha = 1,
			Rot = 0,
			ScaleX = 1,
			ScaleY = 1,	
			Visible = true,
			Bg = bg,
			Text = "",				
			};
		self:__AutoAddLayer(param,"ControlTarget",nil,temp)
	end
end
function MovieToolBar:BuildText(param)
	local name = ParaGlobal.GenerateUniqueID();
	local Alignment,X,Y,Width,Height = "_lt",0,0,256,128;
	local c = ParaUI.CreateUIObject("text",name,Alignment,X,Y,Width,Height);
	local text = "文字";
	c.text = text;
	local root = ParaUI.GetUIObject("root");
	if(root:IsValid())then
		root:AddChild(c);
		local temp = {
			Type = "text", 
			name = name,
			Alignment = Alignment,
			X = 0,
			Y = 0,
			Width = Width,
			Height = Height,
			Alpha = 1,
			Rot = 0,
			ScaleX = 1,
			ScaleY = 1,	
			Visible = true,
			Bg = nil,
			Text = text,				
			};
		self:__AutoAddLayer(param,"ControlTarget",nil,temp)
	end
end
function MovieToolBar:OnControl(param,param2)
	if(param2 == "pic")then
		self:BuildPic(param);
	else
		self:BuildText(param);
	end	
end
function MovieToolBar:OnActor(param)
	Map3DSystem.Movie.MovieToolBar.GlobalHimself = self;
	Map3DSystem.App.Commands.Call("Creation.NormalCharacter");
	self:RegHook(param);
end
function MovieToolBar:RegHook(type)
	if(not type)then return end
	local o = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 		 
		hookName = "MovieToolBar_Hook_"..type, appName = "scene", wndName = "object"}
		if(type == "pe:movie-actor")then
			o.callback = MovieToolBar.Hook_SceneObject_Actor;
		elseif(type == "pe:movie-building")then
			o.callback = MovieToolBar.Hook_SceneObject_Building;
		elseif(type == "pe:movie-plant")then
			o.callback = MovieToolBar.Hook_SceneObject_Plant;
		end
	CommonCtrl.os.hook.SetWindowsHook(o);	
	o = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 		 
		hookName = "MovieToolBar_Hook_afterCreated", appName = "scene", wndName = "object"}
		-- only record building and plant,actor is need not
		if(type == "pe:movie-building" or type == "pe:movie-plant")then
			o.callback = MovieToolBar.Hook_SceneObject_afterCreated;
			CommonCtrl.os.hook.SetWindowsHook(o);
		end
		
end
function MovieToolBar:CreateEntityUnhook()
	--Map3DSystem.Movie.MovieToolBar.GlobalHimself = nil;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MovieToolBar_Hook_pe:movie-actor", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MovieToolBar_Hook_pe:movie-building", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MovieToolBar_Hook_pe:movie-plant", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MovieToolBar_Hook_afterCreated", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
end
function MovieToolBar.Hook_SceneObject_afterCreated(nCode, appName, msg)
	if(msg.type == Map3DSystem.msg.OBJ_CreateObject)then
	local obj_params = msg.obj_params;
	local obj = ObjEditor.GetObjectByParams(obj_params);
	if(obj)then
		NPL.load("(gl)script/ide/Animation/Motion/Target/TargetResourceManager.lua");
		CommonCtrl.Animation.Motion.TargetResourceManager[obj.name] = obj;
	end
	end
	return nCode;
end
function MovieToolBar.Hook_SceneObject_Actor(nCode, appName, msg)
		local self = EventTrackRecorder;
		local obj_params = msg.obj_params;
		if(msg.type == Map3DSystem.msg.OBJ_CreateObject) then
			if(Map3DSystem.Movie.MovieToolBar.GlobalHimself)then
				local self = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
				obj_params["name"] = ParaGlobal.GenerateUniqueID();
				self:__AutoAddLayer("pe:movie-actor","ActorTarget",nil,obj_params)
			end	
		end
	return nCode
end
function MovieToolBar.Hook_SceneObject_Building(nCode, appName, msg)
		local self = EventTrackRecorder;
		local obj_params = msg.obj_params;
		if(msg.type == Map3DSystem.msg.OBJ_CreateObject) then
			if(Map3DSystem.Movie.MovieToolBar.GlobalHimself)then
				local self = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
				obj_params["name"] = ParaGlobal.GenerateUniqueID();
				self:__AutoAddLayer("pe:movie-building","BuildingTarget",nil,obj_params)
			end	
		end
	return nCode
end
function MovieToolBar.Hook_SceneObject_Plant(nCode, appName, msg)
		local self = EventTrackRecorder;
		local obj_params = msg.obj_params;
		if(msg.type == Map3DSystem.msg.OBJ_CreateObject) then
			if(Map3DSystem.Movie.MovieToolBar.GlobalHimself)then
				local self = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
				obj_params["name"] = ParaGlobal.GenerateUniqueID();
				self:__AutoAddLayer("pe:movie-plant","PlantTarget",nil,obj_params)
			end	
		end
	return nCode
end
function MovieToolBar:OnSelected(param,param2)
	if(not param)then return; end
	self:Unhook();
	Map3DSystem.App.Commands.Call("File.CloseAllPropertyPanel");
	if(param == "pe:movie-camera")then
		self:OnCamera(param);

	elseif(param == "pe:movie-sky")then
		self:OnSky(param);  

	elseif(param == "pe:movie-land")then
		self:OnLand(param);  

	elseif(param == "pe:movie-ocean")then
		self:OnOcean(param); 

	elseif(param == "pe:movie-caption")then
		self:OnCaption(param); 
	elseif(param == "pe:movie-actor")then
		self:OnActor(param); 
	elseif(param == "pe:movie-building")then
		self:OnBuilding(param);  
	elseif(param == "pe:movie-plant")then
		self:OnPlant(param);  
	elseif(param == "pe:movie-effect")then
		self:OnEffect(param);  
	elseif(param == "pe:movie-sound")then
		self:OnSound(param) 
	elseif(param == "pe:movie-control")then
		self:OnControl(param,param2);  
	elseif(param == "anyobject")then
		self:RegMoveEndHook();
	elseif(param == "0")then
		self:MoveEndUnHook();
	end
end
function MovieToolBar:Unhook()
	self:CreateEntityUnhook();
	self:MoveEndUnHook();
end
function MovieToolBar:RegMoveEndHook()
	self:CreateEntityUnhook();
	self:SetPickingFilter("anyobject");
	Map3DSystem.Movie.MovieToolBar.GlobalHimself = self;
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET;
		local o = {hookType = hookType, 		 
				hookName = "MovieToolBar_moveEnd", appName = "scene", wndName = "object"}
				o.callback = MovieToolBar.OnMoveEnd;
		CommonCtrl.os.hook.SetWindowsHook(o);
end
function MovieToolBar:MoveEndUnHook()
	self:SetPickingFilter("0");
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "MovieToolBar_moveEnd", hookType = hookType});
end
local function OnObjectSelected_CallBack(curObj)
	if(curObj) then
	    local obj = Map3DSystem.obj.GetObject("selection");
	    local bSameAsLast;
        if(obj and obj:IsValid()) then
            -- deselect old one
            if(not obj:equals(curObj)) then
	            Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	        else
	            bSameAsLast = true;
	        end
	    end 
		-- select current
		if(not bSameAsLast) then
			-- send select message
            Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj=curObj, group=-1, effect = "boundingbox"});
            local self = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
            if(self and self.movieEditor)then
				local selectedLayer,selectedKeyFrame = self.movieEditor:GetMouseSeletedKeyFrame(curObj.name);
				self.movieEditor:UpdateSelected(selectedLayer,selectedKeyFrame)
            end
        end
    end
	return true;
end

-- called when picking filter changes.
function MovieToolBar:SetPickingFilter(filter)
	Map3DSystem.Movie.MovieToolBar.GlobalHimself = self;
    Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_PickObject, 
		filter = filter,
		-- callback. return true if allow next selection. 
		callbackFunc = OnObjectSelected_CallBack, 
	});
end
function MovieToolBar.OnMoveEnd(nCode, appName, msg)
	if(msg.type == Map3DSystem.msg.OBJ_EndMoveObject)then
	
	elseif(msg.type == Map3DSystem.msg.OBJ_CreateObject)then
		
		local obj_params = msg.obj_params;
		local self = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
		if(self and self.movieEditor)then
			local selectedLayer,selectedKeyFrame = self.movieEditor:GetMouseSeletedKeyFrame(obj_params.name);
			if(selectedKeyFrame)then
				local target = selectedKeyFrame:GetValue();
				if(target)then
					target:GetDefaultProperty(obj_params);
					self.movieEditor:UpdateSelected(selectedLayer,selectedKeyFrame)
					local obj = ObjEditor.GetObjectByParams(obj_params)
					if(obj)then
						CommonCtrl.Animation.Motion.TargetResourceManager[obj_params.name] =  obj;
					end
				end
			end
		end
	end
	return nCode;
end