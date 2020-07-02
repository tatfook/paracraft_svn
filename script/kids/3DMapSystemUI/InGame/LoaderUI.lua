--[[
Title: Loader UI: animated when scene is loading.
Author(s): LiXizhi
Date: 2006/9/29, refactored 2008.10.27
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
-- if items are not set, we will use default.
Map3DSystem.UI.LoaderUI.items = {
		{name = "Map3DSystem.UI.LoaderUI.bg", type="container",bg="Texture/3DMapSystem/Loader/loading_bg.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.logoTxt", type="container",bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-512, top=-32, width=512, height=32, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.logo", type="container",bg="Texture/3DMapSystem/brand/paraworld_text_256X128.png", alignment = "_ct", left=-256/2, top=-128/2, width=256, height=128, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",alignment = "_ct", left=-100, top=100, width=200, height=22, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.text", type="text", text=L"Loading ...", alignment = "_ct", left=-100+10, top=100+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "Map3DSystem.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/3DMapSystem/Loader/progressbar_filled.png:7 7 13 7", alignment = "_ct", left=-100, top=100, width=20, max_width=200, height=22,anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
}
Map3DSystem.UI.LoaderUI.Start(100);
Map3DSystem.UI.LoaderUI.SetProgress(40);
Map3DSystem.UI.LoaderUI.SetProgress(90);
Map3DSystem.UI.LoaderUI.SetProgress(100);
Map3DSystem.UI.LoaderUI.End();
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

local LoaderUI = {
	name = "LoaderUI_progress",
	TotalSteps = 100,
	CurrentStep = 0,
	-- whether anims are applied
	use_animation = true,
	-- in milliseconds for fade out animation. 
	fade_in_out_anim_interval = 500,
	-- parent name 
	parent = nil,
	-- UI elements
	items = {
		{name = "Map3DSystem.UI.LoaderUI.bg", type="container",bg="Texture/3DMapSystem/Loader/loading_bg.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.logoTxt", type="container",bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-512, top=-32, width=512, height=32, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.logo", type="container",bg="Texture/3DMapSystem/brand/paraworld_text_256X128.png", alignment = "_ct", left=-256/2, top=-128/2, width=256, height=128, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",alignment = "_ct", left=-100, top=100, width=200, height=22, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Map3DSystem.UI.LoaderUI.text", type="text", text=L"Loading ...", alignment = "_ct", left=-100+10, top=100+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "Map3DSystem.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/3DMapSystem/Loader/progressbar_filled.png:7 7 13 7", alignment = "_ct", left=-100, top=100, width=20, max_width=200, height=22,anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	},
	-- progress bar id
	bar_id = -1,
};
commonlib.setfield("Map3DSystem.UI.LoaderUI", LoaderUI);



-- call this function to start the progress.
function LoaderUI.Start(nTotalSteps)
	local self = LoaderUI;
	if(nTotalSteps == nil) then
		nTotalSteps = 100;
	end
	self.TotalSteps = nTotalSteps;
	self.CurrentStep = 0;
	local _this, _parent;
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		_parent=ParaUI.CreateUIObject("container",self.name, "_fi",0,0,0,0);
		_parent.background="";
		_parent.zorder = 99;
		if(self.parent==nil) then
			_parent:AttachToRoot();
		else
			self.parent:AddChild(_parent);
		end
		
		--
		-- create UI controls
		--		
		local _, info;
		for _, info in ipairs(self.items) do
			_this=ParaUI.CreateUIObject(info.type,info.name, info.alignment,info.left,info.top,info.width,info.height);
			_this.background=info.bg;
			
			if(info.color) then
				_this.color=info.color;
			end	
			if(info.text) then
				_this.text=info.text;
			end
			if(info.texts) then
				local r = math.random(1, #(info.texts) * 100);
				_this.text = info.texts[math.ceil(r / 100)];
			end
			if(info.IsProgressBar)then
				self.bar_id = _this.id;
				self.width = info.max_width;
			end
			if(info.type == "text" and info.color) then
				_guihelper.SetFontColor(_this, info.color);
			end
			
			_parent:AddChild(_this);
		end
		
		--
		-- bind it to animation engine
		--
		NPL.load("(gl)script/ide/Transitions/TweenLite.lua");
		self.fadeout_tween = self.fadeout_tween or CommonCtrl.TweenLite:new{
			instance_id = self.name,
			duration = self.fade_in_out_anim_interval,
			ApplyAnim = true,
			props = {alpha = 0,},
			OnEndFunc = function(self)
				ParaUI.Destroy(self.instance_id);
			end,
		};
	end
	
	if(self.use_animation) then
		_this.colormask = "255 255 255 255";
		_this:ApplyAnim();
	end	
end	

--[[ set the current progress
@param CurrentStep: current progress, such as 20, 40, 100,
@param disableRender: if nil, the GUI will be forced to render to reflect the changes.
]]
function LoaderUI.SetProgress(CurrentStep, disableRender)
	local self = LoaderUI;
	self.CurrentStep = CurrentStep;
	
	local _this = ParaUI.GetUIObject(self.bar_id);
	if(_this:IsValid()) then
		_this.width = self.width*self.CurrentStep/self.TotalSteps;
	end	
	if(not disableRender) then
		ParaEngine.ForceRender();
	end
end

function LoaderUI.End()
	local self = LoaderUI;
	if(self.use_animation and self.fadeout_tween)then
		self.fadeout_tween:Start();
	else
		ParaUI.Destroy(self.name);
	end
end
