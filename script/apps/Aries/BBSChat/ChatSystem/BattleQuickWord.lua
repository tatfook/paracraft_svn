--[[
Title: The battle quick word menu
Author(s): LiXizhi
Date: 2011/3/14
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/BattleQuickWord.lua");
MyCompany.Aries.ChatSystem.BattleQuickWord.OnQuickword();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");

local BattleQuickWord = commonlib.gettable("MyCompany.Aries.ChatSystem.BattleQuickWord");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");


function BattleQuickWord.OnQuickword(x,y, width, height)
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_Quickword");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_BattleChat_Quickword",
			width = 170,
			subMenuWidth = 300,
			height = 350, -- add 30(menuitemHeight) for each new line. 
			AutoPositionMode = "_lt",
			style = CommonCtrl.ContextMenu.DefaultStyleThick,
			--[[
			{
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 18,
				borderRight = 10,
				
				fillLeft = 0,
				fillTop = -15,
				fillWidth = 0,
				fillHeight = -24,
				
				titlecolor = "#e1ccb6",
				level1itemcolor = "#e1ccb6",
				level2itemcolor = "#ffffff",
				
				-- menu_bg = "Texture/Aries/Chat/newbg1_32bits.png;0 0 128 192:40 41 20 17",
				menu_bg = "Texture/Aries/Chat/newbg2_32bits.png;0 0 195 349:17 41 8 9",
				menu_lvl2_bg = "Texture/Aries/Chat/newbg2_32bits.png;0 0 195 349:17 41 8 9",
				shadow_bg = nil,
				separator_bg = "", -- : 1 1 1 4
				item_bg = "Texture/Aries/Chat/fontbg1_32bits.png;0 0 103 26: 1 1 1 1",
				expand_bg = "Texture/Aries/Chat/arrowup_32bits.png; 0 0 15 16",
				expand_bg_mouseover = "Texture/Aries/Chat/arrowon_32bits.png; 0 0 15 16",
				
				menuitemHeight = 30,
				separatorHeight = 2,
				titleHeight = 26,
				
				titleFont = "System;14;bold";
			},]]
		};

		BattleQuickWord.RefreshQuickword();
	end
	
	if(not x or not width) then
		x,y,width, height = ParaUI.GetUIObject("BattleChatBtn"):GetAbsPosition();
	end
	-- Note: 2009.9.29. Xizhi: if u ever added new menu items, please modify the height of the menu item, because animation only support "_lt" alignment. 
	ctl:Show(x+width, y+0);
end

-- @param filename: if nil, it will defaults to "config/Aries/Combat.Quickword.xml"
-- return XML root object of the quick words
function BattleQuickWord.GetQuickWordFromFile(filename)
	filename = filename or "config/Aries/Combat.Quickword.xml";
	BattleQuickWord.xmlRoot = BattleQuickWord.xmlRoot or ParaXML.LuaXML_ParseFile(filename);
	if(not BattleQuickWord.xmlRoot) then
		commonlib.log("error: failed loading quickword config file %s, using default\n", filename);
		-- use default config file xml root
		xmlRoot =  
		{
		  {
			{
			  { attr={ sentence="我的西瓜仔给我找到了新种子。" }, name="node" },
			  attr={ name="问好" },
			  n=1,
			  name="category" 
			},
			n=1,
			name="quickwords" 
		  },
		  n=1 
		};
	end
	return BattleQuickWord.xmlRoot;
end

-- as array of strings
function BattleQuickWord.GetQuickWordAsArray()
	local xmlRoot = BattleQuickWord.GetQuickWordFromFile()
	if(not xmlRoot) then 
		return 
	end
	local out = {};
	-- read attributes of npl worker states
	local node_sentence;
	for node_sentence in commonlib.XPath.eachNode(xmlRoot, "//node") do
		out[#out+1] = node_sentence.attr.sentence;
	end
	return out;
end

function BattleQuickWord.RefreshQuickword()
	
	local xmlRoot = BattleQuickWord.GetQuickWordFromFile()
	if(not xmlRoot) then 
		return 
	end
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_Quickword");
	if(ctl) then
		local node = ctl.RootNode;
		-- clear all children first
		node:ClearAllChildren();
		
		local subNode;
		-- name node: for displaying name of the selected object. Click to display property
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "快捷语言", Name = "name", Type="Title", NodeHeight = 26 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "----------------------", Name = "titleseparator", Type="separator", NodeHeight = 4 });
		-- by categories
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Quickwords", Name = "actions", Type = "Group", NodeHeight = 0 });
		
		-- read attributes of npl worker states
		local node_category;
		for node_category in commonlib.XPath.eachNode(xmlRoot, "/quickwords/category") do
			if(node_category.attr and node_category.attr.name) then
				subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = node_category.attr.name, Name = "looped", Type = "Menuitem"});
				local node_sentence;
				for node_sentence in commonlib.XPath.eachNode(node_category, "/node") do
					subNode:AddChild(CommonCtrl.TreeNode:new({Text = node_sentence.attr.sentence, Name = "xx", Type = "Menuitem", onclick = BattleQuickWord.SendQuickword, }));
				end
			end	
		end
		local node_sentence;
		for node_sentence in commonlib.XPath.eachNode(xmlRoot, "/quickwords/node") do
			node:AddChild(CommonCtrl.TreeNode:new({Text = node_sentence.attr.sentence, Name = "xx", Type = "Menuitem", onclick = BattleQuickWord.SendQuickword, }));
		end
	end
end

-- send quick word
function BattleQuickWord.SendQuickword(node)
	ChatChannel.SendMessage( ChatChannel.EnumChannels.NearBy, nil, nil, node.Text )
end