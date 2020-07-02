--[[
Title: Edit/view Tile dialog box
Author(s):  Leio zhang
Date: 2008/2/22
Note: 
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgTile.lua");
Map3DApp.DlgTile.EditTile(tileInfo);
-------------------------------------------------------
]]
if(not Map3DApp.DlgTile)then Map3DApp.DlgTile={} end;
Map3DApp.DlgTile.CurPageIndex=1;
Map3DApp.DlgTile.PageTotal=1;
Map3DApp.DlgTile.PageNum=5;
Map3DApp.DlgTile.bindingContext=nil;
function Map3DApp.DlgTile.EditTile(tileInfo) 
	 local bindingContext = commonlib.BindingContext:new();
	 --binding Map3DApp.DlgTile.CurPageIndex to curPageIndex_text and pageTotal_text
	 bindingContext:AddBinding(Map3DApp.DlgTile, "GetCurPageIndex", "DlgEditTile#modelContainer#curPageIndex_text", commonlib.Binding.ControlTypes.ParaUI_text, "text")
	 --binding Map3DApp.DlgTile.PageTotal to pageTotal_text
	 bindingContext:AddBinding(Map3DApp.DlgTile, "GetPageTotal", "DlgEditTile#modelContainer#pageTotal_text", commonlib.Binding.ControlTypes.ParaUI_text, "text")
	 
	 bindingContext:AddBinding(tileInfo, "ownerUserName", "DlgEditTile#propertyContainer#ownerUserName", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	 
	 Map3DApp.DlgTile.bindingContext=bindingContext;
	 
	 _guihelper.ShowDialogBox("编辑土地", nil, nil, 800, 570, Map3DApp.DlgTile.CreateDlg, Map3DApp.DlgTile.OnDlgResult);
end

function Map3DApp.DlgTile.CreateDlg(_parent)
	Map3DApp.DlgTile.Show(_parent);
	-- tab views
	NPL.load("(gl)script/ide/MainMenu.lua");
	local ctl = CommonCtrl.GetControl("Map3DApp.TileInfoMainMenu");
	if(ctl==nil)then
		ctl = CommonCtrl.MainMenu:new{
			name = "Map3DApp.TileInfoMainMenu",
			alignment = "_lt",
			left = 560,
			top = 5,
			width = 200,
			height = 20,
			parent = _parent,
		};
		local node = ctl.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "模型", Name = "model", onclick = Map3DApp.DlgTile.TileInfoMainMenu_OnClick}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "属性", Name = "property", onclick = Map3DApp.DlgTile.TileInfoMainMenu_OnClick}));
			
	else
		ctl.parent = _parent
	end	
	ctl:Show(true);
	CommonCtrl.MainMenu.OnClickTopLevelMenuItem("Map3DApp.TileInfoMainMenu", 1);
	
end
--show UI
function Map3DApp.DlgTile.Show(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "DlgEditTile", "_fi", 0,0,0,0)
	_this.background = "";
	_parent:AddChild(_this);
	_parent = _this;
	
	

	_this = ParaUI.CreateUIObject("container", "TileScene", "_lt", 8, 8, 541, 546)
	_parent:AddChild(_this);


	-- tabPage1
	_this = ParaUI.CreateUIObject("container", "modelContainer", "_fi", 560, 18, 0, 0)
	_this.background = "Texture/whitedot.png;0 0 0 0";
	_parent:AddChild(_this);
	_parent = _this;

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "Map3DApp.OperationTypes",
		alignment = "_lt",
		left = 3,
		top = 11,
		width = 200,
		height = 20,
		dropdownheight = 106,
 		parent = _parent,
		text = "",
		items = {"模型标记", "人物标记", "事件标记" },
		onselect = "Map3DApp.DlgTile.OnSelection();",
	};
	ctl:Show();
	local ctl = CommonCtrl.GetControl("Map3DApp.DlgTile.modelsInfo");
		if(not ctl) then		
			ctl = CommonCtrl.TreeView:new{
				name = "Map3DApp.DlgTile.modelsInfo",
				alignment = "_lt",
				left = 6,
				top = 37,
				width = 205,
				height = 369,
				parent = _parent,
				container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
				DefaultIndentation = 5,
				DefaultNodeHeight = 70,
				DrawNodeHandler = Map3DApp.DlgTile.DrawLandWndNodeHandler
			};
		else
			ctl.parent = _parent;
		end		
		ctl:Show();
		Map3DApp.DlgTile.UpdateData()
	
	_this = ParaUI.CreateUIObject("text", "curPageIndex_text", "_lt", 6, 412, 20, 23)
	_this.text = "aa";
	_parent:AddChild(_this);
	_this = ParaUI.CreateUIObject("text", "text1", "_lt", 26, 412, 10, 23)
	_this.text = "/";
	_parent:AddChild(_this);
	_this = ParaUI.CreateUIObject("text", "pageTotal_text", "_lt", 36, 412, 20, 23)
	_this.text = "bb";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "prePageBtn", "_lt", 61, 412, 75, 23)
	_this.text = "上一页";
	_this.onclick=";Map3DApp.DlgTile.OnPrePage();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "nextPageBtn", "_lt", 137, 412, 75, 23)
	_this.text = "下一页";
	_this.onclick=";Map3DApp.DlgTile.OnNextPage();";
	_parent:AddChild(_this);

	-- tabPage2
	_this = ParaUI.CreateUIObject("container", "propertyContainer", "_fi", 560, 18, 0, 0)
	_this.background = "Texture/whitedot.png;0 0 0 0";
	_parent = ParaUI.GetUIObject("DlgEditTile");
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 6, 15, 80, 12)
	_this.text = "土地名称：";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("imeeditbox", "ownerUserName", "_lt", 75, 15, 120, 20)
	_this.text = "label2";
	_parent:AddChild(_this);

	
	--bottom btn
	_this = ParaUI.CreateUIObject("button", "deleteBtn", "_lt", 569, 493, 75, 40)
	_this.text = "删除";
	_parent = ParaUI.GetUIObject("DlgEditTile");
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "uploadBtn", "_lt", 699, 493, 75, 40)
	_this.text = "保存";
	_this.onclick=";Map3DApp.DlgTile.OnSave();";
	_parent:AddChild(_this);

	Map3DApp.DlgTile.bindingContext:UpdateDataToControls();
end
--tab control
function Map3DApp.DlgTile.TileInfoMainMenu_OnClick(treeNode)
	local ctl = CommonCtrl.GetControl("Map3DApp.TileInfoMainMenu");
	if(ctl==nil)then
		return
	end
	local name = treeNode.Name;
	local modelContainer,propertyContainer=ParaUI.GetUIObject("modelContainer"),ParaUI.GetUIObject("propertyContainer");
	if(name == "model") then
		modelContainer.visible=true;
		propertyContainer.visible=false;
	elseif(name == "property") then
		modelContainer.visible=false;
		propertyContainer.visible=true;
	end
end
--
function Map3DApp.DlgTile.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then
		
	end
	return true;
end
--Map3DApp.OperationTypes selected
function Map3DApp.DlgTile.OnSelection()
	local filenameCtl = CommonCtrl.GetControl("Map3DApp.OperationTypes");
	if(filenameCtl~=nil)then
	end
end
--draw treeNode
function Map3DApp.DlgTile.DrawLandWndNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	local width = nodeWidth;
	
	left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			left = left + IconSize+3;
		end	
	end	
	
	if(treeNode.Name == "SmallPic") then
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+10, 4, 128, 68)
		--_this.text = "";
		_this.onclick = string.format(";Map3DApp.DlgTile.OnClickSmallPicBtn(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		--["picURL"] = "/Uploads/MapModel/2D/25461cf2-a96f-4bdb-be73-a249510c17_0.png"
		local smallPicPath="http://202.104.149.47"..treeNode.SmallPicPath
		local tempTex = ParaAsset.LoadRemoteTexture(smallPicPath, "Texture/whitedot.png");
		_this.background=smallPicPath..";0 0 -1 -1";	
		_parent:AddChild(_this);
	end
end
--update data from web service
function Map3DApp.DlgTile.UpdateData()
	local msg = {
		operation = "get",
		pageNum = Map3DApp.DlgTile.PageNum,
		pageindex = Map3DApp.DlgTile.CurPageIndex
	};
	paraworld.map.GetMapModelOfPage(msg, "test", function(msg)
		--log(commonlib.serialize(msg));
		Map3DApp.DlgTile.GetMapModelOfPage_Succeed(msg)
	end);
	
end

function Map3DApp.DlgTile.OnClickSmallPicBtn(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node and node.tag) then
		_guihelper.MessageBox(commonlib.serialize(node.tag));
	end	
	
end
--succeed to visit the romote data
function Map3DApp.DlgTile.GetMapModelOfPage_Succeed(msg)
	local table=msg;
	local models=table["models"];
	local pagecount=table["pagecount"];
	
	Map3DApp.DlgTile.PageTotal=pagecount;
	local ctl = CommonCtrl.GetControl("Map3DApp.DlgTile.modelsInfo");
	if(ctl==nil)then
		log("error getting IDE's TreeView instance ".."Map3DApp.DlgTile.modelsInfo".."\r\n");
		return;
	end
	local root = ctl.RootNode;
	root:ClearAllChildren();
	if(models)then
		local k, modelData
		for k, modelData in ipairs(models) do
			root:AddChild( CommonCtrl.TreeNode:new({tag=modelData, Name = "SmallPic",SmallPicPath=modelData["picURL"]}) );
		end
	end
	ctl:Update();
	
	Map3DApp.DlgTile.bindingContext:UpdateDataToControls();
end
function Map3DApp.DlgTile.OnPrePage()
	if(Map3DApp.DlgTile.CurPageIndex>1)then
		Map3DApp.DlgTile.CurPageIndex=Map3DApp.DlgTile.CurPageIndex-1;
	else
		Map3DApp.DlgTile.CurPageIndex=Map3DApp.DlgTile.PageTotal;
	end
	Map3DApp.DlgTile.UpdateData();
end
function Map3DApp.DlgTile.OnNextPage()
	if(Map3DApp.DlgTile.CurPageIndex<Map3DApp.DlgTile.PageTotal)then
		Map3DApp.DlgTile.CurPageIndex=Map3DApp.DlgTile.CurPageIndex+1;
	else
		Map3DApp.DlgTile.CurPageIndex=1;
	end
	Map3DApp.DlgTile.UpdateData()
end

function Map3DApp.DlgTile.GetCurPageIndex()
	return tostring(Map3DApp.DlgTile.CurPageIndex);
end
function Map3DApp.DlgTile.GetPageTotal()
	return tostring(Map3DApp.DlgTile.PageTotal);
end
function Map3DApp.DlgTile.OnSave()
	Map3DApp.DlgTile.bindingContext:UpdateControlsToData();
	--TODO: 
	--send data to webserver and save changed
	--request data from webserver and update local data about user's tilelist info
end