--[[
Title: PortalCanvasView
Author(s): Leio
Date: 2008/12/29
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalCanvasView.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/Group.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/TreeView.lua");
local PortalCanvasView = {
	canvas = nil,
	name = "Portal3DCanvasView_instance",
	isShow = false,
}
commonlib.setfield("Map3DSystem.App.Creator.PortalCanvasView",PortalCanvasView);
function PortalCanvasView.Init()
	Map3DSystem.App.Inventor.GlobalInventor.commandCallBack = PortalCanvasView.OnRefresh;
end
function PortalCanvasView.Show(params)
	if(not params)then return end
	local self = PortalCanvasView;
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
		DrawNodeHandler = PortalCanvasView.DrawSingleSelectionNodeHandler,	
	};
	ctl:Show();
	CommonCtrl.AddControl(ctl.name,ctl);
end
function PortalCanvasView.DataBind(lite3DCanvas)	
	local self = PortalCanvasView;
	local ctl = CommonCtrl.GetControl(self.name.."treeView");
	if(ctl) then
		ctl.RootNode:ClearAllChildren();
		if(not lite3DCanvas)then return ;end
		local container = lite3DCanvas:GetContainer();
		PortalCanvasView.AddNode(ctl.RootNode,container);		
		ctl:Update();
	end
end
function PortalCanvasView.AddNode(parentNode,parent)
	if(not parentNode or not parent or not parent.GetNumChildren)then return end
	local k,child;
	local len = parent:GetNumChildren();
	for k =1,len do
		child = parent:GetChildAt(k);
		local uid = child:GetUID();
		local node = CommonCtrl.TreeNode:new({Text = uid, Name = uid, data = child})
		parentNode:AddChild(node);
		PortalCanvasView.AddNode(node,child)
	end
end
function PortalCanvasView.DrawSingleSelectionNodeHandler(_parent,treeNode)
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
	local canMetas = false;
	local child = treeNode.data;
	local asset;
	if(child and child.CLASSTYPE == "Building3D")then		
		local params = child:GetEntityParams();
		asset = params["AssetFile"];
		local url = asset..".meta";
		if(ParaIO.DoesFileExist(url))then
			canMetas = true;
		end		
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
			_this.onclick = string.format(";Map3DSystem.App.Creator.PortalCanvasView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			local child = treeNode.data;
			local selected;
			if(child)then
				selected = child:GetSelected();
			end
			local background = "Texture/3DMapSystem/common/image.png";
			if(asset)then
				local temp = asset..".png";	
				if(ParaIO.DoesFileExist(temp))then
					background = temp;
				end		
			else
				if(child and child.CLASSTYPE == "ZoneNode")then
					background = "Texture/3DMapSystem/Creator/BCS_Block.png";
				elseif(child and child.CLASSTYPE == "PortalNode")then
					background ="Texture/3DMapSystem/Creator/BCS_Door.png";	
				end
			end
			_this=ParaUI.CreateUIObject("button","b","_lt", left,0, 16, 16);	
			_this.background = background;
			_parent:AddChild(_this);
			left = left+22;
		
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			
			if(selected) then
				_this.background = "Texture/alphadot.png";
			else
				_this.background = "";
				_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			end
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";Map3DSystem.App.Creator.PortalCanvasView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
			if(canMetas)then
			_this=ParaUI.CreateUIObject("button","b","_rt", -55, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/page_white_c.png";
			_this.tooltip = "复制Metas";
			_this.onclick = string.format(";Map3DSystem.App.Creator.PortalCanvasView.OnCloneMetasItem(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);	
			end
			
			_this=ParaUI.CreateUIObject("button","b","_rt", -35, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/info.png";
			_this.tooltip = "编辑";
			_this.onclick = string.format(";Map3DSystem.App.Creator.PortalCanvasView.OnEditItem(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);	
		end
	end	
end
function PortalCanvasView.OnSelectNode(sCtrlName, nodePath)
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
function PortalCanvasView.OnRefresh()
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	if(lite3DCanvas)then
		PortalCanvasView.DataBind(lite3DCanvas)
	end
end
function PortalCanvasView.OnCloneMetasItem(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local child = node.data;
	if(child)then
		local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
		local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
		if(lite3DCanvas)then	
			local params = child:GetEntityParams();
			local asset = params["AssetFile"];

			--local asset = "model/01building/V3/pw/zsyh/zsyh-out.x"	
			local url = asset..".meta";
			--local url = "script/kids/3DMapSystemUI/Creator/ZonePortal_MetaFile_Example.xml";
			local modelName = ParaGlobal.GenerateUniqueID()
			if(url and modelName)then
				Map3DSystem.App.Creator.PortalMetasParser.url = url;	
				Map3DSystem.App.Creator.PortalMetasParser.modelName = modelName;
				local group = Map3DSystem.App.Creator.PortalMetasParser.Load();	
				if(group)then					
					
					local x,y,z = params.x,params.y,params.z;
					local rot_x,rot_y,rot_z,rot_w= params.rotation.x,params.rotation.y,params.rotation.z,params.rotation.w;
					local clone_node = group:Clone();			
					
					
					local point3D = {x = rot_x,y = rot_y,z = rot_z,w = rot_w};
					NPL.load("(gl)script/ide/mathlib.lua");
					local heading, attitude, bank = mathlib.QuatToEuler(point3D)
					--commonlib.echo(point3D);
					--commonlib.echo({heading, attitude, bank});

							
					lite3DCanvas:UnselectAll();
					clone_node:SetSelected(true);
					lite3DCanvas:AddChild(clone_node);
					clone_node:SetPosition(x,y,z);
					clone_node:vec3RotateByPoint(x, y, z, 0,heading,0);	
					clone_node:SetFacing(heading)	
					clone_node:UpdatePlanesParam(heading)			-- SetFacing
					lite3DCanvas:Update();	
					
					Map3DSystem.App.Creator.PortalMetasParser.url = nil;	
					Map3DSystem.App.Creator.PortalMetasParser.modelName = nil;
					
					PortalCanvasView.OnRefresh()
				end
			end
		end
	end
end
function PortalCanvasView.OnEditItem(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local child = node.data;
	if(child)then
		Map3DSystem.App.Inventor.GlobalInventor.BindPropertyPanel(child);
		PortalCanvasView.OnSelectNode(sCtrlName, nodePath)
	end
end