--[[
Title: Assets Manager
Author(s): Leio Zhang
Date: 2008/10/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/AssetsManager.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieManager.lua");
NPL.load("(gl)script/ide/TreeView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTrackAdapter.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.lua");
-- the mcml page to present the movie manager. 
-- note: this is optional.
local AssetsManager = {
	moviescript = nil, 
	selectedModel = nil,
};
commonlib.setfield("Map3DSystem.Movie.AssetsManager",AssetsManager);
function AssetsManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end

-- @param moviescript: the movie script object (treenode) to bind to. 
function AssetsManager:DataBind(moviescript,selectedModel)
	if(not moviescript or not selectedModel)then return; end
	self.moviescript = moviescript;
	self.selectedModel = selectedModel;	
	self:UpdateTreeView();
end
function AssetsManager:UpdateTreeView()
	if(not self.selectedModel)then return; end
	local rootNode = self.selectedModel["rootNode"];
	self:ResetViewWnd(rootNode);
	local nodes = self.selectedModel["nodes"];
	local node;
	if(nodes)then
		for node in nodes:next() do
				self:CreateTreeNode(rootNode,node)
					
		end	
	end
	self:RefreshViewWnd()
end
function AssetsManager:CreateTreeNode(rootNode,node)
	if(not rootNode or not node)then return; end
	local curMovieManager = Map3DSystem.Movie.MovieListPage.SelectedMovieManager;
	local curMovieScript;
	if(curMovieManager)then
		curMovieScript = curMovieManager.moviescript;
	end
	local moviescript = self.moviescript;
	
	local id = node:GetNumber("id") or node:GetNumber("assetid") or -1;
	local titleNode = node:GetChild("title");
	local title;
	if(titleNode)then
		title = titleNode["TitleValue"]
	end
	local treeNode = CommonCtrl.TreeNode:new({
												Text = title or id,
												canPreview = true,	
												canEnabled = false,
												canEdit = (true == (moviescript == curMovieScript)),
												canDelete = (true == (moviescript == curMovieScript)),
												canImport = (true == (moviescript == curMovieScript)),
												dataNode = node,
												
												UnselectedNodeHeight = 22,
												SelectedNodeHeight = 40,
												Expanded = false,
												
												});
	rootNode:AddChild(treeNode);
	if(node.name == "pe:movie-clip")then
		local nodeValue = node:GetChild("value");
		if(nodeValue)then
			local item;
			for item in nodeValue:next() do
				
				local id = item:GetNumber("assetid") or -1;
				local titleNode;
				local title;
				local __,mapping = self.moviescript:GetAssetNodeFromItemNodeName(item.name)
				local assetNode = mapping[id];
				if(assetNode)then
					titleNode = assetNode:GetChild("title");
				end
				if(titleNode)then
					title = titleNode["TitleValue"]
				end
				local childNode = CommonCtrl.TreeNode:new({
												Text = title or id,
												canPreview = false,	
												canEnabled = false,
												canEdit = false,
												canDelete = (true == (moviescript == curMovieScript)),
												canImport = false,
												dataNode = assetNode,
												itemNode = item,
												UnselectedNodeHeight = 22,
												SelectedNodeHeight = 40,
												Expanded = false,
												
												});
				treeNode:AddChild(childNode);
			end
		end
	end
end
---------------------------------------------------
-- for viewing the asset in asset view
---------------------------------------------------

-- create the treeview control to display all events. 
function AssetsManager:CreateViewWnd(_parent)
	local ctl = CommonCtrl.TreeView:new{
		name = self.name,
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		parent = _parent,
		DefaultNodeHeight = 22,
		ShowIcon = false,
		DrawNodeHandler = AssetsManager.DrawViewNodeHandler,	
	};
	ctl.assetsManager = self;
	ctl:Show();
end
function AssetsManager:ResetViewWnd(rootNode)
	local treeviewName = self.name;
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl and rootNode) then
		rootNode:ClearAllChildren();
		ctl.RootNode:ClearAllChildren();
		ctl.RootNode:AddChild(rootNode);
	end
end
-- refresht he view 
function AssetsManager:RefreshViewWnd(node)
	local treeviewName = self.name;
	local ctl = CommonCtrl.GetControl(treeviewName);
	if(ctl) then
		ctl.assetsManager = self;
		ctl:Update(node);
	end
end

-- event node draw handler
function AssetsManager.DrawViewNodeHandler(_parent,treeNode)
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
		
		local assetsManager = treeNode.TreeView.assetsManager;
		local moviescript = Map3DSystem.Movie.MovieListPage.SelectedMovieManager.moviescript;

		local len = treeNode:GetChildCount();
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		local title = treeNode.Text or "物体";
		_this.text = string.format("%s:共%d个",title,len);
		
		if(assetsManager  and (moviescript == assetsManager.moviescript) )then
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/package_add.png";
			_this.tooltip = "新增";
			_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnNewItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), treeNode.Type);
			_parent:AddChild(_this);
			left = left+20;
			
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/delete.png";
			_this.tooltip = "删除全部";
			_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnDeleteAllItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), treeNode.Type);
			_parent:AddChild(_this);
			left = left+20;
						
		end
	else
		AssetsManager.Child_DrawViewNodeHandler(_parent,treeNode);
	end	
end
function AssetsManager.Child_DrawViewNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local assetsManager = treeNode.TreeView.assetsManager;
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
	if(mcmlName == "pe:movie-clip" )then
		duration = assetsManager.moviescript:GetClipDuration(treeNode.dataNode)
	else
		duration = assetsManager.moviescript:GetAssetNodeDuration(treeNode.dataNode)
	end
	duration = duration or 0;
	duration = CommonCtrl.Animation.Motion.TimeSpan.GetTime(duration)
	_this=ParaUI.CreateUIObject("text","b","_rt", -60, top , 60, height - 1);
	_parent:AddChild(_this);
	_this.text = string.format("%s",duration);
	_guihelper.SetFontColor(_this, "128 128 128")
	
	-- click area to select this node
	_this=ParaUI.CreateUIObject("button","b","_fi", 0,0,0,0);
	_this.background = "";
	_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnToggleNode(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
	_parent:AddChild(_this);
	
	if(treeNode.Selected) then	
		_parent.background = "Texture/alphadot.png"	
		top = top + 16;
		left = 5;
		if(treeNode.canImport)then
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/plugin_add.png";
			_this.tooltip = "导入";
			_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnImportItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;
		end
		if(treeNode.canDelete)then	
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/delete.png";
			_this.tooltip = "删除";
			_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnDeleteItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;
		end
		if(treeNode.canEdit)then		
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/mouse.png";
			_this.tooltip = "编辑";
			_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnEditItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;		
		end	
		if(treeNode.canEnabled)then
			--_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			--_this.background = "Texture/3DMapSystem/common/radiobutton_sel.png";
			--_this.tooltip = "启用";
			--_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnEnabledItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
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
				oncheck = string.format("Map3DSystem.Movie.AssetsManager.OnEnabledItem(%q, %q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName,checkCtr_name),
			};
			ctl:Show();
			left = left+20;
		end
		if(treeNode.canPreview)then
			_this=ParaUI.CreateUIObject("button","b","_rt", -left-16, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/control_play_blue.png";
			_this.tooltip = "预览";
			_this.onclick = string.format(";Map3DSystem.Movie.AssetsManager.OnPlayItem(%q, %q, %q)", treeNode.TreeView.name, treeNode:GetNodePath(), mcmlName);
			_parent:AddChild(_this);
			left = left+20;	
		end
	else
		_parent.background = ""		
	end	
end
function AssetsManager.OnToggleNode(sCtrlName, nodePath)
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
	end
end
function AssetsManager.OnDeleteAllItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.assetsManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local info = moviescript:GetNodeTypeName(type);
	_guihelper.MessageBox(string.format("你确定要全部删除%s?", info or ""), function()
				moviescript:RemoveAllAssetNode(type.."s")	
				self:DataBind(self.moviescript,self.selectedModel)		
				--self:RefreshViewWnd();
				local movieManager = Map3DSystem.Movie.MovieListPage.SelectedMovieManager; 
				if(movieManager)then
					movieManager:DataBind(moviescript);
				end
				end)
end
function AssetsManager.OnNewItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.assetsManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	local node = moviescript:ConstructNode(type,true);

	-- update treeView
	local rootNode = self.selectedModel["rootNode"];
	local treeNode = self:CreateTreeNode(rootNode,node)
	
	local valueNode = node:GetChild("value");
	if(type == "pe:movie-clip")then
		local clip = Map3DSystem.Movie.MovieTrackAdapter.ItemValueNodeToClip(valueNode,moviescript)
		if(clip)then
			Map3DSystem.Movie.MovieClipEditor_Page.Show(clip,moviescript);	
			Map3DSystem.Movie.MovieClipEditor_Page.ShowToolBar(node);	
			Map3DSystem.Movie.MovieEditPage.OnClickClose();		
		end
	else
		local keyFrames = Map3DSystem.Movie.TargetKeyFramesFactory.BuildObject(type,nil,nil)
		if(keyFrames)then
			local __KeyFrames__Node = Map3DSystem.mcml.new(nil, {name = "__KeyFrames__Node"})
			__KeyFrames__Node["KeyFrames"] = keyFrames;
			valueNode:AddChild(__KeyFrames__Node);
			-- like <pe:movie-actor id="121">
			keyFrames["ParentMcmlNode"] = node;
		end
	end
	self:RefreshViewWnd(treeNode)
end
function AssetsManager.OnImportItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.assetsManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local movieManager = Map3DSystem.Movie.MovieListPage.SelectedMovieManager; 
	if(movieManager)then		
			local child = treeNode.dataNode;	
			if(child.name ~="pe:movie-clip")then		
				local selectedNode = Map3DSystem.Movie.MovieListPage.SelectedNode;
				if(selectedNode and selectedNode.dataNode)then				
					local item = selectedNode.dataNode;
					local mcmlName = item.name;
					if(mcmlName == "pe:movie-clip-item")then
						-- item is <pe:movie-clip-item assetid="3"  enabled="true" />
						local id = item:GetNumber("assetid");
						local clip = moviescript.clips_mapping[id];
						if(clip)then
							local result = moviescript:ImportAssetToClip(child,clip)
							if(result)then
								movieManager:DataBind(moviescript);
							end
							return;
						else
							_guihelper.MessageBox("胶片数据错误！");
							return;
						end
					else
						_guihelper.MessageBox("只有胶片有被导入的功能！");
						return;
					end	
				else
					_guihelper.MessageBox("请选择一个胶片！");
					return;
				end
			else
				local movie = movieManager.movie;
				if(movie)then
					moviescript:ImportClipToMovie(child,movie)
					movieManager:DataBind(moviescript);				
					return;
				end
			end
	end
	_guihelper.MessageBox("导入错误！");
end
function AssetsManager.OnDeleteItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.assetsManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local dataNode = treeNode.dataNode;
		local id = dataNode:GetString("id") or dataNode:GetString("assetid")
		local titleNode = dataNode:GetChild("title");
		local title = titleNode["title"];
		_guihelper.MessageBox(string.format("你确定要删除%s?", title or id or ""), function()
					if(treeNode.itemNode)then
						local itemNode = treeNode.itemNode;
						itemNode:Detach();
					else
						moviescript:RemoveAssetNode(dataNode)
					end
					-- update treeView
					treeNode:Detach();
					self:RefreshViewWnd();
					
					local movieManager = Map3DSystem.Movie.MovieListPage.SelectedMovieManager; 
					if(movieManager)then
						movieManager:DataBind(moviescript);
					end
					
					end)
end
function AssetsManager.OnEditItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.assetsManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local dataNode = treeNode.dataNode;
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTrackAdapter.lua");
	if(dataNode)then
		local valueNode;
		local isMovieClip = false;
		valueNode = dataNode:GetChild("value"); 
		local clip;
		if(type == "pe:movie-clip")then	
			clip = Map3DSystem.Movie.MovieTrackAdapter.ItemValueNodeToClip(valueNode,moviescript)	
			isMovieClip = true;	
		else
			clip = Map3DSystem.Movie.MovieTrackAdapter.ValueNodeToClip(valueNode,dataNode)	
		end
		if(clip)then
			Map3DSystem.Movie.MovieClipEditor_Page.Show(clip,moviescript);	
			if(isMovieClip)then
				Map3DSystem.Movie.MovieClipEditor_Page.ShowToolBar(dataNode);
			end
			Map3DSystem.Movie.MovieEditPage.OnClickClose();		
		end
	end
end
function AssetsManager.OnPlayItem(sCtrlName, nodePath, type)	
	if(not sCtrlName or not nodePath or not type)then return; end
	local treeView, treeNode = CommonCtrl.TreeView.GetCtl(sCtrlName,nodePath)
	local self = treeView.assetsManager;
	if(not self)then return; end
	local moviescript = self.moviescript;
	
	local dataNode = treeNode.dataNode;
	if(dataNode)then
		local valueNode;
		valueNode = dataNode:GetChild("value"); 
		local clip;
		if(type == "pe:movie-clip")then	
			clip = Map3DSystem.Movie.MovieTrackAdapter.ItemValueNodeToClip(valueNode,moviescript)	
		else
			clip = Map3DSystem.Movie.MovieTrackAdapter.ValueNodeToClip(valueNode,dataNode)	
		end
		if(clip)then
			Map3DSystem.Movie.MoviePlayerPage.DoOpenWindow()
			Map3DSystem.Movie.MoviePlayerPage.DataBind(clip)
			Map3DSystem.Movie.MovieEditPage.OnClickClose();		
		end
	end
end
function AssetsManager.OnEnabledItem(sCtrlName, nodePath, type)	

end
function AssetsManager:NewKeyFrames()
--local valueNode = camera:GetChild("value");
						--local params = {ID = 1,EyePos="255,255,255"};
						--local keyFrames = Map3DSystem.Movie.TargetKeyFramesFactory.BuildCamera(params)
						--local keyFrames_mcmlNode = keyFrames:ReverseToMcmlNode();
						--if(valueNode and keyFrames_mcmlNode)then
							--valueNode:AddChild(keyFrames_mcmlNode);
						--end
end
function AssetsManager:OnEditKeyFrames()
--local track = moviescript.cameraTracks_mapping[id];
				--if(track)then
					--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTrackAdapter.lua");
					--local clip,bindingContext = Map3DSystem.Movie.MovieTrackAdapter.TrackMcmlNodeToClip(track)
					--if(clip and bindingContext)then
						--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.lua");
						--clip.bindingContext = bindingContext;
						--Map3DSystem.Movie.MovieClipEditor_Page.Show(clip);					
					--end
				--end
end