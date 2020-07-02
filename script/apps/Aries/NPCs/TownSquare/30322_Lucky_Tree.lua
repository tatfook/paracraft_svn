--[[
Title: LuckyTree
Author(s): zrf
Date: 2010/12/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30322_Lucky_Tree.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");

local Lucky_Tree = commonlib.gettable( "MyCompany.Aries.Quest.NPCs.Lucky_Tree" );

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function Lucky_Tree.main()
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
		end
	});
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "character/v5/08functional/LuckTree/LuckTree_tremble.x"));
	LuckyTreeClientLogics.SetWindowsHook();
end
function Lucky_Tree.DoShake()
	Lucky_Tree.info = nil;
	local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30322);
	if(giftTree) then
		giftTree:SetVisible(false);
			
		-- create effect
		local params = {
			asset_file = "character/v5/08functional/LuckTree/LuckTree_tremble.x",
			--ismodel = true,
			scale = 2 * 1.5,
			start_position = {giftTree:GetPosition()},
			duration_time = 2000,
			end_callback = function()
				local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30322);
				if(giftTree) then
					giftTree:SetVisible(true);
					LuckyTreeClientLogics.DoLottery();
				end
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end
function Lucky_Tree.DoLottery_Hanlder(msg)
	if(not msg or not msg.issuccess)then return end
	Lucky_Tree.info = msg;

	 System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
					{npc_id = 30322, state=10,}
			);
end