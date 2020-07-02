--[[
Title: Objects Add page
Author(s): LiXizhi
Date: 2009/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectAddPage.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/SeniorEditor.lua");
local ObjectAddPage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjectAddPage", ObjectAddPage)

-- singleton page instance. 
local page;

-- called to init page
function ObjectAddPage.OnInit()
	page = document:GetPageCtrl();
	
	-- Map3DSystem.App.Inventor.SeniorEditor.SetTool("EntityTool")
end

------------------------
-- page events
------------------------

function ObjectAddPage.OnClose()
end

function ObjectAddPage.OnRefresh()
	page:Refresh(0.01);
end

-- user selects a new folder
function ObjectAddPage.OnSelectFolder(name, folderPath)
	local filebrowserCtl = document:GetPageCtrl():FindControl("FileBrowser");
	if(filebrowserCtl and folderPath) then
		filebrowserCtl:ChangeFolder(folderPath);
	end
end

-- navigate to parent folder
function ObjectAddPage.OnToParentFolder()
	local filebrowserCtl = document:GetPageCtrl():FindControl("FileBrowser");
	if(filebrowserCtl) then
		filebrowserCtl:ToParentFolder();
	end
end

function ObjectAddPage.OnOpenInWinExplorer()
	local filebrowserCtl = document:GetPageCtrl():FindControl("FileBrowser");
	if(filebrowserCtl) then
		local filename = filebrowserCtl:GetCurrentFolder();
		Map3DSystem.App.Commands.Call("File.WinExplorer", {filepath=filename, silentmode=true});
	end
end

-- Lazy loading icons: let us set the icon file if not before
function ObjectAddPage.OnPreRenderNode(name,treeNode, filepath)
	if(not treeNode.Icon) then
		local iconFile = filepath..".png";
		if(ParaIO.DoesFileExist(iconFile, true)) then
			treeNode.Icon = iconFile;
		end
	end
end

-- user click the object
function ObjectAddPage.OnClickObject(name, filepath)
	-- if folder, return
	if(not string.find(filepath, "%.(%w+)$")) then
		return;	
	end
	
	-- check for relative path texture or xmodel file reference
	if(ParaIO.DoesFileExist(filepath)) then
		local file = ParaIO.open(filepath, "r");
		if(file:IsValid() == true) then
			-- read a line 
			local line = file:readline();
			while(line) do
				if(string.find(line, ":")) then
					local file = string.match(line, [["(.-)"]]);
					if(file) then
						_guihelper.MessageBox("文件:"..filepath.."<br/>含有绝对路径引用:"..file);
					end
					break;
				end
				line = file:readline();
			end
			file:close();
		end
	end
		
	if(mouse_button=="left") then
		ObjectAddPage.CreateObjectToScene(filepath)
	elseif(mouse_button=="right") then
		-- auto copy to clipboard
		ParaMisc.CopyTextToClipboard(filepath);
		-- display object inspector page to generate thumbnail icon, etc.  
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Creator/Objects/ObjectInspectorPage.html",
			name="ObjectInspectorPage", 
			text = "查看物品",
			directPosition = true,
				align = "_ct",
				x = -140/2,
				y = -300/2,
				width = 140,
				height = 300,
		});
		Map3DSystem.App.Creator.ObjectInspectorPage.SetModel(filepath);
	end	
end

-------------------------------
-- private functions:
-------------------------------

-- create object automatically by filepath
function ObjectAddPage.CreateObjectToScene(filepath)
	local _,_, ext = string.find(filepath, "%.(%w+)$");
	if(ext ~= nil) then
		ext = string.lower(ext);
	else
		return;	
	end
	if(ext == "x" or ext == "xml") then
		-- refresh the file. 
		local asset = Map3DSystem.App.Assets.asset:new({filename = filepath})
		
		local objParams = asset:getModelParams()
		if(objParams~=nil) then
			-- create object by sending a message
			--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=objParams});
			
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CopyObject, obj_params = objParams});
			--Map3DSystem.App.Inventor.SeniorEditor.SetEntityToolParams(objParams);
		end
	end
end