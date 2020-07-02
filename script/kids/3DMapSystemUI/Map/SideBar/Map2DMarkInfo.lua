--[[
Title: markInfo, folderInfo and mapInfo struct definition 
Author(s): LiXizhi, Leio zhang, refactored by LiXizhi 2008.2.11
Date: 2008/1/25
---------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/Map2DMarkInfo.lua");
---------------------------------------------------
--]]

------------------------------------
-- mark info
------------------------------------
-- mark type
Map3DApp.MarkType = {
	player = 1,
	event = 2,
	city = 3,
	ad = 4,
}

-- enumeration: button styles. 
Map3DApp.mark_styles={
	-- cursor_x, cursor_y is the cursor offset. 
	{icon = "Texture/3DMapSystem/common/Flag_red.png", cursor_x = 2, cursor_y = 17},
	{icon = "Texture/3DMapSystem/common/city.png", cursor_x = 8, cursor_y = 17},
	{icon = "Texture/3DMapSystem/common/Flag_green.png", cursor_x = 8, cursor_y = 17},
};

-- enumeration: text styles. 
Map3DApp.mark_text_styles={
	{color = "0 0 0", scale=nil, background = "Texture/alphadot.png"},
	{color = "0 0 0", scale=1.2, background = "Texture/alphadot.png"},
	{color = "0 0 0", scale=0.9, background = "Texture/alphadot.png"},
	{color = "0 0 0", scale=1.3, background = "Texture/alphadot.png"},
};
	
local markInfo = {
	markID = nil,
	markType = 0,
	-- int, mark model or icon type: see MarkButton.button_style
	markStyle = 1,
	-- text style: see MarkButton.text_style
		bShowText = true,
		textColor = "0 0 0",
		textScale = 1,
		textRot = 0,
	markTitle = "未命名",
	markDesc = "",
	startTime = "",
	endTime = "",
	x = 0,
	y = 0,
	cityName = "",
	rank = 0,
	logo = "",
	signature = "",
	desc = "",
	ageGroup = 0,
	URL = "",
	isApproved = false,
	version = "",
	ownerUserID = "",
	clickCnt = 0,
	worldid = -1,
	allowEdit = false,
	z = 0,
}

Map3DApp.markInfo = markInfo;

function markInfo:new(o)
	o = o or {};
	if(o.markID == nil) then
		o.markID = ParaGlobal.GenerateUniqueID();
	end
	setmetatable(o,self);
	self.__index = self;
	return o;
end

-- get the icon
function markInfo:GetIcon()
	local style = Map3DApp.mark_styles[self.markStyle]
	if(style) then
		return style.icon;
	end	
end

-- get cursor point pixel position in the icon image. 
-- @return: defaults to 0,0
function markInfo:GetCursorPt()
	local style = Map3DApp.mark_styles[self.markStyle]
	if(style) then
		return style.cursor_x, style.cursor_y;
	else
		return 0,0;
	end	
end

------------------------------
-- folder info
------------------------------
local folderInfo = {
	ID=nil,
	title="常用标记",
	desc="",
}
Map3DApp.folderInfo = folderInfo;

function folderInfo:new(o)
	o = o or {};
	if(o.ID == nil) then
		o.ID = ParaGlobal.GenerateUniqueID();
	end
	setmetatable(o,self);
	self.__index = self;
	return o;
end

-- add a new mark 
-- @param mark: if nil a new mark will be created. 
-- @return: return the mark added
function folderInfo:AddMark(mark)
	self.list = self.list or {};
	mark = markInfo:new(mark);
	table.insert(self.list, mark);
	return mark;
end

-- remove mark by ID
function folderInfo:RemoveMark(markID)
	if(self.list) then
		local i, mark
		for i, mark in ipairs(self.list) do
			if(mark.markID == markID) then
				commonlib.removeArrayItem(self.list, i)
				break;
			end	
		end
	end	
end

------------------------------
-- map info
------------------------------
local mapInfo = {
	-- owner id or nil if local.
	userid = nil, 
}
Map3DApp.mapInfo = mapInfo;

function mapInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

-- add folder from the map
-- @param folder: if nil a new folder will be created. 
-- @return: return the folder added
function mapInfo:AddFolder(folder)
	folder = folderInfo:new(folder);
	table.insert(self,folder);
	return folder;
end

-- remove folder from the map
function mapInfo:RemoveFolder(ID)
	local i, folder
	for i, folder in ipairs(self) do
		if(folder.ID == ID) then
			commonlib.removeArrayItem(self, i)
			break;
		end	
	end
end