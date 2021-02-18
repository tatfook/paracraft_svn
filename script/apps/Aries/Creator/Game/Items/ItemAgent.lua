--[[
Title: ItemAgent
Author(s): LiXizhi
Date: 2021/2/17
Desc: Agent item is a special item that is defined in code blocks. The appearance and functions of the agent item 
are implemented by registerAgentEvent in code blocks. Agent Item is usually listed in the inventory of agent sign block. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemAgent.lua");
local ItemAgent = commonlib.gettable("MyCompany.Aries.Game.Items.ItemAgent");
local item = ItemAgent:new({icon,});
-------------------------------------------------------
]]
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");

local ItemAgent = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Items.Item"), commonlib.gettable("MyCompany.Aries.Game.Items.ItemAgent"));

block_types.RegisterItemClass("ItemAgent", ItemAgent);

