--[[
Title: LuckyTree
Author(s): Leio
Date: 2011/04/11

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30420_Lucky_Tree_Bread.lua");
local Lucky_Tree_Bread = commonlib.gettable( "MyCompany.Aries.Quest.NPCs.Lucky_Tree_Bread" );
Lucky_Tree_Bread.DoShake();

NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");
LuckyTreeClientLogics.DoLottery_Bread();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");

local Lucky_Tree_Bread = commonlib.gettable( "MyCompany.Aries.Quest.NPCs.Lucky_Tree_Bread" );

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function Lucky_Tree_Bread.main()
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
		end
	});
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "character/v5/08functional/BreadTree/BreadTree_tremble.x"));
end
function Lucky_Tree_Bread.DoShake()
	Lucky_Tree_Bread.info = nil;
	local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30420);
	if(giftTree) then
		giftTree:SetVisible(false);
			
		-- create effect
		local params = {
			asset_file = "character/v5/08functional/BreadTree/BreadTree_tremble.x",
			--ismodel = true,
			scale = 1,
			start_position = {giftTree:GetPosition()},
			duration_time = 2500,
			end_callback = function()
				local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30420);
				if(giftTree) then
					giftTree:SetVisible(true);
					LuckyTreeClientLogics.DoLottery_Bread();
				end
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end
function Lucky_Tree_Bread.DoLottery_Hanlder(msg)
	if(not msg or not msg.issuccess)then return end
	Lucky_Tree_Bread.info = msg;
	Lucky_Tree_Bread.SaveNum();
	 System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
					{npc_id = 30420, state=10,}
			);
end
function Lucky_Tree_Bread.SaveNum()
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local date = ParaGlobal.GetDateFormat("yyyy-M-d")
	local key = string.format("Lucky_Tree_Bread_%s_%s",nid,date);
	local n = Lucky_Tree_Bread.GetNum() or 0;
	n = n + 1;
	MyCompany.Aries.Player.SaveLocalData(key, n)
end
function Lucky_Tree_Bread.GetNum()
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local date = ParaGlobal.GetDateFormat("yyyy-M-d")
	local key = string.format("Lucky_Tree_Bread_%s_%s",nid,date);
	local n = MyCompany.Aries.Player.LoadLocalData(key, 0);
	return n;
end