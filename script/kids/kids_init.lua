--[[
Title: Kids Movie Init
Author(s): LiXizhi
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/kids_init.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/ui/LoadMainGameUI.lua");
NPL.load("(gl)script/ide/ParaEngineExtension.lua");
NPL.load("(gl)script/kids/UI_startup.lua");
NPL.load("(gl)script/kids/event_handlers.lua");
NPL.load("(gl)script/kids/ui/product_logo.lua");
NPL.load("(gl)script/ide/ParaEngineSettings.lua");

if(not KidsUI) then KidsUI={}; end
KidsUI.state = {}

-- TODO: put folder to seperate zip file for easy of update patching. 
-- there are some preload, hence the following file must be executed even before the scripting interface is ready.
--ParaAsset.OpenArchive ("character.zip", true);
--ParaAsset.OpenArchive ("model.zip", true);
--ParaAsset.OpenArchive ("Texture.zip", true);
--ParaAsset.OpenArchive ("terrain.zip", true);
--ParaAsset.OpenArchive ("script.zip", true);

-- clear all states
function KidsUI.ResetState()
	KidsUI.state = {}
end

-- push a state to the state queue. 
-- @param state: it can be a simple string or a custom table with name field like {name = "some state name", ...}
function KidsUI.PushState(state)
	KidsUI.state[4] = KidsUI.state[3]
	KidsUI.state[3] = KidsUI.state[2]
	KidsUI.state[2] = KidsUI.state[1]
	KidsUI.state[1] = state
	
	-- enable this line, if one wants to debug the state changes.
	--log("PushState: "..state.."\r\n");
end

-- @param state: Either nil or string. if nil, the current state is removed. otherwise it will only pop the state if the current state name is the same as the input
function KidsUI.PopState(state)
	if(not state) then
		KidsUI.state[1] = KidsUI.state[2]
		KidsUI.state[2] = KidsUI.state[3]
		KidsUI.state[3] = KidsUI.state[4]
		KidsUI.state[4] = nil
	else
		local topState = KidsUI.GetState();
		if(type(topState)=="string") then
			if(topState == state) then
				KidsUI.PopState();
			end
		elseif(type(topState)=="table") then
			if(topState.name==state) then
				KidsUI.PopState();
			end
		end	
	end	
end

-- if index is nil or 1, the current state is returned, otherwise, the state at the given index is returned.
function KidsUI.GetState(index)
	if(not index) then
		return KidsUI.state[1]
	else
		return KidsUI.state[index]
	end	
end

--this function initialize the default appearance of the ui objects used in KidsMovie
-- make sure this function is called, before any UI is created. 
function KidsUI.LoadDefaultKidsUITheme()
	
	-- how to deal with hit point
	ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",0,8);
	local _this;
	_this=ParaUI.GetDefaultObject("scrollbar");
	local states={[1]="highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};
	local i;
	for i=1, 4 do
		_this:SetCurrentState(states[i]);
		texture=_this:GetTexture("track");
		texture.texture="Texture/kidui/common/scroll_track.png";
		texture=_this:GetTexture("up_left");
		texture.texture="Texture/kidui/common/scroll_upleft.png";
		texture=_this:GetTexture("down_right");
		texture.texture="Texture/kidui/common/scroll_downright.png";
		texture=_this:GetTexture("thumb");
		texture.texture="Texture/kidui/common/scroll_thumb.png";
	end

	_this=ParaUI.GetDefaultObject("button");
	_this.background="Texture/kidui/common/btn_bg.png";

	_this=ParaUI.GetDefaultObject("container");
	_this.background="Texture/kidui/common/container_bg.png";

	_this=ParaUI.GetDefaultObject("editbox");
	_this.background="Texture/kidui/common/editbox_bg.png";
end