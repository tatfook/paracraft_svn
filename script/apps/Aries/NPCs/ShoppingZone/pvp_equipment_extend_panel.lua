--[[
Title: pvp_equipment_extend_panel
Author(s): Leio
Date: 2010/11/29

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/pvp_equipment_extend_panel.lua");
MyCompany.Aries.Quest.NPCs.pvp_equipment_extend_panel.has_loaded = false;
MyCompany.Aries.Quest.NPCs.pvp_equipment_extend_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/ide/XPath.lua");
local XPath = commonlib.XPath
-- create class
local libName = "pvp_equipment_extend_panel";


local pvp_equipment_extend_panel = commonlib.gettable("MyCompany.Aries.Quest.NPCs.pvp_equipment_extend_panel");

pvp_equipment_extend_panel.file_path = "config/Aries/Others/pvp_equipment_extend.xml";
pvp_equipment_extend_panel.list = {};

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local LOG = LOG;


function pvp_equipment_extend_panel.OnInit()
	local self = pvp_equipment_extend_panel; 
	self.page = document:GetPageCtrl();
end

function pvp_equipment_extend_panel.ShowPage()
	local self = pvp_equipment_extend_panel;
	self.LoadXmlFile();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/ShoppingZone/pvp_equipment_extend_panel.html", 
			name = "pvp_equipment_extend_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -870/2,
				y = -512/2,
				width = 870,
				height = 512,
		});
	self.DoSelectedNode("1","1")
end
function pvp_equipment_extend_panel.DoShowNode(gsid)
	local self = pvp_equipment_extend_panel;
	gsid = tonumber(gsid);
	if(not gsid)then return end
	if(self.page)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(not gsItem)then
			return;
		end
		local assetfile = gsItem.assetfile;
		if(not assetfile or assetfile == "")then
			return
		end
		--model
		local asset = Map3DSystem.App.Assets.asset:new({filename = assetfile})
		local objParams = asset:getModelParams()
		if(objParams ~= nil) then
			objParams.facing = 0;
			if(gsid == 16069 or gsid == 16070 or gsid == 16073 or gsid == 16072 )then
				objParams.scaling = 0.5;
			end
			local canvasCtl = self.page:FindControl("SuitAvatar");
			if(canvasCtl) then
				canvasCtl:ShowModel(objParams);
			end
			self.page:SetValue("SuitAvatar", commonlib.serialize_compact(objParams));
		end
	end
end
function pvp_equipment_extend_panel.DoSelectedNode(parent_level,level)
	local self = pvp_equipment_extend_panel;
	if(self.menu_datasource and parent_level and level)then
        local list = {};
		local folder;
		for folder in commonlib.XPath.eachNode(self.menu_datasource, "//root/folder") do
			if(folder.attr.level == parent_level)then
				local node;
				for node in commonlib.XPath.eachNode(folder, "//items") do
					if(node.attr.level == level)then
						local item_node;
        				for item_node in commonlib.XPath.eachNode(node, "//item") do
							table.insert(list,item_node.attr);
						end
						self.selected_item = node.attr;
					end
				end
				self.list = list;
				if(self.page)then
					
					local function get_gsid(name)
						local k,v;
						for k,v in ipairs(self.list) do
							if(v.type == name)then
								return tonumber(v.gsid);
							end
						end
					end
					local head_gsid = get_gsid("hat");
					local body_gsid = get_gsid("shirt");
					local shoe_gsid = get_gsid("boot");
					local backside_gsid = get_gsid("back");
					local wand_gsid = get_gsid("wand");
					local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
					local css_table = {
						[2] = head_gsid, 
						[5] = body_gsid, 
						[7] = shoe_gsid, 
						[8] = backside_gsid, 
						[11] = wand_gsid, 
					}
					local cssinfo = CCS.GetCCSInfoString(nil, true, css_table);
					local asset_table = {
						name = "user_createnewavatar",
						AssetFile="character/v3/Elf/Female/ElfFemale.xml",
						CCSInfoStr = cssinfo,
						IsCharacter = true,
						x=0,y=0,z=0,
					};
					self.page:SetValue("SuitAvatar",commonlib.serialize(asset_table));

					self.page:Refresh(0);
				end
			end
		end
    end
end
function pvp_equipment_extend_panel.LoadXmlFile()
	local self = pvp_equipment_extend_panel;
	local path = self.file_path;
	if(not self.has_loaded)then
		self.list = {};
		self.has_loaded = true;
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		if(not xmlRoot)then return end
		self.menu_datasource = xmlRoot;
	end
end
function pvp_equipment_extend_panel.DS_Func(index)
	local self = pvp_equipment_extend_panel;
	if(not self.list)then return nil end
	if(index == nil) then
		return #(self.list);
	else
		return self.list[index];
	end
end
function pvp_equipment_extend_panel.GoShop()
	NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
	MyCompany.Aries.HaqiShop.ShowMainWnd("tabInventory","2010");
end
