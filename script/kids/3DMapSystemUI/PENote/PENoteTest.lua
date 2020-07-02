--[[
Title: PENoteTest
Author(s): Leio
Date: 2009/5/26
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteTest.lua");
Map3DSystem.App.PENote.PENoteTest.Test();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteClient.lua");
local PENoteTest = {

}
commonlib.setfield("Map3DSystem.App.PENote.PENoteTest",PENoteTest);
function PENoteTest.doFunc(funcArgs)
	commonlib.echo(funcArgs);
end
function PENoteTest.Test()
	PENoteTest.PENote_Client = Map3DSystem.App.PENote.PENoteClient:new();
	PENoteTest.PENote_Client.OnPush = PENoteTest.OnPush;
	
	local jid = "jid number";
	local to =  "to number"
	local from =  "to number"
	--PENoteTest.PENote_Client:SendMessage({to = to, from = from, note = "pet_dead", doFunc = PENoteTest.doFunc, funcArgs = {"a","b","c"} },jid);	
	PENoteTest.PENote_Client:HandleMessage({to = to, from = from, note = "pet_dead", doFunc = PENoteTest.doFunc, funcArgs = {"a","b","c"} },jid);	
end

function PENoteTest.OnPush(noteClient)
	if(not noteClient)then return end
	local msgPool = PENoteTest.PENote_Client.msgPool;
	if(not msgPool)then return end
	local len = #msgPool;
	--MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(true,len);
	
	local msg = msgPool[len];
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteTemplate.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteLibs.lua");
	local note = Map3DSystem.App.PENote.PENoteLibs.GetNote(msg);
	Map3DSystem.App.PENote.PENoteTemplate.Show(note);
end