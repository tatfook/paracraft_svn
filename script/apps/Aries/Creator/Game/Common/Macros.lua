--[[
Title: all Macros 
Author(s): LiXizhi
Date: 2021/1/2
Desc: namespace for all macros

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macros.lua");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")
-------------------------------------------------------
]]

local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")


function Macros:IsRecording()
	return self.isRecording;
end

function Macros:BeginRecord()
	self.isRecording = true;
	self.macros = {};
end

-- @param text: macro command text or just macro function name
-- @param ...: additional input parameters to macro function name
function Macros:AddMacro(text, ...)
	local args = {...}
	if(#args > 0) then
		local params;
		for _, param in ipairs(args) do
			if(params) then
				params = params..","..commonlib.serialize_compact(param);
			else
				params = commonlib.serialize_compact(param);
			end
		end
		text = format("%s(%s)", text, params or "");
	else
		if(not text:match("%(")) then
			text = text.."()";
		end
	end
	self.macros[#self.macros + 1] = text;
end

function Macros:EndRecord()
	self.isRecording = false;
	if(self.macros) then
		local text = table.concat(self.macros, "\n");
		ParaMisc.CopyTextToClipboard(text);
		GameLogic.AddBBS(nil, format("%d macros are copied to clipboard", #(self.macros)), 5000, "0 255 0")
	end
end
