--[[
Title: history window
Author(s): WangTian
Date: 2007/10/14
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/HistoryWnd.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

-- @param bShow: show or hide the panel
-- @param parentUI: parent container inside which the content is displayed. it can be nil.
-- @param parentWindow: parent window for sending messages
function Map3DSystem.UI.Chat.HistoryWnd.ShowUI(bShow, parentUI, parentWindow)

	local _this, _parent;
	
	-- NOTE: parentWindow should ONLY used on initialize, 
	--		further change parentwindow will cause unreferenced window frame object
	if(parentWindow) then
		Map3DSystem.UI.Chat.parentWindow = parentWindow;
	end
	
	_this = ParaUI.GetUIObject("Map3DSystem_Chat_History_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		-- Map3DSystem_Chat_History_cont
		local width, height = 284, 452;
		
		if(parentUI == nil) then
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_Chat_History_cont", "_lt", 0, 0, width, height);
			_this.candrag = true;
			_this:SetNineElementBG("Texture/uncheckbox.png", 10,10,10,10);
			_this:AttachToRoot();
			
			_parent = _this;
			
			_this = ParaUI.CreateUIObject("button", "buttonClose", "_rt", -27, 3, 24, 24)
			_this.text = "X";
			_this.onclick = ";Map3DSystem.UI.Chat.Show();" -- TODO: close button
			_parent:AddChild(_this);
			
		else
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_Chat_History_cont", "_fi", 0, 0, 0, 0);
			_this:SetNineElementBG("Texture/uncheckbox.png", 10, 10, 10, 10);
			parentUI:AddChild(_this);
			
			-- NOTE: there is no close button is window object specified
		end
		
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "btnRefresh", "_lt", 10, 10, 40, 40);
		_this.text = "Refresh";
		--_this.onclick = ";;";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnSearch", "_lt", 60, 10, 40, 40);
		_this.text = "Search";
		--_this.onclick = ";;";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnDelete", "_lt", 110, 10, 40, 40);
		_this.text = "Delete";
		--_this.onclick = ";;";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
				name = "treeViewHistory",
				alignment = "_fi",
				left = 10,
				top = 60,
				width = 10,
				height = 10,
				container_bg = "Texture/tooltip_text.PNG",
				parent = _parent,
				DefaultIndentation = 10,
				DefaultNodeHeight = 26,
				--DrawNodeHandler = Map3DSystem.UI.Chat.DrawContactNodeHandler,
				--onclick = Map3DSystem.UI.Chat.OnClickUser;
			};
		local node = ctl.RootNode;
		ctl:Show();
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end