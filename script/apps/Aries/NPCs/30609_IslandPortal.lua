--[[
Title: IslandPortal.lua
Author(s): Spring
Date: 2010/11/23

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/30609_IslandPortal.lua");
------------------------------------------------------------
]]

-- create class
local IslandPortal= commonlib.gettable("MyCompany.Aries.Quest.NPCs.IslandPortal");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

--[[
local portal_positions = {
{ 19600.296875, 4.114520, 19535.228516, }, -- 浮冰台
{ 19344.435547, 35.187908, 19759.845703,},-- 林海雪原
{ 19881.951172, 7.179173, 19776.406250, },--- 雪狼湖
{ 20206.535156, 45.702763, 20101.378906, },-- 冰莲峰
{ 19820.031250, 4.004883, 20374.910156, },-- 避风港
{ 19661.101563, 4.191172, 20175.042969, },-- 怒风峡谷
};

local portal_name = {
 [1]={id=79003,name="浮冰台传送门",},
 [2]={id=79004,name="林海雪原传送门",},
 [3]={id=79005,name="雪狼湖传送门",},
 [4]={id=79007,name="冰莲峰传送门",},
 [5]={id=79002,name="避风港传送门",},
 [6]={id=79006,name="怒风峡谷传送门",},
};
]]

local base_portal_param = {
	facing = 0.5,
	--scaling = 0.5,
	scale_char = 1.1,
	scale_model = 2,
	talkdist = 9,
	--assetfile_model = "character/common/dummy/cube_size/cube_size.x";
	assetfile_char = "character/common/dummy/elf_size/elf_size.x",
	main_script = "script/apps/Aries/NPCs/30609_IslandPortal.lua",
	main_function = "MyCompany.Aries.Quest.NPCs.IslandPortal.main_portal();",
	predialog_function = "MyCompany.Aries.Quest.NPCs.IslandPortal.PreDialog_portal",
	dialog_page = "script/apps/Aries/NPCs/30609_IslandPortal_dialog.html",
	isdummy = true,
};

-- IslandPortal.main
function IslandPortal.main()
	local node;

	local worldDir = ParaWorld.GetWorldDirectory();
	local thisworld = string.match(worldDir,"%/([0-9_a-zA-Z]*)%/$");

	local input_path="config/Aries/WorldData/"..thisworld..".Portal.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(input_path);
	if (not xmlRoot) then
		log("++++++++++"..thisworld.." config file not exist!\n");
		return
	end
	local portal_item={};
	for node in commonlib.XPath.eachNode(xmlRoot, "/PortalList/Portal") do
		local item={};
		if(node.attr)then		
			item.id = tonumber(node.attr.id);
			item.name = node.attr.name;				
			item.portal_gsid = tonumber(node.attr.portal_gsid);
			item.facing = tonumber(node.attr.facing);
			item.pos = commonlib.LoadTableFromString(node.attr.pos);						
		end
		portal_item[item.id]=item;
	end
	System.SystemInfo.SetField("IslandPortal", portal_item);
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30609);

	--commonlib.echo("------------------portal_item---------------");
	--commonlib.echo(portal_item);

	---- create npc instances of the IslandPortal
	local i,_;
	for i,_ in pairs(portal_item) do 
		local portal_model = NPC.GetNpcModelFromIDAndInstance(30609, portal_item[i].id);
		if(portal_model) then
		else
			local params = commonlib.deepcopy(base_portal_param);
			--params.instance = i;
			params.instance = portal_item[i].id;
			params.name = portal_item[i].name;
			params.position = portal_item[i].pos;
			params.facing = portal_item[i].facing;
			params.assetfile_char = "character/common/dummy/elf_size/elf_size.x";
			local NPC = MyCompany.Aries.Quest.NPC;
			--commonlib.echo("------------------portal_model---------------");
			--commonlib.echo(params);

			local npcChar = NPC.CreateNPCCharacter(30609, params);
  			local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30609);
	  		local isLighten = hasGSItem(portal_item[i].portal_gsid);

			-- 按策划要求，强行打开各岛传送门 2012.5.21
			local asset_file;
			local scale_char = 2;
			if (not isLighten) then
			  System.Item.ItemManager.PurchaseItem(portal_item[i].portal_gsid, 1, function(msg)
						if(msg.issuccess) then
    						local NPC = MyCompany.Aries.Quest.NPC;
							local portal_char = NPC.GetNpcCharacterFromIDAndInstance(30609, portal_item[i].id);
							if(portal_char) then
								local asset_keyname = portal_char:GetPrimaryAsset():GetKeyName();
								asset_file = "character/v5/09effect/DeliverDoorEfc/DeliverDoorEfc.x";
								if(asset_keyname ~= asset_file) then
								-- change the NPC name and character asset file
									NPC.ChangeCharacterAsset(30609, portal_item[i].id, asset_file);
								end
								portal_char:SetScale(1);
							end	
						end
					end, function() end, nil, "none");					
			else
				asset_file = "character/v5/09effect/DeliverDoorEfc/DeliverDoorEfc.x";
				scale_char = 1;
				local portal_char = NPC.GetNpcCharacterFromIDAndInstance(30609, portal_item[i].id);
				if(portal_char) then
					local asset_keyname = portal_char:GetPrimaryAsset():GetKeyName();
					if(asset_keyname ~= asset_file) then
					-- reset the NPC name and model asset file
						NPC.ChangeCharacterAsset(30609, portal_item[i].id, asset_file);
					end
					portal_char:SetScale(scale_char);
				end	
			end

			--local asset_file;
			--local scale_char = 2;
			--if(isLighten == true) then
				--asset_file = "character/v5/09effect/DeliverDoorEfc/DeliverDoorEfc.x";
				--scale_char = 1;
			--else
				--asset_file = "character/common/dummy/elf_size/elf_size.x";
				--scale_char = 3;
			--end
			----log("+++++++portal_item return: #"..portal_item.."|"..asset_file.."|"..i.." +++++++\n");		
			--local portal_char = NPC.GetNpcCharacterFromIDAndInstance(30609, portal_item[i].id);
			--if(portal_char) then
				--local asset_keyname = portal_char:GetPrimaryAsset():GetKeyName();
				--if(asset_keyname ~= asset_file) then
				---- reset the NPC name and model asset file
					--NPC.ChangeCharacterAsset(30609, portal_item[i].id, asset_file);
				--end
				--portal_char:SetScale(scale_char);
			--end						
		end
	end
end

function IslandPortal.main_portal()
end

function IslandPortal.PreDialog_portal(npc_id, instance)	
	return true;
end

function IslandPortal.PreDialog()	
	return true;
end

function IslandPortal.PreDialog(npc_id, instance)
	return true;
end
