--[[
Title: Switching editor mode, so that the scene events and hooks do not conflict with one another
Author(s): LiXizhi
Date: 2009/1/29
Desc: This is not an ideal solution. However, currently the desktop is shared by too many applications. 
And that the object editors are sub applications. So we have to do this manually. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/SwitchObjectEditorMode.lua");
Map3DSystem.App.Creator.SwitchObjectEditorMode("TerraFormPage");
------------------------------------------------------------
]]

local editors = {
	{name="ObjectSelectPage", funcName="EndEditing"},
	{name="ObjectAddPage", funcName="EndEditing"},
}
-- stop all other editor mode off except for editorName
-- @param editorName: it can be "ObjectSelectPage" or "ObjectAddPage". If nil or unknown, all editors will be closed. 
local function SwitchObjectEditorMode(editorName)
	local _, editor;
	for _, editor in ipairs(editors) do
		if(editor.name ~= editorName) then
			local func = commonlib.getfield(string.format("Map3DSystem.App.Creator.%s.%s", editor.name, editor.funcName));
			if(type(func) == "function") then
				func();
			end
		end
	end
end
commonlib.setfield("Map3DSystem.App.Creator.SwitchObjectEditorMode", SwitchObjectEditorMode);
