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
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local Packets = commonlib.gettable("MyCompany.Aries.Game.Network.Packets");

local Entity = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntitySign"), commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityAgentSign"));
Entity:Property({"languageConfigFile", "mcml", "GetLanguageConfigFile", "SetLanguageConfigFile"})

-- class name
Entity.class_name = "EntityAgentSign";
EntityManager.RegisterEntityClass(Entity.class_name, Entity);

function Entity:ctor()
	self:SetBagSize(16);
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

local EditorAgentMCML
-- the title text to display (can be mcml)
function Entity:GetCommandTitle()
	EditorAgentMCML = EditorAgentMCML or string.format([[
		<div style="float:left;margin-left:5px;margin-top:7px;">
			<input type="button" uiname="EditEntityPage.OpenAgentEditor" value='<%%="%s"%%>' onclick="MyCompany.Aries.Game.EntityManager.EntityAgentSign.OnClickAgentEditor" style="min-width:80px;color:#ffffff;font-size:12px;height:25px;background:url(Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png#179 89 21 21:8 8 8 8)" />
		</div>
	]], L"Agent编辑器...");
	return EditorAgentMCML;
end

function Entity.OnClickAgentEditor()
	NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/EditEntityPage.lua");
	local EditEntityPage = commonlib.gettable("MyCompany.Aries.Game.GUI.EditEntityPage");
	local self = EditEntityPage.GetEntity()
	if(self and self:isa(Entity)) then
		EditEntityPage.CloseWindow();
		self:OpenAgentEditor();
	end
end

function Entity:OpenAgentEditor()
	NPL.load("(gl)script/apps/Aries/Creator/Game/Agent/AgentEditorPage.lua");
	local AgentEditorPage = commonlib.gettable("MyCompany.Aries.Game.Agent.AgentEditorPage");
	AgentEditorPage.ShowPage(self);
end

-- bool: whether show the bag panel
function Entity:HasBag()
	return true;
end

-- virtual function: get array of item stacks that will be displayed to the user when user try to create a new item. 
-- @return nil or array of item stack.
function Entity:GetNewItemsList()
	local itemStackArray = Entity._super.GetNewItemsList(self) or {};
	local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");
	itemStackArray[#itemStackArray+1] = ItemStack:new():Init(block_types.names.AgentItem,1);
	itemStackArray[#itemStackArray+1] = ItemStack:new():Init(block_types.names.Book,1);
	return itemStackArray;
end