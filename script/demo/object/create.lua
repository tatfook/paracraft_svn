--[[ 
Title: object creation UI 
Author(s): LiXizhi
Date: 2005/12
Desc: 
]]

NPL.load("(gl)script/demo/object/manage.lua");
NPL.load("(gl)script/ide/object_editor.lua");

if(not DemoObjEditorUI) then DemoObjEditorUI={}; end

--[[ when the user selected a directory object ]]
function DemoObjEditorUI.OnItemSelect()
	-- TODO activate script
	local tmp = ParaUI.GetUIObject("_devObjSubCategory");
	if(tmp:IsValid() == true) then 
		ObjEditor.AutoCreateObject("unnamed", ObjEditor.CurrentDir..tmp.text);
	end
end

function DemoObjEditorUI.OnItemClick(node, nodepathString)
	if(nodepathString~=nil) then
		--_guihelper.MessageBox(tostring(nodepathString).."\n")
		ObjEditor.AutoCreateObject("unnamed", ObjEditor.CurrentDir..nodepathString);
	end	
end

function DemoObjEditorUI.OnOpenDir(nIndex)
	local obj = ObjEditor.assets[nIndex];
	ObjEditor.CurrentAssetIndex = nIndex;
	ObjEditor.CurrentDir = obj.rootpath;
	
	local sFilePattern;
	if(obj.name == "其它" or obj.name == "地形" or obj.name == "脚本" or obj.name == "灯光") then
		sFilePattern = {"*.lua", "*.raw"};
	else
		-- NOTE by Andy: support LOD
		sFilePattern = {"*.x", "*.xml"};
	end
	
	--[[ old code in 2006.3
	local _this, _parent;
	-- use directory file listing
	ParaUI.Destroy("_devObjSubCategory");
	_this=ParaUI.CreateUIObject("listbox","_devObjSubCategory", "_lt",10,120,270,230);
	_parent=ParaUI.GetUIObject("obj_creation_win");_parent:AddChild(_this);
	_this.scrollable=true;
	_this.background="Texture/dxutcontrols.dds;13 124 228 141";
	_this.itemheight=15;
	_this.wordbreak=false;
	-- _this.onselect="";
	_this.ondoubleclick=";DemoObjEditorUI.OnItemSelect();";
	_this.font="System;11;norm";
	_this.scrollbarwidth=20;
	
	CommonCtrl.InitFileDialog(obj.rootpath, sFilePattern, 4, 1000, _this);
	]]
	NPL.load("(gl)script/ide/FileDialog.lua");

	local ctl = CommonCtrl.GetControl("DemoObjEditorUIFileTreeView");
	if(ctl==nil)then
		ctl = CommonCtrl.FileTreeView:new{
			name = "DemoObjEditorUIFileTreeView",
			alignment = "_lt",
			left=10, top=120,
			width = 270,
			height = 230,
			parent = ParaUI.GetUIObject("obj_creation_win"),
			container_bg ="",
			-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
			DrawNodeHandler = nil,
			sInitDir = obj.rootpath,
			sFilePattern = sFilePattern,
			nMaxFileLevels = 10,
			nMaxNumFiles = 5000,
			onclick = DemoObjEditorUI.OnItemClick,
		};
	else
		ctl.sInitDir = obj.rootpath;
		ctl.sFilePattern = sFilePattern;
		ctl:SetModified(true);
	end	
	ctl:Refresh();
	ctl.RootNode:CollapseAll();
	ctl.RootNode:Expand(); -- only show first level
	ctl:Show(true);
end

local function activate()
	_guihelper.CheckRadioButtons( _demo_obj_pages, "obj_create", "255 0 0");
		
	local _this,_parent,__font,__texture;
	
	_this = ParaUI.GetUIObject("obj_change_con");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	_this = ParaUI.GetUIObject("obj_manage_con");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	
	_this = ParaUI.GetUIObject("obj_creation_win");
	
	if(_this:IsValid() == true) then
		_this.visible=true;
	else
		_this=ParaUI.CreateUIObject("container","obj_creation_win", "_lt",30,60,299,390);
		_parent=ParaUI.GetUIObject("obj_main");_parent:AddChild(_this);
		_this.scrollable=false;
		_this.background="Texture/item.png;";
		_this.candrag=false;
		texture=_this:GetTexture("background");
		texture.transparency=0;--[0-255]

		_this=ParaUI.CreateUIObject("container","conCategory", "_lt",10,20,270,100);
		_parent=ParaUI.GetUIObject("obj_creation_win");_parent:AddChild(_this);
		_this.scrollable=false;
		_this.background="Texture/player/outputbox.png;";
		_this.candrag=false;
		texture=_this:GetTexture("background");
		texture.transparency=100;--[0-255]
		
		local nIndex, listObj;
		local nRow, nCol = 0,0;
		if(ObjEditor.assets == nil) then
			ObjEditor.LoadAsset_demo();
		end
		_parent=ParaUI.GetUIObject("conCategory");
		nIndex=nil;
		for nIndex, listObj in ipairs(ObjEditor.assets) do
			_this=ParaUI.CreateUIObject("button","b1", "_lt",62*nCol,24*nRow,60,24);
			_parent:AddChild(_this);
			_this.text=tostring(listObj.name);
			_this.background="Texture/b_up.png;";
			_this.font="System;15;bold";
			_this.onclick=";DemoObjEditorUI.OnOpenDir("..nIndex..");";
			
			if(nCol>=3) then
				nCol = 0;
				nRow=nRow+1;
			else
				nCol = nCol+1;
			end
		end
				
		_this=ParaUI.CreateUIObject("button","static", "_lt",20,350,80,30);
		_parent=ParaUI.GetUIObject("obj_creation_win");_parent:AddChild(_this);
		_this.text="添加";
		_this.background="Texture/b_up.png;";
		_this.onclick=";ObjEditor.CreateLastObject();";
		
		_this=ParaUI.CreateUIObject("button","static", "_lt",100,350,80,30);
		_parent=ParaUI.GetUIObject("obj_creation_win");_parent:AddChild(_this);
		_this.text="撤销";
		_this.background="Texture/b_up.png;";
		_this.onclick=";ObjManageUI.DelObject();";
		
		_this=ParaUI.CreateUIObject("button","static", "_lt",180,350,100,30);
		_parent=ParaUI.GetUIObject("obj_creation_win");_parent:AddChild(_this);
		_this.text="添加并修改";
		_this.background="Texture/b_up.png;";
		_this.onclick="(gl)script/demo/object/change.lua;ObjEditor.CreateLastObject();";
		
	end
end
NPL.this(activate);
