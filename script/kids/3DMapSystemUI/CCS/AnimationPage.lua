--[[
Title: code behind of character animation page
Author(s): LiXizhi
Date: 2008.6.13
Desc:play universal animation file. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AnimationPage.lua");
Map3DSystem.App.CCS.AnimationPage.PlayAnimByIndex(index)
Map3DSystem.App.CCS.AnimationPage.PlayAnimFile(filepath)
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/Encoding.lua");

-- create class
local AnimationPage = {};
commonlib.setfield("Map3DSystem.App.CCS.AnimationPage",  AnimationPage);

-- skybox db table
AnimationPage.CommonAnims = {
	{text="鼓掌", file = "character/Animation/v3/鼓掌.x", bg = "character/Animation/v3/鼓掌.x.png"},
	{text="再见", file = "character/Animation/v3/再见.x", bg = "character/Animation/v3/再见.x.png"},
	{text="讨论", file = "character/Animation/v3/讨论.x", bg = "character/Animation/v3/讨论.x.png"},
	{text="紧张", file = "character/Animation/v3/紧张.x", bg = "character/Animation/v3/紧张.x.png"},
	{text="欢迎", file = "character/Animation/v3/欢迎.x", bg = "character/Animation/v3/欢迎.x.png"},
	{text="欢呼", file = "character/Animation/v3/欢呼.x", bg = "character/Animation/v3/欢呼.x.png"},
	{text="愤怒", file = "character/Animation/v3/愤怒.x", bg = "character/Animation/v3/愤怒.x.png"},
	{text="哭泣", file = "character/Animation/v3/哭泣.x", bg = "character/Animation/v3/哭泣.x.png"},
	{text="垂头丧气", file = "character/Animation/v3/垂头丧气.x", bg = "character/Animation/v3/垂头丧气.x.png"},
	{text="不可一世", file = "character/Animation/v3/不可一世.x", bg = "character/Animation/v3/不可一世.x.png"},
	{text="点头", file = "character/Animation/v3/很兴奋的点头.x", bg = "character/Animation/v3/很兴奋的点头.x.png"},
	{text="失望", file = "character/Animation/v3/很失望的摇头.x", bg = "character/Animation/v3/很失望的摇头.x.png"},
};

local function DoEncoding()
	local _, t;
	for _,t in ipairs(AnimationPage.CommonAnims) do
		t.file = commonlib.Encoding.Utf8ToDefault(t.file)
		t.bg = commonlib.Encoding.Utf8ToDefault(t.bg)
	end
end
DoEncoding();

-- datasource function for pe:gridview
function AnimationPage.DS_Anims_Func(index)
	if(index == nil) then
		return #(AnimationPage.CommonAnims);
	else
		return AnimationPage.CommonAnims[index];
	end
end

-- init
function AnimationPage.OnInit()
	local self = document:GetPageCtrl();

	local anims = Map3DSystem.App.CCS.app:ReadConfig("RecentlyOpenedAnims", {})
	local index, value
	for index, value in ipairs(anims) do
		self:SetNodeValue("filepath", commonlib.Encoding.DefaultToUtf8(value));
	end
	self:SetNodeValue("filepath", "");
end

-------------------------
-- common anim tab
-------------------------

-- clicks the common animation file
-- @return: true if played. 
function AnimationPage.PlayAnimFile(filepath)
	if(filepath == nil or filepath == "") then
		_guihelper.MessageBox("请选择一个文件");
	elseif(not ParaIO.DoesFileExist(filepath, true)) then
		_guihelper.MessageBox(string.format("文件 %s 不存在", filepath));
	else
		Map3DSystem.Animation.PlayAnimationFile(filepath, ParaScene.GetPlayer());		
		return true;
	end	
end

-- clicks the common animation file by its index
-- @param index: [1,9]. upper limit is the size of AnimationPage.CommonAnims
-- @return: true if played. 
function AnimationPage.PlayAnimByIndex(index)
	local fileinfo = AnimationPage.CommonAnims[index]
	if(fileinfo) then
		Map3DSystem.Animation.PlayAnimationFile(fileinfo.file, ParaScene.GetPlayer());
	end
end

-------------------------
-- from file tab
-------------------------
-- User clicks a file
function AnimationPage.OnSelectFolder(name, folderPath)
	local filebrowserCtl = document:GetPageCtrl():FindControl("AnimFileBrowser");
	if(filebrowserCtl and folderPath) then
		filebrowserCtl.rootfolder = folderPath;
		filebrowserCtl:ResetTreeView();
	end
end

-- User clicks a file
function AnimationPage.OnSelectAnimFile(name, filepath)
	local old_path = commonlib.Encoding.Utf8ToDefault(document:GetPageCtrl():GetUIValue("filepath"));
	if(old_path ~= filepath) then
		document:GetPageCtrl():SetUIValue("filepath", commonlib.Encoding.DefaultToUtf8(filepath));
	end	
end

-- user double clicks a file, it will select it and add it to scene. 
function AnimationPage.OnDoubleClickAnimFile(name, filepath)
	AnimationPage.OnClickPlayAnimFile(filepath);
end

-- play animation file. 
function AnimationPage.OnClickPlayAnimFile()
	local filepath = commonlib.Encoding.Utf8ToDefault( document:GetPageCtrl():GetUIValue("filepath") or "");
	if(AnimationPage.PlayAnimFile(filepath)) then
		AnimationPage.SaveOpenAnimFileRecord(filepath);
	end
end

-- save open world record, so that next time the page is shown, users can open recent world files. 
-- @param filepath: world path 
function AnimationPage.SaveOpenAnimFileRecord(filepath)
	-- save to recently opened anims
	local anims = Map3DSystem.App.CCS.app:ReadConfig("RecentlyOpenedAnims", {})
	local bNeedSave;
	-- sort by order
	local index, value, found
	for index, value in ipairs(anims) do
		if(value == filepath) then
			if(index>1) then
				commonlib.moveArrayItem(anims, index, 1)
				bNeedSave = true;
			end	
			found = true;
			break;
		end
	end
	if(not found) then
		commonlib.insertArrayItem(anims, 1, filepath)
		bNeedSave = true;
	end
	if(bNeedSave) then
		if(#anims>50) then
			commonlib.resize(anims, 50)
		end
		Map3DSystem.App.CCS.app:WriteConfig("RecentlyOpenedAnims", anims)
		Map3DSystem.App.CCS.app:SaveConfig();
	end
end