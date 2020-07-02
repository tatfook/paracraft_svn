

NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppModelTable.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditor.lua");

Map3DApp.TileEditWnd = {};
local TileEditWnd = Map3DApp.TileEditWnd;
TileEditWnd.name = "tileEditWnd";
TileEditWnd.x = 0;
TileEditWnd.y = 0;
TileEditWnd.width = 1000;
TileEditWnd.height = 450;
TileEditWnd.parent = nil;

TileEditWnd.attWndWidth = 220;
TileEditWnd.modelViewWidth = 320;

TileEditWnd.tileID = 0;

TileEditWnd.totalModelPage = 1;
TileEditWnd.currentPage = 1;

function TileEditWnd.Show(bShow)
	local self = TileEditWnd;
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self.CreateUI();
	else
		if(bShow == nil)then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		if(bShow)then
		end
	end
end

function TileEditWnd.CreateUI()
	local _this,_parent,_rootParent;
	
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name,"_lt",TileEditWnd.x,TileEditWnd.y,TileEditWnd.width,TileEditWnd.height);
	if(TileEditWnd.parent ~= nil)then
		TileEditWnd.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	_rootParent = _this;
	
	------------------------
	--model grid view
	-------------------------
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."modelSet","_lt",0,0,TileEditWnd.modelViewWidth,TileEditWnd.height);
	_rootParent:AddChild(_this);
	_parent = _this;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/GridView.lua");
	TileEditWnd.modelGridView = Map3DApp.ImageGridView:new{
		name = TileEditWnd.name.."modelGV",
		left = 8,
		top = 4,
		width = TileEditWnd.modelViewWidth - 15,
		height = TileEditWnd.height - 45,
		cellWidth = 96,
		cellHeight = 96,
		scellSpaceX = 4,
		parent = _parent,
		maxCellCount = 12,
		bgImage = "",
	};
	TileEditWnd.modelGridView:Show(true);
	--TileEditWnd.modelGridView:RefreshCells();
	
	local top = TileEditWnd.height - 40
	local left = 24;
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."btnModel","_lt",left,top,32,32);
	_this.text = "M";
	_this.onclick = string.format(";Map3DApp.TileEditWnd.OnFilterBtnClick(%q)",_this.name);
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."btnMark","_lt",left,top,32,32);
	_this.onclick = string.format(";Map3DApp.TileEditWnd.OnFilterBtnClick(%q)",_this.name);
	_this.text = "K";
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."btnLand","_lt",left,top,32,32);
	_this.onclick = string.format(";Map3DApp.TileEditWnd.OnFilterBtnClick(%q)",_this.name);
	_this.text = "L";
	_parent:AddChild(_this);
	 
	left = TileEditWnd.modelViewWidth - 120;
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."btnPre","_lt",left,top,32,32);
	_this.onclick = ";Map3DApp.TileEditWnd.OnPreModelPageClick()";
	_this.text = "<"
	_parent:AddChild(_this);
	
	left = left + 40;
	_this = ParaUI.CreateUIObject("text",TileEditWnd.name.."pageindex","_lt",left,top+10,32,32);
	_this.text = "1/1";
	_parent:AddChild(_this);
	
	left = left + 25;
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."btnNext","_lt",left,top,32,32);
	_this.onclick = ";Map3DApp.TileEditWnd.OnNextModelPageClick()";
	_this.text = ">"
	_parent:AddChild(_this);
	
	
	---------------------
	---tile edit scene
	---------------------
	local _width = TileEditWnd.width - TileEditWnd.modelViewWidth - TileEditWnd.attWndWidth;
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."edit","_lt",TileEditWnd.modelViewWidth,0,_width,TileEditWnd.height);
	_rootParent:AddChild(_this);

	NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppTileEditScene.lua");
	Map3DApp.TileEditScene.SetParent(_this);
	Map3DApp.TileEditScene.Show(true);

	------------------------------
	--attribute page
	-----------------------------
	_width =  TileEditWnd.width - TileEditWnd.attWndWidth
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."att","_lt", _width,0,TileEditWnd.attWndWidth,TileEditWnd.height);
	_rootParent:AddChild(_this);
	_parent = _this;
	_rootParent = _this;
	
	NPL.load("(gl)script/ide/MainMenu.lua");
	_this = CommonCtrl.GetControl(TileEditWnd.name.."attMenu");
	if(_this == nil)then
		_this = CommonCtrl.MainMenu:new{
			name = TileEditWnd.name.."attMenu",
			alignment = "_lt",
			left = 10,
			top = 5,
			width = 200,
			height = 20,
		};
		local node = _this.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "土地", Name = "land", onclick = Map3DApp.TileEditWnd.OnAttMenuClick}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "标记", Name = "mark", onclick = Map3DApp.TileEditWnd.OnAttMenuClick}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "模型", Name = "model",onclick = Map3DApp.TileEditWnd.OnAttMenuClick}));
	end
	_this.parent = _parent;
	_this:Show(true);
	CommonCtrl.MainMenu.OnClickTopLevelMenuItem(TileEditWnd.name.."attMenu",1)
	
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."landInfoBtn","_lb",85,-28,60,20);
	_this.text = "保存修改";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."landInfoBtn","_lb",155,-28,60,20);
	_this.text = "取消";
	_parent:AddChild(_this);
	
	--=============land Info page==============
	local _height = TileEditWnd.height - 60;
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."landPage","_lt",0,25,TileEditWnd.attWndWidth,_height);
	_parent:AddChild(_this);
	_parent = _this;
	
	local scrollTileHeight = 24;
	local scrollPageHeight = _height - 32 - 24;
	local scrollTileSpace = 4;
	
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."landInfoCtn","_lt",0,0,TileEditWnd.attWndWidth,_height-32);
	_parent:AddChild(_this);
	_parent = _this;
	
	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."landInfoBtn","_lt",2,2,TileEditWnd.attWndWidth-4,20);
	_this.text = "土地信息";
	_this.onclick = ";Map3DApp.TileEditWnd.OnMyLandsBtn()";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."landInfo","_lt",0,scrollTileHeight,TileEditWnd.attWndWidth,scrollPageHeight);
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 12, 10, 59, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "土地名称:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("editbox", "textBox1", "_lt", 81, 5, 127, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label2", "_lt", 12, 39, 59, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "家园世界:";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "comboBox1",
		alignment = "_lt",
		left = 81,
		top = 34,
		width = 127,
		height = 20,
		dropdownheight = 106,
 		parent = _parent,
		text = "",
		items = {},
	};
	ctl:Show();

	_this = ParaUI.CreateUIObject("text", "label3", "_lt", 12, 64, 59, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "土地状态:";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "comboBox2",
		alignment = "_lt",
		left = 81,
		top = 61,
		width = 127,
		height = 20,
		dropdownheight = 106,
 		parent = _parent,
		text = "",
		items = {},
	};
	ctl:Show();

	_this = ParaUI.CreateUIObject("text", "label4", "_lt", 12, 91, 35, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "价格:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("editbox", "textBox2", "_lt", 81, 88, 127, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label5", "_lt", 12, 179, 59, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "所属城市:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "label10", "_lt", 81, 121, 47, 12)
	_this.text = "label10";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label7", "_lt", 12, 122, 47, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "所有者:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label11", "_lt", 81, 140, 47, 12)
	_this.text = "label11";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label8", "_lt", 12, 141, 47, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "使用者:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label12", "_lt", 81, 159, 47, 12)
	_this.text = "label12";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label9", "_lt", 12, 160, 59, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "土地评级:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label13", "_lt", 81, 178, 47, 12)
	_this.text = "label13";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label6", "_lt", 12, 198, 59, 12)
	_this:GetFont("text").color = "83 83 83";
	_this.text = "土地编号:";
	_parent:AddChild(_this);


	_this = ParaUI.CreateUIObject("text", "label14", "_lt", 81, 197, 47, 12)
	_this.text = "label14";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."resetBtn","_lb",TileEditWnd.attWndWidth - 75,-25,60,20);
	_this.text = "取消修改";
	_parent:AddChild(_this);
	------------------------
	_parent = ParaUI.GetUIObject(TileEditWnd.name.."landPage");
	top = _height - scrollTileHeight - scrollTileSpace;

	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."myLandsCtn","_lt",0,top,TileEditWnd.attWndWidth,scrollTileHeight);
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."myLandsBtn","_lt",2,2,TileEditWnd.attWndWidth-4,20);
	_this.text = "我的土地";
	_this.onclick = ";Map3DApp.TileEditWnd.OnMyLandsBtn();";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."myLands","_lt",0,scrollTileHeight,TileEditWnd.attWndWidth,scrollPageHeight+4);
	_this.visible = false;
	_parent:AddChild(_this);
	_parent = _this;
	
	_this = CommonCtrl.TreeView:new{
		name = TileEditWnd.name.."myLandsTri",
		alignment = "mt",
		left = 3,
		top = 4,
		width = TileEditWnd.attWndWidth - 10,
		height = 230,
		parent = _parent;
	}
	local node = CommonCtrl.TreeNode:new({Text = "我的土地", Name = "myLands", });
	_this.RootNode:AddChild(node);
	--TODO:delete this:
	local root = node;
	root:AddChild(CommonCtrl.TreeNode:new({Text = "land No.1", Name = "myLands",}));
	root:AddChild(CommonCtrl.TreeNode:new({Text = "land No.2", Name = "myLands", }));
	root:AddChild(CommonCtrl.TreeNode:new({Text = "land No.3", Name = "myLands", }));
	
	_this:Show();
	
	--==============mark Info page=============
	_parent = ParaUI.GetUIObject(TileEditWnd.name.."att");
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."markPage","_lt",0,25,TileEditWnd.attWndWidth,_height);
	_this.visible = false;
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 14, 15, 59, 12)
	_this.text = "标记名称:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("editbox", TileEditWnd.name.."markName", "_lt", 80, 10, 128, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 14, 47, 59, 12)
	_this.text = "关联世界:";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = TileEditWnd.name.."worldLink",
		alignment = "_lt",
		left = 80,
		top = 44,
		width = 128,
		height = 20,
		dropdownheight = 106,
 		parent = _parent,
		text = "",
		items = {},
	};
	ctl:Show();


	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 14, 79, 59, 12)
	_this.text = "世界描述:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("editbox", TileEditWnd.name.."worldDesc", "_lt", 80, 77, 128, 21)
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 14, 111, 59, 12)
	_this.text = "标记样式:";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = TileEditWnd.name.."markStyle",
		alignment = "_lt",
		left = 80,
		top = 111,
		width = 128,
		height = 20,
		dropdownheight = 106,
 		parent = _parent,
		text = "",
		items = {},
	};
	ctl:Show();

	_this = ParaUI.CreateUIObject("text", "label3", "_lt", 14, 143, 59, 12)
	_this.text = "标记类型:";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = TileEditWnd.name.."markType",
		alignment = "_lt",
		left = 80,
		top = 144,
		width = 128,
		height = 20,
		dropdownheight = 106,
 		parent = _parent,
		text = "",
		items = {},
	};
	ctl:Show();

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 14, 181, 47, 12)
	_this.text = "所有者:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 14, 207, 47, 12)
	_this.text = "访问量:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", TileEditWnd.name.."markOwner", "_lt", 78, 181, 47, 12)
	_this.text = "label10";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", TileEditWnd.name.."clickCnt", "_lt", 78, 207, 47, 12)
	_this.text = "label11";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button",TileEditWnd.name.."markResetBtn","_lb",TileEditWnd.attWndWidth - 75,-25,60,20);
	_this.text = "取消修改";
	_parent:AddChild(_this);
	
	--==============model Info page=============
	_parent = ParaUI.GetUIObject(TileEditWnd.name.."att");
	_this = ParaUI.CreateUIObject("container",TileEditWnd.name.."modelPage","_lt",0,25,TileEditWnd.attWndWidth,_height);
	_this.visible = false;
	_parent:AddChild(_this);
	_parent = _this;

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 20, 20, 59, 12)
	_this.text = "模型名称:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", TileEditWnd.name.."modelName", "_lt", 89, 20, 0, 0)
	_this.text = "label2";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 20, 52, 35, 12)
	_this.text = "描述:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", TileEditWnd.name.."modelDesc", "_lt", 89, 52, 0, 0)
	_this.text = "label4";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 20, 87, 35, 12)
	_this.text = "价格:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", TileEditWnd.name.."modelPrice", "_lt", 89, 86, 0, 0)
	_this.text = "label6";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "sl", "_lt", 20, 117, 47, 12)
	_this.text = "生产商:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", TileEditWnd.name.."mftName", "_lt", 89, 117, 0, 0)
	_this.text = "label8";
	_parent:AddChild(_this);
	
	TileEditWnd.OnControlLoad();
end

function TileEditWnd.SwitchLandScrollBar(scrollBarName)
	local self = TileEditWnd;
	local landPage = ParaUI.GetUIObject(self.name.."landPage");
	if(landPage:IsValid() == false)then
		return;
	end
	
	if(landPage.visible ~= true)then
		return;
	end
	
	local __,__,__,height = landPage:GetAbsPosition();
	
	if(scrollBarName == nil)then
		if(self.landScrollBarState == "myLands")then
			scrollBarName = "landInfo";
		else
			scrollBarName = "myLands"
		end
	end
	
	if(scrollBarName == "myLands")then
		local _this = ParaUI.GetUIObject(self.name.."landInfoCtn");
		if(_this:IsValid())then
			_this.height = 24;
		end
		
		_this = ParaUI.GetUIObject(self.name.."landInfo");
		if(_this:IsValid())then
			_this.visible = false;
		end
		
		_this = ParaUI.GetUIObject(self.name.."myLandsCtn");
		if(_this:IsValid())then
			_this.y = 28;
			_this.height = height - 28;
		end
		
		_this = ParaUI.GetUIObject(self.name.."myLands");
		if(_this:IsValid())then
			_this.visible = true;
		end
		
		self.landScrollBarState = "myLands";
	elseif(scrollBarName == "landInfo")then
		local _this = ParaUI.GetUIObject(self.name.."landInfoCtn");
		if(_this:IsValid())then
			_this.height = height - 32;
		end
		
		_this = ParaUI.GetUIObject(self.name.."landInfo");
		if(_this:IsValid())then
			_this.visible = true;
		end
		
		_this = ParaUI.GetUIObject(self.name.."myLandsCtn");
		if(_this:IsValid())then
			_this.y =  height - 28;
			_this.height = 24;
		end
		
		_this = ParaUI.GetUIObject(self.name.."myLands");
		if(_this:IsValid())then
			_this.visible = false;
		end
		
		self.landScrollBarState = "landInfo";
	end
end

function TileEditWnd.SwitchAttPage(pageName)
	if(pageName == "landPage")then
		local _this = ParaUI.GetUIObject(TileEditWnd.name.."landPage");
		if(_this:IsValid())then
			_this.visible = true;
		end
		
		_this = ParaUI.GetUIObject(TileEditWnd.name.."markPage");
		if(_this:IsValid())then
			_this.visible = false;
		end
		
		_this = ParaUI.GetUIObject(TileEditWnd.name.."modelPage");
		if(_this:IsValid())then
			_this.visible = false;
		end
	elseif(pageName == "markPage")then
		local _this = ParaUI.GetUIObject(TileEditWnd.name.."landPage");
		if(_this:IsValid())then
			_this.visible = false;
		end
		
		_this = ParaUI.GetUIObject(TileEditWnd.name.."markPage");
		if(_this:IsValid())then
			_this.visible = true;
		end
		
		_this = ParaUI.GetUIObject(TileEditWnd.name.."modelPage");
		if(_this:IsValid())then
			_this.visible = false;
		end
	elseif(pageName == "modelPage")then
		local _this = ParaUI.GetUIObject(TileEditWnd.name.."landPage");
		if(_this:IsValid())then
			_this.visible = false;
		end
		
		_this = ParaUI.GetUIObject(TileEditWnd.name.."markPage");
		if(_this:IsValid())then
			_this.visible = false;
		end
		
		_this = ParaUI.GetUIObject(TileEditWnd.name.."modelPage");
		if(_this:IsValid())then
			_this.visible = true;
		end
	end	
end

function TileEditWnd.SetTileID(tileID)
	TileEditWnd.tileID = tileID;
end


--UI event 
function TileEditWnd.OnMyLandsBtn()
	TileEditWnd.SwitchLandScrollBar();
end

function TileEditWnd.OnLandInfoBtn()
	TileEditWnd.SwitchLandScrollBar();
end

function TileEditWnd.OnAttMenuClick(node)
	if(node.Name == "land")then
		TileEditWnd.SwitchAttPage("landPage");
	elseif(node.Name == "mark")then
		TileEditWnd.SwitchAttPage("markPage");
	elseif(node.Name == "model")then
		TileEditWnd.SwitchAttPage("modelPage");
	end
end

function Map3DApp.TileEditWnd.OnNextModelPageClick()
	 TileEditWnd.OnNextModelPage();
end

function Map3DApp.TileEditWnd.OnPreModelPageClick()
	TileEditWnd.OnPreModelPage();
end

function Map3DApp.TileEditWnd.OnModelGridViewClick(cell)
	if(cell == nil)then
		return;
	end
	
	
end

function Map3DApp.TileEditWnd.OnFilterBtnClick(ctrName)
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditor.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditCmd.lua");
	
	local s = "2,0.12,-0.342,23.04;23,-1.3,3.0,-34.0;";
	local temp = Map3DApp.DataPvdHelper.ParseModels(s)
	if(temp)then
		log(commonlib.serialize(temp))
	else
		log("temp is nil...\n");
	end
end

--logic
function TileEditWnd.OnControlLoad()
	TileEditWnd.OnModelGridViewLoad();
end

function TileEditWnd.OnModelGridViewLoad()
	local _this = CommonCtrl.GetControl(TileEditWnd.name.."modelGV");
	if(_this == nil)then
		return;
	end
	
	TileEditWnd.CalcModelPageCount();
	TileEditWnd.currentPage = 1;
	
	TileEditWnd.UpdatePageIndexDisplay()
	
	local data = Map3DApp.DataPvd.GetModelOfPage(_this:GetMaxCellCount(),1);
	_this:SetData(data);
end

function TileEditWnd.OnNextModelPage()
	local _this = CommonCtrl.GetControl(TileEditWnd.name.."modelGV");
	if(_this == nil)then
		return;
	end
	
	--update index
	TileEditWnd.currentPage = TileEditWnd.currentPage + 1;
	if(TileEditWnd.currentPage > TileEditWnd.totalModelPage)then
		TileEditWnd.currentPage = 1;
	end
	TileEditWnd.UpdatePageIndexDisplay();
	
	--update data
	local data = Map3DApp.DataPvd.GetModelOfPage(_this:GetMaxCellCount(),TileEditWnd.currentPage);
	_this:SetData(data);
end

function TileEditWnd.OnPreModelPage()
	local _this = CommonCtrl.GetControl(TileEditWnd.name.."modelGV");
	if(_this == nil)then
		return;
	end
	
	--update index
	TileEditWnd.currentPage = TileEditWnd.currentPage - 1;
	if(TileEditWnd.currentPage < 1)then
		TileEditWnd.currentPage = TileEditWnd.totalModelPage;
	end
	TileEditWnd.UpdatePageIndexDisplay();
	
	--update data
	local data = Map3DApp.DataPvd.GetModelOfPage(_this:GetMaxCellCount(),TileEditWnd.currentPage);
	_this:SetData(data);
end

function TileEditWnd.CalcModelPageCount()
	local _this = CommonCtrl.GetControl(TileEditWnd.name.."modelGV");
	if(_this == nil)then
		return;
	end
	
	local totalModel = Map3DApp.DataPvd.GetModelCount();
	local modelPerPage = _this:GetMaxCellCount();
	if(modelPerPage and modelPerPage > 0)then
		TileEditWnd.totalModelPage = math.ceil(totalModel/modelPerPage);
	else
		TileEditWnd.totalModelPage = 1;
	end
end

function TileEditWnd.UpdatePageIndexDisplay()
	local ctr = ParaUI.GetUIObject(TileEditWnd.name.."pageindex");
	if(ctr:IsValid())then
		ctr.text = TileEditWnd.currentPage.."/"..TileEditWnd.totalModelPage;
	end
end
