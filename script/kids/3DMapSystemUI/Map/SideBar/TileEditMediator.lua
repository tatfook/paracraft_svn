

NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditWnd.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditCmd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditCmdHolder.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditManager.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppTileEditScene.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditPanel.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppDataPvd.lua");
 
Map3DApp.TileEditMediator = {};
Map3DApp.TileEditMediator.scene = Map3DApp.TileEditScene;
Map3DApp.TileEditMediator.panel = Map3DApp.TileEditPanel;
Map3DApp.TileEditMediator.frame = Map3DApp.TileEditWnd;
Map3DApp.TileEditMediator.manager = Map3DApp.TileEditManager;
Map3DApp.TileEditMediator.parentForm = nil;

--==========public method==============
function Map3DApp.TileEditMediator.Init()
	local self = Map3DApp.TileEditMediator;
	local editor = Map3DApp.TileEditor;
	local editScreen = Map3DApp.TileEditWnd;
	local editScene = Map3DApp.TileEditScene;
	local editPanel = Map3DApp.TileEditPanel;
	
	self.frame.SetUIEventCallback(self.onEditWndMsg);
	self.manager.SetMsgCallback(self.OnTileEditManagerMsg);
	self.panel.SetMsgCallback(self.OnPanelMsg);
	self.scene.SetMsgCallback(self.OnEditSceneMsg);
	
	self.frame.AddMsgListener("mediator",self.OnFrameMsg);
end

function Map3DApp.TileEditMediator.SetParentForm(parentForm)
	Map3DApp.TileEditMediator.parentForm = parentForm;
end

--==========private method=============
function Map3DApp.TileEditMediator.OnFrameMsg(msg,data)
	local self = Map3DApp.TileEditMediator;
	
	if(msg == self.frame.Msg.filterChange)then
		if(data == nil)then
			return;
		end
		
	elseif(msg == self.frame.Msg.pageUp)then
		Map3DApp.ModelPageManager.PageUp();
		
	elseif(msg == self.frame.Msg.pageDown)then
		Map3DApp.ModelPageManager.PageDown();
		
	elseif(msg == self.frame.Msg.itemSelect)then
		--when select a model
		if(data == nil)then 
			return;
		end
		
		--create a add model command
		local _modelData = Map3DApp.ModelData:new{
			modelID = data.id,
			model = data.modelPath,
			texture0 = data.texturePath,
			offsetX = 0,
			offsetY = 0,
			facing = 0,
		};
		
		local cmd = Map3DApp.Commands.AddModelCmd:new{
			cmdID = Map3DApp.Commands.IDGenerator.GetNewID();
			modelID = self.manager.GetNewModelID();
			modelData = _modelData;
			sceneEditor = self.scene;
			editManager = self.manager;
		};
		cmd:Execute();
		self.scene.SetActiveModel(cmd.modelID);
		self.scene.SetEditState(self.scene.EditState.add);
		self.scene.ShowModel(cmd.modelID,false);
		self.scene.SetCommand(cmd);
		
		--update modelInfo window;
		if(self.frame.modelInfoWnd)then
			self.frame.modelInfoWnd:SetModelInfo(data);
		end
	
	elseif(msg == self.frame.Msg.formLoaded)then
		Map3DApp.ModelPageManager.FirstPage();
	end
end

function Map3DApp.TileEditMediator.OnTileInfoChange()
	local editor = Map3DApp.TileEditor;
	local editScreen = Map3DApp.TileEditWnd;
	local editScene = Map3DApp.TileEditScene;

	--remove all old models
	editScene.ClearAllModel();
	
	--update terrain
	local terrainInfo = editor.GetTerrainInfo();
	editScene.SetTerrainInfo(terrainInfo);
	
	--update models
	local models = seditor.GetModels();
	if(models ~= nil)then
		for k,v in pairs(models) do
			editScene.AddModel(k,v);
		end
	end
end

function Map3DApp.TileEditMediator.OnPageChange()
	Map3DApp.TileEditWnd.SetPageIndex(Map3DApp.TileEditor.GetCurPageIndex().."/"..Map3DApp.TileEditor.GetTotalPageCount());
end

--handle edit panel message
function Map3DApp.TileEditMediator.OnPanelMsg(msg)
	local self = Map3DApp.TileEditMediator;
	if(msg == nil)then
		return;
	end

	if(msg == self.panel.Msg.Cancel)then
		self.scene.ClearAllModel();
		if(self.parentForm and self.parentForm.SwitchFrame)then
			self.parentForm:SwitchFrame("map");
		end
		
	elseif(msg == self.panel.Msg.Delete)then
		--delete select model
		local _modelID = self.manager.GetActiveModelID();
		local _modelInfo = self.manager.GetModelInfo(_modelID);
		if(_modelID)then
			--create delete model command
			local cmd = Map3DApp.Commands.DeleteModelCmd:new{
				cmdID = Map3DApp.Commands.IDGenerator.GetNewID(),
				modelID = _modelID,
				sceneEditor = Map3DApp.TileEditScene,
				editManager = Map3DApp.TileEditManager
			}
			cmd:Execute();
			--add command to command queue
			self.manager.cmdHolder.AddCommand(cmd);
		end
		
	elseif(msg == self.panel.Msg.RightRotate)then
		--right rotate select model	
		local _modelID = self.manager.GetActiveModelID();
		local _modelInfo = self.manager.GetModelInfo(_modelID);
		if(_modelID)then
			--create change model facing command
			local cmd = Map3DApp.Commands.ChangeModelFacingCmd:new{
				cmdID = Map3DApp.Commands.IDGenerator.GetNewID(),
				modelID = _modelID,
				newFacing = _modelInfo.facing - math.pi/2,
				oldFacing = _modelInfo.facing,
				sceneEditor = self.scene,
				editManager = self.manager,
			}
			cmd:Execute();
			--add command to command queue
			self.manager.cmdHolder.AddCommand(cmd);
		end
		
	elseif(msg == self.panel.Msg.LeftRotate)then
		local _modelID = self.manager.GetActiveModelID();
		local _modelInfo = self.manager.GetModelInfo(_modelID);
		if(_modelID)then
			local cmd = Map3DApp.Commands.ChangeModelFacingCmd:new{
				cmdID = Map3DApp.Commands.IDGenerator.GetNewID(),
				modelID = _modelID,
				newFacing = _modelInfo.facing + math.pi/2,
				oldFacing = _modelInfo.facing,
				sceneEditor = self.scene,
				editManager = self.manager,
			}
			cmd:Execute();
			self.manager.cmdHolder.AddCommand(cmd);
		end
		
	elseif(msg == self.panel.Msg.Save)then
		self.scene.ClearAllModel();
		if(self.parentForm and self.parentForm.SwitchFrame)then
			self.parentForm:SwitchFrame("map");
		end
		--TODO:Save Data
		
	elseif(msg == editPanel.Msg.Undo)then
		Map3DApp.TileEditManager.cmdHolder.Undo();
		
	elseif(msg == editPanel.Msg.Redo)then
		Map3DApp.TileEditManager.cmdHolder.Redo();
	end
end

--handle edit scene message
function Map3DApp.TileEditMediator.OnEditSceneMsg(msg,data)
	local editScene = Map3DApp.TileEditScene;
	local editManager = Map3DApp.TileEditManager;
		
	--create add model command
	if(msg == editScene.Msg.addModel)then
		local _modelInfo = editManager.GetModelInfo(data.modelID);
		if(_modelInfo)then
			_modelInfo.offsetX = data.x;
			_modelInfo.offsetY = data.y;
		
			local cmd = Map3DApp.Commands.AddModelCmd:new{
				cmdID = Map3DApp.Commands.IDGenerator.GetNewID(),
				modelID = data.modelID,
				modelData = _modelInfo,
				sceneEditor = editScene,
				editManager = editManager,
			}
			editManager.cmdHolder.AddCommand(cmd);
		end
	--create model position change command
	elseif(msg == editScene.Msg.modelPosChange)then
		if(data)then
			local cmd = Map3DApp.Commands.ChangeModelPosCmd:new{
				cmdID = Map3DApp.Commands.IDGenerator.GetNewID(),
				modelID = data.modelID,
				newPosX = data.x,
				newPosY = data.y,
				sceneEditor = editScene,
				editManager = editManager,
			}
			cmd:Execute();
			editManager.cmdHolder.AddCommand(cmd);
		end
		
	elseif(msg == editScene.Msg.modelSelect)then
		if(data and data:IsValid() and data.name ~= editManager.GetActiveModelID())then
			editManager.SetActiveModel(data.name);
		else
			editManager.SetActiveModel(nil);
		end
	end
end

--handle eidt window message 
function Map3DApp.TileEditMediator.OnEditWndMsg(msg,data)
	if(msg == Map3DApp.TileEditWnd.Msg.filterChange)then
		if(data == nil)then
			return;
		end
		Map3DApp.TileEditor.SetModelFilter(data);
	elseif(msg == Map3DApp.TileEditWnd.Msg.pageUp)then
		
		Map3DApp.TileEditor.PageUp();
	elseif(msg == Map3DApp.TileEditWnd.Msg.pageDown)then
		
		Map3DApp.TileEditor.PageDown();
	elseif(msg == Map3DApp.TileEditWnd.Msg.ItemSelect)then
		if(data == nil)then 
			return;
		end
		
		local cmd = Map3DApp.Commands.AddModelCmd:new{
			cmdID = Map3DApp.Commands.IDGenerator.GetNewID();
			modelID = Map3DApp.TileEditManager.GetNewModelID();
			modelData = data;
			sceneEditor = Map3DApp.TileEditScene;
			editManager = Map3DApp.TileEditManager;
		};
		cmd:Execute();
		Map3DApp.TileEditScene.SetActiveModel(cmd.modelID);
		Map3DApp.TileEditScene.SetEditState(Map3DApp.TileEditScene.EditState.add);
		Map3DApp.TileEditScene.ShowModel(cmd.modelID,false);
		Map3DApp.TileEditScene.SetCommand(cmd);
	
	end
end

--handle land window message
function Map3DApp.TileEditMediator.OnLandWndMsg(msg,data)
	if(msg == Map3DApp.LandWnd.Msg.edit)then
		Map3DApp.TileEditMediator.mainWnd:SetDisplayMode(Map3DApp.MainWnd.DisplayMode.edit);
	elseif(msg == Map3DApp.LandWnd.Msg.buy)then
	
	elseif(msg == Map3DApp.LandWnd.Msg.rent)then
	end
end

--handle tile edit manager message
function Map3DApp.TileEditMediator.OnTileEditManagerMsg(msg,data)
	if(msg == Map3DApp.TileEditManager.Msg.onModelSelect)then

	end
end

--on model of page call return
function Map3DApp.TileEditMediator.OnModelOfPageUpdate(modelInfos)
	local self = Map3DApp.TileEditMediator;
	--local _this = CommonCtrl.GetControl(self.frame.ctrModelGridView);
	local _this = self.frame.modelGridView;
	if(_this)then
	
		self.frame.SetPageIndex(self.frame.GetModelPageIndex().."/"..Map3DApp.DataPvd.GetModelPageCount());
		--refresh model view
		if(modelInfos)then
			--delete old data
			_this:Reset();
			local i = 1;
			--add new model
			while (modelInfos[i] and (not _this:IsFull())) do
				_this:AddCell(modelInfos[i].thumbnail,modelInfos[i])
				i = i + 1;
			end
		end
		_this:RefreshCells();
	end
end

function Map3DApp.TileEditMediator.OnMapMousePick(selectItemName)
	log("call on map mouse pick:"..selectItemName.."\n");
	
end


--==============ModelPageManager====================
Map3DApp.ModelPageManager = {};
Map3DApp.ModelPageManager.totalPageCount = 0;
Map3DApp.ModelPageManager.activePageIndex = 0;
Map3DApp.ModelPageManager.dataPvd = Map3DApp.DataPvd;
Map3DApp.ModelPageManager.frame = Map3DApp.TileEditWnd;

--=========public method================
function Map3DApp.ModelPageManager.FirstPage()
	Map3DApp.ModelPageManager.activePageIndex = 0;
	Map3DApp.ModelPageManager.PageUp();	
end

function Map3DApp.ModelPageManager.PageUp()
	local self = Map3DApp.ModelPageManager;
	if(self.activePageIndex + 1 > self.totalPageCount)then
		--roll back to first page
		self.activePageIndex = 1;
	else
		--page up
		self.activePageIndex = self.activePageIndex + 1;
	end
	--update data
	self.OnPageChange();
end

function Map3DApp.ModelPageManager.PageDown()
	local self = Map3DApp.ModelPageManager;
	if(self.activePageIndex - 1 < 1)then
		--roll back to last page
		self.activePageIndex = self.totalPageCount;
	else
		--page down
		self.activePageIndex = self.activePageIndex - 1;
	end
	self.OnPageChange();	
end

function Map3DApp.ModelPageManager.GetPageIndex()
	return Map3DApp.ModelPageManager.activePageIndex;
end

function Map3DApp.ModelPageManager.GetTotalPageCount()
	return Map3DApp.ModelPageManager.totalPageCount;
end

--==========private method===============
function Map3DApp.ModelPageManager.OnPageChange()
	local self = Map3DApp.ModelPageManager;

	self.UpdatePageIndexDisplay();
	
	--get model count per page
	local modelOfPage = 10;
	if(self.frame.modelGridView)then
		modelOfPage = self.frame.modelGridView:GetMaxCellCount();
	end
	
	Map3DApp.DataPvd.GetModelOfPage(modelOfPage,self.activePageIndex,self.OnDataUpdate);
end

function Map3DApp.ModelPageManager.OnDataUpdate(modelInfos)
	local self = Map3DApp.ModelPageManager;
	
	self.totalPageCount = self.dataPvd.GetModelPageCount();
	
	self.UpdatePageIndexDisplay();
	
	if(self.frame.modelGridView == nil)then
		return;
	end
	
	--update model grid view display
	if(modelInfos)then
		self.frame.modelGridView:Reset();
		local i = 1;
		while ( modelInfos[i] and (not self.frame.modelGridView:IsFull()))do
			self.frame.modelGridView:AddCell(modelInfos[i].thumbnail,modelInfos[i]);
			i = i + 1;
		end
	end
	self.frame.modelGridView:RefreshCells();
end

function Map3DApp.ModelPageManager.UpdatePageIndexDisplay()
	local self = Map3DApp.ModelPageManager;
	
	--update page index display
	if(self.totalPageCount < self.activePageIndex)then
		self.frame.SetPageIndex("");
	else
		self.frame.SetPageIndex(self.activePageIndex.."/"..self.totalPageCount);
	end
end