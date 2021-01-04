--[[
Title: CommandQuest
Author(s): LiXizhi
Date: 2016/1/20
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandQuest.lua");
-------------------------------------------------------
]]
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");


Commands["macro"] = {
	name="macro", 
	quick_ref="/macro [record|play|stop] [filename]", 
	desc=[[record user actions and then playback. 
e.g.
/macro    toggle recording mode
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local name;
		name, cmd_text = CmdParser.ParseString(cmd_text);

		local function StartRecord()
			GameLogic.Macros:BeginRecord()
			NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroRecorder.lua");
			local MacroRecorder = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroRecorder");
			MacroRecorder.ShowPage();
		end
		if(name == "record") then
			StartRecord()
		elseif(name == "stop") then
			GameLogic.Macros:Stop();
		elseif(name == "play") then
			GameLogic.Macros:Play();
		elseif(not name or name == "") then
			if(GameLogic.Macros:IsRecording()) then
				GameLogic.Macros:Stop()
			else
				StartRecord()
			end
		end
	end,
};
