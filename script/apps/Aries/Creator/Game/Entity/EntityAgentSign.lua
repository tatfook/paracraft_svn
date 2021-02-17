--[[
Title: Agent Sign block entity
Author(s): LiXizhi
Date: 2021/2/17
Desc: Agent sign block is a signature block for describing all scene blocks connected to it. 
Agent sign block have following functions:
1. as a sign block in the scene: it displays the name of the agent and possibly a version number. It is called agent sign block. 
2. A custom `agent editor` UI is shown once the user clicks the button.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/EntityAgentSign.lua");
local EntityAgentSign = commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityAgentSign")
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Direction.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/EntityBlockBase.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Effects/Text3DDisplay.lua");
local Text3DDisplay = commonlib.gettable("MyCompany.Aries.Game.Effects.Text3DDisplay");
local Direction = commonlib.gettable("MyCompany.Aries.Game.Common.Direction")
local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
local PhysicsWorld = commonlib.gettable("MyCompany.Aries.Game.PhysicsWorld");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local TaskManager = commonlib.gettable("MyCompany.Aries.Game.TaskManager")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local Packets = commonlib.gettable("MyCompany.Aries.Game.Network.Packets");

local Entity = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntitySign"), commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityAgentSign"));
Entity:Property({"languageConfigFile", "mcml", "GetLanguageConfigFile", "SetLanguageConfigFile"})
Entity:Property({"isAllowClientExecution", false, "IsAllowClientExecution", "SetAllowClientExecution"})
Entity:Property({"isAllowFastMode", false, "IsAllowFastMode", "SetAllowFastMode"})

Entity:Signal("beforeRemoved")
Entity:Signal("editModeChanged")
Entity:Signal("remotelyUpdated")
Entity:Signal("inventoryChanged", function(slotIndex) end)

-- class name
Entity.class_name = "EntityAgentSign";
EntityManager.RegisterEntityClass(Entity.class_name, Entity);
Entity.is_persistent = true;
-- always serialize to 512*512 regional entity file
Entity.is_regional = true;
Entity.text_color = "0 0 0";
Entity.text_offset = {x=0,y=0.42,z=0.37};

function Entity:ctor()
end

function Entity:OnBlockAdded(x,y,z, data)
	Entity._super.OnBlockAdded(self, x,y,z, data)
end

function Entity:OnBlockLoaded(x,y,z, data)
	Entity._super.OnBlockLoaded(self, x,y,z, data)
end

function Entity:OnRemoved()
	Entity._super.OnRemoved(self);
end

function Entity:GetDisplayName()
	return self.cmd or "";
end

function Entity:SaveToXMLNode(node, bSort)
	node = Entity._super.SaveToXMLNode(self, node, bSort);
	
	return node;
end

function Entity:LoadFromXMLNode(node)
	Entity._super.LoadFromXMLNode(self, node);
end

