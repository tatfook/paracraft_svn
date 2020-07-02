--[[
Title: object texture property page code behind file
Author(s): LiXizhi
Date: 2008/6/15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ObjTexPropertyPage.lua");
Map3DSystem.App.Creator.ObjTexPropertyPage.UpdatePanelUI()
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

local ObjTexPropertyPage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjTexPropertyPage", ObjTexPropertyPage)

-- NPC data source. 
local dsTex = {
	{Title="我要学会说话", Icon="Texture/3DMapSystem/AppIcons/chat_64.dds", SubTitle="学讲话, 真人配音"},
}

-- data source function for official app. 
function ObjTexPropertyPage.DS_Func_Tex(index)
	if(dsTex) then
		if(index==nil) then
			return #dsTex;
		else
			return dsTex[index];
		end
	end
end

-- update UI
function ObjTexPropertyPage.UpdatePanelUI()
	local obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	
	local painter = ParaUI.GetUIObject("map3d_p_m_painter");
	if(painter:IsValid()) then
		if(obj==nil or not obj:IsValid() or obj:IsCharacter()) then
			painter.background="";
		else
			-- get replaceable texture at ID=1
			local curBG = obj:GetReplaceableTexture(1); 
			if(curBG:IsValid()) then
				painter.background=curBG:GetKeyName();
			else
				painter.background="";
			end
		end
	end
end

-- init 
function ObjTexPropertyPage.OnInit()
end

-- close panel
function ObjTexPropertyPage.OnClose()
	local command = Map3DSystem.App.Commands.GetCommand("Creation.ObjTexProperty");
	if(command) then
		command:Call({bShow=false});
	end
end

-- user clicks the NPC template. 
function ObjTexPropertyPage.OnClickTexTemplate(index)
	local tex = dsTex(index);
end

-- user changes the file url. 
function ObjTexPropertyPage.OnChangeFileUrl(sCtrlName, filename)
	if(filename and filename~="") then
		ObjTexPropertyPage.OnOpenFileForModelTexture_imp(sCtrlName, filename)
	else
		document:GetPageCtrl():SetUIValue("result", "文件不能为空");
	end	
end

-- open file for model texture 
function ObjTexPropertyPage.OnOpenFileForModelTexture()
	local obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		return
	end
	local initialFileName;
	if(not obj:GetDefaultReplaceableTexture(1):equals(curBG)) then
		initialFileName = curBG:GetKeyName();
	else	
		initialFileName = "";
	end
	
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-250,
		width = 512,
		height = 380,
		parent = nil,
		FileName = initialFileName,
		FileNamePassFilter = "http://.*", -- allow http texture, is it too dangerous here?
		fileextensions = L:GetTable("open file dialog: texture file extensions"),
		folderlinks = {
			{path = ParaWorld.GetWorldDirectory().."texture/", text = L"My work"},
			{path = L"Shared Media Folder", text = L"Media lib"},
			{path = L"Advertisement Folder", text = L"Advertisement"},
			{path = L"Internet Folder", text = L"Internet"},
			{path = "character/", text = "character"},
			{path = "model/", text = "model"},
			{path = "texture/", text = "texture"},
		},
		onopen = ObjTexPropertyPage.OnOpenFileForModelTexture_imp,
	};
	ctl:Show(true);
end

function ObjTexPropertyPage.OnOpenFileForModelTexture_imp(sCtrlName, filename)
	local obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==false) then
		return
	end
	
	if(filename == "") then
		-- reset texture
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(not defaultBG:equals(curBG)) then
			obj:SetReplaceableTexture(1, defaultBG);
			ObjTexPropertyPage.UpdatePanelUI();
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
			if(document) then document:GetPageCtrl():SetUIValue("result", "成功更改"); end
		end
	else
		-- apply the texture
		local Texture = ParaAsset.LoadTexture("",filename,1);
		if(Texture:IsValid() and not Texture:equals(curBG)) then
			obj:SetReplaceableTexture(1, Texture);
			ObjTexPropertyPage.UpdatePanelUI();
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
			if(document) then document:GetPageCtrl():SetUIValue("result", "成功更改"); end
		end
	end
end

-- use web page texture
function ObjTexPropertyPage.OnClickNavTo()
	local url = document:GetPageCtrl():GetUIValue("weburl");
	if(string.match(url, "^http://%w+")) then
		local obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
		
		if(obj ~= nil and obj:IsValid()) then
			local Texture = ParaAsset.LoadTexture("", "<html>1#"..url, 1);
			if(Texture:IsValid()) then
				obj:SetReplaceableTexture(1, Texture);
				document:GetPageCtrl():SetUIValue("result", "成功更改");
			end
		else
			document:GetPageCtrl():SetUIValue("result", "没有找到物体");	
		end
	else
		document:GetPageCtrl():SetUIValue("result", "URL地址格式不正确");
	end	
end

-- force using the default replaceable texture for the given model.
function ObjTexPropertyPage.OnUndoModelTexture()
	local obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(not defaultBG:equals(curBG)) then
			obj:SetReplaceableTexture(1, defaultBG);
			ObjTexPropertyPage.UpdatePanelUI()
			local x,y,z = obj:GetPosition();
			ParaTerrain.SetContentModified(x,z, true);
			-- TODO: delete unused textures.
			--_guihelper.MessageBox(string.format(L"Do you want to delete old drawing at \n%s?", curBG:GetKeyName()), string.format([[ParaIO.DeleteFile("%s");]], curBG:GetKeyName()));
		end
	end
end

-- let the user painter by himself. 
function ObjTexPropertyPage.OnEditModelTexture()
	local obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == true) then
		return
	end
	-- this is just a quick way to use external editor for replaceable textures
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local ext = ParaIO.GetFileExtension(curBG:GetKeyName());
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		if(defaultBG:equals(curBG) or (ext~="jpg" and  ext~="dds" and ext~="png")) then
			ObjTexPropertyPage.InvokeTextureEditor(defaultBG:GetKeyName(), obj, 1);
		else
			-- invoke editor
			ObjTexPropertyPage.InvokeTextureEditor(curBG:GetKeyName(), obj, 1);
		end
	end
end

ObjTexPropertyPage.CurrentPainterObject = nil;
function ObjTexPropertyPage.InvokeTextureEditor(texturename, obj, nReplaceableTexID)
	-- LiXizhi. 2008.1.28, edited to support app painter. 
	NPL.load("(gl)script/kids/3DMapSystemUI/Painter/PainterManager.lua");
	-- end the previous one
	ObjTexPropertyPage.OnEndEditingTexture();
	
	ObjTexPropertyPage.CurrentPainterObject = obj;
	Map3DSystem.UI.PainterManager.nReplaceableTexID = nReplaceableTexID;
	
	Map3DSystem.App.Commands.Call("File.Painter", {
		imagesize = 256,
		OnCloseCallBack = ObjTexPropertyPage.OnEndEditingTexture,
		OnSaveCallBack = ObjTexPropertyPage.OnSaveUserDrawing,
		LoadFromTexture = texturename,
	});
	
	if(not nReplaceableTexID) then nReplaceableTexID = 1 end
	if(obj~=nil and obj:IsValid()) then
		local rendertarget = Map3DSystem.UI.PainterManager.GetRenderTarget();
		if(rendertarget~=nil) then
			obj:SetReplaceableTexture(1, rendertarget);
		end
	end	
end

-- when the user saves an owner draw image
function ObjTexPropertyPage.OnEndEditingTexture()
	local obj = ObjTexPropertyPage.CurrentPainterObject;
	if(obj==nil or obj:IsCharacter() == true) then
		return
	end
	local nReplaceableTexID = Map3DSystem.UI.PainterManager.nReplaceableTexID;
	if(not nReplaceableTexID) then nReplaceableTexID = 1 end
	if(obj~=nil and obj:IsValid()) then
		local diskTexture = Map3DSystem.UI.PainterManager.GetDiskTexture();
		if(diskTexture~=nil) then
			obj:SetReplaceableTexture(1, diskTexture);
		end
	end	
	ObjTexPropertyPage.CurrentPainterObject = nil;
end

-- when the user saves an owner draw image
function ObjTexPropertyPage.OnSaveUserDrawing()
	local obj = ObjTexPropertyPage.CurrentPainterObject;
	if(obj==nil or obj:IsCharacter() == true) then
		return
	end
	local curBG = obj:GetReplaceableTexture(1); 
	if(curBG:IsValid()==true) then
		local PainterImageFileName = Map3DSystem.UI.PainterManager.GetDiskTextureFileName();
		local ext = ParaIO.GetFileExtension(PainterImageFileName);
		local defaultBG = obj:GetDefaultReplaceableTexture(1); 
		
		-- if the current image is not inside the world texture file directory or the current image is not a 
		if(ParaIO.GetParentDirectoryFromPath(PainterImageFileName, 0) ~= ParaIO.GetParentDirectoryFromPath(ParaWorld.GetWorldDirectory().."texture/",0) or (ext~="jpg" and  ext~="dds" and ext~="png")) then
			-- create a new texture at the [worlddir]/texture/[default_texture_name]_[unique_number].dds
			-- add a random name
			local nameTmp = ParaIO.GetFileName(defaultBG:GetKeyName());
			local len = string.len(nameTmp);
			local newTexName = ParaWorld.GetWorldDirectory().."texture/"..string.sub(nameTmp, 1, len-4)..ParaGlobal.GenerateUniqueID()..string.sub(nameTmp, len-3, -1);
			if(ParaIO.CreateDirectory(newTexName)) then
				-- save the new texture to file
				Map3DSystem.UI.PainterManager.SaveAs(newTexName);
				local tex = ParaAsset.LoadTexture("", newTexName, 1);
				if(tex:IsValid()) then
					obj:SetReplaceableTexture(1, tex);
					ObjTexPropertyPage.UpdatePanelUI(obj);
					local x,y,z = obj:GetPosition();
					ParaTerrain.SetContentModified(x,z, true);
				end	
			end
		else
			-- the old file is under the world texture directory, hence we will just overwrite.
			local newTexName = PainterImageFileName;
			Map3DSystem.UI.PainterManager.SaveAs(newTexName );
		end
	end		
end

function ObjTexPropertyPage.OnLogObject()
	local objParam = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	commonlib.echo(objParam);
end

function ObjTexPropertyPage.OnChangeModelAsset()
	local _obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(_obj ~= nil and _obj:IsValid())then
		local newasset = document:GetPageCtrl():GetUIValue("newasset");
		if(newasset) then
			commonlib.ResetModelAsset(_obj, newasset)
		end
	end	
end