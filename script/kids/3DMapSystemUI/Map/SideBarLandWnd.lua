

NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapMessageDefine.lua");

SideBarLandWnd = {
	name = "sbLandWnd",
	parent = nil,
	app = nil,
	tvLands = nil,
	tvLandDetail = nil,
	isVisible = false;
	listeners = {},
	selectTile = nil,
}
Map3DApp.SideBarLandWnd = SideBarLandWnd;

function SideBarLandWnd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	CommonCtrl.AddControl(o.name,o);
	return o;
end

function SideBarLandWnd:Show(bShow)
	if(bShow == nil)then
		self.isVisible = not self.isVisible;
	else
		self.isVisible = bShow;
	end
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.visible = self.isVisible;
	else
		if(self.isVisible)then
			self:CreateUI();
		end
	end
	
	if(self.tvLands)then
		self.tvLands:Show(self.isVisible);
	end
	
	self:SetMyLands(Map3DApp.SideBarLandWnd.MockGetTileInfos());
	self:SetCommendLands(Map3DApp.SideBarLandWnd.MockGetTileInfos());
end

function SideBarLandWnd:SetCommendLands(tileInfos)
	if(tileInfos == nil or self.tvLands == nil)then
		return;
	end
	
	local node = self.tvLands.RootNode:GetChildByName("commendLands");
	if(node)then
		self:UpdateLandsNode(node,tileInfos,"commendLand");
	end
end

function SideBarLandWnd:SetMyLands(tileInfos)
	if(tileInfos == nil or self.tvLands == nil)then
		return;
	end
	
	local node = self.tvLands.RootNode:GetChildByName("myLands");
	if(node)then
		self:UpdateLandsNode(node,tileInfos,"myland");
	end
end

function SideBarLandWnd:ShowLandDetail(tileInfo)
	self.selectTile = tileInfo;
	local _this;
	_this = ParaUI.GetUIObject(self.name.."landDetail");
	if(_this:IsValid() == false)then
		return;
	end
	self:ResetLandDetailWnd();
	
	if(tileInfo == nil)then
		return;
	end
	
	local temp;
	_this = ParaUI.GetUIObject(self.name.."landName");
	temp = Map3DApp.Data.GetDataField(tileInfo,"name");
	if(temp ~= nil)then
		_this.text = temp;
	end
	
	_this = ParaUI.GetUIObject(self.name.."landState");
	temp = Map3DApp.Data.GetDataField(tileInfo,"tileState");
	if(temp ~= nil)then
		if(temp == Map3DApp.TileState.sale)then
			_this.text = "出售中";
		elseif(temp == Map3DApp.TileState.sold)then
			_this.text = "私人土地";
		elseif(temp == Map3DApp.TileState.rent)then
			_this.text = "出租中";
		elseif(temp == unopened or temp == reserve)then
			_this.text = "未开放土地";
		end
	end
	
	_this = ParaUI.GetUIObject(self.name.."landOwner");
	temp = Map3DApp.Data.GetDataField(tileInfo,"ownerUserName");
	if(temp)then
		_this.text = temp;
	end	
	
	_this = ParaUI.GetUIObject(self.name.."landCity");
	temp = Map3DApp.Data.GetDataField(tileInfo,"cityName");
	if(temp)then
		_this.text = temp;
	end
	
	_this = ParaUI.GetUIObject(self.name.."landRank");
	temp = Map3DApp.Data.GetDataField(tileInfo,"ranking");
	if(temp)then
		_this.text = tostring(temp);
	end
	
	_this = ParaUI.GetUIObject(self.name.."landUser");
	temp = Map3DApp.Data.GetDataField(tileInfo,"username");
	if(temp)then
		_this.text = temp;
	end
	
	_this = ParaUI.GetUIObject(self.name.."landPrice");
	temp = Map3DApp.Data.GetDataField(tileInfo,"price");
	if(temp)then
		_this.text = temp.."g";
	end
	
	self:ShowTileOperateBtn(tileInfo);
end

function SideBarLandWnd:ShowTileOperateBtn(tileInfo)
	local _this = ParaUI.GetUIObject(self.name.."btnOpTile");
	if(_this:IsValid() == false)then
		return;
	end
	
	_this.visible = false;
	local state = Map3DApp.Data.GetDataField(tileInfo,"allowEdit");
	if(state)then
		_this.text = "编辑";
		_this.visible = true;
	else
		state = Map3DApp.Data.GetDataField(tileInfo,"tileState");
		if(state == Map3DApp.TileState.sale)then
			_this.text = "立即购买";
			_this.visible = true;
		elseif(state == Map3DApp.TileState.rent)then
			_this.text = "我要租";
			_this.visible = true;
		end
	end
	_this.visible = false;
end

function SideBarLandWnd:AddListener(name,listener)
	self.listeners[name] = listener;	
end

function SideBarLandWnd:RemoveListener(name)
	if(self.liseners[name])then
		self.liseners[name] = nil;
	end
end

function SideBarLandWnd:SendMessage(msg,data)
	for __,listener in pairs(self.listeners)do
		listener:SetMessage(self.name,msg,data);
	end
end

function SideBarLandWnd:SetParentWnd(parent)
	self.parent = parent;
end

--==================private============================
function SideBarLandWnd:Init()
	NPL.load("(gl)script/ide/TreeView.lua");
	self.tvLands = CommonCtrl.TreeView:new{
		name = self.name.."landtv",
		alignment = "_mt",
		left = 3,
		top = 25,
		width = 3,
		height = 230,
		parentCtr = self,
		container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		DefaultIndentation = 5,
		DefaultNodeHeight = 25,
		--onclick =Map3DApp.LandWnd.OnClickLandNode
		DrawNodeHandler = Map3DApp.SideBarLandWnd.DrawLandNode;
	};
	local rootNode = self.tvLands.RootNode;
	rootNode:AddChild( CommonCtrl.TreeNode:new({Text = "我的土地", Name = "myLands", }));
	rootNode:AddChild( CommonCtrl.TreeNode:new({Text = "热门土地", Name = "commendLands", }));
end

function SideBarLandWnd:CreateUI()
	local _this,_parent;
	_this = ParaUI.CreateUIObject("container", self.name, "_fi", 2, 25, 2, 2)
	_this.background = "";
	_this.onsize = string.format(";Map3DApp.SideBarLandWnd.OnReSize(%q);",self.name);
	if(self.parent)then
		self.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	_parent = _this;
	
	if(self.tvLands)then
		self.tvLands.parent = _this;
	end
	
	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 3, 6, 180, 16);
	_this.text = "拖动地图, 查看土地信息";
	_this:GetFont("text").color = "42 165 42";
	_parent:AddChild(_this);
	
	self:CreateLandDetailWnd();
end

function SideBarLandWnd.DrawLandNode(_parent,node)
	if(_parent == nil or node == nil)then
		return;
	end
	
	local _this;
	--local left = 2; -- indentation of this node. 
	local top = 2;
	local height = node:GetHeight();
	local nodeWidth = node.TreeView.ClientWidth;
	local width = nodeWidth;
	
	local left = node.TreeView.DefaultIndentation*(node.Level-1) + 4;
	
	if(node.TreeView.ShowIcon) then
		local IconSize = node.TreeView.DefaultIconSize;
		if(node.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = node.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
			left = left + IconSize+3;
		end	
	end	

	if(node.Name == "welcome"  ) then
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+3, 4, 140, 18)
		_this.text = node.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		--_this.onclick = string.format(";Map3DApp.LandWnd.OnClickLandNode(%q, %q)", node.TreeView.name, node:GetNodePath());
		_parent:AddChild(_this);

	elseif(node.Name == "myland") then
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+3, 4, 140, 18)
		_this.text = node.Text;
		_this.tooltip=node.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		_this.onclick = string.format(";Map3DApp.SideBarLandWnd.OnClickLandNode(%q, %q)", node.TreeView.name, node:GetNodePath());
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+120, 4, 40, 18)
		_this.text = "编辑";
		--_this.onclick = string.format(";Map3DApp.SideBarLandWnd.OnEditLandBtn(%q, %q)",node.TreeView.name, node:GetNodePath());
		_this.tooltip = "此功能稍后可用";
		_parent:AddChild(_this);

	elseif(node.Name == "commendLand") then
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+3, 4, 140, 18)
		_this.text = node.Text;
		_this.tooltip=node.Text;
		_guihelper.SetUIFontFormat(_this, 0+4);
		_this.background = "";
		_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
		_this.onclick = string.format(";Map3DApp.SideBarLandWnd.OnClickLandNode(%q, %q)", node.TreeView.name, node:GetNodePath());
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left+120, 4, 40, 18)
		_this.text = "购买";
		--_this.onclick = string.format(";Map3DApp.SideBarLandWnd.OnBuyLandBtn(%q, %q)", node.TreeView.name, node:GetNodePath());
		_this.tooltip = "此功能稍后可用";
		_parent:AddChild(_this);
		
	elseif(node.Name == "myLands" or node.Name == "commendLands") then
		CommonCtrl.TreeView.RenderCategoryNode(_parent,node, left, top, width, height)
	end
end

function SideBarLandWnd:UpdateLandsNode(node,tileInfos,nodeName)
	node:ClearAllChildren();
	for __,tileInfo in pairs(tileInfos)do
		node:AddChild((CommonCtrl.TreeNode:new({tag = tileInfo, Text = tileInfo.name,Name = nodeName})));
	end
	self.tvLands:Update();
end

function SideBarLandWnd:CreateLandDetailWnd()
	local _parent = ParaUI.GetUIObject(self.name)
	if(_parent:IsValid()==false)then
		return;
	end

	local _this = ParaUI.CreateUIObject("container",self.name.."landDetail","_fi",3,270,3,3);
	_parent:AddChild(_this);
	_parent = _this;
	
	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 4, 10, 0, 12)
	_this.text = "详细信息";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", self.name.."btnOpTile", "_lt", 110, 8, 60, 18)
	_this.text = "立即购买"
	_this.visible = false;
	_this.onclick = string.format(";Map3DApp.SideBarLandWnd.OnLandOperationBtn(%q)",self.name);
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 32, 0, 12)
	_this.text = "名称:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."landName", "_lt", 50, 32, 180, 0)
	_this.text = "";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 56, 0, 12)
	_this.text = "状态:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."landState", "_lt", 50, 56, 180, 0)
	_this.text = "";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 80, 0, 12)
	_this.text = "所有者:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."landOwner", "_lt", 60, 80, 170, 0)
	_this.text = "";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 128, 0, 12)
	_this.text = "所属城市:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."landCity", "_lt", 78, 128, 170, 0)
	_this.text = "";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 152, 0, 12)
	_this.text = "售价:";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."landPrice", "_lt", 50, 152, 160, 0)
	_this.text = "";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 104, 0, 12)
	_this.text = "使用者:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", self.name.."landUser", "_lt", 60, 104, 180, 0)
	_this.text = "";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", self.name.."s", "_lt", 13, 176, 0, 12)
	_this.text = "土地评级:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", self.name.."landRank", "_lt", 78, 176, 160, 0)
	_this.text = "";
	_parent:AddChild(_this);
	
	_parent.scrollable = true;
end

function SideBarLandWnd:ResetLandDetailWnd()
	local _this = ParaUI.GetUIObject(self.name.."landDetail");
	if(_this:IsValid())then
		_this = ParaUI.GetUIObject(self.name.."btnOpTile");
		_this.visible = false;
		_this.text = "";
		_this = ParaUI.GetUIObject(self.name.."landName");
		_this.text = "n/a";
		_this = ParaUI.GetUIObject(self.name.."landState");
		_this.text = "n/a";
		_this = ParaUI.GetUIObject(self.name.."landOwner");
		_this.text = "n/a";
		_this = ParaUI.GetUIObject(self.name.."landCity");
		_this.text = "n/a";
		_this = ParaUI.GetUIObject(self.name.."landRank");
		_this.text = "n/a";
		_this = ParaUI.GetUIObject(self.name.."landUser");
		_this.text = "n/a";
		_this = ParaUI.GetUIObject(self.name.."landPrice");
		_this.text = "n/a";
	end
end

function SideBarLandWnd.OnReSize(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self ~= nil and self.tvLands ~= nil)then
		self.tvLands:Update();
	end

	ParaUI.Destroy(self.name.."landDetail");
	self:CreateLandDetailWnd();
end

function SideBarLandWnd.OnClickLandNode(ctrName,nodePath)
	local ctr,node = CommonCtrl.TreeView.GetCtl(ctrName,nodePath);
	if(node and node.tag)then
		if(ctr and ctr.parentCtr)then
			local _this = CommonCtrl.GetControl(ctr.parentCtr.name);
			if(_this)then
				_this:ShowLandDetail(node.tag);
			end
		end
	end
end

function SideBarLandWnd.OnEditLandBtn(ctrName,nodePath)
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditWnd.lua");
	Map3DApp.TileEditWnd.Show();
	--Map3DApp.TileEditWnd.SwitchLandScrollBar();
	
	--local ctr,node = CommonCtrl.TreeView.GetCtl(ctrName,nodePath);
	--if(node and node.tag)then
		--if(ctr and ctr.parentCtr)then
			--local self = CommonCtrl.GetControl(ctr.parentCtr.name);
			--if(self)then
				--self:SendMessage(Map3DApp.Msg.onEditTile,node.tag);
			--end
		--end
	--end
end

function SideBarLandWnd.OnBuyLandBtn(ctrName,nodePath)
	local ctr,node = CommonCtrl.TreeView.GetCtl(ctrName,nodePath);
	if(node and node.tag)then
		if(ctr and ctr.parentCtr)then
			local self = CommonCtrl.GetControl(ctr.parentCtr.name);
			if(self)then
				self:SendMessage(Map3DApp.Msg.onBuyTile,node.tag);
			end
		end
	end
end

function SideBarLandWnd.OnLandOperationBtn(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	local _this = ParaUI.GetUIObject(self.name.."btnOpTile");
	if(_this:IsValid())then
		
		local state = Map3DApp.Data.GetDataField( self.selectTile,"allowEdit");
		--if allow edit,send edit tile message
		if(state)then
			self:SendMessage(Map3DApp.Msg.onEditTile,self.selectTile);	
		else
			state = Map3DApp.Data.GetDataField( self.selectTile,"tileState");
			--if tile is on saling, send buy tile message
			if(state == Map3DApp.TileState.sale)then
				self:SendMessage(Map3DApp.Msg.onBuyTile,self.selectTile);
			
			--if tile is on renting,send rent tile message
			elseif(state == Map3DApp.TileState.rent)then
				self:SendMessage(Map3DApp.Msg.onRentTile,self.selectTile);
			end
		end
	end
end

--=======================================================
function Map3DApp.SideBarLandWnd.MockGetTileInfos()
	local tileInfo_1 = {
		id = 1,
		name = "林中小屋",
		x = -1, --normalized position [0,1]
		y = -1, --normalized position [0,1]
		z = 0, --normalized position[0,1]
		terrainInfo = {}, --tarrainInfo object
		models = {}, -- modelData array	
		modelCount = 0, 	
		ownerUserID = "test1",
		ownerUserName = "我的土地1",
		ranking = 0,
		cityName = "",
		ageGroup = 0,
		communityID = 0,
		communityName = "",
		price = 0,
		tileState = Map3DApp.TileState.sale,
		price2 = 0,
		price2StartTime = "",
		price2EndTime = "",
		rentPrice = 0,
		allowEdit = false;
	}
	
	local tileInfo_2 = {
		id = 2,
		name = "小酒馆";
		x = -1, --normalized position [0,1]
		y = -1, --normalized position [0,1]
		z = 0, --normalized position[0,1]
		tileState = Map3DApp.TileState.rent,
		terrainInfo = {}, --tarrainInfo object
		models = {}, -- modelData array	
		modelCount = 0, 	
		ownerUserID = "test2",
		ownerUserName = "我的土地2",
		ranking = 0,
		cityName = "",
		ageGroup = 0,
		communityID = 0,
		communityName = "",
		price = 0,
		price2 = 0,
		price2StartTime = "",
		price2EndTime = "",
		rentPrice = 0,
		allowEdit = false
	}
	
	local tileInfo_3 = {
		id = 3;
		name = "魔法角",
		ownerUserID = "test",
		ownerUserName = "myLand",
		username = "meme",
		ranking = 10,
		cityName = "Magic Land",
		price = 100,
		rentPrice = 0,
		allowEdit = true,
		tileState = 2
	}
	
	local tileInfo_4 = {
		id = 3;
		name = "secret chamber",
		ownerUserID = "test",
		ownerUserName = "myLand",
		username = "meme",
		ranking = 10,
		cityName = "Magic Land",
		price = 100,
		rentPrice = 0,
		allowEdit = false,
		tileState = 2
	}
	
	return {tileInfo_1,tileInfo_2,tileInfo_3,tileInfo_4};
end
 