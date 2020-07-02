--[[
Title: display and edit MCML maps by the user or its friends, etc.  
Author(s): LiXizhi, Leio zhang, refactored by LiXizhi 2008.2.11
Date: 2008/1/21
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/MyMapWnd.lua");
Map3DApp.MyMapWnd.Show(true,_parent);
-------------------------------------------------------
]]

if(not Map3DApp.MyMapWnd)then Map3DApp.MyMapWnd = {};end;

Map3DApp.MyMapWnd.name="Map3DApp.MyMapWnd";
Map3DApp.MyMapWnd.MyMapViewName="Map3DApp.treeViewMyMaps";

function Map3DApp.MyMapWnd.Show(bShow,_parent)

	local _this = ParaUI.GetUIObject(Map3DApp.MyMapWnd.name);

	if(_this:IsValid()) then
		_this.visible = bShow;
	else
		if(bShow == false) then return end
		-- root container
		_this = ParaUI.CreateUIObject("container", Map3DApp.MyMapWnd.name, "_fi",2, 25, 2, 2)
		_this.visible = bShow;
		_this.background = "";
		_this.onsize = ";Map3DApp.MyMapWnd.OnSizeChange();";
		_parent:AddChild(_this);
		_parent = _this;
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Map3DApp.treeViewMyMaps");
		if(not ctl) then
			ctl = CommonCtrl.TreeView:new{
				name = "Map3DApp.treeViewMyMaps",
				alignment = "_fi",
				left = 2,
				top = 2,
				width = 2,
				height = 2,
				parent = _parent,
				DefaultIconSize = 18,
				DefaultIndentation = 15,
				DefaultNodeHeight = 25,
				onclick = Map3DApp.MyMapWnd.OnClickMapNode,
				DrawNodeHandler = Map3DApp.MyMapWnd.DrawMyMapNodeHandler,
			};
			local node = ctl.RootNode;
			node:AddChild( CommonCtrl.TreeNode:new({Text = "我的家", Name = "Home", Type = "Home", Icon = "Texture/3DMapSystem/common/Home.png" }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "新建地图   保存", Name = "MapOperations", Type = "MapOperations", }) );
			node:AddChild( CommonCtrl.TreeNode:new({Text = "我的地图", Name = "MyMaps", Type = "MyMaps", Icon = "Texture/3DMapSystem/common/MapNode.png"}) );
			node = node:AddChild( CommonCtrl.TreeNode:new({Text = "朋友的地图", Name = "FriendsMaps", Type = "FriendsMaps",Icon = "Texture/3DMapSystem/common/Users_Group.png"}) );
				-- TODO: remove this
				node:AddChild( CommonCtrl.TreeNode:new({Text = "Andy的地图", Name = "map", Type = "map", Icon = "Texture/3DMapSystem/common/MapNode.png"}) );
				node = node.parent;
			node = node:AddChild( CommonCtrl.TreeNode:new({Text = "推荐内容", Name = "FeaturedMaps", Type = "FeaturedMaps", Icon = "Texture/3DMapSystem/common/light.png"}) );
				-- TODO: remove this
				node:AddChild( CommonCtrl.TreeNode:new({Text = "ParaWorld官网地图", Name = "map", Type = "map", Icon = "Texture/3DMapSystem/common/MapNode.png"}) );
			
		else
			ctl.parent = _parent;
		end		
		ctl:Show();
		
		-- fill data
		Map3DApp.MyMapWnd.UpdateData();
	end
end

function Map3DApp.MyMapWnd.Destroy()
	ParaUI.Destroy(Map3DApp.MyMapWnd.name);
end

function Map3DApp.MyMapWnd.OnSizeChange()
	local ctl = CommonCtrl.GetControl("Map3DApp.treeViewMyMaps");
	if(ctl) then
		ctl:Update();
	end
end

-- maps tree view owner draw callback
function Map3DApp.MyMapWnd.DrawMyMapNodeHandler(_parent, treeNode)
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
	
	if(treeNode.Type == "Home") then
		--
		-- home 
		--
		CommonCtrl.TreeView.RenderTextNode(_parent,treeNode, left, top, width, height)
	elseif(treeNode.Type == "MapOperations") then
		--
		-- map operations: new map folder, save and refresh map buttons
		--
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+3, 4, 54, 18)
		_this.text = "新建";
		_this.onclick = ";Map3DApp.MyMapWnd.OnClickAddFolder();"
		
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+63, 4, 54, 18)
		_this.text = "保存";
		_this.onclick = ";Map3DApp.MarkProvider.SaveLocalMyMap();"
		_parent:AddChild(_this);
		
	elseif(treeNode.Type == "MyMaps" or treeNode.Type == "map") then
		--
		-- My maps parent node. Since each person has only one map in current version, this is similar to map node. child nodes are folder
		--
		--
		-- map node of an ordinary map owned by some one. child nodes are folder
		--
		if(treeNode:GetChildCount() > 0) then
			width = 12 -- check box width
			local _this=ParaUI.CreateUIObject("button","b","_lt", left, top+6 , width, width);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/common/itemopen.png";
			else
				_this.background = "Texture/3DMapSystem/common/itemclosed.png";
			end
		else
			if(not treeNode.Expanded) then
				treeNode.Expanded = true;
			end
		end	
		
		_this = ParaUI.CreateUIObject("button", "l", "_mt", left+3, 3, 22, height-2)
		_this.text = treeNode.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		if(treeNode:GetChildCount() > 0) then
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		end	
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button4", "_rt", -21, 6, 16, 16)
		_this.background = "Texture/3DMapSystem/common/Refresh.png"
		_this.tooltip = "与服务器同步";
		_this.onclick = string.format(";Map3DApp.MyMapWnd.OnClickSyncMapNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		
	elseif(treeNode.Type == "folder") then
		--
		-- folder node
		--
		width = 16 
		local _this=ParaUI.CreateUIObject("button","b","_lt", left, (height-width)/2 , width, width);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 3;
		if(treeNode.Expanded) then
			_this.background = "Texture/3DMapSystem/common/Folder_open.png";
		else
			_this.background = "Texture/3DMapSystem/common/Folder.png";
		end
	
		-- check box
		_this = ParaUI.CreateUIObject("button", "checkbox", "_lt", left, (height-width)/2 , width, width);
		if(treeNode.IsChecked) then
			_this.background = "Texture/checkbox.png";
		else
			_this.background = "Texture/uncheckbox.png";
		end
		_this.tooltip = "是否显示在地图上"
		_this.onclick = string.format(";Map3DApp.MyMapWnd.OnCheckFolderNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 3;
		
		_this = ParaUI.CreateUIObject("button", "l", "_mt", left, top, 44, height-top)
		_this.text = treeNode.Text or treeNode.tag.title;
		_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_rt", -42, 6, 16, 16)
		_this.background = "Texture/3DMapSystem/common/comment_edit.png"
		_this.tooltip = "编辑目录";
		_this.onclick = string.format(";Map3DApp.MyMapWnd.OnClickFolderEditMode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button4", "_rt", -21, 6, 16, 16)
		_this.background = "Texture/3DMapSystem/common/Trash.png"
		_this.onclick = string.format(";Map3DApp.MyMapWnd.OnClickDeleteFolderNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.tooltip = "删除";
		_parent:AddChild(_this);
	elseif(treeNode.Type == "folderedit") then
		--
		-- edit folder 
		--
		_this = ParaUI.CreateUIObject("button", "l", "_mt", left+3, 3, 64, height-3)
		_this.text = treeNode.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
		_this.background = "";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -60, 4, 55, 18)
		_this.text = "编辑";
		_this.onclick = string.format(";Map3DApp.MyMapWnd.OnClickEditFolder(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
			
	elseif(treeNode.Type == "mark") then
		--
		-- mark inside a folder node. 
		--
		local icon = treeNode.tag:GetIcon();
		if(icon~=nil) then
			local IconSize = treeNode.TreeView.DefaultIconSize;
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			left = left + IconSize+3;
		end	
		
		if(treeNode.Selected) then
			_this = ParaUI.CreateUIObject("button", "l", "_mt", left+3, 3, 44, 22)
			_this.text = treeNode.Text or treeNode.tag.markTitle;
			if(treeNode.tag.textColor) then
				_this:GetFont("text").color = treeNode.tag.textColor;
			end	
			_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
			_this.background = "Texture/alphadot.png";
			_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "button5", "_rt", -42, 6, 16, 16)
			_this.background = "Texture/3DMapSystem/common/comment_edit.png"
			_this.tooltip = "编辑标记";
			_this.onclick = string.format(";Map3DApp.MyMapWnd.OnClickEditMark(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
		else
			_this = ParaUI.CreateUIObject("button", "l", "_mt", left+3, 3, 22, 22)
			_this.text = treeNode.Text or treeNode.tag.markTitle;
			if(treeNode.tag.textColor) then
				_this:GetFont("text").color = treeNode.tag.textColor;
			end	
			_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			_this.onclick = string.format(";CommonCtrl.TreeView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
		end
				
		
		_this = ParaUI.CreateUIObject("button", "button4", "_rt", -21, 6, 16, 16)
		_this.background = "Texture/3DMapSystem/common/Trash.png"
		_this.onclick = string.format(";Map3DApp.MyMapWnd.OnClickDeleteMarkNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.tooltip = "删除";
		_parent:AddChild(_this);
		
	elseif(treeNode.Type == "marktemplates") then
		--
		-- the parent node for various new mark templates that can be instanced.child nodes are newmark
		--
		Map3DApp.MyMapWnd.RenderCategoryNode(_parent,treeNode, left,top, width, height, "42 165 42")
		
	elseif(treeNode.Type == "newmark") then
		--
		-- a mark template inside marktemplates, from which a new mark can be created. 
		--
		CommonCtrl.TreeView.RenderTextNode(_parent,treeNode, left, top, width, height)
	elseif(treeNode.Type == "FriendsMaps") then
		--
		-- parent node for all other people's map nodes. child nodes are map
		--
		Map3DApp.MyMapWnd.RenderCategoryNode(_parent,treeNode, left,top, width, height)
		
	elseif(treeNode.Type == "FeaturedMaps") then
		--
		-- parent node of all featured maps: child nodes are map
		--
		Map3DApp.MyMapWnd.RenderCategoryNode(_parent,treeNode, left,top, width, height)
	end
	
end

-- render a category node that can expand child nodes. 
function Map3DApp.MyMapWnd.RenderCategoryNode(_parent,treeNode, left, top, width, height, textColor)
	if(treeNode:GetChildCount() > 0) then
		width = 12 -- check box width
		local _this=ParaUI.CreateUIObject("button","b","_lt", left, top+6 , width, width);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 2;
		
		if(treeNode.Expanded) then
			_this.background = "Texture/3DMapSystem/common/itemopen.png";
		else
			_this.background = "Texture/3DMapSystem/common/itemclosed.png";
		end
	else
		if(not treeNode.Expanded) then
			treeNode.Expanded = true;
		end
	end	
	
	_this = ParaUI.CreateUIObject("button", "l", "_mt", left+3, 3, 2, height-2)
	_this.text = treeNode.Text;
	_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
	if(textColor) then
		_this:GetFont("text").color = textColor;
	end
	_this.background = "";
	_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
	if(treeNode:GetChildCount() > 0) then
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
	end	
	_parent:AddChild(_this);
end

------------------------------------------------
-- UI methods: add folder and mark node. 
------------------------------------------------

-- Update data from current settings. 
function Map3DApp.MyMapWnd.UpdateData()
	local ctl = CommonCtrl.GetControl("Map3DApp.treeViewMyMaps");
	if(ctl==nil)then
		log("error getting IDE's TreeView instance ".."Map3DApp.treeViewMyMaps".."\r\n");
		return;
	end
	--
	-- add my map
	--
	local nodeMyMap = ctl.RootNode:GetChildByName("MyMaps");
	-- clear children and refill
	nodeMyMap:ClearAllChildren();
	local map=Map3DApp.MarkProvider.GetMyMap();
	if(map)then
		-- add map object to tag
		nodeMyMap.tag = map
		
		-- add all folders to the map 
		local k, folderInfo
		for k, folderInfo in ipairs(map) do
			local folderNode = Map3DApp.MyMapWnd.AddFolderNode(nodeMyMap, folderInfo)
			-- add all marks to each folder
			if(folderNode and folderInfo.list)then
				local kk, markInfo;
				for kk, markInfo in ipairs(folderInfo.list) do
					Map3DApp.MyMapWnd.AddMarkNode(folderNode, markInfo);
				end
			end
		end
	end
	--
	-- TODO: add friends' maps: The Locked property of markNode should be true. 
	--
	
	--
	-- TODO: add my featured maps: The Locked property of markNode should be true. 
	--
	ctl:Update();
	
	-- update the UI layer
	--Map3DApp.MarkUILayer.OnViewRegionChange();
end


-- add new folder node to a given map node
-- @param mapNode: the map node to which the folder node is added.  
-- @param bUpdateUI: true to update UI. 
function Map3DApp.MyMapWnd.AddFolderNode(mapNode, folderInfo, bUpdateUI)
	if(mapNode) then
		local nodeFolder = mapNode:AddChild( CommonCtrl.TreeNode:new({tag=folderInfo, Name = "folder", Type = "folder", IsChecked = true,}) );
		if(bUpdateUI) then
			nodeFolder.TreeView:Update(nil, nodeFolder);
		end
		return nodeFolder;
	end	
end

-- add a new mark node to the given folder Node
function Map3DApp.MyMapWnd.AddMarkNode(folderNode, markInfo, bUpdateUI)
	if(folderNode) then
		local nodeMark = folderNode:AddChild( CommonCtrl.TreeNode:new({tag=markInfo, Name = "mark", Type = "mark"}));
		if(bUpdateUI) then
			nodeMark:SelectMe();
			nodeMark.TreeView:Update(nil, nodeMark);
		end
		return nodeMark;
	end	
end


-- it will append a special mark templates as first child node at the given folder node if it has not been created before
-- @param nodeFolder: the folder node
-- @param bUpdateUI: true to update UI. 
function Map3DApp.MyMapWnd.AppendMarkTemplatesToFolder(nodeFolder, bUpdateUI)
	if(nodeFolder) then
		local templatesNode = nodeFolder:GetChildByName("marktemplates");
		if(not templatesNode) then
			-- add to front
			-- show the edit folder node
			nodeFolder:AddChild( CommonCtrl.TreeNode:new({Text = "编辑目录", Name = "folderedit", Type = "folderedit", }), 1);
					
			templatesNode = nodeFolder:AddChild( CommonCtrl.TreeNode:new({Text = "点击创建新标记", Name = "marktemplates", Type = "marktemplates", }), 2);
			templatesNode:AddChild( CommonCtrl.TreeNode:new({Text = "玩家标记", Name = "player", Type = "newmark", markStyle = 1, Icon = Map3DApp.mark_styles[1].icon}) );
			templatesNode:AddChild( CommonCtrl.TreeNode:new({Text = "城市标记", Name = "city", Type = "newmark", markStyle = 2, Icon = Map3DApp.mark_styles[2].icon}) );
			templatesNode:AddChild( CommonCtrl.TreeNode:new({Text = "事件标记", Name = "event", Type = "newmark", markStyle = 3, Icon = Map3DApp.mark_styles[3].icon}) );
		else
			nodeFolder:Expand();
			templatesNode:Expand();
		end
		if(bUpdateUI) then
			nodeFolder.TreeView:Update(nil, nodeFolder);
		end
	end
end

-- return an iterator of visible markNode in the tree view. 
-- this will includes all marks in my maps, featured maps, and friends maps. 
function Map3DApp.MyMapWnd.IteratorNextVisibleMarkNode()
	local ctl = CommonCtrl.GetControl("Map3DApp.treeViewMyMaps");
	if(ctl==nil)then
		--log("error getting IDE's TreeView instance ".."Map3DApp.treeViewMyMaps".."\r\n");
		return;
	end
	local node = ctl.RootNode:GetNextNode();
	
	return function()
		while (node~=nil) do
			if(node.Type == "mark") then
				local markNode = node;
				node = node:GetNextNode2(true);
				return markNode;
			elseif(node.Type == "marktemplates") then
				node = node:GetNextNode2(true);
			elseif(node.Type == "folder") then
				-- skip folder if folder is not visible
				node = node:GetNextNode2(not node.IsChecked);
			else
				node = node:GetNextNode2();
			end
		end
	end
end

------------------------------------------------
-- event handlers
------------------------------------------------
-- general map node onclick event
function Map3DApp.MyMapWnd.OnClickMapNode(treeNode)
	if(treeNode.Type == "newmark") then
		-- create a new mark. 
		--
		-- add to folderInfo object
		--
		local folderNode = treeNode.parent.parent;
		local folderInfo = folderNode.tag;
		local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
		local x,y ,_,viewRegionSize= mapBrowser:GetViewParams();
		local markInfo = folderInfo:AddMark({x = x, y = y, markStyle = treeNode.markStyle});
		
		-- 
		-- add to treeview UI
		--
		local markNode = Map3DApp.MyMapWnd.AddMarkNode(folderNode, markInfo, true);
		
		-- show the edit mark dlg
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgMark.lua");
		Map3DApp.DlgMark.EditMark(markNode);

		--
		-- refresh UI layer. 
		--
		Map3DApp.MarkUILayer.OnViewRegionChange()
	end
end

------------------------
-- map event
------------------------

-- syn the map with the remote server
function Map3DApp.MyMapWnd.OnClickSyncMapNode(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node) then
		local mapInfo = node.tag;
		-- TODO: syn the map with the remote server
	end
end

------------------------
-- mark event
------------------------
-- user clicks to delete a mark inside a folder node. 
function Map3DApp.MyMapWnd.OnClickDeleteMarkNode(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node and node.tag) then
		local markInfo=node.tag;
		_guihelper.MessageBox(string.format("确定要删除标记<%s>么?  一旦删除将不可逆转。\n", markInfo.markTitle), function()
			-- remove from data
			node.parent.tag:RemoveMark(markInfo.markID)
			-- remove from UI
			node:Detach();
			node.TreeView:Update();
			-- refresh UI layer
			Map3DApp.MarkUILayer.OnViewRegionChange()
		end);
	end
end

function Map3DApp.MyMapWnd.OnClickEditMark(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node and node.tag) then
		-- show the edit mark dlg
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgMark.lua");
		Map3DApp.DlgMark.EditMark(node);
	end	
end

------------------------
-- folder event
------------------------
-- user checks to show/hide a map folder 
function Map3DApp.MyMapWnd.OnCheckFolderNode(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node) then
		node.IsChecked = not node.IsChecked;
		ctl:Update();
		Map3DApp.MarkUILayer.OnViewRegionChange();
	end	
end

-- use clicks to edit the folder node. 
function Map3DApp.MyMapWnd.OnClickFolderEditMode(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node) then
		-- show the folder edit node group 
		Map3DApp.MyMapWnd.AppendMarkTemplatesToFolder(node, true);
	end
end	

-- show the folder editor dialog
function Map3DApp.MyMapWnd.OnClickEditFolder(sCtrlName, nodePath)
	log("on click\n");
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node) then
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgFolder.lua");
		Map3DApp.DlgFolder.EditFolder(node.parent)
	end
end

-- add a folder to my map
function Map3DApp.MyMapWnd.OnClickAddFolder()
	-- 
	-- add to mapInfo object
	--
	local map=Map3DApp.MarkProvider.GetMyMap();
	local folderInfo = map:AddFolder();
	-- 
	-- add to treeview UI
	--
	local ctl = CommonCtrl.GetControl("Map3DApp.treeViewMyMaps");
	if(ctl==nil)then
		log("error getting IDE's TreeView instance ".."Map3DApp.treeViewMyMaps".."\r\n");
		return;
	end
	local mapNode = ctl.RootNode:GetChildByName("MyMaps");
	local folderNode = Map3DApp.MyMapWnd.AddFolderNode(mapNode, folderInfo);
	Map3DApp.MyMapWnd.AppendMarkTemplatesToFolder(folderNode, true);
	-- show the folder editor dialog
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgFolder.lua");
	Map3DApp.DlgFolder.EditFolder(folderNode);
end


-- user clicks to delete a folder inside a map node. 
function Map3DApp.MyMapWnd.OnClickDeleteFolderNode(sCtrlName, nodePath)
	local ctl, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath);
	if(node and node.tag) then
		local folderInfo=node.tag;
		_guihelper.MessageBox(string.format("确定要删除目录<%s>么?  一旦删除将不可逆转。\n", folderInfo.title), function()
			-- remove from data
			node.parent.tag:RemoveFolder(folderInfo.ID)
			-- remove from UI
			node:Detach();
			node.TreeView:Update();
			-- refresh UI layer
			Map3DApp.MarkUILayer.OnViewRegionChange()
		end);
	end
end
