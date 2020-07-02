--[[
Title: FarmlandShop
Author(s): Leio
Date: 2010/03/08

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Farm/30366_FarmlandShop.lua
------------------------------------------------------------
]]

-- create class
local libName = "FarmlandShop";
local FarmlandShop = {
	seeds = {
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19660.224609375, 0.16260300576687, 19881.6796875 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19649.076171875, 0.93238300085068, 19882.875 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19638.05859375, 1.4234520196915, 19883.955078125 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19658.208984375, 0.80418199300766, 19870.220703125 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19647.44921875, 1.4237819910049, 19871.521484375 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19636.86328125, 1.845016002655, 19872.2421875 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19657.66015625, 0.63086497783661, 19860.58984375 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19646.142578125, 1.2610069513321, 19861.595703125 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19635.166015625, 1.6580810546875, 19863.09765625 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19656.349609375, 0.41068801283836, 19850.68359375 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19645.150390625, 0.92040598392487, 19852.435546875 }, scale_model = 1.2, },
		{name = "樱桃种子", label = "樱桃", gsid = 30008, position = { 19634.390625, 1.3176480531693, 19854.80859375 }, scale_model = 1.2, },
		
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19669.14453125, -0.066673003137112, 19882.59765625 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19668.337890625, 0.12193900346756, 19870.796875 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19668.169921875, 0.13916000723839, 19860.33203125 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19667.58203125, 0.25727799534798, 19849.8125 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19679.373046875, -0.078170999884605, 19881.66796875 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19679.18359375, -0.00012199999764562, 19870.361328125 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19678.546875, 0.11268600076437, 19859.6484375 }, scale_model = 1.46, },
		{name = "菠萝种子", label = "菠萝", gsid = 30009, position = { 19678.84375, 0.54012298583984, 19848.84375 }, scale_model = 1.46, },
		
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19667.060546875, -0.050291001796722, 19839.49609375 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19674.263671875, 0.52049100399017, 19839.4921875 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19679.892578125, 0.5915219783783, 19839.1875 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19679.814453125, 0.3780170083046, 19831.4375 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19674.2890625, 0.3345850110054, 19831.65625 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19667.0703125, 0.18468900024891, 19831.84375 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19665.783203125, 0.12299899756908, 19825.599609375 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19674.0234375, 0.21480000019073, 19824.455078125 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19679.447265625, 0.20011700689793, 19823.755859375 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19679.1328125, 0.40241101384163, 19817.310546875 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19673.677734375, 0.39473301172256, 19817.87109375 }, scale_model = 1.6, },
		{name = "竹子种子", label = "竹子", gsid = 30010, position = { 19664.97265625, 0.31207698583603, 19818.599609375 }, scale_model = 1.6, },
		
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19656.123046875, 0.19381700456142, 19839.5546875 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19655.654296875, 0.12019500136375, 19830.01171875 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19654.556640625, 0.21390500664711, 19820.31640625 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19642.849609375, 0.50577199459076, 19820.927734375 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19643.74609375, 0.42984399199486, 19831.505859375 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19645.267578125, 0.51731097698212, 19841.451171875 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19634.830078125, 0.85942298173904, 19842.212890625 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19633.783203125, 0.81507098674774, 19832.583984375 }, scale_model = 1.948, },
		{name = "紫藤萝种子", label = "紫藤萝", gsid = 30011, position = { 19632.3125, 0.9047150015831, 19822.599609375 }, scale_model = 1.948, },
		
		
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19623.7109375, 0.99436897039413, 19845.06640625 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19622.45703125, 0.9274839758873, 19838.955078125 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19621.71875, 0.96280598640442, 19831.14453125 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19620.7265625, 1.011255979538, 19821.90625 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19614.638671875, 0.93531000614166, 19845.740234375 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19614.84375, 0.88555902242661, 19838.404296875 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19613.34765625, 0.92949897050858, 19834.392578125 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19613.34765625, 0.92949897050858, 19834.392578125 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19607.328125, 0.97807198762894, 19846.7734375 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19605.974609375, 0.973837018013, 19840.697265625 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19606.60546875, 0.96302402019501, 19831.658203125 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19600.80078125, 1.0636320114136, 19846.666015625 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19601.115234375, 1.0337619781494, 19838.7421875 }, scale_model = 1.3, },
		{name = "香蕉种子", label = "香蕉", gsid = 30165, position = { 19596.9296875, 1.0665309429169, 19844.294921875 }, scale_model = 1.3, },
		
		
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19627.0546875, 1.9595600366592, 19872.359375 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19627.384765625, 1.9821770191193, 19878.5703125 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19627.857421875, 1.8582960367203, 19884.048828125 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19620.2109375, 1.7901079654694, 19872.3984375 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19620.25390625, 1.8692560195923, 19878.111328125 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19620.41796875, 1.8157600164413, 19885.06640625 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19613.54296875, 1.4739209413528, 19872.333984375 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19613.591796875, 1.5963460206985, 19877.833984375 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19613.548828125, 1.6135350465775, 19883.80859375 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19606.51171875, 1.1254420280457, 19872.26171875 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19606.375, 1.2559690475464, 19877.126953125 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19605.982421875, 1.2891119718552, 19882.2421875 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19599.537109375, 0.8904629945755, 19872.296875 }, scale_model = 1.46, },
		{name = "玉米种子", label = "玉米", gsid = 30163, position = { 19599.767578125, 1.091765999794, 19879.283203125 }, scale_model = 1.46, },
		
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19623.58984375, 1.1594849824905, 19851.533203125 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19624.1484375, 1.4158099889755, 19858.109375 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19625.259765625, 1.7026890516281, 19864.931640625 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19616.1953125, 1.0674860477448, 19852.90625 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19616.09765625, 1.1842139959335, 19858.578125 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19616.45703125, 1.4022500514984, 19865.279296875 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19607.943359375, 0.95811301469803, 19852.85546875 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19607.81640625, 0.89904797077179, 19859.25 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19608.177734375, 0.98512500524521, 19865.548828125 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19598.546875, 1.1236000061035, 19853.708984375 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19598.388671875, 0.78846001625061, 19860.365234375 }, scale_model = 1, },
		{name = "苹果种子", label = "苹果", gsid = 30164, position = { 19598.291015625, 0.68565601110458, 19865.4296875 }, scale_model = 1, },
	}
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FarmlandShop", FarmlandShop);

local assetfile_mapping = {
	[30008] = "model/05plants/v5/08homelandPlant/CherryTree/CherryTreeStage4.x",
	[30009] = "model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage4.x",
	[30010] = "model/05plants/v5/08homelandPlant/Bamboo/BambooStage3.x",
	[30011] = "model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage4.x",
	--苹果树
	[30164] = "model/05plants/v5/08homelandPlant/AppleTree/AppleTreeStage4.x",
	--玉米树
	[30163] = "model/05plants/v5/08homelandPlant/CornTree/CornTreeStage4.x",
	--香蕉树
	[30165] = "model/05plants/v5/08homelandPlant/BananaTree/BananatreeStage4.x",
};

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FarmlandShop.main
function FarmlandShop.main()
	local self = FarmlandShop; 
	self.DeleteSeedInstance();
	self.CreateSeedInstance();
end

function FarmlandShop.PreDialog(npc_id, instance)
	local self = FarmlandShop; 
	return false;
end
---create a number of seed npc instance which can be selected by user who want to buy
function FarmlandShop.CreateSeedInstance()
	local self = FarmlandShop; 
	if(self.seeds)then
		local k, v;
		for k, v in ipairs(self.seeds) do
			local name = v.name;
			local position = v.position;
			local asset_model = assetfile_mapping[v.gsid];
			local params = { 
				name = name,
				instance = k,
				position = position,
				facing = -0.15686285495758,
				scale_char = 3,
				scaling_model = v.scale_model,
				isalwaysshowheadontext = false,
				assetfile_char = "character/common/dummy/elf_size/elf_size.x",
				assetfile_model = asset_model,
				main_script = "script/apps/Aries/NPCs/Farm/30366_FarmlandShop.lua",
				main_function = "MyCompany.Aries.Quest.NPCs.FarmlandShop.main_instance();",
				predialog_function = "MyCompany.Aries.Quest.NPCs.FarmlandShop.PreDialog_Instance",
				AI_script = "script/apps/Aries/NPCs/Farm/30366_FarmlandShop_AI.lua",
				On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.FarmlandShop_AI.On_FrameMove();",
				selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			};
			MyCompany.Aries.Quest.NPC.CreateNPCCharacter(303661, params);
			local npcChar, _model = NPC.GetNpcCharModelFromIDAndInstance(303661,k);
			if(npcChar and npcChar:IsValid())then
				npcChar:SnapToTerrainSurface(0);
				if(_model and _model:IsValid())then
					local x,y,z = npcChar:GetPosition();
					_model:SetPosition(x,y,z);
				end
			end	
		end
	end
end
--delete all seed instance
function FarmlandShop.DeleteSeedInstance()
	local self = FarmlandShop; 
	if(self.seeds)then
		local k,v;
		for k,v in ipairs(self.seeds)do
			MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(303661,k);
		end
	end
end
function FarmlandShop.main_instance()
end

function FarmlandShop.PreDialog_Instance(npc_id,instance)
	local self = FarmlandShop; 
	commonlib.echo("==========FarmlandShop.PreDialog_Instance");
	local id = instance;
	if(self.seeds and id)then
		local seed = self.seeds[id];
		if(seed)then
			local gsid = seed.gsid;
			local name = seed.name;
			local label = seed.label;
			if(gsid)then
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>这里是【%s】种植园，你想买一些【%s】吗？</div>",label,name);
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.Yes)then
						local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
						if(command) then
							command:Call({gsid = gsid});
						end
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
			end
		end
	end
	return false;
end