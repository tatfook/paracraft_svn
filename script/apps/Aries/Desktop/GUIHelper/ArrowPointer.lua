--[[
Title: Arrow pointer to 8 directions
Author(s): WangTian
Date: 2009/8/21
See Also: script/apps/Aries/Desktop/GUIHelper/ArrowPointer.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/ArrowPointer.lua");
MyCompany.Aries.Desktop.GUIHelper.ArrowPointer.Init();
------------------------------------------------------------
]]

-- create class
local libName = "GUIHelper_ArrowPointer";
local ArrowPointer = commonlib.gettable("MyCompany.Aries.Desktop.GUIHelper.ArrowPointer");

local base_bg = "Texture/Aries/Desktop/ArrowHelper/Arrow%DIR%_32bits.png";
local backgrounds = {
	[7] = "Texture/Aries/Desktop/ArrowHelper/Arrow7_32bits.png",
	[8] = "Texture/Aries/Desktop/ArrowHelper/Arrow8_32bits.png",
	[9] = "Texture/Aries/Desktop/ArrowHelper/Arrow9_32bits.png",
	[4] = "Texture/Aries/Desktop/ArrowHelper/Arrow4_32bits.png",
	[6] = "Texture/Aries/Desktop/ArrowHelper/Arrow6_32bits.png",
	[1] = "Texture/Aries/Desktop/ArrowHelper/Arrow1_32bits.png",
	[2] = "Texture/Aries/Desktop/ArrowHelper/Arrow2_32bits.png",
	[3] = "Texture/Aries/Desktop/ArrowHelper/Arrow3_32bits.png",
};
-- invoked at Desktop.InitDesktop()
function ArrowPointer.Init()
	-- load the basic animation file
    local fileName = "script/UIAnimation/CommonBounce.lua.table";
    UIAnimManager.LoadUIAnimationFile(fileName);

	if(System.options.version == "teen") then
		base_bg = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow%DIR%_32bits.png";
		backgrounds = {
			[7] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow7_32bits.png",
			[8] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow8_32bits.png",
			[9] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow9_32bits.png",
			[4] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow4_32bits.png",
			[6] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow6_32bits.png",
			[1] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow1_32bits.png",
			[2] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow2_32bits.png",
			[3] = "Texture/Aries/Desktop/ArrowHelper/Teen/Arrow3_32bits.png",
		};
	end
end

ArrowPointer.arrow_ids = {};

-- show the arrow in specific position
-- @param id: id of the arrow
-- @param direction: pointer direction, using the num pad as the direction
--					7 8 9     ¡ü
--					4   6   ¡û   ¡ú
--					1 2 3     ¡ý
-- @param bAnim: false for static animation, true for arrow with animation
-- @param align: alignment of the arrow ui object
-- @param left, top, width, height: position of the object according to CreateUIObject
-- @param background(optional): if nil use the default background
-- @param OnCreateCallback: this function will be called when a new arrow pointer is first created. One can use it to create additional content. 
function ArrowPointer.ShowArrow(id, direction, align, left, top, width, height, background, _parent, OnCreateCallback, fileName)
    fileName = fileName or "script/UIAnimation/CommonBounce.lua.table";
	local arrow_name = "ArrowPointer_"..id;
	local bInserted = false;
	local _, i;
	for _, i in ipairs(ArrowPointer.arrow_ids) do
		if(i == id) then
			bInserted = true;
			break;
		end
	end
	if(bInserted == false) then
		-- record all arrow ids
		table.insert(ArrowPointer.arrow_ids, id);
	end
	local _arrow = ParaUI.GetUIObject(arrow_name);
	if(_arrow and _arrow:IsValid() == true) then
		ParaUI.Destroy(arrow_name);
	end
	_arrow = ParaUI.CreateUIObject("container", arrow_name, align, left, top, width, height);
	_arrow.background = background or backgrounds[direction];
	_arrow.enabled = false;
	_arrow.zorder = 101;
	
	if(_parent and _parent:IsValid() == true) then
		_parent:AddChild(_arrow);
	else
		_arrow:AttachToRoot();
	end
	if(OnCreateCallback) then
		OnCreateCallback(_arrow, id);
	end
	UIAnimManager.PlayUIAnimationSequence(_arrow, fileName, tostring(direction), true);
end

-- whether a given arrow is shown
function ArrowPointer.IsArrowShown(id)	
	local arrow_name = "ArrowPointer_"..id;
	local _arrow = ParaUI.GetUIObject(arrow_name);
	if(_arrow:IsValid()) then
		return true;
	end
end

function ArrowPointer.RemoveArrow(id)
	local arrow_name = "ArrowPointer_"..id;
	local _arrow = ParaUI.GetUIObject(arrow_name);
	if(_arrow and _arrow:IsValid() == true) then
		_arrow.visible = false;
		UIAnimManager.StopLoopingUIAnimationSequence(_arrow, nil, nil, true);
		ParaUI.Destroy(arrow_name)
	end
end

-- hide the arrow
-- @param id: id of the arrow
function ArrowPointer.HideArrow(id)
	local arrow_name = "ArrowPointer_"..id;
	local _arrow = ParaUI.GetUIObject(arrow_name);
	if(_arrow and _arrow:IsValid() == true) then
		_arrow.visible = false;
		UIAnimManager.StopLoopingUIAnimationSequence(_arrow, nil, nil, true);
	end
end

function ArrowPointer.HideAllArrows()
	local _, i;
	for _, i in ipairs(ArrowPointer.arrow_ids) do
		ArrowPointer.HideArrow(i);
	end
end