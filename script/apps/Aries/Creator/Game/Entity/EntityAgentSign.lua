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
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local Direction = commonlib.gettable("MyCompany.Aries.Game.Common.Direction")
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

-- get all connected blocks containing at least one code block. It will search for all blocks above the current block.
-- if no code block is found, it will search for one layer below the current block. 
-- @param bCodeBlockOnly: if true we will only return code blocks
-- @param max_new_count: max number of blocks to be added. default to 1000
-- @return table of blocks. it will return nil, if no code blocks is found
function Entity:GetConnectedBlocks(bCodeBlockOnly, max_new_count)
	max_new_count = max_new_count or 1000;
	
	local blocks = {};
	local codeblocks = {};
	local blockIndices = {}; -- mapping from block index to true for processed bones
	local cx, cy, cz = self:GetBlockPos();
	local min_y = cy;
	local max_y = 255;
	
	local function IsBlockProcessed(x, y, z)
		local boneIndex = BlockEngine:GetSparseIndex(x-cx,y-cy,z-cz);
		return blockIndices[boneIndex];
	end
	local newlyAddedCount = 0;
	local function AddBlock(x, y, z)
		local boneIndex = BlockEngine:GetSparseIndex(x-cx,y-cy,z-cz)
		if(not blockIndices[boneIndex]) then
			blockIndices[boneIndex] = true;
			local block_id = ParaTerrain.GetBlockTemplateByIdx(x,y,z);
			if(block_id > 0) then
				local block = block_types.get(block_id);
				if(block) then
					local block_data = ParaTerrain.GetBlockUserDataByIdx(x,y,z);
					local block = {x,y,z, block_id, block_data}
					blocks[#blocks+1] = block;
					if(block_id == block_types.names.CodeBlock ) then
						codeblocks[#codeblocks+1] = block;
					end
					newlyAddedCount = newlyAddedCount + 1;
					return true;
				end
			end
		end
	end

	local breadthFirstQueue = commonlib.Queue:new();
	local function AddConnectedBlockRecursive(cx,cy,cz)
		if(newlyAddedCount < max_new_count) then
			for side=0,5 do
				local dx, dy, dz = Direction.GetOffsetBySide(side);
				local x, y, z = cx+dx, cy+dy, cz+dz;
				if(y >= min_y and y<=max_y and AddBlock(x, y, z)) then
					breadthFirstQueue:pushright({x,y,z});
				end
			end
		end
	end
	
	local function AddAllBlocksAbove()
		local baseBlockCount = #blocks;
		for i = 1, baseBlockCount do
			local block = blocks[i];
			local x, y, z = block[1], block[2], block[3];
			AddConnectedBlockRecursive(x,y,z);
		end

		while (not breadthFirstQueue:empty()) do
			local block = breadthFirstQueue:popleft();
			AddConnectedBlockRecursive(block[1], block[2], block[3]);
		end		
	end

	-- add this block
	AddBlock(cx, cy, cz);
	AddAllBlocksAbove();
	
	
	if(#codeblocks == 0) then
		-- tricky: if no code block is found, we will also search for the layer below the current block. 
		min_y = min_y - 1;
		max_y = min_y;
		AddAllBlocksAbove()
	end
	if(#codeblocks ~= 0) then
		if(bCodeBlockOnly) then
			return codeblocks;
		else
			return blocks;
		end
	end
end

-- @param bHighlight: false to un-highlight all.
-- @return all blocks
function Entity:HighlightConnectedBlocks(bHighlight)
	if(bHighlight~=false) then
		local blocks = self:GetConnectedBlocks();
		if(blocks) then
			for _, b in ipairs(blocks) do
				ParaTerrain.SelectBlock(b[1], b[2], b[3], true);
			end
		end
		return blocks
	else
		ParaTerrain.DeselectAllBlock();
	end
end

