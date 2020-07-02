--[[
Title:Map tile edit command holder
Author(s): SunLingFeng
Desc:
Date: 2008/3/18
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditCmdHolder.lua");
-------------------------------------------------------
]]


local cmdHolder = {
	cmds = {},
	cmdCount = 0,
	maxCmdCount = 10,
	minCmdCount = 0,
	maxCmdIndex = 0,
	activeCmdIndex = 0,
	canRedo = false,
	canUndo = false,
};
Map3DApp.CommandHolder = cmdHolder;

function cmdHolder:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function cmdHolder:AddCommand(cmd)
	--add command to command queue
	self.activeCmdIndex = self.activeCmdIndex + 1;
	self.commands[self.activeCmdIndex] = cmd;
	
	--update command queue index
	self.maxCmdIndex = self.activeCmdIndex;
	self.cmdCount = self.maxCmdIndex - self.minCmdIndex;
	
	if(self.minCmdIndex == 0)then
		self.minCmdIndex = 1;
	end
	
	--cmd queue is full,pop the first element
	if(self.cmdCount > self.maxCmdCount)then
		self.PopCommand();
	end
	self.SetCanUndo(true);
end

function cmdHolder:Redo()
	if(self.activeCmdIndex < self.maxCmdIndex)then
		self.activeCmdIndex = self.activeCmdIndex + 1;
		if(self.commands[self.activeCmdIndex])then
			self.commands[self.activeCmdIndex]:Execute();
		end
		
		if(self.activeCmdIndex >= self.maxCmdIndex)then
			self.SetCanRedo(false);
		end
		
		self.SetCanUndo(true);
	end
end

function cmdHolder:Undo()
	if(self.activeCmdIndex >= self.minCmdIndex)then
		if(self.commands[self.activeCmdIndex] ~= nil)then
			self.commands[self.activeCmdIndex]:Undo();
			self.activeCmdIndex = self.activeCmdIndex - 1;		
		end
		
		if(self.activeCmdIndex < self.minCmdIndex)then
			self.SetCanUndo(false);
		end
		
		self.SetCanRedo(true);
	end
end

function cmdHolder:ClearAllCommand()
	for i=self.minComdIndex,self.CmdCount do
		if(self.commands[i] ~= nil)then
			commands[i]:Dispose();
		end
	end

	self.Reset();
end

function cmdHolder:CanRedo()
	return Map3DApp.CommandHolder.canRedo;
end

function cmdHolder:CanUndo()
	return Map3DApp.CommandHolder.canUndo;
end

function cmdHolder:PopCommand()
	if(self.commands[self.minCmdIndex] ~= nil)then
		--remove command
		self.commands[self.minCmdIndex]:Dispose();
		self.commands[self.minCmdIndex] = nil;
		
		--update command queue index
		self.cmdCount = self.cmdCount - 1;
		if(self.cmdCount < 1)then
			--no more command,reset all index
			self.Reset();
		else
			self.minCmdIndex = self.minCmdIndex + 1;
		end
	end
end

function cmdHolder:Reset()
	self.commands = {};
	self.minCmdIndex = 0;
	self.maxCmdIndex = 0;
	self.cmdCount = 0;
	self.activeCmdIndex = 0;
	self.canRedo = false;
	self.canUndo = false;
end

function cmdHolder:SetCanRedo(canRedo)
	self.canRedo = canRedo;
end

function cmdHolder:SetCanUndo(canUndo)
	self.canUndo = canUndo;
end




------------------------------------
--
Map3DApp.CommandHolder = {};
Map3DApp.CommandHolder.commands = {};
Map3DApp.CommandHolder.cmdCount = 0;
Map3DApp.CommandHolder.maxCmdCount = 10;
Map3DApp.CommandHolder.minCmdIndex = 0;
Map3DApp.CommandHolder.maxCmdIndex = 0;
Map3DApp.CommandHolder.activeCmdIndex = 0;
Map3DApp.CommandHolder.canRedo = false;
Map3DApp.CommandHolder.canUndo = false;


--=============public=======================
--function Map3DApp.CommandHolder.AddCommand(cmd)
	--local self = Map3DApp.CommandHolder;
	----add command to command queue
	--self.activeCmdIndex = self.activeCmdIndex + 1;
	--self.commands[self.activeCmdIndex] = cmd;
	--
	----update command queue index
	--self.maxCmdIndex = self.activeCmdIndex;
	--self.cmdCount = self.maxCmdIndex - self.minCmdIndex;
	--
	--if(self.minCmdIndex == 0)then
		--self.minCmdIndex = 1;
	--end
	--
	----cmd queue is full,pop the first element
	--if(self.cmdCount > self.maxCmdCount)then
		--self.PopCommand();
	--end
	--self.SetCanUndo(true);
--end
--
--function Map3DApp.CommandHolder.Redo()
	--local self = Map3DApp.CommandHolder;
	--
	--if(self.activeCmdIndex < self.maxCmdIndex)then
		--self.activeCmdIndex = self.activeCmdIndex + 1;
		--if(self.commands[self.activeCmdIndex])then
			--self.commands[self.activeCmdIndex]:Execute();
		--end
		--
		--if(self.activeCmdIndex >= self.maxCmdIndex)then
			--self.SetCanRedo(false);
		--end
		--
		--self.SetCanUndo(true);
	--end
--end
--
--function Map3DApp.CommandHolder.Undo()
	--local self = Map3DApp.CommandHolder;
--
	--if(self.activeCmdIndex >= self.minCmdIndex)then
		--if(self.commands[self.activeCmdIndex] ~= nil)then
			--self.commands[self.activeCmdIndex]:Undo();
			--self.activeCmdIndex = self.activeCmdIndex - 1;		
		--end
		--
		--if(self.activeCmdIndex < self.minCmdIndex)then
			--self.SetCanUndo(false);
		--end
		--
		--self.SetCanRedo(true);
	--end
--end
--
----clear all commands in command queue
--function Map3DApp.CommandHolder.ClearAllCommand()
	--local self = Map3DApp.CommandHolder;
	----dispose all command object
	--for i=self.minComdIndex,self.CmdCount do
		--if(self.commands[i] ~= nil)then
			--commands[i]:Dispose();
		--end
	--end
--
	--self.Reset();
--end
--
--function Map3DApp.CommandHolder.CanRedo()
	--return Map3DApp.CommandHolder.canRedo;
--end
--
--function Map3DApp.CommandHolder.CanUndo()
	--return Map3DApp.CommandHolder.canUndo;
--end
--
----==============private=======================
----remove the first element in command queue
--function Map3DApp.CommandHolder.PopCommand()
	--local self = Map3DApp.CommandHolder;
	--
	--if(self.commands[self.minCmdIndex] ~= nil)then
		----remove command
		--self.commands[self.minCmdIndex]:Dispose();
		--self.commands[self.minCmdIndex] = nil;
		--
		----update command queue index
		--self.cmdCount = self.cmdCount - 1;
		--if(self.cmdCount < 1)then
			----no more command,reset all index
			--self.Reset();
		--else
			--self.minCmdIndex = self.minCmdIndex + 1;
		--end
	--end
--end
--
--function Map3DApp.CommandHolder.Reset()
	--self.commands = {};
	--self.minCmdIndex = 0;
	--self.maxCmdIndex = 0;
	--self.cmdCount = 0;
	--self.activeCmdIndex = 0;
	--self.canRedo = false;
	--self.canUndo = false;
--end
--
--function Map3DApp.CommandHolder.SetCanRedo(canRedo)
	--if(Map3DApp.CommandHolder.canRedo ~= canRedo)then
		--Map3DApp.CommandHolder.canRedo = canRedo;
	--end
--end
--
--function Map3DApp.CommandHolder.SetCanUndo(canUndo)
	--if(Map3DApp.CommandHolder.canUndo ~= canUndo)then
		--Map3DApp.CommandHolder.canUndo = canUndo;
	--end
--end
--
--