--[[
Title: Edit/view folder dialog box
Author(s): LiXizhi, Leio zhang, refactored by LiXizhi 2008.2.11
Date: 2008/1/22
Note: 
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgFolder.lua");
Map3DApp.DlgFolder.EditFolder(folderNode)
-------------------------------------------------------
]]
if(not Map3DApp.DlgFolder)then Map3DApp.DlgFolder={} end;

local bindingContext;
 
function Map3DApp.DlgFolder.EditFolder(folderNode)
	bindingContext = commonlib.BindingContext:new();
	bindingContext._folderNode = folderNode;
	bindingContext:AddBinding(folderNode.tag, "title", "DlgEditFolder#title", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(folderNode.tag, "desc", "DlgEditFolder#desc", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	
	_guihelper.ShowDialogBox("编辑分类", nil, nil, 211, 105, 
		Map3DApp.DlgFolder.CreateDlg, Map3DApp.DlgFolder.OnDlgResult);
end

-- called when dialog returns. 
function Map3DApp.DlgFolder.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then
		bindingContext:UpdateControlsToData();
		-- update UI
		bindingContext._folderNode.TreeView:Update(nil, bindingContext._folderNode);
	end
	return true;
end

-- create the dialog box content
function Map3DApp.DlgFolder.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "DlgEditFolder", "_fi", 0,0,0,0)
	_this.background = "";
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("imeeditbox", "title", "_mt", 5, 25, 3, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("imeeditbox", "desc", "_mt", 5, 71, 3, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 3, 10, 35, 12)
	_this.text = "标题:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label2", "_lt", 3, 56, 35, 12)
	_this.text = "描述:";
	_parent:AddChild(_this);

	bindingContext:UpdateDataToControls();
end

