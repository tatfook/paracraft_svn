--[[
Title: Edit/view Tile dialog box
Author(s):  Leio zhang & Lingfeng Sun(refactor by Lingfeng Sun on 2.28)
Date: 2008/2/22
Note: 
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditWnd.lua");
Map3DApp.TileEditWnd.Show(true);
-------------------------------------------------------
]]
if(not Map3DApp.TileEditWnd)then Map3DApp.TileEditWnd={} end;

--public
Map3DApp.TileEditWnd.name = "tileEditWnd";

--private
Map3DApp.TileEditWnd.x = 0;
Map3DApp.TileEditWnd.y = 0;
Map3DApp.TileEditWnd.width = 0;
Map3DApp.TileEditWnd.height = 0;
Map3DApp.TileEditWnd.parent = nil;
Map3DApp.TileEditWnd.bindingContext=nil;
Map3DApp.TileEditWnd.lastFilterType = nil;
Map3DApp.TileEditWnd.sideBarWidth = 282;
Map3DApp.TileEditWnd.modelInfoWnd = nil;

Map3DApp.TileEditWnd.modelGridView = nil;
Map3DApp.TileEditWnd.modelInfoWnd = nil;
Map3DApp.TileEditWnd.listeners = {};

--==========public method=================
--show tileEditWnd
function Map3DApp.TileEditWnd.Show(bShow)
	local self = Map3DApp.TileEditWnd;

	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self.CreateUI();
		self.SendMessage(self.Msg.formLoaded);
	else
		if(bShow == nil)then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		if(bShow)then
			self.SendMessage(self.Msg.formLoaded);
		end
	end
end

--release all resource
function Map3DApp.TileEditWnd.Release()
	log("Map3DApp.TileEditWnd.Release() not implement !\n");
end

function Map3DApp.TileEditWnd.SetTileInfo(tileInfo)
	local self = Map3DApp.TileEditWnd;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	--bind data
	self.bindingContext = commonlib.BindingContext:new();
	self.bindingContext:AddBinding(tileInfo,"ownerUserName",self.name.."#"..self.name.."tilePropertyPage#"..self.name.."ownerName",commonlib.Binding.ControlTypes.ParaUI_editbox,"text");
	self.bindingContext:UpdateDataToControls();
end

function Map3DApp.TileEditWnd.UpdateModelView(modelInfos)
	local self = Map3DApp.TileEditWnd;
	local _this = CommonCtrl.GetControl(self.name.."models");
	if(_this == nil)then
		return;
	end
	
	local root = _this.RootNode;
	root:ClearAllChildren();
	if(modelInfos)then
		local k,modelData;
		for k, modelData in ipairs(modelInfos)do
			root:AddChild(CommonCtrl.TreeNode:new({
				tag = modelData,
				Name = "SmallPic",
				SmallPicPath = modelData[ "picURL" ]
			}));
		end
	end
	_this:Update();
end
 
--set current page index
function Map3DApp.TileEditWnd.SetPageIndex(index)
	local _this = ParaUI.GetUIObject(Map3DApp.TileEditWnd.name.."pageindex");
	if(_this:IsValid())then
		_this.text = index;
	end
end

--set control parent
function Map3DApp.TileEditWnd.SetParent(_parent)
	Map3DApp.TileEditWnd.parent = _parent;
end

--set windows position
function Map3DApp.TileEditWnd.SetPosition(x,y)
	local self = Map3DApp.TileEditWnd;
	self.x = x;
	self.y = y;
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end

	_this.x = self.x;
	_this.y = self.y;
end

function Map3DApp.TileEditWnd.SetSize(width,height)
	local self = Map3DApp.TileEditWnd;
	self.width = width;
	self.height = height;
	if(self.width < 450)then self.width = 450;end
	if(self.height < 300)then self.height = 300;end
	
	--resize container
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this:SetSize(self.width,self.height);
		
		--resize scene
		_this = ParaUI.GetUIObject(self.name.."scene");
		if(_this:IsValid())then
			_this:SetSize(self.width - self.sideBarWidth - 8,self.height - 8);
		end
		
		_this = ParaUI.GetUIObject(self.name.."sideBar");
		if(_this:IsValid())then
			_this:SetSize(self.sideBarWidth - 4,self.height - 8);
		end
		
		--resize sideBar
		_this = ParaUI.GetUIObject(self.name.."modelEditPage");
		if(_this:IsValid())then
			_this.height = self.height - 33;
		end
		
		--resize 
		_this = ParaUI.GetUIObject(self.name.."tilePropertyPage");
		if(_this:IsValid())then
			_this.height = self.height - 33;
		end
		
		if(self.modelInfoWnd)then
			self.modelInfoWnd:SetSize(self.sideBarWidth-4,self.height - 360)
		end
	end
end

function Map3DApp.TileEditWnd.GetPosition()
	local _this = ParaUI.GEtUIObject(self.name);
	if(_this:IsValid())then
		return _this:GetAbsPosition();
	end
end

function Map3DApp.TileEditWnd.SetParentForm(parentForm)
	Map3DApp.TileEditWnd.parentForm = parentForm;
end

function Map3DApp.TileEditWnd.SetUIEventCallback(callback)
	Map3DApp.TileEditWnd.onUIMsg = callback;
end

function Map3DApp.TileEditWnd.AddMsgListener(listenerID,callback)
	if(listenerID ~= nil and listenerID ~= "" and callback ~= nil)then
		Map3DApp.TileEditWnd.listeners[listenerID] = callback;
	end
end

function Map3DApp.TileEditWnd.RemovelMsgListener(listenerID)
	if(listenerID ~= nil and listenerID ~= "")then
		Map3DApp.TileEditWnd.listeners[listenerID] = nil;
	end
end

function Map3DApp.TileEditWnd.SetPageIndex(index)
	local _this = ParaUI.GetUIObject(Map3DApp.TileEditWnd.name.."pageindex");
	if(_this:IsValid())then
		_this.text = index;
	end
end

--=========private method==================
--create ui resource
 function Map3DApp.TileEditWnd.CreateUI()
	local self = Map3DApp.TileEditWnd;
	local _this,_parent,_rootParent;
	
	_this = ParaUI.CreateUIObject("container",self.name,"_lt",self.x,self.y,self.width,self.height);
	if(self.parent ~= nil)then
		self.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	_rootParent = _this;
	
	--create edit scene container
	_this = ParaUI.CreateUIObject("container",self.name.."scene","_lt",5,5,541,546);
	_rootParent:AddChild(_this);
	_parent = _this;
	

	NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppTileEditScene.lua");
	Map3DApp.TileEditScene.SetParent(_parent);
	Map3DApp.TileEditScene.Show(bShow);


	--side bar container
	_this = ParaUI.CreateUIObject("container",self.name.."sideBar","_rt",-self.sideBarWidth,4,self.sideBarWidth,self.height-8);
	_rootParent:AddChild(_this);
	_parent = _this;

	--side bar tab page menu
	NPL.load("(gl)script/ide/MainMenu.lua");
	_this = CommonCtrl.GetControl(self.name.."menu");
	if(_this == nil)then
		_this = CommonCtrl.MainMenu:new{
			name = self.name.."menu",
			alignment = "_lt",
			left = 10,
			top = 5,
			width = 200,
			height = 20,
		};
		local node = _this.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "模型", Name = "model", onclick = Map3DApp.TileEditWnd.SwitchTabPage}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "属性", Name = "property", onclick = Map3DApp.TileEditWnd.SwitchTabPage}));
	end
	_this.parent = _parent;
	_this:Show(true);
	CommonCtrl.MainMenu.OnClickTopLevelMenuItem(self.name.."menu",1);
	
	
	--===================model edit page=======================
	_this = ParaUI.CreateUIObject("container",self.name.."modelEditPage","_lt",0,25,self.sideBarWidth-4,self.height-33);
	_this.fastrender = false;
	_parent:AddChild(_this);
	_parent = _this;
	
	--model type filter
	NPL.load("(gl)script/ide/dropdownlistbos.lua");
	_this = CommonCtrl.GetControl(self.name.."filter");
	if(_this == nil)then
		_this = CommonCtrl.dropdownlistbox:new{
			name = self.name.."filter",
			alignment = "_rt",
			left = -140,
			top = 6,
			width = 130,
			height = 20,
			dropdownheight = 106,
			text = "",
			items = {"建筑", "人物标记", "事件标记" },
			onselect = "Map3DApp.TileEditWnd.OnUIMsg(Map3DApp.TileEditWnd.Msg.filterChange)";
		};
	end;
	_this.parent = _parent;
	_this:Show();
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/GridView.lua");
	self.modelGridView = Map3DApp.ImageGridView:new{
		name = self.name.."modelGV",
		left = 0,
		top = 27,
		width = self.sideBarWidth-4,
		height = 260,
		cellWidth = 80,
		cellHeight = 80,
		cellSpaceX = 4,
		parent = _parent;
		maxCellCount= 9,
		onCellClick = Map3DApp.TileEditWnd.OnModelSelect;
	};
	self.modelGridView:Show(true);
	self.modelGridView:RefreshCells();
	
	--display page index
	_this = ParaUI.CreateUIObject("text",self.name.."pageindex","_rt",-180,290,50,23);
	_this.text = "1/1";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", self.name.."prePageBtn", "_rt", -135, 290, 60, 16)
	_this.text = "上一页";
	_this.onclick=";Map3DApp.TileEditWnd.OnPageDown();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", self.name.."nextPageBtn", "_rt", -70, 290, 60, 16)
	_this.text = "下一页";
	_this.onclick=";Map3DApp.TileEditWnd.OnPageUp();";
	_parent:AddChild(_this);
	
	--model infomation window
	if(not self.modelInfoWnd)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppModelInfoWnd.lua");
		self.modelInfoWnd = Map3DApp.ModelInfoWnd:new{
			name = self.name.."modelInfoWnd",
			alignment = "_lt",
			left = 0,
			top = 320,
			width = self.sideBarWidth - 4,
			height = 200,
			parent = _parent;
		}
	end
	self.modelInfoWnd:SetParent(_parent);
	self.modelInfoWnd:Show(true);	

	
	--=================tile property edit page=================
	_parent = ParaUI.GetUIObject(self.name.."sideBar")
	_this = ParaUI.CreateUIObject("container",self.name.."tilePropertyPage","_lt",0,25,self.sideBarWidth-4,self.height-33);
	_this.visible = false;
	_parent:AddChild(_this);
	_parent = _this;
	
	--_this = ParaUI.CreateUIObject("text","s","_lt",6,15,80,12);
	--_this.text = "土地名称:";
	--_parent:AddChild(_this);
	--
	--_this = ParaUI.CreateUIObject("imeeditbox",self.name.."ownerName","_lt",75,15,120,20);
	--_this.text = "none...";
	--_parent:AddChild(_this);
	
	--==================tabpage switch menu====================

end

function Map3DApp.TileEditWnd.SwitchTabPage(treeNode)
	local self = Map3DApp.TileEditWnd;
	local _this = CommonCtrl.GetControl(self.name.."menu");
	if(_this == nil)then
		return;
	end
	
	local name = treeNode.name;
	local modelViewPage = ParaUI.GetUIObject(self.name.."modelEditPage");
	local tilePropertyPage = ParaUI.GetUIObject(self.name.."tilePropertyPage");
	
	if(modelViewPage:IsValid() == false or tilePropertyPage:IsValid() == false)then
		return
	end
	
	if(treeNode.Name == "model")then
		modelViewPage.visible = true;
		tilePropertyPage.visible = false;
	elseif(treeNode.Name == "property")then
		modelViewPage.visible = false;
		tilePropertyPage.visible = true;
	end
end

function Map3DApp.TileEditWnd.OnModelSelect(ctrName,cellID)
	local self = Map3DApp.TileEditWnd;
	local _this = CommonCtrl.GetControl(ctrName);
	if(_this == nil)then
		return;
	end
	if(_this.cells[cellID] and _this.cells[cellID].data)then
		self.SendMessage(self.Msg.itemSelect,_this.cells[cellID].data);
	end
end

function Map3DApp.TileEditWnd.OnPageDown()
	local self = Map3DApp.TileEditWnd;
	self.SendMessage(self.Msg.pageDown,self.modelPageIndex);
end

function Map3DApp.TileEditWnd.OnPageUp()
	local self = Map3DApp.TileEditWnd;
	self.SendMessage(self.Msg.pageUp,self.modelPageIndex);
end

function Map3DApp.TileEditWnd.DrawLandWndNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil)then
		return;
	end
	
	local _this;
	local left = 2;
	local top = 2;
	local height = treeNode:GetHeight();
	local width = treeNode.TreeView.ClientWidth;
	
	left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	
	if(treeNode.TreeView.ShowIcon)then
		local iconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon ~= nil and iconSize > 0)then
			_this = ParaUI.CreateUIObject("button","b","_lt",left,(height-iconSize)/2,iconSize,iconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this,"255 255 255");
			_parent:AddChild(_this);
			left = left + iconSize + 3;
		end
	end
	
	if(treeNode.Name == "SmallPic")then
		_this = ParaUI.CreateUIObject("button","b","_lt",left + 10,4,128,68);
		_this.onclick = string.format(";Map3DApp.TileEditWnd.OnUIMsg(Map3DApp.TileEditWnd.Msg.ItemSelect,%q,%q)",treeNode.TreeView.name,treeNode:GetNodePath());
		local smallPicPath = "http://202.104.149.47"..treeNode.SmallPicPath;
		local temTex = ParaAsset.LoadRemoteTexture(smallPicPath,"Texture/whitedot.png");
		_this.background = smallPicPath..";0 0 -1 -1";
		_parent:AddChild(_this);
	end
end

--ui event handler function----------------
function Map3DApp.TileEditWnd.OnUIMsg(msg,data1)
	local self = Map3DApp.TileEditWnd;
	local data = nil;
	if(msg ~= nil and self.onUIMsg ~= nil)then
		if(msg == self.Msg.filterChange)then
			local _this = CommonCtrl.GetControl(self.name.."filter");
			if(_this == nil)then
				return;
			end
			data = _this:GetText();
			if(data == self.lastFilterType)then
				return;
			end
			self.lastFilterType = data;
		
		elseif(msg == self.Msg.ItemSelect and data)then
			local ctl, node = CommonCtrl.TreeView.GetCtl(data1, data2);
			data = node.tag;
			--TODO:Delete this,
			--if(node and node.tag) then
				--_guihelper.MessageBox(commonlib.serialize(node.tag));
			--end
			data = Map3DApp.ModelData:new{
				model = "model/map3D/building/bank/bank_6.x";
			};
		end
		
		self.onUIMsg(msg,data);
	end
end

function Map3DApp.TileEditWnd.SendMessage(msg,data)
	for __,callback in pairs(Map3DApp.TileEditWnd.listeners)do
		callback(msg,data);
	end
end

--========msg enum============
Map3DApp.TileEditWnd.Msg = {};
Map3DApp.TileEditWnd.Msg.pageUp = 1;
Map3DApp.TileEditWnd.Msg.pageDown = 2;
Map3DApp.TileEditWnd.Msg.itemSelect = 3;
Map3DApp.TileEditWnd.Msg.filterChange = 4;
Map3DApp.TileEditWnd.Msg.formLoaded = 5;
