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
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");

local Entity = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntitySign"), commonlib.gettable("MyCompany.Aries.Game.EntityManager.EntityAgentSign"));
Entity:Property({"languageConfigFile", "mcml", "GetLanguageConfigFile", "SetLanguageConfigFile"})
Entity:Property({"version", "1.0", "GetVersion", "SetVersion", auto=true})
Entity:Property({"agentName", nil, "GetAgentName", "SetAgentName", auto=true})
Entity:Property({"agentDependencies", nil, "GetAgentDependencies", "SetAgentDependencies", auto=true})
Entity:Property({"agentExternalFiles", nil, "GetAgentExternalFiles", "SetAgentExternalFiles", auto=true})
Entity:Property({"agentUrl", nil, "GetAgentUrl", "SetAgentUrl", auto=true})
Entity:Property({"isGlobal", false, "IsGlobal", "SetGlobal", auto=true})
Entity:Property({"updateMethod", "manual", "GetUpdateMethod", "SetUpdateMethod", auto=true})

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

function Entity:SaveToXMLNode(node, bSort)
	node = Entity._super.SaveToXMLNode(self, node, bSort);
	node.attr.version = self:GetVersion();
	node.attr.agentName = self:GetAgentName();
	node.attr.agentDependencies = self:GetAgentDependencies();
	node.attr.agentExternalFiles = self:GetAgentExternalFiles();
	node.attr.agentUrl = self:GetAgentUrl();
	node.attr.isGlobal = self:IsGlobal();
	node.attr.updateMethod = self:GetUpdateMethod();

	return node;
end

function Entity:LoadFromXMLNode(node)
	Entity._super.LoadFromXMLNode(self, node);
	self:SetVersion(node.attr.version);
	self:SetAgentName(node.attr.agentName);
	self:SetAgentDependencies(node.attr.agentDependencies);
	self:SetAgentExternalFiles(node.attr.agentExternalFiles);
	self:SetAgentUrl(node.attr.agentUrl);
	self:SetUpdateMethod(node.attr.updateMethod);
end


function Entity:GetDisplayName()
	local agentName = self:GetAgentName();
	if(agentName and agentName~="") then
		return agentName.."\n"..(self.cmd or "");
	else
		return self.cmd or "";
	end
end

function Entity:GetAgentFilename()
	local name = self:GetAgentName();
	if(name and name~="") then
		return Files.WorldPathToFullPath("agents/"..name..".xml");
	end
end

function Entity:SaveToAgentFile(filename)
	filename = filename or self:GetAgentFilename()
	
	if(filename) then
		-- save to local agent file
		local blocks = self:GetConnectedBlocks()
		if(blocks and #blocks>=1) then
			NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/BlockTemplateTask.lua");
			local BlockTemplate = commonlib.gettable("MyCompany.Aries.Game.Tasks.BlockTemplate");
			
			local pivot_x, pivot_y, pivot_z = self:GetBlockPos();
			local params = {relative_motion = true, pivot = string.format("%d,%d,%d", pivot_x, pivot_y, pivot_z)};
			for i = 1, #(blocks) do
				-- x,y,z,block_id, data, serverdata
				local b = blocks[i];
				b[6] = BlockEngine:GetBlockEntityData(b[1], b[2], b[3]);
				blocks[i] = {b[1]-pivot_x, b[2]-pivot_y, b[3]- pivot_z, b[4], if_else(b[5] == 0, nil, b[5]), b[6]};
			end

			local task = BlockTemplate:new({operation = BlockTemplate.Operations.Save, filename = filename, params = params, blocks = blocks})
			task:Run();
		end
	end
	self:Refresh()
end	

function Entity:LoadFromAgentFile(filename)
	filename = filename or self:GetAgentFilename()
	if(filename and ParaIO.DoesFileExist(filename)) then
		local bx, by, bz = self:GetBlockPos();
		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/BlockTemplateTask.lua");
		local BlockTemplate = commonlib.gettable("MyCompany.Aries.Game.Tasks.BlockTemplate");
		local task = BlockTemplate:new({operation = BlockTemplate.Operations.Load, filename = filename,
			blockX = bx,blockY = by, blockZ = bz, bSelect=false, UseAbsolutePos = false, TeleportPlayer = false})
		task:Run();
	end
end

function Entity:ComputeAgentUrl()
	local remoteFolderName = GameLogic.options:GetRemoteWorldFolder();
	if(remoteFolderName) then
		local url = format("%sagents/%s.xml", remoteFolderName, self:GetAgentName());
		return url;
	end
end

-- agent url is [username]/[worldname]/agents/[agentfilename]
function Entity:ResetAgentUrl()
	local url = self:ComputeAgentUrl();
	if(url) then
		if(self:GetAgentUrl() ~= url) then
			self:SetAgentUrl(url);
			self:Refresh()
		end
	end
end

-- check if this agent belongs to the current world
function Entity:IsInCurrentWorld()
	local url = self:GetAgentUrl()
	if((not url or url== "") or url == self:ComputeAgentUrl()) then
		return true
	end
end

function Entity:Refresh()
	if(self:IsInCurrentWorld()) then
		self.text_color = "128 0 0";
	else
		self.text_color = "0 0 128";
	end

	return Entity._super.Refresh(self);
end
