--[[
Title: Edit/view mark dialog box
Author(s): LiXizhi, Leio zhang, refactored by LiXizhi 2008.2.11
Date: 2008/1/22
Note: 
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/DlgMark.lua");
Map3DApp.DlgMark.EditMark(markNode);
-------------------------------------------------------
]]
if(not Map3DApp.DlgMark)then Map3DApp.DlgMark={} end;

local bindingContext;

function Map3DApp.DlgMark.EditMark(markNode)
	bindingContext = commonlib.BindingContext:new();
	bindingContext._markNode = markNode;
	bindingContext:AddBinding(markNode.tag, "markTitle", "DlgEditMark#title", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(markNode.tag, "markDesc", "DlgEditMark#desc", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(markNode.tag, "markStyle", "DlgMark.radioButtonPlayerMark", commonlib.Binding.ControlTypes.IDE_radiobox, "SelectedIndex")
	bindingContext:AddBinding(markNode.tag, "GetIcon", "DlgEditMark#markIcon", commonlib.Binding.ControlTypes.ParaUI_container, "background", commonlib.Binding.DataSourceUpdateMode.ReadOnly)
	bindingContext:AddBinding(Map3DApp.DlgMark.AttWrapper, "markPos", "DlgEditMark#markPos", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(markNode.tag, "textColor", "DlgMark.coloredit", commonlib.Binding.ControlTypes.IDE_coloreditor, "text")
	bindingContext:AddBinding(Map3DApp.DlgMark.AttWrapper, "textScale", "DlgEditMark#panelMarkTextStyle#textBoxFontScale", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(Map3DApp.DlgMark.AttWrapper, "textRot", "DlgEditMark#panelMarkTextStyle#textBoxFontRotation", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	bindingContext:AddBinding(markNode.tag, "bShowText", "DlgEditMark.checkBoxShowText", commonlib.Binding.ControlTypes.IDE_checkbox, "value")
	
	_guihelper.ShowDialogBox("编辑标记", nil, nil, 268, 346, Map3DApp.DlgMark.CreateDlg, Map3DApp.DlgMark.OnDlgResult);
end

-- writing/reading value from/to datasource for each indirect attribute of markNode. 
function Map3DApp.DlgMark.AttWrapper(dataMember, bIsWriting, value)
	local markInfo = bindingContext._markNode.tag;
	if(dataMember == "markPos") then
		if(not bIsWriting) then
			-- reading from data source
			return string.format("%f, %f, %f", markInfo.x, markInfo.y, markInfo.z)
		else
			-- writing to data source
			local _,_, x,y,z = string.find(value, "([%d%.]+)[%D]+([%d%.]+)[%D]+([%d%.]+)");
			if(z and x and y) then
				x = tonumber(x)
				y = tonumber(y)
				z = tonumber(z)
				if(z and x and y and x>=0 and y>=0 and z>=0 and x<=1 and y<=1 and z<=1) then
					markInfo.x = x;
					markInfo.y = y;
					markInfo.z = z;
				end
			end
		end
	elseif(dataMember == "textScale") then
		if(not bIsWriting) then
			-- reading from data source
			return string.format("%.1f", markInfo.textScale)
		else
			local _,_, v = string.find(value, "([%d%.]+)");
			if(v) then
				v = tonumber(v)
				if(v and v>=0.5 and v<=5) then
					markInfo.textScale = v;
				end
			end
		end		
	elseif(dataMember == "textRot") then
		if(not bIsWriting) then
			-- reading from data source
			return string.format("%.2f", markInfo.textRot)
		else
			local _,_, v = string.find(value, "([%d%.%+%-]+)");
			if(v) then
				v = tonumber(v)
				if(v and v>=-3.1416 and v<=3.1416) then
					markInfo.textRot = v;
				end
			end
		end		
	end	
end
		
-- called when dialog returns. 
function Map3DApp.DlgMark.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then
		bindingContext:UpdateControlsToData();
		-- update UI
		bindingContext._markNode.TreeView:Update(nil, bindingContext._markNode);
		-- refresh UI layer
		Map3DApp.MarkUILayer.RemoveMark(bindingContext._markNode)
		Map3DApp.MarkUILayer.OnViewRegionChange();
	end
	return true;
end

-- create the dialog box content
function Map3DApp.DlgMark.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "DlgEditMark", "_fi", 0,0,0,0)
	_this.background = "";
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 9, 10, 35, 12)
	_this.text = "标题:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("imeeditbox", "title", "_mt", 76, 7, 11, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("imeeditbox", "markPos", "_mt", 76, 61, 11, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label3", "_lt", 9, 64, 35, 12)
	_this.text = "位置:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label2", "_lt", 11, 173, 59, 12)
	_this.text = "标题样式:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "lable10", "_lt", 9, 92, 59, 12)
	_this.text = "标记类型:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label5", "_lt", 9, 37, 35, 12)
	_this.text = "描述:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("editbox", "desc", "_mt", 76, 34, 11, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("container", "markIcon", "_lt", 11, 112, 24, 24)
	_this.enabled = false;
	_parent:AddChild(_this);

	-- panelMarkType
	_this = ParaUI.CreateUIObject("container", "panelMarkType", "_mt", 76, 92, 11, 75)
	_parent:AddChild(_this);
	_parent = _this;

	NPL.load("(gl)script/ide/RadioBox.lua");
	local ctl = CommonCtrl.radiobox:new{
		name = "DlgMark.radioButtonPlayerMark",
		alignment = "_lt",
		left = 12,
		top = 6,
		width = 71,
		height = 16,
		parent = _parent,
		isChecked = false,
		text = "玩家标记",
	};
	ctl:Show();

	NPL.load("(gl)script/ide/RadioBox.lua");
	local ctl = CommonCtrl.radiobox:new{
		name = "DlgMark.radioButtonCityMark",
		alignment = "_lt",
		left = 12,
		top = 28,
		width = 71,
		height = 16,
		parent = _parent,
		isChecked = false,
		text = "城市标记",
	};
	ctl:Show();

	NPL.load("(gl)script/ide/RadioBox.lua");
	local ctl = CommonCtrl.radiobox:new{
		name = "DlgMark.radioButtonEventMark",
		alignment = "_lt",
		left = 12,
		top = 50,
		width = 71,
		height = 16,
		parent = _parent,
		isChecked = false,
		text = "事件标记",
	};
	ctl:Show();

	-- panelMarkTextStyle
	_this = ParaUI.CreateUIObject("container", "panelMarkTextStyle", "_mt", 76, 173, 11, 167)
	_parent = ParaUI.GetUIObject("DlgEditMark");
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "label6", "_lt", 10, 61, 59, 12)
	_this.text = "文字方向:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label7", "_lt", 10, 92, 35, 12)
	_this.text = "颜色:";
	_parent:AddChild(_this);

	
	NPL.load("(gl)script/ide/coloreditor_control.lua");
	local ctl = CommonCtrl.CCtrlColorEditor:new({
		name = "DlgMark.coloredit",
		r = 255,
		g = 255,
		b = 255,
		left = 45,
		top = 84,
		width = 133,
		height = 71,
		parent = _parent,
		
	});
	ctl:Show();

	_this = ParaUI.CreateUIObject("editbox", "textBoxFontScale", "_mt", 81, 30, 47, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("editbox", "textBoxFontRotation", "_mt", 81, 57, 47, 21)
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/CheckBox.lua");
	local ctl = CommonCtrl.checkbox:new{
		name = "DlgEditMark.checkBoxShowText",
		alignment = "_lt",
		left = 12,
		top = 8,
		width = 120,
		height = 16,
		parent = _parent,
		isChecked = false,
		text = "在地图上显示标题",
	};
	ctl:Show();

	_this = ParaUI.CreateUIObject("text", "label4", "_lt", 10, 33, 59, 12)
	_this.text = "文字大小:";
	_parent:AddChild(_this);

	bindingContext:UpdateDataToControls();
end
