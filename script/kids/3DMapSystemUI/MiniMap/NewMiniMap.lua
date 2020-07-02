--[[
Title: New Mini Map Page
Author(s): zrf
Date: 2010/11/23
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/NewMiniMap.lua");

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/OpenFileDialog.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/SwfMapPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapWnd.lua");
local NewMiniMap = commonlib.gettable("Map3DSystem.App.MiniMap.NewMiniMap");
local L = CommonCtrl.Locale("IDE");


--测试代码
--NewMiniMap.anchor = {
--{MapCoord="502, 315", AvatarPosition="20171.2578125, 19871.845703125" },
--{MapCoord="210, 302", AvatarPosition="19579.876953125, 19935.251953125" },
--{MapCoord="354, 112", AvatarPosition="19721.35546875, 20378.6328125" },
--{MapCoord="342, 83", AvatarPosition="19652.88671875, 20420.953125" },
--{MapCoord="217, 348", AvatarPosition="19606.060546875, 19790.08203125" },
--
--};

function NewMiniMap.Init()
	NewMiniMap.page = document:GetPageCtrl();
	if(NewMiniMap.anchor)then
		NewMiniMap.ResetNodes();
	end
end

function NewMiniMap.LoadFile()
	local page = NewMiniMap.page;
	local ctl = CommonCtrl.OpenFileDialog:new{

		name = "OpenFileDialog3",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		CheckFileExists = true,
		fileextensions = {L"小地图文件(*.jpg;*.png;*.bmp;*.dds)",},
		folderlinks = {
			{path = dir, text = dir},
			{path = "Model/", text = L"Model"},
			{path = "Texture/", text = L"Texture"},
			{path = "character/", text = L"Character"},
			{path = "script/", text = L"Script"},
			{path = "/", text = L"Root Directory"},
		},
		onopen = function(name, filename)
			if(filename and filename ~= "" )then			
				NewMiniMap.image = commonlib.Encoding.DefaultToUtf8(filename);
				if(NewMiniMap.page)then
					NewMiniMap.page:Refresh(0.01);
				end
			end
		end

	};

	ctl:Show(true);
end

function NewMiniMap.GetImage()
	if(NewMiniMap.image)then
		return NewMiniMap.image;
	else
		return "";
	end
end

function NewMiniMap.ShowMarker()
	if(NewMiniMap.selectx and NewMiniMap.selecty )then
		local str1 = [[<img name="marker" zorder="10" style="margin-left:%dpx;margin-top:%dpx;width:32px;height:32px" src="/Texture/ico.png" />]];
		local str2 = string.format(str1, NewMiniMap.selectx-12, NewMiniMap.selecty-12 );
		return str2;
	else
		return "";
	end
end
--

function NewMiniMap.OnClickSelect()
	Map3DSystem.App.MiniMap.SwfMapPage.swfile = "Map.swf";
	Map3DSystem.App.MiniMap.GenMiniMapPage.SetSwfRect();
	Map3DSystem.App.MiniMap.SwfMapPage.tilesFolder = Map3DSystem.App.MiniMap.GenMiniMapPage.GetSaveClip();
	--commonlib.echo("!!!!!!!!!!:OnClickSelect");
	--commonlib.echo(Map3DSystem.App.MiniMap.SwfMapPage.tilesFolder);
	Map3DSystem.App.MiniMap.SwfMapPage.ShowPage( nil, true );
end

function NewMiniMap.OnClickMap()
	local page = NewMiniMap.page;

	if(page)then
		local obj = page:FindControl("minimap");
		if(obj)then
			local x1, y1 = ParaUI.GetMousePosition();
			local x2, y2 = obj:GetAbsPosition();
			NewMiniMap.selectx = x1 - x2;
			NewMiniMap.selecty = y1 - y2;
			local pos = NewMiniMap.selectx .. ", " .. NewMiniMap.selecty;
			page:SetValue("minimappos", pos);
			page:Refresh(0.01);
		end
	end
end

function NewMiniMap.SetWorldPos(x,y)
	local page = NewMiniMap.page;
	local pos = x .. ", " .. y;
	page:SetValue("worldpos", pos);
	page:Refresh(0.01);
end

function NewMiniMap.DS()
	--commonlib.echo("!!!!!!!!!!!:DS");
	--commonlib.echo(NewMiniMap.nodes);
	return NewMiniMap.nodes;
end

function NewMiniMap.LoadXML(filename)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading anchor file: %s\n", filename);
		return;
	end

	local xmlnode = "/anchor";
	NewMiniMap.anchor = {};
	local each_anchor;
	for each_anchor in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		local anchor = {};			
		anchor.MapCoord = each_anchor.attr.MapCoord;
		anchor.AvatarPosition = each_anchor.attr.AvatarPosition;
		table.insert( NewMiniMap.anchor, anchor );
	end
	NewMiniMap.ResetNodes();

	if(NewMiniMap.page)then
		NewMiniMap.page:Refresh(0.01);
	end
end

function NewMiniMap.SaveXML(filename)
	--commonlib.echo("!!!!!!!!!!!!!!:SaveXML");
	--commonlib.echo(NewMiniMap.anchor);
	if(NewMiniMap.anchor)then
		local str = [[<?xml version="1.0" encoding="utf-8"?> ]] .. "\r\n";
		local i;
		for i=1,#(NewMiniMap.anchor) do
			local anchor = NewMiniMap.anchor[i];
			local str0 = string.format([[<anchor  MapCoord="%s" AvatarPosition="%s" />]] , anchor.MapCoord, anchor.AvatarPosition );
			str = str .. str0  .. "\r\n";
		end

		ParaIO.CreateDirectory(filename);
		local file = ParaIO.open(filename, "w");
	--commonlib.echo("!!!!!!!!!!!!!!:SaveXML2");

		if(file:IsValid()) then
	--commonlib.echo("!!!!!!!!!!!!!!:SaveXML3");

			file:WriteString(str);
			file:close();
			_guihelper.MessageBox("生成成功："..filename);
		end
	end
end

function NewMiniMap.LoadXMLFile()
	local page = NewMiniMap.page;
	local ctl = CommonCtrl.OpenFileDialog:new{

		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		CheckFileExists = true,
		fileextensions = {L"锚点文件(*.xml)",},
		folderlinks = {
			{path = dir, text = dir},
			{path = "Model/", text = L"Model"},
			{path = "Texture/", text = L"Texture"},
			{path = "character/", text = L"Character"},
			{path = "script/", text = L"Script"},
			{path = "/", text = L"Root Directory"},
		},
		onopen = function(name, filename)
			if(filename and filename ~= "" )then			
				local filename_unicode = commonlib.Encoding.DefaultToUtf8(filename);
				NewMiniMap.LoadXML(filename_unicode);
			end
		end

	};

	ctl:Show(true);
end

function NewMiniMap.BuildAnchorCodeFromXML(filename)
	--commonlib.echo("!!!!!!!!!!!:BuildAnchorCodeFromXML 0");
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading anchor file: %s\n", filename);
		return;
	end
	--commonlib.echo("!!!!!!!!!!!:BuildAnchorCodeFromXML 1");

	local xmlnode = "/anchor";
	local  anchors = {};
	local each_anchor;
	for each_anchor in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		local anchor = {};			
		anchor.MapCoord = each_anchor.attr.MapCoord;
		anchor.AvatarPosition = each_anchor.attr.AvatarPosition;
		table.insert( anchors, anchor );
	end
	--commonlib.echo("!!!!!!!!!!!:BuildAnchorCodeFromXML 2");

	local i;
	local str = "";
	for i=1, #(anchors) do
		local anchor = anchors[i];
		local tmp = string.format([[<pe:map-anchor MapCoord = "%s" AvatarPosition = "%s"/>]], anchor.MapCoord, anchor.AvatarPosition );
		str = str .. tmp;
	end

	--commonlib.echo("!!!!!!!!!!!:BuildAnchorCodeFromXML");
	--commonlib.echo(str);
	return str;
end

function NewMiniMap.SaveXMLFile()
	local page = NewMiniMap.page;
	local ctl = CommonCtrl.OpenFileDialog:new{

		name = "OpenFileDialog2",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		CheckFileExists = false,
		fileextensions = {L"锚点文件(*.xml)",},
		folderlinks = {
			{path = dir, text = dir},
			{path = "Model/", text = L"Model"},
			{path = "Texture/", text = L"Texture"},
			{path = "character/", text = L"Character"},
			{path = "script/", text = L"Script"},
			{path = "/", text = L"Root Directory"},
		},
		onopen = function(name, filename)
			--commonlib.echo("!!!!!!!!!!!!!!!!!:SaveXMLFile");
			--commonlib.echo(filename);
			if(filename and filename ~= "" )then			
				local filename_unicode = commonlib.Encoding.DefaultToUtf8(filename);
			--commonlib.echo(filename_unicode);

				NewMiniMap.SaveXML(filename_unicode);
			end
		end

	};

	ctl:Show(true);
end

function NewMiniMap.OnClickNode(index,treenode)
	--local index = treenode.mcmlNode:GetPreValue("this").index;
	NewMiniMap.selectidx = index;
	NewMiniMap.page:SetValue("worldpos", NewMiniMap.anchor[index].AvatarPosition );
	NewMiniMap.page:SetValue("minimappos", NewMiniMap.anchor[index].MapCoord );
	local _,_;
	_,_,NewMiniMap.selectx, NewMiniMap.selecty = string.find(NewMiniMap.anchor[index].MapCoord, "(%d+)%s*, %s*(%d+)");
	--commonlib.echo("!!!!!!!!!!!:OnClickNode");
	--commonlib.echo(NewMiniMap.anchor[index].MapCoord);
	--commonlib.echo(NewMiniMap.selectx);
	--commonlib.echo(NewMiniMap.selecty);

	NewMiniMap.page:Refresh(0.01);
end

function NewMiniMap.OnClickReplace()
	local mc = NewMiniMap.page:GetValue("minimappos");
	local ap = NewMiniMap.page:GetValue("worldpos");
	if(mc=="" or ap == "")then
		_guihelper.MessageBox("世界坐标和小地图坐标不能为空!");
		return;
	end

	if(NewMiniMap.selectidx)then
		NewMiniMap.anchor[NewMiniMap.selectidx].MapCoord = mc;
		NewMiniMap.anchor[NewMiniMap.selectidx].AvatarPosition = ap;
		NewMiniMap.ResetNodes();
		_guihelper.MessageBox("替换成功!");
		NewMiniMap.page:Refresh(0.01);
	else
		_guihelper.MessageBox("请选定你需要替换的锚点");
	end
end

function NewMiniMap.OnClickAddNew()
	local mc = NewMiniMap.page:GetValue("minimappos");
	local ap = NewMiniMap.page:GetValue("worldpos");
	if(mc=="" or ap == "")then
		_guihelper.MessageBox("世界坐标和小地图坐标不能为空!");
		return;
	end

	local anchor = {};
	NewMiniMap.anchor = NewMiniMap.anchor or {};
	anchor.MapCoord = mc;
	anchor.AvatarPosition = ap;
	table.insert(NewMiniMap.anchor, anchor);
	NewMiniMap.ResetNodes();
	_guihelper.MessageBox("新项添加成功!");
	NewMiniMap.page:Refresh(0.01);
end

function NewMiniMap.ResetNodes()
	NewMiniMap.nodes = {};
	local i;
	--commonlib.echo("!!!!!!!!!!!!!:ResetNodes");

	--commonlib.echo(#(NewMiniMap.anchor));
	for i=1,#(NewMiniMap.anchor) do
		local anchor = NewMiniMap.anchor[i];
		--commonlib.echo("!!!!!!!!!!:ResetNodes0");
		--commonlib.echo(i);
		NewMiniMap.AppendNode(anchor.MapCoord, anchor.AvatarPosition);
	end

	--commonlib.echo(NewMiniMap.anchor);
	
	--commonlib.echo(NewMiniMap.nodes);
end

function NewMiniMap.AppendNode(MapCoord, AvatarPosition)
	local index = #(NewMiniMap.nodes) + 1;
	local attr = {
		index=index, 
		MapCoord = MapCoord, 
		AvatarPosition = AvatarPosition, 
	};
	table.insert( NewMiniMap.nodes, {name="instance", attr=attr,} );
	--commonlib.echo("!!!!!!!!!!!!!:AppendNode");
	--commonlib.echo(index);
end

function NewMiniMap.GetNodeBG(index)
	if(NewMiniMap.selectidx and NewMiniMap.selectidx == index )then
		return "Texture/aries/quest/questlist/fontbg1_32bits.png";
	else
		return "";
	end
end

function NewMiniMap.OnClickDeleteOne()
	if(NewMiniMap.selectidx)then
		--commonlib.echo("!!!!!!!!!!!!!:OnClickDeleteOne");
		--commonlib.echo(NewMiniMap.anchor);
		table.remove( NewMiniMap.anchor, NewMiniMap.selectidx );
		--commonlib.echo(NewMiniMap.anchor);
		NewMiniMap.selectidx = nil;
		NewMiniMap.selectx = nil;
		NewMiniMap.selecty = nil;
		NewMiniMap.ResetNodes();
		_guihelper.MessageBox("删除成功");
		NewMiniMap.page:Refresh(0.01);
	else
		_guihelper.MessageBox("请选定你需要删除的锚点");
	end
end

function NewMiniMap.OnClickDeleteAll()
	NewMiniMap.anchor = {};
	NewMiniMap.selectidx = nil;
	NewMiniMap.selectx = nil;
	NewMiniMap.selecty = nil;
	NewMiniMap.ResetNodes();
	_guihelper.MessageBox("删除成功");
	NewMiniMap.page:Refresh(0.01);
end