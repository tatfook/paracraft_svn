--[[
Title: Movie Manager
Author(s): LiXizhi
Date: 2008/8/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieManager.lua");
local MovieManager = Map3DSystem.Movie.MovieManager;
MovieManager:Load();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/TreeView.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieListPage.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieAssetsPage.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieAssetsManager.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieEditPage.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieActor.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/CaptionTracksEditorPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieEditPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/AssetsManager.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor.lua");
------------------------------------------------------------------------------------------
-- MovieManager
------------------------------------------------------------------------------------------
-- the mcml page to present the movie manager. 
-- note: this is optional.
local MovieManager = {
	name = "moviemanager_instance",
	moviescript = nil, 
	
};
commonlib.setfield("Map3DSystem.Movie.MovieManager",MovieManager);
function MovieManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o.rootNode = CommonCtrl.TreeNode:new({Text = "影片", Type = "pe:movie", dataNode = nil,  Expanded = true, });
	return o
end
-- to data bind the movie manager to a given movie script model. 
-- @param moviescript: the movie script object (treenode) to bind to. 
function MovieManager:DataBind(moviescript)
	if(not moviescript)then return; end
	self.moviescript = moviescript;
	local treeviewName = self.name.."treeView";
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl) then		
		local movies = self.moviescript.moviesNode;
		local movie = movies:GetChild(1);
		if(movie)then
			self.rootNode:ClearAllChildren();		
			local valueNode = movie:GetChild("value");
			self.rootNode.dataNode = movie;
			self.movie = movie;
			local nodes = valueNode;
			local node;
			if(nodes)then
				for node in nodes:next() do
						self:CreateTreeNode(self.rootNode,node)				
				end	
			end			
			self:RefreshViewWnd()
		end
	end
end
function MovieManager:CreateTreeNode(rootNode,node)
	if(not rootNode or not node)then return; end
	local id = node:GetNumber("id") or node:GetNumber("assetid") or -1;
	local treeNode = CommonCtrl.TreeNode:new({
												Text = id,
												canPreview = false,	
												canEnabled = true,
												canEdit = false,
												canDelete = true,
												canImport = false,
												dataNode = node,
												
												UnselectedNodeHeight = 22,
												SelectedNodeHeight = 40,
												Expanded = false,
												});
	rootNode:AddChild(treeNode);
	local id = node:GetNumber("assetid");
	local clip = self.moviescript.clips_mapping[id];
	if(clip)then
		local nodeValue = clip:GetChild("value");
		if(nodeValue)then
			local item;
			for item in nodeValue:next() do
				local id = item:GetNumber("assetid") or -1;
				local childNode = CommonCtrl.TreeNode:new({
												Text = id,
												canPreview = false,	
												canEnabled = false,
												canEdit = false,
												canDelete = true,
												canImport = false,
												dataNode = item,
												
												UnselectedNodeHeight = 22,
												SelectedNodeHeight = 40,
												Expanded = false,
												});
				treeNode:AddChild(childNode);
			end
		end
	end
end
-- create the treeview control to display a movie.
function MovieManager:CreateViewWnd(_parent)
	local ctl = CommonCtrl.TreeView:new{
		name = self.name.."treeView",
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		parent = _parent,
		DefaultNodeHeight = 22,
		ShowIcon = false,
		DrawNodeHandler = Map3DSystem.Movie.MovieManager.DrawViewNodeHandler,	
	};
	ctl.movieManager = self;
	ctl.RootNode:AddChild(self.rootNode);
	ctl:Show(true);
end
function MovieManager:RefreshViewWnd(node)
	local treeviewName = self.name.."treeView";
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl) then
		ctl:Update(node);
	end
end
-- event node draw handler
function MovieManager.DrawViewNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 3;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	-- render each node type	
	if(treeNode.Type) then
		_parent.background = ""
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top-2, 16, 16);
		_this.background = "Texture/3DMapSystem/common/ViewFiles.png";
		_parent:AddChild(_this);
		left = left+22;
		
		local movieManager = treeNode.TreeView.movieManager;
		local moviescript = Map3DSystem.Movie.MovieListPage.SelectedMovieManager.moviescript;

		local len = treeNode:GetChildCount();
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		local title = treeNode.Text or "物体";
		_this.text = string.format("%s:共%d个",title,len);
		
		if(movieManager  and (moviescript == movieManager.moviescript) )then
						
			--_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			--_this.background = "Texture/3DMapSystem/common/package_add.png";
			--_this.tooltip = "新增";
			--_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnNewItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), treeNode.Type);
			--_parent:AddChild(_this);
			--left = left+20;
			
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/delete.png";
			_this.tooltip = "删除全部";
			_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnDeleteAllItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), treeNode.Type);
			_parent:AddChild(_this);
			left = left+20;
		end
	else
		MovieManager.Child_DrawViewNodeHandler(_parent,treeNode);
	end	
end
function MovieManager.Child_DrawViewNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local movieManager = treeNode.TreeView.movieManager;
	local moviescript = Map3DSystem.Movie.MovieListPage.SelectedMovieManager.moviescript;
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 3;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	_parent.background = ""
	local mcmlName = "";
	if(treeNode.dataNode)then
		mcmlName =  treeNode.dataNode.name;
	end
	
	_this=ParaUI.CreateUIObject("button","b","_lt", left, top-2, 16, 16);
	_this.background = Map3DSystem.Movie.MovieScript["Icon"][mcmlName] or "Texture/3DMapSystem/common/film.png";
	_parent:AddChild(_this);
	left = left+22;
			
	_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
	_parent:AddChild(_this);
	_this.text = string.format("%s",treeNode.Text);
	
	-- duration
	local duration;
	if(mcmlName == "pe:movie-clip-item" )then
		duration = movieManager.moviescript:GetClipItemDuration(treeNode.dataNode)
		duration = duration or 0;
		duration = CommonCtrl.Animation.Motion.TimeSpan.GetTime(duration)
		_this=ParaUI.CreateUIObject("text","b","_rt", -60, top , 60, height - 1);
		_parent:AddChild(_this);
		_this.text = string.format("%s",duration);
		_guihelper.SetFontColor(_this, "128 128 128")
	end
	 
	-- click area to select this node
	_this=ParaUI.CreateUIObject("button","b","_fi", 0,0,0,0);
	_this.background = "";
	_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnToggleNode(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
	_parent:AddChild(_this);
	
	if(treeNode.Selected) then	
		_parent.background = "Texture/alphadot.png"	
		top = top + 16;
		left = 5;
		--if(treeNode.canImport)then
			--_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			--_this.background = "Texture/3DMapSystem/common/plugin_add.png";
			--_this.tooltip = "导入";
			--_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnImportItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			--_parent:AddChild(_this);
			--left = left+20;
		--end
		if(treeNode.canDelete)then	
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/delete.png";
			_this.tooltip = "删除";
			_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnDeleteItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;
		end
		if(treeNode.canEdit)then		
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/mouse.png";
			_this.tooltip = "编辑";
			_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnEditItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;		
		end	
		if(treeNode.canEnabled)then
			--_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			--_this.background = "Texture/3DMapSystem/common/radiobutton_sel.png";
			--_this.tooltip = "启用";
			--_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnEnabledItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			--_parent:AddChild(_this);
			local enabled;
			if(treeNode.dataNode)then
				enabled = treeNode.dataNode:GetBool("enabled");
			end
			local checkCtr_name = treeNode:GetNodePath().."checkbox";
			NPL.load("(gl)script/ide/CheckBox.lua");
			local ctl = CommonCtrl.checkbox:new{
				name = checkCtr_name,
				alignment = "_rt",
				left = -left-16,
				top = top,
				width = 16,
				height = 16,
				parent = _parent,
				isChecked = enabled,
				text = "",
				oncheck = string.format("Map3DSystem.Movie.MovieManager.OnEnabledItem(%q, %q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName,checkCtr_name),
			};
			ctl:Show();
			left = left+20;
		end
		if(treeNode.canPreview)then
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/control_play_blue.png";
			_this.tooltip = "预览";
			_this.onclick = string.format(";Map3DSystem.Movie.MovieManager.OnPlayItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;	
		end
	else
		_parent.background = ""		
	end	
end
function MovieManager.OnToggleNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		
		
		-- click the node. 
		CommonCtrl.TreeView.OnClickNode(sCtrlName, nodePath);
		
		if(node.Expanded) then
			node:Collapse();
		else
			node:Expand();
		end
		node:SelectMe(true)
		Map3DSystem.Movie.MovieListPage.SelectedNode = node;
	end
end
function MovieManager.OnDeleteAllItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.movieManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local movie = treeNode.dataNode
	if(movie)then
		local valueNode = movie:GetChild("value"); 
		valueNode:ClearAllChildren();
		self:DataBind(moviescript);
	end
end
function MovieManager.OnNewItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.movieManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local movie = treeNode.dataNode;
	if(movie)then
		local valueNode = movie:GetChild("value"); 
		local clip = moviescript:ConstructNode("pe:movie-clip",true);
		local id = clip:GetNumber("id");
		local clip_item = moviescript:ConstructItemNode("pe:movie-clip",id,"true")
		valueNode:AddChild(clip_item);
		
		
		local node = self:CreateTreeNode(self.rootNode,clip_item)
		self:RefreshViewWnd(node)
		--TODO: open movieclip editor panel
	end
end
function MovieManager.OnDeleteItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.movieManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local dataNode = treeNode.dataNode;
	-- dataNode is  <pe:movie-clip-item assetid="3"  enabled="true" />
	if(dataNode)then
		dataNode:Detach();
		treeNode:Detach();
		self:DataBind(moviescript);
	end
end
function MovieManager.OnEditItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.movieManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local dataNode = treeNode.dataNode;
	-- dataNode is  <pe:movie-clip-item assetid="3"  enabled="true" />
	if(dataNode)then
		local id = dataNode:GetNumber("id");
		local clip_mapping = moviescript.clips_mapping[id];
		if(clip_mapping)then
			--TODO:edit clip
		end
	end
end
function MovieManager.OnPlayItem(sCtrlName, nodePath, type)	

end
function MovieManager.OnEnabledItem(sCtrlName, nodePath, type,checkCtr_name)	
	local enabled = true;
	local ctl = CommonCtrl.GetControl(checkCtr_name);
	if(ctl)then
		enabled = ctl:GetCheck();
	end
	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.movieManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local dataNode = treeNode.dataNode;
	if(dataNode)then
		local s;
		
		if(enabled)then
			s = "true";
		else
			s = "false";
		end
		dataNode:SetAttribute("enabled",s); 
	end
end

