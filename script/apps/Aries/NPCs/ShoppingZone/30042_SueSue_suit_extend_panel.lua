--[[
Title: SueSue_suit_extend_panel
Author(s): Leio
Date: 2010/11/29

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_suit_extend_panel.lua");
local SueSue_suit_extend_panel = commonlib.gettable("MyCompany.Aries.Quest.NPCs.SueSue_suit_extend_panel");
SueSue_suit_extend_panel.has_loaded = false;
SueSue_suit_extend_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/ide/XPath.lua");
local XPath = commonlib.XPath
local SueSue_suit_extend_panel = commonlib.gettable("MyCompany.Aries.Quest.NPCs.SueSue_suit_extend_panel");
SueSue_suit_extend_panel.file_path = "config/Aries/Others/suit_extend.xml";
SueSue_suit_extend_panel.list = {};

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local LOG = LOG;


function SueSue_suit_extend_panel.OnInit()
	local self = SueSue_suit_extend_panel; 
	self.page = document:GetPageCtrl();
end
function SueSue_suit_extend_panel.ShowPage()
	local self = SueSue_suit_extend_panel;
	self.LoadXmlFile();
	local menu_level = self.AutoOpen() or "1";
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_suit_extend_panel.html", 
			name = "SueSue_suit_extend_panel.ShowPage", 
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
	self.DoSelectedNode(menu_level,"1")
end
--根据自己的级别 自动打开适合的分类
function SueSue_suit_extend_panel.AutoOpen()
	local self = SueSue_suit_extend_panel;
	local combatlevel = 1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end
	local temp = {};
	local folder;
	for folder in commonlib.XPath.eachNode(self.menu_datasource, "//root/folder") do
		local level = tonumber(folder.attr.level);
		table.insert(temp,{
			level = level,
			folder = folder,
		});
	end
	table.sort(temp,function(a,b)
		local level_1 = a.level or 0;
		local level_2 = b.level or 0;
		return level_1 > level_2
	end);
	local k,v;
	for k,v in ipairs(temp) do
		if(v.level and combatlevel >= v.level)then
			v.folder.attr.is_opened = true;
			return v.folder.attr.menu_level;
		end
	end
	local node = temp[1];
	if(node)then
		node.folder.attr.is_opened = true;
		return node.folder.attr.menu_level
	end
end
function SueSue_suit_extend_panel.DoSelectedNode(parent_level,level)
	local self = SueSue_suit_extend_panel;
	if(self.menu_datasource and parent_level and level)then
        local list = {};
		local folder;
		for folder in commonlib.XPath.eachNode(self.menu_datasource, "//root/folder") do
			if(folder.attr.menu_level == parent_level)then
				local node;
				for node in commonlib.XPath.eachNode(folder, "//items") do
					if(node.attr.menu_level == level)then
						local item_node;
        				for item_node in commonlib.XPath.eachNode(node, "//item") do
							table.insert(list,item_node.attr);
						end
						self.selected_parent_item = folder.attr;
						self.selected_item = node.attr;
					end
				end
				self.list = list;
				if(self.page)then
					
					local function get_gsid(name)
						local k,v;
						for k,v in ipairs(self.list) do
							if(v.label == name)then
								return tonumber(v.gsid);
							end
						end
					end
					local head_gsid = get_gsid("head");
					local body_gsid = get_gsid("body");
					local shoe_gsid = get_gsid("shoe");
					local backside_gsid = get_gsid("backside");
					local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
					local css_table = {
						[2] = head_gsid, 
						[5] = body_gsid, 
						[7] = shoe_gsid, 
						[8] = backside_gsid, 
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
function SueSue_suit_extend_panel.LoadXmlFile()
	local self = SueSue_suit_extend_panel;
	local path = self.file_path;
	if(not self.has_loaded)then
		self.list = {};
		self.has_loaded = true;
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		if(not xmlRoot)then return end
		self.menu_datasource = xmlRoot;
	end
end
function SueSue_suit_extend_panel.DS_Func(index)
	local self = SueSue_suit_extend_panel;
	if(not self.list)then return nil end
	if(index == nil) then
		return #(self.list);
	else
		return self.list[index];
	end
end


