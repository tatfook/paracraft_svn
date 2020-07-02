--[[
Title: Lite3DCanvasMC
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/Lite3DCanvasMC.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/Lite3DCanvas.lua");
local Lite3DCanvasMC = commonlib.inherit(Map3DSystem.App.Inventor.Lite3DCanvas,{
	
});  
commonlib.setfield("Map3DSystem.App.Inventor.Lite3DCanvasMC",Lite3DCanvasMC);

function Lite3DCanvasMC:CanCut()
	return false;
end
function Lite3DCanvasMC:CanCopy()
	return false;
end
function Lite3DCanvasMC:CanPaste()
	return false;
end
function Lite3DCanvasMC:Clear()
	return false;
end
function Lite3DCanvasMC:DeleteSelection()
	return false;
end 
