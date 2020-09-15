--[[
Title: CommandDiff
Author(s): LiXizhi
Date: 2020/9/15
Desc: generate NPL documentation for NPL language service. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandDiff.lua");
-------------------------------------------------------
]]
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local block = commonlib.gettable("MyCompany.Aries.Game.block")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");

local DiffTool = commonlib.inherit({});

Commands["diff"] = {
	name="diff", 
	quick_ref="/diff [-selection] remote_ip_port", 
	desc=[[show differences between all entities in current world and others in remote or local computer. 
@param remote_ip_port: such as "127.0.0.1:8100"
e.g.
/diff 127.0.0.1:8100
/diff 127.0.0.1:8100
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local outputname;
		local option = "";
		while (option) do
			option, cmd_text = CmdParser.ParseOption(cmd_text);
			if(option == "selection") then
			end
		end
		
		if(cmd_text and cmd_text~="") then
			local remote_ip_port;
			remote_ip_port, cmd_text = CmdParser.ParseString(cmd_text);
			DiffTool:Run(remote_ip_port, remote_ip_port2)
		end
	end,
};

function DiffTool:Run(remote_ip_port)
	
end

