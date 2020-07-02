--[[
Title: template: windows form or modeless dialog
Author(s): Leio, original template by LiXizhi
Date: 2008/1/14
Parameters:
	MarketListCtl: it needs to be a valid name, such as MyDialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/MarketApp/MarketListCtl.lua");
local ctl = CommonCtrl.MarketListCtl:new{
	name = "MarketListCtl1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/MarketApp/MarketService.lua");
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local MarketListCtl = {
	-- the top level control name
	name = "MarketListCtl1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
}
Map3DSystem.App.MarketListCtl = MarketListCtl;

-- constructor
function MarketListCtl:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function MarketListCtl:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function MarketListCtl:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("MarketListCtl instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
				-- nplDesignPanel1
		

		_this = ParaUI.CreateUIObject("button", "prePage_btn", "_rb", -176, -40, 75, 23)
		_this.text = "上一页";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "nextPage_btn", "_rb", -95, -40, 75, 23)
		_this.text = "下一页";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);
		
		local left=40;
		_this = ParaUI.CreateUIObject("text", "label2", "_lt", left, 13, 75, 16)
		_this.text = "商品";
		_parent:AddChild(_this);
		
		left=left+140;
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", left, 13, 75, 16)
		_this.text = "名称";
		_parent:AddChild(_this);
		
		left=left+50;
		_this = ParaUI.CreateUIObject("button", "price_btn", "_lt", left, 10, 75, 23)
		_this.text = "价格";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);
		left=left+80;
		_this = ParaUI.CreateUIObject("button", "amount_btn", "_lt", left, 10, 75, 23)
		_this.text = "库存";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);
		
		left=left+110;
		_this = ParaUI.CreateUIObject("text", "label3", "_lt", left, 13, 75, 16)
		_this.text = "说明";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "Map3DSystem.App.MarketListCtl.MarketListTreeView",
			alignment = "_fi",
			left = 3,
			top = 39,
			width = 3,
			height = 46,
			parent = _parent,
			DefaultIndentation = 5,
			DefaultNodeHeight = 50,
			DrawNodeHandler = Map3DSystem.App.MarketListCtl.DrawGoodsNodeHandler,
			onclick = Map3DSystem.App.MarketListCtl.OnClickGoodsNode,
		};
		MarketListCtl.GetItemList();
		--[[
		local node = ctl.RootNode;
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }) );
		ctl:Show();
		--]]
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- close the given control
function MarketListCtl.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting MarketListCtl instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- this function is called, when a goods node is clicked. 
function MarketListCtl.OnClickGoodsNode(treeNode)

end

-- owner draw function to MarketListCtl
function MarketListCtl.DrawGoodsNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		left = left + IconSize;
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.type == "group") then
		-- render my map group treeNode: a colored name and an expand arrow
		width = 24 -- check box width
		
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 2;
		
		if(treeNode.Expanded) then
			_this.background = "Texture/3DMapSystem/common/itemopen.png";
		else
			_this.background = "Texture/3DMapSystem/common/itemclosed.png";
		end
		
		_this=ParaUI.CreateUIObject("text", "b", "_lt", left, 5, nodeWidth - left-1, height);
		_parent:AddChild(_this);
		_this:GetFont("text").format=36; -- single line and vertical align
		
		_this.text = treeNode.Text;
		
	elseif(treeNode.type == "goods_node") then
		--Goods Icon
		_this=ParaUI.CreateUIObject("container","c","_lt", left, 2 , 75, 40);
		_parent:AddChild(_this);
		--Goods Name
		left=left+160;
		_this=ParaUI.CreateUIObject("text","b","_lt", left, 2 , 75, 40);
		_parent:AddChild(_this);
		_this.text = tostring(treeNode.Name);
		--Goods Price
		left=left+80;
		_this=ParaUI.CreateUIObject("text","b","_lt", left, 2 , 75, 2);
		_parent:AddChild(_this);
		_this.text = tostring(treeNode.Price);
		--Goods Amount
		left=left+80;
		_this=ParaUI.CreateUIObject("text","b","_lt", left, 2 , 75, 2);
		_parent:AddChild(_this);
		_this.text = tostring(treeNode.Amount);
		--Goods Description
		left=left+80;
		_this=ParaUI.CreateUIObject("text","b","_lt", left, 2 , 75, 2);
		_parent:AddChild(_this);
		_this.text = tostring(treeNode.Description);
		
		--Buy	
		left=left+120;
		_this=ParaUI.CreateUIObject("button","b","_lt", left, 2 , 75, 20);
		_parent:AddChild(_this);
		_this.onclick = string.format(";Map3DSystem.App.MarketListCtl.DoBuy('%s', %s)",treeNode.app_key,treeNode.GoodsID);
		_this.text = "购买";
		
			
	end
end

function MarketListCtl.GetItemList(app_key, pageNumber, ItemsPerPage)
	local list=Map3DSystem.App.MarketService.GetItemList(app_key, pageNumber, ItemsPerPage);
	
	local ctl = CommonCtrl.GetControl("Map3DSystem.App.MarketListCtl.MarketListTreeView");
	local node = ctl.RootNode;
	
	list={
		{type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" },
		{type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" },
		{type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" },
		{type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" },
		{type="goods_node", Icon = "", Name = "Goods1", GoodsID = 1, app_key="abc app",
			Price=10, Price2=nil, Price2StartTime=nil,Price2EndTime=nil, Amount=10, Description ="阿德司法所地方" }
	}
		for k,v in ipairs(list) do
			
			node:AddChild( CommonCtrl.TreeNode:new(v) );
		end
	ctl:Show();
end
function MarketListCtl.DoBuy(app_key, item_id)
	log(app_key.."\n");
	--log(string.format("%s,%s\n",app_key,item_id));
	--Map3DSystem.App.MarketService.BuyItem(app_key, item_id)
end