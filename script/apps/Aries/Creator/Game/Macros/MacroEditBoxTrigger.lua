--[[
Title: Macro EditBox Trigger
Author(s): LiXizhi
Date: 2021/1/13
Desc: 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

-- @param text: like "a" or "Z"
-- @return string like "DIK_A" "shift+DIK_Z"
function Macros.TextToKeyName(text)
	local keyname;
	if(text and #text == 1) then
		if(text:match("^[a-z]")) then
			keyname = "DIK_"..text:upper();
		elseif(text:match("^[A-Z]")) then
			keyname = "shift+DIK_"..text;
		elseif(text:match("^%d")) then
			keyname = "DIK_"..text;
		elseif(text == "_") then
			keyname = "shift+DIK_MINUS"
		elseif(text == "/") then
			keyname = "shift+DIK_SLASH"
		elseif(text == ",") then
			keyname = "DIK_COMMA"
		elseif(text == ".") then	
			keyname = "DIK_PERIOD"
		elseif(text == " ") then	
			keyname = "DIK_SPACE"
		end
		-- TODO: add more supported keys?
	end
	return keyname
end

--@param uiName: UI name
--@param text: content text
function Macros.EditBoxTrigger(uiName, text)
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		local x, y, width, height = obj:GetAbsPosition();
		local mouseX = math.floor(x + width /2)
		local mouseY = math.floor(y + height /2)
		obj:SetCaretPosition(-1);
		obj:Focus()
		local textDiff = Macros:UpdateEditBoxTextDiff(uiName, text);
		
		local callback = {};
		MacroPlayer.SetEditBoxTrigger(mouseX, mouseY, text, textDiff, function()
			if(callback.OnFinish) then
				callback.OnFinish();
			end
		end);
		return callback;
	end
end





