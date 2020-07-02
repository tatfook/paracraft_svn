--[[
Title: The battle quick word menu
Author(s): LiXizhi
Date: 2011/3/14
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/BattleQuickWord.teen.lua");
MyCompany.Aries.ChatSystem.BattleQuickWord_Teen.OnQuickword();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");

local BattleQuickWord_Teen = commonlib.gettable("MyCompany.Aries.ChatSystem.BattleQuickWord_Teen");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");


function BattleQuickWord_Teen.OnQuickword(x,y,width,height)
	x = x or 0;
	y = y or 0;
	width = width or 0;
	height = height or 0;
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_Quickword_Teen");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_BattleChat_Quickword",
			width = 170,
			subMenuWidth = 300,
			height = 350, -- add 30(menuitemHeight) for each new line. 
			AutoPositionMode = "_lt",
		};
		CommonCtrl.AddControl("Aries_BattleChat_Quickword",ctl);
		BattleQuickWord_Teen.RefreshQuickword();
	end
	-- Note: 2009.9.29. Xizhi: if u ever added new menu items, please modify the height of the menu item, because animation only support "_lt" alignment. 
	ctl:Show(x+width, y+0);
end

-- @param filename: if nil, it will defaults to "config/Aries/Combat.Quickword.xml"
-- return XML root object of the quick words
function BattleQuickWord_Teen.GetQuickWordFromFile(filename)
	filename = filename or "config/Aries/Combat.Quickword.teen.xml";
	BattleQuickWord_Teen.xmlRoot = BattleQuickWord_Teen.xmlRoot or ParaXML.LuaXML_ParseFile(filename);
	if(not BattleQuickWord_Teen.xmlRoot) then
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
	return BattleQuickWord_Teen.xmlRoot;
end

-- as array of strings
function BattleQuickWord_Teen.GetQuickWordAsArray()
	local xmlRoot = BattleQuickWord_Teen.GetQuickWordFromFile()
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

function BattleQuickWord_Teen.RefreshQuickword()
	
	local xmlRoot = BattleQuickWord_Teen.GetQuickWordFromFile()
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
		
		local node_category;
		for node_category in commonlib.XPath.eachNode(xmlRoot, "/quickwords/category") do
			if(node_category.attr and node_category.attr.name) then
				subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = node_category.attr.name, Name = "looped", Type = "Menuitem"});
				local node_sentence;
				for node_sentence in commonlib.XPath.eachNode(node_category, "/node") do
					subNode:AddChild(CommonCtrl.TreeNode:new({Text = node_sentence.attr.sentence, Name = "xx", Type = "Menuitem", onclick = BattleQuickWord_Teen.SendQuickword, }));
				end
			end	
		end

		local node_sentence;
		for node_sentence in commonlib.XPath.eachNode(xmlRoot, "/quickwords/node") do
			node:AddChild(CommonCtrl.TreeNode:new({Text = node_sentence.attr.sentence, Name = "xx", Type = "Menuitem", onclick = BattleQuickWord_Teen.SendQuickword, }));
		end
	end
end

-- send quick word
function BattleQuickWord_Teen.SendQuickword(node)
	ChatChannel.SendMessage( ChatChannel.EnumChannels.NearBy, nil, nil, node.Text )
end