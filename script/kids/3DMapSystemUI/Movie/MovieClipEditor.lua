--[[
Title: MovieClipEditor
Author(s): Leio Zhang
Date: 2008/10/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor.lua");
local e = Map3DSystem.Movie.MovieClipEditor:new();
e:Show(true);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieToolBar.lua");
NPL.load("(gl)script/ide/ScrollView.lua");
NPL.load("(gl)script/ide/Animation/Motion/McPlayer.lua");
local MovieClipEditor = {
	name = nil,
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 300, 
	container_bg = nil,
	parent = nil,
	
	selectedLayer = nil,
	selectedKeyFrame = nil,
	
	layerTitleWidth = 100,
	sliderBarPress = false,
}
commonlib.setfield("Map3DSystem.Movie.MovieClipEditor",MovieClipEditor);
function MovieClipEditor:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()	
	return o
end
function MovieClipEditor:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name,self);
end
function MovieClipEditor:DataBind(clip,moviescript)
	if(not clip)then return; end
	self.selectedLayer = nil;
	self.selectedKeyFrame = nil;
	self:UpdateLayerAndKeyFrames();
	self.Clip = clip;
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MoviePlayerPage.lua");
	self.mcPlayer = Map3DSystem.Movie.MoviePlayerPage.GetMcPlayer();
	self.mcPlayer:SetClip(self.Clip)
	--clip.MC_MotionStart = self.MC_MotionStart;
	--clip.MC_MotionPause = self.MC_MotionPause;
	--clip.MC_MotionResume = self.MC_MotionResume;
	--clip.MC_MotionStop = self.MC_MotionStop;
	--clip.MC_MotionEnd = self.MC_MotionEnd;
	--clip.MC_MotionTimeChange = self.MC_MotionTimeChange;
	clip.MovieClipEditor = self;
	self:UpdateTimingText(clip);
		
	self.moviescript = moviescript;
	local treeviewName = self.name.."treeView";
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl) then
		ctl.RootNode:ClearAllChildren();
		local k,v;
		local LayerList = self.Clip.LayerList
		if(not LayerList)then return; end
		for k,v in ipairs(LayerList) do
			local layer = v;
			local selected = false;
			if(k==1)then
				selected = false;
			end
			local parentMcmlNode = layer["ParentMcmlNode"]
			local title = "";
			if(parentMcmlNode)then
				local titleNode = parentMcmlNode:GetChild("title");
				if(titleNode)then
					title = titleNode["TitleValue"];
				end
			end
			local node = CommonCtrl.TreeNode:new({Selected = selected,Text = title, Name = title,layer = layer});
			ctl.RootNode:AddChild(node);
		end
	end
	self:RefreshViewWnd();
end
function MovieClipEditor:Show(bShow)
	local _this = ParaUI.GetUIObject(self.name.."container");
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", self.name.."container", self.alignment, self.left, self.top, self.width, self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		else
			_this.background= "";
		end
		local _parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		-- line 1
		_this = ParaUI.CreateUIObject("container", self.name.."line_1", self.alignment, self.left, self.top, self.width, 30);
		_this.background= "";
		_parent:AddChild(_this);
		
		
		_parent = _this;
		-- time text
		local left,top,width,height = 0,0,self.layerTitleWidth,30
		_this = ParaUI.CreateUIObject("text", self.name.."timeText", "_lt", left,top,width,height);
		_this.text = "";
		_parent:AddChild(_this);
		
		left,top,width,height = self.layerTitleWidth,0,self.width-self.layerTitleWidth,30
	
		NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTimeLine.lua");
		_this = ParaUI.CreateUIObject("container", "c", "_lt", left,top,width,height);
		_this.background= "";
		_parent:AddChild(_this);
		local timeLine = Map3DSystem.Movie.MovieTimeLine:new{
			alignment = "_fi",
			left = 0, 
			top = 0,
			width = 0,
			height = 0,
			parent = _this,
			parentControl = self,
			Onchange = Map3DSystem.Movie.MovieClipEditor.OnSliderBarChanged,
			OnMouseDownEvent = Map3DSystem.Movie.MovieClipEditor.OnMouseDownEvent,
			OnMouseUpEvent = Map3DSystem.Movie.MovieClipEditor.OnMouseUpEvent,
		}
		CommonCtrl.AddControl(self.name.."timeLine", timeLine);
		timeLine:Show(true);
		MovieClipEditor.OnSliderBarChanged(timeLine,0)		
		self.TimeLine = timeLine;
		
		_parent = ParaUI.GetUIObject(self.name.."container");
		-- line 2	
		_this = ParaUI.CreateUIObject("container", self.name.."line_2", self.alignment, self.left, 50, self.width, self.height-50);
		_this.background= "";
		_parent:AddChild(_this);
		

		self:CreateViewWnd(_this)	
		
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	 
end
function MovieClipEditor:CreateViewWnd(_parent)
	local ctl = CommonCtrl.TreeView:new{
		name = self.name.."treeView",
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		parent = _parent,
		DefaultNodeHeight = 22,
		ShowIcon = false,
		DrawNodeHandler = MovieClipEditor.DrawViewNodeHandler,	
	};
	ctl.MovieClipEditor = self;
	ctl:Show();
end

-- refresht he view 
function MovieClipEditor:RefreshViewWnd()
	local treeviewName = self.name.."treeView";
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl) then
		ctl:Update();
	end
end
function MovieClipEditor.DrawViewNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local ctl = CommonCtrl.GetControl(treeNode.TreeView.name);
	local editor = ctl.MovieClipEditor;
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 3;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	local frame_const_width,frame_const_height = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameWidth,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameHeight;	
	if(treeNode.layer)then			
		
		
		-- advance btn
		_this = ParaUI.CreateUIObject("button","advBtn", "_lt", left, top,16, 16);
		_this.tooltip = "代码编辑";
		_this.background = "Texture/3DMapSystem/common/mouse.png";
		_parent:AddChild(_this);
		_this.onclick = string.format(";Map3DSystem.Movie.MovieClipEditor.OnAdvanceItem(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		-- layer title
		local layer = treeNode.layer;
		_this=ParaUI.CreateUIObject("button","b","_lt", left+16, top, editor.layerTitleWidth-16, frame_const_height);
		_this.text = treeNode.Text or "";
		_this.background = ""; 
		_parent:AddChild(_this);
			
		-- click area to select this node
		_this=ParaUI.CreateUIObject("button","b","_lt", left+16, top, editor.layerTitleWidth-16, frame_const_height);
		_this.background = "";
		_this.onclick = string.format(";Map3DSystem.Movie.MovieClipEditor.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		if(treeNode.Selected) then	
			_parent.background = "Texture/alphadot.png"	
		else
			_parent.background = ""	
		end	
		
		_this=ParaUI.CreateUIObject("container","b","_lt", left+(editor.layerTitleWidth), top, nodeWidth -left-(editor.layerTitleWidth), frame_const_height);
		--_this.background = "";
		layer._uiParent = _this;
		layer.MovieClipEditorName = editor.name;
		layer:Draw();
		_parent:AddChild(_this);			
	end
end
function MovieClipEditor.OnAdvanceItem(sCtrlName, nodePath)
	if(not sCtrlName or not nodePath)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	if(treeNode and treeNode.layer)then
		local layer = treeNode.layer;
		NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/ScriptPanelPage.lua");
		Map3DSystem.Movie.ScriptPanelPage.Show(layer);
	end
end
function MovieClipEditor.OnToggleNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		
		
		-- click the node. 
		CommonCtrl.TreeView.OnClickNode(sCtrlName, nodePath);
		
		if(node.Expanded) then
			node:Collapse();
		else
			node:Expand();
		end
		node:SelectMe(true)
		--TODO:
		-- Map3DSystem.Movie.MovieListPage.SelectedNode = node;
	end
end

------------------------------------
-- about playing
------------------------------------
function MovieClipEditor:DoPlay()
	if(self.mcPlayer)then
		self.mcPlayer:Stop();
		self.mcPlayer:SetClip(self.Clip)
		self.mcPlayer:Play();
	end
end
function MovieClipEditor:DoResume()
	if(self.mcPlayer)then
		self.mcPlayer:Resume();
	end
end
function MovieClipEditor:DoPause()
	if(self.mcPlayer)then
		self.mcPlayer:Pause();
	end
end
function MovieClipEditor:DoStop()
	if(self.mcPlayer)then
		self.mcPlayer:Stop();
	end
end
function MovieClipEditor:GotoAndStop(frame)
	if(self.mcPlayer)then
		self.mcPlayer:GotoAndStop(frame);
	end
end
------------------------------------
-- about layer
------------------------------------
function MovieClipEditor:GetObjectLayer(targetProperty)
	local LayerList = self.Clip.LayerList
	if(not LayerList or not targetProperty)then return; end
	for k,v in ipairs(LayerList) do
		local layer = v;
		for __,clip in ipairs(layer.ClipList) do
			local TargetProperty = clip.TargetProperty;
			if(TargetProperty == targetProperty)then
				return layer;
			end
		end
	end
end
function MovieClipEditor:NewLayer()
	local layer = CommonCtrl.Animation.Motion.LayerManager:new();
	return layer;
end
function MovieClipEditor:AddLayer(layer,index)
	if(not layer)then return; end
	local treeviewName = self.name.."treeView";
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl) then
		local parentMcmlNode = layer["ParentMcmlNode"]
		local title = "";
		if(parentMcmlNode)then
			local titleNode = parentMcmlNode:GetChild("title");
			if(titleNode)then
				title = titleNode["TitleValue"];
			end
		end		
		local node = CommonCtrl.TreeNode:new({Selected = false,Text = title, Name = title,layer = layer});
		ctl.RootNode:AddChild(node,index);
		self.Clip:AddLayer(layer,index);
		ctl:Update(true,node);
	end
end
function MovieClipEditor:GetLayer(index)
	if(not index)then return; end
	
end
------------------------------------
-- about clip(Empty MovieClip and AnimationUsingKeyFrames)
------------------------------------
function MovieClipEditor:NewMovieClip()

end
function MovieClipEditor:AddMovieClip(clip,index)
	if(not clip)then return; end	
end
------------------------------------
-- about entity
------------------------------------
function MovieClipEditor:DeleteEntity(name)
	self.moviescript:DeleteAssetNodeByTargetName(name)
end
------------------------------------
-- about keyFrame
------------------------------------
function MovieClipEditor:MoveToPre()
	self:KeyFrameMove(-1);
end
function MovieClipEditor:MoveToNext()
	self:KeyFrameMove(1);
end
--@param direction: -1 is pre, 1 if next
function MovieClipEditor:KeyFrameMove(direction)
	if(self.selectedLayer and self.selectedKeyFrame and self.TimeLine)then
		local config = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config;
		local _curTimeRank = self.TimeLine._curTimeRank;
		local _curTimeRank_frame = config.framerate * _curTimeRank;
		local frame = self.selectedKeyFrame:GetKeyFrame();
		if(frame == 0)then return; end
		frame = frame + _curTimeRank_frame * direction;
		if(frame<0)then
			frame = 0;
		end
		local keyFrames = self.selectedLayer:GetChild(1);
		if(keyFrames)then
			local k,v;
			local removed = false;
			for k,v in ipairs(keyFrames.keyframes) do
				local hasframe = v:GetKeyFrame();
				if(frame == hasframe)then
					keyFrames:removeKeyframe(v)
					self.selectedKeyFrame:SetKeyFrame(frame);
					removed = true;
					break;
				end
				
			end
			if(not removed)then
				self.selectedKeyFrame:SetKeyFrame(frame);
			end
			keyFrames:SetMaxFrameNum();
			self.selectedLayer:Draw();
		end
	end
end
function MovieClipEditor:AddKeyFrame(keyFrames,keyFrame)
	if(not keyFrames or not keyFrame)then return; end
	keyFrames:addKeyframe(keyFrame);
end
function MovieClipEditor:RemoveKeyFrame(keyFrames,keyFrame)
	if(not keyFrames or not keyFrame)then return; end
	keyFrames:removeKeyframe(keyFrame);
end
function MovieClipEditor:RemoveSelectedKeyFrame()
	local selectedLayer = self.selectedLayer;
	local selectedKeyFrame = self.selectedKeyFrame;
	if(selectedLayer and selectedKeyFrame)then	
		local keyFrames = selectedLayer:GetChild(1)
		local frame = selectedKeyFrame:GetFrames();
		-- if frame >0 then delete
		if(frame >0)then
			self:RemoveKeyFrame(keyFrames,selectedKeyFrame);
			selectedLayer:Draw();
			
			--if(self.Clip.bindingContext)then
				--self.Clip.bindingContext:UpdateClassToMcmlNode();
			--end
		end
	end
end
function MovieClipEditor:CloneSelectedKeyFrame()
	if(not self.TimeLine)then return; end
	local keyTime = self.TimeLine:GetTime();
	if(not keyTime)then return; end
	local selectedLayer = self.selectedLayer;
	local selectedKeyFrame = self.selectedKeyFrame;
	if(selectedLayer and selectedKeyFrame)then	
		local keyFrames = selectedLayer:GetChild(1)
		local hasKeyFrame = keyFrames:hasKeyFrame(keyTime)
		if(not hasKeyFrame)then
			-- clone a keyframe
			local id = ParaGlobal.GenerateUniqueID();
			local new_keyFrame = commonlib.deepcopy(selectedKeyFrame);
			--local new_keyFrame = selectedKeyFrame:Clone(id);
				
			if(not new_keyFrame)then return ; end
			new_keyFrame.name = id;
			
			---------------------clone viewbox object---------------------------------
			local target = selectedKeyFrame:GetValue();
			local new_target = new_keyFrame:GetValue();
			if(target and new_target and target.Property == "BuildingTarget")then
				--new_target["InternalObj"] = target["InternalObj"];
			end
			--------------------------------------------------------------------------
			new_keyFrame:SetKeyTime(keyTime);	
				
			self:AddKeyFrame(keyFrames,new_keyFrame)
			selectedLayer:Draw();
					
			self:UpdateSelected(selectedLayer,new_keyFrame);
		end
	end
end
function MovieClipEditor:GetMouseSeletedKeyFrame(name)
	local LayerList = self.Clip.LayerList
	if(not LayerList or not name)then return; end
	local keyFrame;
	local frame = self.TimeLine:GetFrame()
	for k,v in ipairs(LayerList) do
		local layer = v;
			-- clip is AnimationUsingKeyFrames
			for __,clip in ipairs(layer.ClipList) do
				local targetName = clip.TargetName;
				if(targetName == name)then
					local keyFrame = clip:getCurrentKeyframe(frame)				
					return layer,keyFrame;
				end
			end
	end
end
function MovieClipEditor.OnSelectedKeyFrame(selfName,keyFrameName,keyTime,parentName)
	if(not selfName or not keyFrameName or not keyTime or not parentName)then return; end;
	local self = CommonCtrl.GetControl(selfName);
	if(not self)then return; end
	local LayerList = self.Clip.LayerList
	if(not LayerList)then return; end
	local selectedLayer
	local selectedKeyFrame;
	
	for k,v in ipairs(LayerList) do
		local layer = v;
		if(layer.name == parentName)then
			-- clip is AnimationUsingKeyFrames
			for __,clip in ipairs(layer.ClipList) do
				selectedKeyFrame = clip:hasKeyFrame(keyTime)
				if(selectedKeyFrame)then
					selectedLayer = layer;
					break;
				end
			end
		end
	end
	self:UpdateSelected(selectedLayer,selectedKeyFrame)
end
function MovieClipEditor:UpdateLayerAndKeyFrames(selectedLayer,selectedKeyFrame)
	if(not self.Clip)then return; end
	local k,v;
	for k,v in ipairs(self.Clip.LayerList) do
		local keyFrames = v:GetChild(1);
		if(keyFrames)then
			keyFrames:UpdateSelected(selectedKeyFrame)
		end
	end
end
function MovieClipEditor:UpdateSelected(selectedLayer,selectedKeyFrame)
	if(not selectedLayer and not selectedKeyFrame)then return; end
	self.selectedLayer = selectedLayer;
	self.selectedKeyFrame = selectedKeyFrame;
	if(self.selectedKeyFrame)then
		self:UpdateLayerAndKeyFrames(selectedLayer,selectedKeyFrame)
		local target = selectedKeyFrame:GetValue()
		self:DoCommand(target)
	end
end
function MovieClipEditor:DoCommand(target)
	if(not target)then return; end
	local property = target.Property;
	if(property)then
		--Map3DSystem.App.Commands.Call("File.CloseAllPropertyPanel");
		Map3DSystem.App.Commands.Call("File.Movie"..property,target);
	end
end
------------------------------------
-- about timeLine
------------------------------------
function MovieClipEditor.OnMouseDownEvent(timeLine)
	if(not timeLine or not timeLine.parentControl)then return; end
	local self = timeLine.parentControl;
end
function MovieClipEditor.OnMouseUpEvent(timeLine)
	if(not timeLine or not timeLine.parentControl)then return; end
	local self = timeLine.parentControl;
end
function MovieClipEditor.MC_MotionStart(mc)
	if(not mc or not mc.MovieClipEditor)then return; end
	local self = mc.MovieClipEditor;
	self:UpdateTimingText(mc)
end
function MovieClipEditor.MC_MotionPause(mc)
	if(not mc or not mc.MovieClipEditor)then return; end
	local self = mc.MovieClipEditor;
	self:UpdateTimingText(mc)
end
function MovieClipEditor.MC_MotionResume(mc)
	if(not mc or not mc.MovieClipEditor)then return; end
	local self = mc.MovieClipEditor;
	self:UpdateTimingText(mc)
end
function MovieClipEditor.MC_MotionStop(mc)
	if(not mc or not mc.MovieClipEditor)then return; end
	local self = mc.MovieClipEditor;
	self:UpdateTimingText(mc)
	self:UpdateSliderBar(mc)
end
function MovieClipEditor.MC_MotionEnd(mc)
	if(not mc or not mc.MovieClipEditor)then return; end
	local self = mc.MovieClipEditor;
	self:UpdateTimingText(mc)
	self:UpdateSliderBar(mc)
end
function MovieClipEditor.MC_MotionTimeChange(mc)
	if(not mc or not mc.MovieClipEditor)then return; end
	local self = mc.MovieClipEditor;
	self:UpdateTimingText(mc)
	self:UpdateSliderBar(mc)
end
function MovieClipEditor:UpdateSliderBar(mc)
	if(not mc)then return; end
	local frame = mc:GetFrame();
	local duration = mc:GetDuration();	
	if(duration == 0) then return; end
	local timeLine = self.TimeLine;
	if(timeLine)then
		 timeLine:UpdateBarValue(frame)
	end
	self:UpdateTimingText(mc)
end
function MovieClipEditor:UpdateTimingText(mc)
	if(not mc)then return; end
	local frame = mc:GetFrame();
	local time = CommonCtrl.Animation.Motion.TimeSpan.GetTime(frame);
	local _this = ParaUI.GetUIObject(self.name.."timeText");
	if(_this:IsValid())then
		_this.text = time;
	end
end
function MovieClipEditor.OnSliderBarChanged(timeLine,value)
	if(not timeLine or not timeLine.parentControl)then return; end
	local self = timeLine.parentControl;
	local txt = ParaUI.GetUIObject(self.name.."timeText");
	if(txt:IsValid() and timeLine.parentControl)then
		txt.text = timeLine:GetTime();
	end
	self:GotoAndStop(timeLine:GetFrame());
end
function MovieClipEditor:DoZoomOut()
	if(not self.TimeLine)then return; end
	self.TimeLine:ZoomOut();
	self:RefreshViewWnd();
end
function MovieClipEditor:DoZoomIn()
	if(not self.TimeLine)then return; end
	self.TimeLine:ZoomIn();
	self:RefreshViewWnd();
end
------------------------------------------------------------------------------------------------------------
-- TargetKeyFramesFactory
------------------------------------------------------------------------------------------------------------
local TargetKeyFramesFactory = {
}
commonlib.setfield("Map3DSystem.Movie.TargetKeyFramesFactory",TargetKeyFramesFactory);
------------------------------------------------------------------------------------------------------------
function TargetKeyFramesFactory.BuildObject(mcmlName,params,keyTime,movieEditor)
	local self = TargetKeyFramesFactory;
	local keyframes;
	if(mcmlName == "pe:movie-camera")then
		keyframes = self.__Build("CameraTarget",params,keyTime,"",movieEditor)
	elseif(mcmlName == "pe:movie-sky")then
		keyframes = self.__Build("SkyTarget",params,keyTime,"",movieEditor) 
	elseif(mcmlName == "pe:movie-land")then
		keyframes = self.__Build("LandTarget",params,keyTime,"Discrete",movieEditor) 
	elseif(mcmlName == "pe:movie-ocean")then
		--keyframes = self.BuildOcean({},keyTime) 
		keyframes = self.__Build("OceanTarget",params,keyTime,"",movieEditor)
	elseif(mcmlName == "pe:movie-caption")then
		keyframes = self.__Build("CaptionTarget",params,keyTime,"Discrete",movieEditor) 
	elseif(mcmlName == "pe:movie-actor")then
		keyframes = self.__Build("ActorTarget",params,keyTime,"",movieEditor) 
	elseif(mcmlName == "pe:movie-building")then
		keyframes = self.__Build("BuildingTarget",params,keyTime,"",movieEditor)  
	elseif(mcmlName == "pe:movie-plant")then
		keyframes = self.__Build("PlantTarget",params,keyTime,"",movieEditor)  
	elseif(mcmlName == "pe:movie-effect")then
		keyframes = self.__Build("EffectTarget",params,keyTime,"Discrete",movieEditor)  
	elseif(mcmlName == "pe:movie-sound")then
		keyframes = self.__Build("SoundTarget",params,keyTime,"Discrete",movieEditor)  
	elseif(mcmlName == "pe:movie-control")then
		keyframes = self.__Build("ControlTarget",params,keyTime,"",movieEditor)  
	end
	
	return keyframes;
end
function TargetKeyFramesFactory.__BuildKeyFrame(keyFrameType,targetType,params,timeLineName)
	local keyFrame;
	if(keyFrameType == "Discrete")then
		keyFrame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new();
		--if(targetType == "BuildingTarget" or targetType == "PlantTarget" or targetType == "ActorTarget")then
			--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/DiscreteMovieKeyFrame.lua");
			--keyFrame = Map3DSystem.App.Inventor.DiscreteMovieKeyFrame:new();
			--keyFrame:__Initialization(params)
			--keyFrame:InitKeyFrame(timeLineName);
		--else
			--keyFrame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new();
		--end
	else
		keyFrame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new();
		--if(targetType == "BuildingTarget" or targetType == "PlantTarget" or targetType == "ActorTarget")then
			--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/LinearMovieKeyFrame.lua");
			--keyFrame = Map3DSystem.App.Inventor.LinearMovieKeyFrame:new();
			--keyFrame:__Initialization(params)
			--keyFrame:InitKeyFrame(timeLineName);
		--else
			--keyFrame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new();
		--end
	end
	return keyFrame;
end
function TargetKeyFramesFactory.__Build(type,params,keyTime,keyFrameType,movieEditor)
	local keyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new();
	keyFrames.TargetName = type;
	keyFrames.TargetProperty = type;
	local timeLineName = movieEditor.name.."timeLine";
	local keyFrame = TargetKeyFramesFactory.__BuildKeyFrame(keyFrameType,type,params,timeLineName);	
	local target;
	if(type == "CameraTarget")then
		target = CommonCtrl.Animation.Motion.CameraTarget:new()
	elseif(type == "OceanTarget")then
		target = CommonCtrl.Animation.Motion.OceanTarget:new()
	elseif(type == "LandTarget")then
		target = CommonCtrl.Animation.Motion.LandTarget:new()
	elseif(type == "SkyTarget")then
		target = CommonCtrl.Animation.Motion.SkyTarget:new()
	elseif(type == "CaptionTarget")then
		target = CommonCtrl.Animation.Motion.CaptionTarget:new()
	elseif(type == "ActorTarget")then
		target = CommonCtrl.Animation.Motion.ActorTarget:new()
		if(params)then
			keyFrames.TargetName = params.name;
			keyFrames.TargetProperty = params.name;
		end
	elseif(type == "SoundTarget")then
		target = CommonCtrl.Animation.Motion.SoundTarget:new()
	elseif(type == "BuildingTarget")then
		target = CommonCtrl.Animation.Motion.BuildingTarget:new()
		if(params)then
			keyFrames.TargetName = params.name;
			keyFrames.TargetProperty = params.name;
		end
	elseif(type == "PlantTarget")then
		target = CommonCtrl.Animation.Motion.PlantTarget:new()
		if(params)then
			keyFrames.TargetName = params.name;
			keyFrames.TargetProperty = params.name;
		end
	elseif(type == "EffectTarget")then
		target = CommonCtrl.Animation.Motion.EffectTarget:new()
	elseif(type == "ControlTarget")then
		target = CommonCtrl.Animation.Motion.ControlTarget:new()
		if(params)then
			keyFrames.TargetName = params.name;
			keyFrames.TargetProperty = params.name;
		end
	end
	target:GetDefaultProperty(params);
	if(not keyTime)then
		keyTime = "00:00:00";
	end
	keyFrame:SetKeyTime(keyTime)
	keyFrame:SetValue(target);
	
	keyFrames:addKeyframe(keyFrame);
	
	return keyFrames;
end
