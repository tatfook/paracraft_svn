--[[
Title: LiteCanvasView
Author(s): Leio
Date: 2008/11/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvasView.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/Group.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/TreeView.lua");
local LiteCanvasView = {
	canvas = nil,
	name = "LiteCanvasView_instance",
	isShow = false,
}
commonlib.setfield("Map3DSystem.App.Inventor.LiteCanvasView",LiteCanvasView);
function LiteCanvasView.Init()
	Map3DSystem.App.Inventor.GlobalInventor.commandCallBack = LiteCanvasView.OnRefresh;
end
function LiteCanvasView.ShowPage()
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemUI/Inventor/Container/LiteCanvasView.html", {cmdredirect=cmdredirect}), 
			name="LiteCanvasView.Wnd", 
			app_key=MyCompany.Apps.Inventor.app_key, 
			text = "资源库",
			icon = "Texture/3DMapSystem/common/lock.png",
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			isShowMinimizeBox = false,
			bToggleShowHide = false,
			DestroyOnClose = true,
			DestroyOnClose = true,
			directPosition = true,
				align = "_lt",
				x = 0,
				y = 200,
				width = 300,
				height = screenHeight - 300,
				bAutoSize=false,
			zorder=3,
		});
end
function LiteCanvasView.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="LiteCanvasView.Wnd", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
		bShow = false,bDestroy  = true});
end
function LiteCanvasView.Show(params)
	if(not params)then return end
	local self = LiteCanvasView;
	local _this = ParaUI.GetUIObject("container"..self.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", "container"..self.name, params.alignment, params.left, params.top, params.width, params.height);
		params.parent:AddChild(_this);
	end	
	local ctl = CommonCtrl.TreeView:new{
		name = self.name.."treeView",
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		parent = _this,
		DefaultNodeHeight = 22,
		ShowIcon = false,
		DrawNodeHandler = LiteCanvasView.DrawSingleSelectionNodeHandler,	
	};
	ctl:Show();
	CommonCtrl.AddControl(ctl.name,ctl);
end
function LiteCanvasView.DataBind(lite3DCanvas)	
	local self = LiteCanvasView;
	local ctl = CommonCtrl.GetControl(self.name.."treeView");
	if(ctl) then
		ctl.RootNode:ClearAllChildren();
		if(not lite3DCanvas)then return ;end
		local container = lite3DCanvas:GetContainer();
		LiteCanvasView.AddNode(ctl.RootNode,container);		
		ctl:Update();
	end
end
function LiteCanvasView.AddNode(parentNode,parent)
	if(not parentNode or not parent or not parent.GetNumChildren)then return end
	local k,child;
	local len = parent:GetNumChildren();
	for k =1,len do
		child = parent:GetChildAt(k);
		local uid = child:GetUID();
		local node = CommonCtrl.TreeNode:new({Text = uid, Name = uid, data = child})
		parentNode:AddChild(node);
		LiteCanvasView.AddNode(node,child)
	end
end
function LiteCanvasView.DrawSingleSelectionNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		if(not treeNode.bSkipIconSpace) then
			left = left + IconSize;
		end	
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.Type=="Title") then
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.text = treeNode.Text;
	elseif(treeNode.Type=="separator") then
		_this=ParaUI.CreateUIObject("button","b","_mt", left, 2, 1, 1);
		_this.background = "Texture/whitedot.png";
		_this.enabled = false;
		_guihelper.SetUIColor(_this, "150 150 150 255");
		_parent:AddChild(_this);
	else
		if(treeNode:GetChildCount() > 0) then
			-- node that contains children. We shall display some
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top+6, 10, 10);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/common/itemopen.png";
			else
				_this.background = "Texture/3DMapSystem/common/itemclosed.png";
			end
			_guihelper.SetUIColor(_this, "255 255 255");
			left = left + 16;
			
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			local child = treeNode.data;
			local selected;
			if(child)then
				selected = child:GetSelected();
			end
			if(selected) then
				_this.background = "Texture/alphadot.png";
			else
				_this.background = "";
				_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			end
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";Map3DSystem.App.Inventor.LiteCanvasView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			local child = treeNode.data;
			local selected;
			if(child)then
				selected = child:GetSelected();
			end
			if(selected) then
				_this.background = "Texture/alphadot.png";
			else
				_this.background = "";
				_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			end
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";Map3DSystem.App.Inventor.LiteCanvasView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
		end
	end	
end
function LiteCanvasView.OnSelectNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		local child = node.data;
		local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
		if(child)then
			if(lite3DCanvas)then
				lite3DCanvas:UnselectAll();
			end
			child:SetSelected(true);
		end
		node:SelectMe(true)
	end
end
function LiteCanvasView.OnRefresh()
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	if(lite3DCanvas)then
		LiteCanvasView.DataBind(lite3DCanvas)
	end
end
