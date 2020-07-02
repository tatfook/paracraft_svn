NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapMessageDefine.lua");

local LandDetailWnd = Map3DSystem.mcml.PageCtrl:new({url = "script/kids/3DMapSystemUI/Map/LandDetailWnd.html"});
commonlib.setfield("Map3DApp.LandDetailWnd",LandDetailWnd);


function LandDetailWnd:OnInit()

end

function LandDetailWnd:OnCreate()

end

function LandDetailWnd:OnLoad()
	
end

function LandDetailWnd:SetData(landInfo)

end
