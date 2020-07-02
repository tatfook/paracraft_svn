--[[
Title: JuniorEditor
Author(s): Leio
Date: 2009/2/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
Map3DSystem.App.Inventor.Gears.ToolBar.Show();

NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/JuniorEditor.lua");
Map3DSystem.App.Inventor.JuniorEditor.Start()
Map3DSystem.App.Commands.Call("Profile.Inventor.NewDocument");
--Map3DSystem.App.Commands.Call("Creation.ObjectEditor");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/ide/Document/RemoteSingleDocumentFrame.lua");
local JuniorEditor = {
	isStart = false,
	curDoc = nil,
	onNewDocFunc = nil,
	onOpenDocFunc = nil,
	onSaveDocFunc = nil,
	onSaveAsDocFunc = nil,
}
commonlib.setfield("Map3DSystem.App.Inventor.JuniorEditor",JuniorEditor);
function JuniorEditor.Start()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local config = JuniorEditor.EditorConfig();
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
	Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
	local lite3DCanvas = GlobalInventor.Lite3DCanvas
	GlobalInventor.MainFrame = CommonCtrl.RemoteSingleDocumentFrame:new{
			onNewDocFunc = JuniorEditor.DoNewDocument,
			onOpenDocFunc = JuniorEditor.DoOpenDocument,
			onSaveDocFunc = JuniorEditor.DoSaveDocument,
			onSaveAsDocFunc = JuniorEditor.DoSaveAsDocument,
			lite3DCanvas = lite3DCanvas
		};
	JuniorEditor.isStart = true;
end
function JuniorEditor.GetDocumentFrame()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	return GlobalInventor.MainFrame;
end
function JuniorEditor.End()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local lite3DCanvas = GlobalInventor.Lite3DCanvas;
	if(lite3DCanvas)then 
		lite3DCanvas:Clear();
	end
	if(self.curDoc)then
		local static_canvas = self.curDoc:GetStaticCanvas();
		static_canvas:Clear();
	end
	GlobalInventor.MainFrame = nil;
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
	JuniorEditor.isStart = false;
end
function JuniorEditor.OpenFile()
	local doc = CommonCtrl.RemoteSingleDocument:new();
	doc:SetFilePath(filepath);
	doc:Load();	
	-- after loaded
	self.curDoc = doc;
end

function JuniorEditor.SaveFile()
	if(self.curDoc)then
		self.curDoc:Save();
	end
end
function JuniorEditor.EditorConfig(lite3DCanvas)
	if(not lite3DCanvas)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");
		lite3DCanvas =  Map3DSystem.App.Inventor.LiteCanvas:new{
			sceneType = "Scene", -- "MiniScene" or "Scene"
			autoPick = true, -- this value can set true only if sceneType is Scene
		} 
	end
	local config = {
	lite3DCanvas = lite3DCanvas,
	canHistory = true,
	canKeyControl = false,
	canContexMenu = false,
	selectorTool = "EasySelectTool", -- "EasySelectTool" or "SelectorTool",default is "EasySelectTool"
	
	editor = "JuniorEditor"
}
	return config;
end
function JuniorEditor.SetTool(s)
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local commandManager = GlobalInventor.commandManager;	
	local tool;
	if(s == "EasySelectTool")then
		tool = Map3DSystem.App.Inventor.EasySelectTool:new();
	elseif(s == "EntityTool")then
		tool = Map3DSystem.App.Inventor.EntityTool:new();
	end
	
	if(not tool)then
		tool = Map3DSystem.App.Inventor.EasySelectTool:new();	
	end
	tool:Initialization(commandManager)
	GlobalInventor.Tool = tool;
end
function JuniorEditor.SetEntityToolParams(params)
	if(not params)then return end;
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local tool = GlobalInventor.Tool;
	if(tool and tool.SetEntityParams)then
		tool:SetEntityParams(params);
	end
end