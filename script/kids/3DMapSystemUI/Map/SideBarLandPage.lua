

local LandPage = Map3DSystem.mcml.PageCtrl:new({url = "script/kids/3DMapSystemUI/Map/SideBarLandPage.html"});
commonlib.setfield("Map3DApp.LandPage",LandPage);


function LandPage.OnInit()
	local self = document:GetPageCtrl();
end

function LandPage:OnCreate()

end

function LandPage:OnLoad()
end

function LandPage:SetData()
end

function LandPage:Show(bShow)
	local _this = self:FindControl("landPage");
	if(_this:IsValid())then
		_this.visible = bShow;
	end
end