--[[
Title: Objec inspector page
Author(s): LiXizhi
Date: 2009/2/12
Desc: View a given asset such as its author, its price, polycount, etc. It also gives the option to buy or upload the asset. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectInspectorPage.lua");
-- call this to update the page
Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	url="script/kids/3DMapSystemUI/Creator/Objects/ObjectInspectorPage.html",
	name="ObjectInspectorPage", bAutoSize=true,
});
Map3DSystem.App.Creator.ObjectInspectorPage.SetModel(filepath);
------------------------------------------------------------
]]

local ObjectInspectorPage = commonlib.gettable("Map3DSystem.App.Creator.ObjectInspectorPage")

-- singleton page instance. 
local page;

-- current file path
ObjectInspectorPage.filepath = nil;

-- init
function ObjectInspectorPage.OnInit()
	page = document:GetPageCtrl();
	ObjectInspectorPage.filepath = page:GetRequestParam("filepath") or ObjectInspectorPage.filepath;
end

---------------------------------
-- page event handlers
---------------------------------
function ObjectInspectorPage:OnClose()
	page:CloseWindow();
end

function ObjectInspectorPage.OnBuy()
	--TODO: 
end

-- take a snapshot
function ObjectInspectorPage.OnTakeSnapShot()
	local filepath = ObjectInspectorPage.filepath;
	if (not filepath) then return end
	local _,_, ext = string.find(filepath, "%.(%w+)$");
	if(ext ~= nil) then
		ext = string.lower(ext);
	end
	if(ext == "x" or ext == "xml") then
		-- refresh the file. 
		local asset = Map3DSystem.App.Assets.asset:new({filename = filepath})
		
		local icon = asset:getIcon();
		-- only save for Non-http icon to disk. 
		if(icon and string.find(icon,"^http")==nil) then
			icon = string.gsub(icon, ":.*$", "")
			local ctl = page:FindControl("modelCanvas");
			if(ctl) then
				
				local function SaveToFile(filename)
					log(icon.." is saved\n")
					ctl:SaveToFile(filename, 64);
					asset.icon = filename;
					CommonCtrl.OneTimeAsset.Unload(filename);
					if(page) then
						page:SetUIValue("ThumbnailImg", filename);
					end
				end
				
				NPL.load("(gl)script/ide/SaveFileDialog.lua");
				local ctl = CommonCtrl.SaveFileDialog:new{
					name = "SaveFileDialog1",
					alignment = "_ct",
					left=-256, top=-150,
					width = 512,
					height = 380,
					parent = nil,
					show_file_buttons = false,
					-- initial file name to be displayed, usually "" 
					FileName = string.gsub(icon, ".*/", ""),
					fileextensions = {"all files(*.*)", "images(*.jpg; *.png; *.dds)", "animations(*.swf; *.wmv; *.avi)", "web pages(*.htm; *.html)", },
					folderlinks = {
						{path = string.gsub(icon, "/[^/\\]*$", ""), text = "当前"},
						{path = "worlds/", text = "worlds"},
					},
					onopen = function(ctrlName, filename)
						local dlgText;
						if(ParaIO.DoesFileExist(filename, true)) then	
							_guihelper.MessageBox(string.format("文件: %s 已经存在, 您确定要覆盖它么?", filename), function ()
								SaveToFile(filename)
							end)
						else
							SaveToFile(filename)
						end
					end
				};
				ctl:Show(true);
			end
		end	
	end
end

------------------------------------
-- public functions
------------------------------------

function ObjectInspectorPage.UpdatePageByEntity(entity)
	if(page and entity) then
		local att = entity:GetAttributeObject();
		page:SetUIValue("PolyCount", att:GetField("PolyCount", 0));
		page:SetUIValue("TextureUsage", att:GetField("TextureUsage", ""));
	end
end

-- this function can be called externally when the page is opened. 
function ObjectInspectorPage.SetModel(filepath)
	ObjectInspectorPage.filepath = filepath;
	local self = ObjectInspectorPage;
	if(not page) then return end
	
	local _,_, ext = string.find(filepath, "%.(%w+)$");
	if(ext ~= nil) then
		ext = string.lower(ext);
	end
	local IsUnknown;
	if(ext==nil or filepath == nil or filepath =="") then
		
	elseif(not ParaIO.DoesAssetFileExist(filepath, true)) then
		IsUnknown = true;
	elseif(ext == "x" or ext == "xml") then
		-- refresh the file. 
		local asset = Map3DSystem.App.Assets.asset:new({filename = filepath})
		
		-- refresh the model in modelCanvas control. 
		local objParams = asset:getModelParams()
		if(objParams~=nil) then
			local canvasCtl = page:FindControl("modelCanvas");
			if(canvasCtl) then
				canvasCtl:ShowModel(objParams);
			end
			if(objParams.AssetFile) then
				local entity;
				if(objParams.IsCharacter) then
					entity = ParaAsset.LoadParaX("", objParams.AssetFile)
				else
					entity = ParaAsset.LoadStaticMesh("", objParams.AssetFile)
				end
				if(entity:IsValid()) then
					if(entity:IsLoaded()) then
						ObjectInspectorPage.UpdatePageByEntity(entity);
					else
						NPL.load("(gl)script/ide/AssetPreloader.lua");
						self.loader = self.loader or commonlib.AssetPreloader:new({
							callbackFunc = function(nItemsLeft)
								if(nItemsLeft == 0) then
									-- NOTE: since asset object are never garbage collected, we will assume asset is still valid at this time. 
									-- However, this can not be easily assumed if I modified the game engine asset logics.
									if(self.asset_ and self.asset_:IsLoaded()) then
										ObjectInspectorPage.UpdatePageByEntity(self.asset_);
										self.asset_ = nil;
									end	
								end
							end
						});
						self.loader:clear();
						self.loader:AddAssets(entity);
						self.asset_ = entity
						self.loader:Start();
					end
					local icon = asset:getIcon();
					if(ParaIO.DoesAssetFileExist(icon)) then
						page:SetUIValue("ThumbnailImg", icon);
					end
				end
			end
		else
			IsUnknown = true;	
		end
	elseif(ext == "png" or ext == "jpg" or ext == "tga" or ext == "bmp" or ext == "dds" ) then	
		local canvasCtl = page:FindControl("modelCanvas");
		if(canvasCtl) then
			canvasCtl:ShowImage(filepath);
		end
	else
		IsUnknown = true;
	end
	
	-- unknown file format
	if(IsUnknown) then
		local canvasCtl = page:FindControl("modelCanvas");
		if(canvasCtl) then
			canvasCtl:ShowImage("");
		end	
	end	
end