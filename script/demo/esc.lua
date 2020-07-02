--[[
Title: esc bar(when the user pressed the esc button)
Author(s): LiXizhi(code logic)
Date: 2006/1/18
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/esc.lua");
------------------------------------------------------------
]]

--[[reset the scene]]
function ResetScene()
	ParaScene.Reset();
	ParaUI.ResetUI();
	ParaAsset.GarbageCollect();
	ParaGlobal.SetGameStatus("disable");
	main_state=nil;
	log("scene has been reset\n");
end

local function activate(intensity)
	if(On_EscKey~=nil) then 
		On_EscKey();
	else
		ResetScene();
	end
end
NPL.this(activate);