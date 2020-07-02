--[[
Title: SeniorEditor
Author(s): Leio
Date: 2009/2/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
Map3DSystem.App.Inventor.Gears.ToolBar.Show();

NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/SeniorEditor.lua");
Map3DSystem.App.Inventor.SeniorEditor.Start()
Map3DSystem.App.Commands.Call("Profile.Inventor.NewDocument");
Map3DSystem.App.Commands.Call("Creation.ObjectEditor");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
local SeniorEditor = {
	isStart = false,
	onNewDocFunc = nil,
	onOpenDocFunc = nil,
	onSaveDocFunc = nil,
	onSaveAsDocFunc = nil,
}
commonlib.setfield("Map3DSystem.App.Inventor.SeniorEditor",SeniorEditor);
function SeniorEditor.Start()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local config = SeniorEditor.EditorConfig();
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
	Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
	local lite3DCanvas = GlobalInventor.Lite3DCanvas
	GlobalInventor.MainFrame = CommonCtrl.LocalSingleDocumentFrame:new{
			onNewDocFunc = SeniorEditor.DoNewDocument,
			onOpenDocFunc = SeniorEditor.DoOpenDocument,
			onSaveDocFunc = SeniorEditor.DoSaveDocument,
			onSaveAsDocFunc = SeniorEditor.DoSaveAsDocument,
			lite3DCanvas = lite3DCanvas
		};
	SeniorEditor.isStart = true;
end
function SeniorEditor.GetDocumentFrame()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	return GlobalInventor.MainFrame;
end
function SeniorEditor.ReStart()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local lite3DCanvas = GlobalInventor.Lite3DCanvas;
	if(lite3DCanvas)then 
		lite3DCanvas:Clear();
	end
	
	GlobalInventor.Clear();
	local config = SeniorEditor.EditorConfig();
	Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
end
function SeniorEditor.End()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local lite3DCanvas = GlobalInventor.Lite3DCanvas;
	if(lite3DCanvas)then 
		lite3DCanvas:Clear();
	end
	GlobalInventor.MainFrame = nil;
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
	SeniorEditor.isStart = false;
end
function SeniorEditor.DoNewDocument(MainFrame)
	if(not MainFrame)then return end
	local curDoc = MainFrame:GetCurrentDocument();	
	SeniorEditor.ReStart()
	curDoc:SetCanvas(Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas);
	local self = SeniorEditor;
	if(self.onNewDocFunc)then
		self.onNewDocFunc(self);
	end
end
function SeniorEditor.DoOpenDocument(MainFrame)
	if(not MainFrame)then return end
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local lite3DCanvas = GlobalInventor.Lite3DCanvas;
	if(lite3DCanvas)then 
		lite3DCanvas:Clear();
	end	
	GlobalInventor.Clear();
	
	local curDoc = MainFrame:GetCurrentDocument();	
	if(curDoc and curDoc:GetCanvas())then
		local lite3DCanvas_new = curDoc:GetCanvas();
		local config = SeniorEditor.EditorConfig(lite3DCanvas_new)	
		Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);

		local x,y,z = lite3DCanvas_new:GetPlayerPos();
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x=x or 255, z=z or 255});
		local self = SeniorEditor;
		if(self.onOpenDocFunc)then
			self.onOpenDocFunc(self);
		end
	else
		_guihelper.MessageBox("加载失败！");
	end
	--local xmlRoot = ParaXML.LuaXML_ParseString(curDoc:GetData());
	--local lite3DCanvas_new = GlobalInventor.__DoParse(xmlRoot)
	--
	--if(lite3DCanvas_new)then
		--local config = SeniorEditor.EditorConfig(lite3DCanvas_new)	
		--Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
		--curDoc:SetCanvas(lite3DCanvas_new);
		--
		--local self = SeniorEditor;
		--if(self.onOpenDocFunc)then
			--self.onOpenDocFunc(self);
		--end
	--else
		--_guihelper.MessageBox("加载失败！");
	--end
end
function SeniorEditor.DoSaveDocument(MainFrame)
	if(not MainFrame)then return end
	
	_guihelper.MessageBox("保存成功！");
	
	local self = SeniorEditor;
	if(self.onSaveDocFunc)then
		self.onSaveDocFunc(self);
	end
end
function SeniorEditor.DoSaveAsDocument(MainFrame)
	if(not MainFrame)then return end
	local self = SeniorEditor;
	if(self.onSaveAsDocFunc)then
		self.onSaveAsDocFunc(self);
	end
end
function SeniorEditor.EditorConfig(lite3DCanvas)
	if(not lite3DCanvas)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");
		lite3DCanvas =  Map3DSystem.App.Inventor.LiteCanvas:new{
			sceneType = "Scene", -- "MiniScene" or "Scene"
			autoPick = false, -- this value can set true only if sceneType is Scene
		} 
	end
	local config = {
	lite3DCanvas = lite3DCanvas,
	canHistory = true,
	canKeyControl = true,
	canContexMenu = false,
	selectorTool = "SelectorTool", -- "EasySelectTool" or "SelectorTool",default is "EasySelectTool"
	
	editor = "SeniorEditor"
}
	return config;
end
function SeniorEditor.SetTool(s)
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local commandManager = GlobalInventor.commandManager;	
	local tool;
	if(s == "SelectorTool")then
		tool = Map3DSystem.App.Inventor.SelectorTool:new();	
	elseif(s == "EasySelectTool")then
		tool = Map3DSystem.App.Inventor.EasySelectTool:new();
	elseif(s == "EntityTool")then
		tool = Map3DSystem.App.Inventor.EntityTool:new();
	end
	
	if(not tool)then
		tool = Map3DSystem.App.Inventor.SelectorTool:new();	
	end
	tool:Initialization(commandManager)
	GlobalInventor.Tool = tool;
end
function SeniorEditor.SetEntityToolParams(params)
	if(not params)then return end;
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local tool = GlobalInventor.Tool;
	if(tool and tool.SetEntityParams)then
		tool:SetEntityParams(params);
	end
end