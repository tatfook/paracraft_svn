--[[
Title: Macro EditBox
Author(s): LiXizhi
Date: 2021/1/13
Desc: 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")


--@param uiName: UI name
--@param text: content text
function Macros.EditBox(uiName, text)
	Macros.SetNextKeyPressWithMouseMove(nil, nil);
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		obj.text = text or ""
		obj:SetCaretPosition(-1);
		--obj:Focus()
		__onuievent__(obj.id, "onmodify");
	end
	return Macros.Idle();
end

function Macros.EditBoxKeyup(uiName, keyname)
	Macros.SetNextKeyPressWithMouseMove(nil, nil);
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		local vKey = keyname:gsub("DIK_", "EM_KEY_");
		if(Event_Mapping[vKey]) then
			virtual_key = Event_Mapping[vKey];
			__onuievent__(obj.id, "onkeyup");
		end
	end
	return Macros.Idle();
end


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
			keyname = "DIK_SLASH"
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


-- return text - lastText.  or nil if text does not begin with lastText
local function GetTextDiff(text, lastText)
	local diff;
	if(lastText and text) then
		if(text:sub(1, #(lastText)) == lastText) then
			diff = text:sub(#(lastText)+1, -1);
		end
	end
	if(diff~="") then
		return diff;
	end
end


--@param uiName: UI name
--@param text: content text
function Macros.EditBoxTrigger(uiName, text)
	local obj = ParaUI.GetUIObject(uiName)
	if(obj and obj:IsValid()) then
		local x, y, width, height = obj:GetAbsPosition();
		local mouseX = math.floor(x + width /2)
		local mouseY = math.floor(y + height /2)
		ParaUI.SetMousePosition(mouseX, mouseY);
		obj:SetCaretPosition(-1);
		--obj:Focus()

		if(text == obj.text) then
			-- skip if equal
			return Macros.Idle();
		else
			local textDiff = GetTextDiff(text, obj.text);
			local callback = {};
			MacroPlayer.SetEditBoxTrigger(mouseX, mouseY, text, textDiff, function()
				if(callback.OnFinish) then
					callback.OnFinish();
				end
			end);
			return callback;
		end
	end
end

--@param uiName: UI name
--@param text: content text
function Macros.EditBoxKeyupTrigger(uiName, keyname)
	if(keyname == "DIK_RETURN") then
		-- we will only trigger the enter key
		local obj = ParaUI.GetUIObject(uiName)
		if(obj and obj:IsValid()) then
			local x, y, width, height = obj:GetAbsPosition();
			local mouseX = math.floor(x + width /2)
			local mouseY = math.floor(y + height /2)
			ParaUI.SetMousePosition(mouseX, mouseY);
			obj:SetCaretPosition(-1);
		
			Macros.SetNextKeyPressWithMouseMove(mouseX, mouseY);
			return Macros.KeyPressTrigger(keyname)
		end
	end
end






