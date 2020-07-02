--[[
Title: map browser side bar search tab page
Author(s): Sun Lingfeng
Date: 2008/4/22
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBarSearchWnd.lua");
self.searchPage = Map3DApp.SideBarSearchWnd:new{
	name = "control name",
	parent = self.parent,
};
------------------------------------------------------]]

NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapDataDefine.lua");

SideBarSearchWnd = {
	name = "sbSearchWnd",
	
	--private data
	parent = nil,
	isVisible = false,
	listeners = {},
	first = true;
}
Map3DApp.SideBarSearchWnd = SideBarSearchWnd;

function SideBarSearchWnd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	CommonCtrl.AddControl(o.name,o);
	return o;
end

function SideBarSearchWnd:Show(bShow)
	if(bShow == nil)then
		self.isVisible = not self.isVisible;
	else
		self.isVisible = bShow;
	end
	
	local ignoreChildCtr = false;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.visible = self.isVisible;
	else
		if(self.isVisible)then
			self:CreateUI();
		else
			ignoreChildCtr = true;
		end
	end
	
	if(not ignoreChildCtr)then
		if(self.inputEdit)then
			self.inputEdit:Show(self.isVisible);
		end
		
		if(self.searchResult)then
			self.searchResult:Show(self.isVisible);
		end
	end
end

function SideBarSearchWnd:SetParentWnd(parent)
	self.parent = parent;
	if(self.searchResult)then
		self.searchResult.parent = parent;
	end
end

function SideBarSearchWnd:SetCommendWorld(markInfos)
	if(self.searchResult == nil)then
		return;
	end
	
	local node = self.searchResult.RootNode:GetChildByName("ads");
	if(node)then
		node:ClearAllChildren();
		for __,item in pairs(markInfos) do
			node:AddChild(CommonCtrl.TreeNode:new({Text= item:GetTitle(),tag = item,Name = "ad",Type = 3,Icon = "Texture/3DMapSystem/common/Flag_green.png"}));
		end
	end

	self.searchResult:Update();
end

function SideBarSearchWnd:SetSearchResult(results)
	if(self.searchResult == nil)then
		return;
	end
	
	local node = self.searchResult.RootNode:GetChildByName("results");
	if(node)then
		node:ClearAllChildren();
		for __,item in pairs(results) do
			node:AddChild(CommonCtrl.TreeNode:new({Text= item:GetTitle(),tag = item,Name = "result",Type = 4,Icon = "Texture/3DMapSystem/common/Flag_red.png"}));
		end
	end
	self.searchResult:Update();
end

function SideBarSearchWnd:AddListener(name,listener)
	self.listeners[name] = listener;
end

function SideBarSearchWnd:RemoveListener(name)
	if(self.listeners[name])then
		self.listeners[name] = nil;
	end
end

function SendMessage(msg,data)
	for __,callback in pairs(self.listeners) do
		callback(self.name,msg,data);
	end
end

--==============private=====================
function SideBarSearchWnd:Init()
	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	self.inputEdit = CommonCtrl.dropdownlistbox:new{
		name = self.name.."input",
		alignment = "_mt",
		left = 3,
		top = 4,
		width = 50,
		height = 20,
		dropdownheight = 106,
		text = "",
		items = {"教程", "帮助", "买地", "交友", "网游", "商务", "ParaEngine", "儿童", "动漫", },
	};
	
	NPL.load("(gl)script/ide/TreeView.lua");
	self.searchResult = CommonCtrl.TreeView:new{
		name = self.name.."searchResult",
		alignment = "_fi",
		left = 2,
		top = 27,
		width = 2,
		height = 2,
		parent = self.parent,
		DefaultIconSize = 18,
		DefaultIndentation = 15,
		DefaultNodeHeight = 25,
		DrawNodeHandler = Map3DApp.SideBarSearchWnd.DrawWorldNode,
	};
	local node = self.searchResult.RootNode;
	node:AddChild(CommonCtrl.TreeNode:new({Text = "推荐世界", Name = "ads", Type = 1,}));
	node:AddChild(CommonCtrl.TreeNode:new({Text = "搜索结果", Name = "results",Type = 2,pagecount = 1,curPage = 1}));
end

function SideBarSearchWnd:CreateUI()
	local _this = ParaUI.CreateUIObject("container", self.name, "_fi", 2, 25, 2, 2);
	_this.onsize = string.format(";Map3DApp.SideBarSearchWnd.OnResize(%q)",self.name);
	_this.background = "";
	if(self.parent)then
		self.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	
	if(self.inputEdit)then
		self.inputEdit.parent = _this;
	end
	
	if(self.searchResult)then
		self.searchResult.parent = _this;
	end
	
	local _parent = _this;
	_this = ParaUI.CreateUIObject("button", self.name.."searchBtn", "_rt", -44, 4, 41, 20);
	_this.text = "搜索";
	_parent:AddChild(_this);
end

--TODO:implement this function
function SideBarSearchWnd.OnResize()
end

function SideBarSearchWnd.DrawWorldNode(_parent, node)
	if(_parent == nil or node == nil) then
		return
	end
	
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = node:GetHeight();
	local nodeWidth = node.TreeView.ClientWidth;
	local left = left + node.TreeView.DefaultIndentation*(node.Level-1) + 4;
	
	if(node.TreeView.ShowIcon) then
		local IconSize = node.TreeView.DefaultIconSize;
		if(node.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","searchResult","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = node.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			left = left + IconSize+3;
		end	
	end
	
	--advertisements node
	if(node.Type == 1)then
		CommonCtrl.TreeView.RenderCategoryNode(_parent,node, left, top, width, height)
	
	--advertisement node
	elseif(node.Type == 3)then
		_this = ParaUI.CreateUIObject("button", "searchResult", "_mt", left+5, 3, 2, 22)
		_this.text = node.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		--_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", node.TreeView.name, node:GetNodePath());
		_parent:AddChild(_this);
	
	--search results
	elseif(node.Type == 2)then
		_this = ParaUI.CreateUIObject("text", "searchResult", "_lt", left, 6, 70, 12)
		_this.text = "搜索结果:";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button1", "_lt", left + 70, 0, 24, 24)
		_this.background = "Texture/3DMapSystem/EBook/left_arrow.png";
		--_this.text = "<";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "searchResult", "_lt", left + 145, 0, 24, 24)
		--_this.text = ">";
		_this.background = "Texture/3DMapSystem/EBook/right_arrow.png";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "searchResult", "_lt", left + 94, 6, 50, 12)
		_this.text = string.format("%d/%d", node.curPage, node.pagecount);
		_guihelper.SetUIFontFormat(_this, 37);-- make text centered and single lined. 
		_parent:AddChild(_this);
	
	--search result	
	elseif(node.Type == 4)then
		_this = ParaUI.CreateUIObject("button", "searchResult", "_mt", left+5, 3, 2, 22)
		_this.text = node.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", node.TreeView.name, node:GetNodePath());
		_parent:AddChild(_this);
	end
end

--============mock data source for testing================
--delete these function
function Map3DApp.SideBarSearchWnd.GetCommendWorld()
	local results = {};
	results[1] = Map3DApp.Mark3DInfo:new{
		id = 0,
		markTitle = "Art Corner",
	};
	results[2] = Map3DApp.Mark3DInfo:new{
		id = 1,
		markTitle = "Movie Club",
	};
	results[3] = Map3DApp.Mark3DInfo:new{
		id = 2,
		markTitle = "Book Shop",
	};
	return results;
end

function Map3DApp.SideBarSearchWnd.GetSearchResult()
	local results = {};
	results[1] = Map3DApp.Mark3DInfo:new{
		id = 3,
		markTitle = "Violin Concert",
	};
	results[2] = Map3DApp.Mark3DInfo:new{
		id = 4,
		markTitle = "Rock n' Roll show",
	};
	results[3] = Map3DApp.Mark3DInfo:new{
		id = 5,
		markTitle = "Puzzle Game World",
	};
	return results;
end



