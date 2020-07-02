--[[
Title: UndoManager
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/UndoManager.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/TreeView.lua");
local UndoManager = {
	historyCmdList = nil,
	nextUndo = nil,
	lite3DCanvas = nil,
} 
commonlib.setfield("Map3DSystem.App.Inventor.UndoManager",UndoManager);
function UndoManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	--o:Initialization()
	return o
end
function UndoManager:Initialization(lite3DCanvas)
	self.name = ParaGlobal.GenerateUniqueID();
	self.lite3DCanvas = lite3DCanvas;
	self:ClearHistory();
end
function UndoManager:ClearHistory()
	self.historyCmdList = {};
	self.nextUndo = 0;
end
function UndoManager:AddCommandToHistory(command)
	if(not command)then return; end
	self:TrimHistoryList();
	table.insert(self.historyCmdList,command);
	--table.insert(self.historyCmdList,{});
	self.nextUndo = self.nextUndo + 1;
end
function UndoManager:CanUndo()
	if(self.nextUndo < 1 or self.nextUndo > (#self.historyCmdList))then
		return false;
	end
	return true;
end	
function UndoManager:CanRedo()
	if(self.nextUndo == (#self.historyCmdList))then
		return false;
	end
	return true;
end	
function UndoManager:Undo()		
	if(not self:CanUndo())then
		return; 
	end
	local command = self.historyCmdList[self.nextUndo];
	if(command)then
		command:Undo(self.lite3DCanvas);
		self.nextUndo = self.nextUndo - 1;	
	end
end
function UndoManager:Redo()
	if(not self:CanRedo())then
		return; 
	end
	
	local itemToRedo = self.nextUndo + 1;
	local command = self.historyCmdList[itemToRedo];
	if(command)then
		command:Redo(self.lite3DCanvas);
		self.nextUndo = itemToRedo;
	end
end
function UndoManager:TrimHistoryList()
	if(not self.historyCmdList)then return; end
	local len = #self.historyCmdList;
	if(len == 0)then
		return;
	end
	if(self.nextUndo == (len))then
		return;
	end
	local index = self.nextUndo;	
	while(len > index) do
		table.remove(self.historyCmdList,len);
		len = len - 1;
	end
end