--[[
Title: Environment sky page
Author(s): LiXizhi
Date: 2008/6/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/SkyPage.lua");
-- call below to load window
Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	url="script/kids/3DMapSystemUI/Env/SkyPage.html", name="SkyPage", 
	app_key=Map3DSystem.App.appkeys["Env"], 
	isShowTitleBar = false, 
	isShowToolboxBar = false, 
	isShowStatusBar = false, 
	initialWidth = 200, 
	alignment = "Left", 
});
------------------------------------------------------------
]]

local SkyPage = {};
commonlib.setfield("Map3DSystem.App.Env.SkyPage", SkyPage)

SkyPage.Name = "SkyPage";

-- skybox db table
SkyPage.skyboxes = {
	[1] = {name = "skybox1", text="沙丘魔堡", file = "model/skybox/skybox1/skybox1.x", bg = "model/skybox/skybox1/skybox1.x.png"},
	[2] = {name = "skybox2", text="晴空万里", file = "model/skybox/skybox2/skybox2.x", bg = "model/skybox/skybox2/skybox2.x.png"},
	[3] = {name = "skybox3", text="冰天雪地", file = "model/skybox/skybox3/skybox3.x", bg = "model/skybox/skybox3/skybox3.x.png"},
	[4] = {name = "skybox4", text="外太空星球", file = "model/skybox/skybox4/skybox4.x", bg = "model/skybox/skybox4/skybox4.x.png"},
	[5] = {name = "skybox5", text="夕阳西下", file = "model/skybox/skybox5/skybox5.x", bg = "model/skybox/skybox5/skybox5.x.png"},
};
-- whether we have searched all skyboxes in disk folder "model/Skybox"
SkyPage.DiskSkyBoxAppended = nil;

-- add disk sky box to SkyPage.skyboxes
function SkyPage.AppendDiskSkybox()
	if(SkyPage.DiskSkyBoxAppended == nil) then
		SkyPage.DiskSkyBoxAppended = true;
		local rootFolder = "model/Skybox"
		local output = commonlib.Files.Find({}, rootFolder, 10, 500, "*.x")
		if(output and #output>0) then
			local function HasSkyBox(filename)
				local _, skybox
				for _,skybox in ipairs(SkyPage.skyboxes)  do
					if(string.lower(skybox.file) == filename) then
						return true;
					end
				end
			end
			
			local _, item;
			for _, item in ipairs(output) do
				
				local skyBox = {};
				local utfFileName = commonlib.Encoding.DefaultToUtf8(string.gsub(item.filename,".*[/\\]", ""))
				skyBox.name = string.gsub(utfFileName, "%.x$", "");
				skyBox.text = skyBox.name;
				skyBox.file = string.lower(string.format("%s/%s", rootFolder,item.filename))
				skyBox.bg = skyBox.file..".png";
				if(not HasSkyBox(skyBox.file)) then
					SkyPage.skyboxes[(#SkyPage.skyboxes)+1] = skyBox;
				end	
			end
		end
	end
end

-- datasource function for pe:gridview
function SkyPage.DS_SkyBox_Func(index)
	SkyPage.AppendDiskSkybox();
	
	if(index == nil) then
		return #(SkyPage.skyboxes);
	else
		return SkyPage.skyboxes[index];
	end
end

-- called to init page
function SkyPage.OnInit()
	local self = SkyPage;
	self.ClearDataBind();
	local Page = document:GetPageCtrl();
	self.page = Page;
	-- update time slider UI
	Page:SetNodeValue("TimeSlider", (ParaScene.GetTimeOfDaySTD()/2+0.5)*100);
	
	local att = ParaScene.GetAttributeObject();
	if(att~=nil) then
		-- update sky color UI
		local color = ParaScene.GetAttributeObjectSky():GetField("SkyColor", {1, 1, 1});
		Page:SetNodeValue("SkyColorpicker", string.format("%d %d %d", color[1]*255, color[2]*255, color[3]*255));
		
		-- update fog color UI
		color = att:GetField("FogColor", {1, 1, 1});
		Page:SetNodeValue("FogColorpicker", string.format("%d %d %d", color[1]*255, color[2]*255, color[3]*255));
	end	
end

function SkyPage.DataBind(bindTarget)
	local self = SkyPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;
	self.bindingContext = commonlib.BindingContext:new();	
	--self.bindingContext:AddBinding(bindTarget, "Timeofday", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "TimeSlider")
	--self.bindingContext:AddBinding(bindTarget, "S_Color", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "SkyColorpicker")
	--self.bindingContext:AddBinding(bindTarget, "F_Color", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "FogColorpicker")
	self.bindingContext:UpdateDataToControls();
	
end
function SkyPage.ClearDataBind()
	local self = SkyPage;
	self.bindTarget = nil;
	self.bindingContext = nil;
end

------------------------
-- page events
------------------------

-- called when the sky box need to be changed
function SkyPage.OnChangeSkybox(nIndex)
	local self = SkyPage;
	local item = SkyPage.skyboxes[nIndex];
	if(item ~= nil) then
		if(Map3DSystem.Animation) then
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "ModifyNature",
					});
		end			
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = item.file,  skybox_name = item.name})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.SkyBoxFile = item.file;
			self.bindTarget.SkyBoxName = item.name;
		end
	end
end

-- called when time slider changes
function SkyPage.OnTimeSliderChanged(value)
	local self = SkyPage;
	if (value) then
		local fTime=(value/100-0.5)*2;
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, timeofday = fTime})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.Timeofday = fTime;
		end
	end	
end

-- called when the fog color changes
function SkyPage.OnFogColorChanged(r,g,b)
	local self = SkyPage;
	if(r and g and b) then
		r = r/255;
		g = g/255;
		b = b/255 
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, fog_r = r, fog_g = g, fog_b = b,})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.FogColor_R = r;
			self.bindTarget.FogColor_G = g;
			self.bindTarget.FogColor_B = b;
			self.bindTarget.F_Color = string.format("%d %d %d", r, g, b)
		end
	end
end

-- called when the sky color changes
function SkyPage.OnSkyColorChanged(r,g,b)
	local self = SkyPage;
	if(r and g and b) then
		r = r/255;
		g = g/255;
		b = b/255 
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, sky_r = r, sky_g = g, sky_b = b,})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.SkyColor_R = r;
			self.bindTarget.SkyColor_G = g;
			self.bindTarget.SkyColor_B = b;
			self.bindTarget.S_Color = string.format("%d %d %d", r, g, b)
		end
	end
end

-- enable/disable simulated sky
function SkyPage.OnClickUseSimulatedSky(bChecked, mcmlNode)
	local self = SkyPage;
	local att = ParaScene.GetAttributeObjectSky();
	att:SetField("SimulatedSky", bChecked);
	if(self.bindingContext and self.bindTarget)then
		self.bindTarget.UseSimulatedSky = bChecked;
	end
end

-- update the page
function SkyPage.OnClickSimSkyTab()
	local page = document:GetPageCtrl();
	local att = ParaScene.GetAttributeObjectSky();
	
	page:SetUIValue("SimulatedSky", att:GetField("SimulatedSky", false))
	page:SetUIValue("IsAutoDayTime", att:GetField("IsAutoDayTime", true))
	
	page:SetUIValue("SunGlowTexture", att:GetField("SunGlowTexture", ""))
	page:SetUIValue("CloudTexture", att:GetField("CloudTexture", ""))
	
	local function Vector3ToColorHex_(vec)
		return string.format("%02X%02X%02X", math.floor(vec[1]*255), math.floor(vec[2]*255), math.floor(vec[3]*255));
	end
	local function Vector2ToString_(vec)
		return string.format("%f,%f", vec[1], vec[2]);
	end
	page:SetUIValue("SunColor", Vector3ToColorHex_(att:GetField("SunColor", {1,1,1})) )
	page:SetUIValue("LightSkyColor", Vector3ToColorHex_(att:GetField("LightSkyColor", {1,1,1})) )
	page:SetUIValue("DarkSkyColor", Vector3ToColorHex_(att:GetField("DarkSkyColor", {1,1,1})) )
	page:SetUIValue("CloudColor", Vector3ToColorHex_(att:GetField("CloudColor", {1,1,1})) )
	
	page:SetUIValue("SunIntensity", Vector2ToString_(att:GetField("SunIntensity", {0,0})) )
	page:SetUIValue("SunHaloSize", Vector2ToString_(att:GetField("SunHaloSize", {0,0})) )
	page:SetUIValue("CloudVelocity", Vector2ToString_(att:GetField("CloudVelocity", {0,0})) )
	page:SetUIValue("CloudOffset", Vector2ToString_(att:GetField("CloudOffset", {0,0})) )
end

-- update sky 
function SkyPage.OnUpdateSimSky(name, values)
	local att = ParaScene.GetAttributeObjectSky();
	
	local function ColorHexToVector3_(str)
		local vec = {};
		local i=1;
		string.gsub(str, "(%x%x)", function (h)
				vec[i] = tonumber(h, 16)/255
				i=i+1;
			end);
		return vec;	
	end
	local function StringToVector2_(str)
		local vec = {};
		local i=1;
		string.gsub(str, "([^,%s]+)", function (h)
				vec[i] = tonumber(h)
				i=i+1;
			end);
		return vec;	
	end
	
	att:SetField("IsAutoDayTime", values["IsAutoDayTime"])
	att:SetField("SunGlowTexture", values["SunGlowTexture"])
	att:SetField("CloudTexture", values["CloudTexture"])
	
	att:SetField("SunColor", ColorHexToVector3_(values["SunColor"]))
	att:SetField("LightSkyColor", ColorHexToVector3_(values["LightSkyColor"]))
	att:SetField("DarkSkyColor", ColorHexToVector3_(values["DarkSkyColor"]))
	att:SetField("CloudColor", ColorHexToVector3_(values["CloudColor"]))
	
	att:SetField("SunIntensity", StringToVector2_(values["SunIntensity"]))
	att:SetField("SunHaloSize", StringToVector2_(values["SunHaloSize"]))
	att:SetField("CloudVelocity", StringToVector2_(values["CloudVelocity"]))
	att:SetField("CloudOffset", StringToVector2_(values["CloudOffset"]))
end