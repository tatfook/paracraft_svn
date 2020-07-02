--[[
Title: Paraworld setting dialog 
Author(s): LiXizhi
Date: 2008/1/28
Desc: display common, advanced and per application settings. Per application settings is just an MCML page url which is specified by each app 
in the their connection function. To create an setting page for your application, just create an MCML file and assign it by calling app:SetSettingPage(filepath) at app start time.
Note, the page must have one form node with one hidden or visible submit button in order for the outer apply button to work. However setting page with multiple submit needs to use their own submit button. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Settings/Settings.lua");
Map3DSystem.App.Settings.Settings.ShowWnd(app);
Map3DSystem.App.Settings.Settings.Show(bShow, _parent, parentWindow)

-- other app can open an browser using this command with this app. 
Map3DSystem.App.Commands.Call("File.WebBrowser", url);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/integereditor_control.lua");

commonlib.setfield("Map3DSystem.App.Settings.Settings", {});

local MusicVolumeMin = 0
local MusicVolumeMax = 100

-- display the main inventory window for the current user.
-- @param params: nil or a table of {category="app", app_key = "profiles_GUID"}
function Map3DSystem.App.Settings.Settings.ShowWnd(_app, params)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("Settings") or _app:RegisterWindow("Settings", nil, Map3DSystem.App.Settings.Settings.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
			iconSize = 48,
			text = "设置",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 900,
			maximumSizeY = 750,
			minimumSizeX = 700,
			minimumSizeY = 460,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = true,
			initialPosX = 100,
			initialPosY = 70,
			initialWidth = 835,
			initialHeight = 550,
			
			ShowUICallback =Map3DSystem.App.Settings.Settings.Show,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	if(params) then
		Map3DSystem.App.Settings.Settings.OnShowCategoryNode(params.category, params.app_key);
	end	
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Settings.Settings.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Settings.Settings.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("Settings.Settings_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","Settings.Settings_cont","_lt",100,50, 606, 390);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "Settings.Settings_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;

		-- the panel inside which sub category settings are displayed. 
		_this = ParaUI.CreateUIObject("container", "SettingsPanel", "_fi", 179, 3, 9, 3)
		_this.background = ""
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Settings.treeViewSettingCategories");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Settings.treeViewSettingCategories",
				alignment = "_ml",
				left = 3,
				top = 3,
				width = 171,
				height = 3,
				parent = _parent,
				DefaultIndentation = 15,
				DefaultNodeHeight = 24,
				DrawNodeHandler = CommonCtrl.TreeView.DrawSingleSelectionNodeHandler,
				container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
				onclick = Map3DSystem.App.Settings.Settings.OnClickCategoryNode,
			};
			local node = ctl.RootNode;
			node = node:AddChild( CommonCtrl.TreeNode:new({Text = "常用设置", Name = "Common"}) );
			-- select Common node by default
			node:SelectMe();
			node = node.parent;
			node = node:AddChild( CommonCtrl.TreeNode:new({Text = "高级设置", Name = "Advanced", Expanded = false}) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "3D场景", Name = "CSceneObject", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "天空", Name = "CSkyMesh", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "海洋", Name = "COceanManager", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "ParaEngine设置", Name = "ParaEngineSettings", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "全局地型", Name = "CGlobalTerrain", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "摄影机", Name = "CAutoCamera", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "当前地型块", Name = "CTerrain", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "当前角色", Name = "CurrentPlayer", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "当前选择的物体", Name = "CurrentSelection", }) );
			node = node.parent;
			node = node:AddChild( CommonCtrl.TreeNode:new({Text = "应用程序设置", Name = "Apps", }) );
			local key, app;
			for key, app in Map3DSystem.App.AppManager.GetNextApp() do
				local url, title = app:GetSettingPage();
				if(url~=nil) then
					node:AddChild( CommonCtrl.TreeNode:new({Text = title or app.name, Icon = app.icon, Name = "app", app_key=key, SettingPage=url}) );
				end
			end
		else
			ctl.parent = _parent;
		end	
		ctl:Show();
		if(ctl.SelectedNode ~= nil) then
			-- show the last selected setting category
			Map3DSystem.App.Settings.Settings.OnClickCategoryNode(ctl.SelectedNode);
		end
		--_this = ParaUI.CreateUIObject("button", "b", "_rb", -230, -27, 70, 24)
		--_this.text = "确定";
		--_this.onclick = ";Map3DSystem.App.Settings.Settings.OnClickOK()";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "b", "_rb", -154, -27, 70, 24)
		--_this.text = "应用";
		--_this.onclick = ";Map3DSystem.App.Settings.Settings.OnClickApply()";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "b", "_rb", -78, -27, 70, 24)
		--_this.text = "取消";
		--_this.onclick = ";Map3DSystem.App.Settings.Settings.OnClose()";
		--_parent:AddChild(_this);
	
	else
		if(not bShow) then
			Map3DSystem.App.Settings.Settings.OnDestroy()
		end
	end	
end

-- destory the control
function Map3DSystem.App.Settings.Settings.OnDestroy()
	ParaUI.Destroy("Settings.Settings_cont");
end

-- close the window
function Map3DSystem.App.Settings.Settings.OnClose()
	if(Map3DSystem.App.Settings.Settings.parentWindow ~= nil)then
		Map3DSystem.App.Settings.Settings.parentWindow:SendMessage(nil, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		--Map3DSystem.App.Settings.Settings.OnDestroy();
	end
end

function Map3DSystem.App.Settings.Settings.OnClickOK()
	Map3DSystem.App.Settings.Settings.OnClickApply();
	Map3DSystem.App.Settings.Settings.OnClose();
end

function Map3DSystem.App.Settings.Settings.OnClickApply()
	if(type(Map3DSystem.App.Settings.Settings.OnApply_callback) == "function") then
		Map3DSystem.App.Settings.Settings.OnApply_callback();
	end
end

-- show the right panel context for the current setting category. Call this function to switch to another setting UI. 
-- @param showUI_callback: a function (bShow, _parent) end
-- @param OnApply_callback: this function is called when user clicked apply button. It may be nil.
function Map3DSystem.App.Settings.Settings.ShowCategoryPanel(showUI_callback, OnApply_callback)
	if(type(showUI_callback) == "function") then
		-- destory old one. 
		-- TODO: if modified, please ask user to apply changes?
		local _panel = commonlib.GetUIObject("Settings.Settings_cont#SettingsPanel");
		if(_panel~=nil and _panel:IsValid()) then
			_panel:RemoveAll();
			--
			-- create the new one
			--
			showUI_callback (true, _panel);
			-- remember call back. 
			Map3DSystem.App.Settings.Settings.OnApply_callback = OnApply_callback;
		end
	else
		local _panel = commonlib.GetUIObject("Settings.Settings_cont#SettingsPanel");
		if(_panel~=nil and _panel:IsValid()) then
			_panel:RemoveAll();
		end	
	end
end

-- a mapping from attribute to display name (needs localization)
local AttributeNameTranslations = {
	["ClassID"] = "类ID",
	["ClassName"] = "类名称",
	["PrintMe"] = "打印帮助",
	-- camera
	["NearPlane"] = "近平面(Near Plane)(米)",
	["FarPlane"] = "远平面(Far Plane)(米)",
	["FieldOfView"] = "视角(Field Of View)(弧度)",
	["InvertPitch"] = "是否反转鼠标",
	["SmoothFramesNum"] = "摄影机运动平滑帧数",
	["Eye position"] = "眼睛位置(eye pos)",
	["Lookat position"] = "观看位置(look pos)",
	["AlwaysRun"] = "是否一直运动",
	["Reset"] = "重置",
	["FreeCameraMode"] = "自由摄影机模式",
	["FollowMode"] = "跟随摄影机模式",
	["MovementDrag"] = "是否启动移动拖拽",
	["TotalDragTime"] = "拖拽总时间",
	["KeyboardMovVelocity"] = "键盘操作的移动速度",
	["KeyboardRotVelocity"] = "键盘操作的旋转速度",
	-- terrain
	["IsModified"] = "是否更改了",
	["RenderTerrain"] = "是否显示地貌",
	-- ocean
	["DrawOcean"] = "是否显示海洋",
	["WaterLevel"] = "海平面高度",
	["OceanColor"] = "海水颜色",
	["UnderWater"] = "是否在水下",
	["WindSpeed"] = "风速",
	["WindDirection"] = "风的方向(弧度)",
	
	["EnableTerrainReflection"] = "启动地表反射",
	["EnableMeshReflection"] = "启动物品反射",
	["EnablePlayerReflection"] = "启动主角反射",
	["EnableCharacterReflection"] = "启动人物反射",
	
	-- CSceneObject
	["name"] = "名字",
	["global"] = "是否为全局对象",
	["facing"] = "朝向",
	["position"] = "位置",
	["render_tech"] = "渲染器(Shader)ID",
	["progress"] = "建筑完成度",
	["reset"] = "重置",
	["FullScreenGlow"] = "是否启动全屏泛光",
	["GlowIntensity"] = "泛光强度",
	["GlowFactor"] = "泛光比例",
	["Glowness"] = "泛光度",
	["BackgroundColor"] = "背景色",
	["OnClickDistance"] = "鼠标点击范围",
	["AutoPlayerRipple"] = "是否显示人物水面涟漪",
	["ShowHeadOnDisplay"] = "是否显示人物头顶文字",
	["MaxHeadOnDisplayDistance"] = "最大头顶文字显示距离",
	["EnableSunLight"] = "是否启动太阳光照",
	["EnableLight"] = "是否启动光源",
	["ShowLights"] = "是否显示灯光",
	["MaxLightsNum"] = "同时显示的最大灯光数",
	["SetShadow"] = "是否启动阴影渲染",
	["MaxNumShadowCaster"] = "最大投影物体数",
	["MaxNumShadowReceiver"] = "最大接受投影物体数",
	["EnableFog"] = "是否启动雾",
	["FogColor"] = "雾的颜色",
	["FogStart"] = "起始雾化范围(米)",
	["FogEnd"] = "结束雾化范围(米)",
	["FogDensity"] = "雾的密度",
	["MinPopUpDistance"] = "最小物体出现距离(米)",
	["ShowSky"] = "是否显示天空",
	["PasueScene"] = "冻结场景",
	["EnableScene"] = "是否开启3D场景",
	["ShowBoundingBox"] = "是否显示包围盒",
	["GenerateReport"] = "是否显示报告",
	["Save ReflectionMap"] = "保存反射贴图",
	["Save ShadowMap"] = "保存影子贴图",
	["Save GlowMap"] = "保存泛光贴图",
	-- sky
	["SkyColor"] = "天空颜色",
	["SkyMeshFile"] = "天空模型文件",
	["SkyFogAngleFrom"] = "天空雾化起始角(弧度)",
	["SkyFogAngleTo"] = "天空雾化结束角(弧度)",
	-- terrain tile
	["IsEmpty"] = "是否为空",
	["Size"] = "大小(米)",
	["OnloadScript"] = "载入脚本",
	["height map"] = "高度图",
	["ConfigFile"] = "配置文件",
	["Base Texture"] = "基层贴图",
	["CommonTexture"] = "通用贴图",
	-- ParaEngine Setting
	["script editor"] = "缺省脚本编辑器",
	["Ctor Color"] = "创建物体时的颜色",
	["Ctor Height"] = "创建物体时的高度",
	["Ctor Speed"] = "创建物体的速度",
	["Is Debugging"] = "是否为调试模式",
	["Effect Level"] = "特效级别",
	
	["Selection Color"] = "物体选择时的颜色",
	["Is Editing"] = "是否为编辑模式",
	["Locale"] = "当前语言",
	
	["IsMouseInverse"] = "是否反转鼠标",
	["WindowText"] = "窗口标题",
	["IsFullScreenMode"] = "全屏显示",
	["ScreenResolution"] = "分辨率",
	["MultiSampleType"] = "反锯齿类型",
	["MultiSampleQuality"] = "反锯齿质量",
	["UpdateScreenMode"] = "更新3D设备",
	
	
	-- RPG Character
	["persistent"] = "是否可以保存",
	["Save"] = "保存",
	["OnLoadScript"] = "载入脚本",
	["IsLoaded"] = "是否已经载入",
	["On_EnterSentientArea"] = "进入感知区的脚本(enter)",
	["On_LeaveSentientArea"] = "离开感知区的脚本(leave)",
	["On_Click"] = "点击时的脚本(client)",
	["On_Event"] = "事件脚本",
	["On_Perception"] = "感知的脚本(perception)",
	["On_FrameMove"] = "每帧的脚本(frame move)",
	["On_Net_Send"] = "网络发送的脚本",
	["On_Net_Receive"] = "网络接受的脚本",
	["Sentient"] = "是否有感知力",
	["AlwaysSentient"] = "是否一直有感知力",
	["Sentient Radius"] = "被感知半径(Sentient)",
	["PerceptiveRadius"] = "感知半径(Perceptive)",
	["GroupID"] = "感知组ID",
	["SentientField"] = "感知域(Sentient Field)",
	["Physics Radius"] = "物力半径",
	["Size Scale"] = "放缩大小",
	["Density"] = "密度",
	["Speed Scale"] = "速度放缩",
	["Animation ID"] = "动画ID",
	["Dump BVH anims"] = "导出BVH动画",
	["Character ID"] = "角色ID",
	["Character type"] = "角色类型",
	["state0"] = "状态0",
	["state1"] = "状态1",
	["state2"] = "状态2",
	["state3"] = "状态3",
	["life point"] = "生命值",
	["Age"] = "年龄",
	["Height"] = "高度",
	["Weight"] = "宽度",
	["Occupation"] = "职业",
	["RaceSex"] = "种族 & 性别",
	["Strength"] = "力量",
	["Dexterity"] = "敏捷",
	["Intelligence"] = "智力",
	["Base Defense"] = "基本防御",
	["Defense"] = "防御",
	["Defense flat"] = "物理防御",
	["Defense Mental"] = "魔法防御",
	["Base Attack"] = "基本攻击",
	["Attack Melee"] = "物理攻击",
	["Attack Mental"] = "魔法攻击",
	["Attack Ranged"] = "远程攻击",
	["MaxLifeLoad"] = "最大生命值",
	["Hero Points"] = "英雄点数",
}

-- Switch to display setting for a given page. 
-- @param category: "Common" or "app" or any ParaEngine Class name(such as "CSceneObject" or "CSkyMesh").
-- @param app_key: app_key if category is "app"
function Map3DSystem.App.Settings.Settings.OnShowCategoryNode(category, app_key)
	local showUI_callback = nil;
	local OnApply_callback = nil;
	if(category == "Common") then
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Common_General;
		OnApply_callback = Map3DSystem.App.Settings.Settings.OnApplyCommonGeneral;
	elseif(category == "app") then
		-- for all installed apps. 
		local app = Map3DSystem.App.AppManager.GetApp(app_key);
		if(app and app.UserAdded and app:GetSettingPage()) then
			Map3DSystem.App.Settings.Settings.CurSettingPage = {app_key=app_key, url = app:GetSettingPage()};
			showUI_callback = Map3DSystem.App.Settings.Settings.Panel_App_SettingPage;
			OnApply_callback = Map3DSystem.App.Settings.Settings.OnApplyAppSettingPage;
		end	
	elseif(category == "CSceneObject") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = ParaScene.GetAttributeObject(),
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "CSkyMesh") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = ParaScene.GetAttributeObjectSky(),
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "COceanManager") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = ParaScene.GetAttributeObjectOcean(),
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;	
	elseif(category == "ParaEngineSettings") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = ParaEngine.GetAttributeObject(),
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "CGlobalTerrain") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = ParaTerrain.GetAttributeObject(),
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "CAutoCamera") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = ParaCamera.GetAttributeObject(),
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "CTerrain") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = function ()
				local x,y,z = ParaScene.GetPlayer():GetPosition();
				local att = ParaTerrain.GetAttributeObjectAt(x,z);
				if(att~=nil and att:IsValid()) then
					return att;
				end
			end,
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "CurrentPlayer") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = function ()
				return ParaScene.GetPlayer():GetAttributeObject();
			end,
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	elseif(category == "CurrentSelection") then
		Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
			att = function ()
				local obj = ParaSelection.GetObject(0,0);
				if(obj~=nil and obj:IsValid()) then
					return obj:GetAttributeObject();
				end	
			end,
			bReadOnly = nil,
			fieldNames = nil,
			fieldTextReplaceables = AttributeNameTranslations,
		}
		showUI_callback = Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes;
	end
	
	Map3DSystem.App.Settings.Settings.ShowCategoryPanel(showUI_callback, OnApply_callback);
end

-- user clicks a category node, we shall show the UI for the category. 
function Map3DSystem.App.Settings.Settings.OnClickCategoryNode(treeNode)
	Map3DSystem.App.Settings.Settings.OnShowCategoryNode(treeNode.Name, treeNode.app_key);
end

--------------------------------------------------------
-- Per application setting page
--------------------------------------------------------

-- show the mcml page for the current settings. 
function Map3DSystem.App.Settings.Settings.Panel_App_SettingPage(bShow, _parent)
	if(bShow) then
		NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
		if(Map3DSystem.App.Settings.Settings.CurSettingPage and Map3DSystem.App.Settings.Settings.CurSettingPage.url) then
			local SettingPage = Map3DSystem.mcml.PageCtrl:new({url=Map3DSystem.App.Settings.Settings.CurSettingPage.url});
			SettingPage:Create("SettingPage."..Map3DSystem.App.Settings.Settings.CurSettingPage.app_key, _parent, "_fi", 0, 0, 0, 0)
		end	
	end	
end

-- automatically find the form Node and call submit
function Map3DSystem.App.Settings.Settings.OnApplyAppSettingPage()
	if(not Map3DSystem.App.Settings.Settings.CurSettingPage) then
		return
	end
	local ctrName = "SettingPage."..Map3DSystem.App.Settings.Settings.CurSettingPage.app_key;
	local pageCtrl = CommonCtrl.GetControl(ctrName);
	if(pageCtrl == nil)then
		log("warning: failed getting pageCtrl "..ctrName.."\n");
		return;
	end
	
	-- find form node and submit
	local formNodes = pageCtrl:GetRoot():GetAllChildWithName("form") or pageCtrl:GetRoot():GetAllChildWithName("pe:editor");
	if(formNodes ~= nil and table.getn(formNodes)==1) then
		local formNode = formNodes[1];
		-- submit the change. 
		pageCtrl:SubmitForm(formNode)
	else
		log("warning: there is no submit button or single form node found in app MCML setting page "..ctrName.."\n");
		_guihelper.MessageBox("请使用页面中的提交按钮保存设置, 谢谢！");
	end
end

--------------------------------------------------------
-- advanced attribute categories: like 3D scene, camera, terrain, ocean, PE settings, etc. 
--------------------------------------------------------
-- current attribute binding information
Map3DSystem.App.Settings.Settings.CurAdvancedAtt = {
	att = nil,
	bReadOnly = nil,
	fieldNames = nil,
	fieldTextReplaceables = nil,
}

-- the show UI callback for all advanced setting categories. 
function Map3DSystem.App.Settings.Settings.Panel_Advanced_DatabindingAttributes(bShow, _parent)
	if(bShow) then
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "Settings.treeViewAdvancedAttributes",
			alignment = "_fi",
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			parent = _parent,
			DefaultIndentation = 5,
			DefaultNodeHeight = 25,
			DrawNodeHandler = CommonCtrl.TreeView.DrawPropertyNodeHandler,
			container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
		};
		local node = ctl.RootNode;
		local AdvAtt = Map3DSystem.App.Settings.Settings.CurAdvancedAtt;
		node:BindParaAttributeObject(nil, AdvAtt.att, AdvAtt.bReadOnly, AdvAtt.fieldNames, AdvAtt.fieldTextReplaceables);
		ctl:Show();
	end	
end

--------------------------------------------------------
-- Common setting categories: general graphics, sound, key&mouse etc,
--------------------------------------------------------

function Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral(dataMember, bIsWriting, value)
	if(dataMember == "IsFullScreen") then
		local att = ParaEngine.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("IsFullScreenMode", false);
		else
			-- writing to data source
			Map3DSystem.App.Settings.Settings.bNeedUpdateScreen = att:GetField("IsFullScreenMode",false) ~= value;
			att:SetField("IsFullScreenMode", value);
		end
	elseif(dataMember == "InverseMouse") then
		local att = ParaEngine.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("IsMouseInverse", false);
		else
			-- writing to data source
			att:SetField("IsMouseInverse", value);
		end	
	elseif(dataMember == "ScreenResolution") then
		local att = ParaEngine.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			local size = att:GetField("ScreenResolution", {1024,768});
			return string.format("%d × %d", size[1], size[2]);
		else
			-- writing to data source
			local _,_, x,y = string.find(value, "(%d+)%D+(%d+)");
			if(x~=nil and y~=nil) then
				x = tonumber(x)
				y = tonumber(y)
				if(x~=nil and y~=nil) then
					local size = {x, y};
					
					local oldsize = att:GetField("ScreenResolution", {1024,768});
					if(oldsize[1] ~=x or oldsize[2]~= y) then
						Map3DSystem.App.Settings.Settings.bNeedUpdateScreen = true;
					end	
					att:SetField("ScreenResolution", size);
				end
			end
		end	
	elseif(dataMember == "EffectLevel") then
		local att = ParaEngine.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			local s={[1024] = 1, [-1] = 2, [0] = 3, [1] = 4, [2] = 5,}
			return s[att:GetField("Effect Level", 0)];
		else
			-- writing to data source
			local s={1024, -1, 0, 1, 2,}
			value = s[tonumber(value or 0)];
			if(value ~= nil) then
				att:SetField("Effect Level",value)
			end	
		end
	elseif(dataMember == "UseShadow") then
		local att = ParaScene.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("SetShadow", false);
		else
			-- writing to data source
			att:SetField("SetShadow", value);
		end
	elseif(dataMember == "UseGlow") then
		local att = ParaScene.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("FullScreenGlow", false);
		else
			-- writing to data source
			att:SetField("FullScreenGlow", value);
		end
		
	elseif(dataMember == "TerrainReflection") then
		local att = ParaScene.GetAttributeObjectOcean();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("EnableTerrainReflection", false);
		else
			-- writing to data source
			att:SetField("EnableTerrainReflection", value);
		end
	elseif(dataMember == "ObjectReflection") then
		local att = ParaScene.GetAttributeObjectOcean();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("EnableMeshReflection", false);
		else
			-- writing to data source
			att:SetField("EnableMeshReflection", value);
		end
	elseif(dataMember == "CharacterReflection") then
		local att = ParaScene.GetAttributeObjectOcean();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("EnableCharacterReflection", false);
		else
			-- writing to data source
			att:SetField("EnableCharacterReflection", value);
		end	
	elseif(dataMember == "PlayerReflection") then
		local att = ParaScene.GetAttributeObjectOcean();
		if(not bIsWriting) then
			-- reading from data source
			return att:GetField("EnablePlayerReflection", false);
		else
			-- writing to data source
			att:SetField("EnablePlayerReflection", value);
		end
	elseif(dataMember == "ViewDistance") then
		local att = ParaScene.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			return ParaCamera.GetAttributeObject():GetField("FarPlane", 120);
		else
			-- writing to data source
			
			local FarPlane = value;
			local att = ParaScene.GetAttributeObject();
			att:SetField("FogEnd", FarPlane);
			local FogStart = att:GetField("FogStart", 50);
			if(FogStart>FarPlane-20) then
				att:SetField("FogStart", FarPlane-20);
			elseif(FogStart<50 and FarPlane>70)	then
				att:SetField("FogStart", 50);
			end
			ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
		end
	elseif(dataMember == "Volume") then
		local att = ParaScene.GetAttributeObject();
		if(not bIsWriting) then
			-- reading from data source
			local volume = (ParaAudio.GetBGMusicVolume()-MusicVolumeMin)/(MusicVolumeMax - MusicVolumeMin)*255
			return volume;
		else
			-- writing to data source
			value = value/255*(MusicVolumeMax-MusicVolumeMin)+MusicVolumeMin;
			-- set all volumes
			ParaAudio.SetBGMusicVolume(value);
			ParaAudio.SetDialogVolume(value);
			ParaAudio.SetAmbientSoundVolume(value);
			ParaAudio.SetUISoundVolume(value);
			ParaAudio.Set3DSoundVolume(value);
			ParaAudio.SetInteractiveSoundVolume(value);
		end
	-- TODO: bind other fields	
	end
end

-- update data binding for common general settings. 
function Map3DSystem.App.Settings.Settings.UpdateBinding_CommonGeneral()
	-- create the binding context if not exist. 
	local bindingContext = Map3DSystem.App.Settings.Settings.common_bindingContext;
	if(bindingContext == nil) then
		bindingContext = commonlib.BindingContext:new();
		Map3DSystem.App.Settings.Settings.common_bindingContext = bindingContext;

		-- add bindings. 		
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"IsFullScreen", "settings.checkBoxFullScreenMode", commonlib.Binding.ControlTypes.IDE_checkbox, "value")
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"ScreenResolution", "settings.comboBoxScreenResolution", commonlib.Binding.ControlTypes.IDE_dropdownlistbox, "text")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"EffectLevel", "settings.graphic_poor", commonlib.Binding.ControlTypes.IDE_radiobox, "SelectedIndex")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"UseShadow", "settings.checkBoxUseShadow", commonlib.Binding.ControlTypes.IDE_checkbox, "value")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"InverseMouse", "settings.checkBoxInverseMouse", commonlib.Binding.ControlTypes.IDE_checkbox, "value")	
			
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"UseGlow", "settings.checkBoxUseGlow", commonlib.Binding.ControlTypes.IDE_checkbox, "value")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"TerrainReflection", "settings.checkBoxTerrainReflection", commonlib.Binding.ControlTypes.IDE_checkbox, "value")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"ObjectReflection", "settings.comboBoxObjectReflection", commonlib.Binding.ControlTypes.IDE_checkbox, "value")			
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"PlayerReflection", "settings.checkBoxPlayerReflection", commonlib.Binding.ControlTypes.IDE_checkbox, "value")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"CharacterReflection", "settings.checkBoxCharacterReflection", commonlib.Binding.ControlTypes.IDE_checkbox, "value")	
			
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"ViewDistance", "settings.trackBarViewDistance", commonlib.Binding.ControlTypes.IDE_sliderbar, "value")	
		bindingContext:AddBinding(Map3DSystem.App.Settings.Settings.DataBindingFunc_CommonGeneral, 
			"Volume", "settings.trackBarVolume", commonlib.Binding.ControlTypes.IDE_sliderbar, "value")			
			
		-- TODO: bind other fields
	end
	bindingContext:UpdateDataToControls();
end

function Map3DSystem.App.Settings.Settings.Panel_Common_General(bShow, _parent)
	if(bShow) then
		local _this, _root;
		_root = _parent;
		
		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 255, 9, 60, 15)
		_this.text = "分辨率:";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label11", "_lt", 14, 34, 75, 15)
		_this.text = "反转鼠标:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 14, 203, 75, 15)
		_this.text = "物体阴影:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 14, 62, 91, 15)
		_this.text = "3D画面质量:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 14, 228, 75, 15)
		_this.text = "全屏泛光:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 14, 256, 75, 15)
		_this.text = "水面反射:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label9", "_lt", 109, 284, 278, 15)
		_this.text = "注: 关闭所有水面反射可以提高运行速度";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label10", "_lt", 244, 312, 157, 15)
		_this.text = "数值越小运行速度越快";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 14, 312, 75, 15)
		_this.text = "可视距离:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label8", "_lt", 14, 348, 45, 15)
		_this.text = "音量:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 14, 9, 75, 15)
		_this.text = "全屏显示:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxFullScreenMode",
			alignment = "_lt",
			left = 112,
			top = 8,
			width = 116,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "使用全屏显示",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxInverseMouse",
			alignment = "_lt",
			left = 111,
			top = 33,
			width = 146,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "反转鼠标控制模式",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxUseShadow",
			alignment = "_lt",
			left = 111,
			top = 203,
			width = 312,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "渲染所有物体阴影(关闭可以提高运行速度)",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxUseGlow",
			alignment = "_lt",
			left = 111,
			top = 228,
			width = 116,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "使用全屏泛光",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxTerrainReflection",
			alignment = "_lt",
			left = 111,
			top = 255,
			width = 56,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "地表",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.comboBoxObjectReflection",
			alignment = "_lt",
			left = 203,
			top = 256,
			width = 56,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "物体",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxPlayerReflection",
			alignment = "_lt",
			left = 297,
			top = 256,
			width = 56,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "主角",
		};
		ctl:Show();
		
		
		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "settings.checkBoxCharacterReflection",
			alignment = "_lt",
			left = 383,
			top = 256,
			width = 56,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "人物",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "settings.comboBoxScreenResolution",
			alignment = "_lt",
			left = 321,
			top = 6,
			width = 147,
			height = 23,
			dropdownheight = 106,
 			parent = _parent,
			--text = "1024 × 768",
			items = {"800 × 600", "1024 × 768", "1152 × 720", "1280 × 720", "1280 × 1024", "1600 × 1200", },
		};
		ctl:Show();

		-- panel1
		_this = ParaUI.CreateUIObject("container", "panel1", "_lt", 111, 62, 357, 135)
		_parent:AddChild(_this);
		_parent = _this;

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "settings.graphic_poor",
			alignment = "_lt",
			left = 13,
			top = 8,
			width = 265,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "简约模式 (适合DirectX 7.0 显卡)",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "setting.graphic_low",
			alignment = "_lt",
			left = 13,
			top = 33,
			width = 229,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "较低画质 (可以提高运行速度)",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "setting.graphic_med",
			alignment = "_lt",
			left = 13,
			top = 58,
			width = 169,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "中等画质 (推荐使用)",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "setting.graphic_high",
			alignment = "_lt",
			left = 13,
			top = 83,
			width = 301,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "高等画质 (适合DirectX 9或以上的显卡)",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "setting.graphic_super",
			alignment = "_lt",
			left = 13,
			top = 108,
			width = 85,
			height = 19,
			parent = _parent,
			isChecked = false,
			text = "特效全开",
		};
		ctl:Show();

		_parent = _root;
		NPL.load("(gl)script/ide/SliderBar.lua");
		local ctl = CommonCtrl.SliderBar:new{
			name = "settings.trackBarViewDistance",
			alignment = "_lt",
			left = 111,
			top = 308,
			width = 127,
			height = 16,
			parent = _parent,
			value = 120,
			max=400, 
			min=40,
			min_step = 10,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/SliderBar.lua");
		local ctl = CommonCtrl.SliderBar:new{
			name = "settings.trackBarVolume",
			alignment = "_lt",
			left = 111,
			top = 348,
			width = 127,
			height = 16,
			parent = _parent,
			value = 0,
			min = MusicVolumeMin,
			max = MusicVolumeMax,
			min_step = 1,
		};
		ctl:Show();
		
		-- update all bindings
		Map3DSystem.App.Settings.Settings.UpdateBinding_CommonGeneral()
		
		_this = ParaUI.CreateUIObject("button", "b", "_lb", 110, -40, 70, 24)
		_this.text = "保存";
		_this.onclick = ";Map3DSystem.App.Settings.Settings.OnClickOK()";
		_parent:AddChild(_this);
	end	
end

-- call to apply changes in the commmon general setting category
function Map3DSystem.App.Settings.Settings.OnApplyCommonGeneral()
	local bindingContext = Map3DSystem.App.Settings.Settings.common_bindingContext;
	if(bindingContext ~= nil) then
		bindingContext:UpdateControlsToData();
		if(Map3DSystem.App.Settings.Settings.bNeedUpdateScreen) then
			Map3DSystem.App.Settings.Settings.bNeedUpdateScreen = nil;
			_guihelper.MessageBox("您的显示设备即将改变:如果您的显卡不支持,可能会出现异常。是否继续?", function ()
				ParaEngine.GetAttributeObject():CallField("UpdateScreenMode");
			end)
		end
		ParaEngine.WriteConfigFile("config/config.txt");		
	end
end

function Map3DSystem.App.Settings.Settings.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.Settings.Settings.parentWindow.app.name, msg.wndName);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end