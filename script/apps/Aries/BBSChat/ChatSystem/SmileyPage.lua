--[[
Title:  
Author(s): leio
Date: 2011/12/08
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/SmileyPage.lua");
local SmileyPage = commonlib.gettable("MyCompany.Aries.ChatSystem.SmileyPage");
SmileyPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatEdit.lua");
local ChatEdit = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatEdit");
local SmileyPage = commonlib.gettable("MyCompany.Aries.ChatSystem.SmileyPage");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

--符号顺序必须递增
SmileyPage.symbols = {
	{ icon = "Texture/Aries/Smiley/face01_32bits.png", symbol="$1", gsid=1},
	{ icon = "Texture/Aries/Smiley/animated/face02_32bits_fps10_a003.png", symbol="$2", gsid=2},
	{ icon = "Texture/Aries/Smiley/animated/face03_32bits_fps10_a003.png", symbol="$3", gsid=3},
	{ icon = "Texture/Aries/Smiley/animated/face04_32bits_fps10_a005.png", symbol="$4", gsid=4},
	{ icon = "Texture/Aries/Smiley/animated/face05_32bits_fps10_a004.png", symbol="$5", gsid=5},
	{ icon = "Texture/Aries/Smiley/animated/face06_32bits_fps10_a003.png", symbol="$6", gsid=6},
	{ icon = "Texture/Aries/Smiley/animated/face07_32bits_fps10_a003.png", symbol="$7", gsid=7},
	{ icon = "Texture/Aries/Smiley/animated/face08_32bits_fps10_a005.png", symbol="$8", gsid=8},
	{ icon = "Texture/Aries/Smiley/animated/face09_32bits_fps10_a005.png", symbol="$9", gsid=9},
	{ icon = "Texture/Aries/Smiley/animated/face10_32bits_fps10_a005.png", symbol="$10", gsid=10},
	{ icon = "Texture/Aries/Smiley/animated/face11_32bits_fps10_a004.png", symbol="$11", gsid=11},
	{ icon = "Texture/Aries/Smiley/face12_32bits.png", symbol="$12", gsid=12},
	{ icon = "Texture/Aries/Smiley/animated/face13_32bits_fps10_a003.png", symbol="$13", gsid=13},
	{ icon = "Texture/Aries/Smiley/face14_32bits.png", symbol="$14", gsid=14},
	{ icon = "Texture/Aries/Smiley/face15_32bits.png", symbol="$15", gsid=15},
}

local gsid_map = {};
local index, item
for index, item in ipairs(SmileyPage.symbols) do
	gsid_map[item.gsid] = item;
end

function SmileyPage.DS_Func_Items(index)
	local self = SmileyPage;
	if(not self.symbols)then return 0 end
	if(index == nil) then
		return #(self.symbols);
	else
		return self.symbols[index];
	end
end
function SmileyPage.OnInit()
	local self = SmileyPage;
	self.page = document:GetPageCtrl();
end
function SmileyPage.ShowPage()
	local self = SmileyPage;
	self.last_caret = ChatEdit.GetCurCaretPosition();

	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	if(not x) then
		return
	end
	x = x+width/2-15;
	if(x<0) then
		x = 0;
	end

	local params = {
			url = "script/apps/Aries/BBSChat/ChatSystem/SmileyPage.teen.html", 
			name = "SmileyPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			enable_esc_key = true,
			isTopLevel = false,
			allowDrag = true,
			directPosition = true,
				align = "_lt",
				x = x,
				y = y-180,
				width = 250,
				height = 180,
		};

	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

-- for kids version only. 
function SmileyPage.ShowPage_Kids(bShow)
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	if(not x or not width) then
		return
	end
	x = x+width/2-65;
	if(x<0) then
		x = 0;
	end
	width, height = 275, 177;
	local _mainWnd = ParaUI.GetUIObject("AriesSmileySelector");
	
	if(_mainWnd:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		_mainWnd = ParaUI.CreateUIObject("container", "AriesSmileySelector", "_fi", 0,0,0,0);
		_mainWnd.background = "";
		_mainWnd.zorder = 1;
		_mainWnd:AttachToRoot();
		
		_mainWnd.onmouseup = [[;MyCompany.Aries.Desktop.Dock.OnClickSmiley(false);]];
		
		local _content = ParaUI.CreateUIObject("container", "Content", "_lt", x, y-height, width, height);
		
		_content.background = "";
		_content.zorder = 1;
		_mainWnd:AddChild(_content);
		
		local contentPage = System.mcml.PageCtrl:new({url = "script/apps/Aries/BBSChat/ChatSystem/SmileyPage.kids.html"});
		contentPage:Create("SmileySelector", _content, "_fi", 0, 0, 0, 0);
	else
		-- toggle visibility if bShow is nil
		if(bShow == nil) then
			bShow = not _mainWnd.visible;
		end
		_mainWnd.visible = bShow;
		if(bShow) then
			_mainWnd:GetChild("Content"):Reposition("_lt", x, y-height, width, height)
		end
	end
end

function SmileyPage.SendSmiley(index)
	if(not index)then return end
	local self = SmileyPage;
	local node = self.symbols[index] or {};
	--ChatEdit.InsertSymbol(node.symbol,self.last_caret);
	--直接发送
	ChatChannel.SendMessage( ChatChannel.EnumChannels.NearBy, nil, nil, node.symbol );
end

function SmileyPage.DoClick(index)
	SmileyPage.SendSmiley(index)
	if(SmileyPage.page)then
		SmileyPage.page:CloseWindow();
	end
end

function SmileyPage.HasSymbol(s)
	if(not s)then return end
	local self = SmileyPage;
	if(string.find(s,"$[0-9]"))then
		return true;
	end	
end

-- remove gsid that is not owned by the current user
function SmileyPage.RemoveNotOwnedGsid(s)
	if(not SmileyPage.HasSymbol(s))then
		return s;
	end
	local pre_text, gsid, post_text;
	local out = {};
	for pre_text, gsid, post_text in s:gmatch("([^$]*)$(%d+)([^$]*)") do
		out[#out+1] = pre_text;
		gsid = tonumber(gsid);
		if(gsid) then
			local item = gsid_map[gsid];
			if(not item) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					if(gsItem.template.cangift and gsItem.template.canexchange) then
						-- only allow tradable items to be displayed this way, to prevent user sending other unnecessary stuff. 
						local bHas = ItemManager.IfOwnGSItem(gsid);
						if(bHas) then
							out[#out+1] = format("$%d", gsid);
						end
					end
				end
			else
				out[#out+1] = format("$%d", gsid);
			end
		end
		out[#out+1] = post_text;
	end
	return table.concat(out);
end

-- remove smiley symbol, but leaves gsid symbols
-- @param bCheckOwn: if true, the current user must own the smiley 
function SmileyPage.RemoveSmiley(s)
	if(not SmileyPage.HasSymbol(s))then
		return s;
	end

	local pre_text, gsid, post_text;
	local out = {};
	for pre_text, gsid, post_text in s:gmatch("([^$]*)$(%d+)([^$]*)") do
		out[#out+1] = pre_text;
		gsid = tonumber(gsid);
		if(gsid) then
			local item = gsid_map[gsid];
			if(not item) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					if(gsItem.template.cangift and gsItem.template.canexchange) then
						-- only allow tradable items to be displayed this way, to prevent user sending other unnecessary stuff. 
						out[#out+1] = format("$%d", gsid);
					end
				end
			end
		end
		out[#out+1] = post_text;
	end
	return table.concat(out);
end

function SmileyPage.ChangeToMcml(s, icon_size)
	local self = SmileyPage;
	if(not SmileyPage.HasSymbol(s))then
		return s;
	end
	icon_size = icon_size or 32;

	local pre_text, gsid, post_text;
	local out = {};
	for pre_text, gsid, post_text in s:gmatch("([^$]*)$(%d+)([^$]*)") do
		out[#out+1] = pre_text;
		gsid = tonumber(gsid);
		if(gsid) then
			local item = gsid_map[gsid];
			if(item) then
				local icon = item.icon;
				local symbol = item.symbol;
				local img = string.format([[<img style='width:%dpx;height:%dpx;background:url(%s)' />]],icon_size,icon_size, icon);
				out[#out+1] = img;
			else
				local itemname = CommonCtrl.GenericTooltip.GetItemMCMLText(gsid,nil, nil, "class='bordertext'");
				if(itemname) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem) then
						local pure_name = gsItem.template.name;
						if(gsItem.template.cangift and gsItem.template.canexchange) then
							-- only allow tradable items to be displayed this way, to prevent user sending other unnecessary stuff. 
							if(itemname and not pure_name:match("未使用") and not pure_name:match("废弃") and not pure_name:match("废除")) then
								out[#out+1] = itemname;
							end
						end
					end
				end
			end
		end
		out[#out+1] = post_text;
	end
	return table.concat(out);
end
