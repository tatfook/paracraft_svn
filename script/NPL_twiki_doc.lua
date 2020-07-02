--[[
Title: generate documentation for twiki from NPL source code
Author(s): LiXizhi
Date: 2008/3/12
Desc: generate documentation for twiki from NPL source code.
Open this file from unit test console window and run them all. 
The generated files are in script/doc/*.txt 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/NPL_twiki_doc.lua");
--
-- one can also generate by running following command line from debug window. 
--
NPL.load("(gl)script/ide/UnitTest/unit_test.lua");
local test = commonlib.UnitTest:new();
if(test:ParseFile("script/NPL_twiki_doc.lua")) then test:Run(); end
-------------------------------------------------------
]]

-- make the test case function available. 
NPL.load("(gl)script/ide/NPLDocGen.lua");

-- All application development docs is automatically generated: They are created as child topics of Main.OfficialApps.
NPL.load("(gl)script/kids/3DMapSystemApp/appkeys.lua");
Map3DSystem.App.GenerateAppDevWikiPages()

-- NPLModules Portal Page
-- %TESTCASE{"NPLModules", func="commonlib.NPLDocGen.GenerateTWikiPortalTopic", input={WikiWord = "NPLModules", ClassName = "Portal page for public NPL modules", input = {"script/NPL_twiki_doc.lua"},}}%

-- change log
-- %TESTCASE{"ParaEngineChangeLog", func="commonlib.NPLDocGen.GenerateChangeLogWiki", input={WikiWord = "ParaEngineChangeLog", TopicParent="ParaEngineDoc", HeaderText="---+++ ParaEngine Change History\r\n", input = {"changes.txt"},}}%

--[[ Group=CommonCtrl
%TESTCASE{"TreeView", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "TreeView", ClassName = "CommonCtrl.TreeView", input = {"script/ide/TreeView.lua"},}}%
%TESTCASE{"SliderBar", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "SliderBar", ClassName = "CommonCtrl.SliderBar", input = {"script/ide/SliderBar.lua"},}}%
%TESTCASE{"NumericUpDown", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "NumericUpDown", ClassName = "CommonCtrl.NumericUpDown", input = {"script/ide/NumericUpDown.lua"},}}%
%TESTCASE{"RadioBox", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "RadioBox", ClassName = "CommonCtrl.RadioBox", input = {"script/ide/RadioBox.lua"},}}%
%TESTCASE{"CheckBox", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "CheckBox", ClassName = "CommonCtrl.CheckBox", input = {"script/ide/CheckBox.lua"},}}%
%TESTCASE{"MultilineEditbox", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MultilineEditbox", ClassName = "CommonCtrl.MultilineEditbox", input = {"script/ide/MultilineEditbox.lua"},}}%
%TESTCASE{"MainMenu", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MainMenu", ClassName = "CommonCtrl.MainMenu", input = {"script/ide/MainMenu.lua"},}}%
%TESTCASE{"ContextMenu", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ContextMenu", ClassName = "CommonCtrl.ContextMenu", input = {"script/ide/ContextMenu.lua"},}}%
%TESTCASE{"DropdownListbox", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "DropdownListbox", ClassName = "CommonCtrl.dropdownlistbox", input = {"script/ide/dropdownlistbox.lua"},}}%
%TESTCASE{"CommonCtrl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "CommonCtrl", ClassName = "CommonCtrl", input = {"script/ide/common_control.lua"},}}%
%TESTCASE{"Canvas3D", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "Canvas3D", ClassName = "CommonCtrl.Canvas3D", input = {"script/ide/Canvas3D.lua"},}}%
%TESTCASE{"MinisceneManager", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MinisceneManager", ClassName = "CommonCtrl.MinisceneManager", input = {"script/ide/MinisceneManager.lua"},}}%
%TESTCASE{"OpenFileDialog", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "OpenFileDialog", ClassName = "CommonCtrl.OpenFileDialog", input = {"script/ide/OpenFileDialog.lua"},}}%
%TESTCASE{"GridView", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "GridView", ClassName = "CommonCtrl.GridView", input = {"script/ide/GridView.lua"},}}%
%TESTCASE{"GridView3D", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "GridView3D", ClassName = "CommonCtrl.GridView3D", input = {"script/ide/GridView3D.lua"},}}%
%TESTCASE{"GUIInspectorSimple", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "GUIInspectorSimple", ClassName = "CommonCtrl.GUI_inspector_simple", input = {"script/ide/GUI_inspector_simple.lua"},}}%
%TESTCASE{"FlashPlayerControl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "FlashPlayerControl", ClassName = "CommonCtrl.FlashPlayerControl", input = {"script/ide/FlashPlayerControl.lua"},}}%
%TESTCASE{"LoaderUI", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "LoaderUI", ClassName = "CommonCtrl.LoaderUI", input = {"script/ide/LoaderUI.lua"},}}%
%TESTCASE{"OneTimeAsset", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "OneTimeAsset", ClassName = "CommonCtrl.OneTimeAsset", input = {"script/ide/OneTimeAsset.lua"},}}%
%TESTCASE{"FileExplorerCtrl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "FileExplorerCtrl", ClassName = "CommonCtrl.FileExplorerCtrl", input = {"script/ide/FileExplorerCtrl.lua"},}}%
%TESTCASE{"FileViewCtrl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "FileViewCtrl", ClassName = "CommonCtrl.FileViewCtrl", input = {"script/ide/FileViewCtrl.lua"},}}%
%TESTCASE{"AutoHide", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AutoHide", ClassName = "CommonCtrl.AutoHide", input = {"script/ide/AutoHide.lua"},}}%
%TESTCASE{"ColorPicker", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ColorPicker", ClassName = "CommonCtrl.colorpicker", input = {"script/ide/colorpicker.lua"},}}%
%TESTCASE{"RibbonControl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "RibbonControl", ClassName = "CommonCtrl.RibbonControl", input = {"script/ide/RibbonControl.lua"},}}%
%TESTCASE{"TextSprite", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "TextSprite", ClassName = "CommonCtrl.TextSprite", input = {"script/ide/TextSprite.lua"},}}%
%TESTCASE{"ButtonStyles", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ButtonStyles", ClassName = "CommonCtrl.ButtonStyles", input = {"script/ide/ButtonStyles.lua"},}}%

%TESTCASE{"HTMLRenderer", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "HTMLRenderer", ClassName = "CommonCtrl.HTMLRenderer", input = {"script/ide/HTMLRenderer.lua"},}}%
%TESTCASE{"ProgressBar", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ProgressBar", ClassName = "CommonCtrl.progressbar", input = {"script/ide/progressbar.lua"},}}%
%TESTCASE{"VizGroup", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "VizGroup", ClassName = "CommonCtrl.VizGroup", input = {"script/ide/visibilityGroup.lua"},}}%
%TESTCASE{"FileDialog", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "FileDialog", ClassName = "CommonCtrl.FileDialog", input = {"script/ide/FileDialog.lua"},}}%
%TESTCASE{"UserAction", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "UserAction", ClassName = "CommonCtrl.user_action", input = {"script/ide/user_action.lua"},}}%
%TESTCASE{"WindowFrame", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "WindowFrame", ClassName = "CommonCtrl.WindowFrame", input = {"script/ide/WindowFrame.lua"},}}%
]]

--[[ Group=UtilityModule
%TESTCASE{"CommonLib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "CommonLib", ClassName = "commonlib", input = {"script/ide/commonlib.lua"},}}%
	%TESTCASE{"DebugLib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "DebugLib", ClassName = "DebugLib", input = {"script/ide/debug.lua"},}}%
	%TESTCASE{"SerializationLib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "SerializationLib", ClassName = "SerializationLib", input = {"script/ide/serialization.lua"},}}%
	%TESTCASE{"AdvancedLog", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AdvancedLog", ClassName = "commonlib.log", input = {"script/ide/log.lua"},}}%
	%TESTCASE{"LibStub", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "LibStub", ClassName = "commonlib.LibStub", input = {"script/ide/LibStub.lua"},}}%
	%TESTCASE{"PackageModule", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "PackageModule", ClassName = "commonlib.package", input = {"script/ide/package/package.lua"},}}%
	
%TESTCASE{"GuiHelper", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "GuiHelper", ClassName = "_gui_helper", input = {"script/ide/gui_helper.lua"},}}%
	%TESTCASE{"MessageBox", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MessageBox", ClassName = "_guihelper.MessageBox", input = {"script/ide/MessageBox.lua"},}}%
	
%TESTCASE{"DataBinding", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "DataBinding", ClassName = "commonlib.DataBinding", input = {"script/ide/DataBinding.lua"},}}%
%TESTCASE{"UnitTestFramework", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "UnitTestFramework", ClassName = "CommonCtrl.CheckBox", input = {"script/ide/UnitTest/readme.lua", "script/ide/UnitTest/unit_test.lua", "script/ide/UnitTest/unit_test_case.lua", "script/ide/UnitTest/unit_test_dlg.lua"},}}%
%TESTCASE{"OperatingSystem", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "OperatingSystem", ClassName = "CommonCtrl.os", input = {"script/ide/os.lua"},}}%
%TESTCASE{"Xpath", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "Xpath", ClassName = "Xpath", input = {"script/ide/Xpath.lua"},}}%
%TESTCASE{"Locale", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "Locale", ClassName = "CommonCtrl.Locale", input = {"script/ide/Locale.lua"},}}%
%TESTCASE{"NPLDocGen", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "NPLDocGen", ClassName = "commonlib.NPLDocGen", input = {"script/ide/NPLDocGen.lua"},}}%
%TESTCASE{"MathLib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MathLib", ClassName = "commonlib.mathlib", input = {"script/ide/mathlib.lua", 
	"script/ide/math/bit.lua", "script/ide/math/complex.lua","script/ide/math/math3d.lua", "script/ide/math/fit.lua", "script/ide/math/matrix.lua", "script/ide/math/TEA.lua"}, "script/ide/math/MD5.lua"}}%
%TESTCASE{"StandardTemplateLibrary", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "StandardTemplateLibrary", ClassName = "Standard Template Library in NPL", input = {"script/ide/STL.lua"},}}%
%TESTCASE{"sandbox", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "sandbox", ClassName = "ParaSandBox.sandbox", input = {"script/ide/sandbox.lua"},}}%
%TESTCASE{"LuaXML", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "LuaXML", ClassName = "commonlib.LuaXML", input = {"script/ide/LuaXML.lua"},}}%
%TESTCASE{"ObjEditor", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ObjEditor", ClassName = "CommonCtrl.ObjEditor", input = {"script/ide/object_editor.lua", "script/ide/object_editor_v1.lua"},}}%
%TESTCASE{"ParaEngineExtension", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaEngineExtension", ClassName = "ParaEngine Extension", input = {"script/ide/ParaEngineExtension.lua"},}}%
%TESTCASE{"VideoRecorder", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "VideoRecorder", ClassName = "VideoRecorder", input = {"script/ide/VideoRecorder.lua"},}}%
%TESTCASE{"AILib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AILib", ClassName = "AI Lib", input = {"script/ide/AI.lua"},}}%
%TESTCASE{"HeadonSpeech", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "HeadonSpeech", ClassName = "headon_speech", input = {"script/ide/headon_speech.lua"},}}%
%TESTCASE{"UIAnim", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "UIAnim", ClassName = "UI animation", input = {"script/ide/UIAnim/UIAnimation.lua", "script/ide/UIAnim/UIAnimBlock.lua", "script/ide/UIAnim/UIAnimFile.lua", "script/ide/UIAnim/UIAnimIndex.lua", "script/ide/UIAnim/UIAnimInstance.lua", "script/ide/UIAnim/UIAnimManager.lua", "script/ide/UIAnim/UIAnimSeq.lua"},}}%
%TESTCASE{"TimeSeries", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "TimeSeries", ClassName = "Time Series", input = {"script/ide/TimeSeries/TimeSeries.lua", "script/ide/TimeSeries/AnimBlock.lua"},}}%
%TESTCASE{"rulemapping", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "RuleMapping", ClassName = "rulemapping", input = {"script/ide/rulemapping.lua",}}%
%TESTCASE{"Encoding", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "Encoding", ClassName = "commonlib.Encoding", input = {"script/ide/Encoding.lua"},}}%
%TESTCASE{"StringMap", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "StringMap", ClassName = "commonlib.StringMap", input = {"script/ide/stringmap.lua"},}}%
%TESTCASE{"Timer", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "Timer", ClassName = "commonlib.timer", input = {"script/ide/Timer.lua"},}}%
%TESTCASE{"StateMachine", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "StateMachine", ClassName = "commonlib.StateMachine", input = {"script/ide/StateMachine.lua"},}}%

%TESTCASE{"MotionLib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MotionLib", ClassName = "Motion Lib", input = {
	"script/ide/Motion/AnimatorEngine.lua", "script/ide/Motion/Animator.lua", "script/ide/Motion/AnimatorManager.lua", 
	"script/ide/Motion/BezierEase.lua", "script/ide/Motion/BezierSegment.lua", "script/ide/Motion/Color.lua", "script/ide/Motion/ColorTransform.lua", "script/ide/Motion/CustomEase.lua", "script/ide/Motion/DisplayObject.lua", "script/ide/Motion/ITween.lua", 
	"script/ide/Motion/Keyframe.lua", "script/ide/Motion/Motion.lua", "script/ide/Motion/Point.lua", "script/ide/Motion/RotationDirection.lua", 
	"script/ide/Motion/SimpleEase.lua","script/ide/Motion/Source.lua","script/ide/Motion/Tweenables.lua",
	"script/ide/Motion/test/motion_test.lua","script/ide/Motion/motionData.xml"},}}%
]]

--[[ Group=NPLUIandEvent
%TESTCASE{"NPLUIandEvent", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "NPLUIandEvent", ClassName = "NPL UI and Event", input = {"EventsReference.txt", "script/ide/action_table.lua"},}}%
]]

--[[ Group=LocalServer
%TESTCASE{"LocalServer", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "LocalServer", ClassName = "Local Server", input = {
"script/ide/System/localserver/readme.lua", 
"script/ide/System/localserver/factory.lua", 
"script/ide/System/localserver/cache_policy.lua", 
"script/ide/System/localserver/capture_task.lua", 
"script/ide/System/localserver/WebserviceStore.lua", 
"script/ide/System/localserver/ResourceStore.lua", 
"script/ide/System/localserver/ManagedResourceStore.lua", 
"script/ide/System/localserver/http_constants.lua", 
"script/ide/System/localserver/http_cookies.lua", 
"script/ide/System/localserver/security_model.lua", 
"script/ide/System/localserver/UrlHelper.lua", 
"script/ide/System/localserver/WebCacheDB_def.lua", 
"script/ide/System/localserver/WebCacheDB.lua", 
"script/ide/System/localserver/WebCacheDB_store.lua", 
"script/ide/System/localserver/WebCacheDB_permissions.lua", 
"script/ide/System/localserver/sqldb_wrapper.lua", 
"script/ide/System/localserver/localserver.lua"},}}%

%TESTCASE{"UrlHelper", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "UrlHelper", ClassName = "UrlHelper", input = {"script/ide/System/localserver/UrlHelper.lua",},}}%
%TESTCASE{"CachePolicy", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "CachePolicy", ClassName = "CachePolicy", input = {"script/ide/System/localserver/cache_policy.lua",},}}%

%TESTCASE{"WebserviceStore", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "WebserviceStore", ClassName = "WebserviceStore", input = {
"script/ide/System/localserver/WebserviceStore.lua",
"script/ide/System/localserver/factory.lua", 
"script/ide/System/localserver/cache_policy.lua"},}}%

%TESTCASE{"ResourceStore", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ResourceStore", ClassName = "ResourceStore", input = {
"script/ide/System/localserver/ResourceStore.lua",
"script/ide/System/localserver/factory.lua", 
"script/ide/System/localserver/cache_policy.lua"},}}%

%TESTCASE{"ManagedResourceStore", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ManagedResourceStore", ClassName = "ManagedResourceStore", input = {
"script/ide/System/localserver/ManagedResourceStore.lua",
"script/ide/System/localserver/factory.lua", 
"script/ide/System/localserver/cache_policy.lua"},}}%
]]

--[[ Group=MCML
%TESTCASE{"MCML_V1", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MCML_V1", ClassName = "MCML", input = {"script/kids/3DMapSystemApp/MCML/readme.lua"}, 
	IgnoreHeader = true, PostProcessor="commonlib.NPLDocGen.MakeValidMCMLWikiWords"}}%

%TESTCASE{"MCMLControls", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MCMLControls", ClassName = "MCML Controls", input = {
"script/kids/3DMapSystemApp/MCML/mcml.lua",
"script/kids/3DMapSystemApp/MCML/mcml_controls.lua",
"script/kids/3DMapSystemApp/MCML/mcml_controls_layout.lua",
"script/kids/3DMapSystemApp/MCML/mcml_base.lua",
"script/kids/3DMapSystemApp/MCML/pe_default_css.lua",
},}}%

%TESTCASE{"HTMLTags", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "HTMLTags", ClassName = "HTML Tags", input = {
"script/kids/3DMapSystemApp/MCML/pe_html.lua",
"script/kids/3DMapSystemApp/MCML/pe_html_input.lua",
"script/kids/3DMapSystemApp/MCML/pe_design.lua",
"script/kids/3DMapSystemApp/MCML/pe_editor.lua",
"script/kids/3DMapSystemApp/MCML/pe_default_css.lua",
"script/kids/3DMapSystemApp/mcml/pe_script.lua",
},}}%

%TESTCASE{"PageCtrl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "PageCtrl", ClassName = "PageCtrl", input = {"script/kids/3DMapSystemApp/MCML/PageCtrl.lua"},}}%
%TESTCASE{"DocumentObjectModel", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "DocumentObjectModel", ClassName = "DocumentObjectModel", input = {"script/kids/3DMapSystemApp/MCML/DOM.lua"},}}%
%TESTCASE{"MCMLBrowserCtrl", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MCMLBrowserCtrl", ClassName = "MCMLBrowserCtrl", input = {"script/kids/3DMapSystemApp/MCML/BrowserWnd.lua"},}}%
%TESTCASE{"MCMLExamples", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "MCMLExamples", ClassName = "MCML Examples", input = {"script/kids/3DMapSystemApp/mcml/mcml_samples.lua"},}}%
%TESTCASE{"Pe_component", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_component", ClassName = "pe_component", input = {"script/kids/3DMapSystemApp/MCML/pe_component.lua"},}}%
%TESTCASE{"pe_design", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_design", ClassName = "pe_design", input = {"script/kids/3DMapSystemApp/MCML/pe_design.lua"},}}%
%TESTCASE{"pe_editor", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_editor", ClassName = "pe_editor", input = {"script/kids/3DMapSystemApp/MCML/pe_editor.lua"},}}%
%TESTCASE{"pe_html", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_html", ClassName = "pe_html", input = {"script/kids/3DMapSystemApp/MCML/pe_html.lua"},}}%
%TESTCASE{"pe_html_input", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_html_input", ClassName = "pe_html_input", input = {"script/kids/3DMapSystemApp/MCML/pe_html_input.lua"},}}%
%TESTCASE{"pe_social", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_social", ClassName = "pe_social", input = {"script/kids/3DMapSystemApp/MCML/pe_social.lua"},}}%
%TESTCASE{"pe_user", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_user", ClassName = "pe_user", input = {"script/kids/3DMapSystemApp/MCML/pe_user.lua"},}}%
%TESTCASE{"pe_profile", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_profile", ClassName = "pe_profile", input = {"script/kids/3DMapSystemApp/MCML/pe_profile.lua"},}}%
%TESTCASE{"pe_avatar", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_avatar", ClassName = "pe_avatar", input = {"script/kids/3DMapSystemApp/MCML/pe_avatar.lua"},}}%
%TESTCASE{"pe_script", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_script", ClassName = "pe_script", input = {"script/kids/3DMapSystemApp/MCML/pe_script.lua"},}}%
%TESTCASE{"pe_motion", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_motion", ClassName = "pe_motion", input = {"script/kids/3DMapSystemApp/MCML/pe_motion.lua"},}}%
%TESTCASE{"pe_gridview", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_gridview", ClassName = "pe_gridview", input = {"script/kids/3DMapSystemApp/MCML/pe_gridview.lua"},}}%
%TESTCASE{"pe_datasource", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_datasource", ClassName = "pe_datasource", input = {"script/kids/3DMapSystemApp/MCML/pe_datasource.lua"},}}%
%TESTCASE{"pe_map", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_map", ClassName = "pe_map", input = {"script/kids/3DMapSystemApp/MCML/pe_map.lua"},}}%
%TESTCASE{"pe_land", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "pe_land", ClassName = "pe_land", input = {"script/kids/3DMapSystemApp/MCML/pe_land.lua"},}}%
]]

--[[ Group=AppDevReference
%TESTCASE{"AppManager", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppManager", ClassName = "AppManager", input = {"script/kids/3DMapSystemApp/AppManager.lua"},}}%
%TESTCASE{"AppCommands", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppCommands", ClassName = "AppCommands", input = {"script/kids/3DMapSystemApp/AppCommands.lua"},}}%
%TESTCASE{"AppHelper", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppHelper", ClassName = "AppHelper", input = {"script/kids/3DMapSystemApp/AppHelper.lua"},}}%
%TESTCASE{"appkeys", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "appkeys", ClassName = "appkeys", input = {"script/kids/3DMapSystemApp/appkeys.lua"},}}%
%TESTCASE{"AppObject", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppObject", ClassName = "App Object", input = {"script/kids/3DMapSystemApp/app.lua"},}}%
%TESTCASE{"AppRegistration", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppRegistration", ClassName = "AppRegistration", input = {"script/kids/3DMapSystemApp/AppRegistration.lua"},}}%
%TESTCASE{"BaseApp", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "BaseApp", ClassName = "BaseApp", input = {"script/kids/3DMapSystemApp/BaseApp.lua"},}}%
%TESTCASE{"AppTaskBar", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppTaskBar", ClassName = "AppTaskBar", input = {"script/kids/3DMapSystemUI/Desktop/AppTaskBar.lua"},}}%
%TESTCASE{"AppMainMenu", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppMainMenu", ClassName = "AppMainMenu", input = {"script/kids/3DMapSystemUI/Desktop/MainMenu.lua"},}}%
%TESTCASE{"DesktopWnd", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "DesktopWnd", ClassName = "DesktopWnd", input = {"script/kids/3DMapSystemUI/Desktop/DesktopWnd.lua"},}}%
%TESTCASE{"AppDesktop", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "AppDesktop", ClassName = "AppDesktop", input = {"script/kids/3DMapSystemUI/Desktop/AppDesktop.lua"},}}%
%TESTCASE{"WorldTemplateGuideline", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "WorldTemplateGuideline", ClassName = "WorldTemplateGuideline", input = {"worlds/Templates/WorldTemplateGuideline.txt"},}}%
]]

--[[ Group=ParaWorldAPI
%TESTCASE{"ParaWorldAPIReference", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorldAPIReference", ClassName = "ParaWorld API Reference", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/readme.lua"}, 
	IgnoreHeader = true, PostProcessor="commonlib.NPLDocGen.MakeValidParaWorldAPIWikiWords"}}%
%TESTCASE{"WebServiceWrapper", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "WebServiceWrapper", ClassName = "webservice_wrapper", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/webservice_wrapper.lua"},}}%
%TESTCASE{"WebServiceConstants", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "WebServiceConstants", ClassName = "Web Service Constants", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/webservice_constants.lua"},}}%
%TESTCASE{"ParaWorldAPIHeaderFile", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorldAPIHeaderFile", ClassName = "ParaWorld API HeaderFile", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/ParaworldAPI.lua"},}}%
%TESTCASE{"ParaWorld_Auth", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Auth", ClassName = "ParaWorld_Auth", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.auth.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Actionfeed", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Actionfeed", ClassName = "ParaWorld_Actionfeed", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.actionfeed.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Apps", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Apps", ClassName = "ParaWorld_Apps", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.apps.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Friends", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Friends", ClassName = "ParaWorld_Friends", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.friends.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Inventory", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Inventory", ClassName = "ParaWorld_Inventory", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.Inventory.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Lobby", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Lobby", ClassName = "ParaWorld_Lobby", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.lobby.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Marketplace", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Marketplace", ClassName = "ParaWorld_Marketplace", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.marketplace.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Profile", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Profile", ClassName = "ParaWorld_Profile", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.profile.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Users", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Users", ClassName = "ParaWorld_Users", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.users.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_Map", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_Map", ClassName = "ParaWorld_Map", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.map.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
%TESTCASE{"ParaWorld_MQL", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ParaWorld_MQL", ClassName = "ParaWorld_Map", TopicParent = "ParaWorldAPI",  input = {"script/kids/3DMapSystemApp/API/paraworld.MQL.lua"},PreProcessor="commonlib.NPLDocGen.PreProcRPCWrapperToFunction"}}%
]]

--[[ Group=JGSL
%TESTCASE{"JgslLib", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JgslLib", ClassName = "JgslLib", input = {"script/kids/3DMapSystemNetwork/JGSL_doc.txt", "script/kids/3DMapSystemNetwork/JGSL.lua"},}}%
%TESTCASE{"JGSL_client", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_client", ClassName = "JGSL_client", input = {"script/kids/3DMapSystemNetwork/JGSL_client.lua"},}}%
%TESTCASE{"JGSL_server", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_server", ClassName = "JGSL_server", input = {"script/kids/3DMapSystemNetwork/JGSL_server.lua"},}}%
%TESTCASE{"JGSL_msg_def", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_msg_def", ClassName = "JGSL_msg_def", input = {"script/kids/3DMapSystemNetwork/JGSL_msg_def.lua"},}}%
%TESTCASE{"JGSL_grid", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_grid", ClassName = "JGSL_grid", input = {"script/kids/3DMapSystemNetwork/JGSL_grid.lua"},}}%
%TESTCASE{"JGSL_agent", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_agent", ClassName = "JGSL_agent", input = {"script/kids/3DMapSystemNetwork/JGSL_agent.lua"},}}%
%TESTCASE{"JGSL_clientproxy", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_clientproxy", ClassName = "JGSL_clientproxy", input = {"script/kids/3DMapSystemNetwork/JGSL_clientproxy.lua"},}}%
%TESTCASE{"JGSL_serverproxy", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_serverproxy", ClassName = "JGSL_serverproxy", input = {"script/kids/3DMapSystemNetwork/JGSL_serverproxy.lua"},}}%
%TESTCASE{"JGSL_history", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_history", ClassName = "JGSL_history", input = {"script/kids/3DMapSystemNetwork/JGSL_history.lua"},}}%
%TESTCASE{"JGSL_opcode, func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_opcode", ClassName = "JGSL_opcode", input = {"script/kids/3DMapSystemNetwork/JGSL_opcode.lua"},}}%
%TESTCASE{"JGSL_query", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_query", ClassName = "JGSL_query", input = {"script/kids/3DMapSystemNetwork/JGSL_query.lua"},}}%
%TESTCASE{"JGSL_servermode", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_servermode", ClassName = "JGSL_servermode", input = {"script/kids/3DMapSystemNetwork/JGSL_servermode.lua"},}}%
%TESTCASE{"JGSL_servermode_loop", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_servermode_loop", ClassName = "JGSL_servermode_loop", input = {"script/kids/3DMapSystemNetwork/JGSL_servermode_loop.lua"},}}%
%TESTCASE{"JGSL_agentstream", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_agentstream", ClassName = "JGSL_agentstream", input = {"script/kids/3DMapSystemNetwork/JGSL_agentstream.lua"},}}%
%TESTCASE{"JGSL_stringmap", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_stringmap", ClassName = "JGSL_stringmap", input = {"script/kids/3DMapSystemNetwork/JGSL_stringmap.lua"},}}%
%TESTCASE{"JGSL_gateway", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_gateway", ClassName = "JGSL_gateway", input = {"script/kids/3DMapSystemNetwork/JGSL_gateway.lua"},}}%
%TESTCASE{"EmuUsers", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "EmuUsers", ClassName = "EmuUsers", input = {"script/kids/3DMapSystemNetwork/EmuUsers.lua"},}}%
%TESTCASE{"JGSL_config", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "JGSL_config", ClassName = "JGSL_config", input = {"script/kids/3DMapSystemNetwork/JGSL_config.lua"},}}%
%TESTCASE{"ValueTracker", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "ValueTracker", ClassName = "ValueTracker", input = {"script/kids/3DMapSystemNetwork/ValueTracker.lua"},}}%
]]