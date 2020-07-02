--[[
Title: Quest system server message handler.
Author(s): WangTian
Date: 2008/12/10

Quest server will handle every CMSG message and perform database query or update
And returns the result with SMSG messages

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGHandler_Server.lua");
------------------------------------------------------------
]]


local function activate()

		local text = commonlib.serialize(msg);
		local logtext = ParaUI.CreateUIObject("button", "logtext", "_lt", 0, 0, 400, 400);
		logtext.text = text;
		logtext:AttachToRoot();
		
		log("showtext\n")
	commonlib.echo(text)
end

NPL.this(activate);