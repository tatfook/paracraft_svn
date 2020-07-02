--[[
Title: HomeZoneEditor
Author(s): Leio
Date: 2009/2/18
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
Map3DSystem.App.Inventor.Gears.ToolBar.Show();

NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneEditor.lua");
Map3DSystem.App.HomeZoneEditor.Start()
Map3DSystem.App.HomeZoneEditor.Load()

NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneEditor.lua");
Map3DSystem.App.HomeZoneEditor.PushATemplate()
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Document/RemoteSingleDocument.lua");
local HomeZoneEditor = {
	isStart = false,
	curDoc = nil,
	name = "HomeZoneEditor_instance",
}
commonlib.setfield("Map3DSystem.App.HomeZoneEditor",HomeZoneEditor);
function HomeZoneEditor.loadFunc(bSucceed)
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	if(bSucceed) then
		--_guihelper.MessageBox("加载成功！");
		if(HomeZoneEditor.curDoc)then
			--NPL.load("(gl)script/kids/3DMapSystemUI/loadworld.lua");
			--Map3DSystem.UI.LoadWorld.LoadWorldImmediate("worlds/3DMapStartup")
			System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/DoodleWorld"});
			HomeZoneEditor.Show();

			local data = HomeZoneEditor.curDoc:GetData();
			HomeZoneEditor.curDoc:DoParse(data);
			
			local lite3DCanvas = HomeZoneEditor.curDoc:GetCanvas();	
			if(not lite3DCanvas)then return end	
			local x,y,z = lite3DCanvas:GetPlayerPos();
			Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x=x or 255, z=z or 255});
			
			local config = HomeZoneEditor.EditorConfig(lite3DCanvas);
			--Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
			Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
			
			local commandManager = GlobalInventor.commandManager;
			if(lite3DCanvas and commandManager)then
				commandManager:Initialization(lite3DCanvas);
			end
		else
			_guihelper.MessageBox("加载失败！");
		end
	else
		_guihelper.MessageBox("加载失败！");
	end
end
function HomeZoneEditor.saveFunc(bSucceed)
	if(bSucceed) then
		if(not HomeZoneEditor.quietSave)then
			_guihelper.MessageBox("保存成功！");
		end
	else
		if(not HomeZoneEditor.quietSave)then
			_guihelper.MessageBox("保存失败！");
		end
	end	
	HomeZoneEditor.quietSave = nil;
end
function HomeZoneEditor.ClearCanvas()
	if(HomeZoneEditor.curDoc)then
		HomeZoneEditor.curDoc:Clear();
	end
end
function HomeZoneEditor.Delete()
	Map3DSystem.App.Commands.Call("Profile.Inventor.Delete");
end
function HomeZoneEditor.Undo()
	Map3DSystem.App.Commands.Call("Profile.Inventor.Undo");
end
function HomeZoneEditor.Redo()
	Map3DSystem.App.Commands.Call("Profile.Inventor.Redo");
end
function HomeZoneEditor.Clear()
	local profile = "";
	Map3DSystem.App.HomeZone.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				_guihelper.MessageBox("清除成功！");
			else
				_guihelper.MessageBox("清除失败！");
			end	
		end)
end
function HomeZoneEditor.Start()
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local config = HomeZoneEditor.EditorConfig();
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
	Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
	
	HomeZoneEditor.isStart = true;
	local lite3DCanvas = GlobalInventor.Lite3DCanvas;
	local doc = CommonCtrl.RemoteSingleDocument:new();
	doc.loadFunc = HomeZoneEditor.loadFunc;
	doc.saveFunc = HomeZoneEditor.saveFunc;
	doc:SetCanvas(lite3DCanvas);
	HomeZoneEditor.curDoc = doc;
end
function HomeZoneEditor.End()
	
	
	HomeZoneEditor.ClearCanvas()
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
	HomeZoneEditor.curDoc = nil;
end
function HomeZoneEditor.Load()
	HomeZoneEditor.ClearCanvas()
	if(HomeZoneEditor.curDoc)then
		HomeZoneEditor.curDoc:Load();
	end
end
function HomeZoneEditor.Save(quiet)
	HomeZoneEditor.quietSave = quiet;
	if(HomeZoneEditor.curDoc)then
		HomeZoneEditor.curDoc:Save();
	end
end
function HomeZoneEditor.EditorConfig(lite3DCanvas)
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
	canKeyControl = false,
	canContexMenu = false,
	selectorTool = "EasySelectTool", -- "EasySelectTool" or "SelectorTool",default is "EasySelectTool"
	
	editor = "HomeZoneEditor"
}
	return config;
end
function HomeZoneEditor.SetTool(s)
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
function HomeZoneEditor.SetEntityToolParams(params)
	if(not params)then return end;
	local GlobalInventor = Map3DSystem.App.Inventor.GlobalInventor;
	local tool = GlobalInventor.Tool;
	if(tool and tool.SetEntityParams)then
		tool:SetEntityParams(params);
	end
end
function HomeZoneEditor.Show()
	local _parent = ParaUI.GetUIObject(HomeZoneEditor.name);
	if(_parent:IsValid())then
		ParaUI.Destroy(HomeZoneEditor.name);
	end
	_parent = ParaUI.CreateUIObject("container", HomeZoneEditor.name, "_lb", 20, -450, 400, 50);
	_parent.background = "";
	_parent:AttachToRoot();
	local left,top,width,height = 0,0,32,32;
	local _this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.background = "Texture/3DMapSystem/common/wrongsign.png;";
	_this.onclick = ";Map3DSystem.App.HomeZoneEditor.Delete();";
	_this.tooltip = "删除";
	_parent:AddChild(_this);
	left = left + 40;
	_this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.background = "Texture/3DMapSystem/Creator/Objects/undo.png;";
	_this.onclick = ";Map3DSystem.App.HomeZoneEditor.Undo();";
	_this.tooltip = "撤销";
	_parent:AddChild(_this);
	left = left + 40;
	_this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.background = "Texture/3DMapSystem/Creator/Objects/redo.png;";
	_this.onclick = ";Map3DSystem.App.HomeZoneEditor.Redo();";
	_this.tooltip = "重做";
	_parent:AddChild(_this);
	left = left + 40;
	_this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.background = "Texture/3DMapSystem/common/save.png;";
	_this.onclick = ";Map3DSystem.App.HomeZoneEditor.Save();";
	_this.tooltip = "保存";
	_parent:AddChild(_this);
	left = left + 40;
	_this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.background = "Texture/3DMapSystem/common/leftarrow.png;";
	_this.onclick = ";Map3DSystem.App.HomeZoneEditor.Return();";
	_this.tooltip = "离开";
	_parent:AddChild(_this);
end
function HomeZoneEditor.Return()
	_guihelper.MessageBox("是否保存？",
					function (result)
						if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.OK == result) then
							HomeZoneEditor.Save(true)	
						end
						ParaUI.Destroy(HomeZoneEditor.name);
						HomeZoneEditor.End()
						System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/AlphaWorld"});
					end,_guihelper.MessageBoxButtons.YesNo
					);	
					
	--HomeZoneEditor.Save(true);	
	--ParaUI.Destroy(HomeZoneEditor.name);
	--HomeZoneEditor.End()
	--System.App.Commands.Call("File.EnterAquariusWorld", {worldpath = "worlds/MyWorlds/AlphaWorld"});
end
function HomeZoneEditor.PushATemplate()
	local s = [[<Room><StaticValue><LiteCanvas x="255.095184" y="0.241956" z="87.986618"><Scene visible="true" IsCharacter="false" y="0" x="0" name="200922023528551-38" facing="0" homezone="" scaling="1" AssetFile="model/06props/shared/pops/muzhuang.x" z="0" ><Building3D visible="true" IsCharacter="false" y="5.9592935031105e-008" x="255.43769836426" name="200922023528551-39" facing="0" homezone="" scaling="1" AssetFile="model/01building/V3/01house/bieshu01/bieshu2.x" z="87.941543579102" />
<Building3D visible="true" IsCharacter="false" y="0.24196057021618" x="259.0305480957" name="200922023528551-40" facing="3" homezone="" scaling="1" AssetFile="model/02furniture/v3/02cabinet/1-bolihongjiuchenliegui.x" z="82.280448913574" />
<Building3D visible="true" IsCharacter="false" y="0.24195611476898" x="255.24205932617" name="200922023528551-41" facing="1.5" homezone="" scaling="1" AssetFile="model/02furniture/v3/02cabinet/1-bolihongjiuchenliegui.x" z="93.028834533691" />
</Scene></LiteCanvas></StaticValue><CustomValue><LiteCanvas x="255.095184" y="0.241956" z="87.986618"><Scene visible="true" IsCharacter="false" y="0" x="0" name="200922023540316-50" facing="0" homezone="" scaling="1" AssetFile="model/06props/shared/pops/muzhuang.x" z="0" ><Building3D visible="true" IsCharacter="false" y="0.24195399880409" x="252.87237548828" name="200922023540316-51" facing="0" homezone="" scaling="1" AssetFile="model/02furniture/v3/03sofa/1-sofa.x" z="90.401039123535" />
<Building3D visible="true" IsCharacter="false" y="0.24195401370525" x="251.72840881348" name="200922023540332-52" facing="0" homezone="" scaling="1" AssetFile="model/02furniture/v3/01bed/1-bed.x" z="85.21159362793" />
<Building3D visible="true" IsCharacter="false" y="0.24195364117622" x="252.37295532227" name="200922023540332-53" facing="0" homezone="" scaling="1" AssetFile="model/02furniture/v3/04electron/1-fengshan.x" z="87.691444396973" />
<Flower visible="true" IsCharacter="false" y="0.24195842444897" x="256.02496337891" name="200922685617453-95" facing="0" homezone="" scaling="1" AssetFile="model/05plants/01flower/01flower/flower_test.x" z="86.470809936523" />
</Scene></LiteCanvas></CustomValue></Room>]]
	local profile = {};
	profile.data = s;
	Map3DSystem.App.HomeZone.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				_guihelper.MessageBox("Push成功！");
			else
				_guihelper.MessageBox("Push失败！");
			end	
		end)
end