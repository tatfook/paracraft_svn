--[[
Title: GlobalInventor
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
Map3DSystem.App.Inventor.Gears.ToolBar.Show();
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
Map3DSystem.App.Commands.Call("Profile.Inventor.Start");
--Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");

local lite3DCanvas = Map3DSystem.App.Creator.PortalSystemPage.Portal3DCanvas;
Map3DSystem.App.Inventor.GlobalInventor.Start(lite3DCanvas)

-- test
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
Map3DSystem.App.Inventor.Gears.ToolBar.Show();
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");
local lite3DCanvas =  Map3DSystem.App.Inventor.LiteCanvas:new{
	sceneType = "MiniScene", -- "MiniScene" or "Scene"
	autoPick = false, -- this value can set true only if sceneType is Scene
}
local config = {
	lite3DCanvas = lite3DCanvas,
	canHistory = true,
	canKeyControl = true,
	canContexMenu = true,
	selectorTool = "SelectorTool", -- "EasySelectTool" or "SelectorTool",default is "EasySelectTool"
}
Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Document/LocalSingleDocumentFrame.lua");
NPL.load("(gl)script/ide/Document/LocalSingleDocument.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/BaseObject.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAdd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAddMulti.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandCut.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandCopy.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandPaste.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandDelete.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandDeleteAll.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandGroup.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandUnGroup.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/EasySelectTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/SelectTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/PointerTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/SelectorTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/EntityTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/RotationTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/ScaleTool.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvasView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
local GlobalInventor ={
	name = "GlobalInventor_instance",
	Lite3DCanvas = nil,
	commandManager = nil,
	Tool = nil,
	virtual_key = {},
	minDistance = 0.01,
	
	canHistory = true,
	canKeyControl = true,
	canContexMenu = true,
	canGroup = true,
	commandCallBack = nil,
}  
commonlib.setfield("Map3DSystem.App.Inventor.GlobalInventor",GlobalInventor);
function GlobalInventor.commandCallBack()

end
function GlobalInventor.DrawArea(startPoint,lastPoint)
	if(not startPoint or not lastPoint)then return end
	local left = startPoint.x;
	local top = startPoint.y;
	local width = lastPoint.x - left;
	local height = lastPoint.y - top;
	GlobalInventor.ClearArea();
	local _this = ParaUI.CreateUIObject("container","GlobalInventor_container","_lt",left,top,width,height);	
	--_this.background="Texture/whitedot.png;";
	_this:AttachToRoot();
end
function GlobalInventor.ClearArea()
	local _this = ParaUI.GetUIObject("GlobalInventor_container");
	if(_this:IsValid())then
		ParaUI.Destroy("GlobalInventor_container");
	end
end
function GlobalInventor.RegHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "GlobalInventor_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = GlobalInventor.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "GlobalInventor_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = GlobalInventor.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "GlobalInventor_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = GlobalInventor.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "GlobalInventor_key_down_hook", appName = "input", wndName = "key_down"}
			o.callback = GlobalInventor.OnKeyDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
end
function GlobalInventor.UnHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "GlobalInventor_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "GlobalInventor_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "GlobalInventor_mouse_up_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "GlobalInventor_key_down_hook", hookType = hookType});
end

function GlobalInventor.Clear()
	GlobalInventor.Lite3DCanvas = nil;
	GlobalInventor.commandManager = nil;
	GlobalInventor.Tool = nil;
end
function GlobalInventor.DefaultConfig()
	GlobalInventor.canHistory = true;
	GlobalInventor.canContexMenu = true;
	GlobalInventor.canKeyControl = true;
end

function GlobalInventor.Start(config)
	local lite3DCanvas;
	
	GlobalInventor.selectorTool = "EasySelectTool";
	if(config)then
		lite3DCanvas = config.lite3DCanvas;
		GlobalInventor.canHistory = config.canHistory;
		GlobalInventor.canKeyControl = config.canKeyControl;
		GlobalInventor.canContexMenu = config.canContexMenu;
		GlobalInventor.canGroup = config.canGroup;
		
		if(config.selectorTool)then
			GlobalInventor.selectorTool = config.selectorTool;
		end
	end
	GlobalInventor.RegHook();
	-- create a lite3DCanvas
	if(not lite3DCanvas)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");
		lite3DCanvas =  Map3DSystem.App.Inventor.LiteCanvas:new{
			type = "MiniScene", -- "MiniScene" or "Scene"
			autoPick = false,
		}
	end
	if(GlobalInventor.canHistory)then
		-- create a command manager
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/UndoManager.lua");
		local commandManager = Map3DSystem.App.Inventor.UndoManager:new();
		commandManager:Initialization(lite3DCanvas);
		GlobalInventor.commandManager = commandManager;
	end
	
	GlobalInventor.Lite3DCanvas = lite3DCanvas;
	
	ParaCamera.GetAttributeObject():SetField("EnableMouseLeftButton", false)
	
	Map3DSystem.App.Commands.Call("Profile.Inventor.PointerTool");
	return lite3DCanvas,commandManager;
	
end
function GlobalInventor.Stop()
	GlobalInventor.Clear();
	GlobalInventor.UnHook();
	GlobalInventor.UnhookCreateEntity()
	GlobalInventor.MainFrame = nil;
end
--IsMouseDown=true,
  --MouseDragDist={ x=0, y=0 },
  --dragDist=0,
  --lastMouseDown={ x=93, y=421 },
  --lastMouseUpTime=0,
  --lastMouseUp_x=0,
  --lastMouseUp_y=0,
  --mouse_button="left",
  --mouse_x=93,
  --mouse_y=421,
  --virtual_key=142,
  --wndName="mouse_down" 
--ParaCamera.GetAttributeObject():SetField("EnableKeyboard", false)
--ParaCamera.GetAttributeObject():SetField("EnableMouseLeftButton", false)
--ParaCamera.GetAttributeObject():SetField("EnableMouseRightButton", false)
--ParaCamera.GetAttributeObject():SetField("EnableMouseWheel", false)
--
function GlobalInventor.OnMouseDown(nCode, appName, msg)
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local tool = Map3DSystem.App.Inventor.GlobalInventor.Tool;
	if(not lite3DCanvas or not tool)then return nCode; end
	if(msg.mouse_button == "right")then
		tool:OnRightMouseDown(lite3DCanvas,msg);
	else
		tool:OnLeftMouseDown(lite3DCanvas,msg);
	end
	return nil;
end
function GlobalInventor.OnMouseMove(nCode, appName, msg)
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local tool = Map3DSystem.App.Inventor.GlobalInventor.Tool;
	if(not lite3DCanvas or not tool)then return nCode; end
	tool:OnMouseMove(lite3DCanvas,msg);
	return nil;
end
function GlobalInventor.OnMouseUp(nCode, appName, msg)
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local tool = Map3DSystem.App.Inventor.GlobalInventor.Tool;
	if(msg.mouse_button == "right")then
		GlobalInventor.OnRightMouseUp(nCode, appName, msg)
		if(not lite3DCanvas or not tool)then return nCode; end
		tool:OnRightMouseUp(lite3DCanvas,msg);
	else	
		if(not lite3DCanvas or not tool)then return nCode; end
		tool:OnLeftMouseUp(lite3DCanvas,msg);
	end
	return nil;
end
function GlobalInventor.GetCanContexMenu()
	local self = GlobalInventor;
	if(self.canContexMenu)then
		local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
		local arr =  lite3DCanvas:GetSelection();
		local len = #arr;
		if(len < 1)then
			return false;
		end
		return true;
	else
		return false;
	end
end
function GlobalInventor.OnRightMouseUp(nCode, appName, msg)
	if(msg.mouse_button ~= "right")then return; end
	local self = GlobalInventor;
	local lite3DCanvas = self.Lite3DCanvas;
	if(self.GetCanContexMenu() and lite3DCanvas)then

			local ctl = CommonCtrl.ContextMenu:new{
				name = self.name.."ContextMenu",
				width = 130,
				height = 150,
				container_bg = "Texture/3DMapSystem/ContextMenu/BG3.png:8 8 8 8",
			};

			local root_node = ctl.RootNode;

			root_node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Inv", Name = "Inv", Type = "Group", NodeHeight = 0 , Invisible = false,});
			--root_node:AddChild(CommonCtrl.TreeNode:new{Text = "移动", Name = "移动 Ctrl+T", Type = "Menuitem", NodeHeight = 26,onclick=function()
				--Map3DSystem.App.Commands.Call("Profile.Inventor.PointerTool")
			--end});
			--root_node:AddChild(CommonCtrl.TreeNode:new{Text = "缩放", Name = "缩放  Ctrl+E", Type = "Menuitem", NodeHeight = 26,onclick=function()
				--Map3DSystem.App.Commands.Call("Profile.Inventor.ScaleTool")
			--end});
			--root_node:AddChild(CommonCtrl.TreeNode:new{Text = "旋转", Name = "旋转  Ctrl+R", Type = "Menuitem", NodeHeight = 26,onclick=function()
				--Map3DSystem.App.Commands.Call("Profile.Inventor.RotationTool")
			--end});
			
			root_node:AddChild(CommonCtrl.TreeNode:new{Text = "属性", Name = "旋转 ", Type = "Menuitem", NodeHeight = 26,onclick=function()
				Map3DSystem.App.Commands.Call("Profile.Inventor.BindPropertyPanel")
			end});
			root_node:AddChild(CommonCtrl.TreeNode:new{Text = "全选 Ctrl+A", Name = "全选", Type = "Menuitem", NodeHeight = 26,onclick=function()
				Map3DSystem.App.Commands.Call("Profile.Inventor.SelectAll")
			end});
			root_node:AddChild(CommonCtrl.TreeNode:new{Text = "剪切 Ctrl+X", Name = "剪切", Type = "Menuitem", NodeHeight = 26,onclick=function()
				Map3DSystem.App.Commands.Call("Profile.Inventor.Cut")
			end});
			root_node:AddChild(CommonCtrl.TreeNode:new{Text = "复制 Ctrl+C", Name = "复制", Type = "Menuitem", NodeHeight = 26,onclick=function()
				Map3DSystem.App.Commands.Call("Profile.Inventor.Copy")
			end});
			root_node:AddChild(CommonCtrl.TreeNode:new{Text = "粘贴 Ctrl+V", Name = "粘贴", Type = "Menuitem", NodeHeight = 26,onclick=function()
				Map3DSystem.App.Commands.Call("Profile.Inventor.Paste")
			end});
			if(lite3DCanvas:CanGroup())then
				root_node:AddChild(CommonCtrl.TreeNode:new{Text = "群组 Ctrl+G", Name = "群组", Type = "Menuitem", NodeHeight = 26,onclick=function()
					Map3DSystem.App.Commands.Call("Profile.Inventor.Group")
				end});
			end
			if(lite3DCanvas:CanUnGroup())then
				root_node:AddChild(CommonCtrl.TreeNode:new{Text = "取消群组 Ctrl+B", Name = "取消群组", Type = "Menuitem", NodeHeight = 26,onclick=function()
					Map3DSystem.App.Commands.Call("Profile.Inventor.UnGroup")
				end});
			end
			root_node:AddChild(CommonCtrl.TreeNode:new{Text = "删除 Delete", Name = "删除", Type = "Menuitem", NodeHeight = 26,onclick=function()
				Map3DSystem.App.Commands.Call("Profile.Inventor.Delete")
			end});

		ctl:Show(msg.mouse_x,msg.mouse_y);
	end
	return nil; 
end
function GlobalInventor.OnKeyDown(nCode, appName, msg)
	if(not GlobalInventor.canKeyControl)then return nCode end;
	local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
	local alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
	local shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
	if(ctrl_pressed)then
		
		if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_X))then
			-- cut
			Map3DSystem.App.Commands.Call("Profile.Inventor.Cut");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_C))then
			-- copy
			Map3DSystem.App.Commands.Call("Profile.Inventor.Copy");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_V) and not shift_pressed)then
			-- paste
			Map3DSystem.App.Commands.Call("Profile.Inventor.Paste","absolute");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_V) and shift_pressed)then
			-- paste
			Map3DSystem.App.Commands.Call("Profile.Inventor.Paste","relative");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_Z))then
			-- undo
			Map3DSystem.App.Commands.Call("Profile.Inventor.Undo");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_Y))then
			-- redo
			Map3DSystem.App.Commands.Call("Profile.Inventor.Redo");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_G))then
			-- group
			Map3DSystem.App.Commands.Call("Profile.Inventor.Group");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_B))then
			-- ungroup
			Map3DSystem.App.Commands.Call("Profile.Inventor.UnGroup");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_A))then
			-- select all
			Map3DSystem.App.Commands.Call("Profile.Inventor.SelectAll");
			GlobalInventor.commandCallBack();
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_N))then
			-- NewDocument 
			Map3DSystem.App.Commands.Call("Profile.Inventor.NewDocument");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_O))then
			-- OpenDocument 
			Map3DSystem.App.Commands.Call("Profile.Inventor.OpenDocument");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_S) and not shift_pressed)then
			-- SaveDocument 
			Map3DSystem.App.Commands.Call("Profile.Inventor.SaveDocument");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_S) and shift_pressed)then
			-- SaveDocumentAs 
			Map3DSystem.App.Commands.Call("Profile.Inventor.SaveDocumentAs");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_D))then
			-- "Profile.Inventor.ShowLite3DCanvasView" 
			Map3DSystem.App.Commands.Call("Profile.Inventor.ShowLite3DCanvasView");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_P))then
			-- "Profile.Inventor.BindPropertyPanel" 
			Map3DSystem.App.Commands.Call("Profile.Inventor.BindPropertyPanel");
			
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_T))then
			-- select tool
			--Map3DSystem.App.Commands.Call("Profile.Inventor.PointerTool");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_E))then
			-- scale tool
			--Map3DSystem.App.Commands.Call("Profile.Inventor.ScaleTool");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_R))then
			-- rotation tool
			--Map3DSystem.App.Commands.Call("Profile.Inventor.RotationTool");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_EQUALS))then
			-- DoScaling +
			GlobalInventor.DoScaling("DIK_ADD");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_MINUS))then
			-- DoScaling -
			GlobalInventor.DoScaling("DIK_SUBTRACT");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RBRACKET) and  not alt_pressed)then
			-- DoFacing +
			GlobalInventor.DoFacing("DIK_RBRACKET");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LBRACKET) and  not alt_pressed)then
			-- DoFacing -
			GlobalInventor.DoFacing("DIK_LBRACKET");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_UP))then
			-- DoMoving x +
			GlobalInventor.DoMoving("DIK_UP_x");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_DOWN))then
			-- DoMoving x -
			GlobalInventor.DoMoving("DIK_DOWN_x");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LEFT))then
			-- DoMoving z +
			GlobalInventor.DoMoving("DIK_LEFT_z");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RIGHT))then
			-- DoMoving z -
			GlobalInventor.DoMoving("DIK_RIGHT_z");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_HOME))then
			-- DoMoving y +
			GlobalInventor.DoMoving("DIK_HOME_y");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_END))then
			-- DoMoving y -
			GlobalInventor.DoMoving("DIK_END_y");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RBRACKET) and alt_pressed)then
			-- advancerot +
			GlobalInventor.DoAdvanceRot("advancerot_up");
		elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LBRACKET) and alt_pressed)then
			-- advancerot -
			GlobalInventor.DoAdvanceRot("advancerot_down");
		end
		return nil;
	end	
	if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_DELETE))then
		-- delete selected
		Map3DSystem.App.Commands.Call("Profile.Inventor.Delete");
		GlobalInventor.commandCallBack();
		return nil;
	end
	if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE))then
		-- delete selected
		Map3DSystem.App.Commands.Call("Profile.Inventor.UnSelectAll");
		GlobalInventor.commandCallBack();
		return nil;
	end
	
	if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_TAB))then
		-- GetNextSelection
		Map3DSystem.App.Commands.Call("Profile.Inventor.GetNextSelection");
		GlobalInventor.commandCallBack();
		return nil;
	end
	if(shift_pressed)then
		return nil
	end
	return nCode;
end
function GlobalInventor.DoMoving(type)
	local value = 0.2;
	local x,y,z;
	if(type == "DIK_UP_x")then
		x = value;
		y = 0;
		z = 0;
	elseif(type == "DIK_DOWN_x")then
		x = -value;
		y = 0;
		z = 0;
	elseif(type == "DIK_HOME_y")then
		x = 0;
		y = value;
		z = 0;
	elseif(type == "DIK_END_y")then
		x = 0;
		y = -value;
		z = 0;
	elseif(type == "DIK_LEFT_z")then
		x = 0;
		y = 0;
		z = value;
	elseif(type == "DIK_RIGHT_z")then
		x = 0;
		y = 0;
		z = -value;
	end
	GlobalInventor.DoProperty("position",{x = x,y = y,z = z})
end
function GlobalInventor.DoScaling(type)
	local value = 0.1;
	local scaling;
	if(type == "DIK_ADD")then
		scaling = value;
	elseif(type == "DIK_SUBTRACT")then
		scaling = -value;
	end
	GlobalInventor.DoProperty("scaling",scaling)
end
function GlobalInventor.DoFacing(type)
	local value = 0.1;
	local facing;
	if(type == "DIK_LBRACKET")then
		facing = -value;
	elseif(type == "DIK_RBRACKET")then
		facing = value;
	end
	GlobalInventor.DoProperty("facing",facing)
end
function GlobalInventor.DoAdvanceRot(type)
	local value = 0.1;
	if(type == "advancerot_down")then
		value =  -0.1
	elseif(type == "advancerot_up")then
		value =  0.1
	end
	GlobalInventor.DoProperty("advancerot",value)
end
function GlobalInventor.DoProperty(type,value)
	if(not type or not value)then return end
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	
	if(lite3DCanvas)then
		local commandChangeState;
		--if(GlobalInventor.canHistory)then
			commandChangeState = Map3DSystem.App.Inventor.CommandChangeState:new();
			commandChangeState:Initialization(lite3DCanvas);
		--end
		local list = lite3DCanvas:GetSelection();
		local k,node;
		local temp_canHistory = true;
		for k,node in ipairs(list) do
			if(type == "position")then
				local x,y,z = value.x,value.y,value.z;
				node:SetPositionDelta(x,y,z);
			elseif(type == "facing")then
				node:SetFacingDelta(value);
			elseif(type == "advancerot")then
				local bindTarget_params = node:GetEntityParams();
				local delta_x = 0;
				local delta_y = value;
				local delta_z = 0;
				local center_x,center_y,center_z = ParaScene.GetPlayer():GetPosition();
				node:vec3RotateByPoint(center_x,center_y,center_z, 
												delta_x,delta_y,delta_z);
			elseif(type == "scaling")then
				local scaling = node:GetScaling();
				scaling = scaling + value
				if(scaling < 0.1)then
					temp_canHistory = false;
				else				
					node:SetScalingDelta(value);
				end
			end
		end
		if(GlobalInventor.canHistory)then
			if(commandManager and temp_canHistory)then
				commandChangeState:NewState(lite3DCanvas);
				commandManager:AddCommandToHistory(commandChangeState);
			end
		end
	end
end
------------------
-- change tool's state
function GlobalInventor.CreateTool(commandName)
	local self = GlobalInventor;
	local commandManager = self.commandManager;	
	local commandManagerEnabled = self.commandManagerEnabled;
	GlobalInventor.UnhookCreateEntity()
	local tool;
	if(commandName == "Profile.Inventor.PointerTool") then
		if(self.selectorTool == "EasySelectTool")then
			tool = Map3DSystem.App.Inventor.EasySelectTool:new();
		elseif(self.selectorTool == "SelectorTool")then
			tool = Map3DSystem.App.Inventor.SelectorTool:new();	
		end
		--tool = Map3DSystem.App.Inventor.PointerTool:new();	
		
		--tool = Map3DSystem.App.Inventor.SelectTool:new();
		--	
	elseif(commandName == "Profile.Inventor.EntityTool") then
		--tool = Map3DSystem.App.Inventor.EntityTool:new();
	elseif(commandName == "Profile.Inventor.RotationTool") then
		--tool = Map3DSystem.App.Inventor.RotationTool:new();
	elseif(commandName == "Profile.Inventor.ScaleTool") then
		--tool = Map3DSystem.App.Inventor.ScaleTool:new();
	end
	if(not tool)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/SelectTool.lua");
		tool = Map3DSystem.App.Inventor.PointerTool:new();	
	end
	tool:Initialization(commandManager)
	Map3DSystem.App.Inventor.GlobalInventor.Tool = tool;
	--Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor=cursor})
end
-----------------------------------------------------------------------
-- hook creator app
-----------------------------------------------------------------------
function GlobalInventor.CreateEntityTool(commandName)
	--Map3DSystem.App.Commands.Call(commandName);
	--GlobalInventor.HookCreateEntity()
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar3.lua");
	Map3DSystem.App.Inventor.Gears.ToolBar3.BuildEntity(commandName)
end
function GlobalInventor.HookCreateEntity()
	local o = {hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 		 
	hookName = "GlobalInventor_HookCreateEntity", appName = "scene", wndName = "object"}
	o.callback = GlobalInventor.Hook_SceneObject;
	CommonCtrl.os.hook.SetWindowsHook(o);	
end
function GlobalInventor.UnhookCreateEntity()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "GlobalInventor_HookCreateEntity", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
	Map3DSystem.UI.Creator.Close();
end
function GlobalInventor.Hook_SceneObject(nCode, appName, msg)
		local self = GlobalInventor;
		local obj_params = msg.obj_params;
		if(msg.type == Map3DSystem.msg.OBJ_CreateObject) then
			if(self.Lite3DCanvas)then
				local id = ParaGlobal.GenerateUniqueID();
				obj_params.name = id;
				NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/BaseObject.lua");
				local baseObject = Map3DSystem.App.Inventor.BaseObject:new();
				baseObject:__Initialization(obj_params)
				self.Lite3DCanvas:AddChild(baseObject);
				self.Lite3DCanvas:UnselectAll();
				self.Lite3DCanvas:UnPickAll();	
				if(baseObject and self.commandManager)then
						NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAdd.lua");
						if(self.commandManager)then
							local commandAdd = Map3DSystem.App.Inventor.CommandAdd:new();
							commandAdd:Initialization(baseObject);
							self.commandManager:AddCommandToHistory(commandAdd);
						end
				end
			end
		end
	return nCode
end
function GlobalInventor.GetNextSelection(commandName)
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(lite3DCanvas)then
		lite3DCanvas:GetNextSelection();
	end
end
-- undo redo
function GlobalInventor.UndoRedo(commandName)
	GlobalInventor.UnhookCreateEntity()
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	if(not commandManager)then return; end
	if(commandName == "Profile.Inventor.Undo") then
		commandManager:Undo();
	elseif(commandName == "Profile.Inventor.Redo") then
		commandManager:Redo();
	end
end
-- clone object
function GlobalInventor.Clone(commandName,type)
	GlobalInventor.UnhookCreateEntity()
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return; end
	if(commandName == "Profile.Inventor.Cut") then
		if(lite3DCanvas:CanCut())then
			local commandCut=Map3DSystem.App.Inventor.CommandCut:new();
			commandCut:Initialization(lite3DCanvas);
			lite3DCanvas:CutSelection();
			lite3DCanvas:SetPasteState("cut");
			if(commandManager)then
				commandManager:AddCommandToHistory(commandCut);
			end
		end
	elseif(commandName == "Profile.Inventor.Copy") then
		if(lite3DCanvas:CanCopy())then
			lite3DCanvas:CopySelection();
			lite3DCanvas:SetPasteState("copy");
		end
	elseif(commandName == "Profile.Inventor.Paste") then
		if(lite3DCanvas:CanPaste())then
			local pasteState = lite3DCanvas:GetPasteState();
			if(pasteState == "copy")then
				lite3DCanvas:CloneCopyList();
			end
			if(lite3DCanvas:CanPaste())then
				local commandPaste = Map3DSystem.App.Inventor.CommandPaste:new();
				commandPaste:Initialization(lite3DCanvas);
				if(type == "absolute")then
					lite3DCanvas:PasteCopyList();
				else
					local x,y,z = ParaScene.GetPlayer():GetPosition();
					local delta_x,delta_y,delta_z = lite3DCanvas:PasteCopyListRelative(x,y,z);
					if(delta_x and delta_y and delta_z)then
						commandPaste:Offset(delta_x,delta_y,delta_z);
					end
				end
				if(commandManager)then
					commandManager:AddCommandToHistory(commandPaste);
				end
			end
		end
	end
end
-- delete object
function GlobalInventor.Delete(commandName)
	GlobalInventor.UnhookCreateEntity()
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return; end
	if(commandName == "Profile.Inventor.Delete") then
		local commandDelete = Map3DSystem.App.Inventor.CommandDelete:new();
		commandDelete:Initialization(lite3DCanvas);
		local arr = lite3DCanvas:GetSelection();
		if(lite3DCanvas:CanDelete())then
			lite3DCanvas:DeleteSelection()
			lite3DCanvas:GetLastSelection();
			if(commandManager)then
				commandManager:AddCommandToHistory(commandDelete);
			end
		end
	elseif(commandName == "Profile.Inventor.DeleteAll") then
		local commandDeleteAll = Map3DSystem.App.Inventor.CommandDeleteAll:new();
		commandDeleteAll:Initialization(lite3DCanvas);
		if(lite3DCanvas:Clear())then
			if(commandManager)then
				commandManager:AddCommandToHistory(commandDeleteAll);
			end
		end
	end
end
function GlobalInventor.SelectAll(commandName)
	GlobalInventor.UnhookCreateEntity()
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return end
	lite3DCanvas:SelectAll();
end
function GlobalInventor.UnSelectAll(commandName)
	GlobalInventor.UnhookCreateEntity()
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return end
	lite3DCanvas:UnselectAll();
end
function GlobalInventor.Group(commandName)
	GlobalInventor.UnhookCreateEntity()
	if(not GlobalInventor.canGroup)then return end
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return; end
	if(commandName == "Profile.Inventor.Group") then
		if(lite3DCanvas:CanGroup())then
			local commandGroup=Map3DSystem.App.Inventor.CommandGroup:new();
			commandGroup:Initialization(lite3DCanvas);
			local groupNode = lite3DCanvas:Group();
			if(groupNode)then
				commandGroup:SetGroupNode(groupNode);
				if(commandManager)then
					commandManager:AddCommandToHistory(commandGroup);
				end
			end
		end
	elseif(commandName == "Profile.Inventor.UnGroup") then
		if(lite3DCanvas:CanUnGroup())then
			local commandUnGroup=Map3DSystem.App.Inventor.CommandUnGroup:new();
			commandUnGroup:Initialization(lite3DCanvas);
			lite3DCanvas:UnGroup();
			if(commandManager)then
				commandManager:AddCommandToHistory(commandUnGroup);
			end
		end
	end
end
function GlobalInventor.BindPropertyPanel(bindTarget)
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return; end	
	if(not bindTarget)then
		local arr =  lite3DCanvas:GetSelection();
		bindTarget = arr[1];
	end
	if(bindTarget)then
		lite3DCanvas:UnselectAll();
		bindTarget:SetSelected(true);
		local type = bindTarget.CLASSTYPE;
		local url;
		local bindFunction;
		if(type == "Sprite3D" or type == "Actor3D" or type == "Building3D")then
			NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ObjectPropertyPanel.lua");
			url = "script/kids/3DMapSystemUI/Inventor/Gears/ObjectPropertyPanel.html"
			
			bindFunction = Map3DSystem.App.Inventor.Gears.ObjectPropertyPanel.DataBind;
			
			if(lite3DCanvas.canvasType == "PortalCanvas")then
				NPL.load("(gl)script/kids/3DMapSystemUI/Creator/StaticObjPage.lua");
				url = "script/kids/3DMapSystemUI/Creator/StaticObjPage.html"
			
				bindFunction = Map3DSystem.App.Creator.StaticObjPage.DataBind;
			end
		elseif(type == "ZoneNode")then
			NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZonePage.lua");
			url = "script/kids/3DMapSystemUI/Creator/ZonePage.html"
			
			bindFunction = Map3DSystem.App.Creator.ZonePage.DataBind;
		elseif(type == "PortalNode")then
			NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalPage.lua");
			url = "script/kids/3DMapSystemUI/Creator/PortalPage.html"
			
			bindFunction = Map3DSystem.App.Creator.PortalPage.DataBind;		
		end
		if(url and bindFunction)then
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="ObjectPropertyPanel", app_key = MyCompany.Apps.Inventor.app.app_key, bShow = false, bDestroy = true});
			
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url=url, name="ObjectPropertyPanel", 
				app_key=MyCompany.Apps.Inventor.app.app_key, 
				isShowTitleBar = true, 
				isShowToolboxBar = false, 
				isShowStatusBar = false, 
				initialPosX = 800 - 4, 
				initialPosY = 175, 
				initialWidth = 220, -- initial width of the window client area
				initialHeight = 440, -- initial height of the window client area
				allowDrag = true,
				opacity = 90,
				icon = "Texture/3DMapSystem/Creator/Level1_BCS.png; 0 0 48 48",
				text = "属性",
				style = CommonCtrl.WindowFrame.DefaultStyle,
				alignment = "Free", 
			});		
			bindFunction(bindTarget)
		end
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="ObjectPropertyPanel", app_key = MyCompany.Apps.Inventor.app.app_key, bShow = false, bDestroy = true});
			
		autotips.AddMessageTips("请选择一个物体!")
	end
end
function GlobalInventor.ShowLite3DCanvasView()
	GlobalInventor.UnhookCreateEntity()
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	if(not lite3DCanvas)then return end
	Map3DSystem.App.Inventor.LiteCanvasView.ShowPage();
	Map3DSystem.App.Inventor.LiteCanvasView.DataBind(lite3DCanvas);
end

function GlobalInventor.NewDocument()	
	local MainFrame = Map3DSystem.App.Inventor.GlobalInventor.MainFrame;
	if(MainFrame)then
		MainFrame:OnClickNew();
	end
end
function GlobalInventor.OpenDocument()
	local MainFrame = Map3DSystem.App.Inventor.GlobalInventor.MainFrame;
	if(MainFrame)then
		MainFrame:OnClickOpen();
	end
end
function GlobalInventor.SaveDocument()
	local MainFrame = Map3DSystem.App.Inventor.GlobalInventor.MainFrame;
	if(MainFrame)then
		MainFrame:OnClickSave();
	end
end
function GlobalInventor.SaveDocumentAs()
	local MainFrame = Map3DSystem.App.Inventor.GlobalInventor.MainFrame;
	if(MainFrame)then
		MainFrame:OnClickSaveAs();
	end
end

function GlobalInventor.__DoParse(xmlRoot)
	if(not xmlRoot)then return; end
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");		
		-- root: pe:storyboards
		local rootNode = nil;
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//Room") do
			rootNode = node;
			break;
		end		
		NPL.load("(gl)script/ide/Display/Util/ObjectsMcmlParser.lua");	
		if(rootNode) then
			local childnode;
			for childnode in rootNode:next() do
				local lite3DCanvas = CommonCtrl.Display.Util.ObjectsMcmlParser.create(childnode);
				return lite3DCanvas;
			end
		end
	end
end
function GlobalInventor.LoadMiniScene()
	if(not GlobalInventor.mytimer)then
		GlobalInventor.mytimer = commonlib.Timer:new({callbackFunc = GlobalInventor.Loading})
	end
	GlobalInventor.mytimer:Change(0, 10)
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	Map3DSystem.UI.LoaderUI.Start(100);
	GlobalInventor.LoadingValue = 10;
end
function GlobalInventor.Loading()
	GlobalInventor.LoadingValue = GlobalInventor.LoadingValue + 1;
	Map3DSystem.UI.LoaderUI.SetProgress(GlobalInventor.LoadingValue);
	if(GlobalInventor.LoadingValue>100)then
		Map3DSystem.UI.LoaderUI.End();
		GlobalInventor.mytimer:Change();
	end
end
-----------------------------------------------------------------------
-- draw selected nodes
-----------------------------------------------------------------------
-- now surport position,facing,sacling
function GlobalInventor.DrawMirrorOfSelectedNodes(selectedNodes,position,facing,sacling,advRotation)
	if(not selectedNodes)then return end
	NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
	local miniScene = GlobalInventor.DrawMirrorOfSelectedNodes_Scene;
	if(not miniScene)then
		miniScene = CommonCtrl.Display.Containers.MiniScene:new()
		miniScene:Init();
		GlobalInventor.DrawMirrorOfSelectedNodes_Scene = miniScene;
	end
	local k,node;
	for k,node in ipairs(selectedNodes) do
		local uid = node:GetUID();
		uid = uid.."_";
		local _node = miniScene:GetChildByUID(uid);
		if(_node)then
			if(position)then
				_node:SetPositionDelta(position.x,position.y,position.z);
			end
			if(facing)then
				_node:SetFacingDelta(facing);
			end
			if(sacling)then
				_node:SetScalingDelta(sacling);
			end
			if(advRotation)then
				local center_x,center_y,center_z = advRotation.center_x,advRotation.center_y,advRotation.center_z;
				local delta_x,delta_y,delta_z = advRotation.delta_x,advRotation.delta_y,advRotation.delta_z;
				_node:vec3RotateByPoint(center_x,center_y,center_z, 
												delta_x,delta_y,delta_z);
			end
		else
			_node = node:CloneNoneID();
			
			_node:SetUID(uid);
			miniScene:AddChild(_node);		
		end
	end
end
function GlobalInventor.Destroy_DrawMirrorOfSelectedNodes()
	local miniScene = GlobalInventor.DrawMirrorOfSelectedNodes_Scene;
	if(miniScene)then
		miniScene:Clear();
		GlobalInventor.DrawMirrorOfSelectedNodes_Scene = nil;
	end
end
function GlobalInventor.Update_DrawMirrorOfSelectedNodes(selectedNodes)
	local miniScene = GlobalInventor.DrawMirrorOfSelectedNodes_Scene;
	if(not miniScene or not selectedNodes)then return end;
	local k,node;
	for k,node in ipairs(selectedNodes) do
		local uid = node:GetUID();
		uid = uid.."_";
		local _node = miniScene:GetChildByUID(uid);
		if(_node)then		
			local x,y,z = _node:GetPosition();
			node:SetPosition(x,y,z);
			local facing = _node:GetFacing();
			node:SetFacing(facing);
			local scaling = _node:GetScaling();
			node:SetScaling(scaling);
			local x,y,z,w = _node:GetRotation()
			node:SetRotation(x,y,z,w);
		end
	end
end
function GlobalInventor.Create_DrawMirrorOfSelectedNodes(selectedNodes,lite3DCanvas,commandManager)
	local miniScene = GlobalInventor.DrawMirrorOfSelectedNodes_Scene;
	if(not miniScene or not selectedNodes or not lite3DCanvas)then return end;
	local k,node;
	lite3DCanvas:UnselectAll();
	local cloneList = {};
	for k,node in ipairs(selectedNodes) do
		local uid = node:GetUID();
		uid = uid.."_";
		local _node = miniScene:GetChildByUID(uid);
		if(_node)then
			local clone_node =node:CloneNoneID();
			lite3DCanvas:AddChild(clone_node);
			local x,y,z = _node:GetPosition();
			clone_node:SetPosition(x,y,z);
			local facing = _node:GetFacing();
			clone_node:SetFacing(facing);
			local scaling = _node:GetScaling();
			clone_node:SetScaling(scaling);
			
			clone_node:SetSelected(true);
			
			table.insert(cloneList,clone_node);
		end
	end
	local len = #cloneList;
	if(len>0 and commandManager)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAddMulti.lua");
		local command = Map3DSystem.App.Inventor.CommandAddMulti:new();
		command:Initialization(cloneList);
		commandManager:AddCommandToHistory(command);
	end		
end
function GlobalInventor.GetPressedNode_DrawMirrorOfSelectedNodes(pressedNode)
	local miniScene = GlobalInventor.DrawMirrorOfSelectedNodes_Scene;
	if(not miniScene or not pressedNode)then return end;
	local node = pressedNode;
	local uid = node:GetUID();
	uid = uid.."_";
	local _node = miniScene:GetChildByUID(uid);
	return _node;
end