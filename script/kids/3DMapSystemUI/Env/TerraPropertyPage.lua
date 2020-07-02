--[[
Title: TerraPropertyPage
Author(s): LiXizhi
Date: 2009/1/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerraPropertyPage.lua");
------------------------------------------------------------
]]

local TerraPropertyPage = {};
commonlib.setfield("Map3DSystem.App.Env.TerraPropertyPage", TerraPropertyPage)

-- singleton page instance. 
local page;

TerraPropertyPage.GlobalProperty = nil
TerraPropertyPage.TileProperty = nil

local AttributeNameTranslations = {
	["ClassID"] = "类ID",
	["ClassName"] = "类名称",
	["PrintMe"] = "打印帮助",
	-- terrain
	["IsModified"] = "是否更改了",
	["RenderTerrain"] = "是否显示地貌",
	-- terrain tile
	["IsEmpty"] = "是否为空",
	["Size"] = "大小(米)",
	["OnloadScript"] = "载入脚本",
	["height map"] = "高度图",
	["ConfigFile"] = "配置文件",
	["Base Texture"] = "基层贴图",
	["CommonTexture"] = "通用贴图",
}
-- called to init page
function TerraPropertyPage.OnInit()
	page = document:GetPageCtrl();
	
	TerraPropertyPage.GlobalProperty = {
		att=ParaTerrain.GetAttributeObject(), 
		bReadOnly=nil, 
		fieldNames=nil, 
		fieldTextReplaceables=AttributeNameTranslations,
	}
	TerraPropertyPage.TileProperty = {
		att = function ()
				local x,y,z = ParaScene.GetPlayer():GetPosition();
				local att = ParaTerrain.GetAttributeObjectAt(x,z);
				if(att~=nil and att:IsValid()) then
					return att;
				end
		end, 
		bReadOnly=nil, 
		fieldNames=nil, 
		fieldTextReplaceables=AttributeNameTranslations,
	}
	NPL.load("(gl)script/kids/3DMapSystemUI/Env/SwitchEnvEditorMode.lua");
	Map3DSystem.App.Env.SwitchEnvEditorMode();
	
	local att = TerraPropertyPage.TileProperty.att;
	if(type(att) == "function") then
		att = att();
	end
	if(att) then
		page:SetNodeValue("MainTexture", att:GetField("Base Texture", ""))
		page:SetNodeValue("DefaultTexture", att:GetField("CommonTexture", ""))
		page:SetNodeValue("TextureMaskWidth", tostring(ParaTerrain.GetAttributeObject():GetField("TextureMaskWidth", 128)))
	end	
end

------------------------
-- page events
------------------------

-- Close the page
function TerraPropertyPage.OnClose()
end

function TerraPropertyPage.OnRefresh()
	page:Refresh(0.01);
end

function TerraPropertyPage.OnChangeTextureMaskWidth(name, value)
	local nWidth = tonumber(value)
	if(nWidth) then
		ParaTerrain.GetAttributeObject():SetField("TextureMaskWidth", nWidth)
		_guihelper.MessageBox("Mask Texture Resolution of all cached terrains are now changed. One needs to save the entire world to preserve the changes.");
	end
end

function TerraPropertyPage.OnChangeMainTexture()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {"images(*.jpg; *.png; *.dds)",},
		folderlinks = {
			{path = "Texture/tileset/generic/", text = "Texture"},
			{path = "worlds/", text = "worlds"},
			{path = "Terrain/data/", text = "Terrain/data/"},
		},
		onopen = function(ctrlName, filename)
			local att = TerraPropertyPage.TileProperty.att;
			if(type(att) == "function") then
				att = att();
			end
			if(filename and att) then
				att:SetField("Base Texture", filename)
				TerraPropertyPage.OnRefresh();
				_guihelper.MessageBox("更新成功: 下次载入世界时, 贴图才会生效");
			end	
		end
	};
	ctl:Show(true);
end

function TerraPropertyPage.OnChangeDefaultTexture()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {"images(*.jpg; *.png; *.dds)",},
		folderlinks = {
			{path = "Texture/tileset/generic/", text = "Texture"},
			{path = "worlds/", text = "worlds"},
			{path = "Terrain/data/", text = "Terrain/data/"},
		},
		onopen = function(ctrlName, filename)
			local att = TerraPropertyPage.TileProperty.att;
			if(type(att) == "function") then
				att = att();
			end
			if(filename and att) then
				att:SetField("CommonTexture", filename)
				TerraPropertyPage.OnRefresh();
			end	
		end
	};
	ctl:Show(true);
end
