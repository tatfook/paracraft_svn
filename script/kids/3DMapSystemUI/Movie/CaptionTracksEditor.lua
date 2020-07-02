--[[
Title: caption tracks editor
Author(s): Leio Zhang
Date: 2008/9/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/CaptionTracksEditor.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Storyboard.lua");
NPL.load("(gl)script/ide/commonlib.lua");
local CaptionTracksEditor = {
	name = "CaptionTracksEditor_instance",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	parent = nil,
	container_bg = nil, -- the background of container,
	canDrag = true,
	showInputBar = true,
	canEdit = true,
	
	_dataSource = nil,
	_txtMapping = nil,
}
commonlib.setfield("Map3DSystem.Movie.CaptionTracksEditor",CaptionTracksEditor);
function CaptionTracksEditor:new (o)
	o = o or {} 
	setmetatable(o, self)
	self.__index = self
	o:Initialization()
	return o
end
function CaptionTracksEditor:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
	self._txtMapping = {};
	self.timeValues = {hours = 0,mins = 0,secs = 0,min_hours = 0,min_mins = 0,min_secs = 0,}
	self.bindingContext = nil;
	CommonCtrl.AddControl(self.name,self)
end
function CaptionTracksEditor:Show(bShow)
	local _this = ParaUI.GetUIObject(self.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", self.name, self.alignment, self.left, self.top, self.width, self.height);
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
		local left,top,width,height = 5,5,self.width,self.height
		local var_left,var_top,var_width,var_height = 0,0,0,0
		local space = 5;
		if(self.showInputBar)then
			var_left,var_top,var_width,var_height = 0,0,60,30
			
			----input_time_text
			--_this = ParaUI.CreateUIObject("text", self.name.."input_time_text", "_lt", left,top,60,var_height)
			--_this.text="";
			--_parent:AddChild(_this);
			NPL.load("(gl)script/ide/NumericUpDown.lua");
			-- hours
			local ctl = CommonCtrl.NumericUpDown:new{
				name = self.name.."NumericUpDown_1",
				alignment = "_lt",
				left = left,
				top = top,
				width = 40,
				height = var_height,
				parent = _parent,
				value = 0, -- current value
				valueformat = "%d",
				min = 0,
				max = 60,
				min_step = 1, 
				canDrag = self.canDrag,
			};
			CommonCtrl.AddControl(ctl.name,ctl)
			ctl:Show();
			-- mins
			ctl = CommonCtrl.NumericUpDown:new{
				name = self.name.."NumericUpDown_2",
				alignment = "_lt",
				left = left+45,
				top = top,
				width = 40,
				height = var_height,
				parent = _parent,
				value = 0, -- current value
				valueformat = "%d",
				min = 0,
				max = 60,
				min_step = 1, 
				canDrag = self.canDrag,
			};
			CommonCtrl.AddControl(ctl.name,ctl)
			ctl:Show();
			-- seconds
			ctl = CommonCtrl.NumericUpDown:new{
				name = self.name.."NumericUpDown_3",
				alignment = "_lt",
				left = left+90,
				top = top,
				width = 40,
				height = var_height,
				parent = _parent,
				value = 0, -- current value
				valueformat = "%.1f",
				min = 0,
				max = 60,
				min_step = 0.1, 
				canDrag = self.canDrag,
			};
			CommonCtrl.AddControl(ctl.name,ctl)
			ctl:Show();
			self:SetBindingContext()
			--input_text
			_this = ParaUI.CreateUIObject("imeeditbox", self.name.."input_text", "_lt", left+140,top,self.width-var_width-140,var_height)
			_this.text="";
			_parent:AddChild(_this);
			
			--add btn
			_this = ParaUI.CreateUIObject("button", self.name.."add_btn", "_rt", -var_width+space,top,var_width-space,var_height)
			_this.text="增加";
			_this.onclick = string.format(";Map3DSystem.Movie.CaptionTracksEditor.OnAdd(%q);", self.name);
			_parent:AddChild(_this);
		end
		left,top,width,height = left,top+var_height,self.width,self.height-var_height
		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = self.name.."MultiLineEditbox",
			alignment = "_lt",
			left = left,
			top = top+space,
			width = width-10,
			height = height-10-space,
			WordWrap = false,
			parent = _parent,
			ShowLineNumber = true,
			ReadOnly = not self.canEdit,
			syntax_map = CommonCtrl.MultiLineEditbox.syntax_map_NPL,
		};
		ctl:Show();		
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	 
end
-- @param dataSource: dataSource must be a StringAnimationUsingKeyFrames
function CaptionTracksEditor:SetDataSource(dataSource)
	if(not dataSource)then return; end
	self._dataSource = dataSource;	
end
function CaptionTracksEditor:GetDataSource()
	return self._dataSource;	
end
function CaptionTracksEditor:SetBindingContext()
	if(not self.bindingContext)then
		self.bindingContext = commonlib.BindingContext:new();
		self.bindingContext:AddBinding(self.timeValues, "hours", self.name.."NumericUpDown_1", commonlib.Binding.ControlTypes.IDE_numeric, "value")
		self.bindingContext:AddBinding(self.timeValues, "mins", self.name.."NumericUpDown_2", commonlib.Binding.ControlTypes.IDE_numeric, "value")
		self.bindingContext:AddBinding(self.timeValues, "secs", self.name.."NumericUpDown_3", commonlib.Binding.ControlTypes.IDE_numeric, "value")
		self.bindingContext:UpdateDataToControls();
	end
end
function CaptionTracksEditor.OnAdd(sControlName)
	local self = CommonCtrl.GetControl(sControlName)
	if(not self)then return; end
	local input_text = ParaUI.GetUIObject(self.name.."input_text");
	if(input_text:IsValid() and self.bindingContext)then
		self.bindingContext:UpdateControlsToData();	
		local h =self.timeValues["hours"] or 0
		local m = self.timeValues["mins"] or 0
		local s = self.timeValues["secs"] or 0
		local keyTime = h..":"..m..":"..s;
		local txt = input_text.text;
		self:InsertValue(keyTime,txt)
		input_text.text = "";
	end
end
function CaptionTracksEditor:InsertValue(keyTime,txt)
	if(not keyTime or not txt)then return; end
	self._txtMapping[keyTime] = txt;
	
	local temp = {};	
	local t_keyTime,value;
	for t_keyTime,value in pairs(self._txtMapping) do
		local frame = CommonCtrl.Animation.TimeSpan.GetFrames(t_keyTime);
		table.insert(temp,{frame = frame,keyTime = t_keyTime,txt = value});
	end
	local compareFunc = compareFunc or CommonCtrl.TreeNode.GenerateLessCFByField("frame");
	-- quick sort
	table.sort(temp, compareFunc)	
	local result = "";
	for __,value in ipairs(temp) do
		local value_kyeTime = value["keyTime"];
		local value_txt = value["txt"];
		local _txt = string.format("[%s]%s",value_kyeTime,value_txt);
		result = result.._txt.."\r\n";		
	end 
	self:SetResultTxt(result)
end
function CaptionTracksEditor:DoSave()
	self:UpdateTxtToDataSource()
end
function CaptionTracksEditor:SetKeyFrame(keyFrame)
	if(not keyFrame)then return; end
	self.keyFrame = keyFrame;
	self:SetCurTimeTxt()
end
function CaptionTracksEditor:SetCurTimeTxt()	
	local keyTime = CommonCtrl.Animation.TimeSpan.GetTime(self.keyFrame);
	if(not self.bindingContext or not keyTime)then return; end
	self:UpdateTimeValues(keyTime)
	self.bindingContext:UpdateDataToControls();
end
function CaptionTracksEditor:UpdateTimeValues(time,min)
	if(not time)then return; end
	local __,__,h,m,s = string.find(time,"(.+):(.+):(.+)");
	h = tonumber(h) or 0;
	m = tonumber(m) or 0;
	s = tonumber(s) or 0;
	self.timeValues["hours"] = h;
	self.timeValues["mins"] = m;
	self.timeValues["secs"] = s;
	if(min)then
		ctl = CommonCtrl.GetControl(self.name.."NumericUpDown_1")
		ctl.min = h;
		ctl = CommonCtrl.GetControl(self.name.."NumericUpDown_2")
		ctl.min = m;
		ctl = CommonCtrl.GetControl(self.name.."NumericUpDown_3")
		ctl.min = s;
	end
	self.bindingContext:UpdateDataToControls();
	
end
function CaptionTracksEditor:SetResultTxt(txt)
	if(not txt)then txt=""; end
	local ctl = CommonCtrl.GetControl(self.name.."MultiLineEditbox");
	if(ctl)then
		ctl:SetText(txt)
	end
end
function CaptionTracksEditor:GetResultTxt()
	local ctl = CommonCtrl.GetControl(self.name.."MultiLineEditbox");
	if(ctl)then
		return ctl:GetText() or "";
	end
end
function CaptionTracksEditor:UpdateDataSourceToTxt()
	local frames = self:GetDataSource();
	if(not frames)then return; end
	local frame;
	local result = "";
	for __,frame in ipairs(frames.keyframes) do
		local keyTime = frame["KeyTime"];
		local text = frame["Value"];
		self:InsertValue(keyTime,text)
	end
	self:SetCurTimeTxt()
end
function CaptionTracksEditor:UpdateTxtToDataSource()
	local result = self:GetResultTxt()
	if(result and self._dataSource)then
		-- self._dataSource must be a StringAnimationUsingKeyFrames
		self._dataSource:clear();
		CommonCtrl.Animation.Reverse.LrcToMcml(result,self._dataSource)
	end
end
