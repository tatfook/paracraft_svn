--[[
Title: aries dialog related interfaces
Author(s): WangTian
Date: 2009/6/24
Desc: global AI related functions.
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/main.lua");
-------------------------------------------------------
]]

-- create class
local libName = "AriesDialog";
local Dialog = commonlib.gettable("MyCompany.Aries.Dialog");

NPL.load("(gl)script/apps/Aries/Dialog/Headon_OPC.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Dialog_NPC.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Headon_NPC.lua");

-- init the dialog component at Aries app activate desktop
function Dialog.Init()
	MyCompany.Aries.Dialog.Headon_NPC.Init();
	MyCompany.Aries.Dialog.Headon_OPC.Init();
end

-- OPC player speak some talk content
-- @nid: nid of the OPC character, if nil or "", means self
-- @text: talk content
-- @time: (optional) the dialog life time, in seconds
function Dialog.OPCSpeak(nid, text, nLifeTime)
	Dialog.Headon_OPC.Speak(nid, text, nLifeTime);
end

-- NPC character speak some talk content
-- @npc_id: nid of the NPC character, if nil or "", means self
-- @text: talk content
-- @nLifeTime: (optional) the dialog life time, in seconds
function Dialog.NPCSpeak(npc_id, text, nLifeTime)
	Dialog.Headon_NPC.Speak(npc_id, text, nLifeTime)
end

-- obsoleted: NPC character speak some talk content
-- @npc_id: nid of the NPC character, if nil or "", means self
-- @text: talk content
-- @nLifeTime: (optional) the dialog life time, in seconds
function Dialog.NPCDialog(npc_id, text)
	
end

-- game object pick
-- @gsid: item global store id
-- @count: pick item count
function Dialog.ItemPick(gsid, count)
	
end

-- game object pick
-- @gsid: item global store id
-- @count: pick item count
function Dialog.ItemPurchase(gsid)
	
end