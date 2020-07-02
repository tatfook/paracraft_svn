--[[
Title:edit panel
Author(s): Lingfeng Sun
Date: 2008/3/11
Note: the edit panel container a series of button to edit models of a tile
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditPanel.lua");
Map3DApp.TileEditPanel.SetParent(parentWnd)
Map3DApp.TileEditPanel.Show(true);
-------------------------------------------------------
]]

if(not Map3DApp.TileEditPanel)then Map3DApp.TileEditPanel = {};end

--======private member=======
Map3DApp.TileEditPanel.name = "tileEditPanel";
Map3DApp.TileEditPanel.parent = nil;
Map3DApp.TileEditPanel.onButtonClick = nil;

--button name
Map3DApp.TileEditPanel.deleteBtn = Map3DApp.TileEditPanel.name.."delete";
Map3DApp.TileEditPanel.undoBtn = Map3DApp.TileEditPanel.name.."undo";
Map3DApp.TileEditPanel.redoBtn = Map3DApp.TileEditPanel.name.."redo";
Map3DApp.TileEditPanel.rightRotateBtn = Map3DApp.TileEditPanel.name.."rRotate";
Map3DApp.TileEditPanel.leftRotateBtn = Map3DApp.TileEditPanel.name.."lRotate";
Map3DApp.TileEditPanel.saveBtn = Map3DApp.TileEditPanel.name.."save";
Map3DApp.TileEditPanel.cancelBtn = Map3DApp.TileEditPanel.name.."cancel";

--=======public method========
function Map3DApp.TileEditPanel.Show(bShow)
	local self = Map3DApp.TileEditPanel;
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self.CreateUI();
	else
		if(bShow == nil)then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

--release all resource
function Map3DApp.TileEditPanel.Release()
	ParaUI.Destroy(Map3DApp.TileEditPanel.name);
	Map3DApp.TileEditPanel.parent = nil;
end

function Map3DApp.TileEditPanel.SetPosition(x,y)
	local self = Map3DApp.TileEditPanel;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.x = x;
		_this.y = y;
	end
end

function Map3DApp.TileEditPanel.GetAbsPosition()
	local self = Map3DApp.TileEditPanel;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		return _this:GetAbsPosition();
	end
end

function Map3DApp.TileEditPanel.SetParent(parentWnd)
	Map3DApp.TileEditPanel.parent = parentWnd;
end

function Map3DApp.TileEditPanel.EnableButton(buttonName)
	
end

function Map3DApp.TileEditPanel.SetMsgCallback(callback)
	Map3DApp.TileEditPanel.onButtonClick = callback;
end

--=========private============
function Map3DApp.TileEditPanel.CreateUI()
	local self = Map3DApp.TileEditPanel;
	
	_this = ParaUI.CreateUIObject("container",self.name,"_lt",0,0,400,40);
	_this.background = "";
	if(self.parent ~= nil)then
		self.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	
	local _parent = _this;
	_this = ParaUI.CreateUIObject("container","s","_lt",0,0,40,40);
	_this.background = "Texture/3DMapSystem/3DMap/MainBar_Left_BG.png";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container","s","_lt",40,0,320,40);
	_this.background = "Texture/3DMapSystem/3DMap/MainBar_Middle_BG.png";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container","s","_rt",-40,0,40,40);
	_this.background = "Texture/3DMapSystem/3DMap/MainBar_Right_BG.png";
	_parent:AddChild(_this);
	
	local left = 70;
	_this = ParaUI.CreateUIObject("button",self.deleteBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/delete.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.Delete)";
	_parent:AddChild(_this);
	
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",self.undoBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/undo.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.Undo)";
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",self.redoBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/redo.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.Redo)";
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",self.rightRotateBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/rotateR.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.RightRotate)";
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",self.leftRotateBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/rotateL.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.LeftRotate)";
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",self.saveBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/save.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.Save)";
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",self.cancelBtn,"_lt",left,4,32,32);
	_this.background = "Texture/3DMapSystem/3DMap/cancel.png";
	_this.onclick = ";Map3DApp.TileEditPanel.OnButtonClick(Map3DApp.TileEditPanel.Msg.Cancel)";
	_parent:AddChild(_this);
end

function Map3DApp.TileEditPanel.OnButtonClick(msg)
	if(msg == nil)then
		return;
	end
	
	if(Map3DApp.TileEditPanel.onButtonClick ~= nil)then
		Map3DApp.TileEditPanel.onButtonClick(msg);
	end
end

--=========message enum=========
Map3DApp.TileEditPanel.Msg = {};
Map3DApp.TileEditPanel.Msg.Cancel = 1;
Map3DApp.TileEditPanel.Msg.Delete = 2;
Map3DApp.TileEditPanel.Msg.RightRotate = 3;
Map3DApp.TileEditPanel.Msg.LeftRotate = 4;
Map3DApp.TileEditPanel.Msg.Save = 5;
Map3DApp.TileEditPanel.Msg.Undo = 6;
Map3DApp.TileEditPanel.Msg.Redo = 7;