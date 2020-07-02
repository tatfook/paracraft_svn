--[[
Title: settings.html code-behind script
Author(s): LiXizhi
Date: 2008/4/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/setting.lua");
Map3DSystem.App.Login.SettingPage:Create("LoginApp.SettingPage", nil, "_ct", -width/2, -height/2, width, height);
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/Login/ParaworldStartPage.lua");

-- create class
local SettingPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemApp/Login/SettingPage.html"});
Map3DSystem.App.Login.SettingPage = SettingPage;

-- this function is overridable. it is called before page UI is about to be created. 
-- @param self.mcmlNode: the root pe:mcml node, one can modify it here before the UI is created, such as filling in default data. 
function SettingPage.OnInit()
	local self = document:GetPageCtrl();
	self:SetNodeValue("StartPage_ShowAddressBar", Map3DSystem.App.Login.app:ReadConfig("ShowAddressBar", false));
	self:SetNodeValue("StartPageMCML", Map3DSystem.App.Login.app:ReadConfig("StartPageMCML", Map3DSystem.App.Login.StartPageUrl));
	
	local bgInfo = Map3DSystem.App.Login.app:ReadConfig("InitScene", Map3DSystem.App.Login.DefaultBGScenes[1]);
	if(bgInfo) then
		self:SetNodeValue("StartPage_3DScene_Text", bgInfo.Text);
		self:SetNodeValue("StartPage_3DScene_RenderNPC", bgInfo.bRenderNPC);
		self:SetNodeValue("StartPage_3DScene_RenderPlayer", bgInfo.bRenderPlayer);
		
		local scenes = Map3DSystem.App.Login.app:ReadConfig("RecentlyOpenedScenes", {})
		local index, value
		for index, value in ipairs(scenes) do
			self:SetNodeValue("StartPage_3DScene", commonlib.Encoding.DefaultToUtf8(value.FilePath));
		end
		
		self:SetNodeValue("StartPage_3DScene", commonlib.Encoding.DefaultToUtf8(bgInfo.FilePath));
	end
end

---------------------------------
-- page event handlers
---------------------------------

-- When clicks the button
function SettingPage.UseCurrentPageBtn(sCtrlName, values)
	local page = document:GetPageCtrl();
	
	local activeDeskTop = CommonCtrl.GetControl(Map3DSystem.App.Login.browsername);
	if(activeDeskTop)then
		page:SetUIValue("StartPageMCML", activeDeskTop:GetUrl());
	end	
end

-- When clicks the button
function SettingPage.UseDefaultBtn(sCtrlName, values)
	local page = document:GetPageCtrl();
	page:SetUIValue("StartPageMCML", Map3DSystem.App.Login.StartPageUrl);
end

-- When clicks the button
function SettingPage.UseBlankPageBtn(sCtrlName, values)
	local page = document:GetPageCtrl();
	page:SetUIValue("StartPageMCML", "");
end

-- When clicks the button
function SettingPage.UseDefaultSceneBtn(sCtrlName, values)
	local self = document:GetPageCtrl();
	
	local bgInfo = Map3DSystem.App.Login.DefaultBGScenes[1];
	if(bgInfo) then
		self:SetUIValue("StartPage_3DScene_Text", bgInfo.Text);
		self:SetUIValue("StartPage_3DScene", commonlib.Encoding.DefaultToUtf8(bgInfo.FilePath));
		self:SetUIValue("StartPage_3DScene_RenderNPC", bgInfo.bRenderNPC);
		self:SetUIValue("StartPage_3DScene_RenderPlayer", bgInfo.bRenderPlayer);
	end
end

-- When clicks the button
function SettingPage.UseBlankSceneBtn(sCtrlName, values)
	local self = document:GetPageCtrl();
	self:SetUIValue("StartPage_3DScene_Text", "无背景");
	self:SetUIValue("StartPage_3DScene", "");
end

-- allow the user to open a bg from a world, image file, etc. 
function SettingPage.Open3DBackgroundBtn()
	local self = document:GetPageCtrl();
	-- show the open file dialog. 
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {"全部文件(*.*)", "图片(*.jpg; *.png; *.dds)", "视频(*.avi; *.wmv; *.swf)", "3D世界(*.zip)", "世界目录(*.)", },
		folderlinks = {
			{path = "worlds/", text = "3D世界"},
			{path = "Texture/", text = "图片和视频"},
		},
		onopen = function(sCtrlName, filename) 
			if(filename) then
				self:SetUIValue("StartPage_3DScene_Text", commonlib.Encoding.DefaultToUtf8(ParaIO.GetFileName(filename)));
				self:SetUIValue("StartPage_3DScene", commonlib.Encoding.DefaultToUtf8(filename));
			end	
		end
	};
	ctl:Show(true);
end

-- saved the common form. 
function SettingPage.SaveCommonBtn(sCtrlName, values)
	Map3DSystem.App.Login.app:BeginConfig()
	
	Map3DSystem.App.Login.app:WriteConfig("ShowAddressBar", values["StartPage_ShowAddressBar"]);
	local StartPageMCML = values["StartPageMCML"]
	if(StartPageMCML) then
		StartPageMCML = string.gsub(StartPageMCML, "[%s\r\n]+", "");
		Map3DSystem.App.Login.app:WriteConfig("StartPageMCML", StartPageMCML);
	end
	local bgInfo = {
		FilePath = commonlib.Encoding.Utf8ToDefault(values["StartPage_3DScene"]),
		Text = values["StartPage_3DScene_Text"],
		bRenderNPC = values["StartPage_3DScene_RenderNPC"],
		bRenderPlayer = values["StartPage_3DScene_RenderPlayer"],
	};
	Map3DSystem.App.Login.app:WriteConfig("InitScene", bgInfo);
	
	if(Map3DSystem.App.Login.app:EndConfig()) then
		_guihelper.MessageBox("更改成功！ 你的部分更改将在重起客户端后才能生效.");
	else
		_guihelper.MessageBox("您没有做更改");
	end
end

-- saved the connection form. 
function SettingPage.SaveConnectionBtn(sCtrlName, values)
end