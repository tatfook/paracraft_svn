--[[
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/EffectTrigger.lua");
Map3DSystem.EffectUnit.EffectTrigger.InitLibs();

NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/Test/Test.Effect.lua");
Map3DSystem.EffectUnit.Test_Effect_Page.Show();
------------------------------------------------------------
--]]
local Test_Effect_Page = {

}
commonlib.setfield("Map3DSystem.EffectUnit.Test_Effect_Page",Test_Effect_Page); 
function Test_Effect_Page.OnInit()
	local page = document:GetPageCtrl();
	Test_Effect_Page.page = page
end
function Test_Effect_Page.OnPreview_single()
	Map3DSystem.EffectUnit.EffectTrigger.PlayEffect("Raining.effect")
	--local effectInstance = Map3DSystem.EffectUnit.EffectManager.CreateEffect("Raining","script/kids/3DMapSystemUI/EffectUnit/OneToNil/Raining.effect.xml");
	--effectInstance:Play();
end
function Test_Effect_Page.OnPreview_immediate_single()	
	Map3DSystem.EffectUnit.EffectTrigger.PlayEffect("Light.effect")
	--local effectInstance = Map3DSystem.EffectUnit.EffectManager.CreateEffect("Light","script/kids/3DMapSystemUI/EffectUnit/OneToNil/Light.effect.xml");
	--effectInstance:Play();
end
function Test_Effect_Page.OnPreview_memory_single()
	Map3DSystem.EffectUnit.EffectTrigger.PlayEffect("Test.effect")
	--local effectInstance = Map3DSystem.EffectUnit.EffectManager.CreateEffect("Test","script/kids/3DMapSystemUI/EffectUnit/OneToNil/Test.effect.xml");
	--effectInstance:Play();
end
function Test_Effect_Page.Show()
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	NPL.load("(gl)script/kids/3DMapSystemUI/EffectUnit/Test/Test.Effect.lua");
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/EffectUnit/Test/Test.Effect.html", name="Test_Effect_Page", 
			app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
			text = "≤‚ ‘",
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			isShowMinimizeBox = false,
			isShowCloseBox = true,
			allowResize = false,
			initialPosX = 0,
			initialPosY = 0,
			initialWidth = 400,
			initialHeight = 80,
			bToggleShowHide = false,
			bShow = true,
			DestroyOnClose = true,
		});
end
