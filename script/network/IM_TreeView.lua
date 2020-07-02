--[[
Title: TreeView owner draw functions for instance messaging
Author(s): LiXizhi
Date: 2007/9/24
------------------------------------------------------------
NPL.load("(gl)script/network/IM_TreeView.lua");
IM_TreeView.DrawContactNodeHandler
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/event_mapping.lua");
NPL.load("(gl)script/network/IM_ChatWnd.lua");

if(not IM_TreeView) then IM_TreeView={}; end

-- TreeView owner draw handler
function IM_TreeView.DrawContactNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1); -- indentation of this node. 
	local top = 2;
	local width;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	-- Test code: just for testing. remove this line
	--_parent.background = "Texture/whitedot.png"; _guihelper.SetUIColor(_parent, "0 0 100 60");
	
	if(treeNode.type == "group") then
		-- render contact group TreeNode: a check box and a text button. click either to toggle the node.
		width = 20 -- check box width
		if(treeNode:GetChildCount() > 0) then
			-- group with children
			-- checkbox
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/unradiobox.png";
			else
				_this.background = "Texture/radiobox.png";
			end
			
			-- text button
			_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
			_parent:AddChild(_this);
			_this.font = "System;12;norm";
			_this.background = "";
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			
			-- set text
			_this.text = treeNode.Text;
		else
			-- no users in this group	
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			_parent:AddChild(_this);
			left = left + width + 2;
			
			if(treeNode.Expanded) then
				_this.background = "Texture/unradiobox.png";
			else
				_this.background = "Texture/radiobox.png";
			end
			
			_this=ParaUI.CreateUIObject("text","b","_lt", left, 0, nodeWidth - left-1, height);
			_parent:AddChild(_this);
			_this.font = "System;12;norm";
			_this:GetFont("text").format=36; -- single line and vertical align
			
			-- set text
			_this.text = (treeNode.Text or "").." (空)";
		end
	elseif(treeNode.type == "user") then
		-- render user TreeNode: user status icon(according to presence, click to open dialog) + text button(NickName+Message) + tooltip (full information). 
		width = 24; -- status icon width
		-- status icon
		_this=ParaUI.CreateUIObject("button","b","_lt", left, 0, width , width );
		local _status = _this;
		_parent:AddChild(_this);
		if(treeNode.Tag.presenceType == -1) then
			-- available status
			if(not treeNode.Tag.presenceShow or treeNode.Tag.presenceShow == "") then
				-- online
				_guihelper.SetVistaStyleButton(_this, "Texture/face/19.png", "Texture/uncheckbox.png");
			elseif(treeNode.Tag.presenceShow == "away") then
				-- away
				_guihelper.SetVistaStyleButton(_this, "Texture/face/18.png", "Texture/uncheckbox.png");
			elseif(treeNode.Tag.presenceShow == "xa") then
				-- xa
				_guihelper.SetVistaStyleButton(_this, "Texture/face/17.png", "Texture/uncheckbox.png");
			elseif(treeNode.Tag.presenceShow == "dnd") then
				-- dnd
				_guihelper.SetVistaStyleButton(_this, "Texture/face/19.png", "Texture/uncheckbox.png");
			elseif(treeNode.Tag.presenceShow == "chat") then
				-- chat
				_guihelper.SetVistaStyleButton(_this, "Texture/face/smile.png", "Texture/uncheckbox.png");
			end	
		else
			-- it is offline or some other unavailable status.
			_guihelper.SetVistaStyleButton(_this, "Texture/face/22.png", "Texture/uncheckbox.png");
		end
		_this.onclick = string.format(";IM_Main.ShowUserOnMap(%q)", treeNode.Name);
		left = left + width;
		
		-- text button	
		_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
		_parent:AddChild(_this);
		_this.font = "System;12;norm";
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q,%q)", treeNode.TreeView.name, treeNode:GetNodePath());
		
		-- set text: NickName -- presenece status text
		local displaytext;
		if(not treeNode.Tag.NickName or treeNode.Tag.NickName=="") then
			displaytext = treeNode.Text or treeNode.Name;
		else
			displaytext = treeNode.Tag.NickName;
		end
		
		if(treeNode.Tag.presenceStatus~=nil and treeNode.Tag.presenceStatus~="") then
			displaytext = displaytext.."-- "..treeNode.Tag.presenceStatus;
		else
			-- TODO: we should store <userJID, status> records in a local table and check if there is an entry in the local database. 
			-- this is because presence is only sent when user is online. for offline users status, we load from local database table.
		end
		_this.text = displaytext;
		
		-- set tooltips: text + (TextStatus) \n<JID>\nSome help text
		local tooltips = displaytext;
		if(treeNode.Tag.presenceType ~= -1) then
			-- TODO: some other status text
			tooltips = tooltips.."(离线)";
		end	
		tooltips = tooltips.."\n<"..treeNode.Name..">".."\n";
		tooltips = tooltips .."左键点击查看地图位置";
		_status.tooltip = tooltips;
	end
end