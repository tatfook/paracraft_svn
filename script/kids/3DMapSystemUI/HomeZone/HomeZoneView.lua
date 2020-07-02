--[[
Title: HomeZoneView
Author(s): Leio
Date: 2009/2/18
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneView.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Document/RemoteSingleDocument.lua");
local HomeZoneView = {
	name = "HomeZoneView_instance",
	uid = nil,
}
commonlib.setfield("Map3DSystem.App.HomeZoneView",HomeZoneView);
function HomeZoneView.loadFunc(bSucceed)
	if(bSucceed) then
		--_guihelper.MessageBox("加载成功！");
		if(HomeZoneView.curDoc)then
			--NPL.load("(gl)script/kids/3DMapSystemUI/loadworld.lua");
			--Map3DSystem.UI.LoadWorld.LoadWorldImmediate("worlds/3DMapStartup")
			System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/DoodleWorld"});
			HomeZoneView.Show();

			local data = HomeZoneView.curDoc:GetData();
			HomeZoneView.curDoc:DoParse(data);
			
			local lite3DCanvas = HomeZoneView.curDoc:GetCanvas();	
			if(not lite3DCanvas)then return end	
			local x,y,z = lite3DCanvas:GetPlayerPos();
			Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x=x or 255, z=z or 255});
			
			NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/FlowerDocument.lua");
			local flower = HomeZoneView.FindFlower(lite3DCanvas)
			if(flower)then
				Map3DSystem.App.HomeZone.FlowerDocument.Clear();
				Map3DSystem.App.HomeZone.FlowerDocument.Load(flower,HomeZoneView.uid);
			end
		else
			_guihelper.MessageBox("加载失败！");
		end
	else
		_guihelper.MessageBox("加载失败！");
	end
end
function HomeZoneView.Start(uid)
	Map3DSystem.App.HomeZoneView.End()
	if(not HomeZoneView.curDoc)then
		HomeZoneView.curDoc = CommonCtrl.RemoteSingleDocument:new();
		HomeZoneView.curDoc.loadFunc = HomeZoneView.loadFunc;
	else
		HomeZoneView.ClearCanvas();
	end
	HomeZoneView.uid = uid;
	HomeZoneView.curDoc:Load(uid);
	
end
function HomeZoneView.End()
	HomeZoneView.ClearCanvas();
end
function HomeZoneView.ClearCanvas()
	if(not HomeZoneView.curDoc)then return end
	local static_canvas = HomeZoneView.curDoc:GetStaticCanvas();
	if(static_canvas)then
		static_canvas:Clear();
	end
	local canvas = HomeZoneView.curDoc:GetCanvas();
	if(canvas)then
		canvas:Clear();
	end
end
function HomeZoneView.Show()
	local _parent = ParaUI.GetUIObject(HomeZoneView.name);
	if(_parent:IsValid())then
		ParaUI.Destroy(HomeZoneView.name);
	end
	_parent = ParaUI.CreateUIObject("container", HomeZoneView.name or "", "_lb", 20, -450, 400, 50);
	_parent.background = "";
	_parent:AttachToRoot();
	local left,top,width,height = 0,0,32,32;
	local _this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.background = "Texture/3DMapSystem/common/leftarrow.png;";
	_this.onclick = ";Map3DSystem.App.HomeZoneView.Return();";
	_this.tooltip = "返回";
	_parent:AddChild(_this);
end
function HomeZoneView.Return()
	ParaUI.Destroy(HomeZoneView.name);
	System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/DoodleWorld"});
end

function HomeZoneView.FindFlower(lite3DCanvas)
	if(not lite3DCanvas)then return end
	local container = lite3DCanvas:GetContainer();
	local flower = {};
	HomeZoneView._Find(container,flower)
	return flower.result;
end
function HomeZoneView._Find(parent,flower)
	if(not parent or not parent.GetNumChildren)then return end
	local k,len = 1,parent:GetNumChildren();
	for k = 1,len do
		local child = parent:GetChildAt(k);
		if(child and child.CLASSTYPE == "Flower")then
			flower.result = child;
			break;
		else
			HomeZoneView._Find(child,flower)
		end
	end
end