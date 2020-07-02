--[[
Title: terrain data editor
Author(s): SunLingfeng
Date: 2012/4/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerrainInfoPage.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerrainBrush.lua");


local TerrainInfoPage = commonlib.gettable("Map3DSystem.App.Env.TerrainInfoPage");

TerrainInfoPage.mapData = 0;
TerrainInfoPage.paintTimerInterval = 100;
TerrainInfoPage.brush = Map3DSystem.App.Env.TerrainBrush:new({
			filtername = "TerrInfo",
			BrushSize = 2, 
		});

--0xFFFFFFFF
TerrainInfoPage.emptyConfig = {id = 0,mask=4294967295,bitOffset=0};
--0xFFFFFFFE, bit pos:1,bit width:1,value:[0,1],offset:0
TerrainInfoPage.walkRegionConfig = {id = 1,mask=4294967294,bitOffset=0,maxValue=1};
--mask:0xFFFFFFC1, position:2-6,bit width:5,value:[0,31],offset:1
TerrainInfoPage.bgSoundConfig = {id = 2,mask=4294967233,bitOffset=1,maxValue=31};
--mask:0xFFFFF83F,position:7-11,bitWidth:5,value:[0,31],offset:6
TerrainInfoPage.ambSoundConig = {id = 3,mask=4294965311,bitOffset=6, maxValue=31};
--mask:0xFFFF07FF,position:12-16,bitWidth:5,value:[0,31],offset:11
TerrainInfoPage.terrainTypeConig = {id = 4,mask = 4294903807,bitOffset=11,maxValue=31};
--mask:0xFF00FFFF,position:17-24,bitWidht:8,value:[0,255],offset:16
TerrainInfoPage.wpRegionConfig = {id = 5,mask = 4278255615,bitOffset = 16,maxValue=255};

TerrainInfoPage.currentConfig = TerrainInfoPage.emptyConfig;
TerrainInfoPage.isSampleMode = false;

function TerrainInfoPage.OnInit()
	TerrainInfoPage.page = document:GetPageCtrl();
end

function TerrainInfoPage.OnSetBrushSize(value)
	TerrainInfoPage.brush.BrushSize = value;
end

function TerrainInfoPage.OnKeyUp(name,mcmlNode)
	local self = TerrainInfoPage;
	local editbox = TerrainInfoPage.page:FindUIControl(name);
	if(editbox:IsValid() == true)then
		local value = tonumber(editbox.text);
		if(value == nil)then
			return;
		end

		if(name == "dataEdit")then
			if(value > self.currentConfig.maxValue)then value=self.currentConfig.maxValue;end
			if(value < 0)then value=0; end;
			TerrainInfoPage.mapData = value;

			local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
			if(statusLable:IsValid() == true)then
				if(self.currentConfig.id == self.walkRegionConfig.id)then
					statusLable.text = "编辑山地区域，value:"..value..",maxValue:"..self.currentConfig.maxValue;
				elseif(self.currentConfig.id == self.wpRegionConfig.id)then
					statusLable.text = "编辑寻路区域，value:"..value..",maxValue:"..self.currentConfig.maxValue;
				elseif(self.currentConfig.id == self.bgSoundConfig.id)then
					statusLable.text = "编辑背景音乐区域，value:"..value..",maxValue:"..self.currentConfig.maxValue;
				elseif(self.currentConfig.id == self.ambSoundConig.id)then
					statusLable.text = "编辑环境音乐区域，value:"..value..",maxValue:"..self.currentConfig.maxValue;
				elseif(self.currentConfig.id == self.emptyConfig.id)then
					statusLable.text = "┑(￣▽ ￣)┍";
				end
			end
		end
	end
end

function TerrainInfoPage.OnSwitchEditMode(name)
	att=ParaTerrain.GetAttributeObject();
	att:SetField("UseGeoMipmapLod",true);
	att:SetField("IsEditorMode",true);

	local self = TerrainInfoPage;
	if(name == "walkBtn")then
		if(self.currentConfig.id == self.walkRegionConfig.id)then
			self.currentConfig = self.emptyConfig;
		else
			self.currentConfig = self.walkRegionConfig;
			local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
			if(statusLable:IsValid() == true)then
				statusLable.text = "编辑山地区域，value:1,maxValue:"..self.currentConfig.maxValue;
			end
		end
	elseif(name == "wpBtn")then
		if(self.currentConfig.id == self.wpRegionConfig.id)then
			self.currentConfig = self.emptyConfig;
		else
			self.currentConfig = self.wpRegionConfig;
						
			local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
			if(statusLable:IsValid() == true)then
				statusLable.text = "编辑寻路区域，value:1,maxValue:"..self.currentConfig.maxValue;
			end
		end
	elseif(name == "bgSoundBtn")then
		if(self.currentConfig.id == self.bgSoundConfig.id)then
			self.currentConfig = self.emptyConfig;
		else
			self.currentConfig = self.bgSoundConfig;
			
			local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
			if(statusLable:IsValid() == true)then
				statusLable.text = "编辑背景音乐区域，value:1,maxValue:"..self.currentConfig.maxValue;
			end
		end
	elseif(name == "ambSoundBtn")then
		if(self.currentConfig.id == self.ambSoundConig.id)then
			self.currentConfig = self.emptyConfig;
		else
			self.currentConfig = self.ambSoundConig;
			
			local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
			if(statusLable:IsValid() == true)then
				statusLable.text = "编辑环境音乐区域，value:1,maxValue:"..self.currentConfig.maxValue;
			end
		end
	end

	if(self.currentConfig ~= self.emptyConfig)then
		self.UpdateBrush();	
		self.BeginEditing();
		self.page:SetValue("showMeshCbx",true);

		self.mapData = 1;
		local editbox = TerrainInfoPage.page:FindUIControl("dataEdit");
		if(editbox:IsValid() == true)then
			editbox.text = "1";
			editbox.enabled = true;
		end
	else
		self.EndEditing();
		self.page:SetValue("showMeshCbx",false);
		local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
		if(statusLable:IsValid() == true)then
			statusLable.text = "┑(￣▽ ￣)┍ ";
		end

		self.mapData = 0;
		local editbox = TerrainInfoPage.page:FindUIControl("dataEdit");
		if(editbox:IsValid() == true)then
			editbox.text = "-";
			editbox.enabled = false;
		end
	end

	ParaTerrain.SetVisibleDataMask(self.currentConfig.mask,self.currentConfig.bitOffset);
end

function TerrainInfoPage.OnSampleDataBtn()
	local self = TerrainInfoPage;
	if(self.currentConfig.id == 0)then
		return;
	end
	
	if(self.isSampleMode)then
		self.isSampleMode = false;
	else
		self.isSampleMode = true;
	end
end


function TerrainInfoPage.BeginEditing()
	TerrainInfoPage.timer = TerrainInfoPage.timer or commonlib.Timer:new({callbackFunc = TerrainInfoPage.OnBrushTimer});
	ParaCamera.GetAttributeObject():SetField("EnableMouseLeftButton", false);
	TerrainInfoPage.RegisterHooks();
end

function TerrainInfoPage.EndEditing()
	ParaCamera.GetAttributeObject():SetField("EnableMouseLeftButton", true);
	TerrainInfoPage.UnregisterHooks();
	if(TerrainInfoPage.timer) then
		TerrainInfoPage.timer:Change();
	end
	TerrainInfoPage.brush:ClearMarker();
end

function TerrainInfoPage.OnBrushTimer()
	local self = TerrainInfoPage;
	self.RefreshMarker();
	if(self.isSampleMode)then
		local sample = ParaTerrain.GetTerrainData(self.brush.x,self.brush.z,self.currentConfig.mask,self.currentConfig.bitOffset);
		TerrainInfoPage.mapData = sample;

		local editbox = TerrainInfoPage.page:FindUIControl("dataEdit");
		if(editbox:IsValid() == true)then
			editbox.text = tostring(sample);
		end
	
		local statusLable = TerrainInfoPage.page:FindUIControl("statusLb");
		if(statusLable:IsValid() == true)then
			if(self.currentConfig.id == self.walkRegionConfig.id)then
				statusLable.text = "编辑山地区域，value:"..sample..",maxValue:"..self.currentConfig.maxValue;
			elseif(self.currentConfig.id == self.wpRegionConfig.id)then
				statusLable.text = "编辑寻路区域，value:"..sample..",maxValue:"..self.currentConfig.maxValue;
			elseif(self.currentConfig.id == self.bgSoundConfig.id)then
				statusLable.text = "编辑背景音乐区域，value:"..sample..",maxValue:"..self.currentConfig.maxValue;
			elseif(self.currentConfig.id == self.ambSoundConig.id)then
				statusLable.text = "编辑环境音乐区域，value:"..sample..",maxValue:"..self.currentConfig.maxValue;
			elseif(self.currentConfig.id == self.emptyConfig.id)then
				statusLable.text = "┑(￣▽ ￣)┍";
			end
		end
	else
		ParaTerrain.PaintTerrainData(self.brush.x,self.brush.z,self.brush.BrushSize,self.mapData,self.currentConfig.mask,self.currentConfig.bitOffset);
	end
end


function TerrainInfoPage.RefreshMarker()
	if(TerrainInfoPage.currentConfig.id ~= 0)then
		TerrainInfoPage.brush:RefreshMarker();
	end
end

function TerrainInfoPage.UpdateBrush(brush)
	if(brush)then
		commonlib.partialcopy(TerrainInfoPage.brush,brush);
	end

	TerrainInfoPage.RefreshMarker();
end

function TerrainInfoPage.RegisterHooks()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.SetWindowsHook({hookType = hookType, 		 
		hookName = "TerraInfo_mouse_down_hook", appName = "input", wndName = "mouse_down", 
		callback = TerrainInfoPage.OnMouseDown});
	CommonCtrl.os.hook.SetWindowsHook({hookType = hookType, 		 
		hookName = "TerraInfo_mouse_move_hook", appName = "input", wndName = "mouse_move",
		callback = TerrainInfoPage.OnMouseMove});
	CommonCtrl.os.hook.SetWindowsHook({hookType = hookType, 		 
		hookName = "TerraInfo_mouse_up_hook", appName = "input", wndName = "mouse_up",
		callback = TerrainInfoPage.OnMouseUp});
	CommonCtrl.os.hook.SetWindowsHook({hookType = hookType, 		 
		hookName = "TerraInfo_key_down_hook", appName = "input", wndName = "key_down",
		callback = TerrainInfoPage.OnKeyDown});
end

function TerrainInfoPage.UnregisterHooks()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TerraInfo_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TerraInfo_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TerraInfo_mouse_up_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TerraInfo_key_down_hook", hookType = hookType});
end

function TerrainInfoPage.OnMouseDown(nCode, appName, msg)
	if(nCode==nil) then return end
	
	if(Map3DSystem.InputMsg.mouse_button == "left") then
		if(TerrainInfoPage.timer) then
			TerrainInfoPage.timer:Change(0, TerrainInfoPage.paintTimerInterval)
		end

		local pt = ParaScene.MousePick(70, "point"); -- pick a object
		if(pt:IsValid())then
			local x,y,z = pt:GetPosition();
			TerrainInfoPage.brush.x1 = x;
			TerrainInfoPage.brush.z1 = z;
		end	
		return;
	end
	
	return nCode; 
end

function TerrainInfoPage.OnMouseMove(nCode, appName, msg)
	if(nCode==nil) then return end
	local input = Map3DSystem.InputMsg;
	
	local pt = ParaScene.MousePick(70, "point"); -- pick a object
	if(pt:IsValid())then
		local x,y,z = pt:GetPosition();
		TerrainInfoPage.UpdateBrush({x=x,y=y,z=z});
		return;
	end	
	return nCode; 
end

function TerrainInfoPage.OnMouseUp(nCode, appName, msg)
	if(nCode==nil) then return end
	
	if(Map3DSystem.InputMsg.mouse_button == "left") then
		if(TerrainInfoPage.timer) then
			TerrainInfoPage.timer:Change()
		end

		TerrainInfoPage.brush.x1= nil;
		TerrainInfoPage.brush.z1= nil;
		return
	end	
	return nCode; 
end

function TerrainInfoPage.OnKeyDown(nCode, appName, msg)
	if(nCode==nil) then return end
	if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE))then
		-- exit editing mode. 
		TerrainInfoPage.EndEditing();
		return
	end
	return nCode; 
end

function  TerrainInfoPage.OnClickShowMesh(bChecked)
	if(bChecked)then
		ParaTerrain.SetVisibleDataMask(TerrainInfoPage.currentConfig.mask,TerrainInfoPage.currentConfig.bitOffset);
	else
		ParaTerrain.SetVisibleDataMask(4294967295,0);
	end
end


function TerrainInfoPage.OnClickCollision(bChecked)
	att=ParaTerrain.GetAttributeObject();
	att:SetField("AllowSlopeCollision",bChecked);
end