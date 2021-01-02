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

function Macros:AddMacro(text)
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
