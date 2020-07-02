--[[
Title: the main file for ParaEngine 3D environment development library
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/3Ddev/3DDevLib.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");

-- _3Ddev is reserved for 3D dev lib
if(not _3Ddev) then _3Ddev = {};end
-- name of the 3D virtual world
_3Ddev.name = "demo world"
-- the world config file, scene objects will be added to the world specified by this file.
_3Ddev.worldfile = "sample/worldconfig.txt";
-- list of ParaObjects that can be edited in the current scene.
_3Ddev.objects = {};
-- The current ParaObject that is being selected.
_3Ddev.currentObj = nil;
-- assets in categories
_3Ddev.assets={};

NPL.load("(gl)script/3Ddev/AssetLib.lua");
_3Ddev.LoadDefaultAsset();

--[[ Get a named object in the scene
@param sName: string: the name of the object.
@return: nil if not found; a ParaObject if found.
]]
function _3Ddev.GetObject(sName)
	return _3Ddev.objects[tostring(sName)];
end

--[[ get the current object ]]
function _3Ddev.GetCurrentObj()
	return _3Ddev.currentObj;
end

--[get the number of active objects in the scene]
function _3Ddev.GetObjectNum()
	return table.getn(_3Ddev.objects);
end
--[[ select an object by its name. if the object does not exists, 
The current selection is not changed.
@param sName: string: the name of the object.
@return: the current selected object is returned.
]]
function _3Ddev.SelectObj(sName)
	local obj = _3Ddev.GetObject(sName);
	if(obj~=nil) then
		_3Ddev.currentObj = obj;
	end
	return _3Ddev.currentObj;
end
--[[ change an object's name from sOld to sNew
@param sOld, sNew: string
]]
function _3Ddev.ReName(sOld, sNew)
	local objOld = c[sOld];
	if(objOld~=nil) then
		objOld.name = sNew;
		_3Ddev.objects[sOld] = nil;
		_3Ddev.objects[sNew] = objOld;
		log(sOld.." is renamed to "..sNew.."\n");
	end
end

--[[Remove the object from the active object list
@param object_name: string value: actor name
@return: return the object that is removed. if nil, there is no such object.
]]
function _3Ddev.RemoveObject(object_name)
	local obj = _3Ddev.objects[object_name];
	if(_3Ddev.currentObj == obj) then
		_3Ddev.currentObj = nil;
	end
	_3Ddev.objects[object_name] = nil;
	return obj;
end

--[[
create a physics object at the specifed position using a Model asset.
The newly created object will be further editable. 
@param sName: the name of the physics objects, if there is already an object
	with the same name, an error message will be returned.if it If the file name ends with _a,  such as "xxx_a.x", then 
	the mesh will by default be created without physics.
@param Model: [string|ParaAssetObject] if this is a string, then it will be treated 
as the file name of the model asset; otherwise, it will be treated like a ParaAssetObject. 
@param x,y,z: where the model will be positioned in the world coordinate system.
@return: return the object created if succeeded, otherwise return nil.
]]
function _3Ddev.CreatePhysicsObject(sName, Model, x,y,z)
	local obj = _3Ddev.GetObject(sName);
	if(obj~=nil) then
		_guihelper.MessageBox("物体"..sName.." 已经存在，请不要给物体命名，或用另一个不同的名字");
		return nil;
	end
	local obj;
	local asset;
	if(Model ~= nil) then
		if(type(Model) == "string") then
			asset = ParaAsset.LoadStaticMesh("", Model);
		else
			asset = Model;
		end
		if(asset:IsValid()==true) then
			local bUsePhysics = true;
			-- decide whether to use physics from the file name
			local sFileName = asset:GetKeyName();
			local nLen = string.len(sFileName);
			if(nLen>4 and string.sub(sFileName, nLen-3, nLen-2)=="_a") then
				bUsePhysics = false;
			end
			
			obj = ParaScene.CreateMeshPhysicsObject(sName, asset, 1,1,1, bUsePhysics, "1,0,0,0,1,0,0,0,1,0,0,0");
			if(obj:IsValid()==true) then
				obj:SetPosition(x,y,z);obj:SetFacing(0);
				ParaScene.Attach(obj);
				-- Add object to list and select it as the current object.
				_3Ddev.objects[sName] = obj;
				_3Ddev.currentObj = obj;
				log("physics object: "..sName.." created\n");
				return obj;
			else
				_guihelper.MessageBox("unable to create mesh physics object\n");
			end
		else
			if(type(Model) == "string") then
				_guihelper.MessageBox("unable to create mesh physics object\nBecause mesh file: "..Model.." not found.");
			else
				_guihelper.MessageBox("unable to create mesh physics object\nBecause mesh file is invalid");
			end
		end
	end
	return nil;
end

--[[ create mesh objects, such as grass, that does not contain physics.]]
function _3Ddev.CreateMesh(sName, Model, x,y,z)
	--TODO:
end

--[[ load file
@param filename:string: name of the file from which objects are loaded. In this version.	
	the name is always appended with "temp/" and so it is with the managed loader name in the file.
]]
function _3Ddev.load(filename_)
	local filename = "(gl)temp/"..filename_;
	NPL.load(filename);
end
--[[save scene to disk. Once saved, the object list will be emptied.
@param filename:string: name of the file to which objects are saved. In this version.	
	the name is always appended with "temp/" and so it is with the managed loader name
]]
function _3Ddev.save(filename_)
	-- "only save to temp directory to prevent overriden useful data"
	local filename = "temp/"..filename_;
	local bFileBackuped = false;
	if (ParaIO.BackupFile(filename) == true) then
		bFileBackuped = true;
	end
	if (ParaIO.CreateNewFile(filename) == false) then
		local err = "Failed creating managed loader file: "..filename.."\n";
		log(err);
		_guihelper.MessageBox(err);
		return;
	end
	-- manager loader header 
	local sScript = string.format([[local sceneLoader = ParaScene.GetObject("<managed_loader>%s");
if (sceneLoader:IsValid() == true) then 
	ParaScene.Attach(sceneLoader);
else 
   sceneLoader = ParaScene.CreateManagedLoader("%s");
   local asset,player;
]], filename, filename);
	ParaIO.WriteString(sScript);

	-- add objects
	local key, obj;
	for key, obj in pairs(_3Ddev.objects) do
		if(obj:IsValid()==true) then
			ParaIO.WriteString("--"..obj.name.."\n");
			-- create in managed Loader
			ParaIO.WriteString(obj:ToString("loader"));
		end
	end
	
	-- manager loader ending
	ParaIO.WriteString([[
	ParaScene.Attach(sceneLoader);
end]]);

	ParaIO.CloseFile();
	sScript = "场景文件: \n"..filename.." 存储成功.\n";
	if(bFileBackuped==true) then
		sScript = sScript.."旧文件备份后，已被覆盖";
	end
	_guihelper.MessageBox(sScript);
	log(sScript);
end

local function activate()
end
NPL.this(activate);


